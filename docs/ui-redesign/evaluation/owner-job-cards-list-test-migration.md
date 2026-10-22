# Owner job-cards register test migration (GROUP-C list-ops, screen 5)

Branch: `ui/list-ops`. Register recomposed presentation-only onto App*
pattern widgets, then adversarial-fixed (D1–D7, 2026-10-22): providers,
filter predicate, presentation sort, selection and open contracts, table
cells, copy semantics, app bar + nav untouched; no new routes, zero new ARB
keys (existing `ownerRegCount` → ICU plural, `ownerRegOpen` relabeled —
same keys, new values). Owner dark verified with before/after dark frames
(no regression).

## Inventory (characterization baseline, STEP 0)

- `apps/owner_app/test/owner_job_cards_list_characterization_test.dart` (9
  testWidgets): behavior pins written for the CURRENT register with a fake
  `JobCardRepository` (`_FakeJobCardRepository` returning growable copies; a
  stub `GoRouter` serves the audit route so the compact-tap and wide
  select-then-Open pins exercise the real `selectedJobCardProvider` + `push`
  contract). GREEN before the adversarial fixes (8/9 + 1 no-match scoping
  fix → 9/9) and GREEN after (9/9). Counts never down (9 -> 9).
- Adversarial round (D1–D7): header search-sheet (same predicate), wrap rail,
  plural count, borderless reordered rows/cards, relabeled Open CTA.
  Changed assertions are all structural (rendering-identical seats,
  display-case/copy only); predicates, sort, selection, open, routes and keys
  unchanged (see table).
- Copy finders: pill/money/findings use `text`/`findsWidgets` where the UI
  renders plain `Text` pre and post (`jobStatusPill` labels are sentence-case
  verbatim from the shared helper — UPPERCASE quirk fixed display-side, see
  below); empty/no-match/ prompt strings use `textContaining` (the recomposed
  `AppEmptyState`
  bidi-isolates title/message, invisible).
- UPPERCASE fix (display-side only, shared helper): pills rendered
  `.toUpperCase()` labels (`IN PROGRESS`, `QUALITY CHECK`, `COMPLETED`) from
  `job_status_ui.dart`, shared with the detail view (2 call sites in
  `job_card_detail_view.dart`). Fixed at the helper by dropping
  `.toUpperCase()` — same `jobStatusLabel` keys, same statuses, same
  tones; ARB verbatim (`In progress`, `Quality check`, `Completed` en;
  Arabic unchanged). No logic/status/color change. C16 now clean (zero caps
  ADDED or kept on this surface).
- Pinned rail behavior: the milestone rail WRAPS on compact/medium (U5
  word-boundary fix, `AppFilterBar.wrap`) — no scroll drag in the harness or
  production; wide keeps the scroll rail. Filter re-tap clears (unchanged).
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
| header shows title, subtitle and live count, header search | `WorkspaceAppBar` + count `StatusPill.neutral` + inline `AppSearchField`; zero header search icons (audited single affordance) | Same bar (deviation A: chrome owned by workspace) + `AppStatusChip` neutral (same `ownerRegCount` label, now ICU plural `0/1/many`); header search icon opens the register filter as a full sheet over the same predicate; zero inline fields in the page at any size (D1 fix) | structural (rendering-identical) |
| compact rows render identity, tabular money and status | `AppRecordRow` (identifier chip `JC-1042` first) + `jobStatusPill` + `formatAed2` | Register-owned `_RegisterJobCard` (`AppSurfaceCard(outlined: false)` — borderless light/shadow, dark keeps border): customer/vehicle title → status pill → meta, `JC-1042` small mono meta LAST (D2+D3 fix); wide columns reordered Customer/Plate/Job(small mono)/Total/Status with matching sort mapping | structural (rendering-identical) |
| sheet search narrows by customer, plate and job ref | `AppSearchField` → `onSearch` + `_applyFilters` | Header icon → `job_cards_search_sheet.dart` (`showJobCardsSearchSheet`, `AppSearchField` writing straight through `notifier.onSearch`, results = live `filtered`, tap reuses `_openJob`); sheet + page both render the predicate (pinned); `1 job` singular via ICU plural (D1+D7 fix) | structural (same target/predicate) |
| milestone rail filters and re-tap clears | `AppFilterBar` + `_statusFor` mapping + `setFilter` (scroll rail, harness drag) | verbatim handlers; rail wraps on compact/medium (`AppFilterBar.wrap`, Clear flows inline — D5 fix); direct chip tap, no drag | behavioral (unchanged) |
| compact row tap opens the job audit | `_openJob` + `push(jobCardDetail)` | verbatim (stub route; tap lands on the borderless card) | behavioral (unchanged) |
| wide row select previews then opens the audit | `_PreviewPane` (`AppCard.standard` + `PrimaryButton` Open) | `AppSurfaceCard(outlined: false)` + `AppPillButton.primary` (dossier reordered: customer → pill → vehicle·plate → total → ref LAST); CTA relabeled `Open job` (was `Open register` — audit destination, D7 fix); prompt `AppEmptyState` (title reuses `ownerRegTitle`, message verbatim, no action); select + Open → same audit | structural (rendering-identical) |
| empty register shows the empty state | Table-owned `emptyMessage` | verbatim message; compact renders `AppTableEmpty` frameless (no outer wrapper frame — D2 fix) | structural (rendering-identical) |
| no match shows the no-match state and clears | Table-owned `noMatchMessage` + field clear | verbatim message; 1-tap Clear in the sheet + compact clear action (same `onSearch('')` + `setFilter(null)` handlers composed — D1 fix keeps clear at 1 tap) | structural (same handlers) |
| sort header re-orders without mutating the provider list | `_sorted` presentation copy (Job/Plate/Customer/Total order) | verbatim contract; column order is now Customer/Plate/Job/Total with the comparator mapping following the columns (provider list never mutated) | behavioral (unchanged) |

## Behavior assertions (verbatim, unchanged)

- Tap counts (AFTER, verified from code): open register = drill
  (**1 tap**); find = header icon (**1 tap**) + keystrokes and/or chip
  (**1 tap**) and/or sort (**1 tap**); open audit compact = result/row tap
  (**1 tap**), wide = select + Open (**2 taps**); clear = sheet Clear / rail
  Clear / compact clear (**1 tap**). AFTER ≤ BEFORE on every task (find
  stays ≤1 + keystrokes; the removed inline field cost 0-tap focus, the
  header icon costs the budgeted 1).
- Provider reads identical: `jobCardsProvider` (`all`/`filtered`/`searchQuery`/
  `activeFilter`/`isLoading`, `onSearch`/`setFilter`) + `selectedJobCardProvider`
  untouched.
- Search predicate identical (id/customer/vehicle/plate contains, now written
  by the sheet straight through `onSearch`) + milestone mapping
  (`_labelFor`/`_statusFor`: Intake→vehicleReceived …→ Invoiced→delivered) +
  presentation-only `_sorted` (column order Customer/Plate/Job/Total; provider
  list never mutated) untouched.
- `formatAed2` byte-exact fixed cents (`AED 2,450.00`, zero as `AED 0.00`),
  Latin `AED` in BOTH locales (ar `د.إ` dropped — bidi-corruption fix; same
  family as LOGIC #9 server-codes-stay-Latin), LTR locks on ref/plate/
  vehicleDisplay/money, tabular figures kept. Pill labels sentence-case
  verbatim (`In progress`, `Quality check`, `Completed` en; Arabic unchanged)
  — same statuses/tones, display-case only.
- Header search-sheet replaces the inline field (brief deviation B retired by
  adversarial D1); no `AppPageHeader` swap (deviation A stands); table kept
  on wide (deviation C stands, columns reordered presentation-only);
  `jobStatusPill` + `formatAed2` kept (shared with detail); `AppTable` kept
  on wide only; compact no longer nests cards in the table frame
  (borderless register-owned rows — deviation D extended, atoms untouched).
  App bar + nav untouched.
- Copy keys: zero NEW (reused `ownerReg*`, `ownerJs*`, shared
  `filterBarClear`/`commonClearSearch`; prompt title reuses `ownerRegTitle`).
  Changed VALUES, same keys: `ownerRegCount` → ICU plural
  (`=0{0 jobs} =1{1 job} other{{count} jobs}}` en; `=0{0 وظائف}
  =1{وظيفة واحدة} other{{count} وظائف}}` ar — `vhCount` precedent);
  `ownerRegOpen` `Open register` → `Open job` (en) / `فتح العمل` (ar —
  the CTA opens the job audit, not the register). Phase-9 list: none.

## WIDGET_MIGRATION_MAP delta (this screen)

- `StatusPill.neutral(` (bar count, 1 site) → `AppStatusChip` neutral (same
  `ownerRegCount` label — now ICU plural 0/1/many, en+ar). No remaining `StatusPill` in
  `job_cards_list_view.dart`.
- `AppCard.standard(` (preview prompt + dossier-mini, 2 sites) →
  `AppSurfaceCard(outlined: false, ...)` (same padding/body; borderless light
  shadow, dark keeps border). Compact rows: `AppRecordRow`-in-`AppTable`
  (card-in-card + wrapper frame) → register-owned `_RegisterJobCard`
  (`AppSurfaceCard(outlined: false)`, title → pill → meta, ref small LAST).
- `EmptyState(` (select prompt, 1 site) → `AppEmptyState` (title reuses
  existing `ownerRegTitle`, message `ownerRegSelectPrompt` verbatim, no
  action).
- `PrimaryButton(` (preview Open, 1 site) → `AppPillButton.primary` (label
  `ownerRegOpen`, now `Open job` — same key, audit-accurate value).
- Inline `AppSearchField` (page, 1 site) + `_searchCtrl`/`_searchFocus` →
  header `WorkspaceAppBar.onSearch` + `WorkspaceSearchShortcuts` opening
  `job_cards_search_sheet.dart` (`showJobCardsSearchSheet`: `AppSearchField`
  writing straight through `notifier.onSearch`, results = live `filtered`,
  tap reuses `_openJob`). Same predicate, same keys, zero inline fields.
- `AppFilterBar` (rail, 1 site) → same atom with `wrap: true` on
  compact/medium (new opt-in `wrap` flag + `IntrinsicWidth` shrink-wrap fix in
  `packages/shared_core`; scroll rail default unchanged, zero effect on other
  surfaces).
- `formatAed2` (shared with detail) → Latin `AED` both locales (ar `د.إ`
  dropped — bidi-corruption fix, LOGIC #9 precedent); LTR locks + tabular kept.
- `ownerRegCount` (ARB, same key) → ICU plural (en/ar, `vhCount` precedent);
  `ownerRegOpen` (ARB, same key) → `Open job` / `فتح العمل`; `flutter gen-l10n`
  from `apps/owner_app` clean, signatures unchanged.
- KEPT (STOP/pinned, not legacy): `WorkspaceAppBar` + back + shortcut
  (deviation A); `AppFilterBar` + milestone mapping + counts; `AppTable` on
  wide only (columns reordered Customer/Plate/Job/Total, small-mono ref; sort
  mapping follows columns — deviation C); `jobStatusPill` (shared with
  detail), providers/sort/selection/open/routes/keys (detail view +
  shared atoms otherwise untouched).
