# UX Brief — supervisor Queue list tab (list family)

## Scope
`apps/staff_app` supervisor Queue surface: `features/supervisor/presentation/widgets/supervisor_queue_tab.dart`
(list + header + priority filter + two sections + assign sheet + empty/no-match/error/loading) +
`supervisor_scaffold.dart` (shell bar + compact 4+More, expanded 7-rail — NOT touched) +
`supervisor_components.dart` (`SupervisorBay` derivation, `bookingPriority`/`queuePriorityRank`,
toast — read-only). Routes touched only as existing destinations: tab index 2 in `IndexedStack`;
row Assign → `showAppModalSheet` advisor picker (same sheet) → `assignBooking`/`assignBreakdown`
→ toast. No new routes. No logic changes (providers, sort, buckets, refresh stay as-is).

Queue/Jobs/Review are SEPARATE tabs (separate lists, separate briefs) — evidence: `supervisor_scaffold.dart`
`IndexedStack` children `[..., SupervisorJobsTab, SupervisorQueueTab, ReviewTab, ...]` (indices 1/2/3),
each with own provider slice (`jobs` vs `bookings/breakdowns` vs `awaitingCompletions`).
This brief covers the Queue tab only.

## User goal
A supervisor opens Queue and in one glance sees what is waiting to be dispatched (breakdowns first,
then priority-sorted bookings) then routes one item to an advisor. One screen, one primary task:
find waiting work → route to advisor.

## Current behavior (verified from code)
- Entry: supervisor scaffold tab index 2 (`SupervisorQueueTab(onOpenReview: ...)`); shell bar shows the
  U1 bay-search icon on this tab (`selectedIndex != 0` guard) opening the floor-wide bay sheet.
- Header: `AppPageHeader` (title `svQueueTitle`, STATIC subtitle `svQueueSubtitle`, leading alt-route
  icon) + refresh `IconButton` action (tooltip `commonRetry` → `refreshQueue`).
- Filter: `AppFilterBar` (VIP / Promised-today / Insurance facets derived from existing
  `bookingPriority`, live counts, single-select + clear on re-tap). Filter narrows BOOKINGS ONLY;
  breakdowns always listed.
- Sections: `_SectionLabel` (icon + label + count badge) for Breakdowns then Bookings; bookings
  priority-sorted (`queuePriorityRank`: VIP → promised → insurance → normal, stable within rank).
- Rows: `_QueueRow` borderless divider rows — icon + title (vehicle‖service) + detail + LTR plate +
  priority pill + FULL-WIDTH `SecondaryButton` Assign (`svQueueAssign`) directly on the row.
- Assign: `_route` → empty-advisor guard toast (`svQueueNoAdvisors`) else `showAppModalSheet` advisor
  picker (radio rows + Assign CTA) → `assignBooking`/`assignBreakdown` → toast (`svQueueAssigned` /
  `svQueueDispatched` / `svQueueAssignFailed`).
- States: `AppSkeleton.listRows(6)` loading; `EmptyState` (inbox + `svQueueEmpty/Message`, NO action);
  `EmptyState.noMatch` (`svQueueNoMatch` + Clear → resets filter); `_EmptyLine` (plain text) when a
  section is empty but the other is not; `AppInfoPanel.danger` (`svQueueError` + Retry → `refreshQueue`);
  `RefreshIndicator` pull-to-refresh.
- Staff light-only convention (dark stays structurally intact, not redesigned).

## Top tasks with tap counts (BEFORE = current UI, AFTER = this brief; AFTER ≤ BEFORE)
1. Open the Queue list — before: bottom-nav/rail Queue tab = **1 tap** (0 if deep-linked). After: ≤ 1 tap.
2. Route waiting work to an advisor — before: tab (1) + row Assign (1) + picker select (1, pre-selected
   first) + sheet Assign CTA (1) = **3 taps from list (+ scroll)**. After: **≤ 3 taps**, ≤ same scroll.
   Assign stays DIRECTLY on each row (frequent action on the card — vehicles pattern applies here).
3. Filter by priority — before: chip tap = **1 tap**. After: ≤ 1 tap (same rail, same buckets).
4. Clear a no-match — before: Clear = **1 tap**. After: ≤ 1 tap.
5. Retry after error / pull-to-refresh — before: Retry = **1 tap** / pull gesture. After: unchanged.

| Task | Before | After budget |
|---|---|---|
| Open list | 1 tap | ≤ 1 tap |
| Route item to advisor | 3 taps from list (+scroll) | ≤ 3 taps, ≤ same scroll |
| Filter by priority | 1 tap | ≤ 1 tap |
| Clear no-match | 1 tap | ≤ 1 tap |
| Retry / refresh | 1 tap / pull | ≤ 1 tap / pull |

Frequent task (route) stays single-screen; the picker sheet is the existing one-step confirm.

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: does not exist (confirmed — no `references` dir under `docs/ui-redesign/`).
- `AIRBNB_PATTERNS.md`: missing anywhere in the repo (repo-wide glob `**/AIRBNB_PATTERNS*` returns nothing;
  only mention is `docs/ui-redesign/evaluation/technician-home-test-migration.md:183`, echoed by the
  vehicles + jobs briefs).
- Mapping is therefore UNMET; this brief proceeds from precedent patterns (phase-5/phase-7 briefs +
  `phase-6-vehicles-list.md` + screen-1 `supervisor-jobs-list.md`): `AppPageHeader` + `AppFilterBar` +
  borderless divider rows + `AppEmptyState` / `AppErrorState` + `AppShimmerSkeleton` + sheets +
  frequent action on the card + no ALL CAPS + zero as `0`.

## Vehicles-list pattern reuse — reasoned deviations
- REUSED: header (+ static subtitle; counts live on the section labels — see deviation A); borderless
  divider rows; filter sheet→here `AppFilterBar` rail (honest priority buckets, existing predicate);
  frequent action DIRECTLY on each row (Assign — the pattern's core); sheets for secondary (advisor picker
  stays the sheet); empty/loading/error vocabulary (mirroring skeleton, one-icon empty, retry error,
  pull-to-refresh).
- DEVIATION A (header count placement): the vehicles pattern puts the count in the header subtitle. Here
  the header subtitle stays STATIC (`svQueueSubtitle`) and counts stay on the two `_SectionLabel` badges
  (breakdowns N, bookings N — already per-section). Reason: a composed header count needs a NEW ARB key
  for zero information gain (two honest section counts already answer "how much is waiting", per-section —
  strictly more useful for triage). No new keys; no invention.
- DEVIATION B (no list-scoped search icon — U1 note): the vehicles pattern shows a search icon when > 5.
  This tab gets NO list-scoped search icon, at any size. Reason: top tasks are triage-by-priority (rail:
  1 tap) and route (row: 1 tap) — both already ≤ 2 taps with zero typing; the surface's ONE search path is
  the scaffold bar bay-search (same-scope rule from the technician single-search audit: one search path
  per surface — here the bar icon IS that path, unlike Jobs where bar + inline coexist on different
  targets). Adding a header search icon would put TWO search affordances on one surface over overlapping
  targets (bay lookup vs queue filter share bookings/breakdowns scope) — a C16 one-path-per-task
  violation. The > 5 threshold therefore does NOT apply here; the rail + section counts scale instead.
- DEVIATION C (no `AppListGroup` card wrapper): rows are already borderless divider rows on the page
  surface (C16-clean); wrapping sections in `AppSurfaceCard`s would ADD boxes-in-boxes. Rebuild keeps
  borderless rows with shared atoms.

## U-laws application (U0–U14, C17)
- U0 (one read): section order answers triage (breakdowns → bookings) → row = title (vehicle‖service) →
  detail + LTR plate → priority pill → Assign. CARD HIERARCHY (binding): title = vehicle/service (what
  the supervisor recognizes); plate = meta (LTR, verbatim); pill ONLY from existing `bookingPriority`
  (VIP/promised/insurance; normal renders NO pill — never invented).
- U1 (find fast): rail narrows bookings in 1 tap; bar icon owns bay lookup (single search path on this
  surface — deviation B). No inline search added (would duplicate the bar path's scope).
- U2 (fit the content): heterogeneous rows (icon + identity + pill + full-width action) — grouped divider
  rows, NOT a data table (table matrix cell = N/A by design). FOLD (binding): at 360x800 the header +
  rail + FIRST breakdown row sit above the fold (above bottom nav, idle with data) with the next row
  peeking; anything pushing the first row below the fold needs a written reason.
- U3 (no fake actions): rows map 1:1 to existing visuals; Assign/Retry/Clear map 1:1 to handlers; normal
  bookings show no pill (no fake priority).
- U4 (no invention): vehicle/plate/service verbatim via existing fields; zero as `0`; counts from
  loaded lists only.
- U5 (reachable + legible): 48dp targets on Assign/chips/Clear/sheet rows; plate LTR-locked; detail
  ellipsizes (1 line) at 320px / 1.3x, action wraps full-width (never clips).
- U6 (states): skeleton mirrors the rows (`AppShimmerSkeleton`); honest empty (`AppEmptyState`: EXACTLY
  one icon + one sentence + NO action — there is nothing to create here; U6 calm); no-match + Clear;
  section-empty `_EmptyLine` kept as quiet text; error (`AppErrorState` + Try again, same retry);
  pull-to-refresh kept.
- U7 (feedback): assign opens the EXISTING picker sheet (same contract); toasts unchanged; busy states
  disable only acting controls. One path per task (deviation B).
- U8 (no dead ends): every row offers Assign; empty offers nothing-to-do honestly (no dead CTA — the
  empty state correctly carries NO action since queue fills from bookings/breakdowns, not from user
  creation); no-match offers Clear; error offers Retry.
- U9 (consistency): `AppPageHeader`, `AppFilterBar`, divider rows, sheet, toasts — same atoms as staff
  precedent + screen 1.
- U10 (RTL): full mirror; plate/figures LTR-locked (`Directionality` kept); rail/badge use
  start/end insets.
- U11 (a11y): row `Semantics` (title + pill) kept; header `Semantics(header: true)`; live-region on
  error kept.
- U12 (density): 1-col compact; wider canvas keeps single-column register (grid chunking N/A by design).
- U13 (offline): bar banner owns offline state; stale list kept + refresh notice; retries inline.
- U14 (no regression): tap budgets above are ceilings; pull-to-refresh, keys, picker-sheet + toast
  contracts unchanged in behavior.
- C17: any U-law fail caps at 8/16. C16 adaptations: no search-sheet (deviation B), borderless light
  rows, no ALL CAPS, zero as `0`.

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke `_QueueRow` chrome (Stack/Container/Icon/Text/Divider code) → shared atoms (icon,
  identity, mono LTR, pill, action, `AppDivider`) with byte-identical behavior; bespoke `_SectionLabel`
  badge chrome → shared badge atom (same counts); bespoke `EmptyState`/`AppSkeleton`/`AppInfoPanel`
  panels → `AppEmptyState` / `AppShimmerSkeleton` (row-mirroring) / `AppErrorState`+Retry (+ stale
  variants where applicable); `SecondaryButton` row Assign → `AppPillButton.secondary` (same label/
  handler); picker confirm `PrimaryButton` → `AppPillButton.primary` (same label/handler).
  Pull-to-refresh kept.
- MOVED: nothing (Assign/Clear/Retry/picker/toast keep seats; rows keep display + action).
- KEPT: scaffold bar + `selectedIndex != 0` guard + compact 4+More + expanded 7-rail (untouched);
  header title/subtitle/refresh action; `AppFilterBar` + priority predicate + counts + clear; sort
  (`queuePriorityRank`, stable); providers/sync/refresh/`buildSupervisorBays`, pill/tone/mono helpers,
  picker sheet + toast contracts, bottom nav, keys. No new routes. No invented items/priorities.
- No new widgets kept back: if an App* atom lacks a behavior the old row had, EXTEND the App* atom
  (additively, with tests) then swap — never keep the legacy row for convenience.

## Fold wireframe (ASCII, 360×800 — header + rail + first breakdown row above fold, second peeking)
```
+----------------------------------+
| Supervisor · Queue       [🔍 bar] |  <- bar icon = bay scope (scaffold; single search path here)
| Incoming queue            [↻]    |  <- AppPageHeader + refresh (1 tap)
| Priority-sorted bookings…        |  <- static subtitle (counts on sections, not header)
| (All) (VIP 1) (Promised 2)(Ins 1)|  <- AppFilterBar rail (existing buckets)
|----------------------------------|
| 🚨 Breakdowns             [1]    |  <- section label + count
| 🚨 Patrol · Overheating    [EMERG]|  <- row 1: icon + identity + pill (above fold)
| GHI 3456                         |
| [Assign advisor               ]  |  <- frequent action ON the card (1 tap from list)
|----------------------------------|  <- fold line (nav below)
| 📅 Bookings               [2]    |  <- second section PEEKING
+----------------------------------+
| Floor | Jobs | Queue | Review |⋯ |
```

## Matrix requirements
- empty (no bookings/breakdowns: one icon + one sentence, NO action — nothing to create) ·
- with-data (breakdown + bookings, priority order VIP → promised → insurance → normal) ·
- filter (rail narrows bookings only; counts update; no-match + Clear when both sections empty) ·
- error (Retry, same handler) + loading (row-mirroring skeleton) + stale/refresh ·
- ar (RTL mirrored; plate/figures LTR-locked) ·
- 1.3x (chips/actions wrap, rows never clip) ·
- 320px (single column; header + rail + first row intact) ·
- tablets (single-column register; rail + rows max-width; table variant N/A by design per U2).

## Copy keys needed
Reuse existing staff keys (`svQueue*`, `filterBarClear`, `commonRetry`, `commonNoResults`,
`commonErrorTitle`) — zero new keys expected (phase-9 list: none). No ALL CAPS strings added.

## Acceptance
- U0–U14 walk (ANY U-law fail caps at 8/16); C16 hard-reject checklist (ANY violation caps at 10/16):
  borderless light rows, one filled accent per row-action group (Assign only), one path per task
  (single search path = bar; rail = filter, different task), no permanent pills, no ALL CAPS, first row
  above fold + next peeking, card hierarchy (title → pill → meta), taps never regress.
- Airbnb rubric ≥ 12/16 to pass.
- Gates: characterization tests on the CURRENT list first, before-images captured, migration table
  (current → shared atoms), reviewer process per redesign mandate, NO logic changes.
- Verify from code: tap counts, `onOpenReview`/sheet route, priority predicate + sort, key names,
  scaffold guard + nav intact.
