# PHASE 07 — Staff Application: Vehicle Intake & Scanning Studio

**Document ID:** `phases/redesign_v2/implementation/PHASE_07_STAFF_VEHICLE_INTAKE.md`  
**Prerequisites:** Phase 06 Completed (`REPORT_PHASE_06.md`)  
**Target Package:** `apps/staff_app/lib/features/advisor/`  
**Status:** READY FOR IMPLEMENTATION (Gate 7)  

---

## 1. Primary User & Engineering Objective
Redesign the end-to-end customer and vehicle intake experience using **Archetype 5: Express Vehicle Intake Studio**. Deliver an automotive telemetry intake flow featuring precision camera scanning, OCR license plate auto-fill, digital odometer scroller, physical fuel dial, vehicle delivery handover, and digital customer signature.

---

## 2. Real Repository File Paths
- `apps/staff_app/lib/features/advisor/presentation/pages/scan_vehicle_view.dart` (S12)
- `apps/staff_app/lib/features/advisor/presentation/pages/vehicle_customer_view.dart` (S13)
- `apps/staff_app/lib/features/advisor/presentation/pages/advisor_vehicle_checkin_view.dart` (S14)
- `apps/staff_app/lib/features/advisor/presentation/pages/vehicle_delivery_view.dart` (S15)
- `apps/staff_app/lib/features/advisor/presentation/widgets/select_brand_sheet.dart` (S16)
- `apps/staff_app/test/features/advisor/intake_views_test.dart`

---

## 3. Screen Redesign Requirements
1. **`ScanVehicleView` (S12):**
   - Precision optical viewfinder HUD with target brackets, real-time VIN decode feedback, torch toggle, and fallback manual plate search.
2. **`VehicleCustomerView` (S13 - Express Intake Wizard):**
   - Progressive card deck flow: 1. Customer Phone/Name -> 2. Vehicle Make/Model/Year -> 3. Photo Capture -> 4. Digital Signature.
   - UAE plate component with Emirates selector (`Dubai`, `Abu Dhabi`, `Sharjah`, etc.) and code letter.
   - Hive offline persistence guaranteed: If internet drops during intake, the wizard caches data locally without blocking completion.
3. **`AdvisorVehicleCheckinView` (S14 - Digital Telemetry Cluster):**
   - Interactive physical fuel dial slider (Empty -> 1/4 -> 1/2 -> 3/4 -> Full) with colored fuel level arc.
   - Digital odometer drum picker with quick scrollers.
4. **`VehicleDeliveryView` (S15):**
   - Formal vehicle delivery handover sheet with final mileage capture, customer satisfaction rating, and delivery sign-off.

---

## 4. Visual Acceptance Criteria
- Expressive automotive telemetry styling for gauges and dials.
- Zero horizontal layout overflows on narrow mobile screens.
- Golden tests generated with real fonts loaded across Mobile and Tablet.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/staff_app` returns 0 errors and 0 warnings.
- `intake_views_test.dart` passes 100% including Hive offline intake simulation.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Tablet (768px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_07.md`.
