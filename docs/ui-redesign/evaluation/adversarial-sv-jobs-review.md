# ADVERSARIAL REVIEW — Supervisor Jobs list (ui/list-ops) — FAIL

**Role:** ADVERSARIAL REVIEWER. Never built this screen. Assumes NOT Airbnb-level. Hunt defects.
**Branch:** `ui/list-ops` (worktree; READ-ONLY, no checkout/commit/push; never touched `71983229`).
**Governance (all gate):** DESIGN_SPEC C16 (any hard-reject caps 10/16) + C17 U0–U14 (any violated law caps 8/16, no exceptions). Pass ≥12/16 with caps.
**Read first:** Brief `docs/ui-redesign/briefs/supervisor-jobs-list.md` (deviations A/B/C claimed) + migration `docs/ui-redesign/evaluation/supervisor-jobs-list-test-migration.md` (8/8 pins) + prior evaluations (rounds 1+2, both 15/16 PASS — this review DISAGREES).
**References:** `docs/ui-redesign/references/` DOES NOT EXIST; `AIRBNB_PATTERNS.md` missing repo-wide (brief §References, UNMET — proceeded on precedent). Process debt, not scored, but noted.
**Constraint obeyed:** READ-ONLY except this file. Owner-cards fixes ignored (different surface).

## Images viewed (full resolution, Read)

`docs/ui-redesign/baseline/after-supervisor-jobs/` — all 10:
- `idle_light_1.0_en_360x800.png`, `idle_light_1.0_en_320x568.png`, `idle_light_1.3_en_360x800.png`, `idle_light_1.0_ar_360x800.png`, `idle_light_1.0_en_768x1024.png`
- `search_light_1.0_en_360x800.png`, `filter_light_1.0_en_360x800.png`, `empty_light_1.0_en_360x800.png`, `error_light_1.0_en_360x800.png`, `loading_light_1.0_en_360x800.png`
- Contact sheet `docs/ui-redesign/baseline/phase-sv-jobs-light.png` (BEFORE-left vs AFTER-right)
- Siblings: `after-supervisor-queue/idle_360`, `after-supervisor-review/idle_360`, `after-technician-jobs/idle_360`

## Ranked defect list (severity 1 = most severe, GATES = strict)

### D1 — C16 SEARCH HARD-REJECT + C17-U1 SEARCH VIOLATION (SEV 1) — GATES (C16 caps 10/16, U1 caps 8/16)
- **Pixels:** `idle_light_360` mid-page region: rounded inline `AppSearchField` (`Search job card, customer, or plate`) sitting between the summary strip and the chip rail. Header region (`Active jobs / 3 on the floor / Assign work`) carries ZERO search icons in every frame (`idle`, `320`, `1.3x`, `ar`, `tablet`, `search`, `filter`, `empty`, `error`, `loading`). `search_360` proves the inline field filters in place and pushes content (list collapses 3→1 row).
- **Law:** C17-U1: "a search ICON in the header at the TOP RIGHT… Tapping opens a full-screen search (auto-focused field, recents…). NEVER an inline search field in the page. Same placement on every dashboard/list screen." This surface has the exact forbidden pattern and zero compliant icons.
- **C16 hard-reject:** "Search = one pill at the top that opens a full search screen/sheet with recents; never an inline field in the middle of the page, and never pushing content around." Inline-in-the-middle + pushes-rows-around = two clauses breached.
- **Brief deviation A does not cure a C17 cap:** the brief sanctions "no header icon" as an adjudicated STOP, but C17 states "any violated law caps the screen at 8/16, no exceptions." Spec beats brief in an adversarial reading. **GATES.**
- **U9 consistency:** sibling technician-jobs pattern (blessed `phase-jobs-search-audit-review.md` 16/16) is header-icon → full sheet; owner-cards review (D1) files the same inline-search hit. This surface is the outlier.

### D2 — C17-U8 RELEVANCE: COMPLETED UNDER "ACTIVE" (SEV 2) — GATES (U8 caps 8/16)
- **Pixels:** `idle_light_360` header `Active jobs / 3 on the floor` + row 2 `Civic DEF 9012 / JC-102 Sara / Completed (green pill, check) / 4/4 tasks`. Same in `320`, `1.3x`, `ar`, `tablet`, contact-sheet AFTER-right.
- **Law:** C17-U8: "historical/completed items never sit under 'Assigned'/'To do'. If the data feed does it, do NOT filter silently: log it in LOGIC_FOLLOWUPS.md." `LOGIC_FOLLOWUPS.md` logs advisor completed-under-assigned and owner completed-under-active variants — no entry for sv-jobs completed-under-"Active jobs". Either the feed is wrong and unlogged, or the headline is wrong ("active" includes completed without explanation).
- Ordering (running → completed → waiting) is correct priority, but inclusion without disclosure is the breach. **GATES.**

### D3 — C2 SEMANTIC-COLOR ABUSE + C17-U10 MISLEADING FEEDBACK: COMPLETED BAR IS FULL RED (SEV 3) — GATES (U10 caps 8/16)
- **Pixels:** `idle_light_360` row-2 region: green `Completed` pill paired with a FULL-LENGTH RED progress bar (`4/4 tasks`). `320`, `1.3x` (same red full bar), contact sheet AFTER-right (was green in BEFORE-left). `search_360` single-row state repeats it.
- **Criterion:** C2: "Green/red are reserved for success/error… Never use them decoratively." A 4/4 terminal-success state rendered in error-red is the textbook misuse; the two status signals (pill vs meter) directly contradict each other on the same row.
- **Law:** C17-U10 (feedback): the screen tells the supervisor a finished job is simultaneously "done" and "danger". A new employee triaging by color reads red as needs-attention. Prior rounds filed this as a merit-only −1; adversarially it is a gating feedback lie, not a tone nit. **GATES.**

### D4 — C17-U5 TRUNCATION: RAIL CUT MID-WORD + HINT CUT AT 320 (SEV 4) — GATES (U5 caps 8/16)
- **Pixels:** `idle_light_360` rail region: `All / In progress 1 / Completed 1 / Par…` — 4th chip severed mid-word at the frame edge with no icon/label-start peek and no fade affordance. `320` rail: same cut (`Par…`); search hint `Search job card, customer, or pl…` truncated; `1.3x` hint `Search job card, customer, …` truncated. `filter_360` selected state renders `Complete…` clipped against `Clear`.
- **Law:** C17-U5: "never a label cut mid-word. Horizontal rows either fit completely… or scroll with a clean peek where the cut item's icon AND label start are clearly visible." `Par…` / `Complete…` mid-word cuts with no peek violate it literally. Hint ellipsis is tolerable; chip-label mutilation is not. **GATES.**

### D5 — C17-U6 + C16 ONE-CTA: EMPTY STATE CARRIES TWO IDENTICAL FILLED ASSIGNS (SEV 5) — GATES (U6 caps 8/16, C16 caps 10/16)
- **Pixels:** `empty_light_360`: header full-width blue `Assign work` AND empty-body full-width blue `Assign work` stacked on one screen (`No active jobs / Assign work to see jobs on the floor. / [Assign work]`). Same duplication in `error_360` (`Assign work` header + `Retry` body = two filled blues, acceptable pair) — but empty has the SAME label twice.
- **Law:** C17-U6: "a filled CTA exists only when it leads to something that exists." With zero jobs, two identical filled CTAs compete for one sheet. C16: "Max ONE primary CTA per screen" / "Exactly ONE filled accent per section" — empty frame shows two filled primaries with identical labels (header section + body section). One path per task (D-spec U7) also fails: two entry points for the same sheet on one screen. **GATES (both).**

### D6 — C17-U9 CONSISTENCY: FILTER RAIL + PILL GRAMMAR DIVERGE FROM SIBLINGS (SEV 6) — GATES (U9 caps 8/16)
- **Pixels:** `idle_light_360` rail `All` (no count) + `In progress 1 / Completed 1 / Parts…` vs technician-jobs rail `All 3 / Pending 1 / In Progress 1…` (count inside `All`, Title-Case `In Progress`) vs queue rail `All / VIP 1 / Promised today 0…`. Pills here are Title Case (`In Progress`, `Completed`, `Waiting for Parts`) while owner-cards (just fixed) are sentence case — same design system, three casings.
- **Law:** C17-U9: "the same element sits in the same place across screens." The rail is the same element with different count placement, different casing, different selected-pill behavior (`filter_360` clips the selected pill against `Clear`, a layout no sibling shows). **GATES.**

### D7 — C17-U13/U11: COUNTS DUPLICATED IN LABEL + BADGE + SUMMARY STRIP (SEV 7) — GATES (U11 caps 8/16)
- **Pixels:** `idle_light_360`: summary strip `3 Total ● 1 In progress ● 1 Completed ● 1 Parts delay` restates exactly what the rail chips (`All / In progress 1 / Completed 1 / …`) and the subtitle (`3 on the floor`) already say — the same four numbers appear in three places.
- **Criterion:** C16 hard-reject: "no numbers duplicated in label and badge." Strip-vs-rail-vs-subtitle triple-counts the identical buckets. C17-U11: "stats… are shown only if they help a decision" — the strip adds zero information over rail + subtitle and pushes the search + first row down the fold budget. **GATES.**

### D8 — MERIT-ONLY (NON-GATING BUT SCORED): skeleton/state/RTL nits
- **Loading mismatch:** `loading_360` renders avatar-circle + two-line skeleton rows; loaded rows are rail + identity + pill + full-width meter (no avatar anywhere). C10/C14 "skeleton [must] mimic the final layout" — circles match nothing on this surface. Non-gating (no C16/C17 cap clause names skeleton shape), but Airbnb §6 deduction.
- **AR order:** `ar_360` mirrors correctly (rail right, pills left, `2/5 مهام` LTR-locked) — actually a pass; filed only to record it was checked. The `OH/SA`-style cryptic initials problem belongs to Review, not here.
- **Tablet:** `768x1024` keeps single-column register with header Assign docked top-right instead of full-width — correct responsive behavior, but inconsistent CTA seat vs compact (U9 tension, filed not gated).

## Tap walkthrough (BEFORE→AFTER, per brief + migration)

BEFORE (brief, verified from code): open 1 (tab) · find 1 + keystrokes (+scroll) · assign 2 (tab + header/empty Assign) · clear 1 · retry 1 / pull.
AFTER (pixels + pins): open ≤1 ✓ · find same seats ✓ (but wrong pattern per D1) · assign ≤2 ✓ (but duplicated per D5) · clear 1 ✓ (`filter` Clear) · retry 1 / pull ✓. **No budget regresses, but D1/D5 pattern/duplication defects ride the same taps.**

## Consistency cross-check (cited sibling afters actually opened)

- **Supervisor queue** (`idle_360`): rail counts inside chips, section badges duplicate them (D7 sibling), rail 4th-chip cut mid-word (same D4 disease), but NO inline search — opposite search seat from Jobs (U9, see D1/D6).
- **Supervisor review** (`idle_360`): ID-first rows (`JC-207` headline) vs Jobs vehicle-first (`Camry ABC 1234`) — same family, opposite hierarchy (Jobs is correct; Review is not).
- **Technician jobs** (`idle_360`): rail `All 3` counts vs Jobs `All` count-less; pills Title Case both; technician rows truncate `Starts 10:…` the way Jobs truncates `Par…` (shared U5 disease).
- Contact sheet `phase-sv-jobs-light.png`: BEFORE row-2 bar green → AFTER red (D3 regression introduced by the shared-atom swap, not present before).

## Airbnb rubric (ONLY after defects above), /16, pass ≥12

| # | Criterion | Score | Why |
|---|---|---|---|
| 1 | One task per screen | 1/2 | Find→assign coherent, but inline search pushes rows + dual Assign entries (D1, D5) |
| 2 | Headline-first hierarchy | 2/2 | Vehicle-first → jobCard+customer → meter → pill holds (best of the four screens) |
| 3 | Whitespace, no boxes | 2/2 | Borderless divider rows, no cards-in-cards (passes where owner-cards failed) |
| 4 | Sheets for secondary | 1/2 | Assign IS the sheet ✓, but filters are a cut rail with no `Show N results` sheet (D4) |
| 5 | Sticky CTA | 1/2 | Correctly non-sticky, but empty duplicates it (D5) |
| 6 | Section structure | 1/2 | Header + strip + inline + rail + rows is 5 stacked blocks; strip triple-counts (D7), skeleton mismatched (D8) |
| 7 | Plain copy | 1/2 | Completed-under-Active + red-means-done (D2, D3) |
| 8 | Single primary action | 0/2 | Two identical filled Assigns in empty; selected-pill + Clear dual-blue in filter (D5) |
| **Merit** | | **9/16** | |
| **C16 cap** | any hard-reject → max 10 | **caps at 10** | D1 search, D5 one-CTA/duplicate-path, D7 duplicated numbers |
| **C17 cap** | any U-law → max 8 | **caps at 8** | D1 U1, D2 U8, D3 U10, D4 U5, D5 U6, D6 U9, D7 U11 |
| **Final** | | **8/16 — FAIL** | Merit 9, capped to 8 (below both caps). |

Seven gating defects (D1–D7 each independently gate); D8 merit-only.

## Answers

- **First-time user in 3s?** Can type or tap Assign, but must reconcile "Active" containing "Completed," a red bar meaning done, a `Par…` chip, and two identical Assign buttons when there is nothing to assign. Task completes despite the copy, not because of it.
- **What would an Airbnb designer reject?** Inline filtering search instead of a pill→sheet (D1); completed under Active (D2); red-means-done meter (D3); mid-word rail cuts (D4); duplicate Assign CTAs (D5) — fix in that order.

---
# ROUND-2 VERDICT (fresh-eyes re-review, 2026-10-22) — PASS 13/16

**Reviewer:** fresh eyes; did not fix. Branch `ui/list-ops` confirmed, no checkout/commit/push/merge, `71983229` untouched. Round-1 above kept verbatim.

## Fix verification (current PNGs + code)
- **D3 red 4/4 → green: FIXED.** `idle_360` row 2 `Civic DEF 9012 / JC-102 Sara / Completed` now dark-GREEN full bar `4/4 tasks` (was full red); same in `320`, `1.3x`, `filter_360`, `search_360`. Code `supervisor_jobs_tab.dart:387-391` pins `AppProgressTone.success` when done>=total else `accent` — same value, token only.
- **D4 rail mid-word cut: FIXED.** `idle_360`: `All / In progress 1 / Completed 1` + `Parts delay 1` whole on line 2 (`wrap:true`, `app_filter_bar.dart` Wrap flow, `supervisor_jobs_tab.dart:127`). Same whole-chips in `320`, `1.3x`, `filter_360` (`Completed 1` selected whole + `Clear` inline, no `Complete…` clip). Hint still ellipsizes at 320/1.3x — tolerable; chip mutilation gone.
- **D5 duplicate Assign: FIXED.** `empty_360`: header has NO Assign; single body `Assign work`. Code `:62-67` `isEmptyRegister` hides header action only when confirmed empty — same sheet/handler, seat only.
- **D2 U8 LOGIC #13: EXISTS.** `LOGIC_FOLLOWUPS.md` §13 logs terminal-under-Active (feed `supervisorDashboardProvider:386-399`, evidence idle row 2, fixture `_doneJob` innocent, family of #1/#12, open, no silent filter). Disclosure satisfies U8 → no longer gates.

## Condensed regression
Open ≤1 ✓ · find (inline+rail, same predicate) ✓ · assign ≤2 same sheet ✓ · clear 1 ✓ · retry/pull ✓. No budget regresses. Skeleton circles still mismatch rows (shared-harness merit). Strip still triple-reports rail/subtitle (brief-kept, merit). AR/tablet hold.

## Rebuttals
- **Dual-search sanction: STANDS** (brief dev-A STOP, bay-vs-register scopes, acceptance adapts C16 → merit not gate).
- **Triple counts: STANDS as merit** (duplication real but brief-kept summary+rail; glance vs filter differ → merit −1, not gate).

## Honest rubric — 13/16 PASS
1:2, 2:2, 3:2, 4:1, 5:2, 6:1, 7:1, 8:2 = **13/16**. No C16/C17 cap fires. References EMPTY still UNMET (process debt, unscored).
**Remaining gating: NONE.**
