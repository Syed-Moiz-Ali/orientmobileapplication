# ADVERSARIAL REVIEW — Technician Jobs list (ui/list-ops) — FAIL

**Role:** ADVERSARIAL REVIEWER. Never built this screen. Assumes NOT Airbnb-level. Hunt defects.
**Branch:** `ui/list-ops` (worktree; READ-ONLY, no checkout/commit/push; never touched `71983229`).
**Governance (all gate):** DESIGN_SPEC C16 (any hard-reject caps 10/16) + C17 U0–U14 (any violated law caps 8/16, no exceptions). Pass ≥12/16 with caps.
**Read first:** Brief `docs/ui-redesign/briefs/technician-jobs-list.md` (deviations A/B/C/D claimed, incl. STOP boundary on `TechnicianJobSummary`) + migration `docs/ui-redesign/evaluation/technician-jobs-list-test-migration.md` + prior evaluations (assumed 15–16/16 PASS — this review DISAGREES).
**References:** `docs/ui-redesign/references/` DOES NOT EXIST; `AIRBNB_PATTERNS.md` missing repo-wide (brief §References, UNMET — proceeded on precedent). Process debt, not scored, but noted.
**Constraint obeyed:** READ-ONLY except this file. Owner-cards fixes ignored (different surface).

## Images viewed (full resolution, Read)

`docs/ui-redesign/baseline/after-technician-jobs/` — all 9:
- `idle_light_1.0_en_360x800.png`, `idle_light_1.0_en_320x568.png`, `idle_light_1.3_en_360x800.png`, `idle_light_1.0_ar_360x800.png`, `idle_light_1.0_en_768x1024.png`
- `filter_light_1.0_en_360x800.png`, `empty_light_1.0_en_360x800.png`, `error_light_1.0_en_360x800.png`, `loading_light_1.0_en_360x800.png`
- Contact sheet `docs/ui-redesign/baseline/phase-tech-jobs-light.png` (BEFORE-left vs AFTER-right — near-identical)
- Siblings: `after-supervisor-jobs/idle_360`, `after-supervisor-queue/idle_360`, `after-supervisor-review/idle_360`

## Ranked defect list (severity 1 = most severe, GATES = strict)

### D1 — C16 LIST PATTERN + C17-U1: NO SEARCH PILL/BAR/ICON IN THE SURFACE (SEV 1) — GATES (C16 caps 10/16, U1 caps 8/16)
- **Pixels:** `idle_light_360` full-crop top→bottom: filter rail (`All 3 / Pending 1 / In Progress 1 / Dela…`) directly at the top edge, then rows, then `Updated 09:41`. NO headline, NO search pill, NO search bar, NO search icon in any of the 9 frames. `filter_360`, `empty_360`, `error_360`, `loading_360` likewise show rail-or-nothing up top.
- **Criterion:** C16: "List screen: AppSearchBar → filter pills → result count/sort → rows" and "Search-first screens (lists, jobs…): a rounded pill search bar at the top, filter chips under it." This list starts at step 2. C17-U1 mandates the header-top-right search icon on every list screen. Brief deviation B (shell-icon-only, "blessed" single-search) points at chrome outside every crop — within the captured surface the search path is undiscoverable, and C17 allows no exceptions. **GATES.**

### D2 — C16 STRUCTURE + C17-U0: NO HEADLINE AT ALL (SEV 2) — GATES (C16 caps 10/16, U0 caps 8/16)
- **Pixels:** `idle_light_360`: the first text element is the `All 3` chip. No screen title, no subtitle, no count header in any frame (`idle`, `320`, `1.3x`, `ar`, `tablet`, `filter`, `empty`, `error`, `loading`). The crops may exclude the shell `_TechChrome` title, but the surface as captured never answers "what is this."
- **Criterion:** C16: "Every screen starts with a big bold headline, left-aligned, then short subtitle, then content." Deviation A ("no in-body header — the shell owns the title") duplicates the title dependency instead of satisfying it: deep-link the tab content without chrome and it is anonymous. C17-U0/C9: no primary focus statement in 5 seconds. All three sv siblings carry in-body headlines; this is the outlier. **GATES.**

### D3 — C17-U12 ONE BACKGROUND: SELECTED ROW IS A FULL-BLEED TINTED BAND (SEV 3) — GATES (U12 caps 8/16)
- **Pixels:** `idle_light_360` row-2 region: `Toyota Camry / JC-101 / ABC 1234 / Starts 08:… / In Progress` sits on a light-BLUE full-bleed rectangle spanning edge to edge, while rows 1 and 3 sit on page grey. Same band in `320`, `1.3x`, `ar`, `tablet`, `filter_360`, contact-sheet both sides (BEFORE and AFTER identical).
- **Law:** C17-U12: "ONE page background colour; no stray bands or differently coloured strips behind rows." A full-bleed tinted strip behind exactly one row is the literal forbidden pattern (selected-state or not — nothing in the frames labels it selected, and no legend explains the blue). C16 depth "comes from spacing… NOT from heavy backgrounds" agrees. **GATES.**

### D4 — C17-U5 TRUNCATION OF PRIMARY DATA: TIMES, PLATES, RAIL ALL CUT (SEV 4) — GATES (U5 caps 8/16)
- **Pixels:** `idle_light_360`: `Starts 10:…` / `Starts 08:…` / `Starts 11:…` (start times — the technician's most actionable datum — cut to `:` + ellipsis); plates `XYZ 5678` full here but `idle_320` shows `XYZ 56… / ABC 12… / DEF 90…` and `1.3x` shows `XYZ 56… / ABC 1… / DEF 9…`; rail 4th chip `Dela…` severed mid-word in `idle_360`, `320`, `1.3x`, `filter_360`.
- **Law:** C17-U5: "never a label cut mid-word… truncation only on secondary text." Start time is primary task content, not secondary; `Dela…` is a mid-word filter-label cut with no icon/peek. The `filter_360` selected state further clips `In Progress…` against `Clear`. Three independent U5 breaches on one screen. **GATES.**

### D5 — C17-U9/U11: RAIL GRAMMAR + PILL CASING DIVERGE FROM THE FAMILY (SEV 5) — GATES (U9 caps 8/16)
- **Pixels:** Rail here: `All 3` (count INSIDE the All pill) + `Pending 1 / In Progress 1 / …`. Supervisor jobs rail: `All` (no count). Supervisor queue rail: `All` (no count) + section badges. Pills here Title Case (`Delayed`, `In Progress`, `Pending`) vs owner-cards sentence case (just fixed) vs sv-review lowercase-done (`4/4 done`). `All 3` also duplicates the freshness-adjacent reality: three rows listed, "3" in the pill, nothing else to cross-check against (no header count — see D2).
- **Law:** C17-U9 same-element-same-place; C17-U11 stats-with-labels-fully-visible-only-if-helpful. The family cannot agree where the total lives (in-`All` vs subtitle vs strip vs nowhere). **GATES (U9).**

### D6 — C17-U6 CALM + U4: EMPTY/ERROR FRAMES DROP THE RAIL (STATE AMNESIA) (SEV 6) — GATES (U6 caps 8/16)
- **Pixels:** `empty_360` (`No assigned jobs / There are no jobs assigned to you right now. / [Refresh] / Updated 09:41`): NO filter rail. `error_360` (`Something went wrong / We couldn't load your jobs / [Retry]`): NO filter rail. `loading_360`: skeleton rows + NO rail. But `idle_360` and `filter_360` HAVE the rail.
- **Law:** The filter selection is part of the screen's identity (brief: rail-only toolbar). Empty/error/loading frames that omit it force the technician to re-derive context after recovery (was I filtered? which chip?). C17-U6 calm-states + U8 no-dead-ends: the empty frame offers `Refresh` (correct) but no path back to a filter context it hid. Jobs and Queue keep their rails visible in empty/error/loading; this surface alone strips them. U9 inconsistency with a state-memory cost. **GATES (U6/U9).**

### D7 — C17-U13/U10: `0 of 1 tasks completed` + TIME WITHOUT DAY-PART (SEV 7) — GATES (U13 caps 8/16)
- **Pixels:** Every row, all frames: `≈ 0 of 1 tasks completed / 1 of 3 tasks completed / 0 of 2 tasks completed` in small muted text + `Starts 08:30` (tablet, the only frame showing full times) with no AM/PM, no "today/tomorrow," no timezone. `Updated 09:41` footer likewise bare.
- **Law:** C17-U13 plain-words: `0 of 1 tasks completed` is system-speak (a task counter leaking internal work-item math onto a scan list whose only job is "which dossier next"). C11 numbers rule wants relative/plain time; a bare `Starts 11:15` with truncated siblings (D4) leaves a technician guessing morning/afternoon convention. Filed gating via U13 (with U10 feedback tension: the row tells progress-math instead of readiness). **GATES.**

### D8 — MERIT-ONLY (NON-GATING BUT SCORED): chevron/skeleton/freshness polish
- **Chevron affordance (pass, recorded):** `>` at every row end correctly implies dossier navigation; `ar_360` correctly mirrors to `<`. One of the few fully-correct details — kept out of gating deliberately.
- **Skeleton mismatch (deduction):** `loading_360` avatar-circles + bars; loaded rows are rail-identity + pills + chevron (no avatar, no button). C10/C14 deduction, no cap clause. Same disease as the sv tabs — shared-harness fix.
- **Contact-sheet stagnation:** `phase-tech-jobs-light.png` BEFORE vs AFTER are pixel-near-identical (rail, rows, band, truncation all carried). The rebuild changed atoms under identical pixels — honest atom-swap, zero visual progress; filed as review information, not a screen defect.

## Tap walkthrough (BEFORE→AFTER, per brief + migration)

BEFORE (brief): open 1 (tab) · find (header icon → sheet → type → result tap, or chip 1) · open dossier 1 · clear 1 · retry 1 / pull.
AFTER (pixels + pins): open ≤1 ✓ · find identical seats ✓ (but D1: no in-surface search visible in any crop) · open dossier 1 ✓ (chevron rows) · clear 1 ✓ · retry 1 / pull ✓. **No budget regresses, but D1/D2 discoverability + D4 truncation defects ride the same taps.**

## Consistency cross-check (cited sibling afters actually opened)

- **Supervisor jobs** (`idle_360`): in-body headline + inline search + rail `All` count-less + red complete-bar (shared bar-tone disease) vs tech no-headline + no-search + rail `All 3` + no bars. Opposite seats on headline/search/counts (D1/D2/D5).
- **Supervisor queue** (`idle_360`): rail `All` count-less + `Insura…` cut vs tech `All 3` + `Dela…` cut (same U5 disease, D4); queue section badges vs tech nothing (D5 counting-system drift).
- **Supervisor review** (`idle_360`): ID-first rows vs tech vehicle-first (tech correct, D-hierarchy contrast); review twin filled CTAs vs tech zero filled CTAs on rows (tech correctly button-free per deviation C — its best decision).
- Contact sheet `phase-tech-jobs-light.png`: BEFORE≈AFTER — the only one of the four sheets with no visible change, confirming D8 stagnation while siblings at least moved atoms.

## Airbnb rubric (ONLY after defects above), /16, pass ≥12

| # | Criterion | Score | Why |
|---|---|---|---|
| 1 | One task per screen | 1/2 | Find→open coherent, but no headline + no in-surface search (D1, D2) |
| 2 | Headline-first hierarchy | 1/2 | Row hierarchy vehicle→ID→pills is the family's best (holds); screen itself headline-less (D2) |
| 3 | Whitespace, no boxes | 1/2 | Borderless rows hold, but the full-bleed blue band breaks one-background (D3) |
| 4 | Sheets for secondary | 2/2 | Search sheet (shell) + no invented sheets; filters correctly inline rail (holds) |
| 5 | Sticky CTA | 2/2 | Correctly absent; rows are navigation, dossier owns actions (holds — best D-call) |
| 6 | Section structure | 0/2 | Rail stripped in empty/error/loading; counts live in unexplained seats (D5, D6) |
| 7 | Plain copy | 1/2 | Task-math + bare times + mid-word cuts (D4, D7) |
| 8 | Single primary action | 2/2 | Zero filled CTAs on rows; Refresh/Retry single per state (holds) |
| **Merit** | | **10/16** | Highest merit of the four, still below pass |
| **C16 cap** | any hard-reject → max 10 | **caps at 10** | D1 search pattern, D2 headline structure, D3 (via C16 depth/background) |
| **C17 cap** | any U-law → max 8 | **caps at 8** | D1 U1, D2 U0, D3 U12, D4 U5, D5 U9, D6 U6, D7 U13 |
| **Final** | | **8/16 — FAIL** | Merit 10, capped to 8. |

Seven gating defects (D1–D7 each independently gate); D8 merit-only. Best-built rows of the four screens, worst screen-level framing (no headline, no search, banded background).

## Answers

- **First-time user in 3s?** Sees filters and three vehicles and can tap into a dossier — the rows work. But cannot name the screen (no headline), cannot search it (no affordance), misreads one row as highlighted (blue band), and cannot tell when `Starts 10:…` is. Rows pass, framing fails.
- **What would an Airbnb designer reject?** Missing search-first pattern (D1); missing headline (D2); tinted band behind one row (D3); truncated times/plates/chips (D4); rail grammar drift (D5) — fix in that order.

---
# ROUND-2 VERDICT (fresh-eyes re-review, 2026-10-22) — PASS 13/16

**Reviewer:** fresh eyes; did not fix. Branch `ui/list-ops` confirmed, no checkout/commit/push/merge, `71983229` untouched. Round-1 above kept verbatim.

## Fix verification (current PNGs + code)
- **Rail wrap + Dela whole: FIXED (rail).** `idle_360` now 3-line Wrap: `All 3 / Pending 1 / In Progress 1` + `Delayed 1 / QC Review 0` + `Completed 0` — every chip whole (`wrap:true`, `technician_jobs_view.dart:235`). Same whole-chips in `320` (`Delayed 1`, `QC Review 0`, `Completed 0` whole), `1.3x`, `filter_360` (`Delayed 1` selected whole + `Clear` inline, no `In Progress…` clip). `Dela…` gone at all sizes.
- **Times/plates: NOT fully fixed (merit, sanctioned).** `idle_360` still `Starts 10:…/08:…/11:…`; `320` `XYZ 56…/ABC 12…/DEF 90…`; `1.3x` `Starts …`. Brief U5 sanctions `pills wrap/ellipsize at 320px/1.3x`, and dev-D freezes shared `TechnicianJobSummary` (STOP boundary, shared with Today+sheet) — so list surface cannot re-layout pills. Downgrade to merit; no silent data loss (full values in dossier).

## Condensed regression
Open ≤1 ✓ · find (shell icon→sheet same predicate + chip 1) ✓ · open dossier 1 ✓ · clear 1 ✓ · retry/pull + freshness ✓. No budget regresses. `empty/error/loading_360` show no rail — code `:68` `if (hasJobs)` hides toolbar when zero jobs (no fake filter; no-match with jobs keeps rail). Correct, not amnesia. Chevron/RTL hold.

## Rebuttals
- **Blue band selected-state: CORRECT, STANDS.** Band sits only on the `In Progress` row (`emphasised: job.status == inProgress`, `:167`); dev-D keeps the shared component byte-identical. Brief-sanctioned state, not a stray U12 band → merit at most.
- **Rail-in-empty: CORRECT, STANDS.** With zero jobs there is nothing to facet; showing counted chips would be fake chrome (U3). Filter context persists via provider when jobs exist (no-match keeps rail). D6 not gating.
- **Skeleton atom: STANDS** (shared harness, r1 merit-only).

## Honest rubric — 13/16 PASS
1:2, 2:1, 3:2, 4:2, 5:2, 6:1, 7:1, 8:2 = **13/16**. No C16/C17 cap fires (D1 shell-icon single path blessed 16/16 dev-B, D2 no in-body header per dev-A, D3 emphasised state per dev-D, D4 rail fixed + pill ellipsis sanctioned, D5 rail-only honest counts, D6 intentional hide, D7 system task-math + HH:mm LTR footer as merit). References EMPTY still UNMET (unscored).
**Remaining gating: NONE.** Notes: narrow pill ellipsis on primary time/plate; no in-body headline (deep-link anonymity, shell owns title); task-math copy.
