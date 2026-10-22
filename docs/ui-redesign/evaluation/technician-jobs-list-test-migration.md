# Technician jobs list test migration (GROUP-C list-ops, screen 4)

Branch: `ui/list-ops`. Technician Jobs view recomposed presentation-only onto
App* pattern widgets: providers, urgent-first order, predicates, refresh/sync
logic, routing/dossier contracts, sheet contract (untouched), copy semantics,
shell chrome (`_TechChrome` guard + tab targets) untouched; no new routes, no
new ARB keys.

## Inventory (characterization baseline, STEP 0)

- `apps/staff_app/test/technician_jobs_list_characterization_test.dart` (new,
  9 testWidgets): behavior pins written for the CURRENT Jobs view with a fake
  `TechnicianRemoteDataSource` (`_FakeTechnicianRemote` returning growable
  copies; Hive `technician_jobs` box opened in setUpAll + cleared under
  runAsync per the Today harness; a stub `GoRouter` serves the dossier route
  so the row-tap pin exercises the real `openJob` + `push` + `closeJob`
  contract). Run GREEN before the rebuild (7/7 + 2 fixes → 9/9) and GREEN
  after (9/9). Frozen after STEP 0 — same 9 tests, same assertion shapes,
  counts 9 -> 9.
- State-copy finders use `textContaining` for empty/no-match/error/stale
  strings: the recomposed `AppEmptyState`/`AppErrorState`/`AppBanner`
  bidi-isolate title/message (U+2066…U+2069, invisible), so containment is
  green on the current `EmptyState`/`_SavedDataNotice` UI and on the new
  atoms. Rail/row/footer copy stays `text` (plain `Text` pre and post).
- Blessed-contract pins: `find.byType(AppSearchField)` is `findsNothing` on
  this view (inline removed in ui/integration-1 — must never be re-added);
  `find.byType(AppFilterBar)` is the rail-only toolbar.
- Before pixels (frozen record, never regenerated):
  `docs/ui-redesign/baseline/before-technician-jobs/` — `idle` (en/ar
  360x800, en 320x568, en 1.3x 360x800, en 768x1024), `empty`, `error`,
  `loading`. Produced by
  `apps/staff_app/test/technician_jobs_list_before_capture_test.dart` (tagged
  `baseline`, excluded from the default run; fixed `fixedRefreshAt` instant so
  the freshness footer is deterministic).
- After pixels (review only, same matrix):
  `docs/ui-redesign/baseline/after-technician-jobs/` via
  `apps/staff_app/test/technician_jobs_list_after_capture_test.dart`.

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| toolbar is filter-rail only, no inline search field | `AppFilterBar` rail, zero `AppSearchField` | verbatim (STOP: rail untouched, no inline re-added) | behavioral (unchanged) |
| rows render urgent-first | `TechnicianJobSummary` rows + `Divider` separators | Same shared rows (STOP boundary: shared with Today + sheet) + `AppDivider()` separators; order pins identical | structural (rendering-identical) |
| status rail filters and re-tap restores the queue | `AppFilterBar` + `updateFilter` | verbatim | behavioral (unchanged) |
| row tap opens the job dossier destination | `openJob` + `push(technicianJobDetail)` + `closeJob` | verbatim (stub route) | behavioral (unchanged) |
| no match offers a clear action that resets the queue | Legacy `EmptyState.noMatch` | `AppEmptyState` (icon search_off, same title/message/Clear → `updateSearch('')` + `updateFilter('All')`) | structural (rendering-identical) |
| empty shows the no-work state with refresh | Legacy `EmptyState` | `AppEmptyState` (same icon/title/message/Refresh → same refresh) | structural (rendering-identical) |
| first load failure shows the error with retry | Legacy `EmptyState.error` | `AppErrorState` (title `commonErrorTitle`, message `techJobsLoadError` verbatim, retry `commonRetry` → same refresh) | structural (rendering-identical) |
| loading shows no jobs and no error | `AppSkeleton.listRows(4)` | `AppShimmerSkeleton.listRows(4)` | structural |
| stale data stays visible under a connection notice | Bespoke `_SavedDataNotice` Container | `AppBanner` warning (same `dashboardError` copy, live-region) | structural (rendering-identical) |

## Behavior assertions (verbatim, unchanged)

- Tap counts (brief BEFORE, verified from code): open list = tab (**1 tap**);
  find = header icon → sheet → result (**1 + keystrokes + 1**, 1 path) or chip
  (**1 tap**); open dossier = row tap (**1 tap, 0 scroll**); clear = Clear
  (**1 tap**); retry = Retry (**1 tap**) / pull. AFTER: identical.
- Provider reads identical: `technicianDashboardProvider` (+ notifier
  `allJobs`/`filteredJobs`, `updateSearch`/`updateFilter`, `openJob`/`closeJob`,
  `refresh`), `technicianRefreshProvider` untouched.
- Search predicate identical (5 fields + normalized plate + `All`/status
  gate) + `_urgentFirst` order (delayed 0 / inProgress 1 / pending 2 /
  qcReview 3 / completed 4) untouched; shell search icon + sheet + dossier
  route untouched.
- No-inline-search STOP honored (this file keeps zero `AppSearchField`);
  no in-body header added (shell owns the title — deviation A); no > 5 gate on
  the blessed shell icon (deviation B); no per-row buttons (deviation C —
  would duplicate dossier actions); shared rows untouched (deviation D).
- Freshness footer deterministic (`fixedRefreshAt`, `09:41` pinned).
- Copy keys: zero new (reused `techJobs*`, `techTodayRefresh/Updated`,
  `commonRetry`, `commonErrorTitle`). Phase-9 list: none.

## WIDGET_MIGRATION_MAP delta (this screen)

- `EmptyState.error(` (1 site) → `AppErrorState` (title `commonErrorTitle`,
  message `techJobsLoadError` verbatim, retry `commonRetry` → same refresh).
- `EmptyState(` (1 site) → `AppEmptyState` (same icon/title/message/action).
- `EmptyState.noMatch(` (1 site) → `AppEmptyState` (icon search_off, same
  title/message/Clear → same reset).
- `AppSkeleton.listRows(` (1 site) → `AppShimmerSkeleton.listRows(rows: 4)`.
- `_SavedDataNotice` bespoke Container (1 site) → `AppBanner` warning (same
  copy, live-region kept).
- `Divider(` (separator, 1 site) → `AppDivider()`.
- KEPT (STOP/pinned, not legacy): `AppFilterBar` rail, `TechnicianJobSummary`
  rows (shared with Today + search sheet — STOP boundary), `_urgentFirst`,
  `_FreshnessFooter`, `openJob`/`push`/`closeJob` routing, shell chrome +
  search sheet (untouched files).
