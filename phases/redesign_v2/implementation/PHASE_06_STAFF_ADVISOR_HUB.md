# PHASE 06 — Staff Application: Service Advisor Command Center

**Document ID:** `phases/redesign_v2/implementation/PHASE_06_STAFF_ADVISOR_HUB.md`  
**Prerequisites:** Phase 03 & Phase 04 Completed (`REPORT_PHASE_03.md`, `REPORT_PHASE_04.md`)  
**Target Package:** `apps/staff_app/lib/features/advisor/`  
**Status:** READY FOR IMPLEMENTATION (Gate 6)  

---

## 1. Primary User & Engineering Objective
Complete redesign of the Service Advisor operational workspace using **Archetype 4: Tactical Operations Radar**. Replace the generic dashboard cards and list views with the Live Workshop Radar, Job Pipeline Kanban/Matrix, 360-degree Vehicle Command Center, and operational action sheets.

---

## 2. Real Repository File Paths
- `apps/staff_app/lib/features/advisor/presentation/pages/advisor_home_view.dart` (S1)
- `apps/staff_app/lib/features/advisor/presentation/pages/advisor_jobs_view.dart` (S2)
- `apps/staff_app/lib/features/advisor/presentation/pages/advisor_reports_view.dart` (S3)
- `apps/staff_app/lib/features/advisor/presentation/pages/advisor_job_detail_view.dart` (S4)
- `apps/staff_app/lib/features/advisor/presentation/widgets/advisor_search_sheet.dart` (S5)
- `apps/staff_app/lib/features/advisor/presentation/widgets/advisor_notification_sheet.dart` (S6)
- `apps/staff_app/lib/features/advisor/presentation/widgets/advisor_profile_sheet.dart` (S7)
- `apps/staff_app/lib/features/advisor/presentation/widgets/advisor_contact_sheet.dart` (S8)
- `apps/staff_app/lib/features/advisor/presentation/widgets/advisor_approval_sheet.dart` (S9)
- `apps/staff_app/lib/features/advisor/presentation/widgets/advisor_job_card_sheet.dart` (S10)
- `apps/staff_app/lib/features/advisor/presentation/widgets/advisor_stat_dialog.dart` (S11)
- `apps/staff_app/test/features/advisor/advisor_views_test.dart`

---

## 3. Screen Redesign Requirements
1. **`AdvisorHomeView` (S1 - Live Workshop Radar):**
   - Top banner replaced with live workshop status bar: Bay Utilization %, active jobs count, and unread alerts.
   - Urgent Triage Pods: Filter jobs into actionable stages (Awaiting Intake, Inspection in Progress, Estimate Pending, QC Ready).
   - Dynamic Job Cards: Display vehicle name, license plate pill, customer name, and live bay timer.
2. **`AdvisorJobsView` (S2 - Job Pipeline Matrix):**
   - **Mobile (<600px):** Sticky filter carousel (All, Intake, Inspection, Approved, WIP, Ready), search bar, and swipeable job cards.
   - **Desktop (≥1024px):** Interactive Kanban board with drag-and-drop status progression OR sortable `AppTable` with plate search and technician assignment.
3. **`AdvisorJobDetailView` (S4 - Vehicle 360 Command Center):**
   - Pinned vehicle header: Plate number (`DXB • M 84920`), VIN, ODO reading, customer contact button.
   - Multi-tabbed execution view: Stages, Checklist, Estimates, Invoices, and Notes.
   - Quick Action Dock: One-tap WhatsApp update, Call Customer, View Inspection HUD, Generate Estimate.
4. **Modal Sheets & Dialogs (S5–S11):**
   - `AdvisorSearchSheet`: Instant Spotlight command palette (`Cmd+K`).
   - `AdvisorContactSheet`: WhatsApp deep link with localized message templates.
   - `AdvisorApprovalSheet`: Differential line-item viewer for customer approvals.

---

## 4. Visual Acceptance Criteria
- Advisor screens look like a luxury automotive command center, not a generic admin panel.
- Clear visual distinction between intake, inspection, and delivery stages.
- Golden tests generated with real fonts loaded across Mobile, Tablet, and Desktop.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/staff_app` returns 0 errors and 0 warnings.
- `advisor_views_test.dart` passes 100% across all state transitions.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR), Tablet (768px), and Desktop (1280px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_06.md`.
