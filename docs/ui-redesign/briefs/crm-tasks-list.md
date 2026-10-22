# UX Brief — CRM tasks list (list family)

## Scope
`apps/crm_app` tasks list surface: `widgets/crm_tasks_page.dart`
(header + list + empty + `_TaskCard` + `_TaskFormSheet` + delete confirm)
+ `providers/crm_task_provider.dart` (`tasks`, `toggleTask`, `add/update/
deleteTask`, `refresh` — unchanged) + `providers/crm_team_provider.dart`
(assignee source — unchanged). Routes touched only as existing
destinations: `_TaskFormSheet` (add/edit bottom sheet, restyled) +
delete confirm (restyled). No new routes. No logic changes (toggle,
CRUD, due-badge derivation, refresh stay as-is).

## User goal
A salesperson opens Tasks and in one glance sees what needs doing (title
+ assignee + due), and completes or edits it without hunting. One
screen, one primary task: see task → complete/edit.

## Current behavior (verified from code)
- Entry: `CrmDashboardView` `IndexedStack` index 4 (`navTasks`). No badge
  on this destination. No header search anywhere on this surface.
- Header row: count pill (`tkCount(n)`, `Container` + border) + `Spacer` +
  32px refresh `GestureDetector` (`notifier.refresh()`) + `Add Task` pill
  (`GestureDetector` + `Container`, `CrmColors.primary`) → `_showTaskForm`
  (`showModalBottomSheet`, white, radius 24 top).
- List: `RefreshIndicator` + `ListView.separated` of `_TaskCard`
  (white `Container`, 14px padding, radius 14, 1px border — overdue gets
  red-tinted border — + soft shadow; BOTH border and shadow today).
  Row: 24px circle toggle (`taskToggle_<id>`, check when done) + title
  (strike when done) + assignee/due `Wrap` + overdue/today badges +
  priority pill + 30px edit (`edit_outlined`) + 30px delete
  (`delete_outline_rounded`).
- Due badges: `_dueStateOf` (ISO-parseable due dates only; unparseable =
  no badge, never guessed): overdue (`tkOverdue`, red) / today
  (`tkDueToday`, amber). Done tasks show no badge.
- Form sheet (`_TaskFormSheet`): title/assignee/due fields + priority
  single-select + team dropdown (`teamMembersProvider`: loading/error/
  data) + validation (`tkTitleRequired`) + save (`addTask`/`updateTask`,
  `Unassigned` → `''` mapping kept). Delete: `showDialog` `AlertDialog`
  (`tkDeleteTitle`/`tkDeleteBody(title)` + Cancel/Delete) → `deleteTask`.
- States: empty = bespoke 80px circle + `tkEmpty`/`tkEmptyBody` +
  `ElevatedButton.icon` Add; no skeleton, no `AppErrorState`, no offline
  banner on this surface. Loading = `isLoading` flag exists but the page
  renders the list/empty directly (no skeleton branch).
- Truth rules (from code comments): due badges derive from parseable due
  dates only; no snooze endpoint so none offered (documented, not
  improvised).

## Top tasks with tap counts (BEFORE = current UI, AFTER must be ≤)
1. Open the tasks list — before: nav Tasks tab = **1 tap**. After: ≤ 1.
2. Complete / reopen a task — before: tab (1) + circle toggle (1) =
   **2 taps** (+ scroll). After: toggle stays DIRECTLY on each card:
   **≤ 1 tap from the list, ≤ 2 from launch**. No regression.
3. Add a task — before: tab (1) + Add pill (1) = **2 taps**, then the
   existing form sheet. After: ≤ 2 taps (header Add when non-empty,
   empty-state CTA when empty — never both at once).
4. Edit a task — before: tab (1) + edit icon (1) = **2 taps** (+ scroll).
   After: ≤ 2 taps. Edit stays a card action (existing sheet route).
5. Delete a task — before: tab (1) + delete icon (1) + dialog Delete (1
   confirm) = **2 taps + 1 confirm**. After: ≤ 2 taps + 1 confirm
   (AppDialog destructive, same `deleteTask`; NO undo — undo would be
   logic).
6. Find a task (NEW find-aid) — before: scroll only (no search; U1
   violation). After: header search icon (when > 5) + result tap =
   **≤ 2 taps**; scroll path unchanged (no regression — search is
   additive for U1 compliance).

| Task | Before | After budget |
|---|---|---|
| Open list | 1 tap | ≤ 1 tap |
| Complete / reopen | 2 taps (+scroll) | ≤ 1 from list, ≤ 2 from launch |
| Add task (reach form) | 2 taps | ≤ 2 taps (header / empty-state) |
| Edit task | 2 taps (+scroll) | ≤ 2 taps, ≤ same scroll |
| Delete task | 2 taps + 1 confirm | ≤ 2 taps + 1 confirm (AppDialog, no undo) |
| Find task | scroll only (no search) | ≤ 2 taps via new header search (> 5 only); scroll unchanged |

Frequent tasks (complete, add) stay single-screen; add/edit is the only
sheet flow and is out of scope for restructuring.

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: **does not exist**.
- `AIRBNB_PATTERNS.md`: **missing anywhere in the repo** (only mention
  records its own absence).
- Mapping is therefore **unmet**; this brief proceeds from phase-5/6/7
  precedent (supervisor-floor, technician-today, owner-home,
  vehicles-list): `AppPageHeader` + header search icon (U1, > 5 only)
  opening a full-screen search sheet over loaded items; borderless light
  cards; `AppStatusChip` pills; sheets; empty/loading/error states.

## U-laws application (U0–U14, C17)
- U0: one card = title → assignee/due meta → ONE due/priority signal. No
  competing heroes. CARD HIERARCHY (binding): title = task title (the
  thing the user recognizes); status = ONE pill row (due badge when the
  existing `_dueStateOf` yields one + priority pill, both verbatim —
  never invented); meta = assignee + due date. Borderless in light.
- U1: header search icon top-right (same placement as every list) opens a
  list-scoped search sheet over loaded tasks (title/assignee substring).
  PROGRESSIVE-DISCLOSURE EXCEPTION (ONE sanctioned U1 exception): icon
  appears ONLY when loaded tasks > 5; ≤ 5 shows cards only. The current
  zero-search state is the U1 violation this fixes.
- U2: first task card above the fold at 360x800 idle with data, second
  peeking; anything pushing it below needs a written reason.
- U3: budgets above are ceilings; most frequent (toggle) ≤ 2 from
  launch, ≤ 1 from list.
- U4: complete/reopen reachable without scrolling past one screen where
  possible; Add reachable from header (non-empty) / empty-state (empty)
  + sticky-safe at 320px.
- U5: no truncation of titles (wrap ≤ 2, never mid-word cut); meta wraps;
  30px edit/delete targets grow to 48dp (current 30px violates U14 —
  fixed here, presentation-only larger hit areas, same handlers).
- U6: calm empty (`AppEmptyState`: 1 icon + 1 sentence + 1 Add action →
  same form); loading skeleton mirrors cards (`AppShimmerSkeleton`);
  error (`AppErrorState` + Try again, same `refresh`); stale kept with
  `AppBanner`; pull-to-refresh kept.
- U7: one path per task (Add header XOR empty-state; never both at once).
- U8: overdue/done ordering kept verbatim (no silent re-sort — feed
  order is logic; if completed ever sorts above open, log in
  LOGIC_FOLLOWUPS.md per U8 instead of filtering).
- U9: same atoms/placements as the leads list rebuilt on this branch.
- U10: every destructive action confirms (`AppDialog` naming the task)
  or offers undo — undo would be logic, so confirm is the path; errors
  say what to do next.
- U11: zero shown as `0`, never `-`; counts from `tasks.length` only.
- U12: one background (current white card on `scaffold` is kept as
  surface-on-background; no stray bands).
- U13: plain labels (`Add task`, `Mark done` — new-employee clear).
- U14: 48dp targets (fixes the 30px/32px violations), AA pairs, Semantics
  on toggle (kept), 320px + 1.3x without clipping.
- C17: any U-law fail caps at 8/16. C16: borderless light cards, ONE
  filled accent per section, no orphan tiles (N/A — list, not tiles), no
  permanent pills (count lives in the header subtitle, not a floating
  pill), no ALL CAPS, search = one top icon → sheet, card hierarchy as
  bound above, no carousel (N/A — list stays a list).

## Search-icon pattern (list-scoped, no new routes/logic)
- `AppPageHeader` (title `navTasks` + count subtitle `tkCount`) with
  search icon top-right (U1) — SHOWN ONLY WHEN loaded tasks > 5.
- Opens a full-screen sheet: field filters loaded tasks by title /
  assignee substring; results are compact rows; result tap closes + reveals
  the card; card actions unchanged. No-match + Clear. No new routes.

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke header row (count `Container` + 32px refresh +
  `Add Task` pill `GestureDetector`s) → `AppPageHeader` (title + count
  subtitle) + search icon (only > 5) + refresh `AppIconButton` + Add
  `AppPillButton`/text action (same `refresh`/`_showTaskForm` handlers).
- REMOVED: bespoke `_TaskCard` chrome (white `Container` + border AND
  shadow, 30px edit/delete targets) → borderless `AppSurfaceCard
  (outlined: false)` rows (shadow light / border dark), 48dp toggle +
  edit/delete `AppIconButton`s, `AppStatusChip` due/priority pills
  (verbatim labels/tones, sentence case), same `taskToggle_<id>` keys.
  FREQUENT ACTION binding: toggle stays DIRECTLY on each card.
- REMOVED: bespoke empty panel → `AppEmptyState` (1 icon + 1 sentence +
  1 Add action → same `_showTaskForm`); loading → `AppShimmerSkeleton`
  mirroring cards; error → `AppErrorState` + Try again (same `refresh`).
- REMOVED: raw `showModalBottomSheet` (white, radius 24) → `showAppModalSheet`
  / `AppBottomSheet` chrome (same fields/validation/save mapping,
  `Unassigned → ''` kept); raw `AlertDialog` → `AppDialog` destructive
  (same title/body naming the task, same `deleteTask` + snackbar
  contracts; NO undo).
- KEPT: `CrmTaskNotifier` (toggle/add/update/delete/refresh), `_dueStateOf`
  derivation (parseable-only, never guessed), team source, `Unassigned`
  mapping, pull-to-refresh, keys, snackbar contracts. No new routes. No
  invented tasks. Current theme wiring unchanged.

## Fold wireframe (ASCII, 360×800 — header + first card above fold)
```
+----------------------------------+
| Tasks                 [🔍][↻][+]|  <- 🔍 only when > 5 items
| 7 tasks                         |
|----------------------------------|
| ( ) Call Ahmed re quote         |  <- title; toggle direct
|     Ahmed · 22 Oct · [High]     |  <- meta + ONE priority pill
|     [Overdue]                   |  <- badge only when derived
|----------------------------------| <- above fold (nav below)
| (✓) Send Zoho docs              |  <- second card PEEKING
+----------------------------------+
|Dashboard|Leads|Chats|Team|Tasks|... |
```

## Matrix requirements
- empty (no tasks: `AppEmptyState` + Add → same sheet; never
  zero-filled) · with-data (toggle direct + edit/delete 48dp) ·
- search (icon ONLY when > 5 → sheet over loaded tasks; ≤ 5 = cards
  only; result reveals card; no-match + Clear; scroll path unchanged) ·
- ar (RTL mirrored; dates/numbers LTR-locked) · 1.3x (wrap, no clip) ·
  320px (header + first card intact) · tablet (single column list, rail).

## Copy keys needed
Reuse existing `tk*` keys (`tkCount/Add/Empty/EmptyBody/Delete*/Form*/High/
Medium/Low/NoDue/Overdue/DueToday/MarkDone/Reopen/Unassigned*`); new keys
only for search-sheet hint/no-match (en+ar, listed for phase 9). No ALL
CAPS strings added.

## Acceptance
- U0–U14 walk (ANY fail caps at 8/16 — the > 5-item search threshold is
  the ONE sanctioned U1 exception); C16 hard-reject (caps 10/16):
  header-icon search (> 5 only), borderless light cards, 48dp targets,
  card hierarchy (title → pill → meta), no ALL CAPS, zero as `0`, first
  card above fold + second peeking, empty = 1 icon + 1 sentence + 1
  action, delete = `AppDialog` destructive naming the task (no undo), no
  dead affordances, taps never regress.
- Airbnb rubric ≥ 12/16. Gates: characterization FIRST, before-images,
  migration table, reviewer per mandate, NO logic changes.
