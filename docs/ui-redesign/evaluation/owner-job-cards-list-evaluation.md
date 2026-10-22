# Owner Job-cards list — Fresh review ROUND 1 (PASS 16/16)

**Role:** FRESH REVIEWER (round 1), never built this screen. READ-ONLY except this file. No code/tests/PNGs edited. No branch/commit/push. Never touched `7198329`.
**Branch:** `ui/list-ops`.
**Read first:** Brief `docs/ui-redesign/briefs/owner-job-cards-list.md` (authoritative, incl. sanctioned deviations: A — chrome stays `WorkspaceAppBar` (no `AppPageHeader` swap; counts on the bar pill); B — single inline search affordance, NO header search icon at any size (desktop shortcut focuses the SAME field, same target); C — table kept on wide (this batch's ONE table case: homogeneous 5-column audit with numeric sort; compact keeps `AppRecordRow`); D — `AppTable` + `AppRecordRow` + `jobStatusPill` + `formatAed2` NOT rebuilt, shared/detail-owned STOP boundaries); migration `docs/ui-redesign/evaluation/owner-job-cards-list-test-migration.md` (behavior pins: 9/9 GREEN before and after; pinned quirks — pills render `.toUpperCase()` labels from detail-shared `job_status_ui.dart`, byte-identical, C16 bans ADDED caps and none added; six-chip rail scrolls, QC chip needs one drag in harness only; NO error branch on this surface, provider-owned, untouched); REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 C17 (brief §§U0–U14 authoritative). Pass ≥ 12/16 with caps.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (both per brief §References, confirmed UNMET — phase-7 brief + vehicles-list + screens 1–4 precedent used instead).
**Images viewed (AFTER via Read, full resolution + BEFORE for contrast):**
- AFTER `docs/ui-redesign/baseline/after-owner-job-cards/`: `idle_light_1.0_en_360x800`, `idle_light_1.0_en_320x568`, `idle_light_1.3_en_360x800`, `idle_dark_1.0_en_360x800` (+ wide `idle-wide`/`selected-wide` + `filter`/`search`/`empty`/`loading` frames in set, relied on via 9/9 pins).
- BEFORE contrast via contact sheet (light + dark exist; frozen records, never regenerated).
- Contact sheet `docs/ui-redesign/baseline/phase-owner-cards-light.png`: BEFORE (left) vs AFTER (right) side-by-side.
**Code read-only (attribution only):** `apps/owner_app/.../pages/job_cards_list_view.dart` (bar count `AppStatusChip :247`; `AppSearchField :262`; `AppFilterBar :273` + milestone mapping; compact `AppRecordRow` path with `jobStatusPill :171,226,353` incl. existing `.toUpperCase()`; preview `AppSurfaceCard :327,336` + `AppPillButton.primary :401` Open + `AppEmptyState :328` select-prompt — grep-confirmed; no remaining `StatusPill` in bar, no header search icon).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle light en 360 — `idle_light_1.0_en_360x800.png`
- **Bar region:** back arrow left; bold `Job register`; muted `All active workshop jobs`; pale pill `● 3 jobs` right. No search icon anywhere in the bar.
- **Search region:** rounded field with magnifier + hint `Search job, plate, customer…`.
- **Rail region:** filled blue `All`; outlined `Intake 0`, `Inspection 0`, `WIP 1` (rail continues past frame edge).
- **Card 1 region:** bordered card: pale chip `JC-1042`; bold `Ahmed`; muted `Camry · ABC 1234`; bold `AED 2,450.00`; teal pill `● IN PROGRESS`; chevron `>` right.
- **Card 2 region:** same shape: `JC-1043`, `Sara`, `Civic · DEF 9012`, `AED 899.50`, amber pill `QUALITY CHECK` with clock glyph, chevron.
- **Card 3 region:** same shape: `JC-1044`, `Khalid`, `Hilux · XYZ 1111`, `AED 0.00`, green pill `COMPLETED` with check glyph, chevron. Each card sits inside a faint outer frame row.

### AFTER 320px — `idle_light_1.0_en_320x568.png`
- Same bar (title + subtitle + `3 jobs` pill); same search hint; rail `All / Intake 0 / Inspection 0` + cut chip; cards 1–2 fully present (ref chip, customer, vehicle·plate, tabular amount, UPPERCASE pill, chevron); card 3 (`JC-1044`) peeking at frame bottom.

### AFTER 1.3x — `idle_light_1.3_en_360x800.png`
- Same structure; rail same; all three cards fully present with amounts `AED 2,450.00 / AED 899.50 / AED 0.00` and pills whole; no clipping, no overflow markers.

### AFTER dark en 360 — `idle_dark_1.0_en_360x800.png`
- Black background; same bar (`Job register`, subtitle, `● 3 jobs` pill, back arrow); same search field (dark); same rail (`All` filled blue, `Intake 0`, `Inspection 0`, `WIP 1`); same three cards in dark-navy with white titles, muted meta, white tabular amounts, dark-adapted pills (`IN PROGRESS` teal-on-dark, `QUALITY CHECK` amber-on-dark, `COMPLETED` green-on-dark), chevrons. Structure 1:1 with light, no missing region.

### BEFORE vs AFTER (contact sheet `phase-owner-cards-light.png`)
- BEFORE left vs AFTER right: bar, search, rail, cards, copy, order, amounts, pills all identical in seat and label; only atom tokens change (stadium rail/buttons, `AppSurfaceCard` borders, `AppStatusChip` count pill). No structural delta visible — the rebuild is chrome-only around kept table/row/pill/money atoms (deviations C/D), exactly as briefed.

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — one read: job ref → customer + vehicle·plate → total → status pill; ROW hierarchy: customer = title (compact), ref = first-col (wide); pill ONLY from existing `JobCardStatus` | idle-360 cards: `JC-1042` → `Ahmed` → `Camry · ABC 1234` → `AED 2,450.00` → `IN PROGRESS`; `AED 0.00` honest zero on card 3, never `–` | PASS |
| U1 — find fast: ONE inline affordance (field + shortcut focusing SAME field = same target, not second path); rail narrows by milestone in 1 tap; columns re-sort in 1 tap; NO header icon (deviation B) | idle frames: single `AppSearchField` (`:262`), zero header icons; rail (`:273`) with live counts; `_sorted` presentation copy (provider never mutated) | PASS (audited single affordance holds at all sizes) |
| U2 — fit: homogeneous audit — table on wide (THIS is the table case), single-column rows compact; FOLD: bar + field + rail + FIRST row above fold, second peeking @360x800 | 360/320: single-column `AppRecordRow` cards; wide frames in set keep sticky `AppTable` + 5:3 split + 360 preview pane (deviation C); card 1 complete + card 2 peeking/complete, card 3 peeking at 320 | PASS |
| U3 — no fake actions: rows map 1:1 to audit entry; Search/Filter/Sort/Clear/Open map 1:1; preview prompt offers no fake creation | Rows → `_openJob` (same `selectedJobCardProvider` + `push(jobCardDetail)`); wide select → preview → Open (2 taps); prompt explains honestly (audits open, jobs arrive from bookings) | PASS |
| U4 — no invention: ref/plate/customer/vehicle/amount verbatim; `formatAed2` fixed-cents byte-exact; zero as `AED 0.00`; counts from `state.all` only | `AED 2,450.00 / AED 899.50 / AED 0.00` tabular; `JC-1042`, `ABC 1234` mono LTR; `3 jobs` + rail counts from loaded lists | PASS |
| U5 — reachability + legibility: 48dp chips/Clear/sort headers/Open; pill block bounded (unshrinkable-pill fix kept); ref/plate/money LTR; wrap/ellipsis @320/1.3x never clips | 320: cards intact incl. full pills + amounts; 1.3x: all pills/amounts whole, no overflow; chevrons + full-row tap targets; preview Open `AppPillButton.primary` (`:401`) | PASS |
| U6 — states: table-owned loading skeleton; honest empty (`ownerRegEmpty` + hint, NO create-CTA); no-match + clear; select-prompt (1 icon + 1 sentence, no action); NO error panel (provider-owned, untouched) | `AppEmptyState` select-prompt (`:328`, title reuses `ownerRegTitle`, message `ownerRegSelectPrompt` verbatim, no action); empty/no-match table-owned verbatim; no error branch added (pinned) | PASS (code + pins) |
| U7 — feedback: row tap → same `_openJob` (sets selection + pushes audit); wide select → same preview; Open → same push; one path per task | Compact tap + wide select-then-Open pins GREEN (stub route exercises real `selectedJobCardProvider` + push) | PASS |
| U8 — no dead ends: every row opens; select-prompt explains; no-match clears; filters always reversible | Every card carries chevron + entry; rail re-tap clears (pins GREEN) | PASS |
| U9 — consistency: `WorkspaceAppBar`, `AppSearchField`, `AppFilterBar`, `AppTable`/`AppRecordRow` — same owner-family atoms | Bar + field + rail + table/row atoms match owner-home precedent; preview `AppSurfaceCard` + `AppEmptyState` + `AppPillButton` same shared family | PASS |
| U10 — RTL: full mirror; ref/plate/vehicleDisplay/money LTR (`Directionality` kept); sort icons mirror-safe | ar idle frame exists in matrix (pins GREEN); amounts/plates LTR-locked in all viewed frames | PASS (stills-limited; pins hold) |
| U11 — a11y: row `Semantics` (shared atoms) + sort `Semantics` (table-owned) + 48dp targets; tabular figures | Kept via untouched shared atoms per migration; 320/1.3x frames show no clipping | PASS (stills-limited for Semantics) |
| U12 — density: 1-col compact/medium; wide 5:3 + 360 pane (existing split, max-width frame) | 360/320 single column; wide frames in set per matrix (table + preview) | PASS |
| U13 — offline: search/filter/sort work on loaded data; reload via provider (same contracts) | Provider/filter/sort/selection contracts untouched per migration | PASS (code pins) |
| U14 — no regression: tap budgets ceilings; sort/selection/filter/search/open contracts unchanged | See §3; `_applyFilters`, `_sorted`, `_selectedId`, `_openJob`, routes, keys byte-identical | PASS |

**U-walk fails: 0.**

---

## 3. Top-task tap walk BEFORE→AFTER (budgets ≤ before)

BEFORE (brief §Top tasks, verified from code per migration): open register 1 (drill) · find ≤ 1 + keystrokes (+scroll; sort 1) · compact open 1 · wide select + Open 2 · clear/re-sort 1.

| Task | Before | After (pixels + code) | Verdict |
|---|---|---|---|
| Open register | 1 tap (dashboard drill) | ≤ 1 tap (entry route untouched) | same ✓ |
| Find job (search + filter + sort) | 0-tap focus + keystrokes and/or chip 1 (+scroll; column tap 1) | Identical: same inline field (`:262`, 4-field predicate) + same rail (`:273`, milestone mapping + counts + clear) + same `_sorted` presentation sort | same ✓ |
| Open audit (compact) | 1 tap (row tap) | ≤ 1 (rows stay entry; `AppRecordRow` + chevron; same `_openJob` + push) | same ✓ |
| Open audit (wide: select + Open) | 2 taps | ≤ 2 (row select → in-place preview → `AppPillButton.primary` Open `:401` → same audit) | same ✓ |
| Clear no-match / re-sort | 1 tap | ≤ 1 (field Clear / chip re-tap; sort header tap, provider list never mutated) | same ✓ |

**Tap result: PASS — no budget regresses; frequent actions (find → open) stay single-screen; wide confirm stays 2 taps.**

---

## 4. Airbnb rubric 0–2 each, /16, pass ≥ 12/16 — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find job → open audit; register + search + milestones + sort serve the one glance |
| 2 | Headline-first hierarchy | 2/2 | Ref → customer → vehicle·plate → tabular total → status pill; amounts tabular, pills terminal |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless-feel rows (preview uses `AppSurfaceCard` border-XOR-shadow; dark keeps border per convention); no wrapper stacking added |
| 4 | Sheets for secondary actions | 2/2 | Wide side preview is the pattern's secondary surface (in-place pane, not a competing page); no new dialogs/sheets |
| 5 | Sticky CTA (none claimed) | 2/2 | Correctly absent; Open lives in the wide pane only (one filled accent per pane); compact rows need no CTA (the row IS the action) |
| 6 | Section structure | 2/2 | Bar + count pill + search + milestone rail + table/rows + preview; rail counts update, no-match + clear, sort re-orders without mutating provider |
| 7 | Plain friendly copy, no invented claims | 2/2 | Verbatim keys, zero new; `AED 0.00` honest zero; UPPERCASE pill labels (`IN PROGRESS`, `QUALITY CHECK`, `COMPLETED`) are the PINNED pre-existing shared-helper quirk (`job_status_ui.dart`, also detail's — STOP boundary, byte-identical, none ADDED, so no C16 added-caps hit) |
| 8 | Single emphasized primary action | 2/2 | Compact: zero filled (rows are entries); wide pane: exactly one filled (Open); empty/prompt: zero filled (correct — nothing to create) |
| **Merit total** | | **16/16** | Pass on merit (≥ 12) |
| **C16 hard-reject cap** | single-search-affordance (audited) / borderless-feel / one-filled-per-pane / one-path-per-task / no-permanent-pills / no-ALL-CAPS-added / above-fold+peek / hierarchy / zero-as-AED-0.00 | **No cap** | ALL PASS: one affordance (shortcut = same field) ✓; pill quirk pre-existing + shared, none added ✓; first row + peek ✓; dark 1:1 no regression ✓ |
| **C17 U-cap** | ANY U-law fail caps at 8/16 | **No cap** | Zero U fails (§2) |
| **Final** | | **16/16 — PASS** | |

---

## ROUND-1 DEFECT LIST (gating first, honestly)

**Gating defects: NONE.** No C16 hard-reject hit (pill caps are pinned pre-existing, none added), no U-law fail, no tap-budget breach, dark verified 1:1 with no regression.

**Non-gating observations (disclosed, filed — NOT defects, do not gate this verdict):**
1. **Pill labels render UPPERCASE (`IN PROGRESS`, `QUALITY CHECK`, `COMPLETED`) — PINNED quirk, filed.** Idle light + dark frames + code `job_status_ui.dart` `.toUpperCase()` (2 call sites in `job_card_detail_view.dart`; STOP boundary deviation D, byte-identical). C16 bans ADDED caps; this screen adds none. Changing it here would restyle the detail view — explicitly out of scope. For owning phase + phase-9: decide sentence-case at the shared helper with both call sites in one change, never per-screen. Non-gating.
2. **Before/after contact sheet shows no visible structural delta** (`phase-owner-cards-light.png` left ≈ right) — expected and correct: deviations C/D froze table/row/pill/money atoms; the rebuild is bar-pill + preview-card/button/prompt chrome only. Verified by 9/9 pins + matrix, not pixel drama. Non-gating.
3. **Wide table/sort/select-then-Open verified via pins + matrix frames, not re-pixel-walked here** (idle/320/1.3x/dark/contact-sheet pixel-verified; `idle-wide`/`selected-wide`/`filter`/`search`/`empty`/`loading` relied on via 9/9 GREEN characterization). Coverage note for the capturing phase, not a behavior gap. Non-gating.
4. **Process artifacts (not screen defects):** `references/` + `AIRBNB_PATTERNS.md` UNMET per brief (precedent used).

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `idle_light_1.0_en_360x800.png`: `Job register / All active workshop jobs / ● 3 jobs`, `Search job, plate, customer…`, `All / Intake 0 / Inspection 0 / WIP 1`, cards `JC-1042 → Ahmed → Camry · ABC 1234 → AED 2,450.00 → IN PROGRESS` with `>`. Next step is unambiguous: type, chip-filter, or tap a card to open the audit.
- **What would an Airbnb product designer reject here?** Nothing blocking in list scope. One system-level carry-forward: resolve the shared `jobStatusPill` UPPERCASE at the helper (with the detail view), never per-screen — this screen's byte-identical keep is the correct call.

(End of file — round 1, 2026-10-22)

---

# ROUND 2 — Fresh independent confirmation (2026-10-22, AGREE — Final 16/16 PASS)

**Role:** FRESH REVIEWER round 2, never built this screen, never saw round-1 before walking pixels. READ-ONLY except this append (round-1 above kept verbatim). No branch/commit/push. Never touched `71983229` / `7198329`.
**Branch:** `ui/list-ops`. **Authoritative:** brief `docs/ui-redesign/briefs/owner-job-cards-list.md` (deviations A–D) + migration `owner-job-cards-list-test-migration.md` (9/9 GREEN pins) + C16 hard-reject (caps 10/16) + U0–U14 C17 (caps 8/16). Pass ≥ 12/16 with caps.
**Images independently viewed (Read, full resolution):** `after-owner-job-cards/` all 11 — `idle_light_1.0_en_360x800`, `idle_light_1.0_en_320x568`, `idle_light_1.3_en_360x800`, `idle_dark_1.0_en_360x800`, `idle_light_1.0_ar_360x800`, `idle-wide_light_1.0_en_1280x800`, `selected-wide_light_1.0_en_1280x800`, `filter_light_1.0_en_360x800`, `search_light_1.0_en_360x800`, `empty_light_1.0_en_360x800`, `loading_light_1.0_en_360x800` — plus contact sheet `phase-owner-cards-light.png` (BEFORE≈AFTER, chrome-only delta as briefed).
**Code attribution (read-only grep + targeted read):** `job_cards_list_view.dart` actions `:243–253` carry ONLY `AppStatusChip` count (`:247`), zero header search icons; `AppSearchField :262` + `AppFilterBar :273`; `AppSurfaceCard :327,:336` + `AppEmptyState :328` + `AppPillButton.primary :401`; `_sorted :64`, `_openJob :79`; `job_status_ui.dart :66` `.toUpperCase()` shared helper, also detail's (`job_card_detail_view.dart :196,:355`) — pinned STOP boundary, byte-identical.

## Independent U0–U14 walk (all with pixel evidence)
- U0 PASS — idle-360 cards `JC-1042→Ahmed→Camry·ABC 1234→AED 2,450.00→IN PROGRESS` (+ `AED 0.00` honest zero, never `–`).
- U1 PASS — single inline affordance in every frame (360/320/1.3x/dark/ar/wide all show zero header search icons); shortcut focuses SAME field (code `:235–236`); rail 1-tap + sort 1-tap (pins).
- U2 PASS — compact single-column; wide keeps sticky `AppTable` + 5:3 split + 360 pane (deviation C); fold: 360 shows card 1 complete + cards 2–3 visible (exceeds bar+field+rail+first-row+peek minimum); 320 shows cards 1–2 complete + JC-1044 peeking.
- U3 PASS — rows → `_openJob` (same push); wide select → preview → Open (2 taps); prompt honest, no fake creation.
- U4 PASS — `AED 2,450.00 / 899.50 / 0.00` tabular; `JC-1042`, `ABC 1234` mono LTR; `3 jobs` + rail counts from loaded lists.
- U5 PASS — 320 + 1.3x: all pills/amounts whole, no overflow/clipping; chevron full-row targets; Open `AppPillButton.primary`.
- U6 PASS — skeleton (`loading`), honest empty (`No job cards found.`, no create-CTA), no-match+clear path (`search` X, `filter` Clear), select-prompt 1 icon + 1 sentence no action; no error branch added (provider-owned, pinned).
- U7 PASS — compact tap + wide select-then-Open pins GREEN (real selection + push contract); one path per task.
- U8 PASS — every card chevron + entry; rail re-tap/Clear reversible.
- U9 PASS — `WorkspaceAppBar` + `AppSearchField` + `AppFilterBar` + `AppTable`/`AppRecordRow` + `AppSurfaceCard`/`AppEmptyState`/`AppPillButton` owner-family atoms.
- U10 PASS — ar frame fully mirrored; `JC-1042`, plates, amounts LTR-locked; pills localized (`قيد التنفيذ/فحص الجودة/مكتملة`).
- U11 PASS — shared-atom Semantics kept; 320/1.3x no clipping (stills-limited for Semantics, pins hold).
- U12 PASS — 1-col compact/medium; wide 5:3 + 360 pane.
- U13 PASS — search/filter/sort on loaded data; provider contracts untouched (pins).
- U14 PASS — tap budgets ceilings held (see below); sort/selection/filter/search/open/routes/keys byte-identical (pins).
- **U fails: 0 → no C17 cap.**

## Independent tap walk (BEFORE→AFTER, budgets ≤ before)
- Open register: 1 → ≤1 (entry route untouched) ✓
- Find (search + chip + sort): ≤1 + keystrokes (+scroll; column tap 1) → identical seats/handlers/predicate/sort ✓
- Open audit compact: 1 → ≤1 ✓; wide select + Open: 2 → ≤2 (`selected-wide` shows row highlight + dossier + `Open register` filled button) ✓
- Clear no-match / re-sort: 1 → ≤1 (`search` X clears; `filter` QC-selected + `Clear` reverses; sort header re-orders, provider never mutated per pins) ✓
- **No budget regresses.**

## C16 hard-reject checklist (brief-adapted) + dark parity
- Single search affordance (audited, all sizes) ✓ · borderless-feel (preview `AppSurfaceCard` border-XOR-shadow; kept table/row atoms per deviations C/D, nothing added) ✓ · one filled accent per pane (compact 0, wide Open 1, empty/prompt 0) ✓ · one path per task (shortcut = same field) ✓ · no permanent pills (count/rail/status all live/data-only) ✓ · **no ALL CAPS ADDED** (UPPERCASE `IN PROGRESS/QUALITY CHECK/COMPLETED` = pinned pre-existing shared-helper quirk `:66`, byte-identical, none added — brief KEPT/STOP sanction, same precedent as phase-7 `REVENUE/MARGIN` keep) ✓ · first row above fold + next peeking ✓ · hierarchy (customer/ref → vehicle·plate → total → pill) ✓ · zero as `AED 0.00` ✓ → **no C16 cap.**
- Dark parity: `idle_dark` 1:1 with light (bar, field, rail `All/Intake 0/Inspection 0/WIP 1`, 3 cards, tabular whites, dark-adapted pills, chevrons) — no missing region, no regression ✓.

## Decision
- **AGREE with round-1 entirely** (16/16 reasoning, zero-gating finding, and all four non-gating disclosures: UPPERCASE quirk provenance, chrome-only contact-sheet delta, wide/sort via pins+matrix, UNMET references/AIRBNB_PATTERNS precedent).
- **Gating defects found by round-2: NONE.** No C16 hit, no U-law fail, no tap-budget breach, no dark regression.
- **Merit 16/16, C16 no cap, C17 no cap → Final 16/16 — PASS (CONFIRMED).**

(End of file — round 2 confirmation, 2026-10-22)
