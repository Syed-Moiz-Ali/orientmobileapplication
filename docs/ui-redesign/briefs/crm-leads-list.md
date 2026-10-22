# UX Brief — CRM leads list (list family)

## Scope
`apps/crm_app` leads list surface: `widgets/crm_leads_page.dart`
(list + header + filter toolbar + empty states) + `widgets/crm_kanban_view.dart`
(stage swimlanes + quick-select, kept) + `widgets/lead_detail_sheet.dart`
(dossier destination, routes unchanged) + `widgets/lead_form_sheet.dart`
(add/edit destination, unchanged) + `support/crm_board_filter.dart`
(`crmLeadStageFilterProvider` + `crmLeadStatusMap`, unchanged) +
`providers/crm_lead_provider.dart` (`filteredLeads`, unchanged) +
`providers/crm_ui_provider.dart` (`updateSearch`/`integrations`, unchanged).
Routes touched only as existing destinations: `LeadDetailSheet.show`,
`LeadFormSheet.show`, `ConnectIntegrationSheet.show`. No new routes. No
logic changes (providers, filters, sort, refresh stay as-is).

## User goal
A salesperson opens Leads and in one glance finds the right lead (name +
phone), sees what stage it is in, and reaches Call / WhatsApp / stage-move
without hunting. One screen, one primary task: find lead → act.

## Current behavior (verified from code)
- Entry: `CrmDashboardView` `IndexedStack` index 1 (`navLeads`); badge =
  lead count when > 0. Shell: `DashboardShell` + `_CrmChrome`
  (`WorkspaceAppBar`: title = `navLeads`, subtitle, search trigger
  `onSearch` → `_openSearch` command palette over first 50 leads,
  offline pill, bell + avatar; compact hides refresh to stay in 320px).
- Header row (leads page): `AppSearchField` (`leadsSearch`, `onChanged`
  `ui.updateSearch` → `filteredLeads` query over name/number/source/phone/
  email) + `IconButton.filledTonal` kanban/table toggle
  (`leadsTableView`/`leadsKanbanView` tooltips).
- Filter toolbar (`_filterToolbar`): source `AppFilterBar` (All + distinct
  sources, `leadNotifier.refresh()` on select) + `FilledButton.tonalIcon`
  `leadsAdd` → `LeadFormSheet.show`; agent `AppFilterBar` (All + distinct
  assignees, local `_agentFilter` state); count `StatusPill`
  (`leadsCount(n)`) + dismissible stage pill (`× stage` → clears
  `crmLeadStageFilterProvider`).
- List (compact or `!_kanbanMode`): `ListView.separated` of `AppRecordRow`
  (title = name or leadNumber, subtitle = phone or email, metadata =
  `StatusPill` status + LTR `AED value`); tap → `LeadDetailSheet.show`.
- Table (medium+ with `_kanbanMode` off): `AppTable` (Lead/Phone/Value/
  Stage/Agent, sort name/value, row tap selects `_selectedLeadId`) +
  `_buildDossier` side panel (same record, call/WhatsApp/edit entry into
  the full sheet). Kanban (`_kanbanMode`): `CrmKanbanView` swimlanes.
- States: `RefreshIndicator` pull-to-refresh; empty = two bespoke panels
  (no-CRM-connected vs empty-sync, `ElevatedButton.icon` CTA); no
  skeleton, no `AppErrorState`, no offline banner on this surface (shell
  owns offline pill, banner off).
- Sorting: local `_sortIndex/_sortAscending` (name/value) over frozen
  `filteredLeads`; agent filter local `_agentFilter`; stage filter shared
  provider applied locally. Stage moves reuse `crmLeadStatusMap` via the
  existing `updateLead` endpoint.

## Top tasks with tap counts (BEFORE = current UI, AFTER must be ≤)
1. Open the leads list — before: nav Leads tab = **1 tap**
   (deep-link via `selectTab(1)` from palette). After: ≤ 1 tap.
2. Find + open a lead dossier — before: tab (1) + inline search type +
   record tap (1) = **2 taps** (+ typing/scroll); OR palette (Ctrl+K/search
   icon, 1) + pick (1) = 2 taps to dossier. After: header search icon (1)
   + result tap (1) = **≤ 2 taps**; list scroll-to-record ≤ 1 tap from
   list. No regression.
3. Add a lead — before: tab (1) + `Add Lead` tonal (1) = **2 taps**, then
   existing form sheet (unchanged). After: ≤ 2 taps (header Add when
   non-empty, empty-state CTA when empty — never both at once).
4. Call / WhatsApp a lead — before: tab (1) + record tap (1) + sheet
   Call/WhatsApp (1) = **3 taps** (+ scroll). After: frequent action
   DIRECTLY on each card (Call primary): **≤ 1 tap from list, ≤ 2 from
   launch**. WhatsApp + Edit/Detail in card overflow (existing sheet
   route, no new destination).
5. Move a lead stage — before: tab (1) + record tap (1) + sheet
   quick-select (1) = **3 taps**. After: ≤ 3 taps (card pill → same sheet
   quick-select; kanban quick-select kept verbatim).
6. Retry sync / connect CRM when empty — before: inline Sync/Connect (1).
   After: ≤ 1 tap, control stays inline in the empty state.

| Task | Before | After budget |
|---|---|---|
| Open list | 1 tap | ≤ 1 tap |
| Find + open lead | 2 taps (+type/scroll) | ≤ 2 taps, ≤ 1 from list |
| Add lead (reach form) | 2 taps | ≤ 2 taps (header / empty-state only) |
| Call lead | 3 taps (+scroll) | ≤ 1 tap from list, ≤ 2 from launch (Call direct on card) |
| Move stage | 3 taps | ≤ 3 taps (same sheet/kanban payload) |
| Retry sync / connect | 1 tap inline | ≤ 1 tap inline |

Frequent tasks (find lead, call lead) stay single-screen; add/edit is the
only sheet flow and is out of scope for restructuring.

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: **does not exist** (confirmed — no
  `references` dir under `docs/ui-redesign/`).
- `AIRBNB_PATTERNS.md`: **missing anywhere in the repo** (repo-wide glob
  returns nothing; only mention is
  `docs/ui-redesign/evaluation/technician-home-test-migration.md:183`,
  which itself records the file/dir does not exist).
- Mapping is therefore **unmet**; this brief proceeds from phase-5/6/7
  precedent patterns (supervisor-floor, technician-today, owner-home,
  vehicles-list briefs): `AppPageHeader` + header search icon (U1) opening
  a full-screen search sheet over loaded list items with no new
  routes/logic; `AppChip` filter sheet keeping existing predicates;
  `AppBanner` for blockers; borderless light cards; no ALL CAPS added;
  zero shown as `0`.

## Single-affordance audit (inline + header search)
Current page pairs an inline `AppSearchField` (filters `filteredLeads` in
place via `ui.updateSearch`) with the shell header search (palette over
first 50 leads → `selectTab(1)` + `LeadDetailSheet.show`). Targets DIFFER
today (filter-list vs jump-to-dossier) but the TASK is one ("find a
lead") — two entry points for one task violates C16 one-path-per-task and
C16 search (never an inline field pushing content). **Decision:
COLLAPSE to header-icon-only** per the single-affordance rule. The inline
field is removed; the header icon opens a list-scoped search sheet over
the loaded leads (name/number/phone/email substring); result tap reveals
the record; record tap still opens the existing dossier (jump-to-dossier
preserved as the second tap, no destination lost). The palette keeps
working unchanged (shell-owned, cross-surface); it is not the list
search. Written justification recorded here, not a silent collapse.

## U-laws application (U0–U14, C17)
- U0 (one read): one record = identity (name → phone) → ONE status pill →
  meta (value LTR). No competing heroes. CARD HIERARCHY (binding): title
  = customer name (the thing the user recognizes, fallback leadNumber);
  status = ONE `AppStatusChip` sentence-case (existing `status` verbatim,
  never invented); value = small LTR meta (`AED n`, tabular); source/agent
  = secondary meta. Borderless in light (soft shadow or flat, whitespace
  separation; C16).
- U1 (find fast): header search icon top-right (same placement as staff
  briefs) opens the list-scoped search sheet (client-side filter of loaded
  leads; no new routes/logic). PROGRESSIVE-DISCLOSURE EXCEPTION (the ONE
  sanctioned U1 exception — see "Search-icon pattern"): the search icon
  appears ONLY when the loaded list has MORE THAN 5 items; ≤ 5 shows
  cards only. Same threshold as the vehicles list.
- U2 (fit the content): lead records are heterogeneous (identity + status
  + value + actions) — cards, NOT a data table on compact. Table duality
  kept on medium+ (existing `AppTable` + dossier, restyled on shared
  atoms). FOLD (binding): at 360x800 the FIRST card sits above the fold
  (above the bottom nav, idle with data) with the SECOND card peeking;
  anything pushing it below the fold needs a written reason.
- U3 (no fake actions): only real states — Call/WhatsApp only when the
  record has a dialable target (existing sheet handlers); stage pill only
  from the existing `status`; no invented health/priority pills.
- U4 (no invention): names/phones/values verbatim via existing entities;
  zero value shown as `0`, never `-`; counts from `leads.length` only.
- U5 (reachable + legible): 48dp targets on all actions; Call direct +
  overflow menu (never clipped) at 320px / 1.3x; phone/value LTR-locked.
- U6 (states): skeleton mirrors the cards (`AppShimmerSkeleton` mirroring
  card layout: title + meta + action row); honest empty
  (`AppEmptyState`: EXACTLY one icon + one sentence + one action →
  same form/connect/refresh handler); error (`AppErrorState` + Try again,
  same retry); stale data kept with `AppBanner`; pull-to-refresh kept.
- U7 (feedback): Call/WhatsApp keep existing launcher + snackbar
  contracts; delete keeps destructive confirm (AppDialog, existing
  `deleteLead` + snackbar; NO undo — undo would be logic, out of scope);
  busy states disable only the acting record's controls.
- U8 (no dead ends): every card with a contact offers Call; stage pill is
  badge-only (tap opens the dossier quick-select — real destination);
  empty always offers the honest next step (Connect vs Sync vs Add).
- U9 (consistency): `AppPageHeader` + search/filter icons + `AppBanner` —
  same atoms as staff/customer/owner lists.
- U10 (RTL): full mirror; phone/value/leadNumber LTR-locked.
- U11 (a11y): record `Semantics` label (name + phone + status) kept;
  header `Semantics(header: true)`; 48dp targets; AA pairs.
- U12 (density): 1-col compact; table + dossier on medium+ (existing
  breakpoint kept, rebuilt on shared atoms).
- U13 (offline): shell pill owns offline state (banner off per shell
  contract); stale list kept + inline retry; no new banner unless the
  feed errors on this surface.
- U14 (no regression): tap budgets above are ceilings; pull-to-refresh,
  keys, confirmation + snackbar contracts unchanged in behavior
  (presentation may move dialog → AppDialog styling, same handler).
- C17: any U-law fail caps at 8/16. C16 list adaptations: search-sheet,
  borderless light cards, no ALL CAPS added (kanban `OVERDUE` etc.
  sentence-cased via theme), zero as `0`.

## Search-icon pattern (list-scoped, no new routes/logic)
- `AppPageHeader` (title `navLeads` + count subtitle) with search icon
  top-right (U1) — SHOWN ONLY WHEN the loaded `leads` list has MORE THAN
  5 items. With ≤ 5 items: cards only, NO search icon.
- Icon opens a full-screen search sheet over the list items: text field
  filters the loaded `filteredLeads` by name / leadNumber / phone / email
  substring; results render as compact rows (tapping closes the sheet and
  reveals the record; record actions unchanged).
- Empty query = full list; no-match = filter-no-match state with Clear.
- No new routes, no server queries, no invented entries. Sheet respects
  RTL + 1.3x (field + list scroll, no clipping).

## Filter sheet design (predicates owned by existing logic)
- Filter entry: funnel icon beside search (header, shown together with
  search when the > 5-item threshold is met) — opens bottom sheet with
  the only honest facets the feed supports: source (All + distinct
  sources, existing `crmLeadSourceFilterProvider`) + agent (All +
  distinct assignees, existing `_agentFilter` state lifted verbatim).
- Sheet: single-select chip groups + Show results CTA + Clear; selection
  filters the rendered list in place; count subtitle updates verbatim;
  no-match + Clear.
- Logic boundary: source/stage derivation stays in
  `crmLeadProvider.filteredLeads` + `crmLeadStageFilterProvider` —
  unchanged.

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: inline `AppSearchField` + `IconButton.filledTonal` toggle row
  → `AppPageHeader` (title + count subtitle) + search icon top-right ONLY
  when > 5 items + filter icon beside search + kanban/table toggle kept
  as a header icon (same `_kanbanMode` state, same tooltips). Add stays a
  header action when non-empty (same `LeadFormSheet.show`) and the
  empty-state CTA when empty.
- REMOVED: bespoke `_filterToolbar` chrome → filter bottom sheet (same
  source/agent predicates, same `refresh()` call sites); count pill →
  header subtitle (`leadsCount`, ICU — zero as `0`); stage pill → sheet
  pre-select + subtitle note (same clear handler).
- REMOVED: bespoke `AppRecordRow` + `StatusPill` styling → shared atoms
  (borderless `AppSurfaceCard(outlined: false)` rows, `AppStatusChip`
  sentence-case, LTR value meta, Call direct + overflow menu). Card
  hierarchy binding: title = name, status = ONE pill, value = meta.
  FREQUENT ACTION binding: Call sits DIRECTLY on each card.
- REMOVED: bespoke empty panels (link-off/people circles +
  `ElevatedButton.icon`) → `AppEmptyState` (1 icon + 1 sentence + 1
  action → same connect/sync/add handlers) + the integrations/auto
  notes kept verbatim as captions under the action (same copy, no new
  destination). New: filtered-to-zero is a real no-match state
  (`AppEmptyState` + Clear — the old tree showed the connect/sync
  empties there).
- MOVED: kanban swimlanes kept verbatim (same component, same atoms;
  legacy atoms inside `crm_kanban_view.dart` remain — filed as remaining
  in the migration doc, not silently fixed);
  table + dossier kept on medium+ (same columns/sort/selection, dossier
  restyled on shared atoms); detail/form/connect sheets unchanged
  (destinations).
- KEPT: all providers/sync/refresh/sort/filter predicates, `filteredLeads`
  derivation, `crmLeadStatusMap` payload, `selectTab`, routes, keys,
  launcher + snackbar contracts. No new routes. No invented leads.
  CRM app keeps its current theme wiring (no dark-scope change).

## Fold wireframe (ASCII, 360×800 — header + first card above fold)
```
+----------------------------------+
| Leads              [🔍][⧩][⇄][+]|  <- 🔍+⧩ only when > 5 items; ≤ 5: [⇄][+] only
| 7 leads                        |
|----------------------------------|
| Ahmed Khan        [Active]       |  <- title = name; ONE status pill
| +971 50 123 4567 · AED 12,000   |  <- phone + LTR value meta
| [Call]            [··· menu]     |  <- Call direct; WA/Edit in menu
|----------------------------------| <- above fold (nav below)
| Sara Ahmed        [New]          |  <- second card PEEKING
+----------------------------------+
|Dashboard|Leads|Chats|Team|Tasks|... |  <- rail/drawer on expanded
```

## Matrix requirements
- empty (no-CRM-connected: `AppEmptyState` + Connect → same sheet; never
  zero-filled) · empty-sync (connected, no leads: `AppEmptyState` + Sync
  → same `refresh`) · with-data (records + Call direct + menu) ·
- search (icon shown ONLY when > 5 items → sheet over loaded leads;
  ≤ 5 = cards only; result reveals record; no-match + Clear; no new
  routes) · filter (source/agent sheet; count updates; no-match + Clear) ·
- kanban toggle + table/dossier on medium+ · ar (RTL mirrored;
  phone/value/numbers LTR-locked) · 1.3x (actions wrap, no clip) · 320px
  (header + first record intact) · tablet (2-col/tablet layout, rail).

## Copy keys needed
Reuse existing `leads*`, `col*`, `filter*`, `kb*`, `dt*`, `fm*` keys;
new keys only for search-sheet hint/no-match + filter-sheet labels +
filter-no-match (en+ar, listed for phase 9). No ALL CAPS strings added.

## Acceptance
- U0–U14 walk (ANY U-law fail caps at 8/16 — the > 5-item search-icon
  threshold is the ONE sanctioned U1 exception; every other U-law
  applies); C16 hard-reject checklist for lists (caps 10/16):
  header-icon search (progressive disclosure only when > 5),
  one-path-per-task (inline collapsed), borderless light cards, card
  hierarchy (name → ONE pill → LTR meta), no ALL CAPS added, zero as `0`,
  first card above fold + second peeking at 360x800, empty = one icon +
  one sentence + one action, delete = `AppDialog` destructive (no undo),
  no dead affordances, no new routes, taps never regress.
- Airbnb rubric ≥ 12/16 to pass.
- Gates: characterization tests on the CURRENT list first,
  before-images captured, migration table (current → shared atoms),
  reviewer process per redesign mandate, NO logic changes.
