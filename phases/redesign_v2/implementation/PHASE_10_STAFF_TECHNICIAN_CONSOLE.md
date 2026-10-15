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
- **Shell Integration (Phase 04.1).** The technician shell header must be the shared `WorkspaceAppBar` (desktop uses `frosted: true` with the reduced-transparency fallback). Show `OfflineStatusPill` and set `DashboardShell(showOfflineBanner: false)` where the pill is shown. Use `AppPageHeader(breadcrumbs:)` on pushed job-detail pages; no global ⌘K search (job-scoped actions only). Acceptance: header/offline widget tests + refreshed mobile/tablet EN/AR goldens.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/staff_app` returns 0 errors and 0 warnings.
- `technician_dashboard_test.dart` passes 100% verifying labor timers and checklist state.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Tablet (768px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_10.md`.


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
