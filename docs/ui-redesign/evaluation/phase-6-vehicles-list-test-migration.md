# Vehicles list test migration (phase 6 vehicles-list recomposition)

Branch: `ui/integration-1`. Vehicles list recomposed presentation-only:
providers, sync, predicates (`contextFor`, `specs`, `plateLabel`,
`mileageLabel`), refresh, `selectTab`, routes, validation, Keys and error
mapping untouched. Characterization tests were written against the CURRENT
list FIRST (8 testWidgets, GREEN before touching UI — one harness-only fix:
`TextButton.icon` finder) and migrated after the rebuild (15 testWidgets,
all structural). Counts never down (8 -> 15).

## Inventory (existing customer tests before this change)

- `apps/customer_app/test/customer_home_tab_test.dart` (home only — zero
  vehicles-list assertions).
- `apps/customer_app/test/customer_home_phase6_capture_test.dart` +
  `apps/customer_app/test/baseline_capture_test.dart` (tagged `baseline`,
  excluded from `melos run test:customer`).
- Old vehicles-list assertion count: **0**. New characterization count
  before touching UI: **8 testWidgets** in
  `apps/customer_app/test/customer_vehicles_list_characterization_test.dart`
  (all structural, GREEN). Counts did not go down (0 -> 8).
- After recomposition: **15 testWidgets** in the same file (all structural).
  Before-captures (10 PNGs) in
  `docs/ui-redesign/baseline/before-vehicles-list/` were generated with
  `--update-goldens` and compared back-to-back GREEN before the rebuild
  (idle-2, idle-6, empty, loading, error, dark, ar, 1.3x, 320px, tablet).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| non-empty header + actions | header title + `2 registered vehicles` + header `Add vehicle`; `Book service` x2, `Edit` x2, `Remove` x2 direct; no search icon; `RefreshIndicator` | `AppPageHeader` title + same count; header `Add vehicle` kept; NO search/filter icons at ≤ 5 (sanctioned U1 exception); `Book service` x2 direct; `Edit`/`Remove` moved into the card menu (`more_vert` x2); `RefreshIndicator` kept | structural |
| card menu | (did not exist — Edit/Remove were direct) | menu holds `Edit` + `Remove`; `Remove` opens the confirmation bottom sheet; `Keep vehicle` keeps the car and closes sheet + menu | structural |
| context line | `View` x2; plates/specs verbatim | `AppStatusChip` x2 sentence-case (`Booked`, `Last service`; no ALL-CAPS); `View` x2; title now make/model/year (`Toyota Camry · 2021`); plate/specs/VIN verbatim | structural |
| no context | no `View`/`Track` with zero bookings | no `AppStatusChip`, no `View`/`Track` with zero bookings | structural |
| six vehicles | 6 records, no search icon | 6 records + search + filter icons together; `Book service` x6; `6 registered vehicles` | structural |
| search sheet | (did not exist) | sheet with `AppSearchField` (`vhSearchHint`); substring filter over loaded records scoped to the sheet list; no-match (`vhSearchNoMatch`) + `Clear` | structural |
| filter apply/count/no-match | (did not exist) | sheet options All / `vhInService` / `vhFilterBooked` / `vhFilterLastService` / `vhFilterNone` + `Show results` + `Clear`; in-place filter; filtered count (`1 registered vehicles`); no-match (`vhFilterNoMatch`) + `Clear` restores all six | structural |
| filter sheet options | (did not exist) | all five honest options + `Show results` present; `No active context` keeps all six unbooked vehicles | structural |
| remove confirm | `showAppConfirmationDialog` (behavioral, untested) | confirmation bottom sheet (`showAppModalSheet`): `Remove Toyota Camry?` + `Remove vehicle` (destructive) + `Keep vehicle`; cancel keeps `vehicle-v1` | structural |
| empty | `_NoVehicles` title + `Add vehicle` | `AppEmptyState` (1 icon + 1 sentence + 1 `Add vehicle` action) | structural |
| loading | `AppSkeleton` shapes | `AppShimmerSkeleton` (header lines + `card(208)`) mirroring the cards | structural |
| load failure | bespoke title + `Retry` | `AppErrorState` (verbatim title/body + `vhRetry` label) | structural |
| record unit | title/specs/VIN; no pill w/o ctx; Book/Edit/Remove | title with year; same specs/VIN; no pill w/o ctx; `Book service` + menu icon | structural |
| dark | (not covered) | dark theme pumps clean: title + 2 Books + 2 pills | structural |
| 1.3x | (not covered) | 1.3x pumps clean: title + 2 Books + 2 menus (Wrap, no clip) | structural |

## Behavior kept verbatim (presentation only — no logic changes)

- Providers/sync/refresh: `customerDashboardProvider`,
  `customerBookingsProvider`, `customerFailedVehicleDeletesProvider`,
  `vehicleIdentityReaderProvider`, `refresh()`, delete-restore loop, pull-
  to-refresh — byte-identical call sites.
- Predicates/helpers: `CustomerVehiclePresentation.contextFor` (one
  derivation per build shared by filter + records), `specs()`,
  `plateLabel()`, `mileageLabel()` (blank stays unknown, plate upper-cased
  single-spaced, zero as `0`).
- Routes (existing destinations only, no new routes): `customerAddVehicle`
  (header non-empty + empty state), `customerEditVehicle(id)` (menu),
  `customerBookServiceLocation(vehicleId:)` (card Book), `customerBookingDetail`
  (View), `customerServiceStatus` (Track). `selectDestination` deep-linking
  untouched.
- Keys: `ValueKey('vehicle-<id>')` on every record (scroll anchors use a
  separate wrapper `GlobalKey`; the value key contract is unchanged).
- Handlers: `customerRemoveVehicle` + snackbar contracts
  (`vhRemoved`/`vhRemoveFail` + `vhRetry` action), `customerRetryVehicleSync`,
  `_retryRemoval`; remove withdrawn while delete-recovery is active.
- No invented vehicles/statuses/specs; health/lastService/nextDue never
  presented; no photo affordances (`VehicleSilhouetteArt` kept as the
  decorative tile band, `CustomerPlateChip` + VIN stay LTR-locked,
  `PositionedDirectional` kept).

## Deviations / notes (presentation-only, filed here)

- `AppListGroup` is a settings-row widget (inert rows dim to 40%) and cannot
  host rich record cards with three actions + inline notices; records are
  `AppSurfaceCard(outlined: false)` rows grouped in columns — the same
  shared-atom family, borderless in light (shadow) / bordered in dark, with
  the identical chunking predicate (single column compact or < 4; 2-col
  medium, 3-col large at ≥ 4). No dividers (whitespace separation, C16).
- Filtered subtitle uses `vhCountMany(filtered)` verbatim per the brief,
  including `0`/`1` filtered counts ("0 registered vehicles" — zero as
  `0`, never `-`, U11).
- Search results render as compact name + plate rows (not full records) so
  one tap closes the sheet and reveals the record via `ensureVisible`;
  record actions stay on the record itself (no new destinations).
- `.toUpperCase()` on context labels removed (sentence case via theme, C17).
- Card title appends year (`Toyota Camry · 2021`) per the wireframe; the
  specs line keeps `specs()` verbatim (year · colour · mileage).

## Tap table (AFTER ≤ BEFORE — no regression)

| Task | Before | After |
|---|---|---|
| Open list | 1 tap (tab) | ≤ 1 tap (unchanged) |
| Book service | 2 taps + scroll (tab + record Book) | ≤ 1 tap from list, ≤ 2 from launch (Book direct on card) |
| Add vehicle | 2 taps (tab + header/empty Add) | ≤ 2 taps (same entries, same wizard) |
| Edit vehicle | 2 taps + scroll (tab + record Edit) | ≤ 2 taps (menu + Edit item, same route) |
| Remove vehicle | 2 taps + 1 confirm (tab + Remove + dialog) | ≤ 2 taps + 1 confirm (menu + Remove + bottom sheet, no undo) |
| Open booking / track | 2 taps (tab + View/Track) | ≤ 2 taps (same inline actions) |
| Retry sync / removal | 1 tap inline | ≤ 1 tap inline (same inline banners) |

## New ARB keys (en+ar, `flutter gen-l10n` from `apps/customer_app`)

`vhSearchTitle`, `vhSearchHint`, `vhSearchNoMatch`, `vhFilterTitle`,
`vhFilterAll`, `vhFilterBooked`, `vhFilterLastService`, `vhFilterNone`,
`vhFilterShow`, `vhFilterNoMatch`, `vhFilterClear`. Reused verbatim:
`vhTitle`, `vhCount*`, `vhAdd`, `vhEmpty*`, `vhLoadFail*`,
`vhBook/Edit/Remove/Retry/*`, `vhTrack/View`, `vhSyncFail`,
`vhDeleteFail*`, `vhInService`, `vhFallbackName`, `vhKeepCta`,
`vhRemoveNoName/Title/Body*`, `stRefreshFail`, `stRetry`. No ALL CAPS
strings added (C16/C17).
