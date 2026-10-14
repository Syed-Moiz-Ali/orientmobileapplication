# PHASE 16 — Customer Application: Digital Garage, Vehicles Tab & Profile

**Document ID:** `phases/redesign_v2/implementation/PHASE_16_CUSTOMER_GARAGE_HOME.md`  
**Prerequisites:** Phase 15 Completed (`REPORT_PHASE_15.md`), Phase 04 Navigation Shells  
**Target Package:** `apps/customer_app/lib/features/customer/presentation/`  
**Status:** READY FOR IMPLEMENTATION (Gate 16)  

---

## 1. Primary User & Engineering Objective
Complete redesign of the Customer application's primary home landing experience, vehicle registry, personal garage, user profile, and push notifications feed using **Archetype 2: Digital Garage & Service Hub** and **Archetype 11: System Configuration & User Settings**.

---

## 2. Real Repository File Paths
- `apps/customer_app/lib/features/customer/presentation/customer_dashboard_view.dart` (Dashboard Shell)
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_home_tab.dart` (C1)
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_bookings_tab.dart` (C2)
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_vehicles_tab.dart` (C3)
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_profile_tab.dart` (C4)
- `apps/customer_app/lib/features/customer/presentation/add_vehicle_view.dart` (C5)
- `apps/customer_app/lib/features/customer/presentation/customer_notifications_view.dart` (C6)
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_vehicle_record.dart`
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_home_garage_summary.dart`
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_plate_chip.dart`
- `apps/customer_app/test/features/customer/customer_garage_test.dart`

---

## 3. Screen Redesign Requirements
1. **`CustomerHomeTab` (C1):**
   - **Hero Garage Carousel:** Displays the customer's active vehicles with realistic vector silhouettes, license plate badge (UAE/GCC formatted with strict LTR number display), and immediate vehicle health indicator badge (`HealthScore` calculated on client as `(Passed/Total)*100`).
   - **Quick Action Bar:** 4 primary touch targets with cobalt accents: "Book Service", "Roadside SOS", "View Invoices", and "Vehicle History".
   - **Active Journey Ribbon:** Real-time progress bar if a job card is active (Intake -> Inspection -> In Repair -> Quality Check -> Ready for Pickup).
2. **`CustomerBookingsTab` (C2):**
   - Chronological service history cards showing date, workshop advisor, total spent in AED, and service checklist summary.
3. **`CustomerVehiclesTab` (C3) & `AddVehicleView` (C5):**
   - Detailed vehicle records showing VIN (strict non-mirrored LTR), odometer reading, insurance expiry countdown pill, and next scheduled service recommendation.
   - `AddVehicleView` redesigned as a sleek 3-step bottom sheet or full modal: Plate Details -> Make/Model/Year -> Mileage & Photo Upload.
4. **`CustomerProfileTab` (C4) & `CustomerNotificationsView` (C6):**
   - Profile settings with language toggle (EN/AR), saved payment methods, emergency contacts, and notifications settings.
   - Categorized push notification feed (Service Updates, Approvals Required, Invoices & Receipts).

---

## 4. Visual Acceptance Criteria
- Clean, premium consumer automotive styling: deep navy typography (`#0A192F`), subtle borders (`#E2E8F0`), and electric cobalt accents (`#1E40AF`).
- License plate badges render cleanly in authentic Dubai/Abu Dhabi plate styles without text clipping.
- Golden tests generated with real fonts loaded across Mobile (390px EN/AR) and Tablet (834px EN).

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/customer_app` returns 0 errors and 0 warnings.
- `customer_garage_test.dart` passes 100% across all viewports.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Tablet (834px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_16.md`.
