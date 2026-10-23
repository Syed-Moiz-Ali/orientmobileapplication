# Sales team list test migration (list family recomposition)

Branch: `ui/list-crm`. Leaderboard recomposed presentation-only:
`crmUiProvider.salesTeam` feed, rank/medal derivation, figures and order
untouched. Characterization tests were written against the CURRENT list
FIRST (4 testWidgets, GREEN before touching UI) and migrated after the
rebuild (7 testWidgets, all structural). WAVE-2 fixes (F7 revenue
display, F8 roster search) migrated the same file to **10 testWidgets**,
all structural. Counts never down (4 -> 7 -> 10). Ruling (a) shell
relocation keeps the same file at **10 testWidgets** (assertions updated
verbatim below, none added/removed) + **8 new shell relocation tests** in
`apps/crm_app/test/crm_shell_search_relocation_test.dart` (all
structural). Counts never down (4 -> 7 -> 10 -> 10 + 8 shell).

## Inventory (existing CRM tests before this change)

- Old sales-team assertion count: **0**. New characterization count
  before touching UI: **4 testWidgets** in
  `apps/crm_app/test/crm_sales_team_characterization_test.dart`
  (all structural, GREEN). Counts did not go down (0 -> 4).
- After recomposition: **7 testWidgets** in the same file. Before-
  captures (4 PNGs) in
  `docs/ui-redesign/baseline/before-crm-salesteam/` were generated with
  `--update-goldens` and compared back-to-back GREEN before the rebuild
  (idle, empty, dark, ar).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| header | `SectionHeader` title + subtitle | `AppPageHeader` (title `tmTitle` + subtitle `tmSub` + count) | structural |
| header plain-Row + search (WAVE-2 F6/F8) | `AppPageHeader` (no find-aid; would stack a search icon below the title on compact) | plain `_TeamHeader` Row: title + subtitle + search icon top-end same-row ONLY when the roster has MORE THAN 5 rows; RTL-mirrored; same family > 5 rule as the leads/tasks lists | structural |
| rows | bespoke bordered+shadow `Container` + gradient avatar + hardcoded styles; `#n` rank; LTR revenue; 3 stat pills; `LinearProgressIndicator` + `Semantics` label | borderless `AppSurfaceCard(outlined: false)` + `AppAvatar` (40) + theme type + rank badge (`#n`, accent tint ≤ 3) + tabular LTR revenue + 3 token stat blocks + `AppProgressBar` (pinned accent, same value + semantics) | structural |
| revenue display (WAVE-2 F7) | bare `AED 12000` figure, no label | `_displayRevenue`: the `revenue` String renders through the existing `AppFormatters.moneyAED` (`AED 12,000` en / `12,000 د.إ` ar, Latin digits) + small `Revenue` label (`tmRevenue`) above the figure; digits extracted for display only — feed, order, rank math untouched; unparseable values render verbatim | structural |
| roster search (WAVE-2 F8) | (did not exist — brief reasoned no-search exception) | search icon ONLY when > 5 → `crm_sales_team_search_sheet.dart` (same list-scoped pattern as the leads/tasks sheets: field filters loaded roster by name/role, avatar rows, result tap reveals the row, no-match + Clear reusing `leadsFilterClear`); ≤ 5 = rows only | structural |
| medal rule | `#1` accent circle, `#4` plain | same rule, same copy | structural |
| empty | legacy `EmptyState` (action-less) | `AppEmptyState` (same icon/title/message, NO action — U6 calm empty) + `AppPageHeader` (`tmTitle` + `tmSub`) kept above it for orientation (U0) | structural |
| view-only | no `InkWell`/`GestureDetector` | no tappable widgets (no destinations invented; `AppAvatar` display-only) | structural |
| dark + ar + 1.3x + 320px | (not covered) | pumps clean (revenue/figures LTR-locked, pills wrap) | structural |

## Behavior kept verbatim (presentation only — no logic changes)

- `salesTeam` feed, rank order, medal rule (`rank <= 3`), figures
  (`revenue` verbatim LTR, `leadsHandled`/`wonDeals` counts,
  `winRate` math + `clamp(0,1)`), empty copy, `Semantics` win-rate
  label text. Rows stay view-only (no destinations invented).
- Copy: all `tm*` keys reused. No new keys. No ALL CAPS added.

## Deviations / notes (presentation-only, filed here)

- Search (reasoned U1 exception — brief §U1 — PARTLY LIFTED by WAVE-2
  F8): the exception covered the 3-row idle (no per-row destination,
  fits one screen — still holds, ≤ 5 shows no icon). A 6-row roster
  scrolls (`team_scrolled_...` proves overflow: Mia #3 clipped, Kris #6
  cut), so the family > 5 sheet now applies — same threshold as the
  leads/tasks lists. Rows stay view-only (search reveals, never
  navigates).
- Tie-rank display (standing): feed order, rank badges (`#n`, medal ≤ 3)
  and figures are byte-verbatim — WAVE-2 changed display only. All six
  fixture rows tied at the same revenue with forced `#1`–`#6` badges, so
  the longest bar (`#5` Lina 80%) still outranks `#1` visually; no
  re-sort applied (feed order is logic). Filed for the data owner, not
  changed here.
- Fixture diversification (test-data only, no production change):
  AFTER-capture fixtures (`crm_after_team_capture_test.dart` `_member`
  only) diversified from constant `AED 12000` to varied realistic
  revenues descending with rank (feed order): Sara `AED 48500` > John
  `AED 32750` > Mia `AED 26400` > Omar `AED 18900` > Lina `AED 15250` >
  Kris `AED 9800`. Names/roles/counts/winRate/order untouched
  (reorder-by-construction: the existing list order is already
  descending, so no rank-logic change); display still groups via
  `moneyAED` (`AED 48,500` en / `48,500 د.إ` ar). Characterization pins
  (`AED 12,000` x2 verbatim) untouched — diversification is
  AFTER-capture only. Recaptured `after-crm-sales-team/` (9 PNGs) with
  `--update-goldens` limited to the after-capture file, compared
  back-to-back GREEN. Counts never down (4 -> 7 -> 10).
- Gradient avatar removed (C16 no-gradients) → `AppAvatar` pale-brand
  pair; per-pill accent/green/purple washes removed (decorative) →
  calm `surfaceAlt` stat blocks (C16 one-accent); revenue keeps the
  success ink (positive figure — semantic, not decorative).
- `AppProgressBar` auto-tone would recolor by value (new meaning), so
  the tone is pinned to accent with the same value + semantics.
- No skeleton/error branches: no loading/error signals exist in the
team feed (sync list renders from cache; empty covers no-data) —
filed as a logic candidate in the session return.
- Adversarial round (team defect 4): the empty state keeps the
`AppPageHeader` (`tmTitle` + `tmSub`) above the action-less
`AppEmptyState` for orientation (U0). No new keys, no new taps.

## Tap table (AFTER ≤ BEFORE — no regression; EXACT counts)

| Task | Before (EXACT) | After (EXACT) |
|---|---|---|
| Open standings | 1 tap (tab) | ≤ 1 tap (unchanged) |
| Compare members | scroll only, 0 taps | scroll only, 0 taps |
| Find member (6-row roster) | scroll-hunt only (no find-aid) | scroll unchanged + ≤ 2 taps via new header search (> 5 only; U1 compliance, additive) |

## New ARB keys (en+ar, `flutter gen-l10n` from `apps/crm_app`)

WAVE-2: `tmRevenue` ("Revenue" / "الإيراد" — the small figure label; no
existing `tm*` key fit, so ONE new key), `tmSearchTitle` ("Search team" /
"البحث في الفريق"), `tmSearchHint` ("Search by name or role" / "ابحث
بالاسم أو الدور"), `tmSearchNoMatch` ("No team members match your
search." / "لا يوجد أعضاء فريق يطابقون بحثك."). No-match Clear reuses
`leadsFilterClear` (one Clear key for all three sheets). After-captures:
same 8 PNGs refreshed + **1 new frame**
(`team_search-open_light_1.0_en_360x800.png`) — 9 PNGs, back-to-back
GREEN. F10 verification (no code change): team empty keeps the
`Leaderboard` header; ar cards show `الإيراد` + grouped `12,000 د.إ`
with mirrored layout.

## Ruling (a) search relocation (presentation/flow-wiring only)

- Shell (`crm_dashboard_view.dart` `_CrmChrome`): the AppBar search
  trigger is the SINGLE visible icon on the sales-team tab — contextual,
  opening the EXISTING `showCrmSalesTeamSearchSheet` (same widget, same
  `salesTeam` feed), gated by the same `team.length > 5` family condition
  relocated from the list header. ≤ 5 → no trigger (fully scannable).
  Non-list tabs keep the palette untouched; Ctrl+K untouched.
- List (`crm_sales_team_page.dart`): `_TeamHeader` search params
  (`showSearch`/`onSearch`) + `openSearch`/`reveal` + search-sheet import
  REMOVED — header is title-only (rows stay view-only). Row keys stay. No
  logic/data/predicate change.
- Changed assertions (same 10 testWidgets, verbatim): `>5` test pins no
  header search + the same sheet opened directly (identical no-match +
  Clear pins, Sara restores); result-tap test pins clean sheet dismissal
  with no exception (no destinations invented).
- Tap table (AFTER ≤ BEFORE): Open standings ≤ 1; Compare scroll only;
  Find member (6-row) = scroll unchanged + ≤ 2 via shell search (> 5).
- Frames recaptured in the living dir `after-crm-sales-team/` (9 PNGs)
  with `--update-goldens` limited to `crm_after_team_capture_test.dart`
  (search-open now opens the same sheet directly), compared back-to-back
  GREEN. RTL mirror, 320/1.3x clean.
- STOPs: scroll-reveal needs the page scroll anchors (page-owned
  presentation state) and rows stay view-only by design — the shell
  `onSelect` only re-selects the tab (existing route, no-op when already
  there); manual scroll is unchanged (taps still ≤ 2). Replicating the
  anchors in the shell would be logic; filed, not changed.
- R1 stale-gate fix (ui/fix-rulings, presentation wiring only): the shell
  gate now reads the SAME list object the page renders —
  `ref.watch(crmUiProvider.notifier).salesTeam.length` (was
  `ref.watch(crmRepositoryProvider).salesTeam.length`); page reads
  `ref.read(crmUiProvider.notifier).salesTeam` (`crm_sales_team_page.dart:56-57`).
  Same `> 5` predicate, same sheet, same routes — no logic/data change.
  Relocation pins still hold (≤5 → 0 icons, >5 → 1 icon + same sheet);
  counts never down (4 -> 7 -> 10 -> 10 + 8 shell).

Ruling (a) ARB delta: **zero new keys on all three surfaces** (shell +
lists reuse `leadsSearchTitle/tasksSearchTitle/tmSearchTitle`,
`chromeSearchHint/chromeShortcut`, `leadsFilterClear`; EN/AR parity
untouched, no `gen-l10n` run needed).
