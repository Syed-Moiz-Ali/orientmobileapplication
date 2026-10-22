# UX Brief — staff advisor jobs list (list family, GROUP-B `ui/list-staff-jobs`)

## Scope
`apps/staff_app` advisor jobs register: `features/advisor/presentation/pages/advisor_jobs_view.dart`
(list + header + inline search + filter rail + sort + assigned-bookings intake section +
compact divider rows + wide master-detail table + preview pane) +
`features/advisor/presentation/widgets/advisor_job_card_row.dart` (one compact row) +
`features/advisor/presentation/widgets/advisor_job_card_sheet.dart` (quick preview sheet,
chrome only). Routes touched only as existing destinations: `AppRoutes.advisorJobDetail`
(extra `JobCardEntity`), `AppRoutes.advisorCheckIn` (extra booking map),
`AppRoutes.vehicleCustomer` (new job card). No new routes. No logic changes
(providers, sort/filter/search predicates, urgent handling, sync, refresh stay as-is).
This register is the jobs surface backing the advisor home Assigned list (home shows
`take(6)` urgent-first; this tab shows the full register with filter/sort/search).

## User goal
An advisor opens the Jobs tab and in one glance finds the right job card (customer +
vehicle), sees what state it is in, and opens it. One screen, one primary task:
find job → open workspace.

## Single primary action
Open the job card workspace (`onJobCard` → `AppRoutes.advisorJobDetail`). Everything
else (search, filter, sort, check-in, quick preview) serves that action.

## Current behavior (verified from code)
- Entry: advisor home `IndexedStack` index 1 (`advisorNavJobs`); no app bar of its own
  (tab content under the shell). Header = title row (`advisorJobsTitle` 800-weight +
  `StatusPill.neutral('${visible.length}')` count, only when non-empty and not loading)
  + `AppSearchField` inline (`advisorJobsSearchHint`, live `_jobsSearchProvider`) +
  `AppInfoPanel.danger` when `hasError` (with `advisorActionRefreshJobCard` retry that
  invalidates both providers).
- Filter: `AppFilterBar` with options All + Intake / Inspection / Approved / WIP / Ready
  (`advisorFilter*` labels via `advisorStatusFilterKey`), live per-label counts; selection
  is `_jobsFilterProvider` (presentation state). Deviation note: `cancelled` cards are
  reachable under All only (filter key exists but has no rail option — kept verbatim).
- Sort: `AppDropdownButton` (`advisorSortLabel`, `advisorSortNewest/Oldest/Customer`);
  `customer` sorts by name, `oldest` reverses server order, default newest-first.
  Search predicate (presentation, unchanged): id + customerName + vehicleInfo substring,
  case-insensitive. Sort + filter compose over `advisorRecentJobCardsProvider` (server
  page 1/size 50 + local-first intake cards, `[...localCards.reversed, ...serverCards]`).
- Intake section (only when query AND filter are empty and bookings non-empty):
  `AppCard.standard` with `advisorAssignedIntakeQueue` title + `StatusPill.info`
  (`advisorPendingCount`) + up to 3 `AppRecordRow`s (service · vehicle / customer · date)
  each with a `PrimaryButton` Check In (`advisorActionCheckIn` → `advisorCheckIn` route).
- Compact: `RefreshIndicator` + bordered container (top/bottom hairlines, 1px dividers)
  of `AdvisorJobCardRow` 72px rows (status dot 8px + customer 15/600 + plate pill LTR +
  job mono 12 LTR + `advisorStatusPill` right + time muted 12 + chevron; `onMore` →
  `_showQuickCard` → `showModalBottomSheet` `AdvisorJobCardSheet` with Open action).
- Wide: `AppMasterDetailScaffold` (master 440–720) + `AppTable` (columns Customer / Job
  Card / Vehicle / Status / Time; sort on Customer + Time; sticky header; row tap =
  local `_selected` preview) + `_JobPreviewPane` (avatar + customer + mono id + pill +
  vehicle/technician/created/odometer tiles + `PrimaryButton` Open job card
  `advisorActionOpenJob`). Placeholder `_JobPreviewPlaceholder` when nothing selected.
- States: loading → `LinearProgressIndicator` (thin, top) + `AppSkeleton.listRows(4)`
  (compact) / `AppTable(isLoading, skeletonRows: 6)` (wide); error-first-load →
  `AppInfoPanel.danger` + retry; empty (no query/filter) → `EmptyState` + `PrimaryButton`
  New job card (`advisorActionNewJobTitle` → `vehicleCustomer`); no-match → 
  `EmptyState.noMatch` (`advisorNoMatchingJobs`) + Clear (`filterBarClear`, clears search
  AND filter); stale data kept under error banner (`advisorDataError` + same retry);
  pull-to-refresh (`advisorRefreshProvider.state++`); no freshness footer on this tab.

## Top tasks with tap counts (BEFORE = current UI, AFTER must be ≤)
1. Open a job card workspace — before: Jobs tab (1) + row tap (1) = **2 taps** (+scroll).
   After: tab (1) + card tap (1) = **≤ 2 taps**, ≤ same scroll.
2. Find a specific job (search) — before: tab (1) + inline field tap (1) + type +
   row tap (1) = **3 taps** + typing. After: tab (1) + header search icon (1) + type +
   sheet result tap (1) = **≤ 3 taps** + typing (icon tap replaces field tap; the
   existing `AdvisorSearchSheet` filters the same loaded register with the same
   predicate, Enter opens the top hit, job-card result → same `advisorJobDetail` push).
3. Triage by status (filter) — before: tab (1) + filter chip (1) = **2 taps**.
   After: rail stays inline = **≤ 2 taps** (see deviation reason below).
4. Check in an assigned booking — before: tab (1) + Check In (1) = **2 taps** (+scroll
   past at most 3 rows). After: **≤ 2 taps**, ≤ same scroll (direct per-row action kept).
5. Quick-preview a card without leaving — before: tab (1) + overflow (1) + Open (1)
   = **2 taps + sheet**. After: **≤ 2 taps + sheet** (same sheet, App* chrome only).
6. Sort the register — before: tab (1) + dropdown (1) + option (1) = **3 taps**.
   After: **≤ 3 taps** (control stays inline, same options).
7. New job card from empty — before: tab (1) + New job card (1) = **2 taps**.
   After: **≤ 2 taps** (empty-state primary CTA, same `vehicleCustomer` route).
8. Retry sync / failed removal — before: inline Retry = **1 tap**. After: **≤ 1 tap**.

| Task | Before | After budget |
|---|---|---|
| Open job card | 2 taps (+scroll) | ≤ 2 taps, ≤ same scroll |
| Find job via search | 3 taps + typing | ≤ 3 taps + typing (icon replaces field tap) |
| Filter by status | 2 taps | ≤ 2 taps (rail stays inline — reason below) |
| Check in booking | 2 taps (+scroll) | ≤ 2 taps, ≤ same scroll |
| Quick preview → Open | 2 taps + sheet | ≤ 2 taps + sheet |
| Sort register | 3 taps | ≤ 3 taps |
| New job from empty | 2 taps | ≤ 2 taps |
| Retry failed load | 1 tap inline | ≤ 1 tap inline |

Frequent tasks (find job, open job, triage) stay single-screen. No step flows.

## References (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: **does not exist** (confirmed — no `references`
  dir under `docs/ui-redesign/`).
- `AIRBNB_PATTERNS.md`: **missing anywhere in the repo** (confirmed — repo-wide
  glob `**/AIRBNB_PATTERNS*` returns nothing; only mention is
  `docs/ui-redesign/evaluation/technician-home-test-migration.md:183`, which itself
  records that the file/dir does not exist).
- Mapping proceeds from the **phase-6 vehicles-list precedent**
  (`docs/ui-redesign/briefs/phase-6-vehicles-list.md` + `WIDGET_MIGRATION_MAP.md`
  § phase-6 vehicles-list): `AppPageHeader` (title + count subtitle) + header search
  icon opening a full-screen search sheet over loaded records (no new routes/logic);
  whitespace-separated borderless light cards (C16); frequent action direct on the
  card; no-match + Clear; `AppBanner` for blockers; `AppEmptyState`/`AppErrorState`;
  `AppShimmerSkeleton` mirroring layout; sentence case; zero as `0`.

## U-laws application (U0–U14, C17)
- U0 (one read): one card = identity (customer + vehicle) → ONE status chip → meta
  (time) → job id as small LTR mono meta. CARD HIERARCHY (binding): title = the thing
  the advisor recognizes (customer + vehicle); plate (when present in `vehicleInfo`)
  stays a small pill; status pill ONLY from existing `advisorStatusLabel` vocabulary
  (never invented); IDs are meta, never titles. Borderless in light (shadow or flat,
  whitespace separation; C16).
- U1 (find fast): header search icon top-right opens the EXISTING `AdvisorSearchSheet`
  full-screen (same predicate id/customer/vehicle, recents, scan CTA, autofocus, Enter
  = top hit; job-card result → same `advisorJobDetail` push). Inline `AppSearchField`
  is REMOVED (never an inline field mid-page; audit rule: exactly one visible search
  icon per screen — the Jobs tab currently has zero header icons, so one is added and
  the inline field is removed, not duplicated). PROGRESSIVE-DISCLOSURE EXCEPTION (the
  ONE sanctioned U1 exception on this screen, per vehicles precedent): the search icon
  is shown ONLY when the loaded register has MORE THAN 5 job cards; with ≤ 5 cards
  show cards only, no search icon (fully scannable as-is).
- U2 (fit the content): at 360x800 the FIRST card sits above the fold (above the bottom
  nav, idle state with data); the second card peeks. Compact header stays slim
  (title + count one row, rail + sort rows); nothing pushes the first card below the
  fold — anything that does needs a written reason in the build log.
- U3 (no fake actions): every control maps 1:1 to an existing handler
  (search/filter/sort/check-in/preview/open/retry/new-job); no invented facets.
- U4 (no invention): plates/ids/times verbatim via existing helpers; counts from
  loaded lists only; zero as `0`; cancelled stays reachable under All (no silent
  re-filtering — the rail genuinely lacks a cancelled option, recorded here, not
  "fixed" by logic).
- U5 (reachable + legible): 48dp targets on all actions; customer name wraps ≤ 2 lines,
  never `…` on a person's name; rows fit at 320px / 1.3x (pill + time compress first,
  same compact-density handling as today); job ids/VIN-ish text stay LTR-locked.
- U6 (states): skeleton mirrors final layout (`AppShimmerSkeleton`: header lines +
  rail + card rows compact / table rows wide); honest empty (`AppEmptyState`: EXACTLY
  one icon + one sentence + one New-job-card action → same wizard route); error
  (`AppErrorState` + Try again, same invalidate); stale data kept under `AppBanner`
  warning; no-match + shared Clear (clears search AND filter, verbatim).
  Pull-to-refresh kept.
- U7 (feedback): row tap → immediate route push; sheet preview → Open; destructive:
  N/A on this surface (no destructive action exists on the jobs list — no confirm
  sheet to migrate; recorded so the vehicles "sheets for destructive confirms" item
  is explicitly not-applicable rather than missed).
- U8 (no dead ends): every card opens; every booking row checks in; empty always
  offers New job card; no-match always offers Clear. Completed/delivered cards are NOT
  hidden under a separate tab — the rail is status-agnostic triage, and All shows
  everything (no silent filtering; U8 relevance satisfied by the existing filter, not
  by reordering logic).
- U9 (consistency): `AppPageHeader` + header search icon top-right (same placement as
  advisor home, supervisor floor, technician today, owner home); shared `AdvisorSheet`
  → `AppBottomSheet` chrome for the quick preview; same atoms as technician-Jobs
  (filter rail) and vehicles-list (cards, banners, states).
- U10 (RTL): full mirror; ids/plates/times LTR-locked (existing `Directionality`
  contracts kept); chevrons mirror via `DirectionalIcon`.
- U11 (a11y): row `Semantics` label (customer + id) kept; header `Semantics(header)`;
  48dp targets; AA contrast; text scale 1.3x with no overflow.
- U12 (density): 1-col compact; wide keeps the existing master-detail table + preview
  (see deviation reason); max-width per `AppResponsivePage` contract.
- U13 (offline): shell owns offline state; stale list kept + `AppBanner` warning +
  inline retry; no permanent sync pill (C16).
- U14 (no regression): tap budgets above are ceilings; pull-to-refresh, haptics,
  `ValueKey`s, sheet + snackbar contracts unchanged in behavior (presentation only).
- C17: any U-law fail caps at 8/16. C16 list adaptations: search-sheet over items
  (progressive disclosure: only when > 5), borderless light cards, card hierarchy
  binding, no ALL CAPS added, zero as `0`, first card above fold + second peeking at
  360x800, empty = one icon + one sentence + one action, no dead affordances, no new
  routes, taps never regress.

## Deviations from the vehicles-list pattern (with reasons — top-3 says otherwise)
1. **Filter rail stays inline (not a bottom sheet).** Status triage is a top-3 frequent
   task at 2 taps today; a filter sheet (icon + chip + Show-results = 4 taps) would
   regress it and violate U3. Technician-Jobs precedent keeps the canonical status
   filter rail inline; this screen follows that precedent instead. Same predicate,
   same counts, same labels — presentation mapping to `AppChip`/`AppPillTabs` only.
2. **Sort control stays inline (not in a sheet).** Adjacent to the rail, one compact
   control, 3 taps today; moving it alone into a sheet adds taps with no U-law gain.
   Same options, same behavior.
3. **Wide keeps the `AppTable` master-detail matrix (vehicles has no table).**
   C9 responsive rule: desktop = real table with sticky header, mobile = stacked cards.
   The jobs matrix is homogeneous sortable rows (customer/id/vehicle/status/time),
   not heterogeneous record cards — a table is the honest wide pattern, and the
   master-detail preview pane is the established wide grammar. Compact stays cards.
   Table chrome migrates to tokens; columns/cells/sort/selection logic untouched.
4. **Search icon threshold (> 5) applies here exactly as on vehicles** (not always-on):
   with ≤ 5 cards the register is fully scannable; an always-on icon would add chrome
   without saving taps. Registers routinely exceed 5, so the icon is present in the
   normal case — the exception only covers the trivially small list.

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke title row (`titleLarge` 800 + `StatusPill.neutral` count pill) →
  `AppPageHeader` (title `advisorJobsTitle` + count subtitle, single proposed
  `advisorJobsCountNone/One/Many` keys; search `AppIconButton` top-right ONLY when loaded
  `jobCards.length > 5`, tooltip reuses `advisorSearchTitle`).
- REMOVED: inline `AppSearchField` (mid-page) → header search icon opens the existing
  `AdvisorSearchSheet` full-screen (same controller state shape, same predicate,
  same recents/scan/Enter/top-hit/result-push contracts; sheet chrome may take App*
  mapping without behavior change).
- REMOVED: `AppInfoPanel.danger` error styling → `AppErrorState` (first-load) /
  `AppBanner` warning (stale + retry); same messages (`advisorDataError`), same
  invalidate retry. `LinearProgressIndicator` thin bar → dropped (skeleton owns
  loading; no permanent status chrome per C16).
- REMOVED: bordered divider container + `AdvisorJobCardRow` bespoke row chrome →
  whitespace-separated borderless `AppSurfaceCard(outlined: false)` rows (shadow in
  light, shared border in dark): customer + vehicle title (≤2 lines) → ONE
  `AppStatusChip` (sentence-case `advisorStatusLabel` vocabulary, same kind mapping
  as `advisorStatusPill`) → meta sentence (time) → job id small LTR mono meta +
  chevron; tap = open (frequent action direct on card); overflow (`advisorActionMore`,
  48dp) → existing `AdvisorJobCardSheet` quick preview re-chromed onto
  `showAppBottomSheet`/`AppBottomSheet` (content + Open + handlers byte-identical).
- REMOVED: `AppCard.standard` intake-queue card + `PrimaryButton` Check Ins →
  `AppSurfaceCard` + per-row direct Check In actions (one filled action per ROW, no
  section-level CTA — C16 one-primary intent; same `advisorCheckIn` route + extras).
  `StatusPill.info` pending count → `AppStatusChip` info (same `advisorPendingCount`
  copy). Cap of 3 rows kept verbatim.
- REMOVED: `EmptyState` / `EmptyState.noMatch` / `AppSkeleton.listRows` →
  `AppEmptyState` (exactly 1 icon + 1 sentence + 1 New-job-card action →
  `advisorNoJobs`/`advisorNoJobsHint` + `advisorActionNewJobTitle`, same
  `vehicleCustomer` route) / no-match + shared Clear / `AppShimmerSkeleton`
  mirroring header + rail + cards (compact) or table rows (wide).
- REMOVED: `_JobAvatar` bespoke circle + `_JobPreviewPane` bespoke card chrome →
  shared `AppAvatar` + `AppSurfaceCard` (same identity fields, same Open route,
  same selection state); `_JobPreviewTile` rows → `AppDataRow` (same labels/values,
  mono kept for id/odometer).
- MOVED (unchanged behavior): filter rail, sort dropdown, bookings section, preview
  selection, pull-to-refresh, haptics, `ValueKey`s, confirmation + snackbar contracts.
- KEPT (untouched logic): `advisorRecentJobCardsProvider` (server + local-first
  intake merge), `advisorAssignedBookingsProvider`, `_jobsSearchProvider`,
  `_jobsFilterProvider`, `_jobsSortProvider` state shapes, `advisorStatusFilterKey`
  taxonomy (incl. cancelled-under-All), `_sorted` comparators, urgent handling,
  `onJobCard` routing, sync/refresh, all ARB copy except the one proposed count key.
- No new routes. No invented jobs/statuses/counts. Zero as `0`, never `-`.

## Flow / sections (C16 list screen)
`AppScaffold` (SafeArea, token background) → `AppPageHeader` (title + count subtitle +
search icon top-right when > 5) → horizontal filter rail (All + 5 status chips with
counts) → sort row (compact control) → intake-queue section (only when unfiltered and
bookings exist, max 3, per-row Check In) → card list (12 gap, pull-to-refresh) →
freshness-neutral (no footer exists — none added). Wide (≥ medium): master table +
preview pane (existing split, App* chrome).

## Hard-reject checklist (all must hold; reviewer caps at 10/16 on ANY violation)
- [ ] Borderless light cards (shadow/flat + whitespace); dark may use border
- [ ] No orphan tiles (N/A — no tile grid on this screen; rail scrolls with peek)
- [ ] ONE filled accent per row/section (card tap is the action; Check In one per row)
- [ ] One path per task (exactly one visible search icon; no inline field + icon)
- [ ] No permanent status pills (sync only as AppBanner when abnormal)
- [ ] Badges offset outside icons, clear area kept (N/A — no badge icons on list)
- [ ] No ALL CAPS; no label/badge number duplication (count once, in subtitle)
- [ ] Search = one top icon → full search sheet (never inline mid-page)
- [ ] Above the fold: first card visible at 360x800 idle (wireframe below proves it)
- [ ] Card hierarchy: recognizable title → status pill → meta (IDs are meta)
- [ ] Wide table keeps sticky header; compact is cards, never a squeezed table

## U0-U14 checklist (all must hold; ANY violation caps at 8/16, no exceptions)
U0 least effort / U1 search icon top-right → full-screen search (> 5 exception noted) /
U2 first actionable card above fold at 360x800 idle / U3 tap counts above (frequent ≤
before, most frequent ≤ 2) / U4 Check In + preview reachable without scrolling past
more than shown rows / U5 no truncation of primary text (name ≤ 2 lines, ids LTR) /
U6 calm empty (filled CTA only to the existing wizard) / U7 one path per task (single
search icon; conditional See-all N/A — full register shown) / U8 relevance (All shows
everything; cancelled documented, not silently dropped) / U9 consistency (same header
+ search + atoms as home/supervisor/technician/owner) / U10 feedback + retry /
U11 readable numbers (0 never `-`; tabular figures for ids/counts) / U12 one
background / U13 new-employee labels (plain words) / U14 a11y (48dp, AA, Semantics,
1.3x, 320px).

## ASCII wireframe at 360x800 (mandatory; first card above the bottom nav)
```
+----------------------------------+
| Workshop Job Cards         [🔍]  |  <- 🔍 only when > 5 cards; ≤ 5: title only
| 7 job cards                      |  <- count subtitle (no pill duplication)
|----------------------------------|
| (All) Intake Inspection Approv…  |  <- filter rail, counts, peek
| Sort: Newest first               |  <- compact sort row (unchanged options)
|----------------------------------|
| Assigned intake queue     [2 pend]|
| Oil change · Camry · Ahmed       |
|                     [Check In]   |  <- per-row direct action (≤ 2 taps)
|----------------------------------|
| Ahmed · Camry · ABC 1234         |  <- title = recognized thing (≤ 2 lines)
| (In progress)                    |  <- ONE status chip, sentence case
| 10:30 AM · JC-1042            [>]|  <- meta + id LTR mono + chevron
|----------------------------------|  <- above fold (nav below)
| Layla · Yaris · XYZ 5678         |  <- second card PEEKING
+----------------------------------+
| Today | Jobs | Reports (bottom nav) |
```

## States
loading (layout-mirroring `AppShimmerSkeleton`: header + rail + cards / table rows) ·
empty (no cards: `AppEmptyState` + New job card → same wizard) · error-first-load
(`AppErrorState` + Try again, same invalidate) · stale (`AppBanner` warning + last
data + retry) · no-match (filter/search: no-match + shared Clear clearing both) ·
ar (RTL mirrored; ids/plates/times LTR-locked) · 1.3x (rows reflow, pill + time
compress first, actions never clip) · 320px (single column; header + rail + first
card intact) · tablets (medium/expanded: master-detail table + preview, max-width
per contract) · staff light-only (no dark frames needed; dark keeps the shared
border path and must not regress structurally).

## Copy keys needed
Reuse existing staff keys (`advisorJobsTitle`, `advisorJobsSearchHint` retired from
the inline field but kept for the sheet entry — no deletion, sheet owns its own
`advisorSearchHint`; `advisorFilter*`, `advisorSort*`, `advisorNoMatchingJobs`,
`advisorNoJobs(Hint)`, `advisorAction*`, `advisorPendingCount`,
`advisorAssignedIntakeQueue`, `advisorJobsColumn*`, `advisorJobsSelectPrompt`,
`advisorActionOpenJob/More`, `advisorStatus*`, `filterBarClear`, `commonRetry`).
New keys (phase-9 list, en+ar): `advisorJobsCountNone` ("No job cards" /
"لا توجد بطاقات عمل"), `advisorJobsCountOne` ("1 job card" / "بطاقة عمل واحدة"),
`advisorJobsCountMany` ("{count} job cards" / "{count} بطاقة عمل") — One/Many
pair convention (no ICU, same as `techProdRepairOne/Many`); zero renders as words
via the None branch (U11). `flutter gen-l10n` from `apps/staff_app` (clean,
`l10n_untranslated.json` empty, ARB byte-safe).

## Acceptance
- U0–U14 walk (ANY U-law fail caps at 8/16; the > 5 search-icon threshold is the ONE
  sanctioned U1 exception on this screen, same rationale as vehicles-list; every
  other U-law applies in full); C16 hard-reject checklist for lists (caps 10/16).
- Airbnb rubric ≥ 12/16 to pass.
- Gates (kept): characterization tests on the CURRENT list first, before-images
  captured, migration table (current → shared atoms), reviewer process per redesign
  mandate, NO logic changes.
- Verify from code: tap counts, route names (`advisorJobDetail`, `advisorCheckIn`,
  `vehicleCustomer`), `advisorStatusFilterKey` taxonomy, existing search predicate
  (id/customer/vehicle substring), `ValueKey` contracts, no `71983229` touched.
