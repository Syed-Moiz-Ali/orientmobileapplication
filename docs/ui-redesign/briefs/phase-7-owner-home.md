# UX Brief — owner home / executive cockpit (dashboard family; build without waiting)

## User goal
An owner opens the app and in one glance knows: how the business is doing today
(revenue + deltas), what needs attention (approvals WIP, receivables, floor),
and how to drill into any area. One screen, one primary read, no fake actions.

## Single primary read
Today's revenue hero (glance, zero taps). Everything else is drill-down navigation.
Approvals triage is READ-ONLY — no approve/reject endpoint exists anywhere in the
owner app (see `pending_approvals_view.dart` header comment); Approve/Reject
buttons would be fake actions (instant FAIL). The queue stays a triage surface.

## Top 3 tasks with tap counts (BEFORE = current UI, AFTER must be ≤)
1. Glance today's business status (revenue hero + KPI micro-pods + live pills) —
   before: 0 taps, visible at launch (hero above fold, `owner_dashboard_page.dart`
   `_RevenueHero` + `_MicroPods` + `_CockpitHeader` pills; verify from code).
2. Drill into the job register (category rows → job-cards list) — before: register
   row tap → `context.push(AppRoutes.jobCards)` (1 tap; compact adds scroll past
   the swipeable charts; section "View all" → same route; verify from code).
3. Triage pending approvals (read-only queue) — before: quick-action tile →
   `context.push(AppRoutes.pendingApprovals)` (1 tap + scroll to the 12-row
   actions section on compact; command-palette search path = 2 taps:
   search icon → destination; verify from code).

| Task | Before | After budget |
|---|---|---|
| Glance status (hero + pods) | 0 taps | 0 taps (hero + first pods above fold) |
| Open job register → job cards | 1 tap (+scroll compact) | ≤ 1 tap, ≤ same scroll |
| Triage pending approvals | 1 tap + scroll (tile) / 2 taps (search) | ≤ 1 tap + scroll / ≤ 2 taps |

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke cockpit header chrome (analytics-icon trailing + status pills
  stay as content, rebuilt on shared atoms) → `AppPageHeader` (ops title +
  branch subtitle) + search icon top-right (U1 — same placement as
  technician/supervisor/customer/advisor; opens the existing command palette
  over real destinations — no new routes/logic; if no honest target, STOP-grade).
- REMOVED: bespoke hero/micro-pod chrome (`TelemetryMetricPod` wrappers) →
  hero `AppMediaCard` or `AppKpiCard`-hero (revenue KPI + verbatim delta line,
  ONE card, no competing KPIs above the fold); micro-pods → 2-col `AppStatTile`
  / `AppKpiCard` grid (margin, occupancy, approvals WIP — shown only when the
  matching KPI actually exists; missing family omitted, never zero-filled).
- REMOVED: bespoke curve-card chrome + swipeable chart pages on compact →
  `AppChartCard` w/ timeframe pills (sales/profit, profit/expenses; empty series
  render the chart placeholder, never blank; charts get text summaries).
- REMOVED: bespoke job-register table/record-row duality → `AppTable` on
  expanded + `AppListGroup` of `AppRecordRow` on compact with Show-all
  (`ownerRegisterAll` → same `jobCards` route); bespoke quick-action record
  rows → horizontal 72px tile row or 3 equal columns (U5-safe) for the top
  3–4 frequent destinations + `AppListGroup` Show-all for the remaining 12.
- REMOVED: bespoke skeleton (`AppSkeleton.page`) → layout-mirroring
  `AppShimmerSkeleton`; bespoke error (`ErrorView`) → `AppErrorState` +
  Try again; connection pill owns offline state (no duplicated full-width
  banner) + stale data kept; blockers (approvals WIP, overdue AR) → `AppBanner`.
- MOVED: secondary destinations (team, subscription, attendance, moderation,
  expiry, top-sales/messages/activity tabs) stay in tabs/routes; destructive
  confirmations stay dialogs.
- KEPT: all providers/sync/refresh/period logic, `_findKpi`/`_trendOf`
  verbatim-value rules (figures render verbatim; LTR lock on `AED 84K`-style
  values inside RTL), filter predicates, bottom nav + rail, pull-to-refresh,
  haptics, keys.
- No new routes. No invented KPIs/statuses/times. Zero shown as 0, never "-".
  Light-only (owner currently light-only, same convention as staff briefs).

## Flow / sections (C16 dashboard adapted: executive glance, not feed)
Greeting header (+ branch/live pills) → hero revenue card (ONE number + delta)
→ KPI micro-pod grid (≤3) → blockers banner (only when approvals/AR need
attention) → charts (AppChartCard) → job register list group with Show-all →
quick-action tiles + Show-all → bottom nav (rail on expanded). Pull-to-refresh.
Cap: hero + first pod row + banner (if any) above the fold; frequent tasks
stay single-screen, step flows only for one-time/complex tasks (none on home).

## ASCII wireframe at 360x800 (hero + first pods visible above the nav)
```
+----------------------------------+
| Operations           [🔍][🔔][av]|
| Main branch · Live · 12 active   |
|                                  |
| [ Revenue  AED 84K   +2.1% ▲   ] |
|                                  |
| [Margin +1.2%][Bays 12/16     ]  |
|                                  |
| ⚠ 3 approvals waiting      View >| <-above fold (when blockers exist)
+----------------------------------+
Sales/profit chart | Register | ...
+----------------------------------+
Dashboard|Top sales|Messages|Activity
```

## States
loading (mirroring skeleton), empty (no KPIs: hero empty state, never a zero;
empty register; empty approvals with read-only note), error + Try again,
offline pill + stale data (no duplicated banner), light-only, RTL ar
(LTR-locked codes/refs/figures/digits), 320px + 1.3x (legend wraps, tiles
stack single-column — never clip), tablet 2-col (charts + register side by
side, actions rail).

## Matrix requirements
empty (no KPIs / empty register / zero approvals — honest empty states, no
zero-filled families) · with-data (hero + 3 pods + charts + register rows +
actions) · search (icon top-right → full-screen command palette over real
destinations; result tap = same push/selectTab contract) · ar (RTL mirrored,
codes/refs/figures/digits LTR-locked) · 1.3x (no clipping, tiles stack,
legend wraps) · 320px (single column, hero + pods intact, first register
row peeking) · tablets (medium 2-col split, expanded 3-col panoramic max-width,
rail replaces bottom nav).

## Copy keys needed
Reuse existing owner `owner*` keys; new keys only for hero sentence + blocker
banner + empty states (en+ar, listed for phase 9).

## Acceptance
U0–U14 walk (ANY U-law fail caps at 8/16, no exceptions); C16 hard-reject
checklist (caps 10/16): borderless-light-cards, ONE-read-per-screen, no
duplicate filled CTAs, above-the-fold hero, no orphan tiles, search-sheet,
card-hierarchy (figure → delta → drill-down), no ALL CAPS added, zero as 0.
Airbnb rubric ≥ 12/16 to pass.
