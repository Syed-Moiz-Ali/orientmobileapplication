# UX Brief — technician home / today execution (dashboard family; build without waiting)

## User goal
A technician opens the app and in one glance knows: what to work on right now, how far along it is,
and how to start/complete/request/escalate. One screen, one primary action.

## Single primary action
The current task's next step (Start / Complete). Everything else is navigation or secondary.

## Top 3 tasks with tap counts (BEFORE = current UI, AFTER must be ≤)
1. Start or complete the current task — before: Today tab shows task card with action (verify from code).
2. Request a part — before: parts action → request sheet (verify from code).
3. Escalate / report a blocker — before: escalate action → sheet (verify from code).

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke header/banner chrome → `AppPageHeader` (shift/day title + attendance state) +
  search icon top-right (U1 — same placement as advisor/customer/supervisor; opens existing search or
  full-screen search over technician jobs — no new routes/logic; if no honest target, report STOP-grade).
- REMOVED: bespoke execution column / queue column / shift strip / task focus card / blocker notice /
  quick actions / slim metrics chrome → hero `AppMediaCard` (current work: vehicle + task + progress +
  ONE primary Start/Complete CTA), `AppListGroup` for queue (up-next rows, no cards-in-cards),
  `AppStepScaffold`-free task focus (progress bar + step list, NOT a flow), blocker → `AppBanner`,
  quick actions → horizontal 72px tile row or 3 equal columns (U5-safe), summary strip removed
  (derivable; zero shown as 0 only if kept — prefer removal).
- REMOVED: bespoke skeleton → layout-mirroring `AppShimmerSkeleton`; bespoke error/empty →
  `AppErrorState`/`AppEmptyState`; connection notice → `AppBanner` + stale data.
- MOVED: secondary actions (history, productivity, profile) stay in tabs; destructive confirmations
  stay dialogs.
- KEPT: all providers/routes/sync/task state machine (start/pause/complete/resume), progress math,
  filter predicates, bottom nav + rail, pull-to-refresh, haptics, keys.
- No new routes. No invented tasks/statuses/times. Zero shown as 0, never "-".

## Flow / sections (C16 dashboard adapted: execution, not feed)
Greeting header (+ shift/attendance) → hero current-work card (ONE primary CTA) → quick-action tile
row → "Up next" list group with Show all → task steps (progress + list) → bottom nav. Pull-to-refresh.

## ASCII wireframe at 360x800 (first task visible above the nav)
```
+----------------------------------+
| Today              [🔍][🔔][av]  |
| Morning shift · Clocked in       |
|                                  |
| [ Camry · Oil change    2/5   ]  |
| [ ██████░░░░  [Complete]  >  ]  |
|                                  |
| [▶ Start][🧩 Parts][⚠ Escalate] |
|                                  |
| Up next                Show all  |
| ○ Brake pads · Yaris · 10:30   > |
| ○ Tire rotation · Hilux · 11:15> | <-above fold
+----------------------------------+
Jobs | Productivity | Profile (nav)
```

## States
loading (mirroring skeleton), empty (no active work: icon + sentence + action), error + Try again,
offline banner + stale board, staff light-only, RTL ar (+LTR codes/refs), 320px + 1.3x, tablet 2-col.

## Copy keys needed
Reuse existing staff tech* keys; new keys only for hero sentence + empty states (en+ar, listed for
phase 9).
