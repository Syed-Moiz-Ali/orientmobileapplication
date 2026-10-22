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
- Adversarial review (2026-10-22): zero code changes — all 7 claims rebutted
  as fixture/feed-owned or brief-contract (EN titles/bodies/times are verbatim
  stored-field fixtures per brief Truth rules; 1:1 grouping is the 4-fixture
  composition over sanctioned sections; chevron/banner grammar is the shared-
  atom contract); 11 testWidgets unchanged (counts 0 -> 11 -> 11, never down).

## Tap table (AFTER ≤ BEFORE — no regression; EXACT counts)

| Task | Before (EXACT) | After (EXACT) |
|---|---|---|
| Open inbox | 1 tap (bell, any tab) | ≤ 1 tap (bell untouched) |
| Open notification destination | 2 taps + scroll (bell + row tap) | ≤ 1 tap from list, ≤ 2 from launch (row tap, same `destination()` mapping) |
| Mark all read | 2 taps (bell + `Mark all read`) | ≤ 1 tap from list, ≤ 2 from launch (summary row, no scroll) |
| Mark one read | 2 taps (bell + row tap) | ≤ 2 taps (row tap, background persist) |

## Wave-2 fixer notes (2026-10-22 — investigate, no code change)

- F4 investigated: notification EN titles/bodies/times in ar are
  backend-stored fields, NOT hardcoded EN templates in UI code. Evidence:
  `_NotificationRow` renders `Text(notification.title)` /
  `Text(notification.body)` / `label · time` meta verbatim
  (`customer_notifications_view.dart:408-409,419-430,432-443`); only the
  category label is ARB-localized (`labelOf`/`groupOf` → `ntType*`/`ntGroup*`
  keys). Fixtures carry EN stored-field copy
  (`customer_notifications_list_after_capture_test.dart` `_service`,
  `_approval`, `_invoice`, `_general`). Per brief Truth rules
  (title/body/time/category only from stored fields) and governance
  (backend-stored/feed strings stay verbatim; translation would be data
  invention), the ar inbox correctly keeps EN content rows inside otherwise-RTL
  chrome — no ARB keys added, no copy invented. Logged as
  `LOGIC_FOLLOWUPS.md` entry 11 (same format) instead.
- Notifications has NO search by sanctioned design (brief deviation 1) —
  touched nothing there (F1 explicitly excludes notifications).
- Counts: 11 testWidgets unchanged (0 -> 11 -> 11, never down). No
  notifications frames recaptured (no code change); bookings + vehicles
  after-dirs recaptured and compared back-to-back GREEN (see sibling docs).

## Fixture grouping diversification (2026-10-22 — test-data only, no code change)

- Capture inbox was 1:1 (4 fixtures → 4 groups), understating grouping.
  Diversified FIXTURE content only in
  `customer_notifications_list_after_capture_test.dart`: kept original 4
  fixtures verbatim (`_service` bookingReceived `Booking confirmed` /
  `Your Camry is booked for Saturday at 10:00.` / `2h ago`; `_approval`
  approvalNeeded `Estimate needs approval` /
  `Review the brake estimate before work continues.` / `3h ago`; `_invoice`
  invoiceReady read; `_general` general read) and added 2 read extras in the
  same EN stored-copy style (no Arabic invented): `_service2`
  bookingAssigned `Technician assigned` /
  `Ali will handle your Camry service today.` / `5h ago` (Service updates);
  `_approval2` estimateApproved `Estimate approved` /
  `The brake estimate was approved. Work resumes today.` / `8h ago`
  (Approvals). Inbox is now 6 (Service x2, Approvals x2, Invoices x1,
  General x1) with unread still 2, so the Mark-all summary row is unchanged.
- Behavior kept verbatim: same providers/sync/predicates/routes/handlers
  (see above); only stored-field feed rows changed. No pinned text/count
  changed in characterization (11 testWidgets unchanged, 0 -> 11 -> 11,
  never down); capture has no text/count pins (PNGs only). Counts never
  down (capture fixtures 4 -> 6).
- Frames recaptured: `after-customer-notifications/` idle variants
  (light/dark/ar/1.3x/320px/tablet + stale which shares the inbox) via
  `--update-goldens` limited to the after-capture test, then compared
  back-to-back GREEN.

## New ARB keys (en+ar, `flutter gen-l10n` from `apps/customer_app`)

NONE expected — all copy reuses existing `nt*` keys (`ntTitle`, `ntUnread`,
`ntAllRead`, `ntMarkAll`, `ntMarkFail`, `ntRetry`, `ntLoadTitle`, `ntLoadBody`,
`ntCaughtUp`, `ntCaughtUpBody`, `ntGroup*`, `ntType*`, `ntReadWord`,
`ntUnreadWord`) + `stRefreshFail`/`stRetry`. If the build surfaces any
hardcoded string without a key, it will be added (en+ar) and listed here for
phase 9. No ALL CAPS strings added (C16/C17).
