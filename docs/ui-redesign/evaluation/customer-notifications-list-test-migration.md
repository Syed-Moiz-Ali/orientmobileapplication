# Notifications list test migration (customer notifications-list recomposition)

Branch: `ui/list-customer`. Notifications list recomposed presentation-only:
providers, sync, predicates (`groupOf`, `labelOf`, `tone`/`toneColor`,
`destination`/`isActionable`, `NotifType.fromWire`), refresh, read-marker
flow, routes, Keys and error mapping untouched. Characterization tests were
written against the CURRENT list FIRST (11 testWidgets, GREEN before touching
UI — one harness-only fix: loading case pumped at 360x800 because the fixed
6-card skeleton column overflows the default 800x600 test viewport, a size the
production fold never has) and migrated after the rebuild (11 testWidgets, all
structural, GREEN).
Counts never down (0 -> 11 -> 11).

## Inventory (existing customer tests before this change)

- `apps/customer_app/test/customer_notifications_list_characterization_test.dart`
  (new, 11 testWidgets, all structural, GREEN).
- `apps/customer_app/test/customer_notifications_list_before_capture_test.dart`
  (tagged `baseline`, 10 PNGs in
  `docs/ui-redesign/baseline/before-customer-notifications/`, generated with
  `--update-goldens` and compared back-to-back GREEN before the rebuild:
  idle, all-read, empty, loading, error, stale, dark, ar, 1.3x, 320px).
- Old notifications-list assertion count before this change: **0**. New
  characterization count before touching UI: **11 testWidgets** (all
  structural, GREEN). Counts did not go down (0 -> 11).

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| title + summary + Mark-all | `WorkspaceAppBar` `ntTitle` + `1 unread` + `Mark all read` button; no search icon | `AppAppBar` same title/back + same summary row (same count, same `unread > 0` predicate); no search icon BY DESIGN (sanctioned deviation, brief reason) | structural |
| all read | `All read` muted, no button | same (calm, no button) | structural |
| groups order | `Service updates` + `Approvals` + `General` `SectionHeader`s in stable order | same titles/order on borderless surfaces | structural |
| actionable vs read-only | chevron x2 (service + approval), none on general | same chevron predicate (`destination != null`), same destinations | structural |
| row meta | `Booking` category + `2h ago` time | same verbatim (`labelOf` + stored time) | structural |
| empty | `_AllCaughtUp` (icon + title + body, no CTA) | `AppEmptyState` (1 icon + 1 sentence, NO action — calm empty) | structural |
| loading | `AppSkeleton` text + 6x card-74 | `AppShimmerSkeleton` mirroring summary + rows | structural |
| first-load error | `_LoadFailure` + `Retry` | `AppErrorState` (verbatim title/body + retry, same `_refresh`) | structural |
| stale | data + `CustomerRefreshNotice` | data + `AppBanner` warning (same retry) | structural |
| mark-all failure | `CustomerNoticePanel` + Retry (rollback) | `AppBanner` error + Retry (same `_markAllRead`, rollback kept) | structural |
| dark | (covered: pumps clean) | dark pumps clean: same rows on bordered surfaces | structural |
| 1.3x | (covered: pumps clean) | 1.3x pumps clean: title 2-line + body 3-line wrap | structural |

## Behavior kept verbatim (presentation only — no logic changes)

- Providers/sync/refresh: `customerDashboardProvider` (notifications,
  `unreadCount`, `loadError`, `isLoading`), `refresh()`, `markRead` (background
  persist, never blocks navigation), `markAllRead` (bulk + rollback on refusal),
  pull-to-refresh — identical call sites.
- Predicates/helpers: `_NotificationRow.groupOf`/`labelOf` (frozen category
  mapping, unknown → General), `_grouped` bucketing + stable service →
  approvals → invoices → general order, `CustomerNotificationPresentation.icon`/
  `tone`/`toneColor`/`destination`/`isActionable`, `NotifType.fromWire`.
- Routes (existing destinations only, no new routes): bell → `/notifications`
  (shell, untouched); actionable rows → `bookingsLocation` /
  `approvalsLocation()` via the existing `destination()` mapping; read-only
  rows stay put. Back behavior unchanged.
- Handlers: `_open` (mark + conditional push), `_markAllRead` (optimistic +
  rollback + `ntMarkFail` notice), `_refresh` — same contracts.
- No invented notifications/categories/times; read state stays the workshop's;
  zero as `0`.

## Deviations / notes (presentation-only, filed here)

- Bordered `DecoratedBox` group surfaces + bespoke row `Material`/`InkWell`
  chrome → whitespace-separated `AppSurfaceCard(outlined: false)` rows
  (borderless light w/ shadow, bordered dark) — vehicles/bookings precedent
  (`AppListGroup` is settings-rows only).
- NO search icon and NO filter sheet BY DESIGN (brief deviations with written
  reasons): triage is recency-based (top-3: open / mark-all), rows are short
  and fully scannable, categories already ARE the group sections (a filter
  would duplicate them, U7). No remove sheet: no destructive action exists
  (mark-read is non-destructive with server-rollback forgiveness, U10).
- `_AllCaughtUp` → `AppEmptyState` with NO action (calm empty, U6 — nothing
  exists to create; adding a CTA would be a fake action).
- No `ValueKey` added to rows (notifications rows never had a key contract;
  Keys untouchable — tests find by type + text).

## Tap table (AFTER ≤ BEFORE — no regression; EXACT counts)

| Task | Before (EXACT) | After (EXACT) |
|---|---|---|
| Open inbox | 1 tap (bell, any tab) | ≤ 1 tap (bell untouched) |
| Open notification destination | 2 taps + scroll (bell + row tap) | ≤ 1 tap from list, ≤ 2 from launch (row tap, same `destination()` mapping) |
| Mark all read | 2 taps (bell + `Mark all read`) | ≤ 1 tap from list, ≤ 2 from launch (summary row, no scroll) |
| Mark one read | 2 taps (bell + row tap) | ≤ 2 taps (row tap, background persist) |

## New ARB keys (en+ar, `flutter gen-l10n` from `apps/customer_app`)

NONE expected — all copy reuses existing `nt*` keys (`ntTitle`, `ntUnread`,
`ntAllRead`, `ntMarkAll`, `ntMarkFail`, `ntRetry`, `ntLoadTitle`, `ntLoadBody`,
`ntCaughtUp`, `ntCaughtUpBody`, `ntGroup*`, `ntType*`, `ntReadWord`,
`ntUnreadWord`) + `stRefreshFail`/`stRetry`. If the build surfaces any
hardcoded string without a key, it will be added (en+ar) and listed here for
phase 9. No ALL CAPS strings added (C16/C17).
