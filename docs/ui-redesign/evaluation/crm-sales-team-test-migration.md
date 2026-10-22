# Sales team list test migration (list family recomposition)

Branch: `ui/list-crm`. Leaderboard recomposed presentation-only:
`crmUiProvider.salesTeam` feed, rank/medal derivation, figures and order
untouched. Characterization tests were written against the CURRENT list
FIRST (4 testWidgets, GREEN before touching UI) and migrated after the
rebuild (6 testWidgets, all structural). Counts never down (4 -> 6).

## Inventory (existing CRM tests before this change)

- Old sales-team assertion count: **0**. New characterization count
  before touching UI: **4 testWidgets** in
  `apps/crm_app/test/crm_sales_team_characterization_test.dart`
  (all structural, GREEN). Counts did not go down (0 -> 4).
- After recomposition: **6 testWidgets** in the same file. Before-
  captures (4 PNGs) in
  `docs/ui-redesign/baseline/before-crm-salesteam/` were generated with
  `--update-goldens` and compared back-to-back GREEN before the rebuild
  (idle, empty, dark, ar).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| header | `SectionHeader` title + subtitle | `AppPageHeader` (title `tmTitle` + subtitle `tmSub` + count) | structural |
| rows | bespoke bordered+shadow `Container` + gradient avatar + hardcoded styles; `#n` rank; LTR revenue; 3 stat pills; `LinearProgressIndicator` + `Semantics` label | borderless `AppSurfaceCard(outlined: false)` + `AppAvatar` (40) + theme type + rank badge (`#n`, accent tint ≤ 3) + tabular LTR revenue + 3 token stat blocks + `AppProgressBar` (pinned accent, same value + semantics) | structural |
| medal rule | `#1` accent circle, `#4` plain | same rule, same copy | structural |
| empty | legacy `EmptyState` (action-less) | `AppEmptyState` (same icon/title/message, NO action — U6 calm empty) | structural |
| view-only | no `InkWell`/`GestureDetector` | no tappable widgets (no destinations invented; `AppAvatar` display-only) | structural |
| dark + ar + 1.3x + 320px | (not covered) | pumps clean (revenue/figures LTR-locked, pills wrap) | structural |

## Behavior kept verbatim (presentation only — no logic changes)

- `salesTeam` feed, rank order, medal rule (`rank <= 3`), figures
  (`revenue` verbatim LTR, `leadsHandled`/`wonDeals` counts,
  `winRate` math + `clamp(0,1)`), empty copy, `Semantics` win-rate
  label text. Rows stay view-only (no destinations invented).
- Copy: all `tm*` keys reused. No new keys. No ALL CAPS added.

## Deviations / notes (presentation-only, filed here)

- No search (reasoned U1 exception — brief §U1): the ranked roster has
  no per-row destination and fits one screen on every matrix size; a
  search icon would add chrome for zero saved taps (U0). The family
  > 5 sheet applies if rosters ever exceed one screen.
- Gradient avatar removed (C16 no-gradients) → `AppAvatar` pale-brand
  pair; per-pill accent/green/purple washes removed (decorative) →
  calm `surfaceAlt` stat blocks (C16 one-accent); revenue keeps the
  success ink (positive figure — semantic, not decorative).
- `AppProgressBar` auto-tone would recolor by value (new meaning), so
  the tone is pinned to accent with the same value + semantics.
- No skeleton/error branches: no loading/error signals exist in the
  team feed (sync list renders from cache; empty covers no-data) —
  filed as a logic candidate in the session return.

## Tap table (AFTER ≤ BEFORE — no regression; EXACT counts)

| Task | Before (EXACT) | After (EXACT) |
|---|---|---|
| Open standings | 1 tap (tab) | ≤ 1 tap (unchanged) |
| Compare members | scroll only, 0 taps | scroll only, 0 taps |

## New ARB keys

None. All copy reuses `tm*`. (`flutter gen-l10n` re-ran clean for the
leads/tasks keys on this branch; no sales-team keys added.)
