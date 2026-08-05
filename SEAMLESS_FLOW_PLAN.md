# Seamless End-to-End Flow Plan

Goal: close every hand-off gap between the 5 apps (customer, staff-advisor/supervisor/technician, owner, CRM) so one event automatically flows into the next with notifications at every step — no dead-ends, no manual re-entry.

**Role rules (per owner's decision):**
- **Supervisor** receives bookings & breakdowns and assigns them to an **advisor**
- **Advisor** does intake → inspection → work list (repair order) → sends estimate approval to **customer only**
- **Owner is READ-ONLY** — dashboards, job statuses, approvals counts. No owner approval actions.

---

## 1. Current Flow Gaps (verified in code)

| # | Gap | Where | Impact |
|---|-----|-------|--------|
| G-1 | **Booking → nobody.** `POST /bookings` just inserts row, status `pending` (`BookingService.java:36`). No supervisor queue, no advisor assignment, no notification | backend, staff_app | Bookings are dead-ends; customer thinks workshop knows |
| G-2 | **Breakdown → nobody.** `POST /customers/breakdowns` inserts row (`BreakdownService.java:22`) | backend | Emergency requests unanswered |
| G-3 | **No notification generation anywhere.** Zero `notificationMapper.insert()` in codebase; `GET /customers/notifications` always empty | backend | All notification UX is fake |
| G-4 | **No booking status updates.** Nothing ever changes `bookings.status` (confirmed/completed) | backend | Booking stuck at pending forever |
| G-5 | **No customer estimate approval.** Only advisor can approve (`ApprovalService.java:43`); customer never sees it | backend, customer_app | Customer not consulted on cost |
| G-6 | **Walk-in customer duplication.** Advisor-created customer has no `user_id` (`InspectionService.resolveCustomer`); when the same person later logs in with the same phone, `findOrCreateCustomer` (by user_id) creates a SECOND customer row | backend | Duplicate records; approval can't be shown to them |
| G-7 | **Inspection locked after submit.** No `PUT /inspections/{id}` to update sections once created; advisor can't add/re-edit inspection on an existing job card | backend | Advisor must redo the whole flow for follow-up checks |
| G-8 | **Repair order → no tasks.** Technician tasks must be created manually; no auto-generation from work-list line items ("engine work", "headlight change"); inspection items not tracked individually; no supervisor review of completion | backend | Tech re-types work; no per-item completion tracking or sign-off |
| G-9 | **Job complete → no invoice.** `jobs.complete` marks done; `invoices` table unused by any flow (only list endpoint) | backend, owner_app | No revenue loop |
| G-10 | **No communication channel.** WhatsApp service is log-only until tokens set (`WhatsAppService`); no SMS/email send on events | backend | All "notify" flags (`notify_owner_sms_email`) do nothing |
| G-11 | **Status updates not broadcast.** Advisor/tech set job status; nobody is told (customer stage auto-derives only) | backend | Stale perception, no "car ready" alert |

---

## 2. Target Seamless Flows

### Flow A — Booking → Supervisor → Advisor
```
Customer books (customer_app)
   → bookings row (status=pending)  [exists]
   → Notification: customer "booking received"  [NEW]
   → Supervisor app: "New bookings" queue (badge)  [NEW endpoint GET /supervisor/bookings]
   → Supervisor assigns booking to an advisor  [NEW: PUT /supervisor/bookings/{id}/assign]
        → bookings.advisor_id set, status=confirmed
   → Notification: advisor "New booking assigned: BMW 3 Series — 5 Apr 10:00 AM"  [NEW]
   → Customer notified: "Booking confirmed with advisor Khalid"  [NEW]
   → Advisor's dashboard shows "Assigned bookings" (badge)  [NEW]
```

### Flow B — Breakdown → Supervisor → Advisor
```
Customer reports breakdown (issue, location)
   → breakdowns row (status=pending)  [exists]
   → Supervisor app: "Breakdowns" queue (badge)  [NEW endpoint]
   → Supervisor assigns to advisor → status=dispatched, ETA sent  [NEW]
   → Advisor calls/arranges recovery; on arrival → intake → job card  [Flow C]
```

### Flow C — Intake (booking OR walk-in) → Inspection → Work list → Customer Approval
```
Customer reaches the garage — booking arrival or first-time walk-in (manual entry)
   Advisor (advisor app):
   → Opens assigned booking OR creates walk-in intake
   → Customer/Vehicle created (walk-in: record phone number — no login needed)  [exists]
   → JobCard created + linked to booking (bookings.job_card_id)  [NEW link]
   → Inspection (26 points, 4 sections, photos) — can be added NOW or LATER on the job card  [exists + G-7 fix: PUT /inspections/{id}]
   → Work list / repair order created: "Engine Work", "Headlight Change", "Oil Change", parts…  [exists]
   → Approval row auto-created (amount = grand total)  [NEW: on RO submit]
   → Customer app gets "Approve estimate AED 1,250" (approve / reject / request changes)  [NEW]

   How walk-in approval works (no prior booking):
   → Approval is stored against the customer record created at intake (with phone)
   → When the customer later logs into customer_app with the SAME phone (OTP),
     the system merges: finds customers.phone_number = login phone → binds user_id  [NEW: G-6 fix]
   → Their pending approval + vehicle + job appear in the app
   → First-time users without the app: advisor shares estimate via WhatsApp/SMS link  [Phase 4]
   → Customer approves → JobCard pendingApproval → inProgress  [auto]
   → Notification: advisor + supervisor "Estimate approved by customer"
```

### Flow D — EVERY item (inspection + work) becomes a trackable work item (auto)
```
Advisor's work items are stored as individual tracked items  [NEW: G-8 fix]
   - Inspection items: "Check Head Light", "Check Brake Lines", "Test Battery" (the checklist entries)
   - Work items: "Engine Work", "Headlight Change", "AC Repair"…
   → EVERY item gets its own row in technician_tasks with status = pending  [NEW auto-gen]

   Advisor assigns technicians — CHOICE at assignment time (advisor app):
   Option 1 — ONE technician for the whole job (existing: PUT /advisor/job-cards/{id}/technician)
   Option 2 — DIFFERENT technicians per item  [NEW: per-item assign]
      "Headlight Change" → Ravi Kumar (Electrical)
      "Engine Work"      → Ali Hassan (Engine)
      "AC Repair"        → Mohammed Salim (AC & Cooling)
   → Advisor picks per item from the technicians list (GET /technicians exists)
   → Each technician gets notified ONLY about their own items  [NEW]
   → Tech sees only their items (technician_tasks.emp_id = my empId)  [exists filter]
   → Every item shows: pending / inProgress / completed + assigned technician at all times
```

### Flow E — Technician tracks EVERY item → Supervisor reviews & approves completion
```
For EACH work item (inspection AND work) the technician tracks (staff_app):
   → status: pending → inProgress → completed  [per item, visible to all]
   → start / end time per item  [exists]
   → notes per item  [exists]
   → before/after photos per item  [NEW: reuse media upload]
   → items CANNOT be marked completed without tech's action — every single item tracked
   Job progress % = completed items / total items  [exists calc — ServiceTrackingService]
   → Customer live tracker updates automatically  [exists]
   → Notifications on transitions: workInProgress, waitingParts  [NEW]

   When ALL items are completed (by all assigned technicians, each marking their own):
   → JobCard status → "awaitingSupervisor" (review queue)  [NEW status]
   → Supervisor app: "Jobs awaiting completion review" list showing EVERY item + assigned tech + done/total  [NEW]
   → Supervisor checks each item (photos, notes, times) — approves or sends back:
       - APPROVE → JobCard completed  [NEW: PUT /supervisor/jobs/{id}/approve-completion]
       - REJECT → JobCard back to inProgress, rejected items reset  [NEW]
   → "Your car is ready" (carReady) only sent AFTER supervisor approval  [NEW]
   → Supervisor/owner see per-item completion (done 4/6, pending 2)  [NEW supervisor view]
```

### Flow F — Supervisor-approved completion → Invoice (owner reads only)
```
Supervisor approves completion (Flow E) → JobCard completed
   → Invoice auto-raised from work list totals  [NEW: InvoiceService.createFromJobCard]
   → Customer: invoiceReady notification + invoice view in app  [NEW]
   → Owner dashboard revenue KPIs update instantly (READ-ONLY)  [exists — real SQL]
   → Payment recorded → invoice paid → AR clears  [NEW]
```

### Flow G — Notifications everywhere (event bus)
Single `NotificationService.emit()` used by every flow above:
- Creates row in `notifications` table for the target user  [NEW]
- Enqueues WhatsApp/SMS/email if provider configured  [exists, code-ready]
- Customer app polls + badge counts (exists endpoints); supervisor/advisor/tech get in-app feeds  [NEW endpoints]

---

## 3. Implementation Plan

### Phase 0 — Foundation: event/notification engine (backend) — ~4 days
| Task | Files | Notes |
|------|-------|-------|
| `NotificationService.emit(userId, type, title, body)` | new `orient-common` service | single insert point, used everywhere |
| `WorkflowEvent` marker + `WorkflowEventBus` | new `orient-common` | in-process pub/sub; services + jobs fire events |
| `notify_*` config flags | `orient-common.properties` | on/off per channel (in-app, whatsapp, sms, email) |
| Tests | `orient-common` test | emit → row created, channel enqueued |

### Phase 1 — Booking & breakdown routing: Supervisor → Advisor (G-1, G-2, G-4) — ~5 days
| Task | Files | Notes |
|------|-------|-------|
| Schema: `bookings.advisor_id BIGINT NULL`, `bookings.job_card_id BIGINT NULL`, `breakdowns.advisor_id BIGINT NULL` | Flyway V3 | FK to staff / job_cards |
| `GET /supervisor/bookings` + `PUT /supervisor/bookings/{id}/assign {advisorId}` | new `BookingController` in orient-supervisor | queue + assignment; sets status=confirmed |
| `GET /supervisor/breakdowns` + `PUT /supervisor/breakdowns/{id}/assign` + `/dispatched` | orient-supervisor | routing + ETA lifecycle |
| `GET /advisor/bookings` (assigned to me) + badge in stats | `AdvisorStatsService` + advisor app | `newAssignedBookings` count |
| Advisor app: "Assigned bookings" list → "Start intake" opens pre-filled form | staff_app advisor | pre-fills vehicle/customer from booking |
| Notifications: booking received → assigned → confirmed | Phase 0 engine | types: bookingConfirmed, reminder |
| Breakdown intake: advisor marks arrived → converts to job card | advisor app + `POST /inspections` | link `breakdowns.job_card_id` |

### Phase 2 — Customer approval loop incl. walk-ins (G-5, G-6) — ~5 days
| Task | Files | Notes |
|------|-------|-------|
| **Phone-merge fix:** on login/verify-otp (or in `findOrCreateCustomer`), match `customers.phone_number = user.phone` first → bind `user_id` to existing row instead of creating a duplicate | `CustomerService.java` | kills G-6; walk-in customer's history + approvals appear after login |
| Auto-create `approvals` row on repair-order submit (amount = grandTotal) | `RepairOrderService` | action=pending |
| `GET /customers/approvals/pending` + `GET /customers/approvals/{id}` (line items) | new orient-customer controller | detail incl. services/parts from repair order |
| `PUT /customers/approvals/{id}` `{action: approve|reject|revise}` | new orient-customer controller | JobCard auto: pendingApproval → inProgress on approve |
| Customer app: "Approve estimate" screen (items, total, buttons) + notifications | customer_app | approvalNeeded / approved / rejected |
| **Owner: READ-ONLY, no changes** — keep view-only counts | `OwnerApprovalService` | no owner action endpoints, ever |
| Advisor sees approval status on the job card | advisor app job detail | pending / approved / rejected badge |

### Phase 3 — Every item tracked: inspection + work → tech → supervisor approval (G-7, G-8) — ~6 days
| Task | Files | Notes |
|------|-------|-------|
| `PUT /inspections/{id}` — update sections/photos on an existing inspection (job card) | `InspectionService` + controller | advisor can add/re-edit inspection any time |
| Schema: extend `technician_tasks` (exists) — add `item_type ENUM('INSPECTION','WORK')`, `qty`, `rate`, `photo_refs JSON`, `advisor_id`, `reject_reason` | Flyway V3 | one row per trackable item — reuses existing task status/times/empId machinery |
| Auto-create `technician_tasks` on RO submit: every repair-order line item + every inspection checklist entry (26 points) | new `TaskGeneratorService` in orient-advisor | "Engine Work", "Headlight Change", "Check Head Light", "Test Battery"… each gets own row + own status |
| **Per-item technician assignment:** `PUT /technician-tasks/{id}/assign {empId}` + batch `PUT /technician-tasks/assign` — advisor chooses per-item tech (or one for all); sets `emp_id` per row (column already exists) | new `TaskAssignmentService` (orient-advisor) + advisor app UI | Option 1: whole job (exists); Option 2: per item from GET /technicians list |
| Assignment notifications: each tech notified only about their own items | Phase 0 engine | "2 work items assigned: Headlight Change, AC Repair" |
| Technician job list filters by `technician_tasks.emp_id` = my empId (exists in productivity; extend `getJobs`) | `TechnicianJobService` | tech never sees other techs' items; supervisor/advisor/owner see ALL items + who's assigned |
| Item status endpoints: `PUT /work-items/{id}/status`, `/start`, `/complete`, notes, media | new `WorkItemController` (orient-technician) | per-item start/end/notes/photos; status visible to advisor/supervisor/owner |
| Job card new status `awaitingSupervisor` — auto when ALL items completed | `JobCardService` + `TaskService` | technician can't mark job done manually; system triggers review |
| Supervisor review: `GET /supervisor/jobs/awaiting` (list with done/total + per-item detail) + `PUT /supervisor/jobs/{id}/approve-completion` + `/reject-completion` | new `CompletionReviewService` (orient-supervisor) | approve → job completed; reject → job back to inProgress, rejected items reset to pending with reason |
| Supervisor app: "Awaiting review" screen — per-item checklist with photos/notes/times, Approve / Send back buttons | staff_app supervisor | only supervisor can finalize a job |
| `carReady` notification ONLY after supervisor approval | Phase 0 engine | no early "your car is ready" |
| Technician app: work-item list per job (inspection + work items) with per-item status + complete + photos | staff_app technician | progress bar = done/total items |

### Phase 4 — Invoice + payment (G-9) — ~3 days
| Task | Files | Notes |
|------|-------|-------|
| `InvoiceService.createFromJobCard(jobCardId)` — totals from repair order | new service in orient-owner | auto-raise on QC-complete |
| `GET /customers/invoices` + invoice detail | new orient-customer endpoints + customer_app screen | invoiceReady notification |
| `PUT /invoices/{id}/pay` (internal/admin) | orient-owner | AR recalculates; owner reads updated KPIs |
| Owner reads: invoices, AR aging, revenue (no actions) | owner_app | existing screens |

### Phase 5 — Communications (G-10) — ~3 days (config; provider work separate)
| Task | Files | Notes |
|------|-------|-------|
| Wire `WhatsAppService` send calls into Phase 0 event bus | `orient-whatsapp` | code-ready; needs `WHATSAPP_ACCESS_TOKEN` |
| SMS/email provider interfaces + config | `orient-common` + `orient-auth` | reuses OTP provider pattern |
| Shareable estimate link for first-time walk-ins (no app yet) | orient-advisor + WhatsApp | link → approval page |
| Webhook status callbacks persist into `whatsapp_messages` | `WhatsAppController` (exists) | |

### Phase 6 — Staff in-app notification feeds — ~4 days
| Task | Files | Notes |
|------|-------|-------|
| `GET /staff/notifications` + `PUT .../{id}/read` | new endpoint (mirror customer's) | supervisor/advisor/technician + owner (read-only) |
| Badge counts in app bars | staff_app + owner_app | poll every 60s; shared_core timer |
| Supervisor dashboard: "Unassigned bookings/breakdowns" KPI | `SupervisorKpiService` | SLA: >24h unassigned → escalate |

### Phase 7 — Hardening (before selling)
- Turn off dev OTP (`app.otp.fixed-value=false`), set real secrets
- Booking/breakdown SLA: unassigned >24h → escalation notification to owner (read-only alert)
- Audit: every status transition logged to `activity_log` (table exists)

## 5. Integration Status (updated 2026-08-05)

| Phase | Scope | Status | What was actually shipped |
|-------|-------|--------|---------------------------|
| **0** | Event/notification engine | ✅ **INTEGRATED** | `NotificationService.emit()` in `orient-core` (single insert for every workflow event); Flyway `V4__seamless_flows.sql` (booking/breakdown advisor links, technician_tasks extensions, `awaitingSupervisor` status, new notification types) |
| **1** | Booking & breakdown routing: Supervisor → Advisor | ✅ **INTEGRATED** | `GET/PUT /supervisor/bookings` + `/breakdowns` queue & assign (notifies customer + advisor); `GET /advisor/bookings`; stats badges `newAssignedBookings`/`newBreakdowns`; booking→job-card link on intake (`bookingId` in `POST /inspections` + sync); advisor app "Assigned Bookings" section with Start-Intake prefill; supervisor app **Queue** tab |
| **2** | Customer approval loop incl. walk-ins | ✅ **INTEGRATED** | Phone-merge in `CustomerService.findOrCreateCustomer` (walk-in record bound on same-phone login); auto-approval + `pendingApproval` on repair-order submit; `GET/PUT /customers/approvals/*`; customer app **Approvals** tab with estimate detail + Approve/Reject. Owner stays read-only |
| **3** | Per-item tracking + assignment + supervisor sign-off | ✅ **INTEGRATED** | `TaskGeneratorService` (RO services + inspection fair/poor items → own task rows); `PUT /advisor/work-items/*` per-item assignment (+batch, `/advisor/technicians` list); `PUT /technicians/work-items/*` status/start/complete/notes with ownership; auto `awaitingSupervisor` when ALL items done; `GET /supervisor/jobs/awaiting` + `approve/reject-completion` (reject resets items + reason); advisor **Work Items** section UI; supervisor **Review** tab; technician sees only own items |
| **4** | Invoice + payment | 🟡 **PARTIAL** | Invoice auto-raised from repair-order totals on supervisor approval (`InvoiceService.createFromJobCard`) + `GET /customers/invoices` + customer invoices list. **NOT done:** payment recording (`PUT /invoices/{id}/pay`) + AR clearing |
| **5** | WhatsApp/SMS/email | ⏳ **DEFERRED (per owner)** | Not implemented — will be done separately in the future. Code-ready hooks exist (`NotificationService` is the single emit point; WhatsApp service is log-only until tokens configured) |
| **6** | Staff in-app notification feeds | ✅ **INTEGRATED** | `GET/PUT /staff/notifications` feed; supervisor notification bell with unread badge; advisor notification sheet shows remote feed. **Partial:** owner_app bell not wired (owner app left as-is), no 60s polling |
| **7** | Hardening (before selling) | ⏳ **NOT DONE** | Dev OTP `123456` still on; SLA escalation job not built; audit logging to `activity_log` not wired |

**Summary: Phases 0, 1, 2, 3, 6 are integrated end-to-end (backend + frontend, all builds green). Phase 4 is partially integrated (invoice auto-raise + customer view; payment mark pending). Phase 5 is deferred by decision — NOT implemented. Phase 7 remains before any real deployment.**

---

## 4. Sequencing & Effort

```
Phase 0  event engine ................. 4 days   (foundation — do first)
Phase 1  booking/breakdown routing ..... 5 days   (supervisor → advisor)
Phase 2  customer approval (walk-ins) .. 5 days   (phone-merge + approve screen)
Phase 3  per-item tracking + assignment   7 days   (inspection+work items → tech per-item assign → supervisor approval)
Phase 4  invoice + payment ............. 3 days
Phase 5  WhatsApp/SMS/email ............ 3 days   (config only, code-ready)
Phase 6  staff in-app feeds ............ 4 days
Phase 7  hardening ..................... 2 days
                                       ---------
                         Total ≈ 33 dev-days (1 backend + 1 Flutter)
```

Exit criteria (demo script):
1. Customer books on phone → **Supervisor app** shows the booking → supervisor assigns to advisor → advisor notified
2. Customer arrives (or walk-in first-timer registers at desk with phone) → advisor intake → inspection + work list "Engine Work + Headlight Change AED 380"
3. Customer approves on their phone (walk-in: same-phone login merges their record, approval appears) → owner watches read-only
4. Advisor assigns technicians — **per item**: Headlight Change → Ravi (Electrical), Engine Work → Ali (Engine), AC Repair → Mohammed (AC) → each tech sees only their items with status pending → each works their items (start/end/notes/photos) → customer tracker shows live progress
5. All items completed → job auto-goes to **Supervisor review queue** with per-item evidence → supervisor approves completion (or sends back) → ONLY then "Your car is ready" → invoice auto-raised → owner dashboard revenue updates (read-only)

Zero manual re-entry, every actor notified at each hand-off.
