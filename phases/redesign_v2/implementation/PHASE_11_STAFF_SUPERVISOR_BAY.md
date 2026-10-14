# PHASE 11 — Staff Application: Supervisor Operations & Floor Management

**Document ID:** `phases/redesign_v2/implementation/PHASE_11_STAFF_SUPERVISOR_BAY.md`  
**Prerequisites:** Phase 10 Completed (`REPORT_PHASE_10.md`)  
**Target Package:** `apps/staff_app/lib/features/supervisor/`  
**Status:** READY FOR IMPLEMENTATION (Gate 11)  

---

## 1. Primary User & Engineering Objective
Complete redesign of the Workshop Supervisor workspace using **Archetype 4: Tactical Operations Radar** and **Archetype 6: Spatial Inspection HUD**. Deliver an interactive workshop floor management console covering bay scheduling, technician task queues, quality control approvals, and floor throughput reports.

---

## 2. Real Repository File Paths
- `apps/staff_app/lib/features/supervisor/presentation/supervisor_login_view.dart` (V1)
- `apps/staff_app/lib/features/supervisor/presentation/supervisor_dashboard_view.dart` (V2)
- `apps/staff_app/lib/features/supervisor/presentation/widgets/supervisor_jobs_tab.dart` (V3)
- `apps/staff_app/lib/features/supervisor/presentation/widgets/supervisor_queue_tab.dart` (V4)
- `apps/staff_app/lib/features/supervisor/presentation/widgets/supervisor_review_tab.dart` (V5)
- `apps/staff_app/lib/features/supervisor/presentation/widgets/supervisor_staff_tab.dart` (V6)
- `apps/staff_app/lib/features/supervisor/presentation/widgets/supervisor_schedule_tab.dart` (V7)
- `apps/staff_app/lib/features/supervisor/presentation/widgets/supervisor_reports_tab.dart` (V8)
- `apps/staff_app/lib/features/supervisor/presentation/widgets/supervisor_assign_sheet.dart` (V9)
- `apps/staff_app/lib/features/supervisor/presentation/widgets/qc_checklist_sheet.dart` (V10)
- `apps/staff_app/test/features/supervisor/supervisor_views_test.dart`

---

## 3. Screen Redesign Requirements
1. **`SupervisorDashboardView` (V2) & Bay Operations:**
   - Workshop Floor Grid: Visual status map of all 16 workshop bays colored by state (Occupied, Idle, Parts Delay, QC Pending).
   - Drag-and-drop or one-tap technician dispatch to clear floor bottlenecks.
2. **`SupervisorQueueTab` (V4) & `SupervisorScheduleTab` (V7):**
   - Active work queue with priority sorting (Urgent VIP, Promised Delivery Today, Insurance Wait).
   - Daily schedule matrix mapping technicians to shifts and bay assignments.
3. **`SupervisorReviewTab` (V5) & `QcChecklistSheet` (V10):**
   - Formal quality control inspection sheet: Road test checklist, torque wrench audit, fluid level confirmation, and final wash sign-off.
4. **`SupervisorReportsTab` (V8):**
   - Daily workshop floor throughput, rework rates, and technician labor utilization percentages.

---

## 4. Visual Acceptance Criteria
- Clean, tactical command center aesthetic with real-time floor status visibility.
- Zero horizontal layout overflows on narrow mobile screens.
- Golden tests generated with real fonts loaded across Mobile, Tablet, and Desktop.
- **Shell Integration (Phase 04.1).** The supervisor shell header must be the shared `WorkspaceAppBar` (desktop uses `frosted: true` with the reduced-transparency fallback). Show `OfflineStatusPill` and set `DashboardShell(showOfflineBanner: false)` where the pill is shown. Use `AppPageHeader(breadcrumbs:)` on pushed review/QC pages. Acceptance: header/offline widget tests + refreshed mobile/tablet/desktop EN/AR goldens.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze apps/staff_app` returns 0 errors and 0 warnings.
- `supervisor_views_test.dart` passes 100% verifying bay status mutations.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Desktop (1280px) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_11.md`.


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
