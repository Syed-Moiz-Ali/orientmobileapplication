# PHASE 10 — Staff: Technician Workspace

## A. Phase identity

- **Phase number:** 10
- **Title:** Technician Workspace (shell, Today, Jobs, Productivity, job execution, parts request, escalation)
- **Objective:** Redesign the technician's shop-floor app into a focused, glove-friendly execution workspace with honest offline/sync states and a job view that makes the next action obvious — preserving shift punch, task lifecycle, and all provider contracts.
- **Priority:** High
- **Dependencies:** Phases 01–09
- **Estimated scope:** Large

## B. Repository context

Files (relative to `apps/staff_app/`):

- Shell: `lib/features/technician/presentation/technician_dashboard_view.dart` —
  `DashboardShell` + `AppAdaptiveNavigationFrame` + `AppBottomNavigation`,
  4 tabs (Today / Jobs / Productivity / Profile), `TechnicianAppBar` (branch +
  attendance subtitle, notifications via shared `AdvisorNotificationSheet`,
  avatar → profile sheet).
- Tabs: `widgets/technician_today_view.dart` (`_ShiftControl`,
  `_ActiveJobCard`, `_QuickActions`, `_ShiftSummary`, `AppSplitView`,
  `_TodaySkeleton` (`AppSkeleton`), `_FirstLoadError`, `_ConnectionNotice`,
  `TechnicianEmptyState` variants), `widgets/technician_jobs_view.dart`
  (`_JobsToolbar`, `_JobFilterChip`, `TechnicianJobSummary`; saved-data notice,
  no-match vs empty), `widgets/technician_productivity_view.dart`
  (`_SummaryColumn`, `_BreakdownRow`, `_ShiftColumn`, `AppSplitView`, skeleton,
  offline notice, error retry).
- Job execution: `widgets/job_detail_sheet.dart` — full-screen route
  `/technician/job-detail` (extra `TechnicianJobEntity`, fallback → dashboard);
  `_JobIdentity`, `_ExecutionArea`, `_TaskList/_TaskRow`, `_ContextColumn`,
  wide 2-col `LayoutBuilder`; actions: start/hold/complete task, complete repair
  (confirm), request part, escalate; `_busy` double-tap guard; delayed/QC/
  completed states.
- Sheets: `widgets/parts_request_sheet.dart` (part name/number, qty stepper,
  urgency, notes; keyboard-inset handling; max-width 560; `_isLoading`, form
  validation, inline retryable error), `widgets/escalation_sheet.dart`
  (5 issue types, description; same conventions).
- Kit: `widgets/technician_components.dart` (`TechnicianSectionHeader`,
  `TechnicianStatusPill`, `TechnicianTaskProgress`, `TechnicianJobSummary`,
  `TechnicianJobContext`, `TechnicianEmptyState`).
- Providers: `features/technician/presentation/providers/technician_providers.dart`
  (`technicianDashboardProvider` with refresh; invalidated on logout in
  `main.dart`) — preserve.
- Attendance: shift punch logic lives in technician views + `core` attendance
  services (shared with attendance screen in Phase 11 — do not change logic).
- Tests: `technician_experience_test.dart`, `technician_today_test.dart`,
  `technician_jobs_test.dart`, `technician_job_detail_test.dart`,
  `technician_productivity_test.dart`, `technician_profile_test.dart`,
  `technician_support_flows_test.dart`; goldens for today/jobs/job
  detail/productivity/profile/escalation/parts request.

## C. Design objectives

1. **Today = execute now.** Above the fold: shift control (punch in/break/out
   with elapsed time, state made obvious) + active job card with the single
   next action ("Start task", "Mark task done", "Complete repair"). Quick
   actions (request part, escalate) available without leaving Today. Shift
   summary (hours, tasks done) below. No dense KPI walls.
2. **Jobs = my queue.** Search + status filter chips + cards (plate/customer,
   work summary, progress pill, promised time). Saved-data notice when offline;
   distinct empty vs no-match; refresh in place.
3. **Job execution = checklist done right.** Task list as large tap targets with
   clear state morphing (todo → in progress → done, hold state visible),
   progress bar per job, task notes if the model supports; context column
   (vehicle, customer, description, media/attachments if present); primary
   "Complete repair" only when checklist rules allow (existing logic), with
   confirmation; parts/escalation as sheets from persistent actions.
4. **Productivity = personal evidence.** Summary counts + shift timeline +
   breakdown rows; period/summary follow existing provider data; offline notice
   when cached.
5. **Parts request:** form restyle (part name/number, qty stepper, urgency
   segmented, notes), validation, keyboard-safe, busy state inside button,
   inline retry on failure — same submission.
6. **Escalation:** issue-type radio cards (5), description, submit — same
   submission, same validation.
7. **Resilience is visible:** offline/queued completion uses a clear "saved,
   will sync" pattern (whatever the sync engine already does — reflect it,
   don't invent), failed actions offer retry with the exact error reason.
8. **Kit consolidation:** `technician_components.dart` retained only if its
   widgets match shared grammar; otherwise replace with shared components and
   delete (confirm references incl. tests).
9. **Advisor notification sheet dependency:** shared sheet from Phase 06 —
   keep working unchanged here.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `TechnicianDashboardView` + `TechnicianAppBar` | shell + tabs + tab-aware app bar | tab switch, notifications, profile | — |
| `TechnicianTodayView` | shift control → active job → quick actions → summary | punch, start/complete task, complete repair, request part, escalate, refresh | skeleton, first-load error + retry, connection notice, empty variants |
| `TechnicianJobsView` | toolbar → chips → list | search, filter, open job, clear, refresh | skeleton, saved-data notice, empty, no-match, error |
| `TechnicianProductivityView` | summary column + shift column | refresh | skeleton, offline notice, error, empty |
| `JobDetailSheet` (route `/technician/job-detail`) | identity → task checklist → context column | task lifecycle actions, complete repair (confirm), parts, escalate, back | busy guard, delayed/QC/completed variants, error |
| `PartsRequestSheet` | form fields → submit | qty stepper, urgency, send, retry | validation, loading, inline error |
| `EscalationSheet` | type options → description → submit | select, send | validation, loading, error |

## E. Responsive specifications

- **Compact:** single column; shift control spans full width; task rows ≥56 px
  tall; sheets full-height with keyboard insets; quick actions as 2-up tiles.
- **Medium:** Today uses existing `AppSplitView` (active job | shift details);
  job detail two columns (checklist | context); productivity two columns.
- **Expanded/large:** job detail capped `contentStandard`; context column
  becomes a right panel; list surfaces get denser rows (48 px) with columns
  where data allows.
- 320 px: stepper and chips fit; no clipped urgency labels; sheets scroll.
- 1.3× scale: task rows expand cleanly.

## F. Localization and RTL

- All technician strings localized (`technician*` namespaces) EN+AR: shift
  actions, task states, urgency levels, escalation types, empty copy, notices.
- RTL: progress bars mirror direction start→end; stepper +/- mirror; task
  checkmarks align end; time formatting localized; plate/VIN identifiers stay
  Latin.
- Tests: technician suites run in `ar`; RTL assertions for task rows and
  sheets; 320 px clean.

## G. Design system integration

- Use: `AppSkeleton` (replace `_TodaySkeleton` custom), `EmptyState` (+no-match),
  `ErrorView`, `AppSearchField`, filter chip styling, `AppRecordRow`-family job
  cards, `StatusPill`+localized statuses, `AppButton`, `AppActionBar` (sheet
  submits), `showAppModalSheet`, `AppConfirmationDialog` (complete repair),
  quantity stepper (parts), `SegmentedButton` (urgency), `AppInfoPanel`
  (connection notices), `AppLinearProgress` (job progress).
- Migration of `technician_components.dart`: replace `TechnicianStatusPill` →
  `StatusPill`, `TechnicianSectionHeader` → `SectionHeader`, keep only
  job-specific components that genuinely encode domain (job summary/context,
  task progress) — documented.
- No new tokens expected.

## H. Technical implementation

- Modify: technician view/widget files; ARB; tests + goldens.
- Preserve: `technician_providers.dart` APIs (refresh, dashboard provider),
  task lifecycle methods, attendance punch calls, `_busy` double-tap guard
  behavior, confirm-dialog rules before complete repair.
- Keep `/technician/job-detail` extra contract + fallback.
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Shift punch in/break/out states and persistence unchanged.
- Task start/hold/complete + repair completion payloads unchanged.
- Parts request + escalation submissions unchanged.
- Offline behavior: cached job display and queue semantics unchanged.
- Technician tabs order unchanged (Today / Jobs / Productivity / Profile).
- All existing technician tests pass (copy/layout updates only); golden updates
  intentional and re-verified.

## J. Testing requirements

- `melos run analyze:staff`; `melos run test:staff`.
- Update/extend all technician test files for: new structure, EN+AR, RTL,
  320/390/768/1280, 1.3×, offline notice paths, task lifecycle actions with
  confirmations, parts/escalation validation + inline retry.
- Goldens: regenerate for redesigned surfaces; add AR goldens for Today +
  job detail.
- Run `technician_profile_test.dart` to ensure the Profile tab (Phase 11 surface)
  still mounts.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the technician workspace and visually review
   Today, Jobs, Productivity, job execution and both sheets; no screen may be
   signed off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px).
3. **Locales** — EN-LTR and AR-RTL renders; task rows, steppers and progress
   mirroring reviewed specifically.
4. **State matrix** — shift states (not punched / in / break / out), task
   lifecycle states (todo / in-progress / done / held), delayed/QC/completed job
   variants, offline "saved, will sync" notice, parts/escalation validation and
   inline retry. Fixtures use realistic job/task data.
5. **Interaction verification** — punch confirmations, task actions with
   confirmation rules, complete-repair confirm, parts/escalation submission,
   search/filters, double-tap guard.
6. **Accessibility** — glove-friendly ≥56 px task targets, 1.0–1.3× scale
   clean, semantics on task rows, contrast sampled on state colors.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_10/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D surfaces redesigned on shared primitives; kit consolidation
   documented; states covered.
2. Lifecycle/punch/submission behaviors unchanged (tests).
3. EN/AR complete; RTL correct; responsive per E.
4. `melos run analyze:staff` + `test:staff` green; goldens intentional.

## L. Deliverables

- File changes; ARB counts; kit consolidation summary; golden diffs; test
  evidence; known limitations.

## M. Completion gate

Stop after this phase. Do not begin Phase 11 until explicitly instructed.
