# Supervisor Review list test migration (GROUP-C list-ops, screen 3)

Branch: `ui/list-ops`. Review tab recomposed presentation-only onto App*
pattern widgets: providers, awaiting derivation, progress math, refresh/sync
logic, checklist-sheet entry + sheet/toast contracts (sheet internals
untouched), copy semantics, scaffold bar guard (`selectedIndex != 0`),
compact 4+More + expanded 7-rail untouched; no new routes, no new ARB keys.

## Inventory (characterization baseline, STEP 0)

- `apps/staff_app/test/supervisor_review_list_characterization_test.dart` (new,
  6 testWidgets): behavior pins written for the CURRENT Review UI with a fake
  `SupervisorRemoteDataSource` (`_FakeSupervisorRemote` returning growable
  awaiting copies — production parses growable lists and the notifier mutates
  them in place on approve/reject; const fixtures would throw where production
  never does; Hive misses are caught+logged by the provider, no box needed).
  Run GREEN before the rebuild (6/6) and GREEN after (6/6). Frozen after
  STEP 0 — same 6 tests, same assertion shapes, counts 6 -> 6.
- State-copy finders use `textContaining` for empty/error strings: the
  recomposed `AppEmptyState`/`AppErrorState` bidi-isolate title+message
  (U+2066…U+2069, invisible), so containment is green on the current
  `EmptyState`/`AppInfoPanel` UI and on the new atoms. Ref/pill/action copy
  stays `text` (plain `Text` pre and post; `AppStatusChip` exposes real `Text`
  under `ExcludeSemantics`, still `find.text`-visible).
- Sheet-entry pin: row Start QC opens `showQcChecklistSheet` (`svQcTitle`
  `Quality control review` + job ref visible); sheet internals NOT in scope.
- Pinned provider-owned quirk (logic, untouched): first load never writes
  `reviewError`/`isReviewLoading` (only `refreshReview` does), so a cold
  failure surfaces the EMPTY state; the error/skeleton paths are
  refresh-driven and pinned via the header refresh action. Preserved exactly.
- Before pixels (frozen record, never regenerated):
  `docs/ui-redesign/baseline/before-supervisor-review/` — `idle` (en/ar
  360x800, en 320x568, en 1.3x 360x800, en 768x1024), `empty`, `error`
  (refresh-driven), `loading` (refresh-driven, skeleton). Produced by
  `apps/staff_app/test/supervisor_review_list_before_capture_test.dart` (tagged
  `baseline`, excluded from the default run).
- After pixels (review only, same matrix):
  `docs/ui-redesign/baseline/after-supervisor-review/` via
  `apps/staff_app/test/supervisor_review_list_after_capture_test.dart`.

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| header shows title, subtitle and refresh | Static subtitle + refresh `IconButton` | verbatim (subtitle stays static per brief deviation A; refresh kept) | behavioral (unchanged) |
| rows render ref, identity, progress and start action | `StatusPill.info` progress pill + `AppLinearProgress` + `PrimaryButton` | `AppStatusChip` (info, same `svReviewProgress(done,total)` label) + `AppProgressBar` (pinned tone: success-when-complete else accent — C2 fix, same value) + `AppPillButton.primary`; same finders, still green | structural (rendering-identical) |
| start opens the qc checklist sheet for the job | `showQcChecklistSheet` entry | verbatim (sheet internals untouched) | behavioral (unchanged) |
| empty review shows the clear state with no action | Legacy `EmptyState` (no action) | `AppEmptyState` (no action — honest empty, U6/U8) | structural (rendering-identical) |
| review refresh failure shows the error with retry | `AppInfoPanel.danger` + Retry | `AppErrorState` (title `commonErrorTitle`, message `svReviewError` verbatim, retry `commonRetry` → same refresh) | structural (rendering-identical) |
| review refresh loading shows no rows and no error | `AppSkeleton.listRows(5)` | `AppShimmerSkeleton.listRows(5)` | structural |

## Behavior assertions (verbatim, unchanged)

- Tap counts (brief BEFORE, verified from code): open list = tab (**1 tap**);
  start QC = row Start QC (**2 taps** from list, ≤ same scroll, same sheet);
  retry = Retry (**1 tap**) / pull. AFTER: identical.
- Provider reads identical: `supervisorDashboardProvider` (+ notifier
  `awaitingCompletions`, `refreshReview`) untouched.
- Progress math identical: `(done/total).clamp(0,1)`, `svReviewProgress(done,total)`
  verbatim; tech initials + customer·vehicle verbatim; no filter rail (nothing
  honest to facet — U3, inventing one would be a fake control).
- No-search-icon deviation honored (brief deviation B): the surface's single
  search path stays the scaffold bar bay-search (which covers QC-awaiting
  records via `buildSupervisorBays(awaiting: ...)`); no list-scoped search
  added. Header subtitle stays static (deviation A). Scaffold nav untouched.
- Copy keys: zero new (reused `svReview*`, `svQcTitle`, `commonNoResults`,
  `commonErrorTitle`, `commonRetry`). Phase-9 list: none.

## WIDGET_MIGRATION_MAP delta (this screen)

- `PrimaryButton(` (row Start QC) → `AppPillButton.primary`
  (full-width, same label/icon/handler). No remaining `PrimaryButton` in
  `supervisor_review_tab.dart`.
- `StatusPill.info(` (progress pill) → `AppStatusChip` (info, same label).
  No remaining `StatusPill` in the file.
- `EmptyState(` (1 site, no action) → `AppEmptyState` (1:1 copy).
- `AppSkeleton.listRows(` (1 site) → `AppShimmerSkeleton.listRows(rows: 5)`.
- `AppInfoPanel.danger(` (1 site) → `AppErrorState` (title/message/retry 1:1).
- `AppLinearProgress(` (1 site) → `AppProgressBar(value:, tone:)` (pinned
  success/accent — C2 fix).
- `Divider(` (1 site) → `AppDivider()`.
- KEPT (pinned/not legacy): `AppPageHeader` + header refresh, `showQcChecklistSheet`
  entry + sheet/toast contracts (sheet internals untouched), mono/initials
  helpers, scaffold bar + nav (untouched files).

## Adversarial-fix pass (ui/list-ops, 2026-10-22 — presentation only)

Verified every D1–D8 claim in `adversarial-sv-review-review.md` against the
full widget tree (tab + `supervisor_scaffold.dart` shell) + code. Fixed 2,
rebutted 5 with file+line evidence. Zero new ARB keys; progress math,
providers, sheet entry/routes untouched; characterization counts 6 -> 6.

FIXED (code + recaptured `after-supervisor-review/` 5 idle frames, 38/38
back-to-back green with the other three screens):
- D2 (C2/U10 4/4 red bar): row `AppProgressBar(value:)` auto tone painted
  ready-to-deliver FULL RED while 3/5 painted green. Pinned `tone:`
  success-when-complete else accent (`supervisor_review_tab.dart` `_QcRow`);
  same progress value, token only. AFTER: 4/4 green + info pill; partials
  neutral blue (matches BEFORE blue bars, never contradicts the pill).
- D5-partial (U13 cryptic initials): `OH`/`SA` initials now carry the feed's
  full technician name as a `Tooltip` + screen-reader label (zero new copy;
  layout/pixels unchanged). Residual: full names don't fit the row — a
  layout change would need a design decision; recorded, non-gating.

REBUTTED (no code change; evidence):
- D1 (C16/U0 ID-first hierarchy): APPROVED binding — brief U0 (lines 84–86)
  mandates "title = jobCardRef (mono, LTR, verbatim); pill ONLY from
  done/total; customer·vehicle = meta" (the supervisor recognizes the QC
  job by its card ref; sibling jobs is vehicle-first because its task is
  floor-scan, different task). Overriding = design decision → STOP if pursued.
- D3 (U1 no search): CAPTURE-FRAMING artifact — shell `_SupervisorChrome`
  search icon renders on this tab (`supervisor_scaffold.dart:401-406`).
  Single search path sanctioned (brief deviation B; bar bay-search covers
  QC-awaiting via `buildSupervisorBays(awaiting: ...)`). Taps unchanged.
- D4 (C16 twin Start QCs): per-ITEM actions — each opens a different sheet
  instance (different `jobCardId/Ref/customer/workItems` args), same as the
  queue's per-row Assign family pattern (sanctioned: brief acceptance "one
  filled accent per row (Start QC only)"). One path per task holds.
- D6 (sheet: photo tiles + red/green bar): OUT OF SCOPE — brief pins sheet
  internals untouched. Verified honest: tiles are plain `Container`s with NO
  tap handler (`qc_checklist_sheet.dart:467-522`) + explicit disclosure note
  (`svQcPhotoUnavailable`, lines 514–519, "no backend endpoint", lines
  464–466); red Send-back + green Approve is the sanctioned destructive-
  confirm pair (Approve disabled until all checked, line 253) — correct C2
  usage, not decoration.
- D7 (U9 orphan refresh): same shared-atom responsive contract as queue D4
  (`app_page_header.dart:113-123`); tablet same-row via the same atom. 1-tap,
  tooltip'd, above-fold. Wireframe same-row tension noted, not a violation.
- D8 (skeleton/empty/error/tablet): skeleton = shared harness atom
  (non-gating, owning-phase STOP); empty/error honest with no dead CTA
  (nothing to create); tablet correct.

Tap walk AFTER-fix: open ≤1 ✓ · start QC 2 ✓ · retry 1 ✓. The `OH/SA`
pixels are unchanged (tooltip is long-press/SR only) — no golden churn.
