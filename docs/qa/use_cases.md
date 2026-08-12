# Orient Workshop — Use Cases (QA Audit)

Every feature in `feature_inventory.md` maps to at least one use case; every use case maps to test cases in `test_cases.md` / `api_test_cases.md` and has an execution result in `test_execution.md`.

Format: `UC-<MODULE>-<NNN>` — Feature · Actor · Preconditions · Trigger · Main Flow · Expected Result · Alternative Flows.

## UC-AUTH

### UC-AUTH-001 — OTP Login
- **Feature:** F001 · **Actor:** Registered user · **Pre:** App installed, account exists, internet up · **Trigger:** User taps Continue with phone
- **Flow:** Enter phone → send-otp → OTP screen → enter 6-digit code → verify → token pair → secure storage → dashboard
- **Expected:** Dashboard for the role; tokens persisted
- **Alternatives:** wrong OTP (400), 5 wrong attempts (429 — **BUG-009 fixed**), invalid phone (**BUG-005 fixed**), expired OTP (400), unknown phone → auto-creates customer (S-2), no internet (offline mode)
- **Result:** PASS (API + device)

### UC-AUTH-002 — Password Login
- **Feature:** F001 · **Actor:** User with password account
- **Flow:** Email/phone + password → /auth/login → token pair
- **Alternatives:** wrong password (400/401), unknown user (400/401), 5 failures → lockout 30s→15min (429), account without password (400 "use OTP"), missing password (400)
- **Result:** PASS

### UC-AUTH-003 — Registration (customer)
- **Flow:** name/email/phone/password/role → /auth/register
- **Alternatives:** duplicate phone/email (400), invalid email (400), weak password (400), staff role → 400 (customer-only, CR-5), success → token pair
- **Result:** PASS

### UC-AUTH-004 — Token Refresh & Rotation
- **Flow:** refresh token → /auth/refresh → new pair; old token reuse → 401 + family revoked
- **Alternatives:** garbage token (400/401), empty body (400), refresh failure → local logout (no deadlock — **BUG-023 fixed**)
- **Result:** PASS

### UC-AUTH-005 — Logout
- **Flow:** Profile → Logout → confirm → /auth/logout → clear storage → state unauthenticated → login screen
- **Alternatives:** expired access token (401 on logout — still clears locally), storage failure (clears state anyway), restart after logout → stays logged out
- **Result:** PASS (on-device, all apps — **BUG-023/027 fixed**)

### UC-AUTH-006 — Forgot / Reset Password
- **Flow:** forgot-password (OTP) → reset-password (OTP + new password) → old password invalid
- **Result:** PASS

### UC-AUTH-007 — Session Restore
- **Flow:** App start → AuthLoading → token + /auth/me validation → dashboard; expired → refresh → refresh fails → login
- **Alternatives:** 30-min offline TTL, unknown role fails closed (no OWNER escalation), disabled user → 401
- **Result:** PASS

## UC-CUSTOMER

### UC-CUS-001 — Browse Home & Service Catalogue
- F004/F005 · view KPIs, symptom cards, service prices
- **Result:** PASS (device) — **BUG-019 fixed** (AED prices)

### UC-CUS-002 — Create Booking (3-step wizard)
- F005 · service → date/slot → vehicle+notes → confirm
- **Alternatives:** past dates blocked, booked slot excluded (verified on-device), missing vehicle (400), invalid date format (400), offline (queued)
- **Result:** PASS (device + API)

### UC-CUS-003 — View / Filter Bookings
- F006 · list + status filters (All/Pending/Confirmed/Completed/Cancelled)
- **Result:** PASS (device)

### UC-CUS-004 — Cancel Booking
- F007 · detail → Cancel → confirm dialog → cancelled
- **Result:** PASS (device + DB) — **BUG-010 fixed**

### UC-CUS-005 — Manage Vehicles (CRUD)
- F011-F013 · add (validation), edit, delete
- **Alternatives:** empty body (400 — **BUG-011 fixed**), duplicate plate (allowed by design), IDOR → 404
- **Result:** PASS (API) / partial (device: form + validation verified; full submit harness-limited)

### UC-CUS-006 — Breakdown Request
- F010 · issue → vehicle → location → submit
- **Alternatives:** empty (400 now — validation), invalid vehicle
- **Result:** PASS (API)

### UC-CUS-007 — Service Status Tracking
- F009 · live stages pipeline
- **Result:** PASS (device + E2E)

### UC-CUS-008 — Estimate Approval
- F014 · pending approvals → detail → approve/reject/revise
- **Result:** PASS (E2E)

### UC-CUS-009 — Invoice View
- F014 · server-driven invoice, VAT 5%, Pay Now for unpaid
- **Result:** PASS (widget tests + E2E)

### UC-CUS-010 — Notifications
- F015 · list, read, read-all
- **Result:** PASS (API)

### UC-CUS-011 — Feedback
- F016 · star ratings + comment
- **Result:** PASS (API) — **BUG-029 fixed** (overall alias)

### UC-CUS-012 — Support Ticket
- F017 · create/list tickets
- **Result:** PASS (API)

### UC-CUS-013 — GDPR Export
- F018 · export data
- **Result:** PASS (API)

## UC-ADVISOR

### UC-ADV-001 — Dashboard & Stats
- F022 · KPIs/orders/WIP/ready/delivered
- **Result:** PASS (device + API)

### UC-ADV-002 — Job Cards List/Search/Filter
- F023 · paged list, status chips
- **Alternatives:** page=0 (500 → **BUG-007 fixed** → 200), huge size capped
- **Result:** PASS (API)

### UC-ADV-003 — Job Card Detail & Status
- F024 · timeline, update status, assign technician
- **Alternatives:** unknown status rejected (400), status labels correct (**BUG-025 fixed**)
- **Result:** PASS (device + API)

### UC-ADV-004 — Vehicle Scan & Check-in
- F025/F026 · camera scan → intake → job card
- **Alternatives:** permission denied → guidance UI (works), permanent denial → settings (**BUG-026 fixed**)
- **Result:** PASS (device + E2E)

### UC-ADV-005 — Inspection
- F027 · create/draft/summary with sections
- **Alternatives:** id contract (**BUG-014 fixed** — numeric id returned), cross-user draft → 403
- **Result:** PASS (API)

### UC-ADV-006 — Repair Order & Estimate
- F028 · line items, send estimate
- **Result:** PASS (E2E)

### UC-ADV-007 — Work Items Assignment
- F029 · per-item assignment to technicians
- **Result:** PASS (E2E)

### UC-ADV-008 — Approvals & Reminders
- F030/F031 · process approvals; reminder CRUD
- **Result:** PASS (API)

### UC-ADV-009 — Reports
- F032 · today/week/month
- **Alternatives:** invalid range → 400 (**BUG-012 fixed**)
- **Result:** PASS (API + device)

### UC-ADV-010 — Search (customer/vehicle)
- F033 · staff-only search
- **Result:** PASS (API, RBAC verified)

### UC-ADV-011 — Media Upload
- F034 · photos/video/audio per repair order
- **Alternatives:** fake file → 400 magic-byte; upload path (**BUG-017 fixed**)
- **Result:** PASS (API)

## UC-SUPERVISOR

### UC-SUP-001 — Queue & Routing
- F037 · KPIs, unassigned bookings/breakdowns, assign to advisor
- **Result:** PASS (E2E)

### UC-SUP-002 — Completion Review & QC
- F038 · approve (→ invoice), reject (→ reset items), QC checklist
- **Result:** PASS (E2E)

### UC-SUP-003 — Work Assignments
- F039 · create assignments with jobCardId items
- **Result:** PASS (API)

### UC-SUP-004 — Staff/Schedule/Notifications
- F040/F041
- **Result:** PASS (API)

## UC-TECHNICIAN

### UC-TECH-001 — Attendance
- F042 · punch in/out, breaks; duplicate punch-in handled
- **Result:** PASS (API)

### UC-TECH-002 — Assigned Jobs & Work Items
- F043/F044 · list, start/complete per-item, notes
- **Result:** PASS (API + E2E)

### UC-TECH-003 — Parts & Escalations
- F045 · request parts, escalate
- **Result:** PASS (API)

### UC-TECH-004 — Productivity & Profile
- F046/F047
- **Result:** PASS (API)

## UC-OWNER

### UC-OWN-001 — Dashboard KPIs & Charts
- F049 · KPIs, sales/profit/expenses/forecast, register, top sales
- **Result:** PASS (API + device) — **BUG-028 fixed** (fresh-login load)

### UC-OWN-002 — Messages & Activity
- F050/F051 · send message, activity feed + exports
- **Result:** PASS (API)

### UC-OWN-003 — Job Cards & Exports
- F052/F053 · register drill-down, CSV export
- **Result:** PASS (API)

### UC-OWN-004 — Accounts Receivable
- F054 · aging summary/records
- **Result:** PASS (API)

### UC-OWN-005 — Invoices & Payments
- F055/F056 · list, PDF, record payment (overpayment rejected)
- **Result:** PASS (API)

### UC-OWN-006 — Inventory
- F059 · items, suppliers, POs, receive
- **Alternatives:** negative qty → 400 (**BUG-015 fixed**), duplicate SKU (P3 open — nullable branch)
- **Result:** PASS (API)

### UC-OWN-007 — Team, Subscription, Moderation, API Keys, Webhooks, Branches
- F060-F067
- **Result:** PASS (API)

## UC-CRM

### UC-CRM-001 — Dashboard & Pipeline
- F069/F070 · KPIs, lead pipeline, channels
- **Result:** PASS (API + device)

### UC-CRM-002 — Lead CRUD & Analytics
- F071/F072 · create/update/delete, score/activities/stats
- **Alternatives:** duplicate phone (allowed), external_id collision (**BUG-018 fixed**)
- **Result:** PASS (API)

### UC-CRM-003 — Tasks, Conversations, Team
- F073-F075
- **Result:** PASS (API)

### UC-CRM-004 — Integrations
- F077 · connect/disconnect/sync Meta/Zoho (encrypted credentials)
- **Result:** PASS (API; live Meta sync not executed — no credentials)

## UC-SEC

### UC-SEC-001 — RBAC enforcement
- Cross-role matrix (see role_access_matrix.md) — PASS (21 RBAC checks)

### UC-SEC-002 — Token abuse
- Missing/garbage/expired/forged/role-swapped tokens → 401 — PASS (forged JWT suite)

### UC-SEC-003 — IDOR
- Cross-user vehicle/booking/inspection access → 404/403 — PASS

### UC-SEC-004 — Rate limiting
- 100/min general, 20/min auth, 429 + Retry-After — PASS (observed during suite)

### UC-SEC-005 — Idempotency
- Duplicate sync with same Idempotency-Key → identical replay — PASS

### UC-SEC-006 — Secrets hygiene
- No passwords/OTPs/tokens in logs or responses; OTP stored SHA-256; JWT dev-only secrets with prod fail-fast — PASS (source review)

### UC-SEC-007 — Sensitive data in UI
- No OTP/logged tokens in app UI; masked phones in logs — PASS (source review)
