# 00 — Verified Monorepo Coverage Matrix (Redesign v2)

**Document ID:** `phases/redesign_v2/00_COVERAGE_MATRIX.md`  
**Total Production Phases:** Exactly **21 Sequentially Gated Units** (Split from 16 to prevent session overload)  
**Total Verified User Surfaces:** Exactly **86 Surfaces** (67 Screens/Tabs + 19 Standalone Sheets/Dialogs)  
**Coverage Guarantee:** 100% of discovered surfaces assigned to an implementation phase  
**Status:** RECONCILED & AUDITED COVERAGE MATRIX  

---

## 1. Complete Cross-Application Surface-to-Phase Mapping

| Ref | App | Surface Name | Canonical Route | Target Archetype | Implementation Phase | Breakpoints Supported | Bilingual LTR/RTL |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| **A1** | Shared Auth | `AuthLoadingView` | `/` | Archetype 1: Auth | **Phase 05** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **A2** | Shared Auth | `LoginView` | `/login` | Archetype 1: Auth | **Phase 05** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **A3** | Shared Auth | `ForgotPasswordView` | `/forgot-password` | Archetype 1: Auth | **Phase 05** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **A4** | Shared Core | `LogoutDialog` | Dialog | Archetype 1: Auth | **Phase 05** | Centered Modal | Yes (LTR/RTL) |
| **S1** | Staff App | `AdvisorHomeView` (Tab 0) | `/advisor_home_view` | Archetype 4: Tactical Radar | **Phase 06** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **S2** | Staff App | `AdvisorJobsView` (Tab 1) | `/advisor_home_view` | Archetype 4: Tactical Radar | **Phase 06** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **S3** | Staff App | `AdvisorReportsView` (Tab 2)| `/advisor_home_view` | Archetype 8: Executive Desk | **Phase 06** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **S4** | Staff App | `AdvisorJobDetailView` | `/advisor/job-detail` | Archetype 4: Tactical Radar | **Phase 06** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **S5** | Staff App | `AdvisorSearchSheet` | Modal Sheet | Archetype 4: Tactical Radar | **Phase 06** | Sheet / Cmd+K Modal | Yes (LTR/RTL) |
| **S6** | Staff App | `AdvisorNotificationSheet`| Modal Sheet | Archetype 4: Tactical Radar | **Phase 06** | Sheet / Slide Drawer | Yes (LTR/RTL) |
| **S7** | Staff App | `AdvisorProfileSheet` | Modal Sheet | Archetype 11: Settings | **Phase 06** | Sheet / Side Drawer | Yes (LTR/RTL) |
| **S8** | Staff App | `AdvisorContactSheet` | Modal Sheet | Archetype 10: Comms | **Phase 06** | Bottom Sheet | Yes (LTR/RTL) |
| **S9** | Staff App | `AdvisorApprovalSheet` | Modal Sheet | Archetype 4: Tactical Radar | **Phase 06** | Bottom Sheet / Modal | Yes (LTR/RTL) |
| **S10** | Staff App | `AdvisorJobCardSheet` | Modal Sheet | Archetype 4: Tactical Radar | **Phase 06** | Bottom Sheet | Yes (LTR/RTL) |
| **S11** | Staff App | `AdvisorStatDialog` | Dialog | Archetype 4: Tactical Radar | **Phase 06** | Centered Modal | Yes (LTR/RTL) |
| **S12** | Staff App | `ScanVehicleView` | `/scan-vehicle` | Archetype 5: Intake Studio | **Phase 07** | Mobile & Tablet Camera | Yes (LTR/RTL) |
| **S13** | Staff App | `VehicleCustomerView` | `/vehicle-customer` | Archetype 5: Intake Studio | **Phase 07** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **S14** | Staff App | `AdvisorVehicleCheckinView`| `/advisor/check-in` | Archetype 5: Intake Studio | **Phase 07** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **S15** | Staff App | `VehicleDeliveryView` | `/vehicle-delivery` | Archetype 5: Intake Studio | **Phase 07** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **S16** | Staff App | `SelectBrandSheet` | Modal Sheet | Archetype 5: Intake Studio | **Phase 07** | Bottom Sheet | Yes (LTR/RTL) |
| **S17** | Staff App | `ChooseInspectionView` | `/choose-inspection` | Archetype 6: Inspection HUD| **Phase 08** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **S18** | Staff App | `InspectionSheetView` | `/inspection-sheet` | Archetype 6: Inspection HUD| **Phase 08** | Mobile, Tablet, Desktop | Yes (Diagram LTR) |
| **S19** | Staff App | `InspectionPreviewView` | `/inspection-preview` | Archetype 6: Inspection HUD| **Phase 08** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **S20** | Staff App | `RepairOrderView` | `/repair-order` | Archetype 4: Tactical Radar | **Phase 09** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **S21** | Staff App | `AdvisorAssignTasksView`| `/advisor/assign-tasks` | Archetype 4: Tactical Radar | **Phase 09** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **T1** | Staff App | `TechnicianDashboardView` | `/technician-dashboard` | Archetype 7: Tech Bay | **Phase 10** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **T2** | Staff App | `TechnicianTodayView` | Tab 0 | Archetype 7: Tech Bay | **Phase 10** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **T3** | Staff App | `TechnicianJobsView` | Tab 1 | Archetype 7: Tech Bay | **Phase 10** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **T4** | Staff App | `TechnicianProductivityView`| Tab 2 | Archetype 7: Tech Bay | **Phase 10** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **T5** | Staff App | `TechnicianJobDetailSheet`| Sheet | Archetype 7: Tech Bay | **Phase 10** | Bottom Sheet | Yes (LTR/RTL) |
| **T6** | Staff App | `PartsRequestSheet` | Sheet | Archetype 7: Tech Bay | **Phase 10** | Bottom Sheet | Yes (LTR/RTL) |
| **T7** | Staff App | `EscalationSheet` | Sheet | Archetype 7: Tech Bay | **Phase 10** | Bottom Sheet | Yes (LTR/RTL) |
| **V1** | Staff App | `SupervisorLoginView` | `/supervisor-login` | Archetype 1: Auth | **Phase 11** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **V2** | Staff App | `SupervisorDashboardView` | `/supervisor_dashboard_view` | Archetype 4: Tactical Radar | **Phase 11** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **V3** | Staff App | `SupervisorJobsTab` | `/supervisor/jobs` | Archetype 4: Tactical Radar | **Phase 11** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **V4** | Staff App | `SupervisorQueueTab` | `/supervisor/queue` | Archetype 4: Tactical Radar | **Phase 11** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **V5** | Staff App | `SupervisorReviewTab` | `/supervisor/review` | Archetype 6: Inspection HUD| **Phase 11** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **V6** | Staff App | `SupervisorStaffTab` | `/supervisor/staff` | Archetype 4: Tactical Radar | **Phase 11** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **V7** | Staff App | `SupervisorScheduleTab` | `/supervisor/schedule` | Archetype 4: Tactical Radar | **Phase 11** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **V8** | Staff App | `SupervisorReportsTab` | `/supervisor/reports` | Archetype 8: Executive Desk | **Phase 11** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **V9** | Staff App | `SupervisorAssignSheet` | Sheet | Archetype 4: Tactical Radar | **Phase 11** | Bottom Sheet | Yes (LTR/RTL) |
| **V10** | Staff App | `QcChecklistSheet` | Sheet | Archetype 6: Inspection HUD| **Phase 11** | Bottom Sheet | Yes (LTR/RTL) |
| **M1** | Staff App | `ProfileScreen` | `/profile` | Archetype 11: Settings | **Phase 12** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **M2** | Staff App | `StaffAttendanceScreen` | `/attendance` | Archetype 4: Tactical Radar | **Phase 12** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **M3** | Staff App | `ShiftDetailsPage` | `/shift-details` | Archetype 11: Settings | **Phase 12** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **M4** | Staff App | `SettingsPage` | `/settings` | Archetype 11: Settings | **Phase 12** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O1** | Owner App | `OwnerDashboardPage` | Tab 0 (`/owner-dashboard`) | Archetype 8: Executive Desk | **Phase 13** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O2** | Owner App | `TopSalesPage` | Tab 1 (`/owner-dashboard`) | Archetype 8: Executive Desk | **Phase 13** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O3** | Owner App | `MessagesPage` | Tab 2 (`/owner-dashboard`) | Archetype 10: Comms Console | **Phase 13** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O4** | Owner App | `OwnerActivityFeedTab` | Tab 3 (`/owner-dashboard`) | Archetype 8: Executive Desk | **Phase 13** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O5** | Owner App | `JobCardsListView` | `/job-cards` | Archetype 8: Executive Desk | **Phase 14** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O6** | Owner App | `JobCardDetailView` | `/job-cards/detail` | Archetype 8: Executive Desk | **Phase 14** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O7** | Owner App | `JobStatusView` | `/job-status` | Archetype 8: Executive Desk | **Phase 14** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O8** | Owner App | `PendingApprovalsView` | `/pending-approvals` | Archetype 8: Executive Desk | **Phase 14** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O9** | Owner App | `AccountsReceivableView`| `/accounts-receivable` | Archetype 8: Executive Desk | **Phase 15** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O10** | Owner App | `InventoryView` | `/inventory` | Archetype 8: Executive Desk | **Phase 15** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O11** | Owner App | `TeamView` | `/team` | Archetype 8: Executive Desk | **Phase 15** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O12** | Owner App | `AttendanceView` | `/attendance` | Archetype 8: Executive Desk | **Phase 15** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O13** | Owner App | `DocumentExpiryView` | `/document-expiry` | Archetype 8: Executive Desk | **Phase 15** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O14** | Owner App | `FeedbackModerationView`| `/feedback-moderation` | Archetype 8: Executive Desk | **Phase 15** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O15** | Owner App | `SubscriptionView` | `/subscription` | Archetype 11: Settings | **Phase 15** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **O16** | Owner App | `InventoryFilterSheet` | Modal Sheet | Archetype 8: Executive Desk | **Phase 15** | Bottom Sheet | Yes (LTR/RTL) |
| **C1** | Customer App| `CustomerHomeTab` | Tab 0 (`/customer_dashboard_view`)| Archetype 2: Digital Garage | **Phase 16** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C2** | Customer App| `CustomerBookingsTab` | Tab 1 (`/customer_dashboard_view`)| Archetype 2: Digital Garage | **Phase 16** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C3** | Customer App| `CustomerVehiclesTab` | Tab 2 (`/customer_dashboard_view`)| Archetype 2: Digital Garage | **Phase 16** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C4** | Customer App| `CustomerProfileTab` | Tab 3 (`/customer_dashboard_view`)| Archetype 11: Settings | **Phase 16** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C5** | Customer App| `AddVehicleView` | `/add-vehicle` | Archetype 3: Guided Flow | **Phase 16** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C6** | Customer App| `CustomerNotificationsView`| `/notifications` | Archetype 2: Digital Garage | **Phase 16** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C7** | Customer App| `CustomerBookServiceView`| `/customer_book_service_view` | Archetype 3: Guided Flow | **Phase 17** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C8** | Customer App| `CustomerBookingDetailView`| `/customer_booking_detail` | Archetype 2: Digital Garage | **Phase 17** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C9** | Customer App| `CustomerBookingSuccessView`| `/booking-success` | Archetype 3: Guided Flow | **Phase 17** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C10** | Customer App| `CustomerBreakdownHelpView`| `/customer_breakdown_help_view`| Archetype 2: Digital Garage | **Phase 17** | Mobile & Tablet | Yes (LTR/RTL) |
| **C11** | Customer App| `CustomerBreakdownResultView`| `/customer_breakdown_result` | Archetype 2: Digital Garage | **Phase 17** | Mobile & Tablet | Yes (LTR/RTL) |
| **C12** | Customer App| `CustomerServiceStatusPage`| `/customer_service_status` | Archetype 2: Digital Garage | **Phase 18** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C13** | Customer App| `CustomerApprovalsPage` | `/customer_approvals` | Archetype 2: Digital Garage | **Phase 18** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C14** | Customer App| `CustomerInvoiceDetailView`| `/invoice-detail` | Archetype 2: Digital Garage | **Phase 18** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **C15** | Customer App| `CustomerFeedbackView` | `/feedback` | Archetype 2: Digital Garage | **Phase 18** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **R1** | CRM App | `CrmDashboardPage` | Tab 0 (`/crm_dashboard_view`) | Archetype 9: Deal Radar | **Phase 19** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **R2** | CRM App | `CrmLeadsPage` | Tab 1 (`/crm_dashboard_view`) | Archetype 9: Deal Radar | **Phase 19** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **R3** | CRM App | `CrmTasksPage` | Tab 4 (`/crm_dashboard_view`) | Archetype 9: Deal Radar | **Phase 19** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **R4** | CRM App | `LeadDetailSheet` | Sheet | Archetype 9: Deal Radar | **Phase 19** | Bottom Sheet | Yes (LTR/RTL) |
| **R5** | CRM App | `LeadFormSheet` | Sheet | Archetype 3: Guided Flow | **Phase 19** | Bottom Sheet | Yes (LTR/RTL) |
| **R6** | CRM App | `CrmConversationsPage` | Tab 2 (`/crm_dashboard_view`) | Archetype 10: Comms Console | **Phase 20** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **R7** | CRM App | `CrmSalesTeamPage` | Tab 3 (`/crm_dashboard_view`) | Archetype 8: Executive Desk | **Phase 20** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **R8** | CRM App | `CrmReportsPage` | Tab 5 (`/crm_dashboard_view`) | Archetype 8: Executive Desk | **Phase 20** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **R9** | CRM App | `CrmIntegrationsPage` | Tab 6 (`/crm_dashboard_view`) | Archetype 11: Settings | **Phase 20** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **R10** | CRM App | `CrmSettingsPage` | Tab 7 (`/crm_dashboard_view`) | Archetype 11: Settings | **Phase 20** | Mobile, Tablet, Desktop | Yes (LTR/RTL) |
| **R11** | CRM App | `ConnectIntegrationSheet`| Sheet | Archetype 11: Settings | **Phase 20** | Bottom Sheet | Yes (LTR/RTL) |

---

## 2. Phase 06 (Staff Advisor Hub) Delivery Status — 2026-10-14

Evidence: `phases/redesign_v2/reports/REPORT_PHASE_06.md`.

| Ref | Surface | Status | Evidence |
| :-- | :-- | :-- | :-- |
| **S1** | `AdvisorHomeView` | ✅ Redesigned — WorkspaceAppBar + OfflineStatusPill + attention radar | `advisor_experience_test`, `advisor_phase06_shell_test`, goldens |
| **S2** | `AdvisorJobsView` | ✅ Redesigned — work-management list + desktop master–detail matrix | `advisor_experience_test`, `advisor_phase06_shell_test`, goldens |
| **S3** | `AdvisorReportsView` | ✅ Refined — report header + range + KPI + charts + export | `advisor_experience_test`, goldens |
| **S4** | `AdvisorJobDetailView` | ✅ Redesigned — WorkspaceAppBar + AppPageHeader(breadcrumbs) | `advisor_experience_test`, goldens |
| **S5** | `AdvisorSearchSheet` | ✅ Wired to shell `WorkspaceSearchShortcuts` (⌘K/Ctrl+K) | `advisor_phase06_shell_test` |
| **S6** | `AdvisorNotificationSheet` | ✅ Theme-migrated | theme guard |
| **S7** | `AdvisorProfileSheet` | ✅ Theme-migrated | theme guard |
| **S8** | `AdvisorContactSheet` | ✅ Theme-migrated | theme guard |
| **S9** | `AdvisorApprovalSheet` | ✅ Theme-migrated | theme guard |
| **S10** | `AdvisorJobCardSheet` | ✅ Rewired as jobs-list overflow preview (localized, theme-driven) | `advisor_jobs_view` |
| **S11** | `AdvisorStatDialog` | ✅ Theme-migrated | `advisor_experience_test` |

**Removed as obsolete (unreferenced legacy widgets superseded by the redesign):** `advisor_body.dart`, `advisor_header.dart`, `advisor_header_button.dart`, `advisor_avatar.dart`, `advisor_bottom_nav.dart`, `advisor_bottom_item.dart`, `advisor_fab.dart`, `advisor_stat_tile.dart`, `advisor_date_chip.dart`, `advisor_tab_panel.dart`, `advisor_job_cards_page.dart`, `advisor_approvals_page.dart`, `advisor_reminders_page.dart`, `advisor_reminder_row.dart`, `advisor_see_all_button.dart`, `advisor_tab_button.dart`, `advisor_status_badge.dart`.

---

## 3. Phase 06 Gate 2 Closure Status — 2026-10-14

Evidence: `reports/REPORT_PHASE_06_GATE_2_CLOSURE.md` (and `reports/REPORT_PHASE_06_GATE_2_AUDIT.md`).

| Item | Status | Evidence |
| :-- | :-- | :-- |
| Pending-sync count reactivity | ✅ Fixed + tested | `advisor_sync_reactivity_test` (3/0) |
| Dark-theme visual states | ✅ Captured + inspected | `advisor_states_dark_home_{390_en,390_ar}`, `advisor_states_dark_detail_1280_en` |
| Offline / pending-sync states | ✅ Captured + inspected | `advisor_states_offline_390_en`, `advisor_states_queued_390_en` |
| Loading / error / empty / no-match | ✅ Captured + inspected | `advisor_states_{loading,error,jobs_empty,jobs_nomatch}_390_en` |
| Search + results | ✅ Captured + inspected | `advisor_states_search_390_en` |
| Four modal sheets | ✅ Captured + inspected | `advisor_states_sheet_{notification,profile,contact,approval}_390_en` |
| Desktop jobs master-detail matrix | ✅ Captured + inspected | `advisor_states_jobs_matrix_1280_en` |
| Home `AsyncError` crash (`.value` throw) | ✅ Fixed (`.valueOrNull`) | `advisor_states_error_390_en`; 14 prior goldens unchanged |
| Live device/browser acceptance | ⚠️ **NOT PERFORMED** — auth-gated + non-interactive; not run at operator's direction | `REPORT_PHASE_06_GATE_2_CLOSURE.md` §4 |

**Gate 2 recommendation:** `CONDITIONAL — ACTIONS REQUIRED` (sole open item: live acceptance). **Product Owner approval: NOT claimed.**

