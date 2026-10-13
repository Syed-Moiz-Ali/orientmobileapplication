# PHASE 06 — Staff: Advisor Home & Jobs

## A. Phase identity

- **Phase number:** 06
- **Title:** Advisor Home & Jobs (workspace shell, Today, Jobs, Reports, job detail, advisor sheets)
- **Objective:** Redesign the advisor's daily workspace on the new design system: home shell + Today dashboard, Jobs list, Reports, job detail hub, and all advisor sheets/dialogs — preserving every provider, route, offline behavior and action contract.
- **Priority:** High (proving ground for the staff app branch)
- **Dependencies:** Phases 01–05
- **Estimated scope:** Large

## B. Repository context

Files (relative to `apps/staff_app/`):

- Pages: `lib/features/advisor/presentation/pages/advisor_home_view.dart`
  (shell + `_AdvisorDashboardContent` + inline `_AdvisorHeader`, `_AdvisorSearchPill`,
  `_AdvisorQuickActionsMatrix`, `_AdvisorShiftMetricsRow`, `_AdvisorDataNotice`),
  `advisor_jobs_view.dart` (search + status filter chips + `AdvisorJobCardRow`),
  `advisor_reports_view.dart` (range switch, fl_chart bar/pie, share/export),
  `advisor_job_detail_view.dart` (route `/advisor/job-detail`, extra `JobCardEntity`,
  loads remote details + inspection + Hive intake, action bar → pushes
  `/repair-order`, `RepairOrderView`, `AdvisorAssignTasksView`, `VehicleDeliveryView`).
- Sheets/dialogs/widgets: `widgets/advisor_search_sheet.dart`,
  `advisor_notification_sheet.dart`, `advisor_profile_sheet.dart`,
  `advisor_stat_dialog.dart`, `advisor_contact_sheet.dart`,
  `advisor_approval_sheet.dart`, and kit: `advisor_job_card_row.dart`,
  `advisor_approval_row.dart`, `advisor_notification_row.dart`,
  `advisor_meta_pill.dart`, `advisor_status_badge.dart`, `advisor_date_chip.dart`,
  `advisor_detail_line.dart`, `advisor_sheet.dart` (sheet base),
  `advisor_divider.dart`, `advisor_menu_item.dart`, `advisor_contact_option.dart`,
  `advisor_see_all_button.dart`, `advisor_solid_action.dart`,
  `advisor_outline_action.dart`.
- Shell/nav: `DashboardShell` + `AppAdaptiveNavigationFrame`; tabs Today / Jobs /
  Reports; rail footer = Advisor Profile; notifications via `AdvisorNotificationSheet`;
  no FAB.
- Providers: `features/advisor/presentation/providers/advisor_providers.dart`
  (`advisorRefreshProvider`, job cards list/detail, approvals, notifications,
  search); Hive-backed caches; `recoverUnsyncedAdvisorIntakes()` at startup.
- Routes: `/advisor_home_view`, `/advisor/job-detail` (extra `JobCardEntity`),
  plus pushes into 07/08 screens (not restyled here).
- Tests: `test/advisor_experience_test.dart`, `vehicle_customer_intake_layout_test.dart`
  (07), goldens under `test/goldens/` (several advisor screens).

## C. Design objectives

1. **Today = command surface, not a card pile.** Order: shift header (greeting,
   branch/shift context, one-line freshness) → attention block (pending
   approvals, reminders via `AdvisorApprovalSheet`/contact) → shift metric tiles
   (tap → `AdvisorStatDialog` detail) → recent job cards (tap → detail) → quick
   actions matrix kept but normalized to an icon-tile grid with 1 eyebrow title.
2. **Jobs = the working list.** Search first, filter chips (All/In Progress/
   Completed/Pending/QC Check/Cancelled) with counts where availability is free,
   records as `AppRecordRow`-family cards: plate/customer title, vehicle line,
   status pill, time metadata, next-action hint. Pull-to-refresh; skeleton first
   load; empty vs no-match distinct.
3. **Reports = evidence, not decoration.** Range control as segmented
   (Today/Week/Month), one hero metric strip, two charts (bar + distribution)
   with chart-theme labels, share/export preserved; numbers tabular.
4. **Job detail = workspace hub.** Identity header (plate, customer, status,
   vehicle) + primary action (start next step contextually) + sections: work
   items/tasks, inspection summary, estimate summary, history; actions callable:
   call/WhatsApp customer (`AdvisorContactSheet`), start inspection, open
   estimate, assign tasks, delivery — same navigation targets as today.
   Remove silent-catch dead ends: every failed load shows error + retry.
5. **Sheets unified.** All advisor sheets move to the `showAppModalSheet`
   grammar (drag handle, title, scroll, sticky confirm) with RTL support; menu
   sheet (`AdvisorProfileSheet`) uses `AppRecordRow` rows; contact sheet offers
   call/WhatsApp/SMS + mark-done with the same callbacks.
6. **Offline truth.** Jobs list/detail surface cached-data notices
   (saved-data notice) and queued intake states honestly; no fake freshness.

## D. Screens and workflows

| Screen | Purpose | New hierarchy | Key interactions | States | Permissions |
|---|---|---|---|---|---|
| `AdvisorHomeView` (shell + Today) | Shift execution cockpit | Shift header → attention → metrics → recent jobs → quick actions | open job detail; open stat dialog; approval sheet; contact sheet; search; notifications; profile menu; retry | skeleton (first load), cached-data notice, error+retry, empty (no jobs) | advisor route allow-list; actions carry existing callbacks |
| `AdvisorJobsListView` (tab) | Find/open job cards | toolbar (search + chips) → list → paged load | search, filter, open detail, refresh | skeleton, empty, no-match, error | as today |
| `AdvisorReportsView` (tab) | Personal analytics | range segmented → hero metric strip → bar chart → distribution | range switch, share/export, retry | loading bar, error+retry, empty chart | as today |
| `AdvisorJobDetailView` | Job workspace | identity header → primary action → work items → inspection → estimate → history | call/WhatsApp, start inspection (`/inspection-sheet`), open estimate (`/repair-order`), assign tasks, open delivery, back | loading, error+retry, per-section empty, offline notice | `JobCardEntity` extra contract; fallback to home on bad extra |
| `AdvisorStatDialog` | Metric detail | value → breakdown rows → "view jobs" (wired to jobs tab with filter where the provider supports it; otherwise keep as display-only and document) | close, optional navigate | — | — |
| `AdvisorSearchSheet` | Global find | search field → grouped results (jobs/approvals/customers) → scan shortcut | type, open result, scan | empty vs no-match | Hive search unchanged |
| `AdvisorNotificationSheet` | Inbox | header + clear-all → rows | open row, clear | explicit empty; no silent failure | shared with technician (10) |
| `AdvisorProfileSheet` | Account menu | identity row → menu items (profile/attendance/logout) | navigate, logout confirm | — | logout dialog preserved |
| `AdvisorApprovalSheet` | Estimate approval | record summary → approve/send-back actions | approve, send back | busy state on actions | callbacks preserved |
| `AdvisorContactSheet` | Reach customer | customer identity → call/WhatsApp/SMS/mark done | invoke platform actions | — | url_launcher permissions unchanged |

## E. Responsive specifications

- **Compact:** single column; shell bottom nav (3 destinations); Today sections
  stack; job cards full-width; search as field in toolbar; sheets as bottom
  sheets. 320 px: filter chips wrap to two rows max then scroll horizontally
  (chips are horizontally scrollable, a deliberate exception); no other overflow.
- **Medium:** rail navigation; Today becomes 2-column (attention | metrics +
  recent); jobs list uses card rows with 2-up grid ≥720 px where cards allow.
- **Expanded/large:** content capped (`contentStandard`); job detail uses
  `AppSplitView` (left: work items/history; right: identity + actions + estimate
  summary); reports charts side-by-side (max 2).
- Keyboard: report/share menus reachable; job list focus traversal.
- Short viewport: Today header collapses gracefully.

## F. Localization and RTL

- All strings from `staff_app` ARB (EN+AR) — tab names, chips, statuses via
  localized `AppStatusLabels`, notices, sheet copy, dialog copy; remove literals.
- `advisor_*` widgets convert to `EdgeInsetsDirectional`; directional icons flip
  (date chips, chevrons, back).
- Numbers/dates: job times, plate/VIN stay Latin identifier style; counts and
  currency localized.
- Tests: run `advisor_experience_test.dart` in `ar`; add RTL assertions for nav
  mirroring + sheet alignment + chips order; 320 px EN/AR no-overflow.

## G. Design system integration

- Replace local constructions with: `AppPageFrame`, `AppTopBar`/workspace
  app-bar pattern, `AppSearchField`, filter chip styling from theme,
  `AppRecordRow`-family card, `StatusPill` + `AppStatusLabels`, `AppSkeleton`,
  `EmptyState` (+no-match variant), `ErrorView`, `AppButton` system,
  `AppInfoPanel` for notices, `showAppModalSheet` + `AppConfirmationDialog`,
  `AppKpiCard` for metric tiles, `AppStepProgress` only if a wizard appears
  in-scope (none here).
- Keep `AdvisorWorkflowIndicator` (used by 07/08) untouched this phase.
- No new tokens/components expected; if a gap appears, follow README §8.

## H. Technical implementation

- Modify: the listed page/widget files; `staff_app` ARB files; update
  `test/advisor_experience_test.dart` + advisor goldens (intentional).
- Preserve provider APIs exactly (`advisor_providers.dart` untouched unless a
  UI-only selector is needed as an addition); Hive keys untouched.
- Navigation contracts: `/advisor/job-detail` extra `JobCardEntity` fallback
  behavior kept; pushes to 07/08 routes kept (targets redesigned later).
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Every existing callback/action still works: approvals, contact actions,
  notifications clear, search results, report sharing, job navigation, stat
  dialog, profile logout (with pending-sync warning).
- Offline behavior: cached job data still displays with notice; sync triggers
  unchanged.
- Technician shared `AdvisorNotificationSheet` must keep working (technician
  phase 10 restyles its usage; do not break the import path).
- Existing tests: update only copy/layout expectations; logic tests untouched.

## J. Testing requirements

- `melos run analyze:staff`; `melos run test:staff`.
- Extend `advisor_experience_test.dart`:
  - Today renders metrics/attention/recent from fake providers; tap flows to
    job detail;
  - jobs search/filter/empty/no-match;
  - reports range switch + chart render + share callback;
  - job detail loads sections, error+retry path, offline notice;
  - sheets open/close; approval callbacks; contact callbacks;
  - EN + AR runs, RTL assertions, 320/390/768/1280 no-overflow, 1.3× scale.
- Regenerate advisor goldens; add AR goldens for Today + job detail.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the staff app as an advisor and visually review
   Today, Jobs, Reports, job detail and every advisor sheet; no screen may be
   signed off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px) for each redesigned screen.
3. **Locales** — EN-LTR and AR-RTL renders for each screen; reviewed for
   mirroring (chips, sheets, stat tiles) and Arabic typography.
4. **State matrix** — loading (skeleton), empty, no-match (jobs filter),
   populated with realistic job-card fixtures (UAE plates, AED money, plausible
   names), error/retry, cached-data notice. No invented placeholder content.
5. **Interaction verification** — search, filter chips, stat dialog, approval
   sheet, contact sheet, notification clear, job navigation, report share.
6. **Accessibility** — 1.0–1.3× scale clean, tabular money readable, semantics
   on rows, contrast sampled on status pills.
7. **No visual overflow** at 320 px in either locale (filter chips scroll
   intentionally; nothing else overflows).
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_06/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. All screens in section D redesigned with shared primitives; zero raw hex/
   magic radius in touched files (search-verifiable).
2. EN/AR complete for every string in scope; RTL correct; 320 px clean.
3. All existing advisor tests pass (updated only for intentional copy/layout);
   new tests cover states above.
4. Actions/route contracts unchanged; offline notices truthful.
5. `melos run analyze:staff` + `test:staff` green; goldens intentional.

## L. Deliverables

- File-by-file change summary; ARB key counts; golden diffs explained.
- Test evidence; known limitations (e.g. any stat-dialog drill-down that the
  provider cannot yet support — documented, not faked).

## M. Completion gate

Stop after this phase. Do not begin Phase 07A until explicitly instructed.
