# UI/UX Screen Registry

Status values: `NOT_STARTED`, `ANALYZING`, `UX_DESIGNED`, `IMPLEMENTED`, `TESTING`, `VERIFIED`, `BLOCKED`.

| Role | Feature | Screen | Route | Old UI Audited | User Journey Defined | UX Redesigned | UI Rebuilt | Mobile Verified | Tablet Verified | Desktop Verified | Accessibility Verified | Functional QA | Automated Tests | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Shared | Authentication | Startup loading | `/` | Yes | Yes | Partial | Existing | No | No | No | No | No | Existing | ANALYZING |
| Shared | Authentication | Login | `/login` | Yes | Yes | Yes | Rebuilt from scratch | Source checked | Source checked | Source checked | Partial | Pending | Existing | IMPLEMENTED |
| Shared | Authentication | Forgot password | `/forgot-password` | Yes | Yes | Yes | Rebuilt from scratch | Source checked | Source checked | Source checked | Partial | Pending | Existing | IMPLEMENTED |
| Shared | Navigation | Adaptive app navigation | Shared shell pattern | Yes | Yes | Yes | Yes | Source checked | Source checked | Source checked | Partial | Pending | Added | IMPLEMENTED |
| Shared | Responsive | Responsive page patterns | Shared core package | Yes | Yes | Yes | Yes | Source checked | Source checked | Source checked | Partial | Pending | Added | IMPLEMENTED |
| Customer | Home and service | Customer dashboard | `/customer_dashboard_view` | Yes | Yes | Yes | Home rebuilt from scratch; shell partially rebuilt | Source checked | Source checked | Source checked | Partial | Pending | Existing | IMPLEMENTED |
| Customer | Booking | Book service | `/customer_book_service_view` | Yes | Yes | Yes | Rebuilt from scratch | Source checked | Source checked | Source checked | Partial | Pending | Existing | IMPLEMENTED |
| Customer | Breakdown | Breakdown help | `/customer_breakdown_help_view` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Customer | Booking | Booking list | Customer dashboard tab | Yes | Yes | Yes | Rebuilt from scratch | Source checked | Source checked | Source checked | Partial | Pending | Existing | IMPLEMENTED |
| Customer | Booking | Booking detail | `/customer_booking_detail` | Yes | Yes | Yes | Rebuilt from scratch | Source checked | Source checked | Source checked | Partial | Pending | Existing | IMPLEMENTED |
| Customer | Breakdown | Breakdown detail | `/customer_breakdown_detail` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Customer | Vehicles | Add/edit vehicle | `/add-vehicle`, `/edit-vehicle/:id` | Yes | Yes | Pending | Existing | Existing QA artifacts | Existing QA artifacts | Existing QA artifacts | No | No | Existing | ANALYZING |
| Customer | Booking | Booking success | `/booking-success` | Yes | Yes | Yes | Rebuilt from scratch | Source checked | Source checked | Source checked | Partial | Pending | Existing | IMPLEMENTED |
| Customer | Finance | Invoice detail | `/invoice-detail` | Yes | Yes | Pending | Existing | No | No | No | No | Partial | Existing | ANALYZING |
| Customer | Feedback | Feedback | `/feedback` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Customer | Service tracking | Service status | `/customer_service_status_view` | Yes | Yes | Pending | Existing | Existing QA artifacts | Existing QA artifacts | Existing QA artifacts | No | No | Existing | ANALYZING |
| Advisor | Home | Advisor dashboard | `/advisor_home_view` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Advisor | Check-in | Scan vehicle | `/scan-vehicle` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Advisor | Check-in | Vehicle/customer | `/vehicle-customer` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Advisor | Inspection | Choose inspection | `/choose-inspection` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Advisor | Inspection | Inspection sheet | `/inspection-sheet` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Advisor | Inspection | Inspection preview | `/inspection-preview` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Advisor | Repair order | Repair order | `/repair-order` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Advisor | Repair order | Repair order preview | `/repair-order-preview` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Technician | Work execution | Technician dashboard | `/technician-dashboard` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Supervisor | Operations | Supervisor dashboard | `/supervisor_dashboard_view` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Supervisor | Authentication | Supervisor login | `/supervisor-login` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Staff | Profile | Profile | `/profile` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Staff | Shift | Shift details | `/shift-details` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Staff | Settings | Settings | `/settings` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Owner | Overview | Owner dashboard | `/owner-dashboard` | Yes | Yes | Partial | Partial responsive rebuild | Source checked | Source checked | Source checked | Partial | Pending | Existing | IMPLEMENTED |
| Owner | Finance | Accounts receivable | `/accounts-receivable` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Owner | Compliance | Document expiry | `/document-expiry` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Owner | Operations | Job status | `/job-status` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Owner | Approvals | Pending approvals | `/pending-approvals` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Owner | Job cards | Job cards list | `/job-cards` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Owner | Job cards | Job card detail | `/job-cards/detail` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Owner | Inventory | Inventory | `/inventory` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Owner | Feedback | Feedback moderation | `/feedback-moderation` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Owner | Team | Team | `/team` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| Owner | Subscription | Subscription | `/subscription` | Yes | Yes | Pending | Existing | No | No | No | No | No | Existing | ANALYZING |
| CRM | Workspace | CRM dashboard | `/crm_dashboard_view` | Yes | Yes | Partial | Partial adaptive navigation rebuild | Source checked | Source checked | Source checked | Partial | Pending | Existing | IMPLEMENTED |
