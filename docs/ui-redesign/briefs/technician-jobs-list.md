# UX Brief — technician jobs list view (list family)

## Scope
`apps/staff_app` technician Jobs surface: `features/technician/presentation/widgets/technician_jobs_view.dart`
(filter rail + urgent-first rows + empty/no-match/error/loading/stale/freshness) +
`technician_dashboard_view.dart` (shell `_TechChrome` search icon + tab targets — NOT touched) +
`technician_today_search.dart` (full-screen search sheet — NOT touched, same predicate) +
`technician_components.dart` (`TechnicianJobSummary` — NOT touched, shared) +
providers (`technicianDashboardProvider`, `filteredJobs`, `_urgentFirst` — read-only).
Routes touched only as existing destinations: Jobs tab (index 1); row tap → `openJob` +
`push(technicianJobDetail)` + `closeJob` on complete (existing dossier). No new routes. No logic changes.

## User goal
A technician opens Jobs and in one glance sees what work is assigned and which job to open next, then
opens one dossier. One screen, one primary task: find job → open dossier.

## Current behavior (verified from code)
- Entry: technician dashboard tab index 1 (`TechnicianJobsView` in `_pages`); shell `_TechChrome`
  (`AppAppBar`, 56, hairline) shows the U1 search icon on this tab (`selectedIndex != 0` guard) opening
  `showTechnicianTodaySearch` over `notifier.allJobs` (5-field predicate: jobCardNo/vehicleBrand/
  vehicleModel/customerName/normalized-plate). NO inline search field on this surface (removed in
  ui/integration-1; toolbar keeps the filter rail only).
- Toolbar: `_JobsToolbar` — `AppFilterBar` rail ONLY (options = `filterOptions` minus All; live counts
  keyed by localized All + per-status; `countSemantics` via `techJobsFilterSemantics`; `onSelected` →
  `updateFilter`). No `AppSearchField`, no controller, no `onChanged` anywhere in this file.
- Rows: urgent-first `ListView.separated` (`_urgentFirst`: delayed 0 / inProgress 1 / pending 2 /
  qcReview 3 / completed 4; filter/search matching untouched, only ordering) of `TechnicianJobSummary`
  (72px high-touch rows: job + vehicle + plate pill + start-time pill + status; `showProgress`,
  `emphasised` when inProgress) — rows are NAVIGATION entries (tap → dossier, 1 tap, 0 scroll). No
  per-row operational buttons — those live in Job Detail (phase-10 pinned).
- States: `AppSkeleton.listRows(4)` loading (showSkeleton = isLoading && empty); `EmptyState.error`
  (message `techJobsLoadError` + Retry → `refresh`) on first-load failure; `EmptyState` (assignment icon
  + `techJobsEmpty/Hint` + `techTodayRefresh` action → `refresh`) when no jobs; `EmptyState.noMatch`
  (title `techJobsNoMatch` + message hint/noMatch + `techJobsClearFilters` → `updateSearch('')` +
  `updateFilter('All')`); `_SavedDataNotice` (cloud_off + `dashboardError`) when stale data shows under
  an error; `_FreshnessFooter` (HH:mm `techTodayUpdated`, LTR). `RefreshIndicator` pull-to-refresh.
- Staff light-only convention (dark stays structurally intact, not redesigned).

## Top tasks with tap counts (BEFORE = current UI, AFTER = this brief; AFTER ≤ BEFORE)
1. Open the Jobs list — before: bottom-nav/rail Jobs tab = **1 tap** (0 via `selectTab(1)` deep-link).
   After: ≤ 1 tap.
2. Find a job — before: header icon → sheet → type → result tap (**1 + keystrokes + 1**, 1 path) OR
   filter chip (**1 tap**). After: identical (single search path kept; rail kept).
3. Open a job dossier — before: row tap = **1 tap, 0 scroll** (urgent-first keeps the next job near top).
   After: ≤ 1 tap, ≤ same scroll. Rows stay navigation entries (no buttons added — adding per-row
   actions would create duplicate paths to the dossier's actions, C16).
4. Clear a no-match — before: Clear filters = **1 tap**. After: ≤ 1 tap.
5. Retry after error / pull-to-refresh — before: Retry = **1 tap** / pull. After: unchanged.

| Task | Before | After budget |
|---|---|---|
| Open list | 1 tap | ≤ 1 tap |
| Find job (search sheet) | 1 + keystrokes + 1 (1 path) | identical, 1 path |
| Filter by status | 1 tap | ≤ 1 tap |
| Open dossier | 1 tap, 0 scroll | ≤ 1 tap, ≤ same scroll |
| Clear no-match | 1 tap | ≤ 1 tap |
| Retry / refresh + freshness | 1 tap / pull | ≤ 1 tap / pull |

Frequent tasks (find, open) stay single-screen; the dossier is the existing destination.

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: does not exist (confirmed — no `references` dir under `docs/ui-redesign/`).
- `AIRBNB_PATTERNS.md`: missing anywhere in the repo (repo-wide glob `**/AIRBNB_PATTERNS*` returns nothing;
  only mention is `docs/ui-redesign/evaluation/technician-home-test-migration.md:183`, echoed by the
  vehicles/supervisor briefs).
- Mapping is therefore UNMET; this brief proceeds from precedent patterns (phase-5 briefs +
  `phase-6-vehicles-list.md` + screens 1–3 + the blessed ui/integration-1 single-search fix
  `phase-jobs-search-audit-review.md` PASS 16/16): header-icon-only search → full-screen sheet,
  `AppFilterBar` rail, borderless rows, `AppEmptyState` / `AppErrorState` + `AppShimmerSkeleton` +
  `AppBanner`, no ALL CAPS + zero as `0`.

## Vehicles-list pattern reuse — reasoned deviations
- REUSED: search icon → full-screen sheet (shell-owned, same predicate/same dossier contract as the
  Today tab); filter rail on honest predicates; borderless rows; empty/loading/error vocabulary
  (mirroring skeleton, one-icon empty, retry error, pull-to-refresh + freshness).
- DEVIATION A (no in-body header — no "header with count" in-body): the shell `_TechChrome` already owns
  the per-tab title. Adding an in-body `AppPageHeader` would duplicate the title on one surface (two
  headlines, C16 one-task-per-screen dilution). Counts live on the rail chips (per-status, live) — the
  honest, already-localized count surface. No new header, no new keys.
- DEVIATION B (no > 5 search-icon gate — U1 note): the shell search icon shows on this tab at ANY list
  size (no count gate). Reason: the ui/integration-1 single-search fix is BLESSED (16/16, STOP
  adjudicated) with exactly this contract — header icon whenever `selectedIndex != 0`. Gating by count
  would add provider reads to shared shell chrome (also serving Productivity/Profile tabs) and regress
  the blessed single-path contract. The > 5 threshold therefore does NOT apply here; the rail + urgent
  order scale instead.
- DEVIATION C (frequent action placement): the vehicles pattern puts the frequent action ON each card.
  Here rows are pure NAVIGATION entries (tap → dossier, the frequent action IS the row tap, 1 tap/0
  scroll); operational buttons (start/complete/request/escalate) live in Job Detail by phase-10 design.
  Adding per-row buttons would duplicate the dossier's actions on the list (two paths per task, C16).
  Rows stay button-free; `TechnicianJobSummary` stays shared and untouched (deviation D).
- DEVIATION D (rows NOT rebuilt — STOP boundary): `TechnicianJobSummary` is shared with the Today view
  AND the search sheet (`technician_today_view.dart:699`, `technician_today_search.dart:123`). Rebuilding
  it here would restyle out-of-scope surfaces. It already meets C16 (borderless, 72px targets,
  hierarchy job → pills → status, no permanent pills). Rebuild swaps only the Jobs-view-owned chrome
  around it (states/separator/stale banner).

## U-laws application (U0–U14, C17)
- U0 (one read): rail (what filter is on) → urgent-first rows (delayed/running surface first) → freshness.
  No hero, no competing CTA. ROW HIERARCHY (binding, via kept component): job ref → vehicle + plate/start
  pills → status; IDs stay meta, never headlines.
- U1 (find fast): ONE top affordance (shell search icon) → full-screen sheet over the same loaded jobs
  (same 5-field predicate, same dossier contract); toolbar is filter-rail only. No inline added (would
  resurrect the cured duplicate — STOP).
- U2 (fit the content): homogeneous scan rows — single-column list, NOT a table (table matrix cell = N/A
  by design). FOLD (binding): at 360x800 the rail + FIRST row sit above the fold (above freshness/bottom
  nav, idle with data) with the second row peeking; anything pushing the first row below the fold needs
  a written reason.
- U3 (no fake actions): rows map 1:1 to dossier entry; rail/Retry/Clear/Refresh map 1:1 to handlers; no
  invented buttons or pills.
- U4 (no invention): refs/vehicle/plate/customer verbatim via existing fields; normalized-plate matching
  untouched; zero as `0`; counts from `allJobs` only.
- U5 (reachable + legible): 48dp+ rows/targets; pills wrap/ellipsize at 320px / 1.3x; footer time
  LTR-locked; `separatorBuilder` hairline full-bleed.
- U6 (states): skeleton mirrors the rows (`AppShimmerSkeleton.listRows(4)`); honest empty
  (`AppEmptyState`: one icon + one sentence + one Refresh → same refresh); no-match (title + hint +
  Clear → same reset); error (`AppErrorState` + Try again, same retry); stale data kept + `AppBanner`
  warning; pull-to-refresh + freshness footer.
- U7 (feedback): row tap → same dossier contract (open/closeJob); toasts inside dossier untouched. One
  search path, one filter path, one open path.
- U8 (no dead ends): every row opens; empty offers Refresh; no-match offers Clear; error offers Retry;
  stale offers pull-to-refresh.
- U9 (consistency): `AppFilterBar`, divider rows, sheet, `AppBanner` — same atoms as staff precedent +
  screens 1–3.
- U10 (RTL): full mirror; plate/time/figures LTR-locked (existing locks kept).
- U11 (a11y): row `Semantics` (kept component) + `countSemantics` on rail + live-region on error kept.
- U12 (density): 1-col compact; wider canvas max-width 1180 (existing `AppResponsivePage`), single-column
  register (grid chunking N/A by design).
- U13 (offline): stale list kept + banner; retries inline; footer clock keeps ticking on refresh.
- U14 (no regression): tap budgets above are ceilings; urgent-first order, predicates, freshness,
  open/closeJob, keys unchanged in behavior.
- C17: any U-law fail caps at 8/16. C16 adaptations: header-icon-only search (blessed, no > 5 gate),
  borderless rows, no ALL CAPS, zero as `0`.

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke `_SavedDataNotice` (plain Container) → `AppBanner` warning (same copy, live-region);
  bespoke state panels (`EmptyState.error` / `EmptyState` / `EmptyState.noMatch` / `AppSkeleton.listRows`)
  → `AppErrorState` (title `commonErrorTitle`, message `techJobsLoadError` verbatim, retry `commonRetry`)
  / `AppEmptyState` (1:1, same action) / `AppEmptyState` no-match (icon search_off, same title/message/
  Clear) / `AppShimmerSkeleton.listRows(4)`; `Divider` separator → `AppDivider()`. Pull-to-refresh +
  freshness kept.
- MOVED: nothing (rail/rows/search/dossier seats unchanged).
- KEPT (STOP/pinned): shell `_TechChrome` + `selectedIndex != 0` guard + tab targets + search sheet +
  predicate + `updateSearch` (frozen, sheet-owned); `_JobsToolbar` rail + predicate + counts +
  `countSemantics`; `_urgentFirst` order; `TechnicianJobSummary` (shared with Today + sheet — STOP
  boundary); open/closeJob + routes; `_FreshnessFooter`; bottom nav/rail. No new routes.
- No new widgets kept back: if an App* atom lacks a behavior the old chrome had, EXTEND the App* atom
  (additively, with tests) then swap — never keep the legacy panel for convenience.

## Fold wireframe (ASCII, 360×800 — rail + first row above fold, second peeking)
```
+----------------------------------+
| Technician · Jobs  [🔍][🔔][av] |  <- shell bar: search = single path (any size — deviation B)
|----------------------------------|
| (All 3)(Pending 1)(Running 1)…   |  <- AppFilterBar rail (existing buckets + counts)
|----------------------------------|
| JC-101 · Camry      [DELAYED]    |  <- row 1: urgent-first (delayed top, above fold)
| Ahmed · ABC 1234 · 08:30         |
|----------------------------------|  <- fold line (freshness + nav below)
| JC-102 · Hilux     [IN PROGRESS] |  <- row 2 PEEKING
+----------------------------------+
| Today | Jobs | Productivity | 👤 |
```
(No in-body header — deviation A; no per-row buttons — deviation C.)

## Matrix requirements
- empty (no jobs: one icon + one sentence + one Refresh → same refresh) ·
- with-data (3 jobs, urgent-first order delayed → inProgress → pending) ·
- filter (rail narrows; counts update; no-match + Clear) ·
- search-sheet ENTRY (shell icon; sheet internals untouched — not re-captured here) ·
- error (Retry, same handler) + loading (row-mirroring skeleton) + stale banner + freshness ·
- ar (RTL mirrored; plate/time/figures LTR-locked) ·
- 1.3x (rail scrolls, rows/pills wrap — never clip) ·
- 320px (single column; rail + first row intact) ·
- tablets (single column, max-width 1180; table variant N/A by design per U2).

## Copy keys needed
Reuse existing staff keys (`techJobs*`, `techTodayRefresh/Updated`, `commonRetry`, `commonNoResults`,
`commonErrorTitle`) — zero new keys expected (phase-9 list: none). No ALL CAPS strings added.

## Acceptance
- U0–U14 walk (ANY U-law fail caps at 8/16); C16 hard-reject checklist (ANY violation caps at 10/16):
  single search path (shell icon, blessed), rail-only toolbar, borderless rows, no filled CTA added,
  one path per task, no permanent pills, no ALL CAPS, first row above fold + next peeking, taps never
  regress.
- Airbnb rubric ≥ 12/16 to pass.
- Gates: characterization tests on the CURRENT list first, before-images captured, migration table
  (current → shared atoms), reviewer process per redesign mandate, NO logic changes.
- Verify from code: tap counts, sheet call (`allJobs` + `openJob` + dossier route), predicate + order,
  key names, shell guard + tab targets intact.
