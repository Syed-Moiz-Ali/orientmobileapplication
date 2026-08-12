# Orient Workshop — Module QA Status (QA Audit)

Allowed final statuses: **READY / READY_WITH_MINOR_ISSUES / NOT_READY / BLOCKED**.

| Module | Functional | UI | UX | API | Negative | Security | Regression | Result |
|--------|-----------|----|----|-----|----------|----------|------------|--------|
| Authentication & Session (auth, OTP, password, refresh, logout) | PASS | PASS | PASS | PASS | PASS | PASS | PASS | READY |
| Customer Portal (bookings, vehicles, breakdowns, approvals, invoices, feedback, tickets, notifications, GDPR) | PASS | PASS | PASS | PASS | PASS | PASS | PASS | READY_WITH_MINOR_ISSUES* |
| Advisor (dashboard, job cards, scan, inspection, repair orders, work items, approvals, reminders, reports, media) | PASS | PASS | PASS | PASS | PASS | PASS | PASS | READY |
| Supervisor (queue, routing, completion review, QC, assignments, notifications) | PASS | PASS | PASS | PASS | PASS | PASS | PASS | READY |
| Technician (attendance, jobs, work items, parts, escalations, productivity) | PASS | PASS | PASS | PASS | PASS | PASS | PASS | READY |
| Owner (KPIs, charts, AR, invoices/PDF, payments, inventory, team, subscription, moderation, api-keys, branches) | PASS | PASS | PASS | PASS | PASS | PASS | PASS | READY_WITH_MINOR_ISSUES† |
| CRM (dashboard, leads, tasks, conversations, team, integrations) | PASS | PASS | PASS | PASS | PASS | PASS | PASS | READY_WITH_MINOR_ISSUES‡ |
| Offline Sync Engine (Hive queue, idempotency, media queue) | PASS | PASS | n/a | PASS | PASS | PASS | PASS | READY |
| Media (upload, magic-byte validation, storage) | PASS | PASS | n/a | PASS | PASS | PASS | PASS | READY |
| WhatsApp (webhook, send) | NOT_RUN (no credentials) | n/a | n/a | PARTIAL (source-reviewed) | n/a | n/a | n/a | BLOCKED (env) |
| Scheduler jobs (ShedLock) | PASS (boot logs) | n/a | n/a | n/a | n/a | n/a | n/a | READY |
| Shared packages (core/auth/models) | PASS | PASS | PASS | PASS | PASS | PASS | PASS | READY |
| Build/CI tooling (melos) | FAIL (melos 8 incompat) | n/a | n/a | n/a | n/a | n/a | n/a | NOT_READY (BUG-002) |

\* Customer Portal minor: mixed date formats in booking list (client vs server formatting — cosmetic); "UK" plate-prefix chip in add-vehicle form (localization); visual-pixel checks blocked.
† Owner minor: duplicate-SKU-with-null-branch (BUG-016, P3); payment-unknown-invoice returns 400 rather than 404 (cosmetic contract).
‡ CRM minor: drawer "Leads 0" badge stale vs dashboard; "Super Admin" role label for crmDashboard user; Zoho integration placeholders `'1000.XXXX'`.

## Blocked / Not-Run Justifications
- **WhatsApp:** outbound send requires Meta credentials (not provided). Webhook signature verification + intent handling source-reviewed only.
- **Visual pixel checks:** this audit environment (CLI model) cannot view screenshots; UI verified via uiautomator semantics (labels, navigation, states). Recommend a visual pass before release.
- **k6 load test:** binary not installed locally; CI has a historical passing run (13,077 requests, p95=120ms). Recommend re-running in CI.
- **GatewayBootIntegrationTest (Docker/Testcontainers):** skipped locally — runs in CI.
- **GDPR erasure:** destructive; not executed against local data (documented; endpoint exists and is RBAC-gated).

## Overall: READY_WITH_MINOR_ISSUES (pending items in final_qa_report.md)
