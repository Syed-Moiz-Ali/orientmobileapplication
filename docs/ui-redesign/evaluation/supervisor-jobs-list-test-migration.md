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
| rows render identity, progress math and status copy | `AppLinearProgress` bar + `Divider` | `AppProgressBar` (pinned tone: success-when-complete else accent — C2 fix, same value; status stays on rail+pill) + `AppDivider` | structural (same finders, still green) |
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
- `AppLinearProgress(` (1 site) → `AppProgressBar(value:, tone:)` (pinned
  success/accent — C2 fix). No remaining `AppLinearProgress` in
  `supervisor_jobs_tab.dart`.
- `Divider(` (1 site) → `AppDivider()`. No remaining raw `Divider` in
  `supervisor_jobs_tab.dart`.
- KEPT (STOP/pinned): `AppSearchField`, `AppFilterBar`, `AppPageHeader`,
  `supervisorStatusPill/Tone/Mono`, scaffold bar + nav (untouched files).

## Adversarial-fix pass (ui/list-ops, 2026-10-22 — presentation only)

Verified every D1–D8 claim in `adversarial-sv-jobs-review.md` against the
full widget tree (tab + `supervisor_scaffold.dart` shell) + code. Fixed 3,
rebutted 5 with file+line evidence. Zero new ARB keys; predicates, routes,
sheets, providers untouched; characterization counts 8 -> 8.

FIXED (code + recaptured `after-supervisor-jobs/` all 10 frames, 38/38
back-to-back green with the other three screens):
- D3 (C2/U10 red-means-done): `_JobRow` `AppProgressBar(value:)` auto tone
  painted 4/4 FULL RED. Pinned `tone:` success-when-complete else accent
  (`supervisor_jobs_tab.dart` `_JobRow`); same progress value, token only.
  AFTER: 4/4 green + green pill; partials neutral blue.
- D4 (U5 rail + Clear clip): `Par…` mid-word cut + `Complete…` clipped
  against `Clear`. `AppFilterBar(wrap: true)` (call-site only; shared atom
  untouched): chips + Clear flow at chip boundaries, nothing cut mid-word.
- D5 (U6/C16 duplicate Assign): empty frame showed header + body `Assign
  work`. Header action now suppressed on the confirmed-empty register
  (`isEmptyRegister`; brief line 49 "never both at once"); body Assign keeps
  the same sheet/handler. Characterization `empty register` updated to
  `findsOneWidget` (same 8 tests, same taps: tab + body Assign = 2 taps).
- D2 (U8 completed-under-Active): feed-owned, NOT filtered (U8 rule).
  Provider returns the status-agnostic server list
  (`supervisor_providers.dart:386-399`); capture fixture `_doneJob`
  (after-capture test `:47-55`) intentionally carries the terminal job — sort
  and fixture verified innocent. Logged as `LOGIC_FOLLOWUPS.md` entry 13
  (same family as advisor #1, owner #12). Behavior intentionally unchanged.

REBUTTED (no code change; evidence):
- D1 (U1/C16 inline search): sanctioned dual-search STOP (brief deviation A +
  blessed `phase-jobs-search-audit-review.md` §2: register inline filter over
  `AssignedJobEntity` vs shell bar bay-search over `SupervisorBay` —
  different entity/fields/scope; scaffold icon exists at
  `supervisor_scaffold.dart:401-406` but the tab captures crop it).
  Removing inline = predicate/logic removal → STOP if pursued.
- D6 (U9 rail grammar/casing): count seats are per-brief sanctioned (strip +
  rail here, rail-only on tech, deviations A); pill labels render feed status
  text verbatim (brief U4; server-text family per LOGIC #9). No invention.
- D7 (U11 triple counts): summary strip is brief-KEPT (same 4 bucket counts);
  numbers are consistent, not contradictory; strip + subtitle serve scan.
  Prior rounds passed; no genuine harm.
- D8 (skeleton/AR/tablet): generic `AppShimmerSkeleton` is the shared
  harness atom (non-gating; changing it touches every surface → owning-phase
  STOP); AR mirrors correctly; tablet single-column correct.

Tap walk AFTER-fix: open ≤1 ✓ · find ≤1 + keystrokes ✓ · assign ≤2 ✓ ·
clear 1 ✓ · retry 1 / pull ✓. No budget regresses.

## Scope-unification pass (ui/fix-rulings, ruling (a) — presentation only)

The adjudicated dual-search STOP above (§Behavior assertions STOP + §Adversarial-fix
D1) is SUPERSEDED by scope unification: the shell AppBar icon on the Jobs tab
now opens a NEW register search sheet over `AssignedJobEntity` (same 4-field
inline predicate: `jobCard`/`customer`/`vehicle`/`status`, case-insensitive
contains; same fields; result tap = same assign sheet via `onSelect` →
`showSupervisorAssignSheet`), and the inline `AppSearchField`
(`supervisor_jobs_tab.dart:106-109`) is REMOVED. One visible search path per
screen: AppBar icon → register sheet (Jobs tab), AppBar icon → floor sheet
(floor tab). Zero new ARB keys (`svJobsTitle` title, `svJobsSearchHint` hint,
`svJobsNoMatch` message, shared `commonNoResults`/`filterBarClear` reused
verbatim); providers, routes, bucket predicate, progress math, sheets/targets
untouched; no predicate change.

### Changed test assertions (this pass)

| Test | Old | New | Kind |
|---|---|---|---|
| inline search narrows by job card, customer, vehicle, status | `AppSearchField` inline filter in the tab body | `register search sheet narrows by job card, customer, vehicle, status`: the sheet (opened exactly as the Jobs-tab AppBar icon opens it, over the same `notifier.jobs`) filters to the match; background tab keeps all rows (sheet scope only); result tap fires the assign contract with the right `jobCard` | structural (same predicate/target, new seat) |
| no match offers a clear action that resets the list | inline no-match Clear resets `_query` + `_filter` | `no match offers a clear action that resets the sheet`: sheet no-match (`commonNoResults` + `svJobsNoMatch` verbatim) Clear restores all register rows in the sheet | structural (same copy, new seat) |

Counts: characterization file still 8 tests, 8 assertions — counts did not
go down (2 tests rewritten for the new seat, 6 untouched). Header note in the
test file ("Do NOT modify …") is superseded by this ruling for exactly these
two search-seat tests; all other pins frozen.

### Behavior assertions (verbatim, updated seats)

- Tap counts (brief BEFORE, verified from code): open list = tab (**1 tap**);
  find = AppBar icon (**1 tap**) + keystrokes + result (**1 tap**, same assign
  sheet — per-path cost identical to the old bar-sheet and inline paths, one
  path kept); assign = header/empty Assign (**2 taps** from launch);
  rail filter = chip (**1 tap**); clear = Clear (**1 tap**); retry = Retry
  (**1 tap**) / pull. AFTER: identical budgets, single path.
- Provider reads identical (`supervisorDashboardProvider` + notifier `jobs`,
  `refreshDashboard`); scaffold `_openSearch` branches per tab
  (Jobs → register sheet, else floor sheet); `_SupervisorChrome` always shows
  the one icon (tooltip `svJobsSearchHint` on Jobs, `svSearchTitle` else).
- Search predicate identical (4 fields over `notifier.jobs`, `_bucket` via
  `supervisorStatusKind` untouched); tab keeps the status rail only.
- Copy keys: zero new (reused `svJobsTitle`, `svJobsSearchHint`,
  `svJobsNoMatch`, `commonNoResults`, `filterBarClear`, `commonRetry`).
- Frames: all 10 `after-supervisor-jobs/` PNGs regenerated (the `search` frame
  now captures the register sheet open with query `sara`); compare
  back-to-back green, `takeException` null, RTL/320/1.3x intact.

STOPs: none. No logic change was needed (unification is flow-wiring over the
same sheets/predicates/targets/routes).

## Adversarial D1/D3 close-out (ui/fix-rulings — presentation only)

- D1 scoping: `_SupervisorChrome` now guards the shell icon to
  `selectedIndex == 0 || selectedIndex == 1` (Floor + Jobs only; same
  `selectedIndex` guard pattern as before). Queue/Review/Reports/Staff/
  Schedule (incl. More overflow) show NO icon — those tabs never had a list
  search, so nothing that existed is removed; taps unchanged. `_openSearch`
  branches untouched (Jobs → register sheet, Floor → floor sheet; same
  sheets/predicates/targets/routes, no logic change).
- D3 rebuttal (FALSE, no code change): the register result tap pops the sheet
  (`Navigator.of(context).pop()` in `supervisor_register_search.dart` +
  `onSelect` → `showSupervisorAssignSheet`) — find costs icon (1) + keys +
  result (1), tying the inline path; there is NO extra close tap. The
  dismiss the adversarial counts only applies to find-without-assign, which
  the inline path also paid (chip Clear / scroll-away); budgets tie.
- Counts: characterization file still 8 tests, 8 assertions — counts did not
  go down (no test edits this pass). Frames: `after-supervisor-jobs/` search
  frame unchanged (Jobs keeps the icon); compare back-to-back green,
  `takeException` null, RTL/320/1.3x intact.
