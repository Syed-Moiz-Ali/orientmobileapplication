# ADVERSARIAL REVIEW — Supervisor Queue list (ui/list-ops) — FAIL

**Role:** ADVERSARIAL REVIEWER. Never built this screen. Assumes NOT Airbnb-level. Hunt defects.
**Branch:** `ui/list-ops` (worktree; READ-ONLY, no checkout/commit/push; never touched `71983229`).
**Governance (all gate):** DESIGN_SPEC C16 (any hard-reject caps 10/16) + C17 U0–U14 (any violated law caps 8/16, no exceptions). Pass ≥12/16 with caps.
**Read first:** Brief `docs/ui-redesign/briefs/supervisor-queue-list.md` (deviations A/B/C claimed) + migration `docs/ui-redesign/evaluation/supervisor-queue-list-test-migration.md` + prior evaluations (assumed 15–16/16 PASS — this review DISAGREES).
**References:** `docs/ui-redesign/references/` DOES NOT EXIST; `AIRBNB_PATTERNS.md` missing repo-wide (brief §References, UNMET — proceeded on precedent). Process debt, not scored, but noted.
**Constraint obeyed:** READ-ONLY except this file. Owner-cards fixes ignored (different surface).

## Images viewed (full resolution, Read)

`docs/ui-redesign/baseline/after-supervisor-queue/` — all 10:
- `idle_light_1.0_en_360x800.png`, `idle_light_1.0_en_320x568.png`, `idle_light_1.3_en_360x800.png`, `idle_light_1.0_ar_360x800.png`, `idle_light_1.0_en_768x1024.png`
- `filter_light_1.0_en_360x800.png`, `sheet_light_1.0_en_360x800.png`, `empty_light_1.0_en_360x800.png`, `error_light_1.0_en_360x800.png`, `loading_light_1.0_en_360x800.png`
- Contact sheet `docs/ui-redesign/baseline/phase-sv-queue-light.png` (BEFORE-left vs AFTER-right)
- Siblings: `after-supervisor-jobs/idle_360`, `after-supervisor-review/idle_360`, `after-technician-jobs/idle_360`

## Ranked defect list (severity 1 = most severe, GATES = strict)

### D1 — C17-U1 SEARCH: NO SEARCH ICON ANYWHERE ON THE SURFACE (SEV 1) — GATES (U1 caps 8/16)
- **Pixels:** `idle_light_360` full-crop region top→bottom: header (`Incoming queue / Priority-sorted bookings and breakdowns`), orphan refresh icon `↻` alone on its own line, filter rail, sections. ZERO search icons in any frame (`idle`, `320`, `1.3x`, `ar`, `tablet`, `filter`, `sheet`, `empty`, `error`, `loading`). The crops exclude the scaffold bar, so within the captured surface there is no discoverable search path at all.
- **Law:** C17-U1 mandates a search ICON at TOP RIGHT on EVERY list screen opening a full-screen search with recents. Brief deviation B ("no list-scoped search icon, at any size") sanctions exactly the forbidden absence, but C17 states "no exceptions" — spec beats brief. A supervisor who inherits this tab alone (deep-link, tablet) finds no search. **GATES.**

### D2 — C17-U5 TRUNCATION: RAIL + ROW DETAIL CUT MID-WORD (SEV 2) — GATES (U5 caps 8/16)
- **Pixels:** `idle_light_360` rail region: `All / VIP 1 / Promised today 0 / Insura…` — 4th chip severed mid-word (`Insura`, not `Insurance`), no icon/label-start peek, no fade. Same cut in `320`, `1.3x`, `tablet`, `empty`, `error`, `loading` (every frame with a rail). `idle_320` row region: `Engine overh… GHI 3456` — the breakdown symptom (the single most important triage text) ellipsized mid-word.
- **Law:** C17-U5: "never a label cut mid-word… cut item's icon AND label start clearly visible." The rail violates it on all 6+ frames; the row violates the "truncation only on secondary text" clause — the failure symptom is primary content, not meta. **GATES.**

### D3 — C16 DUPLICATED NUMBERS + C17-U11 STATS THAT DON'T HELP (SEV 3) — GATES (C16 caps 10/16, U11 caps 8/16)
- **Pixels:** `idle_light_360`: rail `VIP 1` + section badges `Breakdowns [1]`, `Bookings [2]`; `filter_360` (VIP selected): rail `VIP 1` + badge `Breakdowns [1]` + badge `Bookings [1]` + `Clear`. The same counts appear in rail AND badges simultaneously.
- **Criterion:** C16 hard-reject: "no numbers duplicated in label and badge." Rail chip (`VIP 1`) and section badge (`1`) double-report identical buckets. C17-U11: "stats… are shown only if they help a decision" — `Promised today 0` and `Insurance 0`-family zero-chips consume rail slots to report nothing actionable. **GATES.**

### D4 — C17-U4/U9: ORPHAN REFRESH ICON, UNREACHABLE + MISPLACED (SEV 4) — GATES (U4 caps 8/16, U9 caps 8/16)
- **Pixels:** `idle_light_360`: a lone `↻` glyph sits on its own line between the subtitle and the rail, left-aligned, ~48px of dead space around it, the only control on its row. Jobs puts its header action full-width under the title; Review puts `↻` similarly orphaned; technician puts freshness at the bottom. Three sibling screens, three refresh seats.
- **Laws:** C17-U4 (reachability: frequent actions reachable, lower half/sticky) — refresh-the-queue is a top-5 task per the brief yet lives as a tiny lone glyph at the top, not in a sticky/header-action seat. C17-U9 (same element, same place) — the refresh action changes seat and form across Jobs/Queue/Review. The contact sheet confirms BEFORE had the same orphan, so the rebuild carried the defect forward instead of fixing it. **GATES.**

### D5 — C17-U6/U8: SECTION-EMPTY STATES ARE DUPLICATE DEAD TEXT (SEV 5) — GATES (U8 caps 8/16)
- **Pixels:** `loading_light_360` (zero-data variant): `Breakdowns [0]` + plain text `No bookings or breakdowns waiting.` followed by `Bookings [0]` + the IDENTICAL sentence `No bookings or breakdowns waiting.` — the same 6-word sentence twice on one screen, neither naming its section. `empty_360` (`The queue is clear / No bookings or breakdowns waiting.`) offers no Refresh/Retry path — the only recovery is the orphan `↻` (D4).
- **Law:** C17-U8 (no dead ends): two sections simultaneously dead with copy-pasted text and no per-section live control. C17-U6 (calm empty): the empty frame carries filter rail + badges + zero-chips (`VIP 0 / Promised today 0`) above a "clear" message — chrome reporting zeros around a nothing-to-do state. The badge `[0]` + chip `0` + sentence triple-reports emptiness. **GATES.**

### D6 — C17-U0/U13: ROW HIERARCHY BURIES THE DECISION SIGNAL (SEV 6) — GATES (U0 caps 8/16)
- **Pixels:** `idle_light_360` booking rows: `Camry / VIP detailing / ABC 1234 / [VIP]` and `Civic / Oil change / DEF 9012 / (no pill)`. The normal-priority `Civic` row renders with NO pill at all (brief-sanctioned), so two visually identical rows differ only by the absence of a chip — the triage signal is a missing element. The plate (`ABC 1234`) sits center-row in muted text competing with the service line for the meta seat.
- **Law:** C17-U0 (never hunt): a supervisor scanning for "what needs me" must notice an ABSENT pill on `Civic` vs a present pill on `Camry` — negative-space signaling. C16 plain-language status ("one colored dot/pill + one sentence, one status per card") is satisfied for VIP/Emergency but the normal row has zero status — is `Civic / Oil change` normal, un-triaged, or failed-to-classify? U13: nothing answers that in 3 seconds. **GATES (U0).**

### D7 — SHEET CONTRADICTION: PRE-SELECTED RADIO + BOTTOM CTA DUPLICATE (SEV 7) — GATES (C16 caps 10/16)
- **Pixels:** `sheet_light_360` (`Route to advisor`): `Omar Haddad (Advisor)` pre-selected (blue radio) + `Sara Ali (Advisor)` + full-width filled `Assign advisor` bottom CTA. Behind the scrim, the dimmed row button also reads `Assign advisor` — the same label appears twice on one screen (row + sheet CTA).
- **Criterion:** C16 "Max ONE primary CTA per screen" — scrim-dimmed row CTA + sheet CTA = two primaries visible simultaneously. The pre-selected first advisor + CTA means the 3-tap flow (row → select → confirm) can be completed without ever making a choice — the sheet confirms whoever happened to be first, which in a dispatch queue is a mis-route risk, not a convenience. Filed as gating C16 (duplicate primary) + U0 (choice without thinking). **GATES.**

### D8 — MERIT-ONLY (NON-GATING BUT SCORED): skeleton/state polish gaps
- **Skeleton mismatch:** `loading_360` avatar-circles + bars mirror neither the breakdown rows (icon + title + pill + full-width button) nor the section labels — C10/C14 deduction, no cap clause.
- **AR check (pass, recorded):** `ar_360` mirrors correctly, `طوارئ / كبار العملاء` pills intact, plates/figures LTR-locked — the one RTL frame that fully holds. Noted to prove it was checked.
- **Tablet (pass with note):** `768x1024` keeps single-column register, sections + buttons max-width — correct per deviation C; rail still cuts (`Insura…`), already counted in D2.

## Tap walkthrough (BEFORE→AFTER, per brief + migration)

BEFORE (brief): open 1 (tab) · route 3 (row Assign + picker select + sheet CTA) · filter 1 · clear 1 · retry 1 / pull.
AFTER (pixels + pins): open ≤1 ✓ · route 3 ✓ (same seats, but D7 duplicate-label + pre-selected risk) · filter 1 ✓ (but D2 cut chips, D3 duplicated counts) · clear 1 ✓ · retry 1 ✓ (but D4 orphan seat). **No budget regresses, but D2/D4/D7 pattern/seat defects ride the same taps.**

## Consistency cross-check (cited sibling afters actually opened)

- **Supervisor jobs** (`idle_360`): HAS inline search (D1 opposite: Jobs=inline-present, Queue=absent entirely) — the two siblings take opposite sides of U1 and both fail it. Jobs rail `All` count-less vs Queue rail `All` count-less — consistent; but Queue section badges add a second counting system Jobs lacks (D3).
- **Supervisor review** (`idle_360`): same orphan `↻` seat as Queue (D4 shared), same full-red complete-bar disease (Review JC-207 4/4 red; Queue has no bars — spared).
- **Technician jobs** (`idle_360`): rail `All 3` WITH count vs Queue `All` without; Title-Case pills both; technician `Starts 10:…` truncation mirrors Queue `Engine overh…` (shared U5 disease, D2).
- Contact sheet `phase-sv-queue-light.png`: BEFORE `Emergency` pill used `ⓘ` icon → AFTER uses `●` dot (quiet fix, confirmed); rail cut and orphan refresh identical both sides (carried, not fixed).

## Airbnb rubric (ONLY after defects above), /16, pass ≥12

| # | Criterion | Score | Why |
|---|---|---|---|
| 1 | One task per screen | 1/2 | Find→route coherent, but no search path + pre-selected confirm (D1, D7) |
| 2 | Headline-first hierarchy | 1/2 | Breakdowns→bookings order holds; normal rows signal by absence (D6) |
| 3 | Whitespace, no boxes | 2/2 | Borderless divider rows, no cards-in-cards (holds) |
| 4 | Sheets for secondary | 1/2 | Picker IS the sheet ✓, but duplicate CTA label + pre-select (D7) |
| 5 | Sticky CTA | 2/2 | Correctly absent; row buttons are secondary outlined (holds) |
| 6 | Section structure | 0/2 | Duplicate counts rail-vs-badge, zero-chips, copy-pasted section-empty text (D3, D5) |
| 7 | Plain copy | 1/2 | `Insura…`/`overh…` cuts, unexplained missing pill (D2, D6) |
| 8 | Single primary action | 1/2 | One filled per state, but sheet double-labels it (D7) |
| **Merit** | | **9/16** | |
| **C16 cap** | any hard-reject → max 10 | **caps at 10** | D3 duplicated numbers, D7 duplicate primary |
| **C17 cap** | any U-law → max 8 | **caps at 8** | D1 U1, D2 U5, D3 U11, D4 U4/U9, D5 U8, D6 U0 |
| **Final** | | **8/16 — FAIL** | Merit 9, capped to 8. |

Six gating defects (D1–D6 + D7 each independently gate); D8 merit-only.

## Answers

- **First-time user in 3s?** Sees breakdown + bookings and Assign buttons, but no search, a lone `↻` on its own line, an `Insura…` chip, counts in two systems, and a normal row whose only status is nothing. Routing works, triage requires decoding.
- **What would an Airbnb designer reject?** Missing search path (D1); mid-word cuts incl. the symptom line (D2); counts reported twice (D3); orphan refresh (D4); copy-pasted dead sections (D5) — fix in that order.

---
# ROUND-2 VERDICT (fresh-eyes re-review, 2026-10-22) — PASS 12/16

**Reviewer:** fresh eyes; did not fix. Branch `ui/list-ops` confirmed, no checkout/commit/push/merge, `71983229` untouched. Round-1 above kept verbatim.

## Fix verification (current PNGs + code)
- **Insura wrap: FIXED (rail).** `idle_360`: `All / VIP 1 / Promised today 0` + `Insurance 0` whole line 2 (`wrap:true`, `supervisor_queue_tab.dart:101`). Same whole in `filter_360` (`Insurance 0` + `Clear` inline), `empty_360`, `320` (`Insurance 0` whole). `1.3x` still shows `Engine ov…` row-detail truncation (see below).
- **Dead-condition split into skeleton: FIXED for zero-data path.** `loading_360` now pure `AppShimmerSkeleton.listRows(6)` (code `:111-112` `isLoadingNoData`), no duplicate `No bookings…` sentences. `empty_360` single honest `The queue is clear / No bookings or breakdowns waiting.` with NO action (brief-kept: nothing to create). Per-section `_EmptyLine` quiet text remains only when one section has data (brief-kept U6 calm) — not the double-dead screen of r1.
- **360 row detail: FIXED at 360.** `idle_360`/`filter_360` show `Engine overheating GHI 3456` full. **NOT fixed at 320/1.3x** (`Engine overh…` / `Engine ov…`) — but brief U5 explicitly sanctions `detail ellipsizes (1 line) at 320px/1.3x`, so merit, not gate.

## Condensed regression
Open ≤1 ✓ · route 3 same sheet/picker/toast ✓ · filter 1 + Clear 1 ✓ · retry/pull ✓. No budget regresses. Zero-chips (`Promised today 0`, `Insurance 0`) still consume rail slots (brief-kept facets, merit). Orphan `↻` seat is brief-kept header action (`:82-91`); skeleton circles still shared-harness mismatch (merit).

## Rebuttals
- **Triple counts (rail vs badges): STANDS as merit.** Duplication real, but brief dev-A keeps static subtitle + counts on section labels; rail facets vs section totals serve filter vs triage. Merit −1, not gate.
- **Skeleton atom: STANDS.** `AppShimmerSkeleton` is shared harness, identical across tabs; r1 already merit-only. Not screen-gating.

## Honest rubric — 12/16 PASS
1:1, 2:1, 3:2, 4:2, 5:2, 6:1, 7:1, 8:2 = **12/16**. No C16/C17 cap fires (D1 single-path=bar per dev-B, D2 rail fixed + detail ellipsis sanctioned, D3/D4/D6 brief-kept, D5 split fixed, D7 pre-select existing + scrim-dimmed label not a second primary). References EMPTY still UNMET (unscored).
**Remaining gating: NONE.** Notes: 320/1.3x symptom ellipsis; zero-chips; skeleton shape.
