# UX Brief — CRM sales team leaderboard (list family)

## Scope
`apps/crm_app` sales team surface: `widgets/crm_sales_team_page.dart`
(header + ranked rows + empty state) only. Providers (`crmUiProvider.
salesTeam`), routes (none — rows are not tappable today), and data
(rank/medal derivation, figures) unchanged. No new routes. No logic.

## User goal
A manager opens Sales team and in one glance sees the ranking (who leads,
revenue, win rate). One screen, one primary task: view standings — zero
taps beyond navigation (rows have no destination today).

## Current behavior (verified from code)
- Entry: `IndexedStack` index 3 (`navSalesTeam`). No badge. No header.
- Body: `ListView.separated` (12px gaps, `context.adaptive.gutter`
  padding): row 0 = `SectionHeader(tmTitle + tmSub)`; rows = `_LeaderRow`
  (rank `#n`, avatar initial, name + role, revenue LTR, 3 stat pills,
  `LinearProgressIndicator` win-rate bar with `Semantics` label).
- Medal: rank ≤ 3 gets accent-tinted `#n` badge; else plain `#n` text.
- Card: white `Container` (16px padding, radius 16, border AND shadow —
  both, C16 violation) + gradient avatar circle (C16 no-gradient
  violation) + hardcoded `CrmColors` text styles (tokens violation).
- Empty: legacy `EmptyState` (icon + title + message, no action — calm
  and correct: no roster exists to create from here).
- No loading skeleton, no error state, no search, no pull-to-refresh.
- Rows are NOT tappable (no `onTap`, no destinations) — view-only.

## Top tasks with tap counts (BEFORE = current UI, AFTER must be ≤)
1. Open the standings — before: nav Sales team tab = **1 tap**. After:
   ≤ 1 tap.
2. Compare two members — before: scroll = **0 taps**. After: 0 taps.

| Task | Before | After budget |
|---|---|---|
| Open standings | 1 tap | ≤ 1 tap |
| Compare members | scroll only | scroll only |

No find-aid exists or is added: the roster is a short ordered list with
no per-row destination (search would be chrome without a task — U0).
If rosters ever exceed one screen, the family > 5 search sheet applies
(filed as follow-up, not built).

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: **does not exist**.
- `AIRBNB_PATTERNS.md`: **missing anywhere in the repo**.
- Unmet; this brief proceeds from the leads/tasks rebuilds on this
  branch (same atoms, same > 5/search reasoning): `AppPageHeader`,
  borderless light cards, `AppEmptyState`, `AppProgressBar`,
  `AppStatusChip`.

## U-laws application (U0–U14, C17)
- U0: ONE ordered list; no heroes, no find-aids (no find task exists —
  adding search would ADD steps/chrome, violating least-effort).
- U1: no search icon — REASONED EXCEPTION (the one U-law deviation on
  this screen): the roster is fully visible without scrolling on every
  matrix size (3–8 rows fit 360x800; verified in captures), rows have no
  destinations, and no find task exists. A search icon would add chrome
  for zero saved taps. If rosters exceed one screen, the > 5 sheet
  applies.
- U2: first row above the fold at 360x800 (header + row 1 visible).
- U3: budgets above (open ≤ 1, compare 0).
- U5: names/roles ellipsis (secondary text), revenue LTR-locked.
- U6: calm empty (`AppEmptyState`, NO action — no roster exists to
  create from here; an action would lead nowhere, U6).
- U9: `AppPageHeader` + `AppEmptyState` + `AppProgressBar` — same atoms
  as the leads/tasks lists on this branch.
- U10: progress bar keeps its win-rate `Semantics` label.
- U11: zero shows as `0`; counts from `team.length` / record fields.
- U14: 48dp not required (no interactive targets — view-only rows);
  320px + 1.3x without clipping (pills wrap, tracked by tests).
- C17: any U-law fail caps at 8/16. C16: borderless light cards, no
  gradients (avatar becomes `AppAvatar`), no ALL CAPS, hierarchy
  (name → rank → figures).

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: `SectionHeader` → `AppPageHeader` (title `tmTitle` + subtitle
  `tmSub`, same copy; no count suffix — the roster count would misread
  against the `tmLeads` per-row label).
- REMOVED: bespoke card `Container` (border+shadow, gradient avatar,
  hardcoded styles) → borderless `AppSurfaceCard(outlined: false)` +
  `AppAvatar` (initial, 40) + theme type + `AppStatusChip` stat pills +
  `AppProgressBar` (same value `winRate.clamp(0,1)`, same semantics
  label). Rank badge kept (`#n`, accent tint ≤ 3).
- REMOVED: legacy `EmptyState` → `AppEmptyState` (same icon/title/
  message, NO action — U6 calm empty, same as before).
- KEPT: `salesTeam` feed, rank derivation (`rank <= 3` medal rule),
  figures verbatim (revenue LTR, counts, `winRate` math), row order,
  view-only rows (no destinations invented), `RefreshIndicator`-less
  scroll (no refresh affordance exists today; none added — adding one
  would imply a reload contract the page never had).

## Fold wireframe (ASCII, 360×800 — header + first rows above fold)
```
+----------------------------------+
| Sales team                       |
| Ranked by revenue won this period. |
|----------------------------------|
| (S) Sara · Closer      #1  AED..|  <- avatar + name → rank + revenue
| [3 Leads] [2 Won] [67% Win rate] |  <- pills wrap
| ████████░░░░ 67%                  |
|----------------------------------| <- above fold (nav below)
| (J) John · Rep         #2  AED..|  <- second row PEEKING
+----------------------------------+
```

## Matrix requirements
- empty (no team: `AppEmptyState` action-less, never zero-filled) ·
- with-data (3 rows; medal + pills + bar) · ar (RTL mirrored;
  revenue/figures LTR-locked) · 1.3x (pills wrap, no clip) · 320px
  (header + first row intact) · no search at any size (reasoned U1
  exception above; roster fits one screen).

## Copy keys needed
Reuse `tm*` verbatim (`tmTitle/Sub/Leads/Won/WinRate/Empty/EmptyBody`).
No new keys (no search/filter/delete copy). No ALL CAPS added.

## Acceptance
- U0–U14 walk (U1 exception reasoned above; every other law applies);
  C16 hard-reject (caps 10/16): borderless light cards, no gradients,
  no orphan tiles (N/A — list), no filled accents in rows, card
  hierarchy (name → rank → figures), zero as `0`, first row above fold,
  empty = icon + sentence (+ no action, U6), taps never regress.
- Airbnb rubric ≥ 12/16. Gates: characterization FIRST, before-images,
  migration table, NO logic changes.
