# Orient Mobile Application — Backend API Specification

**Base URL**: `https://api.orientworkshop.com/v1`
**Auth**: JWT Bearer token in `Authorization` header
**Content-Type**: `application/json`

---

## 1. Authentication

### POST `/auth/send-otp`

Send OTP code to customer's phone number.

**Request:**

```json
{
  "phone": "971501234567"
}
```

**Response:** `200 OK`

### POST `/auth/verify-otp`

Verify OTP and return auth tokens with user role.

**Request:**

```json
{
  "phone": "971501234567",
  "otp": "123456"
}
```

**Response:**

```json
{
  "role": "advisor",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "dGhpcyBpcyBhIHJlZnJl..."
}
```

**Roles**: `owner`, `advisor`, `technician`, `customer`, `supervisor`, `crmDashboard`

### POST `/auth/refresh`

Refresh an expired JWT token.

**Request:**

```json
{
  "refreshToken": "..."
}
```

**Response:**

```json
{
  "role": "advisor",
  "token": "eyJ...",
  "refreshToken": "..."
}
```

### POST `/auth/logout`

Invalidate the current session/token.

**Response:** `200 OK`

---

## 2. Customer Portal

### 2.1 Profile

#### GET `/customers/profile`

**Response:**

```json
{
  "name": "Ahmed Hassan",
  "firstName": "Ahmed",
  "avatarInitials": "AH",
  "memberId": "CUST-001"
}
```

### 2.2 Vehicles

#### GET `/customers/vehicles`

**Response:**

```json
[
  {
    "id": "1",
    "brand": "BMW",
    "model": "3 Series",
    "plateNumber": "AB19 XYZ",
    "vin": "WBA8E9G58GNT44078",
    "color": "Alpine White",
    "year": 2019,
    "mileage": "41,200 km",
    "lastService": "10 Nov 2025",
    "nextDue": "10 May 2026",
    "healthScore": 82
  }
]
```

#### POST `/customers/vehicles`

**Request:**

```json
{
  "brand": "BMW",
  "model": "3 Series",
  "plateNumber": "ABC123",
  "vin": "WBA...",
  "color": "White",
  "year": 2024,
  "mileage": "0 km",
  "lastService": "",
  "nextDue": "",
  "healthScore": 100
}
```

**Response:** `{"id": "3"}`

### 2.3 Bookings

#### GET `/customers/bookings`

**Response:**

```json
[
  {
    "service": "Oil Change",
    "vehicleName": "BMW 3 Series",
    "plateNumber": "AB19 XYZ",
    "date": "5 Apr 2026",
    "time": "10:00 AM",
    "status": "confirmed"
  }
]
```

**Booking statuses**: `confirmed`, `completed`, `pending`, `cancelled`

#### POST `/bookings`

**Request:**

```json
{
  "vehicleId": "1",
  "vehicleName": "BMW 3 Series",
  "plateNumber": "AB19 XYZ",
  "serviceType": "Full Service",
  "bookingDate": "2026-07-28T10:00:00.000",
  "notes": "Please check AC too"
}
```

**Response:** `{"id": "BK-2026-07-28-0001", "status": "pending"}`

### 2.4 Services

#### GET `/customers/services/active`

Get the customer's currently active/in-progress service.
**Response:**

```json
{
  "jobCardId": "JC-2026-1245",
  "plateNumber": "AB19 XYZ",
  "vehicleName": "BMW 3 Series",
  "service": "Full Inspection",
  "started": "09:00 AM",
  "estCompletion": "12:30 PM",
  "progressPercent": 65,
  "currentStage": "Service Work",
  "technicianName": "Khalid A.",
  "stages": [
    { "name": "Vehicle Received", "time": "09:00 AM", "status": "done" },
    { "name": "Initial Inspection", "time": "09:20 AM", "status": "done" },
    { "name": "Parts Preparation", "time": "09:45 AM", "status": "done" },
    { "name": "Service Work", "time": "10:15 AM", "status": "inProgress" },
    { "name": "Quality Check", "status": "pending" },
    { "name": "Wash & Cleaning", "status": "pending" },
    { "name": "Ready for Delivery", "status": "pending" }
  ]
}
```

**Stage statuses**: `done`, `inProgress`, `pending`

#### GET `/services/types`

List all available service types.
**Response:**

```json
[
  { "id": "1", "name": "Oil Change", "price": "From £65", "duration": "~1 hr" },
  {
    "id": "2",
    "name": "Tyre Rotation",
    "price": "From £55",
    "duration": "~45 min"
  },
  {
    "id": "3",
    "name": "Full Inspection",
    "price": "From £120",
    "duration": "~2 hrs"
  },
  { "id": "4", "name": "General Repair", "price": "POA", "duration": "Varies" },
  {
    "id": "5",
    "name": "MOT Test",
    "price": "From £54.85",
    "duration": "~1 hr"
  },
  {
    "id": "6",
    "name": "Full Service",
    "price": "From £280",
    "duration": "~3 hrs"
  }
]
```

### 2.5 Breakdown / Emergency

#### POST `/customers/breakdowns`

**Request:**

```json
{
  "issue": "Flat Tyre",
  "vehicleId": "1",
  "vehicleName": "BMW 3 Series",
  "vehiclePlate": "AB19 XYZ",
  "location": "Sheikh Zayed Rd, Dubai"
}
```

**Response:** `{"id": "BD-2026-07-27-0001", "status": "pending"}`

### 2.6 Notifications

#### GET `/customers/notifications`

**Response:**

```json
[
  {
    "id": "n1",
    "title": "Your car is ready!",
    "body": "BMW 3 Series has completed its Full Inspection.",
    "time": "26 Mar · 16:30",
    "type": "carReady",
    "isRead": false
  }
]
```

**Notification types**: `carReady`, `bookingConfirmed`, `invoiceReady`, `approvalNeeded`, `workInProgress`, `reminder`

#### PUT `/customers/notifications/{id}/read`

Mark a single notification as read.
**Response:** `200 OK`

#### PUT `/customers/notifications/read-all`

Mark all notifications as read.
**Response:** `200 OK`

---

## 3. Staff App — Advisor

### 3.1 Dashboard

#### GET `/advisor/stats`

Dashboard statistics for the logged-in advisor.
**Response:**

```json
{
  "newJobCardsToday": 5,
  "inspectionsToday": 3,
  "pendingApprovals": 2,
  "vehiclesWaiting": 5,
  "readyForDelivery": 2,
  "totalOpenJobCards": 15
}
```

### 3.2 Job Cards

#### GET `/advisor/job-cards`

List job cards. Optional filters.
**Query params**: `recent=true`, `page=1`, `limit=20`, `status=inProgress`, `search=Ahmed`

**Response:**

```json
[
  {
    "id": "JC-2024-089",
    "customerName": "Ahmed Hassan",
    "vehicleInfo": "Toyota Camry",
    "time": "09:15 AM",
    "createdDate": "12/07/2024 09:15",
    "lastUpdated": "12/07/2024 09:15",
    "status": "inProgress",
    "technician": "Mohammed Hassan"
  }
]
```

**Job card statuses**: `inProgress`, `pendingApproval`, `qualityCheck`, `completed`, `cancelled`, `waitingParts`, `pending`

#### GET `/advisor/job-cards/{id}`

Full job card detail.
**Response:** Same schema as single item above.

#### PUT `/advisor/job-cards/{id}/status`

Update a job card's status.
**Request:** `{"status": "inProgress"}`
**Response:** `200 OK`

#### PUT `/advisor/job-cards/{id}/technician`

Assign a technician to a job card.
**Request:** `{"technician": "Mohammed Hassan"}`
**Response:** `200 OK`

### 3.3 Create Job Card (Vehicle/Customer Intake)

#### POST `/inspections`

Create a new job card with full customer and vehicle details.

**Request:**

```json
{
  "type": "vehicle_customer",
  "status": "inProgress",
  "createdDate": "12/07/2024 09:15",
  "lastUpdated": "12/07/2024 09:15",
  "technician": "",
  "customer": {
    "isB2B": false,
    "customerName": "Ahmed Hassan",
    "phoneNumber": "+971501234567",
    "email": "ahmed@example.com",
    "customerGroup": "Individual",
    "tags": ["Corporate", "Premium"],
    "gender": "Male",
    "address": "Dubai Marina, Dubai",
    "taxNumber": "TX-001",
    "groupTaxNumber": "",
    "occupation": "Engineer",
    "organisation": "ABC Corp",
    "source": "Walk-in"
  },
  "vehicle": {
    "registrationNumber": "D-12345",
    "vin": "WBA8E9G58GNT44078",
    "make": "BMW",
    "model": "3 Series",
    "modelYear": 2019,
    "purchaseDate": "2020-01-15",
    "cylinders": 4,
    "engineCapacity": "2000cc",
    "vehicleColor": "Alpine White",
    "engineNumber": "ENG123456",
    "insuranceProvider": "Orient Insurance",
    "insuranceTaxNumber": "INS-TX-001",
    "insuranceAddress": "PO Box 123, Dubai",
    "policyNumber": "POL-2024-001",
    "insuranceExpiryDate": "2025-01-15"
  },
  "additional": {
    "odometerReading": "41200",
    "fuelLevel": 7,
    "customerConsent": true
  }
}
```

**Response:** `{"id": "JC-2024-090"}`

### 3.4 Approvals

#### GET `/advisor/approvals/pending`

**Response:**

```json
[
  {
    "estimateId": "EST-2024-089",
    "customerName": "Ahmed Hassan",
    "vehicleId": "D-12345",
    "amount": 1250.0,
    "timeAgo": "10 mins ago"
  }
]
```

#### POST `/advisor/approvals/{estimateId}`

Approve or reject an estimate.
**Request:**

```json
{
  "action": "approved",
  "customerName": "Ahmed Hassan",
  "amount": 1250.0
}
```

**Response:** `200 OK`

### 3.5 Reminders

#### GET `/advisor/reminders`

**Response:**

```json
[
  {
    "id": "REM-001",
    "customerName": "Ahmed Hassan",
    "vehicleId": "D-12345",
    "task": "Follow up on estimate approval",
    "dueDate": "Today, 2:00 PM",
    "priority": "high"
  }
]
```

**Priorities**: `high`, `medium`, `low`

#### POST `/advisor/reminders`

**Request:**

```json
{
  "customerName": "Ahmed Hassan",
  "vehicleId": "D-12345",
  "task": "Follow up on estimate approval",
  "dueDate": "Today, 2:00 PM",
  "priority": "high"
}
```

**Response:** `{"id": "REM-001"}`

#### DELETE `/advisor/reminders/{id}`

**Response:** `200 OK`

### 3.6 Inspections (Full Checklist)

#### POST `/inspections`

Submit a completed vehicle inspection. Can also be used for draft saves.

**Inspection Sections** — 4 sections, 26 items total:

| Section               | Items                                                                                                                                           |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| **interior_exterior** | Head Light/Tail Light/Turn Signals, Wiper Blade, Mirror, Emergency Brake, Horn, Fuel Tank Cap, A/C Filter, Seat Belts, Dashboard Lights, Clutch |
| **under_vehicle**     | Shock Absorbers, Steering Gear, Exhaust, Fluid Leaks, Brake Lines, U-Joints, Fuel Lines, Nuts/Bolts                                             |
| **under_hood**        | Fluid Levels, Air Filter, Drive Belts, Coolant, Hoses, Radiator                                                                                 |
| **battery**           | Terminals/Cables, Storage Capacity Test                                                                                                         |

Each item gets a **status**: `good`, `fair`, `poor`

**Request:**

```json
{
  "jobCardId": "JC-2024-089",
  "referenceNumber": "REF-001",
  "placeOfSupply": "Dubai",
  "customerRequests": "AC not cooling properly, strange noise from engine",
  "garageRecommendations": "Replace air filter, top up coolant, check brake pads",
  "estimatedDelivery": "2026-07-28T17:00:00",
  "notifyOwnerSmsEmail": true,
  "tag": "Express",
  "sections": {
    "interior_exterior": {
      "Head Light/Tail Light/Turn Signals": {
        "status": "good",
        "photos": [],
        "note": ""
      },
      "Wiper Blade": {
        "status": "fair",
        "photos": [],
        "note": "Cracked, needs replacement"
      },
      "A/C Filter": { "status": "poor", "note": "Clogged with debris" }
    },
    "under_vehicle": {
      "Fluid Leaks": { "status": "fair" },
      "Brake Lines": { "status": "good" }
    },
    "under_hood": {
      "Fluid Levels": { "status": "fair", "note": "Coolant low" },
      "Air Filter": { "status": "poor", "note": "Clogged, replace urgently" }
    },
    "battery": {
      "Terminals/Cables": { "status": "good" },
      "Storage Capacity Test": { "status": "good" }
    }
  }
}
```

**Response:** `{"id": "INS-001"}`

#### PUT `/inspections/{id}/draft`

Save inspection as draft (partial data allowed).
**Request:** Same schema as above (all fields optional).

#### GET `/inspections/{id}/draft`

Retrieve saved draft.
**Response:** Same schema.

#### DELETE `/inspections/{id}/draft`

Delete draft.
**Response:** `200 OK`

### 3.7 Repair Orders

#### POST `/repair-orders`

Create a repair order with services and parts.

**Predefined Services** (20): A/C Overhauling, Air Filter, Battery, Brake, Clutch, Cooling System, Engine Oil, Fuel Filter, Power Steering, Radiator, Spark Plug, Timing Belt, Wheel Alignment, Wheel Balancing, Wind Screen, AC Service, Brake Pads, Brake Discs, Suspension System, Transmission Fluid

**Predefined Parts** (15): A/C heater core, Alloy wheel, Alternator, Brake booster, Clutch cable, Engine air filter, Fuel filter, Oil filter, Spark plug, Wiper blade, Brake pad set, Radiator cap, Drive belt, Battery, Coolant

**Request:**

```json
{
  "jobCardId": "JC-2024-089",
  "services": [
    {
      "name": "Oil Change",
      "qty": 1,
      "rate": 65.0,
      "discountPercent": 0,
      "discountAmount": 0
    },
    {
      "name": "Brake Inspection",
      "qty": 1,
      "rate": 120.0,
      "discountPercent": 10,
      "discountAmount": 12.0
    }
  ],
  "parts": [
    {
      "name": "Oil Filter",
      "qty": 1,
      "rate": 25.0,
      "discountPercent": 0,
      "discountAmount": 0
    },
    {
      "name": "Brake Pad Set",
      "qty": 1,
      "rate": 180.0,
      "discountPercent": 0,
      "discountAmount": 0
    }
  ],
  "servicesTotal": 173.0,
  "partsTotal": 205.0,
  "grandTotal": 378.0,
  "tag": "Express",
  "customerRequests": "Brakes feel spongy",
  "garageRecommendations": "Replace brake fluid",
  "estimatedDelivery": "2026-07-28T17:00:00",
  "notifyOwnerSmsEmail": true
}
```

**Response:** `{"id": "RO-2026-07-27-0001"}`

### 3.8 Reports

#### GET `/advisor/reports?range=today`

**Query params**: `range` = `today`, `week`, or `month`

**Response:**

```json
{
  "totalJobs": 15,
  "completedJobs": 8,
  "inProgressJobs": 5,
  "cancelledJobs": 2,
  "weeklyActivity": [
    { "day": "Mon", "count": 3 },
    { "day": "Tue", "count": 5 }
  ],
  "statusBreakdown": [
    { "status": "completed", "count": 8, "percentage": 53.3 },
    { "status": "inProgress", "count": 5, "percentage": 33.3 },
    { "status": "cancelled", "count": 2, "percentage": 13.3 }
  ]
}
```

### 3.9 Search

#### GET `/customers/search?q=Ahmed`

Search customers by name, phone, or email.

**Response:**

```json
[
  {
    "customerName": "Ahmed Hassan",
    "phone": "+971501234567",
    "email": "ahmed@example.com"
  }
]
```

#### GET `/vehicles/search?q=ABC123`

Search vehicles by registration number, VIN, or plate.

**Response:**

```json
[
  {
    "regNo": "D-12345",
    "vin": "WBA...",
    "make": "BMW",
    "model": "3 Series",
    "plateNumber": "ABC123"
  }
]
```

---

## 4. Staff App — Supervisor

### 4.1 Dashboard KPIs

#### GET `/supervisor/kpis`

**Response:**

```json
[
  {
    "value": "24",
    "label": "Total Job Cards Pending",
    "sub": "+4 from yesterday"
  },
  { "value": "8", "label": "Today Delivery Job Cards", "sub": "On schedule" },
  { "value": "18", "label": "Total Advisors Present", "sub": "2 out of 20" },
  { "value": "3", "label": "Total Idle Technicians", "sub": "Assign them now" },
  {
    "value": "12",
    "label": "Waiting to Assign Stock",
    "sub": "Requires attention"
  }
]
```

#### GET `/supervisor/advisor-jobs`

Per-advisor job counts.
**Response:**

```json
[
  { "name": "John Smith", "count": 20 },
  { "name": "Sarah Lee", "count": 13 },
  { "name": "Mike Anwar", "count": 18 },
  { "name": "Emma Wilson", "count": 10 }
]
```

#### GET `/supervisor/job-types`

**Response:**

```json
[
  { "label": "Regular Service", "count": 38 },
  { "label": "Insurance", "count": 28 },
  { "label": "Contract", "count": 15 }
]
```

#### GET `/supervisor/revenue-metrics`

**Response:**

```json
[
  { "amount": "$45,280", "label": "Total Revenue", "change": "+12.4%" },
  { "amount": "$18,920", "label": "Service Revenue", "change": "+8.2%" },
  { "amount": "$8,450", "label": "Parts Revenue", "change": "+3.1%" },
  { "amount": "$12,680", "label": "Labour Revenue", "change": "+24.3%" },
  { "amount": "$5,230", "label": "Other Revenue", "change": "+18.7%" }
]
```

#### GET `/supervisor/pending-statuses`

**Response:**

```json
[
  { "count": "10", "label": "Waiting for Parts" },
  { "count": "2", "label": "Job Completed Not Invoiced" },
  { "count": "4", "label": "Waiting for Inspection" },
  { "count": "6", "label": "Waiting for Approval" }
]
```

### 4.2 Reference Data

#### GET `/departments`

**Response:** `["Engine", "Body & Paint", "Electrical", "Tyres & Alignment", "AC & Cooling", "Transmission", "General Service"]`

#### GET `/technicians`

**Response:** `["Ali Hassan", "Ravi Kumar", "Mohammed Salim", "David Osei", "James Patel"]`

### 4.3 Work Assignments

#### POST `/work-assignments`

Create one or more work assignments (batch).

**Request:**

```json
[
  {
    "description": "AC Repair - Toyota Camry 2023",
    "department": "AC & Cooling",
    "technicianName": "Ravi Kumar",
    "dateOfWork": "2026-07-27",
    "statusPercent": 0,
    "stdTime": "2 hrs",
    "remarks": "Customer reported weak AC cooling"
  }
]
```

**Response:**

```json
[{ "id": "ASN-1", "jobCard": "ASN-1", "status": "Pending" }]
```

#### GET `/supervisor/assigned-jobs`

List all assigned jobs.
**Response:**

```json
[
  {
    "jobCard": "JC-2025-001",
    "customer": "John Anderson",
    "vehicle": "Toyota Camry 2023",
    "dateAssigned": "4/20/2026",
    "done": 2,
    "total": 4,
    "status": "In Progress"
  },
  {
    "jobCard": "JC-2025-002",
    "customer": "Sarah Williams",
    "vehicle": "Honda City",
    "dateAssigned": "4/21/2026",
    "done": 3,
    "total": 3,
    "status": "Completed"
  },
  {
    "jobCard": "JC-2025-003",
    "customer": "Michael Brown",
    "vehicle": "BMW 35 2025",
    "dateAssigned": "4/22/2026",
    "done": 0,
    "total": 5,
    "status": "Pending"
  }
]
```

---

## 5. Staff App — Technician

### 5.1 Profile

#### GET `/technicians/profile`

**Response:**

```json
{
  "name": "Mohammed Hassan",
  "empId": "EMP-001",
  "role": "Technician",
  "branch": "Main Branch - Dubai",
  "shift": "Morning (8:00 AM - 5:00 PM)",
  "avatarInitials": "MH"
}
```

### 5.2 Attendance

#### POST `/technicians/attendance/punch-in`

**Request:**

```json
{
  "empId": "EMP-001",
  "status": "working",
  "punchIn": "08:15 AM",
  "date": "2026-07-27"
}
```

**Response:** `{"id": "ATT-001", "status": "working"}`

#### POST `/technicians/attendance/punch-out`

**Request:**

```json
{
  "empId": "EMP-001",
  "status": "punchedOut",
  "punchIn": "08:15 AM",
  "punchOut": "05:00 PM",
  "breakTime": "25 min",
  "workHours": "8h 20m",
  "date": "2026-07-27"
}
```

**Response:** `200 OK`

#### POST `/technicians/attendance/break-start`

**Request:** `{"empId": "EMP-001", "status": "onBreak"}`
**Response:** `200 OK`

#### POST `/technicians/attendance/break-end`

**Request:** `{"empId": "EMP-001", "status": "working"}`
**Response:** `200 OK`

#### GET `/technicians/attendance?date=2026-07-27`

**Response:**

```json
{
  "status": "working",
  "punchIn": "08:15 AM",
  "punchOut": "",
  "breakTime": "25 min",
  "workHours": "4h 35m"
}
```

**Attendance statuses**: `notPunchedIn`, `working`, `onBreak`, `punchedOut`

### 5.3 Assigned Jobs

#### GET `/technicians/assigned-jobs?empId=EMP-001`

**Response:**

```json
[
  {
    "id": "1",
    "customerName": "John Anderson",
    "vehicle": "Toyota Camry",
    "service": "Oil Change",
    "amount": "$65",
    "status": "pending"
  },
  {
    "id": "2",
    "customerName": "Sarah Williams",
    "vehicle": "Honda City",
    "service": "Full Service",
    "amount": "$280",
    "status": "inProgress"
  }
]
```

**Assigned job statuses**: `inProgress`, `pending`, `waitingParts`, `completed`

#### PUT `/technicians/assigned-jobs/{id}/status`

**Request:** `{"empId": "EMP-001", "status": "inProgress"}`
**Response:** `200 OK`

### 5.4 Technician Jobs

#### GET `/technicians/jobs?empId=EMP-001&status=inProgress`

**Response:**

```json
[
  {
    "jobCardNo": "JC-001",
    "dateOfWork": "2026-07-27",
    "startTime": "09:00",
    "vehicleBrand": "Toyota",
    "vehicleModel": "Camry",
    "plateNumber": "ABC123",
    "status": "inProgress",
    "tasks": [
      {
        "id": "t1",
        "description": "Check engine oil level",
        "status": "completed",
        "startTime": "09:15",
        "endTime": "09:30"
      },
      {
        "id": "t2",
        "description": "Replace oil filter",
        "status": "inProgress",
        "startTime": "09:35"
      }
    ],
    "notes": "Customer reported engine noise"
  }
]
```

**Job statuses**: `inProgress`, `completed`, `delayed`, `pending`

#### GET `/technicians/jobs/search?q=JC-001`

Quick search by job card number.
**Response:** Single job object (same schema as above).

### 5.5 Task Management

#### PUT `/technicians/jobs/{jobCardNo}/tasks/{taskId}/start`

**Request:** `{"startTime": "09:15"}`
**Response:** `200 OK`

#### PUT `/technicians/jobs/{jobCardNo}/tasks/{taskId}/complete`

**Request:** `{"endTime": "09:30"}`
**Response:** `200 OK`

#### PUT `/technicians/jobs/{jobCardNo}/tasks/{taskId}/status`

**Request:** `{"status": "inProgress"}`
**Response:** `200 OK`

**Task statuses**: `pending`, `inProgress`, `completed`

### 5.6 Job Completion & Notes

#### POST `/jobs/complete`

Mark an entire job as completed. Includes all tasks and final notes.

**Request:**

```json
{
  "jobCardNo": "JC-001",
  "empId": "EMP-001",
  "status": "completed",
  "tasks": [
    {
      "id": "t1",
      "status": "completed",
      "startTime": "09:15",
      "endTime": "09:30"
    },
    {
      "id": "t2",
      "status": "completed",
      "startTime": "09:35",
      "endTime": "10:45"
    }
  ],
  "notes": "Replaced brake pads, topped up coolant. Test drive successful."
}
```

**Response:** `200 OK`

#### PUT `/technicians/jobs/{jobCardNo}/notes`

**Request:** `{"notes": "Replaced brake pads, topped up coolant. Test drive successful."}`
**Response:** `200 OK`

### 5.7 Productivity

#### GET `/technicians/productivity?empId=EMP-001`

**Response:**

```json
{
  "assignedJobs": 4,
  "inProgress": 1,
  "completedToday": 1,
  "efficiency": 87,
  "avgTimePerJob": "1.2 hrs",
  "totalHoursWorked": "6h 30m"
}
```

---

## 6. Owner Dashboard

### 6.1 Main Dashboard

#### GET `/owner/dashboard/kpis`

16 KPI cards for the owner dashboard.
**Response:**

```json
[
  { "label": "Active Jobs", "value": "145", "sub": "+12 today" },
  { "label": "New Jobs", "value": "23", "sub": "Today" },
  { "label": "Cancelled Jobs", "value": "100", "sub": "Total" },
  { "label": "Total Jobs", "value": "2,168", "sub": "All time" },
  { "label": "Total Sales", "value": "AED 50K", "sub": "This month" },
  { "label": "Total Purchases", "value": "AED 30K", "sub": "This month" },
  { "label": "Receivables", "value": "AED 4K", "sub": "Overdue" },
  { "label": "Payables", "value": "AED 15K", "sub": "Due" },
  { "label": "Total Profit", "value": "AED 20K", "sub": "Net" },
  { "label": "Total Cash", "value": "AED 45K", "sub": "In hand" },
  { "label": "Total Bank", "value": "AED 30K", "sub": "In bank" },
  { "label": "Inventory Value", "value": "AED 85K", "sub": "Stock" },
  { "label": "Commission", "value": "AED 1,500", "sub": "Due" },
  { "label": "Invoice Revenue", "value": "AED 25K", "sub": "This month" },
  { "label": "Parts Revenue", "value": "AED 18K", "sub": "This month" },
  { "label": "Labour Revenue", "value": "AED 7K", "sub": "This month" }
]
```

#### GET `/owner/dashboard/sales-trend`

Monthly sales data (7 months).
**Response:**

```json
[
  { "month": "Jan", "value": 45000 },
  { "month": "Feb", "value": 52000 },
  { "month": "Mar", "value": 48000 },
  { "month": "Apr", "value": 61000 },
  { "month": "May", "value": 55000 },
  { "month": "Jun", "value": 58000 },
  { "month": "Jul", "value": 50000 }
]
```

#### GET `/owner/dashboard/profit-trend`

**Response:** Same format as sales-trend.

#### GET `/owner/dashboard/expenses-trend`

**Response:** Same format as sales-trend.

#### GET `/owner/dashboard/job-card-register`

**Response:**

```json
[
  { "label": "Open", "open": 45, "completed": 120, "total": 165 },
  { "label": "Check-In", "open": 12, "completed": 89, "total": 101 },
  { "label": "Invoice Number", "open": 8, "completed": 95, "total": 103 },
  { "label": "Invoice Service", "open": 5, "completed": 78, "total": 83 },
  { "label": "Park Fee", "open": 3, "completed": 112, "total": 115 }
]
```

### 6.2 Top Sales

#### GET `/owner/dashboard/top-sales`

8 categories with top items each.
**Response:**

```json
[
  {
    "title": "Customer Wise",
    "items": [
      {"sno": 1, "description": "ABC Motors", "value": "AED 125,000"},
      {"sno": 2, "description": "Dubai Auto Services", "value": "AED 98,000"}
    ]
  },
  {
    "title": "Brand/Model Wise",
    "items": [
      {"sno": 1, "description": "Toyota Camry", "value": "AED 45,000"},
      {"sno": 2, "description": "BMW 3 Series", "value": "AED 38,000"}
    ]
  },
  {"title": "Advisor Wise", "items": [...]},
  {"title": "Profit Wise", "items": [...]},
  {"title": "Sales Value Wise", "items": [...]},
  {"title": "Spare Parts Profit Wise", "items": [...]},
  {"title": "Labour Profit Wise", "items": [...]},
  {"title": "Department Wise", "items": [...]}
]
```

### 6.3 Job Cards (Owner View)

#### GET `/owner/job-cards`

**Response:**

```json
[
  {
    "id": "1",
    "customerName": "Ahmed Hassan",
    "vehicle": "Toyota Camry",
    "plateNumber": "ABC123",
    "services": "Full Service, Oil Change",
    "technician": "Khalid A.",
    "estCompletion": "2026-07-27T14:00:00",
    "amount": 2500.0,
    "status": "inProgress"
  }
]
```

### 6.4 Document Expiry

#### GET `/owner/documents/expiry`

**Response:**

```json
[
  {
    "empId": "E001",
    "employeeName": "Ali Hassan",
    "designation": "Technician",
    "documentType": "Passport",
    "expiryDate": "2026-08-15",
    "daysLeft": 19,
    "urgency": "critical"
  },
  {
    "empId": "E002",
    "employeeName": "Ravi Kumar",
    "designation": "Advisor",
    "documentType": "Visa",
    "expiryDate": "2026-09-01",
    "daysLeft": 36,
    "urgency": "urgent"
  },
  {
    "empId": "E003",
    "employeeName": "Mohammed Salim",
    "designation": "Technician",
    "documentType": "Driving License",
    "expiryDate": "2026-10-15",
    "daysLeft": 80,
    "urgency": "warning"
  }
]
```

**Urgency levels**: `critical` (≤30 days), `urgent` (31-60), `warning` (61-90)

### 6.5 Job Status

#### GET `/owner/jobs/status?stage=wip&search=Ahmed`

**Stages**: `waitingInspection`, `waitingPreRequest`, `waitingEstimation`, `waitingApproval`, `waitingParts`, `wip`, `completed`, `invoice`, `gatePassOut`, `cancelled`

**Response:**

```json
[
  {
    "jobCardId": "JC-2024-089",
    "customerName": "Ahmed Hassan",
    "vehicleInfo": "Toyota Camry 2023",
    "assignedTo": "Khalid A.",
    "createdDate": "12/07/2024",
    "dueDate": "14/07/2024",
    "stage": "wip",
    "estimatedAmount": 2500.0
  }
]
```

### 6.6 Pending Approvals

#### GET `/owner/approvals/categories`

13 approval categories with counts.
**Response:**

```json
[
  {
    "title": "Purchase Order",
    "subtitle": "Pending your approval",
    "count": 3
  },
  { "title": "Open Job Card", "subtitle": "Awaiting review", "count": 5 },
  { "title": "WIP", "subtitle": "In progress jobs", "count": 2 },
  { "title": "Job Completed x3", "subtitle": "Ready for QC", "count": 4 },
  { "title": "Job Cancelled", "subtitle": "Cancellation requests", "count": 1 },
  { "title": "Invoice Raised", "subtitle": "Pending payment", "count": 6 },
  { "title": "Sales Return", "subtitle": "Return requests", "count": 2 },
  { "title": "Purchase Return", "subtitle": "Return to supplier", "count": 1 },
  { "title": "Petty Cash", "subtitle": "Cash requests", "count": 3 },
  { "title": "Journal Voucher", "subtitle": "Accounting entries", "count": 2 },
  { "title": "Job Card to Invoice", "subtitle": "Ready to invoice", "count": 7 }
]
```

### 6.7 Pending & Active Job Cards

#### GET `/owner/jobs/pending`

**Response:**

```json
[
  {
    "jobCardId": "JC-2024-089",
    "customerName": "Ahmed Hassan",
    "vehicleInfo": "Toyota Camry",
    "assignedTo": "Khalid A.",
    "createdDate": "12/07/2024",
    "dueDate": "14/07/2024",
    "daysOverdue": 2,
    "status": "overdue",
    "estimatedAmount": 2500.0
  }
]
```

**Pending statuses**: `overdue`, `pending`, `inProgress`

#### GET `/owner/jobs/active`

**Response:**

```json
[
  {
    "id": "1",
    "customerName": "Ahmed Hassan",
    "vehicleInfo": "Toyota Camry - ABC123",
    "services": "Full Service, Oil Change",
    "technician": "Khalid A.",
    "estCompletion": "2026-07-27T14:00:00",
    "amount": 2500.0,
    "status": "inProgress"
  }
]
```

### 6.8 Sales Invoices

#### GET `/owner/invoices?status=unpaid`

**Response:**

```json
[
  {
    "id": "INV-2026-0001",
    "customerName": "Ahmed Hassan",
    "date": "01/07/2026",
    "amount": 3800.0,
    "status": "unpaid"
  }
]
```

**Invoice statuses**: `paid`, `unpaid`, `overdue`

### 6.9 Accounts Receivable

#### GET `/owner/accounts-receivable/summary`

**Response:**

```json
{
  "totalOutstanding": 566000,
  "days0to30": 250000,
  "days31to60": 180000,
  "days61to90": 86000,
  "days90plus": 50000
}
```

#### GET `/owner/accounts-receivable/records`

**Response:**

```json
[
  {
    "arId": "AR-001",
    "customer": "ABC Motors LLC",
    "invoiceDate": "01/06/2026",
    "dueDate": "01/07/2026",
    "amount": 50000.0,
    "outstanding": 50000.0,
    "aging": "days31to60",
    "contactPerson": "John Smith",
    "phone": "+971501234567"
  }
]
```

**Aging buckets**: `days0to30`, `days31to60`, `days61to90`, `days90plus`

### 6.10 Messages & Activity

#### GET `/owner/messages`

**Response:**

```json
[
  {
    "id": "m1",
    "recipient": "John Smith",
    "message": "Parts have arrived for JC-1245",
    "time": "2:30 PM"
  }
]
```

#### POST `/owner/messages`

**Request:** `{"recipient": "John Smith", "message": "Parts arrived for JC-1245"}`
**Response:** `{"id": "m1"}`

#### GET `/owner/activity`

Activity feed of workshop events. Supports pagination.
**Query params**: `page=1`, `limit=20`

**Response:**

```json
[
  {
    "id": "a1",
    "type": "job_card",
    "title": "New job card created",
    "description": "Ahmed Hassan · Toyota Camry · Full Service",
    "timestamp": "2026-07-27T12:34:56"
  },
  {
    "id": "a2",
    "type": "inspection",
    "title": "Inspection completed",
    "description": "BMW 3 Series · All sections passed",
    "timestamp": "2026-07-27T12:04:56"
  },
  {
    "id": "a3",
    "type": "approval",
    "title": "Estimate approved",
    "description": "Nissan Patrol · EST-2024-089 · AED 1,250",
    "timestamp": "2026-07-27T11:34:56"
  },
  {
    "id": "a4",
    "type": "invoice",
    "title": "Invoice raised",
    "description": "Ford Focus · INV-2026-003 · AED 3,800",
    "timestamp": "2026-07-27T10:34:56"
  },
  {
    "id": "a5",
    "type": "parts",
    "title": "Parts arrived",
    "description": "Order #PO-042 · Brake pads, Oil filters",
    "timestamp": "2026-07-27T09:34:56"
  },
  {
    "id": "a6",
    "type": "payment",
    "title": "Payment received",
    "description": "Honda Accord · INV-2026-001 · AED 2,450",
    "timestamp": "2026-07-27T06:34:56"
  }
]
```

**Activity types**: `job_card`, `inspection`, `approval`, `invoice`, `parts`, `payment`, `technician`

---

## 7. CRM Dashboard (All Read-Only)

### 7.1 KPIs

#### GET `/crm/dashboard/kpis`

**Response:**

```json
[
  { "label": "Messages", "value": "1,847", "change": "+12.5%" },
  { "label": "Active Leads", "value": "347", "change": "-3.2%" },
  { "label": "Unanswered", "value": "23", "change": "-8.1%" },
  { "label": "Won", "value": "89", "change": "+15.3%" },
  { "label": "Lost", "value": "45", "change": "+2.1%" },
  { "label": "No Response", "value": "134", "change": "+5.7%" }
]
```

### 7.2 Analytics

#### GET `/crm/channels`

**Response:**

```json
[
  { "name": "WhatsApp Lite", "count": 420 },
  { "name": "WhatsApp Cloud", "count": 380 },
  { "name": "Instagram", "count": 290 },
  { "name": "SMS", "count": 215 },
  { "name": "Live Chat", "count": 180 },
  { "name": "Google Ads", "count": 145 },
  { "name": "Website", "count": 120 },
  { "name": "Email", "count": 97 }
]
```

#### GET `/crm/conversion-trend`

7 months of won/lost/active data.
**Response:**

```json
[
  { "month": "Jan", "won": 45, "lost": 22, "active": 180 },
  { "month": "Feb", "won": 52, "lost": 18, "active": 195 }
]
```

#### GET `/crm/salesperson-performance`

**Response:**

```json
[
  { "name": "Ahmed Al Maktoum", "leads": 85, "won": 32 },
  { "name": "Fatima Hassan", "leads": 72, "won": 28 }
]
```

#### GET `/crm/response-times`

**Response:**

```json
[
  { "label": "< 5 min", "count": 320 },
  { "label": "5-15 min", "count": 245 },
  { "label": "15-30 min", "count": 180 },
  { "label": "30-60 min", "count": 95 },
  { "label": "> 60 min", "count": 60 }
]
```

#### GET `/crm/lead-sources`

**Response:**

```json
[
  { "label": "WhatsApp", "percent": 35 },
  { "label": "Instagram", "percent": 20 },
  { "label": "Website", "percent": 18 },
  { "label": "Google Ads", "percent": 15 },
  { "label": "Referral", "percent": 12 }
]
```

#### GET `/crm/key-metrics`

**Response:**

```json
{
  "winRate": 38.2,
  "avgResponseTime": "4.5 min",
  "satisfaction": 4.7,
  "roi": 285
}
```

### 7.3 Integrations

#### GET `/crm/integrations`

**Response:**

```json
[
  { "name": "WhatsApp Business", "connected": true },
  { "name": "Instagram", "connected": true },
  { "name": "Google Ads", "connected": true },
  { "name": "Facebook", "connected": false },
  { "name": "Email (SMTP)", "connected": true },
  { "name": "SMS Gateway", "connected": false }
]
```

### 7.4 Sales Team

#### GET `/crm/sales-team`

**Response:**

```json
[
  {
    "name": "Ahmed Al Maktoum",
    "role": "Senior Sales",
    "leadsHandled": 85,
    "wonDeals": 32,
    "revenue": "AED 125,000",
    "winRate": 37.6
  }
]
```

### 7.5 Conversations

#### GET `/crm/conversations`

**Response:**

```json
[
  {
    "id": "c1",
    "customerName": "Ahmed Hassan",
    "lastMessage": "When can I bring my car in?",
    "time": "2 min ago",
    "channel": "whatsapp",
    "unread": 2,
    "status": "active"
  }
]
```

### 7.6 Leads

#### GET `/crm/leads?status=ACTIVE&source=whatsapp`

**Lead statuses**: `ACTIVE`, `WON`, `UNANSWERED`, `LOST`

**Response:**

```json
[
  {
    "sno": 1,
    "leadNumber": "LD-2026-001",
    "customerName": "Ahmed Hassan",
    "phone": "+971501234567",
    "email": "ahmed@email.com",
    "source": "WhatsApp",
    "assignedTo": "Ahmed Al Maktoum",
    "status": "ACTIVE",
    "lastActivity": "2 hours ago"
  }
]
```

### 7.7 Tasks

#### GET `/crm/tasks`

**Response:**

```json
[
  {
    "id": "t1",
    "title": "Follow up with Ahmed Hassan",
    "assignedTo": "Ahmed Al Maktoum",
    "dueDate": "Today",
    "priority": "High",
    "isDone": false
  }
]
```

#### PUT `/crm/tasks/{id}`

Toggle task completion status.
**Request:** `{"isDone": true}`
**Response:** `200 OK`

---

## 8. Sync & Conflict Resolution

The mobile apps use an **offline-first** approach. When a user creates or updates data while offline, the operation is queued and synced when connectivity is restored.

### 8.1 Sync Endpoints (POST only)

These endpoints receive operations that were created offline. Each request includes an `Idempotency-Key` header to prevent duplicate processing.

| Endpoint                   | When Called                  | Payload                |
| -------------------------- | ---------------------------- | ---------------------- |
| `POST /inspections/{id}`   | Advisor saves an inspection  | Full inspection JSON   |
| `POST /jobs/complete/{id}` | Technician completes a job   | Full job + tasks JSON  |
| `POST /work-assignments`   | Supervisor assigns work      | Array of assignments   |
| `POST /bookings`           | Customer creates a booking   | Booking JSON           |
| `POST /repair-orders/{id}` | Advisor creates repair order | Full repair order JSON |

### 8.2 Conflict Handling

If the server returns **HTTP 409 Conflict**, the app moves the operation to a failed queue.
**Server-side rule**: When in doubt, the server's data wins. The client will reconcile on next sync.

### 8.3 Idempotency

All sync POST requests include an `Idempotency-Key` header. If the server receives the same key twice, it should return the same response without duplicating the operation.

---

## 9. Media Uploads

### POST `/repair-orders/{id}/media`

Upload photos, videos, or audio recordings for an inspection/repair order item.

**Content-Type**: `multipart/form-data`
**Fields**: `file` (binary), `itemId` (string - the inspection item name), `type` (photo/video/audio)

**Response:** `{"url": "https://cdn.orientworkshop.com/media/..."}`

---

## 10. Complete Endpoint Index

| #   | Method | Path                                                    | App        |
| --- | ------ | ------------------------------------------------------- | ---------- |
| 1   | POST   | `/auth/send-otp`                                        | All        |
| 2   | POST   | `/auth/verify-otp`                                      | All        |
| 3   | POST   | `/auth/refresh`                                         | All        |
| 4   | POST   | `/auth/logout`                                          | All        |
| 5   | GET    | `/customers/profile`                                    | Customer   |
| 6   | GET    | `/customers/vehicles`                                   | Customer   |
| 7   | POST   | `/customers/vehicles`                                   | Customer   |
| 8   | GET    | `/customers/bookings`                                   | Customer   |
| 9   | POST   | `/bookings`                                             | Customer   |
| 10  | GET    | `/customers/services/active`                            | Customer   |
| 11  | GET    | `/services/types`                                       | Customer   |
| 12  | POST   | `/customers/breakdowns`                                 | Customer   |
| 13  | GET    | `/customers/notifications`                              | Customer   |
| 14  | PUT    | `/customers/notifications/{id}/read`                    | Customer   |
| 15  | PUT    | `/customers/notifications/read-all`                     | Customer   |
| 16  | GET    | `/advisor/stats`                                        | Advisor    |
| 17  | GET    | `/advisor/job-cards`                                    | Advisor    |
| 18  | GET    | `/advisor/job-cards/{id}`                               | Advisor    |
| 19  | PUT    | `/advisor/job-cards/{id}/status`                        | Advisor    |
| 20  | PUT    | `/advisor/job-cards/{id}/technician`                    | Advisor    |
| 21  | POST   | `/inspections`                                          | Advisor    |
| 22  | PUT    | `/inspections/{id}/draft`                               | Advisor    |
| 23  | GET    | `/inspections/{id}/draft`                               | Advisor    |
| 24  | DELETE | `/inspections/{id}/draft`                               | Advisor    |
| 25  | GET    | `/advisor/approvals/pending`                            | Advisor    |
| 26  | POST   | `/advisor/approvals/{id}`                               | Advisor    |
| 27  | GET    | `/advisor/reminders`                                    | Advisor    |
| 28  | POST   | `/advisor/reminders`                                    | Advisor    |
| 29  | DELETE | `/advisor/reminders/{id}`                               | Advisor    |
| 30  | POST   | `/repair-orders`                                        | Advisor    |
| 31  | POST   | `/repair-orders/{id}/media`                             | Advisor    |
| 32  | GET    | `/advisor/reports`                                      | Advisor    |
| 33  | GET    | `/customers/search`                                     | Advisor    |
| 34  | GET    | `/vehicles/search`                                      | Advisor    |
| 35  | GET    | `/supervisor/kpis`                                      | Supervisor |
| 36  | GET    | `/supervisor/advisor-jobs`                              | Supervisor |
| 37  | GET    | `/supervisor/job-types`                                 | Supervisor |
| 38  | GET    | `/supervisor/revenue-metrics`                           | Supervisor |
| 39  | GET    | `/supervisor/pending-statuses`                          | Supervisor |
| 40  | GET    | `/departments`                                          | Supervisor |
| 41  | GET    | `/technicians`                                          | Supervisor |
| 42  | POST   | `/work-assignments`                                     | Supervisor |
| 43  | GET    | `/supervisor/assigned-jobs`                             | Supervisor |
| 44  | GET    | `/technicians/profile`                                  | Technician |
| 45  | POST   | `/technicians/attendance/punch-in`                      | Technician |
| 46  | POST   | `/technicians/attendance/punch-out`                     | Technician |
| 47  | POST   | `/technicians/attendance/break-start`                   | Technician |
| 48  | POST   | `/technicians/attendance/break-end`                     | Technician |
| 49  | GET    | `/technicians/attendance`                               | Technician |
| 50  | GET    | `/technicians/assigned-jobs`                            | Technician |
| 51  | PUT    | `/technicians/assigned-jobs/{id}/status`                | Technician |
| 52  | GET    | `/technicians/jobs`                                     | Technician |
| 53  | GET    | `/technicians/jobs/search`                              | Technician |
| 54  | PUT    | `/technicians/jobs/{jobCardNo}/tasks/{taskId}/start`    | Technician |
| 55  | PUT    | `/technicians/jobs/{jobCardNo}/tasks/{taskId}/complete` | Technician |
| 56  | PUT    | `/technicians/jobs/{jobCardNo}/tasks/{taskId}/status`   | Technician |
| 57  | POST   | `/jobs/complete`                                        | Technician |
| 58  | PUT    | `/technicians/jobs/{jobCardNo}/notes`                   | Technician |
| 59  | GET    | `/technicians/productivity`                             | Technician |
| 60  | GET    | `/owner/dashboard/kpis`                                 | Owner      |
| 61  | GET    | `/owner/dashboard/sales-trend`                          | Owner      |
| 62  | GET    | `/owner/dashboard/profit-trend`                         | Owner      |
| 63  | GET    | `/owner/dashboard/expenses-trend`                       | Owner      |
| 64  | GET    | `/owner/dashboard/job-card-register`                    | Owner      |
| 65  | GET    | `/owner/dashboard/top-sales`                            | Owner      |
| 66  | GET    | `/owner/job-cards`                                      | Owner      |
| 67  | GET    | `/owner/documents/expiry`                               | Owner      |
| 68  | GET    | `/owner/jobs/status`                                    | Owner      |
| 69  | GET    | `/owner/approvals/categories`                           | Owner      |
| 70  | GET    | `/owner/jobs/pending`                                   | Owner      |
| 71  | GET    | `/owner/jobs/active`                                    | Owner      |
| 72  | GET    | `/owner/invoices`                                       | Owner      |
| 73  | GET    | `/owner/accounts-receivable/summary`                    | Owner      |
| 74  | GET    | `/owner/accounts-receivable/records`                    | Owner      |
| 75  | GET    | `/owner/messages`                                       | Owner      |
| 76  | POST   | `/owner/messages`                                       | Owner      |
| 77  | GET    | `/owner/activity`                                       | Owner      |
| 78  | GET    | `/crm/dashboard/kpis`                                   | CRM        |
| 79  | GET    | `/crm/channels`                                         | CRM        |
| 80  | GET    | `/crm/conversion-trend`                                 | CRM        |
| 81  | GET    | `/crm/salesperson-performance`                          | CRM        |
| 82  | GET    | `/crm/response-times`                                   | CRM        |
| 83  | GET    | `/crm/lead-sources`                                     | CRM        |
| 84  | GET    | `/crm/key-metrics`                                      | CRM        |
| 85  | GET    | `/crm/integrations`                                     | CRM        |
| 86  | GET    | `/crm/sales-team`                                       | CRM        |
| 87  | GET    | `/crm/conversations`                                    | CRM        |
| 88  | GET    | `/crm/leads`                                            | CRM        |
| 89  | GET    | `/crm/tasks`                                            | CRM        |
| 90  | PUT    | `/crm/tasks/{id}`                                       | CRM        |

**Total: 90 endpoints** — 55 GET, 20 POST, 13 PUT, 2 DELETE
