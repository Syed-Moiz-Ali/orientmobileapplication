# REPORT PHASE 09 — Staff Repair Estimates Studio

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_09.md`
**Execution Phase:** Concept A V2 — Phase 09 (Archetype 4: Repair Order Studio)
**Specification:** `phases/redesign_v2/implementation/PHASE_09_STAFF_REPAIR_ESTIMATES.md`
**Prerequisites:** Phase 08 Completed (`REPORT_PHASE_08.md`)
**Target Package:** `apps/staff_app/lib/features/advisor/` (repair-order files only)
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-16
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: full screen-level redesign (not a color refresh) of the
> two Phase 09-owned repair-order surfaces — the Repair Order Studio (S20)
> and the Bay Dispatch assign view (S21) — plus their owned widgets, on the
> centralized theme + shared-widget architecture, in home-grammar siblinghood
> with the advisor hub. Prices, VAT, discount math, providers and assign
> logic are byte-identical; the money dock projects provider totals only and
> invents zero figures.

> **Ledger note.** Phase 09 was implemented in-tree across prior sessions but
> the report was never written (08 done, 10 done, 11 done, 09 missing). This
> document closes that hole against the current bar, not the old thin spec.

---

## 0. Baseline first (no code)

`git status` was clean and `git log` confirmed the prior Phase 09
implementation committed in-tree. Classification before any new code:

| Path | Disposition | Evidence |
| :--- | :--- | :--- |
| `repair_order_view.dart`, `advisor_assign_tasks_view.dart`, `repair_estimate_math.dart`, `repair_price_breakdown_dock.dart`, `repair_estimate_share_sheet.dart` | ADOPT as baseline | Committed studio composition: greeting header, stepper, flat category list, 72px rows, money dock, share sheet, dispatch cards; analyzer 0 |
| `inspection_provider.dart`, `inspection_view_model.dart`, `advisor_providers.dart`, `advisor_remote_datasource.dart` (math/providers/assign logic) | FROZEN — untouched by this session | `git log` shows no Phase 09-session diffs outside presentation/widgets/l10n/tests; §7 proof below |
| `app_en.arb` / `app_ar.arb` + gen (studio + dispatch keys) | ADOPT | Exact EN/AR parity, `arb_parity` green |
| `advisor_phase09_{estimates,studio,visual,theme,responsive_guard}_test.dart`, `test/goldens/repair_*.png` (10) | ADOPT as baseline, EXTENDED | Math/dock/qty/tier suites green; 6 new tier/state widget tests added this session; studio goldens re-rendered for the restored tier composition |
| `REPORT_PHASE_09.md`, README 09 row | MISSING — created this session | This file; ledger row added |

No mystery diffs were built upon: the tree was clean and every touched file
is Phase 09-owned (`*/presentation/`, `*/widgets/`, l10n, tests, goldens).

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Route / entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| S20 | `RepairOrderView` studio | `advisor/presentation/pages/repair_order_view.dart` | pushed from job detail (`fromInspection`, `onBack`) | greeting header + stepper + breadcrumbs, search, tier groups, sticky category headers, 72px rows, money dock, details card, loading/empty/no-match/error+retry/offline |
| S20b | `RepairOrderPreviewView` (review + submit) | same file | `AppRoutes.repairOrderPreview` | invoice document, signature capture, approval-method picker, submit (online + failure), guards |
| S20c | Service/parts pickers | same file | studio Add actions | search + select + confirm, no-match, selected counts |
| S21 | `AdvisorAssignTasksView` (Bay Dispatch) | `advisor/presentation/pages/advisor_assign_tasks_view.dart` | pushed from job detail / studio rail (`jobCardRef`) | greeting header + breadcrumbs, technician cards, task list, dispatch dock, loading/empty/error/offline |
| — | Estimate math (display projections) | `presentation/widgets/repair_estimate_math.dart` | used by S20/S21 | 5% VAT, tier classifier, stock/tech decorations (deterministic, never persisted) |
| — | `RepairPriceBreakdownDock` | `presentation/widgets/repair_price_breakdown_dock.dart` | studio bottom dock + desktop rail foot | subtotal/labor/VAT/total via MoneyAed, confirm vs add CTA, trust line |
| — | `RepairInvoicePreview` + `RepairEstimateShareSheet` | `presentation/widgets/repair_estimate_share_sheet.dart` | review screen + share action | workshop header, vehicle, grouped lines, totals, WhatsApp deep link, copy-link |

Routes, `extra` shapes, submit/assign payloads, Hive boxes, sync-queue ops
and the approval persistence are byte-identical. No backend inventions.

---

## 2. Before / after composition (per screen) — task → concept → composition

| Screen | Old got WRONG (one line) | New does DIFFERENTLY (one line) | Task → Concept → Composition |
| :-- | :--- | :--- | :--- |
| Studio (S20) | One long box-column form (customer card, reference field, services table, parts table, totals card) that read as paperwork and hid structure. | Tiered work-order studio: greeting header + tappable Parts→Labor→Review stepper + search, then Mandatory/Optional collapsible groups with sticky 32px category headers and 72px home-grammar rows, money dock pinned. | price a repair legibly → dossier disclosure → tiers + sticky sections + dock |
| Studio rows | Pricing tables with per-cell inputs; no stock signal; discount column with no meaning. | Parts rows: 3px tier bar + title + qty×rate meta + In-Stock·Bay / Order·ETA pill + stepper + rate/discount + remove. Labor rows: operation + hours×rate + tech avatar + stepper + suggest + rate/discount + remove. | edit a line fast → home row grammar → identity + money + controls |
| Money dock | Static totals card mid-scroll (`Services Total / Parts Total / Total`, no VAT line). | Sticky `PriceBreakdownDock`: Parts subtotal + Labor + VAT 5% + Total via MoneyAed tabular, live on qty, single Confirm CTA + trust line, pinned bottom (compact) / rail foot (desktop). | trust the total → single money truth → dock |
| Review/submit | Navy `AppBar` invoice with duplicated tables and hardcoded copy. | `WorkspaceAppBar` + breadcrumbs + formal `RepairInvoicePreview` (tiered groups, MoneyAed totals) + signature + approval-method sheet + single submit. | approve with customer → formal document → invoice + sign + submit |
| Dispatch (S21) | Mechanic dropdown + flat task rows; technicians indistinguishable. | Greeting header + breadcrumbs; technician cards (avatar + name + skill chips + load bar + availability) with one-tap assign + haptic + home-pattern toast; dispatch dock with count CTA. | put work on a tech → visual dispatch → cards + dock |

No screen repeats the header + KPI + grid + list template. A palette-only
refresh of the old form was explicitly rejected during development (tiers,
sticky headers, dock, dispatch cards and the invoice are new compositions).

**Tier/side-bar history (why the code looks this way).** An interim
iteration flattened the tiers and dropped the side bars after in-progress
feedback that collapsed groups hid services. This build reinstates the
binding spec — Mandatory (expanded default) vs Optional (collapsible),
3px tier side color — while keeping the comprehension safeguards earned
along the way: both tiers open on arrival, search auto-opens tiers, and an
always-visible primary-tinted Add action ends every category. No line can
arrive hidden, and none can become unreachable.

---

## 3. Include / remove / enhance (SaaS rework)

**Included (was missing):** stepper wayfinding, search with no-match + clear,
tier disclosure, stock pills, qty steppers, rate/discount editors, money dock
with VAT line + trust line, share sheet (WhatsApp deep link + copy-link),
dispatch cards with load/skills/availability, details card (reference,
recommendations, delivery picker, notify toggle, pre-service media),
signature capture, approval-method picker, skeleton-mirrors-geometry,
empty/no-match/error+retry/offline per section, EN/AR keys (165 `tech`-style
`advisorStudio*`/`advisorDispatch*`/`advisorEstimate*` pairs with parity),
48dp targets, focus/semantics, reduced-motion durations, desktop 60/40 rail.

**Removed:** bespoke estimate `AppBar`s, navy preview chrome, `IC.*` legacy
palette usage, `_CategorySection` box containers (replaced by sticky sliver
headers), dead `_TierBody`/`_TierGroup` predecessors (rebuilt as sliver
tier groups), Tag editor and Customer-requests editor (payload keys stay
frozen; no UI edits them), `test/failures/` runner debris.

**Enhanced (recomposed):** studio list is now true slivers — category
mini-headers pin while rows scroll beneath on both panes; desktop is a
separate 60/40 composition (studio pane scrolls, rail scrolls, dock pinned
at the rail foot) instead of a stretched phone column; rows keep 72px
min-height so 1.3x text grows instead of clipping.

---

## 4. Changed files + rationale

**Rewritten/extended (Phase 09-owned):**
- `repair_order_view.dart` — this session: tier groups + sticky
  `SliverPersistentHeader` categories + 3px side bars restored onto the
  committed studio (greeting, stepper, search, rows, pricing, dock wiring,
  details, pickers, preview, signature untouched in behavior).
- `advisor_phase09_studio_test.dart` — NEW (6 tests: tiers open on arrival,
  collapse/reopen, search auto-open, sticky headers, error+retry, AR smoke).

**Untouched by design (this session):** `advisor_assign_tasks_view.dart`,
`repair_estimate_math.dart`, `repair_price_breakdown_dock.dart`,
`repair_estimate_share_sheet.dart`, all providers/models/datasources/routes,
`app_en.arb`/`app_ar.arb` (no new keys needed), existing suites.

**Shared (untouched):** zero `shared_core`/`shared_auth`/`shared_models` diffs.

---

## 5. Contracts-frozen proof (prices/VAT/discount + providers + assign)

- Frozen files (no diff this session or any Phase 09 session):
  `inspection_provider.dart` (`servicesTotal`/`partsTotal`/`grandTotal`,
  `updateServiceLine`/`updatePartLine`), `inspection_view_model.dart`
  (`amount = rate×qty − discountAmount`), `advisor_providers.dart`
  (technicians, work items, `assignTasks`), remote datasource payloads.
- The dock never recomputes a line: it projects provider-owned
  parts/labor totals into the statutory 5% VAT breakdown only.
- Proof by suite (all green): frozen line math (4), VAT projection (4),
  tier classifier (3), decorations determinism (4), dock widget incl. live
  recalc on rebuild (3), studio totals-match-provider-math (1).
- Assign flow calls the identical `assignTasks(jobCardRef, payload)` with the
  identical item shape; approval persistence identical to the home radar.

---

## 6. Theme audit

- All rendered colour resolves via `Theme.of(context).colorScheme` /
  `context.semanticColors` (tier side bars: mandatory → danger, optional →
  info; stock/sync/skill pills via tone ctors; avatar tints via alpha).
  No `AppColors.*` / `AppDarkColors.*`, no `Color(0x…)`, no `Brightness`
  branches in owned files — enforced by `advisor_phase09_theme_test`
  (2/2 green).
- `Colors.*` survives only as `Colors.transparent` (exempt) or behind
  `FIXED-INK` comments (white glyphs on saturated fills; signature ink on
  paper).
- No new theme tokens; no shared theme files changed.

## 7. Widget audit (reused 01.2 vs newly created)

**Reused from shared_core:** `AppBreadcrumbs`/`AppBreadcrumbItem(.current)`,
`AppStepper`, `AppSearchField`, `AppCard`, `SectionHeader`, `AppTextField`,
`AppQuantityStepper`, `AppLinearProgress`, `AppSkeleton`, `StatusPill` tone
ctors, `EmptyState` / `.error` / `.noMatch`, `PrimaryButton`,
`SecondaryButton`, `showAppModalSheet`, `showAppConfirmationDialog`,
`AppDimensions` / `AppTextStyles` / `AppMotion` tokens, MoneyAed
(`shared_models`). Grep proof: zero new app-local duplicates; owned widgets
are feature-domain composition (math/dock/invoice), not primitive copies.

**Genuine local compositions (kept local, single consumer):** `_TierHeader`,
`_MiniHeaderDelegate`, `_StudioPartRow` / `_StudioLaborRow`,
`_RowPricingFields`, `_TechnicianCard` (assign), pickers, signature pad.

## 8. Shell integration

| Requirement | Implementation |
| :--- | :--- |
| Greeting header, no app-bar bulk | Product exception (home grammar): title + context + Synced pill + reset/share actions; breadcrumbs carry pushed wayfinding |
| Offline pill announces once | `OfflineStatusPill(pendingSyncCount)` in header; `showOfflineBanner` nowhere; queue announcement single |
| Stepper wayfinding | `AppStepper` (Parts → Labor → Review, tappable: scrolls to labor / opens review), progress derived from provider lines only |
| Master-detail desktop | Studio pane 60% (own scroll + sticky headers) + totals/assign rail 40% (own scroll, dock pinned at foot); max canvas 1180 centred |
| Preserved | Routes/extras/Hive/sync; one primary CTA per surface; haptics + home-pattern toasts |

## 9. Localization & RTL proof

- EN+AR parity with zero hardcode (`arb_parity_test` green). Numbers, plates,
  VINs, phones and all MoneyAed figures render LTR-locked with tabular Latin
  digits in both locales; chrome mirrors in AR (goldens confirm).
- States covered per section: loading (geometry-mirroring skeleton),
  empty (collapsed category + Add), no-match (+ clear), error + retry,
  offline pill.
- Responsive: verified 320/390/768/1280/1440 layout classes via `spec.pick`
  only (responsive guard green — zero raw `MediaQuery` width reads, zero
  breakpoint literals); 1.3x text grows rows instead of clipping; dark spots
  green; 48dp minimums on every control; focus rings/semantics on interactive
  rows; motion through `AppMotion.resolve` (static under reduced motion).

## 10. Viewport matrix

| Width | Verified | Composition |
| :--- | :--- | :--- |
| 390 EN/AR | goldens + overflow clean | greeting + stepper + search, then tier groups; dock pinned bottom; content owns the scroll |
| 768 | (spec.pick medium → compact composition) | single-column studio stream, sheets become centred dialogs via `showAppModalSheet` |
| 1280/1440 EN | goldens | pinned header chrome + 60% studio pane (sticky headers) + 40% rail (pinned dock); never stretched |
| Dark | 390 dark spots (studio + assign) | full token parity |

Chrome budget at 390×844 (from layout constants): greeting ≈150 +
breadcrumbs ≈30 + stepper ≈110 + search ≈70 ≈ 360px chrome → the studio
list owns ≈55–60% of first paint, and 100% of the scroll thereafter with the
dock persistently visible. Overflow audit: full-scroll sweeps in tests
(zero `takeException`), including a 12px delivery-row overflow caught by the
new tests and fixed (Flexible + ellipsis).

## 11. Failures, deferrals + owners

| Item | Disposition | Owner |
| :--- | :--- | :--- |
| Sublet lines | DEFERRED — no sublet data source exists; the section honestly reports vendor-work-booked-outside instead of inventing lines | Backend (sublet feed, then UI) |
| Delivery-row 12px overflow (prior-session code) | FIXED THIS SESSION — exposed by the new full-scroll sweep test; Flexible + ellipsis | This phase (done) |
| Labor `1hh` double-unit cosmetic (prior-session caller passed `'${qty}h'` into a template already containing `h`) | FIXED THIS SESSION — caller passes bare qty; EN+AR templates untouched | This phase (done) |
| Sliver laziness vs eager assertions | TESTS ADAPTED — below-fold slivers are not built until scrolled; tier tests scroll-to-reveal instead of assuming eagerness | This phase (done) |
| `REPORT_PHASE_09.md` + README row missing | CREATED THIS SESSION | This phase (done) |
| `test/failures/` runner debris | DELETED, never committed | This phase (done) |
| Live-device run | NOT PERFORMED — no device in this environment | Product owner |

## 12. Gates

**Gate 1 — engineering:** `dart analyze apps/staff_app` **0 errors, 0 warnings**.
Suites **40/40 green**: frozen math (4) + VAT (4) + tier classifier (3) +
decorations (4) + dock widget (3) + studio tier/state widgets (6) + visual
(11: studio/dispatch/share 390 EN/AR, 1280, dark, no-match, totals-math) +
theme guard (2) + responsive guard (2) + `arb_parity` (1).

**Gate 2 — visual:** 10 goldens captured with real fonts (Plus Jakarta Sans
+ IBM Plex Sans Arabic + Material Icons), inspected native and pairwise
against HOME (greeting rhythm, divider-row grammar, dock pattern, toast
style) — re-rendered this session for the restored tier composition.
Evidence: `phases/redesign_v2/reports/PHASE_09/screens/`. Live: NOT PERFORMED.

## 13. Evidence

`phases/redesign_v2/reports/PHASE_09/screens/` — 10 PNGs (studio 390 EN/AR +
dark + 1280 + no-match; dispatch 390 EN/AR + dark + 1280; share 390 EN).
Canonical sources: `apps/staff_app/test/goldens/repair_*.png`.

## 14. Reference conformance (home bar)

Greeting header, tappable stepper (home progress grammar), divider rows,
skeleton-mirrors-geometry, home `_toast` pattern, haptics, breadcrumbs,
single-primary dock, state coverage and motion restraint all match
`advisor_home_view.dart` / `advisor_job_detail_view.dart` spacing rhythm and
row/card grammar. Task-driven deltas: tier disclosure with sticky sections,
stock pills, price editors, money dock, invoice share sheet, dispatch cards —
the estimates studio reads as the home's sibling doing money, not a
different app.
