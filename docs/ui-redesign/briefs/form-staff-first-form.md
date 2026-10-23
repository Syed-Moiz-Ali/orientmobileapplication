# UX Brief — FORM family, first screen = staff create job card (advisor vehicle/customer intake)

Governance: REDESIGN MANDATE (PROGRESS.md rule 13) + C16 hard-reject (any violation caps at 10/16) + U0–U14 C17 (any violation caps at 8/16, no exceptions). Tokens only (`App*` + `AppDimensions`/`AppSpacing`/`AppRadius`/`AppShadows`/typography; zero hardcoded sizes/colors/strings outside `core/design_system`). No data invention: every field, count, route, and payload below is verified from code. RTL ar, 320px + 1.3x, taps never regress (every AFTER budget ≤ BEFORE). Pass bar ≥ 12/16.

## Scope (verified from code, not assumed)

FIRST form of the staff FORM family:

- `apps/staff_app/lib/features/advisor/presentation/pages/vehicle_customer_view.dart` (`VehicleCustomerView`, route `AppRoutes.vehicleCustomer` = `/vehicle-customer`, `core/router/app_router.dart:53,281-289`). Extra contract: `{bookingId?}` (`app_router.dart:284-288`).
- State: `vehicleCustomerFormProvider` (+ `inspectionProvider` for the embedded body-condition panel); draft helpers `buildIntakeDraft` / `applyIntakeDraftToForm`; Hive box `inspections`, key `_intakeDraftKey = 'intake_draft_v1'` (`vehicle_customer_view.dart:36`).
- This brief rebuilds ONLY this surface. Sibling staff forms (check-in, inspection sheet, repair order, assign, parts, delivery — see INPUT_INVENTORY.md) follow in their own builds. No new routes. No logic changes (providers, validation predicates, Hive/sync payload, scan/brand/model/signature/share contracts all byte-identical).

## Chosen form + usage evidence (create job card beats add-vehicle-as-separate and check-in)

The MOST-USED staff form is **create job card = `VehicleCustomerView`** (the advisor vehicle + customer intake wizard; there is no separate staff "add vehicle" screen — vehicle capture is Step 2 of this wizard: `_vehicleFields`, `vehicle_customer_view.dart:701`).

Evidence (navigation entry points / call sites in code):

1. Home quick action (primary daily path): `_openNewJobCard() => context.push(AppRoutes.vehicleCustomer)` (`advisor_home_view.dart:77`), wired to the `advisor_quick_new` tile (`advisor_home_view.dart:970-976`) AND to the assigned-list empty state (`advisor_home_view.dart:1174-1177` via `onNewJob` passthrough at `:559,594,620`).
2. Jobs register empty state: `onAction: () => context.push(AppRoutes.vehicleCustomer)` (`advisor_jobs_view.dart:452-453`).
3. INPUT_INVENTORY.md: `vehicle_customer_view.dart` = 18 input hits (biggest staff form) vs `repair_order_view.dart` 11 vs `advisor_vehicle_checkin_view.dart` 6.
4. Runner-up `AdvisorVehicleCheckinView` (`/advisor/check-in`, `app_router.dart:54,291-301`) has exactly ONE entry: the intake-queue per-row Check In (`advisor_jobs_view.dart:649-656`, capped at 3 rows, only rendered when unfiltered bookings exist). It serves pre-booked visits only; the intake wizard serves every walk-in + every empty-state + every linked-booking start, so it is the most reached.

BEFORE counts below are taken from this wizard's own `_actionBar` / `_advance` / `_create` / `_validateStep` code, not estimated.

## Step-flow classification + written reasoning (scoped step-flow rule)

RULING: **one-time/long → STEPPED with progress bar + persisted values** (keep the existing 4-step deck; do NOT collapse to single-screen).

Reasoning against the scoped rule ("frequent forms stay single-screen with grouped sections and sticky submit; one-time or long forms get steps with progress + persisted values"):

- One-time per object: each job card is created ONCE per customer-visit (`IdGenerator.nextId('JC')`, `_create`, `vehicle_customer_view.dart:1779`). Advisors run it many times a day, but never twice for the same visit — it is N one-time instances, not a repeated same-object edit (unlike check-in/today-task execution, which correctly stays single-screen).
- Long by any measure: 4 domains (Customer → Vehicle & plate → Media & condition → Scope & sign-off), ~30 fields + UAE plate group + VIN + brand/model/year pickers + registration/insurance docs + photos/video + `VehicleBodyConditionPanel` + job-description table + comments + dual signatures + share. A single screen would be ~3000 px of scroll, hostile at 320px / 1.3x (U0/U5/U14 fail) and would bury per-step validation.
- Current code already satisfies the exemption terms: `Step X of 4` subtitle + `AppStepper` (≥600 px) / `AppLinearProgress` (compact) in `_progressZone` (`vehicle_customer_view.dart:394-424`), Back preserves typed values (`_handleBack` → `_goTo(_step-1)`, `:1722-1725`; forward jumps re-validate gates in order, `_onStepTap`, `:1550-1567`), and every `_goTo` autosaves a local Hive draft (`_saveDraft`, `:1583`; restore on next open with `advisorIntakeWizardDraftRestored` snackbar, `:229-284`). Drafts never enter the sync queue — only the final submit enqueues (`:36` comment + `_create` payload, `:1784+`).
- Therefore the rebuild keeps steps + progress + persisted values and is exempt from the "frequent ≤ 2 taps" ceiling in the same way Register-3-steps was (DESIGN_SPEC scoped rule note). The frequent single-screen rule still applies to the check-in form and is recorded as correctly differentiated, not violated.

## Top tasks with tap counts (BEFORE = current UI from code; AFTER must be ≤)

| # | Task | BEFORE (code-verified taps) | AFTER budget |
|---|---|---|---|
| 1 | Create a job card end-to-end (walk-in, most frequent) | 5 taps + typing/scroll: home New-job tile (1) → `push(vehicleCustomer)` (`advisor_home_view.dart:77,970-976`) + Next ×3 (`_actionBar` primary Next, `:1539-1544` → `_advance` + `_validateStep`, `:1569-1577`) + Create (1) (`:1530-1538` → `_create`, `:1752`) | ≤ 5 taps + same typing, ≤ same scroll (step count, gate order, and submit unchanged) |
| 2 | Fill vehicle identity with scan assist (VIN/QR or brand→model pickers) | Within step 2: scan-VIN icon (1) → `ScanVehicleView(scanMode VIN/QR)` push (`:2053-2071`) + auto-fill return; or brand sheet (1) → `showSelectBrandSheet` (`:1647-1657`) + model sheet (1) → `showSelectModelSheet` (`:1659-1678`) | ≤ same taps (sheets stay sheets; no added picker steps; scan stays suffix-icon path) |
| 3 | Sign off + submit (signatures, job lines, create) | Step 4: capture customer signature (1 sheet → `AdvisorSignaturePad`, `:2182-2211`) + advisor signature (1) + Create (1); validation failure jumps to the failing step + `ensureVisible` (`_create` `:1762-1771`, `_scrollToFirstError` `:1629-1643`) | ≤ same taps (sheet-per-signature kept; error jump kept; no added confirm step) |

Most frequent (task 1) is a stepped one-time/long flow, so its 5-tap shape is carried, not cut — the scoped exemption. Taps never regress: every budget is ≤ BEFORE.

## What is REMOVED or moved (structural, presentation only — no logic changes)

- REMOVED: bespoke deck chrome (`_DeckCard`, `_deckHeader` icon box, `_ToggleRow`, `_MoreLessLink`, `_MediaAddTile`, `_SignatureRow`, `_UaePlateField` layout, `SecondaryButton` share rows) → `AppSection` + `AppCard` grouped sections per step + `AppInputField`/`AppDropdown`/`AppSwitchTile`/`AppMediaUploadShell` equivalents; exactly ONE filled accent per step (the sticky-bar primary).
- REMOVED: bespoke progress (`AppStepper`/`AppLinearProgress` raw wiring in `_progressZone`) → C16 thin progress bar on top + `AppProgressBar` + "Step X of 4" (same `_step`/`_totalSteps = 4`, same `_onStepTap` gate order).
- REMOVED: bespoke action bar (`AppActionBar` + `AppButton.primary/secondary` wiring, `:1516-1546`) → C16 sticky bottom action bar (Back ghost left + ONE full-width-equivalent primary right: Next / Create job card; loading + disabled states kept).
- REMOVED: bespoke dialogs/sheets chrome (`showAppConfirmationDialog` discard, `AlertDialog` damage, camera/gallery `showModalBottomSheet`, `AdvisorSignaturePad` shape, `SharePreviewSheet` trigger) → `AppDialog` (naming the object on discard) + `AppBottomSheet` (handle, ≤90%, pinned primary); all callbacks/payloads byte-identical.
- REMOVED: bespoke status/sync chrome (`PendingSyncChip`, `AppInfoPanel.primary` linked-booking, success `AlertDialog` with cloud icon) → `AppBanner` (offline/queued only when abnormal) + `AppSnackBar` (draft-restored, blocked-step, created); workspace offline pill already owns pending count.
- MOVED: wide ≥1024 summary rail (`_summary`, `:362-377`) stays as the expanded rail (never a second submit path); compact keeps deck + sticky bar only.
- KEPT (untouched logic): all 4 step gates + `_validateStep`/`_validateForm` predicates, draft shape/version, Hive keys, sync payload, scan/brand/model/year contracts, photo/video/signature persistence paths, `PopScope` + `_confirmDiscard`, success navigation (`inspectionSheet` vs pop), every ARB key. No new routes, fields, or statuses. Zero as `0`.

## Form anatomy (steps + progress + persisted values, per the ruling)

1. `AppScaffold` (SafeArea, background token) + `AppAppBar` (back → `_handleBack`/discard-confirm; subtitle always `Step X of 4`; offline status, no second title row).
2. C16 thin progress bar on top + `AppProgressBar` ("Step X of 4 — {step title}") — tappable steps backward freely, forward only through gates (existing `_onStepTap` order).
3. Single-question-per-step headline (headlineLarge, left, e.g. "Who is the customer?") + one supporting line + deck content (grouped `AppSection`s inside the step; label above field, helper/error below; inline validation on Next/submit, never on keystroke).
4. Step 1 Customer: find-existing + name (required) + phone (required, ≥8, digits, LTR) + email (optional, LTR) + group + collapsed more (gender/address/tax/source).
5. Step 2 Vehicle & plate: UAE plate group (required) + VIN (optional, LTR, scan icon) + make/model (required, picker sheets) + year + collapsed more (cylinders/capacity/color/fuel/engine no./registration doc).
6. Step 3 Photo capture & condition: odometer (optional, digits, LTR) + brought-by + fuel slider + consent switch + photos/video tiles + embedded body-condition panel.
7. Step 4 Scope & sign-off: job category (+ insurance block when Insurance) + markup/order-type + job-description table + comments + advisor identity row + dual signature rows (request-link path kept) + saved-on-device notice + share row.
8. Sticky bottom action bar (surface, top hairline, 16 + safe area): Back ghost (steps > 0) + ONE primary (Next → / Create job card); loading replaces label with 20px spinner, width kept; keyboard-open keeps the bar reachable (keyboard-safe, never hidden behind inset — current `if (!keyboardOpen)` hide is REMOVED).

## ASCII wireframe at 360x800 (mandatory; progress + step-1 card above the fold)

```
+----------------------------------+
| < New job card      Step 1 of 4  |
| ██████░░░░░░░░░░░░░░░░░░░░░░     |
| Who is the customer?             |
| Find them or add them below.     |
|----------------------------------|
| Find existing                    |
| [ Search or scan .......... ]    |
|----------------------------------|
| Customer                         |
|  Name *                          |
| [____________________]           |
|  Phone *              +971 [__]  |
|----------------------------------|  <- above fold (first field visible)
+----------------------------------+
| [ Back ]      [   Next   ]       |  (sticky bar)
+----------------------------------+
| Today | Jobs | Reports           |  (bottom nav)
```

Below fold (scroll): email → group → show-more → error/helper lines. Steps 2–4 keep the identical chrome (headline + progress + deck + sticky bar); wide ≥1024 adds the 340 summary rail right (read-only, no second CTA).

## U-law application (U0–U14, C17 — esp. U4, U10, U14)

- U0: one question per step; supporting line ≤ 2 lines; technical detail (draft version, sync payload) never shown.
- U1: no inline search field creep — the step-1 find row reuses the existing customer-search predicate inside the form (not a global search icon; global search stays header-only per list briefs).
- U2: step headline + first field visible at 360x800 idle; anything pushing them down needs a written reason.
- U3: table above is binding; stepped one-time/long exemption recorded (progress + Back-persistence present).
- U4 (reachability): Next/Create lives in the sticky bar (lower half, no scroll); Back ghost beside it; scan/picker/signature actions are ≥ 48dp and never require reaching the top.
- U5: customer/vehicle names wrap ≤ 2 lines, never "…"; plate/VIN/phone/odometer/IDs stay LTR (`forceLtr` + bidi isolates, already in code — keep); 3-column quick rows fit or scroll with clean peek (never 2×2 + orphan).
- U6: empty/draft-restored is calm (snackbar, no filled CTA to nothing); success is the existing sheet choice (add inspection vs done), never a dead CTA.
- U7: one path per task (one Next/Create per step; pickers/scan/signatures each have exactly one entry).
- U8: completed/failed submits never strand data — failure keeps values + draft; no silent filtering of bookings/vehicles.
- U9: same header/back/CTA/sheet grammar as LIST/DETAIL briefs (AppPageHeader cadence, sticky bar, AppBottomSheet).
- U10 (feedback/forgiveness): every action feeds back — Next validates the step (inline error + `advisorIntakeWizardBlocked` snackbar + scroll-to-first-error, `:1615-1643`); Back preserves values; PopScope/discard confirm names the loss (`_confirmDiscard`, `:1734-1748`); destructive leave is confirm-only; errors say what to do next, never raw exceptions.
- U11: counts signed/tabular (`Step X of 4`, photo/video counts); zero as words/`0`, never "-".
- U12: one page background; no stray bands behind deck cards.
- U13: plain verbs ("Add job card", "Back", "Next", "Discard draft", "Try again"); no "dossier/intake-deck" jargon in UI.
- U14 (a11y): targets ≥ 48dp; AA contrast both themes; Semantics on progress (step X of 4), pickers, drums/sheets; visible focus order; 1.3x reflow without overflow; 320px single column (rail drops below content, never beside).

## States matrix (EVERY cell implemented)

| State | Intake behavior |
|---|---|
| Idle | Step headline + progress + deck + sticky bar; linked-booking banner only when `bookingId` present |
| Filling | Per-keystroke state only (no validation until Next/Create); `_saveDraft` on every `_goTo` so interruption loses nothing |
| Validation-error | Inline `errorText` under the field + blocked snackbar + auto-scroll to first error; submit jumps to the failing step (`_create` `:1762-1771`) |
| Submitting | Primary loading + disabled (Back also disabled); width kept; double-submit guarded by `_isCreatingJobCard` |
| Success | Existing success sheet (queued vs sent copy) → Add inspection (`push inspectionSheet` with callbacks) or Skip (pop); snackbar confirms; draft cleared |
| Error | `AppErrorState` + Try again (same `_create` retry, values kept); partial/stale failures → `AppBanner`, form stays usable |
| Offline/stale | `AppBanner` (warning) + last data + pending count from shell; submit queues locally, never loses the draft |
| ar (RTL) | Full mirror; chevrons/back/progress mirrored; plate/VIN/phone/odometer/IDs/dates stay LTR; tabular numerals kept |
| 1.3x text | No overflow (Flexible/Expanded, wrap; ellipsis secondary only); targets stay ≥ 48dp; tester exception = fail |
| 320px | Single column; plate group wraps; pickers stack full-width; sticky bar wraps Back above primary if needed; first field still above fold |
| Tablet / wide | Deck (60%) + summary rail (40%, read-only); bottom dock never duplicates the rail CTA |
| Dark | Ships from tokens only (light-first staff build); dark uses surface lift + border, no shadow, no pure-black shims — no rework |

## Copy keys needed

Reuse existing `advisorIntake*`, `advisorClient*`, `advisorCheckIn*` keys (titles, hints, errors, wizard, discard, success). New keys only for the C16 question headlines + empty/progress sentences (en+ar, listed for phase 9; flagged REVIEW_NEEDED, never shipped as verified).

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)

- `docs/ui-redesign/references/`: does not exist; `AIRBNB_PATTERNS.md` missing repo-wide (per `docs/ui-redesign/PROGRESS.md` and LIST-phase precedent `briefs/phase-6-vehicles-list.md:89-108`, `briefs/advisor-jobs-list.md:95-109`, DETAIL precedent `briefs/detail-staff-job-detail.md:190-199`).
- Mapping into `AIRBNB_PATTERNS.md` is therefore **unmet**; this brief proceeds from LIST + DETAIL precedent patterns: `AppPageHeader` cadence + header/back placement, whitespace-separated borderless light cards (C16), ONE primary CTA per step (sticky bar), inline-first grouped form anatomy (C9 form screen), `AppBottomSheet` for pickers/confirmations/share, `AppBanner` for abnormal sync, `AppEmptyState`/`AppErrorState`/mirroring skeleton, sentence case, zero as `0`, first content above the fold at 360x800.
- Nothing in this brief pretends a reference was consulted.

## Acceptance (binding gates for the build)

1. Rubric ≥ 12/16 on the form rubric; C16 hard-reject clean (else cap 10/16); U0–U14 clean (else cap 8/16, no exceptions).
2. Full gates in order, none skipped: characterization (current wizard captured + mapped) → before-images (baseline PNGs blessed) → migration (current → App* plan above, WIDGET_MIGRATION_MAP delta) → build (presentation only, zero logic diffs) → contact sheets (C14 matrix: core + stress + locale devices) → fresh reviewer pass + second reviewer sign-off.
3. Tap budgets re-measured AFTER (table above; any regression = fail); forbidden-pattern grep (C13) clean for touched modules before goldens.
4. No `71983229` touched (no commit/push/merge/switch; this brief writes exactly one file and stops).
5. Foreseen logic STOPs (do NOT fix in build — report back): (a) any new/changed required field or payload shape needs a backend-contract change → STOP; (b) draft-vs-sync boundary (Hive draft must never enter the sync queue; only final `_create` enqueues) → STOP if the rebuild pressures otherwise; (c) scan/brand/model/year/signature/share internals (`ScanVehicleView`, `showSelectBrandSheet`, `AdvisorSignaturePad`, `buildJobCardPdf`, share_plus) are behavior boundaries — restyle chrome only, logic STOP; (d) step-gate order/validation predicates are logic — any product request to relax a gate → STOP + LOGIC_FOLLOWUPS.md; (e) missing ar strings at phase 9 → REVIEW_NEEDED, never ship unverified copy as verified.
