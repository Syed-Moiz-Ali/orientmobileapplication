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

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Building all APKs ($mode mode)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$root = Get-Location

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
        Write-Host "FAILED: $name" -ForegroundColor Red
        exit 1
    }
    
    $apkPath = "build\app\outputs\flutter-apk\app-$mode.apk"
    if (Test-Path $apkPath) {
        Write-Host "DONE: $name -> $apkPath" -ForegroundColor Green
    }
    Write-Host ""
}

Set-Location -Path $root

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  All APKs built successfully!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
