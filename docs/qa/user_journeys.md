# Orient Workshop — User Journeys (QA Audit)

## J001 — Customer books a service (full lifecycle)

| Field | Value |
|-------|-------|
| Starting State | App installed, logged out |
| User Role | customer (Guest for J001a) |
| Steps | Install → Launch → Splash → Session check → Login (OTP 123456 dev) → Home → "Book a Service" → Select service → Pick date/slot → Select vehicle → Confirm → Booking Received (ref) → Track → Notifications |
| Expected Result | Booking created with BK-xxxx ref, status pending, notifications emitted |
| APIs | /auth/send-otp, /auth/verify-otp, /services/types, /bookings/availability, POST /bookings |
| Backend | AuthService, BookingService, NotificationService, ActivityService, WebhookService |
| DB impact | users, otp_records, bookings, notifications, activity_log |
| Failure points | invalid phone (BUG-005 fixed), OTP cap (BUG-009 fixed), cancel broken (BUG-010 fixed), booking ref numeric (BUG-020 fixed) |

## J002 — Staff completes a job (seamless flow, automated 28-check)

| Field | Value |
|-------|-------|
| Starting State | Backend up, all roles provisioned |
| User Role | customer → supervisor → advisor → technician ×2 → supervisor → owner |
| Steps | Customer books → supervisor assigns booking → advisor check-in (job card + inspection) → repair order (line items auto-generated) → customer approves estimate → advisor assigns per-item work → technicians complete items → job auto-flips awaitingSupervisor → supervisor approves completion → invoice auto-raised → customer + owner verify |
| Expected Result | 28/28 checks pass; invoice with UAE VAT 5% |
| APIs | bookings, supervisor/bookings/{id}/assign, advisor check-in, /inspections, /repair-orders, approvals, work-items, technician items, supervisor approve, invoices, owner KPIs |
| Backend | BookingService, SupervisorQueueService, InspectionService, RepairOrderService, WorkItemService, InvoiceService, NotificationService |
| DB impact | bookings, job_cards, inspections, repair_orders(+services/parts), approvals, technician_tasks, invoices, notifications |
| Failure points | media upload path (BUG-017 fixed), status enum mapping (BUG-025 fixed) |

## J003 — Customer vehicle management

| Field | Value |
|-------|-------|
| Steps | Login → Vehicles tab → Add vehicle (form validation) → List → Edit → Delete |
| Expected Result | CRUD works; empty submit blocked with "Required"; API rejects empty bodies (BUG-011 fixed) |
| APIs | GET/POST /customers/vehicles, PUT/DELETE /customers/vehicles/{id} |
| Failure points | junk rows on empty body (fixed); IDOR attempts → 404 |

## J004 — Customer cancels a booking

| Field | Value |
|-------|-------|
| Steps | Bookings → detail → Cancel Booking → confirm dialog → cancelled |
| Expected Result | Status → cancelled, UI reflects it, workshop notified |
| APIs | PUT /customers/bookings/{id}/status (query param or body) |
| Status | **FIXED (BUG-010)** — verified on-device + DB |
| Failure points | previously silent 500 (deadlock-free now) |

## J005 — Customer emergency breakdown

| Field | Value |
|-------|-------|
| Steps | Home → Get Help → choose issue → vehicle → location → Request Emergency Support |
| Expected Result | Breakdown created (BD-ref), supervisor queue receives it |
| APIs | POST /customers/breakdowns |
| Failure points | empty body previously 409 (now 400 with validation) |

## J006 — Advisor vehicle intake & inspection

| Field | Value |
|-------|-------|
| Steps | Scan QR/VIN → check-in booking → customer/vehicle intake → choose inspection → capture media → preview → repair order |
| Expected Result | Job card + inspection created; media uploaded with magic-byte validation |
| APIs | /advisor/bookings/{id}/check-in, /inspections, /repair-orders/{id}/media |
| Failure points | media path (fixed), inspection id contract (fixed), camera permission denial (settings redirect added) |

## J007 — Technician attendance & work day

| Field | Value |
|-------|-------|
| Steps | Punch in → assigned jobs → start/complete work items → break → punch out |
| Expected Result | Attendance persisted (emp_id+date), per-item work tracked, job flips on completion |
| APIs | /technicians/attendance/*, /technicians/work-items/*, /technicians/assigned-jobs |
| Failure points | duplicate punch-in handled (200/409) |

## J008 — Owner business review

| Field | Value |
|-------|-------|
| Steps | Login → dashboard KPIs/charts → job card register → AR → invoices/PDF → payments → inventory → team → subscription |
| Expected Result | Real KPIs render on fresh login (BUG-028 fixed), AED currency |
| APIs | /owner/dashboard/*, /owner/job-cards*, /owner/accounts-receivable/*, /owner/invoices*, /owner/inventory/* |
| Failure points | initial-load zeros (fixed), GBP seed (fixed to AED) |

## J009 — CRM lead management

| Field | Value |
|-------|-------|
| Steps | Login → Leads → create lead → score/activities → update status → pipeline |
| Expected Result | Multiple leads creatable; scoring heuristic works |
| APIs | /crm/leads*, /crm/leads/{id}/score, /crm/dashboard/* |
| Failure points | external_id unique collision (BUG-018 fixed — V15 migration) |

## J010 — Logout / session end (all apps)

| Field | Value |
|-------|-------|
| Steps | Profile → Logout → confirm → login screen; restart stays logged out |
| Expected Result | Session terminated; tokens cleared; restart → login |
| APIs | POST /auth/logout |
| Status | **FIXED (BUG-023 + BUG-027)** — deadlock removed, customer app wired onLogout |
| Failure points | expired-token deadlock (fixed), missing onLogout callback (fixed) |

## J011 — Offline resilience

| Field | Value |
|-------|-------|
| Steps | Go offline → create booking/vehicle → actions queued → reconnect → sync |
| Expected Result | Ops queued in Hive, replayed on reconnect, idempotency keys prevent duplicates |
| APIs | /sync/** with Idempotency-Key |
| Status | Unit-tested (sync engine) + offline banner verified; full device offline pass limited |

## J012 — GDPR / privacy

| Field | Value |
|-------|-------|
| Steps | Customer → export data (GET /customers/data/export) |
| Expected Result | Personal data export; erase endpoint exists (destructive — not executed on live data) |
| Status | Export tested (200). Erasure documented, not executed (safety). |
