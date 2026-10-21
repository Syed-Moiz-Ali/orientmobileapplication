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
   **2 taps** (+ scroll to the record). After: Book service sits DIRECTLY on
   each vehicle card (visible action, no menu dive): **≤ 1 tap from the list,
   ≤ 2 taps from app launch**, ≤ same scroll. No regression allowed.
3. Add a vehicle — before: tab (1) + header/empty-state Add (1) = **2 taps**,
   then the existing 3-step wizard (unchanged). After: ≤ 2 taps to wizard.
   "Add vehicle" stays reachable from the header (non-empty list) AND the
   empty state (no list) — never both at once, so no duplicate entry point.
4. Edit a vehicle — before: tab (1) + record Edit (1) = **2 taps** (+ scroll).
   After: ≤ 2 taps. Edit lives in the card menu (overflow/menu on the card)
   or the vehicle detail — existing routes only
   (`customerEditVehicle(id)`), no new destinations.
5. Remove a vehicle — before: tab (1) + Remove (1) + confirm dialog (1 confirm)
   = **2 taps + 1 confirm**. After: ≤ 2 taps + 1 confirm. Remove lives in the
   card menu or the vehicle detail; confirm becomes a confirmation BOTTOM
   SHEET (destructive confirm; NO undo — undo would be logic, out of scope).
6. Open the booking / track service behind a context line — before: tab (1) +
   View/Track (1) = **2 taps**. After: ≤ 2 taps.
7. Retry a failed sync / failed removal — before: inline Retry = **1 tap** from
   the record/banner. After: ≤ 1 tap, control stays inline.

| Task | Before | After budget |
|---|---|---|
| Open list | 1 tap | ≤ 1 tap |
| Book service for vehicle | 2 taps (+scroll) | ≤ 1 tap from list, ≤ 2 taps from launch, ≤ same scroll |
| Add vehicle (reach wizard) | 2 taps | ≤ 2 taps (header when non-empty, empty-state CTA when empty) |
| Edit vehicle | 2 taps (+scroll) | ≤ 2 taps, ≤ same scroll (card menu or detail, existing route) |
| Remove vehicle | 2 taps + 1 confirm | ≤ 2 taps + 1 confirm (bottom-sheet destructive confirm, no undo) |
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
  service context → actions. No competing heroes on a list screen. CARD
  HIERARCHY (binding): title = make/model/year (the thing the user
  recognizes); plate = small meta (chip/label, LTR-locked, verbatim via
  existing helpers); status pill ONLY from existing data — plate-matched
  booking context via `contextFor()` — never invented statuses, and if no
  status exists, NO pill is shown; brand/colour tile placeholder when no
  photo (API has no photography — silhouette/tile art, never a photo
  affordance); borderless in light (soft shadow or flat, whitespace
  separation; C16).
- U1 (find fast): header search icon top-right opens the full-screen search
  sheet over list items (client-side filter of loaded records; no new
  routes/logic). Result tap scrolls to / highlights the record; actions stay
  the record's own buttons (no new destinations). PROGRESSIVE-DISCLOSURE
  EXCEPTION (the ONE sanctioned U1 exception on this screen — see "Search-icon
  pattern" and Acceptance): the search icon appears ONLY when the loaded list
  has MORE THAN 5 items; with ≤ 5 items show cards only, no search icon (≤ 5
  records are fully scannable without find-aids; adding a search icon there
  would add chrome without saving taps). U1 otherwise requires the header
  search icon everywhere — this threshold is the single allowed deviation.
- U2 (fit the content): vehicle records are heterogeneous (art band + specs +
  context + 3 actions) — grouped rows/cards, NOT a data table. No table on any
  width (table matrix cell = N/A by design, recorded here). FOLD (binding):
  at 360x800 the FIRST card sits above the fold (above the bottom nav, idle
  state with data) with the SECOND card peeking (C16 carousel-peek applied as
  list-peek intent); anything pushing the first card below the fold needs a
  written reason in the build log.
- U3 (no fake actions): only real states — context lines only when `contextFor`
  yields one; Book/Edit/Remove/Retry map 1:1 to existing handlers; no health
  pills, no favorite hearts, no photo affordances.
- U4 (no invention): plates/specs/VIN verbatim via existing helpers; unknown
  mileage stays unknown; zero shown as `0`, never `-`; counts from
  `vehicles.length` only.
- U5 (reachable + legible): 48dp targets on all actions; actions Wrap (never
  clip) at 320px / 1.3x; VIN stays LTR-locked; mixed word/number specs follow
  ambient direction (existing contract).
- U6 (states): skeleton mirrors the cards (`AppShimmerSkeleton` mirroring
  card layout: art/tile band + title + meta + action row); honest empty
  (`AppEmptyState`: EXACTLY one icon + one sentence + one "Add your vehicle"
  action → same wizard); error (`AppErrorState` + Try again, same retry
  handler); stale data kept with `CustomerRefreshNotice`/`AppBanner`;
  delete-recovery banner preserved. Pull-to-refresh kept on the list.
- U7 (feedback): remove confirm stays destructive but becomes a confirmation
  BOTTOM SHEET (replacing the `showAppConfirmationDialog` presentation; same
  `customerRemoveVehicle` handler + snackbar contracts; NO undo — undo would
  be logic, out of scope); snackbars for removed/failed stay; busy states
  disable only the acting record's controls.
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
  haptics, keys (`vehicle-<id>`), confirmation + snackbar contracts unchanged
  in behavior (presentation may move dialog → bottom sheet).
- C17: any U-law fail caps at 8/16. C16 list adaptations: search-sheet,
  borderless light cards, no ALL CAPS added (context labels render sentence
  case — note current code upper-cases context labels: `label.toUpperCase()` in
  record + carousel badge — the redesign removes the `.toUpperCase()` calls,
  styling emphasis via theme instead), zero as `0`.

## Search-icon pattern (list-scoped, no new routes/logic)
- `AppPageHeader` (title `vhTitle` + count subtitle) with search icon top-right
  (U1, same placement as staff briefs) — SHOWN ONLY WHEN the loaded `vehicles`
  list has MORE THAN 5 items (progressive disclosure; the ONE sanctioned U1
  exception on this screen). With ≤ 5 items: cards only, NO search icon —
  the list is fully scannable as-is.
- Icon opens a full-screen search sheet over the list items: text field filters
  the loaded `vehicles` by display name / plate label / specs substring;
  results render as the same record rows (tapping a result closes the sheet and
  reveals the record; record actions unchanged).
- Empty query = full list; no-match = filter-no-match state with Clear control.
- No new routes, no server queries, no invented entries. Sheet respects RTL +
  1.3x (field + list scroll, no clipping).

## Filter sheet design (predicates owned by existing logic)
- Filter entry: funnel icon beside search (header, shown together with search
  when the > 5-item threshold is met) — opens bottom sheet with the
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
  search icon top-right ONLY when > 5 items (progressive disclosure; ≤ 5 =
  no search icon) + filter icon beside search when shown; Add stays a header
  action when non-empty (same `customerAddVehicle` push) and the empty-state
  primary CTA when empty.
- REMOVED: bespoke `_Grouped` bordered container + divider code → `AppListGroup`
  of record rows (single column compact / < 4; 2-col medium, 3-col large at
  ≥ 4 — same chunking predicate, rebuilt on shared atoms). Cards are
  borderless in light (soft shadow or flat, whitespace separation).
- REMOVED: bespoke record chrome (silhouette `Stack`, `_ContextLine` container,
  `_Actions` Wrap, `_SyncFailedNotice`, `_DeleteFailedNotice` styling) → shared
  atoms (brand/colour tile placeholder band when no photo, context line, action
  row, inline notices) with byte-identical behavior; card hierarchy binding:
  title = make/model/year, plate = meta, status pill ONLY from existing
  `contextFor()` data (no pill when none — never invented);
  `.toUpperCase()` on context labels removed (sentence case via theme).
  FREQUENT ACTION binding: "Book service" sits DIRECTLY on each card
  (≤ 1 tap from list, ≤ 2 from launch); Edit/Remove live in the card menu or
  the vehicle detail (existing routes only).
- REMOVED: bespoke `_NoVehicles` / `_LoadFailure` panels → `AppEmptyState`
  (EXACTLY one icon + one sentence + one "Add your vehicle" action →
  `vhEmptyTitle`/`vhEmptyBody` + Add) / `AppErrorState` + Try again
  (same retry handler); bespoke skeleton → layout-mirroring `AppShimmerSkeleton`
  (mirrors the cards); refresh + unmatched-delete states → `AppBanner`
  variants (same retry handlers). Pull-to-refresh kept.
- MOVED: context View/Track, Edit, Remove (confirm becomes a confirmation
  bottom sheet — destructive confirm, NO undo since undo would be logic),
  sync/removal retries — same routes/handlers, new clothes only.
- KEPT: all providers/sync/refresh/selectTab, `specs()`/`plateLabel()`/
  `mileageLabel()` verbatim rules, VIN LTR lock, bottom nav (no rail — consumer
  contract), pull-to-refresh, haptics, `ValueKey('vehicle-<id>')`,
  confirmation + snackbar contracts (behavior unchanged, presentation only),
  `selectDestination` deep-linking.
- No new routes. No invented vehicles/statuses/specs. Zero as `0`, never `-`.
  Customer app keeps dark-mode wiring (no regression).

## Fold wireframe (ASCII, 360×800 — header + first card above fold, second peeking)
```
+----------------------------------+
| My vehicles            [🔍][⧩][+]|  <- 🔍+⧩ only when > 5 items; ≤ 5: [+] only
| 7 vehicles (icons shown: count > 5)  |
|----------------------------------|
| [ brand/colour tile    [ABC 123] ]|
| Toyota Camry · 2021              |  <- title = make/model/year; plate = meta
| 2021 · White · 48,200 km         |
| VIN 1HGCM8...                    |
| ⓘ Booked · Oil change · Sat 10:30|  <- pill ONLY from contextFor(); none if none
|            [View]                |
| [Book service] [··· card menu]   |  <- Book direct on card; Edit/Remove in menu
|----------------------------------| <- above fold (nav below)
| [ brand/colour tile    [XYZ 789] ]|  <- second card PEEKING
+----------------------------------+
| Home | Bookings | Vehicles | Prof |
```

## Matrix requirements
- empty (no vehicles: `AppEmptyState` + Add → same wizard; never zero-filled) ·
- with-data (1 record single column; ≥ 4 records multi-column on wider canvas;
  context + sync/delete-failure notices inline) ·
- search (icon shown ONLY when > 5 items → full-screen sheet over loaded
  records; ≤ 5 items = cards only, no icon; result reveals record; no-match
  + Clear; no new routes) ·
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
- U0–U14 walk (ANY U-law fail caps at 8/16, no exceptions — the > 5-item
  search-icon threshold is the ONE sanctioned U1 exception on this screen;
  every other U-law applies in full); C16 hard-reject checklist for lists
  (caps 10/16): search-sheet over items (progressive disclosure: only when
  > 5 items), `AppListGroup` rows, filter sheet on honest predicates,
  borderless light cards, card hierarchy (title = make/model/year, plate =
  meta, pill only from existing data / no pill otherwise, tile placeholder
  when no photo), no ALL CAPS added, zero as `0`, first card above fold +
  second card peeking at 360x800, empty = one icon + one sentence + one
  action, remove = confirmation bottom sheet (destructive, no undo),
  no dead affordances, no fake facets/statuses, no new routes, taps never
  regress (table above).
- Airbnb rubric ≥ 12/16 to pass.
- Gates (kept): characterization tests on the CURRENT list first,
  before-images captured, migration table (current → shared atoms),
  reviewer process per redesign mandate, NO logic changes (providers, sync,
  predicates, refresh stay as-is).
- Airbnb rubric ≥ 12/16 to pass.
- Verify from code: tap counts, route names, `contextFor` predicate, verbatim
  helpers, key names, scaffold no-rail/no-palette consumer constraint.
