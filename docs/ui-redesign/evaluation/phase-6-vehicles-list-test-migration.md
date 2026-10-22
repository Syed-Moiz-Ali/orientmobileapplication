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
| context line | `View` x2; plates/specs verbatim | `AppStatusChip` x2 sentence-case (`Booked`, `Last service`; no ALL-CAPS); `View` x2 (48dp target, bookings-row pattern); title now make/model/year (`Toyota Camry · 2021`); plate/VIN verbatim; specs colour verbatim + mileage grouped (`White · 45,000 km` via `displayMileage`/central formatters, C11) | structural |
| no context | no `View`/`Track` with zero bookings | no `AppStatusChip`, no `View`/`Track` with zero bookings | structural |
| six vehicles | 6 records, no search icon | 6 records + search + filter icons together; `Book service` x6; `6 registered vehicles` | structural |
| search sheet | (did not exist) | sheet with `AppSearchField` (`vhSearchHint`); substring filter over loaded records scoped to the sheet list; no-match (`vhSearchNoMatch`) + `Clear` | structural |
| filter apply/count/no-match | (did not exist) | sheet options All / `vhInService` / `vhFilterBooked` / `vhFilterLastService` / `vhFilterNone` + `Show results` + `Clear`; in-place filter; filtered count (`1 registered vehicles`); no-match (`vhFilterNoMatch`) + `Clear` restores all six | structural |
| filter sheet options | (did not exist) | all five honest options + `Show results` present; `No active context` keeps all six unbooked vehicles | structural |
| remove confirm | `showAppConfirmationDialog` (behavioral, untested) | confirmation bottom sheet (`showAppModalSheet`): `Remove Toyota Camry?` + `Remove vehicle` (destructive) + `Keep vehicle`; cancel keeps `vehicle-v1` | structural |
| empty | `_NoVehicles` title + `Add vehicle` | `AppEmptyState` (1 icon + 1 sentence + 1 `Add vehicle` action) | structural |
| loading | `AppSkeleton` shapes | `AppShimmerSkeleton` (header lines + `card(208)`) mirroring the cards | structural |
| load failure | bespoke title + `Retry` | `AppErrorState` (verbatim title/body + `vhRetry` label) | structural |
| record unit | title/specs/VIN; no pill w/o ctx; Book/Edit/Remove | title with year; specs colour verbatim + mileage grouped (`White · 45,000 km`); VIN verbatim; no pill w/o ctx; `Book service` + menu icon | structural |
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
  single-spaced, zero as `0`) — all byte-identical call sites. Display-only:
  the record rebuilds colour + `displayMileage()` (existing helper, central
  `AppFormatters.group`, Latin digits per frozen policy) for the specs line,
  and the search sheet matches the grouped form too; payloads/input keep the
  canonical `mileageLabel()` form.
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
- Filtered subtitle uses `vhCount(visible.length)` (ICU plural, round-1 fix):
  `=0{0 registered vehicles}` / `=1{1 registered vehicle}` /
  `other{{count} registered vehicles}` (en); `=0{0 مركبات مسجلة}` /
  `=1{مركبة واحدة مسجلة}` / `other{{count} مركبات مسجلة}}` (ar). Zero
  renders as `0`, never `-` (U11). Unfiltered non-empty uses the same
  `vhCount(vehicles.length)`; truly empty keeps `vhCountNone` sentence.
  Existing `vhCountNone/One/Many` keys kept untouched (no renames).
- Search results render as compact name + plate rows (not full records) so
  one tap closes the sheet and reveals the record via `ensureVisible`;
  record actions stay on the record itself (no new destinations).
- `.toUpperCase()` on context labels removed (sentence case via theme, C17).
- Card title keeps year (`Toyota Camry · 2021`) per the brief hierarchy
  (title carries identity); the specs line shows colour + mileage only
  (`White · 45,000 km`) for display — `specs()`/`mileageLabel()` stay
  verbatim and untouched (year · colour · mileage); the record rebuilds
  colour + `displayMileage()` (existing helper, central formatters) for
  display so every predicate is unchanged. VIN line untouched. Round-1 fix
  for the filed year-duplication (was: title + specs both showed year).
  Adversarial fix (2026-10-22): mileage grouping (was `45000 km`) + `View`/
  `Track` 48dp target (bookings-row pattern) — presentation only, same
  handlers/routes.

## Tap table (AFTER ≤ BEFORE — no regression; EXACT counts, round-1)

| Task | Before (EXACT) | After (EXACT) |
|---|---|---|
| Open list | 1 tap (tab) | ≤ 1 tap (unchanged) |
| Book service | 2 taps + scroll (tab + record Book) | ≤ 1 tap from list, ≤ 2 from launch (Book direct on card) |
| Add vehicle | 2 taps (tab + header/empty Add) | ≤ 2 taps (same entries, same wizard) |
| Edit vehicle | 2 taps from launch (tab + record Edit) = 1 tap from list + scroll | 3 taps from launch (tab + ⋮ menu open + Edit item) = 2 taps from list + scroll, same `customerEditVehicle(id)` route — +1 menu tap, BRIEF-SANCTIONED (frequent-action binding: Book direct, Edit in menu) |
| Remove vehicle | 2 taps + 1 confirm from launch (tab + Remove + dialog confirm button) = 1 tap + 1 confirm from list; dialog cancel = 1 tap (keeps car) | 3 taps + 1 confirm from launch (tab + ⋮ menu open + Remove item + sheet `Remove vehicle` FilledButton) = 2 taps + 1 confirm from list; sheet `Keep vehicle` = 1 tap (keeps car, closes sheet+menu), no undo — +1 menu tap, BRIEF-SANCTIONED, same `customerRemoveVehicle` + snackbar contracts |
| Open booking / track | 2 taps (tab + View/Track) | ≤ 2 taps (same inline actions) |
| Retry sync / removal | 1 tap inline | ≤ 1 tap inline (same inline banners) |

## Wave-2 fixer notes (2026-10-22, presentation only — same data/predicates/routes/sheets)

- F1 header: `AppPageHeader` (compact stacks actions below subtitle) replaced
  by a plain-Row header (`_VehiclesHeader` in `customer_vehicles_tab.dart`):
  title row keeps search/filter icons top-right on the SAME row (technician
  `_TodayHeader` / supervisor `_FloorHeader` / owner `_HomeHeader` precedent:
  `Row(Expanded(title), actions end-side)`, RTL-mirrored); subtitle spans full
  width below so the single-word title never squeezes mid-word (U5); Add stays
  end-side below (same `customerAddVehicle` push, ≤ 2 taps, no duplicate
  entry). Same > 5-item `showFindAids` condition, same search/filter sheets
  and targets. `idle-6_light_1.0_en_360x800.png` verifies icons top-right;
  `idle-2_light_1.3_en_360x800.png` + `idle-2_light_1.0_en_320x568.png` verify
  no title/mid-word cut at 1.3x/320px.
- F5 pills: `CustomerVehiclePresentation.contextFor` now takes ambient
  `CustomerLocalizations` + `Locale` and renders pill labels from ARB —
  `vhStatusBooked`/`vhStatusRequested` (glossary style, ar `محجوز`/`مطلوب`),
  `vhStatusLastService` (ar `آخر صيانة`), `vhInService` reused for the
  workshop pill (ar `في الورشة الآن`), `vhStatusInProgress` fallback
  (ar `الصيانة جارية`) — instead of hardcoded `Booked`/`Requested`/
  `Last service`/`In the workshop now`/`Service in progress`. Detail prefix
  reuses existing `jsStage` ARB (`المرحلة الحالية · {stage}`). Verified in
  `idle-2_light_1.0_ar_360x800.png` (pills `محجوز`, `آخر صيانة`, RTL mirrored,
  plate/VIN LTR-locked).
- F5 detail-schedule decision (documented, not a regression): the inline
  `service · date · time` detail keeps the verbatim Latin helpers
  (`compactDateLabel`/`timeLabel`, EN month) in ar on purpose — an Arabic
  month inside that inline mixed line corrupts bidi order (`AM 10:00`,
  swapped segments, observed during this fix). Pills carry the Arabic status;
  the detail keeps LTR-locked Latin like plate/VIN per the U10 policy. Months
  ARE localized where they render safely (bookings date-blocks via
  `AppFormatters` + new `bkWeekday*` ARB; standalone dates via locale-aware
  helpers). No invented Arabic.
- Counts: 15 testWidgets unchanged (0 -> 8 -> 15, never down). After-frames
  recaptured in `after-vehicles-list/` and compared back-to-back GREEN.

## New ARB keys (en+ar, `flutter gen-l10n` from `apps/customer_app`)

`vhSearchTitle`, `vhSearchHint`, `vhSearchNoMatch`, `vhFilterTitle`,
`vhFilterAll`, `vhFilterBooked`, `vhFilterLastService`, `vhFilterNone`,
`vhFilterShow`, `vhFilterNoMatch`, `vhFilterClear`, `vhCount` (ICU plural
`=0/=1/other`, round-1 fix for "1 registered vehicles"). Reused verbatim:
`vhTitle`, `vhCount*`, `vhAdd`, `vhEmpty*`, `vhLoadFail*`,
`vhBook/Edit/Remove/Retry/*`, `vhTrack/View`, `vhSyncFail`,
`vhDeleteFail*`, `vhInService`, `vhFallbackName`, `vhKeepCta`,
`vhRemoveNoName/Title/Body*`, `stRefreshFail`, `stRetry`. No ALL CAPS
strings added (C16/C17).
