# Phase 1P — Airbnb pattern widgets (additive, before any screen redesign continues)

## 1. Title + Goal
Build the 12 Airbnb building blocks from C16 in `shared_core` so every screen phase composes them
instead of re-inventing structure. Same standing orders as phase 1 (tokens, RTL, Semantics, measured
contrast, tests, gallery, captures, reviewer subagent). No app code changes.

## 2. Widgets (all `App*`, all new files in `packages/shared_core/lib/src/widgets/`)
1. `AppStepScaffold` — step flows: thin progress bar top, back arrow, headlineLarge question, subtitle,
   content, sticky bottom CTA bar, horizontal slide + fade step transition (200–300ms ease-out,
   reduced-motion aware).
2. `AppPageHeader` — large left-aligned headline + subtitle (screen opener, no dense toolbar).
3. `AppStickyActionBar` — sticky bottom bar: summary/status left, primary CTA right, keyboard-safe,
   safe-area aware.
4. `AppSearchPill` — rounded pill search bar (distinct from `AppSearchBar` if behavior differs; else extend).
5. `AppCarousel` — horizontal carousel with peeking next card (~2.2 visible), section header + "Show all".
6. `AppMediaCard` — icon/image top, title, meta, status pill; radius 20, soft shadow, NO border, no nesting.
7. `AppListGroup` — icon rows grouped by section with inset hairline dividers; no cards-in-cards.
8. `AppProfileHeader` — large avatar header block.
9. `AppSheetPicker` — list/search picker in a bottom sheet with handle + "Show N results" button.
10. `AppSummaryRow` — label/value row for sticky bars and receipts (tabular LTR numbers).
11. `AppOrDivider` — "or" divider.
12. `AppAltAuthRow` — outlined full-width row with leading icon (alternative auth paths).

## 3. Rules
- Reuse existing App* widgets inside; no duplicates, no parallel styling.
- Additive only; extend existing App* where parity requires (with tests), never change existing behavior.
- Tokens only; Semantics on interactive + state changes; AA contrast asserted; RTL (ar) + dark; 320px + 1.3x.
- Gallery section + captures (light/dark × 1.0/1.3 × LTR/RTL) + reviewer pass before commit.

## 4. Definition of done
12 widgets + unit tests green, gallery PNGs judged, `tool/*.sh` green, PROGRESS ticked, commit +
tag `ui-phase-1P-done`, merge tag into `airbnb_style` (phase-1 git precedent).
