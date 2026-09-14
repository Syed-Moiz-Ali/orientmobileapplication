# Orient Workshop — API Testing Plan
## Ticket Lifecycle: Customer → Supervisor → Advisor → Technician

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Phase 1 — Owner App: Login & Staff Creation](#2-phase-1--owner-app-login--staff-creation)
3. [Phase 2 — Customer App: Create Ticket](#3-phase-2--customer-app-create-ticket)
4. [Phase 3 — Supervisor: Receive & Assign Ticket](#4-phase-3--supervisor-receive--assign-ticket)
5. [Phase 4 — Advisor: Inspect](#5-phase-4--advisor-inspect)
6. [Phase 5 — Technician: Work on Ticket](#6-phase-5--technician-work-on-ticket)
7. [Appendix: Complete Endpoint Reference](#7-appendix-complete-endpoint-reference)

---

## 1. Prerequisites

### Base URL
```
http://localhost:8080/api/v1
```

### Environment Variables (Postman)
| Variable | Value |
|---|---|
| `baseUrl` | `http://localhost:8080/api/v1` |
| `token` | *(set automatically after OTP verification)* |

### Response Envelope
All endpoints return:
```json
{
  "code": 200,
  "message": "Success",
  "data": { ... },
  "timestamp": 1754300000000
}
```

### Roles
| Role | Description |
|---|---|
| `owner` | App owner — manages staff, sees all data |
| `advisor` | Inspects jobs, creates inspections, assigns technicians |
| `supervisor` | Manages queue, assigns advisors to bookings/breakdowns |
| `technician` | Works on assigned jobs/tasks |
| `customer` | End-user — creates tickets, bookings, breakdowns |

---

## 2. Phase 1 — Owner App: Login & Staff Creation

> **Goal:** Log in as Owner via OTP, then create three staff members (advisor, supervisor, technician) who will receive and work on the ticket.

### 2.1 Owner Login — Send OTP

```
POST {{baseUrl}}/auth/send-otp
```

**Headers:**
```
Content-Type: application/json
X-App-Name: owner_app
```

**Body:**
```json
{
  "type": "SMS",
  "phone": "971501234568"
}
```

**Expected Response:**
```json
{
  "code": 200,
  "message": "OTP sent",
  "data": null,
  "timestamp": ...
}
```

### 2.2 Owner Login — Verify OTP

```
POST {{baseUrl}}/auth/verify-otp
```

**Headers:**
```
Content-Type: application/json
X-App-Name: owner_app
```

**Body:**
```json
{
  "type": "SMS",
  "phone": "971501234568",
  "otp": "123456"
}
```

**Expected Response:**
```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "token": "eyJhbGciOi...",
    "refreshToken": "eyJhbGciOi...",
    "role": "owner",
    "name": "Owner Name"
  },
  "timestamp": ...
}
```

> **IMPORTANT:** The JWT token from this response is stored in the `token` variable. All subsequent requests use `Authorization: Bearer {{token}}`.

### 2.3 List Existing Staff (verify none exist)

```
GET {{baseUrl}}/owner/team
```

**Expected:** `200 OK` — returns list of staff (may be empty initially).

### 2.4 Create ADVISOR Staff Member

```
POST {{baseUrl}}/owner/team
```

**Body:**
```json
{
  "name": "Test Advisor",
  "empId": "ADV-001",
  "role": "advisor",
  "phone": "971501234569",
  "email": "testadvisor@orient.com",
  "password": "Test@12345",
  "branchId": 1,
  "branch": "Main Branch",
  "designation": "Service Advisor",
  "department": "Service",
  "shift": "Morning"
}
```

**Expected Response:**
```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "id": 1,
    "userId": 1,
    "empId": "ADV-001",
    "name": "Test Advisor",
    "role": "advisor",
    "email": "testadvisor@orient.com",
    "phone": "971501234569",
    "branchId": 1,
    "branch": "Main Branch",
    "isActive": true
  }
}
```

### 2.5 Create SUPERVISOR Staff Member

```
POST {{baseUrl}}/owner/team
```

**Body:**
```json
{
  "name": "Test Supervisor",
  "empId": "SUP-001",
  "role": "supervisor",
  "phone": "971501234570",
  "email": "testsupervisor@orient.com",
  "password": "Test@12345",
  "branchId": 1,
  "branch": "Main Branch",
  "designation": "Workshop Supervisor",
  "department": "Operations",
  "shift": "Morning"
}
```

### 2.6 Create TECHNICIAN Staff Member

```
POST {{baseUrl}}/owner/team
```

**Body:**
```json
{
  "name": "Test Technician",
  "empId": "TEC-001",
  "role": "technician",
  "phone": "971501234571",
  "email": "testtechnician@orient.com",
  "password": "Test@12345",
  "branchId": 1,
  "branch": "Main Branch",
  "designation": "Mechanic",
  "department": "Workshop",
  "shift": "Morning"
}
```

### 2.7 Verify All Staff Created

```
GET {{baseUrl}}/owner/team
```

**Expected:** Returns all 3 staff members with correct roles.

---

## 3. Phase 2 — Customer App: Create Ticket

> **Goal:** Log in as Customer, then create a support ticket that will flow through the system.

### 3.1 Customer Login — Send OTP

```
POST {{baseUrl}}/auth/send-otp
```

**Body:**
```json
{
  "type": "SMS",
  "phone": "971501234500"
}
```

### 3.2 Customer Login — Verify OTP

```
POST {{baseUrl}}/auth/verify-otp
```

**Body:**
```json
{
  "type": "SMS",
  "phone": "971501234500",
  "otp": "123456"
}
```

> The `token` variable is updated to the Customer's JWT.

### 3.3 Create Support Ticket (TICKET FLOW)

```
POST {{baseUrl}}/customers/tickets
```

**Body:**
```json
{
  "subject": "Engine making strange noise while driving",
  "description": "My car makes a loud clunking noise when I accelerate. It started yesterday and is getting worse.",
  "priority": "high"
}
```

**Expected Response:**
```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "ticketRef": "TK-XXXXXX",
    "status": "open"
  },
  "timestamp": ...
}
```

### ALTERNATIVE 3.3: Create a Booking (BOOKING FLOW)

If testing the booking flow instead of tickets:

```
POST {{baseUrl}}/customers/bookings
```

**Body:**
```json
{
  "serviceType": "Full MOT & Service",
  "vehicleId": "VEH-001",
  "vehicleName": "Toyota Camry",
  "plateNumber": "ABC-1234",
  "bookingDate": "2026-09-15T10:00:00",
  "notes": "Need full service and oil change",
  "branchId": 1
}
```

### ALTERNATIVE 3.3: Create a Breakdown (BREAKDOWN FLOW)

If testing the breakdown/roadside flow:

```
POST {{baseUrl}}/customers/breakdowns
```

**Body:**
```json
{
  "issue": "Car broke down on highway, need roadside assistance",
  "vehicleId": "VEH-001",
  "vehicleName": "Toyota Camry",
  "vehiclePlate": "ABC-1234",
  "location": "Highway 65 near Exit 12",
  "branchId": 1
}
```

### 3.4 Verify Ticket Created

```
GET {{baseUrl}}/customers/tickets
```

**Expected:** Returns the created ticket with `status: "open"`.

---

## 4. Phase 3 — Supervisor: Receive & Assign Ticket

> **Goal:** Log in as Supervisor, see the ticket in the queue, then assign it to the Advisor.

### 4.1 Supervisor Login — Send OTP

```
POST {{baseUrl}}/auth/send-otp
```

**Body:**
```json
{
  "type": "SMS",
  "phone": "971501234570"
}
```

### 4.2 Supervisor Login — Verify OTP

```
POST {{baseUrl}}/auth/verify-otp
```

**Body:**
```json
{
  "type": "SMS",
  "phone": "971501234570",
  "otp": "123456"
}
```

> The `token` variable is updated to the Supervisor's JWT.

### 4.3 View Booking Queue (for Booking flow)

```
GET {{baseUrl}}/supervisor/bookings
```

**Expected:** Returns list of bookings awaiting supervisor assignment. Should include the booking created in Phase 2.

### 4.3 View Breakdown Queue (for Breakdown flow)

```
GET {{baseUrl}}/supervisor/breakdowns
```

**Expected:** Returns list of breakdowns awaiting supervisor assignment.

### 4.4 View Assignable Advisors

```
GET {{baseUrl}}/supervisor/assignable-advisors
```

**Expected:** Returns list of advisors available for assignment (should include "Test Advisor").

### 4.5 Assign Booking to Advisor

```
PUT {{baseUrl}}/supervisor/bookings/{bookingId}/assign
```

**Body:**
```json
{
  "advisorId": 1,
  "advisorEmpId": "ADV-001"
}
```

> Replace `{bookingId}` with the actual booking ID from step 4.3.

**Expected Response:** `200 OK`

### 4.5 Assign Breakdown to Advisor (for Breakdown flow)

```
PUT {{baseUrl}}/supervisor/breakdowns/{breakdownId}/assign
```

**Body:**
```json
{
  "advisorId": 1,
  "advisorEmpId": "ADV-001"
}
```

### 4.6 View Supervisor Dashboard KPIs

```
GET {{baseUrl}}/supervisor/kpis
```

**Expected:** Returns KPI metrics for the supervisor.

### 4.7 View Supervisor Assigned Jobs

```
GET {{baseUrl}}/supervisor/assigned-jobs
```

**Expected:** Returns jobs assigned by this supervisor.

### 4.8 View Available Technicians (for next phase)

```
GET {{baseUrl}}/supervisor/technicians/available
```

**Expected:** Returns list of available technicians (should include "Test Technician").

---

## 5. Phase 4 — Advisor: Inspect

> **Goal:** Log in as Advisor, view the assigned job, create an inspection, then assign to Technician.

### 5.1 Advisor Login — Send OTP

```
POST {{baseUrl}}/auth/send-otp
```

**Body:**
```json
{
  "type": "SMS",
  "phone": "971501234569"
}
```

### 5.2 Advisor Login — Verify OTP

```
POST {{baseUrl}}/auth/verify-otp
```

**Body:**
```json
{
  "type": "SMS",
  "phone": "971501234569",
  "otp": "123456"
}
```

> The `token` variable is updated to the Advisor's JWT.

### 5.3 View Assigned Bookings

```
GET {{baseUrl}}/advisor/bookings
```

**Expected:** Returns the booking assigned by the Supervisor in Phase 4.5.

### 5.4 View Job Cards

```
GET {{baseUrl}}/advisor/job-cards
```

**Query Params:**
```
?status=PENDING&page=1&limit=20
```

**Expected:** Returns job cards for the advisor.

### 5.5 View Job Card Details

```
GET {{baseUrl}}/advisor/job-cards/{jobCardId}
```

> Replace `{jobCardId}` with the ID from step 5.4.

**Expected:** Returns detailed job card information.

### 5.6 Create Inspection

```
POST {{baseUrl}}/inspections
```

**Body:**
```json
{
  "jobCardId": "{jobCardId}",
  "bookingId": "{bookingId}",
  "inspectorName": "Test Advisor",
  "notes": "Initial inspection — engine noise confirmed, needs diagnostic check",
  "findings": {
    "engine": "Loose exhaust manifold bolt",
    "transmission": "No issues found",
    "brakes": "Pads at 30% — replace soon",
    "tires": "Good condition"
  }
}
```

**Expected Response:**
```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "id": 1,
    "jobCardId": "...",
    "status": "CREATED",
    ...
  }
}
```

### 5.7 Update Inspection

```
PUT {{baseUrl}}/inspections/{inspectionId}
```

**Body:**
```json
{
  "notes": "Updated findings after further testing",
  "findings": {
    "engine": "Exhaust manifold bolt tightened, noise reduced",
    "transmission": "No issues found",
    "brakes": "Pads at 30% — replace soon",
    "tires": "Good condition"
  }
}
```

### 5.8 Get Inspection Draft

```
GET {{baseUrl}}/inspections/{inspectionId}/draft
```

**Expected:** Returns draft inspection data.

### 5.9 Save Inspection Draft

```
PUT {{baseUrl}}/inspections/{inspectionId}/draft
```

**Body:** Same as step 5.7.

### 5.10 Get Inspection Summary

```
GET {{baseUrl}}/inspections/{inspectionId}/summary
```

**Expected:** Returns AI-lite summary of inspection.

### 5.11 Assign Technician to Job Card

```
PUT {{baseUrl}}/advisor/job-cards/{jobCardId}/technician
```

**Body:**
```json
{
  "technician": "TEC-001",
  "technicianName": "Test Technician"
}
```

### 5.12 View Advisor Technicians

```
GET {{baseUrl}}/advisor/technicians
```

**Expected:** Returns list of active technicians.

### 5.13 View Job Card Work Items

```
GET {{baseUrl}}/advisor/job-cards/{jobCardRef}/work-items
```

> Replace `{jobCardRef}` with the job card reference.

**Expected:** Returns work items for the job card.

### 5.14 Assign Work Item to Technician

```
PUT {{baseUrl}}/advisor/work-items/{taskId}/assign
```

**Body:**
```json
{
  "empId": "TEC-001"
}
```

---

## 6. Phase 5 — Technician: Work on Ticket

> **Goal:** Log in as Technician, view assigned work, start work, and complete it.

### 6.1 Technician Login — Send OTP

```
POST {{baseUrl}}/auth/send-otp
```

**Body:**
```json
{
  "type": "SMS",
  "phone": "971501234571"
}
```

### 6.2 Technician Login — Verify OTP

```
POST {{baseUrl}}/auth/verify-otp
```

**Body:**
```json
{
  "type": "SMS",
  "phone": "971501234571",
  "otp": "123456"
}
```

> The `token` variable is updated to the Technician's JWT.

### 6.3 View Assigned Jobs

```
GET {{baseUrl}}/technicians/assigned-jobs
```

**Expected:** Returns the job card assigned by the Advisor.

### 6.4 View All Jobs (with filter)

```
GET {{baseUrl}}/technicians/jobs?status=IN_PROGRESS&page=1&size=20
```

**Expected:** Returns jobs filtered by status.

### 6.5 Start Task

```
PUT {{baseUrl}}/technicians/jobs/{jobCardNo}/tasks/{taskId}/start
```

**Body:**
```json
{
  "note": "Started work on engine inspection"
}
```

**Expected:** `200 OK`

### 6.6 Update Task Status

```
PUT {{baseUrl}}/technicians/jobs/{jobCardNo}/tasks/{taskId}/status
```

**Body:**
```json
{
  "status": "IN_PROGRESS",
  "note": "Diagnosing engine noise"
}
```

### 6.7 Complete Task

```
PUT {{baseUrl}}/technicians/jobs/{jobCardNo}/tasks/{taskId}/complete
```

**Body:**
```json
{
  "note": "Task completed — exhaust manifold tightened, noise resolved"
}
```

**Expected:** `200 OK`

### 6.8 Update Job Card Status (Advisor action)

*Switch token back to Advisor to update status:*

```
PUT {{baseUrl}}/advisor/job-cards/{jobCardId}/status
```

**Headers:**
```
Authorization: Bearer {{advisor_token}}
```

**Body:**
```json
{
  "status": "COMPLETED"
}
```

### 6.9 Complete Job (Technician)

```
POST {{baseUrl}}/technicians/jobs/complete
```

**Body:**
```json
{
  "jobCardNo": "{jobCardNo}",
  "notes": "All work completed, awaiting advisor review"
}
```

### 6.10 View Supervisor Awaiting Completion

*Switch token to Supervisor:*

```
GET {{baseUrl}}/supervisor/jobs/awaiting
```

**Expected:** Returns jobs awaiting completion review.

### 6.11 Approve Completion (Supervisor)

```
PUT {{baseUrl}}/supervisor/jobs/{jobCardId}/approve-completion
```

**Expected:** `200 OK`

### 6.12 Get Technician Productivity

```
GET {{baseUrl}}/technicians/productivity
```

**Expected:** Returns productivity metrics.

### 6.13 Technician Attendance — Punch In

```
POST {{baseUrl}}/technicians/attendance/punch-in
```

**Expected:** `200 OK`

### 6.14 Technician Attendance — Punch Out

```
POST {{baseUrl}}/technicians/attendance/punch-out
```

**Expected:** `200 OK`

---

## 7. Appendix: Complete Endpoint Reference

### Auth
| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/send-otp` | Send OTP for login |
| POST | `/auth/verify-otp` | Verify OTP and get JWT |
| POST | `/auth/login` | Login with email/password |
| POST | `/auth/register` | Register new user |
| POST | `/auth/refresh` | Refresh JWT token |
| POST | `/auth/logout` | Logout |
| GET | `/auth/me` | Get current user profile |

### Owner
| Method | Endpoint | Description |
|---|---|---|
| GET | `/owner/team` | List staff members |
| POST | `/owner/team` | Create staff member |
| PUT | `/owner/team/{id}` | Update staff member |
| PUT | `/owner/team/{id}/deactivate` | Deactivate staff |
| GET | `/owner/api-keys` | List API keys |
| POST | `/owner/api-keys` | Create API key |

### Customer
| Method | Endpoint | Description |
|---|---|---|
| POST | `/customers/tickets` | Create support ticket |
| GET | `/customers/tickets` | List my tickets |
| POST | `/customers/bookings` | Create booking |
| GET | `/customers/bookings` | List my bookings |
| POST | `/customers/breakdowns` | Report breakdown |
| GET | `/customers/profile` | Get customer profile |

### Supervisor
| Method | Endpoint | Description |
|---|---|---|
| GET | `/supervisor/bookings` | View booking queue |
| PUT | `/supervisor/bookings/{id}/assign` | Assign booking to advisor |
| GET | `/supervisor/breakdowns` | View breakdown queue |
| PUT | `/supervisor/breakdowns/{id}/assign` | Assign breakdown to advisor |
| GET | `/supervisor/jobs/awaiting` | Jobs awaiting completion |
| PUT | `/supervisor/jobs/{id}/approve-completion` | Approve completion |
| PUT | `/supervisor/jobs/{id}/reject-completion` | Reject completion |
| POST | `/supervisor/job-cards/{ref}/qc-review` | QC review |
| GET | `/supervisor/assignable-advisors` | List advisors |
| GET | `/supervisor/technicians/available` | List available technicians |
| GET | `/supervisor/kpis` | Dashboard KPIs |
| GET | `/supervisor/advisor-jobs` | Advisor job counts |
| GET | `/supervisor/assigned-jobs` | Assigned jobs |
| GET | `/staff/notifications` | Staff notifications |
| PUT | `/staff/notifications/{id}/read` | Mark notification read |
| PUT | `/staff/notifications/read-all` | Mark all read |

### Advisor
| Method | Endpoint | Description |
|---|---|---|
| GET | `/advisor/bookings` | Assigned bookings |
| GET | `/advisor/job-cards` | List job cards |
| GET | `/advisor/job-cards/{id}` | Job card details |
| PUT | `/advisor/job-cards/{id}/status` | Update job card status |
| PUT | `/advisor/job-cards/{id}/technician` | Assign technician |
| POST | `/advisor/job-cards/{ref}/tasks` | Assign tasks |
| POST | `/advisor/job-cards/{ref}/deliver` | Deliver job |
| POST | `/inspections` | Create inspection |
| PUT | `/inspections/{id}` | Update inspection |
| GET | `/inspections/{id}/draft` | Get draft |
| PUT | `/inspections/{id}/draft` | Save draft |
| DELETE | `/inspections/{id}/draft` | Delete draft |
| GET | `/inspections/{id}/summary` | AI summary |
| GET | `/advisor/job-cards/{ref}/work-items` | Work items |
| PUT | `/advisor/work-items/{id}/assign` | Assign work item |
| PUT | `/advisor/work-items/assign` | Batch assign |
| GET | `/advisor/technicians` | List technicians |

### Technician
| Method | Endpoint | Description |
|---|---|---|
| GET | `/technicians/assigned-jobs` | My assigned jobs |
| GET | `/technicians/jobs` | My jobs |
| GET | `/technicians/jobs/search?q=` | Search jobs |
| PUT | `/technicians/jobs/{card}/tasks/{task}/start` | Start task |
| PUT | `/technicians/jobs/{card}/tasks/{task}/complete` | Complete task |
| PUT | `/technicians/jobs/{card}/tasks/{task}/status` | Update task status |
| POST | `/technicians/jobs/complete` | Complete job |
| PUT | `/technicians/jobs/{card}/notes` | Update notes |
| PUT | `/technicians/work-items/{id}/start` | Start work item |
| PUT | `/technicians/work-items/{id}/complete` | Complete work item |
| PUT | `/technicians/work-items/{id}/status` | Update work item status |
| PUT | `/technicians/work-items/{id}/notes` | Add notes |
| POST | `/technicians/attendance/punch-in` | Punch in |
| POST | `/technicians/attendance/punch-out` | Punch out |
| POST | `/technicians/attendance/break-start` | Start break |
| POST | `/technicians/attendance/break-end` | End break |
| GET | `/technicians/productivity` | Productivity stats |
| GET | `/technicians/attendance` | Attendance records |

### Sync
| Method | Endpoint | Description |
|---|---|---|
| POST | `/sync/inspections/{id}` | Sync inspection |
| POST | `/sync/jobs/complete/{id}` | Sync job completion |
| POST | `/sync/repair-orders/{id}` | Sync repair order |
| POST | `/sync/bookings` | Sync bookings |
| POST | `/sync/work-assignments` | Sync work assignments |

---

## Test Data Summary

| Entity | Phone | Email | Role |
|---|---|---|---|
| Owner | 971501234568 | (auto) | owner |
| Test Advisor | 971501234569 | testadvisor@orient.com | advisor |
| Test Supervisor | 971501234570 | testsupervisor@orient.com | supervisor |
| Test Technician | 971501234571 | testtechnician@orient.com | technician |
| Test Customer | 971501234500 | (auto) | customer |

## OTP
All dev-mode OTPs are: **123456**

---

*Document Version: 1.0*  
*Date: 2026-09-14*
