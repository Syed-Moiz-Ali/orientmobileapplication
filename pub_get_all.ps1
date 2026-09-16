$ErrorActionPreference = "Stop"
$root = (Resolve-Path $PSScriptRoot).Path

$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCommand) {
    throw "Flutter was not found in PATH. Install Flutter or add it to PATH before running this script."
}

$flutterProjects = @(
    Get-ChildItem -Path (Join-Path $root "apps"), (Join-Path $root "packages") -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName "pubspec.yaml") } |
        Sort-Object FullName
)

if ($flutterProjects.Count -eq 0) {
    throw "No Flutter projects were found under apps or packages."
}

Write-Host "Running flutter pub get for Flutter projects..." -ForegroundColor Cyan
foreach ($project in $flutterProjects) {
    Write-Host "  flutter pub get: $($project.FullName)" -ForegroundColor Yellow
    Push-Location $project.FullName
    try {
        & flutter pub get
        if ($LASTEXITCODE -ne 0) {
            throw "flutter pub get failed in $($project.FullName)"
        }
    }
    finally {
        Pop-Location
    }
}

Write-Host "Completed flutter pub get for $($flutterProjects.Count) project(s)." -ForegroundColor Green
