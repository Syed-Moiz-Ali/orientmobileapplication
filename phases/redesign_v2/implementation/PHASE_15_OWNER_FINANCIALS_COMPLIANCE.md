# PHASE 15 — Owner Application: Financial Analytics, Inventory & Compliance

**Document ID:** `phases/redesign_v2/implementation/PHASE_15_OWNER_FINANCIALS_COMPLIANCE.md`  
**Prerequisites:** Phase 14 Completed (`REPORT_PHASE_14.md`)  
**Target Package:** `apps/owner_app/lib/features/dashboard/`  
**Status:** READY FOR IMPLEMENTATION (Gate 15)  

---

## 1. Primary User & Engineering Objective
Complete redesign of the Owner application's Accounts Receivable, Inventory Valuation, Team Attendance, Document Expiry, Feedback Moderation, and Subscription administration pages using **Archetype 8: Executive Cockpit & Financial Desk**.

---

## 2. Real Repository File Paths
- `apps/owner_app/lib/features/dashboard/presentation/pages/accounts_receivable_view.dart` (O9)
- `apps/owner_app/lib/features/dashboard/presentation/pages/inventory_view.dart` (O10)
- `apps/owner_app/lib/features/dashboard/presentation/pages/team_view.dart` (O11)
- `apps/owner_app/lib/features/dashboard/presentation/pages/attendance_view.dart` (O12)
- `apps/owner_app/lib/features/dashboard/presentation/pages/document_expiry_view.dart` (O13)
- `apps/owner_app/lib/features/dashboard/presentation/pages/feedback_moderation_view.dart` (O14)
- `apps/owner_app/lib/features/dashboard/presentation/pages/subscription_view.dart` (O15)
- `apps/owner_app/test/features/dashboard/owner_analytics_test.dart`

---

## 3. Screen Redesign Requirements
1. **`AccountsReceivableView` (O9):**
   - Aging buckets breakdown: Current (0-30 days), Overdue (31-60 days), Critical (60+ days) with customer debtor ledger.
2. **`InventoryView` (O10):**
   - Total stock valuation in AED, fast-moving parts reorder alerts, and modal filter sheet by supplier/category.
3. **`TeamView` & `AttendanceView` (O11 & O12):**
   - Workshop staff roster, clock-in status, daily overtime tallies, and commission calculations.
4. **`DocumentExpiryView` & `FeedbackModerationView` (O13 & O14):**
   - Trade license, environmental permit, and technician visa expiry tracking.
   - Customer star rating feed with one-tap moderation and review response actions.

---

## 4. Visual Acceptance Criteria
- Clean, financial-grade data tables with sortable column headers.
- Distinct color coding for overdue receivables and expiring permits (Brembo Crimson / Electric Amber).
- Golden tests generated with real fonts loaded across Mobile, Tablet, and Desktop.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/owner_app` returns 0 errors and 0 warnings.
- `owner_analytics_test.dart` passes 100% across all viewports.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Desktop (1280px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_15.md`.
