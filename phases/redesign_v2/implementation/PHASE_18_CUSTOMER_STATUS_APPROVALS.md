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

---

## Responsive Mandate (Binding — Mobile + Tablet + Desktop)
Every owned screen MUST ship three intentional compositions. Stretching the phone layout wide = Gate 2 FAIL. Current desktop is unacceptable and must be rebuilt per below.

- MOBILE (<600px): single-column stream, bottom dock CTAs, bottom sheets, 48dp targets, thumb-reach primaries. No horizontal overflow at 320/360/390/430, 1.3x text clean.
- TABLET (600-1023px): real two-pane thinking - 40/60 master-detail where list+detail exist, 2-3 col metric grids (no carousels), sheets become 540px centered dialogs, rail or drawer nav. Verify 600/768/834/1024.
- DESKTOP (>=1024px, MANDATORY REBUILD): persistent collapsible rail (72 icon / 240 expanded, never bottom nav), max canvas 1440 centered, cards become dense sortable APPTable with sticky headers + hover + selection where rows exist, detail opens in side pane (AppMasterDetailScaffold) not full-page push where justified, filters become inline toolbar (not sheets), dialogs centered max 640, keyboard (Tab order, Enter submit, Esc dismiss, Cmd/Ctrl+K where search exists), hover/focus rings visible. Verify 1280 + 1440 with screenshots. Empty/loading/error states designed per width, not one stretched mobile card.
- Proof in report: per-screen 3-width matrix (390 + 768 + 1280 PNGs EN, plus AR spot) with composition notes + overflow audit. Any desktop PNG that is a stretched phone layout = FAIL that screen.

---

## Responsive Architecture Mandate (Binding — No Raw MediaQuery Checks)
Breakpoints live in exactly one file. Raw width literals in feature code = Gate 1 FAIL.

- FORBIDDEN in `apps/*/lib` and widget code: `MediaQuery.sizeOf(context).width` / `MediaQuery.of(context).size` comparisons (`>= 1024`, `< 600` etc.) and hardcoded breakpoint numbers (1024/768/600). The single justified home for width reads is `packages/shared_core/lib/src/layout/app_responsive.dart`.
- MANDATORY: `context.spec` / `spec.pick(compact:/medium:/expanded:/large:)` / `spec.isDesktop/isTablet/isCompact` / `AppAdaptiveBuilder` / `AppResponsivePage` / `AppAdaptiveGrid` / `AppSplitView`. Same behavior per width, centralized breakpoints only.
- Gap in the system (needs height-class, hinge margin, per-width motion)? ADD it to `app_responsive.dart` + tests, never inline in the screen.
- Guard enforces it (source-scan fails on raw width comparisons outside `app_responsive.dart`). Document any single justified exception with a one-line reason.


---

## Full Transformation Mandate (Binding — Polish Is Failure)
We do NOT want polish. We want FULL TRANSFORMATION. Recolored old screens, spacing tweaks, card-shadow edits, copy touch-ups presented as redesign = Gate 2 FAIL, no exceptions.

- Every owned screen must be unrecognizable next to its old self: new composition, new hierarchy, new flow. Reviewer holds old vs new side-by-side — if they hesitate telling them apart, the screen FAILED.
- Polish-only tells: same section order with new colors, same form with new inputs, same list with new tiles, same dashboard with new KPI cards, old IA with new fonts. All banned.
- Transformation proof per screen: what the old screen got WRONG (one line) + what the new composition does DIFFERENTLY (one line) + side-by-side PNGs. Missing row = screen not done.

---

## UI-Only Mandate (Binding — Zero Logic Changes)
This phase is UI TRANSFORMATION ONLY. Do not touch API logic or business behavior. Ever.

- FROZEN (byte-identical): API requests/responses/models, repositories, datasources, interceptors, providers/notifiers/state, validation rules, Hive boxes/queues/sync, routes/params/extras/nav semantics, auth/permissions, lifecycle/status semantics, persistence, deep links, DTO serialization.
- ALLOWED: widget composition, layout, styling via theme, strings (EN/AR keys), navigation CHROME (bars/rails/sheets presentation) — never destinations or args.
- Any diff outside `*/presentation/` + `*/widgets/` + l10n `*.arb` + test/golden files must carry a one-line justification or be reverted. New backend endpoints, mock production data, altered payloads, swallowed errors, changed validation = instant FAIL.
- Proof: report lists every non-UI file touched with reason; contracts section states frozen items verified green by suites.

