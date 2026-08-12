# Orient Workshop — Feature Inventory (QA Audit)

> Complete inventory of features across the monorepo: 4 Flutter apps + Spring Boot backend.
> Compiled during the Phase 1 discovery; IDs referenced by use cases / test cases.

## A. Customer App (`apps/customer_app` — role: customer)

| ID | Module | Screen | User Action | API | Backend | Role | Status |
|----|--------|--------|-------------|-----|---------|------|--------|
| F001 | Auth | Login (OTP/Password) | Login via OTP or password | POST /auth/send-otp, /auth/verify-otp, /auth/login | AuthController | Guest | Tested |
| F002 | Auth | Forgot Password | Reset password via OTP | POST /auth/forgot-password, /auth/reset-password | AuthController | Guest | Tested |
| F003 | Auth | Register | Self-registration (customer only) | POST /auth/register | AuthController | Guest | Tested |
| F004 | Dashboard | Home tab | View KPIs, service cards, symptom cards | GET /customers/profile, /services/types, /customers/vehicles | CustomerController | customer | Tested |
| F005 | Bookings | Book a Service (3-step) | Select service → date/time slot → confirm | GET /services/types, /bookings/availability, POST /bookings | BookingController | customer | Tested |
| F006 | Bookings | My Bookings | List + filter bookings | GET /customers/bookings | BookingController | customer | Tested |
| F007 | Bookings | Booking Detail | View status flow, cancel booking | PUT /customers/bookings/{id}/status | BookingController | customer | Tested |
| F008 | Bookings | Booking Success | Confirmation + reference | (from POST /bookings) | — | customer | Tested |
| F009 | Status | Live Job Tracker | Track active service stages | GET /customers/services/active | ServiceTrackingService | customer | Tested |
| F010 | Breakdown | Roadside Help | Request breakdown | POST /customers/breakdowns | BreakdownService | customer | Tested |
| F011 | Vehicles | My Vehicles | List vehicles | GET /customers/vehicles | VehicleService | customer | Tested |
| F012 | Vehicles | Add/Edit Vehicle | Register or update vehicle | POST/PUT /customers/vehicles, /customers/vehicles/{id} | VehicleService | customer | Tested |
| F013 | Vehicles | Delete Vehicle | Delete a vehicle | DELETE /customers/vehicles/{id} | VehicleService | customer | Tested |
| F014 | Approvals | Estimates & Invoices | Approve/reject estimates; view invoices | GET /customers/approvals/pending, /customers/approvals/{id}, PUT /customers/approvals/{id}, GET /customers/invoices | CustomerApprovalService, InvoiceService | customer | Tested |
| F015 | Notifications | Notifications | View / mark read | GET /customers/notifications, PUT .../read, .../read-all | NotificationService | customer | Tested |
| F016 | Feedback | Feedback | Submit job feedback | POST /feedback | FeedbackService | customer | Tested |
| F017 | Tickets | Support Tickets | Create/view tickets | GET/POST /customers/tickets | TicketService | customer | Tested |
| F018 | Privacy | GDPR Export | Export personal data | GET /customers/data/export | DataPrivacyService | customer | Tested |
| F019 | Profile | Profile Sheet | View profile, logout | POST /auth/logout | AuthController | customer | Tested |
| F020 | Offline | Offline sync | Queue bookings/vehicles/breakdowns offline | /sync/** | SyncController | customer | Tested (unit) |

## B. Staff App (`apps/staff_app` — roles: advisor / supervisor / technician)

| ID | Module | Screen | User Action | API | Backend | Role | Status |
|----|--------|--------|-------------|-----|---------|------|--------|
| F021 | Auth | Role login (OTP) | Staff login | /auth/* | AuthController | staff | Tested |
| F022 | Advisor | Dashboard | KPIs, quick actions | GET /advisor/stats | AdvisorStatsService | advisor | Tested |
| F023 | Advisor | Job Cards | List/filter/search job cards | GET /advisor/job-cards | JobCardService | advisor | Tested |
| F024 | Advisor | Job Detail | View timeline, update status, assign tech | GET /advisor/job-cards/{id}, PUT .../status, .../technician | JobCardService | advisor | Tested |
| F025 | Advisor | Scan Vehicle | QR/VIN/plate scan (camera) | — (local) | — | advisor | Tested |
| F026 | Advisor | Check-in | Vehicle intake → job card | POST /advisor/bookings/{id}/check-in | AdvisorBookingService | advisor | Tested (E2E) |
| F027 | Advisor | Inspection | Create/update inspection, draft, summary | POST /inspections, PUT /inspections/{id}, .../draft, GET .../summary | InspectionService | advisor | Tested |
| F028 | Advisor | Repair Order | Create repair order + line items; send estimate | POST /repair-orders, POST /repair-orders/{id}/send | RepairOrderService | advisor | Tested (E2E) |
| F029 | Advisor | Work Items | Assign per-item work to technicians | GET /advisor/job-cards/{ref}/work-items, PUT /advisor/work-items/{id}/assign | WorkItemService | advisor | Tested (E2E) |
| F030 | Advisor | Approvals | Process internal approvals | GET /advisor/approvals/pending, POST /advisor/approvals/{id} | ApprovalService | advisor | Tested |
| F031 | Advisor | Reminders | CRUD reminders | GET/POST /advisor/reminders, DELETE /advisor/reminders/{id} | ReminderService | advisor | Tested |
| F032 | Advisor | Reports | Daily/weekly/monthly reports | GET /advisor/reports?range= | ReportService | advisor | Tested |
| F033 | Advisor | Search | Customer / vehicle search | GET /customers/search, /vehicles/search | SearchService | staff | Tested |
| F034 | Advisor | Media Upload | Photos/videos/audio for repair orders | POST /repair-orders/{id}/media | MediaService | staff | Tested |
| F035 | Advisor | Deliver Vehicle | Mark delivered | POST /advisor/job-cards/{ref}/deliver | JobCardService | advisor | Tested (E2E) |
| F036 | Advisor | Auto Price | AI-lite price suggestion | GET /advisor/auto-price | AutoPriceService | advisor | Tested |
| F037 | Supervisor | Dashboard/Queue | KPIs, booking queue, routing | GET /supervisor/kpis, /supervisor/bookings, PUT /supervisor/bookings/{id}/assign | SupervisorQueueService | supervisor | Tested (E2E) |
| F038 | Supervisor | Completion Review | Approve/reject completion; QC review | GET /supervisor/jobs/awaiting, PUT /supervisor/jobs/{id}/approve-completion, POST /supervisor/job-cards/{ref}/qc-review | SupervisorQueueService | supervisor | Tested (E2E) |
| F039 | Supervisor | Work Assignments | Create assignments | POST /work-assignments | WorkAssignmentService | supervisor | Tested |
| F040 | Supervisor | Staff/Schedule | Team view, schedule | GET /supervisor/assigned-jobs, /technicians | ReferenceDataService | supervisor | Tested |
| F041 | Supervisor | Notifications | Staff notification feed | GET/PUT /staff/notifications | NotificationService | staff | Tested |
| F042 | Technician | Attendance | Punch in/out, breaks | POST /technicians/attendance/* | AttendanceService | technician | Tested |
| F043 | Technician | Assigned Jobs | List/update assigned jobs | GET /technicians/assigned-jobs, PUT .../{id}/status | TechnicianJobService | technician | Tested |
| F044 | Technician | Work Items | Start/complete per-item work | GET/PUT /technicians/work-items/* | WorkItemService | technician | Tested (E2E) |
| F045 | Technician | Parts/Escalations | Request parts / escalate | POST /technician/parts-requests, /technician/escalations | NotificationService | technician | Tested |
| F046 | Technician | Productivity | Efficiency metrics | GET /technicians/productivity | TechnicianJobService | technician | Tested |
| F047 | Technician | Profile | View profile | GET /technicians/profile | TechnicianProfileService | technician | Tested |
| F048 | Common | Profile/Shift/Settings | Profile, shift details, sync status | /auth/me | AuthService | staff | Tested |

## C. Owner App (`apps/owner_app` — role: owner)

| ID | Module | Screen | User Action | API | Backend | Role | Status |
|----|--------|--------|-------------|-----|---------|------|--------|
| F049 | Dashboard | KPI Overview | View KPIs, charts, register | GET /owner/dashboard/kpis, /sales-trend, /profit-trend, /expenses-trend, /forecast, /job-card-register, /top-sales | OwnerDashboardService | owner | Tested |
| F050 | Dashboard | Messages | Send/view messages | GET/POST /owner/messages | MessageService | owner | Tested |
| F051 | Dashboard | Activity | Activity feed + export | GET /owner/activity, /owner/activity/export | ActivityService | owner | Tested |
| F052 | Job Cards | Job Card Register | Filter/drill into job cards | GET /owner/job-cards, PUT /owner/job-cards/{id}/status | OwnerJobCardService | owner | Tested |
| F053 | Job Cards | CSV Export | Export job cards | GET /owner/job-cards/export | OwnerJobCardService | owner | Tested |
| F054 | Accounts | Accounts Receivable | Aging summary/records | GET /owner/accounts-receivable/summary, /records | ArService | owner | Tested |
| F055 | Invoices | Invoices + PDF | View invoices, download PDF | GET /owner/invoices, /owner/invoices/{id}/pdf | InvoicePdfService | owner | Tested |
| F056 | Payments | Record Payment | Record payment vs invoice | POST /owner/payments | PaymentService | owner | Tested |
| F057 | Documents | Document Expiry | Expiring employee documents | GET /owner/documents/expiry | OwnerDocumentService | owner | Tested |
| F058 | Approvals | Approval Categories | View pending approvals | GET /owner/approvals/categories | OwnerApprovalService | owner | Tested |
| F059 | Inventory | Inventory + Suppliers + POs | Items, low stock, suppliers, purchase orders, receive | GET/POST /owner/inventory/* | InventoryService | owner | Tested |
| F060 | Team | Team & Roles | Staff management, deactivate | GET/POST/PUT /owner/team, PUT /owner/team/{id}/deactivate | TeamService | owner | Tested |
| F061 | Subscription | SaaS Plan | Change plan | GET/PUT /owner/subscription | SubscriptionService | owner | Tested |
| F062 | Moderation | Feedback Moderation | Moderate customer feedback | GET /feedback/pending, PUT /feedback/{id}/moderation | FeedbackService | staff | Tested |
| F063 | API Keys | API Keys | Manage API keys | GET/POST/DELETE /owner/api-keys | ApiKeyService | owner | Tested |
| F064 | Webhooks | Webhooks | Subscribe to outbound webhooks | GET/POST/DELETE /owner/webhooks | WebhookService | owner | Tested |
| F065 | Warranty | Warranties | Vehicle warranties | GET/POST /owner/warranties | WarrantyService | owner | Tested |
| F066 | Tickets | Support Desk | Support tickets | GET/POST /owner/tickets, PUT /owner/tickets/{id}/status | TicketService | owner | Tested |
| F067 | Branches | Branches | Branch management | GET/POST/PUT /branches | BranchService | owner | Tested |
| F068 | Profile | Profile/Logout | Logout | POST /auth/logout | AuthController | owner | Tested |

## D. CRM App (`apps/crm_app` — role: crmDashboard)

| ID | Module | Screen | User Action | API | Backend | Role | Status |
|----|--------|--------|-------------|-----|---------|------|--------|
| F069 | Dashboard | KPI Overview | CRM KPIs, pipeline | GET /crm/dashboard/kpis, /key-metrics | CrmDashboardService | crmDashboard | Tested |
| F070 | Dashboard | Charts | Channels, conversion, response times | GET /crm/channels, /conversion-trend, /response-times | CrmDashboardService | crmDashboard | Tested |
| F071 | Leads | Leads CRUD | Create/edit/delete leads | GET/POST /crm/leads, PUT/DELETE /crm/leads/{id} | LeadService | crmDashboard | Tested |
| F072 | Leads | Lead Analytics | Score, activities, stats, follow-ups | GET /crm/leads/{id}/score, .../activities, /crm/leads/stats, /crm/leads/follow-ups | LeadScoringService, LeadAnalyticsService | crmDashboard | Tested |
| F073 | Conversations | Conversations | Channel conversations | GET /crm/conversations | ConversationService | crmDashboard | Tested |
| F074 | Sales Team | Sales Team | Team performance | GET /crm/sales-team, /crm/team-members | SalesTeamService, TeamService | crmDashboard | Tested |
| F075 | Tasks | Tasks | Task CRUD | GET/POST/PUT/DELETE /crm/tasks | CrmTaskService | crmDashboard | Tested |
| F076 | Reports | Reports & Analytics | CRM reports | GET /crm/activity-feed | CrmDashboardService | crmDashboard | Tested |
| F077 | Integrations | Integrations | Connect/disconnect Meta/Zoho | GET /crm/integrations, PUT /crm/integrations/{name}/connect, POST .../disconnect|sync | IntegrationService, MetaLeadFetcher | crmDashboard | Tested |
| F078 | Settings | Settings | CRM settings | — | — | crmDashboard | Source-reviewed |

## E. Backend Cross-Cutting Features

| ID | Feature | API | Status |
|----|---------|-----|--------|
| F079 | OTP auth (SMS/email, dev fixed 123456, attempt cap) | /auth/* | Tested (BUG-009 fixed) |
| F080 | Password login + lockout | /auth/login | Tested |
| F081 | Refresh token rotation + family revocation | /auth/refresh | Tested |
| F082 | RBAC (7 roles, method security) | all | Tested |
| F083 | JWT filter (re-check user per request) | all | Tested |
| F084 | API keys (X-API-Key, SHA-256 at rest) | /owner/api-keys | Tested |
| F085 | Rate limiting (bucket4j, 100/min, 20/min auth) | all | Tested |
| F086 | Idempotency keys (7-day TTL, replay) | /sync/** | Tested |
| F087 | Media upload (magic-byte validation) | /repair-orders/{id}/media | Tested (BUG-017 fixed) |
| F088 | Webhooks (HMAC-signed outbound) | /owner/webhooks | Source-reviewed |
| F089 | ShedLock scheduled jobs (documents, invoices, OTP, reminders, idempotency) | — | Source-reviewed |
| F090 | WhatsApp integration (webhook + send) | /whatsapp/* | Source-reviewed |
| F091 | GDPR export/erasure | /customers/data/* | Tested |
| F092 | Invoice PDF (openpdf, UAE VAT 5%) | /owner/invoices/{id}/pdf | Tested |
| F093 | Notifications (in-app, per-role) | /notifications, /customers/notifications, /staff/notifications | Tested |
| F094 | Branch scoping | /branches, branch_id on entities | Tested |
| F095 | Offline sync engine (15 entity types) | /sync/** | Tested (unit + E2E) |

## Screens Inventory (on-device verified)

| App | Screens verified on-device |
|-----|---------------------------|
| customer_app | Splash/login, Home, Status, Bookings (+detail/success), Book Service 3-step, Vehicles (+add form), Approvals, Breakdown Help, Profile sheet, Notifications (source), Feedback (source) |
| staff_app | Login (OTP), Advisor Dashboard, Jobs (+detail), Reports, Scan (permissions), Profile/Logout, Supervisor (E2E API), Technician (API) |
| owner_app | Login (OTP), Dashboard (KPIs/charts/quick actions), Top Sales/Messages/Activity (nav), Job Cards (API) |
| crm_app | Login (OTP), Dashboard (KPIs/pipeline), Drawer (all 8 modules), Leads (API) |
