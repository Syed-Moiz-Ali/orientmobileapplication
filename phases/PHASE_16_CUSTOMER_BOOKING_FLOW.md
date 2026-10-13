# PHASE 16 — Customer: Booking Flow, Success & Booking Detail

## A. Phase identity

- **Phase number:** 16
- **Title:** Customer Booking Flow (4-step wizard, booking success, booking detail)
- **Objective:** Refine the customer's core conversion journey — booking a service — into a fast, confidence-building wizard with real availability clarity and an honest offline result, and redesign the booking record page. Preserve the entire submission/queueing/identity behavior.
- **Priority:** High
- **Dependencies:** Phases 01–15
- **Estimated scope:** Large

## B. Repository context

Files (relative to `apps/customer_app/`):

- `lib/features/customer/presentation/customer_book_service_view.dart` (route
  `/customer_book_service_view?vehicleId=`): step controller, `_ActionBar`
  (back/continue/confirm, disabled + spinner while submitting), submit failure
  notice with "Retry vehicle sync" when the vehicle registration is unsynced;
  `_StepSkeleton`; `CustomerNoticePanel` errors; per-step empty/loading.
- Steps: `widgets/customer_booking_steps.dart` —
  `CustomerBookingVehicleStep` (registered vehicles, add-vehicle CTAs, spinner,
  empty "No vehicle yet"), `CustomerBookingServiceStep` (`_StepSkeleton(rows:4)`,
  catalogue error notice, empty catalogue), `CustomerBookingScheduleStep` (real
  date + slot availability, slots skeleton, "no times", error notice, hides past
  slots today), `CustomerBookingReviewStep` (submission review, change each
  section, notes).
- Progress/summary: `widgets/customer_booking_flow_progress.dart` —
  `CustomerBookingProgress` ("Step n of 4"), `CustomerBookingSummaryPanel` (live
  summary beside steps, jump-to-step, empty "Nothing selected yet").
- Success: `customer_booking_success_view.dart` (route `/booking-success`,
  extra map `{ref,id,service,date,time,vehicle,plate,queued}`; queued-offline
  banner + "Not sent yet" pill; route-error fallback).
- Detail: `customer_booking_detail_view.dart` (route `/customer_booking_detail`,
  extra entity/map; cancel booking w/ confirm + in-flight state, snackbar retry,
  "review estimate", "track service") + widgets
  `customer_booking_detail_summary.dart`, `_service.dart`, `_vehicle.dart`.
- Router: booking-detail/success `_RouteErrorPage` fallbacks; booking relations
  helpers `presentation/support/customer_booking_relations.dart`,
  `customer_bookings_presentation.dart`, `vehicle_booking_decision.dart`.
- Offline: submit uses sync queue (`BookingSyncHandler` / failed-booking support
  in 15); result view copy distinguishes sent vs saved-on-device.
- Tests: `customer_book_service_test.dart`, `customer_booking_success_test.dart`,
  `customer_booking_detail_test.dart`, `customer_booking_detail_route_test.dart`,
  `booking_detail_cancel_test.dart`, `customer_failed_booking_test.dart`;
  goldens.

## C. Design objectives

1. **Wizard chrome (T5):** persistent `AppStepProgress` (4 steps, localized),
   back/continue in `AppActionBar`, step content single-purpose; on tablet/desktop
   a live `SummaryPanel` occupies the side column (already exists — promote to a
   real two-pane ≥ medium). Step transitions preserve entered data exactly.
2. **Step 1 — Vehicle:** selected state obvious (checkmark + tint), vehicle
   cards with plate chip + make/model; "Add vehicle" opens `/add-vehicle` (flow
   unchanged); empty state explains and offers the action.
3. **Step 2 — Service:** catalogue as selectable rows/cards (name, duration,
   price if provided) with search if catalogue is long; selected state;
   skeleton/error/empty preserved and restyled.
4. **Step 3 — Schedule:** date strip (horizontal calendar with day load if
   available) + slot grid (morning/afternoon groups where data allows); past
   slots hidden (behavior kept); "no availability" clear with alternative date
   guidance; skeleton/error preserved.
5. **Step 4 — Review:** exact submission summary (vehicle, service, date/time,
   notes) with per-section "Change" jumps; primary "Confirm booking" busy state;
   failure → honest panel with retry (and "Retry vehicle sync" path preserved).
6. **Success:** confirmation hierarchy: big status (Booked ✓ / Saved on device),
   booking ref (copyable, tabular), service/vehicle/time summary, next actions
   (View booking / Back to home); queued state explains sync plainly.
7. **Booking detail (T3):** identity header (service, ref, status pill, date/
   time) → vehicle panel → service panel → price/estimate state if provided →
   timeline link (Track service) → actions: Cancel (confirm, in-flight state),
   Review estimate (contextual); all navigation identical.
8. **Localization + RTL of calendar/slots:** date strip scroll direction,
   weekday labels, RTL slot order — all localized via Material + `AppFormatters`.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `CustomerBookServiceView` | step progress → step body → action bar (+ summary pane ≥medium) | select vehicle/service/slot, notes, continue/back, confirm | per-step loading/empty/error, submitting, submit failure (+ vehicle-sync retry), queued |
| Vehicle step | vehicle cards + add CTA | select, add vehicle | spinner, empty |
| Service step | catalogue list | select, retry | skeleton, error, empty catalogue |
| Schedule step | date strip + slot grid | pick date, pick slot, retry times | slots skeleton, no times, error |
| Review step | summary rows + notes + change jumps | change sections | — |
| `CustomerBookingSuccessView` | status hero → ref + summary → actions | copy ref (if already possible), view booking, home | queued banner |
| `CustomerBookingDetailView` | identity → vehicle/service/estimate → actions | cancel (confirm), track, review estimate | busy cancel, snackbar retry, route fallback |

## E. Responsive specifications

- **Compact:** single column; step progress compact (numbers + current label);
  date strip scrolls horizontally; slots 2–3 columns; action bar sticky; summary
  panel collapsed into review step only.
- **Medium:** two-pane wizard (steps left 60% | live summary right 40%);
  slots 3–4 columns; success centered card ~520.
- **Expanded/large:** wizard capped `contentStandard`; summary pane fixed ~360;
  date strip shows two weeks if space; detail page two-column (record | actions).
- 320 px: slot cells ≥44 px height; no overflow; step labels ellipsize safely.
- RTL: date strip scroll mirrors (scroll starts at end), step progress mirrors,
  slot order mirrors logically.

## F. Localization and RTL

- All strings localized (`customerBooking*` namespaces) EN+AR: steps, field
  labels, availability copy, queued copy, errors, success copy.
- Dates/weekdays/times localized; refs stay Latin; money tabular via
  `AppFormatters`.
- RTL: wizard/summary/action bar mirror; slot grid mirrors; success hero
  alignment mirrors.
- Tests: booking/success/detail tests in EN+AR; RTL assertions (step progress,
  date strip, action bar); 320 px no overflow.

## G. Design system integration

- Use: `AppStepProgress`, `AppActionBar`, `AppButton`, `AppCard`/selection rows,
  `AppRecordRow`, `StatusPill`, `AppTextField` (notes), `AppSearchField`
  (catalogue where used), `AppSkeleton`, `EmptyState`, `ErrorView`,
  `AppInfoPanel` (queue/refresh notices), `CustomerPlateChip`, `AppConfirmationDialog`
  (cancel), `showAppModalSheet` (add-vehicle handoff stays a route — unchanged),
  `AppFormatters`.
- Keep domain components (`CustomerBookingSummaryPanel`, plate chip) restyled.
- No new tokens expected.

## H. Technical implementation

- Modify: wizard + steps + progress/summary + success + detail + detail widgets;
  ARB; tests/goldens.
- Preserve: step state model, submit payload/queue behavior, vehicle-sync retry
  path, booking relations helpers, route extras (`success` map keys, `detail`
  entity/map + fallback), cancel method + in-flight semantics, all navigation
  targets (approvals estimate link, status page).
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Submission produces identical booking payloads; offline queueing identical;
  success route extra contract identical; queued copy semantics identical.
- Cancel booking flow and its confirmation identical.
- Review-estimate/track navigation identical.
- Relations/decision helpers unchanged (tests).
- All Phase 16 tests pass (copy/layout updates only); goldens intentional.

## J. Testing requirements

- `melos run analyze:customer`; `melos run test:customer`.
- Update/extend the six listed test files: full happy path per step in EN+AR;
  each step's loading/empty/error; schedule past-slot hiding; submit failure +
  vehicle-sync retry; queued success; detail cancel states; route fallbacks;
  RTL + 320/390/768/1280 + 1.3×.
- Goldens: regenerate wizard/success/detail; add AR goldens for schedule step +
  success.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the booking wizard end to end (all 4 steps →
   success → detail) and visually review each step + both result surfaces.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px); the two-pane wizard (steps | summary) reviewed at
   medium+.
3. **Locales** — EN-LTR and AR-RTL renders; date strip scroll direction, slot
   grid mirroring and step progress reviewed in AR.
4. **State matrix** — per-step loading/empty/error, no-slot-availability,
   submitting, submit failure (+ vehicle-sync retry), queued offline success,
   cancel in-flight. Realistic vehicle/service fixtures.
5. **Interaction verification** — step navigation preserving data, change
   jumps from review, confirm booking, cancel confirmation, track/review links.
6. **Accessibility** — 1.0–1.3× scale clean, ≥44 px slot cells, semantics on
   selection cards, contrast sampled.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_16/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D surfaces redesigned per spec; all states covered.
2. Submission/queue/cancel/route contracts unchanged (tests).
3. EN/AR complete; calendar/slots RTL-correct; responsive per E.
4. `melos run analyze:customer` + `test:customer` green.

## L. Deliverables

- File changes; ARB counts; golden diffs; test evidence; known limitations.

## M. Completion gate

Stop after this phase. Do not begin Phase 17 until explicitly instructed.
