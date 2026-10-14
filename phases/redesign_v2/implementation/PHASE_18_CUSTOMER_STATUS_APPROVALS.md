# PHASE 18 — Customer Application: Live Service Telemetry, Approvals & Invoicing

**Document ID:** `phases/redesign_v2/implementation/PHASE_18_CUSTOMER_STATUS_APPROVALS.md`  
**Prerequisites:** Phase 17 Completed (`REPORT_PHASE_17.md`)  
**Target Package:** `apps/customer_app/lib/features/customer/presentation/`  
**Status:** READY FOR IMPLEMENTATION (Gate 18)  

---

## 1. Primary User & Engineering Objective
Complete redesign of the Customer application's live job telemetry tracking, additional work authorization/approvals desk, itemized tax invoice viewing, and service review feedback using **Archetype 2: Digital Garage & Service Hub** and **Archetype 8: Executive Cockpit & Financial Desk**.

---

## 2. Real Repository File Paths
- `apps/customer_app/lib/features/customer/presentation/customer_service_status_page.dart` (C12)
- `apps/customer_app/lib/features/customer/presentation/customer_approvals_page.dart` (C13)
- `apps/customer_app/lib/features/customer/presentation/customer_invoice_detail_view.dart` (C14)
- `apps/customer_app/lib/features/customer/presentation/customer_feedback_view.dart` (C15)
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_approval_detail_view.dart`
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_service_journey.dart`
- `apps/customer_app/lib/features/customer/presentation/widgets/customer_status_service_panel.dart`
- `apps/customer_app/test/features/customer/customer_status_approvals_test.dart`

---

## 3. Screen Redesign Requirements
1. **`CustomerServiceStatusPage` (C12) & `customer_service_journey.dart`:**
   - **Live Service Telemetry Ribbon:** 5-stage animated timeline with real-time technician status, estimated completion timestamp, and active service bay name.
   - **Diagnostic Inspection Evidence:** Photo carousel of worn/damaged parts uploaded by technician during Phase 08 inspection.
2. **`CustomerApprovalsPage` (C13) & `customer_approval_detail_view.dart`:**
   - Additional repair items requested by service advisor with itemized labor + parts breakdown, high-priority safety callouts, and one-tap "Approve Item" / "Decline Item" buttons.
   - Real-time recalculation of total authorized amount in AED.
3. **`CustomerInvoiceDetailView` (C14):**
   - Clean, tax-compliant invoice breakdown: Subtotal, 5% UAE VAT, applied discounts, and payment settlement options (Apple Pay / Credit Card / Pay at Counter).
4. **`CustomerFeedbackView` (C15):**
   - Interactive 5-star workshop rating, technician rating, and structured feedback tags ("Fast Service", "Clean Bay", "Clear Advice").

---

## 4. Visual Acceptance Criteria
- Modern transparent glassmorphic telemetry cards on clean light neutral backgrounds.
- High-visibility safety indicators (Brembo Crimson / Warning Amber) for critical repair approvals.
- Golden tests generated with real fonts loaded across Mobile (390px EN/AR) and Tablet (834px EN).

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/customer_app` returns 0 errors and 0 warnings.
- `customer_status_approvals_test.dart` passes 100% across all viewports.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Tablet (834px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_18.md`.


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

