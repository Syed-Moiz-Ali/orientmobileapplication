# PHASE 07B — Staff: Advisor Inspection

## A. Phase identity

- **Phase number:** 07B (part 2 of 2; split from the former Phase 07)
- **Title:** Advisor Inspection — template choice, checkpoint sheet, preview/submit, interactive vehicle damage map
- **Objective:** Redesign the flagship inspection interaction — section rail + three-state checkpoints + media/audio + interactive damage map + preview — into the most legible, fastest, RTL-safe workflow in the product, preserving the inspection state machine and damage-map definition/transform behavior.
- **Priority:** High
- **Dependencies:** Phase 07A (intake hands off to inspection; shared pickers/signature patterns proven there)
- **Estimated scope:** Large

## B. Repository context

Files (relative to `apps/staff_app/`):

- `lib/features/advisor/presentation/pages/choose_inspection_view.dart`:
  template cards or skip → repair order; `AdvisorWorkflowIndicator(step 1)`.
- `.../pages/inspection_sheet_view.dart`: section rail, checkpoint cards
  (Good/Fair/Poor), search, media/audio pickers, sticky footer, draft/preview
  actions, exit/cancel confirms.
- `.../pages/inspection_preview_view.dart`: summary + section reviews +
  read-only body condition panel + submit confirm; `_isSubmitting`.
- `.../inspection_pages/`:
  - `presentation/vehicle_map/vehicle_inspection_map.dart` (CustomPainter),
  - `presentation/vehicle_map/vehicle_body_condition_panel.dart` (+
    `_VehicleFindingSheet`),
  - `presentation/vehicle_map/vehicle_map_transform.dart` (**math — do not
    modify; tests exist**),
  - `data/models/inspection_model.dart`, `inspection_view_model.dart`,
    `vehicle_damage_map_model.dart`,
  - `presentation/pages/inspection_provider.dart` (state machine, no widgets —
    **preserve; UI-only refactoring only**).
- Assets: `assets/vehicle_maps/advisor_car_top_mapped.svg` + mapping JSON
  (`flutter_svg`, `path_drawing` already dependencies).
- Entry points: home quick action, job detail ("start inspection"), intake
  inspection prompt (07A).
- Tests: `vehicle_map_definition_test.dart`, `vehicle_map_transform_test.dart`,
  `vehicle_damage_persistence_test.dart` (must pass unmodified);
  `advisor_experience_test.dart` inspection sections; goldens.

## C. Design objectives

1. **Inspection = the flagship interaction.** Section rail (vertical ≥ medium,
   horizontal chips on compact) + checkpoint cards with a clear three-state
   rating control (Good/Fair/Poor using semantic tokens + distinct iconography,
   not color alone), quick search, media/audio per checkpoint, live completion
   progress (%), draft autosave, exit guard. Tablet/desktop two/three-pane:
   (sections | checkpoints | damage map summary) at `large`.
2. **Damage map legibility.** Panel states: none / minor / major via token
   colors + shape/icon, legend visible, tap targets ≥24 px visual with enlarged
   hit areas, finding sheet standardized (severity, note, optional photo),
   read-only mode in preview. **The vehicle outline never mirrors in RTL** —
   surrounding UI mirrors; this is the canonical RTL exception, documented in
   code comments and tests.
3. **Preview = decision screen.** Completeness summary (rated/total, media
   count, findings by severity), section reviews, submit confirmation; no dead
   ends; submit busy + error/retry.
4. **Choose-inspection = clean fork.** Template cards with real template names
   and descriptions (from data), skip path equally visible, workflow indicator
   step 1; empty-templates and error states covered.
5. **Offline resilience visible:** draft saved state, media pending/failed
   retry, submit failure with retry (whatever the existing provider supports —
   reflect it, don't invent).
6. **State machine untouched:** `inspection_provider.dart` logic sequencing
   (section completion, draft, preview submission) is behavior-identical.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `ChooseInspectionView` | workflow indicator → template cards → skip path | select template, skip → repair order, back | empty templates, error |
| `InspectionSheetView` | section rail → checkpoint list → damage map panel → sticky footer | rate, search, add media/audio per checkpoint, open finding sheet, save draft, preview, exit guard | draft saved, empty checkpoint set, media pending/failed, exit confirm |
| `InspectionPreviewView` | completeness summary → section reviews → damage map (read-only) → submit | submit (confirm), back to edit | submitting, submit error+retry |
| `VehicleBodyConditionPanel` + `_VehicleFindingSheet` | map + legend + findings list → finding form sheet | tap panel, add/remove finding (severity/note/photo) | empty definition, no findings, read-only |
| `VehicleInspectionMap` | vector rendering (unchanged math) | tap panels (via panel) | — |

Route contracts: `/choose-inspection` (extra `{jobId}` + callbacks),
`/inspection-sheet` (`InspectionCallbacks`), `/inspection-preview` (extra
`{onBack, jobId}`) — unchanged.

## E. Responsive specifications

- **Compact:** single column; section rail becomes horizontally scrollable
  chips; checkpoint cards full-width; damage map full-width (pinch-zoom
  transform kept); sticky footer.
- **Medium:** vertical rail + content; damage map beside checkpoint list where
  width allows (2-pane).
- **Expanded/large:** three-pane (sections | checkpoints | map + findings
  summary) capped at `contentWide`.
- 1.3× scale: checkpoint cards grow; ratings stay on one line or wrap cleanly.
- RTL: rail/chips/footer mirror; damage map does **not** (documented
  exception); legend text localized and mirrored around the fixed map.

## F. Localization and RTL

- All strings localized (`advisorInspection*` namespaces) EN+AR: section names,
  rating labels (Good/Fair/Poor), finding severity labels, preview copy, dialog
  copy, legend labels.
- RTL: see E; identifier/media captions align per direction.
- Tests: inspection widget tests in EN+AR; **map non-mirroring test** (panel
  coordinate hit-testing unaffected by direction) alongside the existing
  transform tests; 320 px clean.

## G. Design system integration

- Use: `AppStepProgress` (replace `AdvisorWorkflowIndicator` if the step model
  matches — otherwise keep it, with the decision documented), `AppSearchField`,
  `AppCard`, rating control built per spec (three-state segmented or card
  cycle — prototype verdict from Phase 00 screen D6 decides), `AppMediaUploadShell`,
  `AppButton`, `AppActionBar`, `AppInfoPanel`, `AppSkeleton`, `EmptyState`,
  `ErrorView`, `showAppModalSheet` (finding/media/audio), `AppConfirmationDialog`
  (exit/submit).
- Damage map painter updates use token colors + chart palette conventions; no
  structural math changes (`vehicle_map_transform.dart` untouched).

## H. Technical implementation

- Modify: choose-inspection/sheet/preview pages; body condition panel + finding
  sheet; map painter styling only; ARB; tests/goldens.
- Preserve: `inspection_provider.dart` state machine; map definition JSON +
  transform; submission payloads; route extras + callbacks.
- No route/provider/API changes; no new packages.

## I. Functional preservation

- `vehicle_map_definition_test.dart`, `vehicle_map_transform_test.dart`,
  `vehicle_damage_persistence_test.dart` pass **unmodified**.
- Inspection draft/preview/submit behavior identical; media/audio capture
  behavior identical.
- Entry points from 07A/home/job detail still land here.

## J. Testing requirements

- `melos run analyze:staff`; `melos run test:staff`.
- New/extended widget tests: checkpoint rating flow (all three states), search,
  media add/remove with pending/failed, draft save, exit guard, preview
  completeness counts, submit success/error/retry; EN+AR; RTL assertions incl.
  map non-mirroring; 320/390/768/1280; 1.3×.
- Goldens: inspection sheet + preview + damage map states (no findings /
  findings / read-only) regenerated; AR goldens added for sheet + preview.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the full inspection flow (choose → rate → map →
   preview → submit) and visually review each surface; no screen may be signed
   off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px); the three-pane layout reviewed at desktop.
3. **Locales** — EN-LTR and AR-RTL renders; rail/footer mirroring **and the map
   non-mirroring exception** explicitly reviewed with before/after images.
4. **State matrix** — 0 %/partial/complete rating, no-findings/findings
   severity levels, read-only preview, media pending/failed, exit guard, submit
   busy/error. Realistic inspection fixtures.
5. **Interaction verification** — rating control, panel taps (hit areas),
   finding sheet add/remove, search, draft autosave, preview submit confirm.
6. **Accessibility** — 1.0–1.3× scale clean; map panels have semantics labels
   with severity; rating control usable by screen reader; contrast sampled on
   severity colors (also in dark theme).
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_07B/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D surfaces redesigned; rating control legible at a glance (prototype
   verdict applied).
2. Map definition/transform/persistence tests pass unmodified; map non-mirror
   behavior documented + tested.
3. EN/AR complete; responsive per E; 320 px clean; all states covered.
4. `melos run analyze:staff` + `test:staff` green; J2 evidence attached.

## L. Deliverables

- File changes; rating-control decision note (from prototype verdict); map
  styling summary; ARB counts; golden diffs; test evidence; known limitations.

## M. Completion gate

Stop after this phase. Do not begin Phase 08 until explicitly instructed.
