# =====================================================================================
#  QA UI / UX / LAYOUT / RESPONSIVE HARNESS - Orient Workshop
#  Simulates screen sizes + text scaling on a real device via `wm size`/`wm density`/
#  font_scale, walks the major screens of each app, and detects Flutter layout
#  overflows (RenderFlex overflowed by N pixels) + structural issues from the
#  uiautomator tree (touch targets < 48dp, elements clipped off-screen).
#
#  USAGE:
#    powershell -ExecutionPolicy Bypass -File scripts\qa_ui_responsive.ps1 -App customer
#    powershell -ExecutionPolicy Bypass -File scripts\qa_ui_responsive.ps1 -App all -Config all
#  PARAMS: -App customer|staff|owner|crm|all   -Config default|small|large|font13|font20|all
#  EXIT: 1 if any overflow/exception found in any run
# =====================================================================================
param(
    [string]$App = 'all',
    [string]$Config = 'all',
    [string]$Serial = 'a28a68d3',
    [string]$OutDir = 'docs/qa/responsive'
)

$ErrorActionPreference = 'Stop'
$script:Issues = New-Object System.Collections.ArrayList

# ---- screen configs (wm size = virtual px, wm density = dpi) -----------------------
$ScreenConfigs = @{
    default = @{ size = $null; density = 352; font = '1.0'; label = 'default' }
    small   = @{ size = '1080x1920'; density = 480; font = '1.0'; label = 'small 360x640dp' }
    large   = @{ size = '1600x2560'; density = 320; font = '1.0'; label = 'large 800x1280dp' }
    font13  = @{ size = $null; density = 352; font = '1.3'; label = 'text scale 1.3' }
    font20  = @{ size = $null; density = 352; font = '2.0'; label = 'text scale 2.0' }
}

# intruders that MIUI may foreground after config changes
$Intruders = @('com.example.referee_app')

# ---- per-app: package + tap walk (fractions of width/height) ------------------------
$Apps = @{
    customer = @{
        pkg = 'com.orient.customer_app'
        walk = @(
            @{ d = 'home' },
            @{ f = '0.5,0.945'; w = 2000 }, @{ d = 'status' },
            @{ f = '0.5,0.945'; w = 1500 }, @{ d = 'bookings' },
            @{ f = '0.7,0.945'; w = 1500 }, @{ d = 'approvals' },
            @{ f = '0.9,0.945'; w = 1500 }, @{ d = 'vehicles' },
            @{ f = '0.1,0.945'; w = 1500 }, @{ d = 'home2' },
            @{ f = '0.28,0.41'; w = 2500 }, @{ d = 'book_svc_s1' },
            @{ f = '0.26,0.35'; w = 1000 }, @{ f = '0.5,0.92'; w = 2500 }, @{ d = 'book_svc_s2' }
        )
    }
    staff = @{
        pkg = 'com.orient.staff_app'
        walk = @(
            @{ d = 'dashboard' },
            @{ f = '0.375,0.945'; w = 2500 }, @{ d = 'jobs' },
            @{ f = '0.625,0.945'; w = 2000 }, @{ d = 'reports' },
            @{ f = '0.875,0.945'; w = 1500 }, @{ d = 'profile_sheet' }
        )
    }
    owner = @{
        pkg = 'com.orient.owner_app'
        walk = @(
            @{ d = 'dashboard' },
            @{ f = '0.5,0.7'; w = 1200 }, @{ d = 'dashboard_scrolled' },
            @{ f = '0.125,0.945'; w = 2000 }, @{ d = 'top_sales' },
            @{ f = '0.375,0.945'; w = 2000 }, @{ d = 'messages' },
            @{ f = '0.625,0.945'; w = 2000 }, @{ d = 'activity' }
        )
    }
    crm = @{
        pkg = 'com.orient.crm_app'
        walk = @(
            @{ d = 'dashboard' },
            @{ f = '0.06,0.06'; w = 2000 }, @{ d = 'drawer' },
            @{ f = '0.2,0.35'; w = 2500 }, @{ d = 'leads' }
        )
    }
}

function Invoke-Adb([string]$Cmd) { & adb -s $Serial ($Cmd -split '\s+') 2>$null }

function Get-ForegroundApp {
    $out = Invoke-Adb 'shell dumpsys activity activities'
    foreach ($line in $out) {
        if ($line -match 'topResumedActivity=ActivityRecord\{[^}]*? ([a-zA-Z0-9_.]+)/') { return $Matches[1] }
    }
    $line2 = (Invoke-Adb 'shell dumpsys window windows') | Where-Object { $_ -match 'mCurrentFocus' } | Select-Object -First 1
    if ($line2 -and $line2 -match '([a-zA-Z0-9_.]+)/[a-zA-Z0-9_.]+') { return $Matches[1] }
    return ''
}

function Assert-Foreground([string]$pkg, [string]$label) {
    for ($i = 0; $i -lt 5; $i++) {
        $fg = Get-ForegroundApp
        if ($fg -eq $pkg) { return $true }
        Start-Sleep -Seconds 2
    }
    [void]$script:Issues.Add("FATAL: $label could not bring '$pkg' to foreground (current: '$fg')")
    return $false
}

function Test-TouchTargets($dumpPath, [int]$densityDpi, [string]$where) {
    try { $xml = [xml](Get-Content $dumpPath -Raw) } catch { return }
    $minPx = [int](48 * $densityDpi / 160.0)
    foreach ($n in $xml.SelectNodes('//node')) {
        if ($n.clickable -ne 'true') { continue }
        if ($n.bounds -notmatch '\[(-?\d+),(-?\d+)\]\[(-?\d+),(-?\d+)\]') { continue }
        $x1 = [int]$Matches[1]; $y1 = [int]$Matches[2]; $x2 = [int]$Matches[3]; $y2 = [int]$Matches[4]
        $w = $x2 - $x1; $h = $y2 - $y1
        if ($w -gt 0 -and $h -gt 0 -and ($w -lt $minPx -or $h -lt $minPx)) {
            $dpW = [math]::Round($w * 160.0 / $densityDpi, 1)
            $dpH = [math]::Round($h * 160.0 / $densityDpi, 1)
            $desc = ($n.'content-desc' -replace '\s+', ' ')
            if ($desc.Length -gt 60) { $desc = $desc.Substring(0, 60) }
            [void]$script:Issues.Add("TOUCH-TARGET <48dp: $where [$desc] ${dpW}x${dpH}dp")
        }
    }
}

function Test-ClippedElements($dumpPath, [int]$W, [int]$H, [string]$where) {
    try { $xml = [xml](Get-Content $dumpPath -Raw) } catch { return }
    foreach ($n in $xml.SelectNodes('//node')) {
        if ($n.bounds -notmatch '\[(-?\d+),(-?\d+)\]\[(-?\d+),(-?\d+)\]') { continue }
        $x1 = [int]$Matches[1]; $y1 = [int]$Matches[2]; $x2 = [int]$Matches[3]; $y2 = [int]$Matches[4]
        $interactive = $n.clickable -eq 'true' -or ($n.'content-desc' -and $n.'content-desc'.Trim())
        if (-not $interactive) { continue }
        if ($x2 -gt $W + 4 -or $y2 -gt $H + 4 -or $x1 -lt -4 -or $y1 -lt -4) {
            $desc = ($n.'content-desc' -replace '\s+', ' ')
            if ($desc.Length -gt 60) { $desc = $desc.Substring(0, 60) }
            [void]$script:Issues.Add("CLIPPED/OFFSCREEN: $where [$desc] bounds=$($n.bounds) screen=${W}x${H}")
        }
    }
}

function Get-OverflowLines {
    $log = adb -s $Serial logcat -d 2>$null
    $hits = @()
    foreach ($line in $log) {
        if ($line -match 'RenderFlex overflowed|overflowed by \d+ pixels|Another exception was thrown|EXCEPTION CAUGHT BY|RenderBox was not laid out|Bad state: |The following assertion was thrown|_TypeError|Null check operator used on a null value') {
            $hits += $line.Substring(0, [Math]::Min(220, $line.Length))
        }
    }
    return $hits
}

# =====================================================================================
$targets = if ($App -eq 'all') { @('customer','staff','owner','crm') } else { @($App) }
$configNames = if ($Config -eq 'all') { @('default','small','large','font13','font20') } else { @($Config) }

foreach ($app in $targets) {
    foreach ($cfg in $configNames) {
        $c = $ScreenConfigs[$cfg]
        $appInfo = $Apps[$app]
        $runLabel = "${app}_$cfg"
        Write-Host "=== $runLabel ($($c.label)) ===" -ForegroundColor Cyan

        # ---- set config ----
        if ($c.size) { Invoke-Adb "shell wm size $($c.size)" } else { Invoke-Adb 'shell wm size reset' }
        Invoke-Adb "shell wm density $($c.density)"
        Invoke-Adb "shell settings put system font_scale $($c.font)"
        # let the window manager settle before launching (avoids stale-window frames)
        Start-Sleep -Seconds 4

        # physical size (uiautomator reports PHYSICAL px) + virtual size (input space)
        $phys = (Invoke-Adb 'shell wm size') | Where-Object { $_ -match 'Physical size' } | Select-Object -First 1
        $virt = (Invoke-Adb 'shell wm size') | Where-Object { $_ -match 'Override size' } | Select-Object -First 1
        $dpiLine = (Invoke-Adb 'shell wm density') | Select-Object -First 1
        $PHW = 1080; $PHH = 2340
        if ($phys -match '(\d+)x(\d+)') { $PHW = [int]$Matches[1]; $PHH = [int]$Matches[2] }
        $VW = $PHW; $VH = $PHH
        if ($virt -match '(\d+)x(\d+)') { $VW = [int]$Matches[1]; $VH = [int]$Matches[2] }
        $densityDpi = 352
        if ($dpiLine -match '(\d+)') { $densityDpi = [int]$Matches[1] }

        # ---- launch target app (suppress intruders) ----
        foreach ($it in $Intruders) { Invoke-Adb "shell am force-stop $it" | Out-Null }
        Invoke-Adb "shell am force-stop $($appInfo.pkg)" | Out-Null
        Start-Sleep -Milliseconds 500
        Invoke-Adb "shell am start -n $($appInfo.pkg)/.MainActivity" | Out-Null
        Start-Sleep -Seconds 12

        if (-not (Assert-Foreground $appInfo.pkg $runLabel)) { continue }

        # logcat clean AFTER the app is confirmed foreground
        adb -s $Serial logcat -c 2>$null

        # ---- walk ----
        foreach ($step in $appInfo.walk) {
            if ($step.f) {
                $parts = ($step.f -split ',')
                $tx = [int]([double]$parts[0] * $VW)
                $ty = [int]([double]$parts[1] * $VH)
                Invoke-Adb "shell input tap $tx $ty"
                Start-Sleep -Milliseconds ($step.w)
                # after each tap, verify we are still in the target app
                $fg = Get-ForegroundApp
                if ($fg -ne $appInfo.pkg) {
                    [void]$script:Issues.Add("FATAL: $runLabel app lost foreground after tap ($fg)")
                    break
                }
            } elseif ($step.d) {
                $name = $step.d
                $dump = Join-Path $OutDir "ui_${runLabel}_${name}.xml"
                $dir = Split-Path $dump
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                adb -s $Serial shell uiautomator dump /sdcard/ui.xml 2>$null | Out-Null
                adb -s $Serial shell cat /sdcard/ui.xml | Out-File $dump -Encoding utf8
                Test-TouchTargets $dump $densityDpi "${runLabel}_${name}"
                Test-ClippedElements $dump $VW $VH "${runLabel}_${name}"
            }
        }

        # ---- overflow scan ----
        $overflow = Get-OverflowLines
        if ($overflow.Count -gt 0) {
            foreach ($o in $overflow) { [void]$script:Issues.Add("OVERFLOW/EXCEPTION ${runLabel}: $o") }
            Write-Host "  !! $($overflow.Count) overflow/exception lines" -ForegroundColor Red
        } else {
            Write-Host "  no overflows/exceptions" -ForegroundColor Green
        }
        Write-Host "  phys=${PHW}x${PHH} virt=${VW}x${VH} dpi=$densityDpi" -ForegroundColor DarkGray
    }
}

# ---- restore device config ----
Invoke-Adb 'shell wm size reset'
Invoke-Adb 'shell wm density reset'
Invoke-Adb 'shell settings put system font_scale 1.0'

# =====================================================================================
Write-Host ""
Write-Host "=================== UI/UX/Layout Issue Summary ===================" -ForegroundColor Cyan
if ($script:Issues.Count -eq 0) {
    Write-Host "  NO ISSUES FOUND across $($targets.Count) apps x $($configNames.Count) configs" -ForegroundColor Green
} else {
    $script:Issues | Sort-Object -Unique | ForEach-Object { Write-Host "  [$_]" -ForegroundColor Yellow }
}
$issuesOut = Join-Path $OutDir 'ui_ux_issues.txt'
$dir2 = Split-Path $issuesOut
if (-not (Test-Path $dir2)) { New-Item -ItemType Directory -Path $dir2 -Force | Out-Null }
($script:Issues | Sort-Object -Unique) | Set-Content $issuesOut -Encoding UTF8
Write-Host "Issues written to $issuesOut"
if ($script:Issues.Count -gt 0) { exit 1 } else { exit 0 }


