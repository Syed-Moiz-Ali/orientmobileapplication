# Phase 01.2 — SaaS Foundation Hardening

**Document ID:** `phases/redesign_v2/reports/PHASE_01_2_FOUNDATION_HARDENING.md`
**Scope:** `packages/shared_core` + `packages/shared_auth` + `packages/shared_models` (theme authority + foundation primitives) — no feature screens touched
**Status:** **ENGINEERING GATE PASSED** / visual sign-off pending Product Owner
**Timestamp:** 2026-10-15
**Author:** Lead Flutter Architect & Systems Designer
**Reads:** `00_CONCEPT_A_DESIGN_SYSTEM.md` §6, `PHASE_01_1_THEME_ARCHITECTURE.md`, `shared_core.dart` exports, `app_theme.dart`, `app_semantic_colors.dart`, `app_dimensions.dart`, `workspace_app_bar.dart`, `app_table.dart`

---

## 1. Objective & Outcome

Phase 01.1 established the single styling authority (active `ThemeData` → `ColorScheme` + `AppSemanticColors`). Phase 01.2 hardens that foundation for SaaS scale without touching feature screens:

1. **Density** is now a theme concern (`AppDensity` extension + provider), not a per-widget breakpoint hack.
2. **Primary `#215FE6` is locked** — `BrandConfig` is logo-only; a guard fails the build on any custom primary.
3. **Charts scale to 4 series** with locale-aware currency through the single formatter authority.
4. **Focus + disabled grammar is global** — enforced once in `AppTheme._buildTheme`.
5. **Seven missing primitives land** (`AppFilterBar`, `AppDateRangeField`, `AppPaginationFooter`, `AppCommandPalette`, `AppStepper`, `AppTimeline`, `AppTrendStat`) — theme-only styling, EN/AR, 320/768/1280 goldens with real fonts.
6. **Bespoke bars are deprecated** with a guard that fails on any new usage.
7. **`shared_auth`** migrates `RoleConfig` hex, gains `AuthGuard` + session-expired + password-strength slot — no new backend.
8. **`shared_models`** gains `MoneyAed` / `PlateNumber` / `Vin` / `PhoneNumber` value objects (format/validate/LTR); `LoginNotifier` phone munging now delegates to the canonical type.

---

## 2. Changes by Requirement

### 2.1 AppDensity ThemeExtension + provider (§6 rule: one authority)

**Added** `packages/shared_core/lib/src/theme/app_density.dart`:
- `AppDensityMode { comfortable, compact }` + `AppDensity extends ThemeExtension<AppDensity>` (frozen `comfortable` 44/40 px rows, `compact` 36/36 px rows; `copyWith` + `lerp`).
- `densityModeProvider` (Riverpod `StateProvider`, defaults comfortable) for shell-level toggling.
- `AppDensityScope` — subtree override without rebuilding the app theme.
- `context.density` null-safe accessor (bare-`ThemeData` fallback → comfortable).

**Wired:** `AppTheme.light`/`dark` accept `density:` and register the extension; `AppTable` forces dense rows in compact mode on every breakpoint; `AppRecordRow` default padding follows density (explicit overrides honoured); `AppListSurface` skeleton padding follows density. Tested light + dark.

### 2.2 Primary lock `#215FE6` + logo-only BrandConfig

- `AppTheme.authorizedPrimaryLight = Color(0xFF215FE6)`; `light()` **ignores** the legacy brand colors (documented, guarded). `dark()` unchanged on its frozen parity token.
- `BrandConfig` keeps `appName/tagline/icon` + deprecated compatibility color fields (defaults = frozen tokens) + `logoOnly` view. White-label overrides remain logo/name-only by construction.
- **Guard** `test/theme_primary_guard_test.dart` (6 tests): rogue brand with `0xFFE11D48` still builds cobalt light / frozen dark; raw `#2563EB` never appears in built themes; semantic primary agrees with the scheme.

### 2.3 AppChartTheme → 4 series + currency

- `maxSeries` 2 → **4** (palette stays the frozen 6-value series, light + dark).
- `formatCurrency(value, formatters)` → `AppFormatters.moneyAED` (Latin digits both locales); `formatValue(value, formatters, currency:)` for grouped quantities.
- `orderSeries` RTL mirroring + `AppChartPlaceholder` untouched. Existing chart tests updated to the 4-cap; 3 new currency/RTL tests added.

### 2.4 Global focusRing + disabled tokens

- `AppSemanticColors` gains `disabledFill` / `disabledInk` / `disabledBorder` (light: frozen `disabled`/`textDisabled`/`borderDefault`; dark: `surfaceSunken`/`textDisabled`/`borderDefault`), with `copyWith`/`lerp` support.
- `_buildTheme` enforces: `disabledColor`, `focusColor` from `focusRing`, elevated/filled disabled bg+fg, outlined focus-ring side + disabled side, input `focusedBorder` (focusRing) + `disabledBorder`, chip/checkbox/switch disabled + focus states via `AppInteractionStates.focusRing`.
- Covered by `test/focus_disabled_tokens_test.dart` (both brightnesses + EN/AR render).

### 2.5 Seven new primitives (theme-only, EN/AR, goldens)

| Widget | File | l10n keys |
| :--- | :--- | :--- |
| `AppFilterBar` | `app_filter_bar.dart` | `filterBarClear`, `filterBarAll` |
| `AppDateRangeField` | `app_date_range_field.dart` | `filterBar…`, `dateRangeSelect`, `dateRangeClear` (dates via `AppFormatters`) |
| `AppPaginationFooter` | `app_pagination_footer.dart` | `paginationPrevious/Next/PageOf/Results` |
| `AppCommandPalette` (+ `showAppCommandPalette`, dialog/sheet) | `app_command_palette.dart` | `commandPaletteHint/Empty` |
| `AppStepper` (horizontal journey nodes) | `app_stepper.dart` | `stepperStepOf` |
| `AppTimeline` (tone dots via `semantic.status(role)`) | `app_timeline.dart` | — (caller copy) |
| `AppTrendStat` (delta via `AppFormatters.percent`, Latin digits) | `app_trend_stat.dart` | `trendUpLabel/DownLabel` |

All read `context.colors` / `context.semanticColors` only — the Phase 01.1 architecture guard (extended: still zero `AppColors`/`AppDarkColors` in widgets) passes unchanged. Functional coverage: `test/foundation_primitives_test.dart` (EN/AR + 320/768/1280 no-overflow). Rendered-review goldens with real fonts (Plus Jakarta Sans + IBM Plex Sans Arabic, same loader pattern as Phase 03B): `test/foundation_hardening_visual_test.dart` + `test/support/phase01_2_gallery.dart` → 8 baselines `goldens/foundation_01_2_{320,768,1280}_{en,ar}[_dark].png`.

### 2.6 Bespoke bars deprecated + guard

- `@Deprecated('Use WorkspaceAppBar (chrome) or AppPageHeader (headings)')` on `AppTopBar` / `CustomerTopBar`; `@Deprecated('Use AppPageHeader with StatusPill instead')` on `GradientBanner` / `GradientBannerPill`.
- **Guard** `test/deprecation_guard_test.dart`: scans `apps/` + `packages/` and fails on any reference outside the documented allowlist (existing Phases 06–20 callers + frozen prototype comment). Feature screens untouched — their call sites now emit `deprecated_member_use` infos (no errors); migration stays owned by Phases 06–20.

### 2.7 shared_auth (no new backend)

- `RoleConfig`: all six `buttonColor` → `AppColors.primary` (locked); icon marks → frozen tokens (`primary`/`surfaceStrong`/`success`/`purpleAccent`/`info`); zero `Color(0x…)` literals (source-scanned by test).
- `AuthGuard` (new): loading → `AuthLoadingView`; unauthenticated/role-denied → custom builder or `AuthSessionExpiredView` (fails closed, never a privileged fallback).
- `AuthSessionExpiredView` (compact + expanded, EN/AR keys `authSessionExpired{Title,Message,Action}`) — presentation for the existing 401-driven `invalidateSession`; no API/backend change.
- Password-strength slot: `AuthPasswordStrength` (pure `passwordStrengthScore` 0–4) + `AuthTextField.belowField` slot, wired into the register form. Keys `authPasswordStrength{Label,Weak,Fair,Good,Strong}` EN/AR.
- `LoginNotifier._fullPhone` now delegates to `PhoneNumber.normalizeLoose` (duplicate regex removed); `shared_auth.dart` exports the new widgets.

### 2.8 shared_models value objects (format/validate/LTR)

New `lib/src/value_objects/` (pure Dart, no Flutter import — package has no resolved Flutter dep): `money_aed.dart` (`format` EN/AR, `group`, `tryParse`, eastern-digit latinization), `plate_number.dart` (`DXB A 12345`, emirate set, `tryParse`), `vin.dart` (17-char ISO 3779 minus I/O/Q), `phone_number.dart` (E.164 `+971…`, spaced/LTR display, `tryParse`/`normalizeLoose`). Each exposes `isLtr` (callers wrap in LTR `Directionality`/`Text` per V5) and equality. Exported from `shared_models.dart`. Covered by `test/value_objects_test.dart` (17 tests). Added `flutter_test` dev-dep (was missing) + `pub get`.

---

## 3. Testing Results

| Check | Result |
| :--- | :--- |
| `flutter analyze --no-pub` shared_core / shared_auth / shared_models | **0 issues** |
| Downstream analyze (staff/owner/customer/crm apps) | **0 errors** (deprecation infos only, on allowlisted callers) |
| shared_core full suite | **405 pass / 0 fail** (baseline was 324 → **+81 new**, all green) |
| `app_semantic_theme_test` (theme guard) | **21/21 pass** |
| `theme_primary_guard_test` (new) | **6/6 pass** |
| `app_density_test` (new) | **20/20 pass** |
| `focus_disabled_tokens_test` (new) | **15/15 pass** |
| `foundation_primitives_test` (new) | **27/27 pass** |
| `deprecation_guard_test` (new) | **2/2 pass** |
| `shared_chart_theme_test` (4-series + currency) | **pass** |
| `foundation_hardening_visual_test` (8 new goldens, real fonts) | **8/8 pass** |
| shared_auth full suite | **86 pass / 0 fail** (incl. new `foundation_hardening_test` 12/12) |
| shared_models suite | **17/17 pass** |
| l10n parity (`arb_parity_test` both packages, `l10n_untranslated.json`) | **clean** |

Golden churn (both intended, both documented): `phase02_dialog_mobile_en.png` (0.20% — disabled grammar recolor of a disabled control) and `auth_register_mobile.png` (23.5% — new strength meter on the register form). All other existing goldens pixel-identical.

---

## 4. Files Changed

**Added (shared_core lib):** `theme/app_density.dart`, `widgets/app_filter_bar.dart`, `widgets/app_date_range_field.dart`, `widgets/app_pagination_footer.dart`, `widgets/app_command_palette.dart`, `widgets/app_stepper.dart`, `widgets/app_timeline.dart`, `widgets/app_trend_stat.dart`.
**Added (shared_core test):** `app_density_test.dart`, `theme_primary_guard_test.dart`, `focus_disabled_tokens_test.dart`, `foundation_primitives_test.dart`, `deprecation_guard_test.dart`, `foundation_hardening_visual_test.dart`, `support/phase01_2_gallery.dart`, 8 golden baselines.
**Modified (shared_core lib):** `theme/app_theme.dart` (primary lock, density registration, focus/disabled enforcement), `theme/app_semantic_colors.dart` (disabled tokens, 4-series comment), `theme/app_chart_theme.dart` (maxSeries 4 + currency), `branding/brand_config.dart` (logo-only), `widgets/app_table.dart` / `app_record_row.dart` / `app_list_surface.dart` (density), `widgets/app_top_bar.dart` / `gradient_banner.dart` (deprecated), `shared_core.dart` (exports), `l10n/app_{en,ar}.arb` + regenerated gen (13 new keys).
**Modified (shared_core test):** `shared_chart_theme_test.dart` (4-cap + currency/RTL), `app_theme_test.dart` (locked-primary expectation), `localized_shared_widgets_test.dart` (deprecation-ignore), 1 golden re-render.
**Added/modified (shared_auth):** `presentation/widgets/auth_guard.dart`, `presentation/widgets/auth_password_strength.dart`, `AuthTextField.belowField` + register-form wiring, `RoleConfig` token migration, `l10n/app_{en,ar}.arb` + regen (8 new keys), `test/foundation_hardening_test.dart`, 1 golden re-render.
**Added/modified (shared_models):** `src/value_objects/{money_aed,plate_number,vin,phone_number,value_objects}.dart`, `shared_models.dart` export, `test/value_objects_test.dart`, `flutter_test` dev-dep.

---

## 5. Remaining Debt & Ownership

1. Allowlisted bespoke-bar callers (customer/staff/CRM screens) still render the deprecated bars — owned by Phases 06–20; the guard prevents spread.
2. `concept_showcase` stays frozen (raw `#2563EB` reference + infos untouched).
3. Raw-`String` plate/VIN/phone fields in feature models remain API-shaped; features should adopt the value objects in their owning phases (validation/formatting only — serialization unchanged).
4. New golden baselines + 2 re-renders await Product Owner visual sign-off (same gate as Phase 01.1).

---

## 6. Gate Statement

`flutter analyze` clean across `shared_core`, `shared_auth`, `shared_models` (+ zero errors downstream); shared_core **405/405**, shared_auth **86/86**, shared_models **17/17**; theme guard, primary guard, deprecation guard and l10n parity all green. **Phase 01.2 is complete. Stop. Phase 07 is not started.**
