# Supervisor Review list — Fresh review ROUND 1 (PASS 15/16)

**Role:** FRESH REVIEWER (round 1), never built this screen. READ-ONLY except this file. No code/tests/PNGs edited. No branch/commit/push. Never touched `7198329`.
**Branch:** `ui/list-ops`.
**Read first:** Brief `docs/ui-redesign/briefs/supervisor-review-list.md` (authoritative, incl. sanctioned deviations: A — header subtitle static, no honest count key, zero new keys; B — NO list-scoped search icon at any size, bar bay-search is the single search path and covers QC-awaiting records; C — no `AppListGroup` wrapper + NO filter rail, nothing honest to facet); migration `docs/ui-redesign/evaluation/supervisor-review-list-test-migration.md` (behavior pins: 6/6 GREEN before and after; sheet-entry pin — row Start QC opens `showQcChecklistSheet` with `svQcTitle` + job ref, internals untouched; provider-owned quirk pinned — first load never writes `reviewError`/`isReviewLoading`, cold failure surfaces EMPTY, error/skeleton refresh-driven); REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 C17 (brief §§U0–U14 authoritative). Pass ≥ 12/16 with caps.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (both per brief §References, confirmed UNMET — precedent patterns from phase-5/phase-7 + vehicles-list + screens 1–2 used instead).
**Images viewed (AFTER via Read, full resolution + BEFORE for contrast):**
- AFTER `docs/ui-redesign/baseline/after-supervisor-review/`: `idle_light_1.0_en_360x800`, `idle_light_1.0_en_320x568`, `idle_light_1.3_en_360x800`.
- BEFORE contrast via contact sheet (structure only; frozen records, never regenerated).
- Contact sheet `docs/ui-redesign/baseline/phase-sv-review-light.png`: BEFORE (left) vs AFTER (right) side-by-side.
**Code read-only (attribution only):** `apps/staff_app/.../widgets/supervisor_review_tab.dart` (`AppErrorState:56`, `AppShimmerSkeleton:63`, `AppEmptyState:67` no-action, `AppStatusChip:147`, `AppProgressBar:179`, `AppPillButton.primary:181`, `AppDivider:199` — grep-confirmed; no remaining `PrimaryButton`/`StatusPill`/`EmptyState`/`AppSkeleton`/`AppInfoPanel`/`AppLinearProgress`/raw `Divider`).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle en 360 — `idle_light_1.0_en_360x800.png`
- **Header region:** verified-badge glyph + bold `Quality control`; muted `Verify completed repairs before delivery`; lone circular-arrow refresh glyph on its own row below.
- **Row 1 region:** bold `JC-207` left, pale-teal pill `● 4/4 done` right; muted `Layla · Yaris XYZ 5678` below with `OH` right-aligned; full red bar; full-width blue pill `Start QC` with checklist glyph; pale divider under.
- **Row 2 region:** bold `JC-208` left, pale-teal pill `● 3/5 done` right; muted `Ahmed · Camry ABC 1234` with `SA` right; partial green bar; full-width blue pill `Start QC`; pale divider under.

### AFTER 320px — `idle_light_1.0_en_320x568.png`
- Same header + refresh; both rows fully present: refs, pills, meta + initials, bars, full-width `Start QC` buttons; no truncation, no overflow.

### AFTER 1.3x — `idle_light_1.3_en_360x800.png`
- Same structure; subtitle wraps two lines; both rows intact (pills whole, meta one line, buttons full-width); no overflow markers.

### BEFORE vs AFTER (contact sheet `phase-sv-review-light.png`)
- BEFORE left: `4/4 done` / `3/5 done` pills with outline-info glyph; full-blue bar (row 1) + partial-blue bar (row 2); rectangular `Start QC` buttons.
- AFTER right: pills with solid teal dots; row-1 full bar red (was blue), row-2 partial bar green (was blue); `Start QC` buttons fully pill-shaped (stadium). All copy, order, seats identical.

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — one read: jobCardRef → progress pill → customer·vehicle → tech → Start QC | idle-360 rows: `JC-207` → `4/4 done` → `Layla · Yaris XYZ 5678 / OH` → bar → `Start QC`; ref is the recognized thing (mono, LTR, verbatim) | PASS |
| U1 — find fast: rows fully visible, scan-first; bar icon owns lookup (single search path — deviation B); NO inline added | idle frames: zero search fields/icons in-body; bar bay-search covers awaiting records via `buildSupervisorBays(awaiting: …)` per brief | PASS (sanctioned no-search-icon) |
| U2 — fit: heterogeneous rows (identity + pill + meter + full-width action) = divider rows, NOT a table; FOLD: header + FIRST row above fold, second peeking | idle-360: divider rows (`AppDivider :199`), no table; row 1 complete, row 2 complete-and-peeking in scroll frame (structure matches brief wireframe order) | PASS |
| U3 — no fake actions: every visual maps 1:1; NO filter rail (nothing honest to facet — inventing one would be a fake control) | Rows + Start QC + Retry map to same handlers; all rows are "awaiting QC" by construction; no rail anywhere (deviation C) | PASS |
| U4 — no invention: refs/customer/vehicle/tech verbatim; zero as `0`; counts from loaded lists | `JC-207`, `Yaris XYZ 5678`, `OH`, `4/4 done` via `svReviewProgress(done,total)` verbatim; no composed header count (deviation A, zero new keys) | PASS |
| U5 — reachable + legible: 48dp Start QC/Retry; ref LTR; meta ellipsizes 1 line @320/1.3x, action wraps full-width never clips | 320: both rows complete, no truncation; 1.3x: rows intact, buttons full-width; zero overflow evidence | PASS |
| U6 — states: skeleton mirrors rows; honest empty (1 icon + 1 sentence + NO action — nothing to create); error + Retry; pull kept | `AppShimmerSkeleton.listRows(rows: 5) :63`; `AppEmptyState` no-action (`:67`); `AppErrorState` + retry (`:56`, refresh-driven per pinned quirk); `RefreshIndicator` kept | PASS (code + pins; quirk preserved exactly) |
| U7 — feedback: Start QC opens EXISTING checklist sheet (same contract); toasts inside sheet untouched; one path per task | `AppPillButton.primary` Start QC (`:181`) → `showQcChecklistSheet` with same args (pin GREEN); sheet internals untouched | PASS |
| U8 — no dead ends: every row offers Start QC; empty honestly offers nothing-to-create; error offers Retry | Both idle rows carry `Start QC`; empty has no dead CTA by design (QC fills from completions) | PASS |
| U9 — consistency: `AppPageHeader`, divider rows, sheet — same atoms as staff precedent + screens 1–2 | Header/divider/sheet family matches sv-jobs/sv-queue | PASS |
| U10 — RTL: full mirror; ref/progress figures LTR (`Directionality` kept) | ar idle frame exists in matrix; code keeps LTR locks per brief (pins GREEN) | PASS (stills-limited; pins hold) |
| U11 — a11y: row `Semantics` kept; header `Semantics(header: true)`; live-region on error | Kept per migration (pins GREEN 6/6); 320/1.3x frames show no clipping | PASS (stills-limited for Semantics) |
| U12 — density: 1-col compact; wider canvas single-column register (grid N/A by design) | 360/320 single column; tablet frame in set keeps single column per brief | PASS |
| U13 — offline: bar banner owns offline; stale kept + notice; retries inline | Provider/refresh contracts untouched per migration | PASS (code pins) |
| U14 — no regression: tap budgets ceilings; pull, keys, checklist-sheet + toast contracts unchanged | See §3; sheet + toast + progress math byte-identical per migration | PASS |

**U-walk fails: 0.**

---

## 3. Top-task tap walk BEFORE→AFTER (budgets ≤ before)

BEFORE (brief §Top tasks, verified from code per migration): open 1 (tab) · start QC 2 from list (+scroll), then existing sheet · retry 1 / pull. No filter rail (N/A — nothing to facet).

| Task | Before | After (pixels + code) | Verdict |
|---|---|---|---|
| Open list | 1 tap (Review tab; 0 deep-linked) | ≤ 1 tap (tab seat unchanged; index 3 untouched) | same ✓ |
| Start QC checklist | 2 taps: row Start QC → same checklist sheet | ≤ 2: `AppPillButton.primary` Start QC on each row (`:181`) → same `showQcChecklistSheet` (same args); sheet internals untouched | same ✓ |
| Retry / refresh | 1 tap / pull (refresh-driven) | ≤ 1 / pull (refresh `IconButton` kept; `AppErrorState` retry → same `refreshReview`; pinned quirk preserved) | same ✓ |

**Tap result: PASS — frequent action (scan → Start QC) stays ≤ 2 taps on the existing sheet; no filter to regress (correctly absent).**

---

## 4. Airbnb rubric 0–2 each, /16, pass ≥ 12/16 — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find job awaiting QC → start checklist; scan-first rows, no competing hero |
| 2 | Headline-first hierarchy | 1/2 | Ref → pill → meta → meter → Start QC holds; −1: row 1 pairs `4/4 done` (terminal/ready state) with a full RED meter (BEFORE: blue). Same shared-atom tone question as sv-jobs — status stays pill-carried per brief, so not a U-fail, but meter and pill disagree on urgency |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless divider rows; no card wrappers added (deviation C) |
| 4 | Sheets for secondary actions | 2/2 | QC checklist stays the sheet (same entry contract); no new dialogs |
| 5 | Sticky CTA (none claimed) | 2/2 | Correctly absent; Start QC is in-flow per row (the pattern's frequent-action seat) |
| 6 | Section structure | 2/2 | Single register, no fake facets (rail correctly absent, U3); progress `done/total` per row |
| 7 | Plain friendly copy, no invented claims | 2/2 | Verbatim keys, zero new; `done/total` from existing math; no ALL CAPS added |
| 8 | Single emphasized primary action | 2/2 | One filled accent per row (Start QC only); no competing filled CTA |
| **Merit total** | | **15/16** | Pass on merit (≥ 12) |
| **C16 hard-reject cap** | borderless-light / one-filled-per-row / one-path-per-task / no-permanent-pills / no-ALL-CAPS / above-fold+peek / hierarchy / zero-as-0 | **No cap** | ALL PASS: borderless ✓; one filled per row ✓; single search path = bar ✓; pills data-only ✓; no ALL CAPS ✓; first row + peek ✓ |
| **C17 U-cap** | ANY U-law fail caps at 8/16 | **No cap** | Zero U fails (§2) |
| **Final** | | **15/16 — PASS** | |

---

## ROUND-1 DEFECT LIST (gating first, honestly)

**Gating defects: NONE.** No C16 hard-reject hit, no U-law fail, no tap-budget breach.

**Non-gating (scored or filed, do NOT gate this verdict):**
1. **`4/4 done` full meter renders RED — SCORED (−1, criterion 2).** `phase-sv-review-light.png` AFTER row 1 + `idle_light_1.0_en_360x800.png`; code `supervisor_review_tab.dart:179` (`AppProgressBar(value:)`, auto tone). BEFORE rendered the same state blue. If red means "needs QC attention," the tone is arguably functional (full = ready for review); if red means danger, it contradicts the done-pill. Either way the shared atom's tone mapping is ambiguous on terminal states while the pill carries status per brief — hence merit-only, no U-cap. For owning phase: confirm `AppProgressBar` tone semantics (same atom as sv-jobs observation).
2. **Refresh action on its own row with gap under subtitle** — kept seat per brief; unambiguous. Non-gating.
3. **Process artifacts (not screen defects):** `references/` + `AIRBNB_PATTERNS.md` UNMET per brief (precedent used); ar/tablet/sheet/empty/error/loading frames relied on via migration pins (6/6 GREEN) + matrix, pixel-verified here for idle/320/1.3x/contact-sheet only; sheet internals explicitly out of scope.

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `idle_light_1.0_en_360x800.png`: `Quality control / Verify completed repairs before delivery`, `JC-207 → 4/4 done → Layla · Yaris XYZ 5678`, one full-width `Start QC` per row. Next step is unambiguous: tap `Start QC` on the top row.
- **What would an Airbnb product designer reject here?** Nothing blocking. One honest nit: the `4/4 done` meter's red tone needs a system-level meaning (attention vs danger) — fix in the shared atom, not this screen.

(End of file — round 1, 2026-10-22)

---

# Supervisor Review list — Fresh review ROUND 2 (second reviewer, independent)

**Role:** FRESH REVIEWER (round 2), never built this screen, NOT round-1 author. READ-ONLY except this append. No code/tests/PNGs edited. No branch/commit/push. Never touched `7198329`. Round-1 above kept verbatim.
**Branch read:** `ui/list-ops` (no checkout/switch performed).
**Brief authoritative:** `docs/ui-redesign/briefs/supervisor-review-list.md` (deviations A/B/C as pinned in round-1 header). Pass ≥ 12/16. C16 cap 10/16, C17 U-cap 8/16.
**Migration read:** `supervisor-review-list-test-migration.md` (6/6 GREEN before+after; sheet-entry pin; provider-owned cold-failure→EMPTY quirk).
**Images independently viewed (AFTER, full resolution):** all 9 in `docs/ui-redesign/baseline/after-supervisor-review/` — `idle_light_1.0_en_360x800.png`, `idle_light_1.0_en_320x568.png`, `idle_light_1.3_en_360x800.png`, `idle_light_1.0_ar_360x800.png`, `idle_light_1.0_en_768x1024.png`, `empty_light_1.0_en_360x800.png`, `error_light_1.0_en_360x800.png`, `loading_light_1.0_en_360x800.png`, `sheet_light_1.0_en_360x800.png` — plus contact sheet `docs/ui-redesign/baseline/phase-sv-review-light.png` (BEFORE left vs AFTER right).
**Code read-only (attribution):** `supervisor_review_tab.dart` (`AppErrorState:56`, `AppShimmerSkeleton.listRows(rows: 5):63`, `AppEmptyState:67` no-action, `AppStatusChip:147` info `svReviewProgress`, `AppProgressBar:179` auto tone, `AppPillButton.primary:181` → `showQcChecklistSheet:186` same args, `AppDivider:199`; `RefreshIndicator:24` + header refresh `IconButton:44-51`; no `PrimaryButton`/`StatusPill`/`EmptyState`/`AppSkeleton`/`AppInfoPanel`/`AppLinearProgress`/raw `Divider`).

## Round-2 independent U0–U14 walk (all on pixels above + code)

- U0 PASS — 360 idle: `JC-207` → `4/4 done` → `Layla · Yaris XYZ 5678 / OH` → meter → `Start QC`. Same row 2. Ref mono LTR verbatim, hierarchy holds.
- U1 PASS (sanctioned no-search, deviation B) — zero in-body search fields/icons in every idle frame; single search path = bar bay-search per brief. No second path added.
- U2 PASS — heterogeneous rows as borderless divider rows (`AppDivider`), no table. 360: header + row 1 + row 2 complete (fold ceiling met — first row above fold + next visible/peeking). Tablet 768: single-column register, same order, no grid chunking (N/A by design).
- U3 PASS — no filter rail anywhere (correct: all rows "awaiting QC" by construction; rail would be fake). Start QC/Retry map 1:1 to handlers per code.
- U4 PASS — refs/customer/vehicle/tech verbatim (`JC-207`, `Yaris XYZ 5678`, `OH`, `4/4 done` via `svReviewProgress`); static subtitle, zero new keys (deviation A).
- U5 PASS — 320: both rows complete, no truncation/overflow; 1.3x: subtitle wraps 2 lines, pills whole, meta 1 line, buttons full-width, no overflow markers.
- U6 PASS — empty: exactly one icon + `Nothing awaiting sign-off` + `Completed repairs appear here for verification.` + NO action (honest, nothing to create). Error: one icon + `Something went wrong / Could not load QC work.` + single `Retry`. Loading: 5-row skeleton mirroring rows. `RefreshIndicator` kept per code. Pinned cold-failure→EMPTY quirk preserved (code branch order unchanged).
- U7 PASS — each row `Start QC` → same `showQcChecklistSheet` contract (code :181-193); sheet frame confirms `Quality control review / JC-207 / Sign-off checkpoints / Repair verification / Photo proof / Send back / Approve & pass`. One path per task.
- U8 PASS — every row offers `Start QC`; empty honestly offers no CTA; error offers `Retry`. No dead ends.
- U9 PASS — `AppPageHeader`, divider rows, sheet — same atoms as sv-jobs/sv-queue precedent + screens 1–2.
- U10 PASS — ar frame: full mirror (header right-aligned, pills left), `JC-207`/`JC-208` and `Layla · Yaris XYZ 5678` LTR-locked; `4/4 مكتملة` pill + `بدء الفحص` button correctly mirrored; meter direction mirrored. `Directionality(ltr)` kept per code :133.
- U11 PASS (stills-limited for Semantics/live-region; pins GREEN) — 320/1.3x show no clipping; header/row/error structure kept per migration.
- U12 PASS — 1-col compact at 360/320; tablet keeps single-column register (rows max-width, no table variant — N/A by design).
- U13 PASS (code pins) — provider/refresh contracts untouched; bar banner owns offline per brief.
- U14 PASS — tap budgets hold (see below); pull/keys/sheet+toast/progress math unchanged per migration.

**U-walk fails: 0. No C17 cap.**

## Round-2 tap walk (BEFORE budgets from brief; AFTER on pixels + code)

| Task | Before | After (verified) | Verdict |
|---|---|---|---|
| Open list | 1 tap (tab idx 3; 0 deep-linked) | ≤ 1 tap (tab seat unchanged) | same ✓ |
| Start QC checklist | 2 taps: row Start QC → same sheet | ≤ 2: per-row full-width `AppPillButton.primary Start QC` (:181) → same `showQcChecklistSheet` same args (:186-193); sheet frame confirms entry | same ✓ |
| Retry / refresh | 1 tap / pull | ≤ 1 / pull (header refresh `IconButton` :44-51 kept; `AppErrorState` Retry → same `refreshReview` :60) | same ✓ |

**Tap result: PASS. No regression. No filter to regress (correctly absent).**

## Round-2 C16 hard-reject checklist (ANY hit caps 10/16)

- Borderless light rows ✓ (dividers only, no card wrappers — all idle frames).
- One filled accent per row ✓ (Start QC only; pills/meters unfixed-data).
- One path per task ✓ (single search path = bar; no list search icon).
- No permanent pills ✓ (pills data-only `4/4 done` / `3/5 done`).
- No ALL CAPS ✓ (`Quality control`, `Start QC`, `Retry`).
- First row above fold + next peeking/visible ✓ (360 + 320 + tablet).
- Card hierarchy title → pill → meta ✓.
- Taps never regress ✓. Zero-as-`0` ✓ (no invented count; math `.clamp` per code :120).

**C16 caps: NONE.**

## Round-2 rubric (AFTER only, independent)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find awaiting-QC → Start QC; scan-first, no competing hero |
| 2 | Headline-first hierarchy | 1/2 | Ref → pill → meta → meter → Start QC holds; −1 confirmed: `4/4 done` (terminal/ready) pairs with full RED meter (BEFORE: blue per contact sheet; row-2 partial is green). Pill carries status per brief so merit-only; shared-atom tone question, same as sv-jobs |
| 3 | Whitespace, no boxes | 2/2 | Borderless divider rows (deviation C) |
| 4 | Sheets for secondary | 2/2 | QC checklist stays the sheet, same entry; no new dialogs |
| 5 | Sticky CTA (none) | 2/2 | Correctly absent; Start QC in-flow per row |
| 6 | Section structure | 2/2 | Single register; rail correctly absent (U3) |
| 7 | Plain copy, no invention | 2/2 | Verbatim keys, zero new, no ALL CAPS |
| 8 | Single emphasized action | 2/2 | One filled accent per row (Start QC); error single Retry |
| Merit | | 15/16 | ≥ 12 pass on merit |
| C16 cap | | No cap | all pass above |
| C17 cap | | No cap | 0 U fails |
| **Final** | | **15/16 — PASS** | |

## Round-2 verdict

- **Agree with round-1: CONFIRMED.** Same final 15/16 PASS, same single −1 (criterion 2, `4/4` RED tone, merit-only, shared-atom question — fix in `AppProgressBar`, not this screen). Independently verified on all 9 AFTER PNGs + contact sheet (round-1 pixel-verified only idle/320/1.3x/contact; this round adds ar/tablet/empty/error/loading/sheet confirmation).
- **Gating defects found: ZERO.** No C16 hit, no U-law fail, no tap-budget breach.
- **Non-gating:** (1) scored −1 above; (2) refresh glyph on own row under subtitle — kept seat per brief, unambiguous; (3) `references/` + `AIRBNB_PATTERNS.md` UNMET per brief (precedent used) — process artifact, not a screen defect.

**Answers:** (1) 3-second test — Yes: `Quality control / Verify completed repairs before delivery`, `JC-207 → 4/4 done → Layla · Yaris`, one full-width `Start QC` per row. (2) Airbnb-designer reject — Nothing blocking; one nit: give the shared meter a system-level tone meaning (attention vs danger) for terminal states.

(End of file — round 2, 2026-10-22, second fresh reviewer)
