# Advisor jobs register test migration (GROUP-B screen 1, branch `ui/list-staff-jobs`)

Screens covered: (1) advisor jobs list — `AdvisorJobsListView`
(`features/advisor/presentation/pages/advisor_jobs_view.dart`) + row
(`widgets/advisor_job_card_row.dart`) + quick preview sheet
(`widgets/advisor_job_card_sheet.dart`); (2) inspection / repair-order lists —
no separate surface exists (one unified register; see
`docs/ui-redesign/briefs/advisor-inspection-repairorder-lists.md`), so this
single migration doc governs both screens. Recomposed presentation-only onto
App* pattern widgets: providers, routes, sync logic, sort/filter/search
predicates, selection state, sheet contracts and all copy semantics untouched.
Bottom nav / rail untouched; no new routes.

## Inventory (characterization baseline, STEP 0)

- `apps/staff_app/test/advisor_jobs_characterization_test.dart` (new, 12
  testWidgets): behavior pins written for the CURRENT jobs UI with provider
  overrides (`advisorRecentJobCardsProvider`, `advisorAssignedBookingsProvider`,
  `advisorPendingSyncCountProvider`; private `_jobsSearch/_jobsFilter/_jobsSort`
  providers driven through the UI, never touched directly) plus a stub `GoRouter`
  (`/` register, `/advisor/check-in` stub, `/vehicle-customer` stub) so
  navigation targets are asserted without leaving the tab. Run GREEN on current
  UI (12/12; harness-only fixes during authoring: `ensureVisible` for below-fold
  controls, `pumpAndSettle` for sheet/menu animation, row-scoped overflow
  finder, U+2013 en dash in `Customer A–Z`). Frozen after STEP 0 except for
  harness fixes and the structural forward pins below — counts 12 -> 12.
- Old assertion count: **12**. New assertion count: **13** (verified after
  the rebuild — counts never down; +1 is the search test split, one pump per
  test — see the harness lesson in §Changed test assertions).
- Before pixels (frozen record, never regenerated):
  `docs/ui-redesign/baseline/before-advisor-jobs/` — `jobs_1.0_en_360x800`,
  `jobs_1.0_ar_360x800`, `jobs_empty_en_360x800`, `jobs_1.0_en_320x568`,
  `jobs_1.0_en_1280x800` (tab-level, staff light-only). Produced by
  `apps/staff_app/test/advisor_jobs_before_capture_test.dart` (tagged
  `baseline`, excluded from the default run).
- What the before-frames prove (reviewed 2026-10-22): header title + bare `5`
  pill; inline search field mid-page (U1 violation being removed); filter rail
  with live counts; full-width sort dropdown; intake-queue card with per-row
  Check In; divider rows whose `StatusPill`s truncate mid-word at 360px
  (`Pendi…`, `Inspect…` — U5 violation the card redesign fixes); wide = intake
  card + sortable table + empty preview prompt (table cells wrap/truncate:
  `Corolla · DXB 111` wraps, `Complet…` truncates).

## Planned Old → New mapping (presentation only; logic byte-identical)

| Area | Old (current) | New (App*) | Kind |
|---|---|---|---|
| Header | title row (`titleLarge` 800) + `StatusPill.neutral(visible.length)` | `AppPageHeader` (title `advisorJobsTitle` + count subtitle `advisorJobsCount` plural) + search `AppIconButton` top-right ONLY when loaded `jobCards.length > 5` | structural (brief-mandated header; U1-exception noted) |
| Search | inline `AppSearchField` filtering in place | header icon opens existing `AdvisorSearchSheet` full-screen (same predicate id/customer/vehicle, recents, scan CTA, Enter = top hit, job result → same `advisorJobDetail` push); wire `onScan` → `AppRoutes.scanVehicle` (home parity; CTA lives inside the sheet, no second visible affordance) | structural (U1: never inline mid-page; exactly one visible search icon) |
| Filter rail | `AppFilterBar` inline (All + 5 chips + counts) | unchanged position, atoms mapped to `AppChip`/`AppPillTabs` grammar only if the shared bar changes — predicate, labels, counts, toggle + Clear contract verbatim | behavioral (unchanged; sheet would regress the 2-tap triage — see brief deviation 1) |
| Sort | `AppDropdownButton` inline (Newest/Oldest/`Customer A–Z` en dash U+2013, verbatim) | unchanged position/options/behavior | behavioral (unchanged; see brief deviation 2) |
| Compact rows | bordered container + 1px dividers + `AdvisorJobCardRow` (pill truncates at 360px) | whitespace-separated borderless `AppSurfaceCard(outlined: false)` rows: customer·vehicle title (≤2 lines) → ONE `AppStatusChip` (sentence-case `advisorStatusLabel` vocab) → meta (time) → id small LTR mono + chevron; tap = open; overflow (`advisorActionMore`) → same quick sheet | structural (C16 hierarchy; fixes U5 truncation) |
| Intake queue | `AppCard.standard` + `PrimaryButton` Check In + `StatusPill.info` | `AppSurfaceCard` + `AppPillButton.primary` small per-row Check In + `AppStatusChip` info (same copy/route/extras; cap of 3 kept) | structural (one filled action per ROW, no section CTA — vehicles precedent) |
| Quick preview | `showModalBottomSheet` + `AdvisorSheet` chrome | `showAppBottomSheet`/`AppBottomSheet` chrome; content + Open + handlers byte-identical | structural (chrome only) |
| Loading | `LinearProgressIndicator` + `AppSkeleton.listRows` / table skeleton | `AppShimmerSkeleton` mirroring header + rail + cards (compact) / table rows (wide); thin bar dropped (no permanent chrome) | structural |
| Empty | `EmptyState` + `PrimaryButton` New job card | `AppEmptyState` (1 icon + 1 sentence + 1 action → same `vehicleCustomer` route) | structural (rendering-identical) |
| No-match | `EmptyState.noMatch` + Clear (clears search AND filter) | same contract on shared atoms | behavioral (unchanged) |
| Error | `AppInfoPanel.danger` + retry (first-load and stale) | `AppErrorState` + retry (first-load, label stays verbatim `advisorActionRefreshJobCard`) / `AppBanner` warning + last data + retry (stale); same messages (`advisorDataError` + `advisorOfflineNotice`), same invalidate | structural (rendering-identical) |
| Wide matrix | `AppMasterDetailScaffold` + `AppTable` + bespoke preview (`_JobAvatar`, `_JobPreviewTile`, `AppCard.standard`, `PrimaryButton`) | same split/selection/sort; preview rebuilt with `AppAvatar` + `AppSurfaceCard` + `AppDataRow` + `AppPillButton.primary` Open; `cellFlex: [3,2,2,4,2]` added (row flexes mirror column flexes — column `flex` drives the header only; Status owns the widest share so single-word chips never break mid-word) | structural (shared atoms; table kept per C9 — brief deviation 3) |
| Destructive | N/A (no destructive action exists on this surface) | N/A — vehicles "sheets for destructive confirms" item explicitly not-applicable, not missed | — |

## Changed test assertions (post-build actuals, all GREEN)

| Test | Old | New | Kind |
|---|---|---|---|
| register shows every card | Exact customer names (`find.text`) | Card titles (`find.text` exact `customer · vehicle`) + scroll-aware `dragUntilVisible` per card (tall cards build lazily; 5th card is off-viewport) | structural (brief-mandated card hierarchy) |
| row tap opens the job workspace | Tap exact customer name | Tap exact combined title | structural (same tap, new title text) |
| inline search filters in place | Type in inline field, assert filtered register | SPLIT into two tests (12 → 13): (a) ≤ 5 cards render no search icon (the > 5 rule); (b) 6 cards → header icon → sheet → type → sheet shows only the match | structural (U1: search moved to the sheet; same predicate + typing contract) |
| status filter narrows, All restores | Exact names incl. offscreen cards | `textContaining` + scroll-aware re-pin after All | structural (lazy cards) + harness |
| sort by customer A-Z | 5-job register geometry | 2-job register (both cards stay built, geometry holds); `Customer A–Z` keeps U+2013 | harness (same sort behavior) |
| empty offers new-job | Exact `find.text` on copy | `textContaining` (AppEmptyState/AppErrorState bidi-isolate copy — invisible isolates, same strings) | structural (rendering-identical) |
| no-match + Clear | Query-driven no-match | Filter-driven no-match on a sparse register (query clause preserved in code; filter path is the reachable one); two Clear controls, both reset | structural (search moved to sheet) |
| first-load failure retry | (unchanged) | Verbatim — retry label stays `advisorActionRefreshJobCard`, same invalidate | behavioral (unchanged) |
| intake queue Check In | Query hides intake | Filter chip hides intake (same contract, new driver) | structural (search moved to sheet) |
| overflow quick preview | Ancestor on exact name | Ancestor on combined title; pumpAndSettle for sheet entrance | structural + harness |
| loading progress | `LinearProgressIndicator` | `AppShimmerSkeleton` findsWidgets + `LinearProgressIndicator` findsNothing (bar dropped) | structural (brief-mandated skeleton-only loading) |
| wide matrix | (unchanged) | Verbatim (exact customer names still render in table cells) | behavioral (unchanged) |

Harness lessons (test-only, no production impact): (1) a second `pumpWidget`
with a new `ProviderScope` does NOT refresh Riverpod overrides in the same
test — each register variant gets its own test (hence the search split
12 → 13); (2) tall cards build lazily — scroll-aware pins via
`dragUntilVisible`; (3) `ensureVisible` before tapping below-fold controls;
`pumpAndSettle` for sheet/menu entrance; (4) the sheet reads the Hive
customer box + the approvals feed, so the harness opens an empty
`inspections` box and overrides `advisorPendingApprovalsProvider` (production
always has both); (5) `Customer A–Z` carries a U+2013 en dash — probe the
string before pinning it.

## Behavior assertions (verbatim, unchanged)

- Tap counts (brief BEFORE, verified from code): open job = tab + row (**2**);
  search = tab + field + row (**3** + typing); filter = tab + chip (**2**);
  sort = tab + dropdown + option (**3**); check-in = tab + Check In (**2**);
  preview = tab + overflow + Open (**2** + sheet); new job = tab + CTA (**2**);
  retry = inline (**1**). AFTER: identical or fewer (icon tap replaces field
  tap; rail/sort/check-in untouched).
- Provider reads identical: `advisorRecentJobCardsProvider` (server page + local
  intake merge, `[...localCards.reversed, ...serverCards]`),
  `advisorAssignedBookingsProvider`, `_jobsSearchProvider` / `_jobsFilterProvider`
  / `_jobsSortProvider` (private state shapes kept), `advisorRefreshProvider`
  untouched.
- Search predicate identical: id + customerName + vehicleInfo substring,
  case-insensitive; filter taxonomy identical (`advisorStatusFilterKey` incl.
  cancelled-under-All); sort comparators identical (server order / reversal /
  name). Sheet predicate (id/customer/vehicle + approvals + Hive customers)
  identical; Enter = top hit; job result → `advisorJobDetail` push.
- No new routes, no dropped routes: `advisorJobDetail` (extra `JobCardEntity`),
  `advisorCheckIn` (extra booking map), `vehicleCustomer`, `scanVehicle`
  (sheet scan CTA, home parity). Sheet result tap = same dossier contract.
- Selection state identical: wide `_selected` local preview + `onJobCard` Open;
  compact overflow → same quick sheet → same `onJobCard`.
- Copy identical except the new count keys (below). `Customer A–Z` keeps its
  U+2013 en dash byte-identical (found during characterization — probe before
  editing). Retry label stays `Refresh Job Card` (not the shared Try-again —
  zero label drift). No ALL CAPS added. Zero renders as words via the
  `advisorJobsCountNone` branch (U11: never `-`).

## Copy changes (new ARB keys, en+ar, regenerated)

- `advisorJobsCountNone` / `advisorJobsCountOne` / `advisorJobsCountMany` —
  header count subtitle (One/Many pair convention, no ICU — same as
  `techProdRepairOne/Many`; ar drafted, needs native review per C15).
  Replaces the bare-number `StatusPill.neutral('${visible.length}')` (count
  once, in the subtitle — no badge/label duplication).
- `flutter gen-l10n` rerun from `apps/staff_app`; ARB byte-safe only.

## Hero / CTA / empty decisions (with evidence)

- No hero on list screens (C16 list pattern): the register owns the viewport;
  header + rail + sort stay slim so the FIRST card sits above the fold at
  360x800 with the second peeking (before-frames show the intake card pushing
  chrome down — the rebuild keeps the intake section capped at 3 rows and the
  header to one row + subtitle so the fold holds).
- Search: header `AppIconButton` (tooltip reuses `advisorSearchTitle`) shown
  only when loaded `jobCards.length > 5` (the ONE sanctioned U1 exception —
  same rationale as vehicles-list: ≤ 5 cards fully scannable). Audit rule
  honored: exactly one visible search icon on the tab (inline field removed).
- CTA: card tap IS the frequent action (no button needed); per-row Check In
  stays direct (`AppPillButton.primary` small); empty state carries the single
  `AppPillButton.primary` New job card. One filled action per row/section —
  no competing CTAs.
- Empty (no cards): `AppEmptyState` (`advisorNoJobs`/`advisorNoJobsHint` + New
  job card → same wizard). No-match: no-match + shared Clear (clears both).
  Error: `AppErrorState` + Try again; stale: `AppBanner` warning + last data.
- Wide keeps the `AppTable` master-detail matrix (C9 responsive rule; the
  matrix is homogeneous sortable rows, not heterogeneous record cards).

## STOPs

- None. No logic change is needed for this rebuild (predicates, providers,
  routes, sync, payloads all stay byte-identical). If a future step requires a
  logic change, STOP that piece and report instead of inventing.
