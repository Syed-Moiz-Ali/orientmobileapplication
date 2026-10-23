# Technician job detail task-find test migration (ui/fix-rulings, ruling (a))

Branch: `ui/fix-rulings`. Technician Job Detail gains ONE shell search action
(ruling (a): search icon top-right of the header row, in the shell
`WorkspaceAppBar` where one exists). Presentation/flow-wiring only: same
tasks/targets/routes, no logic, no data, no predicate changes. If a relocation
had needed logic, it would have STOPped here — none did.

## Inventory (new capability, no frozen baseline)

- `apps/staff_app/test/technician_task_search_test.dart` (new, 3
  testWidgets): behavior pins for the NEW task find sheet with fixture
  `WorkTaskEntity` rows (completed + pending): substring filter over task
  titles (case-insensitive); no-match message + Clear restoring all rows;
  result tap firing `onSelect` with the task (the detail wires it to the
  existing start/complete toggle contract). Run GREEN (3/3). Counts only go
  up (no prior pins existed for this surface).
- `apps/staff_app/test/technician_job_detail_after_capture_test.dart` (new,
  5 testWidgets, tagged `baseline`, excluded from the default run):
  deterministic detail frames (fixtures carry no in-progress task, so no live
  stopwatch renders) — `detail_1.0_en_360x800`, `detail_1.0_ar_360x800`,
  `detail_1.3_en_360x800`, `detail_1.0_en_320x568`, `detail_search_open_en_360x800`
  (sheet open with query `oil`) — into the new
  `docs/ui-redesign/baseline/after-technician-job-detail/` dir. Compare
  back-to-back green, `takeException` null. Harness per gate: real fonts,
  `debugShowCheckedModeBanner: false`, shadows restored, runAsync + delays,
  connectivity mocks BOTH `check` + `checkConnectivity` (list form) +
  `connectivityStatusProvider` wifi override, Hive `technician_jobs` box,
  ar locale + delegates + AppTheme.

## Changed test assertions

None (new surface). The 3 behavior tests + 5 capture frames are additive.

## Behavior assertions (verbatim, new capability)

- Tap counts (brief BEFORE for start/complete: dossier open (1) + row
  Start/Complete (1) = **2 taps**; find did not exist). AFTER: find = AppBar
  icon (**1 tap**) + keystrokes + result (**1 tap**) = **≤ 2 taps from the
  detail** (N/A-regression: taps never regress; start stays on the existing
  row contract, unchanged cost).
- Predicate: substring over `task.description` (case-insensitive) over the
  detail's loaded `liveJob.tasks` only — same fields the checklist renders,
  so the sheet can never promise a task the detail does not show.
- Result contract: tap pops the sheet (reveal) and calls `onSelect`; the
  detail passes the existing toggle wiring (completed/QC-locked → no-op;
  running → `complete(task)`; else → `start(task)` — the same `_mutate`
  closures the rows use, busy guard intact). No new routes, no new notifier
  methods.
- Sticky bar intact (`bottomNavigationBar` untouched); keyboard-safe intact
  (sheet `AppSearchField` keeps the shared contract, no forced autofocus).
- Copy keys: zero new (reused `techJobsSearch`, `techJobsNoMatch`,
  `techJobsNoMatchHint`, shared `filterBarClear`). Phase-9 list: none.
- Single visible search path on the detail (pump-verified: exactly one
  `Icons.search_rounded` in the shell bar; capture `_openTaskSearch` asserts
  `findsOneWidget`).

## Verification

- `flutter test --exclude-tags baseline` in `apps/staff_app`: all green
  (incl. the 3 new tests; supervisor/technician suites untouched otherwise).
- `flutter analyze --no-pub` in `apps/staff_app`: no issues.
- `test/failures/` debris: none (deleted; verified absent).
- RTL mirror, 320/1.3x: ar/320/1.3x frames compare green, zero
  `takeException`.

## STOP-grade needs / blockers

- None. No logic change was needed (tap reuses the existing toggle
  closures); no invented tasks/statuses/times; no shared_core changes.

## Adversarial D2/D3 close-out (ui/fix-rulings — presentation only)

- D2 retitle: the task sheet no longer reuses `techJobsSearch`. New ARB keys
  en+ar (`techTaskSearch` "Search tasks" / "ابحث في مهام الإصلاح",
  `techTaskSearchHint` "Search by task name" / "ابحث باسم مهمة الإصلاح",
  `techTaskNoMatch` "No matching tasks" / "لا توجد مهام إصلاح مطابقة",
  `techTaskNoMatchHint` "No tasks match your search." / "لا توجد مهام إصلاح
  تطابق بحثك." — sentence-case en, glossary style); `flutter gen-l10n`
  rerun from `apps/staff_app`, gen diff additive only (+48 lines across the
  3 gen files, no renames). `technician_task_search.dart` title/hint/
  no-match now read the task keys; predicate (`description contains`),
  sheet/target/route/result contract untouched. `technician_task_search_test.dart`
  no-match expectation updated to the task copy (same 3 tests, same shapes).
- D3 rebuttal (FALSE, no code change): the task result tap pops the sheet
  (`Navigator.of(context).pop()` in `technician_task_search.dart` +
  `onSelect` → existing start/complete toggle) — find costs icon (1) + keys
  + result (1), ≤ the 2-tap detail start/complete budget; there is NO extra
  close tap. The test pins it (`AppSearchField findsNothing` after select).
- Counts: behavior file still 3 tests, 3 assertions — counts did not go down
  (1 expectation rewritten for the new seat copy, 2 untouched); all other
  suites untouched (112 total green). Frames: all 5
  `after-technician-job-detail/` PNGs regenerated via the allowed
  `technician_job_detail_after_capture_test.dart --update-goldens` only
  (only `detail_search_open_en_360x800.png` pixels change — title now
  `Search tasks` with `oil` → `Change engine oil / Completed`); compare
  back-to-back green, `takeException` null, RTL/320/1.3x intact (ar/320/1.3x
  temp pump clean, then deleted). `test/failures/` debris absent.
- STOPs: none this pass (retitle is copy-only; D3 needed no fix).
