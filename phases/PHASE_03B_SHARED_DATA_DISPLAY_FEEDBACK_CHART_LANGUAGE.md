# PHASE 03B — Shared Data Display, Feedback & Chart Language

## A. Phase identity

- **Phase number:** 03B (part 2 of 2; split from the former Phase 03)
- **Title:** Shared Data Display — skeletons, empty/error states, tables, chart theme, list-surface recipes
- **Objective:** Add the remaining catalog half: standardized skeletons matching final layouts, final empty/error/no-match variants, desktop table primitives (header/data row/kebab/hover/selection), the shared chart theme helper, and the documented list-surface recipe. After 03A + 03B, no feature screen has an excuse to hand-roll a loading, empty, error, table, or chart style.
- **Priority:** Critical (blocks listing-heavy phases 12–19)
- **Dependencies:** Phase 03A (primitives used by table rows/kebab menus)
- **Estimated scope:** Medium-Large

## B. Repository context

- Existing pieces to finalize:
  - `packages/shared_core/lib/src/widgets/app_skeleton.dart` (pulse primitive
    only — needs layout-shaped variants),
  - `empty_state.dart` (`EmptyState`, `EmptyState.error`), `error_view.dart`,
    `loading_indicator.dart` (`LoadingIndicator`, `ShimmerLoading`),
  - `offline_banner.dart` (feedback; verify final copy localization),
  - `app_page_frame.dart` / `app_page_header.dart` / `app_top_bar.dart`
    (layout chrome; polish only if needed by list/detail recipes — structural
    ownership stays Phase 04).
- Known duplications to replace later (documented here, replaced in owning
  phases):
  - owner `owner_shimmer_skeletons.dart` shimmer (→ `AppSkeleton` compositions; Phase 12/13),
  - staff `staff_shimmer_skeletons.dart` `ShimmerBox` (→ `AppSkeleton`; Phase 11),
  - customer `customer_skeleton.dart` + ad-hoc `_DetailSkeleton`s (→ `AppSkeleton`; Phase 15B/17),
  - ad-hoc tables/rows in owner lists, CRM recent leads, customer invoice lines
    (→ table primitives; Phases 13A/19A/17),
  - chart styling drift across `apps/owner_app/.../dual_line_painter.dart` +
    `bar_chart_painter.dart`, staff advisor `fl_chart` usage, CRM `CustomPaint`
    — unified by the chart theme helper.
- Consumers: every feature phase; consumers at this point remain shells/auth.
- Spec: `00_DESIGN_SYSTEM_SPEC.md` §7 (registry), §13 (density), §17 (DoD).

## C. Design objectives

1. **Skeletons that mirror reality:** `AppSkeleton` gains variants — text block,
  list rows, card, grid, chart, table — so first-load frames match the final
  layout shape (no generic grey slabs where the layout is predictable).
  Reduced-motion behavior: pause animation (static).
2. **Complete feedback triad:** `EmptyState` (empty vs no-match vs error
  variants with optional primary action), `ErrorView` (message + retry), plus
  the documented **list-surface recipe**: skeleton (first load) → empty/no-match
  → error+retry → pull-to-refresh, each with the exact widget to use.
3. **Table primitives:** desktop-class table building blocks used by owner and
  CRM:
  - `AppTableHeader` (sortable indicator slot, sticky),
  - `AppTableRow` (hover/selected states, 36–44 px density, kebab slot),
  - `AppTableEmpty` (in-table empty), column alignment helpers (money/quantity
    tabular, end-aligned per direction).
  Below `medium`, tables degrade to `AppRecordRow` lists (the recipes document
  the switch point; components accept a `compact` fallback builder).
4. **Chart language:** `AppChartTheme` — palette (light/dark), axis label
  typography, tooltip style, gridline subtleness, legend/order RTL rules,
  empty-data placeholder style, max-2-series rule documented. Pure
  colors/typography/geometry helper: **must not depend on `fl_chart`** so owner
  painters, staff fl_chart charts and CRM painters all read the same source.
5. **Localized by construction:** all copy from `shared_core` ARB; no strings
   in recipes.
6. **No new dependencies.**

## D. Components and behavior (this phase's scope)

| Component | Final scope |
|---|---|
| `AppSkeleton` variants | text/list/card/grid/chart/table; pulse + reduced-motion static |
| `EmptyState` | empty, no-match, error constructors; icon/title/body/action; localized defaults |
| `ErrorView` | message + retry; optional details line for non-technical reason |
| List-surface recipe | documented widget sequence + test fixture demonstrating all four states |
| `AppTableHeader` / `AppTableRow` / column helpers / `AppTableEmpty` | density tokens; hover/selected; kebab; money alignment; compact fallback hook |
| `AppChartTheme` | palette (light/dark) + typography + tooltip + gridlines + legend RTL + empty placeholder |
| `LoadingIndicator` / `ShimmerLoading` | reconciled with `AppSkeleton` (deprecate if redundant — document) |

## E. Responsive specifications

- Skeleton variants render correct shapes at 320 / 390 / 768 / 1280 px.
- Table: full table ≥ expanded; `AppTableRow` density switch at medium; below
  medium the documented `AppRecordRow` fallback renders.
- 1.6× text scale: table rows grow without clipping (wrap or two-line cells per
  column type); skeletons stay proportional.
- RTL: table column order mirrors; kebab moves to end side; chart axis order
  mirrors via chart theme.

## F. Localization and RTL

- Shared ARB keys for all default copy (empty/error/skeleton labels are mostly
  visual; error retry labels localized).
- Tests: skeletons/empty/error/table in `en` and `ar`; RTL table order
  assertion; no 320 px overflow in either locale.

## G. Design system integration

- Extend/refactor only inside `packages/shared_core` (widgets + a new
  `lib/src/theme/app_chart_theme.dart`), additive exports.
- 03A primitives are consumed as-is; any gap found in 03A is fixed there
  (documented, small) rather than forked here.

## H. Technical implementation

- Files: `app_skeleton.dart` (variants), `empty_state.dart`, `error_view.dart`,
  new `app_table.dart`, new `app_chart_theme.dart`, `loading_indicator.dart`
  reconciliation, recipes doc under `packages/shared_core/docs/` (or a
  doc-comment block in `shared_core.dart` if the repo prefers no new docs dir).
- Tests: new `shared_data_display_test.dart` + extend
  `shared_components_visual_test.dart`; chart theme unit test (palette + RTL
  legend rule); table density/fallback tests.
- No feature-app edits (owners replace ad-hoc implementations in their phases).
- No new packages.

## I. Functional preservation

- No route/provider/API changes; no shell/nav changes (Phase 04 owns those).
- If `LoadingIndicator`/`ShimmerLoading` are deprecated, current consumers in
  shared packages are migrated in this phase; feature consumers listed for
  their phases.

## J. Testing requirements

- `melos run analyze`; `melos run test:core`; `melos run test:auth`.
- Widget tests: skeleton variants at 3 widths; empty/no-match/error; table
  hover/selected/kebab/fallback; chart theme RTL + empty placeholder; EN+AR;
  1.6× scale; 320 px no-overflow.
- Goldens: skeleton set, table (EN/AR, compact/expanded), list-surface recipe
  states.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality.
This phase is not complete until all of the following evidence exists:

1. **Rendered review** — render the list-surface recipe (all four states), the
   table at desktop density, and the chart theme samples; visually review each.
2. **Form factors** — renders at mobile (≤430 px), tablet (600–1023 px) and
   desktop (≥1280 px).
3. **Locales** — EN-LTR and AR-RTL renders for the recipe, table and charts.
4. **State matrix** — skeleton/empty/no-match/error/loaded captured with real
   entity-shaped fixtures (no placeholder text).
5. **Interaction verification** — table hover/selected/kebab; retry actually
   re-runs; pull-to-refresh; reduced-motion checkbox pausing shimmer.
6. **Accessibility** — 1.6× scale clean; table semantics (row = button when
   tappable); localized retry/labels; contrast sampled.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or `phases/reports/PHASE_03B/` pack. Section
   K is unmet without this evidence.

## K. Acceptance criteria

1. All §D items exist, exported, documented, tested.
2. Recipes documented with the exact widget sequence per state.
3. Table compact fallback proven at <600 px.
4. Chart theme produces consistent output in owner painters, fl_chart usage
   docs, and CRM painters (tests/examples demonstrate).
5. `melos run analyze` + core/auth suites green; J2 evidence attached.

## L. Deliverables

- Inventory of added/upgraded components; recipe doc location.
- Test evidence + `phases/reports/PHASE_03B/` pack.
- Migration notes for the ad-hoc implementations each later phase replaces.

## M. Completion gate

Stop after this phase — this closes the split former Phase 03. Phase 04 may now
begin only when explicitly instructed.
