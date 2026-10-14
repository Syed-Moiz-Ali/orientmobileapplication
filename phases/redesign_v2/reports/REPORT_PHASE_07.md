# Phase 07 Completion Report — Staff Vehicle Intake Studio

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_07.md`
**Execution Phase:** Concept A V2 — Phase 07 (Staff Vehicle Intake, Archetype 5: Express Vehicle Intake Studio)
**Target Package:** `apps/staff_app/lib/features/advisor/` (intake surfaces only)
**Specification:** `phases/redesign_v2/implementation/PHASE_07_STAFF_VEHICLE_INTAKE.md`
**Prerequisites:** Phase 06 ✅ (`REPORT_PHASE_06.md` + Gate 2 closure), Phase 04.1 integration plan ✅
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-15

---

## 1. Complete screen, route and file inventory

Discovered from source (routes in `apps/staff_app/lib/core/router/app_router.dart`, sheets via call sites) — not from the spec list alone.

| Ref | Surface | File | Route / entry | States owned |
| :-- | :-- | :-- | :-- | :-- |
| **S12** | `ScanVehicleView` (camera scanner) | `presentation/pages/scan_vehicle_view.dart` | `/scan-vehicle` (no `extra`; ctor `scanMode`) | scanning, decoded-result, permission-denied, camera-starting, manual-entry, manual-error, torch on/off |
| **S13** | `VehicleCustomerView` (express intake wizard) | `presentation/pages/vehicle_customer_view.dart` | `/vehicle-customer` (`extra: {bookingId}`) | 4 decks (contact / vehicle / capture / sign-off), per-deck validation, draft-restored, linked-booking, inspection-prompt (synced / queued), discard-guard |
| **S14** | `AdvisorVehicleCheckinView` (telemetry cluster) | `presentation/pages/advisor_vehicle_checkin_view.dart` | `/advisor/check-in` (`extra: {bookingId, customerName, vehicleInfo}`) | cluster (fuel dial + odo drums + notes + damages), damage dialog, confirmation review, submit loading / success / failure |
| **S15** | `VehicleDeliveryView` (handover sheet) | `presentation/pages/vehicle_delivery_view.dart` | **no route** — pushed via `showModalBottomSheet` from `AdvisorJobDetailView:985` | protocol checklist, mileage capture + error, star rating, notes, signature (pending/signed), gated submit, success / failure + retry |
| **S16a** | `SelectBrandSheet` / `SelectModelSheet` / `showModelYearDialog` | `presentation/widgets/select_brand_sheet.dart` | sheets from the wizard's make/model/year fields | loading (search), no-match empty, selected check |
| **S16b** | `AdvisorSignaturePad` | `presentation/widgets/advisor_signature_pad.dart` | sheet from wizard + delivery sign-off | blank, drawing, captured |
| — | `CustomerTagSheet` (dead) | same file as S16a | **zero references** outside its file | untouched — owned by Phase 08 removal (explicit file comment) |

**Routes preserved (unchanged):** `/scan-vehicle`, `/vehicle-customer`, `/advisor/check-in`, `extra` payload shapes, role allowlist in `_isRouteAllowedForRole`. Delivery still has no route (as before).

**Hive/sync contracts preserved:** `inspections` box (intake records, `intake_booking_id`, **new** local-only `intake_draft_v1`), `sync_queue` / `sync_failed` / `pending_media` boxes, `SyncOperation(entityType: vehicle_customer)` enqueue + `syncEngine.syncAll()` + `jobCardRef`/`serverJobCardId` read-back. NOTE: the mission statement names boxes `advisor_intakes` / `offline_checkins` — **those names do not exist anywhere in source**; the real contracts above were preserved instead (verified by grep).

---

## 2. Before / after visual-composition audit

| Screen | Before | After |
| :-- | :-- | :-- |
| Scan (S12) | Black stage, floating back/torch pills, centered mode pill, bare corner brackets, scan line, permission card with hardcoded white-on-black text, manual dock in `white10` containers. | Shared `WorkspaceAppBar` (title + live mode subtitle, back, torch action, frosted on desktop). Same black optical stage, but: targeting reticle (brackets + center crosshair), live status readout strip (mode hint + idle/permission state), themed permission card + manual dock card + result sheet (all resolve from the theme), desktop **guidance rail** (tips card) beside a 560 px constrained stage instead of a stretched phone view. |
| Intake (S13) | One long scrolling form: intro card, 6-step `AppStepProgress`, 8 collapsible `_IntakeSection` cards (find / customer / vehicle / body / media / job / signature), side summary, single Create bar. | **4-step express deck**: slim journey progress on compact (full tappable `AppStepper` ≥600 px), per-deck studio header (cobalt icon tile + `Step X of 4` + title + sub), always-open `_DeckCard`s, UAE plate component with live LTR preview strip, desktop 3-zone studio (deck + 340 px live-summary dock). Step-gated validation with error scroll-to-field. |
| Check-in (S14) | 2-step wizard (`AppTopBar`, `AppStepProgress`, details form with `SegmentedButton` fuel **missing Empty**, damage area buttons). | **Digital telemetry cluster**: semicircular fuel gauge (needle + per-level semantic arc color + 5 tappable detents + slider semantics), 6-wheel LTR odometer drums with +1k/+10k/Reset scrollers, notes, damage grid, and an explicit **confirmation review panel** before submit. `WorkspaceAppBar` + `AppPageHeader(breadcrumbs: Jobs › Vehicle check-in)`. |
| Delivery (S15) | Hardcoded-English checklist card + `AdvisorWorkflowIndicator` + notes + green `FilledButton`; **no** mileage, **no** rating, **no** signature, hardcoded `Color(0xFF10B981)`. | **Formal handover sheet**: `WorkspaceAppBar` + breadcrumbs + ref chip (LTR mono), protocol card (progress pill + bar + 5 localized checks), final-mileage capture with validation, LTR 5-star satisfaction rating with semantics, notes, stacked customer sign-off block (reuses `AdvisorSignaturePad`), gated handover bar (`N checks remaining` → `Complete handover`). 100% localized (was 0%). |
| Brand/model/year (S16a) | Bespoke stateful sheets (`_SearchSheetShell`, `_SelectRow`, custom year `AlertDialog`) wired through 85%-height `showModalBottomSheet` wrappers. | Thin wrappers + `showSelectBrandSheet` / `showSelectModelSheet` / `showModelYearDialog` delegating to shared `showAppSelectionSheet` (bottom sheet on compact, **centered dialog ≥600 px**, shared search + localized no-match state). Return contracts unchanged. |

Compositions are task-specific: optical instrument (scan), stepped deck (intake), gauge cluster (check-in), formal document (delivery). Shared tokens/primitives throughout; no repeated page template.

---

## 3. Changed production files & architectural rationale

**Pages (rewrites, contracts intact)**
- `scan_vehicle_view.dart` — HUD recomposition + shell header; camera/permission/pop contracts byte-identical; reduced-motion static sweep via `didChangeDependencies`.
- `vehicle_customer_view.dart` — wizard deck + draft save/resume; `_create` payload **verbatim** (field-by-field identical keys); all pickers/media/signature/audio/rich-editor helpers preserved with palette fixes only.
- `advisor_vehicle_checkin_view.dart` — telemetry cluster + confirmation state; `checkInVehicleResult(bookingId, {odometer, fuelLevel, existingDamages, notes})` + `pushReplacement` job-detail identical; fuel domain values unchanged (`Empty…Full`, default still `1/4`).
- `vehicle_delivery_view.dart` — handover sheet + full localization; `deliverVehicle(jobCardRef, {'notes': …})` shape preserved — captured facts (mileage, rating, sign-off) travel **inside the same `notes` string** (see §8).

**Widgets**
- `select_brand_sheet.dart` — bespoke sheets deleted, shared selection surface adopted; `CustomerTagSheet` untouched (Phase 08).
- `advisor_signature_pad.dart` — **2-line change only**: `FIXED-INK` justification on PNG-export colors (non-rendered bytes).

**Localization** — `lib/l10n/app_en.arb` / `app_ar.arb` + regenerated `staff_localizations*.dart`: **53 new keys** (wizard 12, scan 6, check-in 13, delivery 24 + attachment-error 1 + odo-label shortening), exact EN/AR parity, `l10n_untranslated.json = {}`.

**Tests (new/rewritten)** — `advisor_phase07_theme_test.dart` (guard, 2 tests), `advisor_phase07_shell_test.dart` (27 tests: shell/offline/wizard/cluster/delivery/permissions/draft/responsive), `vehicle_customer_intake_layout_test.dart` (rewritten for the deck, 17 tests), `advisor_phase07a_visual_test.dart` (rewritten, 16 goldens incl. new delivery/sign-off/confirm states).

**Goldens (Phase 07-owned, 16):** `intake_{390,768,1280}_{en,ar}`, `intake_390_{en,ar}_invalid`, `intake_390_en_signoff`, `checkin_390_{en,ar}`, `checkin_390_en_confirm`, `scan_390_{en,ar}`, `delivery_390_{en,ar}`. Deleted: `checkin_390_en_damage.png` (flow it captured no longer exists; replaced by the confirm state). Each inspected at native resolution before acceptance (§7).

No API request/response model, repository/provider, state contract, route, permission, validation rule, or Hive box behavior was changed.

---

## 4. Centralized-theme audit findings

- **Removed all static palette selection** from the Phase 07 production set: `scan_vehicle_view` (`AppColors.primary/danger`, `AppDarkColors.danger`, `Color(0xFF0A0A12)`), `vehicle_customer_view` (`AppColors.success/info/primary/danger`, white busy-foreground), `advisor_vehicle_checkin_view` (`AppColors.warning`), `vehicle_delivery_view` (`Color(0xFF10B981)` ×5). Everything now resolves via `context.colors` / `context.semanticColors` (incl. `damageModerate`, `syncQueued`, `inspectionAdvisory` domain roles).
- **Justified fixed ink (documented, guard-enforced):** white HUD ink + black stage on the camera instrument surface (`OPTICAL-HUD` markers), video-badge glyph over user thumbnails + PNG-export bytes (`FIXED-INK` markers). No other `Colors.*` remains.
- **New guard:** `test/advisor_phase07_theme_test.dart` — (1) fails on `AppColors.` / `AppDarkColors` / `Color(0x` / `Brightness.` in the 6 owned files; (2) **extends the Phase 06 guard** by failing any `Colors.*` (excl. `transparent`/`semanticColors`) without a `FIXED-INK`/`OPTICAL-HUD` marker within 6 lines. Both pass.
- **Dark-mode correctness improved:** sheets/result overlays previously hardcoded light accents (`AppColors.success`, white text); all surfaces now theme-resolve (verified by dark-theme widget tests).
- **No new theme tokens required** — existing `AppSemanticColors` roles covered every case.

---

## 5. Shell integration (Phase 04.1) details

| Requirement | Implementation |
| :-- | :-- |
| Bespoke headers → `WorkspaceAppBar` | All four screens. Scan keeps its black stage below the bar (torch moved into bar actions); intake/check-in/delivery use title + subtitle + back. |
| Frosted sticky header | `frosted: !context.isCompact` on all four (component falls back to opaque under reduced-transparency). |
| `OfflineStatusPill` + `showOfflineBanner: false` | Pill on intake/check-in/delivery with `advisorPendingSyncCountProvider`; none of these pages render an `OfflineBanner`, so offline state is announced **exactly once** (asserted: pill present + `OfflineBanner` absent). Scan is fully offline-capable (local decode + local manual entry) and carries no network state — pill intentionally omitted, documented. |
| Breadcrumbs | `AppPageHeader(breadcrumbs:)` on check-in (`Jobs › Vehicle check-in`) and delivery (`Jobs › Vehicle handover`), per spec scope. |
| Master-detail | N/A — no intake list/detail surface exists. Desktop uses constrained studio + summary dock instead. |
| Preserve navigation/args/permissions | Untouched routes, extras, role allowlist, pop-with-value contracts, scan→intake prefill. |
| Mobile-appropriate nav | Camera keeps HUD chrome (no desktop rail forced); compact wizard uses slim progress + bottom action bar; desktop adds stepper/rail/dock. |
| Cmd+K search | N/A — intake has no global search endpoint (spec-exempt); record search stays in-deck. |

No shared component was modified for Phase 07.

**Shared-code repairs (pre-existing breakage, documented):** the working tree contained uncommitted other-workstream `shared_core` changes that did not compile (`app_command_palette` paren typo, `app_theme` checkbox `side:` API vs Flutter 3.35, `app_density` F-bounded extensions spread, 2 warnings). Minimal intent-preserving fixes applied so any test could run; the WIP itself is untouched otherwise. See git diff on those three files + two warning lines.

---

## 6. Localization & RTL verification

- 53 new keys, exact EN/AR parity (`arb_parity_test` ✅, `l10n_untranslated.json` `{}` ✅, `localization_cross_boundary_test` ✅). Delivery went from 100% hardcoded English to 100% keyed.
- Professional MSA automotive Arabic throughout (e.g. `استلام المركبة`, `تسليم المركبة`, `خانات عدّاد المسافة`, `بروتوكول التسليم الرسمي`).
- RTL: directional APIs everywhere; goldens confirm mirrored chrome (back chevron, pill side, action-bar order, star row stays LTR by design).
- Non-mirroring: UAE plate preview, VIN/mono values, phone `+971` prefix, odometer/mileage/rating numerals, star order all render LTR (`textDirection: TextDirection.ltr`, `Directionality` wrappers) — verified in AR goldens.
- One benign convergence: AR `advisorIntakeSectionCustomer` and new `advisorIntakeWizardContactTitle` share one translation (`بيانات العميل`) — both placements are legitimate; tests use `findsWidgets` there with a comment.

---

## 7. Responsive viewport matrix, accessibility & golden review

| Width | Verified | Composition |
| :-- | :-- | :-- |
| 320, 360, 390, 430 | ✅ EN+AR no-overflow suite + goldens | single-column decks, slim journey progress (<600 px), bottom action bar, modal sheets |
| 600, 768, 834, 1024 | ✅ 768 asserted (suite + goldens) | tappable `AppStepper`, 2-up scan buttons, master-style wide cards |
| 1280, 1440 | ✅ 1280 asserted (suite + goldens) | scan: 560 px stage + 320 px tips rail; intake: deck + 340 px summary dock; check-in/delivery: 3:2 studio split |

- Text scaling 1.3× ✅ (dedicated test, 360 px). Touch targets ≥48 dp (detents, drums scrollers, stars, buttons) ✅. Focus/semantics: stepper `Step X of Y`, dial + drums + rating expose value/increase/decrease (fixed two framework assertion failures during development — `increasedValue`/`decreasedValue` added), permission/torch/manual states labelled ✅. Reduced motion (static scan sweep) + reduced transparency (opaque bar fallback) ✅.
- **Golden review (native resolution, real fonts):** all 16 inspected — intake EN/AR + desktop + invalid + sign-off, check-in EN + confirm, scan EN/AR, delivery EN/AR (+ AR check-in scanned in suite). Two defects found by review and fixed before acceptance: `+10,000` quick button clipped (shortened to `+10k`, EN+AR, re-baselined) and denied-state readout copy (`Starting camera…` → permission title, re-baselined). Evidence: `reports/PHASE_07/screens/` (16 PNGs).

---

## 8. Business/API contract notes (explicit)

1. **Delivery notes enrichment (intentional, shape-preserving):** `deliverVehicle` accepts only `{notes}`. The new mileage/rating/sign-off facts are appended as labeled lines to that same string (`Final mileage: … · Satisfaction: … · Customer sign-off: …` after the advisor's free text). No new keys, no unknown fields, backend-compatible.
2. **Delivery gating is stricter UI-side** (checklist + valid mileage + rating ≥ 1; signature optional) — client validation only, endpoint unchanged.
3. **Check-in default fuel stays `1/4`**; the dial adds the missing `Empty` detent without changing submitted values for untouched flows.
4. **Drafts are local-only** (`intake_draft_v1` in `inspections`, pure build/apply helpers unit-tested, media paths re-validated with `existsSync` on restore, cleared on submit/discard). Drafts never enter the sync queue.
5. **Real bug found & fixed:** delivery `Complete` stayed disabled when mileage was filled last (controller changes don't rebuild; `_canComplete` went stale). `onChanged` now always `setState`s.

---

## 9. Baseline vs final test results

| Suite | Baseline | Final | Δ |
| :-- | ---: | ---: | :-- |
| `staff_app` (full) | 309 / 62 | **354 / 49** | **+45 passes, −13 failures, 0 regressions** |
| `advisor_phase07a_visual_test` | 0 / 13 | **16 / 0** | +16 re-baselined (reviewed) |
| `advisor_phase07_theme_test` | (new) | **2 / 0** | theme + fixed-ink guards |
| `advisor_phase07_shell_test` | (new) | **27 / 0** | shell/offline/flow/cluster/delivery/permission/draft/responsive |
| `vehicle_customer_intake_layout_test` | 17 / 0 | **17 / 0** | rewritten for the deck, still green |
| `shared_auth` | 73 / 1 | **86 / 0** | golden now green (no Phase 07 touch) |
| `shared_core` | 353-ish / 13 (other-workstream WIP) | **unchanged by Phase 07** | not re-run per operator direction; failures belong to that WIP |
| Analyzer (`flutter analyze lib test`, staff_app) | 0 | **0** | clean |

**Commands run:** `flutter analyze lib test` (staff_app); `flutter gen-l10n`; focused suites above; full `flutter test` (staff_app) ×3; `--update-goldens` on the Phase 07 visual file only (then a clean re-run to 16/0).

### Exact remaining failures (49 — all pre-existing, other phases, NOT fixed, NOT claimed fixed)

| Test file | Count | Owner |
| :-- | ---: | :-- |
| `supervisor_login_phase05_test.dart` | 2 | Phase 05/11 |
| `technician_today_test.dart` | 7 | Phase 10 |
| `technician_jobs_test.dart` | 8 | Phase 10 |
| `technician_job_detail_test.dart` | 9 | Phase 10 |
| `technician_productivity_test.dart` | 6 | Phase 10 |
| `technician_profile_test.dart` | 9 | Phase 10 |
| `technician_support_flows_test.dart` | 8 | Phase 10 |

All are stale-golden pixel mismatches (same set as the Phase 06 baseline record, minus the 13 Phase 07 goldens this phase re-baselined). Per operator direction they will be covered in their own phases.

---

## 10. Screenshots of the completed screens

`phases/redesign_v2/reports/PHASE_07/screens/` (16 PNGs, real fonts):
- Intake: `intake_390_{en,ar}.png`, `intake_768_{en,ar}.png`, `intake_1280_{en,ar}.png`, `intake_390_{en,ar}_invalid.png`, `intake_390_en_signoff.png`
- Check-in: `checkin_390_{en,ar}.png`, `checkin_390_en_confirm.png`
- Scan: `scan_390_{en,ar}.png`
- Delivery: `delivery_390_{en,ar}.png`

---

## 11. Known limitations

1. **No live device/emulator/browser is available.** Verification is headless golden + widget tests only; live visual/interaction acceptance is **NOT PERFORMED** and must not be reported as passed.
2. Camera, image-picker, signature-pad strokes, and app-settings intents are not exercisable headless — covered by permission-denied/manual-fallback/dialog states instead.
3. The offline-queue widget test overrides `advisorPendingSyncCountProvider` with a fixed stream (Hive box IO is too slow/flaky in this environment); true box reactivity is covered by the pre-existing `advisor_sync_reactivity_test.dart`.
4. `shared_core` failures (13, other-workstream WIP: density test, foundation goldens, deprecation guard) were not run/fixed per operator direction — owned by that workstream.
5. `phases/README.md` (cited by the phase brief) does not exist in the repo — the ledger update went to `00_COVERAGE_MATRIX.md` instead (see §12).

---

## 12. Gate verdicts + ledger

**Gate 1 — Engineering: PASS.** All Phase 07 surfaces inventoried; shell integration implemented; analyzer clean; theme + fixed-ink guards pass; localization parity + untranslated-empty pass; contracts/routes/persistence preserved (payloads verbatim, one documented shape-preserving notes enrichment); 354/49 with zero new failures; report + evidence produced.

**Gate 2 — Visual: PENDING PRODUCT OWNER.** Compositions are rebuilt per task (not recolored); Concept A identity throughout; mobile/tablet/desktop + EN/AR + dark renders reviewed headless. Live acceptance **not performed**. This report does **not** claim Product Owner approval.

### Ledger update (`00_COVERAGE_MATRIX.md`)

Phase 07 intake studio: S12–S16 redesigned (wizard deck, optical HUD, telemetry cluster, handover sheet, shared pickers), shell-integrated, theme-guarded, localized EN/AR, 16 goldens reviewed. Evidence: this report + `reports/PHASE_07/screens/`.

---

## 13. Product Owner sign-off checklist

- [ ] Review `reports/PHASE_07/screens/` (intake wizard, check-in cluster + confirm, scan HUD, delivery handover; EN/AR; mobile/tablet/desktop).
- [ ] Confirm the 4-step deck replaces the long intake form acceptably (incl. draft save/resume behavior).
- [ ] Confirm the delivery `notes` enrichment (mileage/rating/sign-off appended) is acceptable to the backend.
- [ ] Confirm removal of the bespoke brand/model/year sheets in favor of the shared selection surface.
- [ ] Accept the headless-visual limitation or provide a device/browser for live acceptance.
- [ ] Approve Gate 2 and this report.

**Phase 07 executed in isolation. Phase 08 and later were not started.**
