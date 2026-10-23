# UX Brief — supervisor Review list tab (list family)

## Scope
`apps/staff_app` supervisor Review surface: `features/supervisor/presentation/widgets/supervisor_review_tab.dart`
(list + header + per-row QC meter + checklist sheet entry + empty/error/loading) +
`qc_checklist_sheet.dart` (sheet entry point — `showQcChecklistSheet` call preserved; sheet internals NOT
in scope) + `supervisor_scaffold.dart` (shell bar + compact 4+More, expanded 7-rail — NOT touched) +
`supervisor_components.dart` (`StatusPill`/mono/initials helpers — read-only). Routes touched only as
existing destinations: tab index 3 in `IndexedStack`; row Start QC → `showQcChecklistSheet` (same sheet).
No new routes. No logic changes (providers, awaiting derivation, progress math, refresh stay as-is).

Queue/Jobs/Review are SEPARATE tabs (separate lists, separate briefs) — evidence: `supervisor_scaffold.dart`
`IndexedStack` children `[..., SupervisorJobsTab, SupervisorQueueTab, ReviewTab, ...]` (indices 1/2/3),
each with own provider slice (`jobs` vs `bookings/breakdowns` vs `awaitingCompletions`).
This brief covers the Review tab only.

## User goal
A supervisor opens Review and in one glance sees which completed repairs await sign-off then starts the
QC checklist for one job. One screen, one primary task: find job awaiting QC → start checklist.

## Current behavior (verified from code)
- Entry: supervisor scaffold tab index 3 (`const SupervisorReviewTab()`); shell bar shows the U1
  bay-search icon on this tab (`selectedIndex != 0` guard) opening the floor-wide bay sheet (which
  includes QC-awaiting records via `buildSupervisorBays(awaiting: ...)`).
- Header: `AppPageHeader` (title `svReviewTitle`, STATIC subtitle `svReviewSubtitle`, leading verified
  icon) + refresh `IconButton` action (tooltip `commonRetry` → `refreshReview`).
- Rows: `_QcRow` borderless divider rows — jobCardRef mono LTR (w800) + `StatusPill.info`
  `svReviewProgress(done,total)` + customer·vehicle (1-line ellipsis) + tech initials (w800) +
  `AppLinearProgress` + FULL-WIDTH `PrimaryButton` Start QC (`svReviewStart` + fact-check icon) directly
  on the row → `showQcChecklistSheet(jobCardId/jobCardRef/customerName/vehicleInfo/workItems)`.
- States: `AppSkeleton.listRows(5)` loading; `EmptyState` (verified icon + `svReviewEmpty/Message`,
  NO action); `AppInfoPanel.danger` (`svReviewError` + Retry → `refreshReview`); `RefreshIndicator`
  pull-to-refresh.
- Staff light-only convention (dark stays structurally intact, not redesigned).

## Top tasks with tap counts (BEFORE = current UI, AFTER = this brief; AFTER ≤ BEFORE)
1. Open the Review list — before: bottom-nav/rail Review tab = **1 tap** (0 if deep-linked). After: ≤ 1 tap.
2. Start the QC checklist for a job — before: tab (1) + row Start QC (1) = **2 taps from list
   (+ scroll)**, then the existing checklist sheet. After: **≤ 2 taps**, ≤ same scroll. Start QC stays
   DIRECTLY on each row (frequent action on the card — vehicles pattern applies here).
3. Retry after error / pull-to-refresh — before: Retry = **1 tap** / pull gesture. After: unchanged
   (error/skeleton are refresh-driven — provider-owned, see below).

| Task | Before | After budget |
|---|---|---|
| Open list | 1 tap | ≤ 1 tap |
| Start QC checklist | 2 taps from list (+scroll) | ≤ 2 taps, ≤ same scroll, same sheet |
| Retry / refresh | 1 tap / pull | ≤ 1 tap / pull |

Frequent task (start QC) stays single-screen; the checklist sheet is the existing flow.

## References / AIRBNB_PATTERNS.md status (dependency: UNMET, proceeded on precedent)
- `docs/ui-redesign/references/`: does not exist (confirmed — no `references` dir under `docs/ui-redesign/`).
- `AIRBNB_PATTERNS.md`: missing anywhere in the repo (repo-wide glob `**/AIRBNB_PATTERNS*` returns nothing;
  only mention is `docs/ui-redesign/evaluation/technician-home-test-migration.md:183`, echoed by the
  vehicles/jobs/queue briefs).
- Mapping is therefore UNMET; this brief proceeds from precedent patterns (phase-5/phase-7 briefs +
  `phase-6-vehicles-list.md` + screens 1–2): `AppPageHeader` + borderless divider rows +
  `AppEmptyState` / `AppErrorState` + `AppShimmerSkeleton` + sheets + frequent action on the card +
  no ALL CAPS + zero as `0`.

## Vehicles-list pattern reuse — reasoned deviations
- REUSED: header (+ static subtitle — see deviation A); borderless divider rows; frequent action
  DIRECTLY on each row (Start QC — the pattern's core); sheets for secondary (QC checklist stays the
  sheet); empty/loading/error vocabulary (mirroring skeleton, one-icon empty, retry error,
  pull-to-refresh).
- DEVIATION A (header count placement): the vehicles pattern puts the count in the header subtitle. Here
  the subtitle stays STATIC (`svReviewSubtitle`) — there is no honest existing count key (the awaiting
  length has no `svReview*Count` string), and composing one needs a NEW ARB key for information already
  evident from the rows (each row carries its own `done/total` pill). U4 (no invention, reuse existing
  copy) wins over a net-new key for marginal gain. Zero new keys.
- DEVIATION B (no list-scoped search icon — U1 note): this tab gets NO list-scoped search icon, at any
  size. Reason: top tasks are scan (rows fully visible, 1 tap) + Start QC (1 tap) — both already ≤ 2 taps
  with zero typing; the surface's ONE search path is the scaffold bar bay-search (same-scope rule from
  the technician single-search audit: one search path per surface), which covers QC-awaiting records by
  ref/title via `buildSupervisorBays(awaiting: ...)`. A header search icon would put TWO search
  affordances on one surface over overlapping scope — a C16 one-path-per-task violation. The > 5
  threshold therefore does not trigger a search icon here either.
- DEVIATION C (no `AppListGroup` card wrapper + no filter rail): rows are already borderless divider rows
  (C16-clean); there is no honest facet to filter on (all rows are "awaiting QC" by construction — a
  filter rail would be a fake control, U3). Rebuild keeps borderless rows with shared atoms.

## U-laws application (U0–U14, C17)
- U0 (one read): row = vehicle/customer (human-recognizable title) → progress pill → customer meta +
  tech → JC ref small mono LAST → Start QC. CARD HIERARCHY (binding, ruling (d)): title =
  `vehicleInfo` (fallback `customerName`, `titleSmall` w700, verbatim, 1-line ellipsis); pill ONLY from
  existing done/total (`svReviewProgress` — never invented); `customerName` = meta; JC ref = small mono
  (`supervisorMono`, 11, `onSurfaceVariant`, LTR-locked) LAST — consistent with owner cards.
- U1 (find fast): rows fully visible, scan-first; bar icon owns lookup (single search path — deviation
  B). No inline added (would duplicate the bar path's scope, which includes awaiting records).
- U2 (fit the content): heterogeneous rows (identity + pill + meter + full-width action) — grouped
  divider rows, NOT a data table (table matrix cell = N/A by design). FOLD (binding): at 360x800 the
  header + FIRST row sit above the fold (above bottom nav, idle with data) with the second row peeking;
  anything pushing the first row below the fold needs a written reason.
- U3 (no fake actions): rows map 1:1 to existing visuals; Start QC/Retry map 1:1 to handlers; NO filter
  rail (nothing honest to facet — inventing one would be a fake control).
- U4 (no invention): refs/customer/vehicle/tech verbatim via existing fields; zero as `0`; counts from
  loaded lists only.
- U5 (reachable + legible): 48dp targets on Start QC/Retry; JC ref LTR-locked; title + customer meta
  ellipsize (1 line each) at 320px / 1.3x, action wraps full-width (never clips).
- U6 (states): skeleton mirrors the rows (`AppShimmerSkeleton`); honest empty (`AppEmptyState`: EXACTLY
  one icon + one sentence + NO action — nothing to create, QC fills from completions); error
  (`AppErrorState` + Try again, same refresh); pull-to-refresh kept.
- U7 (feedback): Start QC opens the EXISTING checklist sheet (same contract); toasts inside the sheet
  untouched. One path per task (deviation B).
- U8 (no dead ends): every row offers Start QC; empty offers nothing-to-do honestly (no dead CTA);
  error offers Retry.
- U9 (consistency): `AppPageHeader`, divider rows, sheet — same atoms as staff precedent + screens 1–2.
- U10 (RTL): full mirror; JC ref/progress figures LTR-locked (`Directionality` kept).
- U11 (a11y): row `Semantics` kept; header `Semantics(header: true)`; live-region on error kept.
- U12 (density): 1-col compact; wider canvas keeps single-column register (grid chunking N/A by design).
- U13 (offline): bar banner owns offline state; stale list kept + refresh notice; retries inline.
- U14 (no regression): tap budgets above are ceilings; pull-to-refresh, keys, checklist-sheet + toast
  contracts unchanged in behavior.
- C17: any U-law fail caps at 8/16. C16 adaptations: no search-sheet/filter-rail (deviations B/C),
  borderless light rows, no ALL CAPS, zero as `0`.

## What is REMOVED or moved (structural, presentation only — no logic changes)
- REMOVED: bespoke `_QcRow` chrome (Stack/Container/Text/Divider code) → shared atoms (mono identity,
  pill, meta, meter, action, `AppDivider`) with byte-identical behavior; bespoke `EmptyState`/
  `AppSkeleton`/`AppInfoPanel` panels → `AppEmptyState` / `AppShimmerSkeleton` (row-mirroring) /
  `AppErrorState`+Retry. `PrimaryButton` row Start QC → `AppPillButton.primary` (same label/handler);
  `StatusPill.info` progress pill → `AppStatusChip` (info, same label). Pull-to-refresh kept.
- MOVED: nothing (Start QC/Retry keep seats; rows keep display + action).
- KEPT: scaffold bar + `selectedIndex != 0` guard + compact 4+More + expanded 7-rail (untouched);
  header title/subtitle/refresh action; awaiting derivation; progress math (`done/total`,
  `svReviewProgress`); providers/sync/refresh; `initialsOf`/mono helpers; checklist-sheet + toast
  contracts (sheet internals untouched), bottom nav, keys. No new routes. No invented items/statuses.
- Provider-owned quirk pinned (logic, untouched): first load never writes `reviewError`/`isReviewLoading`
  (only `refreshReview` does), so a cold failure surfaces the EMPTY state; the error/skeleton paths are
  refresh-driven and pinned via the header refresh action. The rebuild preserves this exactly.
- No new widgets kept back: if an App* atom lacks a behavior the old row had, EXTEND the App* atom
  (additively, with tests) then swap — never keep the legacy row for convenience.

## Fold wireframe (ASCII, 360×800 — header + first row above fold, second peeking)
```
+----------------------------------+
| Supervisor · Review      [🔍 bar] |  <- bar icon = bay/QC lookup (scaffold; single search path)
| Quality control            [↻]   |  <- AppPageHeader + refresh (1 tap)
| Verify completed repairs…        |  <- static subtitle (no count key — deviation A)
|----------------------------------|
| Yaris XYZ 5678          [4/4 done]|  <- row 1: vehicle/customer title + pill (above fold)
| Layla                (OH)  JC-207 |  <- meta + tech + JC small mono LAST
| ━━━━━━━━━━━━                     |
| [Start QC                     ]  |  <- frequent action ON the card (1 tap from list)
|----------------------------------|  <- fold line (nav below)
| Camry ABC 1234          [3/5 done]|  <- row 2 PEEKING
+----------------------------------+
| Floor | Jobs | Queue | Review |⋯ |
```

## Matrix requirements
- empty (no awaiting: one icon + one sentence, NO action — nothing to create) ·
- with-data (N awaiting rows, progress pills `done/total`, tech initials) ·
- no filter rail (nothing honest to facet — U3; no-match state N/A) ·
- error (refresh-driven Retry, same handler) + loading (refresh-driven row-mirroring skeleton) +
  stale/refresh ·
- ar (RTL mirrored; ref/figures LTR-locked) ·
- 1.3x (action wraps full-width, rows never clip) ·
- 320px (single column; header + first row intact) ·
- tablets (single-column register; rows max-width; table variant N/A by design per U2).

## Copy keys needed
Reuse existing staff keys (`svReview*`, `commonRetry`, `commonNoResults`, `commonErrorTitle`) — zero new
keys expected (phase-9 list: none). No ALL CAPS strings added.

## Acceptance
- U0–U14 walk (ANY U-law fail caps at 8/16); C16 hard-reject checklist (ANY violation caps at 10/16):
  borderless light rows, one filled accent per row (Start QC only), one path per task (single search
  path = bar), no permanent pills, no ALL CAPS, first row above fold + next peeking, card hierarchy
  (vehicle/customer title → pill → meta → JC small mono last, ruling (d)), taps never regress.
- Airbnb rubric ≥ 12/16 to pass.
- Gates: characterization tests on the CURRENT list first, before-images captured, migration table
  (current → shared atoms), reviewer process per redesign mandate, NO logic changes.
- Verify from code: tap counts, sheet call args, progress math, key names, scaffold guard + nav intact.
