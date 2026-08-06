# =====================================================================================
#  SEAMLESS FLOW E2E TEST — Orient Workshop (customer booking -> technician -> owner)
# =====================================================================================
#  Logs in as EVERY role (customer, supervisor, advisor, technician x2, owner) and
#  walks the full seamless flow:
#
#   customer books  -> supervisor assigns to advisor -> advisor intake + inspection
#   -> repair order (work items auto-generated) -> customer approves estimate
#   -> advisor assigns technicians PER ITEM -> technicians complete their items
#   -> job auto-flips to awaitingSupervisor -> supervisor approves completion
#   -> invoice auto-raised -> customer + owner verify
#
#  REQUIREMENTS
#   1. Backend running:      docker compose up -d   (or mvnw spring-boot:run)
#      Dev OTP is "123456" (application-dev.properties: app.otp.fixed-value)
#   2. MySQL CLI reachable for automatic staff provisioning, OR run the printed SQL
#      manually. Staff records must exist (advisor/technician/supervisor endpoints).
#
#  USAGE
#     powershell -ExecutionPolicy Bypass -File scripts\test_seamless_flow.ps1
#     # options:
#     #  -BaseUrl http://localhost:8080/api/v1
#     #  -Otp 123456
#     #  -DbUser root -DbPass root -DbName orient_workshop
#     #  -SkipProvision   (staff rows already exist)
#     #  -RunTag t01      (unique suffix for test phones/emp ids; default = HHmmss)
#
#  EXIT CODE: 0 = all steps passed, 1 = any step failed
# =====================================================================================

param(
    [string]$BaseUrl = 'http://localhost:8080/api/v1',
    [string]$Otp = '123456',
    [string]$DbHost = 'localhost',
    [string]$DbUser = 'root',
    [string]$DbPass = 'root',
    [string]$DbName = 'orient_workshop',
    [switch]$SkipProvision,
    [string]$RunTag = (Get-Date -Format 'HHmmss')
)

$ErrorActionPreference = 'Stop'

# ---- role phones (LAST 3 DIGITS = role, see AuthService.resolveDefaultRole) -------
$PhoneAdvisor    = "9715$RunTag" + '001'
$PhoneSupervisor = "9715$RunTag" + '002'
$PhoneTechnician = "9715$RunTag" + '003'
$PhoneTech2      = "9716$RunTag" + '003'
$PhoneCustomer   = "9715$RunTag" + '004'
$PhoneOwner      = "9715$RunTag" + '005'

# ---- shared API helpers -----------------------------------------------------------
function Invoke-Api {
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [string]$Token = '',
        $Body = $null,
        [switch]$AllowError
    )
    $headers = @{}
    if ($Token) { $headers['Authorization'] = "Bearer $Token" }
    $params = @{
        Uri         = "$BaseUrl$Path"
        Method      = $Method
        Headers     = $headers
        ContentType = 'application/json'
    }
    if ($null -ne $Body) { $params['Body'] = ($Body | ConvertTo-Json -Depth 12) }

    for ($attempt = 1; $attempt -le 6; $attempt++) {
        try {
            $resp = Invoke-RestMethod @params
            if ($resp -is [System.Management.Automation.PSCustomObject] -and $resp.PSObject.Properties['code'] -and $resp.code -ge 400) {
                throw "API error $($resp.code): $($resp.message)"
            }
            return $resp
        } catch {
            $status = 0
            if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode }
            if ($status -eq 429 -and $attempt -lt 6) {
                Start-Sleep -Seconds 5
                continue
            }
            if ($AllowError) { return $null }
            throw "API $Method $Path FAILED: $($_.Exception.Message)"
        }
    }
}

function Login-Role {
    param([Parameter(Mandatory)][string]$Phone, [Parameter(Mandatory)][string]$ExpectedRole)
    $null = Invoke-Api -Method POST -Path '/auth/send-otp' -Body @{ type = 'sms'; phone = $Phone }
    $resp = Invoke-Api -Method POST -Path '/auth/verify-otp' -Body @{ type = 'sms'; phone = $Phone; otp = $Otp }
    $token = $resp.data.token
    if (-not $token) { throw "No token returned for phone ending ...$($Phone.Substring($Phone.Length-3))" }
    $actualRole = $resp.data.role
    if ($actualRole -ne $ExpectedRole) {
        throw "Expected role '$ExpectedRole' for phone ...$($Phone.Substring($Phone.Length-3)) but got '$actualRole'"
    }
    Write-Host ("  logged in: role={0}" -f $actualRole) -ForegroundColor DarkGray
    return $token
}

function Get-ApiData {
    param([Parameter(Mandatory)]$Resp)
    if ($null -eq $Resp) { return $null }
    if ($Resp -is [System.Management.Automation.PSCustomObject] -and $Resp.PSObject.Properties['data']) { return $Resp.data }
    return $Resp
}

# ---- step runner ------------------------------------------------------------------
$script:StepResults = New-Object System.Collections.ArrayList
function Step {
    param([Parameter(Mandatory)][string]$Name, [Parameter(Mandatory)][scriptblock]$Action)
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $ok = & $Action
        if ($ok -ne $true) { $ok = $false }
    } catch {
        Write-Host ("      ! " + $_.Exception.Message) -ForegroundColor DarkRed
        $ok = $false
    }
    $sw.Stop()
    $null = $script:StepResults.Add([pscustomobject]@{ Name = $Name; Pass = $ok; Ms = $sw.ElapsedMilliseconds })
    $icon = if ($ok) { 'PASS' } else { 'FAIL' }
    $color = if ($ok) { 'Green' } else { 'Red' }
    Write-Host ("  [{0}] {1} ({2} ms)" -f $icon, $Name, $sw.ElapsedMilliseconds) -ForegroundColor $color
    return $ok
}

function Assert {
    param([Parameter(Mandatory)]$Condition, [Parameter(Mandatory)][string]$Message)
    if (-not $Condition) { throw "ASSERT FAILED: $Message" }
}

# ===================================================================================
Write-Host "`n=== SEAMLESS FLOW E2E TEST ===" -ForegroundColor Cyan
Write-Host "BaseUrl: $BaseUrl | OTP: $Otp | RunTag: $RunTag" -ForegroundColor DarkGray

# health check
$health = Invoke-Api -Method GET -Path '/health' -AllowError
if (-not $health) { Write-Host "Backend not reachable at $BaseUrl. Start it first (docker compose up -d)." -ForegroundColor Red; exit 1 }

# ---- PHASE A: LOGIN EVERY ROLE ----------------------------------------------------
# P3 (audit): roles are NO LONGER derived from the phone suffix (that was the
# privilege-escalation fix). Phase A only logs in to obtain user ids; roles are
# provisioned in Phase B (SQL, mirroring the owner admin flow) and Phase C
# re-logs-in with role assertions.
Write-Host "`n[Phase A] Login all roles (bootstrap, no role assertion yet)" -ForegroundColor Yellow
$TokCustomer = Login-Role -Phone $PhoneCustomer -ExpectedRole 'customer'
$TokSupervisor = Login-Role -Phone $PhoneSupervisor -ExpectedRole 'customer'
$TokAdvisor = Login-Role -Phone $PhoneAdvisor -ExpectedRole 'customer'
$TokTech1 = Login-Role -Phone $PhoneTechnician -ExpectedRole 'customer'
$TokTech2 = Login-Role -Phone $PhoneTech2 -ExpectedRole 'customer'
$TokOwner = Login-Role -Phone $PhoneOwner -ExpectedRole 'customer'

# ---- PHASE B: PROVISION STAFF RECORDS ---------------------------------------------
Write-Host "`n[Phase B] Provision staff records" -ForegroundColor Yellow
$meAdvisor = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokAdvisor).data
$meSupervisor = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokSupervisor).data
$meTech1 = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokTech1).data
$meTech2 = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokTech2).data
$meOwner = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokOwner).data

if (-not $SkipProvision) {
    $branchId = 1
    # Bootstrap tokens are all customers, so /branches is 403 by design now —
    # fall back to branch 1 (the seeded default) instead of failing.
    try {
        $branches = Get-ApiData (Invoke-Api -Method GET -Path '/branches' -Token $TokOwner -AllowError)
        if ($branches -and @($branches).Count -gt 0) { $branchId = @($branches)[0].id }
    } catch { $branchId = 1 }

    $sql = @"
DELETE FROM staff WHERE emp_id IN ('EADV$RunTag','ESUP$RunTag','ETCH$($RunTag)1','ETCH$($RunTag)2');
INSERT INTO staff (user_id, emp_id, name, role, branch_id, branch, designation, is_active)
VALUES
  ($($meAdvisor.userId),   'EADV$RunTag',    'Seamless Test Advisor',   'advisor',    $branchId, 'Main Branch - Dubai', 'Advisor', TRUE),
  ($($meSupervisor.userId),'ESUP$RunTag',    'Seamless Test Supervisor','supervisor', $branchId, 'Main Branch - Dubai', 'Supervisor', TRUE),
  ($($meTech1.userId),     'ETCH$($RunTag)1','Seamless Test Tech A',    'technician', $branchId, 'Main Branch - Dubai', 'Technician', TRUE),
  ($($meTech2.userId),     'ETCH$($RunTag)2','Seamless Test Tech B',    'technician', $branchId, 'Main Branch - Dubai', 'Technician', TRUE);
UPDATE users SET name = 'Seamless Test Advisor'    WHERE id = $($meAdvisor.userId);
UPDATE users SET name = 'Seamless Test Supervisor' WHERE id = $($meSupervisor.userId);
UPDATE users SET name = 'Seamless Test Tech A'     WHERE id = $($meTech1.userId);
UPDATE users SET name = 'Seamless Test Tech B'     WHERE id = $($meTech2.userId);
UPDATE users SET name = 'Seamless Test Owner'      WHERE id = $($meOwner.userId);
-- P3 (audit): roles are provisioned here (the owner admin flow), never from
-- the phone number. The JWT filter re-checks the DB role per request, so the
-- bootstrap tokens are invalidated — Phase C re-logs-in with the new roles.
UPDATE users SET role = 'advisor'    WHERE id = $($meAdvisor.userId);
UPDATE users SET role = 'supervisor' WHERE id = $($meSupervisor.userId);
UPDATE users SET role = 'technician' WHERE id = $($meTech1.userId);
UPDATE users SET role = 'technician' WHERE id = $($meTech2.userId);
UPDATE users SET role = 'owner'      WHERE id = $($meOwner.userId);
"@

    $mysql = Get-Command mysql -ErrorAction SilentlyContinue
    if (-not $mysql) {
        foreach ($candidate in @(
            'C:\Program Files\MySQL\MySQL Workbench 8.0 CE\mysql.exe',
            'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe',
            'C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe',
            'C:\xampp\mysql\bin\mysql.exe',
            'C:\wamp64\bin\mysql\*\bin\mysql.exe'
        )) {
            $resolved = Get-Item $candidate -ErrorAction SilentlyContinue
            if ($resolved) { $mysql = $resolved; break }
        }
    }
    if ($mysql) {
        $mysqlPath = if ($mysql -is [System.Management.Automation.CommandInfo]) { $mysql.Source } else { $mysql.FullName }
        Write-Host "  running mysql provisioning via $mysqlPath ..." -ForegroundColor DarkGray
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        $null = $sql | & $mysqlPath -h $DbHost -u $DbUser ("-p$DbPass") $DbName 2>$null
        $mysqlExit = $LASTEXITCODE
        $ErrorActionPreference = $prevEap
        if ($mysqlExit -ne 0) {
            Write-Host "  mysql provisioning failed (exit $mysqlExit). Run the SQL below manually then re-run with -SkipProvision" -ForegroundColor Red
            Write-Host $sql -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "  mysql CLI not found. Run the SQL below manually then re-run with -SkipProvision" -ForegroundColor Red
        Write-Host $sql -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "  -SkipProvision: assuming staff records + roles exist" -ForegroundColor DarkGray
}

# ---- PHASE C: RE-LOGIN WITH PROVISIONED ROLES --------------------------------------
Write-Host "`n[Phase C] Re-login with provisioned roles" -ForegroundColor Yellow
$TokSupervisor = Login-Role -Phone $PhoneSupervisor -ExpectedRole 'supervisor'
$TokAdvisor = Login-Role -Phone $PhoneAdvisor -ExpectedRole 'advisor'
$TokTech1 = Login-Role -Phone $PhoneTechnician -ExpectedRole 'technician'
$TokTech2 = Login-Role -Phone $PhoneTech2 -ExpectedRole 'technician'
$TokOwner = Login-Role -Phone $PhoneOwner -ExpectedRole 'owner'

$advisorStaffId = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokAdvisor).data.staffId
Assert ($null -ne $advisorStaffId) 'Advisor has no staff record after provisioning'
$tech1EmpId = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokTech1).data.empId
$tech2EmpId = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokTech2).data.empId
Assert ($tech1EmpId -and $tech2EmpId) 'technician staff records missing after provisioning'

# ===================================================================================
# ---- FLOW: CUSTOMER -> SUPERVISOR -> ADVISOR -> CUSTOMER APPROVAL -> TECH -> OWNER
# ===================================================================================
Write-Host "`n[Flow] Starting seamless journey" -ForegroundColor Yellow

# ---- 1. Customer: add vehicle + book appointment ----------------------------------
$null = Step 'Customer login + add vehicle' {
    $resp = Invoke-Api -Method POST -Path '/customers/vehicles' -Token $TokCustomer -Body @{
        brand = 'BMW'; model = '3 Series'; plateNumber = "T$RunTag"; vin = "WBA$RunTag"
        color = 'White'; year = 2022; mileage = '12000 km'; healthScore = 85
    }
    $script:VehicleId = (Get-ApiData $resp).id
    Assert ($script:VehicleId) 'vehicle id missing'
    $custMe = (Invoke-Api -Method GET -Path '/auth/me' -Token $TokCustomer).data
    $script:CustomerId = $custMe.customerId
    Assert ($script:CustomerId) 'customerId missing after first customer action'
    $true
}

$null = Step 'Customer books appointment' {
    $resp = Invoke-Api -Method POST -Path '/bookings' -Token $TokCustomer -Body @{
        vehicleId = $script:VehicleId
        vehicleName = 'BMW 3 Series'
        plateNumber = "T$RunTag"
        serviceType = 'Full Service'
        bookingDate = (Get-Date).AddDays(1).ToString('yyyy-MM-ddTHH:mm:00')
        notes = 'Seamless flow e2e test booking'
    }
    $script:BookingRef = (Get-ApiData $resp).id
    Assert ($script:BookingRef) 'booking ref missing'
    $true
}

$null = Step 'Customer gets bookingReceived notification' {
    $resp = Get-ApiData (Invoke-Api -Method GET -Path '/customers/notifications' -Token $TokCustomer)
    $types = @($resp | ForEach-Object { $_.type })
    Assert ($types -contains 'bookingReceived') "expected bookingReceived, got: $($types -join ',')"
    $true
}

# ---- 2. Supervisor: sees the booking, assigns to advisor --------------------------
$null = Step 'Supervisor sees unassigned booking in queue' {
    $queue = Get-ApiData (Invoke-Api -Method GET -Path '/supervisor/bookings' -Token $TokSupervisor)
    $found = @($queue) | Where-Object { $_.id -eq $script:BookingRef -or $_.bookingRef -eq $script:BookingRef } | Select-Object -First 1
    Assert ($null -ne $found) "booking $($script:BookingRef) not in supervisor queue"
    $script:BookingId = $found.id
    $true
}

$null = Step 'Supervisor assigns booking to advisor' {
    $advisors = Get-ApiData (Invoke-Api -Method GET -Path '/supervisor/assignable-advisors' -Token $TokSupervisor)
    $myAdvisor = @($advisors) | Where-Object { $_.empId -eq "EADV$RunTag" } | Select-Object -First 1
    Assert ($null -ne $myAdvisor) 'assigned advisor not in assignable list'
    $script:AdvisorStaffId = $myAdvisor.id
    $null = Invoke-Api -Method PUT -Path "/supervisor/bookings/$script:BookingId/assign" -Token $TokSupervisor -Body @{ advisorId = $script:AdvisorStaffId }
    $queue = Get-ApiData (Invoke-Api -Method GET -Path '/supervisor/bookings' -Token $TokSupervisor)
    Assert (-not (@($queue) | Where-Object { $_.bookingRef -eq $script:BookingRef })) 'booking still in unassigned queue after assign'
    $true
}

$null = Step 'Customer gets bookingAssigned notification' {
    $resp = Get-ApiData (Invoke-Api -Method GET -Path '/customers/notifications' -Token $TokCustomer)
    $types = @($resp | ForEach-Object { $_.type })
    Assert ($types -contains 'bookingAssigned') "expected bookingAssigned, got: $($types -join ',')"
    $true
}

# ---- 3. Advisor: sees assigned booking, intake + inspection + repair order --------
$null = Step 'Advisor sees assigned booking' {
    $bookings = Get-ApiData (Invoke-Api -Method GET -Path '/advisor/bookings' -Token $TokAdvisor)
    Assert (@($bookings) | Where-Object { $_.id -eq $script:BookingRef -or $_.bookingRef -eq $script:BookingRef }) 'booking not visible to advisor'
    $true
}

$null = Step 'Advisor intake: job card + inspection (with fair/poor items)' {
    $resp = Invoke-Api -Method POST -Path '/inspections' -Token $TokAdvisor -Body @{
        type = 'vehicle_customer'
        status = 'inProgress'
        bookingId = "$script:BookingId"
        customerId = "$script:CustomerId"
        customerRequests = 'AC not cooling, headlight dim'
        vehicle = @{
            registrationNumber = "T$RunTag"; vin = "WBA$RunTag"; make = 'BMW'; model = '3 Series'; modelYear = 2022; vehicleColor = 'White'
        }
        sections = @{
            interior_exterior = @{ 'Head Light/Tail Light/Turn Signals' = @{ status = 'fair' } }
            under_vehicle     = @{ 'Fluid Leaks' = @{ status = 'poor' } }
        }
        notifyOwnerSmsEmail = $true
    }
    $script:InspectionId = (Get-ApiData $resp).id
    Assert ($script:InspectionId) 'inspection id missing'
    # booking must now be linked -> disappears from the advisor open list
    $bookings = Get-ApiData (Invoke-Api -Method GET -Path '/advisor/bookings' -Token $TokAdvisor)
    Assert (-not (@($bookings) | Where-Object { $_.bookingRef -eq $script:BookingRef })) 'booking not linked after intake'
    $true
}

$null = Step 'Advisor finds the job card (with dbId)' {
    $cards = Get-ApiData (Invoke-Api -Method GET -Path '/advisor/job-cards' -Token $TokAdvisor)
    if ($cards -is [System.Management.Automation.PSCustomObject] -and $cards.PSObject.Properties['content']) { $cards = $cards.content }
    $card = @($cards) | Where-Object { $_.vehicleInfo -match 'BMW' } | Select-Object -First 1
    Assert ($null -ne $card) 'job card not found for test vehicle'
    $script:JobRef = $card.id
    $script:JobDbId = $card.dbId
    Assert ($script:JobDbId) 'dbId missing on job card response'
    $true
}

$null = Step 'Advisor creates repair order (Engine Work + Headlight Change)' {
    $resp = Invoke-Api -Method POST -Path '/repair-orders' -Token $TokAdvisor -Body @{
        jobCardId = "$script:JobDbId"
        services = @(
            @{ name = 'Engine Work'; qty = 1; rate = 250.0; discountPercent = 0; discountAmount = 0 }
            @{ name = 'Headlight Change'; qty = 1; rate = 80.0; discountPercent = 0; discountAmount = 0 }
        )
        parts = @(
            @{ name = 'Headlight Bulb'; qty = 1; rate = 25.0; discountPercent = 0; discountAmount = 0 }
        )
        customerRequests = 'AC not cooling, headlight dim'
        garageRecommendations = 'Replace headlight, check AC'
        estimatedDelivery = (Get-Date).AddDays(1).ToString('yyyy-MM-ddTHH:mm:00')
        notifyOwnerSmsEmail = $true
    }
    $script:EstimateId = (Get-ApiData $resp).id
    Assert ($script:EstimateId) 'repair order ref missing'
    $true
}

$null = Step 'Work items auto-generated (inspection + work)' {
    $items = Get-ApiData (Invoke-Api -Method GET -Path "/advisor/job-cards/$script:JobRef/work-items" -Token $TokAdvisor)
    $names = @($items | ForEach-Object { $_.description })
    Assert ($names -contains 'Engine Work') "Engine Work missing: $($names -join '|')"
    Assert ($names -contains 'Headlight Change') "Headlight Change missing"
    Assert (@($names | Where-Object { $_ -match 'Head Light' })) 'inspection item (Head Light) missing'
    Assert (@($names | Where-Object { $_ -match 'Fluid Leaks' })) 'inspection item (Fluid Leaks) missing'
    $script:WorkItems = @($items)
    $true
}

# ---- 4. Advisor assigns technicians PER ITEM --------------------------------------
$null = Step 'Advisor assigns technicians per work item' {
    $techs = Get-ApiData (Invoke-Api -Method GET -Path '/advisor/technicians' -Token $TokAdvisor)
    $techA = @($techs) | Where-Object { $_.empId -eq $tech1EmpId } | Select-Object -First 1
    $techB = @($techs) | Where-Object { $_.empId -eq $tech2EmpId } | Select-Object -First 1
    Assert ($null -ne $techA -and $null -ne $techB) 'both technicians must be visible to advisor'
    $i = 0
    foreach ($item in $script:WorkItems) {
        $emp = if (($i % 2) -eq 0) { $techA.empId } else { $techB.empId }
        $null = Invoke-Api -Method PUT -Path "/advisor/work-items/$($item.id)/assign" -Token $TokAdvisor -Body @{ empId = $emp }
        $i++
    }
    $items = Get-ApiData (Invoke-Api -Method GET -Path "/advisor/job-cards/$script:JobRef/work-items" -Token $TokAdvisor)
    $unassigned = @($items | Where-Object { -not $_.empId })
    Assert ($unassigned.Count -eq 0) "$($unassigned.Count) items still unassigned"
    $true
}

# ---- 5. Customer approves the estimate --------------------------------------------
$null = Step 'Customer sees pending approval' {
    $approvals = Get-ApiData (Invoke-Api -Method GET -Path '/customers/approvals/pending' -Token $TokCustomer)
    $found = @($approvals) | Where-Object { $_.estimateId -eq $script:EstimateId } | Select-Object -First 1
    Assert ($null -ne $found) "approval $($script:EstimateId) not pending for customer"
    $true
}

$null = Step 'Customer views approval detail (line items + total)' {
    $detail = Get-ApiData (Invoke-Api -Method GET -Path "/customers/approvals/$script:EstimateId" -Token $TokCustomer)
    Assert ($detail.services.Count -ge 2) 'services line items missing'
    Assert ($detail.parts.Count -ge 1) 'parts line items missing'
    Assert ($detail.grandTotal -gt 0) 'grand total missing'
    $true
}

$null = Step 'Customer approves estimate -> job in progress' {
    $null = Invoke-Api -Method PUT -Path "/customers/approvals/$script:EstimateId" -Token $TokCustomer -Body @{ action = 'approve' }
    $svc = Get-ApiData (Invoke-Api -Method GET -Path '/customers/services/active' -Token $TokCustomer)
    Assert ($svc.jobCardId -eq $script:JobRef) "active service job mismatch: $($svc.jobCardId)"
    Assert ($svc.currentStage -eq 'In Progress') "expected In Progress, got $($svc.currentStage)"
    $true
}

# ---- 6. Technicians complete their items ------------------------------------------
$null = Step 'Tech A sees only their work items' {
    $items = Get-ApiData (Invoke-Api -Method GET -Path '/technicians/work-items' -Token $TokTech1)
    $mine = @($items | Where-Object { $_.empId -eq $tech1EmpId })
    Assert ($mine.Count -gt 0) 'tech A has no assigned items'
    Assert (@($items | Where-Object { $_.empId -eq $tech2EmpId }).Count -eq 0) 'tech A sees tech B items!'
    $script:TechAItems = $mine
    $true
}

$null = Step 'Tech B sees only their work items' {
    $items = Get-ApiData (Invoke-Api -Method GET -Path '/technicians/work-items' -Token $TokTech2)
    $mine = @($items | Where-Object { $_.empId -eq $tech2EmpId })
    Assert ($mine.Count -gt 0) 'tech B has no assigned items'
    $script:TechBItems = $mine
    $true
}

$null = Step 'Tech A starts & completes each item (timed)' {
    foreach ($item in $script:TechAItems) {
        $null = Invoke-Api -Method PUT -Path "/technicians/work-items/$($item.id)/start" -Token $TokTech1 -Body @{ startTime = '09:00 AM' }
        $null = Invoke-Api -Method PUT -Path "/technicians/work-items/$($item.id)/complete" -Token $TokTech1 -Body @{ endTime = '10:30 AM' }
    }
    $items = Get-ApiData (Invoke-Api -Method GET -Path '/technicians/work-items' -Token $TokTech1)
    Assert (@($items | Where-Object { $_.id -in @($script:TechAItems | ForEach-Object { $_.id }) -and $_.status -ne 'completed' }).Count -eq 0) 'not all tech A items completed'
    $true
}

$null = Step 'Tech B starts & completes each item (timed)' {
    foreach ($item in $script:TechBItems) {
        $null = Invoke-Api -Method PUT -Path "/technicians/work-items/$($item.id)/start" -Token $TokTech2 -Body @{ startTime = '09:15 AM' }
        $null = Invoke-Api -Method PUT -Path "/technicians/work-items/$($item.id)/complete" -Token $TokTech2 -Body @{ endTime = '11:00 AM' }
    }
    $true
}

# ---- 7. Supervisor review gate ----------------------------------------------------
$null = Step 'Job auto-flips to awaitingSupervisor' {
    $cards = Get-ApiData (Invoke-Api -Method GET -Path '/advisor/job-cards' -Token $TokAdvisor)
    if ($cards -is [System.Management.Automation.PSCustomObject] -and $cards.PSObject.Properties['content']) { $cards = $cards.content }
    $card = @($cards) | Where-Object { $_.id -eq $script:JobRef } | Select-Object -First 1
    Assert ($null -ne $card) 'job card vanished'
    Assert ($card.status -eq 'awaitingSupervisor') "expected awaitingSupervisor, got $($card.status)"
    $true
}

$null = Step 'Supervisor sees job in completion review with per-item evidence' {
    $awaiting = Get-ApiData (Invoke-Api -Method GET -Path '/supervisor/jobs/awaiting' -Token $TokSupervisor)
    $job = @($awaiting) | Where-Object { $_.jobCardRef -eq $script:JobRef } | Select-Object -First 1
    Assert ($null -ne $job) 'job not in awaiting queue'
    Assert ($job.done -eq $job.total) "done=$($job.done) total=$($job.total)"
    Assert ($job.items.Count -gt 0) 'no per-item evidence'
    $script:AwaitingJobDbId = $job.jobCardId
    $true
}

$null = Step 'Supervisor receives jobAwaitingReview notification' {
    $notifs = Get-ApiData (Invoke-Api -Method GET -Path '/staff/notifications' -Token $TokSupervisor)
    Assert (@($notifs | Where-Object { $_.type -eq 'jobAwaitingReview' }).Count -gt 0) 'jobAwaitingReview notification missing'
    $true
}

$null = Step 'Supervisor approves completion -> invoice auto-raised' {
    $null = Invoke-Api -Method PUT -Path "/supervisor/jobs/$script:AwaitingJobDbId/approve-completion" -Token $TokSupervisor
    $cards = Get-ApiData (Invoke-Api -Method GET -Path '/advisor/job-cards' -Token $TokAdvisor)
    if ($cards -is [System.Management.Automation.PSCustomObject] -and $cards.PSObject.Properties['content']) { $cards = $cards.content }
    $card = @($cards) | Where-Object { $_.id -eq $script:JobRef } | Select-Object -First 1
    Assert ($null -ne $card) 'job card vanished after approval'
    Assert ($card.status -eq 'completed') "expected completed, got $($card.status)"
    $true
}

# ---- 8. Customer + owner verification ---------------------------------------------
$null = Step 'Customer receives car-ready + invoice notifications' {
    $resp = Get-ApiData (Invoke-Api -Method GET -Path '/customers/notifications' -Token $TokCustomer)
    $types = @($resp | ForEach-Object { $_.type })
    Assert ($types -contains 'completionApproved') "completionApproved missing: $($types -join ',')"
    Assert ($types -contains 'invoiceReady') "invoiceReady missing"
    $true
}

$null = Step 'Customer sees invoice in app' {
    $invoices = Get-ApiData (Invoke-Api -Method GET -Path '/customers/invoices' -Token $TokCustomer)
    Assert (@($invoices).Count -gt 0) 'no invoices for customer'
    $script:InvoiceId = @($invoices)[0].id
    $true
}

$null = Step 'Owner (read-only) sees completed job + revenue KPIs' {
    $completed = Get-ApiData (Invoke-Api -Method GET -Path '/owner/jobs/status?stage=completed' -Token $TokOwner)
    Assert (@($completed | Where-Object { $_.jobCardId -eq $script:JobRef }).Count -gt 0) 'completed job not visible to owner'
    $kpis = Get-ApiData (Invoke-Api -Method GET -Path '/owner/dashboard/kpis' -Token $TokOwner)
    Assert (@($kpis).Count -ge 8) 'owner KPI cards missing (expected 8 real cards after the fabricated-KPI removal)'
    Assert (@($kpis | Where-Object { $_.label -like '*Revenue*' }).Count -gt 0) 'owner revenue KPI missing'
    $true
}

$null = Step 'Advisor received bookingAssigned notification' {
    $notifs = Get-ApiData (Invoke-Api -Method GET -Path '/staff/notifications' -Token $TokAdvisor)
    $types = @($notifs | ForEach-Object { $_.type })
    Assert ($types -contains 'bookingAssigned') "advisor bookingAssigned missing: $($types -join ',')"
    $true
}

$null = Step 'Technician received workAssigned notification' {
    $notifs = Get-ApiData (Invoke-Api -Method GET -Path '/staff/notifications' -Token $TokTech1)
    Assert (@($notifs | Where-Object { $_.type -eq 'workAssigned' }).Count -gt 0) 'tech workAssigned notification missing'
    $true
}

# ===================================================================================
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
$passed = @($script:StepResults | Where-Object { $_.Pass }).Count
$failed = @($script:StepResults | Where-Object { -not $_.Pass }).Count
$total = @($script:StepResults).Count
foreach ($r in $script:StepResults) {
    $c = if ($r.Pass) { 'Green' } else { 'Red' }
    Write-Host ("  {0}  {1}" -f $(if ($r.Pass) { 'PASS' } else { 'FAIL' }), $r.Name) -ForegroundColor $c
}
Write-Host ("`n  Result: {0}/{1} passed, {2} failed" -f $passed, $total, $failed) -ForegroundColor $(if ($failed -eq 0) { 'Green' } else { 'Red' })
Write-Host "  Test ids: booking=$script:BookingRef job=$script:JobRef estimate=$script:EstimateId invoice=$script:InvoiceId" -ForegroundColor DarkGray
Write-Host "  Phones: advisor=$PhoneAdvisor supervisor=$PhoneSupervisor tech1=$PhoneTechnician tech2=$PhoneTech2 customer=$PhoneCustomer owner=$PhoneOwner" -ForegroundColor DarkGray

if ($failed -gt 0) { exit 1 } else { exit 0 }
