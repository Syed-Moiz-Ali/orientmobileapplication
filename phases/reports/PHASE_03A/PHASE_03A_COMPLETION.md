# PHASE 03A — Shared Primitives (Actions, Inputs & Surfaces): Completion Report

- **Date:** 2026-10-13
- **Phase:** 03A — Shared Primitives (`phases/PHASE_03A_SHARED_PRIMITIVES_ACTIONS_INPUTS_SURFACES.md`)
- **Status:** **IMPLEMENTATION COMPLETE — awaiting product-owner review**
- **Toolchain:** Flutter 3.35.7 stable · Dart 3.9.2 · Windows dev machine
- **Authorities:** `00_DESIGN_SYSTEM_SPEC.md` (§7 registry, §8 a11y, §12 form UX,
  §13 density), `00_VISUAL_DIRECTION.md` (frozen V1–V14 + Phase 01.1 ink
  amendment), `00_RESPONSIVE_STRATEGY.md`, `00_LOCALIZATION_RTL_STRATEGY.md`,
  Phase 00 prototype (`apps/design_prototype/**` — read-only, **0 changes**)

---

## 1. Components implemented or refined

Every component in Phase 03A §D is finalized in `packages/shared_core`. All
variants/states are resolved from approved tokens, localized (EN+AR), RTL-safe,
and 1.6× text-scale safe.

### New components (the five proven gaps, §B)

| Component | File | Notes |
|---|---|---|
| `AppQuantityStepper` | `app_quantity_stepper.dart` | −/+ with long-press repeat, min/max/step, tabular value, RTL mirror, disabled/loading/error states, localized increase/decrease tooltips |
| `AppSelectionSheet` + `showAppSelectionSheet` | `app_selection_sheet.dart` | Searchable single-select sheet (>8 options), selected check + `Semantics(selected)`, localized empty-results, bottom-sheet↔dialog switch via `showAppModalSheet` |
| `showAppSnackBar` | `app_snackbar.dart` | Single-line outcome + optional action (Undo/Retry), neutral/success/danger tones |
| `PendingSyncChip` | `pending_sync_chip.dart` | `notSent`/`queued`/`failed`/`synced`, localized, icon+text+color (never color alone), dark-safe |
| Identifier `AppTextField` variant | `app_text_field.dart` | Forced-LTR content inside AR layouts (carried from Phase 02) — verified + exported; `AppSelectField` also added for sheet-backed dropdowns |

### Refined existing components

| Component | File | What changed |
|---|---|---|
| `AppButton` system (`primary`/`secondary`/`tertiary`/`danger`/`quietIcon`/`compactInline`) + `PrimaryButton`/`SecondaryButton` | `primary_button.dart` | Contrast-increasing interaction overlays + 2 px focus ring (central), automatic RTL flip of directional icons, loading keeps active fill/ink, disabled unchanged |
| `AppTextField` | `app_text_field.dart` | + optional reveal/hide password toggle (localized), `maxLines`/`minLines`, `onTap`; default rendering byte-identical |
| `AppSearchField` | `app_search_field.dart` | + `focusNode`, `onSubmitted` passthrough (320 px safe, clear button, focus ring) |
| `AppDropdownButton` + `AppSelectField` | `app_dropdown_button.dart` | 52 px control, hint/disabled/label, dark-safe tokens; `AppSelectField<T>` routes to the searchable selection sheet |
| `AppCard` | `app_card.dart` | Brightness-aware variant resolution (standard/subtle/outlined/selected) — light output byte-identical, dark parity fixed (was white-on-white) |
| `AppInfoPanel` | `app_info_panel.dart` | Semantic tones now resolve from approved tokens and the dark parity map (was fixed light constants) |
| `AppRecordRow` | `app_record_row.dart` | Wrapped in `Semantics(button:, enabled:)` when tappable (≥48 px preserved) |
| `AppKpiCard` | `app_kpi_card.dart` | + `wide` layout and `KpiTrend.isFlat`; value scale-down (matches approved prototype); dark-safe semantic/icon tints; ≥156 px scale-aware retained |
| `StatusPill` | `status_pill.dart` | Already D-complete (semantic tones + dot + flex-ellipsis); unchanged |
| `AppLinearProgress` / `AppStepProgress` | `app_progress.dart` | `AppLinearProgress` gains indeterminate (`value: null`) + dark-safe track; step progress dark-safe check ink and track |
| `AppActionBar` | `app_action_bar.dart` | + `isLoading` (localized busy affordance + absorbs input) and opt-in `sticky` decoration; compact stacking retained |
| `AppConfirmationDialog` / `showAppConfirmationDialog` | `app_confirmation_dialog.dart` | Destructive dialogs put the safe choice (Cancel) in initial focus |
| `showAppModalSheet` | `app_bottom_sheet.dart` | Verified as the single sheet entry point (640/600 px dialog switch, RTL) — unchanged |
| `AppFormField`/`AppFormSection`/`AppFormPanel` | `app_form_primitives.dart` | `AppFormField` gains the single "Optional" marker (spec §12.2); title rhythm retained |
| `AppDateSelectorShell` / `AppMediaUploadShell` | `app_form_primitives.dart` | Upload shell gains `hasError`/`errorLabel`/`onRetry` failed state (localized Retry) alongside the loading (pending) state |
| `SectionHeader`, `UserAvatar`, `NotificationBell` | `app_form_primitives`, … | `UserAvatar` tappable semantics label localized (was hard-coded "Open profile"); others verified |
| `AppInteractionStates` (new, central) | `app_interaction_states.dart` | Single source of truth for interaction overlays + focus rings (see §5) |

---

## 2. File paths changed

### Production — `packages/shared_core`

New:
- `lib/src/theme/app_interaction_states.dart`
- `lib/src/widgets/app_quantity_stepper.dart`
- `lib/src/widgets/app_selection_sheet.dart`
- `lib/src/widgets/app_snackbar.dart`
- `lib/src/widgets/pending_sync_chip.dart`

Modified:
- `lib/shared_core.dart` (additive exports)
- `lib/src/theme/app_theme.dart` (central overlays on elevated/filled/outlined/text button themes)
- `lib/src/widgets/directional_icon.dart` (`isDirectional` helper)
- `lib/src/widgets/primary_button.dart`
- `lib/src/widgets/app_text_field.dart`
- `lib/src/widgets/app_search_field.dart`
- `lib/src/widgets/app_dropdown_button.dart`
- `lib/src/widgets/app_card.dart`
- `lib/src/widgets/app_info_panel.dart`
- `lib/src/widgets/app_record_row.dart`
- `lib/src/widgets/app_kpi_card.dart`
- `lib/src/widgets/app_progress.dart`
- `lib/src/widgets/app_action_bar.dart`
- `lib/src/widgets/app_confirmation_dialog.dart`
- `lib/src/widgets/app_form_primitives.dart`
- `lib/src/widgets/user_avatar.dart`
- `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` (+ regenerated `lib/l10n/gen/**`)

### Tests — `packages/shared_core`

New:
- `test/app_interaction_states_test.dart`
- `test/shared_primitives_actions_test.dart`
- `test/support/phase03a_gallery.dart`

Modified:
- `test/shared_components_visual_test.dart` (gallery + 8 goldens, EN/AR × form factors, light/dark)

New golden baselines (`test/goldens/`): `shared_components_{mobile,tablet,desktop,mobile_ar,tablet_ar,desktop_ar,mobile_dark,mobile_dark_ar}.png`.

### Evidence — `phases/reports/PHASE_03A/`

`screens/` (8 renders), `capture/primitives_capture_test.dart`, `baseline/` and
`final_*.txt` logs.

*Not touched:* `apps/design_prototype/**` (git-verified 0 changes), all four
apps' production source, `shared_auth` production source, routes/providers/APIs.

---

## 3. Public API compatibility

**No exported symbol was removed or renamed.** Every change is additive:

- `PrimaryButton`/`SecondaryButton`/`AppButton.*` — same constructors/param names; new optional params only (`mirrorIcon`, `mirrorLeadingIcon`/`mirrorTrailingIcon`).
- `AppTextField` — all existing params intact; new `maxLines` (default 1 = previous behaviour), `minLines`, `onTap`, `onToggleObscure`; default rendering **byte-identical**.
- `AppCard` — same constructors and params; the internal color resolution moved into `build` (light output byte-identical, verified: all four app suites at baseline and light gallery goldens unchanged).
- `AppKpiCard`/`AppKpiCard.compact` — unchanged; `isWide` and `AppKpiCard.wide`/`KpiTrend.isFlat` additive.
- `AppLinearProgress` — `value` widened from `double` to `double?` (`null` = indeterminate); existing call sites pass a `double` and compile unchanged.
- `AppActionBar`, `AppInfoPanel`, `AppStatusPill`, `AppFormField`, `AppMediaUploadShell`, `AppSearchField`, `AppDropdownButton` — additive params only.
- `UserAvatar` semantics string now localized (no signature change).
- `showAppModalSheet`/`showAppConfirmationDialog` — unchanged signatures.

`AppDropdownButton` is fully replaced by a re-authored equivalent (height 48→52,
dark-safe tokens, `label`/`hint`/`enabled`/`isExpanded` params); it had **no
production consumers** (verified by repository search), so nothing else needed
updating.

**Documented behavior changes (intentional):**
1. Interaction overlays for filled/elevated/outlined/text buttons now darken
   light-ink fills and lighten dark-ink fills (see §5). This aligns with the
   frozen `primaryHover`/`primaryPressed` tokens and only affects
   hover/pressed/focus (no static-render/golden impact).
2. `AppInfoPanel` semantic light backgrounds now use the approved
   `AppColors.*Subtle/*Border` tokens instead of ad-hoc hex values. No app screen
   consumes `AppInfoPanel` (verified), so no feature golden shifts.
3. `AppKpiCard` value now scale-downs instead of clipping. No app screen consumes
   `AppKpiCard` (verified), so no feature golden shifts.

---

## 4. Variants and interaction states

| Primitive | Variants | States covered (tests) |
|---|---|---|
| Buttons | primary, secondary, tertiary, danger, quietIcon, compactInline | default, hover, pressed, focus, disabled, loading (busy keeps fill/ink) |
| Text/search/identifier fields | normal, error, identifier(LTR), obscured+toggle, multiline | default, error, focused, disabled |
| Dropdown/Select | menu (≤8), sheet (>8, searchable) | default, hint, disabled, selected, empty-results |
| Quantity stepper | normal, disabled, loading, error | min/max clamp, long-press, RTL |
| Cards | plain, standard, subtle, outlined, selected, navy, semantic | light + dark |
| Info panels | neutral, primary, success, warning, danger, navy | light + dark |
| Record row | leading/title/subtitle/metadata/status/trailing | tappable semantic button, 320 px |
| KPI | standard, compact, wide (trend up/down/flat) | scale-aware, dark |
| Status pill | neutral/info/success/warning/danger/in-progress + dot | flex-ellipsis |
| Progress | determinate, indeterminate, step | RTL, dark |
| Action bar | compact stacked / wide row, loading, sticky | compact vs expanded |
| Dialog/sheet | standard, destructive, sheet↔dialog ≥600 px | safe-default focus |
| Snackbar | neutral, success, danger + action | action fires |
| Sync chip | notSent/queued/failed/synced | EN + AR |

---

## 5. Accessibility results

### 5.1 Central interaction-state correction (closes the Phase 01.1 deviation)

`AppInteractionStates` derives every enabled interaction overlay from the
**opposite of the control ink** (black on light inks, white on dark inks), so
composited label contrast always *increases* in hover/pressed/focus. Applied
centrally to `PrimaryButton`/`SecondaryButton`, all `AppButton` variants, and the
Material `elevated/filled/outlined/text` button themes.

Computed composited contrast (WCAG 2.1), `app_interaction_states_test.dart`:

| Control | Rest | Hover (8 %) | Pressed (12 %) | Focus (10 %) |
|---|---|---|---|---|
| Light danger `#D92D43` / white | 4.77 | 5.47 | 5.87 | 5.67 |
| Light primary `#3157D5` / white | 6.08 | 6.87 | 7.31 | 7.08 |
| Dark primary `#6E8BFF` / `#0C1120` | 6.09 | 6.73 | 7.08 | 6.90 |
| Dark danger `#F1707F` / `#0C1120` | 6.59 | 7.16 | 7.47 | 7.31 |

- **Light danger pressed was ≈4.21:1 (below AA) → now 5.87:1.** All enabled
  states for every button variant are ≥4.5:1. Genuinely disabled states keep the
  established dimmed treatment (WCAG-exempt, no regression).
- Focus: a visible 2 px focus ring resolves from the frozen `focus`/`primary`
  token on focused (spec §8.4); verified in test.
- Touch targets: buttons, stepper, dropdown, select, rows, dialog actions all
  ≥48 px.
- `Semantics`: tappable record rows expose `isButton`; selected options expose
  `selected`; icon-only controls have localized tooltips/labels.

### 5.2 Text scaling

All 03A primitives render without overflow at **1.6× text scale** at 320 px in
both locales (test-proven); KPI tiles remain scale-aware (≥156 px × scale).

---

## 6. English / Arabic and RTL verification

- **14 new `shared_core` ARB keys, EN+AR complete** (parity test + empty
  untranslated file green): `commonUndo`, `commonLoading`, `commonIncrease`,
  `commonDecrease`, `commonSelect`, `commonNoResults`, `commonShowPassword`,
  `commonHidePassword`, `userAvatarOpenProfile`, `commonOptional`,
  `pendingSyncNotSent`, `pendingSyncQueued`, `pendingSyncFailed`,
  `pendingSyncSynced`. Total `shared_core` keys: **70**.
- Shared widgets read their own copy from `SharedCoreLocalizations` (data-in /
  copy-out rule); contextual labels remain parameters.
- RTL: quantity stepper control order mirrors; directional button icons flip via
  `DirectionalIcon`; selection-sheet rows/check mirror; progress and action bars
  mirror via `Directionality`. Verified in AR widget tests and the AR render
  pack.
- Technical identifiers keep Latin LTR (`AppTextField.isIdentifier`), proven in
  the Arabic gallery render (Latin plate "A 12345" inside an Arabic form).

---

## 7. Responsive validation

- Catalog rendered and reviewed at **390 px (compact), 834 px (tablet), 1400 px
  (expanded)**; widget tests also cover **320 px** and 768/1024 widths.
- Compact: action bar stacks; KPI 2-up; record rows single column; no horizontal
  overflow at 320 px in either locale (test-proven).
- Medium/expanded: action bar lays out horizontally; `showAppSelectionSheet`
  switches from bottom sheet (<600 px) to a bounded centered dialog (≥600 px) —
  both branches tested.
- No overflow exceptions in any catalog render.

---

## 8. Screenshot / golden evidence

- Goldens (suite baselines): `packages/shared_core/test/goldens/shared_components_*.png` — 8 files.
- Report pack (`phases/reports/PHASE_03A/screens/`, `primitive_width_locale_state.png`):

| File | Proves |
|---|---|
| `primitives_390_en_light.png` / `primitives_390_ar_light.png` | Full catalog, compact, EN-LTR vs AR-RTL (mirrored, Latin identifiers) |
| `primitives_834_en_light.png` / `primitives_834_ar_light.png` | Tablet width |
| `primitives_1400_en_light.png` / `primitives_1400_ar_light.png` | Expanded/desktop width |
| `primitives_390_en_dark.png` / `primitives_390_ar_dark.png` | Dark parity (cards, panels, buttons, chips) |

The gallery uses real entity shapes (plate `A 12345`, `JOB-4091`,
`Mercedes-Benz E300`, `AED 42,500`, real statuses) — no placeholder text.
Capture harness archived at `capture/primitives_capture_test.dart`.

---

## 9. Tests executed and exact results

Baseline captured **before** implementation (this session); final after. Run
per package (`melos` scripts remain unusable in this workspace — see Phase 01
report §9).

| Unit | Baseline (pass/fail) | Final (pass/fail) | New failures | Notes |
|---|---|---|---|---|
| `shared_core` | 155 / 9 | **189 / 6** | **0** | +31 test cases (20 primitive + 6 interaction + 5 added gallery); **3 previously-missing component goldens resolved**; 6 remaining are non-component (shell_family ×5 → Phase 04, app_theme ×1 → Phase 01) |
| `shared_auth` | 35 / 11 | **35 / 11** | **0** | unchanged (out of scope) |
| `staff_app` | 277 / 7 | **277 / 7** | **0** | unchanged baseline set |
| `owner_app` | 21 / 0 | **21 / 0** | **0** | unchanged |
| `customer_app` | 511 / 6 | **511 / 6** | **0** | unchanged baseline set |
| `crm_app` | 14 / 0 | **14 / 0** | **0** | unchanged |
| `design_prototype` | 299 / 0 | **299 / 0** | 0 | read-only; git-verified 0 changes |

**Static analysis:** `dart analyze` → **0 issues** on all six production units
and `apps/design_prototype`.

New tests (all passing):
- `app_interaction_states_test.dart` (6): light/dark primary & danger label
  contrast ≥4.5:1 in every enabled state; 2 px focus ring; overlay-tone policy.
- `shared_primitives_actions_test.dart` (20): stepper clamp/disabled/loading/RTL
  320 px; selection sheet search/empty/return + dialog≥600 px; `AppSelectField`;
  snackbar action; sync chip EN/AR; form optional marker; media-upload failed
  retry; action-bar loading absorption; wide/flat KPI; indeterminate progress;
  record-row semantics; dark info panel; 320 px/1.6× AR sweep.
- `shared_components_visual_test.dart` (8 gallery goldens).

---

## 10. Existing versus new failures

- **Newly introduced:** **none** in any unit.
- **Pre-existing (unchanged, recorded baseline):** `shared_core` shell_family
  visual goldens (5, owned by Phase 04) and `app_theme_visual_test` (1, owned by
  Phase 01); `shared_auth` 11 missing auth goldens (owned by Phase 05); staff 6
  intake overflows + 1 advisor-workflow finder (07A/08); customer 3 light
  goldens (16). None is caused or touched by Phase 03A.
- **Resolved:** the 3 component-owned missing goldens
  (`shared_components_{mobile,tablet,desktop}`) now exist and pass — regenerated
  from the real catalog and visually reviewed (not blind regeneration).
- No golden was regenerated except the eight new `shared_components_*` component
  baselines (this phase's own catalog). No feature-app golden was touched. The
  Phase 00 prototype and its goldens are untouched.

---

## 11. Deferred issues and owning phases

| Item | Owner phase |
|---|---|
| Shell-family visual goldens (nav/rail/drawer) | 04 |
| `app_theme_visual_test` baseline | 01/20 |
| Auth-experience visual goldens | 05 |
| Feature screens consuming the new primitives (stepper in parts request, selection sheet in pickers, sync chip in offline UX, snackbar undo in lists) | 08, 07A/B, 16, 18, 19B |
| Adopting `AppSelectField`/`AppQuantityStepper` in advisor/technician/CRM screens | 06–19C |
| Melos 8 workspace migration | tooling (unscheduled) |

---

## 12. Readiness for Phase 03B

**Ready.** The interactive primitive layer is complete, exported, documented and
tested:

- all §D components exist with stable, additive APIs; consumers from Phases 04–05
  (shells/nav/auth) compile and behave unchanged (all app suites at baseline);
- every primitive uses approved tokens, is EN+AR + RTL + 1.6× clean, and meets
  WCAG AA in all enabled states;
- the five gap components have named future consumers;
- 8 fresh component goldens + 8 report renders provide reviewable evidence.

**Phase 03A completion checklist**

- [x] Every §D component implemented/refined and exported
- [x] Approved semantic tokens; light/dark parity
- [x] Five gap components added with identified consumers
- [x] English/Arabic rendering correct; 14 new ARB keys, parity green
- [x] RTL behavior correct (stepper, icons, sheets, progress, bars)
- [x] Responsive 320/390/834/1400 verified, no overflow
- [x] Accessible text scaling to 1.6× (test-proven)
- [x] Interaction states tested; contrast ≥4.5:1 (danger pressed fixed)
- [x] Public API compatible (additive); documented behavior changes listed
- [x] `melos run analyze` equivalent: 0 issues × 7 units; core/auth suites green
- [x] J2 evidence pack attached (`phases/reports/PHASE_03A/`)
- [ ] Phase 03B — awaiting explicit authorization (not started)
