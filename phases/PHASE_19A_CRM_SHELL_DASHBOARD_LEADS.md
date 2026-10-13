# PHASE 19A — CRM: Shell, Dashboard & Leads

## A. Phase identity

- **Phase number:** 19A (part 1 of 3; split from the former Phase 19)
- **Title:** CRM Shell, Dashboard Tab, Leads Workspace (list/kanban), Lead Form & Detail Sheets
- **Objective:** Bring the CRM's core conversion workspace onto the unified design system — shell/chrome, dashboard tab, the leads list↔kanban workspace and both lead sheets — replacing the parallel navy/cyan visual world in these surfaces with tokens.
- **Priority:** Medium-High (highest-value CRM surfaces first)
- **Dependencies:** Phases 01–05
- **Estimated scope:** Large

## B. Repository context

Files (relative to `apps/crm_app/`):

- Shell: `lib/features/crm_dashboard/presentation/crm_dashboard_view.dart`
  (route `/crm_dashboard_view`; `IndexedStack` of 8 tabs via
  `crmUiProvider.selectedIndex`; Leads tab badge; "CRM Settings" drawer footer).
- Chrome: `widgets/crm_app_bar.dart` (per-tab titles + "Orient CRM · <branch>"
  subtitle, refresh, `NotificationBell`, avatar → `showProfileSheet`),
  `widgets/crm_drawer.dart` (`AppNavDrawer`, 8 destinations, logout via
  `showLogoutDialog`).
- Dashboard tab: `widgets/crm_dashboard_page.dart` (header banner, KPI grid,
  attention queue = `crm_pipeline_widget.dart` + `crm_followups_widget.dart`,
  channel performance `crm_channel_widgets.dart`, activity feed
  `crm_activity_feed_widget.dart`, recent leads `crm_recent_leads.dart`;
  pull-to-refresh; "Connect"/"Sync Now").
- Leads: `crm_leads_page.dart` (search, source filter chips All/Meta/Zoho/
  WhatsApp, list ↔ kanban toggle, empty/connect states) + `crm_kanban_view.dart`
  (stages ACTIVE/NEW/CONTACTED/QUALIFIED/PROPOSAL/WON/LOST/UNANSWERED/
  NO_RESPONSE; compact chip selector vs full board).
- Sheets: `lead_form_sheet.dart` (create/edit: name, phone, email, source,
  assignee, value AED, follow-up date ISO-8601, notes, status),
  `lead_detail_sheet.dart` (info rows, status actions, activity timeline, edit,
  delete confirm).
- Providers: `crm_ui_provider.dart` (tabs, search), `crm_lead_provider.dart`,
  `crm_analytics_provider.dart` (dashboard tab reads) — preserve APIs.
- Palette: `presentation/crm_constants.dart` (navy/cyan) — files touched here
  migrate to tokens; the constants file is **deleted only in 19C** after all
  remaining consumers migrate.
- Tests: none for CRM pages today; this phase adds the first CRM widget suite.

## C. Design objectives

1. **Kill the parallel palette in touched surfaces.** App bar, drawer, shell,
   dashboard tab, leads, kanban and lead sheets read tokens only. The old
   `crm_constants.dart` values may remain referenced by untouched tab files
   until 19B/19C — but no surface redesigned here may use them.
2. **Dashboard tab (T7):** header banner (real data only), KPI row (leads, won,
   conversion, response time — only real metrics), attention queue (pipeline
   bars + follow-ups with overdue emphasis, tappable to Leads with filter where
   the provider supports), channel performance, recent activity, recent leads
   table (desktop) / rows (compact). Connect / Sync Now preserved.
3. **Leads = the workspace.** Toolbar: search, source chips, view toggle
   (list/kanban segmented), add-lead action. List rows: name, phone, source
   pill, status pill, value (tabular AED), assignee, follow-up (overdue
   emphasized). Kanban: stage columns with counts, cards → lead detail; compact
   uses the stage-chip selector pattern (documented as the mobile kanban);
   tablet scrolls columns horizontally.
4. **Lead sheet + form:** detail as large sheet (compact) / side dialog
   (desktop ≥600 via `showAppModalSheet`) with identity header, contact actions
   (keep only what exists today), status action row, value/assignee/follow-up,
   activity timeline, edit/delete. Form: local validation (name/phone
   required), date picker for follow-up (ISO-8601 payload unchanged),
   source/assignee/status selectors, busy save, error panel.
5. **App bar + drawer standardized** on Phase 04 patterns; badge language
   shared; notification bell/refresh behaviors preserved.
6. **Localization:** every string in these surfaces localized EN+AR (starts the
   `crm*` key namespace); lead statuses via localized labels.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `CrmDashboardView` (+ app bar, drawer) | shell + 8 tabs (leads badge; other tabs still legacy until 19B/19C) | tab switch, refresh, notifications, profile/logout | — |
| Dashboard tab | banner → KPIs → attention → channels → activity → recent leads | connect, sync, drill to leads | skeleton, error+retry, per-section empties |
| `CrmLeadsPage` (+ kanban) | toolbar → list/kanban | search, source filter, view toggle, add lead, open lead | skeleton, empty (+connect CTA), no-match, error |
| `LeadDetailSheet` | identity → status actions → details/timeline → edit/delete | status change, edit, delete (confirm) | busy, error |
| `LeadFormSheet` | form sections → save | create/update | validation, busy, error |

Route/provider contracts unchanged (`/crm_dashboard_view`; `crmUiProvider`
tab index/search; lead CRUD payloads incl. ISO-8601 follow-up).

## E. Responsive specifications

- **Compact:** bottom bar (max 5 incl. More) + `AppNavDrawer`; kanban uses
  stage chips; tables become rows; lead sheets full-height with keyboard
  insets.
- **Medium:** icon rail + drawer; kanban horizontal columns scrolling; KPIs
  4-up.
- **Expanded/large:** extended rail 224; kanban full board (columns side by
  side, horizontal scroll if needed); recent leads as true table; lead sheets
  become side dialogs.
- 320 px: chip selectors scroll; no overflow; RTL: kanban column order and
  pipeline bars mirror.

## F. Localization and RTL

- All strings localized (`crmShell*`, `crmDashboard*`, `crmLeads*`) EN+AR;
  lead status labels localized; money AED via `AppFormatters`; phone numbers
  Latin digits.
- RTL: kanban/pipeline mirror; date picker localized; sheets/dialogs mirror.
- Tests: new CRM widget tests in EN+AR; RTL assertions for kanban + pipeline +
  lead rows; 320 px clean.

## G. Design system integration

- Use: `AppPageFrame`, `AppSearchField`, filter chips, `AppRecordRow`,
  `AppKpiCard`, `StatusPill`, `AppCard`, chart theme (pipeline/response bars),
  `AppButton`, `showAppModalSheet` + `AppConfirmationDialog`,
  `AppTextField`/`AppDropdownButton`, `AppSkeleton`, `EmptyState`, `ErrorView`,
  `AppInfoPanel`, `GradientBanner` (dashboard header only), `NotificationBell`,
  `UserAvatar`, `DirectionalIcon` as needed.
- No new tokens expected. Do not delete `crm_constants.dart` yet (19C).

## H. Technical implementation

- Modify: shell/app bar/drawer, dashboard tab + its widgets, leads page +
  kanban, both lead sheets; CRM ARB; add widget tests.
- Preserve: `crmUiProvider` (tab index, search, connect/sync), lead provider
  CRUD payloads (incl. ISO-8601 follow-up date), status transitions, delete
  confirmations, badge source, resume refresh in `main.dart`.
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Lead CRUD/status/delete flows unchanged; provider payloads untouched.
- Connect/Sync Now and notification behavior unchanged.
- Other tabs (Conversations/Tasks/Team/Reports/Integrations/Settings) keep
  working untouched while still consuming old constants (until 19B/19C).
- `crmUiProvider` tab index contract unchanged; settings footer shortcut
  unchanged.

## J. Testing requirements

- `melos run analyze:crm`; `melos run test:crm` (this phase establishes the
  suite).
- Widget tests: shell/tabs render; leads list + filter + search + kanban
  toggle; lead form validation + save; lead detail status/delete; dashboard
  sections render from fakes; EN+AR; RTL; 320/390/768/1280; 1.3×.
- Goldens: CRM dashboard + leads (EN compact + expanded) + AR golden for
  leads.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the CRM app and visually review the shell,
   dashboard tab, leads list/kanban and both lead sheets; no surface may be
   signed off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px); kanban reviewed at tablet + desktop.
3. **Locales** — EN-LTR and AR-RTL renders; kanban/pipeline mirroring and lead
   rows reviewed in AR.
4. **State matrix** — dashboard skeleton/error/empty sections; leads
   empty/no-match/connect-CTA; kanban populated per stage; form
   pristine/invalid/busy/save-error; detail timeline populated. Realistic lead
   fixtures (Gulf names, UAE phones, AED values).
5. **Interaction verification** — tab switch + badge, search/filter, view
   toggle, add/edit/delete lead confirms, status change, contact actions that
   exist today.
6. **Accessibility** — 1.0–1.3× scale clean; ≥48 px rows/cards; semantics on
   kanban cards and rows; contrast sampled on stage colors.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_19A/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D surfaces redesigned on the unified system; none reference
   `crm_constants.dart`.
2. Provider/payload/badge/refresh behaviors unchanged (tests).
3. EN/AR complete; RTL correct incl. kanban; responsive per E.
4. `melos run analyze:crm` + `test:crm` green with the new suite; J2 evidence
   attached.

## L. Deliverables

- File changes; ARB counts; token-migration notes for 19B/19C; test evidence;
  goldens; known limitations.

## M. Completion gate

Stop after this phase. 19B (work hub: conversations/tasks/sales team) and 19C
(reports/integrations/settings + palette deletion) follow. Do not begin until
explicitly instructed.
