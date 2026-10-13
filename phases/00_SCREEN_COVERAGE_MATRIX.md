# 00 — Screen-to-Phase Coverage Matrix

Every user-facing screen/tab/pushed page/primary sheet discovered during the
repository analysis, mapped to **exactly one owning implementation phase**.
`✓` = required layout/locale support for that screen in that phase. Dead-code
rows are marked for removal in the phase owning that module (after confirming
zero references).

Apps: **S** = staff_app, **O** = owner_app, **C** = customer_app, **R** = crm_app, **PKG** = shared packages.

---

## Shared work vs screen ownership

Foundation phases build the system but **own no production screens**, except
Phase 05 which owns the auth screens (mounted by every app):

| Phase | Owns (shared work — no screen ownership) |
|---|---|
| 00 | Visual validation only: runs an isolated prototype of six representative screens; owns **no** production screen |
| 01 | Tokens/themes/motion in `shared_core` + `main.dart` wiring |
| 02 | l10n infrastructure, locale provider, Arabic font, shared copy, formatting |
| 03A | Interactive primitive catalog in `shared_core` |
| 03B | Skeletons, empty/error, tables, chart theme, recipes |
| 04 | Shell/navigation chrome + page templates in `shared_core` |
| 05 | **Auth screens** (below) — shared by all four apps |

## Shared auth (owned by Phase 05)

| Module | Screen | File path | Route | Phase | Mobile | Tablet | Desktop | EN | AR/RTL |
|---|---|---|---|---|---|---|---|---|---|
| shared_auth (all apps) | AuthLoadingView | packages/shared_auth/lib/src/presentation/widgets/auth_loading_view.dart | `/` (all apps) | 05 | ✓ | ✓ | ✓ | ✓ | ✓ |
| shared_auth (all apps) | LoginView (password / email-OTP / SMS-OTP / registration) | packages/shared_auth/lib/src/presentation/pages/login_view.dart | `/login` (all apps) | 05 | ✓ | ✓ | ✓ | ✓ | ✓ |
| shared_auth (all apps) | ForgotPasswordView (3-stage recovery) | packages/shared_auth/lib/src/presentation/pages/forgot_password_view.dart | `/forgot-password` (all apps) | 05 | ✓ | ✓ | ✓ | ✓ | ✓ |
| S | SupervisorLoginView | apps/staff_app/lib/features/supervisor/presentation/supervisor_login_view.dart | `/supervisor-login` | 05 | ✓ | ✓ | ✓ | ✓ | ✓ |
| shared_auth | Legacy: AuthBackground, AuthHeader, PhoneInputField, OtpInputField | packages/shared_auth/lib/src/presentation/widgets/ | — | 05 (removed; dial-code data retained as `phone_country.dart`) | — | — | — | — | — |

## Staff app — Advisor

| Module | Screen | File path | Route | Phase | Mobile | Tablet | Desktop | EN | AR/RTL |
|---|---|---|---|---|---|---|---|---|---|
| Advisor | AdvisorHomeView (shell + Today tab) | lib/features/advisor/presentation/pages/advisor_home_view.dart | `/advisor_home_view` | 06 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Today dashboard content (stats, recent jobs, quick actions) | same file (`_AdvisorDashboardContent`) | tab (embedded) | 06 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Jobs list (search + status filter chips) | .../pages/advisor_jobs_view.dart | tab (embedded) | 06 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Reports (range switch, bar + pie charts, share) | .../pages/advisor_reports_view.dart | tab (embedded) | 06 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Job detail workspace | .../pages/advisor_job_detail_view.dart | `/advisor/job-detail` | 06 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Global search sheet | .../widgets/advisor_search_sheet.dart | sheet | 06 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor (+Technician) | Notification inbox sheet | .../widgets/advisor_notification_sheet.dart | sheet | 06 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Profile menu sheet | .../widgets/advisor_profile_sheet.dart | sheet | 06 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Stat detail dialog | .../widgets/advisor_stat_dialog.dart | dialog | 06 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Contact (call/WhatsApp/SMS) sheet | .../widgets/advisor_contact_sheet.dart | sheet | 06 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Estimate approval sheet | .../widgets/advisor_approval_sheet.dart | sheet | 06 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Vehicle/customer intake (new job card) | .../pages/vehicle_customer_view.dart | `/vehicle-customer` | 07A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | VIN/QR scan | .../pages/scan_vehicle_view.dart | `/scan-vehicle` | 07A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Vehicle check-in wizard (odometer, fuel, damage) | .../pages/advisor_vehicle_checkin_view.dart | `/advisor/check-in` | 07A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Brand/model/year pickers | .../widgets/select_brand_sheet.dart | sheets/dialog | 07A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Signature pad | .../widgets/advisor_signature_pad.dart | embedded/sheet | 07A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Choose inspection template | .../pages/choose_inspection_view.dart | `/choose-inspection` | 07B | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Inspection sheet (checkpoints + media/audio) | .../pages/inspection_sheet_view.dart | `/inspection-sheet` | 07B | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Inspection preview + submit | .../pages/inspection_preview_view.dart | `/inspection-preview` | 07B | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Vehicle body-condition panel + finding sheet | .../inspection_pages/presentation/vehicle_map/vehicle_body_condition_panel.dart | embedded + sheet | 07B | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Vehicle inspection map (vector painter) | .../vehicle_map/vehicle_inspection_map.dart | embedded | 07B | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Repair order / estimate builder | .../pages/repair_order_view.dart | `/repair-order` | 08 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Repair order preview (signature + approval method) | same file (`RepairOrderPreviewView`) | `/repair-order-preview` | 08 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Vehicle delivery checklist + finalize | .../pages/vehicle_delivery_view.dart | pushed (MaterialPageRoute) | 08 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Assign tasks to technician | .../pages/advisor_assign_tasks_view.dart | pushed (MaterialPageRoute) | 08 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Advisor | Legacy dead UI: AdvisorBody/TabPanel/Header/BottomNav/Fab/StatTile, AdvisorJobCardSheet, AdvisorRemindersPage, CustomerTagSheet | lib/features/advisor/presentation/widgets/ (multiple) | — | 08 (remove) | — | — | — | — | — |

## Staff app — Supervisor

| Module | Screen | File path | Route | Phase | Mobile | Tablet | Desktop | EN | AR/RTL |
|---|---|---|---|---|---|---|---|---|---|
| Supervisor | Dashboard shell (5 tabs + FAB + queue badge) | .../supervisor/presentation/supervisor_dashboard_view.dart + widgets/supervisor_scaffold.dart | `/supervisor_dashboard_view` | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | Today tab (attention queues, nav matrix, workload) | .../widgets/supervisor_dashboard_tab.dart | tab | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | Assign tab/sheet | .../widgets/supervisor_assign_sheet.dart | tab + `/supervisor/assign` | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | Queue tab (bookings & breakdowns, route to advisor) | .../widgets/supervisor_queue_tab.dart | tab + `/supervisor/queue` | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | QC review tab | .../widgets/supervisor_review_tab.dart | tab + `/supervisor/review` | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | Staff roster tab | .../widgets/supervisor_staff_tab.dart | `/supervisor/staff` | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | Schedule tab | .../widgets/supervisor_schedule_tab.dart | `/supervisor/schedule` | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | Operations report tab | .../widgets/supervisor_reports_tab.dart | `/supervisor/reports` | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | Active jobs tab | .../widgets/supervisor_jobs_tab.dart | `/supervisor/jobs` | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | QC checklist sheet (approve / send back) | .../widgets/qc_checklist_sheet.dart | sheet | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | Notification bell + sheet | .../widgets/staff_notification_bell.dart | app bar action + sheet | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | App bar (tab-aware titles) | .../widgets/supervisor_app_bar.dart | chrome | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | Sub-page wrapper | lib/core/router/app_router.dart (`SupervisorSubPageWrapper`) | wraps 6 routes | 09 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Supervisor | Legacy dead: SupervisorStatCard/StatsGrid | .../widgets/supervisor_stat_card.dart, supervisor_stats_grid.dart | — | 09 (remove) | — | — | — | — | — |

## Staff app — Technician

| Module | Screen | File path | Route | Phase | Mobile | Tablet | Desktop | EN | AR/RTL |
|---|---|---|---|---|---|---|---|---|---|
| Technician | Dashboard shell (4 tabs) + app bar | .../technician/presentation/technician_dashboard_view.dart | `/technician-dashboard` | 10 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Technician | Today (shift punch, active job, quick actions) | .../widgets/technician_today_view.dart | tab | 10 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Technician | Jobs queue (search + filters) | .../widgets/technician_jobs_view.dart | tab | 10 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Technician | Productivity (shift + counts) | .../widgets/technician_productivity_view.dart | tab | 10 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Technician | Job execution workspace | .../widgets/job_detail_sheet.dart | `/technician/job-detail` (+ pushed) | 10 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Technician | Parts request sheet | .../widgets/parts_request_sheet.dart | sheet | 10 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Technician | Escalation sheet | .../widgets/escalation_sheet.dart | sheet | 10 | ✓ | ✓ | ✓ | ✓ | ✓ |

## Staff app — Common

| Module | Screen | File path | Route | Phase | Mobile | Tablet | Desktop | EN | AR/RTL |
|---|---|---|---|---|---|---|---|---|---|
| Common | Staff profile (also supervisor/technician tab) | lib/features/common/presentation/profile_screen.dart | `/profile` + tabs | 11 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Common | Attendance (punch in/out + timeline) | .../common/presentation/staff_attendance_screen.dart | `/attendance` | 11 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Common | Shift details | .../common/presentation/simple_pages.dart | `/shift-details` | 11 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Common | Settings (app info, sync status, language) | .../common/presentation/simple_pages.dart | `/settings` | 11 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Common | Shimmer skeletons file (refactor to AppSkeleton) | .../common/presentation/staff_shimmer_skeletons.dart | embedded | 11 (via 03B) | ✓ | ✓ | ✓ | ✓ | ✓ |

## Owner app

| Module | Screen | File path | Route | Phase | Mobile | Tablet | Desktop | EN | AR/RTL |
|---|---|---|---|---|---|---|---|---|---|
| Owner | Dashboard shell (4 tabs) | lib/features/dashboard/presentation/dashboard_view.dart + widgets/dashboard_body.dart | `/owner-dashboard` | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | App bar (period, bell, profile) | .../widgets/owner_app_bar.dart | chrome | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Dashboard tab (KPI, register, analytics, quick actions) | .../widgets/owner_dashboard_page.dart | tab 0 | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Header banner (live pills) | .../widgets/header_banner.dart | section | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | KPI grid + cards | .../widgets/kpi_grid.dart, kpi_card.dart | section | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Job Card Register card | .../widgets/job_card_register_card.dart | section | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Sales trend chart + painter | .../widgets/sales_trend_card.dart, dual_line_painter.dart | section | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Sales vs expenses chart + painter | .../widgets/sales_vs_expenses_card.dart, bar_chart_painter.dart | section | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Quick actions row | .../widgets/quick_actions_row.dart, action_button.dart | section | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Top Sales tab + category cards | .../widgets/top_sales_page.dart, sales_category_card.dart | tab 1 | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Messages tab (broadcast + history) | .../widgets/messages_page.dart, message_tile.dart | tab 2 | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Activity feed tab | .../widgets/owner_activity_feed_tab.dart | tab 3 | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Period dropdown | .../widgets/period_dropdown.dart | control | 12 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Job cards list + tile + filter chips | lib/features/job_cards/presentation/pages/job_cards_list_view.dart + widgets | `/job-cards` | 13A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Job card detail | .../job_cards/presentation/pages/job_card_detail_view.dart | `/job-cards/detail` | 13A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Job status pipeline (stage filter) | .../dashboard/presentation/pages/job_status_view.dart | `/job-status` | 13A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Pending approvals | .../pages/pending_approvals_view.dart | `/pending-approvals` | 13A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Inventory (parts / suppliers / POs + add-part sheet) | .../pages/inventory_view.dart | `/inventory` | 13B | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Attendance (date picker, role filter) | .../pages/attendance_view.dart | `/attendance` | 13B | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Team (directory, add-member sheet, credentials dialog) | .../pages/team_view.dart | `/team` | 13B | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Accounts receivable (aging + ledger) | .../pages/accounts_receivable_view.dart | `/accounts-receivable` | 14 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Document expiry / compliance | .../pages/document_expiry_view.dart | `/document-expiry` | 14 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Feedback moderation | .../pages/feedback_moderation_view.dart | `/feedback-moderation` | 14 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Subscription | .../pages/subscription_view.dart | `/subscription` | 14 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Owner | Dead: CardTitle, FormLabel, KpiGridSkeleton | .../widgets/card_title.dart, form_label.dart, common/owner_shimmer_skeletons.dart | — | 14 (remove) | — | — | — | — | — |

## Customer app

| Module | Screen | File path | Route | Phase | Mobile | Tablet | Desktop | EN | AR/RTL |
|---|---|---|---|---|---|---|---|---|---|
| Customer | Workspace shell (4 tabs, no app bar) | lib/features/customer/presentation/customer_dashboard_view.dart + widgets/customer_scaffold.dart | `/customer_dashboard_view?tab=` | 15A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Home tab | .../widgets/customer_home_tab.dart (+ home header/attention/quick actions/garage summary/recent activity) | tab | 15A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Profile tab (+ profile rows, language switcher) | .../widgets/customer_profile_tab.dart, customer_profile_rows.dart | tab | 15A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Route-error fallback pages | lib/core/router/app_router.dart (`_RouteErrorPage`) | used by 4 builders | 15A | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Dead: empty fallback cards | .../widgets/customer_empty_fallbacks.dart | — | 15A (remove) | — | — | — | — | — |
| Customer | Bookings tab (+ booking item, failed item) | .../widgets/customer_bookings_tab.dart, customer_booking_item.dart, customer_failed_booking_item.dart | tab | 15B | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Vehicles/garage tab (+ vehicle record) | .../widgets/customer_vehicles_tab.dart, customer_vehicle_record.dart | tab | 15B | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Add / edit vehicle form | .../add_vehicle_view.dart | `/add-vehicle`, `/edit-vehicle/:id` | 15B | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Book service wizard (4 steps + progress + summary + action bar) | .../customer_book_service_view.dart + widgets/customer_booking_steps.dart, customer_booking_flow_progress.dart | `/customer_book_service_view?vehicleId=` | 16 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Booking success | .../customer_booking_success_view.dart | `/booking-success` | 16 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Booking detail (+ summary/service/vehicle panels, cancel) | .../customer_booking_detail_view.dart + widgets/customer_booking_detail_*.dart | `/customer_booking_detail` | 16 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Service status page + tracking tab (live/upcoming/idle, journey) | .../customer_service_status_page.dart + widgets/customer_service_status_tab.dart, customer_service_journey.dart, customer_status_details.dart | `/customer_service_status` | 17 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Approvals overview | .../customer_approvals_page.dart | `/customer_approvals` | 17 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Approval detail (estimate decision) | .../widgets/customer_approval_detail_view.dart | embedded via `?estimateId=` | 17 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Invoice detail | .../customer_invoice_detail_view.dart | `/invoice-detail` | 17 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Notifications inbox | .../customer_notifications_view.dart | `/notifications` | 18 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Roadside breakdown help | .../customer_breakdown_help_view.dart | `/customer_breakdown_help_view` | 18 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Breakdown result (sent / saved on device) | .../customer_breakdown_result_view.dart | `/customer_breakdown_result` | 18 | ✓ | ✓ | ✓ | ✓ | ✓ |
| Customer | Feedback (3-step rating) | .../customer_feedback_view.dart | `/feedback` (deep link only — wire entry point in this phase) | 18 | ✓ | ✓ | ✓ | ✓ | ✓ |

## CRM app

| Module | Screen | File path | Route | Phase | Mobile | Tablet | Desktop | EN | AR/RTL |
|---|---|---|---|---|---|---|---|---|---|
| CRM | Workspace shell (8 tabs, drawer, app bar) | lib/features/crm_dashboard/presentation/crm_dashboard_view.dart + widgets/crm_drawer.dart, crm_app_bar.dart | `/crm_dashboard_view` | 19A | ✓ | ✓ | ✓ | ✓ | ✓ |
| CRM | Dashboard tab (KPI grid, attention queue, channels, activity, recent leads) | .../widgets/crm_dashboard_page.dart + pipeline/followups/channel/activity/recent-leads widgets | tab 0 | 19A | ✓ | ✓ | ✓ | ✓ | ✓ |
| CRM | Leads page (+ kanban board) | .../widgets/crm_leads_page.dart, crm_kanban_view.dart | tab 1 | 19A | ✓ | ✓ | ✓ | ✓ | ✓ |
| CRM | Lead form / lead detail sheets | .../widgets/lead_form_sheet.dart, lead_detail_sheet.dart | sheets | 19A | ✓ | ✓ | ✓ | ✓ | ✓ |
| CRM | Conversations page | .../widgets/crm_conversations_page.dart | tab 2 | 19B | ✓ | ✓ | ✓ | ✓ | ✓ |
| CRM | Sales team page | .../widgets/crm_sales_team_page.dart | tab 3 | 19B | ✓ | ✓ | ✓ | ✓ | ✓ |
| CRM | Tasks page (+ task form sheet) | .../widgets/crm_tasks_page.dart | tab 4 | 19B | ✓ | ✓ | ✓ | ✓ | ✓ |
| CRM | Reports page (charts) | .../widgets/crm_reports_page.dart | tab 5 | 19C | ✓ | ✓ | ✓ | ✓ | ✓ |
| CRM | Integrations page (+ connected sheet, connect sheet) | .../widgets/crm_integrations_page.dart, connect_integration_sheet.dart | tab 6 + sheets | 19C | ✓ | ✓ | ✓ | ✓ | ✓ |
| CRM | Settings page (toggles, language, dark decision) | .../widgets/crm_settings_page.dart | tab 7 | 19C | ✓ | ✓ | ✓ | ✓ | ✓ |
| CRM | Legacy navy/cyan constants (delete after migration) | .../presentation/crm_constants.dart | — | 19C (remove) | — | — | — | — | — |

---

## Coverage checks

- **Total mapped screens/pages/tabs/primary surfaces:** ~100 (excluding dead code).
- Every discovered screen is assigned to **exactly one** owning phase; foundation
  phases 00–04 own no production screens (shared work only); Phase 05 owns auth.
- Every screen carries Mobile/Tablet/Desktop + EN/AR(RTL) requirements (✓).
- Cross-cutting validation of every phase's output: **Phase 20**.
- Screens that require product confirmation before redesign (marked in their
  phase): `PendingApprovalsView` drill-down (13A), CRM conversation rows (19B),
  `/feedback` in-app entry point (18), CRM dark toggle honesty (19C).

## Phase status notes

- **Phase 05 (Auth)** and **Phase 06 (Staff: Advisor Home & Jobs)** are
  implemented (reports at `phases/reports/PHASE_05|06/`). The advisor rows above
  are delivered; the staff-intake rows (07A) and inspection rows (07B) remain
  pending. No row reassignments were required by Phase 06.
