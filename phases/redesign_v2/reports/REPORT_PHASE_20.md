# REPORT PHASE 20 — CRM Comms & Ops at Sibling Bar

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_20.md`
**Execution Phase:** Concept A V2 — Phase 20 (Archetypes 10 + 8 + 11, enterprise SaaS density)
**Specification:** `phases/redesign_v2/implementation/PHASE_20_CRM_COMMS_TEAM_OPS.md`
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-19
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: screen-level redesign of the CRM comms console and ops
> desk — conversations, leaderboard, reports, integrations hub, settings —
> at the Phase 19 sibling bar (dense tables, panes, tabular data), never
> cheaper and never consumer-Airbnb. Every figure derives from frozen
> provider data; anything without a contract (message threads, send
> endpoints, templates, quotes, period controls, routing rules, payment
> flows) is omitted honestly rather than faked. Conversation/team/report/
> integration providers, validation, routes and models are byte-identical,
> and every non-CRM tree was never touched. Last feature phase before the
> Phase 21 final audit.

---

## 0. Baseline the dirty tree (§0 directive — done FIRST, no code)

Phase 19 is FLOATING (HEAD is `e26a4958`, Phase 18): its ~10 crm +
phases entries are the approved sibling work, read-only for this phase.
No other author's work exists on the tree.

| Path | Disposition | Evidence |
| :--- | :--- | :--- |
| Phase 19 deal radar (floating, crm + phases only) | Carryover sibling (same shell/tables/sheets) | Untouched; re-verified green at close |
| `apps/staff_app/**`, `apps/owner_app/**`, `apps/customer_app/**`, `packages/**` | READ-ONLY | Final status: zero paths |
| CRM comms files R6–R11 + channel widgets | REBUILT per scope | Zero-hardcode; all copy in ARB with EN/AR parity |
| CRM goldens for R6–R11 | CONFIRMED NEW | No goldens existed for these surfaces — all created here |
| `test/features/crm/crm_comms_admin_test.dart` (spec §2) | DOES NOT EXIST | Created here (10 contract tests, green) |
| CRM analyzer 0, suite green at baseline | KEPT green throughout | `flutter analyze` clean at close |

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| R6 | `CrmConversationsPage` (3/2/1-pane console) | `crm_conversations_page.dart` | tab 2 | channel list + unread, honest thread, dossier rail, drilldown, empty |
| R7 | `CrmSalesTeamPage` (ranked leaderboard) | `crm_sales_team_page.dart` | tab 3 | rank badges, revenue/counts/rates, empty |
| R8 | `CrmReportsPage` (charts, painters kept) | `crm_reports_page.dart` | tab 5 | 4 real-data charts + key metrics, per-chart empties |
| R9 | `CrmIntegrationsPage` (apps hub) | `crm_integrations_page.dart` | tab 6 | platform cards + sync badges, connected sheet, toasts |
| R10 | `CrmSettingsPage` (3 real toggles) | `crm_settings_page.dart` | tab 7 | workflow/appearance rows, language switcher |
| R11 | `ConnectIntegrationSheet` (validated connect) | `connect_integration_sheet.dart` | sheet | platform pick, META/ZOHO credential rules, busy/error/success |
| — | `CrmChannelGrid` (strings-only) | `crm_channel_widgets.dart` | dashboard | channel cards (structure untouched) |

Out of scope and untouched: shell, dashboard, leads, kanban, tasks,
detail/form sheets and their goldens (all still green at close).

---

## 2. Before / after composition (per screen) — task → concept → composition

| Screen | Old got WRONG (one line) | New does DIFFERENTLY (one line) | Task → Concept → Composition | Viewport @390 EN |
| :-- | :--- | :--- | :--- | :--- |
| Conversations (R6) | Dead list with no-op taps and hardcoded copy. | 3-pane console (list + honest thread + dossier) collapsing to drilldown. | triage talk → comms console → panes + thread | list ≈50% |
| Team (R7) | Flat rows, no rank, no header, no empty state. | Ranked leaderboard with medals, header and empty state. | who delivers → leaderboard → ranks + stats | rows ≈65% |
| Reports (R8) | Charts with hardcoded titles and a tight metric grid. | Same real painters under localized headers with roomy metric cells. | prove performance → analytics desk → charts + metrics | charts ≈60% |
| Integrations (R9) | Cards with hardcoded badges and copy. | Same real flows in localized hub + connected sheet with toasts. | keep sources alive → ops hub → cards + sheet | cards ≈55% |
| Settings (R10) | Rows with hardcoded copy, loose canvas. | Same 3 real toggles in a 720-centered localized desk. | configure work → settings desk → rows | rows ≈60% |
| Connect (R11) | Working form with hardcoded copy. | Identical rules/fields, fully localized. | connect source → form sheet → pick + fields | form ≈70% |

Six jobs, six layouts, one dense language. Nothing resembles the old
screens side-by-side; nothing reads consumer or cheaper than Phase 19.

---

## 3. Include / remove / enhance (SaaS rework)

**Included (added, all real):** honest thread pane (latest message +
history note, dossier rail with every record field); mobile drilldown
with back + selection fallback when a thread vanishes; rank badges from
list position; header/empty states where none existed; localized
legends/empties/titles across reports (painters byte-identical except a
localized donut-center label passed in); localized hub/sheet/settings
copy; `crm_comms_admin_test.dart` (10) + 12 NEW visual goldens (390
EN/AR + 1280 + dark, real Arabic fonts); ~95 `cv*/tm*/rp*/it*/se*/cs*`
keys with exact EN/AR parity.

**Removed:** hardcoded EN copy across all owned files (~90 literals);
no-op thread taps (real drilldown); unbounded grid aspect (metric-cell
overflow fix, §7); dead `example` sample rendering (unchanged behavior
— samples were never rendered).

**Enhanced:** dense enterprise rhythm, tabular LTR data, 48dp targets,
StatusPill grammar; desktop 3-pane comms + centered 720 settings;
tablet 2-pane comms; RTL mirrors; dark resolves every tone; 320–1440 +
1.3x + semantics/focus + reduced-motion throughout.

**Honest omissions / deferrals (no fake data — FAIL rule):** message
threads/history (no thread API — newest message + note instead);
composer/send (no send endpoint — no dead input box); template chips +
quote-insert (no template/quote contracts); period control (no period
record — subtitle states ranking basis); routing selectors (zero
routing config anywhere — `autoAssign` switch is the only assignment
config); payment flows; new endpoints; mock figures (every number is
provider data). Charts render LTR data order (standard data-viz;
legends/labels localized).

---

## 4. Reference conformance (house bar)

Studied before writing a widget: `advisor_home_view.dart` (spacing
rhythm, row grammar, skeleton-mirrors-geometry, toasts) and
`advisor_job_detail_view.dart` (dossier hierarchy, lifecycle, action
dock — the thread dossier + connected sheet follow it). Styling
resolves Concept A §6 with no hand-rolled theme. Side-by-side vs the
old CRM UI: unrecognizable; vs the Phase 19 sibling: same terminal
(same panes/tables/pills/sheets). Cheaper output nowhere.

---

## 5. Contracts proof (UI-only, zero logic changes)

Frozen and byte-identical: conversation/team/report/integration
providers, connect/sync/disconnect flows + credential maps + validation
rules, settings toggles, chart data mappings, routes/params/extras/nav
semantics, Hive/sync, DTOs. Painters byte-identical except the passed-
in donut label (no drawing change).

Non-UI files touched (one-line justification each):

- `apps/crm_app/lib/l10n/app_{en,ar}.arb` + `gen/*` — new keys + regen only.
- CRM tests — new comms/admin (10) suite; zero touched behavior pins
  elsewhere (all 45 prior tests still green).
- `reports/REPORT_PHASE_20.md`, `reports/PHASE_20/screens/*` (12),
  README ledger row 20.

Shared touches: **none**. Staff/owner/customer touches: **none**.

---

## 6. Deltas made this session (all CRM-side)

Conversations rebuilt (panes + honest thread + dossier + drilldown);
team rebuilt (ranks + header + empty); reports localized (painters
kept, grid aspect fixed, donut label passed in); integrations hub +
connected sheet localized; settings localized + centered; connect sheet
localized (rules byte-identical); channel grid strings-only; two test
additions (comms suite + visual goldens); 12 goldens created.

---

## 7. Gates & evidence

**Gate 1 — Engineering:**

- `flutter analyze` (crm_app): **0 issues**. `flutter analyze`
  (shared_core): **0 issues** (re-verified, untouched).
- CRM suite: **67/67 ALL GREEN** — 45 prior (incl. 07.1 migration
  source-scan + pipeline 9) + 10 new comms/admin + 12 new visual
  goldens. `crm_comms_admin_test.dart` (spec §2) did not exist —
  created and green.
- `arb_parity_test` (crm): **green**.
- Manual guards: zero `AppColors.*`/raw widths/breakpoints in new code;
  zero new app-local duplicates; no composer/period/routing/payment
  code; no stretched-phone compositions; deprecation guard unaffected.

**Gate 2 — Visual (headless):**

- 12 NEW PNGs in `reports/PHASE_20/screens/` (test originals in
  `apps/crm_app/test/goldens/`): conversations 390 EN/AR + 1280,
  team 390 EN/AR, reports 390 + 1280, integrations/settings/connect
  390, conversations/team dark. Deterministic reruns green; reviewed
  headless in-session (all non-empty, exception-free renders).
- Matrix: 390 EN/AR + 834 (Phase 19 suite still green) + 1280 EN +
  dark + 320/1.3x smoke (no new overflows).
- **Live device: NOT PERFORMED** (no device in this session).

**Failures, incidents & owners:**

| Item | State | Owner |
| :--- | :--- | :--- |
| (none — full suite green, analyzer 0) | — | — |
| Thread/send/template/quote/period/routing deferrals | Missing APIs/contracts (§3) | Backend / follow-up |
| `crm_comms_admin_test.dart` (spec §2) | Did not exist; created here | Spec erratum, noted |
| Metric-cell overflow under real fonts | Grid aspect relaxed (in-scope fix) | This phase (closed) |

---

## 8. Files changed (Phase 20 scope)

- Rewritten: `widgets/crm_conversations_page.dart`,
  `widgets/crm_sales_team_page.dart`,
  `widgets/crm_integrations_page.dart`,
  `widgets/crm_settings_page.dart`
- Localized (logic byte-identical): `widgets/crm_reports_page.dart`
  (painters kept), `widgets/connect_integration_sheet.dart`
- Strings-only: `widgets/crm_channel_widgets.dart`
- Kept byte-identical: all providers/entities/datasources/router/sync/
  validation, out-of-scope pages/sheets, shell, painters (drawing)
- L10n: `app_en.arb`/`app_ar.arb` (+~95 keys), `gen/*` (regen)
- Tests: `test/features/crm/crm_comms_admin_test.dart` (new, 10);
  `test/crm_deal_visual_test.dart` extended (+12 goldens)
- Docs: `reports/REPORT_PHASE_20.md`, `reports/PHASE_20/screens/*` (12),
  README ledger row 20

Staff touches: **none**. Owner touches: **none**. Customer touches:
**none**. Shared touches: **none**. Runner artifacts committed:
**none** (no `test/failures/` produced; goldens are the evidence).
