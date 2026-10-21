# UX Brief — customer vehicles list / my garage (list family)

## Scope
`apps/customer_app` vehicles list surface: `widgets/customer_vehicles_tab.dart`
(list + header + empty/failure states) + `widgets/customer_vehicle_record.dart`
(one record row/card) + `widgets/customer_scaffold.dart` (tab shell, index 2).
Routes touched only as existing destinations: `AppRoutes.customerAddVehicle`
(`/add-vehicle`), `customerEditVehicle(id)` (`/edit-vehicle/:id`),
`customerBookServiceLocation(vehicleId:)` (`/customer_book_service_view?vehicleId=`),
`customerBookingDetail` (extra), `customerServiceStatus`. No new routes. No
logic changes (providers, sync, predicates, refresh stay as-is).

## User goal
A customer opens My vehicles and in one glance finds the right car (name +
plate), sees what is actually happening with it (real booking-derived context
only — no invented health/due claims), and reaches Book / Edit / Remove without
hunting. One screen, one primary task: find vehicle → act.

## Current behavior (verified from code)
- Entry: `CustomerScaffold` bottom nav, 4 destinations
  (Home, Bookings, Vehicles, Profile); vehicles = `selectTab(2)`, bottom nav on
  every width — deliberately NO rail, NO command palette on consumer surfaces
  (`customer_scaffold.dart` header comment cites 04.1 §3.1 + Airbnb addendum §6).
  App bar = `WorkspaceAppBar` (title `vhTitle`, bell + avatar actions, offline
  pill; `showOfflineBanner: false`). There is currently NO search icon.
- Header (`_Header`): `vhTitle` headline + count subtitle
  (`vhCountNone` / `vhCountOne` / `vhCountMany`) + `TextButton.icon` Add — only
  when the list is non-empty; when empty the Add CTA lives inside `_NoVehicles`
  (`FilledButton.icon`).
- List: `_Grouped` bordered container with dividers; `< 4` records or compact =
  single column; `>= 4` records on wider canvas = 2 columns (3 on large),
  chunked via `_Grouped` per column.
- Record (`CustomerVehicleRecord`): 96px `VehicleSilhouetteArt` band (API has no
  photography) + `CustomerPlateChip` overlay; name (`titleMedium` w800, 2-line
  ellipsis) + specs line (`CustomerVehiclePresentation.specs()`: year · colour ·
  mileage, 1-line ellipsis) + VIN mono LTR line; `_ContextLine` when
  `contextFor()` (plate-matched bookings) yields in-service / upcoming
  (Booked/Requested) / completed (Last service) with View/Track text button;
  `_SyncFailedNotice` / `_DeleteFailedNotice` with inline retry when
  applicable; `_Actions` Wrap (Book w/ calendar icon, Edit, Remove tertiary
  error; Remove withdrawn while delete-recovery is active).
- States: `AppSkeleton` loading; `_NoVehicles` empty; `_LoadFailure` + retry;
  `CustomerRefreshNotice` when `loadError` + stale data; `_UnmatchedDeleteRecovery`
  banner for missing-after-failed-delete; `RefreshIndicator` pull-to-refresh;
  remove = `showAppConfirmationDialog` (destructive) → `customerRemoveVehicle` →
  snackbar.
- Truth rules (from `customer_vehicle_presentation.dart`): blank mileage stays
  unknown (never `0 km`); plate upper-cased single-spaced, never padded;
  health/lastService/nextDue never presented as facts; context derived only from
  plate-matched bookings + live service.

## Top tasks with tap counts (BEFORE = current UI, AFTER must be ≤)
1. Open the vehicles list — before: bottom-nav Vehicles tab = **1 tap**
   (0 if deep-linked via `selectDestination`). After: ≤ 1 tap.
2. Book service for a vehicle — before: tab (1) + record Book action (1) =
   **2 taps** (+ scroll to the record). After: ≤ 2 taps, ≤ same scroll.
3. Add a vehicle — before: tab (1) + header/empty-state Add (1) = **2 taps**,
   then the existing 3-step wizard (unchanged). After: ≤ 2 taps to wizard.
4. Edit a vehicle — before: tab (1) + record Edit (1) = **2 taps** (+ scroll).
   After: ≤ 2 taps.
5. Remove a vehicle — before: tab (1) + Remove (1) + confirm dialog (1 confirm)
   = **2 taps + 1 confirm**. After: ≤ 2 taps + 1 confirm (dialog stays).
6. Open the booking / track service behind a context line — before: tab (1) +
   View/Track (1) = **2 taps**. After: ≤ 2 taps.
7. Retry a failed sync / failed removal — before: inline Retry = **1 tap** from
   the record/banner. After: ≤ 1 tap, control stays inline.

| Task | Before | After budget |
|---|---|---|
| Open list | 1 tap | ≤ 1 tap |
| Book service for vehicle | 2 taps (+scroll) | ≤ 2 taps, ≤ same scroll |
| Add vehicle (reach wizard) | 2 taps | ≤ 2 taps |
| Edit vehicle | 2 taps (+scroll) | ≤ 2 taps, ≤ same scroll |
| Remove vehicle | 2 taps + 1 confirm | ≤ 2 taps + 1 confirm |
| Open booking / track service | 2 taps | ≤ 2 taps |
| Retry sync / removal | 1 tap inline | ≤ 1 tap inline |

Frequent tasks (find vehicle, book service) stay single-screen; the add/edit
wizard is the only multi-step flow and is out of scope for restructuring.

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: **does not exist** (confirmed — no `references`
  dir under `docs/ui-redesign/`; glob returns nothing).
- `AIRBNB_PATTERNS.md`: **missing anywhere in the repo** (confirmed — repo-wide
  glob `**/AIRBNB_PATTERNS*` returns nothing; the only mention is
  `docs/ui-redesign/evaluation/technician-home-test-migration.md:183`, which
  itself records that the file/dir does not exist).
- Mapping into `AIRBNB_PATTERNS.md` is therefore **unmet**; this brief proceeds
  from phase-5 / phase-7 precedent patterns (supervisor-home, technician-home,
  owner-home briefs): `AppPageHeader` + header search icon (U1) opening a
  full-screen search sheet over list items with no new routes/logic;
  `AppListGroup` rows; filter sheet keeping existing predicates; `AppBanner` for
  blockers; borderless light cards; no ALL CAPS added; zero shown as `0`.
- **Tension flagged for build:** the customer scaffold explicitly forbids the
  enterprise command palette on consumer surfaces. The search pattern here MUST
  be the list-scoped variant: a full-screen search sheet that filters the
  already-loaded vehicle records in place (name / plate / specs), NOT a
  destination palette. If even that is judged to violate the consumer-chrome
  rule at build time, that is STOP-grade — report back, do not invent an
  alternative.

## U-laws application (U0–U14, C17)
- U0 (one read): one record = identity (name + plate chip) → specs → real
  service context → actions. No competing heroes on a list screen.
- U1 (find fast): header search icon top-right opens the full-screen search
  sheet over list items (client-side filter of loaded records; no new
  routes/logic). Result tap scrolls to / highlights the record; actions stay
  the record's own buttons (no new destinations).
- U2 (fit the content): vehicle records are heterogeneous (art band + specs +
  context + 3 actions) — grouped rows/cards, NOT a data table. No table on any
  width (table matrix cell = N/A by design, recorded here).
- U3 (no fake actions): only real states — context lines only when `contextFor`
  yields one; Book/Edit/Remove/Retry map 1:1 to existing handlers; no health
  pills, no favorite hearts, no photo affordances.
- U4 (no invention): plates/specs/VIN verbatim via existing helpers; unknown
  mileage stays unknown; zero shown as `0`, never `-`; counts from
  `vehicles.length` only.
- U5 (reachable + legible): 48dp targets on all actions; actions Wrap (never
  clip) at 320px / 1.3x; VIN stays LTR-locked; mixed word/number specs follow
  ambient direction (existing contract).
- U6 (states): skeleton mirrors layout (`AppShimmerSkeleton`); honest empty
  (`AppEmptyState` + Add); error (`AppErrorState` + Try again); stale data kept
  with `CustomerRefreshNotice`/`AppBanner`; delete-recovery banner preserved.
- U7 (feedback): remove confirm dialog stays destructive; snackbars for
  removed/failed stay; busy states disable only the acting record's controls.
- U8 (no dead ends): every context line with a behind-booking offers View/Track;
  badge-only otherwise (no dead affordance); empty state always offers Add.
- U9 (consistency): `AppPageHeader`, `AppListGroup` rows, filter sheet, `AppBanner`
  — same atoms as phase-5/phase-7.
- U10 (RTL): full mirror; plate/VIN/figures/digits LTR-locked; `PositionedDirectional`
  already used — keep.
- U11 (a11y): record `Semantics` label (name + plate + specs + context) kept;
  live-region on delete-failure kept; header `Semantics(header: true)` kept.
- U12 (density): 1-col compact; 2-col at ≥ 4 records on medium, 3-col large
  (existing chunking predicate kept, rebuilt on shared atoms).
- U13 (offline): bar pill owns offline state (banner off, per shell contract);
  stale list kept + refresh notice; retries inline.
- U14 (no regression): tap budgets above are ceilings; pull-to-refresh,
  haptics, keys (`vehicle-<id>`), dialog contracts unchanged.
- C17: any U-law fail caps at 8/16. C16 list adaptations: search-sheet,
  borderless light cards, no ALL CAPS added (context labels render sentence
  case — note current code upper-cases context labels: `label.toUpperCase()` in
  record + carousel badge — the redesign removes the `.toUpperCase()` calls,
  styling emphasis via theme instead), zero as `0`.

## Search-icon pattern (list-scoped, no new routes/logic)
- `AppPageHeader` (title `vhTitle` + count subtitle) with search icon top-right
  (U1, same placement as staff briefs).
- Icon opens a full-screen search sheet over the list items: text field filters
  the loaded `vehicles` by display name / plate label / specs substring;
  results render as the same record rows (tapping a result closes the sheet and
  reveals the record; record actions unchanged).
- Empty query = full list; no-match = filter-no-match state with Clear control.
- No new routes, no server queries, no invented entries. Sheet respects RTL +
  1.3x (field + list scroll, no clipping).

## Filter sheet design (predicates owned by existing logic)
- Filter entry: funnel icon beside search (header) — opens bottom sheet with the
  only honest facets the data supports: service context (All / In the workshop
  now / Booked or requested / Last service / No active context), derived via the
  existing `contextFor()` per vehicle. NO make/model/year/color facets (no
  honest backing predicate — inventing them would be fake filtering).
- Sheet: single-select chip group + Show results CTA + Clear; selection filters
  the rendered record list in place; count subtitle updates verbatim
  (`vhCountMany(filtered)`); no-match = filter-no-match state with Clear.
- Logic boundary: sheet owns presentation only; context derivation stays in
  `CustomerVehiclePresentation.contextFor` — unchanged.

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke `_Header` chrome → `AppPageHeader` (title + count subtitle) +
  search icon + filter icon top-right; Add stays a header action when non-empty
  (same `customerAddVehicle` push) and the empty-state primary CTA when empty.
- REMOVED: bespoke `_Grouped` bordered container + divider code → `AppListGroup`
  of record rows (single column compact / < 4; 2-col medium, 3-col large at
  ≥ 4 — same chunking predicate, rebuilt on shared atoms).
- REMOVED: bespoke record chrome (silhouette `Stack`, `_ContextLine` container,
  `_Actions` Wrap, `_SyncFailedNotice`, `_DeleteFailedNotice` styling) → shared
  atoms (media row, context line, action row, inline notices) with byte-identical
  behavior; `.toUpperCase()` on context labels removed (sentence case via theme).
- REMOVED: bespoke `_NoVehicles` / `_LoadFailure` panels → `AppEmptyState`
  (icon + `vhEmptyTitle`/`vhEmptyBody` + Add) / `AppErrorState` + Try again
  (same retry handler); bespoke skeleton → layout-mirroring `AppShimmerSkeleton`;
  refresh + unmatched-delete states → `AppBanner` variants (same retry handlers).
- MOVED: context View/Track, Edit, Remove (with confirm dialog), sync/removal
  retries — same routes/handlers, new clothes only.
- KEPT: all providers/sync/refresh/selectTab, `specs()`/`plateLabel()`/
  `mileageLabel()` verbatim rules, VIN LTR lock, bottom nav (no rail — consumer
  contract), pull-to-refresh, haptics, `ValueKey('vehicle-<id>')`, dialog +
  snackbar contracts, `selectDestination` deep-linking.
- No new routes. No invented vehicles/statuses/specs. Zero as `0`, never `-`.
  Customer app keeps dark-mode wiring (no regression).

## Fold wireframe (ASCII, 360×800 — header + search/filter + first record above fold)
```
+----------------------------------+
| My vehicles            [🔍][⧩][+]|
| 3 vehicles                       |
|----------------------------------|
| [ silhouette band      [ABC 123] ]|
| Toyota Camry                     |
| 2021 · White · 48,200 km         |
| VIN 1HGCM8...                    |
| ⓘ Booked · Oil change · Sat 10:30|
|            [View]                |
| [Book] [Edit] [Remove]           |
|----------------------------------| <- above fold (nav below)
| [ silhouette band      [XYZ 789] ]|
+----------------------------------+
| Home | Bookings | Vehicles | Prof |
```

## Matrix requirements
- empty (no vehicles: `AppEmptyState` + Add → same wizard; never zero-filled) ·
- with-data (1 record single column; ≥ 4 records multi-column on wider canvas;
  context + sync/delete-failure notices inline) ·
- search (icon → full-screen sheet over loaded records; result reveals record;
  no-match + Clear; no new routes) ·
- filter (context-facet sheet; count updates; no-match + Clear) ·
- ar (RTL mirrored; plate/VIN/figures/digits LTR-locked) ·
- 1.3x (actions wrap, specs ellipsis, sheet scrolls — never clips) ·
- 320px (single column; header + first record intact; actions stack) ·
- tablets (medium 2-col, expanded 3-col, max-width 1040; bottom nav stays, no
  rail — consumer contract; table variant N/A by design per U2).

## Copy keys needed
Reuse existing customer `vh*` keys (`vhTitle`, `vhCount*`, `vhAdd`, `vhEmpty*`,
`vhLoadFail*`, `vhBook/Edit/Remove/Retry/*`, `vhTrack/View`, `vhSyncFail`,
`vhDeleteFail*`) + `garNavVehicles`; new keys only for search-sheet
hint/no-match + filter-sheet labels + filter-no-match (en+ar, listed for
phase 9). No ALL CAPS strings added.

## Acceptance
- U0–U14 walk (ANY U-law fail caps at 8/16, no exceptions); C16 hard-reject
  checklist for lists (caps 10/16): search-sheet over items, `AppListGroup`
  rows, filter sheet on honest predicates, borderless light cards, no ALL CAPS
  added, zero as `0`, above-fold first record, no dead affordances, no fake
  facets/statuses, no new routes, taps never regress (table above).
- Airbnb rubric ≥ 12/16 to pass.
- Verify from code: tap counts, route names, `contextFor` predicate, verbatim
  helpers, key names, scaffold no-rail/no-palette consumer constraint.
