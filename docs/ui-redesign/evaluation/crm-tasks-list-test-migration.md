# CRM tasks list test migration (list family recomposition)

Branch: `ui/list-crm`. Tasks list recomposed presentation-only:
toggle/CRUD, `_dueStateOf` derivation, team source, refresh and Keys
untouched. Characterization tests were written against the CURRENT list
FIRST (6 testWidgets, GREEN before touching UI) and migrated after the
rebuild (10 testWidgets, all structural). Counts never down (6 -> 10).

## Inventory (existing CRM tests before this change)

- `apps/crm_app/test/baseline_capture_test.dart` (tagged `baseline`,
  excluded from suite).
- Old tasks-list assertion count: **0**. New characterization count
  before touching UI: **6 testWidgets** in
  `apps/crm_app/test/crm_tasks_list_characterization_test.dart`
  (all structural, GREEN). Counts did not go down (0 -> 6).
- After recomposition: **10 testWidgets** in the same file (all
  structural). Before-captures (5 PNGs) in
  `docs/ui-redesign/baseline/before-crm-lists/` were generated with
  `--update-goldens` and compared back-to-back GREEN before the rebuild
  (idle-2, empty, dark, ar, 320px).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| header | count `Container` + 32px refresh `GestureDetector` + filled Add pill; no search (U1 violation) | `AppPageHeader` (title `navTasks` + `tkCountN` subtitle) + search icon ONLY when > 5 + refresh `AppIconButton` + `TextButton.icon` Add; `RefreshIndicator` kept | structural |
| cards | white `Container` (border AND shadow) + 24px circle `GestureDetector` + bare meta `Text`s + priority pill + 30px edit/delete `GestureDetector`s | borderless `AppSurfaceCard(outlined: false)` + 48px toggle hit area (24px visual, same `taskToggle_<id>` keys) + `Flexible` meta (ellipsis, never clips) + `AppStatusChip` due/priority pills + 48dp `AppIconButton` edit/delete with tooltips | structural |
| toggle | 24px target flips `isDone` | same `toggleTask` handler, 48dp target; cards stay 2 | structural |
| edit | `showModalBottomSheet` white/radius-24 form | `showAppModalSheet` (titled) + `AppInputField`s + `AppDropdown` assignee + `AppChip` priority group + `AppPillButton` save with `busyLabel`; same validation (`tkTitleRequired`) + same `Unassigned → ''` mapping | structural |
| delete | raw `AlertDialog` (Cancel/Delete) | `AppDialog` destructive (same `tkDeleteTitle`/`tkDeleteBody(title)` + `onPrimary` pops true, fixed after a failing test) → same `deleteTask`; NO undo; card removed, empty state follows | structural |
| assignee errors | bespoke red `Container` / spinner row | team loading → disabled `AppInputField` hint; team error → `AppBanner` error (`tkTeamFail` verbatim) | structural |
| search | (did not exist — scroll only) | icon ONLY when > 5 → sheet over loaded tasks (title/assignee substring, result reveals card, no-match + Clear); scroll path unchanged | structural |
| empty | bespoke 80px circle + `ElevatedButton.icon` | `AppEmptyState` (1 icon + 1 sentence + 1 Add action → same form) | structural |
| unparseable due | no badge | no badge (verbatim derivation kept) | structural |
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
