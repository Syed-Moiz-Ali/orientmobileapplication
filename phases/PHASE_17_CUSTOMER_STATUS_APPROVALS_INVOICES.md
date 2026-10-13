# PHASE 17 — Customer: Service Status, Approvals & Invoices

## A. Phase identity

- **Phase number:** 17
- **Title:** Customer Service Status, Approvals & Invoices (tracking page, estimate decisions, invoice detail)
- **Objective:** Redesign the three decision/monitoring surfaces where trust is won or lost: live service tracking, estimate approval with financial breakdown, and the invoice record. Preserve the contextual routing model, auto-refresh behavior and every decision contract.
- **Priority:** High
- **Dependencies:** Phases 15, 16
- **Expected scope:** Large

## B. Repository context

Files (relative to `apps/customer_app/`):

- Status: `lib/features/customer/presentation/customer_service_status_page.dart`
  (route `/customer_service_status`; legacy `/customer_service_status_view`
  redirects) + `widgets/customer_service_status_tab.dart`
  (`CustomerStatusLivePanel`, `CustomerStatusUpcomingPanel`,
  `CustomerStatusIdlePanel` via `customer_status_service_panel.dart`;
  `_OtherBookingsRow`; `CustomerServiceJourney` + `CustomerStatusDetails` in
  `customer_service_journey.dart`, `customer_status_details.dart`;
  `CustomerStatusSkeleton`, `CustomerRefreshNotice`, 60 s auto-refresh,
  `RefreshIndicator`).
- Approvals: `customer_approvals_page.dart` (route
  `/customer_approvals?estimateId=`; `_ApprovalsOverview`, `_NeedsDecision`,
  `_PendingApprovalRow`, `_SettledInvoices`, `_InvoiceRow`, `_CountChip`;
  `CustomerSkeleton` box; per-section failed/empty panels) +
  `widgets/customer_approval_detail_view.dart` (`_EstimateRecord`,
  `_WorkBreakdown`, `_FinancialSummary`, `_DecidedNote`, `_DecisionBar`,
  `_IconLine`, `_DetailSkeleton`, `_DetailError`; busy decision bar;
  snackbars).
- Invoices: `customer_invoice_detail_view.dart` (route `/invoice-detail`,
  extra `InvoiceResponse`; read-only; route-error fallback; `AppCard` +
  `AppAdaptiveGrid` already used).
- Router: `customerApprovalsRoute` with `?estimateId=` deep-link contract;
  `customerServiceStatusRoute` + compat redirect; `_RouteErrorPage` fallbacks.
- Providers: `customer_providers.dart` (approvals, invoices; Hive fallback) —
  preserve; decision methods (approve/reject) with payloads — preserve.
- Tests: `customer_status_tab_test.dart`, `customer_service_status_route_test.dart`,
  `customer_approvals_test.dart`, `customer_approvals_route_test.dart`,
  `invoice_detail_widget_test.dart`, `customer_booking_relations`-adjacent
  decision tests, `vehicle_booking_decision_test.dart`; ~many goldens.

## C. Design objectives

1. **Service status = calm live tracking.**
   - Live: status hero (current stage, ETA/context if provided, last update
     freshness), stage timeline (`CustomerServiceJourney` refined: token colors,
     localized stage names, current-stage emphasis + motion on change ≤280 ms),
     details rows, notices (estimates/invoices needing attention + refresh).
   - Upcoming: appointment summary + directions/call actions if wired.
   - Idle: friendly empty with Book service.
   - Auto-refresh (60 s) preserved; refresh happens in place (badge/timeline
     morph), full-page flash never occurs; manual pull-to-refresh kept.
2. **Approvals = decision-first.** Overview ordering: "Needs your decision"
   count + rows (estimate ref, vehicle, amount, age) → settled invoices.
   `?estimateId=` opens detail directly (contract kept).
3. **Approval detail = financial transparency.**
   - `_EstimateRecord` → identity header (job/vehicle/estimate ref, date).
   - `_WorkBreakdown` → line-item table with tabular money (desktop table;
     compact grouped rows), quantity/prices/amounts aligned.
   - `_FinancialSummary` → subtotal/tax/discount/total with clear total
     emphasis; no hidden fees; currency localized AED.
   - `_DecisionBar` → sticky approve (primary) / reject (secondary-danger) with
     confirmation copy explaining consequences and in-button busy; decision
     outcome states: pending → decided note (`_DecidedNote`) with date;
     undo not offered unless the product already supports it (it does not —
     keep as-is).
   - `_DetailError` → error + retry; decided/pending states distinct.
4. **Invoice detail = official record.** Document-style layout: header (number,
   date, job/customer/vehicle), line items table (tabular), totals block,
   payment status pill, footer notes; print/share only if already supported
   (currently not — omit); `AppAdaptiveGrid` behavior kept for wide layouts.
5. **RTL + localization end-to-end:** timeline mirrors direction, tables mirror
   columns, currency and dates localize, stage names from localized labels.
6. **Notices unified:** refresh/decided/queued notices use `AppInfoPanel`
   grammar; per-section failures become `ErrorView` + retry (no broken-silent
   panels).

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `CustomerServiceStatusPage`/Tab | status hero → timeline → details → notices | back, refresh (auto+manual), open booking/estimate/invoice (existing targets) | live/upcoming/idle, skeleton, refresh notice, error+retry |
| `CustomerApprovalsPage` | needs-decision → settled invoices | open detail (deep-link compatible), open invoice, refresh | skeleton, per-section empty, per-section error+retry |
| `CustomerApprovalDetailView` | identity → work breakdown → financial summary → decision bar | approve (confirm), reject (confirm), retry | pending, decided, busy, detail skeleton/error |
| `CustomerInvoiceDetailView` | document header → line items → totals → status | back | route fallback; static content |

## E. Responsive specifications

- **Compact:** single column; timeline vertical; line items as stacked
  label/value rows; decision bar sticky above safe area; invoice totals block
  full width.
- **Medium:** line items table with columns; timeline can be horizontal
  (stepper) where stage count ≤5 when it improves scanability — choose one
  orientation and apply consistently; approvals two-column (needs decision |
  settled) at ≥900.
- **Expanded/large:** approval detail two-column (breakdown | summary + decision
  sidebar sticky); invoice document capped ~820 px centered; status page capped
  `contentStandard`.
- 320 px: money columns never clip (amounts wrap under label if needed).
- RTL: timeline/table/summary mirror fully.

## F. Localization and RTL

- All strings localized (`customerStatus*`, `customerApprovals*`,
  `customerInvoice*`) EN+AR; stage labels from localized status mapping;
  amounts/dates via `AppFormatters`; refs Latin.
- RTL: timeline direction, table column order, decision bar button order
  (approve remains leading in logical order), invoice header alignment.
- Tests: all Phase-17 test files EN+AR; RTL assertions for timeline + line-item
  table; 320 px clean.

## G. Design system integration

- Use: `AppPageFrame`, `AppTopBar` (pushed pages), `AppCard`/tinted panels,
  `StatusPill`, `AppStepProgress` or cross-checked domain timeline (pick one
  grammar — recommend keeping `CustomerServiceJourney` restyled to token
  language for its domain semantics, documented), table primitives, `AppButton`,
  `AppActionBar` (decision bar), `AppInfoPanel`, `AppKpiCard` (overview counts),
  `AppSkeleton`, `EmptyState`, `ErrorView`, `AppConfirmationDialog`,
  `AppDivider`/`SectionHeader` equivalents.
- Retire ad-hoc skeleton/error widgets (`CustomerSkeleton` box usages, `_DetailSkeleton`
  etc.) where `AppSkeleton` compositions replace them without behavior change.
- No new tokens expected.

## H. Technical implementation

- Modify: status page/tab + journey/details widgets; approvals page + detail;
  invoice detail; ARB; tests/goldens.
- Preserve: 60 s auto-refresh timer + cancellation semantics; `?estimateId=`
  deep-link handling; approve/reject method payloads and result handling;
  invoice extra contract + fallback; status compat redirect; all navigation
  targets (booking detail, invoice detail, book service).
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Decision submissions unchanged (same providers, same payloads, same
  confirmation requirements).
- Auto-refresh cadence and resume behavior unchanged.
- Deep links (`/customer_approvals?estimateId=`, legacy status path) intact.
- Invoice rendering unchanged in content; only layout restyled.
- All listed tests pass (copy/layout updates only); goldens intentional.

## J. Testing requirements

- `melos run analyze:customer`; `melos run test:customer`.
- Update/extend: status tab states (live/upcoming/idle + notice + auto-refresh
  timer behavior), approvals overview states + deep link, approval detail
  pending/decided/busy/error, cancel & decision confirmations, invoice render;
  EN+AR; RTL; 320/390/768/1280; 1.3×.
- Goldens: regenerate status/approvals/invoice; add AR goldens for status live
  panel + approval detail.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the customer app and visually review service
   status (live/upcoming/idle), approvals overview, approval detail and invoice
   detail; no screen may be signed off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px); the invoice document cap and detail two-column
   reviewed at desktop.
3. **Locales** — EN-LTR and AR-RTL renders; timeline direction, table column
   mirroring and money alignment reviewed in AR.
4. **State matrix** — live stage progression, decided estimate note, pending
   decision, budget/financial summary populated, invoice paid/unpaid, skeleton
   and error+retry states. Realistic estimate/invoice fixtures (AED line items).
5. **Interaction verification** — auto-refresh in place (no full-page flash),
   manual refresh, approve/reject confirmations, deep link `?estimateId=`,
   invoice navigation, track/review links.
6. **Accessibility** — 1.0–1.3× scale clean, money never clipped, semantics on
   decision bar, contrast sampled on status timeline.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_17/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D surfaces redesigned; state coverage complete; refresh in-place
   behavior proven (no full-page flash test).
2. Decision/refresh/deep-link contracts unchanged (tests).
3. EN/AR complete; RTL correct incl. timeline; responsive per E.
4. `melos run analyze:customer` + `test:customer` green.

## L. Deliverables

- File changes; ARB counts; timeline grammar decision note; golden diffs; test
  evidence; known limitations (e.g. no undo of decisions, no print/share on
  invoices).

## M. Completion gate

Stop after this phase. Do not begin Phase 18 until explicitly instructed.
