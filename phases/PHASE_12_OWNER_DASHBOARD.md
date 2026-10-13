# PHASE 12 — Owner: Dashboard Experience

## A. Phase identity

- **Phase number:** 12
- **Title:** Owner Dashboard Experience (shell, app bar, Dashboard tab, KPIs, charts, register, quick actions, Top Sales, Messages, Activity)
- **Objective:** Redesign the owner's daily command center — the first screen of the owner app — into an executive-grade, drillable dashboard backed entirely by the unified design system, removing hand-rolled cards and ad-hoc colors, while preserving provider contracts and the period/refresh model.
- **Priority:** High
- **Dependencies:** Phases 01–05
- **Estimated scope:** Large

## B. Repository context

Files (relative to `apps/owner_app/`):

- Shell: `lib/features/dashboard/presentation/dashboard_view.dart` (thin) +
  `widgets/dashboard_body.dart` (`DashboardShell` +
  `AppAdaptiveNavigationFrame` + `IndexedStack`, 4 tabs: Dashboard / Top Sales /
  Messages / Activity).
- Chrome: `widgets/owner_app_bar.dart` (per-tab titles, `PeriodDropdown`, bell,
  avatar → `showProfileSheet`; back-to-overview on non-dashboard tabs).
- Dashboard tab: `widgets/owner_dashboard_page.dart` — `OwnerDashboardSkeleton`
  loading, `MaterialBanner` error + RETRY, `RefreshIndicator`; order:
  `HeaderBanner` → KPI Overview (`KpiGrid`) → Job Card Register
  (`JobCardRegisterCard`) → Analytics (`AppSplitView`: `SalesTrendCard` +
  `SalesVsExpensesCard`) → Quick Actions (`QuickActionsRow`).
- Widgets: `header_banner.dart` (hero + Live/Active/Today pills),
  `kpi_grid.dart`/`kpi_card.dart`, `job_card_register_card.dart` (**uses raw
  `Navigator.push(MaterialPageRoute)` to job cards — fix in this phase**),
  `sales_trend_card.dart` + `dual_line_painter.dart`, `sales_vs_expenses_card.dart`
  + `bar_chart_painter.dart`, `quick_actions_row.dart` + `action_button.dart`
  (12 actions: 9 `context.push` routes + Top Sales + Messages tab switches +
  Subscription).
- Tabs: `top_sales_page.dart` + `sales_category_card.dart` (expandable),
  `messages_page.dart` + `message_tile.dart` (broadcast to active staff +
  history; silent offline fallback; no loading/empty UX),
  `owner_activity_feed_tab.dart` (backend activity; errors swallowed to `[]`;
  loading == empty).
- Providers: `providers/dashboard_ui_providers.dart` (`dashboardUiProvider.refresh()`),
  `dashboard_providers.dart`, team/subscription/moderation/inventory/attendance/
  AR providers; resume refresh in `main.dart`.
- Known issues recorded in analysis: ~11 hand-rolled cards, 85 hard-coded hex
  colors across pages, `KpiGridSkeleton` unused, owner dead code
  (`card_title.dart`, `form_label.dart`) — dead removal is Phase 14.
- Tests: `test/responsive_dashboard_widgets_test.dart` (320/390/800/1440),
  `chart_painters_test.dart`, `logic_test.dart`.

## C. Design objectives

1. **Executive hierarchy.** Dashboard tab reads in one glance: hero banner
   (workshop identity + period + live pills) → KPI strip (max 4 tiles, one navy
   hero allowed) → "Job Card Register" as the operating table (counts by
   category, tap row → job list filtered where supported) → analytics (2 charts
   side-by-side ≥medium) → quick actions grid. No duplicate metrics between hero
   and KPIs; every KPI/register row taps to its source page (`go_router`).
2. **Charts adopted to the shared chart language** (Phase 03B chart theme):
   colors from palette, axis/tooltip typography per tokens, gridlines subtle,
   values tabular, RTL axis order mirrored, empty-data states rendered (not
   blank). Painters refactored accordingly; `chart_painters_test.dart` stays
   green (extend only if painter APIs change — prefer not).
3. **Truthful data states.** Replace swallowed errors in Activity tab
   (`errors → []`) with error+retry; give Messages an explicit empty/offline
   state; loading uses skeletons per grammar (retire one-off shimmer where
   replaced; `KpiGridSkeleton` either used or deleted in Phase 14).
4. **Quick actions = navigation tiles, not decoration.** Grid of icon+label
   tiles (2-up compact, 4-up medium+, 6-up large), consistent hit areas,
   all existing destinations preserved exactly (9 routes + 2 tab switches +
   subscription).
5. **Top Sales = drillable ranking.** Categories as expandable cards with
   item/revenue tables (desktop table grammar), tabular money, "0 categories"
   becomes a proper empty state.
6. **Messages = broadcast with receipts.** Recipient picker (active staff,
   searchable), body, send with in-button busy; history list with delivery
   state; offline attempt shows honest "not sent" state instead of silent
   fallback.
7. **Activity feed = real feed.** Loading skeleton, error+retry, empty state,
   relative timestamps localized.
8. **App bar final.** Uses the workspace app-bar pattern from Phase 04: title +
   context subtitle, period control (dashboard tab only), bell with badge,
   avatar menu; back-to-overview affordance on secondary tabs kept.
9. **Navigator consistency:** replace the raw `Navigator.push` in
   `JobCardRegisterCard` with `context.push(AppRoutes.jobCards)` (or detail)
   matching the rest of the app.

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `DashboardBody` + `OwnerAppBar` | shell + 4 tabs + workspace app bar | tab switch, period select, notifications, profile | — |
| `OwnerDashboardPage` | banner → KPI strip → register → analytics → quick actions | pull-to-refresh, retry, tap KPI/row → pages, quick actions | skeleton, error banner + retry, per-section empty |
| `HeaderBanner` | identity + period + live pills | display | derived-safe labels |
| `KpiGrid`/`KpiCard` | responsive grid, tappable | tap → destination | value/trend states |
| `JobCardRegisterCard` | category table | row tap → job cards list (go_router), view all | empty |
| Charts | trend + expenses/bar | display; tooltips per painter capability | empty-data render |
| `QuickActionsRow` | action tile grid | navigate (all existing) | — |
| `TopSalesPage` | category cards expandable | expand, view items/revenue | empty |
| `MessagesPage` | composer + history | pick recipient, type, send, view history | busy, success/failure, offline honest, empty |
| `OwnerActivityFeedTab` | feed list | refresh | skeleton, error+retry, empty |

## E. Responsive specifications

- **Compact:** bottom nav (4 tabs); KPI 2×2; register as compact rows (no wide
  table); charts stacked full-width with fixed heights (trend ~200, bars ~200);
  quick actions 3 columns; messages composer full-width, history below.
- **Medium:** rail; KPI 4-up; register shows category columns; charts
  side-by-side (`AppSplitView`); quick actions 4-up.
- **Expanded/large:** content capped (`contentWide` for dashboard); charts
  side-by-side max 2 series each; register as a true table with aligned money;
  quick actions 6-up; Top Sales category tables as desktop tables.
- 320 px: no overflow (existing test must keep passing, extended to new tiles).
- RTL: chart axes/legend mirrored; table numeric alignment per spec §13.

## F. Localization and RTL

- All strings localized (owner ARB, `ownerDashboard*` namespaces): banner pills,
  KPI labels, register categories, quick action labels, messages copy, activity
  titles, empty/error copy.
- Money/dates/period labels localized via `AppFormatters`; period dropdown
  values localized (Today/This Week/This Month/This Year).
- RTL: tile grids mirror, register rows mirror, chart labels localized and
  axis order mirrored; bell badge unaffected.
- Tests: new owner dashboard widget tests in EN+AR; RTL assertion for grid and
  register; 320 px EN/AR.

## G. Design system integration

- Use: workspace app-bar pattern, `GradientBanner` or navy `AppCard` hero
  (choose one — recommend navy card for data emphasis, gradient only if it
  stays subtle), `AppKpiCard`, `AppRecordRow`, table primitives (Phase 03B),
  `AppSearchField` (messages recipient/sales search where applicable),
  `AppSkeleton`, `EmptyState`, `ErrorView`, `AppButton`, `AppInfoPanel`,
  `StatusPill`, chart theme helper, `SectionHeader`, `AppAdaptiveGrid`,
  `AppSplitView`.
- Remove hand-rolled hex colors in all touched files → tokens.
- No new tokens expected; note any gap per README §8.

## H. Technical implementation

- Modify: files in B; ARB; tests/goldens.
- Preserve: `dashboardUiProvider`/`dashboardUiProvider.refresh()`, period
  selection state provider, tab switching mechanics, resume refresh wiring in
  `main.dart`, message-send provider method, activity provider.
- `go_router` for all navigation in touched files.
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Period selection semantics (server-side range) unchanged.
- All 12 quick actions navigate exactly as today.
- Message broadcast payload/recipient rules unchanged; offline fallback logic
  preserved but surfaced honestly.
- Charts continue to use the same data series/aggregations.
- `responsive_dashboard_widgets_test.dart` + `chart_painters_test.dart` remain
  green (extend for new structure, don't rewrite assertions).

## J. Testing requirements

- `melos run analyze:owner`; `melos run test:owner`.
- Extend `responsive_dashboard_widgets_test.dart` for new KPI/action tiles at
  320/390/800/1440 (EN+AR); new widget tests: dashboard sections render from
  fake providers, error banner retry, register navigation via router, quick
  actions route mapping, messages send/offline-honest, activity error+retry,
  EN/AR + RTL + 1.3×.
- Painter tests: keep green; add empty-data render assertions.
- Goldens: first owner dashboard goldens (EN/AR at compact + expanded).

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the owner app and visually review the Dashboard
   tab (banner, KPIs, register, charts, quick actions), Top Sales, Messages and
   Activity; no screen may be signed off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px); the two-chart side-by-side layout reviewed on
   desktop.
3. **Locales** — EN-LTR and AR-RTL renders; chart axis mirroring and money
   formatting reviewed in both.
4. **State matrix** — loading skeleton, error banner + retry, empty register,
   empty categories, activity empty/error, message send success/failure/offline.
   Populated fixtures use realistic workshop KPIs (AED amounts, plate numbers).
5. **Interaction verification** — period selection, KPI/register drill-ins via
   go_router, all 12 quick actions, recipient picking, message send, pull-to-
   refresh.
6. **Accessibility** — 1.0–1.3× scale clean, tabular KPIs, chart labels legible,
   semantics on tiles, contrast sampled (incl. navy tiles).
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_12/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D surfaces redesigned with shared primitives; zero hard-coded hex in
   touched files; raw `Navigator.push` removed.
2. Provider/period/message/refresh behaviors unchanged (tests).
3. EN/AR complete; RTL correct; responsive per E; 320 px no-overflow.
4. `melos run analyze:owner` + `test:owner` green; new tests cover all states.

## L. Deliverables

- File changes; ARB counts; chart refactor summary; test evidence; golden
  baselines; known limitations.

## M. Completion gate

Stop after this phase. Do not begin Phase 13A until explicitly instructed.
