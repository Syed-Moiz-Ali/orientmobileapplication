# PHASE 07.1 — Centralized SaaS Foundation Hardening & Retrofit (Phases 01–07)

**Document ID:** `phases/redesign_v2/implementation/PHASE_07_1_CENTRALIZED_SAAS_HARDENING.md`  
**Prerequisites:** Phases 01 through 07 Completed (`REPORT_PHASE_06.md` + Phase 07 report) AND Phase 01.2 Foundation Hardening COMPLETE (`reports/PHASE_01_2_FOUNDATION_HARDENING.md` — engineering PASSED: shared_core 405/405, shared_auth 86/86, shared_models 17/17)  
**Target Packages:** `packages/shared_core/`, `packages/shared_auth/`, `packages/shared_models/` (+ duplicate-removal in `apps/*/lib`)  
**Status:** READY FOR IMPLEMENTATION (Gate 07.1 — runs AFTER 07, BEFORE 08)  

---

## 1. Primary User & Engineering Objective
Retrofit the SaaS/enterprise centralized foundation across everything Phases 01–07 already shipped. Phases 01–07 built the Concept A tokens, primitives, shells, auth, advisor hub and intake studio — but each phase created app-local copies, left theme gaps, and never enforced the 01.2 centralized rule. Phase 01.2 has since LANDED the hardened foundation (density, primary lock, 4-series charts, focus/disabled grammar, 7 new primitives, bespoke-bar deprecation, AuthGuard, value objects — see its report). This phase CONSUMES 01.2: migrate every 01–07 app-local duplicate onto the 01.2 widgets/tokens/guards FIRST so Phases 08–21 become fast copy-paste instead of 14 more rebuilds. Do not rebuild what 01.2 already built — adopt it, rewire callers, delete duplicates, adopt value objects in 01–07 feature code, and close remaining debt §5 of the 01.2 report.

Deliver: global density system, single brand-primary authority, extended chart language, global focus/disabled grammar, the 7 missing SaaS workhorse widgets, `AuthGuard` + session/strength slots, centralized money/plate/VIN/phone value objects, deprecation + guards for bespoke bars/duplicate primitives, and migration of every 01–07 app-local duplicate into `shared_core`.

---

## 2. Real Repository File Paths
- `packages/shared_core/lib/src/theme/app_theme.dart`, `app_semantic_colors.dart`, `app_dimensions.dart`, `app_text_styles.dart`, `app_interaction_states.dart`, `app_chart_theme.dart`, `app_theme_context.dart`
- `packages/shared_core/lib/src/widgets/` (47 files — `workspace_app_bar.dart`, `dashboard_shell.dart`, `app_table.dart`, `app_master_detail_scaffold.dart`, `offline_status_pill.dart`, `empty_state.dart`, `error_view.dart`, `app_skeleton.dart`, + NEW below)
- `packages/shared_core/lib/shared_core.dart` (barrel exports)
- `packages/shared_auth/lib/src/domain/entities/role_config.dart`, `src/presentation/widgets/*`, `src/presentation/pages/*`
- `packages/shared_models/lib/src/` (`user_role.dart`, `job_card_status.dart` + NEW value objects)
- Audit targets (read-only, migrate duplicates OUT): `apps/staff_app/lib/features/advisor/**`, `apps/owner_app/**/owner_app_bar.dart`, `apps/crm_app/**/crm_app_bar.dart`, `apps/staff_app/**/supervisor_app_bar.dart`, `apps/customer_app/**/customer_scaffold.dart`, `packages/shared_core/lib/src/widgets/gradient_banner.dart`
- Tests: `packages/shared_core/test/**`, `packages/shared_auth/test/**`

---

## 3. Screen Redesign Requirements
1. **Theme hardening (no visual redesign, additive only):**
   - `AppDensity` `ThemeExtension` (comfortable/compact) + `densityProvider`; wire to `AppTable` (36/44 row heights), `AppRecordRow`, `AppListSurface`. Light + dark.
   - Lock primary to single authority Hyper Cobalt `#215FE6` (dark `#6E8BFF`); `BrandConfig` becomes logo/name only, never primary. Guard test fails on custom primary.
   - Extend `AppChartTheme`: 4 series max (was 2), 8-color palette, currency via `app_formatters.dart`; keep RTL `orderSeries` + `AppChartPlaceholder` empty state.
   - Global focus ring (2px `focusRing`) + disabled ink/alpha tokens enforced in `AppTheme._buildTheme` for inputs, table rows, cards, buttons.
2. **Create the 7 missing SaaS widgets in `shared_core` (theme-driven, EN/AR, responsive 320/768/1280, a11y 48dp, reduced-motion):**
   - `AppFilterBar` (search + chips + clear), `AppDateRangeField` (range picker + presets), `AppPaginationFooter` (page/size/total), `AppCommandPalette` (+ `WorkspaceSearchShortcuts` wiring, recent/empty states), `AppStepper` (wizard steps), `AppTimeline` (vertical journey), `AppTrendStat` (value + delta pill).
   - Export all from `shared_core.dart`; widget tests + goldens with real fonts.
3. **Migrate 01–07 duplicates INTO `shared_core`:** grep `apps/*/lib` for local copies of cards, pills, sheets, search fields, skeletons, stat tiles, section headers; delete app-local copies, rewire to shared. Deprecate `OwnerAppBar`, `CrmAppBar`, `SupervisorAppBar`, `gradient_banner.dart` — guard test fails on new bespoke bars.
4. **`shared_auth`:** migrate `RoleConfig` legacy hex to `semanticColors`; add `AuthGuard` GoRouter widget + session-expired notice slot + password-strength meter slot + biometric hook slot (slots only, no fake backend).
5. **`shared_models`:** add `MoneyAED`, `PlateNumber`, `Vin`, `PhoneE164` value objects (format/validate/LTR-direction rules); replace per-app duplicates; wire to `AppTextStyles.mono()` usage.

---

## 4. Visual Acceptance Criteria
- No feature screen changes appearance except through centralized tokens/widgets (pixel-diff limited to density/focus/chart cases).
- All new widgets render Concept A: canvas `#FBFBFD`/`#090B10`, hairline borders, 8/12/16 radii, cobalt primary, semantic status, Jakarta/Plex Arabic ×1.05.
- Goldens for every new widget at 390 EN/AR + 768 + 1280 with real fonts; dark-mode spot goldens.
- Zero horizontal overflow at 320px; text scale 1.3× clean; RTL mirrored with plates/VIN/phone/money LTR-locked.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze lib test` 0 issues in `shared_core`, `shared_auth`, `shared_models`.
- `flutter test` green in all three packages (existing 324+ core / 74+ auth + new density/chart/filter/palette/stepper/timeline/guard/value-object tests).
- Theme guard + new bespoke-bar guard + brand-primary guard pass; `shared_core.dart` exports verified; no new `AppColors.*`/`AppDarkColors.*` in feature code.

### Gate 2: Visual Aesthetic Validation
- New-widget goldens inspected at native resolution before acceptance.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_07_1.md` ( hardened files, migrated duplicates with before/after imports, theme audit, widget catalog, l10n/RTL matrix, baseline-vs-final, remaining owners).

---

## Styling Authority (Phase 01.1 — Mandatory)
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
- This phase CREATES the missing 01.2 widgets listed in §3.2 — that is its primary deliverable.
- Forbidden: app-local copies of shared primitives, hardcoded spacing/radii/fonts, hardcoded colors, bespoke app bars/shells.
- Acceptance: grep shows zero new app-local duplicates; new shared widgets have tests + docs.
