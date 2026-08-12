# =====================================================================================
#  QA API SUITE - Orient Workshop (Phase 2 of complete QA audit)
#  Role-aware endpoint testing + negative/security/validation edge cases.
#  REQUIREMENTS: backend running locally (dev profile, OTP fixed 123456)
#  USAGE:
#     powershell -ExecutionPolicy Bypass -File scripts\qa_api_suite.ps1
#  EXIT CODE: 0 = all passed, 1 = failures
# =====================================================================================
param(
    [string]$BaseUrl = 'http://localhost:8080/api/v1',
    [string]$Otp = '123456',
    [string]$RunTag = (Get-Date -Format 'HHmmss'),
    [string]$DbPass = 'root',
    [string]$ResultsOut = 'docs/qa/api_test_results.json'
)

$ErrorActionPreference = 'Stop'
$script:Results = New-Object System.Collections.ArrayList
$script:PassCount = 0
$script:FailCount = 0

# ---- role phones (LAST 3 DIGITS = role, see AuthService.resolveDefaultRole) -------
$PhoneAdvisor    = "9715$RunTag" + '001'
$PhoneSupervisor = "9715$RunTag" + '002'
$PhoneTechnician = "9715$RunTag" + '003'
$PhoneTech2      = "9716$RunTag" + '003'
$PhoneCustomer   = "9715$RunTag" + '004'
$PhoneOwner      = "9715$RunTag" + '005'
$PhoneCRM        = "9715$RunTag" + '006'
$PhoneLockout    = "9715$RunTag" + '007'   # dedicated for login-lockout test
$PhoneDummy      = "9715$RunTag" + '008'   # dedicated for IDOR / erase tests

function Check {
    param([Parameter(Mandatory)][string]$Name, [bool]$Ok, [string]$Detail = '')
    $r = [PSCustomObject]@{ check = $Name; pass = $Ok; detail = $Detail }
    [void]$script:Results.Add($r)
    if ($Ok) { $script:PassCount++; Write-Host "  PASS  $Name" -ForegroundColor Green }
    else { $script:FailCount++; Write-Host "  FAIL  $Name  $Detail" -ForegroundColor Red }
}

function Invoke-ApiRaw {
    # returns full response object incl status code; never throws
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [string]$Token = '',
        $Body = $null,
        [string]$ContentType = 'application/json',
        [hashtable]$ExtraHeaders = @{},
        [switch]$NoRetry
    )
    $headers = @{}
    if ($Token) { $headers['Authorization'] = "Bearer $Token" }
    foreach ($k in $ExtraHeaders.Keys) { $headers[$k] = $ExtraHeaders[$k] }
    $params = @{
        Uri = "$BaseUrl$Path"; Method = $Method; Headers = $headers
    }
    if ($ContentType) { $params['ContentType'] = $ContentType }
    if ($null -ne $Body) {
        $params['Body'] = if ($Body -is [string]) { $Body } else { ($Body | ConvertTo-Json -Depth 12 -Compress) }
    }
    for ($attempt = 1; $attempt -le 8; $attempt++) {
        try {
            $resp = Invoke-WebRequest @params -UseBasicParsing -TimeoutSec 30
            return @{ status = [int]$resp.StatusCode; body = $resp.Content }
        } catch {
            $status = 0
            if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode }
            if ($status -eq 429 -and -not $NoRetry -and $attempt -lt 8) { Start-Sleep -Seconds 6; continue }
            $content = ''
            try { $content = $_.ErrorDetails.Message } catch {}
            return @{ status = $status; body = $content; error = $_.Exception.Message }
        }
    }
    return @{ status = 0; body = ''; error = 'rate-limited' }
}

function Invoke-Api {
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [string]$Token = '',
        $Body = $null,
        [string]$ContentType = 'application/json',
        [hashtable]$ExtraHeaders = @{},
        [switch]$NoRetry
    )
    $r = Invoke-ApiRaw -Method $Method -Path $Path -Token $Token -Body $Body -ContentType $ContentType -ExtraHeaders $ExtraHeaders -NoRetry:$NoRetry
    $parsed = $null
    if ($r.body) { try { $parsed = $r.body | ConvertFrom-Json } catch {} }
    return @{ status = $r.status; body = $r.body; data = $parsed }
}

function Get-Data($resp) {
    if ($null -eq $resp.data) { return $null }
    if ($resp.data.PSObject.Properties['data']) { return $resp.data.data }
    return $resp.data
}

function Login-Role {
    param([Parameter(Mandatory)][string]$Phone, [Parameter(Mandatory)][string]$ExpectedRole)
    $null = Invoke-Api -Method POST -Path '/auth/send-otp' -Body @{ type = 'sms'; phone = $Phone }
    Start-Sleep -Milliseconds 400
    $resp = Invoke-Api -Method POST -Path '/auth/verify-otp' -Body @{ type = 'sms'; phone = $Phone; otp = $Otp }
    if ($resp.status -ne 200) { throw "verify-otp failed for $Phone : $($resp.body)" }
    $token = $resp.data.data.token
    $role = $resp.data.data.role
    if ($role -ne $ExpectedRole) { throw "role mismatch for $Phone : expected $ExpectedRole got $role" }
    return $token
}

# =====================================================================================
#  PART 0 - SYSTEM
# =====================================================================================
Write-Host "=== PART 0: System ===" -ForegroundColor Cyan
$r = Invoke-Api -Method GET -Path '/health'
Check 'health returns 200' ($r.status -eq 200)
$r = Invoke-Api -Method GET -Path '/version'
Check 'version returns 200' ($r.status -eq 200)
$r = Invoke-Api -Method GET -Path '/does-not-exist'
Check 'unknown route -> 404/401 (BUG-006 fixed: no more 500)' ($r.status -eq 404 -or $r.status -eq 401) "got $($r.status) body='$($r.body)'"
$r = Invoke-Api -Method GET -Path '/health' -ExtraHeaders @{ 'X-API-Version' = '99' }
Check 'unsupported X-API-Version returns 406' ($r.status -eq 406)
$r = Invoke-Api -Method GET -Path '/api/v1/health' -ContentType ''
Check 'context path already included -> 401/404 (BUG-006 fixed: no more 500)' ($r.status -eq 401 -or $r.status -eq 404) "got $($r.status) body='$($r.body)'"

# =====================================================================================
#  PART 1 - AUTH
# =====================================================================================
Write-Host "=== PART 1: Auth ===" -ForegroundColor Cyan
# -- send-otp variants
$r = Invoke-Api -Method POST -Path '/auth/send-otp' -Body @{ type = 'sms'; phone = $PhoneCustomer }
Check 'send-otp valid sms -> 200' ($r.status -eq 200)
$r = Invoke-Api -Method POST -Path '/auth/send-otp' -Body @{ type = 'email'; email = 'qa@test.com' }
Check 'send-otp valid email -> 200' ($r.status -eq 200)
$r = Invoke-Api -Method POST -Path '/auth/send-otp' -Body @{ type = 'fax'; phone = $PhoneCustomer }
Check 'send-otp invalid type -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/send-otp' -Body @{ }
Check 'send-otp empty body -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/send-otp' -Body @{ type = 'sms'; phone = '123' }
Check 'send-otp invalid phone rejected (BUG-005: accepted, "OTP sent")' ($r.status -eq 400) "got $($r.status)"

# -- verify-otp variants (customer phone; do the real one LAST to avoid locking order issues)
$r = Invoke-Api -Method POST -Path '/auth/send-otp' -Body @{ type = 'sms'; phone = $PhoneCustomer }
Start-Sleep -Milliseconds 300
$r = Invoke-Api -Method POST -Path '/auth/verify-otp' -Body @{ type = 'sms'; phone = $PhoneCustomer; otp = '999999' }
Check 'verify-otp wrong otp rejected (400 or 401)' ($r.status -eq 400 -or $r.status -eq 401) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/auth/verify-otp' -Body @{ type = 'sms'; phone = $PhoneCustomer; otp = '' }
Check 'verify-otp empty otp -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/verify-otp' -Body @{ type = 'sms'; phone = $PhoneCustomer }
Check 'verify-otp missing otp -> 400' ($r.status -eq 400) "got $($r.status)"

# -- real logins per role (bootstrap tokens; roles provisioned next)
$TokenCustomer = Login-Role -Phone $PhoneCustomer -ExpectedRole 'customer'
Check 'login customer role' $true
$TokenAdvisor = Login-Role -Phone $PhoneAdvisor -ExpectedRole 'customer'
$TokenSupervisor = Login-Role -Phone $PhoneSupervisor -ExpectedRole 'customer'
$TokenTechnician = Login-Role -Phone $PhoneTechnician -ExpectedRole 'customer'
$TokenOwner = Login-Role -Phone $PhoneOwner -ExpectedRole 'customer'
$TokenCRM = Login-Role -Phone $PhoneCRM -ExpectedRole 'customer'
Check 'bootstrap logins created customer accounts (S-2 role gate)' $true

# -- PROVISION ROLES + STAFF via MySQL (mirrors owner admin flow; see seamless script)
Write-Host "  provisioning roles via MySQL ..." -ForegroundColor DarkGray
$meAdvisor = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokenAdvisor).data.data
$meSupervisor = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokenSupervisor).data.data
$meTechnician = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokenTechnician).data.data
$meOwner = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokenOwner).data.data
$meCRM = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokenCRM).data.data
$sql = @"
DELETE FROM staff WHERE emp_id IN ('EQA$RunTag','EQA$RunTag`S','EQA$RunTag`T');
INSERT INTO staff (user_id, emp_id, name, role, branch_id, branch, designation, is_active)
VALUES
  ($($meAdvisor.userId),    'EQA$RunTag',   'QA Advisor',   'advisor',    1, 'Main Branch - Dubai', 'Advisor', TRUE),
  ($($meSupervisor.userId), 'EQA$RunTag`S', 'QA Supervisor','supervisor', 1, 'Main Branch - Dubai', 'Supervisor', TRUE),
  ($($meTechnician.userId), 'EQA$RunTag`T', 'QA Tech A',    'technician', 1, 'Main Branch - Dubai', 'Technician', TRUE);
UPDATE users SET name='QA Advisor', role='advisor'     WHERE id=$($meAdvisor.userId);
UPDATE users SET name='QA Supervisor', role='supervisor' WHERE id=$($meSupervisor.userId);
UPDATE users SET name='QA Tech A', role='technician'   WHERE id=$($meTechnician.userId);
UPDATE users SET name='QA Owner', role='owner'         WHERE id=$($meOwner.userId);
UPDATE users SET name='QA CRM', role='crmDashboard'    WHERE id=$($meCRM.userId);
"@
$mysql = Get-Command mysql -ErrorAction SilentlyContinue
if (-not $mysql) {
    $cand = Get-Item 'C:\Program Files\MySQL\MySQL Workbench 8.0 CE\mysql.exe' -ErrorAction SilentlyContinue
    if ($cand) { $mysql = $cand }
}
if (-not $mysql) { throw 'mysql CLI not found - cannot provision roles' }
$mysqlPath = if ($mysql -is [System.Management.Automation.CommandInfo]) { $mysql.Source } else { $mysql.FullName }
$env:MYSQL_PWD = $DbPass
$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$null = $sql | & $mysqlPath -h localhost -u root orient_workshop 2>$null
$mysqlExit = $LASTEXITCODE
$ErrorActionPreference = $prevEap
if ($mysqlExit -ne 0) { throw "mysql provisioning failed (exit $mysqlExit)" }
Write-Host "  roles provisioned - re-logging in ..." -ForegroundColor DarkGray

# -- re-login with provisioned roles (old bootstrap tokens rejected - stale role)
$TokenAdvisor = Login-Role -Phone $PhoneAdvisor -ExpectedRole 'advisor'
Check 'login advisor role' $true
$TokenSupervisor = Login-Role -Phone $PhoneSupervisor -ExpectedRole 'supervisor'
Check 'login supervisor role' $true
$TokenTechnician = Login-Role -Phone $PhoneTechnician -ExpectedRole 'technician'
Check 'login technician role' $true
$TokenOwner = Login-Role -Phone $PhoneOwner -ExpectedRole 'owner'
Check 'login owner role' $true
$TokenCRM = Login-Role -Phone $PhoneCRM -ExpectedRole 'crmDashboard'
Check 'login crmDashboard role' $true

# -- /auth/me per role
foreach ($t in @(@('customer',$TokenCustomer),@('advisor',$TokenAdvisor),@('supervisor',$TokenSupervisor),@('technician',$TokenTechnician),@('owner',$TokenOwner),@('crmDashboard',$TokenCRM))) {
    $r = Invoke-Api -Method GET -Path '/auth/me' -Token $t[1]
    $ok = $r.status -eq 200
    $me = $null
    if ($ok) { $me = $r.data.data; $ok = ($me.role -eq $t[0]) }
    Check "/auth/me as $($t[0]) returns own role" $ok "status=$($r.status) role=$($me.role)"
}
$r = Invoke-Api -Method GET -Path '/auth/me'
Check '/auth/me without token -> 401' ($r.status -eq 401)

# -- register
$regPhone = "9715$RunTag" + '111'
$regEmail = "qa$RunTag@test.com"
$r = Invoke-Api -Method POST -Path '/auth/register' -Body @{ name = 'QA Register'; phone = $regPhone; email = $regEmail; password = 'Qa123456!'; role = 'customer' }
Check 'register customer -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/auth/register' -Body @{ name = 'QA Bad'; phone = "9715$RunTag" + '112'; email = 'bad'; password = 'Qa123456!'; role = 'customer' }
Check 'register invalid email -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/register' -Body @{ name = 'QA Weak'; phone = "9715$RunTag" + '113'; email = "weak$RunTag@test.com"; password = 'short'; role = 'customer' }
Check 'register weak password -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/register' -Body @{ name = 'QA Dup'; phone = $regPhone; email = "dup$RunTag@test.com"; password = 'Qa123456!'; role = 'customer' }
Check 'register duplicate phone -> 400/409' ($r.status -eq 400 -or $r.status -eq 409) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/auth/register' -Body @{ name = 'QA Role'; phone = "9715$RunTag" + '114'; email = "role$RunTag@test.com"; password = 'Qa123456!'; role = 'owner' }
Check 'register with owner role -> 403/400 (customer-only)' ($r.status -eq 403 -or $r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/register' -Body @{ name = 'QA Role'; phone = "9715$RunTag" + '115'; email = "role2$RunTag@test.com"; password = 'Qa123456!'; role = 'admin' }
Check 'register with admin role -> 403/400' ($r.status -eq 403 -or $r.status -eq 400) "got $($r.status)"

# -- password login
$r = Invoke-Api -Method POST -Path '/auth/login' -Body @{ phone = $regPhone; password = 'Qa123456!' }
Check 'login with password (phone) -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/auth/login' -Body @{ email = $regEmail; password = 'Qa123456!' }
Check 'login with password (email) -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/login' -Body @{ phone = $regPhone; password = 'wrongpass' }
Check 'login wrong password -> 400/401' ($r.status -eq 400 -or $r.status -eq 401) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/login' -Body @{ phone = $regPhone; password = 'wrongpass' }
Check 'login wrong password 2 -> 400/401' ($r.status -eq 400 -or $r.status -eq 401) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/login' -Body @{ phone = '9715000000000'; password = 'whatever' }
Check 'login unknown user -> 400/401' ($r.status -eq 400 -or $r.status -eq 401) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/login' -Body @{ phone = $regPhone }
Check 'login missing password -> 400' ($r.status -eq 400) "got $($r.status)"

# -- refresh token rotation
$r = Invoke-Api -Method POST -Path '/auth/login' -Body @{ phone = $regPhone; password = 'Qa123456!' }
$refreshToken = $r.data.data.refreshToken
$r = Invoke-Api -Method POST -Path '/auth/refresh' -Body @{ refreshToken = $refreshToken }
Check 'refresh token -> 200 with new tokens' ($r.status -eq 200 -and $null -ne $r.data.data.token) "got $($r.status)"
$newRefresh = $r.data.data.refreshToken
$r = Invoke-Api -Method POST -Path '/auth/refresh' -Body @{ refreshToken = $refreshToken }
Check 'reuse old refresh token -> 401 (family revoked)' ($r.status -eq 401) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/auth/refresh' -Body @{ refreshToken = $newRefresh }
Check 'new refresh token still valid -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/refresh' -Body @{ refreshToken = 'garbage-token' }
Check 'refresh with garbage token -> 400/401' ($r.status -eq 400 -or $r.status -eq 401) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/refresh' -Body @{ }
Check 'refresh empty body -> 400' ($r.status -eq 400) "got $($r.status)"

# -- logout + me after logout
$r = Invoke-Api -Method POST -Path '/auth/logout' -Token $TokenAdvisor
Check 'logout -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/auth/me' -Token $TokenAdvisor
Check 'me after logout (revoked refresh) still valid access token' ($r.status -eq 200) "got $($r.status) (access token stateless; refresh revoked)"

# -- forgot/reset password
$r = Invoke-Api -Method POST -Path '/auth/forgot-password' -Body @{ type = 'sms'; phone = $regPhone }
Check 'forgot-password -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/reset-password' -Body @{ type = 'sms'; phone = $regPhone; otp = '999999'; newPassword = 'NewPass123!' }
Check 'reset-password wrong otp -> 400/401' ($r.status -eq 400 -or $r.status -eq 401) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/reset-password' -Body @{ type = 'sms'; phone = $regPhone; otp = $Otp; newPassword = 'NewPass123!' }
Check 'reset-password correct otp -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/auth/login' -Body @{ phone = $regPhone; password = 'NewPass123!' }
Check 'login with new password -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/auth/login' -Body @{ phone = $regPhone; password = 'Qa123456!' }
Check 'old password no longer works -> 400/401' ($r.status -eq 400 -or $r.status -eq 401) "got $($r.status)"

# -- login lockout (dedicated user, 5 wrong then correct; NoRetry so the harness
#    does not retry through the 30s lock window)
$null = Invoke-Api -Method POST -Path '/auth/register' -Body @{ name = 'Lockout'; phone = $PhoneLockout; email = "lock$RunTag@test.com"; password = 'Lock123456!'; role = 'customer' }
for ($i = 0; $i -lt 5; $i++) { $null = Invoke-Api -Method POST -Path '/auth/login' -Body @{ phone = $PhoneLockout; password = 'bad' } }
$r = Invoke-Api -Method POST -Path '/auth/login' -Body @{ phone = $PhoneLockout; password = 'Lock123456!' } -NoRetry
Check 'login locked after 5 failures -> 429/401' ($r.status -eq 429 -or $r.status -eq 401) "got $($r.status)"

# -- OTP attempt cap (BUG-009: increments rolled back -> cap ineffective)
$null = Invoke-Api -Method POST -Path '/auth/send-otp' -Body @{ type = 'sms'; phone = $PhoneCustomer }
for ($i = 0; $i -lt 5; $i++) { $null = Invoke-Api -Method POST -Path '/auth/verify-otp' -Body @{ type = 'sms'; phone = $PhoneCustomer; otp = '111111' } -NoRetry }
$r = Invoke-Api -Method POST -Path '/auth/verify-otp' -Body @{ type = 'sms'; phone = $PhoneCustomer; otp = $Otp } -NoRetry
Check 'otp capped after 5 wrong attempts (BUG-009: got 200, cap ineffective)' ($r.status -eq 429 -or $r.status -eq 401 -or $r.status -eq 400) "got $($r.status) (expected rejection)"

# =====================================================================================
#  PART 2 - SECURITY / NEGATIVE (cross-role RBAC, token abuse)
# =====================================================================================
Write-Host "=== PART 2: Security/RBAC ===" -ForegroundColor Cyan
$sec = @(
    @('/owner/dashboard/kpis',      $TokenCustomer, 403, 'customer -> owner endpoint'),
    @('/owner/dashboard/kpis',      $TokenAdvisor,  403, 'advisor -> owner endpoint'),
    @('/crm/dashboard/kpis',        $TokenCustomer, 403, 'customer -> crm endpoint'),
    @('/crm/dashboard/kpis',        $TokenAdvisor,  403, 'advisor -> crm endpoint'),
    @('/supervisor/kpis',           $TokenCustomer, 403, 'customer -> supervisor endpoint'),
    @('/supervisor/kpis',           $TokenAdvisor,  403, 'advisor -> supervisor endpoint'),
    @('/advisor/stats',             $TokenCustomer, 403, 'customer -> advisor endpoint'),
    @('/advisor/stats',             $TokenOwner,    200, 'owner -> advisor endpoint (owner has advisor access)'),
    @('/technicians/attendance/punch-in', $TokenCustomer, 403, 'customer -> technician endpoint'),
    @('/branches',                  $TokenAdvisor,  403, 'advisor -> branches (owner only)'),
    @('/customers/search?q=x',      $TokenCustomer, 403, 'customer -> staff search'),
    @('/feedback/pending',          $TokenCustomer, 403, 'customer -> moderation inbox'),
    @('/feedback/pending',          $TokenAdvisor,  200, 'advisor -> moderation inbox allowed')
)
foreach ($s in $sec) {
    $r = Invoke-Api -Method ($(if ($s[0] -like '*punch-in') {'POST'} else {'GET'})) -Path $s[0] -Token $s[1] -Body $(if ($s[0] -like '*punch-in') {@{}} else {$null})
    if ($s[2] -eq 403) { Check "RBAC: $($s[3]) -> $($r.status)" ($r.status -eq 403) "expected 403" }
    elseif ($s[2] -eq 200) { Check "RBAC: $($s[3]) -> $($r.status)" ($r.status -eq 200) "expected 200" }
    else { Check "RBAC: $($s[3]) -> $($r.status)" ($r.status -eq 200 -or $r.status -eq 403) }
}
$r = Invoke-Api -Method GET -Path '/owner/dashboard/kpis'
Check 'no token -> 401' ($r.status -eq 401) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/owner/dashboard/kpis' -Token 'eyJhbGciOiJIUzI1NiJ9.abc.def'
Check 'garbage token -> 401' ($r.status -eq 401) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/owner/dashboard/kpis' -Token 'Bearer garbage'
Check 'Bearer garbage -> 401' ($r.status -eq 401) "got $($r.status)"

# -- forged JWT with known dev secret (invalid exp / role escalation attempts)
function New-Jwt([string]$payload, [string]$secret) {
    $enc = { param($s) ([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($s)) -replace '\+','-' -replace '/','_' -replace '=','') }
    $header = & $enc '{"alg":"HS256","typ":"JWT"}'
    $p = & $enc $payload
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($secret)
    $sig = [Convert]::ToBase64String($hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes("$header.$p"))) -replace '\+','-' -replace '/','_' -replace '=',''
    return "$header.$p.$sig"
}
$devSecret = 'dev-secret-key-this-is-only-for-development-not-production'
$expired = New-Jwt '{"sub":"999999999","phone":"9715000000000","role":"owner","branchId":1,"jti":"qa-expired","exp":1700000000,"iat":1700000000,"type":"access"}' $devSecret
$r = Invoke-Api -Method GET -Path '/owner/dashboard/kpis' -Token $expired
Check 'forged JWT with expired exp -> 401' ($r.status -eq 401) "got $($r.status)"
$noExp = New-Jwt '{"sub":"1","phone":"971501234567","role":"owner","branchId":1,"jti":"qa-noexp","type":"access"}' $devSecret
$r = Invoke-Api -Method GET -Path '/owner/dashboard/kpis' -Token $noExp
Check 'forged JWT without exp -> 401' ($r.status -eq 401) "got $($r.status)"
$badSig = $expired.Substring(0, $expired.LastIndexOf('.')) + '.AAAA'
$r = Invoke-Api -Method GET -Path '/owner/dashboard/kpis' -Token $badSig
Check 'forged JWT bad signature -> 401' ($r.status -eq 401) "got $($r.status)"
$roleSwap = New-Jwt '{"sub":"1","phone":"971501234567","role":"owner","branchId":1,"jti":"qa-role","exp":2000000000,"iat":1700000000,"type":"access"}' $devSecret
$r = Invoke-Api -Method GET -Path '/owner/dashboard/kpis' -Token $roleSwap
Check 'forged JWT role escalation (customer sub=1 as owner) -> 401/403' ($r.status -eq 401 -or $r.status -eq 403) "got $($r.status): $($r.body)"

# =====================================================================================
#  PART 3 - CUSTOMER PORTAL
# =====================================================================================
Write-Host "=== PART 3: Customer portal ===" -ForegroundColor Cyan
$r = Invoke-Api -Method GET -Path '/customers/profile' -Token $TokenCustomer
Check 'customer profile -> 200' ($r.status -eq 200) "got $($r.status)"
$customerData = $r.data.data

# vehicles CRUD (camelCase contract: brand/model/plateNumber/vin/color/year/mileage)
$r = Invoke-Api -Method GET -Path '/customers/vehicles' -Token $TokenCustomer
Check 'list vehicles -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/customers/vehicles' -Token $TokenCustomer -Body @{ brand = 'Toyota'; model = 'Camry'; plateNumber = "QA$RunTag"; year = 2022 }
Check 'create vehicle -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$vehicle = $r.data.data
$vehicleId = if ($vehicle.id) { $vehicle.id } else { $vehicle.vehicleId }
$r = Invoke-Api -Method POST -Path '/customers/vehicles' -Token $TokenCustomer -Body @{ brand = 'Toyota'; model = 'Camry'; plateNumber = "QA$RunTag"; year = 2022 }
Check 'duplicate vehicle reg allowed (no unique constraint - by design)' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method PUT -Path "/customers/vehicles/$vehicleId" -Token $TokenCustomer -Body @{ brand = 'Toyota'; model = 'Corolla'; plateNumber = "QA$RunTag"; year = 2023 }
Check 'update vehicle -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method PUT -Path '/customers/vehicles/999999999' -Token $TokenCustomer -Body @{ brand = 'x'; plateNumber = 'X1' }
Check 'update non-owned vehicle id -> 404' ($r.status -eq 404) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/customers/vehicles' -Token $TokenCustomer -Body @{ }
Check 'create vehicle empty body rejected (BUG-011: got 200, junk row)' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method DELETE -Path "/customers/vehicles/$vehicleId" -Token $TokenCustomer
Check 'delete vehicle -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"

# bookings (camelCase contract)
$date = (Get-Date).AddDays(1).ToString('yyyy-MM-dd')
$r = Invoke-Api -Method GET -Path "/bookings/availability?date=$date" -Token $TokenCustomer
Check 'availability -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/bookings/availability' -Token $TokenCustomer
Check 'availability missing date -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/bookings' -Token $TokenCustomer -Body @{ serviceType = 'Full Service'; bookingDate = "$date`T10:00:00"; vehicleName = 'Toyota Camry'; plateNumber = "QA$RunTag"; notes = 'QA test booking' }
Check 'create booking -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$booking = $r.data.data
$bookingId = if ($booking.id) { $booking.id } else { $booking.bookingId }
$r = Invoke-Api -Method GET -Path '/customers/bookings' -Token $TokenCustomer
Check 'list bookings -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/bookings' -Token $TokenCustomer -Body @{ serviceType = 'Full Service'; bookingDate = $date }
Check 'create booking missing vehicle details -> 400' ($r.status -eq 400) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/bookings' -Token $TokenCustomer -Body @{ serviceType = 'Full Service'; bookingDate = '2020-01-01'; vehicleName = 'x'; plateNumber = 'X' }
Check 'create booking past date -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method PUT -Path "/customers/bookings/$bookingId/status" -Token $TokenCustomer -Body @{ status = 'cancelled' }
Check 'cancel own booking (body status) -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method PUT -Path "/customers/bookings/$bookingId/status?status=cancelled" -Token $TokenCustomer -Body @{ }
Check 'cancel via query param (BUG-010 fixed: app path works) -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method PUT -Path '/customers/bookings/999999999/status' -Token $TokenCustomer -Body @{ status = 'cancelled' }
Check 'cancel other/unknown booking -> 404/403' ($r.status -eq 404 -or $r.status -eq 403) "got $($r.status)"

# breakdowns (camelCase contract: issue/vehicleId/vehicleName/vehiclePlate/location)
$r = Invoke-Api -Method POST -Path '/customers/breakdowns' -Token $TokenCustomer -Body @{ issue = 'Engine wont start'; location = 'Dubai Marina'; vehicleName = 'Toyota Camry'; vehiclePlate = "QA$RunTag" }
Check 'create breakdown -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/customers/breakdowns' -Token $TokenCustomer -Body @{ }
Check 'create breakdown empty -> 400 (got 409 - wrong code)' ($r.status -eq 400) "got $($r.status)"

# services
$r = Invoke-Api -Method GET -Path '/services/types' -Token $TokenCustomer
Check 'service types -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/customers/services/active' -Token $TokenCustomer
Check 'active services -> 200' ($r.status -eq 200) "got $($r.status)"

# notifications
$r = Invoke-Api -Method GET -Path '/customers/notifications' -Token $TokenCustomer
Check 'notifications -> 200' ($r.status -eq 200) "got $($r.status)"
$notifs = $r.data.data
if ($notifs -and $notifs.content -and $notifs.content.Count -gt 0) {
    $nid = $notifs.content[0].id
    $r = Invoke-Api -Method PUT -Path "/customers/notifications/$nid/read" -Token $TokenCustomer
    Check 'mark notification read -> 200' ($r.status -eq 200) "got $($r.status)"
    $r = Invoke-Api -Method PUT -Path '/customers/notifications/999999999/read' -Token $TokenCustomer
    Check 'mark unknown notification read -> 404' ($r.status -eq 404) "got $($r.status)"
} else { Check 'mark notification read (no data to test)' $true 'no notifications' }
$r = Invoke-Api -Method PUT -Path '/customers/notifications/read-all' -Token $TokenCustomer
Check 'read-all notifications -> 200' ($r.status -eq 200) "got $($r.status)"

# invoices / approvals (may be empty - just status)
$r = Invoke-Api -Method GET -Path '/customers/invoices' -Token $TokenCustomer
Check 'customer invoices -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/customers/approvals/pending' -Token $TokenCustomer
Check 'pending approvals -> 200' ($r.status -eq 200) "got $($r.status)"

# feedback (camelCase contract; requires valid jobCardId)
$jcId = $null
$mysql2 = if ($mysql -is [System.Management.Automation.CommandInfo]) { $mysql.Source } else { $mysql.FullName }
$env:MYSQL_PWD = $DbPass
$q = & $mysql2 -h localhost -u root orient_workshop -N -e "SELECT id FROM job_cards WHERE status <> 'cancelled' ORDER BY id DESC LIMIT 1;" 2>$null
if ($q) { $jcId = (($q | Select-Object -First 1) -replace '\s','').Trim() }
$r = Invoke-Api -Method POST -Path '/feedback' -Token $TokenCustomer -Body @{ jobCardId = $jcId; overallRating = 5; comment = 'QA feedback test'; workQuality = 5; communication = 5; timeliness = 5; valueForMoney = 5; wouldRecommend = $true }
Check 'submit feedback -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body) (jobCardId=$jcId)"
$r = Invoke-Api -Method POST -Path '/feedback' -Token $TokenCustomer -Body @{ overallRating = 9 }
Check 'feedback invalid rating (9) -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/feedback' -Token $TokenCustomer -Body @{ overallRating = 0 }
Check 'feedback invalid rating (0) -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/feedback' -Token $TokenCustomer
Check 'list feedback (moderated) -> 200' ($r.status -eq 200) "got $($r.status)"

# tickets
$r = Invoke-Api -Method GET -Path '/customers/tickets' -Token $TokenCustomer
Check 'list tickets -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/customers/tickets' -Token $TokenCustomer -Body @{ subject = 'QA ticket'; description = 'test'; priority = 'medium' }
Check 'create ticket -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"

# GDPR export
$r = Invoke-Api -Method GET -Path '/customers/data/export' -Token $TokenCustomer
Check 'GDPR export -> 200' ($r.status -eq 200) "got $($r.status)"

# device token
$r = Invoke-Api -Method POST -Path '/notifications/device-token' -Token $TokenCustomer -Body @{ token = 'qa-device-token-123'; platform = 'android' }
Check 'register device token -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"

# =====================================================================================
#  PART 4 - IDOR
# =====================================================================================
Write-Host "=== PART 4: IDOR ===" -ForegroundColor Cyan
# customer A cannot touch customer B's resources. Create 2nd customer.
$PhoneVictim = "9715$RunTag" + '120'
$null = Invoke-Api -Method POST -Path '/auth/send-otp' -Body @{ type = 'sms'; phone = $PhoneVictim }
Start-Sleep -Milliseconds 300
$r = Invoke-Api -Method POST -Path '/auth/verify-otp' -Body @{ type = 'sms'; phone = $PhoneVictim; otp = $Otp }
$TokenVictim = $r.data.data.token
$r = Invoke-Api -Method POST -Path '/customers/vehicles' -Token $TokenVictim -Body @{ brand = 'Nissan'; model = 'Sunny'; plateNumber = "QA-IDOR-$RunTag" }
$victimVehicle = $r.data.data
$victimVehicleId = if ($victimVehicle.id) { $victimVehicle.id } else { $victimVehicle.vehicleId }
$r = Invoke-Api -Method PUT -Path "/customers/vehicles/$victimVehicleId" -Token $TokenCustomer -Body @{ brand = 'hacked'; plateNumber = 'HACK1' }
Check "IDOR: customer A updates customer B vehicle -> 404/403 (got $($r.status))" ($r.status -eq 404 -or $r.status -eq 403)
$r = Invoke-Api -Method DELETE -Path "/customers/vehicles/$victimVehicleId" -Token $TokenCustomer
Check "IDOR: customer A deletes customer B vehicle -> 404/403 (got $($r.status))" ($r.status -eq 404 -or $r.status -eq 403)
# victim can still update own vehicle
$r = Invoke-Api -Method PUT -Path "/customers/vehicles/$victimVehicleId" -Token $TokenVictim -Body @{ brand = 'Nissan'; model = 'Sunny'; plateNumber = "QA-IDOR-$RunTag"; year = 2020 }
Check "IDOR: victim still owns vehicle -> 200 (got $($r.status))" ($r.status -eq 200)

# =====================================================================================
#  PART 5 - ADVISOR
# =====================================================================================
Write-Host "=== PART 5: Advisor ===" -ForegroundColor Cyan
$r = Invoke-Api -Method GET -Path '/advisor/stats' -Token $TokenAdvisor
Check 'advisor stats -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/advisor/job-cards?page=1&size=10' -Token $TokenAdvisor
Check 'advisor job-cards paged -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/advisor/job-cards?page=0' -Token $TokenAdvisor
Check 'advisor job-cards page=0 handled -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/advisor/job-cards?size=9999' -Token $TokenAdvisor
Check 'advisor job-cards huge size capped -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/advisor/technicians' -Token $TokenAdvisor
Check 'advisor technicians list -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/advisor/approvals/pending' -Token $TokenAdvisor
Check 'advisor pending approvals -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/advisor/reminders' -Token $TokenAdvisor
Check 'advisor reminders -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/advisor/reminders' -Token $TokenAdvisor -Body @{ task = 'Call customer QA'; customerName = 'QA'; dueDate = $date; priority = 'high' }
Check 'advisor create reminder -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/advisor/reminders' -Token $TokenAdvisor -Body @{ }
Check 'advisor reminder empty -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/advisor/reports?range=today' -Token $TokenAdvisor
Check 'advisor reports -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/advisor/reports?range=invalid' -Token $TokenAdvisor
Check 'advisor reports invalid range rejected (BUG-012: got 200, ignored)' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/advisor/inventory/search?q=oil' -Token $TokenAdvisor
Check 'advisor inventory search -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/advisor/auto-price?name=Oil+Change' -Token $TokenAdvisor
Check 'advisor auto-price -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/customers/search?q=' -Token $TokenAdvisor
Check 'advisor customer search -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/vehicles/search?q=' -Token $TokenAdvisor
Check 'advisor vehicle search -> 200' ($r.status -eq 200) "got $($r.status)"

# inspection lifecycle (advisor) - proper InspectionRequest contract
$r = Invoke-Api -Method POST -Path '/inspections' -Token $TokenAdvisor -Body @{ customer = @{ customerName = 'QA Customer'; phoneNumber = $PhoneCustomer }; vehicle = @{ registrationNumber = "QA$RunTag"; make = 'Toyota'; model = 'Camry' }; sections = @{} }
Check 'create inspection -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$inspection = $r.data.data
$inspectionId = if ($inspection.id) { $inspection.id } else { $inspection.inspectionId }
$r = Invoke-Api -Method POST -Path '/inspections' -Token $TokenAdvisor -Body @{ }
Check 'create inspection empty -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method PUT -Path "/inspections/$inspectionId" -Token $TokenAdvisor -Body @{ sections = @{} }
Check 'update inspection with returned id (BUG-014: id is INS-ref, endpoint needs numeric) -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method GET -Path "/inspections/$inspectionId/summary" -Token $TokenAdvisor
Check 'inspection summary with returned id (BUG-014) -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/inspections/999999999/summary' -Token $TokenAdvisor
Check 'inspection summary unknown -> 404' ($r.status -eq 404) "got $($r.status)"
$r = Invoke-Api -Method GET -Path "/inspections/$inspectionId/draft" -Token $TokenCustomer
Check 'customer cannot read advisor inspection -> 403/404' ($r.status -eq 403 -or $r.status -eq 404) "got $($r.status)"

# =====================================================================================
#  PART 6 - SUPERVISOR
# =====================================================================================
Write-Host "=== PART 6: Supervisor ===" -ForegroundColor Cyan
foreach ($p in @('/supervisor/kpis','/supervisor/advisor-jobs','/supervisor/job-types','/supervisor/revenue-metrics','/supervisor/pending-statuses','/supervisor/bookings','/supervisor/breakdowns','/supervisor/jobs/awaiting','/supervisor/assignable-advisors','/supervisor/assigned-jobs','/supervisor/technicians/available','/departments','/technicians','/staff/notifications')) {
    $r = Invoke-Api -Method GET -Path $p -Token $TokenSupervisor
    $d = ''; if ($r.body) { $d = $r.body.Substring(0, [Math]::Min(120, $r.body.Length)) }
    Check "supervisor GET $p -> 200" ($r.status -eq 200) "got $($r.status): $d"
}
# work assignment (items with real jobCardId)
$r = Invoke-Api -Method POST -Path '/work-assignments' -Token $TokenSupervisor -Body @{ items = @(@{ jobCardId = $jcId; description = 'QA work assignment'; department = 'Engine'; technicianName = 'QA Tech A'; dateOfWork = $date }) }
Check 'create work assignment -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/work-assignments' -Token $TokenSupervisor -Body @{ }
Check 'work assignment empty -> 400' ($r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/supervisor/job-cards/999999999/qc-review' -Token $TokenCustomer
Check 'customer cannot qc-review -> 403/404' ($r.status -eq 403 -or $r.status -eq 404) "got $($r.status)"

# =====================================================================================
#  PART 7 - TECHNICIAN
# =====================================================================================
Write-Host "=== PART 7: Technician ===" -ForegroundColor Cyan
$r = Invoke-Api -Method GET -Path '/technicians/profile' -Token $TokenTechnician
Check 'technician profile -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/technicians/assigned-jobs' -Token $TokenTechnician
Check 'assigned jobs -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/technicians/jobs' -Token $TokenTechnician
Check 'technician jobs -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/technicians/jobs/search?q=QA' -Token $TokenTechnician
Check 'technician job search q=QA -> 200/404 (single-result search, 404 on no match)' ($r.status -eq 200 -or $r.status -eq 404) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/technicians/jobs/search?q=' -Token $TokenTechnician
Check 'technician job search empty q -> 200/404 (404 documented, minor)' ($r.status -eq 200 -or $r.status -eq 404) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/technicians/productivity' -Token $TokenTechnician
Check 'technician productivity -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/technicians/work-items' -Token $TokenTechnician
Check 'technician work-items -> 200' ($r.status -eq 200) "got $($r.status)"
# attendance lifecycle
$r = Invoke-Api -Method POST -Path '/technicians/attendance/punch-in' -Token $TokenTechnician -Body @{ }
Check 'punch-in -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/technicians/attendance/punch-in' -Token $TokenTechnician -Body @{ }
Check 'duplicate punch-in same day -> 200/409' ($r.status -eq 200 -or $r.status -eq 409) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/technicians/attendance/break-start' -Token $TokenTechnician -Body @{ }
Check 'break-start -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/technicians/attendance/break-end' -Token $TokenTechnician -Body @{ }
Check 'break-end -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/technicians/attendance/punch-out' -Token $TokenTechnician -Body @{ }
Check 'punch-out -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method GET -Path '/technicians/attendance' -Token $TokenTechnician
Check 'attendance history -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/technicians/attendance/punch-in' -Token $TokenCustomer -Body @{ }
Check 'customer cannot punch-in -> 403' ($r.status -eq 403) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/technician/parts-requests' -Token $TokenTechnician -Body @{ }
Check 'parts request -> 200/400' ($r.status -eq 200 -or $r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/technician/escalations' -Token $TokenTechnician -Body @{ }
Check 'escalation -> 200/400' ($r.status -eq 200 -or $r.status -eq 400) "got $($r.status)"

# =====================================================================================
#  PART 8 - OWNER
# =====================================================================================
Write-Host "=== PART 8: Owner ===" -ForegroundColor Cyan
foreach ($p in @('/owner/dashboard/kpis','/owner/dashboard/sales-trend','/owner/dashboard/profit-trend','/owner/dashboard/expenses-trend','/owner/dashboard/forecast','/owner/dashboard/job-card-register','/owner/dashboard/top-sales','/owner/job-cards','/owner/jobs/status','/owner/jobs/pending','/owner/jobs/active','/owner/documents/expiry','/owner/approvals/categories','/owner/invoices','/owner/accounts-receivable/summary','/owner/accounts-receivable/records','/owner/messages','/owner/activity?page=1&limit=10','/owner/subscription','/owner/team','/owner/inventory/items','/owner/inventory/items/low-stock','/owner/inventory/suppliers','/owner/inventory/purchase-orders','/owner/warranties','/owner/tickets','/owner/webhooks','/owner/api-keys','/branches')) {
    $r = Invoke-Api -Method GET -Path $p -Token $TokenOwner
    $d = ''; if ($r.body) { $d = $r.body.Substring(0, [Math]::Min(150, $r.body.Length)) }
    Check "owner GET $p -> 200" ($r.status -eq 200) "got $($r.status): $d"
}
# exports
$r = Invoke-Api -Method GET -Path '/owner/job-cards/export' -Token $TokenOwner
Check 'owner job-cards CSV export -> 200' ($r.status -eq 200 -and $r.body -match ',') "got $($r.status)"
$r = Invoke-Api -Method GET -Path '/owner/activity/export' -Token $TokenOwner
Check 'owner activity CSV export -> 200' ($r.status -eq 200) "got $($r.status)"
# invoice PDF (likely no invoices yet for this data - check 404 handling)
$r = Invoke-Api -Method GET -Path '/owner/invoices/999999999/pdf' -Token $TokenOwner
Check 'invoice pdf unknown id -> 404' ($r.status -eq 404) "got $($r.status)"
# messages
$r = Invoke-Api -Method POST -Path '/owner/messages' -Token $TokenOwner -Body @{ recipient = 'QA Team'; message = 'QA test message' }
Check 'owner send message -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/owner/messages' -Token $TokenOwner -Body @{ }
Check 'owner message empty -> 400' ($r.status -eq 400) "got $($r.status)"
# subscription (query param contract)
$r = Invoke-Api -Method PUT -Path '/owner/subscription?plan=pro' -Token $TokenOwner
Check 'owner update subscription -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
# branches
$r = Invoke-Api -Method POST -Path '/branches' -Token $TokenOwner -Body @{ name = "QA Branch $RunTag"; address = 'Test'; phone = '0500000000' }
Check 'owner create branch -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
# api keys (query param contract)
$r = Invoke-Api -Method POST -Path '/owner/api-keys?name=QA+Key' -Token $TokenOwner
Check 'owner create api key -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$apiKey = $r.data.data.key
if ($apiKey) {
    $r = Invoke-ApiRaw -Method GET -Path '/owner/dashboard/kpis' -ExtraHeaders @{ 'X-API-Key' = $apiKey }
    Check 'api key authenticates (owner role) -> 200' ($r.status -eq 200) "got $($r.status)"
    $r = Invoke-ApiRaw -Method GET -Path '/owner/dashboard/kpis' -ExtraHeaders @{ 'X-API-Key' = 'invalid-key' }
    Check 'invalid api key -> 401' ($r.status -eq 401) "got $($r.status)"
}
# team
$r = Invoke-Api -Method POST -Path '/owner/team' -Token $TokenOwner -Body @{ name = 'QA Staff'; role = 'advisor'; phone = "9715$RunTag" + '130'; empId = "EQA$RunTag`TM" }
Check 'owner create team member -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
# inventory
$r = Invoke-Api -Method POST -Path '/owner/inventory/items' -Token $TokenOwner -Body @{ name = 'QA Oil Filter'; sku = "QA-$RunTag"; quantity = 5; reorder_level = 2; unit_price = 15.5 }
Check 'owner create inventory item -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/owner/inventory/items' -Token $TokenOwner -Body @{ name = 'QA Dup'; sku = "QA-$RunTag"; quantity = 1 }
Check 'owner duplicate sku rejected (BUG-016: nullable branch bypasses unique index) -> 409/400' ($r.status -eq 409 -or $r.status -eq 400) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/owner/inventory/items' -Token $TokenOwner -Body @{ name = 'QA Neg'; sku = "QA-NEG-$RunTag"; qtyOnHand = -5 }
Check 'owner negative qty rejected (BUG-015: got 200, row created) -> 400' ($r.status -eq 400) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/owner/payments' -Token $TokenOwner -Body @{ invoiceId = 999999999; amount = 10 }
Check 'payment unknown invoice -> 404 (got 400, minor contract)' ($r.status -eq 404) "got $($r.status): $($r.body)"

# =====================================================================================
#  PART 9 - CRM
# =====================================================================================
Write-Host "=== PART 9: CRM ===" -ForegroundColor Cyan
foreach ($p in @('/crm/dashboard/kpis','/crm/channels','/crm/conversion-trend','/crm/salesperson-performance','/crm/response-times','/crm/lead-sources','/crm/key-metrics','/crm/leads','/crm/leads/stats','/crm/leads/follow-ups','/crm/activity-feed','/crm/integrations','/crm/conversations','/crm/sales-team','/crm/team-members','/crm/tasks')) {
    $r = Invoke-Api -Method GET -Path $p -Token $TokenCRM
    Check "crm GET $p -> 200" ($r.status -eq 200) "got $($r.status): $($r.body.Substring(0, [Math]::Min(120, $r.body.Length)))"
}
$r = Invoke-Api -Method POST -Path '/crm/leads' -Token $TokenCRM -Body @{ customerName = 'QA Lead'; phone = "9715$RunTag" + '140'; source = 'walk-in'; leadValue = 500; status = 'ACTIVE' }
Check 'crm create lead -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$lead = $r.data.data
$leadId = if ($lead.id) { $lead.id } else { $lead.leadId }
$r = Invoke-Api -Method POST -Path '/crm/leads' -Token $TokenCRM -Body @{ customerName = 'QA Lead'; phone = "9715$RunTag" + '140'; source = 'walk-in' }
Check 'crm duplicate lead -> 200/409' ($r.status -eq 200 -or $r.status -eq 409) "got $($r.status)"
if ($leadId) {
    $r = Invoke-Api -Method GET -Path "/crm/leads/$leadId/score" -Token $TokenCRM
    Check 'crm lead score -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
    $r = Invoke-Api -Method GET -Path "/crm/leads/$leadId/activities" -Token $TokenCRM
    Check 'crm lead activities -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
    $r = Invoke-Api -Method PUT -Path "/crm/leads/$leadId" -Token $TokenCRM -Body @{ customerName = 'QA Lead Updated'; status = 'WON' }
    Check 'crm update lead -> 200' ($r.status -eq 200) "got $($r.status): $($r.body)"
} else {
    Check 'crm lead score -> 200' $false 'no lead id (create failed)'
    Check 'crm lead activities -> 200' $false 'no lead id (create failed)'
    Check 'crm update lead -> 200' $false 'no lead id (create failed)'
}
$r = Invoke-Api -Method GET -Path '/crm/leads?page=1&size=5' -Token $TokenCRM
Check 'crm leads pagination -> 200' ($r.status -eq 200) "got $($r.status)"
$r = Invoke-Api -Method POST -Path '/crm/tasks' -Token $TokenCRM -Body @{ title = 'QA Task'; assignedTo = 'QA'; dueDate = $date; priority = 'high'; isDone = $false }
Check 'crm create task -> 200/201' ($r.status -eq 200 -or $r.status -eq 201) "got $($r.status): $($r.body)"
$r = Invoke-Api -Method POST -Path '/crm/tasks' -Token $TokenCRM -Body @{ }
Check 'crm task empty -> 400' ($r.status -eq 400) "got $($r.status)"

# =====================================================================================
#  PART 10 - SYNC + MEDIA
# =====================================================================================
Write-Host "=== PART 10: Sync/Media ===" -ForegroundColor Cyan
# sync endpoints require staff; idempotency replay
$r = Invoke-Api -Method POST -Path '/sync/bookings' -Token $TokenAdvisor -Body @{ booking_ref = 'SYNC-QA-1'; customer_id = 1; service_type = 'Test'; booking_date = $date }
$syncStatus1 = $r.status
$r2 = Invoke-Api -Method POST -Path '/sync/bookings' -Token $TokenAdvisor -Body @{ booking_ref = 'SYNC-QA-1'; customer_id = 1; service_type = 'Test'; booking_date = $date } -ExtraHeaders @{ 'Idempotency-Key' = 'qa-key-1' }
$r3 = Invoke-Api -Method POST -Path '/sync/bookings' -Token $TokenAdvisor -Body @{ booking_ref = 'SYNC-QA-1'; customer_id = 1; service_type = 'Test'; booking_date = $date } -ExtraHeaders @{ 'Idempotency-Key' = 'qa-key-1' }
Check 'sync bookings accepted (staff only) -> 200/4xx' ($syncStatus1 -eq 200 -or $syncStatus1 -eq 400 -or $syncStatus1 -eq 409) "got ${syncStatus1}: $($r.body)"
$norm2 = ($r2.data | ConvertTo-Json -Compress -Depth 8)
$norm3 = ($r3.data | ConvertTo-Json -Compress -Depth 8)
Check 'sync duplicate idempotency-key replays -> same body' ($norm2 -eq $norm3) "diff: $norm2 vs $norm3"
$r = Invoke-Api -Method POST -Path '/sync/bookings' -Token $TokenCustomer -Body @{ }
Check 'customer cannot use sync endpoint -> 403' ($r.status -eq 403) "got $($r.status)"

# media upload - valid png magic bytes (curl.exe handles multipart reliably)
$tmpPng = "$env:TEMP\qa_upload_test.png"
[IO.File]::WriteAllBytes($tmpPng, [Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=='))
function Invoke-MultipartUpload([string]$FilePath) {
    $out = curl.exe -s -w "`nHTTP:%{http_code}" -X POST "$BaseUrl/repair-orders/1/media" -H "Authorization: Bearer $TokenAdvisor" -F "file=@$FilePath"
    $lines = $out -split "`n"
    $body = ($lines | Where-Object { $_ -and $_ -notmatch '^HTTP:' }) -join "`n"
    $statusLine = ($lines | Where-Object { $_ -match '^HTTP:' } | Select-Object -First 1)
    $status = 0
    if ($statusLine) { $status = [int]($statusLine -replace '^HTTP:','').Trim() }
    return @{ status = $status; body = $body }
}
$up = Invoke-MultipartUpload $tmpPng
Check 'media upload png -> 200/201 (BUG-017 fixed)' ($up.status -eq 200 -or $up.status -eq 201) "got $($up.status): $($up.body)"
if ($up.status -eq 200 -or $up.status -eq 201) {
    $mediaBody = $up.body | ConvertFrom-Json
    Check 'media upload returns url' ($null -ne $mediaBody.data.url) "$($up.body)"
} else { Check 'media upload returns url' $false 'upload failed' }
# fake image (text bytes renamed .png) - magic-byte validation
$tmpFake = "$env:TEMP\qa_fake.png"
[IO.File]::WriteAllText($tmpFake, 'this is not an image')
$upFake = Invoke-MultipartUpload $tmpFake
Check 'media upload fake png rejected -> 400/415' ($upFake.status -eq 400 -or $upFake.status -eq 415) "got $($upFake.status): $($upFake.body)"
Remove-Item $tmpPng, $tmpFake -ErrorAction SilentlyContinue

# =====================================================================================
#  SUMMARY
# =====================================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "QA API SUITE COMPLETE" -ForegroundColor Cyan
Write-Host "  Passed: $script:PassCount   Failed: $script:FailCount" -ForegroundColor $(if ($script:FailCount -eq 0) {'Green'} else {'Red'})
Write-Host "========================================" -ForegroundColor Cyan

$json = $script:Results | ConvertTo-Json -Depth 5
$outPath = Join-Path (Get-Location) $ResultsOut
$outDir = Split-Path $outPath
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
[IO.File]::WriteAllText($outPath, $json)
Write-Host "Results written to $outPath"

if ($script:FailCount -gt 0) { exit 1 } else { exit 0 }


