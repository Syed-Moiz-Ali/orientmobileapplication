# Advisor home test migration (phase 3 home recomposition)

Branch: `ui/phase-6-customer` (advisor work lands on the same branch — no new
branch). Home recomposed presentation-only: providers, routes, sync logic,
sort order, search filtering, selection state and Keys untouched.

## Inventory (existing advisor tests before this change)

- `apps/staff_app/test/baseline_capture_test.dart` (tagged `baseline`,
  excluded from the default run): pumps the real staff root on the login
  path (light). Zero assertions touch Advisor Home — no home widget
  finders, no home behavior assertions existed.
- Old home assertion count: **0**. New home assertion count: **9 testWidgets**
  in `apps/staff_app/test/advisor_home_view_test.dart` (all structural).
  Counts did not go down (0 -> 9).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| (none existed) | n/a | `header greets with offline pill, bell badge and avatar`: `AppPageHeader` with greeting + branch/shift line, `OfflineStatusPill`, bell `AppBadge`, profile avatar | structural |
| (none existed) | n/a | `hero shows inspections-due-today with sentence and See all`: one `AppMediaCard` with `advisorHeroDueTitle` count + `advisorHeroSentence`, See-all CTA into the Jobs tab (reuses `advisorSeeAll`; no new CTA key per the brief) | structural |
| (none existed) | n/a | `quick actions are one horizontal row of three with New job primary`: Scan / New job / Approvals tiles, approvals `AppBadge`, New job emphasized primary | structural |
| (none existed) | n/a | `pinned pill search filters with recents and scan`: pill-style `AppSearchBar` (same controller/focus/query/clear) with hint, recent chips, scan action; sheet via header search + Ctrl+K kept | structural |
| (none existed) | n/a | `assigned jobs render as media cards with Show all`: `AppMediaCard` rows (customer + vehicle/plate + one `AppStatusChip`), `Show all` into the Jobs tab, urgent-first order kept | structural |
| (none existed) | n/a | `assigned search filters by id, customer and vehicle`: recent-chip query filters the card list inline; predicate unchanged | structural |
| (none existed) | n/a | `empty assigned list shows one empty state with New job action`: one `AppEmptyState` (`advisorHomeEmptyTitle` + `advisorHomeEmptyBody` + New job CTA) | structural |
| (none existed) | n/a | `loading skeleton mirrors the final layout`: `AppShimmerSkeleton` shapes, no `AppMediaCard` | structural |
| (none existed) | n/a | `error state with retry when nothing loaded`: `AppErrorState` (`advisorDataError`) + retry invalidates the provider | structural |

## Behavior assertions (verbatim, unchanged)

No behavior assertions were modified because no behavior changed:

- Navigation targets identical: `AppRoutes.scanVehicle`,
  `AppRoutes.vehicleCustomer`, `AppRoutes.advisorJobDetail` (extra: job card);
  `Show all`/hero/summary move between the Today/Jobs/Reports tabs
  (`onNavigateTab(1|2)`) — no new routes, no dropped routes (there is no
  analytics route; the summary never linked out).
- Provider reads identical: `advisorRecentJobCardsProvider`,
  `advisorDashboardProvider`, `advisorPendingApprovalsProvider`,
  `advisorPendingSyncCountProvider`, `advisorNotificationsProvider`,
  `advisorInfoProvider`, connectivity via `connectivityStatusProvider`.
- Urgent-first sort identical (`_urgencyRank`: pending/approval/parts/QC >
  active > finished > cancelled; stable within rank).
- Search filter predicate identical (id / customerName / vehicleInfo,
  case-insensitive); only the cap presentation moved with the card list
  (still 6 visible).
- Approval/sync writes identical (`_persistApproval`: Hive `approval_` key +
  `SyncOperation` enqueue + `syncAll`); toasts, haptics, Ctrl+K shortcut,
  bell count (`notifications + approvals`), selection state and all sheets
  (profile / notifications / search / approval) plus the destructive logout
  dialog unchanged.
- Sheets keep their own widgets verbatim (`AdvisorProfileSheet`,
  `AdvisorNotificationSheet`, `AdvisorSearchSheet`, `AdvisorApprovalSheet`).

## Copy changes (new ARB keys, en+ar, regenerated)

- `advisorHeroDueTitle` ("{count} inspections due today" /
  "‏{count} عمليات فحص مستحقة اليوم") — hero key number.
- `advisorHeroSentence` ("Review what's urgent first." /
  "راجع المهام العاجلة أولاً.") — hero plain-language sentence.
- `advisorHomeEmptyTitle` ("No jobs assigned yet" / "لا توجد مهام مسندة بعد")
  + `advisorHomeEmptyBody` ("New job cards will appear here. Create one to
  get started." / "ستظهر بطاقات العمل الجديدة هنا. أنشئ واحدة للبدء.") —
  empty assigned list (action reuses `advisorActionNewJobTitle`).
- All other home strings reused verbatim (`advisorGreeting`,
  `advisorAction*`, `advisorSearch*`, `advisorAssignedWorkOrders`,
  `advisorSeeAll`, `advisorWorkSummary`, `advisorDeltaToday`,
  `advisorOfflineNotice`, `advisorDataError`, status labels).
