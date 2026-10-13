# PHASE 09 — Staff: Supervisor Workspace

## A. Phase identity

- **Phase number:** 09
- **Title:** Supervisor Workspace (shell, Today, Assign, Queue, Review, Staff, Schedule, Reports, Jobs, QC sign-off, notifications)
- **Objective:** Redesign the supervisor's operations cockpit — the shop-floor control room — into a clear, queue-driven workspace with consistent record grammar across its seven surfaces, preserving every provider contract, route, badge behavior and the save-and-assign FAB flow.
- **Priority:** High
- **Dependencies:** Phases 01–08
- **Estimated scope:** Large

## B. Repository context

Files (relative to `apps/staff_app/`):

- Shell: `lib/features/supervisor/presentation/supervisor_dashboard_view.dart`
  (thin wrapper) + `widgets/supervisor_scaffold.dart` — `DashboardShell` +
  `AppAdaptiveNavigationFrame` + `AppBottomNavigation`, 5 tabs (Today / Assign /
  Queue / Review / Profile), queue badge index 2, FAB "Save and assign" on
  Assign tab (`isAssignWorkLoading` drives FAB spinner + snackbar outcome),
  profile rail footer.
- Tabs/pages: `widgets/supervisor_dashboard_tab.dart` (context banner, attention
  area → Queue/Review, workload/distribution, `_ContextualNavigationMatrix` to
  jobs/staff/schedule/reports sub-pages, KPI grid, `SupervisorQueueSkeleton`,
  `_SupervisorErrorNotice`, multiple `EmptyState`s), `supervisor_assign_sheet.dart`
  (search job card, assignment cards, task rows, tech/department pickers,
  `EmptyState`, FAB-driven save), `supervisor_queue_tab.dart` (incoming bookings
  & breakdowns, route-to-advisor bottom sheet, 4 empty states, `_QueueNotice`),
  `supervisor_review_tab.dart` (QC list, `_QcJobCard`, responsive wrap/grid,
  spinner + notice + empty), `supervisor_staff_tab.dart` (technician/department
  cards, wide 2-col, 4 empty states), `supervisor_schedule_tab.dart`
  (appointments list, empty + error notice), `supervisor_reports_tab.dart`
  (report stat cards + category distribution, notice + empty),
  `supervisor_jobs_tab.dart` (metric pills, search, job cards, error + 2 empties).
- Sheets/widgets: `widgets/qc_checklist_sheet.dart` (checklist toggles, notes,
  approve / send-back requiring notes, `_isLoading`, snackbar errors),
  `widgets/staff_notification_bell.dart` (+ `_StaffNotificationsSheet`, 30 s
  polling, badge), `widgets/supervisor_app_bar.dart` (tab-aware titles/subtitles,
  `UserAvatar` → profile sheet).
- Router: `SupervisorSubPageWrapper` in `lib/core/router/app_router.dart` wraps
  `/supervisor/{assign,jobs,queue,review,staff,schedule,reports}`.
- Provider: `features/supervisor/presentation/providers/supervisor_providers.dart`
  (`supervisorDashboardProvider` with refreshQueue/refreshReview/loadNotifications,
  `isAssignWorkLoading`, `isReviewLoading`, etc. — preserve) + data layer.
- Dead: `widgets/supervisor_stat_card.dart`, `supervisor_stats_grid.dart`
  (confirm zero references → delete).
- Tests: `test/supervisor_experience_test.dart`; goldens where present.

## C. Design objectives

1. **Today = attention-first cockpit.** Order: shift/context banner → "Needs
   attention" (queue count, review count as tappable cards with primary
   actions) → workload & distribution (tabs/segments only if data exists) →
   navigation matrix (Jobs / Staff / Schedule / Reports as 4 clean tiles) →
   KPIs. Every attention card taps to its tab.
2. **Assign = one-thumb dispatch.** Search-first, recently assigned context if
   the provider exposes it; assignment card per job with tech + department
   pickers as selection sheets (search + workload hints where real data exists);
   task rows with toggles; visible "Save and assign" state on the shared FAB and
   a sticky confirmation alternative on ≥medium (FAB remains on compact).
3. **Queue = intake triage.** Bookings and breakdowns as grouped `AppRecordRow`
   cards with status pills and time context; primary action routes to advisor
   via the existing bottom sheet; secondary opens booking detail if wired today
   (keep); per-section empty states become a single clear "Queue is clear"
   pattern with per-type sub-states where needed.
4. **Review (QC) = evidence-based verification.** Queue of completed jobs with
   vehicle/customer identity, completion time, worker; tap opens
   `QcChecklistSheet` redesigned: checklist rows (≥48 px targets), notes field,
   approve (primary) / send back (danger + notes required) with in-button busy
   states and error panels; rejected requires notes (behavior kept, now
   visibly enforced).
5. **Staff roster = at-a-glance capacity.** Technician cards (name, role,
   department, state if available) and department cards; verification mark for
   checked-in staff if the data exists (do not invent).
6. **Schedule = today's appointments.** Chronological list with time-block
   grouping, customer/vehicle/service lines, status pills; refresh in place.
7. **Reports = operations summary.** Stat strip → category distribution (bars
   via chart theme) → revenue metrics that exist today; tabular numbers;
   share/export only if already present (none today — do not add backend calls).
8. **Jobs = floor view.** Search + metric pills (counts by status) + job cards;
   assign-from-card keeps its existing route/select behavior.
9. **Notifications:** badge + inbox sheet restyled; polling stays; rows unified
   (`AppRecordRow`), empty state clear.
10. **Sub-page wrapper:** replaced by `AppTopBar`-based pages (with the same
    titles/subtitles localized) so supervisor sub-pages match every other pushed
    page; keep routes identical.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `SupervisorScaffold` | shell + 5 tabs + FAB | tab switch, badge, profile footer, FAB save-and-assign | FAB busy, snackbar outcomes |
| `SupervisorDashboardTab` | context → attention → workload → matrix → KPIs | open queue/review, push sub-pages, refresh | skeleton, error+retry, empty |
| `SupervisorAssignSheet` | search → assignment cards → pickers → task rows | search, pick tech/dept, toggle tasks, save (FAB) | empty, saving, success/error |
| `SupervisorQueueTab` | grouped queue sections | route to advisor (sheet), open booking, refresh | per-section empty, error |
| `SupervisorReviewTab` | QC queue list | open QC sheet, refresh | spinner, error, empty |
| `QcChecklistSheet` | checklist → notes → decision bar | toggle, approve, send back (notes required) | busy, validation, error |
| `SupervisorStaffTab` | roster sections | view cards (actions only if already wired) | empty per section |
| `SupervisorScheduleTab` | appointments list | view, refresh | empty, error |
| `SupervisorReportsTab` | stats → distribution | refresh | empty distribution, error |
| `SupervisorJobsTab` | metrics + search + cards | search, assign, open job | no results, no jobs, error |
| `StaffNotificationBell` | badge + inbox sheet | open, mark read (existing notifier) | empty |
| `SupervisorAppBar` | title/subtitle + actions | notifications, profile | — |
| `SupervisorSubPageWrapper` | replaced by `AppTopBar` pages | back | — |

## E. Responsive specifications

- **Compact:** bottom nav (5 destinations, queue badge), FAB above the bar;
  Today stacks; assign cards single column; queue/review cards full width;
  sheets for pickers/QC.
- **Medium:** rail; Today 2-column (attention | workload+KPIs); matrix 2×2;
  review/queue card grids 2-up; assign uses a two-pane layout (jobs | assignment
  detail) where the data model allows a selected-job state, else cards.
- **Expanded/large:** content capped; Reports stat strip 4-up; review list as
  dense rows with columns (job, vehicle, completed, worker, decision);
  breadcrumbs on sub-pages; FAB replaced by sticky action button in a toolbar
  on Assign (FAB remains a valid pattern on compact/medium — document the
  switch).
- 320 px: metric pills scroll horizontally (intentional); FAB not overlapping
  cards (bottom padding).
- 1.3× scale: tab labels/notification rows clean.

## F. Localization and RTL

- All strings localized (`supervisor*` namespaces) EN+AR incl. tab titles,
  subtitles, empty states, QC decision copy, notification labels.
- RTL: matrix grid order mirrors, list chevrons flip, FAB position mirrors
  automatically, QC checklist checkmarks align end; time/date localized.
- Tests: run supervisor suite in `ar`; RTL assertions for matrix and QC sheet;
  320 px EN/AR no-overflow.

## G. Design system integration

- Use: workspace `AppTopBar` pattern (replacing `SupervisorSubPageWrapper`),
  `AppSearchField`, `AppRecordRow`, `AppKpiCard`, `AppCard` sections,
  `StatusPill` + localized status labels, `AppSkeleton`/existing
  `SupervisorQueueSkeleton`→`AppSkeleton` migration, `EmptyState`, `ErrorView`,
  `AppButton`, `showAppModalSheet`, `AppConfirmationDialog`, `NotificationBell`,
  `UserAvatar`, `AppInfoPanel` for notices, chart-theme bars in Reports.
- Delete: dead supervisor stat widgets after reference check.
- Replace ad-hoc `_SupervisorErrorNotice`/`_QueueNotice`/`_ReviewNotice` with
  `AppInfoPanel`/`ErrorView` per grammar.

## H. Technical implementation

- Modify: files listed in B; update `app_router.dart` only for the wrapper
  replacement (same paths/titles) — routes and redirect logic untouched.
- Preserve: `supervisor_providers.dart` APIs (`refreshQueue`, `refreshReview`,
  `loadNotifications`, loading flags), `qr`/badge indices, FAB gating logic.
- Keep 30 s notification polling behavior.
- No new packages; no API changes.

## I. Functional preservation

- FAB "Save and assign" drives the same method and outcomes.
- Queue routing-to-advisor sheet callbacks unchanged.
- QC reject-requires-notes and approve flows unchanged.
- Notification badge/polling/mark-read unchanged.
- Sub-page routes `/supervisor/*` and their titles/subtitles (now localized)
  unchanged.
- Existing supervisor tests pass (copy/layout updates only).

## J. Testing requirements

- `melos run analyze:staff`; `melos run test:staff`.
- Extend `supervisor_experience_test.dart`: Today attention counts + navigation;
  assign happy/error path via FAB; queue route sheet; QC approve/send-back
  validation; staff/schedule/reports/jobs render + empties; notification sheet;
  EN+AR; RTL; 320/390/768/1280; 1.3×.
- Goldens for supervisor surfaces regenerated; add AR goldens for Today + QC
  sheet.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the supervisor workspace and visually review all
   five tabs + sub-pages + QC sheet + notification inbox; no surface may be
   signed off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px) for each surface.
3. **Locales** — EN-LTR and AR-RTL renders; matrix grid mirroring and QC sheet
   alignment reviewed specifically.
4. **State matrix** — queue/review/staff/schedule/reports empties, populated
   queues with realistic booking/breakdown fixtures, FAB saving, QC decision
   states (approve / send-back-with-notes validation). No invented data.
5. **Interaction verification** — FAB save-and-assign, queue routing sheet,
   QC checklist toggles, notification badge/polling, sub-page navigation and
   back behavior.
6. **Accessibility** — 1.0–1.3× scale clean; ≥48 px QC checklist targets;
   focus order; contrast sampled on attention cards.
7. **No visual overflow** at 320 px in either locale (metric pills scroll
   intentionally).
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_09/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. All section D surfaces on shared primitives; notices unified; dead widgets
   removed with proof.
2. Provider/FAB/badge/QC behaviors preserved; suite green.
3. EN/AR complete, RTL correct, responsive per E.
4. `melos run analyze:staff` + `test:staff` green.

## L. Deliverables

- File changes + deletions; ARB counts; golden diffs; test evidence; known
  limitations (e.g. any card action that remains display-only because no
  callback exists today).

## M. Completion gate

Stop after this phase. Do not begin Phase 10 until explicitly instructed.
