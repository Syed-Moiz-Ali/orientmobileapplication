# Technician job detail — Fresh review ROUND 1 (PASS 15/16)

**Role:** FRESH REVIEWER (round 1), never built this screen. READ-ONLY except this file. No code/tests/PNGs edited. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/detail-technician`.
**Read first:** Brief `docs/ui-redesign/briefs/detail-staff-job-detail.md` (authoritative, incl. transitions pending→inProgress→completed/onHold, derived qcReview, completed/qcReview read-only, delayed display-only, primary CTA = next valid action, C9 anatomy, tap budgets start/complete 2 / part-escalate 3 via sheet / activity 1+scroll latest-3 + Show-all sheet); migration `docs/ui-redesign/evaluation/technician-job-detail-test-migration.md` (pins: 13/13 characterization GREEN before+after, tap re-measurement, WIDGET_MIGRATION_MAP delta, S1–S7 STOPs); REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 C17 (caps 8/16). Pass ≥ 12/16.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (per brief §References, confirmed UNMET — precedent patterns + phase-5/staff precedent used instead, nothing claimed as consulted).
**Images viewed (AFTER via Read, full resolution + BEFORE contrast):**
- AFTER `docs/ui-redesign/baseline/after-technician-job-detail/`: `idle_light_1.0_en_360x800`, `idle_light_1.0_ar_360x800`, `empty_light_1.0_en_360x800`, `locked_light_1.0_en_360x800` (JC-105 QC Review), `delayed_light_1.0_en_360x800` (JC-102), `idle_light_1.0_en_320x568`, `idle_light_1.3_en_360x800`, `idle_light_1.0_en_768x1024`, `done_light_1.0_en_360x800` (JC-108 Completed), `loading_light_1.0_en_360x800`, `error_light_1.0_en_360x800`, `sheet_light_1.0_en_360x800` (4-assigned View-all sheet).
- BEFORE `docs/ui-redesign/baseline/before-technician-job-detail/`: `idle_light_1.0_en_360x800`, `empty_light_1.0_en_360x800`, `locked_light_1.0_en_360x800`, `delayed_light_1.0_en_360x800` (+ ar/320/1.3x/tablet idle set viewed for fold contrast).
- Contact sheet `docs/ui-redesign/baseline/phase-tech-detail-light.png`: BEFORE (left) vs AFTER (right) idle en 360x800 side-by-side.
**Code read-only (attribution only):** `apps/staff_app/lib/features/technician/presentation/widgets/job_detail_sheet.dart` (`TechnicianJobDetailView`, `_HandoverBar:257`, `_HeroCard:332`, `_ExecutionArea:415`, `_FocusPanel:516`, `_TaskList:684`/`_TaskRow:723`, `_GreaseToggle:895`, `_ContextColumn:983`).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle en 360 — `idle_light_1.0_en_360x800.png`
- **App bar region:** back arrow left, `Job details` title, search magnifier icon in rounded square + green `Synced` pill with cloud icon right.
- **Header region:** `Jobs > JC-101` breadcrumb line (Jobs blue), `Toyota Camry` large title, `In Progress` pill with dot below title.
- **Hero card region:** rounded card containing blue `JC-101` top-left, `Toyota Camry` bold, `ABC 1234` plate chip + `Ahmed` muted side-by-side, `1 of 3 tasks completed` muted left + `33%` bold right, thin blue progress bar below.
- **Focus section region:** `Next task` section title, rounded card with `Replace brake pads` title + full-width blue pill button `▶ Start next task`.
- **Checklist region:** `3 assigned` section title, first task card visible: green check circle, `Change engine oil` with strikethrough, `Completed` green + `08:30 – 08:50` muted tabular; second task card top edge visible (`Replace brake pads` title fragment).
- **Sticky bar region (bottom, above fold):** top hairline, left column `In Progress` muted over `JC-101` bold mono LTR, right blue pill `⊙ Complete repair` filling remainder width.

### AFTER idle ar 360 — `idle_light_1.0_ar_360x800.png`
- Mirrored layout: back arrow right, `تفاصيل المهمة` title, `Synced`/`متزامن` pill + search icon left. Breadcrumb `المهام < JC-101` right-aligned, `Toyota Camry` Latin title right-aligned, `In Progress` pill left-below. Hero: `JC-101` blue right, `Toyota Camry` bold right, `Ahmed` + `ABC 1234` chip, progress sentence Arabic right + `33%` left, bar fills from right. Focus card: `المهمة القادمة` title, `Replace brake pads` Latin, blue pill `بدء المهمة التالية ◀`. Checklist row mirrored with green check right. Sticky bar mirrored: CTA right-to-left with `إكمال الإصلاح`, summary `In Progress / JC-101` left.

### AFTER empty — `empty_light_1.0_en_360x800.png` (JC-106 Honda Civic, Pending)
- Header `Jobs > JC-106`, `Honda Civic`, yellow `Pending` pill. Hero card: `JC-106` blue, `Honda Civic`, `MNO 1122` chip + `Lina`, no progress bar. Middle: lavender circle with inbox icon, `No tasks` bold, two-line sentence `No tasks have been added to this job. Ask the advisor before starting work.` Below: `Support` title, two list rows `Request part >` and `Escalate issue >` with leading icons and inset divider. No sticky bar visible.

### AFTER locked (QC Review) — `locked_light_1.0_en_360x800.png` (JC-105 Toyota Corolla)
- Header `Jobs > JC-105`, `Toyota Corolla`, `QC Review` pill with info icon. Hero: `JC-105`, `Toyota Corolla`, `JKL 7890` chip + `Omar`, `1 of 1 tasks completed` + `100%`, full blue bar. Section `Repair tasks complete`, notice card with teal list-check icon + sentence `Repair work has been submitted for supervisor QC review.` Section `1 assigned`, one task card: green check, strikethrough `Change engine oil`, `Completed 08:00 – 08:30`. `Support` title + `Request part >` / `Escalate issue >` rows. No sticky bar.

### AFTER delayed — `delayed_light_1.0_en_360x800.png` (JC-102 Nissan Yaris)
- Header `Jobs > JC-102`, `Nissan Yaris`, red `Delayed` pill. Hero: `JC-102`, `Nissan Yaris`, `XYZ 5678` chip + `Sara`, `0 of 1 tasks completed` + `0%`, empty track bar. Amber warning banner card with triangle icon + three-line sentence about delayed repair. `Next task` + focus card `Inspect brakes` + blue `▶ Start next task`. `1 assigned` + first row fragment. Sticky bar: `Delayed / JC-102` left, blue `Complete repair` right.

### AFTER done — `done_light_1.0_en_360x800.png` (JC-108 Toyota Corolla, Completed)
- Header `Jobs > JC-108`, `Toyota Corolla`, green `Completed` pill. Hero `JC-108`, `2 of 2 tasks completed` + `100%`, full bar. `Repair tasks complete` + notice card `This repair is completed. Technician edits are locked.` with green badge icon. `2 assigned` + two task cards, both green check + strikethrough + `Completed` + time ranges (`08:30 – 08:50`, `09:00 – 09:40`). No sticky bar in frame.

### AFTER 320px — `idle_light_1.0_en_320x568.png`
- Same stack as idle 360, narrower: app bar, breadcrumb, title, pill, hero (`JC-101`, `Toyota Camry`, `ABC 1234` + `Ahmed`, `1 of 3 tasks completed` + `33%`, bar), `Next task` + `Replace brake pads` + top half of blue Start button visible at crop edge, sticky bar `In Progress / JC-101` + full `Complete repair` text.

### AFTER 1.3x — `idle_light_1.3_en_360x800.png`
- Same stack at larger text: all strings from 320 present with larger glyphs, Start CTA fully visible in-frame, sticky bar with two-line summary + full CTA label.

### AFTER tablet 768 — `idle_light_1.0_en_768x1024.png`
- Wider canvas, single column: top bar with `← Job details` left, `Search CtrlK` field + `Synced` right. Breadcrumb + `Toyota Camry` title left, `In Progress` pill right on same row. Hero full-width (`JC-101`, vehicle, plate, `1 of 3 tasks completed` + `33%`). `Next task` focus card full-width with Start CTA. `3 assigned` with three task cards stacked (first Completed with times, next two Pending with outline `▶ Start` rows). Sticky bar full-width at bottom.

### AFTER loading vs error — `loading_light_1.0_en_360x800.png` / `error_light_1.0_en_360x800.png`
- Both frames show identical stack: header `Jobs > JC-101`, `Vehicle` title, yellow `Pending` pill, hero card `JC-101` + `Vehicle` + `Plate not recorded` chip (no customer, no progress bar), centered inbox icon + `No tasks` + same two-line sentence, `Support` + `Request part >` / `Escalate issue >` rows, no sticky bar.

### AFTER activity sheet — `sheet_light_1.0_en_360x800.png`
- Dimmed detail background (`Jobs > JC-109` top), foreground bottom sheet with handle: title `4 assigned`, four task cards each with outline circle icon, task name (`Change engine oil`, `Replace brake pads`, `Rotate tires`, `Top up fluids`), `Pending` muted, outline `▶ Start` row button.

### BEFORE idle en 360 vs AFTER (contact sheet `phase-tech-detail-light.png`)
- BEFORE left: bordered thin-outline cards, hero carries second `In Progress` pill top-right inside card, section titles with ALL-CAPS eyebrow lines (`NEXT TASK` blue inside card, `EXECUTION` gray under `Next task`, `ALL TASKS` under `3 assigned`), focus CTA rectangular blue `Start next task`, dock full-width rectangular blue `Complete repair` without status summary.
- AFTER right: same seats and copy, cards without visible borders (soft shadow), hero has no second pill, no ALL-CAPS eyebrow lines (sentence-case `Next task` / `3 assigned` only), focus CTA stadium pill, sticky bar with status-summary column + stadium CTA.

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — one read: identity → current task → ONE next step; progress sentence under hero; IDs meta | idle-360: breadcrumb `Jobs > JC-101` → `Toyota Camry` → hero `JC-101 / Toyota Camry / ABC 1234 / Ahmed / 1 of 3 tasks completed 33%` → `Next task / Replace brake pads / Start next task` → sticky `In Progress JC-101 + Complete repair`. IDs (`JC-101`) blue meta / mono LTR, never headline alone | PASS |
| U1 — search icon top-right → full-screen search over jobs; never inline mid-detail | idle-360/320/1.3x/locked/delayed/empty/done: magnifier icon in app-bar top-right next to `Synced`; tablet-768: `Search CtrlK` affordance from shared app bar. Code `_openSearch:64` → `showTechnicianTodaySearch(allJobs, openJob/push/closeJob)` — same jobs, same predicate, same dossier contract; zero inline fields in body | PASS |
| U2 — first actionable item (current-task card) above fold at 360x800 idle | idle-360: `Next task / Replace brake pads / Start next task` card fully visible above sticky bar, zero scroll; delayed-360 same (`Inspect brakes / Start next task`); 320: title + CTA top visible with sticky bar (stress width, fold earlier by design) | PASS |
| U3 — tap counts: start/complete ≤2, part/escalate ≤3 via sheet, activity ≤1+scroll (brief binding) | Code + pins (see §3): focus primary direct `notifier.startTask/completeTask`, Support rows → `showAppBottomSheet(PartsRequest/EscalationSheet)` with own submit, checklist `take(3)` + `View all` sheet only when >3. idle/tablet/sheet frames corroborate seats | PASS |
| U4 — primary CTA reachable in sticky bar (lower half); keyboard-safe | idle-360/320/1.3x/delayed/tablet: `Complete repair` in bottom sticky bar (thumb zone). Code `_HandoverBar:257`: `SafeArea(top:false)` + `MediaQuery.viewInsetsOf(bottom)` padding, `AppPillButton.large` ≥48dp; summary intrinsic width + CTA expanded so label never truncates at 320. No keyboard frame in set — stills-limited, code-verified | PASS (code-verified, stills-limited for keyboard) |
| U5 — no truncation: names wrap ≤2 lines, refs/plates/VIN/ODO LTR; ellipsis secondary only | idle/ar/320/1.3x/tablet: `Toyota Camry`, `Replace brake pads`, `Change engine oil` whole; `JC-101`, `ABC 1234`, `08:30 – 08:50`, `09:41`-style times LTR-locked via `Directionality(ltr)` (hero:356, bar:299, rows:821). 320/1.3x: no mid-word breaks, no `…` on primary; tablet full plate/times. loading/error `Plate not recorded` fallback sentence, not `-` | PASS |
| U6 — calm empty: icon + sentence + action; no filled CTA to nothing; skeleton/error/honest states | empty-360 (JC-106): lavender inbox icon + `No tasks` + sentence, hero with no progress bar, sticky bar hidden (`canComplete` false), Support rows remain. loading/error-360: same calm fallback (see gap (b) below — entity fallback, not skeleton/error atoms on this surface). done/locked: notice + no sticky CTA, no task actions | PASS with adjudicated gap (b) — see below |
| U7 — one path per task; See-all only when more items exist | idle-360/tablet: single `Start next task` focus primary per section; rows secondary `Start` / ghost `Hold` (glove-first content, brief-KEPT); `seeAllLabel View all` only when `tasks.length>3` (`_ExecutionArea:450`), sheet-360 proves 4-assigned sheet; sticky vs wide-rail CTA viewport-gated (`wide || !canComplete ? null`, rail `showHandover:wide`) — never both | PASS |
| U8 — relevance: completed/qcReview read-only, no actions; delayed display-only; data issues → LOGIC_FOLLOWUPS | done-360 (Completed): notice `edits are locked`, rows Completed-only with no buttons, no sticky bar (`isActionable` false:93), Support hidden (`completed → shrink`:1007). locked-360 (QC Review): notice `submitted for supervisor QC review`, rows no buttons, no sticky bar. delayed-360: `AppBanner.warning` + normal execution (banner display-only, transitions untouched per migration). Zero silent filtering — status machines verbatim | PASS (QC Support rows kept = preserved behavior, see defects) |
| U9 — consistency: same header/search/back/CTA placement as list screens | All frames: `WorkspaceAppBar` back + search + offline status, `AppPageHeader` breadcrumbs + vehicle title + trailing pill, `AppSurfaceCard(outlined:false)`, `AppProgressBar`, `AppSection`, `AppListGroup`, `AppBanner`, `AppEmptyState` — same atoms as staff precedent; tablet search affordance from shared chrome (unchanged) | PASS |
| U10 — feedback + destructive confirm naming the object; errors say what to do | Code `_confirmComplete:229`: `showAppDialog(title: techDetailCompleteRepairOn(jobCardNo))` — `Complete repair on 'JC-101'?` + body/cancel/confirm verbatim, explicit bool pops; `_mutate` busy guard + 250ms anti-double-tap + haptics; rows carry status + start/end times as immediate feedback. Confirm dialog pixels not in set — code+pin verified, stills-limited | PASS (code + characterization pin; dialog pixels not in matrix) |
| U11 — readable numbers: 0 never `-`, tabular, signed deltas | Hero `1 of 3 tasks completed 33%`, delayed `0 of 1 tasks completed 0%` (honest `0`, not `-`), done `2 of 2 100%`; row times `08:30 – 08:50` tabular LTR (`FontFeature.tabularFigures`); plate chips; no bare `-` anywhere | PASS |
| U12 — one background | All frames: single page background, borderless light cards separated by whitespace + hairline sticky-bar top border only; no stray bands behind rows; tablet single column same background | PASS |
| U13 — new-employee labels: plain verbs, no jargon | `Next task`, `Start next task`, `3 assigned`, `Request part`, `Escalate issue`, `Complete repair`, `No tasks / Ask the advisor…`, `Repair tasks complete`, `Plate not recorded` — no grease/dossier/escalation jargon in UI; status labels sentence-case (`In Progress`, `Pending`, `Delayed`, `Completed`, `QC Review`) | PASS |
| U14 — a11y: 48dp, AA, Semantics, 1.3x, 320px | 1.3x-360: no overflow, CTA + rows whole, targets intact; 320-568: summary + full `Complete repair` legible, no clipping; code: `Semantics(header)`:349, `Semantics(label task…)`:758, `Semantics(button)`:922, `MergeSemantics` bar:288, `liveRegion`:544, 28px visual inside 48dp `touchTarget`:939, icon+label+dot never color-alone. AA/Semantics stills-limited, pins hold | PASS (stills-limited for SR/contrast) |

**Explicit C16/C9/one-pill/one-CTA checks (required):**
- **One pill:** header trailing `technicianStatusPill` only — hero second pill removed (before had 2, after has 1 in every frame: idle/ar/delayed/empty/locked/done/tablet). Migration FIXED item corroborated.
- **One CTA:** focus section exactly ONE filled accent (`AppPillButton.primary` Start/Complete/Resume + ghost Hold only when running:630–676); rows secondary/ghost only (:850–882); sticky bar / wide rail exactly ONE primary each, viewport-gated never both (:177–185, :1012–1016). idle/delayed/tablet/sheet frames show this seating.
- **C9 anatomy hero→facts→groups→activity→sticky bar:** `_HeroCard` (identity + progress) → `_ExecutionArea` (focus Current/Next + `3 assigned` checklist facts) → `_ContextColumn AppListGroup` (Support groups → sheets) → task rows activity (status + `Started`/`start–end` times, latest-3 + `View all` sheet) → `_HandoverBar` sticky (summary + handover CTA) / wide rail CTA. idle→sheet→tablet trace this order top-to-bottom (tablet single-column at medium per `adaptive.pick` parity).
- **CTA visibility without scroll at 360x800:** idle-360 + delayed-360: `Start next task` focus CTA fully above fold + sticky `Complete repair` fully visible, 0 scroll (matches brief ASCII fold + migration fold note).
- **Taps (2/3/1+scroll):** §3 re-measured — no regression.
- **Keyboard-safe sticky bar:** `_HandoverBar` adds `viewInsets.bottom` to padding + `SafeArea`, wraps summary above CTA at 320/1.3x — code-verified, no keyboard-open pixel in matrix (disclosed stills limit, not a fail).
- **Gap (a) NO running-state frame:** no pixel with live stopwatch ticking; fixtures keep tasks pending/completed for determinism (0.06% drift note). Code path present (`TechnicianStopwatch` in focus:646 + rows:842, `running → Complete + ghost Hold`, `held → Resume`). Characterization pins `Complete` instead of wall-clock — adjudicated NON-GATING (see defects).
- **Gap (b) loading vs error byte-identical:** `loading_*` and `error_*` pixels identical (Vehicle / `Plate not recorded` / `No tasks` fallback). Architecture: detail is entity-driven (`liveJob` fallback to route-time entity:87–92), async states live on list screens (migration S6). Adjudicated NON-GATING with 1 merit deduction (states-matrix proof gap on this surface, not a U-law breach — U6 calm-empty still holds, no CTA to nothing).

**U-walk fails: 0. C17 cap: none. C16 hard-reject on this screen: none (Synced shell pill = STOP, see defects).**

---

## 3. Top-task tap walk BEFORE→AFTER (budgets ≤ before, most frequent ≤ 2)

BEFORE (brief §Top 3 + migration re-measurement, code-verified): row → `push(technicianJobDetail)` (1) + focus/row Start/Complete direct (1) = 2, 0 scroll; part/escalate = detail (1) + sheet button (1) + submit (1) = 3; activity = detail (1) + scroll (task rows with status/times); Complete repair = detail + dock + confirm = 3.

| Task | Before | After (pixels + code) | Verdict |
|---|---|---|---|
| 1. Start / complete current task | 2 taps, 0 scroll (row → focus `Start next task` above fold) | 2 taps, 0 scroll: same seats — idle-360 focus CTA fully above fold, `_FocusPanel` primary → `onStart/onComplete` → `notifier.startTask/completeTask` direct (:97–108), `_GreaseToggle` tap advances (:928–937), busy guard prevents double-exec (:47–62). 13/13 pins GREEN | same ✓ (budget ≤2 met) |
| 2. Request part / escalate | 3 taps (detail → sheet button → submit) | 3 taps: `Support > Request part / Escalate issue` rows (:1021–1059) → `showAppBottomSheet(PartsRequest/EscalationSheet)` same content + own submit — no added steps. empty/locked/delayed frames show same rows | same ✓ |
| 3. View activity / timeline | 1 tap + scroll (rows carry status + start/end times) | 1 tap + ≤ same scroll: inline `visible take(3)` (:451) + `View all` sheet only when >3 (:450–513); sheet-360 proves 4-assigned full list with per-row Start; tablet-768 shows all 3 inline without sheet affordance. Task rows are the timeline (migration S7 — no separate feed exists) | same ✓ |
| Complete repair (not budgeted, must not regress) | 3 taps (detail → dock → confirm) | 3 taps: sticky/rail `Complete repair` → `showAppDialog(Complete repair on 'JC-101'?)` naming the ref (U10) → `notifier.completeJob` (:229–247). done/locked frames confirm terminal read-only (no CTA) | no regression ✓ |

**Tap result: PASS — no budget regresses; focus card stays above fold; sheets keep their own submit; activity stays one scroll region.**

---

## 4. Airbnb rubric 0–2 each, /16, pass ≥ 12/16 — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Open job → execute current task → handover; Support/activity subordinate, no competing hero |
| 2 | Headline-first hierarchy | 2/2 | Breadcrumb → vehicle title → ONE pill → hero identity + progress sentence → focus → checklist; IDs/refs mono meta LTR, never titles |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless `AppSurfaceCard(outlined:false)` + whitespace; second pill + ALL-CAPS eyebrows + bespoke borders removed vs before |
| 4 | Sheets for secondary actions | 2/2 | Parts/escalation + >3 tasks via `AppBottomSheet` with handle + pinned primary; dialogs only for destructive handover confirm |
| 5 | Sticky CTA | 2/2 | C16 sticky bar (summary + ONE handover CTA), hidden when empty/locked/all-done (U6); wide rail owns CTA instead — never both |
| 6 | Section structure | 2/2 | Sentence-case `AppSection` (`Next task`, `3 assigned`, `Support`), progressive disclosure latest-3, banner for blockers only |
| 7 | Plain friendly copy, no invented claims | 2/2 | Verbatim keys + 1 new `techDetailCompleteRepairOn(ref)` (ar REVIEW_NEEDED); honest `0 of 1 … 0%`, `Plate not recorded` fallback, no invented statuses/times |
| 8 | Single emphasized primary action | 1/2 | Focus/rows/sticky each obey one-primary, but states-matrix proof on this surface is incomplete — loading/error share one identical fallback frame instead of distinct shimmer/error atoms (−1 polish, NOT a cap; list owns async per S6) |
| **Merit total** | | **15/16** | Pass on merit (≥12) |
| **C16 hard-reject cap** | ANY violation caps 10/16 | **No cap on this screen** | Borderless light ✓; no orphans ✓; ONE filled/section ✓; one path per task (row triplets = brief-KEPT content) ✓; no permanent pills *on this screen* (hero second pill removed; persistent `Synced` = shell-owned STOP, not counted here — disclosed) ✓; badges offset ✓; no ALL CAPS / no label-badge duplication ✓; search header→sheet ✓; fold rule ✓; card hierarchy ✓; no carousels ✓ |
| **C17 U-cap** | ANY U-law fail caps 8/16 | **No cap** | Zero U fails in §2; gaps (a)(b) adjudicated non-gating with evidence (running path code+pins; entity-fallback architecture) |
| **Final** | | **15/16 — PASS** | |

---

## ROUND-1 DEFECT LIST (gating first, honestly)

**Gating defects: NONE.** No C16 hard-reject hit on this screen, no U-law fail, no tap-budget breach on any path.

**Non-gating observations (disclosed, filed — do NOT gate this verdict):**
1. **(b) Loading vs error share one identical fallback frame — merit −1, NON-GATING.** `loading_light_1.0_en_360x800.png` ≡ `error_light_1.0_en_360x800.png` (Vehicle / Pending / `Plate not recorded` / `No tasks` / Support). Brief states-matrix expects `AppShimmerSkeleton` + `AppErrorState` on detail; architecture is entity-driven (`liveJob` falls back to route-time entity, async states live on list screens — migration S6). U6 still holds (calm, no CTA to nothing; `0` honest). Fix (if wanted) is product decision: either add skeleton/error atoms to detail or amend brief matrix to record list-owns-async; presentation-only either way. Not a C17 breach.
2. **(a) No running-state (live stopwatch) frame — observation, NO deduction, NON-GATING.** Fixtures intentionally keep tasks pending/completed so the stopwatch never ticks (shell-fix determinism precedent; 0.06% drift note). Running path is code-present (`TechnicianStopwatch` focus + rows, `running → Complete + ghost Hold`, `held → Resume`) and characterization pins `Complete` instead of wall-clock. Suggest one frozen running still (fixed `startTime`, paused ticker) if orchestrator wants pixel proof — optional.
3. **Permanent `Synced` pill in `WorkspaceAppBar` — SHELL-owned STOP, not this screen's defect, NO CAP.** Visible in every after frame (and before). C16 hard-reject wording bans permanent pills; migration Review-pass explicitly KEEPs this as shared-chrome STOP (owning phase). This review does not count shell chrome against the detail screen.
4. **QC-Review still shows Support rows (Completed hides them) — preserved behavior, NON-GATING.** Code `_ContextColumn:1007` hides Support only for `completed`; `qcReview` (`isActionable=false`) keeps `Request part / Escalate issue` entry points (locked-360 proves). Status machine + read-only task actions/sticky CTA are correct; Support visibility is pre-existing logic, untouched per mandate. If product wants QC fully action-free, file a logic STOP — not a redesign fail.
5. **Process artifacts (not screen defects):** `references/` + `AIRBNB_PATTERNS.md` UNMET (precedent used, per brief); confirm-dialog pixels + open-keyboard pixels not in matrix (code + pins cover); tablet-768 renders single-column + sticky bar at medium — verbatim `adaptive.pick` parity (dossier + rail only at expanded), not a defect.

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `idle_light_1.0_en_360x800.png`: `Jobs > JC-101 / Toyota Camry / In Progress` → `JC-101 / Toyota Camry / ABC 1234 / Ahmed / 1 of 3 tasks completed 33%` → `Next task / Replace brake pads / Start next task` (above fold) → sticky `In Progress JC-101 + Complete repair`. Next step is unambiguous: start the named task, or complete the repair when done.
- **What would an Airbnb product designer reject here?** Nothing blocking. The honest costs: (1) loading/error share one fallback still instead of distinct skeleton/error atoms — invisible in normal use (list owns loading), but the matrix proof is incomplete; (2) no frozen running-stopwatch still — the ticking path is code+test proven, just not pixel-frozen for determinism. Both are disclosed above; the visible screen itself is calm, single-pill, single-CTA, and thumb-reachable.

(End of file — round 1, 2026-10-22)

---

# ROUND 2 — Second fresh reviewer (CONFIRMED PASS 15/16, zero gating)

**Role:** SECOND FRESH REVIEWER, never built this screen. READ-ONLY except this appendix. No code/tests/PNGs edited. No branch/commit/push. Never touched `71983229` (verified unrelated phase-1g commit, left alone).
**Branch:** `ui/detail-technician` (verified via `git branch --show-current`).
**Read first:** Brief `docs/ui-redesign/briefs/detail-staff-job-detail.md` (authoritative) + round-1 above (kept verbatim) + migration `technician-job-detail-test-migration.md` (13/13 GREEN before+after, tap re-measurement, S1–S7 STOPs).
**References:** `docs/ui-redesign/references/` does NOT exist (`Test-Path` False); `AIRBNB_PATTERNS.md` missing repo-wide (no match under `docs/ui-redesign`). Confirmed UNMET — nothing claimed as consulted.
**Images viewed (full resolution, Read tool):** AFTER 12/12 (`idle en/ar/320/1.3x/tablet`, `empty`, `locked` JC-105 QC, `delayed` JC-102, `done` JC-108, `loading`, `error`, `sheet` 4-assigned) + BEFORE 8/8 contrast + contact sheet `phase-tech-detail-light.png` BEFORE-vs-AFTER side-by-side.
**Hash check:** `loading_light_1.0_en_360x800.png` SHA256 `11370767DBD51341…CC2229` ≡ `error_light_1.0_en_360x800.png` SHA256 `11370767DBD51341…CC2229` — byte-identical confirmed.

## Round-2 independent U0–U14 walk (AFTER pixels)
- U0 one read: idle-360 breadcrumb → title → ONE pill → hero (JC-101/Camry/plate/customer/progress sentence) → Next task → sticky summary+CTA. PASS.
- U1 search top-right → sheet: magnifier top-right every 360 frame; tablet `Search CtrlK` from shared chrome; zero inline fields. PASS.
- U2 focus above fold 360x800: idle + delayed both show full `Start next task` CTA + sticky bar, 0 scroll; 1.3x full CTA; 320 title+CTA top visible (stress width, fold earlier by design). PASS.
- U3 taps 2/3/1+scroll: focus primary direct, Support rows → sheets with own submit, checklist ≤3 inline + View-all only when >3 (sheet proves 4-assigned). Matches migration re-measurement; no regression vs brief BEFORE. PASS.
- U4 sticky bar lower-half + keyboard-safe: `Complete repair` thumb-zone all idle/delayed/tablet/ar frames; migration cites `_HandoverBar: SafeArea + viewInsets.bottom`, ≥48dp, CTA-priority wrap (code-attribution, no keyboard-open pixel in matrix — disclosed limit, not a fail). PASS.
- U5 no truncation / LTR: names whole at 320/1.3x/ar/tablet; JC-*/plates/times LTR; honest `Plate not recorded` / `0 of 1 … 0%` fallbacks, no `-`. PASS.
- U6 calm empty, no CTA to nothing: empty (JC-106) icon+sentence, hero no bar, no sticky bar; done/locked notices + no bar; loading/error fallback calm with no bar. PASS.
- U7 one path: one focus primary per section, rows secondary/ghost (brief-KEPT glove content), `View all` only when >3, sticky vs rail viewport-gated never both (migration pins). PASS.
- U8 relevance: done (`edits are locked`, no rows buttons, no bar, Support hidden) + locked (`submitted for QC review`, no bar) read-only; delayed banner display-only with normal execution. QC keeps Support rows = preserved pre-existing behavior (`:1007` hides only `completed`), status machines verbatim — non-gating. PASS.
- U9 consistency: WorkspaceAppBar + PageHeader + SurfaceCard + ProgressBar + Section + ListGroup + Banner + EmptyState atoms throughout; tablet search affordance from shared chrome. PASS.
- U10 feedback + destructive confirm: rows carry status + start–end times; `showAppDialog(title: Complete repair on 'JC-101'?)` code+characterization pinned (dialog pixels not in matrix — disclosed, code-verified). PASS.
- U11 numbers: `1 of 3 … 33%`, `0 of 1 … 0%`, `2 of 2 … 100%`, tabular `08:30 – 08:50` times, no bare `-`. PASS.
- U12 one background: single page bg, borderless light cards + whitespace, hairline sticky-bar top border only; tablet same. PASS.
- U13 plain verbs: `Next task / Start next task / Request part / Escalate issue / Complete repair / No tasks / Repair tasks complete`, sentence-case statuses. PASS.
- U14 a11y: 1.3x no overflow with intact targets; 320 summary+CTA legible unclipped; Semantics/liveRegion/touchTarget code-cited; SR/contrast stills-limited, pins hold. PASS.
- **U fails: 0. C17 cap: none.**

## Round-2 C16 hard-reject (all must hold, else cap 10/16)
Borderless light ✓ (soft shadow vs before borders) · no orphans ✓ (Support full-width rows) · ONE filled/section ✓ (focus exactly one primary; Hold ghost; rows secondary/ghost; sticky/rail one each, never both) · one path ✓ (dock mirrors focus state) · no permanent pills *on this screen* ✓ (hero second pill removed; persistent `Synced` = brief-KEPT shell chrome in WorkspaceAppBar, explicitly kept per brief + migration STOP — not counted here) · badges clear ✓ · no ALL-CAPS / no label-badge duplication ✓ (sentence-case only) · search header→sheet ✓ · fold ✓ · hierarchy (title → pill → meta LTR mono) ✓ · no carousels ✓. **No C16 hit on this screen. No 10/16 cap.**

## Special attention (the two adjudicated gaps)
- **(b) Loading/error byte-identical fallback — CONFIRMED non-gating, merit −1 stands.** Hashes identical; both render Vehicle / Pending / `Plate not recorded` / `No tasks` / Support, no bar. Brief states-matrix expects distinct shimmer/error atoms, but U6 still holds (calm, honest `0`, no CTA to nothing) and no U-law mandates distinct async pixels on an entity-driven detail (async lives on list screens per migration S6). States-matrix proof gap = polish deduction under rubric criterion 8, not a C16/U-law gate. Overturning to gate would require inventing a U-law that does not exist in the brief.
- **(a) Missing running frame — CONFIRMED non-gating, no deduction.** No ticking-stopwatch pixel by design (deterministic pending/completed fixtures); running path (`Complete + ghost Hold`, `held → Resume`) + stopwatch atoms code-present and characterization-pinned. Suggesting a gate would punish determinism the brief never forbids. Optional frozen-running still remains a nice-to-have only.

## Rubric (only after (1)–(3)): agree 15/16
Criteria 1–7: 2/2 each (one task, headline hierarchy, borderless whitespace, sheets for secondary, sticky CTA hidden when empty/locked/done, sentence-case sections with progressive disclosure, verbatim keys + 1 honest new key). Criterion 8: 1/2 (single primary everywhere, −1 for incomplete states-matrix proof on this surface). **Merit 15/16 ≥ 12. No C16 cap. No C17 cap. Final 15/16 — PASS.**

## Tap walk: agree — no budget regresses (2 / 3 / 1+scroll; handover 3, no regression).

**ROUND-2 VERDICT: CONFIRMED — 15/16 PASS, zero gating defects.** Round-1 scoring, caps, and both gap adjudications upheld on independent evidence. Non-gating observations (shell `Synced`, QC Support visibility, confirm-dialog/keyboard pixels, single-column tablet per `adaptive.pick` parity, UNMET references) remain correctly filed as STOPs/notes, not gates.

(End of file — round 2, 2026-10-22)
