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
