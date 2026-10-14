# PHASE 07A — Staff: Advisor Intake & Check-in: Completion Report

- **Date:** 2026-10-14
- **Phase:** 07A — Advisor Vehicle/Customer Intake, Scan & Check-in
  (`phases/PHASE_07A_STAFF_ADVISOR_INTAKE_AND_CHECKIN.md`)
- **Status:** **IMPLEMENTATION COMPLETE — awaiting product-owner review**
- **Toolchain:** Flutter 3.35.7 stable · Dart 3.9.2 · Windows dev machine
- **Authorities:** `00_DESIGN_SYSTEM_SPEC.md` (§7 registry, §12 form UX, §14
  templates T4/T5), `00_VISUAL_DIRECTION.md`, `00_RESPONSIVE_STRATEGY.md`,
  `00_LOCALIZATION_RTL_STRATEGY.md`, Phase 00 prototype (read-only, 0 changes).

---

## 1. Screens and workflows redesigned

| Screen | File | Redesign delivered |
|---|---|---|
| `VehicleCustomerView` (intake) | `.../pages/vehicle_customer_view.dart` | `AppTopBar` + discard guard (`PopScope` + `AppConfirmationDialog`) → intro panel → `AppStepProgress` intake rail (Customer → Vehicle → Media & docs → Job → Signature → Save) → **collapsible section cards** (Customer, Vehicle, Body condition, Documents & media, Job description, Signatures) → **live summary panel** (≥600 px) → sticky `AppActionBar`. Inline validation on submit with expand-and-scroll to the first error; honest save states (`Saving locally…` → `Queued (offline)` / `Sent` via `PendingSyncChip`); inspection prompt rebuilt on the shared surface. |
| `ScanVehicleView` | `.../pages/scan_vehicle_view.dart` | Camera surface + framing guides + animated scan line; themed Plate/VIN/QR switcher; localized hint per mode; torch toggle; **permission-denied state** with explanation + "Open settings" (permanently denied) and "Grant permission"; **scan-result confirmation** ("Use this value" / rescan) before returning; manual-entry fallback with validation. |
| `AdvisorVehicleCheckinView` | `.../pages/advisor_vehicle_checkin_view.dart` | Two-step `AppStepProgress` wizard (`Odometer & fuel` → `Document condition`); identity `AppInfoPanel`; `AppFormPanel` sections; numeric odometer (identifier/digits), themed fuel `SegmentedButton`, notes; damage-area grid + recorded-damage rows with remove + empty state; sticky `AppActionBar` with busy submit and localized success/failure toasts. |
| `SelectBrandSheet` / `SelectModelSheet` / model-year dialog | `.../widgets/select_brand_sheet.dart` | Rebuilt on the shared modal grammar: drag handle, localized title, `AppSearchField`, ≥48 px select rows with selected semantics, localized no-match empty state; localized model-year dialog. Return contracts unchanged. |
| `AdvisorSignaturePad` | `.../widgets/advisor_signature_pad.dart` | Focused signature sheet: instruction, full-width signing surface (empty hint), `Clear`/`Use signature` on `AppButton`; PNG byte contract unchanged. |

Deleted: the superseded local kit
`.../widgets/vehicle_customer_shared_widgets.dart` (SectionCard, FieldLabel,
AdvisorTextField, AdvisorDropdown, AdvisorToggleTile, MoreLessLink) — confirmed
**zero references** before deletion.

---

## 2. Files changed

All under `apps/staff_app/` unless noted:

**Pages** — `vehicle_customer_view.dart` (rewritten, ~2 900 → ~3 170 lines but
~1 900 lines of hand-rolled widget code replaced by shared primitives + thin
adapters), `scan_vehicle_view.dart` (rewritten), `advisor_vehicle_checkin_view.dart`
(rewritten).

**Widgets** — `select_brand_sheet.dart` (rewritten), `advisor_signature_pad.dart`
(rewritten), `vehicle_customer_shared_widgets.dart` (**deleted**).

**Localization** — `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` +
regenerated `lib/l10n/gen/**`.

**Tests** — `test/vehicle_customer_intake_layout_test.dart` (rewritten, 6 → 17
tests), `test/advisor_phase07a_visual_test.dart` (**new**, 13 goldens),
`test/staff_experience_test.dart` (one over-specific finder corrected),
`test/goldens/intake_*.png`, `checkin_*.png`, `scan_*.png` (13 new).

**Shared package** — `packages/shared_core/lib/src/widgets/app_text_field.dart`
(additive `Widget? prefix` slot — documented in `00_DESIGN_SYSTEM_SPEC.md` §7).

**Docs** — `phases/README.md`, `phases/00_SCREEN_COVERAGE_MATRIX.md`,
`phases/00_DESIGN_SYSTEM_SPEC.md`.

*Not touched:* any provider, entity, route/`extra`, DTO, Hive key, sync/queue
operation, `advisor_providers.dart`, `inspection_provider.dart`, the Phase 07B
inspection views, the Phase 08 legacy kit, `apps/design_prototype/**` (0 changes).

---

## 3. Old-to-new UX improvements

- **Intake is a guided flow, not a wall of fields.** A 6-step progress rail and
  collapsible sections give a clear progression; Customer + Vehicle open by
  default (required data first), optional sections stay calm until opened.
- **Reduced visual complexity.** ~1 900 lines of bespoke `Container`/`BoxDecoration`
  scaffolding replaced by `AppCard`/`AppFormPanel`/`AppFormField`/`AppTextField`
  (identifier variant + always-visible `prefix`) /`AppDropdownButton` /
  `AppMediaUploadShell` / `AppDateSelectorShell`. No raw hex or magic radius
  remains in the touched files.
- **Live context.** A two-column live summary (customer, vehicle, section
  completion) appears at ≥600 px so the advisor sees what will be submitted.
- **Honest save feedback.** The `NEXT`/`Create` bar is now an `AppActionBar`;
  the inspection prompt shows a `PendingSyncChip` (`Sent` vs `Queued (offline)`)
  instead of the previous binary success/local copy.
- **Accessible error recovery.** Required-field errors render inline under the
  field, the relevant sections force-expand, and the view scrolls the first
  error into view.
- **Data-loss protection.** Back (app bar or system) on a dirty form opens a
  localized discard confirmation.
- **Trustworthy scan.** Permission denial explains itself and routes to settings;
  a detected code is confirmed before it is returned (no silent pop).
- **Consistent check-in.** The bare 2-step `ListView` becomes a tokenized wizard
  with progress, empty state for damage, and localized toasts.

---

## 4. Shared components adopted

`AppTopBar`, `AppPageFrame`, `AppCard` (`standard`/`subtle`/`interactive`/
`semantic`), `AppFormField`, `AppFormSection`, `AppFormPanel`, `AppTextField`
(+ identifier variant + new `prefix`), `AppDropdownButton`, `AppSearchField`,
`AppMediaUploadShell`, `AppDateSelectorShell`, `AppActionBar`, `AppButton`
(`primary`/`secondary`/`danger`), `AppStepProgress`/`AppProgressStep`,
`AppLinearProgress`, `AppInfoPanel`, `PendingSyncChip` (+ `SyncChipState`),
`EmptyState`, `AppConfirmationDialog` (`showAppConfirmationDialog`),
`DirectionalIcon`, `AppMotion`, `AppDimensions`/`AppColors`/`AppTextStyles`.

**Documented additive gap (README §8):** `AppTextField` gained an optional
always-visible `prefix` slot so identifier fields (country dial code `+971`,
plate prefix `Dubai-A`) stay visible when empty/unfocused, matching the previous
behaviour. Public API change is additive; no existing call site changed.

---

## 5. Responsive layout behavior

- **Compact (≤599 px):** single column; sections stack as cards; sticky
  `AppActionBar` clears the keyboard (hidden while the IME is open); scan/check-in
  fields stack; damage grid 2-up; media grid wraps. Verified 320/360/390/430 px.
- **Medium (600–1023 px):** intake becomes **two columns** — form (flex 3) +
  live summary (flex 2); check-in damage grid 3-up; action bar right-aligns its
  primary.
- **Expanded/large (≥1024 px):** content capped at `contentStandard` via
  `AppPageFrame`; two-column intake with generous gutters; signature/scanner stay
  focused full-height surfaces.
- **Text scale:** 1.0–1.3× verified at 360 px (no overflow); shared components
  already verified to 1.6×.
- **Keyboard/short viewport:** action bar suppressed while typing; fields use
  `scrollPadding`.

---

## 6. English / Arabic coverage

- `staff_app` ARB now ships **373 keys** (was 168): **205 new**
  `advisorIntake*` / `advisorScan*` / `advisorCheckIn*` keys; EN+AR parity green,
  `l10n_untranslated.json` = `{}`.
- Every in-scope visible string is localized: titles, section/subtitle copy,
  field labels and hints, validation messages, media/signature labels, fuel and
  damage-area labels, dialog copy, toasts, empty states, scan guidance and
  permission copy.
- Identifier values (VIN, plate, phone) keep LTR Latin content/`mono`; option
  *data* values (`kCarBrands`, `kEmirates`, `kFuelTypes`, priorities) are
  unchanged payload contract values.

---

## 7. RTL and accessibility verification

- All layouts use directional spacing/alignment; `DirectionalIcon` mirrors the
  back chevron; the step rail mirrors (6 → 1 right-to-left in AR renders); the
  two-column intake mirrors; section rows align end.
- Identifier fields keep LTR content inside the RTL form (verified in AR render
  — VIN hint stays LTR).
- Controls ≥48 px (touch targets on rows, buttons, damage tiles); section
  headers carry `Semantics(button, expanded, label)`; select rows carry
  `Semantics(selected)`; signature surface has a semantics label.
- Contrast: semantic error text and borders use the danger tokens (sampled on the
  invalid-state render); no colour-only status (icons + text accompany colour).

---

## 8. Six intake overflow regression results

**Baseline (reproduced before implementation):** all six tests in
`vehicle_customer_intake_layout_test.dart` failed — the six pre-existing
`VehicleCustomerView` overflow failures. Exact cases and exceptions are recorded
in `baseline_intake_layout.txt`.

| # | Baseline failing case | Final |
|---|---|---|
| 1 | no overflow on narrow phone (320×640) | **PASS** |
| 2 | no overflow on normal phone (390×844) | **PASS** |
| 3 | no overflow on large phone / tablet (768×1024) | **PASS** |
| 4 | 1.3× text scaling without overflow (360×780) | **PASS** |
| 5 | expanded vehicle fields and priority selector valid | **PASS** |
| 6 | field hints and dropdown content use the global app font | **PASS** |

The layouts were **redesigned, not masked**: the overflow came from fixed-width
horizontal rows (`_ResponsiveFieldGroup`/custom button rows) and the previous
action-bar composition; the rewrite replaces them with responsive field groups,
`AppFormField` stacking, and an `AppActionBar` whose primary is compact-aware.
The rewritten test now additionally proves 430 px, AR, and the wide two-column
summary. **Zero of the six failures remain.**

---

## 9. Workflow tests

- `vehicle_customer_intake_layout_test.dart` (17): no-overflow at
  320/360/390/430/768/1280 × EN/AR; 1.3× scaling; optional-section expansion
  (media + job); required-field validation; wide summary panel; global font.
- `advisor_phase07a_visual_test.dart` (13 goldens): intake 390/768/1280 EN+AR,
  check-in 390 EN+AR, scan 390 EN+AR (permission denied), intake invalid EN+AR,
  check-in damage step EN.
- Preserved unmodified and passing: `packages/shared_core/test/advisor_intake_payload_test.dart`
  (payload shape) and `apps/staff_app/test/vehicle_damage_persistence_test.dart`
  (Hive damage persistence) — the intake payload, Hive keys, queue enqueue,
  `syncAll`, server-ref resolution, scanner return contract and check-in submit
  contract are byte-for-byte unchanged.
- Offline path: the inspection prompt renders the `Queued (offline)` state when
  the server ref is absent (same `_savedToServer` logic as before); the queue
  call and `recoverUnsyncedAdvisorIntakes()` are untouched.

---

## 10. Screenshot evidence

`phases/reports/PHASE_07A/screens/` — **13 renders**, `screen_width_locale_state.png`:

```
intake_390_en_default      intake_390_ar_default
intake_768_en_default      intake_768_ar_default
intake_1280_en_default     intake_1280_ar_default
intake_390_en_invalid      intake_390_ar_invalid
checkin_390_en_default     checkin_390_ar_default
checkin_390_en_damage
scan_390_en_denied         scan_390_ar_denied
```

Goldens: `apps/staff_app/test/goldens/{intake,checkin,scan}_*.png` (13).
All rendered screens were visually reviewed (not code-read) before baselining:
the compact/tablet/desktop intake, the AR-RTL intake (mirrored rail, LTR
identifiers), the invalid state (inline errors + scroll-to-first-error), the
check-in wizard and its damage step, and the scan permission-denied state.

---

## 11. Baseline versus final test results

| Unit | Baseline (pass/fail) | Final (pass/fail) | New failures | Notes |
|---|---|---|---|---|
| `staff_app` | 312 / 7 | **343 / 0** | **0** | +31 net tests (intake rewrite 6→17, +13 goldens, +1 finder fix); **the 6 intake overflows and the 1 advisor-workflow finder are resolved** |
| `shared_core` | 245 / 1 | 245 / 1 | 0 | 1 = pre-existing `app_theme_visual_test` (owned by 01); the additive `AppTextField.prefix` slot changed nothing |
| `shared_auth` | 73 / 0 | 73 / 0 | 0 | untouched |
| `owner_app` | 21 / 0 | 21 / 0 | 0 | untouched |
| `crm_app` | 14 / 0 | 14 / 0 | 0 | untouched |
| `customer_app` | 509 / 8 | 509 / 8 | 0 | **not touched**; the 8 are the pre-existing date-relative booking-flow goldens (4 goldens × 2 duplicate groups) documented in Phase 06 §13 and **not regenerated** |
| `dart analyze` | 0 | 0 | 0 | 0 issues on `shared_core` + `staff_app` (the two units changed) |
| Phase 00 prototype | 0 changes | 0 changes | 0 | untouched |

**Advisor-workflow finder (the 7th pre-existing staff failure, owned by 07A/06):**
corrected. `staff_experience_test.dart` asserted each workflow-step label
`findsOneWidget`, but `AdvisorWorkflowIndicator` intentionally renders the active
step's name in both the header title and the step rail, so "Estimate" legitimately
appears twice. The assertion was corrected to `findsWidgets` (the widget itself is
unchanged and still owned by 07B/08). This is a test-precision fix, not a
suppression: the intended behaviour — every service step is visible — still holds.

Goldens were regenerated only for the screens intentionally redesigned here and
were visually reviewed before re-baselining. No golden was regenerated to hide a
failure.

---

## 12. Deferred issues

| Item | Owner |
|---|---|
| Intake has no dedicated draft-autosave provider; entered data is preserved in-memory across rebuilds and persisted on submit (existing behaviour). A Hive draft-restore would be a new backend-adjacent behaviour and was **not** introduced. | 07A (documented) |
| Media rows show local previews + remove; a true per-item *pending/failed upload* state needs an upload-status source the current queue does not expose per file, so it is not faked. | 08 (estimate/media sync) |
| `CustomerTagSheet` (dead UI) remains in `select_brand_sheet.dart`, tokenized/localized, pending removal. | 08 (planned removal) |
| `AdvisorWorkflowIndicator` remains the overall-workflow header for 07B/08 screens; the intake uses the shared `AppStepProgress` section rail instead. | 07B |
| `customer_app` date-relative booking goldens (unchanged, out of scope). | 16 / 20 |

---

## 13. Readiness for Phase 07B

**Ready.** The advisor capture flow (intake → check-in → scan) is redesigned on
the approved 2026 system, localized EN+AR, RTL-correct, responsive at
320–1280 px, behavior-preserving, and green (`analyze` + `test:staff` 343/0).
The intake prompts for inspection at exactly the point where Phase 07B begins;
no inspection view was modified.

**Phase 07A completion checklist**

- [x] All section-D screens redesigned with shared primitives; no raw hex/magic
      radius in touched files
- [x] Payload/Hive/queue/check-in contracts unchanged (unmodified tests prove it)
- [x] EN/AR complete; RTL correct; responsive per E; 320 px clean
- [x] **Six pre-existing intake overflow failures resolved** (redesigned, not hidden)
- [x] `analyze:staff` + `test:staff` green (343/0, no new failures); goldens
      intentional and visually reviewed
- [x] J2 evidence pack attached (`phases/reports/PHASE_07A/`, 13 renders)
- [ ] Phase 07B — awaiting explicit authorization (not started)
