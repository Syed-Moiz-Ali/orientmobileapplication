# CRM tasks list test migration (list family recomposition)

Branch: `ui/list-crm`. Tasks list recomposed presentation-only:
toggle/CRUD, `_dueStateOf` derivation, team source, refresh and Keys
untouched. Characterization tests were written against the CURRENT list
FIRST (6 testWidgets, GREEN before touching UI) and migrated after the
rebuild (11 testWidgets, all structural). WAVE-2 fixes (F6 header)
migrated the same file to **12 testWidgets**, all structural. Counts
never down (6 -> 11 -> 12). Ruling (a) shell relocation keeps the same
file at **12 testWidgets** (assertions updated verbatim below, none
added/removed) + **8 new shell relocation tests** in
`apps/crm_app/test/crm_shell_search_relocation_test.dart` (all
structural). Counts never down (6 -> 11 -> 12 -> 12 + 8 shell).

## Inventory (existing CRM tests before this change)

- `apps/crm_app/test/baseline_capture_test.dart` (tagged `baseline`,
  excluded from suite).
- Old tasks-list assertion count: **0**. New characterization count
  before touching UI: **6 testWidgets** in
  `apps/crm_app/test/crm_tasks_list_characterization_test.dart`
  (all structural, GREEN). Counts did not go down (0 -> 6).
- After recomposition: **11 testWidgets** in the same file (all
structural). Before-captures (5 PNGs) in
  `docs/ui-redesign/baseline/before-crm-lists/` were generated with
  `--update-goldens` and compared back-to-back GREEN before the rebuild
  (idle-2, empty, dark, ar, 320px).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| header | count `Container` + 32px refresh `GestureDetector` + filled Add pill; no search (U1 violation) | `AppPageHeader` (title `navTasks` + `tkCountN` subtitle) + search icon ONLY when > 5 + refresh `AppIconButton` + `TextButton.icon` Add; `RefreshIndicator` kept | structural |
| header same-row (WAVE-2 F6) | `AppPageHeader` stacked all actions below the title on compact (read as a body toolbar row) | plain responsive Row: compact row 1 = title + search same-row, row 2 = end-aligned refresh + Add; wide (≥ 600) single row; RTL-mirrored; same >5 condition, sheet, target | structural |
| cards | white `Container` (border AND shadow) + 24px circle `GestureDetector` + bare meta `Text`s + priority pill + 30px edit/delete `GestureDetector`s | borderless `AppSurfaceCard(outlined: false)` + 48px toggle hit area (24px visual, same `taskToggle_<id>` keys) + `Flexible` meta (ellipsis, never clips) + `AppStatusChip` due/priority pills + 48dp `AppIconButton` edit/delete with tooltips | structural |
| toggle | 24px target flips `isDone` | same `toggleTask` handler, 48dp target; cards stay 2 | structural |
| edit | `showModalBottomSheet` white/radius-24 form | `showAppModalSheet` (titled) + `AppInputField`s + `AppDropdown` assignee + `AppChip` priority group + `AppPillButton` save with `busyLabel`; same validation (`tkTitleRequired`) + same `Unassigned → ''` mapping | structural |
| delete | raw `AlertDialog` (Cancel/Delete) | `AppDialog` destructive (same `tkDeleteTitle`/`tkDeleteBody(title)` + `onPrimary` pops true, fixed after a failing test) → same `deleteTask`; NO undo; card removed, empty state follows | structural |
| assignee errors | bespoke red `Container` / spinner row | team loading → disabled `AppInputField` hint; team error → `AppBanner` error (`tkTeamFail` verbatim) | structural |
| search | (did not exist — scroll only) | icon ONLY when > 5 → sheet over loaded tasks (title/assignee substring, result reveals card, no-match + Clear); scroll path unchanged | structural |
| empty | bespoke 80px circle + `ElevatedButton.icon` | `AppEmptyState` (1 icon + 1 sentence + 1 Add action → same form) | structural |
| unparseable due | no badge | no badge (verbatim derivation kept) | structural |
| priority chip label | stored English name verbatim on the card (`High` Latin in ar) | localized display mapping via existing `tkHigh/Medium/Low` keys (same mapping as the form sheet; unknown server labels stay verbatim); kinds by name unchanged | structural |
| dark + 1.3x + 320px | (not covered) | pumps clean incl. `Flexible` meta fix for a 6px Row overflow caught by the suite | structural |

## Behavior kept verbatim (presentation only — no logic changes)

- `CrmTaskNotifier` (`tasks`, `toggleTask`, `add/update/deleteTask`,
  `refresh`), `_dueStateOf` (parseable-only, never guessed), team source
  (`teamMembersProvider`: loading/error/data), `Unassigned → ''`
  mapping (incl. the literal `'Unassigned'` comparison), pull-to-refresh,
  keys, snackbar contracts.
- Priority labels render the stored English names verbatim (same family
  as the server-label note in the migration map); kinds by name
  (High→error, Medium→warning, else neutral) with sentence-case display.
- Due badges only from `_dueStateOf` (`tkOverdue`/`tkDueToday`
  localized, unchanged).
- Routes (existing destinations only): form sheet (add/edit), delete
  confirm. No new routes. No invented tasks.
- Copy: all `tk*` keys reused; `chromeRefresh` reused for the refresh
  tooltip (same `refresh()` handler it labels in the shell).

## Deviations / notes (presentation-only, filed here)

- `showAppDialog` pops null by default — both delete confirms pass an
  explicit `onPrimary` popping `true` (found by the failing leads
  test, fixed in production, not the test).
- `tkCount` (`{count} Tasks`, "1 Tasks" bug) is NOT fixed in place —
  the new ICU key `tkCountN` (`=0/=1/other`, en+ar) carries the header;
  the old key stays untouched (no renames).
- No skeleton branch: `CrmTaskState.isLoading` is never set true by the
  notifier (`refresh()` doesn't touch it) — a skeleton on
  `isLoading && empty` would be dead code. Filed as a logic candidate
  in the session return (LOGIC_FOLLOWUPS.md is owner-edited).
- No error branch on the list: no list-level error signal exists in the
  task providers. The team-dropdown error maps to `AppBanner`
  (verbatim copy); form validation maps to `AppInputField.error`.
- Test fakes copy-on-read (`List.of`, same rationale as the leads file).
- The `Flexible` meta fix: bare `Text` in a `Row(mainAxisSize.min)`
never ellipsizes — the suite caught a 6px overflow the old 30px
targets had masked.
- Adversarial round (tasks defects 5-partial): the card priority chip now
renders the localized display label through the existing
`tkHigh/Medium/Low` keys (same mapping as the form sheet; unknown
server labels stay verbatim). No new ARB keys; en pixels unchanged
(`High`), ar pill reads `عالية` via the pre-existing translation.

## Tap table (AFTER ≤ BEFORE — no regression; EXACT counts)

| Task | Before (EXACT) | After (EXACT) |
|---|---|---|
| Open list | 1 tap (tab) | ≤ 1 tap (unchanged) |
| Complete / reopen | 2 taps + scroll (tab + 24px circle) | ≤ 1 from list, ≤ 2 from launch (48dp toggle, same handler) |
| Add task (reach form) | 2 taps (tab + Add pill) | ≤ 2 taps (header/empty-state Add, same sheet) |
| Edit task | 2 taps + scroll (tab + 30px icon) | ≤ 2 taps, ≤ same scroll (48dp icon, same sheet) |
| Delete task | 2 taps + 1 confirm (tab + 30px icon + dialog Delete) | ≤ 2 taps + 1 confirm (48dp icon + `AppDialog` naming the task; NO undo) |
| Find task | scroll only (no search) | scroll unchanged + ≤ 2 taps via new header search (> 5 only; U1 compliance, additive) |

## New ARB keys (en+ar, `flutter gen-l10n` from `apps/crm_app`)

`tasksSearchTitle`, `tasksSearchHint`, `tasksSearchNoMatch`, `tkCountN`
(ICU `=0/=1/other`, header only — old `tkCount` kept), `leadsFilterClear`
reused for the tasks no-match Clear (one Clear key for both sheets).
Reused verbatim: `navTasks`, `tkAdd/Empty/EmptyBody`, `tkDeleteTitle/
tkDeleteBody/tkCancel/tkDelete`, `tkForm*`, `tkHigh/Medium/Low`,
`tkLoadingTeam/tkTeamFail/tkSelectAssignee`, `tkSaving/tkSaveChanges/
tkTitleRequired`, `tkUnassigned/tkNoDue/tkOverdue/tkDueToday/tkMarkDone/
tkReopen`, `chromeRefresh`. No ALL CAPS strings added.

WAVE-2 notes (presentation only — no logic changes):

- F6 header: `crm_tasks_page.dart` header block no longer uses
  `AppPageHeader` — same responsive split as the leads list (compact row
  1 = title + search same-row, row 2 = end-aligned refresh + Add; wide
  single row; RTL-mirrored). Evidence:
  `tasks_idle-6_light_1.0_en_360x800.png` (search top-right row 1;
  refresh + `+ Add Task` end-aligned row 2); ≤ 5 frames keep title +
  refresh/Add with no search (sanctioned exception honored).
- F9 shell guard is leads-tab-scoped (`selectedIndex == 1`): the shell
  palette stays visible on the tasks tab, where it jump-targets leads
  (selectTab(1) + dossier) — a different task from the tasks list sheet,
  so no same-target duplicate exists here (round-2 "C16 PASS single find
  path" stands).
- F10 verification (no code change): ar pill reads `عالية` on both
  cards (`tasks_idle-2_light_1.0_ar_360x800.png`), mirrored layout
  intact.
- WAVE-2 ARB delta on this surface: **zero new keys**. Counts never down
  (6 -> 11 -> 12; +1 same-row header test).

Fixture diversification (test-data only, no production change):

- AFTER-capture fixtures (`crm_after_tasks_capture_test.dart` `_task(i)`
  only) diversified from identical `Task N` / `High` / empty-due x6 to
  realistic varied titles (`Call back buyer`, `Prepare payment plan`,
  `Follow up site visit`, `Send contract draft`, `Schedule valuation
  visit`, `Confirm token deposit`), mixed priorities (High/Medium/Low x2
  each, colors red/amber/green to match), mixed assignees
  (Sara/unassigned/John/Mia) and some ISO due dates (`2026-10-24/25/26`,
  EN `2026-10-xx` style matching the leads `followUpDate` fixtures; 3
  dated + 3 `No due date`). IDs (`t0..t5`) and counts (2 / 6) unchanged.
- Pinned values stable: header/count/search-threshold, toggle/edit/delete
  keys, `tk*` copy, characterization assertions (`Task N`, `High`) and
  counts (6 -> 11 -> 12) untouched — diversification is AFTER-capture
  only, so no pin change and no count change.
- Recaptured `after-crm-tasks/` (8 PNGs) with `--update-goldens` limited
  to the after-capture file, compared back-to-back GREEN.

## Ruling (a) search relocation (presentation/flow-wiring only)

- Shell (`crm_dashboard_view.dart` `_CrmChrome`): the AppBar search
  trigger is the SINGLE visible icon on the tasks tab — contextual,
  opening the EXISTING `showCrmTasksSearchSheet` (same widget, same
  `crmTaskProvider.tasks` list), gated by the same `tasks.length > 5`
  condition relocated from the list header. ≤ 5 → no trigger. Non-list
  tabs keep the palette untouched; Ctrl+K untouched.
- List (`crm_tasks_page.dart`): header search icon REMOVED with its
  `findAids()` block (refresh + Add stay where they are);
  `crm_tasks_search_sheet.dart` import removed (row keys stay). No
  logic/data/predicate change.
- Changed assertions (same 12 testWidgets, verbatim): same-row test now
  pins title-only row 1 + refresh/Add + no search; `>5` test pins no
  header search + the same sheet opened directly (identical no-match +
  Clear pins).
- Tap table (AFTER ≤ BEFORE): Open ≤ 1; Complete ≤ 1 from list;
  Add/Edit/Delete ≤ 2 (+1 confirm, NO undo); Find = scroll unchanged +
  ≤ 2 via shell search (> 5 only); all handlers/keys unchanged.
- Frames recaptured in the living dir `after-crm-tasks/` (8 PNGs) with
  `--update-goldens` limited to `crm_after_tasks_capture_test.dart`
  (search-open now opens the same sheet directly), compared back-to-back
  GREEN. RTL mirror, 320/1.3x clean.
- STOPs: scroll-reveal needs the page scroll anchors (page-owned
  presentation state) and no dossier route exists on this list — the
  shell `onSelect` only re-selects the tab (existing route, no-op when
  already there); manual scroll is unchanged (taps still ≤ 2, no
  regression). Replicating the anchors in the shell would be logic;
  filed, not changed.
- R1 gate check (ui/fix-rulings, no change needed): the shell tasks gate
  already reads the SAME source the page renders —
  `ref.watch(crmTaskProvider).tasks.length` vs page
  `ref.watch(crmTaskProvider).tasks` (`crm_tasks_page.dart:72`); sheet
  reads `ref.read(crmTaskProvider).tasks` (same provider list). No
  defect, no edit. Counts never down (6 -> 11 -> 12 -> 12 + 8 shell).
