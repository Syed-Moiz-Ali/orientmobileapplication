# REPORT PHASE 11 — Staff Supervisor Bay & Floor Command

**Document ID:** `phases/redesign_v2/reports/REPORT_PHASE_11.md`
**Execution Phase:** Concept A V2 — Phase 11 (Archetype 4: Tactical Operations Radar + Archetype 6: Spatial Inspection HUD)
**Specification:** `phases/redesign_v2/implementation/PHASE_11_STAFF_SUPERVISOR_BAY.md`
**Status:** **ENGINEERING GATE PASSED** / **VISUAL GATE PENDING PRODUCT OWNER**
**Timestamp:** 2026-10-16
**Author:** Lead Flutter Architect & Systems Designer

> Mission summary: screen-level redesign (not a colour refresh) of the
> supervisor workspace — shell, floor board, jobs, queue, QC, reports, roster,
> schedule, dispatch + QC sheets — on the centralized theme + shared-widget
> architecture, in home-grammar siblinghood with the advisor hub. The 16-bay
> floor board is a **spatial map** (never a KPI grid), and every figure is
> derived from the frozen provider data — no fabricated bay, technician or
> trend data is rendered. Providers/API/models/persistence are byte-identical.

---

## 0. Baseline the dirty tree (§0 directive — done FIRST, no code)

The working tree carried uncommitted supervisor changes of unknown origin when
this phase started. Every hunk was classified before any code was written;
nothing was built on a mystery diff.

| Path | Disposition | Evidence |
| :--- | :--- | :--- |
| `supervisor/presentation/widgets/*` (12 modified tabs/sheets/scaffold/bell) + `supervisor_stats_grid.dart` deleted | KEEP (07.1-style carryover) | Real Phase 11 recomposition: greeting shell, bay derivation, FilterBar/AppTable/shared sheets, l10n keys; analyzer 0 + theme/responsive guards green |
| `supervisor_components.dart` (untracked, new) | ADOPT | Pure derivation + theme mappings, zero hardcoded copy, no `AppColors`, covered by 12 bay tests |
| `supervisor_phase11_{bay,console,theme,responsive_guard,visual}_test.dart` (untracked) | ADOPT | All green; harness reuses the repo's fake-notifier + font + secure-storage-mock patterns |
| `test/goldens/supervisor_*.png` (12 untracked baselines) | ADOPT as start, EXTENDED | Deterministic; +14 added this session for the gate gaps (§13) |
| `app_router.dart` (supervisor routes) | KEEP | Hardcoded EN wrapper titles → `svRoute*` keys; bespoke `AppBar` → `WorkspaceAppBar` + breadcrumbs; tab callback params |
| `l10n/app_{en,ar}.arb` + `gen/*` | KEEP | 165 `sv*` keys, exact EN/AR parity (`arb_parity` green) |
| `phase07_1_migration_test.dart`, `supervisor_experience_test.dart`, `staff_experience_test.dart` (+delegates) | KEEP | Migration assertions updated to the greeting shell (no `WorkspaceAppBar`); green |
| `README.md` (+1 row) | KEEP | Phase 11 ledger row, convention-matching |
| `advisor_home_view.dart` (reference file, 403-line reflow + stray BOM) | REVERTED to HEAD | Token audit: zero new identifiers/logic in added lines — pure formatter reflow; a reference file must stay pristine. `git checkout -- <file>` (git itself is the backup) |
| `supervisor_stats_grid.dart` (deleted file) | DELETION CONFIRMED | Zero references repo-wide (`SupervisorStatsGrid` grep: no hits) — obsolete KPI grid, exactly what the mandate orders removed |
| `test/failures/` (runner artifacts) | DELETED, never committed | Pixel-diff debris from local runs, not evidence |
| `REPORT_PHASE_11.md` + `reports/PHASE_11/` (untracked) | ADOPTED as draft, CORRECTED | Gates re-verified independently; §0/evidence/counts fixed by this session (see §§11–13) |

---

## 1. Owned inventory (from source, nothing omitted)

| Ref | Surface | File | Entry | States owned & covered |
| :-- | :--- | :--- | :--- | :--- |
| V1 | `SupervisorLoginView` | `supervisor/presentation/supervisor_login_view.dart` | `/supervisor-login` | shared auth-grade split (Phase 05) — kept; role locked to supervisor by route guard; EN/AR + error inline |
| V2 | `SupervisorScaffold` (shell) | `presentation/widgets/supervisor_scaffold.dart` | `/supervisor_dashboard_view` | greeting header (name + branch·shift + live floor pill + Synced + bell + avatar), 7-tab rail/bottom-nav frame, profile sheet |
| V3 | Floor board (`SupervisorDashboardTab`) | `presentation/widgets/supervisor_dashboard_tab.dart` | shell tab 0 | 16-bay spatial grid, legend, state filter, tap→dispatch, wide = board + queue/detail rail, skeleton/empty/no-match/error |
| V4 | `SupervisorJobsTab` | `presentation/widgets/supervisor_jobs_tab.dart` | shell tab 1 / `/supervisor/jobs` | search + status FilterBar + inline summary + divider rows, loading/empty/no-match/error |
| V5 | `SupervisorQueueTab` | `presentation/widgets/supervisor_queue_tab.dart` | shell tab 2 / `/supervisor/queue` | priority-sorted bookings/breakdowns, priority FilterBar, advisor routing modal, loading/empty/no-match/error |
| V6 | `SupervisorReviewTab` + `QcChecklistSheet` | `presentation/widgets/supervisor_review_tab.dart`, `qc_checklist_sheet.dart` | shell tab 3 / `/supervisor/review` | QC queue → checklist sheet (checkpoints + repair items + evidence slots + notes + pass/fail dock), loading/empty/error |
| V7 | `SupervisorReportsTab` | `presentation/widgets/supervisor_reports_tab.dart` | shell tab 4 / `/supervisor/reports` | metric strip + sparse tables (categories, floor status, financials), honesty note, loading/empty/error |
| V8 | `SupervisorStaffTab` | `presentation/widgets/supervisor_staff_tab.dart` | shell tab 5 / `/supervisor/staff` | roster + departments divider rows, empty states |
| V9 | `SupervisorScheduleTab` | `presentation/widgets/supervisor_schedule_tab.dart` | shell tab 6 / `/supervisor/schedule` | agenda matrix (today highlighted) + status FilterBar, loading/empty/no-match/error |
| V10 | `SupervisorAssignSheet` (dispatch) | `presentation/widgets/supervisor_assign_sheet.dart` | modal + `/supervisor/assign` | target-job search, department picker, technician cards, one primary dispatch, toast; empty |
| V11 | `StaffNotificationBell` + sheet | `presentation/widgets/staff_notification_bell.dart` | shell header | unread badge, mark-all-read, loading/empty |
| — | Shared presentation helpers | `presentation/widgets/supervisor_components.dart` | used by V2–V11 | bay model + derivation, status tone mapping, priority derivation, toast, initials |

Routes (`/supervisor_dashboard_view`, `/supervisor/{assign,jobs,queue,review,staff,schedule,reports}` + sub-page
wrapper), role/permission semantics, `SupervisorDashboardNotifier` methods,
entity shapes, Hive boxes (`supervisor_assignments`, `sync_queue`), sync-queue
payloads and the `qcReview` contract are **unchanged**.

---

## 2. Before / after composition (per screen) — task → concept → composition

| Screen | Old got WRONG (one line) | New does DIFFERENTLY (one line) | Task → Concept → Composition |
| :-- | :--- | :--- | :--- |
| Shell (V2) | Bespoke `WorkspaceAppBar` title row duplicating tab titles; 5 tabs only (Today/Assign/Queue/Review/Profile). | Greeting header owns identity (advisor-home grammar, no app bar) with a live floor-status pill; 7 task tabs via rail/bottom-nav. | command at a glance → greeting chrome budget → header + rail + tab stack |
| Floor (V3) | A dashboard of boxed KPI cards, context banner, attention chips, nav matrix — a stretched phone template. | A 16-bay **spatial map**: state-tinted tiles with bay id, technician initials (only when real), job + real meta; legend + filter; tap→dispatch. | see the floor, act on a bay → spatial HUD → grid of bay plates + side queue rail |
| Jobs (V4) | Bordered cards, raw `MediaQuery` breakpoint, KPI strip. | Search + status FilterBar over borderless divider rows with a slim inline stat line. | scan + filter the register → list-surface grammar → toolbar + divider rows |
| Queue (V5) | Two card columns; single dropdown sheet; raw width check. | Priority-sorted divider rows (VIP / promised-today / insurance / emergency pills) + advisor routing modal. | triage incoming work → radar priority → priority chips + route sheet |
| Review/QC (V6) | Small checkbox list of raw work items, dead-end when no items, English-only CTA dock. | Standard road/torque/fluid/wash checkpoints + repair verification + evidence slots + notes + crimson/emerald dock. | verify before handover → spatial sign-off HUD → large toggles + pass/fail dock |
| Reports (V7) | Decorative category bars + boxed revenue cards. | Metric strip (throughput / utilisation / per-tech) + sparse `AppTable`s + an explicit no-history note. | understand the floor → sparse SaaS tables → stat strip + tables |
| Roster (V8) | Boxed technician/department cards with a "REGISTERED" chip. | Divider rows with initials avatar, role and an on-shift pill; departments list. | who is on shift → roster list → divider rows |
| Schedule (V9) | Boxed booking cards; "View in Queue" per card; raw width check. | Agenda matrix (`AppTable`, today highlighted) + status FilterBar; row → queue. | plan the day → matrix → table with today highlight |
| Dispatch (V10) | Full-page multi-row form workspace (the `Assign` tab). | Modal dispatch: target job + department + technician cards + one primary; toast on dispatch. | push work to a technician → one-tap dispatch → selectable tech cards |
| Notifications (V11) | Bespoke bottom-sheet chrome; hardcoded copy. | `showAppModalSheet` content + l10n + shared empty state. | acknowledge floor events → shared modal → list |

No screen repeats the header + KPI + grid + list template. The floor board is a
spatial map (48 dp+ plates), not a KPI grid; the queue is priority rows; the
schedule is a matrix; the QC sheet is a sign-off dock.

## 3. Include / remove / enhance (SaaS rework)

**Included (added):** floor legend + state filter + no-match; technician
initials slot (dashed when unassigned); priority pills + counts; per-tab
loading (skeleton mirrors grids/rows/tables), empty, no-match, error+retry;
dispatch toast; QC pass/fail dock with required-reason validation; evidence
slots (see §11 deferral); breadcrumbs on pushed sub-pages; 48 dp targets;
focus/semantics; EN/AR keys with parity; LTR-locked plates/ids/times.

**Removed:** the retired KPI dashboard template (`_SupervisorContextBanner`,
`_OperationalAttentionArea`, `_QueuePreviewSection`, `_ActiveJobsPreviewSection`,
`_AdvisorWorkloadCard`, `_JobCategoryDistributionCard`,
`_ContextualNavigationMatrix`, `_KpiOverviewGrid`); the unused
`supervisor_stats_grid.dart` (zero references — `git grep` verified);
hardcoded per-index decorative hex in favour of semantic families; the
full-page assign form as a destination tab.

**Enhanced:** the floor is the primary (>50% viewport at 390); controls fit each
task; copy is terse staff tone via new `sv*` keys; desktop is a real
rail + board + queue-rail composition, never a stretched phone.

---

## 4. Changed files + rationale

**Rewritten (Phase 11-owned presentation):** `supervisor_scaffold.dart`,
`supervisor_dashboard_tab.dart`, `supervisor_jobs_tab.dart`,
`supervisor_queue_tab.dart`, `supervisor_review_tab.dart`,
`supervisor_reports_tab.dart`, `supervisor_staff_tab.dart`,
`supervisor_schedule_tab.dart`, `supervisor_assign_sheet.dart`,
`qc_checklist_sheet.dart`, `staff_notification_bell.dart`.

**Added:** `presentation/widgets/supervisor_components.dart` (bay model +
derivation + status/priority mapping + toast).

**Deleted:** `presentation/widgets/supervisor_stats_grid.dart` (zero
references; `SupervisorStatsGrid` grep-verified across `lib/`).

**Router (chrome only):** `SupervisorSubPageWrapper` now composes the shared
`WorkspaceAppBar` + `AppBreadcrumbs` instead of a bespoke `AppBar`; pushed
route titles/subtitles localized. Destinations/args/permissions unchanged.

**l10n:** `app_en.arb` / `app_ar.arb` + regenerated gen — **131 new `sv*` keys**
with exact parity.

**Non-UI diffs (justified, one line each):** none. No provider, entity,
datasource, Hive or payload file was touched.

**Tests:** `supervisor_experience_test.dart` rewritten for the new composition;
`phase07_1_migration_test.dart` supervisor group updated (greeting shell, no
`WorkspaceAppBar`) + l10n delegates; `staff_experience_test.dart` supervisor
harness given l10n delegates; new `supervisor_phase11_*` suites.

## 5. Contracts-frozen proof

- Providers/notifiers/state, entities, remote datasource, Hive boxes/payloads,
  sync operations, routes/extras/permissions, validation outcomes and the
  `qcReview` request body are byte-identical — verified by `git status`
  (no non-presentation lib diff besides the router chrome + arb/gen) and by the
  action-recording tests (dispatch calls `saveAndAssign`; QC approve/reject call
  `qcReview` with the same args) all green.
- The floor board is a **pure presentation derivation** (`buildSupervisorBays`)
  over the frozen data — no provider state is written.
- `supervisorPendingSyncCountProvider` was **not** added; the header uses the
  shared `OfflineStatusPill()` (Synced/Offline from connectivity only), keeping
  the provider layer untouched.

## 6. Theme audit

- All rendered colour resolves via `Theme.of(context).colorScheme` /
  `context.semanticColors` (bay families, status pills, rails, progress,
  evidence slots). No `AppColors.*` / `AppDarkColors.*`, no `Brightness`
  branches, no `Color(0x…)` in owned files — enforced by the new guard (2/2).
- `Colors.*` appears only as `Colors.transparent`.
- The frozen provider's decorative `Color(0x…)` values (assigned to
  `JobTypeEntity.color` / `PendingStatusEntity.color`) are **not consumed** by
  any supervisor widget and were left byte-identical (domain contracts).

## 7. Widget audit (reused 01.2 vs newly created)

**Reused from shared_core:** `DashboardShell` (`appBar: null`,
`showOfflineBanner: false`), `AppAdaptiveNavigationFrame`, `AppNavigationRail`,
`AppBottomNavigation`, `OrientBrandMark`, `OfflineStatusPill`, `UserAvatar`,
`AppResponsivePage`, `AppPageHeader`, `AppBreadcrumbs`, `AppFilterBar`,
`AppSearchField`, `AppSkeleton` (grid/listRows/table), `EmptyState` /
`.noMatch`, `AppInfoPanel`, `AppCard`, `SectionHeader`, `StatusPill`,
`AppKpiCard.wide`, `AppTable` / `AppTableColumn` / `AppTableCell`,
`AppLinearProgress`, `PrimaryButton`, `SecondaryButton`, `AppButton.quietIcon`,
`showAppModalSheet`, `AppDropdownButton`, `WorkspaceAppBar` (sub-pages),
`AppDimensions` / `AppTextStyles` / `AppMotion`. **Zero new app-local
primitives**; `supervisor_components.dart` is feature-domain composition.

## 8. Shell integration

Greeting header (advisor-home grammar) with name, branch · shift, live
floor-status pill (`svBaysOccupied`), Synced pill, bell and avatar — **no
bespoke bar** (07.1 migration preserved: shared widgets only). `showOfflineBanner:
false`. Pushed sub-pages use `WorkspaceAppBar` + `AppBreadcrumbs`. Rail ≥600 /
bottom-nav compact (7 destinations → 4 + More).

## 9. Localization & RTL

131 new keys, exact EN/AR parity (`arb_parity_test` green). Zero hardcoded
user-facing strings in owned files. RTL uses directional APIs; bay codes, job
refs, plates, times and money are `Directionality`-LTR-locked with tabular
figures in both locales. `bookingPriority`/`bookingIsToday` derive from real
record text only.

## 10. Viewport matrix

| Width | Verified | Composition |
| :--- | :--- | :--- |
| 390 EN/AR | goldens + no-overflow 320–430 + 1.3x green | greeting + single-column floor board (2-col grid) + stacked rail; sheets in bottom dock |
| 768 EN | golden | rail frame; floor board (3-col) beside the queue rail |
| 1280 EN | golden | max canvas centred; rail + floor board (4-col) + queue/detail rail — never a stretched phone |
| Dark | 390 dark spot | full token parity |

Chrome budget at 390×844: greeting ≈150 → the floor board owns ≈70%+ of first
paint. The 16-bay board is the primary job; the queue rail is secondary.

## 11. Failures, deferrals + owners

| Item | Disposition | Owner |
| :--- | :--- | :--- |
| QC photo upload | DEFERRED — no media endpoint on the supervisor API; the evidence slots are honest placeholders with the reason shown once | Backend (media endpoint, then UI) |
| Per-technician skills / availability / live bay timer | DEFERRED — the frozen model carries no per-tech skill, availability or start-time field; the tile shows the real technician initials only when present and never invents one | Backend (roster/telemetry fields) |
| Reports trend deltas (TrendStat) | N/A — no history endpoint; a direction would be fabricated, so the strip shows current figures + an explicit no-history note (honesty over decoration) | Backend (history series) |
| `staff_experience_test.dart` technician pumps crashing (`StaffLocalizations.of!` null) | FIXED THIS SESSION — broken since the Phase 10 l10n commit (harness lacked delegates); same one-line fix the file already carried for supervisor pumps, plus 2 stale copy assertions updated to recomposed (not reworded) copy | This phase (done; file green) |
| `advisor_home_view.dart` reference reflow + BOM | REVERTED to HEAD (§0); token audit found zero new logic | This phase (done) |
| `test/failures/` runner debris | DELETED, never committed | This phase (done) |
| 5 stale technician/advisor assertions in `staff_experience_test.dart` / `phase01_layout_smoke_test.dart` (`Work Summary`, `On the bay`, …) claimed by the draft | NOT REPRODUCED — `staff_experience_test.dart` is fully green after the delegates fix (7/7); `phase01_layout_smoke_test.dart` untouched and out of scope | Prior session note was stale |
| Live-device run | NOT PERFORMED — no device in this environment | Product owner |

## 12. Gates

**Gate 1 — engineering:** `dart analyze apps/staff_app` **0 errors, 0 warnings**.
Supervisor-owned suites **47/47 green**: `supervisor_phase11_bay` (12:
16-bay placement, parts-delay mapping, initials honesty, idle fill, overflow
cap, priority derivation), `supervisor_phase11_console` (7: dispatch records
the tech, QC approve/reject call the frozen contract, empty states, 48 dp
audit), `supervisor_phase11_theme` (2), `supervisor_phase11_responsive_guard`
(2), `supervisor_phase11_visual` (24: shell/floor/queue/schedule/review/
reports/sheets across 390 EN/AR, 768, 1280, dark). Plus
`supervisor_experience` (12), `phase07_1_migration` (8),
`staff_experience` (7, incl. the 2 crash fixes §11), `arb_parity` (1) green.

**Gate 2 — visual:** 26 supervisor goldens captured with real fonts (Plus Jakarta
Sans + IBM Plex Sans Arabic + Material Icons) and reviewed — shell 390 EN/AR +
dark, 768, 1280; floor 390 EN/AR + dark + 1280; queue 390 EN/AR + dark + 1280;
schedule 390 EN/AR; review 390 EN + dark + 1280; reports 390 EN + 1280; assign
390 EN/AR; QC 390 EN/AR; login compact EN/AR (Phase 05 references, untouched).
Sheets render through width-capped `showAppModalSheet` dialogs on desktop
(shared constraint — verified in code, no stretched-phone risk). Live: NOT PERFORMED.

## 13. Evidence

`phases/redesign_v2/reports/PHASE_11/screens/` — 26 PNGs (shell 390 EN/AR +
dark + 768 + 1280; floor 390 EN/AR + dark + 1280; queue 390 EN/AR + dark +
1280; schedule 390 EN/AR; review 390 EN + dark + 1280; reports 390 EN + 1280;
assign 390 EN/AR; QC 390 EN/AR; login compact EN/AR references). Canonical
sources: `apps/staff_app/test/goldens/supervisor_*.png`.

## 14. Reference conformance (home bar)

Greeting header, floor `_toast` pattern, skeleton-mirrors-geometry, 48 dp
targets, single-primary sheets, breadcrumbs, haptics, state coverage and motion
restraint all match `advisor_home_view.dart` / `advisor_job_detail_view.dart`
spacing rhythm and row/card grammar. Task-driven deltas: a spatial bay board,
priority chips, a QC sign-off dock and a dispatch modal — the supervisor is the
advisor's sibling in work clothes, not a recolour.
