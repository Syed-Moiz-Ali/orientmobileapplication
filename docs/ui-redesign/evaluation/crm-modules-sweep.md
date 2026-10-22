# MODULES sweep — remaining list surfaces (branch `ui/list-crm`)

Scope rule applied: this builder MAY edit only CRM list production
scope. Non-CRM leftovers are enumerated with evidence and FILED (not
touched, not blown up silently). Within CRM scope, small screens are
rebuilt under full gates; medium+ screens are filed.

Method: each file below was checked for new-pattern atoms
(`AppPageHeader`, `AppSurfaceCard`, `AppEmptyState`/`AppErrorState`,
`AppShimmerSkeleton`, `AppSearchBar`, `AppStatusChip`,
`showAppModalSheet`) vs legacy atoms (`EmptyState`, `StatusPill`,
`AppSkeleton`, `AppCard`, raw `AlertDialog`/`showDialog`/
`showModalBottomSheet`, `CrmColors`/`Color(0x` styling).

## Done before this branch (verified, not re-listed as work)

- Auth (phase-2, all 4 apps), advisor home (phase-3), supervisor floor +
  compact nav (phase-5 + integration-1), technician today (phase-5),
  customer home + vehicles list (phase-6 + integration-1), owner home
  (phase-7), owner job-card detail, staff profile, advisor detail/
  delivery/checkin/preview headers (partial `AppPageHeader` adoptions).

## Rebuilt on this branch (full gates: brief + char + before + migration + build + verify)

1. CRM leads list — `crm_leads_page.dart` (+ new `crm_leads_search_sheet`,
   `crm_leads_filter_sheet`, `support/lead_contact_actions.dart`).
   Brief `briefs/crm-leads-list.md`; char 8→13 GREEN; before/after
   captures; migration `evaluation/crm-leads-list-test-migration.md`.
2. CRM tasks list — `crm_tasks_page.dart` (+ new
   `crm_tasks_search_sheet.dart`). Brief `briefs/crm-tasks-list.md`;
   char 6→10 GREEN; before/after captures; migration
   `evaluation/crm-tasks-list-test-migration.md`.
3. CRM sales team leaderboard — `crm_sales_team_page.dart`. Brief
   `briefs/crm-sales-team-list.md`; char 4→6 GREEN; before/after
   captures; migration `evaluation/crm-sales-team-test-migration.md`.

## Filed follow-ups (precise list, NOT rebuilt — owner/scope noted)

### M3 staff advisor core (staff_app) — OUT OF SCOPE for this builder
- `features/advisor/presentation/pages/advisor_jobs_view.dart` — legacy:
  inline `AppSearchField`, `AppSkeleton.listRows`, `EmptyState.noMatch`/
  `EmptyState`. Needs full list rebuild. Owner: staff phase-3 session.
- `features/advisor/presentation/pages/advisor_reports_view.dart` —
  legacy `AppSkeleton.chart`. Owner: staff phase-3 session.

### M5 supervisor / technician (staff_app) — OUT OF SCOPE
- `features/supervisor/presentation/widgets/supervisor_jobs_tab.dart` —
  PARTIAL (`AppPageHeader` ✓; legacy inline `AppSearchField`,
  `AppSkeleton`, `EmptyState(.noMatch)`, `supervisorStatusPill`).
  Owner: staff phase-5 session.
- `features/supervisor/presentation/widgets/supervisor_queue_tab.dart` —
  PARTIAL (`AppPageHeader` ✓; legacy `AppSkeleton`, `EmptyState`,
  `StatusPill.danger/warning/info/neutral`). Owner: staff phase-5.
- `features/supervisor/presentation/widgets/supervisor_review_tab.dart` —
  PARTIAL (`AppPageHeader` ✓; legacy `AppSkeleton`, `EmptyState`,
  `StatusPill.info`). Owner: staff phase-5.
- `features/supervisor/presentation/widgets/supervisor_{staff,schedule,reports}_tab.dart`
  — `AppPageHeader` present; cards/empty/states need verification +
  completion. Owner: staff phase-5.
- `features/technician/presentation/widgets/technician_jobs_view.dart` —
  legacy (`AppSkeleton`, `EmptyState(.error/.noMatch)`). Owner:
  staff phase-5.
- `features/technician/presentation/widgets/technician_productivity_view.dart` —
  legacy (`EmptyState`, `AppSkeleton`). Owner: staff phase-5.

### M6 customer (customer_app) — OUT OF SCOPE
- `features/customer/presentation/widgets/customer_bookings_tab.dart` —
  legacy (`EmptyState`, `AppSkeleton` text/card). Owner: customer
  phase-6 session.
- `features/customer/presentation/customer_notifications_view.dart` —
  legacy (`AppSkeleton` card rows). Owner: customer phase-6 session.
- `features/customer/presentation/customer_approvals_page.dart` —
  legacy (`StatusPill`, `AppSkeleton`). Owner: customer phase-6
  session.

### M7 owner (owner_app) — OUT OF SCOPE
- `features/job_cards/presentation/pages/job_cards_list_view.dart` —
  zero new-pattern atoms. Needs full list rebuild. Owner: owner
  phase-7 session.
- `features/dashboard/presentation/pages/{team,subscription,pending_approvals,job_status,inventory,feedback_moderation,document_expiry,attendance,accounts_receivable}_view.dart`
  — 9 sub-pages; per-file verification + rebuild. Owner: owner
  phase-7 session.
- `features/dashboard/presentation/widgets/{owner_activity_feed_tab,messages_page,top_sales_page,kpi_grid}.dart`
  — feeds/charts; verify + complete. Owner: owner phase-7 session.

### M8 CRM (crm_app) — IN SCOPE, filed as medium+ (own sessions)
- `widgets/crm_conversations_page.dart` — PARTIAL (`AppPageHeader` ✓;
  legacy `EmptyState` x2, `StatusPill` x2). Needs master-detail rebuild.
- `widgets/crm_reports_page.dart` — legacy `AppCard.surface` charts.
  Needs chart-card rebuild.
- `widgets/crm_integrations_page.dart` — PARTIAL (`AppPageHeader` ✓;
  legacy `showModalBottomSheet`, `StatusPill`, spinners). Needs sheet/
  state rebuild.
- `widgets/crm_dashboard_page.dart` — PARTIAL (`AppPageHeader` ✓;
  legacy `StatusPill`, `Container`s, spinner). Needs dashboard rebuild.
- `widgets/crm_settings_page.dart` — `AppPageHeader` ✓; verify rows/
  states.
- `widgets/crm_{kanban_view}.dart` — KEPT verbatim per leads brief
  (legacy atoms remain; next slice).
- `widgets/{lead_form_sheet,lead_detail_sheet,connect_integration_sheet}.dart`
  — destinations/sheets, kept per brief (raw `showModalBottomSheet`/
  `AlertDialog` remain; migrate with their owning flows).
- `widgets/{crm_recent_leads,crm_followups_widget,crm_activity_feed_widget,crm_pipeline_widget,crm_channel_widgets}.dart`
  + `crm_drawer.dart` — dashboard-embedded lists/widgets, legacy
  atoms; rebuild with the dashboard surface.

## Sweep result

- Leftover lists found: **well over 2** (25+ across M3/M5/M6/M7/M8).
- Rebuilt under full gates: **3** (leads, tasks, sales-team — all CRM
  scope; the sweep's "first 2" plus one, all small).
- Second-slot accounting: no second SMALL in-scope list screen exists
  (next CRM lists are medium+: conversations/reports/integrations/
  dashboard); non-CRM screens are blocked by the edit-scope gate. Filed
  explicitly here instead of touched silently.
- Taps/mandate note: no list surface was altered outside CRM; nothing
  in staff/customer/owner changed behaviorally or visually.
