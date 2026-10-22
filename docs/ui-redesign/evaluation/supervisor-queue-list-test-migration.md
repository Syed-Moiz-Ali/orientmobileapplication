# Supervisor Queue list test migration (GROUP-C list-ops, screen 2)

Branch: `ui/list-ops`. Queue tab recomposed presentation-only onto App*
pattern widgets: providers, sort, priority buckets, refresh/sync logic,
picker-sheet + toast contracts, copy semantics, scaffold bar guard
(`selectedIndex != 0`), compact 4+More + expanded 7-rail untouched; no new
routes, no new ARB keys.

## Inventory (characterization baseline, STEP 0)

- `apps/staff_app/test/supervisor_queue_list_characterization_test.dart` (new,
  10 testWidgets): behavior pins written for the CURRENT Queue UI with a fake
  `SupervisorRemoteDataSource` (`_FakeSupervisorRemote` returning growable
  copies — production parses growable lists and the notifier mutates them in
  place on assign; const fixtures would throw where production never does;
  Hive misses are caught+logged by the provider, no box needed). Run GREEN
  before the rebuild (8/8 + 2 added for the insurance bucket and the
  no-advisor guard, then 10/10) and GREEN after (10/10). Frozen after STEP 0 —
  same 10 tests, same assertion shapes, counts 10 -> 10.
- State-copy finders use `textContaining` for empty/no-match/error strings:
  the recomposed `AppEmptyState`/`AppErrorState` bidi-isolate title+message
  (U+2066…U+2069, invisible), so containment is green on the current
  `EmptyState`/`AppInfoPanel` UI and on the new atoms. Row/header/pill/action
  copy stays `text` (plain `Text` pre and post; `AppStatusChip` exposes real
  `Text` under `ExcludeSemantics`, still `find.text`-visible).
- Pinned provider-owned quirk (logic, untouched): first load never writes
  `queueError`/`isQueueLoading` (only `refreshQueue` does), so a cold failure
  surfaces the EMPTY state; the error/skeleton paths are refresh-driven and
  pinned via the header refresh action. The rebuild preserves this exactly.
- Before pixels (frozen record, never regenerated):
  `docs/ui-redesign/baseline/before-supervisor-queue/` — `idle` (en/ar
  360x800, en 320x568, en 1.3x 360x800, en 768x1024), `empty`, `error`
  (refresh-driven), `loading` (refresh-driven, skeleton). Produced by
  `apps/staff_app/test/supervisor_queue_list_before_capture_test.dart` (tagged
  `baseline`, excluded from the default run).
- After pixels (review only, same matrix):
  `docs/ui-redesign/baseline/after-supervisor-queue/` via
  `apps/staff_app/test/supervisor_queue_list_after_capture_test.dart`.

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| header shows title, subtitle and refresh | Static subtitle + refresh `IconButton` | verbatim (subtitle stays static per brief deviation A; refresh kept) | behavioral (unchanged) |
| sections render with counts, priority pills and vip-first order | `StatusPill.*` priority pills + bespoke count badges | `AppStatusChip` (danger→error, warning→warning, info→info, neutral→neutral; normal renders no pill) + kept badge layout; VIP pill + rail chip = `findsNWidgets(2)` pre and post | structural (rendering-identical) |
| priority filter narrows bookings only, breakdowns stay | `AppFilterBar` + `bookingPriority` predicate | verbatim | behavioral (unchanged) |
| insurance filter shows only insurance bookings | same rail, third bucket | verbatim | behavioral (unchanged) |
| assign opens the advisor picker and confirms with a toast | `SecondaryButton` row Assign → `showAppModalSheet` picker (`PrimaryButton` confirm) → `assignBreakdown` → toast | `AppPillButton.secondary` → same sheet (`AppPillButton.primary` confirm) → same notifier → same toast; same finders, still green | structural (rendering-identical) |
| assign with no advisors shows the guard toast, no sheet | `showSupervisorToast(svQueueNoAdvisors)`, no sheet | verbatim | behavioral (unchanged) |
| no match offers a clear action that resets the filter | Legacy `EmptyState.noMatch` | `AppEmptyState` (title `commonNoResults`, message `svQueueNoMatch` verbatim, Clear → same reset) | structural (rendering-identical) |
| empty queue shows the clear state with no action | Legacy `EmptyState` (no action) | `AppEmptyState` (no action — honest empty, U6/U8) | structural (rendering-identical) |
| queue refresh failure shows the error with retry | `AppInfoPanel.danger` + Retry | `AppErrorState` (title `commonErrorTitle`, message `svQueueError` verbatim, retry `commonRetry` → same refresh) | structural (rendering-identical) |
| queue refresh loading shows no rows and no error | `AppSkeleton.listRows(6)` | `AppShimmerSkeleton.listRows(6)` | structural |

## Behavior assertions (verbatim, unchanged)

- Tap counts (brief BEFORE, verified from code): open list = tab (**1 tap**);
  route item = row Assign + picker select + sheet Assign (**3 taps** from list,
  ≤ same scroll); filter = chip (**1 tap**); clear = Clear (**1 tap**);
  retry = Retry (**1 tap**) / pull. AFTER: identical (same seats, same sheet,
  ≤ same scroll).
- Provider reads identical: `supervisorDashboardProvider` (+ notifier
  `bookings`/`breakdowns`/`advisors`, `refreshQueue`, `assignBooking`,
  `assignBreakdown`) untouched.
- Priority derivation identical: `bookingPriority` (vip → promisedToday →
  insurance → normal; normal renders NO pill) + `queuePriorityRank` stable sort
  untouched; filter narrows BOOKINGS ONLY (breakdowns always listed); counts
  from loaded lists only.
- Assign flow identical: pre-selected first advisor, empty-advisor guard toast,
  sheet confirm → notifier → success/failure toast; row buttons full-width
  before and after.
- No-search-icon deviation honored (brief deviation B): the surface's single
  search path stays the scaffold bar bay-search; no list-scoped search added.
  Header count stays on section labels (deviation A). Scaffold nav untouched.
- Copy keys: zero new (reused `svQueue*`, `commonNoResults`, `commonErrorTitle`,
  `filterBarClear`, `commonRetry`). Phase-9 list: none.

## WIDGET_MIGRATION_MAP delta (this screen)

- `SecondaryButton(` (row Assign, N sites) → `AppPillButton.secondary`
  (full-width, same label/icon/handler). No remaining `SecondaryButton` in
  `supervisor_queue_tab.dart`.
- `PrimaryButton(` (picker confirm, 1 site) → `AppPillButton.primary`
  (same label/icon/handler). No remaining `PrimaryButton` in the file.
- `StatusPill.danger/warning/info/neutral` (4 sites) → `AppStatusChip`
  (error/warning/info/neutral, same labels). No remaining `StatusPill` in
  the file.
- `EmptyState(` + `EmptyState.noMatch(` (2 sites) → `AppEmptyState` (1:1 copy;
  no-match title reuses shared `commonNoResults`, zero new keys).
- `AppSkeleton.listRows(` (1 site) → `AppShimmerSkeleton.listRows(rows: 6)`.
- `AppInfoPanel.danger(` (1 site) → `AppErrorState` (title/message/retry 1:1).
- `Divider(` (N sites) → `AppDivider()`.
- KEPT (pinned/not legacy): `AppPageHeader`, `AppFilterBar`,
  `showAppModalSheet` picker infra, `showSupervisorToast`, header refresh
  `IconButton`, `_SectionLabel` badge layout (accent-filled `AppBadge` would
  add a second filled accent per section — C16; kept token-only layout),
  `_EmptyLine`, scaffold bar + nav (untouched files).
