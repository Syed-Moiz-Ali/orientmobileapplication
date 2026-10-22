# UX Brief — DETAIL family, first screen = staff job detail (technician dossier first)

## Scope (which detail surface(s) — verified from code, not assumed)

There is NOT one shared detail. The repo has **two full detail screens + one
assign sheet**, verified in `apps/staff_app/lib`:

1. **Technician job detail (FIRST screen of this brief)** —
   `features/technician/presentation/widgets/job_detail_sheet.dart`
   (`TechnicianJobDetailView`, alias `JobDetailSheet`), route
   `AppRoutes.technicianJobDetail` (`core/router/app_router.dart:51,266`).
   Reached from Today (`technician_today_view.dart:246`), Jobs
   (`technician_jobs_view.dart:190`), dashboard
   (`technician_dashboard_view.dart:291`) — always 1 tap on a job row.
   Structure today: `WorkspaceAppBar` + `AppPageHeader` (breadcrumbs, vehicle
   title, status pill) + dossier (`_JobIdentity` card, `_ExecutionArea`:
   focus panel + full task checklist) + `_ContextColumn` (parts / escalation
   sheet buttons, handover CTA) + sticky bottom dock (Complete repair +
   confirm dialog).
2. **Advisor job detail (dossier, second in family)** —
   `features/advisor/presentation/pages/advisor_job_detail_view.dart`
   (`AdvisorJobDetailView`), route `AppRoutes.advisorJobDetail`
   (`app_router.dart:55,303`). Reached from advisor home list
   (`advisor_home_view.dart:131`), search sheet, checkin, inspection preview.
   Structure today: dossier (identity header, 6-stage stepper, checklist,
   comments, estimates, invoices, notes, signatures, share) + rail
   (next-step contextual primary, overflow sheet, activity) + sticky
   `_DockBar` (primary + More).
3. **Supervisor per-job surface = assign sheet (NOT a detail route)** — no
   supervisor detail route exists in `app_router.dart` (only technician +
   advisor detail routes). The supervisor's per-job surface is
   `SupervisorAssignSheet` (`supervisor_assign_sheet.dart:12`), opened from
   floor/scaffold/queue (`supervisor_scaffold.dart:87,103`): target-job
   search + technician cards + brief + Dispatch.

This brief rebuilds surface (1) first; surfaces (2) and (3) follow the same
C16 detail pattern (dossier + sticky action bar + sheets) in their own
builds. No logic changes anywhere: same routes, same notifier methods
(`startTask`/`completeTask`/`updateTaskStatus`/`completeJob`,
`saveAndAssign`), same Hive extras, same status machines.

## User goal
A technician opens a job and in one glance knows: what job is this, what is
the current task, and how to start/complete it or get help — one screen, one
primary action. Secondary needs (parts, escalation, handover) are one tap
away, never competing with the primary CTA.

## Single primary action
The current task's next step (Start / Complete) in the sticky action bar +
focus panel. Everything else is navigation or sheets.

## Top 3 tasks with tap counts (BEFORE = current UI from code, AFTER must be ≤)
| Task | BEFORE (code-verified) | AFTER budget |
|---|---|---|
| 1. Start / complete the current task | 2 taps, 0 scroll: tap job row → `push(technicianJobDetail)` (`technician_today_view.dart:242-250`) + tap Start/Complete `_GreaseButton.fill` → direct `notifier.startTask`/`completeTask` (`job_detail_sheet.dart:470-485,524-543`) | ≤ 2 taps (in-detail 1 tap), 0 scroll |
| 2. Request a part (or escalate) | 3 taps: open detail (1) + Request-part sheet button (1) → `showAppModalSheet(PartsRequestSheet)` (`job_detail_sheet.dart:1089-1122`) + submit inside sheet (1) | ≤ 3 taps (sheet keeps its own submit; no added steps) |
| 3. View activity / timeline | 1 tap + scroll: open detail (1) + scroll to history. Technician: task rows carry status + start/end times (`job_detail_sheet.dart:721-757`); Advisor: `_activitySection` rail (created / updated / advisor / tech, `:752-790`) | ≤ 1 tap + ≤ same scroll (timeline stays one scroll region, never a new page) |

Most frequent (task 1) stays ≤ 2 taps. Taps never regress: every budget is
≤ BEFORE. No step flows (frequent execution tasks stay single-screen per the
scoped step-flow rule).

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke grease fills / multi-accent buttons (`_GreaseButton.fill`
  cobalt/amber/emerald, `_TaskAction` semantic fills) → ONE accent
  `AppPillButton` primary per section (C16 hard-reject: exactly one filled
  accent per section); Hold becomes secondary/ghost. Text always carries
  meaning (icon + label + status dot, never color alone — U14/C2).
- REMOVED: bespoke `PrimaryButton` dock + `showAppConfirmationDialog` chrome →
  C16 sticky action bar (status summary left + ONE primary CTA right) +
  `AppDialog` confirm naming the object ("Complete repair on 'JC-123'?").
- REMOVED: bespoke `_HelpActions` outlined buttons + `showAppModalSheet`
  chrome → `AppBottomSheet` (parts / escalation / overflow), handle + pinned
  primary, max 90%.
- REMOVED: bespoke `_DelayedNotice` container → `AppBanner` (warning) so
  blockers use the same pattern as every other screen (no permanent pills).
- REMOVED: bespoke skeleton/empty/error (`AppInfoPanel.danger` on advisor,
  inline hints) → `AppShimmerSkeleton` (mirrors layout), `AppEmptyState`
  (no-tasks), `AppErrorState` + Try again; offline → `AppBanner` + stale
  data + pending count (already in `WorkspaceAppBar`, keep).
- MOVED: per-row Start/Hold/Complete triplets stay (glove-first execution is
  the content, not chrome) but rebuilt with App* buttons; secondary rows
  (history, support) stay in place; destructive/locked states stay dialogs.
- KEPT: all providers/routes/sync/offline queue/stopwatch math (display-only
  elapsed), task state machine, filter predicates, bottom dock on compact /
  rail on wide, pull-to-refresh, haptics, keys, all localized strings.
- No new routes. No invented tasks/statuses/times. Zero shown as 0, never "-".

## Flow / sections (C16 DETAIL pattern: hero → title → stats → grouped cards → sticky bar)
1. `AppScaffold` + `AppAppBar` (back, job ref LTR-locked, offline status).
2. Header: `AppPageHeader` (breadcrumbs Jobs › JC-123, vehicle title wraps
   ≤ 2 lines, ONE status chip with plain-language "why" sentence).
3. HERO `AppCard`: identity (vehicle, plate chip LTR, customer) + progress
   (`AppProgressBar`: "2 of 5 tasks").
4. Section "Current task": focus card (task title, live stopwatch, ONE
   primary Start/Complete + ghost Hold) — above the fold.
5. Section "All tasks": checklist rows (28px-equivalent toggle ≥ 48dp target,
   per-row actions, tabular start–end times, done = strikethrough + label).
6. Section "Need help": parts + escalation as `AppListTile` rows opening
   `AppBottomSheet`s (not inline forms).
7. Sticky action bar (C16): left = status summary ("2 of 5 done"), right = ONE
   primary (current next step / Complete repair); overflow (More) → sheet.
   Danger zone separated at bottom, never next to the primary CTA.

## Hard-reject checklist (all must hold; reviewer caps at 10/16 on ANY violation)
- [ ] Borderless light cards (shadow e1/flat + whitespace); dark may use border
- [ ] No orphan tiles (support rows: full-width list, never 2x2 + lone tile)
- [ ] ONE filled accent per section (focus card: ONE primary; Hold = ghost)
- [ ] One path per task (no dock CTA + focus CTA duplicating the same step)
- [ ] No permanent status pills (delayed/offline → AppBanner only when abnormal)
- [ ] Badges offset outside icons, clear area kept
- [ ] No ALL CAPS; no label/badge number duplication
- [ ] Search: header search icon top-right → full search sheet (U1; detail keeps
      the same placement as list screens; filters existing jobs only)
- [ ] Above the fold: current-task focus card visible at 360x800 idle
- [ ] Card hierarchy: recognizable title (vehicle/task) → status pill → meta
      (IDs/refs are meta, mono, LTR-locked)
- [ ] No carousels on detail (single-column stream; wide = dossier + rail)

## U0–U14 checklist (all must hold; ANY violation caps at 8/16, no exceptions)
U0 least effort / U1 search icon top-right → full-screen search / U2 first
actionable item (current-task card) above fold at 360x800 idle / U3 tap counts
above (frequent ≤ before, most frequent ≤ 2) / U4 primary action reachable in
sticky bar (lower half) / U5 no truncation (vehicle/task names wrap ≤ 2 lines,
never "…"; refs stay LTR inside RTL) / U6 calm empty (no-tasks = icon +
sentence + action; no filled CTA to nothing) / U7 one path per task / U8
relevance (completed jobs read-only, no actions offered) / U9 consistency
(same header/search/back/CTA placement as list screens) / U10 feedback +
destructive confirm ("Complete repair on 'JC-123'?") / U11 readable numbers
(0 never "-", tabular, signed deltas) / U12 one background / U13 new-employee
labels / U14 a11y (48dp, AA, Semantics, 1.3x, 320px).

## ASCII wireframe at 360x800 (mandatory; current-task card above the nav)
```
+----------------------------------+
| < JC-123            [🔍][🔔][av] |
| Camry · Oil change               |
| ● In progress — waiting on you   |
|                                  |
| [ Camry · ABC-1234      2/5 ]    |
| [ ████████░░░░  2 of 5 tasks ]   |
|                                  |
| Current task                     |
| [ Oil drain                      |
|   00:12:41 elapsed                |
|   [  Complete task  ]  Hold ]    | <-above fold
+----------------------------------+ fold (bottom nav below)
| 2 of 5 done        [ Complete ]  | (sticky action bar)
+----------------------------------+
| Jobs | Productivity | Profile     | (bottom nav)
```
Below fold (scroll): All-tasks checklist → Need help (parts / escalation
rows → sheets) → Activity/timeline → Danger zone (separated).

## U-law application (U0–U14, C17 — detail-specific notes)
- U0: one read — identity → current task → ONE next step. Progress sentence
  ("2 of 5 tasks") under the hero; technical IDs/refs collapsed to meta.
- U1: search icon top-right (same placement as Today/Jobs list screens)
  opens full-screen search over jobs; NEVER an inline field mid-detail.
- U2: current-task focus card above the fold at 360x800 idle; anything
  pushing it down needs a written reason in the build log.
- U3: table above is binding; most frequent = 2 taps.
- U4: primary CTA lives in the sticky bar (lower half) AND the focus card;
  same action, one path (U7: dock mirrors focus state, never diverges).
- U5: vehicle/task/customer names wrap ≤ 2 lines; job refs, plates, VIN, ODO
  stay LTR (`Directionality` bidi isolates, already in code — keep).
- U8: completed / QC-locked jobs render read-only (notice + no actions);
  never filter silently — data issues go to LOGIC_FOLLOWUPS.md.
- U13: "Start task / Complete task / Hold / Request part / Report a problem"
  — plain verbs, no "grease", "dossier", "escalation" jargon in UI.

## States matrix (EVERY cell implemented; staff light-only per phase-5 precedent)
| State | Detail behavior |
|---|---|
| Loading | `AppShimmerSkeleton` mirroring hero + focus card + 3 rows (no spinner) |
| Error | `AppErrorState` (what happened + what to do) + Try again; partial failures → `AppBanner`, rest usable |
| Empty (no tasks) | `AppEmptyState` (icon + sentence + action); sticky bar hides its CTA (U6) |
| Offline / stale | `AppBanner` (warning) + last data + "Updated Xm ago" + pending count; mutations queue, no double-execution guard lost |
| ar (RTL) | Full mirror; refs/plates/VIN/ODO/times LTR-locked; chevrons/back mirrored; tabular numerals kept |
| 1.3x text | No overflow (Flexible/Expanded, wrap; ellipsis secondary only); targets stay ≥ 48dp; tester exception = fail |
| 320px | Single column, no clipping; support rows stack full-width; sticky bar wraps summary above CTA |
| Tablet / wide | Dossier (60%) + rail (40%): support + handover + activity; bottom dock → rail CTA (never both) |
| Dark | Staff ships light-only today; rebuild uses tokens only so a future dark theme needs no rework; no pure-black shims |

## Copy keys needed
Reuse existing `techDetail*`, `techToday*`, `techEsc*`, `advisorJobDetail*`,
`advisorSection*`, `advisorAction*` keys. New keys only for hero sentence +
empty states (en+ar, listed for phase 9). No invented strings.

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: does not exist; `AIRBNB_PATTERNS.md`
  missing repo-wide (per `docs/ui-redesign/PROGRESS.md:130` and the
  LIST-phase precedent `briefs/phase-6-vehicles-list.md:89-108`).
- Mapping into `AIRBNB_PATTERNS.md` is therefore **unmet**; this brief
  proceeds from LIST-phase + phase-5 precedent patterns (technician-home,
  supervisor-home, vehicles-list briefs): `AppPageHeader` + header search
  icon (U1), hero card + `AppProgressBar`, `AppListGroup` rows, filter/sheet
  keeping existing predicates, `AppBanner` for blockers, borderless light
  cards, C16 sticky bar (summary left + ONE CTA right), zero shown as `0`.
- Nothing in this brief pretends a reference was consulted.

## Acceptance (binding gates for the build)
1. Rubric ≥ 12/16 on the detail rubric; C16 hard-reject clean (else cap
   10/16); U0–U14 clean (else cap 8/16, no exceptions).
2. Full gates in order, none skipped: characterization (current screens
   captured + mapped) → before-images (baseline PNGs blessed) →
   migration (App* rebuild per plan above, WIDGET_MIGRATION_MAP updated) →
   build (presentation only, zero logic diffs) → contact sheets (per
   C14 matrix: core + stress + locale devices) → fresh reviewer pass +
   second reviewer sign-off.
3. Tap budgets verified by test (top-3 table above re-measured AFTER; any
   regression = fail).
4. Forbidden-pattern grep (C13) clean for the touched modules before goldens.
5. Foreseen logic STOPs (do NOT fix in build — report back): (a) step-flow
   demand from Login modes/state machine; (b) advisor compact rail gap —
   activity/next-step rail is wide-only in current code (`else dossier`),
   so the rebuild must surface those sections on compact without inventing
   routes; (c) any backend/status-machine change needed for handover or
   assign payloads; (d) missing translations at phase 9 (flag REVIEW_NEEDED,
   never ship unverified copy as verified).
