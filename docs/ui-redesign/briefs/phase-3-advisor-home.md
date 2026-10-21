# UX Brief — staff advisor home (dashboard family, build without waiting)

## User goal
An advisor opens the app and in one glance knows: what's urgent right now, what to do next, and how
to start it. One task per screen; assigned work first, never a dense console.

## Single primary action
Start the next work: New job card (emphasized). Secondary: Scan, Approvals, Search.

## What is REMOVED or moved (structural, presentation only)
- REMOVED: bespoke `_GreetingHeader` row + `SliverAppBar` search hero → `AppPageHeader` (greeting
  headline + shift/branch line + offline pill) + `AppSearchPill`-style pinned search with recents
  (keep Ctrl+K shortcut + scan CTA; same query state, same routes).
- REMOVED: `_ActionStrip` 2x2 grid → ONE horizontal row of 3 tiles (Scan, New job, Approvals with
  badge) per C16 (note: a 2026-10-15 comment records an owner preference for the 2x2 grid — C16
  mandate supersedes it; flagged here for veto. New job is the emphasized primary).
- REMOVED: `_AssignedSection` divider rows → large `AppMediaCard` rows (job id, customer, vehicle +
  plate, ONE status chip + one-line status sentence, chevron) with Show all → Jobs tab; urgent-first
  sort UNCHANGED (logic).
- REMOVED: `_SummaryStrip` slim metrics → ONE hero `AppMediaCard` (key number: inspections due today
  + delta sentence + "View jobs" action). Other metrics move behind "See all"/Reports tab.
- REMOVED: bespoke `_DesktopPreview` side panel on expanded → keep the two-column split (list +
  detail preview is the C16 expanded pattern) rebuilt with App* cards; same selection state.
- KEPT: bottom nav (Today/Jobs/Reports) + NavigationRail on expanded, all sheets (profile,
  notifications, search, approval), logout destructive dialog, offline pill + shortcuts, pull-to-refresh,
  bell badge, avatar, haptics, all providers/routes/sync logic/keys.

## Flow / sections (C16 dashboard)
Greeting header → hero summary card → 3-tile quick-action row → pinned search (recents) →
"Assigned to you" carousel-or-cards with Show all → summary behind See all. No widget grids.

## ASCII wireframe (360px)
```
+----------------------------------+
| Tue 20 Oct            [synced][🔔][av]
| Good morning, Omar               |
| Branch A · Morning shift         |
|                                  |
| [ HERO: 6 inspections due today] |
| [ You're 2 ahead · View jobs > ] |
|                                  |
| [Scan][+ New job][Approvals (3)] |
|                                  |
| [ 🔍 Search jobs, plates…    ]   |
|                                  |
| Assigned to you        Show all  |
| [JC-1042 · Ahmed · Camry ·      ] |
| [ URGENT parts waiting    >     ] |
| [JC-1041 · Layla · Yaris ·      ] |
| [ In progress             >     ] |
+----------------------------------+
Today | Jobs | Reports (bottom nav)
```

## States
loading (layout-mirroring skeleton), empty (no assigned jobs: icon + sentence + "New job card"),
error + Try again, offline banner + last data, pull-to-refresh, tablet 2-col, staff light-only, RTL ar,
320px + 1.3x.

## Copy keys needed
Reuse existing staff keys (`advisorGreeting`, `advisorAction*`, search hints, status labels); new keys
only for the hero sentence + empty state (en+ar, listed for phase 9).
