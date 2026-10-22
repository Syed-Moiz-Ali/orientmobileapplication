# UX Brief — supervisor Jobs list tab (list family)

## Scope
`apps/staff_app` supervisor Jobs surface: `features/supervisor/presentation/widgets/supervisor_jobs_tab.dart`
(list + header + summary + filter + empty/no-match/error/loading) + `supervisor_scaffold.dart`
(shell bar + compact 4+More nav, expanded 7-rail — NOT touched) + `supervisor_components.dart`
(`SupervisorBay` derivation, `supervisorStatusPill/Tone`, `supervisorMono` — read-only).
Routes touched only as existing destinations: tab index 1 in `IndexedStack`; `onOpenAssign` →
`showSupervisorAssignSheet` (existing sheet). No new routes. No logic changes (providers,
`notifier.jobs`, `_bucket`, search predicate, refresh stay as-is).

Queue/Review are SEPARATE tabs (separate lists, separate briefs) — evidence: `supervisor_scaffold.dart`
`IndexedStack` children `[..., SupervisorJobsTab, SupervisorQueueTab, ReviewTab, ...]` (indices 1/2/3),
each with own provider slice (`jobs` vs `bookings/breakdowns` vs `awaitingCompletions`).
This brief covers the Jobs tab only.

## User goal
A supervisor opens Jobs and in one glance sees the active floor register (how many jobs, where each
stands) then narrows to the right record (type-to-filter, status chip) and fires the assign flow.
One screen, one primary task: find job → assign.

## Current behavior (verified from code)
- Entry: supervisor scaffold tab index 1 (`SupervisorJobsTab(onOpenAssign: _openAssign)`); compact nav
  keeps 4 primaries (Floor/Jobs/Queue/Review) + More (Reports/Staff/Schedule behind sheet); expanded rail
  keeps all 7. Scaffold bar shows the U1 bay-search icon ONLY off the floor tab (`selectedIndex != 0`
  guard) — on the Jobs tab the bar icon opens the floor-wide bay sheet (`showSupervisorFloorSearch`
  over `SupervisorBay`: bayCode/ref/title), NOT the register.
- Header: `AppPageHeader` (title `svJobsTitle`, subtitle `svJobsSubtitle(count)`, leading assignment icon)
  + `PrimaryButton` Assign (header action → same assign sheet).
- Summary: `_JobsSummary` Wrap — total / in-progress / completed / waiting-parts counts (inline text row,
  not cards).
- Filter: `AppSearchField` (hint `svJobsSearchHint`, live `onChanged` → `_query`) over
  `jobCard/customer/vehicle/status` (4-field contains) + `AppFilterBar` (InProgress/Completed/PartsDelay
  buckets via `supervisorStatusKind`, live counts, single-select + clear on re-tap).
- Rows: `_JobRow` borderless divider rows — status colour rail + identity (vehicle‖customer) +
  jobCard mono LTR + customer + `AppLinearProgress` + `svJobsTasks(done,total)` + status pill.
  Rows are DISPLAY ONLY (no onTap, no per-row action).
- States: `AppSkeleton.listRows(6)` loading; `EmptyState` (checklist icon + `svJobsEmpty/Message` + Assign
  action → same sheet); `EmptyState.noMatch` (`svJobsNoMatch` + clear → resets query+filter);
  `AppInfoPanel.danger` (`svJobsError` + Retry → `refreshDashboard`); `RefreshIndicator` pull-to-refresh.
- Staff light-only convention (dark stays structurally intact, not redesigned).

## Top tasks with tap counts (BEFORE = current UI, AFTER = this brief; AFTER ≤ BEFORE)
1. Open the Jobs list — before: bottom-nav/rail Jobs tab = **1 tap** (0 if deep-linked). After: ≤ 1 tap.
2. Find a job in the register — before: tab (1) + type in inline filter (0-tap focus + keystrokes) and/or
   status chip (1 tap) = **1 tap + keystrokes** (+ scroll). After: **≤ 1 tap + keystrokes**, ≤ same scroll.
   Inline filter stays (adjudicated STOP — different target from the bar bay-search; see below).
3. Open the assign flow — before: tab (1) + header Assign (1) = **2 taps**; empty-state Assign = 2 taps.
   After: ≤ 2 taps. Assign stays a header primary action AND the empty-state action (never both at once).
4. Clear a no-match — before: Clear = **1 tap** (resets query + filter). After: ≤ 1 tap.
5. Retry after error / pull-to-refresh — before: Retry = **1 tap** / pull gesture. After: unchanged.

| Task | Before | After budget |
|---|---|---|
| Open list | 1 tap | ≤ 1 tap |
| Find job (filter) | 1 tap + keystrokes (+scroll) | ≤ 1 tap + keystrokes, ≤ same scroll |
| Open assign flow | 2 taps (header or empty-state Assign) | ≤ 2 taps, same sheet |
| Clear no-match | 1 tap | ≤ 1 tap |
| Retry / refresh | 1 tap / pull | ≤ 1 tap / pull |

Frequent tasks (scan register, filter) stay single-screen; assign is the existing one-step sheet.

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: does not exist (confirmed — no `references` dir under `docs/ui-redesign/`).
- `AIRBNB_PATTERNS.md`: missing anywhere in the repo (repo-wide glob `**/AIRBNB_PATTERNS*` returns nothing;
  only mention is `docs/ui-redesign/evaluation/technician-home-test-migration.md:183` recording its absence;
  vehicles-list brief `phase-6-vehicles-list.md:89-108` records the same UNMET state).
- Mapping is therefore UNMET; this brief proceeds from precedent patterns (phase-5/phase-7 briefs +
  `phase-6-vehicles-list.md`): `AppPageHeader` + `AppFilterBar` + `AppListGroup` rows + `AppEmptyState` /
  `AppErrorState` + `AppShimmerSkeleton` + `AppBanner`/`AppInfoPanel` + borderless light rows + no ALL CAPS
  + zero as `0`.

## Vehicles-list pattern reuse — reasoned deviations
- REUSED: header with count (`AppPageHeader` title + `svJobsSubtitle(count)`); borderless divider rows;
  filter sheet→here `AppFilterBar` rail (honest status buckets, existing predicate); sheets for secondary
  (assign sheet stays the sheet); empty/loading/error vocabulary (mirroring skeleton, one-icon empty,
  retry error, pull-to-refresh).
- DEVIATION A (adjudicated STOP, keeps BOTH searches — U1-exception note): the vehicles pattern says
  "search icon only when > 5, inline never". The Jobs tab KEEPS its inline `AppSearchField` AND the shell
  bar keeps its bay-search icon. Reason: different entity + fields + scope + result contract
  (`docs/ui-redesign/evaluation/phase-jobs-search-audit-review.md` §2: `SupervisorBay` bayCode/ref/title
  over floor-wide awaiting+jobs+bookings+idle bays → assign sheet, vs `AssignedJobEntity`
  jobCard/customer/vehicle/status over the register only → inline narrowing). Collapsing either way loses
  scope. C16 one-path-per-task does not fire (different tasks). No search icon is ADDED to the Jobs header;
  the bar icon is owned by the scaffold (off-floor guard untouched). The > 5 threshold does NOT apply here
  (register filter is always present, even ≤ 5 — it doubles as the status-text search the rail cannot do).
- DEVIATION B (frequent action placement): vehicles pattern puts the frequent action on each card. Here
  rows stay display-only and Assign stays header-level (+ empty-state). Reason: top-3 tasks show assign is
  a GLOBAL dispatch action (not per-record — rows have no per-row assign target today, and inventing one
  would add a duplicate entry path, C16). Taps do not regress (header Assign stays 1 tap from the list).
- DEVIATION C (no `AppListGroup` card wrapper): rows are already borderless divider rows on the page
  surface (C16-clean); wrapping them in `AppSurfaceCard`s would ADD boxes-in-boxes. Rebuild keeps
  borderless rows (rail + identity + progress + pill) with shared atoms, not new cards.

## U-laws application (U0–U14, C17)
- U0 (one read): register row = identity (vehicle‖customer) → jobCard LTR + customer → progress + pill.
  No competing hero; summary is a slim count strip, not cards. CARD HIERARCHY (binding): title = vehicle/
  customer (what the supervisor recognizes); jobCard = meta (mono, LTR, verbatim); status pill ONLY from
  existing `supervisorStatusKind` data — never invented.
- U1 (find fast): inline register filter (always present — STOP exception above) + status rail; shell bar
  icon (bay scope) untouched. No new search icon added to the Jobs header (adding one would duplicate the
  bar icon's seat and violate one-path-per-task). No inline added anywhere else.
- U2 (fit the content): heterogeneous rows (identity + progress + pill) — grouped divider rows, NOT a data
  table (table matrix cell = N/A by design). FOLD (binding): at 360x800 the header + summary + filter +
  FIRST row sit above the fold (above bottom nav, idle with data) with the SECOND row peeking; anything
  pushing the first row below the fold needs a written reason.
- U3 (no fake actions): rows map 1:1 to existing visuals (no row tap invented — rows stay display-only as
  today); Assign/Retry/Clear map 1:1 to existing handlers.
- U4 (no invention): jobCard/vehicle/customer/status verbatim via existing fields; zero shown as `0`;
  counts from `allJobs.length` + bucket counts only.
- U5 (reachable + legible): 48dp targets on Assign/chips/Clear; progress + counts wrap (never clip) at
  320px / 1.3x; jobCard stays LTR-locked; customer/vehicle follow ambient direction.
- U6 (states): skeleton mirrors the rows (`AppShimmerSkeleton` mirroring row layout); honest empty
  (`AppEmptyState`: EXACTLY one icon + one sentence + one Assign action → same sheet); no-match + Clear;
  error (`AppErrorState`/`AppInfoPanel` + Try again, same retry); stale data kept + notice; pull-to-refresh.
- U7 (feedback): assign opens the EXISTING sheet (same contract); snackbars unchanged; busy states disable
  only acting controls. One path per task: register filter (inline) vs bay lookup (bar) are different
  tasks — no same-target twins.
- U8 (no dead ends): every state offers a live control (Assign / Clear / Retry / pull); no badge-only rows.
- U9 (consistency): `AppPageHeader`, `AppFilterBar`, `AppListGroup`-style divider rows, `AppBanner`/
  `AppInfoPanel` — same atoms as staff precedent.
- U10 (RTL): full mirror; jobCard/progress figures LTR-locked (`Directionality` kept); rail uses
  `marginEnd`, never left/right hard-code.
- U11 (a11y): row `Semantics` label (vehicle + jobCard + status) kept; header `Semantics(header: true)`;
  live-region on error kept.
- U12 (density): 1-col compact; wider canvas keeps single-column register (register is a scan list, not a
  grid — chunking predicate N/A by design, recorded here).
- U13 (offline): bar banner owns offline state; stale list kept + refresh notice; retries inline.
- U14 (no regression): tap budgets above are ceilings; pull-to-refresh, keys, assign-sheet + snackbar
  contracts unchanged in behavior (presentation may move dialog→sheet only where a confirm exists — none
  on this tab; assign already IS a sheet).
- C17: any U-law fail caps at 8/16. C16 adaptations: no search-sheet (STOP), borderless light rows, no
  ALL CAPS, zero as `0`.

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke `_JobsSummary` Wrap styling → slim shared count strip (same 4 counts, same bucket
  predicate); bespoke `_JobRow` chrome (Stack/rail/Container/Divider code) → shared atoms (rail, identity,
  mono LTR, progress, pill) with byte-identical behavior; bespoke `EmptyState`/`AppSkeleton`/`AppInfoPanel`
  panels → `AppEmptyState` / `AppShimmerSkeleton` (row-mirroring) / `AppErrorState`+Retry (+ stale banner
  where applicable). Pull-to-refresh kept.
- MOVED: nothing (Assign/Clear/Retry keep seats; rows stay display-only).
- KEPT: scaffold bar + `selectedIndex != 0` guard + compact 4+More + expanded 7-rail (untouched);
  inline `AppSearchField` + 4-field predicate + `AppFilterBar` + bucket predicate + counts + clear;
  providers/sync/refresh/`buildSupervisorBays`, `supervisorMono`, pill/tone helpers, bottom nav, keys,
  assign-sheet + snackbar contracts. No new routes. No invented jobs/statuses.
- No new widgets kept back: if an App* atom lacks a behavior the old row had, EXTEND the App* atom
  (additively, with tests) then swap — never keep the legacy row for convenience.

## Fold wireframe (ASCII, 360×800 — header + summary + filter + first row above fold, second peeking)
```
+----------------------------------+
| Supervisor · Jobs        [🔍 bar] |  <- bar icon = BAY scope (scaffold, off-floor only); NOT register
| Active jobs · 12 jobs  [Assign]  |  <- AppPageHeader + count + header Assign (1 tap from list)
| 12 total · 7 run · 3 done · 2 wait|  <- slim count strip (no cards)
| [Filter jobs…                       ]|  <- inline register filter (STOP: always present)
| (All) (Running 7) (Done 3) (Wait 2)|  <- AppFilterBar rail (existing buckets)
|----------------------------------|
| ▏Toyota Camry · Ahmed      [RUN] |  <- row 1: rail + identity + pill (above fold)
| JC-1042 · progress ━━━━ 3/5      |
|----------------------------------|  <- fold line (nav below)
| ▏Nissan Patrol · Sara      [WAIT]|  <- row 2 PEEKING
+----------------------------------+
| Floor | Jobs | Queue | Review |⋯ |
```

## Matrix requirements
- empty (no jobs: one icon + one sentence + one Assign → same sheet; never zero-filled) ·
- with-data (1 record single column; N records same column; progress inline) ·
- filter (inline + rail; count updates; no-match + Clear) ·
- error (Retry, same handler) + loading (row-mirroring skeleton) + stale/refresh ·
- ar (RTL mirrored; jobCard/figures LTR-locked) ·
- 1.3x (chips/actions wrap, rows never clip) ·
- 320px (single column; header + filter + first row intact) ·
- tablets (single-column register; rail + rows max-width; table variant N/A by design per U2).

## Copy keys needed
Reuse existing staff keys (`svJobs*`, `svBayPartsDelay`, `filterBarClear`, `commonRetry`) — zero new keys
expected (phase-9 list: none). No ALL CAPS strings added.

## Acceptance
- U0–U14 walk (ANY U-law fail caps at 8/16); C16 hard-reject checklist (ANY violation caps at 10/16):
  borderless light rows, one filled accent per section (Assign only), one path per task (register filter
  vs bay lookup are different tasks — STOP), no permanent pills, no ALL CAPS, first row above fold +
  second peeking, card hierarchy (title → pill → meta), taps never regress.
- Airbnb rubric ≥ 12/16 to pass.
- Gates: characterization tests on the CURRENT list first, before-images captured, migration table
  (current → shared atoms), reviewer process per redesign mandate, NO logic changes.
- Verify from code: tap counts, `onOpenAssign` route/sheet, 4-field predicate, bucket predicate, key names,
  scaffold `selectedIndex != 0` guard + 4+More intact.
