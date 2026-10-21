# UX Brief — customer dashboard home (first screen of the dashboard family; STOPPED for go)

## User goal
A vehicle owner opens the app and in one glance knows: which car needs attention, what is happening
with it right now, and how to book the next service. One screen, one primary action, no dense grids.

## Single primary action
Book service (the single CTA emphasis; everything else is navigation or secondary).

## What is REMOVED or moved (structural, not a restyle)
- REMOVED: bespoke `SectionHeader` + raw carousel scaffolding → `AppPageHeader` (greeting headline) +
  `AppCarousel` (~2.2 peek, "Show all" → vehicles tab).
- REMOVED: `_RecentActivitySection` boxed card-with-dividers → `AppListGroup` (icon rows, inset hairline
  dividers, no card borders, no nesting).
- REMOVED: bespoke skeleton column → skeleton mirroring the final C16 layout with `AppShimmerSkeleton`
  primitives (hero + carousel + list rows).
- MOVED: secondary actions (manage garage, view-all bookings, invoice review) stay as section headers
  with "Show all" (C16 wants them); destructive/overflow actions (none on home) need no sheet.
- MOVED: `CustomerAttentionPanel` (approvals + unpaid invoices) → hero-position `AppBanner`/`AppMediaCard`
  with ONE status (plain-language chip + one sentence) + single action; full adjudication stays in approvals.
- KEPT: bottom tab bar (≤5), pull-to-refresh, `AppSplitView` two-column on medium/expanded, all providers,
  routes, booking/approval/invoice logic, copy keys (new keys only where C16 copy requires them).

## Flow / sections (C16 dashboard: hero + carousels + a few sections)
1. `AppPageHeader`: "Good evening, {name}" + one supporting line (cars needing attention count).
2. Hero: ONE `AppMediaCard` — the key status (active service OR next due OR new-customer welcome) with
   status pill + one plain sentence + single CTA (Track / Book service).
3. Attention (only if approvals/unpaid exist): banner card → approvals.
4. "Your garage": `AppCarousel` of vehicle cards (silhouette art + booking-derived context line, no health
   scores/favorites/promotions — no provenance), "Show all" → vehicles tab.
5. Quick actions: ONE horizontal row of 3–4 icon tiles (72px): Book service, Breakdown help, Invoices, History.
6. "Recent activity": `AppListGroup` (max 2–3 rows) → bookings tab.
No widget grids, no cards-in-cards, max 5 sections above the fold; rest behind "See all".

## Airbnb pattern used
Dashboard (C16): greeting → hero summary → quick-action tile row → garage carousel → recent-activity
list group; large titles, minimal chrome, bottom tab bar.

## ASCII wireframe (360px)
```
+----------------------------------+
| Good evening, Layla              |
| 2 cars · 1 needs attention       |
|                                  |
| [ HERO: Camry service in       ] |
| [ progress · Track service >   ] |
|                                  |
| Your garage            Show all  |
| [car][car][peek..]  (carousel)   |
|                                  |
| [Book][SOS][Bills][History]      |
|                                  |
| Recent activity        Show all  |
|  ○ Oil change · Camry · Tue      |
|  ○ Brake pads · Yaris · 12 May   |
+----------------------------------+
Bottom tab bar (Home Bookings Vehicles Approvals Profile)
```

## States
loading (layout-mirroring skeleton), new-customer empty (one icon + one sentence + "Add your vehicle"),
load error (friendly + Try again), partial/offline (`AppBanner` + keep last data, pull-to-refresh),
dark (customer dark must not regress), RTL ar, 320px + 1.3x, tablet two-column.

## Copy keys needed
Reuse existing customer ARB keys (`garTitleOne/Many`, `garManage`, `garRecentTitle/All`, ...); new keys
only for the hero sentence + empty-state line if no key fits (en+ar, listed for phase 9).
