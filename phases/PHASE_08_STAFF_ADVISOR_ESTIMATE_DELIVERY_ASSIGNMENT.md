# PHASE 08 — Staff: Advisor Estimate, Delivery & Assignment

## A. Phase identity

- **Phase number:** 08
- **Title:** Advisor Estimate Builder, Preview/Signature, Delivery & Task Assignment (plus advisor legacy-kit cleanup)
- **Objective:** Redesign the estimate/repair-order builder and its preview, the vehicle delivery handover, and the task-assignment surface into precise, money-trustworthy, two-pane (tablet/desktop) experiences — then delete the confirmed dead advisor UI.
- **Priority:** High
- **Dependencies:** Phases 01–07
- **Estimated scope:** Very Large

## B. Repository context

Files (relative to `apps/staff_app/`):

- `lib/features/advisor/presentation/pages/repair_order_view.dart` (~2 900 lines):
  `RepairOrderView` (route `/repair-order`, extra `{onBack, fromInspection}`):
  `_LineItemsCard`, `_ChooseServicesView`, `_ChoosePartsView`, `_EditableField`,
  `_PreviewDetailRow`, media pickers, tag dialog, reset confirm, item-info dialog;
  `RepairOrderPreviewView` (route `/repair-order-preview`): `_TableHeader`,
  `_TableRow`, `_SignaturePadSheet`, `_ApprovalMethodTile`,
  `_CreateRepairOrderButton`; `_submitting`, snackbar errors.
  Uses legacy `inspection_widgets.dart` kit + `AdvisorWorkflowIndicator(step 2)`
  and `brandConfigProvider` (repair order watches brand).
- `.../presentation/widgets/inspection_widgets.dart` — legacy kit
  (`AppBadge`, `SolidBtn`, `OutlineBtn`, `StatusBoxes`, `Switch`, `SearchField`,
  `InfoCard`, `SmallTag`) used by repair order.
- `.../pages/vehicle_delivery_view.dart` — pushed via `MaterialPageRoute` from job
  detail; 5-item checklist, notes, complete & finalize; `_isLoading`; action bar.
- `.../pages/advisor_assign_tasks_view.dart` — pushed via `MaterialPageRoute`;
  technician picker, toggle/add tasks, assign; `_isLoadingItems`, `_isLoading`,
  snackbar errors; `AppResponsivePage`, `AppCard`.
- Providers: advisor job detail/estimate providers in
  `.../providers/advisor_providers.dart` (preserve APIs).
- Dead advisor UI to remove this phase (confirm zero references first):
  `advisor_body.dart`, `advisor_tab_panel.dart`, `advisor_header.dart`,
  `advisor_header_button.dart`, `advisor_bottom_nav.dart`, `advisor_bottom_item.dart`,
  `advisor_fab.dart`, `advisor_stat_tile.dart`, `advisor_tab_button.dart`,
  `advisor_avatar.dart`, `advisor_job_card_sheet.dart`,
  `advisor_reminders_page.dart`, `advisor_job_cards_page.dart`,
  `advisor_approvals_page.dart`, and (after repair-order migration)
  `inspection_widgets.dart`; the unused skeletons `AdvisorDashboardSkeleton` /
  `TechnicianHUDSkeleton` in `staff_shimmer_skeletons.dart` (keep file for the
  used skeletons until Phase 10/11 replace them).
- Tests: `advisor_experience_test.dart` (estimate paths), `pending_approval_entity_test.dart`,
  `logic_test.dart`; goldens for repair-order screens if present.

## C. Design objectives

1. **Estimate builder = money-grade editor.**
   - Structure: catalog picker (services/parts) | line-item editor | summary
     (subtotal, tax if present, total) — two-pane at ≥`medium`, three-pane at
     `large`, stacked on compact (picker opens as sheet).
   - Line items: `AppRecordRow`-family rows with tap-to-edit sheet or inline
     fields (name, qty stepper, unit price, amount) — all money tabular, aligned;
     validation (qty ≥1, price ≥0) inline; remove with confirmation when it
     affects totals.
   - Search inside pickers (`AppSearchField`), categories if provided by data;
     selection adds to estimate with a visible count/toast + optional undo.
   - Add-item media/tag/item-info actions preserved (dialogs become sheets with
     the same callbacks).
   - Reset estimate keeps its confirmation.
   - Sticky footer: total + primary "Preview estimate"; secondary reset/back.
   - Draft persistence: keep whatever local mechanism exists (do not invent new);
     if the current code keeps in-memory only, preserve that.
2. **Preview = contract surface.** Header (job card ref, customer, vehicle,
   date), line-item table (desktop) / grouped rows (mobile) with tabular money,
   signature capture (`_SignaturePadSheet` → focused sheet with clear/confirm),
   approval method selection (`_ApprovalMethodTile` → radio-card list),
   submit with in-button loading and explicit success/failure; failure offers
   retry; success pops with the existing callback contract.
3. **Delivery = closing ritual.** Checklist (5 items, each with clear label +
   checkbox ≥48 px), notes, "Complete & finalize" disabled until all checks;
   summary of what finalizing does; loading inside button; failure shown as
   panel with retry; success pops/concludes exactly as today.
4. **Assignment = fast dispatch.** Technician picker with search + workload
   context (only fields the provider already exposes: name, department/role if
   available, active task count if present), task rows with select toggles and
   add-custom-task, assign with in-button loading; failure retry. No invented
   capacity data.
5. **Kill the legacy kit.** `inspection_widgets.dart` fully replaced by the
   shared component library, then deleted along with the confirmed-dead advisor
   widgets — shrinking the hand-rolled surface as recorded in analysis.
6. **Navigator consistency:** the two `MaterialPageRoute` pushes
   (`VehicleDeliveryView`, `AdvisorAssignTasksView`) — if go_router conversion
   is safe with existing constructors (they take `jobCardRef`), convert to
   declared routes with extras **only if** no deep-link/back-stack behavior
   changes; otherwise keep `MaterialPageRoute` and document. Default: keep
   behavior, restyle only.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `RepairOrderView` | picker / editor / summary panes + sticky footer | add service/part, edit qty/price, media, tag, item info, reset, preview | loading generated items, empty estimate, validation errors, busy flags |
| `RepairOrderPreviewView` | header → line table/rows → totals → signature + approval method → submit | sign, choose approval method, submit, back | submitting, submit error+retry, signed/unsigned |
| `VehicleDeliveryView` | header (job/vehicle) → checklist → notes → action bar | toggle checks, notes, finalize | loading, disabled-until-complete, error+retry |
| `AdvisorAssignTasksView` | header (job) → technician picker → task rows → action bar | pick tech, toggle/add tasks, assign | loading items, assigning, error+retry, empty tasks |

## E. Responsive specifications

- **Compact:** estimate stacked — picker as sheet; line items as editable rows
  (tap → edit sheet); totals in a pinned card above the action bar; preview rows
  grouped with label/value; signature full-width sheet; delivery/assignment
  single column.
- **Medium:** two-pane estimate (editor | summary); preview uses a readable
  width (`formMaxWidth`-equivalent cap ~720 px centered); assignment two columns
  (tech list | tasks).
- **Expanded/large:** three-pane (catalog | editor | summary) capped at
  `contentWide`; preview table full columns; delivery content capped ~800 px.
- Money columns: tabular, right-aligned in LTR / start-aligned in RTL per spec
  §13 (numeric alignment follows locale direction of the table).
- 320 px: line-item edit sheet scrolls; no clipped totals.
- 1.3× scale: totals row wraps without truncation.

## F. Localization and RTL

- All strings localized (`advisorEstimate*`, `advisorDelivery*`, `advisorAssign*`
  namespaces) EN+AR; currency via `AppFormatters` (AED).
- RTL: table columns mirror (Item | Qty | Price | Total order mirrors), stepper
  buttons mirror, signature pad alignment mirrors, action bars mirror; money
  numbers remain Latin digits with localized grouping.
- Tests: estimate/preview widget tests in both locales; RTL column-order
  assertion; no overflow at 320 px.

## G. Design system integration

- Use: `AppSearchField`, `AppRecordRow`-family line items, quantity stepper
  (Phase 03A), `AppButton` system, `AppActionBar`, `AppInfoPanel` (totals/notice),
  `AppConfirmationDialog` (reset/remove), `showAppModalSheet` (edit/tag/media/
  item-info/signature/approval-method), `AppStepProgress` (workflow step 2/4
  indicator — replace `AdvisorWorkflowIndicator` with `AppStepProgress` if the
  step model matches; otherwise keep the indicator and note).
- Delete after replacement: `inspection_widgets.dart`; dead widgets listed in B.
- No new tokens expected.

## H. Technical implementation

- Modify: `repair_order_view.dart` (split into smaller files if practical —
  e.g. `repair_order/` subfolder with editor/preview files — while keeping the
  public widget names and route builders intact), `vehicle_delivery_view.dart`,
  `advisor_assign_tasks_view.dart`; ARB; tests/goldens.
- Preserve: estimate provider methods, submission payloads, `_submitting`
  outcome semantics, callbacks (`onBack`, `fromInspection`), brand watch
  behavior on repair order.
- Deletions require a text search proving zero references (`rg` across `lib/`
  and `test/`), then remove files and any now-unused imports/tests.
- No route changes by default; no API/provider changes; no new packages.

## I. Functional preservation

- Estimate line-item math, totals, submission payloads and approval-method
  values unchanged.
- Signature bytes handling unchanged; preview submit callback contract unchanged.
- Delivery checklist completion gating and finalize call unchanged.
- Assignment payload (technician + tasks) unchanged.
- Route/extra contracts for `/repair-order`, `/repair-order-preview` unchanged;
  `MaterialPageRoute` pushes keep working (same constructors).
- Existing tests for estimates/approvals pass (updated only for intentional
  copy/layout).

## J. Testing requirements

- `melos run analyze:staff`; `melos run test:staff`.
- New/extended widget tests:
  - estimate: add/remove/edit line items, validation, totals correctness,
    reset confirm, picker selection, empty estimate state;
  - preview: sign → approval method → submit success/failure/retry;
  - delivery: checklist gating + finalize states;
  - assignment: tech pick, task toggle/add, assign states;
  - EN+AR, RTL table order, 320/390/768/1280, 1.3×.
- Run `pending_approval_entity_test.dart` + `logic_test.dart` untouched
  (contract proof).
- Goldens: regenerate repair-order/delivery/assignment goldens; add AR goldens
  for the estimate editor.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the estimate builder, preview/signature, delivery
   and assignment flows end to end and visually review each screen.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px); the three-pane estimate layout is reviewed on
   desktop specifically.
3. **Locales** — EN-LTR and AR-RTL renders; money tables reviewed for mirrored
   column order and correct tabular alignment in both directions.
4. **State matrix** — empty estimate, populated (realistic services/parts with
   AED prices), validation errors, submitting, submit error/retry, signed vs
   unsigned preview, delivery checklist partial/complete. No invented data.
5. **Interaction verification** — add/remove/edit line items, quantity stepper
   bounds, reset confirm, tag/media/item-info sheets, signature capture,
   approval-method selection, delivery gating, technician picking.
6. **Accessibility** — 1.0–1.3× scale clean; totals never clipped; semantics on
   steppers and selectable rows; contrast sampled.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_08/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D screens redesigned with shared primitives; legacy
   `inspection_widgets.dart` deleted; dead advisor widgets deleted with proof of
   zero references.
2. Money tables tabular and correctly aligned per direction; calculations
   unchanged (tests).
3. All states covered (busy/error/retry/empty).
4. EN/AR complete; RTL correct; responsive per section E.
5. `melos run analyze:staff` + `test:staff` green.

## L. Deliverables

- File changes (incl. new file split), deletions with evidence, ARB counts.
- Test evidence incl. totals-math tests and untouched contract tests.
- Known limitations (e.g. any deliberate kept `MaterialPageRoute`, any estimate
  feature the data layer does not support yet).

## M. Completion gate

Stop after this phase. Do not begin Phase 09 until explicitly instructed.
