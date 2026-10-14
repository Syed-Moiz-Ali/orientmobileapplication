# PHASE 10 — Staff Application: Technician Execution Console

**Document ID:** `phases/redesign_v2/implementation/PHASE_10_STAFF_TECHNICIAN_CONSOLE.md`  
**Prerequisites:** Phase 09 Completed (`REPORT_PHASE_09.md`)  
**Target Package:** `apps/staff_app/lib/features/technician/`  
**Status:** READY FOR IMPLEMENTATION (Gate 10)  

---

## 1. Primary User & Engineering Objective
Redesign the Technician execution experience using **Archetype 7: Task Execution Bay**. Provide a grease-friendly, distraction-free execution environment for workshop mechanics featuring large touch targets, live task stopwatch timers, and operational requisition sheets.

---

## 2. Real Repository File Paths
- `apps/staff_app/lib/features/technician/presentation/technician_dashboard_view.dart` (T1)
- `apps/staff_app/lib/features/technician/presentation/widgets/technician_today_view.dart` (T2)
- `apps/staff_app/lib/features/technician/presentation/widgets/technician_jobs_view.dart` (T3)
- `apps/staff_app/lib/features/technician/presentation/widgets/technician_productivity_view.dart` (T4)
- `apps/staff_app/lib/features/technician/presentation/widgets/job_detail_sheet.dart` (T5)
- `apps/staff_app/lib/features/technician/presentation/widgets/parts_request_sheet.dart` (T6)
- `apps/staff_app/lib/features/technician/presentation/widgets/escalation_sheet.dart` (T7)
- `apps/staff_app/test/features/technician/technician_dashboard_test.dart`

---

## 3. Screen Redesign Requirements
1. **`TechnicianDashboardView` (T1) & `TechnicianTodayView` (T2):**
   - High-contrast job cards with large typography, bold license plate badges, and customer promised times.
   - Pinned Active Job Banner: Displays active vehicle, current stage, and elapsed bay time.
2. **`TechnicianJobsView` (T3) & `JobDetailSheet` (T5):**
   - Interactive task checklist with high-touch checkbox toggles.
   - Live Task Stopwatch: Start / Pause / Complete timer tracking actual labor against billed book time.
   - Handover trigger to send vehicle directly to Supervisor QC upon completion.
3. **`TechnicianProductivityView` (T4):**
   - Personal efficiency ratio ticker (Billed Hours vs Clocked Hours), daily target progress bar, and rework alerts.
4. **Requisition & Escalation Sheets (T6 & T7):**
   - Rapid parts requisition sheet for requesting extra oil, filters, or brake hardware from the parts counter.
   - Escalation sheet for reporting seized bolts, hidden rust damage, or additional customer safety issues.

---

## 4. Visual Acceptance Criteria
- Grease-friendly UI with generous touch targets (minimum 48x48dp).
- Distinct color accents for active timer states (Cobalt = Running, Amber = Paused, Emerald = Complete).
- Golden tests generated with real fonts loaded across Mobile and Tablet.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/staff_app` returns 0 errors and 0 warnings.
- `technician_dashboard_test.dart` passes 100% verifying labor timers and checklist state.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Tablet (768px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_10.md`.
