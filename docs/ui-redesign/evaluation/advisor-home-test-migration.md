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

## Rebuild rows (C16 hard-reject pass — structure changed, behavior verbatim)

Branch: `ui/phase-6-customer`. Rebuild is presentation + widget-tree only:
providers, routes, sync logic, sort order, search predicate, selection
state and Keys untouched. No new ARB keys (all copy reused, en+ar
regenerated untouched). No `LOGIC_FOLLOWUPS.md`: the "+2 today"
investigation verdict is copy (see below), so no follow-up file was
created per the task's only-if-logic rule.

| Test | Old | New | Kind |
|---|---|---|---|
| header greets with bell badge and avatar, no sync pill | `OfflineStatusPill` in header, header search `AppIconButton`, `AppPageHeader` | compact custom header (sentence-case date + greeting maxLines 2 + muted branch·shift; bell badge offset above the glyph + avatar top-right); no `OfflineStatusPill`, no header search icon; single pinned `AppSearchBar` is the one search path | structural |
| abnormal sync surfaces once as a banner, never a pill (NEW) | n/a | online + queued 0: nothing; offline: warning `AppBanner` (`advisorOfflineNotice`); queued: info `AppBanner` (`connectivityQueuedCount`) | structural |
| first assigned order sits above the fold at 360x800 (NEW) | n/a | measures first card rect bottom <= bottom-nav rect top at 360x800 idle | structural |
| quick actions are one scrolling row, count once | 3 equal pills / 2x2 reflow, `Approvals (2)` label + badge, emphasized New-job tile | ONE horizontal `SingleChildScrollView` tile row (120px tiles, 2-line wrap, peek); neutral tiles (no filled tile next to hero CTA); approvals count on badge ONLY (`Approvals` label, `findsNothing` for `(2)`) | structural |
| pinned pill search shows hint, opens sheet on submit | scan `AppIconButton` beside the pill | no separate scan button (scan lives only in quick-actions tile); submit records the recent AND opens the existing `AdvisorSearchSheet` (same predicate/recents/scan CTA inside); Ctrl+K unchanged | structural |
| assigned jobs render as media cards with Show all | job-id-first cards | customer/vehicle-first title, then ONE status chip, then meta sentence, job id as small LTR mono meta; chevron kept; urgent-first order kept | structural |
| (others: hero, hero zero-state, filter predicate, empty, loading, error) | — | unchanged (verbatim) | behavior |

New `packages/shared_core/test/app_hard_reject_guards_test.dart` (9
testWidgets, hermetic, bundled fonts in setUpAll): (a) borderless light
cards for `AppMediaCard` / `AppSurfaceCard(outlined:false)` /
`AppListGroup` (card-radius decorations carry no `Border`), (b) no
all-caps Latin for cased input in `AppPageHeader` (no-eyebrow usage) /
hero-style card copy, (c) tap targets >= 48dp for `AppPillButton` (all
sizes) / `AppIconButton` (48x48) / `AppTileRow`, (d) `AppBadge` rect
disjoint from the icon glyph rect in the offset-outside pattern. All pass.

## U-laws rebuild rows (C17 — structure changed, behavior verbatim)

Branch: `ui/phase-6-customer`. Presentation + widget-tree only: providers,
routes, sync logic, sort order, search predicate, selection state and Keys
untouched. No new ARB keys (all copy reused; en+ar untouched). One new doc:
`docs/ui-redesign/LOGIC_FOLLOWUPS.md` (data-feed issue only — see U8 row).

| Test | Old | New | Kind |
|---|---|---|---|
| header greets with search icon, bell badge and avatar | no header search icon (pinned pill was the only visible path); greeting `maxLines: 2` WITH ellipsis | date + icons row (search `AppIconButton` top-right next to bell + avatar, same placement as customer home per U9); greeting full-width `maxLines: 2` with NO ellipsis (full name wraps); muted branch·shift kept; badge offset-disjoint + avatar unchanged | structural |
| search icon in header AND no inline `TextField` in the page body (guard f) | one `AppSearchBar` pill + recents + inline filter state in the page body | inline pill + pinned `SliverAppBar` + divider band + home filter state REMOVED; header search icon opens the existing `AdvisorSearchSheet` FULL-SCREEN (tight full-size box via the existing bottom-sheet mechanism + `viewInsets` padding; sheet predicate/scan/autofocus verbatim); sheet EXTENDED additively (`recents` + `onRemember`) so the home-owned session recents survive across sheet opens and the normal case shows them; Ctrl+K unchanged — one search path (U1/U7) | structural |
| hero zero-state is a calm status row, no filled button | `0 inspections due today` title + caught-up sentence + filled `View jobs` button | compact calm status row (success check + `advisorHeroCaughtUp` sentence), NO filled button, no `0 …` title (U6); due > 0 hero unchanged (ONE hero + ONE CTA) | structural |
| quick actions are 3 equal columns, count once | ONE horizontal `SingleChildScrollView` tile row (120px tiles + peek) | `Row` of 3 `Expanded` equal columns, no scroll, no cut-offs (fits 360px + 1.3x); neutral tiles; icon + short label (existing keys) wrapping ≤ 2 lines on word boundaries; approvals count on badge ONLY | structural |
| assigned list keeps conditional See-all | `See all` always rendered (even when all ≤ 6 shown) | `See all` rendered ONLY when more items exist than shown (`matches.length > visible.length`); hero `View jobs` stays the one persistent path into Jobs (U7); LIST kept, not a carousel (N ≤ 6, statuses need side-by-side comparison, carousel would hide urgent items and cost the above-fold first order) | structural |
| work summary REMOVED | `Work summary` 3-stat row (`Total orders` / `In progress` / `Ready`, zero as `–`, `See all` → Reports) | removed: derivable from the list itself (drives no decision), zero-as-dash violated U11, second `See all` duplicated paths (U7) | structural |
| page uses exactly one background color (guard h) | pinned search band (`surface` `ColoredBox` + bottom divider strip) behind rows | band + divider removed with the pill; page background is the theme page token only (`theme.scaffoldBackgroundColor` via `DashboardShell`) | structural |
| (e) no ellipsis on greeting with a LONG name at 360x800 | n/a | pumps a 28-char name, asserts the greeting `Text` has `maxLines: 2` with non-ellipsis overflow and no `…` in the header | structural |
| (g) tap count to job detail ≤ before | n/a | before-count = **1 tap** (launch lands on Today with the first job visible; single tap opens the detail); pumps a stub `GoRouter`, taps the first card once, asserts the detail route is shown (1 ≤ 1 ≤ 3) | structural |
| assigned inline-filter test (`assigned search filters by id, customer and vehicle`) | filtered the home list via the inline pill | REMOVED with the pill; same predicate is covered by the sheet test below (sheet predicate verbatim, never changed) | structural |
| search sheet filters with recents + scan (replaces inline-filter test) | n/a | taps the header search icon, enters a query in the sheet, asserts same-predicate results + scan action present; behavior assertions verbatim | structural |
| (others: bell badge, banner, above-fold, hero due-state, empty, loading, error) | — | unchanged (comments updated for the pill removal where they named it) | behavior |

`packages/shared_core/test/app_hard_reject_guards_test.dart` intentionally
untouched: guards (e)–(h) assert advisor-home widgets, and `shared_core`
cannot import `staff_app` (dependency direction). They live in
`apps/staff_app/test/advisor_home_view_test.dart` under
`hard-reject U-guards (e)–(h)`.

## Tap counts before → after (U3; role's top-3 tasks from launch)

- Open an assigned job: **1 → 1** (first card above the fold, single tap;
  most-frequent task ≤ 2 ✓).
- Create a job card: **1 → 1** (New-job tile, no scroll).
- Search to results: **3 → 2** (before: focus pill + type + submit-which-opens
  the sheet; after: tap search icon + type — sheet autofocuses with recents).

## +2 re-verdict (copy, not data/logic — no code changed)

Re-confirmed against the same sources: ARB `advisorDeltaToday`
(`app_en.arb:181`, `app_ar.arb:84`) renders
`advisorDashboardProvider` → `AdvisorStatsEntity.newJobCardsToday` ←
backend `AdvisorStatsResponse.newJobCardsToday` 1:1. With the summary
removed, the hero sentence is now the sole home reader of that field —
still honest copy from a single source, no logic change, no follow-up.

## Completed-under-Assigned verdict (U8 — FEED, behavior kept)

- Sort: innocent — `_sortedUrgentFirst` only reorders (completed rank 2
  sorts last, stable within rank); it never admits or excludes.
- Fixture: innocent mirror — the test fixture includes a completed card
  because the feed returns one.
- **Feed: responsible** — `advisorRecentJobCardsProvider` returns the
  status-agnostic server page (`getJobCards(page: 1, size: 50)`) plus local
  intake cards with no status filter, so completed/delivered cards render
  under "Assigned work orders".
- Per U8 the home does NOT filter silently: behavior kept as-is, issue
  logged in `docs/ui-redesign/LOGIC_FOLLOWUPS.md` (feed, evidence,
  proposed owner) for the backend/product owner.

## +2 investigation record (round-1 C16 pass — superseded in detail, verdict stands)

- ARB key: `advisorDeltaToday` ("+{count} today" / "+{count} اليوم",
  `apps/staff_app/lib/l10n/app_en.arb:181`, `app_ar.arb:84`).
- Data feed: backend `AdvisorStatsResponse.newJobCardsToday`
  (`packages/shared_core/lib/src/models/advisor_models.dart`) mapped 1:1
  by `advisorDashboardProvider` into
  `AdvisorStatsEntity.newJobCardsToday`
  (`apps/staff_app/lib/features/advisor/presentation/providers/advisor_providers.dart:62-86`).
- Superseded detail: round-1 noted "the hero sentence AND the summary
  Total delta both read that same field" — the U-laws rebuild REMOVED the
  summary, so the hero sentence is now the sole home reader. Verdict
  unchanged: honest copy from a single source — no logic bug, no logic
  change, no follow-up file.
