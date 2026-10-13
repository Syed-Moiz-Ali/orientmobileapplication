# PHASE 15B — Customer: Bookings, Garage & Vehicle Form

## A. Phase identity

- **Phase number:** 15B (part 2 of 2; split from the former Phase 15)
- **Title:** Customer Bookings Tab, Vehicles/Garage Tab and Add/Edit Vehicle Form
- **Objective:** Redesign the customer's records surfaces — appointments, garage and the vehicle form — with honest offline recovery UX, preserved identity reconciliation, and complete state coverage.
- **Priority:** High
- **Dependencies:** Phase 15A (shell/nav must exist first)
- **Estimated scope:** Large

## B. Repository context

Files (relative to `apps/customer_app/`):

- Bookings: `lib/features/customer/presentation/widgets/customer_bookings_tab.dart`
  (sections: upcoming/past; `_NoBookings`; `_FailedBookingsSection`),
  `customer_booking_item.dart`, `customer_failed_booking_item.dart`
  ("NOT SENT" rows with retry/remove), `customer_bookings_skeleton.dart`.
- Vehicles: `widgets/customer_vehicles_tab.dart` (`_VehiclesSkeleton`,
  `_LoadFailure`, `_NoVehicles`, `_UnmatchedDeleteRecovery`),
  `customer_vehicle_record.dart` (`_SyncFailedNotice`, `_DeleteFailedNotice`).
- Vehicle form: `add_vehicle_view.dart` (`_Section`×3, `_Note`, `_SaveBar`;
  inline field errors; save-error notice; save-bar spinner) — routes
  `/add-vehicle`, `/edit-vehicle/:id`.
- Offline core: `lib/core/local/vehicle_identity_store.dart`,
  `vehicle_sync_handler.dart`, `sync_providers.dart`; failed-booking support in
  `presentation/support/*` (`failed_booking_sync.dart`, `failed_vehicle_delete.dart`,
  `vehicle_booking_decision.dart`, `customer_bookings_presentation.dart`).
- Providers: `providers/customer_providers.dart` (bookings load + Hive fallback).
- Navigation in: Home quick actions/garage summary, tab bar, booking flow
  ("add vehicle" handoff from Phase 16).
- Tests: `customer_bookings_tab_test.dart`, `customer_vehicles_test.dart`,
  `customer_vehicle_form_test.dart`, `customer_vehicle_identity_test.dart`,
  `customer_failed_booking_test.dart`, `customer_failed_delete_test.dart`,
  `vehicle_booking_decision_test.dart`; goldens. **Identity/failed-* tests must
  pass unmodified** (behavioral contracts).

## C. Design objectives

1. **Bookings = appointments + honest attention.** Sections: "Needs attention"
   (failed/queued bookings with retry/remove — behavior preserved), Upcoming,
   Past; rows: service, vehicle plate chip, date/time, status pill, next
   action. Empty state offers Book service.
2. **Vehicles = the garage.** Vehicle cards: plate chip, make/model/year,
   mileage if known, actions (Book service, View booking, Edit, Remove with
   confirm); failed sync/delete recovery notices visually integrated (calm
   panels, not red walls); `_UnmatchedDeleteRecovery` preserved.
3. **Add/edit vehicle (T4):** 3 grouped sections + note + sticky save bar;
   inline validation; save-error panel; same repository calls incl. identity
   reconciliation; push/pop contracts unchanged.
4. **Offline honesty:** "NOT SENT" rows, retry/remove flows, sync-failure
   recovery notices — same triggers, same methods, restyled only.
5. **Skeleton standardization:** replace ad-hoc skeletons with `AppSkeleton`
   compositions without behavior change (reduced-motion preserved).

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `CustomerBookingsTab` | needs-attention → upcoming → past | open detail, book, retry/remove failed | skeleton, empty, refresh notice |
| `CustomerVehiclesTab` | garage cards | book for vehicle, view booking, edit, remove (confirm), retry sync/delete | skeleton, load failure, empty, recovery notices |
| `AddVehicleView` | sections → save bar | validate, save, add-from-flow | inline errors, busy, save-error panel |

Route contracts unchanged: `/add-vehicle`, `/edit-vehicle/:id`, booking detail
navigation from rows, booking flow handoff into the form.

## E. Responsive specifications

- **Compact:** cards full width; form single column with sticky bar clearing
  keyboard; 320 px: plate chips never overflow; no horizontal scroll.
- **Medium:** bookings 2-column card grid where space allows; vehicles 2-up
  grid; form two-column (fields | vehicle summary card).
- **Expanded/large:** vehicles 3-up grid; bookings table-like cards with
  columns; form capped ~720 px with summary.
- 1.3× scale: cards grow cleanly; form labels wrap.
- RTL: rows/cards mirror; plate chips keep Latin content; direction icons flip.

## F. Localization and RTL

- All strings localized (`customerBookings*`, `customerVehicles*`,
  `customerVehicleForm*`) EN+AR; dates/times localized; identifiers Latin.
- RTL: full mirroring incl. recovery notice copy/actions; confirmation dialogs
  mirror.
- Tests: the listed suites run EN+AR; RTL assertions for rows/form; 320 px
  clean.

## G. Design system integration

- Use: `AppResponsivePage`, `AppCard`/grouped-surface recipe, `AppRecordRow`,
  `CustomerPlateChip`, `StatusPill`, `AppButton`, `AppTextField` (+identifier
  variant per Phase 02), `AppActionBar` (save bar), `AppInfoPanel` (recovery
  notices), `AppSkeleton`, `EmptyState`, `ErrorView`, `AppConfirmationDialog`
  (remove vehicle/booking), `showAppModalSheet` if a sheet is warranted.
- Retire ad-hoc skeleton widgets where replaced without behavior change.

## H. Technical implementation

- Modify: bookings tab + item widgets; vehicles tab + record; add-vehicle view;
  customer ARB; tests/goldens.
- Preserve: bookings/vehicles provider interactions, failed-booking
  retry/remove methods, vehicle identity reconciliation flow
  (`customer_vehicle_identity_test.dart` unmodified), failed-delete recovery,
  `vehicle_booking_decision.dart` logic, sync queue handlers.
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Identity reconciliation, failed-sync and failed-delete recovery contracts
  pass **unmodified** tests.
- Form submission payloads and push/pop behavior unchanged.
- Booking row actions/navigation unchanged; "Needs attention" triggers
  unchanged.
- Phase 16's booking flow can still open the form and receive the result.

## J. Testing requirements

- `melos run analyze:customer`; `melos run test:customer`.
- Update the five listed suites for EN+AR, RTL, 320/390/768/1280, 1.3×; keep
  identity/failed-* tests behaviorally unmodified (only copy/layout asserts).
- New: bookings attention-section ordering, garage recovery visuals,
  form validation/error panel.
- Goldens: bookings/vehicles/form regenerated; AR goldens for vehicles.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the customer app and visually review bookings,
   garage and the vehicle form incl. all recovery notices.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px).
3. **Locales** — EN-LTR and AR-RTL renders; rows, plate chips and form reviewed
   in AR.
4. **State matrix** — bookings empty/populated/failed rows; garage empty/load
   failure/delete recovery/sync recovery; form pristine/invalid/saving/error.
   Realistic booking/vehicle fixtures (UAE plates, service names).
5. **Interaction verification** — retry/remove failed booking, retry sync,
   recovery flows, remove vehicle confirm, form save + error recovery, edit
   mode prefill.
6. **Accessibility** — 1.0–1.3× scale clean; ≥48 px actions; semantics on
   recovery panels; contrast sampled.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_15B/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D surfaces redesigned on shared grammar; skeleton standardization
   done; dead code from 15A not re-introduced.
2. Identity/failed-* behavioral tests unmodified and green.
3. EN/AR complete; RTL correct; responsive per E.
4. `melos run analyze:customer` + `test:customer` green; J2 evidence attached.

## L. Deliverables

- File changes; ARB counts; golden diffs; test evidence; known limitations.

## M. Completion gate

Stop after this phase — 15A + 15B close the former Phase 15. Phase 16 (booking
flow) follows. Do not begin until explicitly instructed.
