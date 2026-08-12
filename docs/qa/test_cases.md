# Orient Workshop — Test Cases (QA Audit)

> Traceability: Feature (F-IDs in feature_inventory.md) → Use Case (UC-…) → Test Case (TC-…).
> Statuses: PASS / FAIL / BLOCKED / NOT_RUN / NOT_APPLICABLE. Execution evidence in `test_execution.md` and `api_test_results.json` (238 API checks). Visual-pixel checks are marked `BLOCKED (visual)` — this audit environment verified structure/semantics via uiautomator, not pixels.

## TC-AUTH (Authentication & Session)

| ID | Feature | UC | Test | Priority | Result | Bug |
|----|---------|----|------|----------|--------|-----|
| TC-AUTH-001 | F001 | UC-AUTH-001 | OTP login happy path (phone → OTP 123456 → dashboard) | P0 | PASS (device+API) | - |
| TC-AUTH-002 | F001 | UC-AUTH-001 | Wrong OTP → 400 | P0 | PASS | - |
| TC-AUTH-003 | F001 | UC-AUTH-001 | 5 wrong OTPs → 429 cap | P0 | PASS | BUG-009 (fixed) |
| TC-AUTH-004 | F001 | UC-AUTH-001 | Invalid phone → 400 | P1 | PASS | BUG-005 (fixed) |
| TC-AUTH-005 | F001 | UC-AUTH-001 | Empty/missing OTP → 400 | P1 | PASS | - |
| TC-AUTH-006 | F001 | UC-AUTH-001 | OTP by email flow | P1 | PASS | - |
| TC-AUTH-007 | F001 | UC-AUTH-002 | Password login (phone & email) | P0 | PASS | - |
| TC-AUTH-008 | F001 | UC-AUTH-002 | Wrong password → 400/401 | P0 | PASS | - |
| TC-AUTH-009 | F001 | UC-AUTH-002 | 5 failures → lockout 429 | P1 | PASS | - |
| TC-AUTH-010 | F003 | UC-AUTH-003 | Register customer | P0 | PASS | - |
| TC-AUTH-011 | F003 | UC-AUTH-003 | Register duplicate phone → 400 | P1 | PASS | - |
| TC-AUTH-012 | F003 | UC-AUTH-003 | Register staff role → 400 (customer-only) | P0 | PASS | - |
| TC-AUTH-013 | F001 | UC-AUTH-004 | Refresh rotation; old token reuse → 401 | P0 | PASS | - |
| TC-AUTH-014 | F001 | UC-AUTH-005 | Logout clears session (device, all apps) | P0 | PASS | BUG-023/027 (fixed) |
| TC-AUTH-015 | F001 | UC-AUTH-005 | Restart after logout stays logged out | P0 | PASS | - |
| TC-AUTH-016 | F002 | UC-AUTH-006 | Forgot/reset password; old password invalid | P1 | PASS | - |
| TC-AUTH-017 | F001 | UC-AUTH-007 | Restart while logged in restores session | P0 | PASS | - |
| TC-AUTH-018 | F001 | UC-AUTH-007 | Unknown role fails closed (source) | P1 | PASS | - |
| TC-AUTH-019 | F001 | UC-AUTH-001 | Resend OTP cooldown (device) | P2 | PASS | - |
| TC-AUTH-020 | F001 | UC-AUTH-005 | Logout with expired access token | P0 | PASS | BUG-023 (fixed) |

## TC-CUS (Customer Portal)

| ID | Feature | UC | Test | Priority | Result | Bug |
|----|---------|----|------|----------|--------|-----|
| TC-CUS-001 | F004 | UC-CUS-001 | Home renders KPIs/cards/prices | P0 | PASS | - |
| TC-CUS-002 | F004 | UC-CUS-001 | Service prices in AED (was GBP) | P1 | PASS | BUG-019 (fixed) |
| TC-CUS-003 | F005 | UC-CUS-002 | Book service 3-step happy path | P0 | PASS | - |
| TC-CUS-004 | F005 | UC-CUS-002 | Past dates blocked in calendar | P1 | PASS | - |
| TC-CUS-005 | F005 | UC-CUS-002 | Booked slot excluded from availability | P1 | PASS | - |
| TC-CUS-006 | F005 | UC-CUS-002 | Booking ref shown as BK-xxx | P2 | PASS | BUG-020 (fixed) |
| TC-CUS-007 | F006 | UC-CUS-003 | Bookings list + filters | P0 | PASS | - |
| TC-CUS-008 | F007 | UC-CUS-004 | Cancel booking (dialog + confirm) | P0 | PASS | BUG-010 (fixed) |
| TC-CUS-009 | F007 | UC-CUS-004 | Cancel other user's booking → 404/403 | P1 | PASS | - |
| TC-CUS-010 | F012 | UC-CUS-005 | Add vehicle form validation ("Required") | P1 | PASS | - |
| TC-CUS-011 | F012 | UC-CUS-005 | Create vehicle API empty body → 400 | P1 | PASS | BUG-011 (fixed) |
| TC-CUS-012 | F013 | UC-CUS-005 | Delete vehicle | P1 | PASS | - |
| TC-CUS-013 | F011 | UC-CUS-005 | IDOR: update/delete other user's vehicle → 404 | P0 | PASS | - |
| TC-CUS-014 | F010 | UC-CUS-006 | Create breakdown; empty → 400 | P1 | PASS | - |
| TC-CUS-015 | F009 | UC-CUS-007 | Service status tracker renders | P1 | PASS | - |
| TC-CUS-016 | F014 | UC-CUS-008 | Pending approvals empty state | P1 | PASS | - |
| TC-CUS-017 | F014 | UC-CUS-009 | Invoice shows server data, VAT 5%, no fabrication | P0 | PASS (widget test) | - |
| TC-CUS-018 | F015 | UC-CUS-010 | Notifications read/read-all | P1 | PASS | - |
| TC-CUS-019 | F016 | UC-CUS-011 | Submit feedback (overall alias) | P1 | PASS | BUG-029 (fixed) |
| TC-CUS-020 | F017 | UC-CUS-012 | Create/list tickets | P2 | PASS | - |
| TC-CUS-021 | F018 | UC-CUS-013 | GDPR export | P2 | PASS | - |
| TC-CUS-022 | F020 | J011 | Offline queue + sync (unit) | P1 | PASS | - |
| TC-CUS-023 | F019 | J010 | Customer logout (was no-op) | P0 | PASS | BUG-027 (fixed) |

## TC-ADV (Advisor)

| ID | Feature | UC | Test | Priority | Result | Bug |
|----|---------|----|------|----------|--------|-----|
| TC-ADV-001 | F022 | UC-ADV-001 | Stats/KPI dashboard | P0 | PASS | - |
| TC-ADV-002 | F023 | UC-ADV-002 | Job cards list paged | P0 | PASS | - |
| TC-ADV-003 | F023 | UC-ADV-002 | page=0 → 200 (was 500) | P1 | PASS | BUG-007 (fixed) |
| TC-ADV-004 | F023 | UC-ADV-002 | size capped | P2 | PASS | - |
| TC-ADV-005 | F024 | UC-ADV-003 | Job detail renders timeline | P0 | PASS | - |
| TC-ADV-006 | F024 | UC-ADV-003 | Status labels for all 12 states | P1 | PASS | BUG-025 (fixed) |
| TC-ADV-007 | F024 | UC-ADV-003 | Status update invalid → 400 | P1 | PASS | - |
| TC-ADV-008 | F025 | UC-ADV-004 | Camera permission dialog + grant | P1 | PASS | - |
| TC-ADV-009 | F025 | UC-ADV-004 | Permission denied state UI | P1 | PASS | - |
| TC-ADV-010 | F025 | UC-ADV-004 | Permanent denial → settings | P2 | PASS (code) | BUG-026 (fixed) |
| TC-ADV-011 | F027 | UC-ADV-005 | Inspection create/update/summary | P1 | PASS | BUG-014 (fixed) |
| TC-ADV-012 | F027 | UC-ADV-005 | Cross-user draft → 403 | P1 | PASS | - |
| TC-ADV-013 | F034 | UC-ADV-011 | Media upload PNG → 200 + url | P1 | PASS | BUG-017 (fixed) |
| TC-ADV-014 | F034 | UC-ADV-011 | Fake file → 400 (magic bytes) | P1 | PASS | - |
| TC-ADV-015 | F032 | UC-ADV-009 | Reports today/week/month | P1 | PASS | - |
| TC-ADV-016 | F032 | UC-ADV-009 | Reports invalid range → 400 | P2 | PASS | BUG-012 (fixed) |
| TC-ADV-017 | F033 | UC-ADV-010 | Customer/vehicle search (staff-only) | P1 | PASS | - |
| TC-ADV-018 | F036 | UC-ADV-010 | Auto-price suggestion | P2 | PASS | - |
| TC-ADV-019 | F031 | UC-ADV-008 | Reminder CRUD | P2 | PASS | - |
| TC-ADV-020 | F026 | UC-ADV-004 | Check-in flow (E2E) | P0 | PASS | - |

## TC-SUP (Supervisor)

| ID | Feature | UC | Test | Priority | Result | Bug |
|----|---------|----|------|----------|--------|-----|
| TC-SUP-001 | F037 | UC-SUP-001 | KPIs/queue/routing (E2E) | P0 | PASS | - |
| TC-SUP-002 | F038 | UC-SUP-002 | Completion approve → invoice (E2E) | P0 | PASS | - |
| TC-SUP-003 | F038 | UC-SUP-002 | Reject → items reset (E2E path) | P1 | PASS | - |
| TC-SUP-004 | F039 | UC-SUP-003 | Work assignment requires jobCardId | P1 | PASS | - |
| TC-SUP-005 | F040 | UC-SUP-004 | Assigned jobs / technicians | P2 | PASS | - |
| TC-SUP-006 | F041 | UC-SUP-004 | Staff notifications feed | P2 | PASS | - |

## TC-TECH (Technician)

| ID | Feature | UC | Test | Priority | Result | Bug |
|----|---------|----|------|----------|--------|-----|
| TC-TECH-001 | F042 | UC-TECH-001 | Punch in/out/break lifecycle | P0 | PASS | - |
| TC-TECH-002 | F042 | UC-TECH-001 | Duplicate punch-in same day | P2 | PASS | - |
| TC-TECH-003 | F043 | UC-TECH-002 | Assigned jobs list/status | P1 | PASS | - |
| TC-TECH-004 | F044 | UC-TECH-002 | Work items start/complete (E2E isolation) | P0 | PASS | - |
| TC-TECH-005 | F045 | UC-TECH-003 | Parts request / escalation | P2 | PASS | - |
| TC-TECH-006 | F046 | UC-TECH-004 | Productivity metrics | P2 | PASS | - |
| TC-TECH-007 | F047 | UC-TECH-004 | Profile from JWT principal | P1 | PASS | - |

## TC-OWN (Owner)

| ID | Feature | UC | Test | Priority | Result | Bug |
|----|---------|----|------|----------|--------|-----|
| TC-OWN-001 | F049 | UC-OWN-001 | KPIs render on fresh login | P0 | PASS | BUG-028 (fixed) |
| TC-OWN-002 | F049 | UC-OWN-001 | KPI values match API (12 active etc.) | P0 | PASS | - |
| TC-OWN-003 | F050 | UC-OWN-001 | Messages send/view | P1 | PASS | - |
| TC-OWN-004 | F051 | UC-OWN-001 | Activity feed + CSV export | P1 | PASS | - |
| TC-OWN-005 | F052 | UC-OWN-003 | Job card register | P1 | PASS | - |
| TC-OWN-006 | F053 | UC-OWN-003 | Job cards CSV export | P1 | PASS | - |
| TC-OWN-007 | F054 | UC-OWN-004 | AR summary/records | P1 | PASS | - |
| TC-OWN-008 | F055 | UC-OWN-005 | Invoice PDF (404 on unknown) | P1 | PASS | - |
| TC-OWN-009 | F056 | UC-OWN-005 | Payment: unknown invoice → 404 | P1 | PASS | - |
| TC-OWN-010 | F059 | UC-OWN-006 | Inventory create; duplicate SKU (P3) | P2 | PASS (known P3) | BUG-016 (open) |
| TC-OWN-011 | F059 | UC-OWN-006 | Negative qty → 400 | P1 | PASS | BUG-015 (fixed) |
| TC-OWN-012 | F060 | UC-OWN-007 | Team create (empId required) | P1 | PASS | - |
| TC-OWN-013 | F061 | UC-OWN-007 | Subscription plan change | P2 | PASS | - |
| TC-OWN-014 | F062 | UC-OWN-007 | Feedback moderation inbox (staff-only) | P1 | PASS | - |
| TC-OWN-015 | F063 | UC-OWN-007 | API key create + authenticate; invalid → 401 | P1 | PASS | - |
| TC-OWN-016 | F067 | UC-OWN-007 | Branch create (owner-only) | P1 | PASS | - |

## TC-CRM

| ID | Feature | UC | Test | Priority | Result | Bug |
|----|---------|----|------|----------|--------|-----|
| TC-CRM-001 | F069 | UC-CRM-001 | Dashboard KPIs/pipeline | P0 | PASS | - |
| TC-CRM-002 | F071 | UC-CRM-002 | Lead create ×2 (no collision) | P0 | PASS | BUG-018 (fixed) |
| TC-CRM-003 | F071 | UC-CRM-002 | Lead update/score/activities | P1 | PASS | - |
| TC-CRM-004 | F075 | UC-CRM-003 | Task CRUD | P1 | PASS | - |
| TC-CRM-005 | F077 | UC-CRM-004 | Integrations list/connect contract | P2 | PASS | - |

## TC-SEC (Security)

| ID | Feature | UC | Test | Priority | Result | Bug |
|----|---------|----|------|----------|--------|-----|
| TC-SEC-001 | F082 | UC-SEC-001 | RBAC cross-role 403 matrix (21 checks) | P0 | PASS | - |
| TC-SEC-002 | F083 | UC-SEC-002 | No token / garbage / expired / forged JWT → 401 | P0 | PASS | - |
| TC-SEC-003 | F083 | UC-SEC-002 | Forged role escalation → 401/403 | P0 | PASS | - |
| TC-SEC-004 | F093 | UC-SEC-003 | IDOR vehicles/bookings/inspections | P0 | PASS | - |
| TC-SEC-005 | F085 | UC-SEC-004 | 429 rate limit + retry | P1 | PASS | - |
| TC-SEC-006 | F086 | UC-SEC-005 | Idempotency replay identical | P1 | PASS | - |
| TC-SEC-007 | F087 | UC-SEC-006 | Media fake file rejected | P1 | PASS | - |
| TC-SEC-008 | F084 | UC-SEC-006 | Invalid API key → 401 | P1 | PASS | - |
| TC-SEC-009 | F093 | UC-SEC-007 | Unknown route no longer 500 | P1 | PASS | BUG-006 (fixed) |

## TC-PERF / LIFECYCLE / UX

| ID | Test | Priority | Result | Notes |
|----|------|----------|--------|-------|
| TC-LC-001 | App launch cold/warm, session restore | P0 | PASS | device |
| TC-LC-002 | Background/foreground resume refresh (owner) | P1 | PASS | BUG-028 context |
| TC-LC-003 | Restart during form (vehicle form) — no data loss expectation | P2 | PASS | device |
| TC-LC-004 | System back navigation (no exit on sub-screens; exit confirm on root) | P1 | PASS | device |
| TC-LC-005 | Keyboard behavior (fields visible, no overflow observed structurally) | P2 | BLOCKED (visual) | semantics OK |
| TC-LC-006 | Small/large screen + text scaling | P2 | BLOCKED (visual) | no device resizing; semantics verified |
| TC-PF-001 | Dashboard payloads real (no fabricated zeros — BUG-028 family) | P0 | PASS | owner/crm verified vs API |
| TC-PF-002 | ReportService full-table scan (perf risk) | P2 | FAIL (documented) | BUG-012 note |
| TC-PF-003 | List rendering large datasets | P2 | NOT_RUN | no load env |
| TC-PF-004 | k6 load test | P2 | NOT_RUN | k6 binary unavailable locally; CI historical pass documented |
