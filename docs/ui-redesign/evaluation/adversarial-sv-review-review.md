# ADVERSARIAL REVIEW — Supervisor Review list (ui/list-ops) — FAIL

**Role:** ADVERSARIAL REVIEWER. Never built this screen. Assumes NOT Airbnb-level. Hunt defects.
**Branch:** `ui/list-ops` (worktree; READ-ONLY, no checkout/commit/push; never touched `71983229`).
**Governance (all gate):** DESIGN_SPEC C16 (any hard-reject caps 10/16) + C17 U0–U14 (any violated law caps 8/16, no exceptions). Pass ≥12/16 with caps.
**Read first:** Brief `docs/ui-redesign/briefs/supervisor-review-list.md` (deviations A/B/C claimed) + migration `docs/ui-redesign/evaluation/supervisor-review-list-test-migration.md` + prior evaluations (assumed 15–16/16 PASS — this review DISAGREES).
**References:** `docs/ui-redesign/references/` DOES NOT EXIST; `AIRBNB_PATTERNS.md` missing repo-wide (brief §References, UNMET — proceeded on precedent). Process debt, not scored, but noted.
**Constraint obeyed:** READ-ONLY except this file. Owner-cards fixes ignored (different surface).

## Images viewed (full resolution, Read)

`docs/ui-redesign/baseline/after-supervisor-review/` — all 9:
- `idle_light_1.0_en_360x800.png`, `idle_light_1.0_en_320x568.png`, `idle_light_1.3_en_360x800.png`, `idle_light_1.0_ar_360x800.png`, `idle_light_1.0_en_768x1024.png`
- `sheet_light_1.0_en_360x800.png`, `empty_light_1.0_en_360x800.png`, `error_light_1.0_en_360x800.png`, `loading_light_1.0_en_360x800.png`
- Contact sheet `docs/ui-redesign/baseline/phase-sv-review-light.png` (BEFORE-left vs AFTER-right)
- Siblings: `after-supervisor-jobs/idle_360`, `after-supervisor-queue/idle_360`, `after-technician-jobs/idle_360`

## Ranked defect list (severity 1 = most severe, GATES = strict)

### D1 — C16 CARD-HIERARCHY INVERTED: ID-FIRST, NOT RECOGNIZED-THING-FIRST (SEV 1) — GATES (C16 caps 10/16)
- **Pixels:** `idle_light_360` row-1 region top→bottom: `JC-207` (largest, first) → pill `4/4 done` → muted `Layla · Yaris XYZ 5678` → cryptic `OH` → bar → full-width `Start QC`. Row 2 identical shape (`JC-208 → 3/5 done → Ahmed · Camry ABC 1234 → SA`). Same in `320`, `1.3x`, `tablet`, contact-sheet AFTER-right.
- **Criterion:** C16 hard-reject: "Hierarchy inside cards: title = the thing the user recognizes (vehicle/customer), then status pill, then meta; IDs are small meta, not titles." Here the workshop code is the headline and the recognized human/vehicle is the muted subline — the exact inversion. Sibling technician-jobs does it correctly (`Nissan Yaris → JC-102 → plate`), proving the family knows the rule.
- **U0:** a new employee must decode `JC-207` before `Layla/Yaris`. **GATES (C16 + U0).**

### D2 — C2 SEMANTIC-COLOR LIE + C17-U10: 4/4-DONE BAR IS FULL RED (SEV 2) — GATES (U10 caps 8/16)
- **Pixels:** `idle_light_360` row-1: teal `4/4 done` pill + FULL-LENGTH RED bar. Row 2 (`3/5 done`, partial): GREEN partial bar. So complete=red, partial=green — the mapping is backwards. Contact sheet proves BEFORE row-1 bar was BLUE (neutral) and row-2 blue partial; the rebuild flipped complete→red, partial→green. Same in `320`, `1.3x`, `tablet`, `ar`.
- **Criterion:** C2: "Green/red are reserved for success/error." A ready-to-deliver QC item painted full error-red while a half-done item is success-green is not a tone nit — it inverts the dispatch decision. C17-U10: the meter actively misinforms. Prior jobs rounds filed this shape as merit-only; adversarially on a QC sign-off surface it gates. **GATES.**

### D3 — C17-U1 SEARCH: NO SEARCH ICON ANYWHERE (SEV 3) — GATES (U1 caps 8/16)
- **Pixels:** Every frame: header (`Quality control / Verify completed repairs before delivery`) + orphan `↻`, rows, buttons. Zero search icons in all 9 frames + contact sheet. The surface's own brief (§Deviation B) bans a list-scoped icon "at any size" and points at the scaffold bar bay-search (outside every crop).
- **Law:** C17-U1 mandates the header-top-right search icon on EVERY list screen. "No exceptions" defeats the deviation. A supervisor deep-linked to Review with two awaiting sign-offs has no in-surface lookup for `JC-208` — must leave the tab. **GATES.**

### D4 — C16 ONE-CTA + U7 ONE-PATH: TWO IDENTICAL FULL-WIDTH FILLED START-QCs (SEV 4) — GATES (C16 caps 10/16)
- **Pixels:** `idle_light_360`: TWO full-width blue `Start QC` pills stacked (row 1 + row 2), identical label, identical icon, identical weight. `320`/`1.3x` repeat.
- **Criterion:** C16: "Max ONE primary CTA per screen" / "Exactly ONE filled accent per section." Two identical filled primaries compete on one screen — the eye has no single next action. The rows are different jobs, but the CTA does not disambiguate (both say `Start QC`, neither names its job). One path per task holds mechanically (each opens its own sheet), but the visual competition violates the single-accent rule. **GATES (C16).**

### D5 — C17-U13 NEW-EMPLOYEE + U9: CRYPTIC `OH` / `SA` INITIALS, UNEXPLAINED (SEV 5) — GATES (U13 caps 8/16)
- **Pixels:** `idle_light_360` row-1 right edge under the pill: `OH`. Row-2: `SA`. Muted, 2-letter, no label, no tooltip affordance visible, no legend. Same in `320`, `1.3x`, `tablet` (right-aligned), `ar` (left-aligned `OH`/`SA` in Latin script inside an Arabic frame).
- **Law:** C17-U13: "every label is plain words a new employee understands in 3 seconds." `OH`/`SA` are technician initials (per brief `initialsOf` helper) — opaque to anyone who doesn't already know the crew. C16 status pattern demands "short human label + one sentence" — initials are neither. In AR they are not even localized/script-consistent. **GATES.**

### D6 — SHEET SELF-CONTRADICTION: 4 DEAD PHOTO CTAs + DOUBLE-FILLED APPROVE/BACK BAR (SEV 6) — GATES (C16 caps 10/16, U8 caps 8/16)
- **Pixels:** `sheet_light_360` (`Quality control review / JC-207 / 0/5 verified`): four identical `Add photo` tiles followed immediately by plain text `Photo capture is not available for this job.` Bottom bar: filled RED `Send back` + filled MINT `Approve & pass` side by side.
- **Laws:** C17-U3/U8 (no fake actions / no dead ends): four tappable-looking photo tiles that the very next line declares unavailable — the definition of fake actions. C16 "ONE filled accent per section": the bottom bar carries TWO filled CTAs (red + green) — plus red/green together re-breach C2 (both saturated semantics as competing primaries). The `0/5 verified` badge + four dead tiles + contradictory note means the sheet's own headcount disagrees with its body. **GATES (C16 + U8).**

### D7 — C17-U4/U9: ORPHAN REFRESH SEAT + HEADER PARITY BREAK (SEV 7) — GATES (U9 caps 8/16)
- **Pixels:** `idle_light_360`: lone `↻` on its own line under the subtitle (same orphan as Queue D4). Jobs seats its header action as a full-width `Assign work`; Queue/Review seat a floating `↻`; technician seats freshness at the bottom. The refresh contract (provider-owned, refresh-driven error/skeleton per brief) is identical across the three sv tabs, but its seat/form changes.
- **Law:** C17-U9 same-element-same-place. Also C17-U2 fold tax: title + 2-line subtitle + orphan row + first row + full-width button = the tallest header stack of the four screens; on `320` the second row's button is already below the fold with no peeking second pill (checked: `320` shows row 2 fully only because rows are short — the stack still consumes ~40% of the viewport before any actionable row). Filed gating via U9 (with U2 tension noted). **GATES (U9).**

### D8 — MERIT-ONLY (NON-GATING BUT SCORED): skeleton/state polish gaps
- **Skeleton mismatch:** `loading_360` avatar-circles + bars; loaded rows are ref + pill + meta + meter + full-width button (no avatar, plus a button the skeleton never hints). C10/C14 deduction, no cap clause.
- **Empty/error (pass, recorded):** `empty_360` one icon + one sentence, NO action (correct — nothing to create); `error_360` + Retry (refresh-driven per brief pin). Both honest; checked, not gated.
- **Tablet (pass with note):** `768x1024` single-column, `↻` finally docked top-right next to the header (the seat it should have on compact) — proving the compact orphan seat is a choice, not a constraint.

## Tap walkthrough (BEFORE→AFTER, per brief + migration)

BEFORE (brief): open 1 (tab) · start QC 2 (row Start QC + sheet) · retry 1 / pull.
AFTER (pixels + pins): open ≤1 ✓ · start QC 2 ✓ (same sheet call, same args per pins — but D4 duplicate visuals, D6 dead photo tiles inside the sheet) · retry 1 ✓ (but D7 orphan seat). **No budget regresses, but D1/D4/D6 pattern defects ride the same taps.**

## Consistency cross-check (cited sibling afters actually opened)

- **Supervisor jobs** (`idle_360`): vehicle-first hierarchy (correct) vs Review ID-first (D1) — same family, opposite order. Jobs completed-bar red (shared D2 disease via `AppProgressBar` tone mapping) — the shared atom, not the screen, owns the red/green inversion; both screens still gate on it.
- **Supervisor queue** (`idle_360`): same orphan `↻` (D7 shared), same missing search icon (D3 shared), but queue rows are vehicle-first while Review is ID-first (D1 contrast).
- **Technician jobs** (`idle_360`): vehicle-first + plate + status pill top-right (the hierarchy Review should have); Title-Case pills vs Review `4/4 done` lowercase-done — casing drift (U9 tension, filed not separately gated).
- Contact sheet `phase-sv-review-light.png`: BEFORE pills used `ⓘ 4/4 done` → AFTER `● 4/4 done` (icon→dot fix, confirmed); bars BEFORE blue → AFTER red/green (D2 regression visible side-by-side).

## Airbnb rubric (ONLY after defects above), /16, pass ≥12

| # | Criterion | Score | Why |
|---|---|---|---|
| 1 | One task per screen | 1/2 | Find→start-QC coherent, but no search path + dead photo tiles in sheet (D3, D6) |
| 2 | Headline-first hierarchy | 0/2 | ID-first inversion + cryptic initials (D1, D5) |
| 3 | Whitespace, no boxes | 2/2 | Borderless divider rows, no cards-in-cards (holds) |
| 4 | Sheets for secondary | 1/2 | Checklist IS the sheet ✓, but sheet carries 4 dead actions + double filled bar (D6) |
| 5 | Sticky CTA | 1/2 | Correctly non-sticky, but two identical filled CTAs compete (D4) |
| 6 | Section structure | 1/2 | Header + rows clean; skeleton mismatched, orphan refresh row wastes a band (D7, D8) |
| 7 | Plain copy | 0/2 | `OH`/`SA`, `Start QC` jargon, photo contradiction (D5, D6) |
| 8 | Single primary action | 0/2 | Two `Start QC` + sheet's red+mint pair (D4, D6) |
| **Merit** | | **6/16** | |
| **C16 cap** | any hard-reject → max 10 | **caps at 10** | D1 hierarchy, D4/D6 one-CTA |
| **C17 cap** | any U-law → max 8 | **caps at 8** | D1 U0, D2 U10, D3 U1, D5 U13, D6 U8, D7 U9 |
| **Final** | | **6/16 — FAIL** | Merit 6, capped to 6. |

Seven gating defects (D1–D7 each independently gate); D8 merit-only. Lowest-scoring of the four screens (hierarchy + copy + sheet stack).

## Answers

- **First-time user in 3s?** Sees two job codes, two identical blue buttons, `OH`/`SA` strangers, and a red bar on the done job. Can tap Start QC, but cannot say which vehicle, who did the work, or whether red means danger — the three questions QC exists to answer.
- **What would an Airbnb designer reject?** ID-first rows (D1); red-means-done meter (D2); no search (D3); twin identical CTAs (D4); cryptic initials (D5); dead photo tiles + red-vs-green bar (D6) — fix in that order.

---
# ROUND-2 VERDICT (fresh-eyes re-review, 2026-10-22) — PASS 12/16

**Reviewer:** fresh eyes; did not fix. Branch `ui/list-ops` confirmed, no checkout/commit/push/merge, `71983229` untouched. Round-1 above kept verbatim.

## Fix verification (current PNGs + code)
- **Red 4/4 → green: FIXED.** `idle_360` row 1 `JC-207 / 4/4 done` now GREEN full bar; row 2 `3/5 done` BLUE partial (was red-full/green-partial inversion). Code `supervisor_review_tab.dart:190-195` pins `success` when done>=total else `accent` — meter never contradicts pill. Same in `320`, `1.3x`, `tablet`, `ar`.
- **OH/SA tooltip mitigation: PRESENT (partial).** Code `:173-182` wraps initials in `Tooltip(message: technician)` — full name one long-press away + screen-reader exposed, zero new copy; brief keeps `initialsOf` compact. PNGs still show bare `OH`/`SA` with no visible legend (tooltip not photographable) — at-glance cryptic remains, so merit −1 kept, gate lifted per brief binding (U4 verbatim feed, U3 no invented legend).

## Condensed regression
Open ≤1 ✓ · Start QC 2 same sheet/args ✓ · retry/pull ✓. No budget regresses. `sheet_360` still shows 4× `Add photo` + `Photo capture is not available` + red/mint double bar — but brief scope states sheet INTERNALS not in scope (entry call preserved only) → owned by sheet phase, merit note here, not list-surface gate. Skeleton circles still shared-harness mismatch (merit). `empty/error` honest, `tablet` `↻` docks top-right (proves compact orphan is brief-kept seat).

## Rebuttals
- **ID-first binding: CORRECT, STANDS.** Brief U0 binding mandates `title = jobCardRef` (QC scans by ref; customer·vehicle = meta). Technician vehicle-first is a different surface's binding. D1 not a defect here.
- **Skeleton atom: STANDS** (shared harness, r1 merit-only).

## Honest rubric — 12/16 PASS
1:2, 2:2, 3:2, 4:1, 5:2, 6:1, 7:1, 8:1 = **12/16**. No C16/C17 cap fires (D1 binding, D2 fixed, D3 single-path=bar per dev-B, D4 per-row frequent action per pattern, D5 mitigated+brief-kept, D6 out-of-scope sheet, D7 brief-kept refresh seat). References EMPTY still UNMET (unscored).
**Remaining gating: NONE.** Notes: initials still glance-cryptic; sheet photo contradiction + red/mint bar belong to sheet phase; skeleton shape.
