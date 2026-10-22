# UX Brief — customer notifications list

## Scope
`apps/customer_app` notifications list surface:
`presentation/customer_notifications_view.dart` (inbox page: `_SummaryRow` +
`_GroupSection` xN + `_NotificationRow` + `_AllCaughtUp` + `_LoadFailure` +
loading skeleton) + `support/customer_notification_presentation.dart`
(icon/label/tone/destination rules) + entry `widgets/customer_scaffold.dart`
`_BellButton` (bell + unread badge → `AppRoutes.customerNotifications`
`/notifications`). Routes touched only as existing destinations:
`CustomerNotificationPresentation.destination()` results
(`bookingsLocation`, `approvalsLocation()`) — no new routes. No logic changes
(providers/state/routes/API/sync/predicates/Keys) — STOP + report if logic is
needed.

## User goal
A customer taps the bell and in one glance sees what changed and what needs
attention (title + category + time), and reaches the thing behind it
(bookings list / approvals page) or clears the pile (mark all read) without
hunting. One screen, one primary task: triage inbox → act.

## Current behavior (verified from code)
- Entry: `_BellButton` in the scaffold `WorkspaceAppBar` (badge = unreadCount,
  offset badge, Semantics "Notifications, N unread"); tap → `context.push(
  AppRoutes.customerNotifications)`. Inbox is a contextual pushed page
  (`Scaffold` + `WorkspaceAppBar(title: ntTitle, showBack: true)`), NOT a
  workspace destination. No search icon. No filter icon.
- Summary (`_SummaryRow`): `ntAllRead` (muted) or `ntUnread(count)` (bold)
  + `TextButton(ntMarkAll)` ONLY when `unread > 0` → `_markAllRead()`; failure
  sets `_markAllFailed` → `CustomerNoticePanel(ntMarkFail + ntRetry)`.
- Groups: `_grouped()` buckets by `_NotificationRow.groupOf(type)` (frozen
  category mapping; unknown → General), stable order service → approvals →
  invoices → general; each `_GroupSection` = `SectionHeader(title)` +
  bordered `DecoratedBox` (surface, radiusPanel, outlineVariant) of rows.
- Row (`_NotificationRow`): unread-tinted surface + 8px dot (fixed slot, title
  also bolder — never color-alone) + category icon (tone color) + title
  (2-line, w800 unread / w600 read) + body (3-line, if non-empty) +
  `label · time` meta (1-line) + chevron ONLY when `destination(type) !=
  null`; tap → `markRead(id)` (background, never blocks) + push destination
  when non-null, else read-only row. Full Semantics label
  (read-state + category + title + body + time).
- Destinations (from `CustomerNotificationPresentation.destination`, backend
  stores no per-item ids so only id-less destinations exist): booking events +
  completion → bookings list; approval/invoice/payment → approvals page;
  estimate decisions / breakdown / general → null (non-navigational, never
  guessing).
- States: `AppSkeleton` loading (96-line + 6x card-74); `_LoadFailure`
  (ntLoadTitle/Body + `FilledButton(ntRetry)`); `_AllCaughtUp` (bell icon +
  ntCaughtUp + ntCaughtUpBody, no CTA — nothing exists to create);
  `CustomerRefreshNotice` stale + data; `RefreshIndicator` pull-to-refresh
  (AlwaysScrollable).
- Truth rules: title/message/category/timestamp only from stored fields;
  `NotifType.fromWire` falls back to general; read state is the workshop's
  (persisted marker, badge agrees after restart).

## Top tasks with tap counts (BEFORE = current UI, AFTER must be ≤)
1. Open the notifications inbox — before: bell in app bar = **1 tap** from any
   tab. After: ≤ 1 tap (bell untouched).
2. Open what a notification leads to — before: bell (1) + row tap (1) =
   **2 taps**. After: row stays directly tappable (chevron rows): **≤ 1 tap
   from the list, ≤ 2 taps from launch**, ≤ same scroll.
3. Mark all as read — before: bell (1) + `Mark all read` (1) = **2 taps**.
   After: `Mark all read` stays in the summary row (visible without scrolling
   when unread > 0): **≤ 1 tap from list, ≤ 2 from launch**.
4. Mark one as read — before: bell (1) + row tap (1) = **2 taps** (marker
   persists in background). After: ≤ 2 taps, same background contract.

| Task | Before | After budget |
|---|---|---|
| Open inbox | 1 tap (bell) | ≤ 1 tap (bell untouched) |
| Open notification destination | 2 taps (+scroll) | ≤ 1 tap from list, ≤ 2 from launch, ≤ same scroll |
| Mark all read | 2 taps | ≤ 1 tap from list, ≤ 2 from launch (summary row, no scroll) |
| Mark one read | 2 taps | ≤ 2 taps (row tap, background persist) |

Frequent tasks (triage, open, mark-all) stay single-screen; destinations are
existing pages (unchanged).

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: **does not exist** (confirmed — no `references`
  dir under `docs/ui-redesign/`).
- `AIRBNB_PATTERNS.md`: **missing anywhere in the repo** (confirmed — repo-wide
  glob `**/AIRBNB_PATTERNS*` returns nothing; the only mention is
  `docs/ui-redesign/evaluation/technician-home-test-migration.md:183`, which
  itself records that the file/dir does not exist).
- Mapping into `AIRBNB_PATTERNS.md` is therefore **unmet**; this brief proceeds
  from the vehicles-list precedent (`docs/ui-redesign/briefs/phase-6-vehicles-list.md`
  + `docs/ui-redesign/evaluation/phase-6-vehicles-list-test-migration.md`) and
  the bookings-list precedent (`docs/ui-redesign/briefs/customer-bookings-list.md`):
  `AppPageHeader` + count, borderless light surfaces, `AppBanner` for
  stale/failure, `AppEmptyState`/`AppErrorState`/`AppShimmerSkeleton`, sentence
  case, zero as `0`.
- Never pretend otherwise: no pattern file was consulted; all pattern claims cite
  the vehicles-list / bookings-list precedent above.

## Vehicles-list pattern reuse (UNLESS top-3 says otherwise)
PARTIAL — two sanctioned deviations, each with its reason:
- REUSED: header with count (bell badge + `ntUnread(count)` summary kept as the
  count contract), borderless cards in light (group surfaces lose borders,
  whitespace separation), frequent action on the row (destination chevron +
  row-tap; `Mark all read` stays in the summary row — the card-level frequent
  action for the bulk task), empty/loading/error states per precedent
  (`AppEmptyState` caught-up / `AppErrorState` + Try again /
  `AppShimmerSkeleton` mirroring rows), stale → `AppBanner`, taps never regress.
- DEVIATION 1 — NO search icon (not even > 5): the top-3 tasks are triage-by-
  recency (open / mark-all), not find-by-text; notification rows are 2-line
  titles already fully scannable, and the list is grouped by category with a
  stable 4-group order. A search sheet would add chrome (and a tap) without
  saving any tap on any top-3 task, violating U0 (fewer steps) and C16 (one
  path per task). The > 5-item U1 exception therefore does NOT apply here —
  this screen has no find-aid by design, recorded here.
- DEVIATION 2 — NO filter sheet: the honest category facets already ARE the
  group sections (service / approvals / invoices / general, stable order); a
  filter sheet over the same facets would duplicate the sections (two paths to
  the same slice, violating U7 one-path-per-task). Progressive disclosure is
  served by the sections themselves. No remove sheet either: there is no
  destructive action on this screen (mark-read is non-destructive with
  server-rollback forgiveness, U10).

## U-laws application (U0–U14, C17)
- U0 (one read): one row = unread dot + icon → title → body → `category ·
  time` meta. No competing heroes. CARD HIERARCHY (binding): title = the
  workshop's title (the thing the user recognizes); category label = small
  meta (never a pill — rows already carry dot + icon + weight signals);
  timestamp = meta; no invented summaries; borderless group surfaces in light.
- U1 (find fast): NO search icon by design (deviation 1 above — recorded
  reason; triage needs recency, not text-find). Bell placement (top-right,
  next to avatar) unchanged across shell + home precedent (U9).
- U2 (fit the content): inbox rows are heterogeneous (dot + icon + 2-line
  title + 3-line body + meta + chevron) — grouped surfaces, NOT a data table.
  No table on any width (N/A by design). FOLD (binding): at 360x800 the
  summary row + FIRST notification row sit above the fold (idle state with
  data); anything pushing the first row below the fold needs a written reason.
- U3 (no fake actions): chevron + navigation ONLY when `destination(type) !=
  null`; otherwise read-only rows (never guessing); `Mark all read` ONLY when
  `unread > 0`; no invented categories or destinations.
- U4 (no invention): title/body/time/category verbatim from stored fields;
  unknown wire types → General (existing `fromWire` fallback); counts from
  `unreadCount`/`notifications.length` only; zero shown as `0`, never `-`.
- U5 (reachable + legible): full-row 48dp+ tap targets; `Mark all read` in the
  summary row (reachable without scrolling, upper half — the bulk triage
  action); title wraps 2 lines + body 3 lines (never mid-word cut); meta
  1-line ellipsis (secondary text only).
- U6 (states): skeleton mirrors the rows (`AppShimmerSkeleton`: summary line +
  row cards); honest empty (`AppEmptyState`: EXACTLY one icon + one sentence,
  NO action — calm empty, nothing exists to create); error (`AppErrorState` +
  Try again, same `_refresh`); stale data kept with `AppBanner` warning;
  mark-all failure keeps inline notice + Retry (rollback preserved).
  Pull-to-refresh kept.
- U7 (feedback): row tap marks read immediately (optimistic) with silent
  background persist (existing contract); mark-all failure rolls back + shows
  `ntMarkFail` + Retry (forgiveness, U10); destructive actions: none on this
  screen (no confirm needed).
- U8 (no dead ends): every actionable row opens its destination; read-only rows
  carry no chevron (no dead affordance); empty state needs no CTA (U6 calm).
- U9 (consistency): same atoms as vehicles/bookings lists (`AppPageHeader`-grade
  title row, `AppBanner`, `AppEmptyState`/`AppErrorState`); bell + back behavior
  unchanged; category icons/tones from the frozen presentation mapping.
- U10 (RTL): full mirror; timestamps/figures/digits LTR-locked where mixed;
  `EdgeInsetsDirectional` everywhere; direction-implying chevron mirrors in RTL.
- U11 (a11y): row `Semantics` label (read-state + category + title + body +
  time) kept; header `Semantics(header: true)` on group titles kept; bell
  announcement contract ("Notifications, N unread") kept.
- U12 (density): single column compact; max-width 860 kept (existing
  `AppResponsivePage` predicate); groups stack (no multi-column — inbox triage
  is recency-ordered, columns would break scan order).
- U13 (offline): stale list kept + refresh notice; retries inline; no permanent
  "Synced" pill (abnormal → `AppBanner` only, C16).
- U14 (no regression): tap budgets above are ceilings; pull-to-refresh,
  haptics (none on this screen — none added), mark-read + snackbar/notice
  contracts unchanged in behavior.
- C17: any U-law fail caps at 8/16. C16 list adaptations: borderless light
  surfaces, no ALL CAPS added (check `labelOf`/`groupOf` display strings render
  sentence case — note current `SectionHeader` titles come from ARB group names,
  keep verbatim), zero as `0`.

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke `Scaffold` + `WorkspaceAppBar` page chrome → `AppScaffold`
  + `AppAppBar` (title `ntTitle`, back behavior unchanged) — same shell atoms
  as other customer surfaces; bell entry untouched (shell owns it).
- REMOVED: bespoke `_GroupSection` bordered `DecoratedBox` + divider-less
  column → whitespace-separated borderless group surfaces
  (`AppSurfaceCard(outlined: false)` rows with 12 gaps; dark keeps border).
- REMOVED: bespoke `_SummaryRow` `Row` + `TextButton` styling → same row rebuilt
  on tokens (count text + `Mark all read` text-button, visibility predicate
  `unread > 0` unchanged).
- REMOVED: bespoke row chrome (tint `Material` + `InkWell` + dot `Container` +
  icon + chevron `Padding`) → shared atoms (unread tint block, dot, icon,
  chevron) with byte-identical behavior; row hierarchy binding: title first,
  category/time meta last; LTR-locked figures.
- REMOVED: bespoke `_AllCaughtUp` / `_LoadFailure` panels → `AppEmptyState`
  (EXACTLY one icon + one sentence, NO action — calm empty per U6) /
  `AppErrorState` + Try again (same `_refresh`); bespoke skeleton →
  layout-mirroring `AppShimmerSkeleton`; stale + mark-fail notices →
  `AppBanner` variants (same retry handlers).
- MOVED: nothing navigational — `_open` (markRead + conditional push),
  `_markAllRead` (bulk + rollback), `_refresh` — same handlers, new clothes only.
- KEPT: bell + badge (shell), back behavior, `groupOf`/`labelOf`/`tone`/
  `destination` mappings, group bucketing + stable order, read-marker persist +
  rollback, pull-to-refresh, haptics (none), Semantics contracts. No new
  routes. No invented notifications/categories/times. Customer dark wiring kept.

## Fold wireframe (ASCII, 360×800 — summary + first row above fold)
```
+----------------------------------+
| <- Notifications                  |  <- AppAppBar + back
| 3 unread          [Mark all read] |  <- summary row (action only if unread>0)
|----------------------------------|
| Service                           |  <- group title
| [•] 📅 Booking confirmed         |
|     Your Camry … · Booking · 2h  |  <- first row ABOVE fold
|----------------------------------| <- above fold (no bottom nav: pushed page)
| [•] 🧾 Approval needed …         |  <- second row PEEKING
+----------------------------------+
```

## Matrix requirements
- with-data (grouped rows; actionable chevron vs read-only; unread vs read
  treatment) ·
- mark-all (visible when unread > 0; hidden when all read; failure notice +
  Retry + rollback) ·
- empty (all caught up: `AppEmptyState`, no action) ·
- loading (`AppShimmerSkeleton` mirroring summary + rows) ·
- error (`AppErrorState` + Try again) ·
- stale (data + `AppBanner` warning + Retry) ·
- ar (RTL mirrored; chevron flips; category/time meta wraps; figures LTR) ·
- 1.3x (title 2-line + body 3-line wrap — never clips) ·
- 320px (single column; summary + first row intact) ·
- dark (soft charcoal, bordered surfaces, AA contrast) ·
- tablet (max-width 860 centered; no rail — pushed page, not a destination).

## States matrix
| State | Current | After (shared atoms, same behavior) |
|---|---|---|
| Loading (empty) | `AppSkeleton` text + 6x card-74 | `AppShimmerSkeleton` mirroring summary + rows |
| Empty (no notifications) | `_AllCaughtUp` panel (icon + title + body) | `AppEmptyState` (1 icon + 1 sentence, NO action) |
| First-load error | `_LoadFailure` + `FilledButton(ntRetry)` | `AppErrorState` (verbatim title/body + retry, same `_refresh`) |
| Stale (data + loadError) | `CustomerRefreshNotice` + data | `AppBanner` warning + data (same retry) |
| Mark-all failure | `CustomerNoticePanel` + Retry | `AppBanner` error + Retry (same `_markAllRead`, rollback kept) |
| All read | `ntAllRead` muted, no button | same (no button — calm) |
| Dark / ar / 320px / 1.3x / tablet | untested | covered by char + capture matrix |

## Copy keys needed
Reuse ALL existing `nt*` keys (`ntTitle`, `ntUnread`, `ntAllRead`,
`ntMarkAll`, `ntMarkFail`, `ntRetry`, `ntLoadTitle`, `ntLoadBody`,
`ntCaughtUp`, `ntCaughtUpBody`, `ntGroup*`, `ntType*`, `ntReadWord`,
`ntUnreadWord`) + `stRefreshFail`/`stRetry`. New keys: NONE expected (no new
copy — empty state has no action, no search/filter chrome). If the build finds
any hardcoded string without a key, add it (en+ar) and list for phase 9.

## Acceptance
- U0–U14 walk (ANY U-law fail caps at 8/16 — the no-search/no-filter deviations
  above are the sanctioned exceptions with written reasons; every other U-law
  applies in full); C16 hard-reject checklist (caps 10/16): borderless light
  surfaces, one path per task (no duplicate triage entries), no permanent
  status pills, no ALL CAPS added, zero as `0`, summary + first row above fold
  at 360x800, empty = one icon + one sentence + NO action (calm empty),
  no dead affordances, no fake categories/destinations, no new routes, taps
  never regress (table above).
- Airbnb rubric ≥ 12/16 to pass.
- Gates (kept): characterization tests on the CURRENT list first,
  before-images captured, migration table (current → shared atoms),
  reviewer process per redesign mandate, NO logic changes.
- Verify from code: tap counts, route/destination mapping, `groupOf`/`labelOf`
  predicates, key names, bell/shell consumer constraint.
