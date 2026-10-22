# Supervisor home test migration (phase-5 floor-board recomposition)

Branch: `ui/dashboards-2` (from airbnb_style with 1P). Floor tab recomposed
presentation-only onto App* pattern widgets: providers, routes, sync logic,
sort order, bay derivation (`buildSupervisorBays`), filter predicate,
selection state, assign-sheet contract and all copy semantics untouched.
Bottom nav untouched; no new routes.

## Inventory (characterization baseline, STEP 0)

- `apps/staff_app/test/supervisor_dashboard_view_test.dart` (new, 8
  testWidgets): behavior pins written against the CURRENT floor UI with a
  fake `SupervisorRemoteDataSource` (`_FakeSupervisorRemote` implementing the
  interface; no backend/Hive touched — Hive "Box not found" logs are caught
  inside the notifier and never fail a test). Run green BEFORE the rebuild,
  re-run green AFTER. Frozen after STEP 0 except for the three documented
  rendering-identical finder adaptations below (same 8 tests, same
  assertions, counts 8 -> 8).
- Old assertion count: **8**. New assertion count: **8**. Counts did not go
  down.
- Before pixels (frozen record, never regenerated):
  `docs/ui-redesign/baseline/before-supervisor-home/floor_1.0_en_360x800.png`
  and `floor_1.0_ar_360x800.png` (tab-level, 360x800, staff light-only).
  Produced by `apps/staff_app/test/supervisor_dashboard_capture_test.dart`
  (tagged `baseline`, excluded from the default run).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| board renders 16 bays with mixed states and occupancy | `SectionHeader` masthead + bespoke tiles; single `svFloorSubtitle` text | Same finders, still green: `AppPageHeader` subtitle carries the identical `svFloorSubtitle` sentence; tiles keep bay codes + refs | structural |
| bay-state filter keeps the same predicate | `AppFilterBar` chips + `_filteredBays` predicate | Verbatim same widget + verbatim same predicate (moved, not rewritten) | behavioral (unchanged) |
| filter with no matches offers a clear action | `EmptyState.noMatch` (plain `Text`) message + card `Clear` tap | `AppEmptyState` title/message (bidi-isolated, invisible) -> finder is `textContaining` on the same string; tap targets the filter bar's `Clear` (scoped `descendant(of: AppFilterBar)`) — the no-match card sits below the fold in the taller new layout | structural (rendering-identical) |
| bay tap opens the assign entry and selects the bay | tile tap -> `onOpenAssign` x1, selected card `Dispatch` x1 | Identical: tile grammar kept, selected card kept (`AppSurfaceCard` + secondary Dispatch action); hero adds a second same-label CTA so the test taps `.first` | behavioral (unchanged) |
| rail actions reach queue and review destinations | rail row tap -> `onOpenQueue`; `Review` button -> `onOpenReview` | Identical callbacks; rows keep verbatim title/subtitle mapping; buttons keep verbatim labels on `AppPillButton.secondary` | behavioral (unchanged) |
| loading shows no bays and no error | bespoke `_FloorSkeleton` (`AppSkeleton`) | Layout-mirroring `AppShimmerSkeleton` (header + hero + grid + rail); same finders (no bay codes, no error) | structural |
| load failure shows the error with a retry action | `AppInfoPanel.danger` (plain `Text`) + `commonRetry` | `AppErrorState` (title `svFloorErrorTitle`, message `svFloorError`, retry label still `commonRetry`) -> message finder is `textContaining` on the same string (bidi isolation, invisible) | structural (rendering-identical) |
| empty floor shows the clear queue and no error | 16 idle tiles + rail queue-empty text | `AppEmptyState` (`svFloorEmpty`/`svFloorEmptyMessage` + Dispatch action) in the board slot; rail kept beside/below it so the queue-empty text and occupancy sentence still pin | structural |

## Behavior assertions (verbatim, unchanged)

- Tap counts (brief BEFORE, verified from code): dispatch = bay tap ->
  assign sheet (1 tap, 0 scroll); queue = rail row/button (1 tap);
  review = rail button (1 tap). AFTER: identical (hero Dispatch also 1 tap;
  nothing moved behind an extra step).
- Provider reads identical: `supervisorDashboardProvider` (+ notifier
  `awaitingCompletions`/`jobs`/`bookings`/`breakdowns`), `refreshDashboard`
  retry, `connectivityStatusProvider` for the offline banner.
- Bay derivation identical: `buildSupervisorBays` untouched (QC awaiting
  first, then parts-held jobs, then occupied jobs, then bookings; 16 bays;
  tech initials only when known; nothing invented).
- Filter predicate identical: `SupervisorBayState` mapping in
  `_filteredBays` moved verbatim; `AppFilterBar` kept.
- Selection identical: `_selected` + `onOpenAssign` on every tile/search
  result tap; selected-bay card keeps title/code/subtitle + dispatch.
- No new routes, no dropped routes: CTAs call `onOpenAssign` (existing
  `showSupervisorAssignSheet`), `onOpenQueue`/`onOpenReview` (existing
  IndexedStack tabs 2/3; router also exposes `/supervisor/assign`,
  `/supervisor/queue`, `/supervisor/review` — verified in
  `apps/staff_app/lib/core/router/app_router.dart`, all pre-existing).
- Copy identical except the two new keys below; `svFloorSubtitle`,
  `svBaysOccupied` (header subtitle), `svBay*`, `svQueueTitle`,
  `svNavReview`, `svAssignTitle`, `svFloorTapHint`, `svFloorNoMatch`,
  `svFloorError(Title)`, `svFloorEmpty(Message)`, `svFloorQueue(Title/Empty)`
  reused verbatim. No ALL CAPS added (`AppPageHeader` eyebrow unused).

## Copy changes (new ARB keys, en+ar, regenerated — no renames)

- `svFloorHeroSentence` ("Dispatch the next job into a free bay." /
  "وجّه مهمة العمل التالية إلى منصة متاحة.") — hero supporting sentence.
  Arabic drafted per C15, flagged needs-native-review (phase 9 owns polish).
- `svFloorNoMatchHint` ("Try a different filter, or clear it to see
  every bay." / "جرّب مرشحًا مختلفًا، أو امسحه لرؤية كل المنصات.") —
  no-match helper under the existing `svFloorNoMatch` title. Same flag.
- `flutter gen-l10n` rerun; gen diff is additive only
  (`staff_localizations*.dart` +2 getters each).

## Hero / CTA / empty decisions (with evidence)

- Hero: ONE `AppMediaCard` (grid icon, big active-bay count, hero sentence,
  neutral `Bays` unit chip) + ONE full-width `AppPillButton.primary`
  Dispatch (`svAssignTitle`, existing assign entry). The count is the bare
  number (no plural-key sprawl, `0` renders `0` never `-`); the unit rides in
  the status slot so `16 bays`-style duplication with the header occupancy
  sentence cannot occur. Evidence: C16 dashboard hero (one number + sentence
  + one CTA), brief flow § ("hero occupancy card + ONE Dispatch CTA").
- Search (U1): `AppIconButton` (search, tooltip `svSearchTitle`) in
  `AppPageHeader.actions` — top-right, same glyph/tooltip contract as the
  advisor greeting header (`advisor_home_view.dart` search `IconButton` +
  `AdvisorSearchSheet` via sheet). Opens `SupervisorFloorSearchSheet`
  (`supervisor_floor_search.dart`, new): `showAppModalSheet` +
  `AppSearchField` (`svSearchHint`) over the derived bays (code/ref/title,
  case-insensitive) with LTR codes; result tap = same tile contract
  (select + assign sheet). No new routes/logic — the brief's permitted
  "full-screen search over floor data". No STOP-grade needed.
- Empty floor: header + hero (`0` + sentence + Dispatch) + `AppEmptyState`
  (`svFloorEmpty`/`svFloorEmptyMessage`, action Dispatch) in the board slot;
  rail stays mounted (queue/review reachable, queue-empty text pins).
  Rationale: brief states list demands "empty floor (icon + sentence +
  action)" per C10; the 16-bay map returns with the first active bay
  (derivation unchanged). Evidence: DESIGN_SPEC C10 empty pattern.
- Rail: `AppCard.standard` -> `AppSurfaceCard` (header + count trailing +
  rows + secondary CTA footer-equivalent); breakdown/booking row mapping
  verbatim (`issue||vehicleName`/`location`, `serviceType`/`vehicleName`,
  take(2)/take(3)); review card keeps header + single secondary CTA.
  Selected-bay card keeps code/title/subtitle + dispatch (secondary to honor
  one-primary-per-screen; hero owns the primary).
- Error: `AppInfoPanel.danger` -> `AppErrorState` + `Try again` (`commonRetry`
  label kept). Offline: `AppBanner` warning (`offlineBannerMessage`, shared)
  + stale board (shell `showOfflineBanner: false` unchanged, no duplicate).
  Skeleton: `AppShimmerSkeleton` mirroring header + hero + grid + rail.
- Kept verbatim (not migrated, still used): `_BayTile` grammar (state dot +
  LTR `B-01` code + tech-initials slot + title/ref/meta + selection ring;
  shared tile grammar per `supervisor_components.dart`), `_BayLegend`,
  `_RailRow`, `_TechSlot`, pull-to-refresh, bottom nav, scaffold.
  Pre-existing micro-numbers kept as-is (`minHeight: 104`, `height: 2`,
  `fontSize: 10/10.5/11`, `BorderSide 1.6/1`) — not introduced here.

## Verification

- `flutter test --exclude-tags baseline` in `apps/staff_app`: **all 8
  passed** (only suite file in the package).
- `flutter analyze --no-pub` in `apps/staff_app`: **no issues**.
- Transient stress check (temp file, deleted after run): 320x568 en
  offline, 360x800 ar 1.3x offline (RTL, LTR bay codes intact), 768x1024
  tablet 2-col — zero `takeException`, `AppBanner` present offline.
- No `--update-goldens` on existing goldens (only the new before-capture
  file generated its own two PNGs, pre-rebuild).

## STOP-grade needs / blockers

- None. Search has an honest target (floor-data sheet, no new routes);
  every CTA destination verified existing; no invented
  statuses/bays/scores; no shared_core changes were needed (no parity
  params missing); `supervisor_providers.dart` untouched.

## Compact nav (ui/integration-1): 4 primaries + More (LOGIC_FOLLOWUPS #8)

Presentation-only; resolves entry 8 (orchestrator closes that file).
File touched: `supervisor_scaffold.dart` only — routes, providers, tab
content/targets, haptics, badge derivation, selection, assign-sheet
contract, copy/ARB all untouched; no new keys, no new routes, no tab
removed. The expanded rail keeps all 7 destinations; only the compact
bottom bar changes (legacy 7-slot `AppBottomNavigation` replaced by the
spec-C8 `AppBottomNav` + `AppBottomSheet` More overflow, tokens only).

- 4 PRIMARY tabs (the tabs the brief's top-3 tasks need, plus home):
  Floor (home; dispatch bay tap -> assign sheet), Jobs
  (dispatch-adjacent active-jobs list), Queue (check what's waiting),
  Review (QC sign-off). 5th slot = More (`commonMore`, shared key,
  en "More" / ar "المزيد") opening an `AppBottomSheet` (icon + label
  rows, 48dp+ targets, trailing check on the active destination, same
  tab targets/routes when tapped; More slot selected while an overflow
  tab is active).
- More contents: Reports, Staff, Schedule (indices 4/5/6, order kept).
- Badges: no tab carries badge/count state (the scaffold never wired
  `badgeIndices`/`badgeCounts`), so More carries no dot/count — existing
  state read only, nothing invented.

### Tap table (BEFORE = brief + §Behavior assertions; AFTER measured)

Primary tasks stay ≤ before (most-frequent dispatch = 1 tap ≤ 2, U3 held):

| Task | Before | After | Delta |
|---|---|---|---|
| Dispatch a job into a bay (bay tap -> assign sheet; hero Dispatch CTA) | 1 tap, 0 scroll | 1 tap, 0 scroll (Floor primary, unchanged) | ±0 |
| Check what's waiting (Queue tab; floor rail row/button) | 1 tap | 1 tap (Queue primary; rail unchanged) | ±0 |
| Review a finished job (Review tab; rail Review button) | 1 tap | 1 tap (Review primary; rail unchanged) | ±0 |
| Active jobs list (Jobs tab) | 1 tap | 1 tap (Jobs primary) | ±0 |
| Operations report | 1 tap (Reports tab) | 2 taps (More -> Reports) | **+1** |
| Workshop roster | 1 tap (Staff tab) | 2 taps (More -> Staff) | **+1** |
| Bay schedule | 1 tap (Schedule tab) | 2 taps (More -> Schedule) | **+1** |

Plainly: Reports, Staff and Schedule each cost exactly one extra tap
(the More sheet); dispatch, queue, review and jobs cost the same as
before. No frequent task takes more taps than before (U3: Reports/Staff/
Schedule are infrequent admin destinations, not top-3 tasks).

### Verification

- New pins: `apps/staff_app/test/supervisor_scaffold_nav_test.dart`
  (6 testWidgets, harness per gate: real FontLoader fonts,
  debugShowCheckedModeBanner:false, shadows restored, runAsync+delays,
  connectivity mocks BOTH check+checkConnectivity, ar locale+delegates+
  AppTheme): bar shows Floor/Jobs/Queue/Review + More with overflow tabs
  hidden; each primary switches in one tap; More sheet rows are 48dp+ and
  navigate to Reports/Staff/Schedule; ar RTL + 320px + 1.3x pump with
  `takeException()` null (0 overflow). Run green.
- Shell captures (`shell_fix_supervisor_capture_test.dart`, capture agent
  owns) run locally in compare mode: 320/1.3x/ar pump with 0 overflow;
  golden diffs vs the pre-nav goldens are expected and left for the
  capture-agent regen (no `--update-goldens`, nothing written to
  `after-shell-fix/`).
- STOPs: none. No logic change was needed (no badge state existed to
  surface; no hidden-tab count derivation exists).

## Fixer round-1 (U-review FAIL: U1 + U7 capped 8/16, plus borderless + hero nits)

Presentation-only, zero logic changes: routes/providers/domain/bay
derivation/filter predicate/selection/assign-sheet contract/copy/ARB all
untouched; no new keys. File touched:
`supervisor_dashboard_tab.dart` only.

- U1: replaced `AppPageHeader(actions:)` (its compact layout stacks actions
  below the subtitle) with a private `_FloorHeader` — title + subtitle
  (identical strings/styles) + `AppIconButton` search pinned to the end side
  of the SAME row on every breakpoint. Phones now mirror tablets (end side
  in RTL). No test finder referenced `AppPageHeader`, so no test change.
- U7 (ONE filled Dispatch per screen): hero keeps the single primary
  Dispatch. `_FloorEmpty` drops its `AppEmptyState` action (empty screen =
  hero Dispatch only). No-match keeps `AppEmptyState` action-less + a
  secondary `Clear` button (was a second filled CTA next to hero
  Dispatch). Selected-bay card was already `secondary` — unchanged. Bay tap
  / search-result tap still open the sheet (no filled button); the sheet
  keeps its own CTA. The `filter with no matches` test still taps the
  filter bar's `Clear` (scoped `descendant(of: AppFilterBar)`); the extra
  secondary `Clear` only adds a `findsWidgets` match, assertions unchanged.
- Borderless light tiles: `_BayTile` light-unselected uses `BorderSide.none`
  + `elevation: 2` soft shadow (dark keeps the tone border, never a
  shadow); selected keeps the functional primary ring on both themes.
- Hero nit: removed the `AppMediaCard` (dead grey media block + count +
  `Bays` chip card chrome); hero is now the plain dispatch sentence +
  primary CTA. The occupancy count already lives in the header subtitle,
  so no number is lost on-screen.
- Test deltas this round: **none** — all 8 behavior tests green unmodified
  (8 -> 8, no finder touched); this doc is the only doc change.
- Re-capture: all 17 `after-phase-5-supervisor` PNGs regenerated via the
  allowed `supervisor_dashboard_after_capture_test.dart --update-goldens`
  only; double-run SHA-256 identical (byte-stable); `before*/` untouched;
  no `--update-goldens` on anything else. All 17 re-viewed: search
  top-right/end-side same-row on 360/320/ar/tablet, exactly one filled
  Dispatch per screen state, zero bordered light tiles.

## Fixer round-2 (phase-5 current re-audit FAIL 8/16: C16 orphan + U5 cap)

Gating defects from `phase-5-supervisor-home-current-evaluation.md` §4:
medium 3-col board orphans B-16 (16 mod 3 = 1) and truncates B-02
mid-token (`Camry ABC 12…`, `_BayTile` title `maxLines: 1` ellipsis).

Presentation-only, zero logic changes: bay derivation/filter predicate/
selection/routes/providers/copy/ARB untouched; no new keys/routes; taps
unchanged (columns + `maxLines` never touch `onTap`). File touched:
`supervisor_dashboard_tab.dart` only.

- C16 exact tiling: `_FloorBoard` + `_FloorSkeleton` medium pick 3 -> 2
  (compact 2 / medium 2 / expanded 4 / large 4 — every breakpoint divides
  16 exactly: 8 / 8 / 4 / 4 rows, no orphan). Medium 2-col matches brief
  §States "tablet 2-col (board + rail side by side)"; expanded/large keep
  the brief's 4-col bend; compact 2 kept (already exact). Wider medium
  tiles also give the vehicle identity room to fit.
- U5 full-word labels: `_BayTile` title `maxLines: 1` -> `2` (same
  string, same `labelMedium` style) so the identity wraps at word
  boundaries instead of cutting mid-token. Ref/meta rows untouched
  (short LTR codes, still single-line).
- Test deltas this round: **none** — all 8 behavior tests green
  unmodified; no finder references columns or `maxLines`.
- Verify: `flutter test --exclude-tags baseline` (staff_app) all green;
  `flutter analyze --no-pub` (staff_app) no issues; current-capture matrix
  in compare mode 10/11 — only `sv_home_en_1.0_768x1024.png` diffs
  (10.32%, the intended 3-col -> 2-col reflow; B-02 now renders
  `Camry ABC 1234` in full, pairs B-01/B-02, B-03/B-04, no orphan, zero
  overflow tolerations). 360/ar/320/1.3x/1180/empty/loading/error/search/
  more all still match (fold intact at 360x800, no 320/1.3x/ar overflow).
  No `--update-goldens` — 768 regen belongs to the capture agent.
  `test/failures/` debris deleted.
