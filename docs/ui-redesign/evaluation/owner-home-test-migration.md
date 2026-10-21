# Owner home test migration (phase-7 owner-home recomposition)

Branch: `ui/dashboards-2`. Owner home (`OwnerDashboardPage` + shell palette
source) recomposed presentation-only onto App* pattern widgets: providers,
routes, sync/refresh/period logic, `_findKpi` / `_trendOf` derivation,
filter predicates, selection state, bottom nav + rail, pull-to-refresh,
haptics and copy semantics untouched. No new routes. Approvals stay a
read-only triage (no approve/reject endpoint exists).

## Inventory (characterization baseline, STEP 0)

- `apps/owner_app/test/owner_dashboard_characterization_test.dart` (new,
  10 testWidgets, 36 expects): behavior pins for the CURRENT home with a
  fake `OwnerRemoteDataSource` (`_FakeOwnerRemote` implementing the
  interface; Hive `owner_messages` box opened in setUpAll). Run GREEN after
  the rebuild (10 green before, 10 green after — same tests, same counts).
- Old assertion count: **36 expects / 10 tests**. New assertion count:
  **36 expects / 10 tests**. Counts did not go down.
- Before pixels (frozen record, never regenerated):
  `docs/ui-redesign/baseline/before-owner-home/` — `home_1.0_en_360x800`
  (+ `ar`), `home_empty_en_360x800`, `home_search_open_en_360x800`,
  `home_1.3_en_360x800`, `home_1.0_en_320x568`, `home_1.0_en_768x1024`,
  `home_1.0_en_1280x800` (owner light-only). Produced by
  `apps/owner_app/test/owner_home_before_capture_test.dart` (tagged
  `baseline`, excluded from the default run). Before frames document two
  genuine current-UI overflows: the app-bar row overflows 17px right at
  1.3x and 29px right at 320x568 (striped, tolerated by the capture
  harness — the redesign's evidence, not a harness bug).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| all twelve quick-action destinations survive | All 12 tiles tapped directly (single-column record rows) | Top-4 tiles tapped directly; Show-all preview (`Job status · Compliance · Reviews`) expands inline, then the remaining 8 tapped; tab destinations unchanged (`selectTab(1/2)`) | structural (brief-mandated top-tiles + Show-all; same 12 routes/tabs) |
| palette search path reaches approvals in two taps | Bare `find.byIcon(search)` (shell was the only trigger) | Finder scoped to `WorkspaceAppBar` (the home header adds a second search action opening the same palette) | structural (U1 second entry point, same palette/routes) |
| empty shows honest empty states | Exact `find.text` for `No figures yet.` / `No register rows.` | `find.textContaining` for those two (AppEmptyState bidi-isolates, invisible) | structural (rendering-identical) |
| glance / drill / view-all / tile-triage / verbatim / error / loading | Same finders, still green | Verbatim | behavioral (unchanged) |

## Behavior assertions (verbatim, unchanged)

- Tap counts (brief BEFORE, verified from code): glance hero + pods =
  **0 taps** (hero + first pods above the fold at launch); register row (or
  section View-all) -> `AppRoutes.jobCards` = **1 tap**; approvals tile ->
  `AppRoutes.pendingApprovals` = **1 tap + scroll**; shell search icon ->
  palette destination = **2 taps**. AFTER: identical (hero + first pods
  above the fold; row tap 1; tile 1 + scroll; header search icon -> same
  palette destination 2; Show-all expand + destination 2).
- Provider reads identical: `dashboardUiProvider` (+ notifier `kpis` /
  `registerItems` / `salesTrend` / `profitTrend` / `expensesTrend` /
  `selectTab` / `refresh`) untouched; shell providers untouched.
- Figures derivation identical: `_findKpi` (revenue/sales/turnover,
  margin, occupancy/occupan/bay, approval, open/active, new/today) and
  `_trendOf` moved verbatim; all figures render verbatim with the same
  LTR locks (`AED 84K`-style values); zero renders as `0`; missing
  families omitted, never zero-filled.
- No new routes, no dropped routes: 10 pushes + 2 `selectTab` targets
  unchanged; palette ids/labels/hints/icons/ordering unchanged (moved to
  `owner_search.dart`, shared by shell + header); Show-all rows push the
  same `jobCards` route; view-all trailing kept (`ownerRegisterAll`).
- No Approve/Reject buttons anywhere (pinned `findsNothing`); the
  approvals drill lands on the read-only triage; the new blocker banner is
  warning-kind with a View drill, no decision affordance.
- Pills: `Live operations` (accent) + active/today (info/success) rebuilt
  on `AppStatusChip` with verbatim labels. BEFORE-QUIRK fixed
  presentation-side: the old `const _CockpitHeader` read KPIs via
  `ref.read` and froze on the first (empty) content frame, so active/today
  pills never populated; the header now takes `kpis` as parameters.
  Providers/state/logic untouched — same derivation, same strings.
- Copy identical except two new keys (below). No ALL CAPS added: pod
  overlines stay uppercase exactly as the legacy pods rendered them
  (`REVENUE`, `MARGIN` — both UIs uppercase non-Arabic labels); no new
  uppercase styling.

## Copy changes (new ARB keys, en+ar, regenerated)

- `ownerHomeApprovalsBanner` (`{value} waiting for owner review` / `{value}
  بانتظار مراجعة المالك`) — blocker banner, value verbatim (String
  placeholder, no parsing for display).
- `ownerRegisterEmptyHint` (`New jobs will appear here when they are booked.`
  / `ستظهر المهام الجديدة هنا عند حجزها.`) — round-1 fix: the compact
  register empty used the hero hint (`ownerHeroEmptyHint`); it now uses the
  register-empty family. Title (`ownerRegisterEmpty`) unchanged.
- `ownerHomeLoadError` (`Could not load the latest figures` / `تعذّر
  تحميل أحدث الأرقام`) — `AppErrorState` title; the server message stays
  the body, retry is shared `commonRetry`.
- `flutter gen-l10n` run from `apps/owner_app` (l10n.yaml); `git diff
  --stat` shows only the two ARB files + three gen files. Byte-safe
  inserts (en +7, ar +2); ar file carries no `@` metadata by convention.

## Harness fixes (test-only, app code untouched)

- Connectivity mock returns `<String>['wifi']` on both `check` and
  `checkConnectivity`: the plugin casts the reply to List — a bare String
  crashes `OfflineStatusPill`.
- `connectivity_status` EventChannel stream mock added (baseline shape);
  required for shell pumps under `runAsync`.
- Pod overline casing pinned as-rendered (`REVENUE`, `MARGIN`), not as
  authored — both UIs uppercase non-Arabic labels.
- Compact 390x844 default surface (register compactBuilder path holds the
  `Open: 0` metadata line); tall 420x1600 surface for the legacy skeleton
  still; shadows restored via `addTearDown`; `debugShowCheckedModeBanner:
  false`; ar locale + delegates + `AppTheme`.
- Before-capture tolerates ONLY RenderFlex-overflow `FlutterError`s (the
  documented 17px/29px app-bar overflows); anything else rethrows.

## STOPs honored

- STOP-1 (no approve/reject endpoint): queue stays read-only triage; no
  buttons added; banner drills to triage.
- STOP-2 (figures derivation): `_findKpi` / `_trendOf` byte-verbatim;
  LTR locks kept; banner visibility uses `int.tryParse` for show/hide
  ONLY (unparseable stays visible), never a figure change.
- STOP-3 (12 destinations): all survive with identical routes/tabs
  (10 pushes + `selectTab(1/2)`); top-4 order preserved.
- STOP-4 (existing palette): header search opens the same palette via
  the shared helper; no new search route.
- STOP-5 (build-time): overdue-AR blocker NOT built — AR summary is not
  part of the dashboard payload and fetching it from home would be new
  logic; only the approvals-WIP banner shipped (from existing KPIs).
- STOP-6 (build-time): chart timeframe pills NOT built — period state
  does not drive trend data, so pills would be fake actions.
- STOP-7 (build-time): no `AppChartCard` exists in shared_core — charts
  stay composed from the existing shared atoms (`AppCard.standard` +
  `SectionHeader` + `SparklineChart` + first/last month rule); the change
  is structural (swipeable `PageView` on compact removed; curves stack).
