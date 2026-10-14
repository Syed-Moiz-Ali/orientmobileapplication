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
