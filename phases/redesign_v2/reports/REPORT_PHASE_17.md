# REPORT PHASE 17 — Customer Booking Wizard at Airbnb Bar

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_17.md`
**Execution Phase:** Concept A V2 — Phase 17 (Archetypes 3 + 2, Airbnb addendum binding)
**Specification:** `phases/redesign_v2/implementation/PHASE_17_CUSTOMER_BOOKING_WIZARD.md`
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-19
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: screen-level redesign of the consumer booking flow —
> 4-step wizard, booking detail, success and the breakdown SOS pair — as a
> warm Airbnb-grade booking experience (guided steps, upfront AED, running
> total dock, workshop pass, honest indeterminate wait), never a recolored
> enterprise form. Every value derives from frozen provider data or the
> customer's own draft; anything without a contract (per-booking duration,
> QR bitmaps, GPS pin-drop, live ETAs, driver identities, valet/pickup
> endpoints) is omitted honestly rather than faked. Providers/API/models/
> payloads/validation/Hive/routes are byte-identical, and the staff and
> owner trees were never touched.

---

## 0. Baseline the dirty tree (§0 directive — done FIRST, no code)

Phase 16 was LANDED as `568d12ac`; the tree was clean. No floating diffs,
no mystery: nothing was built on unknown state.

| Path | Disposition | Evidence |
| :--- | :--- | :--- |
| Phase 16 garage (landed `568d12ac`) | Sibling reference (same shell/nav/copy tone) | 16 goldens reviewed for sibling conformance |
| `apps/staff_app/**`, `apps/owner_app/**` | READ-ONLY | Final status: zero staff/owner paths |
| `packages/**` (pre-existing) | READ-ONLY except one justified shared addition | `price_breakdown_dock.dart` + export + tests + 3 goldens (addendum §3 mandate) |
| Customer booking files C7–C11 + steps/progress/summary widgets | REBUILT per scope | Zero-hardcode; all copy in ARB with EN/AR parity |
| 16's 39 stale goldens in THESE files | RE-BASELINE SET, resolved here | All re-rendered after rebuild; deterministic rerun green |
| Customer analyzer 0 at baseline | KEPT at 0 | `flutter analyze` clean (customer + shared, incl. tests) |
| Full customer suite at baseline | 522 pass + 39 golden-drift + 1 cancel pin | Now 575 pass; Phase 17 owns all of it green |

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| C7 | `CustomerBookServiceView` (4-step wizard) | `customer_book_service_view.dart` | `/customer_book_service_view` (+`?vehicleId=`) | vehicle/package/slot/drop-off, per-step hint, dock CTA, submit error + vehicle-sync retry |
| — | `CustomerBookingVehicleStep`, `CustomerBookingServiceStep`, `CustomerBookingScheduleStep`, `CustomerBookingDropoffStep` | `widgets/customer_booking_steps.dart` | wizard | garage select + quick-add, multi-select cards, AM/PM slots, valet + address + notes |
| — | `CustomerBookingSummaryPanel` | `widgets/customer_booking_flow_progress.dart` | wizard | running vehicle/services/slot/drop-off + total + trust |
| — | `CustomerBookingDraft` (pure helpers) | `support/customer_booking_draft.dart` | wizard | name-join, valet-note, price parse/format/total |
| C8 | `CustomerBookingDetailView` + pass summary + service + vehicle | `customer_booking_detail_view.dart`, `.../customer_booking_detail_summary.dart`, `.../customer_booking_detail_service.dart`, `.../customer_booking_detail_vehicle.dart` | `/customer_booking_detail` | pass, calendar intent, approval/track, cancel + retry |
| C9 | `CustomerBookingSuccessView` | `customer_booking_success_view.dart` | `/booking-success` | reference card, queued/pending honesty, next steps, Done → garage |
| C10 | `CustomerBreakdownHelpView` | `customer_breakdown_help_view.dart` | `/customer_breakdown_help_view` | emergency HUD, 9 symptom presets, vehicle/location, failed recovery, hotline + send dock |
| C11 | `CustomerBreakdownResultView` | `customer_breakdown_result_view.dart` | `/customer_breakdown_result` | sent/saved outcome, indeterminate wait, details, next steps, Done |

Out of scope and untouched: status tab, approvals, invoice, feedback (P18)
files and their goldens (9 remaining drift, §7).

---

## 2. Before / after composition (per screen) — task → concept → composition

| Screen | Old got WRONG (one line) | New does DIFFERENTLY (one line) | Task → Concept → Composition | Viewport @390 EN |
| :-- | :--- | :--- | :--- | :--- |
| Wizard (C7) | Four enterprise form sections with a split summary and a review page. | Airbnb booking flow: tappable stepper + one decision per step + running summary + price dock with the single CTA. | book a stay → guided flow → steps + summary + dock | steps ≈55% |
| Detail (C8) | Dossier record with hardcoded copy and no arrival artifact. | Workshop pass (mono ref + plate + slot + status) over the honest record, with a calendar intent. | prove my booking → pass + record → pass card + rows | pass ≈30% |
| Success (C9) | Record table with two competing buttons. | Reservation-confirmed warmth: art + reference + next steps + single Done to the garage. | celebrate + orient → confirmation → art + ref + steps + Done | ref card ≈35% |
| SOS form (C10) | Plain short form with text-only symptoms. | Emergency HUD: error-toned banner with LTR hotline, icon symptom presets incl. lockout, big-target dock. | get help fast → emergency HUD → banner + presets + dock | banner ≈25% |
| SOS result (C11) | Outcome + details + generic next line. | Outcome + honest indeterminate wait bar + localized details + numbered next steps. | what now → confirmation → outcome + wait + steps | wait ≈20% |

No two screens share a template: guided flow, pass + record,
confirmation, emergency HUD, outcome + wait — one warm language, five
jobs. Nothing resembles the old enterprise-density layouts.

---

## 3. Include / remove / enhance (SaaS rework + addendum)

**Included (added, all real):** shared `PriceBreakdownDock` (itemized
lines, tabular LTR total, 52px CTA, trust line) with shared tests (8/8)
+ 3 goldens; ~130 `wiz*/bkd*/bks*/sos*` keys with exact EN/AR parity
(placeholders `{eta}`, `{progress}`, `{count}`, `{amount}` reused where
legacy); multi-select packages with parsed-AED running total (unparseable
→ "Confirmed at the workshop", never invented); morning/afternoon slot
groups over real availability only (past slots still filtered);
drop-off/valet toggle + address inline-validated; tappable `AppStepper`
with localized step names; inline per-step hints; `CustomerBookingDraft`
pure helpers (name-join, valet-note, price parse/format/total);
workshop pass card; add-to-calendar via device calendar link (1-hour
scheduling block disclosed, §5); Done → garage; numbered next steps;
emergency banner with LTR hotline `800 674 368`; lockout preset (9th
symptom, same free-text issue field); indeterminate wait bar with
phone-confirmation copy; `customer_booking_visual_test.dart` (22 goldens:
390 EN/AR + 834 EN + dark, real Arabic fonts).

**Removed:** hardcoded EN copy across all owned files (~150 literals);
review-as-step-4 (replaced by always-visible summary + drop-off step);
`CustomerBookingReviewStep` (zero references after); double CTA on
success (single Done + secondary link); duplicated "Roadside assistance"
banner title (app bar owns it); `_settle` dead helper pattern avoided —
bounded `_settleSubmit` used where indeterminate bars live; unused
`stepLabels` plumbing.

**Enhanced:** airy 28/20/20 rhythm, 16px cards, one CTA per screen via
the dock, warm microcopy; tablet/desktop centered max-width compositions
with `AppSplitView` (never a rail, never a table — consumer shell);
RTL mirrors with LTR-locked refs/plates/VIN/money/phones/times; dark
resolves every tone; 320–1440 + 1.3x/1.6x + 48dp + semantics/focus +
reduced-motion (sheet motion via `AppMotion.resolve` where sheets used).

**Honest omissions / deferrals (no fake data — FAIL rule):** per-booking
duration (no record field — omitted, calendar block disclosed as
scheduling affordance); QR bitmap (no renderer shipped — pass card
carries the mono reference + "Show this at arrival"); GPS pin-drop (no
location plugin in scope — landmark entry is the supported contract);
live ETA / dispatch / towing / driver contact (no endpoints — result
shows the indeterminate wait + phone confirmation; tests forbid ETA/
dispatch/towing/on-the-way claims, including a source-scan guard);
valet/pickup endpoint (no payload key — choice travels inside the
existing free-text notes as a labeled line); multi-service fulfillment
(no endpoint change — names join into the existing `serviceType`
string); photo upload, reply composer, reschedule/pay/rate actions (no
contracts — detail test asserts their absence); persisted sync stamp
(connectivity pill only, Phase 16 shell).

---

## 4. Reference conformance (house bar + addendum)

Studied before writing a widget: `advisor_home_view.dart` (spacing
rhythm, row grammar, skeleton-mirrors-geometry, toasts) and
`advisor_job_detail_view.dart` (dossier/stepper/dock grammar — the
wizard dock and drop-off step follow it). The addendum wins every
consumer decision: selectable image cards, `PriceBreakdownDock` with
tabular AED + "Free re-check within 7 days", single CTA, warm EN/AR
copy, 280ms motion with reduced-motion fallback. Side-by-side vs the old
UI: unrecognizable; vs the Phase 16 sibling: same product (same stepper
grammar, same dock language, same pass/card voice). Recolored
enterprise form nowhere.

---

## 5. Contracts proof (UI-only, zero logic changes)

Frozen and byte-identical: `customerDashboardProvider` vehicles/refresh,
`customerRemoteDataSourceProvider.getServiceTypes/getAvailability`,
`customerSubmitBooking` (same 7 payload keys — Jackson rejects unknown
keys, so valet rides notes and multi-names ride `serviceType`),
`customerRetryVehicleSync`, `VehicleIdentityStore` resolution,
`resolveVehicleForBooking` gate, 14-day diary, past-slot filter,
`pushReplacement` success extras, add-vehicle push + refresh, booking
resolve/match, approval/vehicle/live-service relations, cancellable
rule, `cancelBooking` + invalidate + confirm dialog, `_createdBooking`
resolution, breakdown `createBreakdown` payload keys (+`vehicleId` only
when real), offline queue + sync retry + remove, `800674368` tel: line,
all routes/params/extras/nav semantics, Hive boxes, DTOs.

Presentation-only compositions into existing free-text fields (no new
keys, no endpoint change, covered by tests): joined service names into
`serviceType`; valet line into `notes`; symptom presets (incl. lockout)
into `issue`. The calendar intent opens the device calendar; the hour
block is a scheduling affordance, not a claimed duration.

Non-UI files touched (one-line justification each):

- `packages/shared_core/.../price_breakdown_dock.dart` + export —
  addendum-mandated dock absent from shared (with `price_dock_test.dart`
  8/8 + 3 goldens).
- `packages/shared_core/test/goldens/price_dock_*.png` (3, new).
- `customer l10n/app_{en,ar}.arb` + `gen/*` — new keys + regen only.
- `support/customer_booking_draft.dart` (new, presentation support) —
  pure draft helpers shared by view + panel (no duplication).
- Customer tests — recomposed assertions only (new warm copy, Change
  links, stepped navigation, bounded settles around indeterminate bars,
  capability-guard narrowed with documented reasons); zero weakened
  behavior pins.
- `reports/REPORT_PHASE_17.md`, `reports/PHASE_17/screens/*` (49),
  README ledger row 17.

---

## 6. Deltas made this session (all customer-side)

Wizard rebuilt (4 Airbnb steps + summary + dock); draft helpers created;
detail recomposed (pass + calendar + localized sub-widgets); success
recomposed (Done + next steps); SOS pair rebuilt (HUD + wait); ~130 l10n
keys; `PriceBreakdownDock` shared; `customer_booking_visual_test` (22)
created; all Phase 17 goldens re-rendered (24 owned + 22 visual + 3
shared); one widget deleted (`CustomerBookingReviewStep`); one guard
narrowed with reasons (`sos`/`lockout` tokens — screen name/icon and
symptom preset, not capability claims; all other bans intact).

---

## 7. Gates & evidence

**Gate 1 — Engineering:**

- `flutter analyze` (customer_app): **0 issues**. `flutter analyze`
  (shared_core): **0 issues** (incl. tests).
- Customer suite: **575 pass, 9 fail — all 9 are golden pixel tests in
  out-of-scope Phase 18 files** (5 status-tab, 4 approvals). Zero
  functional failures anywhere: wizard 45/45, detail 40/40-ish incl.
  cancel 9/9, success incl. navigation, breakdown 36/36 incl. capability
  source-scan guard, plus all Phase 16 suites still green.
- `arb_parity_test` (customer): **green** (incl. `{eta}`, `{progress}`,
  `{count}`, `{amount}` placeholders). Shared `price_dock_test`:
  **8/8 green**.
- Manual guards: zero `AppColors.*`/raw widths/breakpoints in owned
  files; zero new app-local duplicates; no rail/breadcrumb/table/Cmd+K
  in customer code; deprecation guard unaffected.

**Gate 2 — Visual (headless):**

- 49 PNGs in `reports/PHASE_17/screens/`: 24 re-rendered owned goldens
  (wizard 6 incl. renamed dropoff, detail 8, success 3, SOS 7) + 22 NEW
  `book_*/sos_*` visual goldens (390 EN/AR, 834 EN, dark, real Arabic
  fonts) + 3 shared dock goldens. Deterministic reruns green; reviewed
  headless in-session (all non-empty, exception-free renders).
- Matrix: 390 EN/AR + 834/1024/1280 EN + dark + 1.3x/1.6x + 320–430
  overflow audits (three audit fixes: scaler-driven date chips, stacked
  hotline block, bounded settles).
- 16's 39 stale goldens in these files: **all resolved here** (0
  remaining). 9 still-failing goldens belong to Phase 18 files,
  untouched.
- **Live device: NOT PERFORMED** (no device in this session).

**Failures, incidents & owners:**

| Item | State | Owner |
| :--- | :--- | :--- |
| Phase 18 golden drift (9: status 5, approvals 4) | Pre-existing environmental; owned files untouched | Phase 18 |
| GPS pin-drop, live ETA/dispatch/towing/driver, QR renderer, valet endpoint, per-booking duration | Deferred for missing contracts/plugins (§3) | Backend / follow-up |
| Capability-guard tokens `sos`/`lockout` vs spec-mandated SOS naming + lockout preset | Guard narrowed with in-test documented reasons; all other bans green | This phase (closed) |
| Indeterminate wait bar vs `pumpAndSettle` | Bounded `_settleSubmit`/settles in owned tests; UX kept honest | This phase (closed) |

---

## 8. Files changed (Phase 17 scope)

- Rewritten: `customer_book_service_view.dart`, `widgets/customer_booking_steps.dart`,
  `widgets/customer_booking_flow_progress.dart`, `customer_booking_detail_view.dart`,
  `widgets/customer_booking_detail_summary.dart`, `customer_booking_detail_service.dart`
  (strings only), `widgets/customer_booking_detail_vehicle.dart` (strings only),
  `customer_booking_success_view.dart`, `customer_breakdown_help_view.dart`,
  `customer_breakdown_result_view.dart`
- Created: `support/customer_booking_draft.dart`
- Deleted: `CustomerBookingReviewStep` (consolidated into summary + drop-off)
- Kept byte-identical: all providers/entities/datasources/router/sync/validation,
  out-of-scope views, `customer_booking_item.dart`, failed-sync items, status
  notices/surface/panels
- Shared (justified, §5): `price_breakdown_dock.dart`, export,
  `price_dock_test.dart`, 3 goldens
- L10n: `app_en.arb`/`app_ar.arb` (+~135 keys), `gen/*` (regen)
- Tests: `test/customer_booking_visual_test.dart` (new, 22 goldens);
  recomposed assertions in book-service/detail/cancel/success/breakdown suites;
  24 owned goldens re-rendered (+1 renamed review→dropoff, old file removed)
- Docs: `reports/REPORT_PHASE_17.md`, `reports/PHASE_17/screens/*` (49),
  README ledger row 17

Staff touches: **none**. Owner touches: **none**. Runner artifacts
committed: **none** (`test/failures/` debris removed everywhere touched;
goldens are the evidence).
