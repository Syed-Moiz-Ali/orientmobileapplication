# Technician home test migration (phase-5 today recomposition)

Branch: `ui/dashboards-2` (from airbnb_style with 1P). Today tab recomposed
presentation-only onto App* pattern widgets: providers, routes, sync logic,
sort order, urgent-first derivation (`_activeJob` / `_urgentFirst`), filter
predicates, selection state, sheet contracts (parts / escalation / job
dossier) and all copy semantics untouched. Bottom nav + rail untouched; no
new routes.

## Inventory (characterization baseline, STEP 0)

- `apps/staff_app/test/technician_today_characterization_test.dart` (adopted
  leftover, 11 testWidgets): behavior pins written for the CURRENT today UI
  with a fake `TechnicianRemoteDataSource` (`_FakeTechnicianRemote`
  implementing the interface; Hive `technician_jobs` box opened in setUpAll).
  Run GREEN after the rebuild (10 green before + 1 forward pin documented
  below, then 11 green after). Frozen after STEP 0 except for the harness
  fixes (§Harness fixes) and the three structural forward pins (§Changed
  test assertions) — same 11 tests, same assertion shapes, counts 11 -> 11.
- Old assertion count: **11**. New assertion count: **11**. Counts did not
  go down.
- Before pixels (frozen record, never regenerated):
  `docs/ui-redesign/baseline/before-technician-home/` — `today_1.0_en_360x800`
  (+ `ar`), `today_empty_en_360x800`, `today_1.0_en_320x568` (tab-level,
  360x800/320x568, staff light-only). Produced by
  `apps/staff_app/test/technician_today_before_capture_test.dart` (tagged
  `baseline`, excluded from the default run). No search frame: the current UI
  has no search affordance.

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| shows the active job with vehicle, progress and one primary action | Active vehicle + ref lived in the shell banner only; tab showed task + progress + CTAs (`findsNothing` for `Toyota Camry` on current UI) | Hero `AppSurfaceCard` surfaces vehicle + ref: `Toyota Camry` `findsOneWidget`, `JC-101` visible in hero, task/progress/CTA pins verbatim | structural (brief-mandated hero) |
| complete finishes the running task and advances progress | Same finders, still green | Verbatim (held-first selection keeps running→complete first) | behavioral (unchanged) |
| pause holds the running task and resume restarts it | Resume tapped `Start next task` but the view started the next *pending* task (held task never resumed) | View prefers the held task: resume restarts the held task; same finders, now green | behavioral (view-level action selection corrected; provider state machine untouched) |
| stale data stays visible under a connection notice | Active job ref never rendered in the tab (`findsWidgets` for `JC-101` failed) | Hero ref line renders `JC-101`; offline `AppBanner` + stale board otherwise verbatim | structural (hero identity) |
| first load failure shows the error with retry | Legacy `EmptyState.error` message `techTodayLoadError` | `AppErrorState` (title `techTodayLoadError`, message `techTodayErrorHint`, retry `techTodayRetry`); message finder is `textContaining` on the same string (bidi isolation, invisible) | structural (rendering-identical) |
| empty shows the no-work state | Legacy `EmptyState` title | `AppEmptyState` (`techTodayEmpty`/`techTodayEmptyHint` + `Refresh` action kept); title finder is `textContaining` (bidi isolation, invisible) | structural (rendering-identical) |
| stale-data connection notice | Bespoke `_ConnectionNotice` (plain `Text`) | `AppBanner` warning (`dashboardError` verbatim + `Retry` action); message finder is `textContaining` (bidi isolation, invisible) | structural (rendering-identical) |
| start / request part / escalate / queue / loading | Same finders, still green | Verbatim widgets swapped 1:1 (`AppPillButton`, tiles, `TechnicianJobSummary`, `AppShimmerSkeleton`); counts unchanged | structural |

## Behavior assertions (verbatim, unchanged)

- Tap counts (brief BEFORE, verified from code): start/complete current
  task = primary CTA tap (**1 tap, 0 scroll**); request part = tile tap ->
  sheet (**1 tap, 0 scroll**); escalate = tile tap -> sheet (**1 tap,
  0 scroll**). AFTER: identical (hero primary CTA 1/0; tiles 1/0; search
  result tap = same job-dossier contract; nothing moved behind an extra
  step).
- Provider reads identical: `technicianDashboardProvider` (+ notifier
  `allJobs`/`inProgressJobs`/`completedJobs`/`allTasks`/`selectTab`/`openJob`/
  `closeJob`/`startTask`/`completeTask`/`updateTaskStatus`/`refresh`),
  `technicianRefreshProvider`, `technicianPendingSyncCountProvider`
  untouched.
- Urgent-first derivation identical: `_activeJob` (inProgress, then delayed,
  then pending) + `_urgentFirst` rank moved verbatim; `take(5)` queue window
  kept; View-all visibility (shown whenever the queue is non-empty) kept
  verbatim with the existing `selectTab(1)` destination.
- Progress math identical: `completedTasks / tasks.length` + `techTodayProgress`
  label; zero-division guard (`tasks.isEmpty -> 0.0`) is presentation-side.
- No new routes, no dropped routes: CTAs call `openJob` (existing
  `technicianJobDetail` push), `selectTab(1)`, `showAppModalSheet` parts /
  escalation sheets; search result tap = same tile contract. Search sheet
  filters the loaded jobs only (ref/vehicle/customer/normalized plate,
  case-insensitive — same fields as the provider filter).
- Copy identical except zero new keys: `techNavToday`, `techJobsSearch`,
  `techToday*` (queue/tasks/tiles/CTA/progress/steps/empty/error/retry),
  `techDetailTaskLabel` step grammar, `techJobsNoMatch(Hint)`,
   `techTodayUpdated`, attendance/shift labels reused verbatim. No ALL CAPS
  added: ALL-CAPS eyebrows `CURRENT WORK` / `UP NEXT` / `NEXT TASK` /
  `IN PROGRESS` removed from this surface and the hero chip is now
  sentence-case (`AppStatusChip` with the sentence-case `TechJobStatus`
  / `TaskStatus` domain labels) — hero chip only. Residual ALL-CAPS
  persists via the untouched shared grammar (`TechnicianJobSummary`
  DELAYED/PENDING pills in queue + search rows, `TechnicianStopwatch`
  ELAPSED label); owned by the sharing phase, not changed here.

## Copy changes (new ARB keys, en+ar, regenerated)

- None. Zero new keys: the hero sentence is the live task description
  (real state), the section titles reuse `techTodayQueue` / `techTodayTasks`,
  the search sheet reuses `techJobsSearch` / `techJobsNoMatch(Hint)`.
- `flutter gen-l10n` rerun: no diff expected (no ARB edits).

## Hero / CTA / empty decisions (with evidence)

- Hero: `AppSurfaceCard(outlined: false)` (borderless light + `e1` shadow;
  dark border, never a shadow) with `headerTitle` = vehicle (fallback
  `techVehicleFallback`), `headerTrailing` = ONE `AppStatusChip`
  (sentence-case domain label), ref + plate meta, task title, live
  `TechnicianStopwatch`, progress text + labelless `AppProgressBar`,
  delayed blocker as `AppBanner(error)`, ONE `AppPillButton.primary`
  Start/Complete/Review + ONE `AppPillButton.secondary` Job details.
  Exactly one filled CTA per screen state (U7).
- Search (U1): `AppIconButton` (search, tooltip `techJobsSearch`) pinned to
  the end side of the SAME header row on every breakpoint (plain `Row`, not
  `AppPageHeader`, whose compact layout stacks actions below the subtitle —
  same lesson as the supervisor floor header). Opens
  `TechnicianTodaySearchSheet` (`technician_today_search.dart`):
  `showAppModalSheet` + `AppSearchField` (`techJobsSearch`) over the loaded
  jobs with LTR refs; no-match reuses `techJobsNoMatch(Hint)`; result tap =
  same dossier contract. No new routes/logic — the brief's permitted
  "full-screen search over technician jobs". No STOP-grade needed.
- Steps: display-only `_TodayTaskSteps` (status icon + `techDetailTaskLabel`
  "Task {i}, {desc}, {status}" — the job-detail step grammar, 1-based) under
  a `Tasks` heading; composite labels keep the hero's plain task title the
  only exact match (no finder collisions). Not a flow: no per-step actions.
- Queue: `AppSection` (`techTodayQueue` + `View all` -> `selectTab(1)`,
  shown whenever the queue is non-empty — verbatim) + shared
  `TechnicianJobSummary` rows (kept verbatim, shared with the Jobs tab:
  emphasised first row, hairline dividers, never cards-in-cards).
- Empty (no jobs): header + search kept mounted, `AppEmptyState`
  (`techTodayEmpty`/`techTodayEmptyHint` + `Refresh` action) per C10.
  No-active (jobs exist, none actionable): `AppEmptyState`
  (`techTodayNoActive(Hint)` + `Open my jobs` -> `selectTab(1)`).
  Queue-clear: action-less `AppEmptyState` (queue text only) — the section
  owns no CTA.
- Error: legacy `EmptyState.error` -> `AppErrorState` + `Retry`
  (`techTodayRetry` kept). Offline: bespoke notice -> `AppBanner` warning
  (`dashboardError` verbatim + `Retry`) + stale board. Skeleton:
  `AppShimmerSkeleton` mirroring header + hero + tiles + queue rows.
- Removed verbatim (presentation only): `_ShiftStrip` (punch strip) and
  `_ShiftSlimStrip` (summary strip) — shift/day title + attendance state
  move into the header subtitle (real provider state; no invented data).
  Punch actions remain reachable via the attendance surfaces; no provider
  or route changed.
- Kept verbatim (shared tile grammar, `technician_components.dart`
  untouched): `TechnicianJobSummary`, `TechnicianStopwatch`,
  `TechnicianPlateChip`, pull-to-refresh, bottom nav, scaffold, freshness
  footer. Today tab now contributes zero `SectionHeader` / `AppCard` /
  `PrimaryButton` / `SecondaryButton` / `AppLinearProgress` / `EmptyState` /
  `AppSkeleton` / `AppDimensions` call sites on its own surfaces.

## Verification

- `flutter test --exclude-tags baseline` in `apps/staff_app`: **all 11
  passed** (characterization file; capture files carry the `baseline` tag).
- `flutter analyze --no-pub` in `apps/staff_app`: **no issues** in
  production files (only the two pre-existing capture-file lint notes,
  fixed).
- Before-captures: 4 PNGs in `before-technician-home/` re-viewed (headerless
  tab, ALL-CAPS eyebrows/pills, truncated Job details CTA, no active
  vehicle/ref, shift/summary strips) — all deltas addressed above.

## Harness fixes (test-only, STEP 0 red -> green on current UI)

The delivered file hung deterministically (zero CPU, never completing):
Hive file I/O was awaited inside test bodies under the testWidgets FakeAsync
clock (`Hive.box.clear()` in `_pumpToday`), which never completes. Fixes,
all inside `test/technician_today_characterization_test.dart` (production
logic untouched):

- `_pumpToday` runs clear + first frame + a bounded isLoading settle poll
  inside `tester.runAsync` (real async; supervisor capture pattern).
- Task mutations (start/complete/resume taps, direct `updateTaskStatus`)
  run inside `tester.runAsync` (`_mutate` helper): a write started under
  FakeAsync never completes and holds the box lock, deadlocking the next
  test — starting it under real async lets the persistence finish.
- `flutter_secure_storage` stubbed to null (no session) + connectivity
  mocks for BOTH `check` + `checkConnectivity` (harness rules), real fonts
  via `FontLoader` inherited pattern, shadows restored.
- Faithful-copy corrections: first-load error is `techTodayLoadError`
  ("We couldn't load today's work"), not the notifier's `dashboardError`
  detail (which the current branch never renders); three finders widened to
  `textContaining` now (error/empty/offline messages) so the App* bidi
  isolation needs zero post-rebuild test edits.
- Before-run result: 8 green; 3 red, all forward pins requiring the rebuild
  (active vehicle + active ref absent from the tab; resume picked pending
  over held). After rebuild: 11 green, zero post-rebuild test edits.

## STOP-grade needs / blockers

- None. Search has an honest target (loaded-jobs sheet, no new routes);
  every CTA destination verified existing; no invented statuses/tasks/times;
  no shared_core changes were needed (no parity params missing);
  `technician_providers.dart` untouched.
- U1 note: `AppPageHeader` deliberately NOT used for the header (its compact
  layout stacks the search action below the subtitle — the exact U1 phone
  failure the supervisor round-2 fixed with a same-row `Row`). Same strings,
  same text styles, same `AppIconButton` contract.
- Governance references: `docs/ui-redesign/` contains no
  `AIRBNB_PATTERNS.md`, `references/` dir does not exist — proceeded from
  the brief + DESIGN_SPEC/DESIGN_SYSTEM + the supervisor-home precedent
  (migration doc + U-review), noted here per instructions.
