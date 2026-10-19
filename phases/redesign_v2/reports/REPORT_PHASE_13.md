# REPORT PHASE 13 — Owner Executive Cockpit & Dashboard Operations

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_13.md`
**Execution Phase:** Concept A V2 — Phase 13 (Archetype 8: Executive Cockpit & Financial Desk)
**Specification:** `phases/redesign_v2/implementation/PHASE_13_OWNER_COCKPIT_OPERATIONS.md`
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-19
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: screen-level redesign (not a colour refresh) of the owner
> executive workspace — shell, revenue cockpit, sales leaderboard, comms
> thread, activity log — on the centralized theme + shared-widget
> architecture, in house-grammar siblinghood with the advisor hub. Every
> figure is a frozen provider value rendered verbatim; anything without a
> contract (target series, per-advisor ranks/averages/conversion, queued-sync
> count, persisted last-sync, device model) is omitted honestly rather than
> faked. Providers/API/models/persistence/routes are byte-identical, and the
> staff tree was never touched.

---

## 0. Baseline the dirty tree (§0 directive — done FIRST, no code)

The tree was clean on `redesign_v2` (Phase 12 committed as `83217fe0`;
`git status` empty), so this phase started with zero floating diffs. The
owner dir was classified file-by-file before any code was written.

| Path | Disposition | Evidence |
| :--- | :--- | :--- |
| `owner/.../dashboard/presentation/**` (view, body, 4 tabs, 12 widgets) | REBUILD (pre-redesign prototype) | Hardcoded EN copy, bespoke painters/cards/buttons, direct `AppColors`, bool-only sync thinking, no l10n/search/pill/states |
| 07.1 migration (`OwnerAppBar`/`HeaderBanner`/`KpiCard` → shared) | VERIFIED current, KEPT | Code refs to deleted primitives: zero (only doc-comment prose, which the 07.1 guard strips); `KpiGrid`→`AppKpiCard` composition kept |
| `apps/staff_app/**` | READ-ONLY, zero touches | Final `git status` shows no `staff_app` paths (instant-FAIL rule respected) |
| Owner suites 31/31 green + analyzer 0 (pre-phase run) | KEPT green | Baseline recorded before rebuild |
| `owner l10n` (5 keys, auth shell only) | EXTENDED | Dashboard chrome had zero localized strings |
| Owner goldens | NONE existed | First baseline created this phase (20) |
| `test/features/dashboard/owner_dashboard_test.dart` (spec path) | DID NOT EXIST | Created this phase (11 contract tests) |

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| Shell | `DashboardBody` + `_OwnerChrome` | `widgets/dashboard_body.dart` | `/owner-dashboard` | frosted app bar, period selector, ⌘K palette, offline pill (banner off), rail ≥600 / bottom nav, 4 tabs |
| O1 | `OwnerDashboardPage` (cockpit) | `widgets/owner_dashboard_page.dart` | shell tab 0 | hero pod, micro-pods, 2 curves (swipe/split/3-col), register table+rows, 12 actions; loading/empty/error |
| O2 | `TopSalesPage` (leaderboard) | `widgets/top_sales_page.dart` | shell tab 1 | expandable category rankings, count pill; empty |
| O3 | `MessagesPage` (comms) | `widgets/messages_page.dart` | shell tab 2 | composer (roster dropdown + body + send + toasts), server-merged history; empty |
| O4 | `OwnerActivityFeedTab` (log) | `widgets/owner_activity_feed_tab.dart` | shell tab 3 | day-grouped feed, relative times, real-route taps; loading/empty |
| — | `PeriodDropdown` | `widgets/period_dropdown.dart` | app-bar selector | localized display over frozen state values |
| — | `KpiGrid` | `widgets/kpi_grid.dart` | kept, unused by cockpit | Still owned by 07.1/responsive suites (test references exist → not zero-ref → kept) |

Routes (all 12 destinations), `DashboardUiNotifier` methods, `TeamNotifier`,
`OwnerRemoteDataSource`, entity shapes, Hive boxes (`owner_messages`),
message payloads and the role guard are **unchanged**.

---

## 2. Before / after composition (per screen) — task → concept → composition

| Screen | Old got WRONG (one line) | New does DIFFERENTLY (one line) | Task → Concept → Composition | Viewport @390 EN |
| :-- | :--- | :--- | :--- | :--- |
| Shell | Bare `WorkspaceAppBar` (title only) + hardcoded rail labels + banner on. | Frosted bar with period selector, search trigger, offline pill; localized rail; banner off. | command the business → executive chrome → bar + rail + palette + pill | chrome ≈112px |
| Cockpit (O1) | Prototype stack: ops header + KPI grid + register table + 2 bespoke charts + 12 hex-accent buttons. | Revenue hero pod → micro-pods → shared sparkline curves → register table → theme-ink action rows. | read the money first → financial instrument cluster → hero + pods + curves + table | hero ≈50% |
| Leaderboard (O2) | Bespoke expandable cards with hardcoded headers and static success hex. | Rank-badged category cards with count pill, theme tones, 2-up grid on desktop. | see what sells → ranked categories → expandable rank rows | list ≈70% |
| Comms (O3) | Bespoke dropdown/TextField/FilledButton with hardcoded copy and unthemed snackbars. | Shared dropdown + text field + primary CTA with themed toasts; history as record rows. | brief the floor → broadcast console → composer + history | composer ≈55% |
| Activity (O4) | Flat ungrouped list with `AppColors` chrome, bespoke timestamps, dead rows. | Day-grouped sections with locale relative times and rows that open their real screens. | know what happened → event log → grouped tappable rows | feed ≈75% |

No screen repeats the header + KPI + grid + list template. The cockpit is an
instrument cluster; the leaderboard is rank rows; comms is a composer; the
log is grouped events — one language, four layouts.

Side-by-side vs house bar: same spacing rhythm (`AppDimensions`), same
divider-row/record-row/table grammar, same pill/toast/haptic/skeleton
patterns, same `AppPageHeader`/`SectionHeader`/`StatusPill` family. The owner
surfaces read as the advisor hub's financial-grade sibling — never cheaper,
never cloned, never the old UI.

---

## 3. Include / remove / enhance (SaaS rework)

**Included (added, all real):** ~70 `owner*` l10n keys with exact EN/AR
parity; ⌘K/Ctrl+K command palette over the 9 real destinations (4 tabs + 5
routes); period selector in `contextSelector`; connectivity pill with
`showOfflineBanner: false`; revenue hero pod with verbatim delta; margin /
occupancy / approvals micro-pods (each only when its KPI exists); shared
`SparklineChart` curves (≤4 series, RTL `orderSeries`, placeholder on empty);
register `AppTable` (sticky-ready, numeric tabular cells, compact record-row
fallback, real tap-through); 12 theme-ink action rows over real routes/tabs;
server-merged comms history with delivered state; day-grouped activity with
locale relative times and type→route/tab mapping; per-panel loading
(`AppSkeleton.page/listRows`), empty (`EmptyState`), error+retry
(`ErrorView`); 1.3x/48dp/semantics/reduced-motion throughout.

**Removed (11 obsolete files, zero references verified by repo-wide grep
before deletion):** `bar_chart_painter.dart`, `dual_line_painter.dart`,
`sales_trend_card.dart`, `sales_vs_expenses_card.dart`,
`sales_category_card.dart`, `action_button.dart`, `card_title.dart`,
`form_label.dart`, `job_card_register_card.dart`, `message_tile.dart`,
`quick_actions_row.dart`. Plus: hardcoded hex accents (`0xFF0284C7`…),
`MaterialBanner`+`RETRY`, bespoke dropdown/TextField/FilledButton chrome,
flat activity chrome. `chart_painters_test.dart` was migrated (not deleted):
the P0/P1 empty-crash guards now lock `SparklineChart` placeholder behavior.
`KpiGrid` is intentionally KEPT (referenced by 07.1 + responsive suites).

**Enhanced:** hero owns the first viewport; curves share one chart language
instead of two bespoke painters; register is a real table on desktop;
actions resolve theme ink; activity rows navigate; copy is financial-grade
owner tone via new keys; desktop is rail + 3-column panoramic (max 1440),
tablet is split/two-pane, compact stacks with swipeable chart pages.

**Honest omissions / deferrals (no fake data — FAIL rule):** revenue-vs-*target*
curve (no target endpoint — profit plotted second instead, documented in
code); per-advisor leaderboard ranks/invoice averages/conversion (endpoint
carries categories only — categories ranked honestly); persisted last-sync
time (no contract — omitted; pill reports connectivity only, never a
fabricated zero); device model (no contract — omitted); geo (no provider
field); late/absent-style verdicts (no schedule contract); permission-denied
(N/A — router role-gates); no-match (N/A — no cockpit search filter).
Server-driven strings (KPI labels/values, category titles, trend months)
render verbatim including their source language — data, not chrome.

---

## 4. Reference conformance (house bar + secondary)

Studied before writing a widget: `advisor_home_view.dart` (greeting-led
hierarchy, action tiles, divider-rows, skeleton-mirrors-geometry, toasts,
haptics, `WorkspaceSearchShortcuts`) and `advisor_job_detail_view.dart`
(dossier hierarchy, breadcrumbs-equivalent headers, lifecycle tone, action
dock). Applied as grammar spirit with different layouts per §2 (never
cloned). Secondary reference: the owner's own register/actions patterns were
kept recognizable in structure while every atom was re-composed on shared
widgets. Cheaper output nowhere: tabular money, rank badges, grouped log,
panoramic desktop.

---

## 5. Contracts proof (UI-only, zero logic changes)

Frozen and byte-identical: `DashboardUiNotifier` methods/state,
`DashboardUIRemoteAdapter.loadAll` + all mappings, `TeamNotifier`,
`OwnerRemoteDataSource`, `ownerActivityFeedProvider` fetch/sort,
`sendMessage` validation/persistence, Hive boxes, routes/params/nav
semantics, auth/permissions, DTOs. Allowed diffs only:
`dashboard/presentation/widgets/*` composition, `period_dropdown.dart`
display labels, `*.arb` strings, test/golden files — plus one justified
shared-system fix below.

Non-UI files touched (one-line justification each):

- `packages/shared_core/.../telemetry_metric_pod.dart` — system gap: the
  delta badge row was unshrinkable (320px/1.3x right-overflow, proven by a
  failing probe). Badge now flexes with ellipsis; trailing gap renders only
  beside supporting text. Zero other app usages; covered by the new shared
  test.
- `packages/shared_core/test/telemetry_metric_pod_test.dart` — required
  coverage for the shared fix (narrow + 1.3x, delta+supporting row).
- `packages/shared_core/test/.../data_display_compact_{en,ar}{,_dark}.png`
  (4 re-baselined gallery goldens) — pixels changed exactly on the fixed
  badge; new render reviewed (no overflow, correct ellipsis).
- `owner l10n/app_{en,ar}.arb` + `gen/*` — new `owner*` keys + regen only.
- Owner tests — harness/expectation updates only (delegates; recomposed
  assertions); `chart_painters_test` migrated to shared-chart guards.
- `reports/REPORT_PHASE_13.md`, `PHASE_13/screens/*`, README ledger row.

---

## 6. Deltas made this session (all owner-side)

Shell, cockpit, leaderboard, comms, activity, period dropdown rewritten;
11 bespoke files deleted; chart guard test migrated; `owner_dashboard_test`
(11) + `owner_phase13_visual_test` (20) created; ~70 l10n keys EN+AR;
smoke-test harness fixed for l10n + recomposed assertions; three
overflow fixes from audits (actions 1-col stream, PageView 320px height,
shared pod flex); medium grid aspect tuned for 800px/1.3x.

---

## 7. Gates & evidence

**Gate 1 — Engineering:**

- `flutter analyze` (owner_app): **0 issues**. `flutter analyze`
  (shared_core): **0 issues**.
- Owner suite: **61/61 green** — logic, responsive (KPI grid), 07.1
  migration, chart guards (migrated), parity, cross-boundary, smoke (5),
  `owner_dashboard_test` (11: hero/pods verbatim, empty, error+retry,
  register+actions, 1.3x, leaderboard expand/empty, comms validation,
  activity empty + real-route tap), visual (20).
- `arb_parity_test` (owner): **green**. Shared `telemetry_metric_pod_test`:
  **2/2 green**.
- Manual guards (source scan): zero `AppColors.*`/`AppDarkColors`/raw
  `MediaQuery` widths/breakpoint literals in owned files (remaining
  `AppColors` hits live in out-of-scope `pages/attendance_view.dart`,
  owned by a later phase); zero new app-local duplicates; bespoke bar
  stays dead (only comment prose + the 07.1 allowlisted scans).

**Gate 2 — Visual (headless):**

- 20 NEW goldens (the app had none), real fonts, deterministic rerun
  green, reviewed native in-session:
  `reports/PHASE_13/screens/owner13_{cockpit,topsales,messages,activity}_{390_en,390_ar,768_en,1280_en,390_dark}.png`
  (test originals in `apps/owner_app/test/goldens/`).
- Matrix: 390 EN/AR + 768 EN + 1280 EN + 390 dark per surface; RTL
  mirroring with LTR-locked money/ids/times; tablet split, desktop rail +
  3-column panoramic (max 1440); overflow audited 320→1440 at 1.0x/1.3x.
- **Live device: NOT PERFORMED** (no device in this session).

**Failures & owners (none owned by this phase):**

| Item | State | Owner |
| :--- | :--- | :--- |
| `shared_core/deprecation_guard_test` (2) | Environmental: `PathNotFoundException` listing stale `apps/staff_app/build/...` artifact dir | Pre-existing workspace debris, out of scope |
| Owner `pages/*` (attendance etc.) `AppColors` + hardcoded copy | Untouched: outside the Phase 13 file list | Later phases (14/15 own jobs/financials-adjacent screens) |
| Per-advisor ranks / target curve / persisted sync stamp | Deferred for missing contracts (§3) | Backend / follow-up |

---

## 8. Files changed (Phase 13 scope)

- Rewritten: `dashboard_body.dart` (shell), `owner_dashboard_page.dart`
  (cockpit), `top_sales_page.dart`, `messages_page.dart`,
  `owner_activity_feed_tab.dart`, `period_dropdown.dart`
- Deleted (11, §3): painters, bespoke cards/buttons/labels/register/message
  tile, `quick_actions_row.dart`
- Kept: `dashboard_view.dart` (thin entry), `kpi_grid.dart` (suite-owned),
  all providers/entities/datasources/router
- L10n: `app_en.arb`/`app_ar.arb` (+~70 keys), `gen/*` (regen)
- Tests: `test/features/dashboard/owner_dashboard_test.dart` (new),
  `test/owner_phase13_visual_test.dart` (new),
  `test/goldens/owner13_*.png` (20, new), `chart_painters_test.dart`
  (migrated), `phase01_layout_smoke_test.dart` (harness + assertions)
- Shared (justified, §5): `telemetry_metric_pod.dart` +
  `telemetry_metric_pod_test.dart` + 4 gallery goldens
- Docs: `reports/REPORT_PHASE_13.md`, `reports/PHASE_13/screens/*` (20),
  README ledger row 13

Staff touches: **none**. Runner artifacts committed: **none**
(`test/failures/` debris removed in both apps; goldens are the evidence).
