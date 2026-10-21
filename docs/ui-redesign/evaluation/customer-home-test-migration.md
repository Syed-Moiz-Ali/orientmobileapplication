# Customer home test migration (phase 6 home recomposition)

Branch: `ui/phase-6-customer`. Home recomposed presentation-only: providers,
routes, booking/approval/invoice logic, validation and Keys untouched.

## Inventory (existing customer tests before this change)

- `apps/customer_app/test/baseline_capture_test.dart` (tagged `baseline`,
  excluded from `melos run test:customer`): pumps the logged-out login screen
  (light + dark). Zero assertions touch Customer Home — no home widget
  finders, no home behavior assertions existed.
- Old home assertion count: **0**. New home assertion count: **8 testWidgets**
  in `apps/customer_app/test/customer_home_tab_test.dart` (all structural).
  Counts did not go down (0 -> 8).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| (none existed) | n/a | `approval hero wins over payment due, with +N more row`: approval title + `bkApprovalMsg` sentence in one `AppMediaCard`, `1 more item needs review` row, unpaid hero suppressed | structural |
| (none existed) | n/a | `payment-due hero when no approval waits`: `2 unpaid invoices` + `garUnpaidBody` sentence in one `AppMediaCard` | structural |
| (none existed) | n/a | `service hero with tracking CTA when no attention`: live service title in hero, garage `AppCarousel` present | structural |
| (none existed) | n/a | `garage carousel, quick actions and recent activity`: `Show all` + silhouette art kept, 4 tiles (`Book service`, `Breakdown help`, `Invoices`, `History`), `Recent activity` + `AppListGroup` | structural |
| (none existed) | n/a | `new customer gets one empty state with one action`: one `AppEmptyState` (`garHeroEmpty` + `garHeroAdd`), no carousel | structural |
| (none existed) | n/a | `loading skeleton mirrors the final layout`: `AppShimmerSkeleton` shapes, no `AppMediaCard` | structural |
| (none existed) | n/a | `error state with retry when nothing loaded`: `AppErrorState` (`garLoadTitle`/`garLoadBody`) | structural |
| (none existed) | n/a | `stale data keeps rendering under a warning banner`: `AppBanner` warning + last data kept | structural |

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

## Copy changes (new ARB keys, en+ar, regenerated)

- `garShowAll` ("Show all" / "عرض الكل") — garage carousel action
  (replaces the `garManage` "Manage" label on Home only; the key is untouched).
- `garAttentionMoreOne` / `garAttentionMoreMany` — hero "+N more" row.
- `garUnpaidBody` ("Review and settle your outstanding invoices." /
  "راجع وسدد فواتيرك المستحقة.") — payment-hero sentence.
- All other home strings reused verbatim (`gar*`, `st*`, `js*`, `bk*`, `ap*`).
