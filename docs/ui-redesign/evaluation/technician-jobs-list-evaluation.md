# Technician Jobs list — Fresh review ROUND 1 (PASS 16/16)

**Role:** FRESH REVIEWER (round 1), never built this screen. READ-ONLY except this file. No code/tests/PNGs edited. No branch/commit/push. Never touched `7198329`.
**Branch:** `ui/list-ops`.
**Read first:** Brief `docs/ui-redesign/briefs/technician-jobs-list.md` (authoritative, incl. sanctioned deviations: A — no in-body header (shell `_TechChrome` owns the title; counts live on rail chips); B — shell search icon at ANY size, no > 5 gate (blessed ui/integration-1 single-search fix, STOP); C — rows are pure NAVIGATION entries, no per-row buttons (operations live in Job Detail); D — `TechnicianJobSummary` NOT rebuilt, shared with Today + search sheet, STOP boundary); migration `docs/ui-redesign/evaluation/technician-jobs-list-test-migration.md` (behavior pins: 9/9 GREEN before and after; blessed-contract pins — zero `AppSearchField` on this view, `AppFilterBar` rail-only; freshness footer deterministic `fixedRefreshAt 09:41`); REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 C17 (brief §§U0–U14 authoritative). Pass ≥ 12/16 with caps.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (both per brief §References, confirmed UNMET — precedent patterns + blessed single-search audit used instead).
**Images viewed (AFTER via Read, full resolution + BEFORE for contrast):**
- AFTER `docs/ui-redesign/baseline/after-technician-jobs/`: `idle_light_1.0_en_360x800`, `idle_light_1.0_en_320x568`, `idle_light_1.3_en_360x800`.
- BEFORE contrast via contact sheet (frozen record, never regenerated).
- Contact sheet `docs/ui-redesign/baseline/phase-tech-jobs-light.png`: BEFORE (left) vs AFTER (right) side-by-side.
**Code read-only (attribution only):** `apps/staff_app/.../widgets/technician_jobs_view.dart` (`AppShimmerSkeleton:121`, `AppErrorState:125`, `AppEmptyState:135,146`, `AppDivider:164` separator, `AppFilterBar:225` rail-only, `AppBanner:252` stale warning — grep-confirmed; zero `AppSearchField` in this file per STOP).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle en 360 — `idle_light_1.0_en_360x800.png`
- **Toolbar region (top, cropped above):** chip rail: filled blue `All 3`, outlined `Pending 1`, `In Progress 1`, `Dela…` (fourth chip cut at frame edge). No title, no search field in-body.
- **Row 1 region:** left red rail; bold `Nissan Yaris`; red pill `Delayed` with dot + alert glyph right; muted `JC-102`, pale plate chip `XYZ 5678`, muted `Starts 10:…` with chevron `>` far right; muted `0 of 1 tasks completed` with list glyph below.
- **Row 2 region (highlighted):** pale-blue full-bleed background; left blue rail; bold `Toyota Camry`; teal pill `● In Progress`; muted `JC-101`, plate `ABC 1234`, `Starts 08:…`, chevron; `1 of 3 tasks completed`. This is the selected/in-progress row.
- **Row 3 region:** left amber rail; bold `Toyota Hilux`; amber pill `● Pending` with clock glyph; muted `JC-103`, plate `DEF 9012`, `Starts 11:…`, chevron; `0 of 2 tasks completed`.
- **Footer region:** centered muted `Updated 09:41`.

### AFTER 320px — `idle_light_1.0_en_320x568.png`
- Same rail; rows in urgent-first order; plate chips read `XYZ 56…`, `ABC 12…`, `DEF 90…` (ellipsis); start times read `Starts 1…` / `Starts 0…` (ellipsis); job titles, JC refs, counts line, pills, chevrons, footer intact.

### AFTER 1.3x — `idle_light_1.3_en_360x800.png`
- Same rail; plate chips read `XYZ 56…`, `ABC 1…`, `DEF 9…`; start times `Starts …`; titles/refs/counts/pills/chevrons intact; footer `Updated 09:41`; no overflow markers.

### BEFORE vs AFTER (contact sheet `phase-tech-jobs-light.png`)
- BEFORE left vs AFTER right: copy, order, rails, pills, plate chips, start times, chevrons, footer all identical in seat and label; only atom tokens change (stadium chips/buttons, `AppDivider` hairline). No structural delta visible — the rebuild is chrome-only around the kept shared row (deviation D), exactly as briefed.

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — one read: rail (what filter is on) → urgent-first rows → freshness; ROW hierarchy: job ref → vehicle + plate/start pills → status; IDs meta, never headlines | idle-360: `All 3` → `Nissan Yaris / JC-102 / XYZ 5678 / Starts 10:… / Delayed` (delayed surfaces first) → `Updated 09:41`; titles lead, `JC-10x` muted sub-line | PASS |
| U1 — find fast: ONE top affordance (shell search icon) → full-screen sheet over same loaded jobs (same 5-field predicate + normalized plate, same dossier contract); toolbar filter-rail only; NO inline re-added (STOP) | idle frames: rail only, zero `AppSearchField` (code pin `findsNothing` GREEN); shell chrome + sheet untouched per migration | PASS (blessed single path intact) |
| U2 — fit: homogeneous scan rows, single column, NOT a table; FOLD: rail + FIRST row above fold, second peeking @360x800 | idle-360: single-column `ListView.separated` (`AppDivider :164`), no table; delayed row complete, in-progress row peeking/complete in scroll frame (order matches wireframe) | PASS |
| U3 — no fake actions: rows map 1:1 to dossier entry; rail/Retry/Clear/Refresh map 1:1; no invented buttons/pills | Rows are navigation entries (chevron, tap → dossier); no per-row operational buttons (deviation C — those live in Job Detail); pills from existing status only | PASS |
| U4 — no invention: refs/vehicle/plate/customer verbatim; normalized-plate matching untouched; zero as `0` | `JC-102`, `Nissan Yaris`, `XYZ 5678`, `0 of 1 tasks completed` (`0`, not `–`); `_urgentFirst` order delayed 0 / inProgress 1 / pending 2 pinned | PASS |
| U5 — reachable + legible: 48dp+ rows/targets; pills wrap/ellipsize @320/1.3x; footer LTR; hairline full-bleed separator — PRIMARY vs SECONDARY adjudication | 320: PRIMARY identity (`Nissan Yaris`, `JC-102`, `Delayed`/`In Progress`/`Pending` pills, counts line) fully legible; SECONDARY meta (plate `XYZ 56…`, `Starts 1…`) ellipsized. 1.3x: same split, no clipping/overflow, footer intact. Brief U5 explicitly sanctions 1-line detail ellipsis; the truncated fields are recoverable one tap away (row → dossier, ≤ 1 tap). Honest cost noted, law met | PASS (with noted secondary truncation) |
| U6 — states: skeleton mirrors rows; honest empty (1 icon + 1 sentence + 1 Refresh → same refresh); no-match (title + hint + Clear → same reset); error + retry; stale kept + `AppBanner`; pull + freshness | `AppShimmerSkeleton.listRows(4) :121`; `AppErrorState` (`commonErrorTitle` + `techJobsLoadError` verbatim `:125`); `AppEmptyState` empty (`:135`) + no-match (`:146`, search_off); `AppBanner` warning, same `dashboardError` copy (`:252`); `RefreshIndicator` + `_FreshnessFooter` kept; pins GREEN 9/9 | PASS (code + pins) |
| U7 — feedback: row tap → same dossier contract (`openJob` + push + `closeJob`); one search path, one filter path, one open path | Stub-route pin GREEN (row tap exercises real `openJob`/`push`/`closeJob`); toasts inside dossier untouched | PASS |
| U8 — no dead ends: every row opens; empty offers Refresh; no-match offers Clear; error offers Retry; stale offers pull | Every row has chevron + tap target; states all carry actions per migration | PASS |
| U9 — consistency: `AppFilterBar`, divider rows, sheet, `AppBanner` — same atoms as staff precedent + screens 1–3 | `:225` rail, `:164` divider, `:252` banner, shared `TechnicianJobSummary` kept (STOP) | PASS |
| U10 — RTL: full mirror; plate/time/figures LTR (existing locks kept) | ar idle frame exists in matrix; footer `09:41` LTR in all frames; locks kept per brief | PASS (stills-limited; pins hold) |
| U11 — a11y: row `Semantics` (kept component) + `countSemantics` on rail + live-region on error | Kept per migration (pins GREEN); 320/1.3x frames show no clipping/overflow | PASS (stills-limited for Semantics) |
| U12 — density: 1-col compact; wider canvas max-width 1180, single-column register (grid N/A by design) | 360/320 single column; tablet frame in set keeps single column per brief | PASS |
| U13 — offline: stale list kept + banner; retries inline; footer clock keeps ticking on refresh | `AppBanner` warning + stale data kept; deterministic `fixedRefreshAt` footer pin | PASS (code pins) |
| U14 — no regression: tap budgets ceilings; urgent-first order, predicates, freshness, open/closeJob, keys unchanged | See §3; `_urgentFirst`, 5-field predicate, shell icon/sheet/dossier untouched | PASS |

**U-walk fails: 0.**

---

## 3. Top-task tap walk BEFORE→AFTER (budgets ≤ before)

BEFORE (brief §Top tasks, verified from code per migration): open 1 (tab) · find = header icon → sheet → type → result tap (1 + keystrokes + 1, 1 path) OR chip 1 · dossier 1/0-scroll · clear 1 · retry 1 / pull.

| Task | Before | After (pixels + code) | Verdict |
|---|---|---|---|
| Open list | 1 tap (Jobs tab; 0 via `selectTab(1)` deep-link) | ≤ 1 tap (tab seat unchanged) | same ✓ |
| Find job (search sheet) | 1 + keystrokes + 1, single path | Identical: shell icon → same sheet (same predicate, same dossier contract); no inline resurrected (STOP pin `findsNothing` GREEN) | same ✓ |
| Filter by status | 1 tap (chip) | ≤ 1 (same rail `:225`, same predicate/counts/`updateFilter`) | same ✓ |
| Open dossier | 1 tap, 0 scroll (urgent-first keeps next job top) | ≤ 1, ≤ same scroll: rows stay navigation entries, no buttons added (deviation C); urgent-first order pinned (Delayed → In Progress → Pending visible in idle frames) | same ✓ |
| Clear no-match | 1 tap | ≤ 1 (same `updateSearch('')` + `updateFilter('All')` reset) | same ✓ |
| Retry / refresh + freshness | 1 tap / pull | ≤ 1 / pull (same refresh; `Updated 09:41` footer LTR-locked in all frames) | same ✓ |

**Tap result: PASS — no budget regresses; urgent-first scan order preserved; single search path blessed-contract intact.**

---

## 4. Airbnb rubric 0–2 each, /16, pass ≥ 12/16 — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find job → open dossier; rail + urgent-first rows + freshness, no hero, no competing CTA |
| 2 | Headline-first hierarchy | 2/2 | Vehicle → JC ref + plate/start pills → status → counts; IDs meta; in-progress row highlighted, not headlined |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless rows, hairline dividers, whitespace separation; no wrappers added around kept component |
| 4 | Sheets for secondary actions | 2/2 | Search = full-screen sheet (shell-owned, same contract); no inline field, no new dialogs |
| 5 | Sticky CTA (none claimed) | 2/2 | Correctly absent — and correctly NO per-row buttons added (would duplicate dossier actions, C16) |
| 6 | Section structure | 2/2 | Rail-only toolbar with live counts; filter narrows, re-tap restores; urgent-first order is the structure |
| 7 | Plain friendly copy, no invented claims | 2/2 | Verbatim keys, zero new; `0 of 1 tasks completed` honest zero; no invented statuses |
| 8 | Single emphasized primary action | 2/2 | Zero filled CTAs in-body (rail-selected `All 3` is the filter state, not a CTA); no competing fills |
| **Merit total** | | **16/16** | Pass on merit (≥ 12) |
| **C16 hard-reject cap** | single-search-path (blessed) / rail-only-toolbar / borderless-rows / no-filled-CTA-added / one-path-per-task / no-permanent-pills / no-ALL-CAPS / above-fold+peek / zero-as-0 | **No cap** | ALL PASS: no `AppSearchField` in file ✓; rail-only ✓; borderless ✓; no CTA added ✓; secondary ellipsis ≠ C16 violation (content reachable in 1 tap) ✓; no ALL CAPS ✓; `0` ✓ |
| **C17 U-cap** | ANY U-law fail caps at 8/16 | **No cap** | Zero U fails (§2; U5 adjudicated primary-intact/secondary-ellipsized per explicit brief sanction) |
| **Final** | | **16/16 — PASS** | |

---

## ROUND-1 DEFECT LIST (gating first, honestly)

**Gating defects: NONE.** No C16 hard-reject hit, no U-law fail, no tap-budget breach on any path including the blessed single-search contract.

**Non-gating observations (disclosed, filed — NOT defects, do not gate this verdict):**
1. **Secondary meta ellipsizes at 320px/1.3x while primary identity stays whole — ADJUDICATED under U5, filed.** 320: `XYZ 56…` / `Starts 1…`; 1.3x: `XYZ 56…` / `ABC 1…` / `DEF 9…` / `Starts …`. PRIMARY (vehicle, JC ref, status pill, counts line, chevron, footer) never truncates; SECONDARY (plate suffix, start-time suffix) truncates. U5 explicitly sanctions 1-line ellipsis here and the full values sit one row-tap away (dossier, ≤ 1 tap, 0 added paths). Capture notes asked for exactly this adjudication: primary wins, secondary truncation is the sanctioned price of 48dp+ rows at 320px. Non-gating.
2. **Before/after contact sheet shows no visible structural delta** (`phase-tech-jobs-light.png` left ≈ right) — expected and correct: deviation D froze the shared row; the rebuild is chrome-only (states/separator/stale banner). Redesign delivered at the atom level, verified by the 9/9 pins + matrix, not by pixel drama. Non-gating.
3. **Process artifacts (not screen defects):** `references/` + `AIRBNB_PATTERNS.md` UNMET per brief (blessed audit + precedent used); ar/tablet/error/empty/loading/stale frames relied on via migration pins (9/9 GREEN), pixel-verified here for idle/320/1.3x/contact-sheet only.

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `idle_light_1.0_en_360x800.png`: `All 3 / Pending 1 / In Progress 1` rail, urgent-first `Nissan Yaris → JC-102 → XYZ 5678 → Delayed → 0 of 1 tasks completed` with `>` chevron, `Updated 09:41`. Next step is unambiguous: tap the top row to open the dossier (or chip-filter first).
- **What would an Airbnb product designer reject here?** Nothing blocking. The only honest cost — plate/start suffixes ellipsized at 320px — is brief-sanctioned, primary-safe, and one tap from full detail.

(End of file — round 1, 2026-10-22)

---

# Fresh review ROUND 2 (SECOND reviewer, independent — AGREE 16/16)

**Role:** SECOND FRESH REVIEWER (never built this), independent of round-1. READ-ONLY except this appendix. No code/tests/PNGs edited. No branch/commit/push. Never touched `7198329`.
**Branch:** `ui/list-ops`.
**Read first:** Brief `docs/ui-redesign/briefs/technician-jobs-list.md` (authoritative, incl. deviations A–D + U0–U14 C17 + blessed ui/integration-1 single-search fix); round-1 above (kept verbatim); migration `technician-jobs-list-test-migration.md` (9/9 GREEN pins); REDESIGN MANDATE + C16/C17 caps. Pass ≥ 12/16.
**Images viewed (AFTER via Read, full resolution):** `docs/ui-redesign/baseline/after-technician-jobs/` all 9 PNGs — `idle_light_1.0_en_360x800`, `idle_light_1.0_en_320x568`, `idle_light_1.3_en_360x800`, `filter_light_1.0_en_360x800`, `empty_light_1.0_en_360x800`, `error_light_1.0_en_360x800`, `loading_light_1.0_en_360x800`, `idle_light_1.0_ar_360x800`, `idle_light_1.0_en_768x1024` — + contact sheet `docs/ui-redesign/baseline/phase-tech-jobs-light.png` (BEFORE left vs AFTER right).
**Code read-only (attribution):** `technician_jobs_view.dart` (zero `AppSearchField` grep-confirmed, `AppFilterBar:225` rail-only, `AppDivider:164`, `AppBanner:252` warning, `AppShimmerSkeleton.listRows(rows:4):121`, `AppEmptyState:135,146`, `AppErrorState:125`, `_urgentFirst delayed0/inProgress1/pending2:99-105`, `openJob+push(technicianJobDetail)+closeJob:183-191`, `_FreshnessFooter LTR + maxWidth 1180:63-65,256-276`); `technician_dashboard_view.dart:81-85` sheet over `allJobs` + `:364` `selectedIndex != 0` guard (blessed contract).

## 1. Independent U0–U14 spot-walk (all 9 + contact sheet)

- U0 one-read PASS: idle-360 rail `All 3` → urgent-first `Nissan Yaris JC-102 Delayed` → `Toyota Camry JC-101 In Progress (highlighted)` → `Toyota Hilux JC-103 Pending` → footer `Updated 09:41`. Titles lead, JC refs muted sub-line, IDs meta. AR mirrors same order.
- U1 single-search PASS (blessed contract intact): all idle/filter frames show rail-only, zero inline search; `findsNothing(AppSearchField)` pin + code confirm; shell icon `selectedIndex != 0` + `showTechnicianTodaySearch(allJobs)` untouched. No >5 gate applied per deviation B — correct, no C16 duplicate path.
- U2 fit PASS: single-column `ListView.separated`, no table; 360 idle rail + first row above fold, second peeking; 768 tablet single column, full plate `XYZ 5678 / ABC 1234 / DEF 9012` + full `Starts 10:30 / 08:30 / 11:15`, max-width intact.
- U3 no-fake PASS: rows = chevron navigation entries, tap → dossier; rail/Clear/Retry/Refresh map 1:1; zero per-row buttons (deviation C honored).
- U4 no-invention PASS: `JC-102 / Nissan Yaris / XYZ 5678 / 0 of 1` verbatim, `0` honest zero; `_urgentFirst` order pinned Delayed→In Progress→Pending visible in every idle frame.
- U5 reachable+legible PASS with sanctioned secondary ellipsis (agree round-1 adjudication): 360/tablet full meta legible; 320 `XYZ 56… / Starts 1…`, 1.3x `XYZ 56… / ABC 1… / Starts …` — PRIMARY (vehicle, JC ref, pills, counts line, chevron, footer) whole, no clip/overflow; brief U5 sanctions 1-line ellipsis; full values 1 tap away (dossier). Non-gating.
- U6 states PASS (pixel-verified): loading 4-row shimmer mirror; empty `No assigned jobs + There are no jobs… + Refresh`; error `Something went wrong + We couldn't load… + Retry`; no-match `filter` frame narrows to 1 row + `Clear`; stale `AppBanner` warning pin + `RefreshIndicator` + `Updated 09:41` footer in all frames.
- U7 feedback PASS: stub-route pin exercises real `openJob/push/closeJob`; one search / one filter / one open path.
- U8 no-dead-ends PASS: every row chevron-tappable; empty→Refresh, no-match→Clear, error→Retry, stale→pull.
- U9 consistency PASS: `AppFilterBar`/`AppDivider`/`AppBanner`/`AppEmptyState`/`AppErrorState`/`AppShimmerSkeleton` same atoms.
- U10 RTL PASS: ar frame mirrored (rail `الكل 3`, rows right-aligned, chevron `<`), plates `XYZ 5678` + `JC-10x` + `09:41` LTR-locked, footer `09:41` intact.
- U11 a11y PASS (stills-limited): `countSemantics` rail + kept row Semantics + error live-region per pins; 320/1.3x no overflow.
- U12 density PASS: 1-col compact; tablet single column, no grid chunking per N/A-by-design.
- U13 offline PASS: stale-kept + banner pin, footer clock deterministic `09:41`, retries inline.
- U14 no-regression PASS: tap budgets identical (see §2), predicates/order/keys/shell/sheet untouched.

**U fails: 0. C17 cap: none.**

## 2. Tap walk BEFORE→AFTER (brief budgets = ceilings)

Open list ≤1 (tab seat unchanged) same ✓; Find sheet 1+keystrokes+1 single path identical + chip 1 same ✓ (no inline resurrected); Filter 1 same ✓; Open dossier 1 tap 0-scroll same ✓ (urgent-first keeps Delayed top, no buttons added); Clear no-match 1 same ✓ (`updateSearch('')+updateFilter('All')`); Retry 1 / pull + freshness same ✓ (`Updated 09:41` all frames). **No budget regresses.**

## 3. C16 hard-reject checklist (ANY hit caps 10/16)

Single search path (shell icon, blessed, no inline) PASS; rail-only toolbar PASS; borderless rows PASS; no filled CTA added (selected `All 3` = filter state) PASS; one path per task PASS; no permanent pills PASS; no ALL CAPS PASS; above-fold+peek PASS; zero as `0` PASS. **No cap.**

## 4. Airbnb rubric (ONLY after §§1–3): 2+2+2+2+2+2+2+2 = 16/16

One-task → dossier 2; headline hierarchy 2; whitespace borderless 2; sheets-for-search 2; sticky-CTA correctly absent 2; rail structure 2; plain copy 2; single emphasized action (zero in-body fills) 2. Merit 16/16, C16 no-cap, C17 no-cap. **Final 16/16 — PASS.**

## 5. Defect list (gating first)

**Gating defects: NONE.** No C16 hit, no U fail, no tap breach on any path incl. blessed single-search contract.
**Non-gating (agree + filed, do not gate):** (1) secondary-meta ellipsis at 320/1.3x, primary whole — sanctioned per U5, 1-tap recoverable; (2) contact sheet left≈right — expected chrome-only rebuild around frozen shared row (deviation D); (3) `references/`+`AIRBNB_PATTERNS.md` UNMET — precedent + blessed audit used per brief.

## Verdict

**AGREE with round-1. Final score 16/16 — PASS. Gating found: ZERO.**

(End — round 2 second-reviewer confirmation, 2026-10-22)
