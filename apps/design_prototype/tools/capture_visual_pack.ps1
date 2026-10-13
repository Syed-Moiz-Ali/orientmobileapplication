# Capture the Phase 00 visual pack.
#
# 1. Regenerates the golden PNGs deterministically (EN/AR, all widths,
#    state variants, dark spot checks), and verifies them.
# 2. Copies the pack into phases/reports/PHASE_00/ with a flat naming scheme
#    (screen_width_locale_state[_dark].png).
#
# Usage (from the repository root):
#   tools (in apps/design_prototype):  .\tools\capture_visual_pack.ps1
param(
    [switch]$SkipUpdate
)

$ErrorActionPreference = 'Stop'
$appDir = Split-Path -Parent $PSScriptRoot
$repoRoot = Resolve-Path (Join-Path $appDir '..\..')
$goldenDir = Join-Path $appDir 'test\goldens'
$reportDir = Join-Path $repoRoot 'phases\reports\PHASE_00'

Write-Host "==> Generating goldens in $goldenDir"
Push-Location $appDir
try {
    if (-not $SkipUpdate) {
        flutter test test/visual_pack_test.dart --update-goldens
        if ($LASTEXITCODE -ne 0) { throw 'golden update failed' }
    }
    flutter test test/visual_pack_test.dart
    if ($LASTEXITCODE -ne 0) { throw 'golden verification failed' }
}
finally {
    Pop-Location
}

New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
Get-ChildItem $goldenDir -Filter *.png | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $reportDir $_.Name) -Force
}
$count = (Get-ChildItem $reportDir -Filter *.png | Measure-Object).Count
Write-Host "==> Copied $count renders to $reportDir"
