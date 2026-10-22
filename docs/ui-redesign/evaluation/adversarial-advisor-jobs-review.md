# Adversarial Review — Advisor Jobs List (GROUP-B `ui/list-staff-jobs`)

**Verdict: FAIL — 6/16 (capped by C17 at 8/16; C16 hard-reject cap 10/16 also tripped).**
**Branch:** `ui/list-staff-jobs` worktree `C:\Users\sanja\AppData\Local\Temp\opencode\wt-staff`
**Brief:** `docs/ui-redesign/briefs/advisor-jobs-list.md` (references UNMET — proceeded on vehicles precedent, as brief records)
**Spec:** `docs/ui-redesign/DESIGN_SPEC.md` C16 + C17 (U0–U14)
**Images inspected (all viewed with Read):**
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_1.0_ar_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_1.0_en_320x568.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_1.3_en_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_empty_en_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_filter_en_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_search_en_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_1.0_en_1280x800.png`
- `docs/ui-redesign/baseline/phase-advisor-jobs-light.png` (BEFORE en 360x800 left vs AFTER en 360x800 right)

**Assumption per instruction:** NOT Airbnb-level. Hunted aggressively. 7 defects, ranked severe-first. Every defect marks GATES explicitly.

---

## Ranked defects (most severe first)

### D1 — Search icon NOT top-right header; floats mid-page left, wastes fold (MOST SEVERE)
- **Evidence:**
  - `jobs_1.0_en_360x800.png` top third: header is `Workshop Job Cards` + `6 job cards` subtitle, then ~80px blank band with a lone `🔍` left-aligned at x≈100,y≈200. No icon at top-right.
  - Same in `jobs_1.0_en_320x568.png`, `jobs_1.3_en_360x800.png`, `jobs_empty_en_360x800.png`, `jobs_filter_en_360x800.png` (all compact show the orphan left magnifier).
  - Counter-proof it *should* be top-right: `jobs_1.0_en_1280x800.png` wide shows `🔍` correctly at top-right of header. Compact diverged from wide + from wireframe.
  - `phase-advisor-jobs-light.png` right panel confirms the gap: title → subtitle → magnifier row → rail. Wireframe in brief §ASCII demands `| Workshop Job Cards [🔍] |` same row.
- **Law / criterion:**
  - U1: "search ICON in the header at the TOP RIGHT" — violated (wrong row, wrong side).
  - U9 consistency: "same placement as advisor home, supervisor floor, technician today, owner home" — violated (those are top-right; this is mid-page left).
  - C16 hard-reject: "Search = one top icon → full search sheet (never inline mid-page)" — placement clause violated; the lone icon *looks* like a leftover inline field stripped of its box.
  - Brief §REMOVED: "`AppPageHeader` + `AppIconButton` top-right ONLY when >5" — not implemented on compact.
- **Tap walkthrough hit:** Task 2 (find job via search): tab (1) + hunt for misplaced icon (cognitive +1, scroll risk) + type + result tap = over budget in effort even if tap count nominally ≤3. U0 also hit.
- **GATES? YES — U1 + U9 are U-laws → C17 caps at 8/16. C16 search-placement also tripped (cap 10/16).**

### D2 — First real job card pushed down; header chrome + dead search gap break above-fold rule
- **Evidence:**
  - `jobs_1.0_en_360x800.png`: vertical stack before first job card = title (~40px) + subtitle + dead search band (~80px) + rail (~64px) + `Sort` label + full-width `Newest first` dropdown (~64px) + `Assigned intake queue` card (~200px). Zara·Corolla card starts at ~65% of frame. Second card (Ahmed) barely starts; Layla only peeking as clipped text at bottom. No bottom-nav in crop means even this required scrolling to capture.
  - `jobs_1.0_en_320x568.png` worse: same stack consumes >70% of 568px height; only intake + Zara visible.
  - Wireframe demands: title+count one row, rail+sort compact rows, then intake, then Ahmed card + Layla PEEKING above nav at 360x800. Actual has an extra blank row + oversize sort + oversize intake padding.
- **Law / criterion:**
  - U2: "first actionable item visible above fold at 360x800 idle" — first *job* card is the primary content (intake is secondary); it is marginal/below fold on small heights.
  - C16 hard-reject: "ABOVE-THE-FOLD RULE: first item visible above bottom nav, idle" — violated.
  - U0: user must scroll past secondary chrome to reach primary task.
  - Brief U2: "Compact header stays slim; nothing pushes first card below fold — anything that does needs written reason" — no reason logged; the dead search band is the culprit.
- **GATES? YES — U2 is U-law (cap 8/16); C16 fold rule independently caps at 10/16.**

### D3 — Filter rail last visible chip cut mid-word, no clean peek
- **Evidence:**
  - `jobs_1.0_en_360x800.png` rail right edge: chip reads `Approve` clipped at frame edge (the `d` cut, `1` count not visible). Same in `jobs_1.0_en_320x568.png` (`Appr` clipped), `jobs_filter_en_360x800.png` is the only one surviving because filter=Inspection hides overflow, but default state fails.
  - `jobs_1.0_ar_360x800.png` mirrored: left edge chip clipped mid-glyph.
  - Brief requires "rail scrolls with peek"; DESIGN_SPEC C4/U5 requires clean peek where cut item's icon + label start are clearly visible.
- **Law / criterion:**
  - U5: "never a label cut mid-word; rows either fit completely or scroll with clean peek" — violated.
  - U14 / C4 spacing: rail padding + 320px contract violated.
  - Sibling consistency: technician-Jobs precedent keeps rail with counts fully legible; this regresses it.
- **GATES? YES — U5 is U-law (cap 8/16).**

### D4 — 1.3x scale truncates date mid-string with ellipsis; intake title wraps to 3 lines
- **Evidence:**
  - `jobs_1.3_en_360x800.png` intake row center: `Nadia · 2026-1…` — date cut mid-number with `…`. Brief U4/U5 mandates verbatim dates, LTR-locked, never truncated; compression order is pill+time first, but date must not be cut mid-token.
  - Same image: `Oil change · Patrol` wraps to 2 lines + `Assigned intake queue` wraps to 2 lines, pushing Zara card further down; `Ahmed · Camry` card intact but intake eats fold.
  - `jobs_1.0_en_360x800.png` at 1.0x shows full `2026-10-21`, proving 1.3x reflow was not handled.
- **Law / criterion:**
  - U5: no truncation of primary text; time/date is primary meta on this screen.
  - U14 / C12: "text scale 1.3x with no overflow / reflow, actions never clip" — violated (ellipsis on date = overflow handling by truncation).
  - U11: readable numbers — `2026-1…` is unreadable.
- **GATES? YES — U5 + U14 are U-laws (cap 8/16).**

### D5 — Compact card hierarchy broken: no chevron, `…` overflow tiny target, `Pending sync` masquerades as time
- **Evidence:**
  - `jobs_1.0_en_360x800.png` Zara card: rows = `Zara · Corolla` title → `Pending` chip → `DXB 111 | Pending sync` meta row → `JC-2001` mono. Right side shows `…` (three dots, ~20px) vertically centered, no `>` chevron. Same on Ahmed card (`ABC 1234 | 10:30 AM` + `JC-2002` + `…`).
  - Brief binding: title → ONE chip → meta (time) → job id small LTR mono + chevron; tap=Open (frequent action direct); overflow (48dp) → preview sheet.
  - `…` is not a directional chevron, fails U10 directional contract (must mirror via DirectionalIcon in RTL; dots do not), and visual target is far below 48dp (tap walkthrough Task 5 quick-preview therefore risks miss-taps).
  - Zara (local unsynced) shows `Pending sync` where `Time` belongs; wide `jobs_1.0_en_1280x800.png` table correctly separates `Time` column (`Pending sync` vs `10:30 AM`), proving compact conflates status-sync with time.
- **Law / criterion:**
  - U0 card-hierarchy binding (brief §U0): violated.
  - C16 hard-reject: "Hierarchy inside cards: recognizable title → status pill → meta (IDs are meta)" + "max 3 levels per card" — compact uses 4 visual rows + ambiguous affordance.
  - U4 reachability + U14 48dp: `…` fails size/clarity.
  - U9: wide uses table + preview correctly; compact invents a different affordance.
- **GATES? YES — U0 is U-law (cap 8/16).**

### D6 — Empty state keeps dead rail + sort with zero counts (dead affordances, uncalm empty)
- **Evidence:**
  - `jobs_empty_en_360x800.png`: header `No job cards` + rail `All | Intake 0 | Inspection 0 | Approv…` + `Sort / Newest first` dropdown + centered `No job cards yet / New job cards will appear… / [New job card]`.
  - Tapping `Intake 0` / changing sort with zero items does nothing — dead controls. Brief U6: honest empty = EXACTLY one icon + one sentence + one New-job-card action; rail/sort should collapse when register empty (vehicles precedent hides filters on empty).
- **Law / criterion:**
  - U6 calm empty: violated (aturated chrome around calm message).
  - C16 hard-reject: "no dead affordances" + "Max ONE primary CTA per screen" + "no numbers duplicated in label and badge" — `0` repeated across chips + subtitle `No job cards` duplicates zero state.
  - U7 one path per task: Clear/filters visible with nothing to filter.
  - Tap walkthrough Task 7 (new job from empty): achievable in 2 taps but user must scroll past dead rail+sort to reach illustration/CTA on short screens.
- **GATES? YES — U6 is U-law (cap 8/16); C16 dead-affordance independently caps at 10/16.**

### D7 — Search sheet + wide preview break borderless / vocabulary / number rules; AR leaks English
- **Evidence:**
  - `jobs_search_en_360x800.png` sheet: result card has 1px light border (`Ahmed / Camry · ABC 1234 · JC-2002` in rounded box) — in LIGHT theme borders are forbidden (shadow/flat + whitespace only). Title is `Ahmed` alone (not `Ahmed · Camry` as card-hierarchy mandates); vehicle + plate + JC id crushed into one subtitle line.
  - `jobs_1.0_ar_360x800.png` Zara card meta: `Pending sync` in Latin inside otherwise Arabic card (`بالانتظار` chip + `DXB 111` + `JC-2001`); intake `Nadia · 2026-10-21` + `Oil change · Patrol` also untranslated — mixed-locale string leak.
  - `jobs_1.0_en_1280x800.png` preview pane: `Technician --` uses `--` for empty; U11 mandates zero/empty as `0` or plain words, never `-`/`--`.
- **Law / criterion:**
  - C16 hard-reject: "Cards in LIGHT theme have no borders" — search result + sort dropdown + intake inner card all show hairline borders in light.
  - U0 hierarchy: search result title ≠ recognized thing (customer+vehicle).
  - U13 new-employee / C15 localization: English `Pending sync` inside AR UI; `--` is jargon, not plain words.
  - U11 readable numbers: `--` violates "zero as 0, never -".
- **GATES? YES — U0 + U11 + U13 are U-laws (cap 8/16); C16 border rule independently caps at 10/16.**

---

## Tap walkthrough (AFTER vs budget — all ≤ budget on taps, over on effort due to D1/D2/D5)

| Task | Budget (brief) | Observed (from images + code contracts) |
|---|---|---|
| Open job card | ≤2 taps | tab + card tap = 2 taps OK, but card affordance is `…` not chevron (D5) — users hunt |
| Find via search | ≤3 + typing | tab + misplaced icon (D1) + type + result tap = 3 taps nominal, FAIL on placement/consistency |
| Filter triage | ≤2 | tab + chip = 2 OK, but clipped chip (D3) hides Approved/WIP/Ready |
| Check in booking | ≤2 | tab + Check In = 2 OK (intake card intact) |
| Quick preview | ≤2 + sheet | tab + `…` + Open = 2 + sheet OK on count, FAIL on 48dp/chevron (D5) |
| Sort | ≤3 | tab + dropdown + option = 3 OK, but dropdown full-width pushes fold (D2) |
| New from empty | ≤2 | tab + New job card = 2 OK, but dead rail/sort above it (D6) |
| Retry | ≤1 inline | not screenshot-covered; code keeps `AppBanner` + retry per brief — no verdict here |

No logic changes per brief, so predicates/sort/counts assumed intact; all failures above are presentation/chrome.

## Consistency with siblings
- Advisor home / supervisor / technician-today place search top-right; this compact header does not (D1) — breaks U9.
- Technician-Jobs keeps filter rail legible with counts; this clips the 4th chip (D3).
- Vehicles-list precedent: borderless light cards, icon+sentence+action empty, search sheet over register with >5 threshold; this keeps borders in search result/sort (D7), keeps rail+sort on empty (D6), and misplaces the search icon (D1).

## Score
- C17: multiple U-law breaches (U0, U1, U2, U5, U6, U9, U11, U13, U14) → **cap 8/16, no exceptions**.
- C16 hard-reject: search placement, borders in light, dead affordances, fold rule → **cap 10/16 independently tripped**.
- Effective cap = 8/16. Deductions for 7 ranked defects (2 structural, 2 text-scale/rail, hierarchy, empty, localization/numbers) → **6/16. FAIL. Pass requires ≥12/16.**
- To pass: move search icon to AppPageHeader top-right (compact), remove dead search band, slim sort row, fix rail peek (never mid-word cut), fix 1.3x date reflow (compress pill first, wrap don't ellipsis), restore chevron + 48dp overflow + separate Time vs Pending-sync, collapse rail/sort on empty, deborder light cards, translate `Pending sync` in AR, replace `--` with plain words.

---

## Round-2 re-verification (2026-10-22, fresh eyes — did not fix)

**Verdict: PASS — 13/16. No C17 cap, no C16 hard-reject cap tripped on core.**
**Branch/worktree:** `ui/list-staff-jobs` worktree `C:\Users\sanja\AppData\Local\Temp\opencode\wt-staff` (no checkout/switch/commit/push/merge run, `71983229` untouched)
**Spec:** `docs/ui-redesign/DESIGN_SPEC.md` C16 + U0–U14 C17; **Brief:** `docs/ui-redesign/briefs/advisor-jobs-list.md`; **References:** EMPTY (UNMET, as brief records)
**Images inspected (all CURRENT, viewed with Read):**
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_1.0_en_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_1.0_ar_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_1.0_en_320x568.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_1.3_en_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_empty_en_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_filter_en_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_search_en_360x800.png`
- `docs/ui-redesign/baseline/after-advisor-jobs/jobs_1.0_en_1280x800.png`
**Code cross-checked (read-only):** `advisor_jobs_view.dart` (header Row 220–262, `collapseChrome` 164–170/280, sync mapping 549–557, `_shownValue` 925–926), `advisor_job_card_row.dart` (sync separation 51–56, chips 91–102, trailing 176–197), `advisor_search_sheet.dart` (borderless rows 359–435, title 270).

### Fix-by-fix (fixer claimed all 7 — image evidence)

1. **Header search icon top-right same-row (plain Row, RTL-mirrored) + single path — PASS**
   - `jobs_1.0_en_360x800.png`: `Workshop Job Cards` + `6 job cards` left, search icon top-right same row, no mid-page orphan band. `jobs_1.0_ar_360x800.png`: mirrored — title right, icon top-left. Same in 320, 1.3x, filter shots. Code `Row[Expanded(title+count), if(jobCards.length>5) AppIconButton(search)]` — plain Row, RTL auto-mirror, `>5` exception per brief, inline field removed. One visible path. U1/U9 fixed (D1 closed).

2. **Fold (intake + Zara + Ahmed + Layla peeking at 360x800) — PASS**
   - `jobs_1.0_en_360x800.png`: `Assigned intake queue / Oil change·Patrol / Nadia·2026-10-21 [Check In]` + `Zara·Corolla` + `Ahmed·Camry` + `Layla·Yaris` fully + next sliver. Dead 80px band gone, sort compact one-line `Sort | Newest first`. U2/C16-fold fixed (D2 closed). Caveat: PNGs crop bottom-nav, fold proven by stack slimming.

3. **Rail full `Approved` label with count-peek (360) + clean scroll 320/1.3x — PARTIAL PASS (non-gating)**
   - `jobs_1.0_en_360x800.png`: 4th chip `Approved` full (was `Approve` clipped). Count `1` off-screen in still; wide `jobs_1.0_en_1280x800.png` proves taxonomy `All | Intake 2 | Inspection 1 | Approved 1 | WIP 1 | Ready 1`.
   - `jobs_1.0_en_320x568.png` shows `Apprc`, `jobs_1.3_en_360x800.png` shows `Appr` — stress stills cut mid-word. Acceptable: 6-item rail must scroll; cut start visible = clean peek per U5 scroll clause. No overflow. D3 core fixed. Deduct polish: gap-cut + count-peek ideal.

4. **1.3x whole `2026-10-21` — PASS**
   - `jobs_1.3_en_360x800.png`: `Nadia ·` / `2026-10-21` wrapped 2 lines, full date, no `2026-1…`. Code `_BookingRow maxLines:2 softWrap:true`. U5/U14/U11 fixed (D4 closed).

5. **48dp more_vert + chevron + sync chip separated from time slot — PASS (size by contract)**
   - `jobs_1.0_en_360x800.png` Zara: `Pending` + `Not sent yet`, right `more_vert` over `chevron`; Ahmed/Layla same with `10:30 AM` / `09:15 AM`. AR mirrors to `<`. Code `AppIconButton(more_vert)` + `DirectionalIcon(chevron)`, `isPendingSync` → separate warning chip + empty time slot. Wide Time localized `Not sent yet`. D5 closed. dp via system contract, not PNG ruler.

6. **Calm empty (icon + sentence + New job card only) — PASS**
   - `jobs_empty_en_360x800.png`: `No job cards` + centered icon + `No job cards yet` + `New job cards will appear here as they are created.` + `[New job card]` only. No rail/sort. Code `collapseChrome`. U6 fixed (D6 closed).

7. **Borderless search sheet with `Ahmed · Camry` titles + localized sync + zero `--` — PASS**
   - `jobs_search_en_360x800.png`: `Search / ahmed / Job Cards (1)` row `Ahmed · Camry` + `ABC 1234 · JC-2002`, flat row no border. Code borderless `_result minHeight:touchTarget + DirectionalIcon`.
   - `jobs_1.0_ar_360x800.png`: `بالانتظار` + `لم يُرسل بعد` + `تم الفحص` — sync localized. `jobs_1.0_en_1280x800.png`: `Technician No data yet` (was `--`). U11/U13/C16-border fixed (D7 closed).

### Condensed regression re-walk (taps ≤ budget)

| Task | Budget | Observed |
|---|---|---|
| Open job card | ≤2 | tab + card tap = 2 PASS |
| Find via search | ≤3+typing | tab + icon + type + result tap = 3+typing PASS |
| Triage filter | ≤2 | tab + chip = 2 (`Inspection 1` + `Clear` shown) PASS |
| Check-in | ≤2 | tab + `Check In` = 2 PASS |
| Quick preview | ≤2+sheet | tab + `more_vert` + Open = 2+sheet PASS |
| Sort | ≤3 | tab + dropdown + option = 3 PASS |
| New from empty | ≤2 | tab + `New job card` = 2 PASS |
| Retry | ≤1 | `AppBanner` stale / `AppErrorState` first-load, same invalidate — PASS by contract |

### Honest rubric (C16 + U0–U14 = 16, need ≥12)

C16 PASS, U0 PASS, U1 PASS, U2 PASS, U3 PASS, U4 PASS, U5 PASS (core full, stress peek-start allowed; date whole), U6 PASS, U7 PASS, U8 PASS, U9 PASS, U10 PASS, U11 PASS, U12 PASS, U13 PASS, U14 PASS — minus 3 polish pts (rail count-peek/320 gap-cut, wide Time reuses sync string, small-pill target PNG-unverified). **13/16 PASS.** No C17 8/16 cap, no C16 10/16 cap.

### Remaining gating

- **None gating.** Polish to 15-16: (a) rail 360 `Approved 1` peek + 320 gap-cut; (b) wide Time honest empty vs sync text note; (c) nav-in-frame 360 shot next round.
