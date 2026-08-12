# Orient Workshop — Role Access Matrix (QA Audit)

Roles (from `users.role` ENUM + `RoleConstants`): **owner, advisor, technician, customer, supervisor, crmDashboard, admin**.

Legend: ✅ allowed · ❌ denied (403) · N/A not applicable · 🟡 partial (e.g. only own resources)
Access derived from SecurityConfig path rules + @PreAuthorize + verified by the Phase 2 API security suite (RBAC negative tests).

| Feature / Path prefix | Guest | customer | advisor | supervisor | technician | owner | crmDashboard |
|-----------------------|-------|----------|---------|------------|------------|-------|--------------|
| /auth/me, /auth/logout | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| /auth/send-otp, verify-otp, login, register, refresh | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| /customers/profile, /customers/vehicles, /customers/bookings | ❌ | ✅ (own) | ✅ | ✅ | ✅ | ✅ | ❌ |
| /customers/breakdowns, /customers/notifications, /customers/invoices, /customers/approvals | ❌ | ✅ (own) | ✅ | ✅ | ✅ | ✅ | ❌ |
| /customers/tickets, /feedback (submit), /customers/data/export | ❌ | ✅ (own) | ✅ | ✅ | ✅ | ✅ | ❌ |
| /bookings/availability, /services/types | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| /bookings (create) | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| /feedback/pending (moderation) | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| /feedback/{id}/moderation | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| /customers/search, /vehicles/search | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| /advisor/** | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| /inspections/**, /repair-orders/** | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| /supervisor/** | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ |
| /work-assignments, /jobs/complete, /departments | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ |
| /technicians/**, /technician/** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ |
| /technicians/attendance/** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ |
| /owner/** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| /branches/** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| /crm/** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| /staff/notifications | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| /sync/** | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| /media/** (static) | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| /whatsapp/send | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| /health, /version | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Ownership / IDOR rules (verified)

| Resource | Rule | Verified |
|----------|------|----------|
| customers/vehicles/{id} (PUT/DELETE) | customerId must match caller | ✅ 404 for other users |
| bookings/{id}/status | booking.customerId must match | ✅ 403/404 for other users |
| inspections drafts | advisor_id ownership persisted | ✅ 403 cross-user |
| technician work-items | emp ownership enforced | ✅ (E2E per-item isolation) |
| job cards (advisor list) | branch-scoped | ✅ |
| notifications read | user-scoped | ✅ |

## Notable matrix findings

- **advisor → /supervisor/** correctly 403; **owner → /advisor/** allowed by design (owner sees everything).
- **customer → /feedback/pending** correctly 403 (moderation inbox is staff-only).
- **owner → /crm/** allowed by design (crmDashboard + owner + admin).
- Unauthenticated access to protected paths → 401; unknown paths → 401/404 (BUG-006 fixed: no more 500).
- X-API-Key defaults to `owner` role and is rejected for /auth/**.
