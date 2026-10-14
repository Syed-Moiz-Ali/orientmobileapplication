# PHASE 17 â€” Customer Application: Guided Service Booking & Roadside Breakdown

**Document ID:** `phases/redesign_v2/implementation/PHASE_17_CUSTOMER_BOOKING_WIZARD.md`  
**Prerequisites:** Phase 16 Completed (`REPORT_PHASE_16.md`)  
**Target Package:** `apps/customer_app/lib/features/customer/presentation/`  
**Status:** READY FOR IMPLEMENTATION (Gate 17)  

---

## 1. Primary User & Engineering Objective
Complete redesign of the Customer application's service booking flow, booking confirmation details, success presentation, and emergency roadside breakdown assistance using **Archetype 3: Guided Flow & Stepper Wizard** and **Archetype 2: Digital Garage & Service Hub**.

---

## 2. Real Repository File Paths
- `apps/customer_app/lib/features/customer/presentation/customer_book_service_view.dart` (C7)
- `apps/customer_app/lib/features/customer/presentation/customer_booking_detail_view.dart` (C8)
- `apps/customer_app/lib/features/customer/presentation/customer_booking_success_view.dart` (C9)
- `apps/customer_app/lib/features/customer/presentation/customer_breakdown_help_view.dart` (C10)
- `apps/customer_app/lib/features/customer/presentation/customer_breakdown_result_view.dart` (C11)
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_booking_steps.dart`
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_booking_flow_progress.dart`
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_booking_detail_summary.dart`
- `apps/customer_app/test/features/customer/customer_booking_test.dart`

---

## 3. Screen Redesign Requirements
1. **`CustomerBookServiceView` (C7) & `customer_booking_steps.dart`:**
   - **Step 1: Vehicle Selection:** Select vehicle from garage or quick add with plate recognition.
   - **Step 2: Service Package & Custom Requests:** Multi-select packages (e.g., Major Service, Brake Pad Inspection, AC Refresh) with upfront itemized estimates in AED.
   - **Step 3: Appointment Date & Time Bay:** Calendar day picker with real-time morning/afternoon slot availability chips.
   - **Step 4: Workshop or Valet Delivery:** Toggle between Self Drop-off at workshop or Valet Pick-up with address selector.
2. **`CustomerBookingDetailView` (C8) & `CustomerBookingSuccessView` (C9):**
   - Clean summary card with booking confirmation code, QR pass for workshop intake arrival, estimated service duration, and add-to-calendar action.
3. **`CustomerBreakdownHelpView` (C10) & `CustomerBreakdownResultView` (C11):**
   - High-contrast emergency assistance HUD: One-tap GPS pin-drop for tow truck dispatch, flat tire, battery jump-start, or lock-out help.
   - Live ETA radar with tow truck driver contact and direct hotline dialer.

---

## 4. Visual Acceptance Criteria
- Seamless step transitions with breadcrumb stepper indicator.
- Arabic RTL mirrored correctly with stepper progressing right-to-left while phone numbers, dates, and currency remain standard.
- Golden tests generated with real fonts loaded across Mobile (390px EN/AR) and Tablet (834px EN).

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/customer_app` returns 0 errors and 0 warnings.
- `customer_booking_test.dart` passes 100% across all viewports.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Tablet (834px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_17.md`.


---

## Styling Authority (Phase 01.1 — Mandatory)
All styling in this phase MUST resolve through the single centralized theme system. Do not select light/dark colors by hand.

- Standard Material roles -> `context.colors` (`ColorScheme`).
- Custom automotive/workshop roles -> `context.semanticColors` (`AppSemanticColors` ThemeExtension).
- **Forbidden:** `dark ? AppDarkColors.x : AppColors.x` ternaries; direct `AppColors.*` / `AppDarkColors.*` palette selection in feature widgets; hardcoded semantic hex; duplicate local theme systems or competing theme providers; hardcoded font styles, spacing, or radii where a theme or `AppDimensions` token exists.
- **Justified exceptions** (brand assets, theme construction, color previews, brightness-dependent behavior) must carry a one-line documented reason.
- Full rules: `00_CONCEPT_A_DESIGN_SYSTEM.md` Sec.6 and `reports/PHASE_01_1_THEME_ARCHITECTURE.md`.
