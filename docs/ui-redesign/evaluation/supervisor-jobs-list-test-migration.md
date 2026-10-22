# Supervisor Jobs list test migration (GROUP-C list-ops, screen 1)

Branch: `ui/list-ops`. Jobs tab recomposed presentation-only onto App* pattern
widgets: providers, routes/sheets, predicates, buckets, progress math,
refresh/sync logic, copy semantics, scaffold bar guard (`selectedIndex != 0`),
compact 4+More nav + expanded 7-rail untouched; no new routes, no new ARB keys.

## Inventory (characterization baseline, STEP 0)

- `apps/staff_app/test/supervisor_jobs_list_characterization_test.dart` (new,
  8 testWidgets): behavior pins written for the CURRENT Jobs UI with a fake
  `SupervisorRemoteDataSource` (`_FakeSupervisorRemote` implementing the
  interface; Hive misses are caught+logged by the provider, no box needed).
  Run GREEN before the rebuild (8/8) and GREEN after (8/8). Frozen after
  STEP 0 except the bidi-containment hardening below — same 8 tests, same
  assertion shapes, counts 8 -> 8.
- State-copy finders use `textContaining` (not `text`) for empty/no-match/
  error strings: the recomposed `AppEmptyState`/`AppErrorState` bidi-isolate
  title+message (U+2066…U+2069, invisible), so containment is green on the
  current `EmptyState`/`AppInfoPanel` UI and on the new atoms. Row/header/
  progress/action copy stays `text` (plain `Text` pre and post).
- Before pixels (frozen record, never regenerated):
  `docs/ui-redesign/baseline/before-supervisor-jobs/` — `idle` (en/ar
  360x800, en 320x568, en 1.3x 360x800, en 768x1024), `empty`, `error`,
  `loading` (light, staff light-only). Produced by
  `apps/staff_app/test/supervisor_jobs_list_before_capture_test.dart` (tagged
  `baseline`, excluded from the default run).
- After pixels (review only, same matrix):
  `docs/ui-redesign/baseline/after-supervisor-jobs/` via
  `apps/staff_app/test/supervisor_jobs_list_after_capture_test.dart`.

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| header shows title, live count and the assign action | `PrimaryButton` header Assign | `AppPillButton.primary` header Assign (same label/icon/handler) | structural (rendering-identical: same finders, still green) |
| rows render identity, progress math and status copy | `AppLinearProgress` bar + `Divider` | `AppProgressBar` bar (auto tone; status stays on rail+pill) + `AppDivider` | structural (same finders, still green) |
| inline search narrows by job card, customer, vehicle, status | `AppSearchField` + 4-field predicate | verbatim (STOP: inline kept, predicate untouched) | behavioral (unchanged) |
| status rail filters by bucket and re-tap clears | `AppFilterBar` + bucket predicate | verbatim | behavioral (unchanged) |
| no match offers a clear action that resets the list | Legacy `EmptyState.noMatch` | `AppEmptyState` (title `commonNoResults`, message `svJobsNoMatch` verbatim, Clear → same reset) | structural (rendering-identical) |
| empty register shows the empty state with assign | Legacy `EmptyState` | `AppEmptyState` (icon/title/message/action verbatim, same sheet) | structural (rendering-identical) |
| first-load failure shows the error with retry | `AppInfoPanel.danger` + Retry | `AppErrorState` (title `commonErrorTitle`, message `svJobsError` verbatim, retry `commonRetry` → same refresh) | structural (rendering-identical) |
| loading shows no rows and no error | `AppSkeleton.listRows(6)` | `AppShimmerSkeleton.listRows(6)` | structural |

## Behavior assertions (verbatim, unchanged)

- Tap counts (brief BEFORE, verified from code): open list = tab (**1 tap**);
  find job = type + chip (**1 tap + keystrokes**); assign = header/empty Assign
  (**2 taps** from launch); clear = Clear (**1 tap**); retry = Retry (**1 tap**)
/ pull. AFTER: identical (same seats, same sheet, ≤ same scroll).
- Provider reads identical: `supervisorDashboardProvider` (+ notifier `jobs`,
  `refreshDashboard`), `supervisorRemoteDataSourceProvider` untouched.
- Search predicate identical: `jobCard`/`customer`/`vehicle`/`status`
  case-insensitive contains over `notifier.jobs`; `_bucket` via
  `supervisorStatusKind` (success → Completed, inProgress → In progress,
  else → Parts delay) untouched; counts from `allJobs` only.
- Progress math identical: `(done/total).clamp(0,1)`, `svJobsTasks(done,total)`
  verbatim; bar token changed only.
- STOP honored: bar bay-search (`SupervisorBay`, scaffold-owned, off-floor
  guard) and inline register filter (`AssignedJobEntity`) both kept — different
  entity + fields + scope + result contract (adjudicated
  `phase-jobs-search-audit-review.md` §2). No search icon added to the Jobs
  header; scaffold nav untouched.
- Copy keys: zero new (reused `svJobs*`, `svBayPartsDelay`, `commonErrorTitle`,
  `commonNoResults`, `filterBarClear`, `commonRetry`). Phase-9 list: none.

## WIDGET_MIGRATION_MAP delta (this screen)

- `PrimaryButton(` (1 site, Jobs header Assign) → `AppPillButton.primary`
  (small, non-expanded). No remaining `PrimaryButton` in `supervisor_jobs_tab.dart`.
- `EmptyState(` + `EmptyState.noMatch(` (2 sites) → `AppEmptyState` (1:1 copy).
  No remaining `EmptyState` in `supervisor_jobs_tab.dart`.
- `AppSkeleton.listRows(` (1 site) → `AppShimmerSkeleton.listRows(rows: 6)`.
  No remaining `AppSkeleton` in `supervisor_jobs_tab.dart`.
- `AppInfoPanel.danger(` (1 site) → `AppErrorState` (title/message/retry 1:1).
  No remaining `AppInfoPanel` in `supervisor_jobs_tab.dart`.
- `AppLinearProgress(` (1 site) → `AppProgressBar(value:)` (auto tone).
  No remaining `AppLinearProgress` in `supervisor_jobs_tab.dart`.
- `Divider(` (1 site) → `AppDivider()`. No remaining raw `Divider` in
  `supervisor_jobs_tab.dart`.
- KEPT (STOP/pinned): `AppSearchField`, `AppFilterBar`, `AppPageHeader`,
  `supervisorStatusPill/Tone/Mono`, scaffold bar + nav (untouched files).
