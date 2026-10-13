# PHASE 03A — Shared Primitives: Actions, Inputs & Surfaces

## A. Phase identity

- **Phase number:** 03A (part 1 of 2; split from the former Phase 03)
- **Title:** Shared Primitives — buttons/actions, inputs/search/select, steppers, cards/panels, record rows, KPI tiles, status pills, progress, action bar, dialogs/sheets, form primitives
- **Objective:** Finalize the interactive primitive layer of the component catalog in `packages/shared_core` — every control a form, action bar, list row or card needs — with stable APIs, full state matrices, EN/AR + RTL + 1.6× tests, so no feature phase hand-rolls a button, field, card or row again.
- **Priority:** Critical (blocks every feature phase)
- **Dependencies:** Phases 01, 02
- **Estimated scope:** Large

## B. Repository context

- Existing files to finalize (all under `packages/shared_core/lib/src/widgets/`):
  `primary_button.dart` (`AppButton` system), `app_text_field.dart`,
  `app_search_field.dart`, `app_dropdown_button.dart`, `app_card.dart`,
  `app_info_panel.dart`, `app_record_row.dart`, `app_kpi_card.dart`,
  `status_pill.dart`, `app_progress.dart` (`AppLinearProgress`,
  `AppStepProgress`), `app_action_bar.dart`, `app_confirmation_dialog.dart`,
  `app_bottom_sheet.dart` (`showAppModalSheet`), `app_form_primitives.dart`
  (`AppFormField`, `AppFormSection`, `AppFormPanel`, `AppDateSelectorShell`,
  `AppMediaUploadShell`), `section_header.dart`, `user_avatar.dart`,
  `notification_bell.dart`.
- Known gaps proven by the analysis (must be added here):
  - quantity stepper (used by parts request, inventory adjust, estimate lines),
  - searchable selection sheet for dropdowns with >8 options (brand/model
    pickers, supervisor tech pickers, message recipients),
  - snackbar-with-action helper (undo/retry patterns),
  - pending-sync chip ("Not sent yet" / queued) used by customer + staff sync UX,
  - identifier `AppTextField` variant (LTR content inside AR layouts — Phase 00
    screen D4 pattern).
- Consumers at this point: shells, navigation, auth (Phases 04–05), and every
  feature phase after. Feature screens still on legacy code paths untouched here.
- Deprecation list this phase must document (replacement → owning feature phase):
  advisor `inspection_widgets.dart` kit (→ tools here; removed in Phase 08),
  customer `customer_surface_panel.dart` (→ `AppCard`; replaced in 15A/15B),
  CRM `crm_constants.dart` (→ tokens; removed in 19C), owner ad-hoc search
  fields (→ `AppSearchField`; replaced in 13A/13B).
- Spec: `00_DESIGN_SYSTEM_SPEC.md` §7 (registry), §8 (a11y), §12 (form UX), §13 (density).

## C. Design objectives

1. **One API per primitive** with documented variants and states (default /
   hover / pressed / focus / disabled / loading / error where applicable).
2. **State completeness:** loading-in-button (no layout jump), inline error
   borders + messages, disabled contrast, focus rings per spec §8.
3. **Localized + RTL + scale:** zero hard-coded strings (shared_core ARB),
   direction-safe layout, 1.6× text-scale safe, screenshots per Phase 00
   direction.
4. **Density behavior:** record rows, KPI tiles, action bars honor spec §13
   across compact/medium/expanded/large via `context.adaptive`.
5. **Data-in/copy-out rule** (Phase 02): components take data as parameters and
   read their own copy from `SharedCoreLocalizations`; contextual labels stay
   parameters.
6. **No new dependencies.**

## D. Components and behavior (this phase's scope)

| Component | Final scope |
|---|---|
| `AppButton` system | primary/secondary/tertiary/danger/quietIcon/compactInline; sizes; loading; disabled; RTL icon flip |
| `AppTextField` (+ identifier variant) | label above; helper/error below; icon slots; obscure toggle; LTR identifier variant; input formatters hook |
| `AppSearchField` | clear button; debounce hook; focus ring; 320 px safe |
| `AppDropdownButton` + selection sheet | 52 px control; searchable sheet >8 options; selected state; empty-results state |
| Quantity stepper | −/+ with long-press repeat optional; min/max/step; tabular value; RTL mirroring |
| `AppCard` | default / subtle / strong(navy) / semantic-tinted variants |
| `AppInfoPanel` | neutral/primary/success/warning/danger/navy tones |
| `AppRecordRow` | leading/title/metadata/trailing (value, chevron, badge); ≥48 px; semantic button when tappable |
| `AppKpiCard` | compact/standard/wide; trend up/down/flat; semantic states; tappable |
| `StatusPill` | semantic tones + dot variant; localized label via parameter |
| `AppLinearProgress` / `AppStepProgress` | determinate/indeterminate; RTL mirroring of determinate; step states |
| `AppActionBar` | sticky bottom actions; stacks on compact; loading state |
| `AppConfirmationDialog` | standard + destructive; safe-default focus |
| `showAppModalSheet` | verified as the single sheet entry point; 600 px dialog switch; RTL |
| `AppFormField/AppFormSection/AppFormPanel` | section rhythm per spec §12; label placement; required marker |
| `AppDateSelectorShell` / `AppMediaUploadShell` | picker shell; upload preview + pending/failed states |
| Snackbar-with-action helper | outcome + optional action (Undo/Retry) |
| Pending-sync chip | "Not sent yet" / queued variants, localized |
| `SectionHeader`, `UserAvatar`, `NotificationBell` | final polish per spec |

## E. Responsive specifications

- Catalog tests at 320 / 390 / 768 / 1280 px and 1.6× text scale (extend the
  existing shared-component test approach).
- Action bar stacking on compact; row metadata truncation rules; KPI 2-up
  compact / 4-up max.
- `showAppModalSheet`: bottom sheet on compact, bounded centered dialog ≥600 px;
  both branches tested.
- 320 px: identifier field, stepper, dropdown control and search field never
  overflow.

## F. Localization and RTL

- Every label/placeholder/semantic from `shared_core` ARB (EN+AR in the same
  change); parity test (Phase 02 machinery) stays green.
- Directional icons flip (chevrons, arrows); stepper buttons mirror; action bar
  button order mirrors logically; sheets mirror alignment.
- Widget tests run every primitive in `en` and `ar` asserting no overflow at
  320 px and correct `Directionality`.

## G. Design system integration

- Extend/refactor only inside `packages/shared_core/lib/src/widgets/` (+ ARB).
- Backward compatibility: existing constructors keep working for current
  consumers (shells, nav, auth from Phases 04–05); prefer additive parameters +
  deprecation annotations.
- Update `shared_core.dart` exports (additive only).

## H. Technical implementation

- Audit each listed file against spec §7 and upgrade missing variants/states.
- Add the new files for the five gaps in §B; each with a widget test file
  section in the existing test files (or a new
  `shared_primitives_actions_test.dart`).
- Golden coverage: extend `shared_components_visual_test.dart` for the six
  representative combos (EN/AR × compact/expanded) if goldens exist for them.
- No new packages; no feature-app edits.
- Charts/tables/skeletons are **not** in scope (Phase 03B).

## I. Functional preservation

- No route/provider/API changes.
- Current consumers (shells/nav/auth) must keep compiling and behaving; any
  changed constructor is updated in this phase for those consumers only and
  documented.
- Existing shared-component tests are the regression baseline; intentional
  changes documented with golden diffs.

## J. Testing requirements

- `melos run analyze`; `melos run test:core`; `melos run test:auth`.
- Per-primitive widget tests: default/hover/pressed/focus/disabled/loading/error
  where applicable; EN+AR; RTL; 1.6× scale; 320 px overflow check.
- Semantics assertions (labels, selected states, tappable rows).
- Goldens updated only for intentionally changed primitives.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality.
This phase is not complete until all of the following evidence exists:

1. **Rendered review** — render every finalized primitive in the visualization
   harness (extend the existing component gallery test page) and visually
   review its states; no primitive is signed off from code-reading alone.
2. **Form factors** — renders at mobile (≤430 px), tablet (600–1023 px) and
   desktop (≥1280 px) for the component gallery + one real in-app usage each
   (e.g. auth field, action bar in login, record row in a listing).
3. **Locales** — EN-LTR and AR-RTL renders for every primitive and its states.
4. **State matrix** — default/hover/pressed/focus/disabled/loading/error
   captured. Any fixture content mirrors real entity shapes — no "Lorem ipsum".
5. **Interaction verification** — press/hover/focus/loading transitions behave;
   stepper bounds; dropdown sheet search; sheet↔dialog switch at 600 px.
6. **Accessibility** — 1.6× scale clean; contrast sampled (incl. disabled and
   semantic tints); focus ring visible; semantics labels localized.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — golden diffs or screenshot pack
   `phases/reports/PHASE_03A/` named `primitive_width_locale_state.png`. Section
   K is unmet without this evidence.

## K. Acceptance criteria

1. Every component in §D exists, exported, documented, tested.
2. No primitive overflows at 320 px / 1.6× in either locale (test-proven).
3. RTL tests pass for all direction-aware primitives.
4. The five gap components exist with real consumers identified for later
   phases.
5. Deprecation appendix lists legacy kits → replacement → owning phase.
6. `melos run analyze` + core/auth suites green; J2 evidence attached.

## L. Deliverables

- Primitive inventory: added / upgraded / deprecated with file paths.
- New ARB keys (count, EN+AR); parity test status.
- Test evidence incl. RTL and 1.6× results; `phases/reports/PHASE_03A/` pack.
- Migration appendix (legacy pattern → primitive → phase).

## M. Completion gate

Stop after this phase. Phase 03B (data display / feedback / chart language) is
the other half of the former Phase 03 and may only start after this phase's
sign-off. Do not begin Phase 04 until 03B is also complete.
