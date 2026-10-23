# CRM leads list test migration (list family recomposition)

Branch: `ui/list-crm`. Leads list recomposed presentation-only:
providers, sync, predicates (`filteredLeads`, stage/agent filters, sort),
refresh, routes, Keys and launcher/error-mapping contracts untouched.
Characterization tests were written against the CURRENT list FIRST (8
testWidgets, GREEN before touching UI — two harness-only fixes: compact
viewport for the list branch, documented 1.3x overflow) and migrated
after the rebuild (13 testWidgets, all structural). Counts never down
(8 -> 13). Round-2 adversarial fixes (8 items from
`adversarial-crm-leads-review.md`) migrated the same file to **14
testWidgets**, all structural. WAVE-2 fixes (F6 header, F9 shell guard)
migrated the same file to **15 testWidgets**, all structural. Counts
never down (8 -> 13 -> 14 -> 15). Ruling (a) shell relocation keeps the
same file at **15 testWidgets** (assertions updated verbatim below, none
added/removed) + **8 new shell relocation tests** in
`apps/crm_app/test/crm_shell_search_relocation_test.dart` (all
structural). Counts never down (8 -> 13 -> 14 -> 15 -> 15 + 8 shell).

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
- After round-2 adversarial fixes: **14 testWidgets** in the same file
  (all structural; +1 loading-skeleton test, records/empty assertions
  updated verbatim below). After-captures (11 PNGs, +1 loading frame) in
  `docs/ui-redesign/baseline/after-crm-leads/` regenerated with
  `--update-goldens` and compared back-to-back GREEN after the fixes.
- After WAVE-2 fixes (F6/F9): **15 testWidgets** in the same file (all
  structural; +1 same-row header test). After-captures (same 11 PNGs, no
  new frames) regenerated with `--update-goldens` and compared
  back-to-back GREEN after the fixes.

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| header + find-aids | `AppSearchField` inline + `IconButton.filledTonal` kanban toggle + `FilledButton.tonalIcon` Add; `2 Leads` pill | `AppPageHeader` (title `navLeads` + `leadsCountN` subtitle) + kanban toggle `AppIconButton` (same tooltips) + `TextButton.icon` Add; NO inline search; NO search/filter icons at ≤ 5 (sanctioned U1 exception); `RefreshIndicator` kept | structural |
| records | `AppRecordRow` x2 (title name/number, subtitle contact, `StatusPill` + LTR value); tap opens dossier | `AppSurfaceCard(outlined: false)` x2 (same identity/contact/value); sentence-case `AppStatusChip` x2 (`Active`, no ALL-CAPS); Call direct x2; `more_vert` menu x2; tap opens dossier | structural |
| records (round-2) | card title `LD-1000` (ID promoted to title weight); bare `AED 12000` value; phone + value only | customer-name-first title (`_leadTitle`: name → phone → email → number); value line `Value · AED 12,000 · LD-1001` (existing `AppFormatters.moneyAED`, tabular, ID trailing meta); why-line `Meta · Sara · Called` (existing source/agent/lastActivity only); contact line hidden when it duplicates the title | structural |
| Call intent | (did not exist on card — sheet only) | Call tap → same `tel:` intent; in tests the missing dialer surfaces the sheet's own `dtCallFail` notice | structural |
| card menu | (did not exist) | menu holds `WhatsApp` + `Edit lead` + `Delete`; existing destinations only | structural |
| menu Delete | (did not exist on card — sheet dialog) | `AppDialog` destructive (`dtDeleteTitle` + `dtDeleteBody(name, number)`, `onPrimary` pops true) → same `deleteLead` + `dtDeleted` snackbar; card removed; empty state follows | structural |
| six leads | 6 records, no search icon | 6 records + search + filter icons together; `6 leads` (ICU) | structural |
| search sheet | (did not exist) | sheet with `AppSearchField` (`leadsSearch` hint); substring filter over rendered leads; result reveal; no-match (`leadsSearchNoMatch`) + `Clear` | structural |
| filter sheet | source+agent `AppFilterBar`s + tonal Add inline | sheet with Source/Agent `AppChip` groups + `Show results` + `Clear`; in-place filter; filtered count (`3 leads · Filter leads`); no-match (`leadsFilterNoMatch`) + Clear restores six | structural |
| filtered-to-zero | showed connect/sync empties (wrong states) | real no-match (`AppEmptyState` + Clear) | structural |
| empty-sync / no-crm | bespoke link-off/people panels + `ElevatedButton.icon` | `AppEmptyState` (1 icon + 1 sentence + 1 action → same connect/sync handlers) + verbatim captions kept | structural |
| empty-sync / no-crm (round-2) | `AppEmptyState` + verbatim caption, zero Add paths (header Add renders only when non-empty) | unchanged primary + caption, plus secondary `TextButton.icon` Add (`leadsAdd` → same `LeadFormSheet.show`) below the caption; header-XOR-empty holds (header Add only when `totalLoaded > 0`) | structural |
| loading | (no skeleton — immediate empty) | `AppShimmerSkeleton` (header lines + `card(148)`) when `ui.isLoading && empty` | structural |
| loading (round-2) | skeleton branch existed but had no structural test and no golden | new `loading with empty list shows skeleton cards` test (real notifier subclass latching existing `isLoading`; `AppShimmerSkeleton` findsWidgets, no cards/empties) + new `leads_loading_light_1.0_en_360x800.png` golden | structural |
| header same-row (WAVE-2 F6) | `AppPageHeader` stacked all actions below the title on compact (read as a body toolbar row) | plain responsive Row: compact row 1 = title + search/filter same-row, row 2 = end-aligned kanban + Add; wide (≥ 600) single row; RTL-mirrored; same tooltips/sheets/targets | structural |
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

## Round-2 adversarial fixer notes (presentation only — no logic changes)

Law wins over prior sanctions: where the brief's fallback (`title =
customer name, fallback leadNumber`) conflicts with C16 (IDs are small
meta, never titles), C16 governs — deviation recorded under item 1.

1. ID-as-title → customer-name-first hierarchy. FIXED.
   `crm_leads_page.dart` `_leadTitle` (top-level, ~line 60): name → phone
   → email → leadNumber last resort; card title, table Lead cell, dossier
   title and search-sheet rows (private `_titleOf` copy in
   `crm_leads_search_sheet.dart` — local on purpose, importing the page
   would cycle; same precedent as the dossier's private contact-intent
   copy) all use it. The ID renders as small trailing meta on the value
   line (`Value · AED 12,000 · LD-1001`), never the title. Contact line is
   hidden when it would duplicate the title. Evidence:
   `leads_idle-6_light_1.0_en_360x800.png` (phone title on the nameless
   card, `Customer 1..5` elsewhere, zero ID titles). Deviation: nameless
   tablet rows show the contact as identity in both Lead and Phone columns
   (same record, full dossier one tap away) rather than promoting the ID.
2. Tablet truncations → whole primary text at 768. FIXED.
   `crm_leads_page.dart` `_buildTable`: flexes rebalanced to
   `[4, 3, 3, 3, 2]` with matching `cellFlex`, and Lead/Phone/Value/Agent
   cells wrap in scale-down `FittedBox` (`softWrap: false` + visible
   overflow so the Text sizes to its intrinsic single-line width and the
   box scales the whole string) exactly like the round-1 Stage fix; plus
   `masterMinWidth: 380` on the caller-local `AppMasterDetailScaffold`
   (same class of caller param as the advisor list's `masterMaxWidth` —
   no shared-atom change; wider screens still clamp to 420). Evidence:
   `leads_idle-6_light_1.0_en_768x1024.png` — all headers (`Lead Phone
   Value Stage Agent`) and all cells (`Customer 1..5`, full phones,
   `AED 12,000..17,000`, whole `Active` chips, `Sara/John`) with zero
   ellipsis. Trade-off recorded: phone/value render scaled-down whole in
   the narrow master; the full record is one row-tap away in the dossier.
3. Zero Add path on empties → secondary Add on both empties. FIXED +
   VERIFIED. Header Add exists only when non-empty (`totalLoaded > 0`,
   `crm_leads_page.dart` header block) — header-XOR-empty verified in
   code — so both empty branches gained a secondary `TextButton.icon`
   Add (`leadsAdd` → same `LeadFormSheet.show`) below the verbatim
   caption; the `AppEmptyState` single primary action (Connect/Sync) is
   untouched. Evidence: recaptured `leads_empty-sync_...` /
   `leads_empty-nocrm_...` PNGs show `+ Add Lead` under the caption.
   Tap: empty Add → form = 1 tap (budget ≤ 2, no regression).
4. Search placement + alleged duplicate find-path. VERIFIED + DOCUMENTED,
   no widget change (rebuttal with evidence). Placement: the icon lives in
   `AppPageHeader.actions` (`crm_leads_page.dart` header block) — the
   shared atom, same as sibling lists (U9). On medium+ it is top-right
   same-row (see tablet golden header); on compact the atom stacks actions
   below the title (`app_page_header.dart:113-123`, `Align(centerLeft)`),
   which the review read as a body toolbar row. Restructuring only this
   screen would break U9/C8 shared atoms, so the atom is kept — law (U9 +
   C8) over the fold-wireframe sketch. Duplication: the shell palette
   (`crm_dashboard_view.dart:167-194`, first-50 jump-to-dossier,
   app-chrome scope) and the list sheet (`crm_leads_search_sheet.dart:
   47-56`, in-place filter of loaded leads, list scope) have different
   targets — not same-target duplicates — so they are NOT collapsed;
   scope note added in code above `showFindAids`. Single task-path: find
   + open dossier from the list = header icon → sheet → result reveal →
   record tap (≤ 2 taps); the palette is global jump chrome, unchanged.
5. Ungrouped/unlabeled numbers → grouped tabular labeled figures. FIXED
   via the EXISTING helper (display mapping only). `AppFormatters.moneyAED`
   (`packages/shared_core/lib/src/localization/app_formatters.dart:87-89`,
   already used by `app_trend_stat`/`app_date_range_field`, exported from
   the `shared_core` barrel) renders `AED 12,000` (en) / `12,000 د.إ`
   (ar, Latin digits per the frozen V5 policy) with
   `FontFeature.tabularFigures()`. Cards: `Value · <money> · <ID>`
   (`colValue` reused verbatim — no new copy); table Value cells: grouped
   money (header `Value` is the label); dossier second line: grouped money
   + ID. Search rows: value deliberately NOT a third column — documented
   in code (`crm_leads_search_sheet.dart` row builder): at 320px it would
   reintroduce the U5 truncation item 2 removes; the value surfaces on the
   revealed card within the same ≤ 2-tap path. Evidence: idle-6, tablet,
   ar (`12,000 د.إ`), 320px and 1.3x goldens.
6. Content-free `Active` pill → why-line from existing fields. FIXED
   (fields only, never invented). `_leadContextLine` (`crm_leads_page.dart`,
   top-level): `[source, assignedTo, lastActivity]` verbatim, empties
   dropped, `·`-joined (same display-join precedent as the subtitle and
   dossier lines), rendered as secondary meta under the value line.
   Evidence: `Meta · Sara · Called` / `Zoho · John · Called` on every
   card in the recaptured goldens.
7. Skeleton/error/offline proof. PARTIAL + STOPS. Loading: the
   `isLoading && empty` skeleton branch already existed
   (`crm_leads_page.dart` `_body`); it now has a structural test (new
   14th testWidget, `_LoadingUiNotifier` latching the EXISTING signal)
   and a new golden `leads_loading_light_1.0_en_360x800.png` (header lines
   + card shapes mirroring the cards). Error/offline: STOP — no signal
   exists in code (LOGIC_FOLLOWUPS #11: refresh failures swallowed in
   `ui.refresh`; #10 family). No `AppErrorState`/`AppBanner` was invented;
   presentation adds error+retry only when state owners surface a signal.
8. `Active` English in ar. KEEP-VERBATIM + NOTE (LOGIC #9 family). No ARB
   key exists for lead stage codes (grep: only `rpActive`, a reports-chart
   legend in a different scope; `dtMarked` passes the raw code through).
   `_displayStatus` output stays verbatim in both locales — translating
   backend codes in presentation would invent copy, same family as
   LOGIC_FOLLOWUPS #9 (server/entity labels). Evidence: ar golden mirrors
   correctly (`العملاء المحتملون`, `أضف عميلاً`, `اتصال`, grouped
   `12,000 د.إ`) with `Active`/`LD-100*`/`Meta`/`Sara` verbatim Latin.
   Proposed owner: backend/product — locale-aware stage labels or
   confirmation that English codes are acceptable.

Legacy harness note: `crm_lists_after_capture_test.dart` (writes the older
`after-crm-lists/` dir) also pumps `CrmLeadsPage`, so its 8 leads goldens
went red against the new pixels (tasks 6/6 stayed green — untouched).
They were refreshed with `--update-goldens` and compared back-to-back
GREEN (14/14); the failure-feedback debris under
`apps/crm_app/test/failures/` was deleted. `before-crm-lists/` historical
goldens were not touched.

WAVE-2 legacy refresh: the same legacy file's 8 leads + 6 tasks goldens
went red against the WAVE-2 pixels (plain-Row headers) and were refreshed
with `--update-goldens` and compared back-to-back GREEN (14/14). No
`test/failures/` debris remained (none generated — verified absent).

## New ARB keys (en+ar, `flutter gen-l10n` from `apps/crm_app`)

`leadsSearchTitle`, `leadsSearchNoMatch`, `leadsFilterTitle`,
`leadsFilterShow`, `leadsFilterNoMatch`, `leadsFilterClear`, `leadsCountN`
(ICU `=0/=1/other`, header only — old `leadsCount` kept). Reused verbatim:
`navLeads`, `leadsSearch` (sheet hint), `filterAll/Source/Agent`,
`dtCall/dtWhatsApp/dtEdit/dtDelete/dtDeleteTitle/dtDeleteBody/dtCancel/
dtDeleted/dtCallFail/dtWaFail`, `leadsAdd/leadsEmpty/leadsNoCrm(leads*`,
`col*`. No ALL CAPS strings added.

Round-2 ARB delta: **zero new keys** (byte-safe, no `gen-l10n` run
needed). Item 5 reuses `colValue` verbatim as the card value label and
`AppFormatters.moneyAED` for locale placement; item 6 joins verbatim
entity fields (no copy); item 8 adds no stage keys per the LOGIC #9
keep-verbatim rule. EN/AR parity untouched (verified: `app_en.arb` /
`app_ar.arb` unmodified).

WAVE-2 notes (presentation only — no logic changes):

- F6 header (leads): `crm_leads_page.dart` header block no longer uses
  `AppPageHeader`. A `LayoutBuilder` plain Row keeps the title +
  search/filter find-aids top-end same-row on compact; the kanban toggle
  + Add sit in an end-aligned second header row (still header chrome,
  never body — four actions cannot share one 360px row with the title,
  proven by a 24px `RenderFlex` overflow the suite caught before the
  split). Wide (≥ 600) keeps everything in one row, as the tablet golden
  already showed. RTL mirrors (icons top-start in ar). Evidence:
  `leads_idle-6_light_1.0_en_360x800.png` (search + filter top-right row
  1; kanban + `+ Add Lead` end-aligned row 2), `leads_idle-6_768x1024`
  (single row), ar/tablet/320/1.3x goldens unchanged in structure.
- F9 shell single-path (leads): the shell-bar search trigger WAS visible
  on the leads tab alongside the list header icon (two find paths for
  "find a lead" — C16 duplicate). `crm_dashboard_view.dart` `_CrmChrome`
  now passes `onSearch: null` when `selectedIndex == 1`
  (owner/tech/supervisor `selectedIndex`-guard precedent, presentation
  only — the `WorkspaceSearchShortcuts` Ctrl+K wiring is untouched, only
  the visible trigger is scoped out). On the leads tab: > 5 → the list
  sheet is the single path; ≤ 5 → no search at all (the sanctioned
  exception holds). Other tabs keep the shell palette unchanged.
- F10 verification (no code change): context lines `Meta · Sara ·
  Called` / `Zoho · John · Called` present on `leads_idle-6_360`; tasks
  ar pill reads `عالية`; team empty keeps the `Leaderboard` header;
  `leads_loading_...` skeleton frame present. Observed (not in scope):
  the phone-fallback card title renders `+971 ...` last-glyph-first in
  the ar golden (bidi, pre-existing round-2 behavior) — reported, not
  changed.

WAVE-2 ARB delta: **zero new keys on this surface** (header/shell work
reuses `navLeads`, `leadsSearchTitle/FilterTitle`, `leadsAdd`,
`tkCountN`, `chromeRefresh`). The 4 new keys (`tmRevenue`,
`tmSearchTitle/Hint/NoMatch`) belong to the sales-team surface; EN/AR
parity holds (`flutter gen-l10n` ran clean from `apps/crm_app`).

## Ruling (a) search relocation (presentation/flow-wiring only)

- Shell (`crm_dashboard_view.dart` `_CrmChrome`): the AppBar search
  trigger is the SINGLE visible icon on the leads tab — contextual,
  opening the EXISTING `showCrmLeadsSearchSheet` (same widget, same
  provider list, same `LeadDetailSheet.show` dossier route), gated by the
  same `totalLoaded > 5` condition relocated from the list header. ≤ 5 →
  no trigger (sanctioned exception holds). Non-list tabs keep the palette
  (`_openSearch`, jump-to-dossier over the first 50) untouched; Ctrl+K
  (`WorkspaceSearchShortcuts`) untouched.
- List (`crm_leads_page.dart`): header search icon REMOVED (filter +
  kanban + Add stay where they are); `crm_leads_search_sheet.dart`
  import + `_revealLead` removed (page scroll anchors stay as row keys).
  No logic/data/predicate change (local agent/sort presentation state is
  page-owned — the shell sheet reads the provider list; STOP below).
- Changed assertions (same 15 testWidgets, verbatim): `>5` now asserts
  `Filter leads` present + `Search leads` absent; same-row test now pins
  filter-title Row + no search; search-sheet test opens the same sheet
  directly (shell owns the trigger) with identical no-match + Clear pins.
- Tap table (AFTER ≤ BEFORE): Open list ≤ 1; Find + open lead ≤ 2
  (shell icon + result → dossier, vs header icon + reveal + record tap);
  Add ≤ 2 (same sheet); Call ≤ 1 from list; Move stage ≤ 3; Retry ≤ 1.
- Frames recaptured in the living dir `after-crm-leads/` (11 PNGs) with
  `--update-goldens` limited to `crm_after_leads_capture_test.dart`
  (search-open now opens the same sheet directly), compared back-to-back
  GREEN. RTL mirror, 320/1.3x clean (capture matrix + shell RTL test).
- STOPs: (1) compact list-mode scroll-reveal needs the page scroll
  anchors — the shell leads path goes straight to the dossier (same
  destination, fewer taps, no regression); (2) the shell sheet reads the
  provider list without the page-local agent/sort presentation state —
  replicating it in the shell would be logic; filed, not changed.
- R1 gate check (ui/fix-rulings, no change needed): the shell leads gate
  already reads the SAME source the page renders —
  `ref.watch(crmLeadProvider).length` vs page
  `ref.watch(crmLeadProvider).length` (`crm_leads_page.dart:110`); sheet
  reads `ref.read(crmLeadProvider)` (same provider list). No defect, no
  edit. Counts never down (8 -> 13 -> 14 -> 15 -> 15 + 8 shell).
