# CRM leads list test migration (list family recomposition)

Branch: `ui/list-crm`. Leads list recomposed presentation-only:
providers, sync, predicates (`filteredLeads`, stage/agent filters, sort),
refresh, routes, Keys and launcher/error-mapping contracts untouched.
Characterization tests were written against the CURRENT list FIRST (8
testWidgets, GREEN before touching UI — two harness-only fixes: compact
viewport for the list branch, documented 1.3x overflow) and migrated
after the rebuild (13 testWidgets, all structural). Counts never down
(8 -> 13).

## Inventory (existing CRM tests before this change)

- `apps/crm_app/test/baseline_capture_test.dart` (tagged `baseline`,
  excluded from suite).
- Old leads-list assertion count: **0**. New characterization count
  before touching UI: **8 testWidgets** in
  `apps/crm_app/test/crm_leads_list_characterization_test.dart`
  (all structural, GREEN). Counts did not go down (0 -> 8).
- After recomposition: **13 testWidgets** in the same file (all
  structural). Before-captures (7 PNGs) in
  `docs/ui-redesign/baseline/before-crm-lists/` were generated with
  `--update-goldens` and compared back-to-back GREEN before the rebuild
  (idle-2, idle-6, empty-sync, empty-nocrm, dark, ar, 320px).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| header + find-aids | `AppSearchField` inline + `IconButton.filledTonal` kanban toggle + `FilledButton.tonalIcon` Add; `2 Leads` pill | `AppPageHeader` (title `navLeads` + `leadsCountN` subtitle) + kanban toggle `AppIconButton` (same tooltips) + `TextButton.icon` Add; NO inline search; NO search/filter icons at ≤ 5 (sanctioned U1 exception); `RefreshIndicator` kept | structural |
| records | `AppRecordRow` x2 (title name/number, subtitle contact, `StatusPill` + LTR value); tap opens dossier | `AppSurfaceCard(outlined: false)` x2 (same identity/contact/value); sentence-case `AppStatusChip` x2 (`Active`, no ALL-CAPS); Call direct x2; `more_vert` menu x2; tap opens dossier | structural |
| Call intent | (did not exist on card — sheet only) | Call tap → same `tel:` intent; in tests the missing dialer surfaces the sheet's own `dtCallFail` notice | structural |
| card menu | (did not exist) | menu holds `WhatsApp` + `Edit lead` + `Delete`; existing destinations only | structural |
| menu Delete | (did not exist on card — sheet dialog) | `AppDialog` destructive (`dtDeleteTitle` + `dtDeleteBody(name, number)`, `onPrimary` pops true) → same `deleteLead` + `dtDeleted` snackbar; card removed; empty state follows | structural |
| six leads | 6 records, no search icon | 6 records + search + filter icons together; `6 leads` (ICU) | structural |
| search sheet | (did not exist) | sheet with `AppSearchField` (`leadsSearch` hint); substring filter over rendered leads; result reveal; no-match (`leadsSearchNoMatch`) + `Clear` | structural |
| filter sheet | source+agent `AppFilterBar`s + tonal Add inline | sheet with Source/Agent `AppChip` groups + `Show results` + `Clear`; in-place filter; filtered count (`3 leads · Filter leads`); no-match (`leadsFilterNoMatch`) + Clear restores six | structural |
| filtered-to-zero | showed connect/sync empties (wrong states) | real no-match (`AppEmptyState` + Clear) | structural |
| empty-sync / no-crm | bespoke link-off/people panels + `ElevatedButton.icon` | `AppEmptyState` (1 icon + 1 sentence + 1 action → same connect/sync handlers) + verbatim captions kept | structural |
| loading | (no skeleton — immediate empty) | `AppShimmerSkeleton` (header lines + `card(148)`) when `ui.isLoading && empty` | structural |
| kanban toggle | `AppRecordRow` absence asserted (wrong — kanban uses it too) | `CrmKanbanView` present + tooltip flip | structural |
| dark + 1.3x + 320px | overflowed ~22px at 1.3x (documented, strict off) | pumps clean strict (overflow fixed) | structural |

## Behavior kept verbatim (presentation only — no logic changes)

- Providers/sync/refresh: `crmLeadProvider` (`filteredLeads`, `refresh`,
  `create/update/deleteLead`), `crmUiProvider` (`integrations`,
  `isLoading`), `crmLeadSourceFilterProvider`,
  `crmLeadStageFilterProvider`, `_agentFilter`/`_sortIndex` local state,
  `crmLeadStatusMap` payload — byte-identical call sites.
- Predicates: `filteredLeads` (source + search-query), local stage/agent
  filters + name/value sort (one derivation per build, unchanged).
- Routes (existing destinations only, no new routes):
  `LeadDetailSheet.show` (record tap, dossier, kanban reveal),
  `LeadFormSheet.show` (header Add, menu Edit),
  `ConnectIntegrationSheet.show` (no-CRM CTA).
- Handlers: `refresh()` (pull-to-refresh, source-apply, sync CTA),
  `callLeadPhone`/`whatsAppLeadPhone` (byte-identical URIs, 3s bound,
  same `dtCallFail`/`dtWaFail` notices as the sheet), delete flow
  (same `deleteLead` + `dtDeleted` snackbar; NO undo — undo would be
  logic).
- Countdown/copy: `leadsCount`/`filterAll`/`filterSource`/`filterAgent`
  and all `dt*`/`kb*`/`fm*` keys reused verbatim. No invented leads.

## Deviations / notes (presentation-only, filed here)

- Inline search + shell palette: COLLAPSED to header-icon-only per the
  single-affordance rule (brief §Single-affordance audit). The palette
  (shell-owned, jump-to-dossier) keeps working unchanged; the list
  search is the sheet over rendered leads.
- `AppListGroup` is settings-rows only and cannot host rich record cards;
  records are `AppSurfaceCard(outlined: false)` rows with 12px gaps —
  the same shared-atom family, borderless in light (shadow) / bordered
  in dark. No dividers (whitespace separation, C16).
- `leadsCount` (`{count} Leads`, "1 Leads" bug) is NOT fixed in place —
  the new ICU key `leadsCountN` (`=0/=1/other`, en+ar, same shape as the
  vehicles `vhCount` round-1 fix) carries the header; the old keys stay
  untouched (no renames).
- Stage codes render sentence-case on chips (`ACTIVE` → `Active`,
  `NO_RESPONSE` → `No Response`); matching stays uppercase. Same display
  class as the vehicles `.toUpperCase()` removal (C16 no-ALL-CAPS).
- Chip kinds by status name (WON→success, LOST→error,
  UNANSWERED/NO_RESPONSE→warning, else accent); the entity `statusColor`
  is data, not mapped (mapping raw colors would be guessing).
- `showAppDialog` pops null by default — the delete confirm passes an
  explicit `onPrimary` popping `true` (found by the failing test, fixed
  in production, not the test).
- Test fakes copy-on-read (`List.of`): the notifier keeps the returned
  list as state, so a mutated same-instance list compares equal and
  never notifies. Copies mimic the production adapter.
- Kanban (`crm_kanban_view.dart`) kept fully verbatim — its legacy
  atoms (`AppRecordRow`, `StatusPill`, ALL-CAPS stages) remain, filed
  as the next slice, not silently fixed.
- No error branch: no error signal exists in the lead providers
  (`refresh()` failures are swallowed in `ui.refresh`) — filed as a
  logic candidate in the session return (LOGIC_FOLLOWUPS.md is
  owner-edited, not touched here).

## Tap table (AFTER ≤ BEFORE — no regression; EXACT counts)

| Task | Before (EXACT) | After (EXACT) |
|---|---|---|
| Open list | 1 tap (tab/`selectTab(1)`) | ≤ 1 tap (unchanged) |
| Find + open lead | 2 taps + type (inline filter + record) or 2 taps (palette + dossier) | ≤ 2 taps (header icon + result reveal + record tap; palette unchanged) |
| Add lead (reach form) | 2 taps (tab + tonal Add) | ≤ 2 taps (header/empty-state Add, same sheet) |
| Call lead | 3 taps + scroll (tab + record + sheet Call) | ≤ 1 from list, ≤ 2 from launch (Call direct on card) |
| Move stage | 3 taps (record + sheet quick-select) | ≤ 3 taps (card tap → same quick-select; kanban kept) |
| Retry sync / connect | 1 tap inline | ≤ 1 tap inline (same handlers) |

## Round-1 fixer notes (presentation only — no logic changes)

- U5 tablet Stage chip (`*_768x1024.png`, `A/ct/iv/e`): `crm_leads_page.dart`
  `_buildTable` gives the Stage column one extra flex share (2 -> 3, Agent
  stays 2) and passes matching `cellFlex` so rows stop defaulting to 1
  per cell; the Stage cell wraps the same `AppStatusChip` in a scale-down
  `FittedBox` so a longer label shrinks whole instead of wrapping
  mid-word. Compact cards untouched (separate `_buildList` branch).
- Criterion-7 dossier placeholder: `_buildWide` placeholder no longer
  reuses the search hint (`leadsSearch`); new single sentence-case key
  `leadsSelectLead` ("Select a lead to view details" /
  "اختر عميلاً لعرض التفاصيل"), en+ar, `flutter gen-l10n` from
  `apps/crm_app`. Same handlers/predicates/routes.

## New ARB keys (en+ar, `flutter gen-l10n` from `apps/crm_app`)

`leadsSearchTitle`, `leadsSearchNoMatch`, `leadsFilterTitle`,
`leadsFilterShow`, `leadsFilterNoMatch`, `leadsFilterClear`, `leadsCountN`
(ICU `=0/=1/other`, header only — old `leadsCount` kept). Reused verbatim:
`navLeads`, `leadsSearch` (sheet hint), `filterAll/Source/Agent`,
`dtCall/dtWhatsApp/dtEdit/dtDelete/dtDeleteTitle/dtDeleteBody/dtCancel/
dtDeleted/dtCallFail/dtWaFail`, `leadsAdd/leadsEmpty/leadsNoCrm(leads*`,
`col*`. No ALL CAPS strings added.
