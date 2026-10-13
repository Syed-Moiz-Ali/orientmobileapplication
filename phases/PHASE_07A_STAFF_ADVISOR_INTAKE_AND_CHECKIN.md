# PHASE 07A — Staff: Advisor Intake & Check-in

## A. Phase identity

- **Phase number:** 07A (part 1 of 2; split from the former Phase 07)
- **Title:** Advisor Vehicle/Customer Intake, Scan & Check-in (capture flow before inspection)
- **Objective:** Redesign the advisor's data-capture flow — the most offline-critical part of the staff app — into a fast, sectioned, autosaved experience with trustworthy media/signature handling and honest queue states, preserving Hive persistence, sync payloads and every route/extra contract.
- **Priority:** High
- **Dependencies:** Phases 01–06
- **Estimated scope:** Very Large (this is why the former Phase 07 was split)

## B. Repository context

Files (relative to `apps/staff_app/`):

- `lib/features/advisor/presentation/pages/vehicle_customer_view.dart`
  (~3 200 lines): sections `_CustomerDetailsSection`, `_VehicleDetailsSection`,
  `_AdditionalInfoSection`, `_JobDescriptionTable`; doc/video/photo pickers;
  signature capture; `_JobDescriptionAudioDialog`; inspection prompt sheet;
  Hive local save + sync queue on network failure; `_isCreatingJobCard`,
  `_fieldErrors`; route `/vehicle-customer` (extra `{bookingId}` optional);
  also pushed from home.
- `.../pages/scan_vehicle_view.dart`: `mobile_scanner`, torch toggle, manual
  entry, permission-denied state (`openAppSettings`), `scanMode` constructor.
- `.../pages/advisor_vehicle_checkin_view.dart`: 2-step wizard (odometer, fuel
  `SegmentedButton`, notes, damage add), damage `AlertDialog`; route
  `/advisor/check-in`, extra `{bookingId, customerName, vehicleInfo}`.
- `.../widgets/select_brand_sheet.dart` (brand/model pickers + model-year dialog).
- `.../widgets/advisor_signature_pad.dart` (CustomPainter canvas).
- `.../widgets/vehicle_customer_shared_widgets.dart` (SectionCard, FieldLabel,
  AdvisorTextField, AdvisorDropdown, AdvisorToggleTile, MoreLessLink) — to be
  replaced by 03A primitives in this phase.
- Offline core: `core/local/sync_providers.dart`, `recoverUnsyncedAdvisorIntakes()`
  in `main.dart`; payload tests in `packages/shared_core/test/advisor_intake_payload_test.dart`.
- Tests: `test/vehicle_customer_intake_layout_test.dart`, advisor goldens.
- **Inspection screens are Phase 07B** — this phase ends at the point where the
  intake prompts for inspection; do not modify inspection views here.

## C. Design objectives

1. **Intake as a guided, sectioned flow** (T4/T5 hybrid): section progress
   (Customer → Vehicle → Documents & media → Job description → Signature →
   Save), collapsible section cards, inline validation on blur, sticky action
   bar with honest status: `Saving locally…` → `Queued (offline)` → `Sent`.
   Replace bare catches with explicit, retryable error states.
2. **Assisted vehicle entry:** plate/VIN inputs with identifier styling (LTR
   content, per Phase 02 variant); brand/model selection sheets with search +
   recents + clear "Other" path; mileage numeric; fuel segmented.
3. **Trustworthy media/documents:** `AppMediaUploadShell` rows with real local
   previews, per-item pending/failed state, retry/remove; section counts
   visible. Camera/gallery/file sources unchanged (image_picker/video_player
   behaviors preserved).
4. **Signature first-class:** full-width signature surface in a focused sheet;
   clear/confirm; saves bytes exactly as today; visible captured preview with
   redo.
5. **Scan → prefill loop:** scanner restyled (framing guides, torch, manual
   fallback, permission explanation with "Open settings"); scan result confirms
   what will be filled before returning.
6. **Check-in wizard:** 2 steps with progress, large numeric odometer entry,
   fuel segmented, notes, damage list add/remove rows; submit busy state.
7. **Offline truth:** queued intake renders the pending-sync chip and the
   recovery path (`recoverUnsyncedAdvisorIntakes`) is reflected honestly — no
   fake success, no silent failure.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `VehicleCustomerView` | progress rail → 5 section cards → sticky save bar | fill sections, docs/media, signatures, audio note, save (online→queue fallback), inspection prompt | per-field errors, saving/queued/sent, offline notice, recovered-intake state |
| `ScanVehicleView` | camera frame + guidance → torch → manual entry | scan (returns code), torch, manual submit, permission handling | permission denied (+open settings), scanning |
| `AdvisorVehicleCheckinView` | step progress → odometer/fuel/notes → damage list → submit | add/remove damage rows, fuel segment, submit | validation, submitting, success/failure panel |
| `SelectBrandSheet` / `SelectModelSheet` / model-year dialog | searchable list + recents → confirm | search, select, clear | empty search |
| `AdvisorSignaturePad` | focused sheet surface | draw, clear, confirm | — |

Route/extra contracts: `/vehicle-customer` extra `{bookingId}`; `/scan-vehicle`
`scanMode`; `/advisor/check-in` extra map — unchanged.

## E. Responsive specifications

- **Compact:** single column; section cards stack; sticky save bar clears
  keyboard + safe area; damage list rows; media grid ≥3 columns with ≥88 px
  cells; no overflow at 320 px.
- **Medium (≥600):** intake two-column (form 60 % | live vehicle/customer
  summary 40 %); check-in two columns (fields | damage list).
- **Expanded/large:** intake three-pane option (section outline | form |
  summary) capped at `contentStandard`; signature/scanner stay focused modals
  ≤640 px.
- Text scale 1.3×: section headers wrap; no clipped chips.

## F. Localization and RTL

- All strings localized (staff unit, `advisorIntake*` / `advisorCheckIn*` /
  `advisorScan*` namespaces) EN+AR: section titles, field labels/hints, error
  copy, media labels, signature instructions, fuel options, dialog copy.
- RTL: progress rail mirrors, section rows align end, signature sheet
  alignment mirrors; identifier fields keep LTR content (Phase 02 rule).
- Numbers: odometer/mileage tabular; VIN/plate Latin; dates localized.
- Tests: intake layout test + scan/check-in widget tests in EN+AR; RTL
  assertions; 320 px clean.

## G. Design system integration

- Use: `AppStepProgress`, `AppFormSection`/`AppFormField`/`AppFormPanel`,
  `AppTextField` (+identifier variant), `AppDropdownButton` + selection sheets
  (03A), `AppMediaUploadShell`, `AppButton`, `AppActionBar`, `AppInfoPanel`
  (offline/queue notices), `pending-sync chip` (03A), `AppSkeleton`, `EmptyState`,
  `ErrorView`, `showAppModalSheet`, `AppConfirmationDialog` (discard guards).
- Replace and delete `vehicle_customer_shared_widgets.dart` when fully
  superseded (confirm zero references).
- `inspection_widgets.dart` legacy kit remains for Phase 08 — untouched here.
- No new tokens expected; gaps follow README §8.

## H. Technical implementation

- Modify: the page/widget files listed in B; staff ARB; tests/goldens.
- Preserve: intake payload shape, Hive keys, queue operations,
  `recoverUnsyncedAdvisorIntakes()` behavior, scanner return contract,
  check-in submit contract, media byte handling.
- No route/extra changes; no new packages (`mobile_scanner`, `image_picker`,
  `audioplayers` already present).

## I. Functional preservation

- Payload/Hive/queue tests (`advisor_intake_payload_test.dart`,
  `vehicle_damage_persistence_test.dart`) must pass **unmodified**.
- Every existing callback/action still works; offline save path calls the same
  repository/queue methods; UI reflects their real results.
- Existing intake tests updated only for intentional copy/layout changes.

## J. Testing requirements

- `melos run analyze:staff`; `melos run test:staff`; `melos run test:core`
  (payload tests).
- Update/extend `vehicle_customer_intake_layout_test.dart` (EN/AR,
  320/390/768/1280, 1.3×); new tests: scan permission path, check-in validation
  + submit states, media pending/failed states, signature capture/redo, brand
  picker empty search.
- Offline simulation: force failure on save → queued state renders → recovery
  path unchanged (test).
- Goldens for intake/check-in/scan regenerated + AR goldens added.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the intake → check-in flow end to end and visually
   review each screen; no screen may be signed off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px).
3. **Locales** — EN-LTR and AR-RTL renders; form alignment, identifier fields
   and signature sheet reviewed in AR.
4. **State matrix** — pristine/focused/invalid sections, saving/queued/sent,
   media pending/failed, scanner permission denied, check-in partial/complete.
   Fixtures use realistic customer/vehicle data (UAE plates, plausible names).
5. **Interaction verification** — section collapse, add/remove damage, pickers,
   signature clear/confirm, discard guards, scan return.
6. **Accessibility** — 1.0–1.3× scale clean; ≥48 px controls; semantics on
   section headers and upload rows; contrast sampled on error states.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_07A/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D screens redesigned on shared primitives; no silent failure remains
   in touched files.
2. Payload/Hive/queue/check-in contracts unchanged (unmodified tests prove it).
3. EN/AR complete; RTL correct; responsive per E; 320 px clean.
4. `melos run analyze:staff` + `test:staff` green; J2 evidence attached.

## L. Deliverables

- File changes; deleted local kit(s) with proof; ARB counts; golden diffs; test
  evidence; known limitations.

## M. Completion gate

Stop after this phase. Phase 07B (inspection) follows. Do not begin Phase 07B
until explicitly instructed.
