param(
    [Parameter(Mandatory = $true)]
    [string]$LegacyRoot,
    [Parameter(Mandatory = $true)]
    [string]$ModernRoot,
    [string]$ParityMap,
    [string]$BaseUrl
)

$ErrorActionPreference = "Stop"
$LegacyRoot = (Resolve-Path $LegacyRoot).Path.TrimEnd('\', '/')
$ModernRoot = (Resolve-Path $ModernRoot).Path.TrimEnd('\', '/')
$failures = New-Object System.Collections.Generic.List[string]
$pages = @{}

function Get-SourceFiles([string]$root, [string]$filter) {
    Get-ChildItem -Path $root -Recurse -Filter $filter -File |
        Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' }
}

function Get-ActionNames([string]$path) {
    $text = Get-Content -Path $path -Raw
    $found = [regex]::Matches($text, 'public\s+(?:async\s+)?(?:Task\s*<\s*)?(?:IActionResult|ActionResult|ViewResult|JsonResult)\s*>?\s+(\w+)\s*\(')
    @($found | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
}

function Get-ParityRows([string]$path) {
    $rows = @()
    $textIndex = -1
    $urlIndex = -1
    foreach ($line in Get-Content -Path $path) {
        if ($line -notmatch '^\|') { continue }
        $cells = @($line.Trim('|').Split('|') | ForEach-Object { $_.Trim().Trim('`') })
        if ($cells -contains 'Text that must appear' -and $cells -contains 'Page URL') {
            $textIndex = [array]::IndexOf($cells, 'Text that must appear')
            $urlIndex = [array]::IndexOf($cells, 'Page URL')
            continue
        }
        if ($textIndex -lt 0) { continue }
        if ($cells[0] -match '^-+$') { continue }
        if ($cells.Count -le [Math]::Max($textIndex, $urlIndex)) { continue }
        $text = $cells[$textIndex]
        $url = $cells[$urlIndex]
        if ([string]::IsNullOrWhiteSpace($text) -or [string]::IsNullOrWhiteSpace($url)) { continue }
        if ($text -match 'from `_Layout`|Menu link text|Application name') { continue }
        $rows += [pscustomobject]@{ Text = $text; Url = $url }
    }
    return $rows
}

function Test-LayoutDeclaresStyles([string]$root) {
    $layouts = Get-ChildItem -Path $root -Recurse -File |
        Where-Object {
            $_.FullName -notmatch '\\(bin|obj)\\' -and (
                $_.Name -like '_Layout*.cshtml' -or $_.Extension -eq '.master'
            )
        }
    foreach ($file in $layouts) {
        $text = Get-Content -Path $file.FullName -Raw
        if ($text -match 'stylesheet|Styles\.Render|\.css') {
            return $true
        }
    }
    return $false
}

function Get-StylesheetHrefs([string]$html) {
    $found = New-Object System.Collections.Generic.List[string]
    foreach ($tag in [regex]::Matches($html, '<link\b[^>]*>', 'IgnoreCase')) {
        $text = $tag.Value
        $isStylesheet = $text -match 'rel\s*=\s*["'']stylesheet' -or $text -match '\.css'
        if (-not $isStylesheet) { continue }
        $href = [regex]::Match($text, 'href\s*=\s*["'']([^"'']+)["'']', 'IgnoreCase')
        if ($href.Success) { $found.Add($href.Groups[1].Value) }
    }
    return @($found | Select-Object -Unique)
}

function Resolve-AssetUrl([string]$href, [string]$pageUrl, [string]$rootUrl) {
    if ($href -match '^(?i)https?://') { return $href }
    if ($href.StartsWith('//')) { return 'http:' + $href }
    $path = $href
    if ($path.StartsWith('~/')) { $path = $path.Substring(1) }
    if ($path.StartsWith('/')) { return $rootUrl + $path }
    return ([Uri]::new([Uri]$pageUrl, $path)).AbsoluteUri
}

$scopedControllers = @()
if ($ParityMap -and (Test-Path $ParityMap)) {
    foreach ($line in Get-Content -Path $ParityMap) {
        if ($line -notmatch '^\|') { continue }
        foreach ($cell in ($line.Trim('|').Split('|') | ForEach-Object { $_.Trim().Trim('`') })) {
            if ($cell -match '([^\\/]+Controller\.cs)$') {
                $scopedControllers += $Matches[1]
            }
        }
    }
    $scopedControllers = @($scopedControllers | Select-Object -Unique)
}

$legacyControllers = @(Get-SourceFiles $LegacyRoot "*Controller.cs")
if ($scopedControllers.Count -gt 0) {
    $legacyControllers = @($legacyControllers | Where-Object { $scopedControllers -contains $_.Name })
}
$modernControllers = @(Get-SourceFiles $ModernRoot "*Controller.cs")

if ($legacyControllers.Count -eq 0) {
    Write-Error "No controllers found under $LegacyRoot"
    exit 1
}

foreach ($legacy in $legacyControllers) {
    $modern = $modernControllers | Where-Object { $_.Name -eq $legacy.Name } | Select-Object -First 1
    if (-not $modern) {
        $failures.Add("Missing controller file: $($legacy.Name)")
        continue
    }
    $oldActions = Get-ActionNames $legacy.FullName
    $newActions = Get-ActionNames $modern.FullName
    foreach ($action in $oldActions) {
        if ($newActions -notcontains $action) {
            $failures.Add("$($legacy.Name) is missing action $action")
        }
    }
    Write-Output ("Controller {0}: old=[{1}] new=[{2}]" -f $legacy.Name, ($oldActions -join ","), ($newActions -join ","))
}

if (-not $ParityMap -or -not (Test-Path $ParityMap)) {
    $failures.Add("A filled parity-map.md is required. Razor source tokens are not a screen check.")
}
else {
    $rows = @(Get-ParityRows $ParityMap)
    if ($rows.Count -eq 0) {
        $failures.Add("Parity map has no rendered text rows.")
    }
    elseif ([string]::IsNullOrWhiteSpace($BaseUrl)) {
        $failures.Add("Rendered check was not run. Start the new app and pass -BaseUrl.")
    }
    else {
        $rootUrl = $BaseUrl.TrimEnd('/')
        foreach ($row in $rows) {
            $relative = $row.Url
            if ($relative -notmatch '^https?://') {
                $relative = $rootUrl + '/' + $row.Url.TrimStart('/')
            }
            if (-not $pages.ContainsKey($relative)) {
                $response = Invoke-WebRequest -Uri $relative -UseBasicParsing
                $pages[$relative] = [System.Net.WebUtility]::HtmlDecode($response.Content)
            }
            if ($pages[$relative] -notlike "*$($row.Text)*") {
                $failures.Add("Missing '$($row.Text)' on $relative")
            }
            else {
                Write-Output "Found '$($row.Text)' on $relative"
            }
        }

        $legacyHasStyles = Test-LayoutDeclaresStyles $LegacyRoot
        $checkedAssets = @{}
        foreach ($pageUrl in @($pages.Keys)) {
            $hrefs = @(Get-StylesheetHrefs $pages[$pageUrl])
            if ($legacyHasStyles -and $hrefs.Count -eq 0) {
                $failures.Add("No stylesheet link on $pageUrl")
            }
            foreach ($href in $hrefs) {
                $asset = Resolve-AssetUrl $href $pageUrl $rootUrl
                if ($checkedAssets.ContainsKey($asset)) { continue }
                $checkedAssets[$asset] = $true
                try {
                    $css = Invoke-WebRequest -Uri $asset -UseBasicParsing
                    $length = [int]$css.RawContentLength
                    if ($css.StatusCode -ne 200 -or $length -lt 1) {
                        $failures.Add("Stylesheet did not load ($($css.StatusCode)) $asset")
                    }
                    else {
                        Write-Output "Stylesheet loaded $asset ($length bytes)"
                    }
                }
                catch {
                    $failures.Add("Stylesheet did not load: $asset")
                }
            }
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Output "=== PARITY FAILED ==="
    $failures | ForEach-Object { Write-Output $_ }
    exit 1
}

Write-Output "=== PARITY PASSED ==="
exit 0
