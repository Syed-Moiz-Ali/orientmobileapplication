# Bookings list test migration (customer bookings-list recomposition)

Branch: `ui/list-customer`. Bookings list recomposed presentation-only:
providers, sync, predicates (`groupOf`, `sortByUpcoming`/`sortByRecent`,
`scheduleLabel`, `referenceOf`), refresh, `selectTab`, routes, Keys and error
mapping untouched. Characterization tests were written against the CURRENT
list FIRST (12 testWidgets, GREEN before touching UI — one harness-only fix:
never-completing `Completer` future for the loading case instead of a
`Future.delayed` pending timer) and migrated after the rebuild (16 testWidgets,
all structural, GREEN — two more harness-only fixes: `AppChip`-scoped filter
taps because option text also matches the section header behind the scrim).
Counts never down (0 -> 12 -> 16).

## Inventory (existing customer tests before this change)

- `apps/customer_app/test/customer_bookings_list_characterization_test.dart`
  (new, 12 testWidgets, all structural, GREEN).
- `apps/customer_app/test/customer_bookings_list_before_capture_test.dart`
  (tagged `baseline`, 10 PNGs in
  `docs/ui-redesign/baseline/before-customer-bookings/`, generated with
  `--update-goldens` and compared back-to-back GREEN before the rebuild:
  idle, failed, empty, loading, error, dark, ar, 1.3x, 320px, tablet).
- Old bookings-list assertion count before this change: **0**. New
  characterization count before touching UI: **12 testWidgets** (all
  structural, GREEN). Counts did not go down (0 -> 12).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| non-empty header + actions | `bkTitle` headline + subtitle (`1 upcoming · 1 past service`) + header `Book service`; no search icon; `RefreshIndicator` | `AppPageHeader` title + same subtitle; header `Book service` kept; NO search/filter icons at ≤ 5 (sanctioned U1 exception, vehicles precedent); `RefreshIndicator` kept | structural |
| sections split | `Upcoming & in service` + `History` `SectionHeader`s, 3 `CustomerBookingItem`s | same titles/counts on borderless cards; same split predicate (two sections → `AppSplitView`, else single) | structural |
| row chrome | `CONFIRMED` uppercase `StatusPill`, plate, `BK-1001` ref, `InkWell` open | `AppStatusChip` sentence-case (`Confirmed`; `.toUpperCase()` removed, vehicles precedent); plate/ref/schedule verbatim; row-tap opens detail | structural |
| approval action | direct `Review` + `awaiting approval` line | direct `Review` (`bkReview`) + `bkApprovalMsg`/`bkApprovalEst` (ARB, was hardcoded) on the card | structural |
| track action | direct `Track service` + `Current stage` line (live job only) | direct `Track service` (`bkdTrack` reuse) + `jsStage` (ARB, was hardcoded) on the card | structural |
| failed rows | `Needs attention` + `NOT SENT` pill + inline `Retry`/`Remove` (dialog confirm) | sentence-case pill (`bkfNotSent`); ARB body (`bkfSendBody`/`bkfWaitingBody`); inline Retry kept; Remove → confirmation bottom sheet (`showAppModalSheet`, destructive, no undo; same `failedBookingSync.remove` + snackbar contracts) | structural |
| search (> 5 only) | (did not exist) | sheet with `AppSearchField` (`bkSearchHint`); substring filter over loaded bookings (service/vehicle/plate/ref); no-match (`bkSearchNoMatch`) + `Clear` | structural |
| filter (> 5 only) | (did not exist) | sheet options All / Upcoming / In service / History (`bkFilter*`) + `Show results` + `Clear`; in-place filter; counts update verbatim; no-match (`bkFilterNoMatch`) + `Clear` | structural |
| empty (vehicles) | `_NoBookings` + `Book service` | `AppEmptyState` (1 icon + 1 sentence + 1 `Book service` action) | structural |
| empty (no vehicles) | `_NoBookings` + add-vehicle path | `AppEmptyState` (1 icon + 1 sentence + 1 `garHeroAdd` action) | structural |
| loading | `AppSkeleton` shapes | `AppShimmerSkeleton` mirroring header + cards | structural |
| first-load error | `EmptyState` + `Retry` | `AppErrorState` (verbatim title/body + retry, same `_refresh`) | structural |
| dark | (covered: pumps clean) | dark pumps clean: same rows on bordered cards | structural |
| 1.3x | (covered: pumps clean) | 1.3x pumps clean: title ≤ 2 lines, actions wrap | structural |

## Behavior kept verbatim (presentation only — no logic changes)

- Providers/sync/refresh: `customerDashboardProvider`,
  `customerBookingsProvider`, `customerFailedBookingsProvider`,
  `failedBookingSyncProvider`, `refresh()`, pull-to-refresh — identical call sites.
- Predicates/helpers: `CustomerBookingsPresentation.groupOf` (filter + sections
  read the same derivation), `sortByUpcoming`/`sortByRecent`, `scheduleLabel`,
  `timeLabel`, `referenceOf`, `bookingKey`/`identityKey` reconciliation,
  `CustomerServiceTracking.bookingTone`/`bookingForJobCard`/`humanize`/`isLiveService`.
- Routes (existing destinations only, no new routes): `customerBookService`
  (header non-empty + empty state), `customerAddVehicle` (empty no-vehicle),
  `customerBookingDetail` (row tap), `customerServiceStatus` (Track),
  `approvalsLocation(estimateId:)` (Review). `selectDestination` deep-linking untouched.
- Handlers: `failedBookingSync.retry` + `bkSendFail` snackbar, `.remove` +
  invalidates, busy-per-operation guard; remove withdrawn while busy.
- No invented bookings/statuses/dates/prices; unreadable dates degrade to raw
  values; zero as `0`.

## Deviations / notes (presentation-only, filed here)

- Bordered `DecoratedBox` + dividers → whitespace-separated
  `AppSurfaceCard(outlined: false)` rows (borderless light w/ shadow, bordered
  dark) — vehicles-list precedent (`AppListGroup` is settings-rows only).
- `.toUpperCase()` on status + `NOT SENT` removed (sentence case via theme, C17).
- Hardcoded EN row/failed copy moves into ARB with identical EN + new AR
  (`bkServiceAppt`, `bkApprovalMsg`, `bkApprovalEst`, `jsStage`, `bkdTrack`,
  `bkReview`, `bkRetry`, `vhRemove` reused verbatim; 15 new keys listed below).
- Search results render as compact service + vehicle rows (not full records);
  one tap closes the sheet and reveals the record via `ensureVisible`.
- No `ValueKey` added to rows (bookings rows never had a key contract; Keys
  untouchable — tests find by type + text).
- Adversarial fix (2026-10-22, presentation only): date-block time wrapped in
  `Directionality(ltr)` (U10 — the `9:00 AM`-style token keeps its order in
  RTL instead of rendering `AM 9:00`); same text/data/predicates/routes, 16
  testWidgets unchanged (counts 0 -> 12 -> 16, never down).

## Tap table (AFTER ≤ BEFORE — no regression; EXACT counts)

| Task | Before (EXACT) | After (EXACT) |
|---|---|---|
| Open list | 1 tap (tab) | ≤ 1 tap (unchanged) |
| Open booking detail | 2 taps + scroll (tab + row tap) | ≤ 1 tap from list, ≤ 2 from launch (row/card tap, same `customerBookingDetail` extra) |
| Track live service | 2 taps (tab + `Track service`) | ≤ 1 tap from list, ≤ 2 from launch (direct on card, same Status route) |
| Review estimate | 2 taps (tab + `Review`) | ≤ 1 tap from list, ≤ 2 from launch (direct on card, same approvals deep link) |
| Book service | 2 taps (tab + header/empty Book) | ≤ 2 taps (same entries, same flow) |
| Retry failed booking | 1 tap inline | ≤ 1 tap inline (same retry + snackbar contracts) |
| Remove failed booking | 1 tap + 1 confirm from list (tab + Remove + dialog confirm button) | 1 tap + 1 confirm from list (inline Remove + sheet confirm, destructive, no undo), same `failedBookingSync.remove` contracts |

## Wave-2 fixer notes (2026-10-22, presentation only — same data/predicates/routes/sheets)

- F1 header: `AppPageHeader` replaced by a plain-Row header (`_BookingsHeader`
  in `customer_bookings_tab.dart`): title row keeps search/filter icons
  top-right on the SAME row (vehicles `_VehiclesHeader` + technician/
  supervisor/owner precedent, RTL-mirrored); subtitle spans full width below
  (no mid-word `Bookin/gs` squeeze at 1.0x/1.3x/320px); Book stays end-side
  below (same `customerBookService` push, ≤ 2 taps). Same > 5-item
  `showFindAids` condition, same sheets/targets. Verified in
  `idle_light_1.0_en_360x800.png` (icons top-right, `Bookings` whole),
  `idle_light_1.3_en_360x800.png` (header intact, no mid-word cut),
  `idle_light_1.0_en_320x568.png` (single column, header + first card intact).
- F2 vehicle wrap: `CustomerBookingItem` vehicle `Text` changed
  `maxLines: 1` → `2` (`softWrap: true`, ellipsis) so the vehicle meta wraps
  at word boundary (`Toyota` / `Camry`) instead of mid-word `Toyota Cam…`;
  service title stays `maxLines: 2` untouched. Verified in
  `idle_light_1.3_en_360x800.png` card 2 (`ABC 1234` + `Toyota`/`Camry` whole).
- F3 fixture: `customer_bookings_list_after_capture_test.dart` (and the
  characterization twin) `_liveService.currentStage` changed
  `'In progress'` → `'Quality check'` (test data only) so the pill
  (`In Service`, from `inProgress` status) differs from the stage line
  (`Current stage · Quality check`), proving both signals independently.
  Production predicate (`groupOf`, `liveServiceFor`, `humanize`) unchanged.
  Verified in `idle_light_1.0_en_360x800.png` card 1 (pill `In Service` +
  `Current stage · Quality check`, no duplication).
- F5 status pills: `CustomerBookingItem` pill label now renders via
  `AppStatusLabels.of(context).booking(status.name)` (shared-core ARB:
  `statusConfirmed`/`statusInService`/`statusApprovalRequired`/…,
  ar `مؤكد`/`قيد الخدمة`/`بانتظار الموافقة`) instead of the legacy
  English-only `statusLabel` shim; same status, same tone, English fallback
  when the delegate is absent (tests stay green). Verified in
  `idle_light_1.0_ar_360x800.png` (pills `قيد الخدمة`, `مؤكد`,
  `بانتظار الموافقة`).
- F5 months/weekdays: `CustomerBookingsPresentation.dateLabel/longDateLabel/
  compactDateLabel/monthLabel/scheduleLabel` now accept `{Locale, l10n}` —
  Arabic renders ARB weekdays (`bkWeekdayMon…Sun`, `bkWeekdayMonday…Sunday`,
  new keys en+ar) + central-formatter months (`AppFormatters.monthName`,
  ar `يونيو`…, Latin digits per frozen policy); time stays LTR-locked
  (`9:00 AM`, `Directionality(ltr)` in `_DateBlock`, unchanged). Verified in
  `idle_light_1.0_ar_360x800.png` (date-blocks `10/12/15 يونيو`, times
  `9:00/10:00/11:00 AM` ordered, chevron mirrored, search/filter top-left).
- New ARB keys (en+ar, `flutter gen-l10n` from `apps/customer_app`):
  `vhStatusBooked`, `vhStatusRequested`, `vhStatusLastService`,
  `vhStatusInProgress`, `bkWeekdayMon/Tue/Wed/Thu/Fri/Sat/Sun`,
  `bkWeekdayMonday/Tuesday/Wednesday/Thursday/Friday/Saturday/Sunday`.
  Reused verbatim: all prior `bk*`/`jsStage`/`vh*`/`st*` keys; booking status
  uses existing shared-core `status*` ARB (no duplication).
- Counts: 16 testWidgets unchanged (0 -> 12 -> 16, never down). After-frames
  recaptured in `after-customer-bookings/` and compared back-to-back GREEN.

## New ARB keys (en+ar, `flutter gen-l10n` from `apps/customer_app`)

`bkSearchTitle`, `bkSearchHint`, `bkSearchNoMatch`, `bkFilterTitle`,
`bkFilterAll`, `bkFilterUpcoming`, `bkFilterInService`, `bkFilterHistory`,
`bkFilterShow`, `bkFilterNoMatch`, `bkFilterClear`, `bkfNotSent`,
`bkfSendBody`, `bkfWaitingBody`, `bkfRetrying`. Reused verbatim: `bkTitle`,
`bkUpcoming`, `bkInService`, `bkHistory`, `bkBookCta`, `bkEmpty*`,
`bkLoadFail*`, `bkRetry*`, `bkUp*/bkIn*/bkPast*`, `bkSubDefault`,
`bkFailedTitle`, `bkSendFail`, `bkRemove*`, `bkKeepCta`, `bkReview`,
`bkServiceAppt`, `bkApprovalMsg`, `bkApprovalEst`, `jsStage`, `bkdTrack`,
`vhRemove`, `garHeroAdd`, `stRefreshFail`, `stRetry`. No ALL CAPS strings
added (C16/C17).
