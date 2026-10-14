# PHASE 19 — CRM Application: Deal Radar Dashboard, Pipeline Kanban & Lead Sheets

**Document ID:** `phases/redesign_v2/implementation/PHASE_19_CRM_DEAL_RADAR_PIPELINE.md`  
**Prerequisites:** Phase 18 Completed (`REPORT_PHASE_18.md`)  
**Target Package:** `apps/crm_app/lib/features/crm_dashboard/presentation/`  
**Status:** READY FOR IMPLEMENTATION (Gate 19)  

---

## 1. Primary User & Engineering Objective
Complete redesign of the CRM application's primary executive dashboard, Kanban deal pipeline, leads directory, tasks scheduler, and lead management sheets using **Archetype 9: Deal Radar & Pipeline Terminal** and **Archetype 3: Guided Flow & Stepper Wizard**.

---

## 2. Real Repository File Paths
- `apps/crm_app/lib/features/crm_dashboard/presentation/crm_dashboard_view.dart` (Shell)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_dashboard_page.dart` (R1)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_leads_page.dart` (R2)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_tasks_page.dart` (R3)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/lead_detail_sheet.dart` (R4)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/lead_form_sheet.dart` (R5)
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_kanban_view.dart`
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_kpi_card.dart`
- `apps/crm_app/lib/features/crm_dashboard/presentation/widgets/crm_pipeline_widget.dart`
- `apps/crm_app/test/features/crm/crm_pipeline_test.dart`

---

## 3. Screen Redesign Requirements
1. **`CrmDashboardPage` (R1):**
   - **Deal Velocity KPI Pods:** Total Pipeline Value (AED), Conversion Rate (%), Average Deal Cycle (Days), and Active Leads Count with trend indicators.
   - **Lead Conversion Funnel:** Visual stage progression (New Inquiry -> Contacted -> Estimate Sent -> Booked -> Closed Won).
2. **`CrmLeadsPage` (R2) & `crm_kanban_view.dart`:**
   - **Multi-View Toggle:** Switch between high-density operational data table and multi-column Kanban board.
   - **Interactive Stage Drag-and-Drop / Quick Select:** Updating lead stages directly updates backend `updateLeadStatus` provider.
   - Filter chips for Lead Source (WhatsApp, Instagram, Walk-in, Google Ads) and Assigned Agent.
3. **`CrmTasksPage` (R3):**
   - Daily follow-up checklist with priority flags, call reminders, and overdue badges.
4. **`LeadDetailSheet` (R4) & `LeadFormSheet` (R5):**
   - Comprehensive lead drawer showing customer contact info, vehicle interest, quote history, and one-tap WhatsApp / Phone launcher.
   - Streamlined lead creation sheet with instant customer lookup and auto-formatting phone inputs.

---

## 4. Visual Acceptance Criteria
- Clean, financial/SaaS data density with sharp typography and minimal decorative fluff.
- Responsive adaptation: Single column list on Mobile (<600px), multi-column responsive Kanban on Tablet (600-1023px) and Desktop (≥1024px).
- Golden tests generated with real fonts loaded across Mobile (390px EN/AR), Tablet (834px), and Desktop (1280px).

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/crm_app` returns 0 errors and 0 warnings.
- `crm_pipeline_test.dart` passes 100% across all viewports.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR), Tablet (834px), and Desktop (1280px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_19.md`.
