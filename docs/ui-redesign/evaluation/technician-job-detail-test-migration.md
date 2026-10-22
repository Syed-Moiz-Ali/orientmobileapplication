# Technician job detail test migration (DETAIL family, screen 1)

Branch: `ui/detail-technician`. TechnicianJobDetailView recomposed
presentation-only onto App* pattern widgets: providers, sync/offline queue,
status machines, routing, sheet contracts, copy semantics, shell chrome
(`WorkspaceAppBar` guard) untouched; no new routes. One new ARB key
(`techDetailCompleteRepairOn`, en+ar, `gen-l10n` from `apps/staff_app`); seven
dead detail-only keys removed (six ALL-CAPS eyebrow keys + the replaced
confirm title).

## Per-screen brief determination (STEP b)

The family brief (`docs/ui-redesign/briefs/detail-staff-job-detail.md`)
already carries detail specifics: the top-3 tap table with BEFORE counts
verified from code (§Top 3 tasks), budgets (≤ BEFORE, most frequent ≤ 2),
and the 360x800 ASCII fold wireframe with the current-task card above the
fold. No separate per-screen brief file was needed.

Fold verified from the frozen before-frames
(`docs/ui-redesign/baseline/before-technician-job-detail/`,
`idle_light_1.0_en_360x800.png`): the `Start next task` focus CTA is fully
visible at 360x800 idle above the sticky dock — BEFORE start/complete is
2 taps, 0 scroll, matching the brief table.

## Status machine honored (read from code, never changed)

Task-level (`TaskStatus`: pending, inProgress, onHold, completed;
`work_task_entity.dart:6`; backend knows only pending/inProgress/completed,
hold is device-side per `work_task_entity.dart:3-5`):

- pending → inProgress via `notifier.startTask` (sets `startTime=now`)
  (`technician_providers.dart:628-644`): focus Start, row Start, toggle tap.
- inProgress → completed via `notifier.completeTask` (sets `endTime=now`)
  (`technician_providers.dart:647-664`): focus Complete, row Complete,
  toggle tap.
- inProgress → onHold via `notifier.updateTaskStatus(..., onHold)` (sent to
  the backend as `pending`) (`technician_providers.dart:666-690`): focus
  Hold, row Hold.
- onHold → inProgress via `notifier.startTask` = Resume (focus
  `job_detail_sheet.dart` old 479-481, kept verbatim in the rebuild).
- Derived job sync `_syncJobStatus` (`technician_providers.dart:754-760`):
  all tasks completed → `qcReview`; any inProgress → `inProgress`.
- `completeJob` (`technician_providers.dart:817-846`): every remaining task
  → completed, job → `qcReview`, per-task complete pushes, then `refresh()`.
- Read-only: `completed` + `qcReview` → `isActionable=false`
  (`job_detail_sheet.dart` old 72-74, kept): notice + no task actions + no
  sticky CTA.
- `delayed` is display-only (banner); no transition exists on this screen.

Primary CTA = the next valid action of the flow: running → Complete task;
pending → Start next task; held → Resume task; terminal (tasks remain) →
Complete repair (→ `qcReview`); empty/locked → no CTA (U6).

## Inventory (characterization baseline, STEP 0)

- `apps/staff_app/test/technician_job_detail_characterization_test.dart`
  (new, 13 testWidgets): behavior pins written for the CURRENT detail view
  with a fake `TechnicianRemoteDataSource` (growable copies; Hive
  `technician_jobs` box opened once in setUpAll in a fresh temp dir; the
  shared connectivity source pinned to wifi; 360x800 viewport so the focus
  panel sits above the fold exactly as the tap budgets assume). Run GREEN
  before the rebuild (13/13) and GREEN after (13/13). Frozen after STEP 0 —
  same 13 tests, counts 13 -> 13.
- State-copy finders use `textContaining` for the recomposed bidi-isolating
  atoms (`AppProgressBar` label, `AppEmptyState` message): the atoms wrap
  text in U+2066…U+2069 (invisible), so containment is green on the old
  plain-`Text` UI and on the new atoms.
- Harness-only fixes during authoring (production untouched): connectivity
  override (the detail app bar reads the shared connectivity source);
  360x800 viewport (off-screen tap misses at the default 800x600 surface);
  `ensureVisible` for below-fold rows; NO per-pump Hive clear (mutation
  tests leave the production `_persistJob` box.put unawaited, and a second
  `clear()` waits on it forever in FakeAsync — canonical state always comes
  from the fake remote, so the fresh-temp-dir box is never cleared).
- Fixture spelling: the fake simulates the REMOTE, so backend spellings are
  used (`qualitycheck` → `qcReview` via `TechJobStatusX.parse`; `qcReview`
  would parse to `pending`).
- The `completeJob` pin reads `selectedJob` (not `allJobs`): `completeJob`
  sets the handover on `selectedJob`, then its own `refresh()` reloads the
  fake-pristine list into `allJobs` — production behavior, not a bug (the
  server reports the handover post-refresh).
- Before pixels (frozen record, never regenerated):
  `docs/ui-redesign/baseline/before-technician-job-detail/` — `idle` (en/ar
  360x800, en 320x568, en 1.3x 360x800, en 768x1024), `empty`, `locked`,
  `delayed`. Produced by
  `apps/staff_app/test/technician_job_detail_before_capture_test.dart`
  (tagged `baseline`, excluded from the default run; fixtures keep every
  task pending/completed so the live stopwatch never ticks — shell-fix
  determinism precedent).
- After pixels (review only, same matrix):
  `docs/ui-redesign/baseline/after-technician-job-detail/` via
  `apps/staff_app/test/technician_job_detail_after_capture_test.dart`.

## Changed test assertions

| Test | Old | New | Kind |
|---|---|---|---|
| hero shows vehicle, job ref, status and progress | `find.text('1 of 3 tasks completed')` (plain `Text` in `AppLinearProgress` label) | `find.textContaining(...)` findsOneWidget (hero keeps the sentence; the sticky bar now carries status + ref instead of duplicating it — U5/320px fix) | structural (rendering-identical) |
| complete repair confirm | `find.text('Complete repair?')` + `AlertDialog` descendant | `find.textContaining("Complete repair on 'JC-101'?")` + `Dialog` descendant (U10 names the object; `showAppDialog` builds `Dialog`) | copy (new key, phase-9 list) + structural |
| empty shows the no-tasks hint | `find.text(hint)` | `find.textContaining(hint)` (recomposed `AppEmptyState` bidi-isolates) | structural (rendering-identical) |
| everything else (10 tests) | verbatim | verbatim | behavioral (unchanged) |

## Behavior assertions (verbatim, unchanged)

- Status machine + transitions above: zero logic diffs (providers, entities,
  sheets, router, sync queue untouched — `git status` shows only
  `job_detail_sheet.dart` in production scope).
- Taps BEFORE → AFTER (re-measured on the after-frames + tests):

  | Task | BEFORE (code + before-frames) | AFTER | Budget |
  |---|---|---|---|
  | Start / complete current task | 2 taps, 0 scroll (row → focus CTA, above fold at 360x800) | 2 taps, 0 scroll (identical; focus card above fold in after idle frame) | ≤ 2 ✓ |
  | Request part / escalate | 3 taps (row → sheet button → submit) | 3 taps (row → list row → submit; sheets keep their own submit) | ≤ 3 ✓ |
  | View activity | 1 tap + scroll (task rows carry status + start/end times) | 1 tap + ≤ same scroll (≤ 3 rows inline; `View all` sheet only when > 3 — U7) | ≤ 1 + same scroll ✓ |
  | Complete repair (not budgeted, must not regress) | 3 taps (row → dock → confirm) | 3 taps (row → sticky bar → confirm naming the ref) | no regression ✓ |

- One status pill per screen (header trailing; the hero's second pill was
  removed). One filled accent per section (focus: ONE primary + ghost Hold;
  rows: secondary/ghost only; sticky bar / wide rail: ONE primary each, never
  both — viewport-gated as before).
- Copy keys: all existing keys reused verbatim; one new key
  `techDetailCompleteRepairOn` (`Complete repair on '{ref}'?` / ar draft —
  phase-9 list, ar needs native review); seven dead keys removed (six
  ALL-CAPS eyebrow keys + replaced `techDetailConfirmTitle`).
- C13 forbidden-pattern grep clean for the touched module (one pre-existing
  `Duration(milliseconds: 250)` debounce guard kept verbatim — behavior
  timing, not motion).

## WIDGET_MIGRATION_MAP delta (this screen)

- `AppCard.standard(` (hero + focus + rows + notice) → `AppSurfaceCard(outlined: false)` (borderless light, shadow; dark keeps border automatically).
- Bespoke `_GreaseButton.fill` (cobalt/amber/emerald) → `AppPillButton.primary` (focus next step, `busyLabel` for Starting/Completing/Resuming) + `AppPillButton.ghost` (Hold).
- Bespoke `_TaskAction` (filled/outlined triplets) → `AppPillButton.secondary` (Start/Complete/Resume, small + icon) + `AppPillButton.ghost` (Hold, small + icon); meaning via icon + label, never color alone (C2).
- Bespoke `PrimaryButton` dock → `_HandoverBar` (custom sticky composition: spec chrome — surface, top hairline, safe area, keyboard viewInsets — with CTA-priority flex; `AppStickyActionBar`'s 50/50 split truncates the CTA at 320px, U5) on compact; the same `AppPillButton.primary` in the wide rail (never both).
- `showAppConfirmationDialog` → `showAppDialog` (title `techDetailCompleteRepairOn(ref)`, body/cancel/confirm verbatim, explicit bool pops).
- `showAppModalSheet` (parts/escalation) → `showAppBottomSheet` (same sheet content with its own submit — no added steps).
- Bespoke `_DelayedNotice` Container → `AppBanner` warning (`techDetailDelayedHint` verbatim).
- `SectionHeader` (ALL-CAPS subtitles) → `AppSection` (sentence-case titles, `View all` only when > 3 — U7).
- Bespoke `_HelpActions` outlined buttons → `AppListGroup` (Support rows + chevrons + inset dividers → bottom sheets).
- No-tasks hint → `AppEmptyState` (no action — U6 calm).
- `AppLinearProgress` → `AppProgressBar` (same value + label, pinned accent tone).
- `WorkspaceAppBar` + `onSearch` (NEW wiring to the existing `showTechnicianTodaySearch` sheet: same jobs, same predicate, same `openJob`/`push`/`closeJob` contract — U1 header search placement).
- KEPT (STOP/pinned, not legacy): `technicianStatusPill`/`StatusPill` (shared `technician_components.dart` with Today/Jobs), `TechnicianStopwatch`/`TechnicianPlateChip` (display-only), `PartsRequestSheet`/`EscalationSheet` content, `TechnicianJobSummary` rows elsewhere, all providers/routes/sync/status machines, medium-breakpoint single-column + sticky bar (verbatim `adaptive.pick` parity — dossier + rail only at expanded), offline/pending chrome in the app bar.

## Review pass (fresh eyes, 2026-10-22 — presentation only)

Inspected every after-frame against the checklist; fixed 2, kept 1:

- FIXED (U5): sticky summary + CTA squeezed the progress sentence into a
  mid-word break (`com|pleted`) at 360px. Summary rescoped to status + ref
  (existing keys only — the brief's example abbreviates; no new key per the
  keys rule), then the whole bar recomposed CTA-priority when the atom still
  truncated the CTA at 320px (`Complete rep…`). After: full CTA + no breaks
  at 320/360/1.3x/ar.
- FIXED (C16): second status pill in the hero (header trailing + hero).
  After: exactly one pill per screen.
- KEPT: the permanent `Synced` pill in `WorkspaceAppBar` (shared shell
  chrome — STOP, owning phase; C16 hard-reject item recorded, not fixed
  here). Medium (768) renders single-column + sticky bar — verbatim parity
  with the old `adaptive.pick` (dossier + rail only at expanded).
- ar frame: full RTL mirror (search/sync left, breadcrumbs mirrored,
  refs/plates/times LTR-locked, progress bar grows from the start edge,
  tabular numerals kept). 1.3x: no overflow, targets ≥ 48dp. Wide: search
  shortcut affordance comes from the shared app bar (unchanged chrome).

## STOPs filed (logic untouched — orchestrator routes these)

- S1 login state-machine / step-flow demand: none encountered (no auth
  logic on this surface).
- S2 advisor compact activity rail: untouched file, out of scope.
- S3 status-machine changes: none needed; `completeJob`/handover payloads
  verified working through the existing `refresh()` contract (see
  `selectedJob` pin note above).
- S4 shared chrome STOPs: `WorkspaceAppBar` (+ permanent `Synced` pill),
  `technicianStatusPill`/`StatusPill`, `TechnicianStopwatch`,
  `TechnicianPlateChip`, rail breakpoint pick — kept byte-identical.
- S5 missing translations: one new ar string drafted
  (`techDetailCompleteRepairOn`) — flagged REVIEW_NEEDED (native review),
  never claimed verified.
- S6 no loading/error/offline-banner states on the detail itself: the view
  is entity-driven; async states live on the list screens (pinned by their
  suites). Offline mutations keep queuing (the caught sync-queue log in
  tests is that path working).
- S7 inventory honesty: no activity feed exists on this surface — the task
  rows with start/end times ARE the timeline (same scroll region); > 3
  tasks disclose via `View all` sheet (U7-sanctioned).

## Phase-9 list (new ARB keys)

- ADDED `techDetailCompleteRepairOn` (`Complete repair on '{ref}'?` /
  `إكمال الإصلاح على '{ref}'؟` — ar draft, REVIEW_NEEDED).
- REMOVED `techDetailConfirmTitle` (replaced) + `techDetailCurrentTask`,
  `techDetailNextTask`, `techDetailOnHold`, `techDetailExecution`,
  `techDetailAllTasks`, `techDetailNeedHelp` (dead ALL-CAPS eyebrow keys,
  zero non-gen references at removal).
- `flutter gen-l10n` clean from `apps/staff_app`; `flutter analyze --no-pub`
  clean; full `flutter test --exclude-tags baseline` green (122/122,
  includes the 13 characterization tests).
