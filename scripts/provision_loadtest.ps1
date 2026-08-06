# Orient Workshop — load-test user provisioning.
# Roles are set BY USER ID (the JWT filter re-checks the DB role per request)
# and advisor/supervisor users need staff records — mirrors the E2E harness.
# Usage:  powershell -File scripts/provision_loadtest.ps1
param(
  [string]$DbHost = 'localhost',
  [string]$DbUser = 'root',
  [string]$DbPass = 'root',
  [string]$DbName = 'orient_workshop',
  [string]$BaseUrl = 'http://localhost:8080/api/v1'
)

$mysql = Get-Command mysql -ErrorAction SilentlyContinue
if (-not $mysql) {
    foreach ($candidate in @(
        'C:\Program Files\MySQL\MySQL Workbench 8.0 CE\mysql.exe',
        'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe',
        'C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe'
    )) {
        $resolved = Get-Item $candidate -ErrorAction SilentlyContinue
        if ($resolved) { $mysql = $resolved; break }
    }
}
if (-not $mysql) { Write-Error 'mysql CLI not found'; exit 1 }
$mysqlPath = if ($mysql -is [System.Management.Automation.CommandInfo]) { $mysql.Source } else { $mysql.FullName }

# role -> (phone, staff record?)  — phones are normalized by the auth service
# (050... becomes 97150...); lookups always go through /auth/me -> userId.
$users = @(
    @{ Name = 'owner';      Phone = '0501234777'; Role = 'owner';        Staff = $false },
    @{ Name = 'advisor';    Phone = '0501111001'; Role = 'advisor';      Staff = $true  },
    @{ Name = 'supervisor'; Phone = '0501111002'; Role = 'supervisor';   Staff = $true  },
    @{ Name = 'crm';        Phone = '0501111003'; Role = 'crmDashboard'; Staff = $false },
    @{ Name = 'customer';   Phone = '0501111004'; Role = 'customer';     Staff = $false }
)

$updates = @("DELETE FROM staff WHERE emp_id LIKE 'ELD%';")
foreach ($u in $users) {
    # One send + one verify per user (the dev OTP is single-use).
    try {
        $null = Invoke-RestMethod -Uri "$BaseUrl/auth/send-otp" -Method Post `
            -Body (@{ type = 'sms'; phone = $u.Phone } | ConvertTo-Json) `
            -ContentType 'application/json'
    } catch {
        Write-Warning "  send-otp failed for $($u.Name) ($($u.Phone)): $($_.Exception.Message)"
    }
    try {
        $tokResp = Invoke-RestMethod -Uri "$BaseUrl/auth/verify-otp" -Method Post `
            -Body (@{ type = 'sms'; phone = $u.Phone; otp = '123456' } | ConvertTo-Json) `
            -ContentType 'application/json'
    } catch {
        Write-Error "  verify-otp failed for $($u.Name) ($($u.Phone)): $($_.Exception.Message)"
        exit 1
    }
    $me = Invoke-RestMethod -Uri "$BaseUrl/auth/me" -Method Get `
        -Headers @{ Authorization = "Bearer $($tokResp.data.token)" }
    $userId = $me.data.userId
    if (-not $userId) { Write-Error "no userId for $($u.Name)"; exit 1 }
    $updates += "UPDATE users SET role = '$($u.Role)' WHERE id = $userId;"
    if ($u.Staff) {
        $empId = "ELD$($u.Name)"
        $updates += @"
INSERT INTO staff (user_id, emp_id, name, role, branch_id, branch, designation, is_active)
VALUES ($userId, '$empId', 'Load Test $($u.Name)', '$($u.Role)', 1, 'Main Branch - Dubai', '$($u.Name)', TRUE);
"@
    }
    Write-Host "  $($u.Name) -> userId $userId, role $($u.Role)" -ForegroundColor DarkGray
}

$null = $updates | & $mysqlPath -h $DbHost -u $DbUser "-p$DbPass" $DbName 2>$null
if ($LASTEXITCODE -ne 0) { Write-Error "SQL failed (exit $LASTEXITCODE)"; exit 1 }

& $mysqlPath -h $DbHost -u $DbUser "-p$DbPass" $DbName -e "SELECT u.id, u.phone, u.role, IFNULL(s.emp_id,'-') AS emp FROM users u LEFT JOIN staff s ON s.user_id = u.id WHERE u.phone LIKE '97150%' ORDER BY u.id DESC LIMIT 6;" 2>$null
Write-Host 'Provisioning done.' -ForegroundColor Green
