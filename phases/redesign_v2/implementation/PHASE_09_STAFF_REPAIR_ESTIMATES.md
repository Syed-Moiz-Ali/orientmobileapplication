# PHASE 09 — Staff Application: Repair Order Studio & Estimates

**Document ID:** `phases/redesign_v2/implementation/PHASE_09_STAFF_REPAIR_ESTIMATES.md`  
**Prerequisites:** Phase 08 Completed (`REPORT_PHASE_08.md`)  
**Target Package:** `apps/staff_app/lib/features/advisor/`  
**Status:** READY FOR IMPLEMENTATION (Gate 9)  

---

## 1. Primary User & Engineering Objective
Redesign the Repair Order and Service Estimate creation workflows. Replace standard tabular inputs with an intelligent Work Order Studio featuring real-time parts margin calculation, live inventory stock indicators, labor hour multipliers, and a high-trust customer estimate preview.

---

## 2. Real Repository File Paths
- `apps/staff_app/lib/features/advisor/presentation/pages/repair_order_view.dart` (S20)
- `apps/staff_app/lib/features/advisor/presentation/pages/advisor_assign_tasks_view.dart` (S21)
- `apps/staff_app/test/features/advisor/repair_order_test.dart`

---

## 3. Screen Redesign Requirements
1. **`RepairOrderView` (S20 - Dynamic Work Order Studio):**
   - Itemized smart grid grouping items into Parts, Labor Operations, and Sublet Work.
   - Live Inventory Pills: Displays stock availability (e.g. `In Stock • Bay 4` vs `Order from Supplier • 2h`).
   - Margin & Total Dock: Sticky footer showing Subtotal, Labor, VAT (5%), and Total in AED with live recalculation on quantity changes.
2. **Estimate Customer Share Integration:**
   - Formal invoice-style layout with workshop header, vehicle details, and itemized lines.
   - Tiered breakdown: Mandatory Safety Repairs vs Optional Enhancements.
   - One-tap WhatsApp deep link to share interactive estimate approval link directly with customer.
3. **`AdvisorAssignTasksView` (S21 - Visual Bay Dispatch):**
   - Technician cards showing active job load, specialty skills (Brakes, AC, Electrical), and estimated availability time.
   - One-tap task delegation and bay reassignment.

---

## 4. Visual Acceptance Criteria
- Clean, financial-grade estimate builder layout with high typography contrast.
- Zero horizontal layout overflows on narrow mobile screens.
- Golden tests generated with real fonts loaded across Mobile and Desktop.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/staff_app` returns 0 errors and 0 warnings.
- `repair_order_test.dart` passes 100% verifying price, tax, and discount math.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Desktop (1280px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_09.md`.
