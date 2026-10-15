# PHASE 17 — Customer Application: Guided Service Booking & Roadside Breakdown

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

## Styling Authority (Phase 01.1 � Mandatory)
All styling in this phase MUST resolve through the single centralized theme system. Do not select light/dark colors by hand.

- Standard Material roles -> `context.colors` (`ColorScheme`).
- Custom automotive/workshop roles -> `context.semanticColors` (`AppSemanticColors` ThemeExtension).
- **Forbidden:** `dark ? AppDarkColors.x : AppColors.x` ternaries; direct `AppColors.*` / `AppDarkColors.*` palette selection in feature widgets; hardcoded semantic hex; duplicate local theme systems or competing theme providers; hardcoded font styles, spacing, or radii where a theme or `AppDimensions` token exists.
- **Justified exceptions** (brand assets, theme construction, color previews, brightness-dependent behavior) must carry a one-line documented reason.
- Full rules: `00_CONCEPT_A_DESIGN_SYSTEM.md` Sec.6 and `reports/PHASE_01_1_THEME_ARCHITECTURE.md`.

---

## Centralized Widgets (Phase 01.2 — Mandatory)
All UI in this phase MUST reuse `packages/shared_core` centralized widgets. Never build a per-app duplicate when a shared widget exists.

- Use existing: `WorkspaceAppBar`, `DashboardShell`, `OfflineStatusPill`, `AppBreadcrumbs`, `AppPageHeader`, `AppMasterDetailScaffold`, `AppTable`, `AppCard`, `AppKpiCard`, `AppListSurface`, `AppRecordRow`, `AppSearchField`, `AppTextField`, `AppDropdownButton`, `AppFilterBar` / `AppDateRangeField` / `AppPaginationFooter` (01.2), `AppCommandPalette` + `WorkspaceSearchShortcuts` (01.2), `AppStepper` / `AppTimeline` / `AppTrendStat` (01.2), `AppBottomSheet`, `AppConfirmationDialog`, `AppSelectionSheet`, `EmptyState`, `ErrorView`, `AppSkeleton`, `LoadingIndicator`, `StatusPill`, `SectionHeader`, `AppActionBar`, `PrimaryButton`.
- If a needed widget does NOT exist in `shared_core`: create it in `packages/shared_core/lib/src/widgets/` (theme-driven via `context.colors` / `context.semanticColors`, EN/AR, responsive, a11y), export from `shared_core.dart`, add widget tests + goldens, THEN use it in this phase. Do not create `apps/*/lib/.../widgets/` copies.
- Forbidden: app-local copies of shared primitives, hardcoded spacing/radii/fonts, hardcoded colors, bespoke app bars/shells.
- Acceptance: grep shows zero new app-local duplicates; new shared widgets have tests + docs.


---

## Full 100% Redesign Mandate (Binding)
This phase is a SCREEN-LEVEL REDESIGN, not a color refresh, spacing tweak, or bug-fix pass. Minimal-change execution FAILS this phase.

- Rebuild every owned screen composition from its archetype (see 00_SCREEN_ARCHETYPES.md): new visual hierarchy, layout, spacing rhythm, section order, interaction patterns, responsive behavior. The finished screen must look visibly different from the old one side-by-side.
- FORBIDDEN as the whole change: only swapping colors/fonts/padding, only wrapping old layout in new cards, keeping obsolete headers/lists/forms because they exist. If the diff is palette + spacing only, reject and rework.
- Each screen gets a task-specific composition (never the same header + KPI cards + grid + list template on every screen). Attention/action content outranks passive metrics. Remove dead sections, kill obsolete widgets (verify zero references first, like REPORT_PHASE_06 S-section did with 17 legacy files).
- Must use Concept A tokens + centralized shared_core widgets (01.2 block); no per-app duplicates.
- Proof required in report: before/after composition table per screen + deleted-obsolete-files list + side-by-side screenshots. Reviewer compares old vs new at 390 + 1280 EN/AR. If it still resembles the old UI, Gate 2 FAILS.

---

## Airbnb-Grade Mandate (Phases 16-18, Customer Only)
This phase MUST follow `phases/redesign_v2/00_AIRBNB_GRADE_ADDENDUM.md` on top of Concept A. Imagery-first cards, airy spacing (28/20/20), single primary CTA per screen, PriceBreakdownDock with tabular AED + trust line, TrustPill/ReviewRow where specified, 280ms sheet motion with reduced-motion fallback. Warm Airbnb microcopy EN/AR, zero hardcoded strings. Enterprise tables/rails/breadcrumbs/Cmd+K are FORBIDDEN here. Side-by-side old-vs-new 390 + 834 EN/AR in report; recolored enterprise form = Gate 2 FAIL.


---

## UX-Concepts Mandate (Binding)
Steal the UX CONCEPTS, design each screen for its own job. Never clone one approved screen onto the others.

- Extract principles from any approved reference (content owns viewport >=50% at 390, chrome budget ~112px + one control row, progressive disclosure, one primary CTA matching the screen verb, sticky wayfinding over scrolling work, 48dp targets) and apply each screen according to ITS task with a DIFFERENT layout sharing ONE design language.
- Cloning: two screens in this phase reading as the same page with swapped text = Gate 2 FAIL. Forbidden patterns: same header + KPI + grid + list template everywhere, pasting one screen verdict/CTA/card pattern where the decision differs, decorative sections without task purpose.
- Proof in phase report: per-screen task-to-concept-to-composition table + viewport% at 390 EN + side-by-side PNGs showing different layouts, one language.

---

## SaaS Rework Mandate (Binding — Phase 05+)
Rework UI, UX, style, layout, EVERYTHING for every owned screen to SaaS-product grade. Enhance fully, include what is needed, remove what is not. Partial polish FAILS.

- INCLUDE (add if missing): primary task CTA + secondary path, loading/skeleton, empty, no-match, error+retry, offline-queued, permission-denied, success/confirmation, destructive-confirm, responsive 320/390/768/1280/1440 behavior, 1.3x text, dark + RTL (plates/VIN/phone/money LTR), semantics/focus/48dp/reduced-motion, EN/AR keys with parity, analytics-ready empty/error hooks where the app tracks them. If the screen real workflow needs it and it is absent, ADD it with shared_core widgets.
- REMOVE (delete if present): dead sections with no data/action, obsolete widgets after zero-reference check, decorative charts/gauges/cards without business meaning, duplicated headers/banners/chrome, stacked double CTAs, placeholder copy, hardcoded strings/hex, per-app duplicates of shared widgets, steps/fields the workflow never uses. Every deletion listed in the report with references proof.
- ENHANCE: recompose hierarchy so the screen primary job owns >=50% viewport at 390; controls fit task (not cloned); copy rewritten to product tone for its user (staff terse, customer warm per Airbnb addendum, owner financial-grade, CRM sales-grade).
- Proof in report: per-screen include/remove/enhance table (added / deleted with refs / recomposed) + before/after PNGs + viewport% at 390 EN. Unjustified leftover dead UI or missing required state = Gate 2 FAIL.
