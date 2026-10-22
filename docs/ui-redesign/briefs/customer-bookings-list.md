# UX Brief — customer bookings / service-history list

## Scope
`apps/customer_app` bookings list surface: `widgets/customer_bookings_tab.dart`
(header `_BookingsHeader` + `_BookingSection` x2 + `_FailedBookingsSection` +
`_NoBookings` + loading/error) + `widgets/customer_booking_item.dart` (one
row) + `widgets/customer_failed_booking_item.dart` (failed row) + tab shell
`widgets/customer_scaffold.dart` index 1. Routes touched only as existing
destinations: `AppRoutes.customerBookingDetail` (extra), `customerServiceStatus`,
`approvalsLocation(estimateId:)` (`/customer_approvals?estimateId=`),
`customerBookService` (`/customer_book_service_view`), `customerAddVehicle`
(`/add-vehicle`). No new routes. No logic changes (providers/state/routes/API/
sync/predicates/Keys) — STOP + report if logic is needed.

Bookings + history are ONE surface (two `_BookingSection`s in one tab:
active/upcoming+in-service and history). No separate history surface exists,
so this single brief covers both.

## User goal
A customer opens Bookings and in one glance finds the right appointment
(service + vehicle + date), sees what actually needs them (approval / trackable
live stage), and reaches Open / Review / Track / Retry without hunting. One
screen, one primary task: find booking → act.

## Current behavior (verified from code)
- Entry: `CustomerScaffold` bottom nav, 4 destinations (Home, Bookings,
  Vehicles, Profile); bookings = `selectTab(1)`, bottom nav on every width —
  NO rail (consumer contract, `customer_scaffold.dart` header comment).
  No search icon. No filter icon.
- Header (`_BookingsHeader`): `bkTitle` headline (w800) + count subtitle via
  `_subtitle()` (`bkUpOne/bkUpMany` · `bkInOne/bkInMany` · `bkPastOne/bkPastMany`,
  else `bkSubDefault`) + `TextButton.icon` Book (`bkBookCta`) only when
  `bookings.isNotEmpty`; when empty the CTA lives inside `_NoBookings`
  (`FilledButton.icon`: `bkBookCta` if hasVehicles else `garHeroAdd`).
- List: `_BookingSection` = `SectionHeader(title+count)` + bordered
  `DecoratedBox` (`surface`, radiusCard, outlineVariant) + dividers between
  `CustomerBookingItem`s; two sections side-by-side in `AppSplitView`
  (primary 3/secondary 2, medium 1/1) when both non-empty, else single.
  Section 1 title = `bkUpcoming` or `bkUpcoming & bkInService.lower`;
  section 2 title = `bkHistory`.
- Row (`CustomerBookingItem`): date-block (day+month+time) or icon tile;
  title (service or "Service appointment", 2-line) + `StatusPill`
  (`statusLabel.toUpperCase()`, dot, tone via `CustomerServiceTracking.bookingTone`);
  plate chip (`CustomerPlateChip`) + vehicle 1-line; stage line
  (`Current stage · X`, primary) when trackable; approval line + estimate
  amount when `approvalRequired`; raw schedule line when unreadable;
  reference mono LTR line; contextual `_RowAction` right-aligned
  (`Review` → `onReviewApproval(estimateId)` / `Track service` → Status).
  Whole row `InkWell` → `onOpen` (detail). Semantics label joined.
- Failed (`_FailedBookingsSection` + `CustomerFailedBookingItem`): `SectionHeader`
  (`bkFailedTitle`+count) + bordered box + dividers; row = error tile +
  title + `StatusPill('NOT SENT')` ALL CAPS + plate/vehicle + schedule +
  2-line failure copy (hardcoded EN, not ARB) + `Remove` TextButton +
  `Retry` FilledButton (busy → disabled + "Retrying…"); remove =
  `showAppConfirmationDialog` (destructive) → `failedBookingSync.remove` +
  invalidates; retry → `failedBookingSync.retry` + invalidates + refresh +
  `bkSendFail` snackbar when refused.
- States: `EmptyState` first-load error (`bkLoadFailTitle/Body` + `bkRetryCta`);
  `AppSkeleton` loading (header lines + 282/188 cards); `_NoBookings` empty
  (`CustomerSurfacePanel` + icon + title/body + filled CTA); `CustomerRefreshNotice`
  stale + data; `RefreshIndicator` pull-to-refresh.
- Truth rules (from `customer_bookings_presentation.dart`): groups from
  `groupOf()` (inService/upcoming/history sets); sorts `sortByUpcoming` /
  `sortByRecent`; labels `dateLabel/scheduleLabel/timeLabel/referenceOf`
  degrade to raw values, never invented; `formatAmount` from dash state.

## Top tasks with tap counts (BEFORE = current UI, AFTER must be ≤)
1. Open the bookings list — before: bottom-nav Bookings tab = **1 tap**
   (0 if deep-linked via `bookingsLocation`). After: ≤ 1 tap.
2. Open a booking's detail — before: tab (1) + row tap (1) = **2 taps**
   (+ scroll to the row). After: row stays directly tappable, whole card
   opens detail: **≤ 1 tap from the list, ≤ 2 taps from launch**, ≤ same scroll.
3. Track the live service behind a booking — before: tab (1) + `Track service`
   row action (1) = **2 taps**. After: `Track service` stays DIRECTLY on the
   card (visible action, no menu dive): **≤ 1 tap from list, ≤ 2 from launch**.
4. Review an estimate needing approval — before: tab (1) + `Review` (1) =
   **2 taps**. After: `Review` stays DIRECTLY on the card: **≤ 1 from list**.
5. Book a service — before: tab (1) + header/empty-state Book (1) = **2 taps**,
   then existing flow (unchanged). After: ≤ 2 taps (header when non-empty,
   empty-state CTA when empty — never both, no duplicate entry point).
6. Retry / remove a failed (not-sent) booking — before: inline Retry/Remove
   (1) + confirm dialog (1 confirm) = **1 tap + 1 confirm for remove, 1 tap
   for retry**. After: ≤ 1 tap inline; remove confirm becomes a confirmation
   BOTTOM SHEET (destructive, NO undo — undo would be logic); retry stays
   inline FilledButton.

| Task | Before | After budget |
|---|---|---|
| Open list | 1 tap | ≤ 1 tap |
| Open booking detail | 2 taps (+scroll) | ≤ 1 tap from list, ≤ 2 from launch, ≤ same scroll |
| Track live service | 2 taps | ≤ 1 tap from list, ≤ 2 from launch (direct on card) |
| Review estimate | 2 taps | ≤ 1 tap from list, ≤ 2 from launch (direct on card) |
| Book service (reach flow) | 2 taps | ≤ 2 taps (header when non-empty, empty-state CTA when empty) |
| Retry failed booking | 1 tap inline | ≤ 1 tap inline |
| Remove failed booking | 1 tap + 1 confirm (dialog) | ≤ 1 tap + 1 confirm (bottom-sheet destructive, no undo) |

Frequent tasks (find booking, open, track/review) stay single-screen; the
book-service wizard is the only multi-step flow and is out of scope.

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: **does not exist** (confirmed — no `references`
  dir under `docs/ui-redesign/`).
- `AIRBNB_PATTERNS.md`: **missing anywhere in the repo** (confirmed — repo-wide
  glob `**/AIRBNB_PATTERNS*` returns nothing; only mention is
  `docs/ui-redesign/evaluation/technician-home-test-migration.md:183`, which
  itself records the file/dir does not exist).
- Mapping into `AIRBNB_PATTERNS.md` is therefore **unmet**; this brief proceeds
  from the vehicles-list precedent (`docs/ui-redesign/briefs/phase-6-vehicles-list.md`
  + `docs/ui-redesign/evaluation/phase-6-vehicles-list-test-migration.md` +
  `WIDGET_MIGRATION_MAP.md` vehicles-list rows): `AppPageHeader` + header
  search/filter icons (U1, > 5-item threshold) opening full-screen/modal sheets
  over loaded items with no new routes/logic; borderless light cards;
  `AppBanner` for stale/failed; `AppEmptyState`/`AppErrorState`/`AppShimmerSkeleton`;
  remove-confirm bottom sheet; sentence case (remove `.toUpperCase()`); zero as `0`.
- Never pretend otherwise: nopattern file was consulted; all pattern claims cite
  the vehicles-list precedent above.

## Vehicles-list pattern reuse (UNLESS top-3 says otherwise)
Re-used IN FULL — no deviation. Reason: the top-3 tasks (find booking → open /
track / review) are the same find-and-act shape as vehicles (find vehicle →
book/edit): a scannable list with per-row frequent actions, honest group
facets, and failed-item recovery. So: header with count, search icon only when
> 5 items (U1-exception note below), borderless cards, frequent actions
(`Review` / `Track service` + row-tap open) directly on the card, filter sheet
(honest `groupOf` facets) + remove-confirm sheet (failed bookings), and
empty/loading/error states per vehicles precedent.

## U-laws application (U0–U14, C17)
- U0 (one read): one card = service title → ONE status pill → vehicle·plate →
  schedule → reference meta. No competing heroes. CARD HIERARCHY (binding):
  title = service name (or "Service appointment" fallback — the thing the user
  recognizes); status pill ONLY from existing `statusLabel`+tone (never invented);
  vehicle/plate = meta; booking/job-card ref = small mono LTR meta; date-block
  kept as the scannable anchor; borderless in light (soft shadow or flat,
  whitespace separation; C16).
- U1 (find fast): header search icon top-right opens a full-screen search sheet
  over loaded bookings (service/vehicle/plate/reference substring; result tap
  closes + reveals the row; row actions unchanged). PROGRESSIVE-DISCLOSURE
  EXCEPTION (the ONE sanctioned U1 exception, same as vehicles-list): the
  search icon appears ONLY when the loaded list has MORE THAN 5 items; with
  ≤ 5 items show cards only, no search icon (fully scannable; search chrome
  would add taps without saving any). Filter funnel beside search under the
  same threshold.
- U2 (fit the content): booking rows are heterogeneous (date-block + pill +
  stage/approval + actions) — grouped cards, NOT a data table. No table on any
  width (table matrix cell = N/A by design). FOLD (binding): at 360x800 the
  header + FIRST booking card sit above the fold (above the bottom nav, idle
  state with data) with the SECOND card peeking; anything pushing the first
  card below the fold needs a written reason in the build log.
- U3 (no fake actions): only real states — `Review` only when
  `approvalRequired` + estimateId; `Track service` only when the row owns the
  live job (`liveServiceFor` non-null); reference only when `referenceOf`
  non-empty; no invented slots/prices/scores.
- U4 (no invention): dates/times/refs verbatim via existing helpers (unreadable
  → raw value); zero shown as `0`, never `-`; counts from list lengths only.
- U5 (reachable + legible): 48dp targets on all actions; actions Wrap (never
  clip) at 320px / 1.3x; refs/plates stay LTR-locked; title wraps ≤ 2 lines,
  never mid-word cut.
- U6 (states): skeleton mirrors the cards (`AppShimmerSkeleton` mirroring card
  layout: header lines + card shapes); honest empty (`AppEmptyState`: EXACTLY
  one icon + one sentence + one Book/Add action → same destinations);
  error (`AppErrorState` + Try again, same retry handler); stale data kept with
  `AppBanner` warning (`CustomerRefreshNotice` contract); failed bookings keep
  inline Retry + bottom-sheet Remove. Pull-to-refresh kept.
- U7 (feedback): remove confirm becomes a confirmation BOTTOM SHEET (same
  `failedBookingSync.remove` + invalidate contracts; NO undo — undo would be
  logic); retry failure keeps `bkSendFail` snackbar; busy states disable only
  the acting row's controls.
- U8 (no dead ends): every approval/trackable row offers its action; badge-only
  otherwise (no dead affordance); empty state always offers Book/Add; history
  never sits under Upcoming (existing `groupOf` order kept; if the feed ever
  misorders, log in LOGIC_FOLLOWUPS.md, do NOT filter silently).
- U9 (consistency): `AppPageHeader`, `AppChip` filter sheet, `AppBanner`,
  `AppEmptyState`/`AppErrorState` — same atoms as vehicles-list.
- U10 (RTL): full mirror; plate/ref/figures/digits LTR-locked;
  `EdgeInsetsDirectional` everywhere.
- U11 (a11y): row `Semantics` label (service + status + vehicle/plate + schedule
  + stage/approval + ref) kept; failed-row live-region kept; header
  `Semantics(header: true)` kept.
- U12 (density): single column compact; 2-col split (active | history) on
  medium+ when both sections non-empty (existing `AppSplitView` predicate kept,
  rebuilt on shared atoms).
- U13 (offline): stale list kept + refresh notice; retries inline; no permanent
  "Synced" pill (abnormal → `AppBanner` only, C16).
- U14 (no regression): tap budgets above are ceilings; pull-to-refresh,
  haptics, confirmation + snackbar contracts unchanged in behavior
  (presentation may move dialog → bottom sheet).
- C17: any U-law fail caps at 8/16. C16 list adaptations: search-sheet,
  borderless light cards, no ALL CAPS added (remove `.toUpperCase()` on status
  + `NOT SENT`; sentence case via theme), zero as `0`.

## Search-icon pattern (list-scoped, no new routes/logic)
- `AppPageHeader` (title `bkTitle` + count subtitle verbatim via `_subtitle()`)
  with search icon top-right (U1) — SHOWN ONLY WHEN the loaded bookings list
  has MORE THAN 5 items (progressive disclosure; the ONE sanctioned U1
  exception). With ≤ 5 items: cards only, NO search icon.
- Icon opens a full-screen search sheet over the loaded bookings:
  text field filters by service / vehicle / plate / reference substring
  (case-insensitive; plates punctuation-insensitive); results render as compact
  rows (tapping closes the sheet and reveals the record via `ensureVisible`;
  record actions unchanged).
- Empty query = full list; no-match = filter-no-match state with Clear control.
- No new routes, no server queries, no invented entries. Sheet respects RTL +
  1.3x (field + list scroll, no clipping).

## Filter sheet design (predicates owned by existing logic)
- Filter entry: funnel icon beside search (header, shown together with search
  when the > 5-item threshold is met) — opens bottom sheet with the only honest
  facets the data supports: booking group (All / Upcoming / In service /
  History), derived via the existing `CustomerBookingsPresentation.groupOf`
  per booking. NO service/vehicle/date facets (no honest backing predicate).
- Sheet: single-select chip group + Show results CTA + Clear; selection filters
  the rendered rows in place; section headers/counts update verbatim
  (existing `_subtitle` parts recomputed on the filtered list); no-match =
  filter-no-match state with Clear.
- Logic boundary: sheet owns presentation only; group derivation stays in
  `CustomerBookingsPresentation.groupOf` — unchanged.

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke `_BookingsHeader` chrome → `AppPageHeader` (title + count
  subtitle verbatim + search/filter `AppIconButton`s top-right ONLY when > 5
  items + `TextButton.icon` Book kept when non-empty).
- REMOVED: bespoke `_BookingSection` bordered container + divider code →
  whitespace-separated `AppSurfaceCard(outlined: false)` rows (borderless light
  w/ shadow, bordered dark); same split predicate (two sections → `AppSplitView`
  medium+, else single column).
- REMOVED: bespoke row chrome (`StatusPill.toUpperCase`, `_DateBlock`/`_IconTile`
  container, `_StateLine`, `_RowAction` styling) → shared atoms (date-block
  anchor kept as presentation, `AppStatusChip` sentence-case, context lines,
  direct `Review`/`Track service` actions on the card, row-tap opens detail);
  card hierarchy binding: title = service, pill from existing status, ref = meta.
- REMOVED: bespoke `_NoBookings` / first-load `EmptyState` panels →
  `AppEmptyState` (EXACTLY one icon + one sentence + one Book/Add action) /
  `AppErrorState` + Try again (same retry handler); bespoke skeleton →
  layout-mirroring `AppShimmerSkeleton`; stale → `AppBanner` (same retry).
- MOVED: failed rows' `showAppConfirmationDialog` → confirmation bottom sheet
  via `showAppModalSheet` (destructive confirm, NO undo; same
  `failedBookingSync.remove` + snackbar contracts); retry stays inline.
- Hardcoded EN failure copy in `customer_failed_booking_item.dart`
  ("We couldn't send…", "The workshop hasn't…", "Service appointment",
  "Current stage · …", "Estimate … awaiting approval", "Approval needed…",
  "Review", "Track service", "NOT SENT", "Remove", "Retry", "Retrying…")
  moves into ARB (new `bkf*`/`bkRow*` keys, en+ar) — copy unchanged in EN,
  newly translated in AR; no other copy invented.
- KEPT: all providers/sync/refresh/selectTab, `groupOf`/`sortByUpcoming`/
  `sortByRecent`/`scheduleLabel`/`referenceOf` verbatim rules, bottom nav
  (no rail), pull-to-refresh, haptics, confirmation + snackbar contracts,
  `selectDestination` deep-linking. No new routes. Customer dark wiring kept.

## Fold wireframe (ASCII, 360×800 — header + first card above fold, second peeking)
```
+----------------------------------+
| Bookings               [🔍][⧩][+]|  <- 🔍+⧩ only when > 5 items; ≤ 5: [+] only
| 2 upcoming · 1 in service · 3 past|
|----------------------------------|
| [22 SEP · 9:00 AM] Oil change    |
|  Booked · Toyota Camry [ABC 123] |
|  Tue, 22 Sep 2026 · 9:00 AM      |
|  BK-1001                   [Open]|
|  [Review estimate]               |  <- frequent actions direct on card
|----------------------------------| <- above fold (nav below)
| [IN-SERVICE] Brake pads …        |  <- second card PEEKING
+----------------------------------+
| Home | Bookings | Vehicles | Prof |
```

## Matrix requirements
- empty (no bookings: `AppEmptyState` + Book/Add → same flows; never zero-filled) ·
- with-data (active + history sections; approval + trackable + reference inline) ·
- failed (not-sent rows: inline Retry + bottom-sheet Remove; busy disables row) ·
- search (icon shown ONLY when > 5 items → full-screen sheet over loaded
  bookings; ≤ 5 items = cards only, no icon; result reveals record; no-match
  + Clear; no new routes) ·
- filter (group-facet sheet; counts update; no-match + Clear) ·
- ar (RTL mirrored; plate/ref/figures/digits LTR-locked) ·
- 1.3x (actions wrap, title ≤ 2 lines — never clips) ·
- 320px (single column; header + first record intact; actions stack) ·
- tablets (medium 2-col active|history split, max-width 1080; bottom nav stays,
  no rail — consumer contract; table variant N/A by design per U2) ·
- dark (soft charcoal surfaces, bordered cards, AA contrast, no neon).

## States matrix
| State | Current | After (shared atoms, same behavior) |
|---|---|---|
| Loading (empty) | `AppSkeleton` header + 282/188 cards | `AppShimmerSkeleton` mirroring header + cards |
| Empty (no bookings, no failed) | `_NoBookings` panel + filled Book/Add | `AppEmptyState` (1 icon + 1 sentence + 1 Book/Add action) |
| First-load error (empty + loadError) | `EmptyState` + `bkRetryCta` | `AppErrorState` (verbatim title/body + retry, same `_refresh`) |
| Stale (data + loadError) | `CustomerRefreshNotice` + data | `AppBanner` warning + data (same retry) |
| Failed bookings | bordered box + `NOT SENT` pill + inline Retry/Remove(dialog) | borderless cards + sentence-case pill + inline Retry + bottom-sheet Remove |
| No-match (search/filter) | (did not exist) | one-line no-match + Clear |
| Dark / ar / 320px / 1.3x / tablet | untested | covered by char + capture matrix |

## Copy keys needed
Reuse existing `bkTitle/bkUpcoming/bkInService/bkHistory/bkBookCta/bkEmpty*/bkLoadFail*/bkRetry*/bkUp*/bkIn*/bkPast*/bkSubDefault/bkFailedTitle/bkSendFail/bkRemove*/bkKeepCta/bkReview/garHeroAdd/stRefreshFail/stRetry` + new keys only for
search-sheet hint/no-match + filter-sheet labels + filter-no-match + failed-row
and row-action strings moving into ARB (en+ar, listed for phase 9). No ALL CAPS
strings added.

## Acceptance
- U0–U14 walk (ANY U-law fail caps at 8/16 — the > 5-item search-icon threshold
  is the ONE sanctioned U1 exception; every other U-law applies in full); C16
  hard-reject checklist for lists (caps 10/16): search-sheet over items
  (progressive disclosure: only when > 5 items), filter sheet on honest
  predicates, borderless light cards, card hierarchy (title = service, pill
  only from existing status, ref = meta), no ALL CAPS added, zero as `0`,
  first card above fold + second peeking at 360x800, empty = one icon + one
  sentence + one action, remove = confirmation bottom sheet (destructive, no
  undo), no dead affordances, no fake facets/statuses, no new routes, taps never
  regress (table above).
- Airbnb rubric ≥ 12/16 to pass.
- Gates (kept): characterization tests on the CURRENT list first,
  before-images captured, migration table (current → shared atoms),
  reviewer process per redesign mandate, NO logic changes.
- Verify from code: tap counts, route names, `groupOf` predicate, verbatim
  helpers, key names, scaffold no-rail consumer constraint.
