# REPORT PHASE 18 — Customer Status & Approvals at Airbnb Bar

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_18.md`
**Execution Phase:** Concept A V2 — Phase 18 (Archetypes 2 + 8, Airbnb addendum binding)
**Specification:** `phases/redesign_v2/implementation/PHASE_18_CUSTOMER_STATUS_APPROVALS.md`
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-19
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: screen-level redesign of the consumer post-booking
> surfaces — live status timeline, approvals resolution desk, invoice
> receipt and service review — as warm Airbnb-grade trip + resolution
> experiences (timeline, authorized-total dock, nightly-style receipt,
> starred review), never a recolored enterprise form. Every value derives
> from frozen provider data; anything without a contract (bay names, photo
> evidence, safety flags, discounts, payment routes, per-line decisions,
> QR codes, review gating input) is omitted honestly rather than faked.
> Providers/API/models/math/validation/Hive/routes are byte-identical, and
> the staff and owner trees were never touched.

---

## 0. Baseline the dirty tree (§0 directive — done FIRST, no code)

Phase 17 is LANDED as `1e3926ba` (landed mid-session; verified clean:
customer + phases only, zero staff/owner/shared-out-of-scope paths); the
45M/1D/32?? floating entries it had become the commit verbatim. No other
author's work exists on the tree.

| Path | Disposition | Evidence |
| :--- | :--- | :--- |
| Phase 17 wizard (floating, 45M/1D/32??) | Carryover sibling (same shell/dock/pass voice) | Untouched by this phase; its suites re-verified green at close (602/602) |
| `apps/staff_app/**`, `apps/owner_app/**`, `packages/**` | READ-ONLY | Final status: zero staff/owner/shared paths |
| Customer status files C12–C15 + journey/panel/notice/detail widgets | REBUILT per scope | Zero-hardcode; all copy in ARB with EN/AR parity |
| 17's 9 stale goldens in THESE files (5 status-tab, 4 approvals) | RE-BASELINE SET, resolved here | All re-rendered after rebuild; deterministic rerun green |
| Customer analyzer 0 (incl. Phase 17 files) | KEPT at 0 | `flutter analyze` clean (customer + shared, incl. tests) |
| `test/features/customer/customer_status_approvals_test.dart` (spec §2) | DOES NOT EXIST | Real suites are `customer_status_tab_test`, `customer_approvals_test`, `invoice_detail_widget_test` + route tests — all owned green |

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| C12 | `CustomerServiceStatusPage` (shell) + `CustomerServiceStatusTab` (composition, strings-only) | `customer_service_status_page.dart`, `widgets/customer_service_status_tab.dart` | `/customer_service_status` | title/subtitles, attention, live/upcoming/idle, journey, details, load/error/refresh |
| — | `CustomerServiceJourney` (AppTimeline) | `widgets/customer_service_journey.dart` | status | real stages only, done/current/upcoming tones, empty → shrink |
| — | `CustomerStatusLivePanel`, `CustomerStatusUpcomingPanel`, `CustomerStatusIdlePanel` | `widgets/customer_status_service_panel.dart` | status | stage/progress/ETA-or-wait/technician, appointment, idle paths |
| — | `CustomerAttentionPanel`, `CustomerRefreshNotice`, `CustomerStatusDetails` | `widgets/customer_status_notices.dart`, `.../customer_status_details.dart` | status | localized attention/refresh/details (shared with Home) |
| C13 | `CustomerApprovalsPage` (overview cards + invoices) | `customer_approvals_page.dart` | `/customer_approvals` (+`?estimateId=`) | loading/skeleton, error+pull-retry, empty, decision cards, invoice receipts |
| — | `CustomerApprovalDetailView` (whole-estimate decision + dock) | `widgets/customer_approval_detail_view.dart` | approvals | record, line groups, summary, dock approve + quiet reject, decided read-only, error |
| C14 | `CustomerInvoiceDetailView` (receipt) | `customer_invoice_detail_view.dart` | `/invoice-detail` | header + pill, billed-to/issued, subtotal/VAT/total, receipt note |
| C15 | `CustomerFeedbackView` (3-step review) | `customer_feedback_view.dart` | `/feedback` | overall/category stars, tags + comment + recommend, submit, thanked |

Out of scope and untouched: garage/wizard/breakdown files and their
goldens (all still green at close).

---

## 2. Before / after composition (per screen) — task → concept → composition

| Screen | Old got WRONG (one line) | New does DIFFERENTLY (one line) | Task → Concept → Composition | Viewport @390 EN |
| :-- | :--- | :--- | :--- | :--- |
| Status (C12) | Operational console: combined vehicle line, bespoke stage rows, no wait honesty. | Trip timeline: plate-chip live panel + shared AppTimeline + static wait when no ETA + technician row. | where's my car → trip tracker → live panel + timeline + details | live panel ≈45% |
| Approvals (C13) | One bordered list of rows + inline decision bar. | Resolution desk: per-request cards + itemized estimate + authorized-total dock with Approve + quiet Reject. | decide with confidence → resolution center → cards + lines + dock | decision ≈ dock |
| Invoice (C14) | Generic card stack with grid info tiles. | Nightly-style receipt: mono id + pill + billed rows + subtotal/VAT/total + receipt note. | what do I owe → receipt → header + rows + breakdown | breakdown ≈40% |
| Feedback (C15) | Three enterprise form steps with hardcoded hex stars. | Warm review: theme-amber accessible stars + structured tag chips + recommend + thanked state. | rate my visit → review flow → stars + tags + thanks | stars ≈30% |

Four jobs, four layouts, one warm language. Nothing resembles the old
enterprise-density screens; nothing reads as staff/owner chrome.

---

## 3. Include / remove / enhance (SaaS rework + addendum)

**Included (added, all real):** shared `AppTimeline` reuse for the stage
list (success/info/neutral tones, real times); static indeterminate wait
panel when `estCompletion` is empty (icon + copy, deliberately
non-animated so it never hangs harnesses); technician row from the real
`technicianName`; plate chips + LTR-locked refs/money/times; per-request
approval cards with count chips; `PriceBreakdownDock` as the authorized-
total decision bar (total-only while open, so no amount renders twice);
structured review tags (Fast/Clean/Clear) composing into the existing
`comment` field; theme-amber accessible stars with `N of 5` semantics;
`customer_status_visual_test.dart` (18 goldens: 390 EN/AR + 834 EN +
dark, real Arabic fonts); ~110 `st*/ap*/inv*/fb*` keys with exact EN/AR
parity (placeholders `{progress}`, `{eta}`, `{count}`, `{amount}`,
`{date}`, `{qty}`, `{rate}`, `{pct}`, `{subject}`, `{vehicle}`,
`{label}`).

**Removed:** hardcoded EN copy across all owned files (~120 literals);
hardcoded star gold `0xFFFFB800` (→ theme warning ink); combined
`vehicleLine` single-string renders (→ name + plate chip, LTR-safe);
bespoke journey stage rows (→ shared `AppTimeline`); inline
 approve+reject decision bar (→ dock + quiet reject); duplicate Total
(amount renders once: dock while pending, summary when decided);
`title`/`message` hardcoded defaults on shared status notices (→
nullable + localized fallback, Home benefits too).

**Enhanced:** airy 28/20/20 rhythm, 16px cards, one CTA per screen,
warm microcopy; tablet/desktop centered max-width compositions with
`AppSplitView` (never a rail, never a table — consumer shell); RTL
mirrors with LTR-locked money/refs/plates/phones/times; dark resolves
every tone; 320–1440 + 1.3x/1.6x + 48dp + semantics/focus +
reduced-motion throughout.

**Honest omissions / deferrals (no fake data — FAIL rule):** bay name
(no record field — omitted); photo evidence carousel (no photo fields
on any record — section omitted, not even an empty state for a
plumbed-nothing feature); per-line approve/decline (only endpoint is
whole-estimate PUT — line rows stay read-only); safety callouts (no
safety flag on the model — none shown); invoice discounts/line-items
(no fields — subtotal + VAT + total only); payment actions (no payment
routes/methods anywhere — receipt only); feedback status-gating (route
carries no input AND nothing in-app links to `/feedback`, so no review
is ever prompted on an uncompleted job — satisfied by construction,
proper gating needs route input, a frozen nav semantic); persisted sync
stamp (connectivity pill only, Phase 16 shell).

---

## 4. Reference conformance (house bar + addendum)

Studied before writing a widget: `advisor_home_view.dart` (spacing
rhythm, row grammar, skeleton-mirrors-geometry, toasts) and
`advisor_job_detail_view.dart` (dossier/stepper/dock grammar — the
approval dock and decision flow follow it). The addendum wins every
consumer decision: trip-timeline tracking, `PriceBreakdownDock` with
tabular AED, nightly-style receipt, review flow with addendum tags,
single CTA, warm EN/AR copy, 280ms motion with reduced-motion fallback.
Side-by-side vs the old UI: unrecognizable; vs the Phase 16/17
siblings: same product (same dock/stepper/pass/card voice). Recolored
enterprise form nowhere.

---

## 5. Contracts proof (UI-only, zero logic changes)

Frozen and byte-identical: dashboard/bookings/approvals/invoices
providers, `customerApprovalDetailProvider` family,
`customerProcessApproval(estimateId, action)` whole-estimate PUT,
`customerApprovalsRefreshProvider` bump + invalidations,
`submitFeedback` 7-key map (tags compose into `comment`, no new keys),
`lineAmount` math + qty/discount display rules, approval/invoice
surfacing rules, cancel/booking relations, 60s live refresh timer,
`formatAmount`, pull-to-refresh, all routes/params/extras/nav
semantics, Hive boxes, DTOs.

Non-UI files touched (one-line justification each):

- `customer l10n/app_{en,ar}.arb` + `gen/*` — new keys + regen only.
- Customer tests — recomposed assertions only (split vehicle/plate,
  AppTimeline grouped texts, technician ×2, dock-owned Total, pill
  case, bounded status pumps); zero weakened behavior pins.
- `reports/REPORT_PHASE_18.md`, `reports/PHASE_18/screens/*` (27),
  README ledger row 18.

Shared touches: **none** (`AppTimeline`, `PriceBreakdownDock` reused).
Staff touches: **none**. Owner touches: **none**.

---

## 6. Deltas made this session (all customer-side)

Status journey rewritten on shared `AppTimeline`; live/upcoming/idle
panels recomposed (wait honesty, technician, chips, localized); tab +
page + notices + details localized strings-only (tab structure
untouched — out-of-scope file); approvals overview recomposed to
per-request cards; approval detail recomposed around the dock (whole-
estimate decision preserved); invoice recomposed as receipt (no pay
actions — none exist); feedback recomposed (tags, themed stars,
localized); `customer_status_visual_test` (18) created; all Phase 18
goldens re-rendered; notice defaults made nullable-localized.

---

## 7. Gates & evidence

**Gate 1 — Engineering:**

- `flutter analyze` (customer_app): **0 issues**. `flutter analyze`
  (shared_core): **0 issues** (re-verified, untouched).
- Customer suite: **602/602 ALL GREEN** — every suite in the app,
  including all Phase 16/17/18 suites, route tests, guards and goldens.
  17's 9 stale goldens all resolved here; zero remaining failures.
- `arb_parity_test` (customer): **green** (incl. all new placeholders).
- Manual guards: zero `AppColors.*`/raw widths/breakpoints in owned
  files; zero new app-local duplicates; no rail/breadcrumb/table/Cmd+K/
  payment/URL code in customer code; no `Image.network`/stock URLs; no
  indeterminate spinners in settle-based suites; deprecation guard
  unaffected.

**Gate 2 — Visual (headless):**

- 27 PNGs in `reports/PHASE_18/screens/`: 9 re-rendered owned goldens
  (5 status-tab, 4 approvals) + 18 NEW `status_*/approve_*/invoice_*/`
  `feedback_*` visual goldens (390 EN/AR, 834 EN, dark, real Arabic
  fonts). Deterministic reruns green; reviewed headless in-session
  (all non-empty, exception-free renders).
- Matrix: 390 EN/AR + 834/1024 EN + dark + 1.3x/1.6x + 320–430
  overflow audits (two audit fixes: Flexible invoice amounts, static
  status wait).
- **Live device: NOT PERFORMED** (no device in this session).

**Failures, incidents & owners:**

| Item | State | Owner |
| :--- | :--- | :--- |
| (none — full suite green, analyzer 0) | — | — |
| Bay/photo/safety/discount/payment/per-line/gating deferrals | Missing contracts/routes/fields (§3) | Backend / follow-up |
| Animated wait bar vs settle harnesses | Static wait in status (SOS keeps its adapted animated bar) | This phase (closed) |
| `customer_status_approvals_test.dart` (spec §2) | Does not exist; real suites used instead | Spec erratum, noted |

---

## 8. Files changed (Phase 18 scope)

- Rewritten: `widgets/customer_service_journey.dart`,
  `widgets/customer_status_service_panel.dart`,
  `widgets/customer_approval_detail_view.dart`,
  `customer_approvals_page.dart`, `customer_invoice_detail_view.dart`,
  `customer_feedback_view.dart`
- Strings-only: `widgets/customer_service_status_tab.dart` (structure
  untouched — out-of-scope), `customer_service_status_page.dart`,
  `widgets/customer_status_notices.dart`, `widgets/customer_status_details.dart`
  (via caller), `widgets/customer_booking_detail_service.dart` (already 17),
  `widgets/customer_booking_detail_vehicle.dart` (already 17)
- Kept byte-identical: all providers/entities/datasources/router/sync/
  validation, out-of-scope views, failed-sync items, journey math,
  line-amount math, decision endpoint
- L10n: `app_en.arb`/`app_ar.arb` (+~115 keys), `gen/*` (regen)
- Tests: `test/customer_status_visual_test.dart` (new, 18 goldens);
  recomposed assertions in status/approvals/invoice suites; 9 owned
  goldens re-rendered
- Docs: `reports/REPORT_PHASE_18.md`, `reports/PHASE_18/screens/*` (27),
  README ledger row 18

Staff touches: **none**. Owner touches: **none**. Shared touches:
**none**. Runner artifacts committed: **none** (`test/failures/` debris
removed everywhere touched; goldens are the evidence).
