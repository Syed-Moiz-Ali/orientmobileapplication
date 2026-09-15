param(
    [string]$ArchivePath
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path $PSScriptRoot).Path

if ([string]::IsNullOrWhiteSpace($ArchivePath)) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $ArchivePath = Join-Path $root "archives\orientmobileapplication-$timestamp.zip"
}

$archivePath = [System.IO.Path]::GetFullPath($ArchivePath)
$archiveDirectory = Split-Path -Parent $archivePath
New-Item -ItemType Directory -Path $archiveDirectory -Force | Out-Null

$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCommand) {
    throw "Flutter was not found in PATH. Install Flutter or add it to PATH before running this script."
}

$flutterProjects = @(
    Get-ChildItem -Path (Join-Path $root "apps"), (Join-Path $root "packages") -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName "pubspec.yaml") }
)

if ($flutterProjects.Count -eq 0) {
    throw "No Flutter projects were found under apps or packages."
}

Write-Host "Cleaning Flutter projects..." -ForegroundColor Cyan
foreach ($project in $flutterProjects) {
    Write-Host "  flutter clean: $($project.FullName)" -ForegroundColor Yellow
    Push-Location $project.FullName
    try {
        & flutter clean
        if ($LASTEXITCODE -ne 0) {
            throw "flutter clean failed in $($project.FullName)"
        }
    }
    finally {
        Pop-Location
    }
}

Write-Host "Removing generated JAR files..." -ForegroundColor Cyan
$jarFiles = Get-ChildItem -Path $root -Filter "*.jar" -File -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch "[\\/]\.git[\\/]" }
foreach ($jarFile in $jarFiles) {
    Remove-Item -LiteralPath $jarFile.FullName -Force
}
Write-Host "  Removed $($jarFiles.Count) JAR file(s)." -ForegroundColor Green

if (Test-Path -LiteralPath $archivePath) {
    Remove-Item -LiteralPath $archivePath -Force
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($archivePath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $files = Get-ChildItem -Path $root -File -Recurse -Force |
        Where-Object {
            $_.FullName -notmatch "[\\/]\.git[\\/]" -and
            $_.FullName -notmatch "[\\/]build[\\/]" -and
            $_.FullName -notmatch "[\\/]\.dart_tool[\\/]" -and
            $_.FullName -notmatch "[\\/]target[\\/]" -and
            $_.FullName -ne $archivePath -and
            $_.FullName -notlike "$(Join-Path $archiveDirectory '*')"
        }

    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring($root.Length).TrimStart([char[]]"\\/")
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip,
            $file.FullName,
            $relativePath,
            [System.IO.Compression.CompressionLevel]::Optimal
        ) | Out-Null
    }
}
finally {
    $zip.Dispose()
}

Write-Host "Created archive: $archivePath" -ForegroundColor Green
Write-Host "Archived $($files.Count) file(s)." -ForegroundColor Green
