# Phase 02 Completion Report: Shared UI Primitives & Input System

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_02.md`
**Execution Phase:** Concept A V2 — Phase 02 (Shared UI Primitives & Input System)
**Target Package:** `packages/shared_core/`
**Prerequisite:** Phase 01 (`PHASE_01_COMPLETION.md`) + Phase 01.1 (`PHASE_01_1_THEME_ARCHITECTURE.md`)
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER REVIEW**
**Timestamp:** 2026-10-14
**Author:** Lead Flutter Architect & Systems Designer

---

## 1. Objective, Scope & Outcome

Phase 02 redesigns the `shared_core` foundational UI primitives — the action system, input system, form sections, status indicators, modals, feedback surfaces, and loading skeletons — to embody Concept A geometry, tactile haptics, elevation and accessibility, **while consuming the single centralized theme authority established in Phase 01.1**.

This pass:

- Completed the migration of every in-scope `shared_core` primitive so it resolves color through `context.colors` / `context.semanticColors` only.
- Corrected two residual violations found in-phase (`primary_button.dart`, `status_pill.dart`).
- Strengthened the architecture source-guard so it now fails the build on **either** `AppDarkColors` **or** a direct `AppColors.*` selection inside `shared_core/lib/src/widgets`, with two explicit, documented allowlists.
- Refreshed only the dark goldens invalidated by the corrected dark border, and re-verified the full surface.

**No application behavior, API shape, business logic, localization, or persistence was changed.** Phase 03 was **not** started.

> **Evidence policy.** Results marked *independent* were reproduced in this pass and are backed by the concrete commands in §7. Results marked *reported* are quoted from prior phase documents and were not re-executed here.

---

## 2. Centralized Theme Architecture (Phase 01.1 Authority — Preserved)

Phase 02 introduces **no new theme system and no design decisions**. Styling resolves exclusively through the Phase 01.1 authority:

```
ThemeData (AppTheme.light / AppTheme.dark)
├── ColorScheme              → standard Material roles        → context.colors
├── TextTheme (locale-aware) → typography roles (EN / AR ×1.05)
├── component themes         → buttons, inputs, cards, dialogs, sheets, chips, nav
└── extensions: [AppSemanticColors]  → custom automotive roles → context.semanticColors
```

- **Standard roles** → `context.colors` (`ColorScheme`).
- **Custom automotive/workshop roles** → `context.semanticColors` (`AppSemanticColors` `ThemeExtension`).
- Accessors are null-safe (`app_theme_context.dart`): a subtree with a bare `ThemeData` resolves the frozen light/dark palette, so call sites never branch on brightness.
- Supporting artifacts (added in Phase 01.1, consumed here): `app_semantic_colors.dart`, `app_theme_context.dart`; test `app_semantic_theme_test.dart`.

---

## 3. Shared Primitive Changes

All in-scope primitives were finalized against the ThemeExtension / `ColorScheme`. The following source files carry the Phase 02 changes (23 widgets + 3 theme files = 26 modified under `lib/src`, plus the `shared_core.dart` barrel export; `dart analyze` clean — §7):

| Area | Files |
| :--- | :--- |
| Action system | `primary_button.dart` (unified `AppButton.primary/secondary/tertiary/danger/quietIcon/compactInline`) |
| Inputs | `app_text_field.dart`, `app_search_field.dart`, `app_dropdown_button.dart`, `app_selection_sheet.dart`, `app_form_primitives.dart` |
| Status | `status_pill.dart`, `pending_sync_chip.dart` |
| Surfaces & content | `app_card.dart`, `app_info_panel.dart`, `app_kpi_card.dart`, `app_record_row.dart`, `user_avatar.dart`, `empty_state.dart` |
| Feedback & loading | `app_progress.dart`, `app_skeleton.dart`, `app_snackbar.dart`, `app_action_bar.dart` |
| Modals & chrome-adjacent | `app_bottom_sheet.dart`, `app_confirmation_dialog.dart`, `app_page_header.dart`, `section_header.dart`, `gradient_banner.dart` |
| Theme | `app_chart_theme.dart` (reads `semanticColors.chartSeries`), `app_theme.dart` (registers the extension), `app_colors.dart` (documented crimson amendment) |

Verify the count for yourself (this scoped diff reports the 26 `lib/src` files; the barrel is outside these paths):

```powershell
git diff --stat -- packages/shared_core/lib/src/widgets packages/shared_core/lib/src/theme
```

Phase 02 component-facing API (unchanged public signatures; additive): `AppButton` action set, `AppSelectField`, `AppQuantityStepper`, `AppDateSelectorShell`, `AppMediaUploadShell`, `AppListSurface`, `AppFormSection`, and the existing `AppCard` / `AppInfoPanel` variant constructors.

---

## 4. In-Phase Corrections (`primary_button.dart`, `status_pill.dart`)

Two residual palette violations were found during this pass and corrected. Both are now guard-clean.

### 4.1 `primary_button.dart` — raw light-palette border in `compactInline`

`AppButton.compactInline` built its non-primary resting border with a hardcoded light token:

```dart
// before — light palette leaked into dark mode
side: isPrimary ? null : BorderSide(color: AppColors.borderDefault),
```

```dart
// after — resolved from the active theme
side: isPrimary
    ? null
    : BorderSide(color: context.semanticColors.borderDefault),
```

The now-unused `import 'app_colors.dart'` was removed. Impact: in dark mode the inline button border now renders the dark hairline (`AppDarkColors.borderDefault`) instead of the light `#E2E8F0`. Light rendering is unchanged (light `borderDefault` is the same value).

### 4.2 `status_pill.dart` — dead hardcoded light hexes in tone constructors

The six semantic constructors (`StatusPill.neutral/.info/.success/.warning/.danger/.inProgress`) still initialized `bg`/`fg`/`borderColor` with literal light hexes (`#F1F5F9`/`#475569`/`#E2E8F0` … `#EEF2FF`/`#4338CA`/`#C7D2FE`). Because `_tone` is non-null, `build()` resolves every color from `AppSemanticColors` and **ignores those fields** — they were dead values, but they still planted prohibited hardcoded semantic hex in a widget. The initializers were set to `null`; the color grammar now lives solely in the `AppSemanticColors` status families. Rendering is unchanged in both themes (verified by goldens).

---

## 5. Strengthened Architecture Guard (`app_semantic_theme_test.dart`)

The Phase 01.1 guard scanned `lib/src/widgets` for `AppDarkColors` only. It now scans for **both** `AppDarkColors` and a direct `AppColors.*` selection, and a second test bounds palette debt to the documented allowlists.

### 5.1 Allowlist `justifiedBrand` — legitimate, must NOT be "corrected"

| File | Rationale |
| :--- | :--- |
| `app_card.dart` | `AppCard.navy` constructs a nested **inverse `ThemeData`** (fixed navy brand surface). This is class-1 *theme construction* and the single source of the literal `AppColors.navy` / `#2A3A5E` / `#60A5FA` hexes. |
| `app_info_panel.dart` | `AppInfoPanel.navy` is the same fixed inverse **brand asset**; it intentionally does not follow the light/dark semantic palette (inline comment documents this). |

### 5.2 Allowlist `pendingFuturePhase` — existing debt owned by a future phase

| File | Owning phase | Violation |
| :--- | :--- | :--- |
| `app_page_frame.dart` | **Phase 04** | `BorderSide(color: AppColors.borderDefault)` (breaks dark mode) |
| `notification_bell.dart` | **Phase 04** | `AppColors.danger` / `AppColors.warningBorder` / `AppColors.navy` |
| `offline_banner.dart` | **Phase 04** | `AppColors.warning` fills / border / icon |

These three are shell/navigation chrome, not Phase 02 input primitives, so they remain owned by Phase 04 per the migration-ownership rule (§8).

### 5.3 Guard tests

1. `foundation widgets never select a static light/dark palette` — fails on any `AppDarkColors` reference, or any `AppColors.*` reference outside the two allowlists.
2. `future-phase palette debt stays bounded to the documented list` — asserts the set of files referencing either palette equals `justifiedBrand ∪ pendingFuturePhase`, so new offenders cannot be silently added.

Both tests pass (§7). The guard is the enforcement mechanism for the acceptance criterion: **no new widget-level theme duplication or direct light/dark palette selection is introduced in Phase 02.**

---

## 6. Refreshed Goldens

The `compactInline` dark-border correction (§4.1) changed exactly the dark renderings that contain that control. Only the dark goldens below were regenerated; all light goldens were re-rendered **byte-identical** (no diff) and every other historical golden was left untouched.

| Golden file | Suite | Why regenerated |
| :--- | :--- | :--- |
| `goldens/phase02_primitives_mobile_dark.png` | Phase 02 visual | `AppButton.compactInline` dark resting border now resolves the dark hairline (352 px diff, 0.02%) |
| `goldens/phase02_primitives_mobile_dark_ar.png` | Phase 02 visual | same, Arabic RTL (352 px diff, 0.02%) |
| `goldens/shared_components_mobile_dark.png` | Phase 03A shared gallery | same control in the dark component catalog (352 px diff, 0.03%) |
| `goldens/shared_components_mobile_dark_ar.png` | Phase 03A shared gallery | same, Arabic RTL (352 px diff, 0.03%) |

Commands:

```powershell
flutter test --update-goldens test/shared_primitives_phase02_visual_test.dart
flutter test --update-goldens test/shared_components_visual_test.dart
```

No Phase 03/04 historical golden was regenerated (see §8 and §9).

---

## 7. Verification

Environment: Flutter (bundled Plus Jakarta Sans + IBM Plex Sans Arabic loaded for golden tests). Every command below was executed in this pass.

### 7.1 Focused tests (independent)

| Command (working dir = `packages/shared_core`) | Scope | Result |
| :--- | :--- | :--- |
| `flutter analyze lib test` | analyzer | **0 issues** |
| `flutter test test/app_semantic_theme_test.dart test/shared_primitives_phase02_test.dart` | theme + primitive interaction | **26 / 26 pass** (21 theme incl. 2 guard tests + 5 interaction) |
| `flutter test test/shared_primitives_phase02_visual_test.dart` | Phase 02 catalog goldens | **9 / 9 pass** |
| `flutter test test/app_button_accessibility_test.dart test/shared_primitives_actions_test.dart test/shared_components_test.dart test/app_theme_parity_test.dart test/app_interaction_states_test.dart` | button/pill/primitive regression | **47 / 47 pass** |

### 7.2 Downstream compilation (independent)

| Command | Package | Result |
| :--- | :--- | :--- |
| `flutter analyze lib test` | `packages/shared_auth` | **0 issues** |
| `flutter analyze lib test` | `apps/staff_app` | **0 issues** |

No public API changed; downstream compilation is unaffected.

### 7.3 Complete `shared_core` suite (independent)

```powershell
flutter test   # working dir = packages/shared_core
```

**Result: 266 passed / 21 failed.** The full suite is **not green.** All 21 failures are pre-existing **historical golden pixel diffs**, unchanged from the Phase 01.1/Phase 01 baseline of 21 (`PHASE_01_COMPLETION.md` §4.2 — *reported*), and are owned by future phases:

| Owning phase | Count | Failing goldens |
| :--- | ---: | :--- |
| **Phase 03** (Complex Data Components) | 6 | `data_display_compact_en`, `_compact_ar`, `_compact_en_dark`, `_compact_ar_dark`, `_expanded_en`, `_expanded_ar` |
| **Phase 04** (Navigation Shells) | 15 | `shell_nav_mobile_en/_ar`, `shell_nav_tablet_en/_ar`, `shell_nav_desktop_en/_ar`, `shell_overflow_mobile`, `shell_overflow_mobile_ar`, `shell_overflow_dark_mobile`, `shell_master_detail_en/_ar`, `shell_drawer_mobile`, `shell_drawer_mobile_ar`, `shell_family_mobile`, `shell_family_desktop` |

Interim note: mid-pass, before the dark goldens of §6 were refreshed, the suite read `264 passed / 23 failed`. Those two extra failures were the Phase 02/03A dark goldens rendering the **pre-fix** light border; after the correction + refresh the suite returned to exactly the documented 21-failure baseline. **No new failure was introduced.**

### 7.4 Responsive, dark/light, interaction & visual verification performed

Only where supported by executed tests:

- **Responsive:** the Phase 02 catalog golden test renders the same primitives at **390 / 834 / 1400 px** (`phase02_primitives_mobile/tablet/desktop_en.png`) — evidence: 3 passing tests.
- **Light / dark:** the catalog renders **EN light, AR-RTL light, EN dark, AR-RTL dark** — evidence: 4 passing tests + 4 self-describing PNGs.
- **Interaction:** loading spinner swaps in place (`PrimaryButton`), transient shortcut badge/clear tooltip (`AppSearchField`), single-CTA empty state (`EmptyState`), and selection-sheet round-trip (`showAppSelectionSheet`) — evidence: `shared_primitives_phase02_test.dart` (5 tests) + `app_interaction_states_test.dart` + `app_button_accessibility_test.dart`.
- **Visual:** 9 deterministic catalog goldens (7 primitives + confirmation dialog + selection sheet).

No responsive/interaction claim is made beyond what these tests cover.

---

## 8. Outstanding Palette Violations & Owning Phases

Discovered outside Phase 02 scope; left in place per the migration-ownership rule and pinned in the guard allowlists so they cannot be silently forgotten.

| File | Violation | Owning phase |
| :--- | :--- | :--- |
| `app_page_frame.dart` | raw `AppColors.borderDefault` border (dark-mode incorrect) | **Phase 04** |
| `notification_bell.dart` | raw `AppColors.danger` / `AppColors.warningBorder` / `AppColors.navy` | **Phase 04** |
| `offline_banner.dart` | raw `AppColors.warning*` fill / border / icon | **Phase 04** |
| `app_table.dart` + `data_display_*` components/goldens | Phase 03 data-presentation surface + stale goldens (6) | **Phase 03** |

**Not classified as violations (intentional brightness-dependent behavior):** `dashboard_shell.dart` and `workspace_app_bar.dart` select system status-bar / navigation icon brightness from `theme.brightness`. This is genuine OS-chrome contrast behavior that must track brightness; it is a documented justified exception (`00_CONCEPT_A_DESIGN_SYSTEM.md` §6.3), not a palette-selection violation, and is therefore **not** added to the guard allowlists.

**Mandate.** Every allowlisted item must be **resolved or individually justified with an inline comment** inside its owning phase. The **Phase 21 monorepo audit** must confirm there is **no unexplained palette debt** — i.e. the `pendingFuturePhase` allowlist is empty or each remaining entry carries an explicit justification.

---

## 9. Preserved Concept A Decisions (No New Design Decisions)

This pass introduced **no new design decisions**. The following remain intact and are asserted by tests:

- **Hyper Cobalt `#215FE6`** authorized primary (accessible amendment over prototype `#2563EB`) — asserted in `app_semantic_theme_test.dart` contrast tests.
- **Brembo Crimson `#DC2626`** authorized danger (amendment over prototype `#EF4444`) — asserted likewise.
- **Arabic typography** single frozen **`×1.05`** line-height multiplier with zero letter-spacing — asserted (`AppTypography.forLocale`).
- **Geometry/radii ordering** `control < card < panel < dialog < sheet` — asserted.
- **Centralized theme architecture** (the `AppSemanticColors` `ThemeExtension`, `context.colors` / `context.semanticColors`, no competing providers) — asserted + source-guarded.
- **Navy inverse brand surfaces** (`AppCard.navy`, `AppInfoPanel.navy`) — preserved as justified fixed assets.

---

## 10. Phase 02 Gate Status & Remaining Items

| Gate | Result |
| :--- | :--- |
| **Gate 1 — Engineering** (`dart analyze` = 0; focused primitive tests pass) | ✅ **PASSED** (independent) |
| **Gate 2 — Visual** (catalog golden PNGs approved for Concept A fidelity) | ⏳ **PENDING PRODUCT OWNER** |

Remaining / out of scope for this pass:

1. **Product Owner visual sign-off** of the Phase 02 catalog goldens.
2. Phase 03 (`app_table.dart`, data components) — **not started**.
3. Phase 04 palette migration (`app_page_frame.dart`, `notification_bell.dart`, `offline_banner.dart`) — owned by Phase 04.
4. Historical `data_display_*` (6) and shell (15) goldens — owned by their phases; Phase 21 verifies none remain.

**Phase 03 was not begun. The roadmap and acceptance criteria were not altered.**
