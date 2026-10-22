# UX Brief — owner job-cards list (list family)

## Scope
`apps/owner_app` job-cards register: `features/job_cards/presentation/pages/job_cards_list_view.dart`
(search + milestone filter + sortable audit table + compact rows + wide side preview + empty/no-match/
loading) + `owner_dashboard` entry to this surface (route only) + `job_status_ui.dart` helpers
(`jobStatusPill`, `formatAed2` — READ-ONLY, shared with the detail view) + providers
(`jobCardsProvider` filter/sort/selection state, `selectedJobCardProvider` — read-only).
Routes touched only as existing destinations: compact row tap → `push(jobCardDetail)` (existing audit);
wide row tap → in-place preview select, preview Open → same `push(jobCardDetail)`. No new routes. No
logic changes (provider list/filter/sort, `_sorted`, `_labelFor`/`_statusFor`, `_openJob`, refresh stay
as-is).

## User goal
An owner opens the job register and in one glance sees every active job (who, what car, how much, what
stage) then opens one audit. One screen, one primary task: find job → open audit.

## Current behavior (verified from code)
- Entry: register page (`JobCardsListView`) under `WorkspaceSearchShortcuts` (`onSearch` → focuses the
  inline field — desktop shortcut, same target as typing). NO header search icon anywhere on this surface
  (audited single affordance: app bar actions carry ONLY the `StatusPill.neutral(ownerRegCount(n))`
  count; `WorkspaceAppBar` title `ownerRegTitle` + subtitle `ownerRegSubtitle` + back).
- Filter: `AppSearchField` (controller + focus, hint `ownerRegSearchHint`, `onChanged` → `onSearch`,
  `onClear` resets) over id/customer/vehicle/plate (4-field contains via `_applyFilters`) +
  `AppFilterBar` (6 lifecycle milestones Intake→Invoiced via `_labelFor`/`_statusFor`, live counts,
  single-select + clear on re-tap → `setFilter`).
- Table (`AppTable`, shared responsive atom): columns Job/Plate/Customer/Total(numeric)/Status;
  sortable Job/Plate/Customer/Total (`_sorted`, presentation-only copy sort, provider list never
  mutated); sticky header on wide (`maxHeight: 560`); `onRowTap`: wide (expanded/large) → in-place
  preview select (`_selectedId`), compact/medium → `_openJob` (sets `selectedJobCardProvider` +
  `push(jobCardDetail)`). Cells: LTR mono id + LTR mono plate + customer + `formatAed2` tabular total +
  `jobStatusPill` (shared helper, also detail's).
- Compact rows (`compactBuilder`): `AppRecordRow` (identifier id, title customer, subtitle
  `vehicle · plate`, metadata: LTR `formatAed2` amount + status pill as full-width bounded block —
  unshrinkable-pill fix, never clips at 320px/1.3x) → `_openJob`.
- Wide preview (`_PreviewPane`, expanded/large only): `AppCard.standard` dossier-mini (ref + pill +
  customer + LTR `vehicleDisplay` + total + `PrimaryButton` Open → `_openJob`) or select-prompt
  (`EmptyState` preview icon + `ownerRegSelectPrompt`).
- States: table-owned loading (`isLoading && all.isEmpty` skeleton), `emptyMessage`
  (`ownerRegEmpty`), no-match (`isNoMatch` + `ownerRegNoMatch` + clear path); there is NO error
  panel on this surface (the provider load has no error branch — pinned, untouched); pull behaviour
  via page scroll (`AppPageFrame`); `AppPageFrame` single-column, wide 5:3 split + 360 preview pane.
- Owner dark must not regress (light + dark captured, dark stays structurally intact per light-only
  convention — here: dark is a first-class owner contract, verify no regression).

## Top tasks with tap counts (BEFORE = current UI, AFTER = this brief; AFTER ≤ BEFORE)
1. Open the register — before: dashboard drill = **1 tap**. After: ≤ 1 tap.
2. Find a job — before: type in inline field (0-tap focus + keystrokes) and/or milestone chip (**1 tap**)
   = **≤ 1 tap + keystrokes** (+ scroll; sortable columns re-order without leaving). After: identical
   (single affordance kept; no header icon at any size).
3. Open a job audit — before: compact row tap = **1 tap**; wide row select (1) + preview Open (1) =
   **2 taps**. After: ≤ same (row tap stays the frequent action; preview Open stays the wide confirm).
4. Clear a no-match — before: field Clear / chip re-tap = **1 tap**. After: ≤ 1 tap.
5. Re-sort the audit — before: column header tap = **1 tap**. After: ≤ 1 tap (same table).

| Task | Before | After budget |
|---|---|---|
| Open register | 1 tap | ≤ 1 tap |
| Find job (search + filter + sort) | ≤ 1 tap + keystrokes (+scroll) | identical, ≤ same scroll |
| Open audit (compact) | 1 tap | ≤ 1 tap |
| Open audit (wide: select + Open) | 2 taps | ≤ 2 taps |
| Clear no-match / re-sort | 1 tap | ≤ 1 tap |

Frequent tasks (find, open) stay single-screen; the audit is the existing destination.

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: does not exist (confirmed — no `references` dir under `docs/ui-redesign/`).
- `AIRBNB_PATTERNS.md`: missing anywhere in the repo (repo-wide glob `**/AIRBNB_PATTERNS*` returns nothing;
  only mention is `docs/ui-redesign/evaluation/technician-home-test-migration.md:183`, echoed by the
  vehicles/supervisor/technician briefs).
- Mapping is therefore UNMET; this brief proceeds from precedent patterns (phase-7 brief +
  `phase-6-vehicles-list.md` + screens 1–4): header with count, single inline search affordance,
  filter rail on honest predicates, borderless light rows, frequent action = row entry, sheets/panes
  for secondary, empty/loading/error vocabulary, no ALL CAPS + zero as `0`.

## Vehicles-list pattern reuse — reasoned deviations
- REUSED: header with count (app-bar title + subtitle + live count pill); inline search (single
  affordance) + filter rail on honest predicates + sortable audit; borderless compact rows; frequent
  action = row entry (1 tap to audit); wide side preview (the pattern's detail/secondary path);
  empty/no-match/loading vocabulary; no ALL CAPS; zero as `0` (`AED 0.00`, never `-`).
- DEVIATION A (no `AppPageHeader` swap — chrome ownership): the surface chrome stays `WorkspaceAppBar`
  (title + subtitle + back + count-pill actions). Reason: the app bar is the owner workspace chrome
  (shared back/offline/shortcut vocabulary with the owner family); swapping it for `AppPageHeader`
  would diverge this surface from its family for zero task gain (title + subtitle + count already
  present, same seats). Presentation-only retoken inside the existing bar is allowed; replacing the bar
  is not.
- DEVIATION B (no header search icon — U1 note, audited STOP): NO search icon is added to this surface
  at any size. Reason: the phase-jobs-search-audit-review spot-check records this register as exactly
  one search affordance (inline `AppSearchField` + rail); the desktop shortcut focuses the SAME field
  (same target, not a second path). A header icon would create two same-target entries — a C16
  one-path-per-task violation. The > 5 threshold therefore does not add an icon here; the inline field
  + rail + sort scale instead.
- DEVIATION C (table kept on wide — data shape): unlike the staff scan lists (heterogeneous rows → no
  tables), this register is a homogeneous 5-column audit (Job/Plate/Customer/Total/Status) with numeric
  sort — the ONE list in this batch where the table matrix cell applies. Wide keeps the real `AppTable`
  (sticky header, sort semantics); compact keeps single-column `AppRecordRow` cards (shared row atom —
  deviation D). No grid-of-cards reinvention.
- DEVIATION D (shared atoms kept — STOP boundaries): `AppTable` + `AppRecordRow` + `jobStatusPill` +
  `formatAed2` are NOT rebuilt here. Reason: `jobStatusPill` is shared with the detail view (2 sites in
  `job_card_detail_view.dart`); `AppTable`/`AppRecordRow` are shared-core atoms whose internals serve
  other surfaces. Rebuilding them here would restyle out-of-scope surfaces. Rebuild swaps only the
  register-owned chrome around them (bar pill, preview cards/buttons, select prompt).

## U-laws application (U0–U14, C17)
- U0 (one read): table/row = job ref (what the owner recognizes) → customer + vehicle·plate → total →
  status pill. CARD/ROW HIERARCHY (binding): title = customer (compact) / ref (wide first col); ref/plate/
  money = mono LTR verbatim; pill ONLY from existing `JobCardStatus` (never invented).
- U1 (find fast): ONE inline affordance (field + shortcut focusing the same field) → in-place filter;
  rail narrows by milestone in 1 tap; columns re-sort in 1 tap. No header icon (deviation B).
- U2 (fit the content): homogeneous audit — table on wide (N/A-by-design does NOT apply here; this is
  the table case), single-column rows compact. FOLD (binding): at 360x800 the bar + field + rail + FIRST
  row sit above the fold (above bottom nav/gesture bar, idle with data) with the second row peeking;
  anything pushing the first row below the fold needs a written reason.
- U3 (no fake actions): rows map 1:1 to audit entry; Search/Filter/Sort/Clear/Open map 1:1 to handlers;
  preview prompt offers no fake creation (honest: audits open, jobs arrive from bookings).
- U4 (no invention): ref/plate/customer/vehicle/amount verbatim; `formatAed2` fixed-cents kept byte-exact;
  zero as `AED 0.00`; counts from `state.all` only.
- U5 (reachability + legibility): 48dp targets on chips/Clear/sort headers/Open; pill block bounded
  (unshrinkable-pill fix kept); ref/plate/money LTR-locked; wrap/ellipsis at 320px / 1.3x, never clip.
- U6 (states): table-owned loading skeleton; honest empty (`ownerRegEmpty` + hint, NO create-CTA —
  nothing to create); no-match (`ownerRegNoMatch` + clear path); select-prompt (`AppEmptyState`: one
  icon + one sentence, no action); no error panel exists on this surface (provider-owned, untouched).
- U7 (feedback): row tap → same `_openJob` (sets selection + pushes audit); wide select → same preview;
  Open → same push. One path per task (deviation B).
- U8 (no dead ends): every row opens; select-prompt explains; no-match clears; filters always reversible.
- U9 (consistency): `WorkspaceAppBar`, `AppSearchField`, `AppFilterBar`, `AppTable`/`AppRecordRow` —
  same atoms as the owner family.
- U10 (RTL): full mirror; ref/plate/vehicleDisplay/money LTR-locked (`Directionality` kept); sort icons
  mirror-safe.
- U11 (a11y): row `Semantics` (via shared atoms) + sort `Semantics` (table-owned) + 48dp targets kept;
  tabular figures kept.
- U12 (density): 1-col compact/medium; wide 5:3 + 360 pane (existing split kept, max-width frame).
- U13 (offline): search/filter/sort work on loaded data; reload via provider (same contracts).
- U14 (no regression): tap budgets above are ceilings; sort/selection/filter/search/open contracts
  unchanged in behavior.
- C17: any U-law fail caps at 8/16. C16 adaptations: no search-sheet, no ALL CAPS, zero as `0`,
  light cards borderless-feel (preview uses `AppSurfaceCard` border-XOR-shadow; dark keeps border).

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bar count `StatusPill.neutral` → `AppStatusChip` neutral (same `ownerRegCount` label);
  preview `AppCard.standard` (2 sites: prompt + dossier-mini) → `AppSurfaceCard` (same padding/body);
  preview Open `PrimaryButton` → `AppPillButton.primary` (same label/handler); select-prompt
  `EmptyState` (message-only) → `AppEmptyState` (title reuses existing `ownerRegTitle`, message
  `ownerRegSelectPrompt` verbatim, no action). No new keys.
- MOVED: nothing (Search/Filter/Sort/Select/Open keep seats; rows keep entry + preview).
- KEPT (STOP/pinned): `WorkspaceAppBar` + back + shortcut (deviation A); inline `AppSearchField` +
  `AppFilterBar` + milestone mapping + counts (deviation B); `AppTable` + columns/cells/sort/sticky +
  `compactBuilder` `AppRecordRow` + pill-block fix (deviations C/D); `jobStatusPill` + `formatAed2`
  (shared with detail — deviation D, including the helper's existing `.toUpperCase()` pill labels:
  byte-identical, none ADDED — C16 bans added caps, not this pinned quirk); providers/sort/selection/
  `_openJob`/routes/keys. No new routes. No invented jobs/statuses/totals.
- Dark: verify no regression against `baseline/after-owner-home` + new before/after dark frames.

## Fold wireframe (ASCII, 360×800 — bar + field + rail + first row above fold, second peeking)
```
+----------------------------------+
| ← Job register          [3 jobs] |  <- WorkspaceAppBar + count pill (deviation A; no search icon — B)
| All active workshop jobs         |
|----------------------------------|
| [Search job, plate, customer.    ]|  <- single inline affordance (shortcut focuses same field)
| (All)(Intake)(Inspect)(WIP)(QC)… |  <- milestone rail (existing mapping + counts)
|----------------------------------|
| JC-1042 · Ahmed            [WIP] |  <- row 1: ref + customer + pill (above fold)
| Camry · ABC 1234  AED 2,450.00   |
|----------------------------------|  <- fold line (nav/gesture below)
| JC-1043 · Sara          [QC]     |  <- row 2 PEEKING
+----------------------------------+
| (owner nav / gesture bar)         |
```
(Wide ≥ expanded: same + sticky table header + 360 preview pane with Open — deviation C.)

## Matrix requirements
- empty (no cards: table empty message, no create-CTA) ·
- with-data (3 cards: WIP/QC/Ready, tabular totals incl. `AED 0.00`) ·
- filter (rail narrows; counts update; no-match + clear) ·
- sort (column tap re-orders, provider list untouched) ·
- wide select + Open → audit (2 taps) ·
- ar (RTL mirrored; ref/plate/money LTR-locked) + dark (no regression) ·
- 1.3x (chips/rows/pill-block wrap — never clip) ·
- 320px (single column; bar + field + rail + first row intact) ·
- tablets (medium: single column rows; expanded/large: sticky table + preview pane).
- 1.3x (chips/rows/pill-block wrap — never clip) ·
- 320px (single column; bar + field + rail + first row intact) ·
- tablets (medium: single column rows; expanded/large: sticky table + preview pane).

## Copy keys needed
Reuse existing owner keys (`ownerReg*`, `ownerJs*`, `filterBarClear`, `commonRetry`, shared
`commonNoResults`/`commonErrorTitle` if the table-owned states need them — table internals untouched so
expected zero) — zero new keys expected (phase-9 list: none). No ALL CAPS strings added.

## Acceptance
- U0–U14 walk (ANY U-law fail caps at 8/16); C16 hard-reject checklist (ANY violation caps at 10/16):
  single search affordance (audited), borderless-feel rows, one filled accent per pane (Open only),
  one path per task, no permanent pills, no ALL CAPS, first row above fold + next peeking, card/row
  hierarchy (title → pill → meta), taps never regress.
- Airbnb rubric ≥ 12/16 to pass.
- Gates: characterization tests on the CURRENT register first, before-images captured (light + dark),
  migration table (current → shared atoms), reviewer process per redesign mandate, NO logic changes.
- Verify from code: tap counts, `_openJob` route, `_applyFilters` predicate, `_sorted` + milestone
  mapping, `formatAed2` byte-exactness, key names, app bar + nav intact.
