# UX Brief — supervisor home / floor board (dashboard family; build without waiting)

## User goal
A supervisor opens the app and in one glance knows: how busy the floor is, which bays need
attention (parts delay / QC / idle), and how to dispatch the next job. One screen, one primary action.

## Single primary action
Dispatch into a bay (tap bay → assign sheet). Everything else is navigation.

## Top 3 tasks with tap counts (BEFORE = current UI, AFTER must be ≤)
1. Dispatch a job into a bay — before: tap bay → assign sheet opens (1 tap, 0 scroll — verify from code).
2. Check what's waiting (queue) — before: Queue tab (1 tap). After: same or rail action (≤1).
3. Review a finished job (QC) — before: Review tab (1 tap). After: same or rail action (≤1).

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke masthead/board/rail/skeleton chrome → `AppPageHeader` (floor title + occupancy
  sentence), search icon top-right (U1 — verify current placement; same pattern as advisor/customer),
  bay grid rebuilt with pattern tiles (state dot + bay id + tech initials + job meta), rail rebuilt with
  App* cards.
- REMOVED: bespoke skeleton → layout-mirroring `AppShimmerSkeleton` (masthead + grid + rail).
- REMOVED: `AppInfoPanel` error → `AppErrorState` + Try again; offline → `AppBanner` + keep last data.
- MOVED: bay-state filter into a filter row / sheet (keep the same `SupervisorBayState` predicate —
  logic-owned); breakdowns/bookings rail actions keep their routes (queue/review/dispatch sheet).
- KEPT: 16-bay spatial map (the map IS the content — C16 collections rule bends to U2/U5: a 4-col grid
  of small tiles with full-word/short labels is the fitting layout; carousel would hide bays), urgent
  states (parts delay / QC) sorted or badged first, all providers/routes/sync/selection logic, keys.
- No new routes. Bay tap → same assign sheet. No invented statuses, no fake bays.

## Flow / sections (C16 dashboard adapted: status board, not feed)
Greeting header (+ floor status) → hero occupancy card (X/Y bays active + ONE "Dispatch" CTA opening
the assign sheet) → filter row → 16-bay grid (state dot + id + tech + job) → rail (queue / review /
breakdowns) → bottom nav (7 items; rail on expanded). Pull-to-refresh.

## ASCII wireframe at 360x800 (first bay row visible above the nav)
```
+----------------------------------+
| Floor status      [🔍][🔔][av]  |
| Good morning, Supervisor         |
| 12 of 16 bays active             |
|                                  |
| [ 12/16 bays active    Dispatch>]|
|                                  |
| [All][Busy][Parts][QC][Idle]     |
|                                  |
| [B1 ●][B2 ●][B3 ●][B4 ○]        |
| [B5 ●][B6 ●][B7 ●][B8 ○]  <-above|
+----------------------------------+ fold (bottom nav below)
| [Queue (3)] [Review (2)]         |
+----------------------------------+
```

## States
loading (mirroring skeleton), empty floor (icon + sentence + action), error + Try again,
offline banner + stale board, filter-no-match (clear filter), staff light-only, RTL ar, 320px + 1.3x,
tablet 2-col (board + rail side by side).

## Copy keys needed
Reuse existing staff sv* keys (svFloorTitle/Subtitle, svBay*, svQueue*, svReview*); new keys only
for hero sentence + empty states (en+ar, listed for phase 9).
