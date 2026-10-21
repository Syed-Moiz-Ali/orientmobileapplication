# Customer home test migration (phase 6 home recomposition + U-fix pass)

Branch: `ui/phase-6-customer`. Home recomposed presentation-only: providers,
routes, booking/approval/invoice logic, validation and Keys untouched.
U-fix pass (customer-home-U.md: U1, U6, U7, U9 + craft slips): presentation +
widget-tree only, same rule — no provider/route/domain/logic changes.

## Inventory (existing customer tests before this change)

- `apps/customer_app/test/baseline_capture_test.dart` (tagged `baseline`,
  excluded from `melos run test:customer`): pumps the logged-out login screen
  (light + dark). Zero assertions touch Customer Home — no home widget
  finders, no home behavior assertions existed.
- Old home assertion count: **0**. New home assertion count: **8 testWidgets**
  in `apps/customer_app/test/customer_home_tab_test.dart` (all structural).
  Counts did not go down (0 -> 8).
- U-fix pass: **11 testWidgets** (8 updated/kept + 3 new, all structural).
  New file `customer_home_search_sheet.dart` covered structurally only
  (open/filter/no-match); result-tap navigation reuses existing destinations
  and is asserted nowhere (no router in the harness, by design).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| (none existed) | n/a | `approval hero wins over payment due, with +N more row`: approval title + `bkApprovalMsg` sentence in one `AppMediaCard`, `1 more item needs review` row, unpaid hero suppressed | structural |
| (none existed) | n/a | `payment-due hero when no approval waits`: `2 unpaid invoices` title once + `Unpaid` chip + `garUnpaidBody` sentence in one `AppMediaCard`, `Review invoices` CTA | structural |
| (none existed) | n/a | `service hero with tracking CTA when no attention`: live service title in hero, garage `AppCarousel` present | structural |
| (none existed) | n/a | `garage carousel, quick actions and recent activity`: calm nothing-state status row (no `AppMediaCard`, no duplicate `Book service`), single vehicle hides `Show all`, search icon present, tiles + `Recent activity` + `AppListGroup` | structural |
| (none existed) | n/a | `new customer gets a calm status row with a text action`: no `AppEmptyState`/`AppMediaCard`, full `garHeroEmptyBody` sentence + `Add your vehicle` text action, no carousel | structural |
| (none existed) | n/a | `loading skeleton mirrors the final layout`: `AppShimmerSkeleton` shapes, no `AppMediaCard` | structural |
| (none existed) | n/a | `error state with retry when nothing loaded`: `AppErrorState` (`garLoadTitle`/`garLoadBody`) | structural |
| (none existed) | n/a | `stale data keeps rendering under a warning banner`: `AppBanner` warning + last data kept (banner is message-only; see deviations) | structural |
| (none existed) | n/a | `two vehicles keep Show all and grouped mileage`: `Your garage` + `Show all`, spec lines `45,000 km` / `78,200 km` | structural |
| (none existed) | n/a | `payment hero suppresses the duplicate invoices tile`: `Review invoices` CTA kept, `Invoices` tile absent (U7) | structural |
| (none existed) | n/a | `header search opens a sheet over existing data`: search icon opens the sheet, empty-query hint (no recents), `camry` filters to the Camry hit, no-match message | structural |

## U-fix deviations (brief notes, presentation-only)

- U6 new-customer row: `Add your vehicle` is a quiet `AppTextButton` action
  inside the calm status row, downgraded from the filled `AppEmptyState` CTA
  (filed here, not in the phase-6 brief: booking requires a vehicle, so the
  path stays one tap; the full `garHeroEmptyBody` sentence renders wrapped,
  never truncated).
- Payment hero: the `Invoices` tile is suppressed while the payment-due hero
  shows (hero `Review invoices` CTA owns the task). The 3-tile row leaves a
  blank second-row slot — accepted for U7 (one path beats grid symmetry).
- Offline banner: message-only `AppBanner` (advisor parity). The shared
  banner stacks its action slot full-width with the icon centered against
  the stack; without an action the icon + message render baseline-aligned.
  Refresh stays one pull away; the full error state keeps its `Retry` button.
- Single vehicle: garage card takes the available width (up to 480) instead
  of the 2.2 peek slot, so the grouped spec line stays whole; `Show all` is
  hidden (U7). Two-up cards keep the peek slot.

## Search-surface decision (U1/U9, no new logic)

- The sheet filters the lists Home already holds: `state.vehicles`
  (brand/model/plate) + `customerBookingsProvider` (service/vehicle/plate/
  bookingRef) via in-memory substring match. No new providers, no new routes:
  a vehicle hit reuses the garage card destination
  (`customerBookServiceLocation(vehicleId:)`), a booking hit reuses
  `customerBookingDetail` (extra: booking).
- Recents omitted honestly: the customer app keeps no recent searches
  anywhere, so the empty-query state is a plain hint line
  (`garSearchEmpty`). No scan action: scan is a staff/advisor flow with no
  customer destination.
- Presentation mirrors the advisor sheet mechanism (top-right header
  `AppIconButton` -> full-screen `showModalBottomSheet` with autofocus
  `AppSearchField` + grouped `AppRecordRow` hits), so U9 holds across apps.
  New ARB keys (en+ar, regenerated): `garSearchTitle`, `garSearchHint`,
  `garSearchEmpty`, `garSearchNoMatch`, `garUnpaidChip` (payment chip
  de-duplicated from the title count: `Unpaid` / `غير مدفوعة`).

## Behavior assertions (verbatim, unchanged)

No behavior assertions were modified because no behavior changed:

- Navigation targets identical: `customerBookService[?vehicleId=]`,
  `customerBreakdownHelp`, `approvalsLocation([estimateId])`,
  `customerServiceStatus`, `customerBookingDetail` (extra: booking),
  `customerAddVehicle`, `selectDestination(bookings|vehicles)`.
- Provider reads identical: `customerDashboardProvider`,
  `customerBookingsProvider`, `customerApprovalsProvider`.
- Hero priority logic identical to the code it replaced: attention-panel row
  order (approvals, then unpaid) > live-service check
  (`CustomerServiceTracking.isLiveService`) > first live booking in provider
  order (`CustomerServiceTracking.activeBooking`) > idle.
- Recent-activity ordering identical (provider order, live statuses skipped);
  only the cap moved 2 -> 3 (presentation budget per the brief).
- Booking-gating identical: new-customer CTA stays `Add your vehicle`
  because step 0 of the booking flow requires a resolved vehicle
  (`_canProceed` false without one; empty garage shows only the add-vehicle
  action in `CustomerBookingVehicleStep`).
- Search result taps reuse existing destinations only (vehicle ->
  `customerBookService[?vehicleId=]`, booking -> `customerBookingDetail`);
  no new routes were added and none of the above targets changed.

## Copy changes (new ARB keys, en+ar, regenerated)

- `garShowAll` ("Show all" / "عرض الكل") — garage carousel action
  (replaces the `garManage` "Manage" label on Home only; the key is untouched).
- `garAttentionMoreOne` / `garAttentionMoreMany` — hero "+N more" row.
- `garUnpaidBody` ("Review and settle your outstanding invoices." /
  "راجع وسدد فواتيرك المستحقة.") — payment-hero sentence.
- All other home strings reused verbatim (`gar*`, `st*`, `js*`, `bk*`, `ap*`).
