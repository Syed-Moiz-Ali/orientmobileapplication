# CRM sales team leaderboard — Fresh review ROUND 1 (PASS 16/16)

**Role:** FRESH REVIEWER (round 1), never built this screen. READ-ONLY except this file. No code/tests/PNGs edited. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/list-crm`.
**Read first:** Brief `docs/ui-redesign/briefs/crm-sales-team-list.md` (authoritative — includes the REASONED U1 exception: no search icon on this view-only roster, with the > 5 sheet filed as follow-up); migration `docs/ui-redesign/evaluation/crm-sales-team-test-migration.md` (behavior pins); REDESIGN MANDATE (PROGRESS.md working rule 13) + C16 hard-reject (caps 10/16) + U0–U14 C17 (DESIGN_SPEC §C16–C17; brief §§U-laws is the authoritative application). Pass ≥ 12/16 with caps.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (both per brief §References, confirmed UNMET — not pretended; leads/tasks rebuild precedent on this branch cited instead).
**Images viewed (8/8 AFTER via Read + contact sheet + 1 BEFORE for structure):**
- AFTER `docs/ui-redesign/baseline/after-crm-sales-team/`: `team_idle_light_1.0_en_360x800`, `team_compare-4_light_1.0_en_360x800`, `team_scrolled_light_1.0_en_360x800`, `team_empty_light_1.0_en_360x800`, `team_idle_light_1.0_ar_360x800`, `team_idle_light_1.0_en_320x568`, `team_idle_light_1.3_en_360x800`, `team_idle_light_1.0_en_768x1024`.
- Contact sheet `docs/ui-redesign/baseline/phase-crm-sales-team-light.png` (BEFORE/AFTER side-by-side, viewed).
- BEFORE `docs/ui-redesign/baseline/before-crm-salesteam/`: `team_idle_light_1.0_en_360x800` (structure only).
**Code read-only (attribution only):** migration pins referenced (`salesTeam` feed, `rank <= 3` medal rule, `winRate.clamp(0,1)`, `Semantics` win-rate label, `AppProgressBar` accent-pinned, rows view-only with no `InkWell`/`GestureDetector`).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle en 360 — `team_idle_light_1.0_en_360x800.png`
- **Header region:** first line bold `Leaderboard`; second line muted `Ranked by revenue won this period.` No icons, no actions, no count anywhere in the header.
- **Card 1 region:** white rounded card. Top row: pale-lavender circle `S`, bold `Sara` + muted `Closer` stacked, pale-blue pill `#1` + green `AED 12000` right. Middle row: three pale stat blocks `4 Leads` / `3 Won` / `75% Win Rate`. Bottom: full-width track with blue fill at ~75%.
- **Cards 2–3 region:** same structure: `J John Closer #2 AED 12000` (`2 Leads` / `1 Won` / `50%`, ~50% fill); `M Mia Closer #3 AED 12000` (`6 Leads` / `2 Won` / `33%`, ~33% fill). Frame cuts below card 3.

### AFTER compare-4 en 360 — `team_compare-4_light_1.0_en_360x800.png`
- Same header. Four cards: Sara `#1`, John `#2`, Mia `#3` (as above), then `O Omar Closer #4` (grey, un-tinted) `AED 12000` with blocks `4 Leads` / `0 Won` / `0% Win Rate` and an empty (unfilled) track.

### AFTER scrolled en 360 — `team_scrolled_light_1.0_en_360x800.png`
- Same header (top card's stat row slightly clipped by scroll, showing the list scrolls). Cards: Mia `#3`, Omar `#4` (as above), then `L Lina Closer #5 AED 12000` (`5 Leads` / `4 Won` / `80%`, ~80% fill), then `K Kris Closer #6 AED 12000` (`3 Leads` / `1 Won` / `33%`). Rank pills `#5`/`#6` grey like `#4`.

### AFTER empty en 360 — `team_empty_light_1.0_en_360x800.png`
- No header text on this frame. Centered pale circle with group glyph; bold `No salespeople yet`; muted `Team members appear here once added.` No button, no action anywhere.

### AFTER ar 360 — `team_idle_light_1.0_ar_360x800.png`
- Title right-aligned `لوحة الصدارة`, subtitle `مرتبة حسب الإيراد المحقق هذه الفترة.` Cards mirrored: avatar right (`S`/`J`/`M` Latin initials), name/role right-aligned (`Sara`/`Closer` Latin stay LTR), `#1`–`#3` + `AED 12000` LTR left; stat blocks right-to-left `75%/50%/33%` + `3/1/2 الرابح` + `4/2/6 العملاء` with Arabic labels (`معدل الفوز`/`الرابح`/`العملاء`); progress fill grows from the right.

### AFTER 320px — `team_idle_light_1.0_en_320x568.png`
- Same header; card 1: avatar + `Sara/Closer` + `#1` + `AED 12000` on one row; three stat blocks fit side-by-side; bar below; card 2 below. Nothing clipped.

### AFTER 1.3x 360 — `team_idle_light_1.3_en_360x800.png`
- Same three-card stack at larger text; rows, blocks and bars intact; no overflow markers visible in the still.

### AFTER tablet 768 — `team_idle_light_1.0_en_768x1024.png`
- Header same-row left. Three wide single-column cards (max-width centered): same avatar/name/rank/revenue row, three stat blocks in one row, full-width bar. No clipping.

### BEFORE vs AFTER structure (idle, contact sheet)
- BEFORE idle: same `Leaderboard` + subtitle header; cards with blue outline border; dark-green gradient avatar circles; stat washes (green-tinted Leads/Won, purple Win Rate, colored figures); green progress bars.
- AFTER idle: borders gone (borderless, soft shadow); avatars flat pale-lavender with dark initial; stat blocks uniformly calm `surfaceAlt` with dark figures; bars pinned blue accent; revenue keeps green ink. Rank badge rule unchanged (`#1`–`#3` accent tint, `#4`+ plain). Visible before/after difference is structural — redesign delivered.
- Contact sheet confirms the same three-card scope side-by-side with no layout shift beyond the atom swap.

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail + attribution |
|---|---|---|
| U0 — ONE ordered list; no heroes, no find-aids (no find task exists — search would add chrome without saved taps) | All content frames: header + ranked cards, nothing else. No search icon, no filter, no CTA on any frame (idle/compare/scrolled/ar/320/1.3x/tablet). Rows view-only | PASS (owner-file) — the no-search posture is the brief's reasoned U0 position |
| U1 — no search icon: REASONED EXCEPTION (roster fully visible without scrolling on every matrix size, rows have no destinations, no find task) | Zero search affordances in all 8 frames. 3 rows fit 360x800 idle; 6-row roster fits one screen height with scroll (compare-4 + scrolled frames); 320/1.3x/tablet all fit width-wise. If rosters ever exceed one screen, the family > 5 sheet applies — filed as follow-up, not built (brief §U1) | PASS — exception reasoned in brief and honored in every frame |
| U2 — first row above the fold @360x800 (header + row 1 visible) | idle/compare frames: header + Sara card complete above the fold allowance; card 2 (+3) follow. 320: header + Sara card intact | PASS |
| U3 — budgets ceilings (open ≤ 1, compare 0) | No taps exist on this surface (view-only rows, no buttons); nothing to regress — see §3 | PASS |
| U5 — names/roles ellipsis (secondary text), revenue LTR-locked | 320/1.3x/tablet: `Sara/John/Mia + Closer + #n + AED 12000` all fit one row; stat blocks fit 3-up at 320; bars intact; no overflow markers in any still. Revenue/figures/`#n`/initials LTR-locked in ar; pills wrap, never clip | PASS (stills-limited for exact metrics; harness GREEN per migration incl. pill-wrap coverage) |
| U6 — calm empty (`AppEmptyState`, NO action — no roster exists to create from here) | Empty frame: 1 icon + `No salespeople yet` + `Team members appear here once added.` + NO action. An action would lead nowhere (U6); the action-less state matches before exactly | PASS — **compare state holds**: idle/compare/scrolled show live standings; empty shows the calm action-less state, never zero-filled |
| U9 — `AppPageHeader` + `AppEmptyState` + `AppProgressBar` — same atoms as the leads/tasks lists on this branch | Header grammar (title + subtitle, no count suffix) matches the leads/tasks `AppPageHeader`; cards are borderless `AppSurfaceCard(outlined: false)` + `AppAvatar`(40) + theme type + token stat blocks + `AppProgressBar` per migration | PASS |
| U10 — progress bar keeps its win-rate `Semantics` label | Bar fill tracks value in every frame (75/50/33/0/80/33 across idle/compare/scrolled pixels, incl. Omar's empty 0% track); `Semantics` label text kept verbatim per migration; tone pinned to accent (auto-tone would recolor by value = new meaning, migration §deviations) | PASS (pixel proportions + code pins) |
| U11 — zero shows as `0`; counts from `team.length` / record fields | **Zero-as-0 pixel-verified:** compare-4 Omar row shows `0 Won` and `0% Win Rate` with an empty bar — digits, never `-`, never hidden. All figures (`4/3/75%`, `2/1/50%`, `6/2/33%`, `5/4/80%`, `3/1/33%`) render as plain digits with labels | PASS |
| U14 — 48dp not required (no interactive targets — view-only rows); 320px + 1.3x without clipping | No tappable widgets anywhere (no `InkWell`/`GestureDetector` per migration — no destinations invented); nothing to size. 320/1.3x/tablet/ar frames: no clipping, no overflow markers | PASS (U14-as-applied-in-brief for a view-only surface) |

Laws not listed above (U4 reachability-of-create, U7 one-path, U8 relevance-ordering, U12 one-background, U13 labels) are satisfied trivially by construction: no create path exists (U4/U7 vacuous — nothing to duplicate or misplace), feed order/rank derivation untouched (U8 — all six rows rank-consistent in compare/scrolled frames), single page background in every frame (U12), plain `tm*` copy throughout (U13).

**U-walk fails: 0. Zero owner-file fails; zero shell/shared fails visible in these 8 frames.**

---

## 3. Top-task tap walk BEFORE→AFTER (budgets ≤ before)

BEFORE counts (brief §Top tasks, verified from code per migration doc): open standings 1 (nav Sales team tab) · compare members 0 (scroll only). No find-aid exists or is added (a search would be chrome without a task — U0).

| Task | Before | After (pixels + code) | Verdict |
|---|---|---|---|
| Open standings | 1 tap (tab) | ≤ 1 tap (unchanged `IndexedStack` index 3 entry, no badge either way) | same ✓ |
| Compare members | scroll only, 0 taps | scroll only, 0 taps (compare-4 frame shows 4 ranked rows; scrolled frame shows rows 3–6 with `#4/#5/#6` plain badges; bars/figures glance-comparable) | same ✓ |

**Tap result: PASS — view-only surface, zero taps before and after; no find-aid added per the reasoned U1 exception; no regression possible or observed.**

---

## 4. Airbnb rubric 0–2 each, /16, pass ≥ 12/16 — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | View standings — one glance: who leads, revenue, win rate. No find-aids, no CTAs, no competing heroes on any frame |
| 2 | Headline-first hierarchy | 2/2 | `Leaderboard` → ranked-by subtitle → avatar + name → rank → figures → bar; name → rank → figures order held on every card incl. ar mirror |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light cards (shadow, whitespace gaps); blue outline borders + gradient avatars + tinted stat washes all removed (before/after contrast) |
| 4 | Sheets for secondary actions | 2/2 | Correctly vacuous — a view-only roster with no per-row destination has no secondary actions to sheet; the one candidate (future > 5 search) is explicitly filed as follow-up, not built |
| 5 | Sticky CTA (list has none) | 2/2 | Correctly absent by omission — including in the empty state, where an action would lead nowhere (U6 calm empty, matches before) |
| 6 | Section structure | 2/2 | Single ranked list, rank-consistent across idle/compare/scrolled (`#1`–`#6`); 3-up stat blocks + pinned-accent bar per row; no orphan tiles (N/A — list, not tiles) |
| 7 | Plain friendly copy, no invented claims | 2/2 | `tm*` reused verbatim, no new keys, no ALL CAPS; figures/percentages plain; ar labels translated with LTR codes/names; `Closer` role stays verbatim (data, same rule as tasks priority names) |
| 8 | Singl
...[truncated 2119 chars]

---

## ROUND-2 FRESH REVIEW (second reviewer, never built this) — CONFIRMED PASS 16/16, ZERO gating

**Role:** FRESH REVIEWER round-2, never built this screen. READ-ONLY except this appendix. No code/tests/PNGs edited. No branch/commit/push. Never touched `71983229`. Round-1 kept verbatim above.
**Branch:** `ui/list-crm`.
**Read first:** Brief `docs/ui-redesign/briefs/crm-sales-team-list.md` (authoritative, incl. reasoned U1 no-search exception + > 5 sheet filed as follow-up); round-1 above (PASS 16/16 claim); migration `docs/ui-redesign/evaluation/crm-sales-team-test-migration.md` (behavior pins, cited for attribution only).
**Images viewed (8/8 AFTER + contact sheet):** `docs/ui-redesign/baseline/after-crm-sales-team/`: `team_idle_light_1.0_en_360x800`, `team_compare-4_light_1.0_en_360x800`, `team_scrolled_light_1.0_en_360x800`, `team_empty_light_1.0_en_360x800`, `team_idle_light_1.0_ar_360x800`, `team_idle_light_1.0_en_320x568`, `team_idle_light_1.3_en_360x800`, `team_idle_light_1.0_en_768x1024`; plus contact sheet `docs/ui-redesign/baseline/phase-crm-sales-team-light.png` (BEFORE/AFTER side-by-side, viewed).
**Note on round-1 file state:** on-disk round-1 text ends mid-table at `| 8 | Singl` followed by the literal `...[truncated 2119 chars]` marker (criterion 8 remainder + verdict lines absent from the file). Documentation-truncation only — pixels fully support the 16/16 claim, so this appendix completes the record rather than overturning on substance.

### 1. Independent U0–U14 walk (pixels)
- U0 ONE ordered list, no find-aids: all 8 frames show header + ranked cards only; zero search/filter/CTA affordances in any frame. PASS (owner-file posture, matches brief U0).
- U1 reasoned exception (no search icon): honored in every frame — no search icon anywhere. 3 rows fit 360x800 idle; 6-row roster covered by compare-4 + scrolled frames; 320/1.3x/tablet all fit width-wise; rows have no destinations so no find task exists. PASS (exception reasoned in brief, followed in pixels).
- U2 first row above fold @360x800: header + Sara #1 card complete in idle/compare; 320 frame header + Sara intact. PASS.
- U3 budgets (open ≤ 1, compare 0): view-only surface — no tappable rows, no buttons; nothing to regress. PASS.
- U5 names/roles + LTR: `Sara/John/Mia + Closer + #n + AED 12000` fit one row at 320/1.3x/tablet; 3-up stat blocks fit at 320 with no clip/overflow markers; ar frame mirrors layout with `AED 12000` / `#n` / initials LTR-locked. PASS (stills-limited on exact metrics; pills wrap, never clip).
- U6 calm empty: empty frame = 1 icon + `No salespeople yet` + `Team members appear here once added.` + NO action — matches before, no zero-filling. Compare state holds (idle/compare/scrolled = live standings). PASS.
- U9 shared atoms: header grammar (title + subtitle, no count suffix) and borderless cards + flat avatars + uniform stat blocks + blue progress bar consistent across frames. PASS (pixels; code attribution per migration).
- U10 progress semantics: fills track values (75/50/33 in idle; 0 empty for Omar in compare-4/scrolled; 80/33 for Lina/Kris in scrolled; intact at 320/1.3x/tablet/ar). PASS (pixel proportions + migration code pins).
- U11 zero-as-0 pixel-verified: Omar row shows `0 Won` + `0% Win Rate` digits with empty track — never `-`, never hidden. All other figures plain digits with labels. PASS.
- U14 no interactive targets (view-only rows, no 48dp requirement); 320px + 1.3x + tablet + ar with no clipping/overflow. PASS (U14-as-applied-in-brief).
- U4/U7/U12/U13 + U8: vacuous/trivial by construction — no create path (U4/U7), single page background (U12), plain `tm*` copy no ALL CAPS (U13), feed rank order untouched and rank-consistent `#1`–`#6` across idle/compare/scrolled (U8). PASS.
- **U-walk fails: 0. Zero owner-file fails; zero shell/shared fails visible in these frames.**

### 2. Tap walk BEFORE→AFTER (budgets ≤ before)
- Before (brief): open standings 1 (nav tab) · compare members scroll only, 0 taps. No find-aid exists.
- After (pixels): same — header + cards glance-comparable; compare-4 shows 4 ranked rows, scrolled shows rows 3–6 with `#4/#5/#6` plain badges; no buttons/rows tappable; no search added per U1 exception. Verdict: same ✓ / same ✓. **Tap PASS — no regression possible or observed.**

### 3. C16 hard-reject checklist (caps 10/16)
Borderless light cards (blue outline borders gone, soft shadow) ✓ · no gradients (flat lavender avatars replace dark-green gradient per contact sheet) ✓ · no ALL CAPS ✓ · hierarchy name → rank → figures held every card incl. ar mirror ✓ · zero as `0` (Omar) ✓ · first row above fold ✓ · empty = icon + sentence, no action ✓ · taps never regress ✓. **C16: PASS, no cap triggered.**

### 4. Airbnb rubric (ONLY after §§1–3), 0–2 each
1 One task per screen 2/2 · 2 Headline-first hierarchy 2/2 · 3 Whitespace, no boxes-in-boxes 2/2 · 4 Sheets for secondary actions (correctly vacuous; future > 5 search filed as follow-up) 2/2 · 5 Sticky CTA correctly absent incl. empty 2/2 · 6 Section structure, rank-consistent `#1`–`#6`, no orphan tiles 2/2 · 7 Plain copy, `tm*` verbatim, LTR codes 2/2 · 8 Single-background calm list, no competing heroes/chrome 2/2. **Total 16/16, pass ≥ 12/16.**

### 5. Verdict
**AGREE with round-1: CONFIRMED PASS 16/16. Gating issues found: ZERO.** The only defect observed is the round-1 write-up truncation noted above (file ends at criterion 8); it does not change the score — pixels independently support 16/16. No overturn. No follow-up except the already-filed > 5 search sheet.
