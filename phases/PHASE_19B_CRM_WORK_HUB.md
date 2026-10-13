# PHASE 19B — CRM: Work Hub (Conversations, Tasks, Sales Team)

## A. Phase identity

- **Phase number:** 19B (part 2 of 3; split from the former Phase 19)
- **Title:** CRM Work Hub — Conversations inbox, Tasks with form sheet, Sales Team directory
- **Objective:** Redesign the CRM's daily work surfaces onto the unified system, resolve the conversations row-affordance ambiguity, and complete the token migration for these tab files.
- **Priority:** Medium-High
- **Dependencies:** Phase 19A (shell/tokens proven)
- **Estimated scope:** Medium-Large

## B. Repository context

Files (relative to `apps/crm_app/`):

- `lib/features/crm_dashboard/presentation/widgets/crm_conversations_page.dart`:
  `AppRecordRow` + channel `StatusPill` rows; unread emphasis; **no row tap
  handler today** — resolve this phase.
- `crm_tasks_page.dart`: task list with count, add/edit/delete, toggle done,
  private `_TaskFormSheet`, `_TaskCard`.
- `crm_sales_team_page.dart`: member cards (avatar, role, revenue, lead stats,
  win rate).
- Providers: `crm_task_provider.dart`, `crm_team_provider.dart`,
  `crm_ui_provider.dart` (tab index) — preserve APIs.
- Palette: these files still consume `crm_constants.dart` from before 19A —
  migrate all of them here to tokens; the constants file remains until 19C only
  if any consumer remains (report exact remaining references).
- Tests: CRM suite established in 19A — extend it here.

## C. Design objectives

1. **Conversations = scannable inbox.** Rows: channel icon, contact name,
   snippet (2 lines), relative time, unread emphasis, channel status pill.
   **Row-affordance decision (mandatory):** if the data layer exposes a
   conversation detail/thread destination, wire the tap; otherwise render rows
   static (no chevron, no hover cue) and document the decision. No ambiguous
   affordances survive this phase.
2. **Tasks = lightweight task manager.** Header with open count → grouped list
   (overdue / today / upcoming / done if data allows) → rows with toggle (≥48
   px), due date, priority if present; add/edit `_TaskFormSheet` restyled with
   the form grammar + local validation (title required); delete confirm; toggle
   with immediate feedback and revert-on-failure if the provider returns errors.
3. **Sales team = performance directory.** Member cards: avatar, name, role,
   revenue (tabular AED), lead stats, win-rate indicator (bar or percent — one
   visual language); responsive grid; empty and error states.
4. **Token migration completed** for the three files (zero `crm_constants`
   references remain in them).
5. **Localization:** all strings in these surfaces localized EN+AR.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `CrmConversationsPage` | list (rows) | per documented decision (open thread or static) | empty, error, no-match if search added (only if provider supports) |
| `CrmTasksPage` (+ form sheet) | header + groups → rows | add, edit, toggle, delete (confirm) | empty, error, busy, validation |
| `CrmSalesTeamPage` | summary → cards grid | — (display only, as today) | empty, error |

Tab contracts unchanged (tab indices 2/3/4 in `crmUiProvider`).

## E. Responsive specifications

- **Compact:** rows full width; tasks grouped list; team cards stacked; form
  sheet full-height with keyboard insets.
- **Medium:** team 2-up grid; conversations capped readable width.
- **Expanded/large:** team 3-up; conversations in a capped column (~720 px
  centered — inboxes read best narrow, documented); tasks as dense rows.
- 320 px: no overflow; relative times ellipsize safely.
- RTL: rows mirror; unread dots/times move to the end side; team cards mirror.

## F. Localization and RTL

- All strings localized (`crmConversations*`, `crmTasks*`, `crmTeam*`) EN+AR;
  relative times via ICU; money tabular AED; roles localized.
- RTL: mirroring per above; delete/toggle confirmations mirror.
- Tests: CRM suite extended in EN+AR; RTL row assertions; 320 px clean.

## G. Design system integration

- Use: `AppPageFrame`, `AppRecordRow`, `StatusPill`, `AppCard`, `AppButton`,
  `AppSearchField` (only where a search exists today or the provider supports
  one — do not invent), `AppTextField`/`AppDropdownButton` (task form),
  `showAppModalSheet`, `AppConfirmationDialog`, `AppSkeleton`, `EmptyState`,
  `ErrorView`, `UserAvatar`, `AppLinearProgress`/percent indicator (win rate).
- No new tokens; `crm_constants.dart` untouched (deleted in 19C).

## H. Technical implementation

- Modify: the three tab files; CRM ARB; extend widget tests.
- Preserve: task CRUD + toggle methods, team provider reads, conversation data
  mapping; tab index contracts.
- Conversations decision documented (wire vs static) with rationale; if
  wiring, call only existing repository methods.
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Task add/edit/delete/toggle flows unchanged (payloads, confirmations).
- Team stats display unchanged (same fields).
- Conversations rows show the same data; only the affordance decision changes.
- Tab switching + badge from 19A unaffected.

## J. Testing requirements

- `melos run analyze:crm`; `melos run test:crm`.
- Extend widget tests: conversations decision behavior + empties; task CRUD +
  toggle + confirm + validation; team cards from fakes + empty/error; EN+AR;
  RTL; 320/390/768/1280; 1.3×.
- Goldens: conversations, tasks, team (EN compact + expanded); AR golden for
  conversations.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the CRM app and visually review conversations,
   tasks (incl. form sheet) and sales team; no surface may be signed off from
   code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px).
3. **Locales** — EN-LTR and AR-RTL renders for all three surfaces.
4. **State matrix** — conversations empty/unread emphasis/status pills; tasks
   empty/grouped/overdue/toggle states/validation; team empty/populated/error.
   Realistic CRM fixtures.
5. **Interaction verification** — conversation rows behave per documented
   decision; task add/edit/toggle/delete; relative time accuracy; no dead
   affordances.
6. **Accessibility** — 1.0–1.3× scale clean; ≥48 px toggles; semantics on rows
   and toggles; contrast sampled on unread emphasis.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_19B/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Three surfaces redesigned on the unified system; zero `crm_constants`
   references remain in touched files.
2. Task/team/conversation data behaviors unchanged (tests).
3. Conversations affordance decision documented and implemented.
4. EN/AR complete; RTL correct; responsive per E.
5. `melos run analyze:crm` + `test:crm` green; J2 evidence attached.

## L. Deliverables

- File changes; ARB counts; conversations decision note; remaining
  `crm_constants` reference list for 19C; test evidence; goldens.

## M. Completion gate

Stop after this phase. 19C (reports/integrations/settings + palette deletion)
follows. Do not begin until explicitly instructed.
