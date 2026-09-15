$apps = @(
    @{Name="Customer App"; Path="apps\customer_app"},
    @{Name="Staff App";    Path="apps\staff_app"},
    @{Name="Owner App";    Path="apps\owner_app"},
    @{Name="CRM App";      Path="apps\crm_app"}
)

$mode = "debug"
if ($args[0] -eq "-r" -or $args[0] -eq "--release") {
    $mode = "release"
}

$root = Get-Location
$builtApks = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Building all APKs ($mode mode)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($app in $apps) {
    $name = $app.Name
    $path = $app.Path

    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host "  Building $name..." -ForegroundColor Yellow
    Write-Host "  Path: $path" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Yellow

    Set-Location -Path "$root\$path" -ErrorAction Stop

    flutter build apk --$mode
    if ($LASTEXITCODE -ne 0) {
        Set-Location -Path $root
        Write-Host "FAILED: $name" -ForegroundColor Red
        exit 1
    }

    $apkPath = "build\app\outputs\flutter-apk\app-$mode.apk"
    if (-not (Test-Path $apkPath)) {
        Set-Location -Path $root
        Write-Host "FAILED: APK not found for $name at $apkPath" -ForegroundColor Red
        exit 1
    }

    $fullApkPath = Join-Path (Get-Location) $apkPath
    $builtApks += @{Name=$name; Path=$fullApkPath}
    Write-Host "DONE: $name -> $apkPath" -ForegroundColor Green
    Write-Host ""
}

Set-Location -Path $root

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  All APKs built successfully!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Installing APKs on connected device" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
if (-not $adbCommand) {
    Write-Host "FAILED: adb was not found in PATH. Install Android platform-tools or add adb to PATH." -ForegroundColor Red
    exit 1
}

$devices = adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "\tdevice$" }
if (-not $devices -or $devices.Count -eq 0) {
    Write-Host "FAILED: No connected Android device found. Enable USB debugging and run adb devices." -ForegroundColor Red
    exit 1
}

if ($devices.Count -gt 1) {
    Write-Host "FAILED: More than one Android device is connected. Keep only one device connected, then rerun." -ForegroundColor Red
    adb devices
    exit 1
}

foreach ($apk in $builtApks) {
    Write-Host "Installing $($apk.Name)..." -ForegroundColor Yellow
    adb install -r -d "$($apk.Path)"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: Could not install $($apk.Name)" -ForegroundColor Red
        exit 1
    }
    Write-Host "INSTALLED: $($apk.Name)" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build and install completed!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
