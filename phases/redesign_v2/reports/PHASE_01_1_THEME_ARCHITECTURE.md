# Phase 01.1 — Centralized Theme Architecture Correction

**Document ID:** `phases/redesign_v2/reports/PHASE_01_1_THEME_ARCHITECTURE.md`
**Scope:** `packages/shared_core` (theme authority + foundation primitives) — no unrelated feature screens
**Status:** **ENGINEERING GATE PASSED** / visual sign-off pending Product Owner
**Timestamp:** 2026-10-14
**Author:** Lead Flutter Architect & Systems Designer

---

## 1. Objective & Outcome

**Problem.** "Corrective" styling such as

```dart
final dark = theme.brightness == Brightness.dark;
final track = trackColor ?? (dark ? AppDarkColors.surfaceSubtle : AppColors.surfaceSunken);
```

had begun to spread. If left unchecked it becomes the app-wide standard, producing duplicated palette selection, dark-mode drift, and untestable color logic.

**Outcome.** There is now **one semantic styling authority**: the active Flutter `ThemeData`. Standard roles resolve through `ColorScheme`; custom automotive/workshop roles resolve through a single `AppSemanticColors` `ThemeExtension`. Widgets read `context.colors` / `context.semanticColors`. Every `shared_core` foundation primitive was migrated; a source-guard test fails the build if `AppDarkColors` reappears in any widget.

---

## 2. Audit Findings

Occurrences of the target anti-patterns across the monorepo, classified:

1. **Legitimate theme construction** — `AppTheme`, `AppSemanticColors`, `AppDarkPanel`, `AppCard.navy` (nested inverse theme).
2. **Legitimate behaviour / asset variation** — system status-bar icon brightness, brand navy panels, vehicle damage maps.
3. **Widget styling that must consume the active theme** — the `shared_core` foundation primitives (migrated now).
4. **Legacy feature styling owned by a future V2 phase** — per-app feature screens (owned by Phases 05–20).

### 2.1 `packages/shared_core/lib/src/widgets` (Phase 01.1 scope)

| File | Anti-pattern | Class | Action |
| :--- | :--- | :--- | :--- |
| `app_progress.dart` | `dark ? AppDarkColors…` (track + step ink) | 3 | **Migrated** → `context.semanticColors.surfaceSunken` / `.onPrimary` |
| `primary_button.dart` | 5× `dark ? AppDarkColors.focusRing/borderStrong/surfaceSubtle` | 3 | **Migrated** |
| `app_card.dart` | 8× variant light/dark ternaries | 3 | **Migrated** (`AppCard.navy` nested theme kept as class 1) |
| `app_info_panel.dart` | 4× variant light/dark ternaries | 3 | **Migrated** |
| `app_search_field.dart` | 3× surface/border/fill ternaries | 3 | **Migrated** |
| `app_form_primitives.dart` | 2× border + hardcoded `AppColors.danger` | 3 | **Migrated** |
| `app_text_field.dart` | fill ternary | 3 | **Migrated** |
| `app_action_bar.dart` | sticky surface + border ternary | 3 | **Migrated** |
| `app_dropdown_button.dart` | 4× fill/border ternaries | 3 | **Migrated** |
| `app_kpi_card.dart` | 6× semantic base + trend ternaries | 3 | **Migrated** |
| `pending_sync_chip.dart` | 8× state light/dark ternaries | 3 | **Migrated** → `syncNotSent/Queued/Failed/Synced` |
| `status_pill.dart` | brightness fork with hardcoded dark hex | 3 | **Migrated** → tone → `AppStatusColors` |
| `user_avatar.dart` | 4× ring/fill/dot ternaries | 3 | **Migrated** |
| `app_snackbar.dart` | 2× rail ternary | 3 | **Migrated** |
| `app_skeleton.dart` | shimmer base/highlight ternary | 3 | **Migrated** |
| `app_record_row.dart` | hardcoded `AppColors.primarySubtle/borderDefault` | 3 | **Migrated** |
| `empty_state.dart` | hardcoded `#DC2626`/`#FEF2F2` error plate | 3 | **Migrated** → danger family |
| `app_chart_theme.dart` | `Brightness` → palette selection | 3 | **Migrated** → `semanticColors.chartSeries` |
| `dashboard_shell.dart` | `brightness` → system icon brightness | 2 | **Kept** (documented reason) |
| `workspace_app_bar.dart` | `brightness` → status-bar brightness | 2 | **Kept** (documented reason) |
| `app_dark_surface.dart` | constructs inverse `ThemeData` | 1 | **Kept** (theme construction) |
| `section_header.dart`, `app_page_header.dart`, `gradient_banner.dart`, `app_bottom_sheet.dart`, `app_confirmation_dialog.dart`, `app_selection_sheet.dart` | none / `ColorScheme` only | — | No change required |

### 2.2 Feature applications (deferred — class 4)

| Package | `AppDarkColors` / `Brightness.dark` refs | Hardcoded `Color(0x…)` | Owning V2 phases |
| :--- | ---: | ---: | :--- |
| `packages/shared_auth/lib` | 8 | 12 | Phase 05 |
| `apps/staff_app/lib` | 4 | 41 | Phases 06–12 |
| `apps/owner_app/lib` | 2 | 85 | Phases 13–15 |
| `apps/customer_app/lib` | 0 | 3 | Phases 16–18 |
| `apps/crm_app/lib` | 2 | 29 | Phases 19–20 |
| `apps/concept_showcase/lib` | 1 | — | **Frozen reference — do not modify** |

These are **not** in scope for Phase 01.1 and remain owned by their phase (see the ownership matrix, §7). They must all be migrated before the Phase 21 final audit.

---

## 3. Theme Architecture

```
ThemeData (AppTheme.light / AppTheme.dark)
├── ColorScheme              → standard Material roles        → context.colors
├── TextTheme (locale-aware) → typography roles (EN / AR ×1.05)
├── component themes         → buttons, inputs, cards, dialogs, sheets, chips, nav…
└── extensions: [AppSemanticColors]  → custom automotive/workshop roles → context.semanticColors
```

- **No competing providers, no global singletons.** The theme is the only authority.
- **Null-safe accessors** (`app_theme_context.dart`): `context.colors` and `context.semanticColors`. When a subtree supplies a bare `ThemeData` without the extension (widget tests), the frozen light/dark resolution is returned — call sites never write `!`.
- **Single registration point:** `AppTheme._buildTheme` receives the correct frozen palette (`AppSemanticColors.light` / `.dark`) and registers it under `ThemeData.extensions`.

---

## 4. Semantic Token Mapping & `ThemeExtension` API

`AppSemanticColors extends ThemeExtension<AppSemanticColors>` (immutable; `copyWith` + `lerp` implemented; two frozen const instances `light` / `dark`; `forBrightness()`).

Fields (only roles `ColorScheme` does **not** model):

| Group | Fields |
| :--- | :--- |
| Surfaces | `surface`, `surfaceSubtle`, `surfaceSunken`, `surfaceRaised`, `surfaceStrong`, `selectedSurface` |
| Borders | `borderSubtle`, `borderDefault`, `borderStrong` |
| Brand | `primary`, `primarySubtle`, `primaryBorder`, `focusRing`, `onPrimary`, `onError` |
| Status families | `neutral`, `success`, `warning`, `danger`, `info` (each an `AppStatusColors`) |
| Shimmer / scrim | `skeletonBase`, `skeletonHighlight`, `overlayScrim` |
| Chart | `chartSeries` (light/dark ordered telemetry palette) |

`AppStatusColors { base, subtle, border, ink }` is a small value type so a status role is one object, not four loose colors.

**Domain roles** resolve to the five families (no new values): `syncNotSent→warning`, `syncQueued→info`, `syncFailed→danger`, `syncSynced→success`, `inspectionPass→success`, `inspectionAdvisory→warning`, `inspectionFail→danger`, `damageMinor→info`, `damageModerate→warning`, `damageSevere→danger`, `operationalActive→success`, `operationalIdle→neutral`, `operationalBlocked→danger`.

**Ergonomic API:**
```dart
final scheme   = context.colors;                       // ColorScheme
final semantic = context.semanticColors;               // AppSemanticColors
final track    = trackColor ?? semantic.surfaceSunken; // no brightness branch
```

---

## 5. Files Changed

**Added**
- `packages/shared_core/lib/src/theme/app_semantic_colors.dart` — the `ThemeExtension` + `AppStatusColors` + `StatusColorRole`.
- `packages/shared_core/lib/src/theme/app_theme_context.dart` — `context.colors` / `context.semanticColors`.
- `packages/shared_core/test/app_semantic_theme_test.dart` — 20 tests (registration, resolution, ColorScheme consistency, component themes, contrast, EN/AR, `copyWith`/`lerp`, architecture guard).

**Modified (theme)**
- `app_theme.dart` — register the extension; pass the frozen palette into `_buildTheme`.
- `app_colors.dart` — authorize/document the crimson amendment (`#DC2626`).
- `app_chart_theme.dart` — read `semanticColors.chartSeries`.
- `shared_core.dart` — export the two new files.

**Modified (widgets — class 3 migration):** `app_progress`, `primary_button`, `app_card`, `app_info_panel`, `app_search_field`, `app_form_primitives`, `app_text_field`, `app_action_bar`, `app_dropdown_button`, `app_kpi_card`, `pending_sync_chip`, `status_pill`, `user_avatar`, `app_snackbar`, `app_skeleton`, `app_record_row`, `empty_state`.

**Modified (goldens — current phase):** `theme_foundation_*` ×5 (Phase 01), `shared_components_*` ×8 and `phase02_*` ×9 (Phase 02, in-progress).

---

## 6. Testing Results

| Check | Result |
| :--- | :--- |
| `dart analyze` (shared_core) | **0 issues** |
| `app_semantic_theme_test.dart` | **20/20 pass** |
| shared_core full suite | **265 pass / 21 fail** (all historical goldens, Phases 03/04) |
| Theme-extension registration | ✅ pass |
| Light/dark resolution + null-safe fallback | ✅ pass |
| ColorScheme consistency | ✅ pass |
| Component-theme consumption | ✅ pass |
| Accessibility contrast (cobalt, crimson, dark ink, status inks) | ✅ pass |
| English / Arabic | ✅ pass |
| Architecture guard (no `AppDarkColors` in widgets) | ✅ pass |
| Downstream compilation (`shared_auth`, all 4 apps) | ✅ analyze clean |
| Downstream regressions | No logic/API/localization/persistence failures (owner_app & crm_app fully green; other failures are historical goldens only) |

---

## 7. Migration Ownership Matrix

| Surface | Owner | Status |
| :--- | :--- | :--- |
| `shared_core` theme authority + foundation primitives | **Phase 01.1** | ✅ Done |
| `shared_core` complex data components (tables, pods, HUD) | Phase 03 | Pending |
| `shared_core` shells & navigation | Phase 04 | Pending |
| `shared_auth` (login/otp/recovery/splash) | Phase 05 | Pending |
| `staff_app` advisor / intake / inspection / estimates / technician / supervisor / profile | Phases 06–12 | Pending |
| `owner_app` cockpit / jobs / financials | Phases 13–15 | Pending |
| `customer_app` garage / booking / status | Phases 16–18 | Pending |
| `crm_app` pipeline / comms / team | Phases 19–20 | Pending |
| Whole-monorepo styling compliance audit | Phase 21 | Pending |

No separate "big refactor" project is created: each remaining widget is migrated inside its existing owning phase.

---

## 8. Remaining Technical Debt

1. Feature-level palette selection / hardcoded hex in the four apps and `shared_auth` (counts in §2.2) — owned by Phases 05–20.
2. `AppCard.navy`, `AppDarkPanel`, and the `AppSemanticColors` status "ink" hexes are intentionally literal (brand/inverse surfaces and AA-tuned inks); they are the single source and must not be duplicated elsewhere.
3. `concept_showcase` retains pre-existing `withOpacity` deprecation infos (frozen reference; out of scope).
4. Historical golden suites are intentionally left failing until their owning phase re-renders them; Phase 21 verifies none remain.

---

## 9. Phase 02 Readiness

- The single styling authority is in place and enforced by tests; Phase 02 primitives already read from it.
- No public API breaks; downstream packages compile clean.
- Recommended: Product Owner reviews the regenerated `theme_foundation_*` and `phase02_*` screenshots, then Phase 02 resumes from its existing uncommitted work using the mandatory rules in `00_CONCEPT_A_DESIGN_SYSTEM.md` §6.

**Phase 02 was not started/signed off by this pass. Phase 03 not begun.**
