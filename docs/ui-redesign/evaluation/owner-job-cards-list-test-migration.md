# Owner job-cards register test migration (GROUP-C list-ops, screen 5)

Branch: `ui/list-ops`. Register recomposed presentation-only onto App*
pattern widgets: providers, filter predicate, presentation sort, selection
and open contracts, table/row atoms, copy semantics, app bar + nav untouched;
no new routes, no new ARB keys. Owner dark verified with before/after dark
frames (no regression).

## Inventory (characterization baseline, STEP 0)

- `apps/owner_app/test/owner_job_cards_list_characterization_test.dart` (new,
  9 testWidgets): behavior pins written for the CURRENT register with a fake
  `JobCardRepository` (`_FakeJobCardRepository` returning growable copies; a
  stub `GoRouter` serves the audit route so the compact-tap and wide
  select-then-Open pins exercise the real `selectedJobCardProvider` + `push`
  contract). Run GREEN before the rebuild (7/9 + 2 fixes → 9/9) and GREEN
  after (9/9). Frozen after STEP 0 — same 9 tests, same assertion shapes,
  counts 9 -> 9.
- Copy finders: pill/money/findings use `text`/`findsWidgets` where the UI
  renders plain `Text` pre and post (`jobStatusPill` labels are byte-identical
  UPPERCASE via the shared helper — pinned quirk, see below); empty/no-match/
  prompt strings use `textContaining` (the recomposed `AppEmptyState`
  bidi-isolates title/message, invisible).
- Pinned quirk (logic, untouched): pills render `.toUpperCase()` labels
  (`IN PROGRESS`, `QUALITY CHECK`, `COMPLETED`) from `job_status_ui.dart`,
  which is shared with the detail view (2 call sites in
  `job_card_detail_view.dart`). Changing it would restyle an out-of-scope
  surface — STOP boundary, kept byte-identical. C16 bans ADDED caps; none
  added here.
- Pinned rail behavior: the six-chip milestone rail scrolls horizontally — the
  `QC` chip needs one drag into view before tapping (test harness only;
  production behavior identical). Filter re-tap clears (rail keeps scroll
  offset).
- Before pixels (frozen record, never regenerated):
  `docs/ui-redesign/baseline/before-owner-job-cards/` — `idle` (light+dark en
  360x800, ar 360x800, en 320x568, en 1.3x 360x800, wide 1280x800 light),
  `empty`, `loading`. No error frame exists: the provider load has no error
  branch (pinned, untouched). Produced by
  `apps/owner_app/test/owner_job_cards_list_before_capture_test.dart` (tagged
  `baseline`, excluded from the default run; overflow-drain per the owner home
  precedent — none fired).
- After pixels (review only, same matrix):
  `docs/ui-redesign/baseline/after-owner-job-cards/` via
  `apps/owner_app/test/owner_job_cards_list_after_capture_test.dart`.

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| header shows title, subtitle and live count, no header search | `WorkspaceAppBar` + count `StatusPill.neutral` + inline `AppSearchField` | Same bar (deviation A: chrome owned by workspace) + `AppStatusChip` neutral (same `ownerRegCount` label); still zero header search icons at any size (deviation B: audited single affordance) | structural (rendering-identical) |
| compact rows render identity, tabular money and status | `AppTable` + `AppRecordRow` + `jobStatusPill` + `formatAed2` | verbatim (deviations C/D: STOP boundaries — table/row atoms + detail-shared helper kept) | behavioral (unchanged) |
| inline search narrows by customer, plate and job ref | `AppSearchField` → `onSearch` + `_applyFilters` | verbatim | behavioral (unchanged) |
| milestone rail filters and re-tap clears | `AppFilterBar` + `_statusFor` mapping + `setFilter` | verbatim | behavioral (unchanged) |
| compact row tap opens the job audit | `_openJob` + `push(jobCardDetail)` | verbatim (stub route) | behavioral (unchanged) |
| wide row select previews then opens the audit | `_PreviewPane` (`AppCard.standard` + `PrimaryButton` Open) | `AppSurfaceCard` + `AppPillButton.primary` (same body/label/handler); prompt `EmptyState` → `AppEmptyState` (title reuses `ownerRegTitle`, message verbatim, no action); select + Open → same audit | structural (rendering-identical) |
| empty register shows the empty state | Table-owned `emptyMessage` | verbatim (table internals untouched) | behavioral (unchanged) |
| no match shows the no-match state and clears | Table-owned `noMatchMessage` + field clear | verbatim | behavioral (unchanged) |
| sort header re-orders without mutating the provider list | `_sorted` presentation copy | verbatim | behavioral (unchanged) |

## Behavior assertions (verbatim, unchanged)

- Tap counts (brief BEFORE, verified from code): open register = drill
  (**1 tap**); find = type (**0-tap focus + keystrokes**) and/or chip
  (**1 tap**) and/or sort (**1 tap**); open audit compact = row tap
  (**1 tap**), wide = select + Open (**2 taps**); clear = Clear/re-tap
  (**1 tap**). AFTER: identical (same seats, same sheet/pane, ≤ same scroll).
- Provider reads identical: `jobCardsProvider` (`all`/`filtered`/`searchQuery`/
  `activeFilter`/`isLoading`, `onSearch`/`setFilter`) + `selectedJobCardProvider`
  untouched.
- Search predicate identical (id/customer/vehicle/plate contains) +
  milestone mapping (`_labelFor`/`_statusFor`: Intake→vehicleReceived …→
  Invoiced→delivered) + presentation-only `_sorted` (provider list never
  mutated) untouched.
- `formatAed2` byte-exact (`AED 2,450.00`, zero as `AED 0.00`), LTR locks on
  ref/plate/vehicleDisplay/money, unshrinkable pill block at 320px/1.3x kept.
- No-header-search STOP honored (deviation B); no `AppPageHeader` swap
  (deviation A); table kept on wide (deviation C); shared atoms/helpers kept
  (deviation D). App bar + nav untouched.
- Copy keys: zero new (reused `ownerReg*`, `ownerJs*`; prompt title reuses
  `ownerRegTitle`). Phase-9 list: none.

## WIDGET_MIGRATION_MAP delta (this screen)

- `StatusPill.neutral(` (bar count, 1 site) → `AppStatusChip` neutral (same
  `ownerRegCount` label). No remaining `StatusPill` in
  `job_cards_list_view.dart`.
- `AppCard.standard(` (preview prompt + dossier-mini, 2 sites) →
  `AppSurfaceCard` (same padding/body; border-XOR-shadow; dark keeps border).
- `EmptyState(` (select prompt, 1 site) → `AppEmptyState` (title reuses
  existing `ownerRegTitle`, message `ownerRegSelectPrompt` verbatim, no
  action).
- `PrimaryButton(` (preview Open, 1 site) → `AppPillButton.primary` (same
  label/handler).
- KEPT (STOP/pinned, not legacy): `WorkspaceAppBar` + back + shortcut,
  `AppSearchField`, `AppFilterBar` + milestone mapping, `AppTable` +
  columns/cells/sort/sticky + `compactBuilder` + `AppRecordRow` + pill-block
  fix, `jobStatusPill` (incl. existing `.toUpperCase()` — shared with detail),
  `formatAed2`, providers/sort/selection/open/routes/keys (detail view +
  shared atoms untouched).
