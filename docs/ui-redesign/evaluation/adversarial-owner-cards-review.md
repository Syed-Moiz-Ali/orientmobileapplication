# ADVERSARIAL REVIEW — Owner Job-Cards List (ui/list-ops) — FAIL

**Role:** ADVERSARIAL REVIEWER. Never built this screen. Assumes NOT Airbnb-level. Hunt defects.
**Branch:** `ui/list-ops`. **Repo:** `E:\syed_moiz_ali\orientmobileapplication`.
**Governance (all gate):** REDESIGN MANDATE + C16 hard-reject (any violation caps at 10/16) + U0–U14 C17 (`docs/ui-redesign/DESIGN_SPEC.md`, any violated law caps at 8/16, no exceptions). Pass ≥12/16 with caps.
**Read first:** Brief `docs/ui-redesign/briefs/owner-job-cards-list.md` (deviations A–D claimed) + migration `docs/ui-redesign/evaluation/owner-job-cards-list-test-migration.md` (9/9 pins, UPPERCASE fix claim) + prior evaluations (`owner-job-cards-list-evaluation.md` rounds 1+2, both 16/16 PASS — this review DISAGREES).
**References:** `docs/ui-redesign/references/` DOES NOT EXIST; `AIRBNB_PATTERNS.md` missing repo-wide (brief §References, UNMET — proceeded on precedent). Process debt, not scored, but noted: no authoritative pattern source was consulted.
**Constraint obeyed:** READ-ONLY except this file. No branch/commit/push. Never touched `71983229`.

## Images viewed (full resolution, Read)

`docs/ui-redesign/baseline/after-owner-job-cards/` — all 11:
- `idle_light_1.0_en_360x800.png`, `idle_light_1.0_en_320x568.png`, `idle_light_1.3_en_360x800.png`, `idle_dark_1.0_en_360x800.png`, `idle_light_1.0_ar_360x800.png`, `idle-wide_light_1.0_en_1280x800.png`, `selected-wide_light_1.0_en_1280x800.png`, `filter_light_1.0_en_360x800.png`, `search_light_1.0_en_360x800.png`, `empty_light_1.0_en_360x800.png`, `loading_light_1.0_en_360x800.png`
- Contact sheet `docs/ui-redesign/baseline/phase-owner-cards-light.png` (BEFORE-left vs AFTER-right)
- Siblings: `after-owner-home/home_1.0_en_360x800.png`, `after-technician-jobs/idle_light_1.0_en_360x800.png`, `after-technician-jobs/empty_light_1.0_en_360x800.png`

## UPPERCASE pills — VERIFIED FIXED IN PIXELS (not re-filed)

Prior rounds described `IN PROGRESS / QUALITY CHECK / COMPLETED` (pinned `.toUpperCase()` quirk). Current afters show sentence case in every frame: `idle_light_360` card regions read `In progress / Quality check / Completed`; `idle_dark_360` same; `selected-wide` table + preview same; `search/filter` same. Fix confirmed. The contact sheet `phase-owner-cards-light.png` still shows ALL-CAPS on BOTH sides — it is STALE (pre-fix capture), not evidence of a live violation. No caps remain on this surface. No C16 added-caps hit on this point.

## Ranked defect list (≥5, severity 1 = most severe, GATES = strict)

### D1 — U1 SEARCH VIOLATION + C16 search-pattern violation + U9 inconsistency (SEV 1) — GATES (U1 caps 8/16, C16 caps 10/16)
- **Pixels:** `idle_light_360` search region: rounded inline `AppSearchField` with hint `Search job, plate, customer…` mid-page under the bar; bar region (`Job register / All active… / 3 jobs`) carries ZERO header icons. Same in `320`, `1.3x`, `dark`, `ar`, `idle-wide`, `selected-wide`. `search_light_360` proves inline field filters in place and pushes content (list collapses 3→1, `1 jobs` pill updates).
- **Law:** U1 (C17): "a search ICON in the header at TOP RIGHT… NEVER an inline search field in the page. Same placement on every dashboard/list screen." This screen has the exact forbidden pattern and zero compliant icons.
- **C16 hard-reject:** "Search = one pill at the top that opens a full search screen/sheet with recents; never an inline field in the middle of the page, and never pushing content around." This is an inline field in the middle that pushes the list around. Two independent hard-reject clauses breached.
- **U9 consistency:** Sibling `after-owner-home/home_360` HAS header search affordances (top-left search box + top-right magnifier next to bell/avatar); technician jobs pattern per `phase-jobs-search-audit-review.md` is header-icon → full sheet. This surface is the outlier family-wide.
- **Brief deviation B does not cure a C17 cap:** the brief sanctions "no header icon" as deviation B, but C17 states "any violated law caps at 8/16, no exceptions." An adversarial reading enforces spec over brief. **GATES.**
- **Tap impact:** find = 0-tap focus + keystrokes works, but violates mandated path; no recents/scan sheet exists.

### D2 — C16 LIGHT CARDS HAVE BORDERS + CARD-INSIDE-CARD + U12 STRAY BAND (SEV 2) — GATES (C16 caps 10/16, U12 caps 8/16)
- **Pixels:** `idle_light_360` card regions: every job sits in an inner bordered card (`JC-1042 / Ahmed / Camry · ABC 1234 / AED 2,450.00 / In progress / >`) which itself sits inside a larger faint outer rounded frame that wraps all three jobs. Same double-frame in `320`, `1.3x`, `search`, `filter`, `empty` (outer frame + inner empty card), `loading` (outer frame + skeleton rows). Light theme, borders clearly rendered.
- **Criterion:** C16 hard-reject: "Cards in LIGHT theme have no borders (soft shadow or flat, separated by whitespace). Dark may use border." + C16 STRUCTURE: "Content is cards with big rounded corners, soft shadow, NO borders on cards… NEVER card-inside-card." This is borders + card-inside-card + wrapper box.
- **U12:** "ONE BACKGROUND: one page background colour; no stray bands or differently coloured strips behind rows." The outer wrapper is a stray band behind rows (page grey vs wrapper white vs card white = 3 tones).
- Prior review's "borderless-feel (border-XOR-shadow)" is contradicted by pixels — borders are visible, and XOR was not achieved (both outer AND inner borders render). **GATES.**

### D3 — C16 CARD HIERARCHY INVERTED: ID-FIRST, NOT CUSTOMER/VEHICLE-FIRST + U0 (SEV 3) — GATES (C16 caps 10/16, U0 caps 8/16)
- **Pixels:** `idle_light_360` card 1 region top→bottom: pale chip `JC-1042` FIRST, then bold `Ahmed`, then muted `Camry · ABC 1234`, then bold `AED 2,450.00`, then pill `In progress` terminal. Same order cards 2–3, all idle variants, `search`, `filter`.
- **Criterion:** C16 hard-reject: "Hierarchy inside cards: title = the thing the user recognizes (vehicle/customer), then status pill, then meta; IDs are small meta, not titles." Here the ID is the topmost chip — acting as a title — while status (the decision signal) is buried last.
- **U0:** "The user must never have to think… fewer steps." Forcing an ID-first read (workshop code) before the recognized name/vehicle adds cognitive load; new employee must decode `JC-1042` before `Ahmed/Camry`.
- **Consistency:** Sibling `after-technician-jobs/idle_360` does it correctly: title `Nissan Yaris / Toyota Camry` (vehicle = recognized thing), then `JC-102` small meta, then plate/starts meta, status pill top-right. Owner cards are inverted vs the family pattern. **GATES.**

### D4 — U10 RTL MONEY ORDER FLIPPED + C11/U13 CURRENCY CORRUPTION (SEV 4) — GATES (U10 caps 8/16)
- **Pixels:** `idle_light_1.0_ar_360x800.png` card regions: amounts render as `2,450.00 E.E` / `899.50 E.E` / `0.00 E.E` (number-first, currency glyphs rendered as disconnected `E.E`, not `AED`). Compare LTR `idle_light_360`: `AED 2,450.00` (currency-first, tabular, intact).
- **Law:** U10 (RTL): "full mirror; ref/plate/vehicleDisplay/money LTR-locked (`Directionality` kept)"; C15/U10 rule: "numbers/IDs/URLs stay LTR inside RTL." Pixels prove the lock failed — order flipped (trailing vs leading) and the `AED` codepoint run broke under mirroring (bidi-isolate missing or `formatAed2` not isolated).
- Brief §U10 claims "`Directionality` kept… LTR-locked" — pixels refute it. Technician/owner-home AR known-issues (`LOGIC_FOLLOWUPS.md` #9: English labels in AR) do not cover currency corruption; this is presentation-level. **GATES.**

### D5 — U5 TRUNCATION: RAIL LABEL CUT MID-WORD, NO CLEAN PEEK (SEV 5) — GATES (U5 caps 8/16)
- **Pixels:** `idle_light_320` rail region: chips `All / Intake 0 / Inspection 0 / WI` — the 4th chip is severed mid-word (`WI`, not `WIP 1`), right edge cuts through glyphs. `filter_light_360` rail: `WIP 1 / QC 1 / Ready 1 / Ir + Clear` — `Invoiced` severed to `Ir` with `Clear` text overlapping the rail edge. `idle_light_360` also clips `WIP 1` at the frame edge (right border cut, no affordance hint).
- **Law:** U5: "Horizontal rows either fit completely… or scroll with a clean peek where the cut item's icon AND label start are clearly visible. Prefer fitting over scrolling for ≤4 items… never a label cut mid-word." Cutting `WIP→WI` and `Invoiced→Ir` mid-word with no fade/peek affordance is the exact forbidden case. 1.3x passes, but 320px and filter-scroll fail.
- **GATES.**

### D6 — U8 RELEVANCE: COMPLETED UNDER "ALL ACTIVE" + NO LOG ENTRY, U13 PLAIN-WORDS LIE (SEV 6) — GATES (U8 caps 8/16)
- **Pixels:** `idle_light_360` subtitle `All active workshop jobs` + card 3 `JC-1044 / Khalid / Hilux / AED 0.00 / Completed` (green). Same in `dark`, `320`, `1.3x`, `wide` table row 3 `Completed`.
- **Law:** U8: "actionable items first; historical/completed items never sit under Assigned/To do. If the data feed does it, do NOT filter silently: log it in LOGIC_FOLLOWUPS.md." `LOGIC_FOLLOWUPS.md` (read 2026-10-22) logs advisor completed-under-assigned (#1), owner AR gaps (#3–5), tech stopwatch (#6) — NO entry for owner register completed-under-active. So either the feed is wrong and unlogged, or the subtitle is wrong ("active" includes completed without explanation). U13 new-employee test also fails: "active" plainly excludes "completed."
- Ordering (WIP→QC→Completed) is correct priority, but inclusion without disclosure is the breach. **GATES (U8).**

### D7 — U13 GRAMMAR + MISLABELED CTA: "1 jobs" + "Open register" (SEV 7) — GATES (U13 caps 8/16)
- **Pixels:** `search_light_360` bar pill reads `1 jobs` (top-right); `filter_light_360` same `1 jobs`. `selected-wide_1280` preview pane: dossier `JC-1043 / Sara / Civic - DEF 9012 / Total AED 899.50` + filled button `→ Open register`.
- **Laws:** U13: "every label is plain words a new employee understands in 3 seconds." C11: "Sentence case… ICU plural for counts." `1 jobs` is ungrammatical (should be `1 job`); zero failure would be silent but singular is wrong in two frames. `Open register` when already IN the register (route pushes `jobCardDetail` audit) misnames the destination — new employee expects register, gets audit. Should be `Open job / Open audit`.
- Technician empty (`after-technician-jobs/empty`) correctly uses `No assigned jobs / There are no jobs… / Refresh`; owner register has no such plural care. **GATES (U13).**

### D8 — MERIT-ONLY (NON-GATING BUT SCORED): skeleton/state/consistency gaps
- **Loading mismatch:** `loading_light_360` renders a 7-row TABLE skeleton (5-col grey bars) on a 360px phone, but the loaded phone layout is CARDS (`AppRecordRow`), not a table. C10/C14: "skeleton [must] mimic the final layout (same radii, heights, gaps)." Table skeleton ≠ card layout. Non-gating (no U/C16 cap clause), but Airbnb §6 deduction.
- **Empty inconsistency:** `empty_light_360` = icon + `No job cards found.` with NO action; sibling `technician empty` = icon + title + sentence + filled `Refresh`. U9 same-element-same-place + U10 feedback (no retry path on owner empty; provider has no error branch per brief — pinned, but empty offers no reload either). Non-gating per brief sanction (honest empty, nothing to create), filed for family alignment.
- **Sort unreachable on compact:** wide table has sortable `Job/Plate/Customer/Total` headers (`idle-wide`); compact cards expose NO sort control — phone users cannot re-sort without going wide. Brief tap table claims "column tap 1" universally, but pixels prove no phone affordance. U0 hunting concern; filed as merit deduction (brief pins sort to wide table, deviation C), not an additional cap beyond D1–D7.

## Tap walkthrough (BEFORE→AFTER, per brief + migration)

BEFORE (brief, verified from code): open register 1 (drill) · find ≤1 + keystrokes (+scroll; sort 1) · compact open 1 · wide select+Open 2 · clear/re-sort 1.
AFTER (pixels + code attribution from prior rounds, unrebutted): open ≤1 ✓ · find identical seats ✓ (but wrong pattern per D1) · compact open 1 ✓ · wide select+Open 2 ✓ (but mislabeled per D7) · clear 1 (`search` X, `filter` Clear/re-tap) ✓ · re-sort 1 on wide only (absent on compact per D8). **No budget regresses, but D1/D7/D8 pattern/label/reachability defects ride the same taps.**

## Consistency cross-check (cited sibling afters actually opened)

- **Owner home** (`home_360`): header search icons present + `Synced` permanent pill + ALL-CAPS `REVENUE / MARGIN / BAY OCCU…` overlines + truncated deltas (`vs last we…`). This screen fixes caps (D-verified) but keeps inline search — opposite search seats (U9 breach, see D1). Home's `Synced` is itself a C16 permanent-pill hit; this screen correctly omits it.
- **Technician jobs** (`idle_360`): vehicle-first hierarchy (`Nissan Yaris → JC-102 → XYZ 5678 → tasks`), Title Case pills (`In Progress / Delayed / Pending`), counts inside rail (`All 3 / Pending 1`). Owner is ID-chip-first, sentence-case, counts split (bar `3 jobs` + rail zeros). Hierarchy + rail grammar diverge (D3, D7). Technician empty HAS `Refresh` CTA; owner empty has none (D8).
- Contact-sheet staleness (`phase-owner-cards-light.png` shows caps both sides) must be regenerated — review artifact, not a screen defect.

## Airbnb rubric (ONLY after defects above), /16, pass ≥12

| # | Criterion | Score | Why |
|---|---|---|---|
| 1 | One task per screen | 1/2 | Find→open coherent, but inline search pushes content + no sheet/recents (D1) |
| 2 | Headline-first hierarchy | 0/2 | ID-chip first, status last (D3); ref-first contradicts "IDs are small meta" |
| 3 | Whitespace, no boxes | 0/2 | Light borders + card-in-card + wrapper band (D2) |
| 4 | Sheets for secondary | 1/2 | Wide preview pane OK; filters are cut rail, no `Show N results` sheet (D5) |
| 5 | Sticky CTA | 1/2 | Correctly absent on compact, but wide CTA mislabeled `Open register` (D7) |
| 6 | Section structure | 1/2 | Rail zeros clutter, sort absent on compact, skeleton mismatched (D5/D8) |
| 7 | Plain copy | 1/2 | `1 jobs`, `Open register`, `All active` incl. Completed (D6/D7) |
| 8 | Single primary action | 1/2 | Compact 0 / wide 1 correct count, but `All` + `QC` + `Clear` triple-blue accents compete |
| **Merit** | | **6/16** | |
| **C16 cap** | any hard-reject → max 10 | **caps at 10** | D1 search, D2 borders/card-in-card, D3 hierarchy |
| **C17 cap** | any U-law → max 8 | **caps at 8** | D1 U1/U9, D2 U12, D3 U0, D4 U10, D5 U5, D6 U8, D7 U13 |
| **Final** | | **6/16 — FAIL** | Merit 6, capped to 6 (below both caps). |

Seven gating defects (D1–D7 each independently gate); D8 merit-only. UPPERCASE caps verified fixed and NOT counted. Stale contact sheet excluded from scoring.

## Answers

- **First-time user in 3s?** Can type or tap a card, but must decode `JC-1042` before `Ahmed/Camry`, wonders why `Completed` is under "active," reads `1 jobs`, and taps `Open register` to leave the register. Task completes despite the copy, not because of it.
- **What would an Airbnb designer reject?** Inline pushed search instead of a pill→sheet (D1); bordered card-in-card on light (D2); ID-first hierarchy (D3); RTL currency break (D4); mid-word rail cuts (D5); completed-under-active (D6); `1 jobs` + `Open register` (D7). Fix in that order.

---

# ROUND-2 VERDICT (fresh-eyes re-walk, 2026-10-22) — PASS, 15/16, ZERO gating

**Role:** Reviewer did NOT author round-2 fixes. Worktree is on `ui/list-ops`; no checkout/commit/push/merge performed; `71983229` untouched. Read-only except this appendix. Fix claims checked against CURRENT on-disk pixels: `docs/ui-redesign/baseline/after-owner-job-cards/` (11 frames, mtimes 2026-10-22 17:54 UTC+3) + regenerated `docs/ui-redesign/baseline/phase-owner-cards-light.png` + `LOGIC_FOLLOWUPS.md` #12 + migration `owner-job-cards-list-test-migration.md`. Test-count / byte-stable claims (19/19, 11/11) are recorded as builder claims, NOT independently re-executed (read-only); no evidence in pixels contradicts them.

## D1–D7 re-verification (each against current pixels)

- **D1 search → FIXED.** `idle_light_360`: header shows back + `Job register` + magnifier icon + `3 jobs` pill; ZERO inline `AppSearchField` in the page at any size (360/320/1.3x/dark/ar/wide all confirm). `search_light_360`: bottom sheet (`Job register` + field `sara` + X + result row `Sara / Civic · DEF 9012 / AED 899.50 / JC-1043`) overlays a dimmed list filtered to 1; count pill reads `1 job`. Exactly one search path: header icon → sheet. No pushing layout — sheet is modal. **Gate lifted.**
- **D2 borders/card-in-card/U12 band → FIXED.** `idle_light_360`: three freestanding cards on one grey page background, soft shadow, no visible borders, no outer wrapper frame. Same in 320/1.3x/search/filter/dark (dark keeps hairline border, which C16 permits). `empty` is now frameless (`No job cards found.` on page background, no outer frame/inner card). Contact sheet AFTER-right confirms the same. **Gate lifted.**
- **D3 hierarchy → FIXED.** Card order in every compact frame: customer title (`Ahmed`) → status pill (`In progress`) → `Camry · ABC 1234` → `AED 2,450.00` → `JC-1042` small mono LAST. Wide table reordered Customer / Plate / Job(small) / Total / Status with JC-1042 as small cell. Status is now the decision signal in position 2; ID is meta. **Gate lifted.**
- **D4 RTL money → FIXED.** `idle_light_ar_360`: card amounts render `AED 2,450.00` / `AED 899.50` / `AED 0.00` — Latin `AED` leading, digits intact, tabular; refs `JC-1042/43/44` and plates `ABC 1234 / DEF 9012 / XYZ 1111` LTR-intact. Zero `E.E` glyphs in any AR card. LTR-lock holds. **Gate lifted.**
- **D5 truncation → FIXED.** `idle_light_320`: rail WRAPS 3+2+1 (`All / Intake 0 / Inspection 0 / WIP 1 / QC 1 / Ready 1 / Invoiced 0`), every label whole — `Invoiced 0` fully visible, no `WI`/`Ir` severing. `filter_360`: wrapped rail + inline `Clear`, `Sara` card whole. U5 word-boundary satisfied on the smallest viewport. **Gate lifted.**
- **D6 completed-under-active → FIXED (U8 procedure).** Pixels still show `Completed` (JC-1044) under `All active workshop jobs` — intentionally unchanged per U8 — but `LOGIC_FOLLOWUPS.md` #12 now exists with feed (`jobCardsProvider` status-agnostic server list), evidence (idle_360 card 3 + dark/320/1.3x/wide row 3), and proposed owner (exclude terminal statuses or rename subtitle; no silent filtering). That is exactly what round-1 D6 demanded ("log it in LOGIC_FOLLOWUPS.md"). **Gate lifted.**
- **D7 copy → FIXED.** `search/filter_360` pills read `1 job` (ICU singular); `0 jobs` / `3 jobs` elsewhere correct. `selected-wide_1280` preview dossier (Sara → pill → Civic·DEF 9012 → Total → JC-1043) + filled button `→ Open job` (was `Open register`). **Gate lifted.**

## Regression walk (other laws)

No new caps: sentence case everywhere (`In progress / Quality check / Completed`, `Job register`); no ALL-CAPS on this surface; loading skeleton now mimics cards (3 rounded card blanks, not the old 7-row table); wide `Search CtrlK` trigger opens the same sheet path (family-consistent); subtitle ellipsis at 320/1.3x is standard truncation, not a mid-word rail cut; dark borders permitted.

## Rubric (round-2, /16)

| # | Criterion | Score | Why |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Header icon → sheet; zero inline fields; modal, no push |
| 2 | Headline-first hierarchy | 2/2 | Customer/vehicle title first, status second, JC small last |
| 3 | Whitespace, no boxes | 2/2 | Borderless light cards, one background, no wrapper |
| 4 | Sheets for secondary | 2/2 | Search is a full sheet; filter is a wrapping rail + Clear |
| 5 | Sticky CTA | 2/2 | Absent compact; wide `Open job` correctly labeled |
| 6 | Section structure | 1/2 | Rail wraps, skeleton matches, empty frameless; −1: wide sort headers show no visible sort affordance (contract pinned in tests, undiscoverable in pixels; compact sort absent by sanctioned deviation C) |
| 7 | Plain copy | 2/2 | `1 job`, `Open job`, counts correct; subtitle covered by LOGIC #12 |
| 8 | Single primary action | 2/2 | Compact 0 / wide 1; no competing accents |
| **Merit** | | **15/16** | |
| **C16 cap** | none violated | no cap | Search/borders/hierarchy/caps all compliant |
| **C17 cap** | none violated | no cap | U0/U1/U5/U8(logged)/U9/U10/U12/U13 all satisfied |
| **Final** | | **15/16 — PASS** | ≥12 with no caps tripped |

**Remaining gating defects: ZERO.** Merit-only notes (non-gating, no cap): wide sort affordance invisible; empty state offers no retry/refresh (sanctioned honest-empty); `Completed` still renders under "active" pending backend/product decision on LOGIC #12.

**Answers.** First-time user in 3s: reads `Ahmed → In progress → Camry → AED → JC-1042`, taps header magnifier for search, reads `1 job` / `Open job` without decoding. Airbnb designer: no further hard-reject on this surface; only polish is sort discoverability.
