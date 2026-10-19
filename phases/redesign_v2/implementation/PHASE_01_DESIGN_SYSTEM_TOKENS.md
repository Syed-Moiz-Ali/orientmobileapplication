# PHASE 01 — Concept A Design Tokens & Theme Foundation

**Document ID:** `phases/redesign_v2/implementation/PHASE_01_DESIGN_SYSTEM_TOKENS.md`  
**Prerequisites:** Product Owner Concept A Approval (`00_CONCEPT_A_APPROVAL.md`)  
**Target Package:** `packages/shared_core/lib/src/theme/`  
**Status:** READY FOR IMPLEMENTATION (Gate 1)  

---

## 1. Primary User & Engineering Objective
Establish the production-grade **Concept A Design System** within `packages/shared_core`, replacing the superseded Phase 00 color tokens and themes. Provide a single, centralized source of truth for all downstream phases covering colors, typography, elevations, radiuses, and theme data for both light and dark modes in English (LTR) and Arabic (RTL).

---

## 2. Real Repository File Paths
- `packages/shared_core/lib/src/theme/app_colors.dart` (Token definitions)
- `packages/shared_core/lib/src/theme/app_typography.dart` (Font styles & text themes)
- `packages/shared_core/lib/src/theme/app_theme.dart` (ThemeData builders)
- `packages/shared_core/lib/src/theme/app_dimensions.dart` (Radius, spacing, elevation)
- `packages/shared_core/test/theme/app_theme_test.dart` (Automated theme tests)

---

## 3. Information Hierarchy & Token Structure
1. **Canvases & Surfaces:**
   - Light: Canvas `#FBFBFD`, Surface `#FFFFFF`, Secondary Surface / Fill `#F4F6F9`, Border `#E2E8F0`, Subtle Divider `#EDF2F7`.
   - Dark: Canvas `#090B10`, Surface `#11141D`, Secondary Surface / Fill `#181C28`, Border `#262C3D`, Subtle Divider `#1A202E`.
2. **Typography Hierarchy:**
   - English LTR: **Plus Jakarta Sans** (Display 32sp w900, H1 24sp w800, H2 18sp w700, H3 14sp w700, Body 13sp w400, Overline Telemetry 11sp w800 uppercase).
   - Arabic RTL: **IBM Plex Sans Arabic** (H1 24sp w800, H2 18sp w700, H3 14sp w700, Body 13sp w400, Overline 11sp w800) with a single frozen **`×1.05` line-height multiplier** (`AppTypography.arabicLineHeightScale`) applied to every Latin role height to accommodate diacritics (effective role heights ≈ `1.3`–`1.5`).
3. **Geometry & Dimensions:**
   - Chamfered corner radiuses: `radiusXs: 4.0`, `radiusSm: 8.0`, `radiusMd: 12.0`, `radiusLg: 16.0`, `radiusXl: 24.0`.
   - 8-point spatial grid: `xxs: 4`, `xs: 8`, `sm: 12`, `md: 16`, `lg: 20`, `xl: 24`, `xxl: 32`.

---

## 4. Visual Acceptance Criteria
- Clean, high-contrast off-white light mode and deep space-slate dark mode.
- Zero blurry drop shadows; clean 1px structural hairline borders.
- Golden tests render crisp text using real loaded fonts (`loadShowcaseFonts()`).

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze packages/shared_core` returns 0 errors and 0 warnings.
- `flutter test packages/shared_core/test/theme/app_theme_test.dart` passes 100%.

### Gate 2: Visual Aesthetic Validation
- Rendered token swatch golden PNG approved for Concept A fidelity.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_01.md`.

---

## Centralized Widgets (Phase 01.2 — Mandatory)
All UI in this phase MUST reuse `packages/shared_core` centralized widgets. Never build a per-app duplicate when a shared widget exists.

- Use existing: `WorkspaceAppBar`, `DashboardShell`, `OfflineStatusPill`, `AppBreadcrumbs`, `AppPageHeader`, `AppMasterDetailScaffold`, `AppTable`, `AppCard`, `AppKpiCard`, `AppListSurface`, `AppRecordRow`, `AppSearchField`, `AppTextField`, `AppDropdownButton`, `AppFilterBar` / `AppDateRangeField` / `AppPaginationFooter` (01.2), `AppCommandPalette` + `WorkspaceSearchShortcuts` (01.2), `AppStepper` / `AppTimeline` / `AppTrendStat` (01.2), `AppBottomSheet`, `AppConfirmationDialog`, `AppSelectionSheet`, `EmptyState`, `ErrorView`, `AppSkeleton`, `LoadingIndicator`, `StatusPill`, `SectionHeader`, `AppActionBar`, `PrimaryButton`.
- If a needed widget does NOT exist in `shared_core`: create it in `packages/shared_core/lib/src/widgets/` (theme-driven via `context.colors` / `context.semanticColors`, EN/AR, responsive, a11y), export from `shared_core.dart`, add widget tests + goldens, THEN use it in this phase. Do not create `apps/*/lib/.../widgets/` copies.
- Forbidden: app-local copies of shared primitives, hardcoded spacing/radii/fonts, hardcoded colors, bespoke app bars/shells.
- Acceptance: grep shows zero new app-local duplicates; new shared widgets have tests + docs.

