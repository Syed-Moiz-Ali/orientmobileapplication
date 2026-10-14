# PHASE 14 — Owner Application: Job Cards Management & Approvals

**Document ID:** `phases/redesign_v2/implementation/PHASE_14_OWNER_JOBS_APPROVALS.md`  
**Prerequisites:** Phase 13 Completed (`REPORT_PHASE_13.md`)  
**Target Package:** `apps/owner_app/lib/features/job_cards/` & `dashboard/`  
**Status:** READY FOR IMPLEMENTATION (Gate 14)  

---

## 1. Primary User & Engineering Objective
Redesign the Owner application's Job Cards Register, Job Detail audit views, live workshop job status monitors, and pending executive approvals queue using **Archetype 8: Executive Cockpit & Financial Desk**.

---

## 2. Real Repository File Paths
- `apps/owner_app/lib/features/job_cards/presentation/pages/job_cards_list_view.dart` (O5)
- `apps/owner_app/lib/features/job_cards/presentation/pages/job_card_detail_view.dart` (O6)
- `apps/owner_app/lib/features/dashboard/presentation/pages/job_status_view.dart` (O7)
- `apps/owner_app/lib/features/dashboard/presentation/pages/pending_approvals_view.dart` (O8)
- `apps/owner_app/test/features/job_cards/owner_job_cards_test.dart`

---

## 3. Screen Redesign Requirements
1. **`JobCardsListView` (O5) & `JobStatusView` (O7):**
   - High-density data register displaying all active workshop jobs.
   - Status chips: Filter by Intake, Inspection, WIP, QC, Ready for Delivery, Invoiced.
   - Desktop view leverages `AppTable` with sortable columns for Job #, Plate, Customer, Total AED, and Profit Margin %.
2. **`JobCardDetailView` (O6 - Executive Job Audit):**
   - Complete operational & financial breakdown: Parts margin %, labor profitability, assigned technicians, discount history, and invoice status.
3. **`PendingApprovalsView` (O8 - Executive Approvals Queue):**
   - Specialized review queue for advisor discounts (>15%), goodwill warranty repairs, and parts credit overrides.
   - One-tap "Approve" (Emerald) or "Reject with Comment" (Crimson) buttons.

---

## 4. Visual Acceptance Criteria
- Clean, auditable financial and operational views.
- Tables format numbers with tabular lining and fixed decimals (`AED 2,450.00`).
- Golden tests generated with real fonts loaded across Mobile, Tablet, and Desktop.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/owner_app` returns 0 errors and 0 warnings.
- `owner_job_cards_test.dart` passes 100% across all viewports.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Desktop (1280px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_14.md`.


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
