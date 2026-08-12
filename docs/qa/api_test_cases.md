# Orient Workshop — API Test Cases (QA Audit)

> Executed by `scripts/qa_api_suite.ps1` against the local backend (dev profile, MySQL).
> Full machine-readable results: `docs/qa/api_test_results.json` — **238 checks: 237 PASS, 1 FAIL (BUG-016, P3)**.
> Categories: functional happy path, negative, boundary, security/RBAC, IDOR, validation, idempotency, media.

## 1. System
| TC-API | Request | Expect | Result |
|--------|---------|--------|--------|
| API-001 | GET /health | 200 database UP | PASS |
| API-002 | GET /version | 200 | PASS |
| API-003 | GET /does-not-exist (auth) | 404 envelope (BUG-006) | PASS |
| API-004 | GET /api/v1/health (double context) | 401/404, no 500 | PASS |
| API-005 | GET with X-API-Version: 99 | 406 | PASS |

## 2. Auth
| TC-API | Request | Expect | Result |
|--------|---------|--------|--------|
| API-010 | POST /auth/send-otp (sms) | 200 | PASS |
| API-011 | POST /auth/send-otp (email) | 200 | PASS |
| API-012 | POST /auth/send-otp (invalid type) | 400 | PASS |
| API-013 | POST /auth/send-otp (empty body) | 400 | PASS |
| API-014 | POST /auth/send-otp (invalid phone "123") | 400 (BUG-005) | PASS |
| API-015 | POST /auth/verify-otp (wrong otp) | 400/401 | PASS |
| API-016 | POST /auth/verify-otp (empty/missing otp) | 400 | PASS |
| API-017 | 5 wrong OTPs then correct | 429 (BUG-009) | PASS |
| API-018 | Role logins (6 roles via provisioned users) | tokens + role | PASS |
| API-019 | GET /auth/me per role | own role | PASS |
| API-020 | GET /auth/me no token | 401 | PASS |
| API-021 | POST /auth/register (valid) | 200/201 | PASS |
| API-022 | POST /auth/register (bad email) | 400 | PASS |
| API-023 | POST /auth/register (weak pwd) | 400 | PASS |
| API-024 | POST /auth/register (duplicate phone) | 400/409 | PASS |
| API-025 | POST /auth/register (owner role) | 400 (customer-only) | PASS |
| API-026 | POST /auth/register (admin role) | 400 | PASS |
| API-027 | POST /auth/login (phone/email password) | 200 | PASS |
| API-028 | POST /auth/login (wrong password) | 400/401 | PASS |
| API-029 | POST /auth/login (unknown user) | 400/401 | PASS |
| API-030 | POST /auth/login (missing password) | 400 | PASS |
| API-031 | POST /auth/refresh (rotation) | 200 new pair | PASS |
| API-032 | POST /auth/refresh (reuse old) | 401 family revoked | PASS |
| API-033 | POST /auth/refresh (new still valid) | 200 | PASS |
| API-034 | POST /auth/refresh (garbage) | 400/401 | PASS |
| API-035 | POST /auth/logout | 200 | PASS |
| API-036 | POST /auth/forgot-password | 200 | PASS |
| API-037 | POST /auth/reset-password (wrong otp) | 400/401 | PASS |
| API-038 | POST /auth/reset-password (correct) | 200 | PASS |
| API-039 | Login after reset (old password dead) | 400/401 | PASS |
| API-040 | Lockout: 5 failures → 429 | 429 | PASS |

## 3. Security / RBAC / Token
| TC-API | Request | Expect | Result |
|--------|---------|--------|--------|
| API-050 | customer → /owner/dashboard/kpis | 403 | PASS |
| API-051 | advisor → /owner/dashboard/kpis | 403 | PASS |
| API-052 | customer → /crm/dashboard/kpis | 403 | PASS |
| API-053 | advisor → /crm/dashboard/kpis | 403 | PASS |
| API-054 | customer → /supervisor/kpis | 403 | PASS |
| API-055 | advisor → /supervisor/kpis | 403 | PASS |
| API-056 | customer → /advisor/stats | 403 | PASS |
| API-057 | owner → /advisor/stats | 200 (owner sees all) | PASS |
| API-058 | customer → /technicians/attendance/punch-in | 403 | PASS |
| API-059 | advisor → /branches | 403 | PASS |
| API-060 | customer → /customers/search | 403 | PASS |
| API-061 | customer → /feedback/pending | 403 | PASS |
| API-062 | advisor → /feedback/pending | 200 | PASS |
| API-063 | No token → protected | 401 | PASS |
| API-064 | Garbage token → 401 | 401 | PASS |
| API-065 | Forged JWT (expired exp) | 401 | PASS |
| API-066 | Forged JWT (no exp) | 401 | PASS |
| API-067 | Forged JWT (bad signature) | 401 | PASS |
| API-068 | Forged JWT (role escalation) | 401/403 | PASS |

## 4. Customer Portal
| TC-API | Request | Expect | Result |
|--------|---------|--------|--------|
| API-070 | GET /customers/profile | 200 | PASS |
| API-071 | GET/POST/PUT/DELETE /customers/vehicles | CRUD | PASS |
| API-072 | POST /customers/vehicles {} | 400 (BUG-011) | PASS |
| API-073 | PUT vehicle other user | 404 (IDOR) | PASS |
| API-074 | GET /bookings/availability (date) | 200 slots | PASS |
| API-075 | GET /bookings/availability (no date) | 400 | PASS |
| API-076 | POST /bookings (valid) | 200 + ref | PASS |
| API-077 | POST /bookings (past date) | 400 | PASS |
| API-078 | PUT /customers/bookings/{id}/status (body) | 200 | PASS |
| API-079 | PUT ...status?status=cancelled (query) | 200 (BUG-010) | PASS |
| API-080 | PUT ...status other booking | 404/403 | PASS |
| API-081 | POST /customers/breakdowns (valid) | 200 | PASS |
| API-082 | POST /customers/breakdowns {} | 400 (was 409) | PASS |
| API-083 | GET /services/types | 200 (AED) | PASS |
| API-084 | GET /customers/services/active | 200 | PASS |
| API-085 | GET /customers/notifications | 200 | PASS |
| API-086 | PUT notification read / read-all | 200 | PASS |
| API-087 | GET /customers/invoices, /approvals/pending | 200 | PASS |
| API-088 | POST /feedback (valid) | 200 (BUG-029) | PASS |
| API-089 | POST /feedback rating 9 / 0 | 400 | PASS |
| API-090 | GET /customers/tickets, POST | 200 | PASS |
| API-091 | GET /customers/data/export | 200 | PASS |
| API-092 | POST /notifications/device-token | 200 | PASS |

## 5. IDOR
| TC-API | Test | Result |
|--------|------|--------|
| API-100 | Customer A update/delete customer B vehicle | 404 PASS |
| API-101 | Victim still owns own vehicle | 200 PASS |

## 6. Advisor
| TC-API | Request | Expect | Result |
|--------|---------|--------|--------|
| API-110 | GET /advisor/stats | 200 | PASS |
| API-111 | GET /advisor/job-cards (paged) | 200 | PASS |
| API-112 | GET /advisor/job-cards?page=0 | 200 (BUG-007) | PASS |
| API-113 | GET /advisor/job-cards?size=9999 | 200 capped | PASS |
| API-114 | GET /advisor/technicians | 200 | PASS |
| API-115 | GET /advisor/approvals/pending | 200 | PASS |
| API-116 | POST /advisor/reminders (valid/empty) | 200 / 400 | PASS |
| API-117 | GET /advisor/reports?range=today | 200 | PASS |
| API-118 | GET /advisor/reports?range=invalid | 400 (BUG-012) | PASS |
| API-119 | GET /advisor/inventory/search, /auto-price | 200 | PASS |
| API-120 | GET /customers/search, /vehicles/search | 200 | PASS |
| API-121 | POST /inspections (valid) | 200 numeric id (BUG-014) | PASS |
| API-122 | PUT /inspections/{id} with returned id | 200 (BUG-014) | PASS |
| API-123 | GET /inspections/{id}/summary | 200 (BUG-014) | PASS |
| API-124 | GET /inspections/999999999/summary | 404 | PASS |
| API-125 | GET /inspections/{id}/draft as customer | 403/404 | PASS |

## 7. Supervisor
| API-130..142 | /supervisor/kpis, /advisor-jobs, /job-types, /revenue-metrics, /pending-statuses, /bookings, /breakdowns, /jobs/awaiting, /assignable-advisors, /assigned-jobs, /technicians/available, /departments, /technicians, /staff/notifications | 200 | PASS |
| API-143 | POST /work-assignments (items) | 200 | PASS |
| API-144 | POST /work-assignments {} | 400 | PASS |
| API-145 | customer qc-review | 403/404 | PASS |

## 8. Technician
| API-150 | GET /technicians/profile | 200 | PASS |
| API-151 | GET /technicians/assigned-jobs, /jobs, /work-items, /productivity | 200 | PASS |
| API-152 | POST attendance punch-in/out, break-start/end | 200 | PASS |
| API-153 | Duplicate punch-in same day | 200/409 | PASS |
| API-154 | customer punch-in | 403 | PASS |
| API-155 | POST /technician/parts-requests, /escalations | 200/400 | PASS |

## 9. Owner
| API-160..190 | dashboard KPIs/trends/forecast/register/top-sales, job-cards(+export CSV), jobs/status/pending/active, documents/expiry, approvals/categories, invoices(+pdf 404), AR summary/records, messages, activity(+export), subscription, team, inventory items/suppliers/POs (low-stock at /items/low-stock), warranties, tickets, webhooks, api-keys, branches | 200 | PASS |
| API-191 | POST /owner/inventory/items {} duplicate SKU | 409 expected — **200 (BUG-016 P3 open)** | FAIL |
| API-192 | POST /owner/inventory/items qtyOnHand -5 | 400 (BUG-015) | PASS |
| API-193 | POST /owner/payments unknown invoice | 404 | PASS |
| API-194 | API key auth (valid/invalid) | 200 / 401 | PASS |
| API-195 | POST /branches (owner) | 200 | PASS |

## 10. CRM
| API-200..220 | dashboard KPIs/channels/conversion/performance/response-times/lead-sources/key-metrics, leads(+stats/follow-ups), lead create×2/update/score/activities, tasks CRUD, integrations, conversations, sales-team, team-members, activity-feed | 200 | PASS |
| API-221 | POST /crm/leads (no external_id) ×2 | 200 both (BUG-018) | PASS |

## 11. Sync / Media
| TC-API | Test | Result |
|--------|------|--------|
| API-230 | POST /sync/bookings (staff) | 200/4xx PASS |
| API-231 | Same Idempotency-Key replay → identical body | PASS |
| API-232 | customer → /sync | 403 PASS |
| API-233 | POST /repair-orders/{id}/media PNG | 200 + url (BUG-017) PASS |
| API-234 | Fake .png (text bytes) | 400 magic-byte PASS |

## Summary
- Total API checks: **238** · Passed: **237** · Failed: **1** (BUG-016 — P3 duplicate-SKU-with-null-branch, DEFERRED)
- All fixes verified at API level: BUG-005, 006, 007, 009, 010, 011, 012, 014, 015, 017, 018, 029.
