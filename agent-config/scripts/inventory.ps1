param(
    [Parameter(Mandatory = $true)]
    [string]$RepoRoot
)

$ErrorActionPreference = "Stop"
if (-not (Test-Path $RepoRoot)) {
    Write-Error "Repo root not found: $RepoRoot"
    exit 1
}

$csproj = Get-ChildItem -Path $RepoRoot -Recurse -Filter *.csproj -File |
    Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' }
$aspx = Get-ChildItem -Path $RepoRoot -Recurse -Filter *.aspx -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' }
$controllers = Get-ChildItem -Path $RepoRoot -Recurse -Filter *Controller.cs -File |
    Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' }

Write-Output "=== Project files ==="
if (-not $csproj) {
    Write-Output "NO_CSPROJ"
    if ($aspx) {
        Write-Output "STOP: Web Site style .aspx files without a .csproj. See agent-config/rules/stop-list.md."
    }
}
foreach ($project in $csproj) {
    $text = Get-Content -Path $project.FullName -Raw
    $tfm = "unknown"
    $version = [regex]::Match($text, '<TargetFrameworkVersion>\s*(v[^<]+)\s*</TargetFrameworkVersion>')
    $sdkTfm = [regex]::Match($text, '<TargetFramework>\s*([^<]+)\s*</TargetFramework>')
    if ($version.Success) { $tfm = $version.Groups[1].Value.Trim() }
    elseif ($sdkTfm.Success) { $tfm = $sdkTfm.Groups[1].Value.Trim() }
    $sdk = $text -match '<Project\s+Sdk='
    Write-Output ("{0} | tfm={1} | sdk-style={2}" -f $project.FullName, $tfm, $sdk)
}

Write-Output "=== Counts ==="
Write-Output ("csproj={0}" -f @($csproj).Count)
Write-Output ("aspx={0}" -f @($aspx).Count)
Write-Output ("controllers={0}" -f @($controllers).Count)
Write-Output ("svc={0}" -f @(Get-ChildItem -Path $RepoRoot -Recurse -Filter *.svc -File -ErrorAction SilentlyContinue).Count)
Write-Output ("asmx={0}" -f @(Get-ChildItem -Path $RepoRoot -Recurse -Filter *.asmx -File -ErrorAction SilentlyContinue).Count)
Write-Output ("edmx={0}" -f @(Get-ChildItem -Path $RepoRoot -Recurse -Filter *.edmx -File -ErrorAction SilentlyContinue).Count)

Write-Output "=== Controllers ==="
foreach ($controller in $controllers) {
    $text = Get-Content -Path $controller.FullName -Raw
    $actions = [regex]::Matches($text, 'public\s+(?:async\s+)?(?:Task\s*<\s*)?(?:IActionResult|ActionResult|ViewResult|JsonResult)\s*>?\s+(\w+)\s*\(')
    $names = @($actions | ForEach-Object { $_.Groups[1].Value })
    Write-Output ("{0} | actions={1}" -f $controller.Name, ($names -join ","))
}
