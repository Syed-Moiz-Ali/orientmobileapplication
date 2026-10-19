# REPORT PHASE 19 — CRM Deal Radar at House Bar

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_19.md`
**Execution Phase:** Concept A V2 — Phase 19 (Archetype 9, enterprise SaaS density)
**Specification:** `phases/redesign_v2/implementation/PHASE_19_CRM_DEAL_RADAR_PIPELINE.md`
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-19
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: screen-level redesign of the CRM deal terminal — shell,
> dashboard, leads table/Kanban, tasks, lead sheets — at enterprise house
> bar (Archetype 9: dense tables, tabular AED, AppTable/FilterBar,
> Cmd/Ctrl+K, master-detail), never Airbnb consumer. Every figure derives
> from frozen provider data; anything without a contract (probability %,
> snooze, payment flows, GPS, new endpoints) is omitted honestly rather
> than faked. Lead/task/status providers, the updateLead flow, validation,
> routes and models are byte-identical, and the staff/owner/customer trees
> were never touched.

---

## 0. Baseline the dirty tree (§0 directive — done FIRST, no code)

Phase 18 is LANDED as `e26a4958` (landed mid-session; verified clean:
customer + phases only, zero staff/owner/shared-code paths — plus 16
`test/failures/` debris PNGs swept in by the same external commit,
recorded below, absent from the working tree). No other author's work
exists on the tree.

| Path | Disposition | Evidence |
| :--- | :--- | :--- |
| Customer 16–18 (16/17 landed, 18 floating ~52 entries) | Read-only either way | Final status: zero customer paths; 18 re-verified untouched |
| `apps/staff_app/**`, `apps/owner_app/**`, `packages/**` | READ-ONLY | Final status: zero paths (one justified pubspec line, §5) |
| CRM tree (07.1 migrated shell: DashboardShell + WorkspaceAppBar + AppKpiCard, analyzer 0, 21/21 green) | REBUILT per scope, carryover kept | 07.1 migration test still green; `CrmAppBar`/`CrmHeaderBanner`/`CrmKpiCard` still zero-referenced |
| CRM goldens | CONFIRMED NEW | `test/goldens/` did not exist — all 15 goldens created here |
| `test/features/crm/crm_pipeline_test.dart` (spec §2) | DOES NOT EXIST | Created here (9 contract tests, green) |

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| Shell | `CrmDashboardView` (chrome + search + nav) | `crm_dashboard_view.dart` | all tabs | frosted bar, search trigger + Cmd/K palette, offline pill, bell + avatar, rail/drawer/bottom-nav |
| R1 | `CrmDashboardPage` (velocity + funnel + follow-ups) | `widgets/crm_dashboard_page.dart` | tab 0 | KPI grid, tappable funnel + filter note, channels, activity, recent leads, connect/sync empties |
| — | `LeadPipelineWidget` (tappable funnel) | `widgets/crm_pipeline_widget.dart` | dashboard | stage bars + counts + AED + conversion + won revenue, selected ring |
| R2 | `CrmLeadsPage` (table/Kanban + master-detail) | `widgets/crm_leads_page.dart` | tab 1 | search, view toggle, source/agent/stage filters, sortable table, side dossier, empties |
| — | `CrmKanbanView` (swimlanes + quick-select) | `widgets/crm_kanban_view.dart` | leads | stage columns, counts, card move menus (full stage universe) |
| R3 | `CrmTasksPage` (checklist + badges) | `widgets/crm_tasks_page.dart` | tab 4 | count, toggle/edit/delete, overdue/today badges, empty, form |
| R4 | `LeadDetailSheet` (dossier + launchers) | `widgets/lead_detail_sheet.dart` | sheet | contact/vehicle/value/notes, activities, WhatsApp/Call LTR, status chips, delete confirm |
| R5 | `LeadFormSheet` (create/edit + PhoneNumber) | `widgets/lead_form_sheet.dart` | sheet | lookup dropdowns, date picker, inline validation, canonical phone save |
| — | `crm_board_filter.dart` (stage filter + status-map) | `support/crm_board_filter.dart` | leads | presentation-only shared state, exact status payload |

Out of scope and untouched: conversations/sales-team/reports/integrations/
settings pages, channel/activity/recent/follow-up widgets (strings-only
localization), all providers/entities/datasources/router.

---

## 2. Before / after composition (per screen) — task → concept → composition

| Screen | Old got WRONG (one line) | New does DIFFERENTLY (one line) | Task → Concept → Composition | Viewport @390 EN |
| :-- | :--- | :--- | :--- | :--- |
| Shell | Shared chrome with hardcoded copy, no search, no offline pill. | Localized frosted bar + Cmd/K palette over live leads + offline pill + same rail/drawer. | command the floor → terminal chrome → bar + palette + nav | chrome ≈112px |
| Dashboard (R1) | Static funnel display with hardcoded copy, no funnel action. | Tappable funnel that filters the board + localized dense sections. | where's the money → radar → pods + funnel + follow-ups | pods ≈40% |
| Leads (R2) | Cards list + read-only Kanban + hardcoded filters. | Sortable AppTable / Kanban with move menus + FilterBars + side dossier + stage chip. | work the pipe → terminal → table/Kanban + dossier | table ≈60% |
| Tasks (R3) | Plain checklist, no due honesty. | Same flows with parse-only overdue/today badges + toggle semantics. | what slips → checklist → flags + badges | list ≈70% |
| Sheets (R4/R5) | Detail without contact actions; form without phone rules. | WhatsApp/Call LTR launchers with failure notices; PhoneNumber validate + canonical save. | reach + capture → dossier + form → actions + rules | actions ≈20% |

Five jobs, five layouts, one dense language. Nothing resembles the old
screens side-by-side; nothing reads consumer-Airbnb.

---

## 3. Include / remove / enhance (SaaS rework)

**Included (added, all real):** `WorkspaceSearchShortcuts` + `onSearch`
palette over live leads (jump-to-tab + dossier); `showOfflineStatus`
pill + `showOfflineBanner:false`; frosted desktop bar; tappable funnel
stages (presentation-only stage filter over frozen `filteredLeads`,
cleared from dashboard or leads); sortable AppTable (Lead/Value) with
compact record rows; `AppMasterDetailScaffold` side dossier; Kanban
quick-select moves through the exact status-change map (full known
universe, snackbar confirm); agent FilterBar (local, over frozen
results); source FilterBar over the existing filter provider;
WhatsApp (`wa.me`) + tel: launchers with bounded intents + failure
notices; `PhoneNumber` validate-when-present + canonical save; overdue/
today badges from parseable dates only; `crm_pipeline_test.dart` (9)
+ `crm_deal_visual_test.dart` (15 NEW goldens: 390 EN/AR + 834/1280 EN
+ dark, real Arabic fonts); ~150 CRM keys with exact EN/AR parity.

**Removed:** hardcoded EN copy across all owned files (~150 literals);
hardcoded kbd hint on compact bars (overflow audit); bespoke view
toggle + filter chips (→ shared toggle + `AppFilterBar`); dead
`_CrmPulseHeader` duplication risk (kept, localized); `_profileData`
top-level constant (→ localized builder).

**Enhanced:** dense 24/16/16 enterprise rhythm, tabular LTR AED/phones/
dates, 48dp targets, StatusPill grammar throughout; tablet multi-column
Kanban + 40/60 master-detail; desktop rail + dense table + side dossier
(never stretched phone); RTL mirrors; dark resolves every tone;
320–1440 + 1.3x + semantics/focus + reduced-motion throughout.

**Honest omissions / deferrals (no fake data — FAIL rule):** probability
% column (no record field — omitted, never derived); task snooze (no
endpoint — omitted); drag-and-drop (quick-select satisfies the
spec's either/or through the same endpoint); per-line approval-style
actions (whole-record endpoints only); payment flows; GPS; new
endpoints; mock figures (every number is provider data, formatted
only). `CrmColors`/`AppColors` in untouched files stay frozen (visuals
byte-identical); new code resolves theme roles.

---

## 4. Reference conformance (house bar)

Studied before writing a widget: `advisor_home_view.dart` (spacing
rhythm, row grammar, skeleton-mirrors-geometry, toasts) and
`advisor_job_detail_view.dart` (dossier hierarchy, lifecycle, action
dock — the lead dossier + decision flows follow it). Styling resolves
Concept A §6 (`context.colors` / `context.semanticColors`) with no
hand-rolled theme. Side-by-side vs the old CRM UI: unrecognizable; vs
staff/owner: same density grade, same component grammar. Cheaper output
nowhere.

---

## 5. Contracts proof (UI-only, zero logic changes)

Frozen and byte-identical: `crmUiProvider` (tabs/search/refresh),
`crmLeadProvider` + `crmLeadSourceFilterProvider` + `filteredLeads`,
`updateLead/createLead/deleteLead` flows and map shapes,
`crmTaskProvider` toggle/add/update/delete, `teamMembersProvider`,
`leadAnalyticsProvider`, repositories/datasources/interceptors,
validation rules (name-required kept; phone validated only when
present), Hive/sync, routes/params/extras/nav semantics, DTOs.
`updateLeadStatus` does not exist anywhere — stage moves use the exact
`updateLead(id, status-map)` the detail sheet always sent (shared
helper, identical keys/values).

Non-UI files touched (one-line justification each):

- `apps/crm_app/pubspec.yaml` (+1 line: `url_launcher`) — mandated
  WhatsApp/Phone launchers need it; resolved offline from the workspace
  pub cache, no version churn, analyzer still 0.
- `apps/crm_app/lib/l10n/app_{en,ar}.arb` + `gen/*` — new keys + regen only.
- `support/crm_board_filter.dart` + `support/crm_l10n.dart` (new,
  presentation zone) — filter state + null-safe l10n accessor.
- CRM tests — new pipeline (9) + visual (15) suites; recomposed pins in
  none (existing 21 untouched and green).
- `reports/REPORT_PHASE_19.md`, `reports/PHASE_19/screens/*` (15),
  README ledger row 19.

---

## 6. Deltas made this session (all CRM-side)

Shell recomposed (search + pill + frosted + localized, refresh tucked
off compact); dashboard localized with tappable funnel; pipeline widget
gains taps/selection/keys; leads page rebuilt (table/Kanban/dossier/
filters/sort); kanban gains quick-select moves; detail sheet gains
launchers; form sheet gains PhoneNumber rules; tasks gain badges;
`crm_board_filter.dart` + `crm_l10n.dart` created; two test suites
created; 15 goldens created (none existed).

---

## 7. Gates & evidence

**Gate 1 — Engineering:**

- `flutter analyze` (crm_app): **0 issues**. `flutter analyze`
  (shared_core): **0 issues** (re-verified, untouched).
- CRM suite: **45/45 ALL GREEN** — 21 pre-existing (incl. 07.1
  migration source-scan + EN/AR overflow) + 9 new pipeline contracts +
  15 new visual goldens. `crm_pipeline_test.dart` (spec §2) did not
  exist — created and green.
- `arb_parity_test` (crm): **green**.
- Manual guards: zero `AppColors.*`/raw widths/breakpoints in new code;
  zero new app-local duplicates (`CrmAppBar` still zero-referenced);
  no rail-less desktop, no stretched-phone compositions; no
  drag-and-drop half-states; deprecation guard unaffected.

**Gate 2 — Visual (headless):**

- 15 NEW PNGs in `reports/PHASE_19/screens/` (test originals in
  `apps/crm_app/test/goldens/`): dashboard/leads/tasks 390 EN/AR,
  table 1280, kanban/dashboard 834, dashboard 1280, sheets, shell 1280
  + dark spots. Deterministic reruns green; reviewed headless
  in-session (all non-empty, exception-free renders).
- Matrix: 390 EN/AR + 834 EN + 1280 EN + dark + 320/1.3x smoke (one
  audit fix: refresh tucked off compact bars).
- **Live device: NOT PERFORMED** (no device in this session).

**Failures, incidents & owners:**

| Item | State | Owner |
| :--- | :--- | :--- |
| Mid-session external commits (`e26a4958` landing 18 + sweeping 19 WIP; 16 `test/failures/` debris PNGs captured) | Recorded; working tree verified clean, no work lost, debris absent from tree | Reporter (local flow) |
| Probability/snooze/drag/payment/GPS deferrals | Missing fields/endpoints (§3) | Backend / follow-up |
| `crm_pipeline_test.dart` (spec §2) | Did not exist; created here | Spec erratum, noted |
| Launcher intents pend in widget tests | Bounded 3s intents (same failure path in prod) | This phase (closed) |

---

## 8. Files changed (Phase 19 scope)

- Rewritten: `crm_dashboard_view.dart`,
  `widgets/crm_dashboard_page.dart`, `widgets/crm_pipeline_widget.dart`,
  `widgets/crm_leads_page.dart`, `widgets/crm_kanban_view.dart`,
  `widgets/crm_tasks_page.dart`, `widgets/lead_detail_sheet.dart`,
  `widgets/lead_form_sheet.dart`
- Strings-only: `widgets/crm_followups_widget.dart`,
  `widgets/crm_activity_feed_widget.dart`,
  `widgets/crm_recent_leads.dart`
- Created: `support/crm_board_filter.dart`, `support/crm_l10n.dart`
- Kept byte-identical: all providers/entities/datasources/router/sync/
  validation, out-of-scope pages, channel/recent widgets (structure),
  `CrmColors` + frozen `AppColors` usages
- L10n: `app_en.arb`/`app_ar.arb` (+~155 keys), `gen/*` (regen)
- Tests: `test/features/crm/crm_pipeline_test.dart` (new, 9),
  `test/crm_deal_visual_test.dart` (new, 15 goldens in new `test/goldens/`)
- Docs: `reports/REPORT_PHASE_19.md`, `reports/PHASE_19/screens/*` (15),
  README ledger row 19

Staff touches: **none**. Owner touches: **none**. Customer touches:
**none**. Shared touches: **none** (code). Runner artifacts committed:
**none** (no `test/failures/` produced; goldens are the evidence).
