param(
    [Parameter(Mandatory = $true)]
    [string]$LegacyRoot,
    [Parameter(Mandatory = $true)]
    [string]$ModernRoot,
    [string]$ParityMap,
    [string]$BaseUrl,
    [switch]$WholeApp,
    [string]$LoginUrl,
    [string]$LoginFields
)

$ErrorActionPreference = "Stop"
$LegacyRoot = (Resolve-Path $LegacyRoot).Path.TrimEnd('\', '/')
$ModernRoot = (Resolve-Path $ModernRoot).Path.TrimEnd('\', '/')
$failures = New-Object System.Collections.Generic.List[string]
$pages = @{}
$session = $null
$skipMethods = @("Dispose", "ToString", "Equals", "GetHashCode")

function Get-SourceFiles([string]$root) {
    Get-ChildItem -Path $root -Recurse -File |
        Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules)\\' }
}

function Get-RelativePath([string]$root, [string]$path) {
    $path.Substring($root.Length).TrimStart('\', '/')
}

function Find-MappedFile([object[]]$files, [string]$mapped) {
    $path = $mapped.Trim().Trim('`').Replace('/', '\').TrimStart('.').TrimStart('\')
    if ([string]::IsNullOrWhiteSpace($path)) { return @() }
    @($files | Where-Object { $_.FullName.EndsWith('\' + $path, [StringComparison]::OrdinalIgnoreCase) })
}

function Get-ActionNames([string]$path) {
    $text = Get-Content -Path $path -Raw
    $found = [regex]::Matches($text, '(?m)^\s*public\s+(?:async\s+)?(?:override\s+)?(?:virtual\s+)?(?!void\b)(?:[A-Za-z0-9_<>\.\[\]\?]|,\s*)+\s+(\w+)\s*\(')
    @($found | ForEach-Object { $_.Groups[1].Value } | Where-Object { $skipMethods -notcontains $_ } | Select-Object -Unique)
}

function Get-CleanCell([string]$cell) {
    $cell.Trim().Trim('`').Trim()
}

function Get-ActionCell([string]$cell) {
    $match = [regex]::Match($cell, '[\*\w]+')
    if ($match.Success) { return $match.Value }
    return ''
}

function Get-MarkdownTables([string]$path) {
    $tables = @()
    $headers = $null
    $rows = $null
    foreach ($line in Get-Content -Path $path -Encoding UTF8) {
        if ($line -notmatch '^\s*\|') {
            if ($headers) { $tables += [pscustomobject]@{ Headers = $headers; Rows = $rows.ToArray() } }
            $headers = $null
            continue
        }
        $cells = @($line.Trim().Trim('|').Split('|') | ForEach-Object { Get-CleanCell $_ })
        if (-not $headers) {
            $headers = $cells
            $rows = New-Object System.Collections.Generic.List[object]
            continue
        }
        if ($cells[0] -match '^:?-+:?$') { continue }
        $row = @{}
        for ($i = 0; $i -lt $headers.Count -and $i -lt $cells.Count; $i++) {
            $row[$headers[$i]] = $cells[$i]
        }
        $rows.Add($row)
    }
    if ($headers) { $tables += [pscustomobject]@{ Headers = $headers; Rows = $rows.ToArray() } }
    return $tables
}

function Get-RowsWith([object[]]$tables, [string[]]$columns) {
    $result = @()
    foreach ($table in $tables) {
        $hasAll = $true
        foreach ($column in $columns) {
            if ($table.Headers -notcontains $column) { $hasAll = $false }
        }
        if ($hasAll) { $result += @($table.Rows) }
    }
    return $result
}

function Test-LayoutDeclaresStyles([string]$root) {
    $layouts = Get-SourceFiles $root |
        Where-Object { $_.Name -like '_Layout*.cshtml' -or $_.Extension -eq '.master' }
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

function Get-AbsoluteUrl([string]$url, [string]$rootUrl) {
    if ($url -match '^(?i)https?://') { return $url }
    return $rootUrl + '/' + $url.TrimStart('/')
}

function Invoke-Page([string]$url) {
    if ($session) {
        return Invoke-WebRequest -Uri $url -UseBasicParsing -WebSession $session
    }
    return Invoke-WebRequest -Uri $url -UseBasicParsing
}

function Get-InputAttribute([string]$tag, [string]$name) {
    $match = [regex]::Match($tag, '\b' + $name + '\s*=\s*["'']([^"'']*)["'']', 'IgnoreCase')
    if ($match.Success) { return [System.Net.WebUtility]::HtmlDecode($match.Groups[1].Value) }
    return $null
}

function Invoke-FormLogin([string]$loginUrl, [string]$fields) {
    $script:session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $page = Invoke-WebRequest -Uri $loginUrl -UseBasicParsing -WebSession $script:session
    $form = $null
    foreach ($candidate in [regex]::Matches($page.Content, '<form\b[^>]*>.*?</form>', 'IgnoreCase, Singleline')) {
        if ($candidate.Value -match 'type\s*=\s*["'']password["'']') {
            $form = $candidate.Value
            break
        }
    }
    if (-not $form) {
        $failures.Add("Login page has no form with a password input: $loginUrl")
        return
    }
    $body = @{}
    foreach ($tag in [regex]::Matches($form, '<input\b[^>]*>', 'IgnoreCase')) {
        $type = Get-InputAttribute $tag.Value 'type'
        $name = Get-InputAttribute $tag.Value 'name'
        if ($name -and $type -eq 'hidden') {
            $body[$name] = Get-InputAttribute $tag.Value 'value'
        }
    }
    foreach ($pair in $fields.Split(';')) {
        $index = $pair.IndexOf('=')
        if ($index -lt 1) { continue }
        $body[$pair.Substring(0, $index).Trim()] = $pair.Substring($index + 1)
    }
    $postUrl = $loginUrl
    $action = Get-InputAttribute ([regex]::Match($form, '<form\b[^>]*>', 'IgnoreCase').Value) 'action'
    if ($action) { $postUrl = ([Uri]::new([Uri]$loginUrl, $action)).AbsoluteUri }
    try {
        $result = Invoke-WebRequest -Uri $postUrl -Method Post -Body $body -UseBasicParsing -WebSession $script:session
        if ($result.Content -match 'type\s*=\s*["'']password["'']') {
            $failures.Add("Login with -LoginFields did not succeed at $postUrl")
        }
        else {
            Write-Output "Signed in through $postUrl"
        }
    }
    catch {
        # A rejected login re-renders the form; a redirect away from it means the credentials were accepted,
        # even when the landing page itself errors (some legacy apps land on a URL that returns 404).
        $response = $_.Exception.Response
        $finalUri = $null
        if ($response -and $response.PSObject.Properties['ResponseUri']) { $finalUri = $response.ResponseUri }
        elseif ($response -and $response.PSObject.Properties['RequestMessage']) { $finalUri = $response.RequestMessage.RequestUri }
        $formPaths = @(([Uri]$postUrl).AbsolutePath, ([Uri]$loginUrl).AbsolutePath)
        if ($finalUri -and ($formPaths -notcontains $finalUri.AbsolutePath)) {
            Write-Output "Signed in through $postUrl (landing page $finalUri returned: $($_.Exception.Message))"
        }
        else {
            $failures.Add("Login POST failed at ${postUrl}: $($_.Exception.Message)")
        }
    }
}

$legacyFiles = @(Get-SourceFiles $LegacyRoot)
$modernFiles = @(Get-SourceFiles $ModernRoot)

if (-not $ParityMap -or -not (Test-Path $ParityMap)) {
    Write-Output "=== PARITY FAILED ==="
    Write-Output "A filled parity-map.md is required. Razor source tokens are not a screen check."
    exit 1
}

$tables = @(Get-MarkdownTables $ParityMap)
$actionRows = @(Get-RowsWith $tables @('Old file', 'Action', 'New file', 'New action'))
$excludedRows = @(Get-RowsWith $tables @('Old file', 'Action', 'Reason'))
$mappedFiles = @{}
$mappedActions = @{}
$excludedActions = @{}

if ($actionRows.Count -eq 0) {
    $failures.Add("Parity map has no controllers table (Old file, Action, New file, New action).")
}

foreach ($row in $excludedRows) {
    $found = @(Find-MappedFile $legacyFiles $row['Old file'])
    if ($found.Count -ne 1) {
        $failures.Add("Out-of-scope row: old file '$($row['Old file'])' matched $($found.Count) files under $LegacyRoot")
        continue
    }
    $key = $found[0].FullName
    $mappedFiles[$key] = $true
    if (-not $excludedActions.ContainsKey($key)) { $excludedActions[$key] = @() }
    $excludedActions[$key] += (Get-ActionCell $row['Action'])
}

foreach ($row in $actionRows) {
    $oldMatches = @(Find-MappedFile $legacyFiles $row['Old file'])
    if ($oldMatches.Count -ne 1) {
        $failures.Add("Old file '$($row['Old file'])' matched $($oldMatches.Count) files under $LegacyRoot")
        continue
    }
    $oldFile = $oldMatches[0]
    $mappedFiles[$oldFile.FullName] = $true
    if (-not $mappedActions.ContainsKey($oldFile.FullName)) { $mappedActions[$oldFile.FullName] = @() }
    $mappedActions[$oldFile.FullName] += (Get-ActionCell $row['Action'])

    $newMatches = @(Find-MappedFile $modernFiles $row['New file'])
    if ($newMatches.Count -eq 0) {
        $failures.Add("Missing new file '$($row['New file'])' under $ModernRoot")
        continue
    }
    if ($newMatches.Count -gt 1) {
        $failures.Add("New file '$($row['New file'])' matched $($newMatches.Count) files. Use a longer path or pass the web project folder as -ModernRoot.")
        continue
    }
    $newAction = Get-ActionCell $row['New action']
    if ($newMatches[0].Extension -eq '.cs') {
        $newActions = @(Get-ActionNames $newMatches[0].FullName)
        if ($newActions -notcontains $newAction) {
            $failures.Add("$($row['New file']) is missing action $newAction")
        }
    }
}

foreach ($path in @($mappedFiles.Keys | Sort-Object)) {
    if (-not $path.EndsWith('.cs', [StringComparison]::OrdinalIgnoreCase)) { continue }
    $relative = Get-RelativePath $LegacyRoot $path
    $excluded = @()
    if ($excludedActions.ContainsKey($path)) { $excluded = $excludedActions[$path] }
    if ($excluded -contains '*') {
        Write-Output "Controller ${relative}: out of scope"
        continue
    }
    $mapped = @()
    if ($mappedActions.ContainsKey($path)) { $mapped = $mappedActions[$path] }
    $oldActions = @(Get-ActionNames $path)
    foreach ($action in $oldActions) {
        if ($mapped -notcontains $action -and $excluded -notcontains $action) {
            $failures.Add("$relative action $action has no parity-map row and no out-of-scope row")
        }
    }
    Write-Output ("Controller {0}: old=[{1}] mapped=[{2}] out-of-scope=[{3}]" -f $relative, ($oldActions -join ","), (($mapped | Select-Object -Unique) -join ","), ($excluded -join ","))
}

if ($WholeApp) {
    $entryPoints = @($legacyFiles | Where-Object {
            $_.Name -like '*Controller.cs' -or $_.Extension -in @('.aspx', '.svc', '.asmx')
        })
    foreach ($file in $entryPoints) {
        if (-not $mappedFiles.ContainsKey($file.FullName)) {
            $failures.Add("Whole app: $(Get-RelativePath $LegacyRoot $file.FullName) is not in the controllers table or the out-of-scope table")
        }
    }
    Write-Output ("Whole app: {0} legacy entry points checked" -f $entryPoints.Count)
}

$rows = @(Get-RowsWith $tables @('Text that must appear', 'Page URL') | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_['Text that must appear']) -and
        -not [string]::IsNullOrWhiteSpace($_['Page URL']) -and
        $_['Text that must appear'] -notmatch 'from `_Layout`|Menu link text|Application name'
    })
if ($rows.Count -eq 0) {
    $failures.Add("Parity map has no rendered text rows.")
}
elseif ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    $failures.Add("Rendered check was not run. Start the new app and pass -BaseUrl.")
}
else {
    $rootUrl = $BaseUrl.TrimEnd('/')
    if ($LoginUrl) {
        Invoke-FormLogin (Get-AbsoluteUrl $LoginUrl $rootUrl) $LoginFields
    }
    foreach ($row in $rows) {
        $text = $row['Text that must appear']
        $url = Get-AbsoluteUrl $row['Page URL'] $rootUrl
        if (-not $pages.ContainsKey($url)) {
            try {
                $response = Invoke-Page $url
                $pages[$url] = [System.Net.WebUtility]::HtmlDecode($response.Content)
            }
            catch {
                $failures.Add("Could not load ${url}: $($_.Exception.Message)")
                $pages[$url] = ''
            }
        }
        if ($pages[$url] -notlike "*$text*") {
            $failures.Add("Missing '$text' on $url")
        }
        else {
            Write-Output "Found '$text' on $url"
        }
    }

    $legacyHasStyles = Test-LayoutDeclaresStyles $LegacyRoot
    $checkedAssets = @{}
    foreach ($pageUrl in @($pages.Keys)) {
        if ([string]::IsNullOrEmpty($pages[$pageUrl])) { continue }
        $hrefs = @(Get-StylesheetHrefs $pages[$pageUrl])
        if ($legacyHasStyles -and $hrefs.Count -eq 0) {
            $failures.Add("No stylesheet link on $pageUrl")
        }
        foreach ($href in $hrefs) {
            $asset = Resolve-AssetUrl $href $pageUrl $rootUrl
            if ($checkedAssets.ContainsKey($asset)) { continue }
            $checkedAssets[$asset] = $true
            try {
                $css = Invoke-Page $asset
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

if ($failures.Count -gt 0) {
    Write-Output "=== PARITY FAILED ==="
    $failures | ForEach-Object { Write-Output $_ }
    exit 1
}

Write-Output "=== PARITY PASSED ==="
exit 0
