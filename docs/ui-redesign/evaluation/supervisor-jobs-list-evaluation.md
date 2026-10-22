# Supervisor Jobs list — Fresh review ROUND 1 (PASS 15/16)

**Role:** FRESH REVIEWER (round 1), never built this screen. READ-ONLY except this file. No code/tests/PNGs edited. No branch/commit/push. Never touched `7198329`.
**Branch:** `ui/list-ops`.
**Read first:** Brief `docs/ui-redesign/briefs/supervisor-jobs-list.md` (authoritative, incl. sanctioned deviations: sv-jobs KEEPS both searches — inline register filter + shell bar bay-search on different targets, adjudicated; tech header-only; owner single inline; sv-queue/review no list-search; STOP boundaries honored); migration `docs/ui-redesign/evaluation/supervisor-jobs-list-test-migration.md` (behavior pins: 8/8 GREEN before and after); REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 C17 (brief §§U0–U14 is the authoritative application). Pass ≥ 12/16 with caps.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (both per brief §References, confirmed UNMET — not pretended; precedent patterns from phase-5/phase-7 + vehicles-list used instead).
**Images viewed (AFTER via Read, full resolution + BEFORE for contrast):**
- AFTER `docs/ui-redesign/baseline/after-supervisor-jobs/`: `idle_light_1.0_en_360x800`, `idle_light_1.0_en_320x568`, `idle_light_1.3_en_360x800`, plus `empty`, `error`, `loading` frames listed (structure confirmed via migration pins; idle + stress frames pixel-verified here).
- BEFORE `docs/ui-redesign/baseline/before-supervisor-jobs/`: `idle_light_1.0_en_360x800` (structure contrast only; frozen record, never regenerated).
- Contact sheet `docs/ui-redesign/baseline/phase-sv-jobs-light.png`: BEFORE (left) vs AFTER (right) side-by-side.
**Code read-only (attribution only):** `apps/staff_app/.../widgets/supervisor_jobs_tab.dart` (`AppPageHeader:71`, `AppPillButton.primary:75`, `AppSearchField:91`, `AppFilterBar:96`, `AppErrorState:108`, `AppShimmerSkeleton:233`, `AppEmptyState:238,250`, `AppProgressBar:346`, `AppDivider:365` — grep-confirmed, no legacy `PrimaryButton`/`EmptyState`/`AppSkeleton`/`AppInfoPanel`/`AppLinearProgress`/raw `Divider` remain).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle en 360 — `idle_light_1.0_en_360x800.png`
- **Header region:** clipboard glyph + bold `Active jobs`; muted `3 on the floor` below; full-width blue pill `Assign work` with hard-hat glyph beneath.
- **Summary region:** one wrapped strip: `3 Total` (black numeral) `● 1 In progress` (teal numeral) `● 1 Completed` (green numeral); second line `● 1 Parts delay` (amber numeral).
- **Filter region:** rounded search field with magnifier + hint `Search job card, customer, or plate`; below, chip rail: filled blue `All`, outlined `In progress 1`, `Completed 1`, `Par…` (fourth chip cut at frame edge).
- **Row 1 region:** left teal rail; bold `Camry ABC 1234`; muted `JC-101  Ahmed`; right teal pill `● In Progress`; blue partial bar + `2/5 tasks` right.
- **Row 2 region:** left green rail; bold `Civic DEF 9012`; muted `JC-102  Sara`; right green pill `Completed` with check glyph; full red bar + `4/4 tasks` right.
- **Row 3 region:** left amber rail; bold `Hilux XYZ 1111`; muted `JC-900  Khalid`; right amber pill `Waiting for Parts` with clock glyph; blue partial bar + `1/4 tasks` right. Pale divider below each row.

### AFTER 320px — `idle_light_1.0_en_320x568.png`
- Same header + full-width `Assign work`; summary strip identical; search hint truncated `Search job card, customer, or pl…`; rail `All` + `In progress 1` + `Completed 1` + cut chip; rows 1–3 fully present with rails, pills, bars, counts on one visual row each.

### AFTER 1.3x — `idle_light_1.3_en_360x800.png`
- Same structure; summary wraps to two lines (`Completed` / `Parts delay` second line); search hint truncated `Search job card, customer,, …`; rail chips same; all three rows present, pills + counts intact, no overflow markers.

### BEFORE vs AFTER (contact sheet `phase-sv-jobs-light.png`)
- BEFORE left: `Assign work` is a small left-aligned rounded button (not full-width); progress bars teal (row 1), green full (row 2), amber (row 3); pills identical labels/icons.
- AFTER right: `Assign work` spans full width; row-1 bar blue (was teal), row-2 full bar red (was green), row-3 bar blue (was amber); all copy, rails, pills, dividers otherwise identical in seat and label.

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — one read: identity → jobCard + customer → progress → pill; no competing hero; slim count strip | idle-360 rows: `Camry ABC 1234` → `JC-101 Ahmed` → bar + `2/5 tasks` → pill; header `Active jobs` → `3 on the floor` → summary strip (text, no cards). Code `:71` header, `:346` meter, pills via `supervisorStatusPill` (kept helper) | PASS |
| U1 — find fast: inline register filter ALWAYS present (STOP exception) + status rail; shell bar bay-search untouched; NO header search icon added | idle frames: inline `AppSearchField` present (`:91`) + rail (`:96`); header carries only `Assign work`, no magnifier. Different entity/fields/scope vs bar sheet per brief deviation A | PASS (sanctioned dual-search: different targets) |
| U2 — fit: grouped divider rows, NOT a table; FOLD: header + summary + filter + FIRST row above fold, second peeking @360x800 | idle-360: rows are borderless divider rows (`AppDivider :365`), no table; first row complete, rows 2–3 visible in scroll frame (frame is window-cropped above nav; structure matches brief wireframe order) | PASS |
| U3 — no fake actions: rows display-only (no row tap invented); Assign/Retry/Clear map 1:1 | Rows show no chevron/action; `Assign work` → same sheet; Clear resets query+filter; Retry → `refreshDashboard` (migration pins) | PASS |
| U4 — no invention: jobCard/vehicle/customer/status verbatim; zero as `0` | `JC-101`, `Camry ABC 1234`, `Ahmed`, pills from `supervisorStatusKind`; counts `3 Total · 1/1/1` from `allJobs` + buckets | PASS |
| U5 — reachable + legible: 48dp Assign/chips/Clear; wrap never clip @320/1.3x; jobCard LTR; customer/vehicle ambient | 320: rows intact, hint ellipsized (hint only, not content); 1.3x: summary wraps 2 lines, rows intact, pills whole; rail edge-cut = horizontal scroll affordance, content reachable | PASS |
| U6 — states: skeleton mirrors rows; honest empty (1 icon + 1 sentence + 1 Assign → same sheet); no-match + Clear; error + Retry; stale kept + pull-to-refresh | `AppShimmerSkeleton.listRows(rows: 6) :233`; `AppEmptyState` empty (`:238`) + no-match (`:250`, title `commonNoResults`); `AppErrorState` (`:108`, retry → same refresh); `RefreshIndicator` kept per migration | PASS (code + pins; idle pixels confirm row-mirroring shape) |
| U7 — feedback: assign opens EXISTING sheet (same contract); snackbars unchanged; one path per task (register filter vs bay lookup = different tasks) | `AppPillButton.primary` header Assign same label/handler (`:75`); no new routes/keys; STOP dual-search is different-target, not twin-path | PASS |
| U8 — no dead ends: every state offers live control; no badge-only rows | Rows carry pill + progress (info, not actions — actions live header/empty); empty→Assign, no-match→Clear, error→Retry, pull always | PASS |
| U9 — consistency: `AppPageHeader`, `AppFilterBar`, divider rows, `AppBanner`/`AppInfoPanel` same staff atoms | `:71` header, `:91` field, `:96` rail, `:365` divider, `:108/:238` states — same family as queue/review/tech | PASS |
| U10 — RTL: full mirror; jobCard/figures LTR (`Directionality` kept); rail uses `marginEnd` | ar idle frame exists in set (migration matrix); code keeps `supervisorMono` LTR locks per brief (pins GREEN) | PASS (stills-limited; pins hold) |
| U11 — a11y: row `Semantics` (vehicle + jobCard + status); header `Semantics(header: true)`; live-region on error | Kept per migration (behavior pins GREEN 8/8); no overflow evidence in 320/1.3x frames | PASS (stills-limited for Semantics) |
| U12 — density: 1-col compact; wider canvas single-column register (grid N/A by design) | 360/320 single column; tablet frame in set keeps single-column register per brief | PASS |
| U13 — offline: bar banner owns offline; stale kept + notice; retries inline | Provider/refresh contracts untouched per migration; no new offline UI | PASS (code pins) |
| U14 — no regression: tap budgets ceilings; pull-to-refresh, keys, sheet + snackbar unchanged | See §3; keys/sheet/snackbar byte-identical per migration | PASS |

**U-walk fails: 0.**

---

## 3. Top-task tap walk BEFORE→AFTER (budgets ≤ before)

BEFORE (brief §Top tasks, verified from code per migration): open 1 (tab) · find 1 + keystrokes (+scroll) · assign 2 (tab + header/empty Assign) · clear 1 · retry 1 / pull.

| Task | Before | After (pixels + code) | Verdict |
|---|---|---|---|
| Open list | 1 tap (Jobs tab; 0 deep-linked) | ≤ 1 tap (tab seat unchanged; `IndexedDB` stack index 1 untouched) | same ✓ |
| Find job | tab + type and/or chip = 1 + keystrokes | Identical: inline field (`:91`, same 4-field predicate) + rail (`:96`, same buckets/counts/clear) | same ✓ |
| Open assign | 2 taps (header or empty Assign → same sheet) | ≤ 2: full-width `Assign work` (idle frames) + empty-state Assign; same `showSupervisorAssignSheet` contract | same ✓ |
| Clear no-match | 1 tap | ≤ 1 (`AppEmptyState` Clear → same reset, `:250`) | same ✓ |
| Retry / refresh | 1 tap / pull | ≤ 1 / pull (`AppErrorState` retry → same `refreshDashboard`; pull kept) | same ✓ |

**Tap result: PASS — no budget regresses; frequent action (filter → assign) stays single-screen.**

---

## 4. Airbnb rubric 0–2 each, /16, pass ≥ 12/16 — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find job → assign. Register + filter + one header action; no competing hero |
| 2 | Headline-first hierarchy | 1/2 | Identity → jobCard + customer → progress → pill holds; −1: row 2 pairs a green `Completed` pill with a full RED progress bar (danger tone on a terminal state; BEFORE was green). Status still pill-carried per brief, so not a U-fail — but the two signals disagree |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless divider rows on page surface; no card wrappers added (deviation C) |
| 4 | Sheets for secondary actions | 2/2 | Assign already IS the sheet; no new dialogs; bar bay-sheet untouched |
| 5 | Sticky CTA (none claimed) | 2/2 | Correctly absent; Assign lives header/empty-state, never both |
| 6 | Section structure | 2/2 | Header + count strip + inline + rail + rows; counts update, no-match + Clear |
| 7 | Plain friendly copy, no invented claims | 2/2 | Verbatim keys, zero new; sentence-case pills; zero as `0`; no ALL CAPS added |
| 8 | Single emphasized primary action | 2/2 | Exactly one filled accent per state (Assign); progress bars are meters, not CTAs |
| **Merit total** | | **15/16** | Pass on merit (≥ 12) |
| **C16 hard-reject cap** | borderless-light / one-filled-per-group / one-path-per-task / no-permanent-pills / no-ALL-CAPS / above-fold+peek / hierarchy / zero-as-0 | **No cap** | ALL PASS: borderless ✓; one filled (Assign) ✓; dual search = different tasks (sanctioned STOP) ✓; pills data-only ✓; no ALL CAPS ✓; first row + peek ✓; zero `0` ✓ |
| **C17 U-cap** | ANY U-law fail caps at 8/16 | **No cap** | Zero U fails (§2) |
| **Final** | | **15/16 — PASS** | |

---

## ROUND-1 DEFECT LIST (gating first, honestly)

**Gating defects: NONE.** No C16 hard-reject hit, no U-law fail, no tap-budget breach.

**Non-gating (scored or filed, do NOT gate this verdict):**
1. **Completed-row progress bar renders full RED against a green `Completed` pill — SCORED (−1, criterion 2).** `phase-sv-jobs-light.png` AFTER row 2 (`Civic DEF 9012`, `4/4 tasks`) + `idle_light_1.0_en_360x800.png`; code `supervisor_jobs_tab.dart:346` (`AppProgressBar(value:)`, auto tone). BEFORE rendered the same state green. Status remains pill/rail-carried per brief deviation (so no U0/U7 fail), and tests pin math not tone — but the shared atom's auto tone now contradicts the pill on terminal states. For owning phase: confirm `AppProgressBar` tone mapping (complete = success-green, not danger-red). Shared-atom fix, not a screen-logic change.
2. **Search hint truncates at 320px/1.3x** (`…or pl…`) — hint text only, field still focuses + filters; U5 explicitly tolerates hint ellipsis. Filed, non-gating.
3. **Rail edge chip cut (`Par…`)** — horizontal scroll affordance, all buckets reachable; sanctioned rail pattern. Non-gating.
4. **Process artifacts (not screen defects):** `references/` + `AIRBNB_PATTERNS.md` UNMET per brief (precedent used); ar/tablet/error/empty/loading frames relied on via migration pins + matrix, pixel-verified here for idle/320/1.3x/contact-sheet only.

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `idle_light_1.0_en_360x800.png`: `Active jobs / 3 on the floor`, counts strip, `Search job card, customer, or plate`, `All / In progress 1 / Completed 1`, rows `Camry ABC 1234 → JC-101 Ahmed → 2/5 tasks → In Progress`, and one full-width `Assign work`. Next step is unambiguous: filter, then Assign.
- **What would an Airbnb product designer reject here?** Nothing blocking. One honest nit: the completed row's full-red meter fights its green `Completed` pill — fix the shared progress-tone mapping, not this screen.

(End of file — round 1, 2026-10-22)

---

# Fresh review ROUND 2 — independent confirmation (CONFIRMED PASS 15/16, ZERO gating)

**Role:** FRESH REVIEWER (round 2), never built this screen. READ-ONLY except this append. No code/tests/PNGs edited. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/list-ops` (verified via `git branch --show-current`).
**Read first:** Brief `docs/ui-redesign/briefs/supervisor-jobs-list.md` (authoritative, incl. sanctioned Deviation A dual-search, B header-assign, C borderless rows); migration `supervisor-jobs-list-test-migration.md` (8/8 GREEN before+after); round-1 above (kept verbatim).
**Images viewed (AFTER via Read, full resolution):** all 10 in `docs/ui-redesign/baseline/after-supervisor-jobs/` — `idle_light_1.0_en_360x800`, `idle_light_1.0_en_320x568`, `idle_light_1.3_en_360x800`, `empty`, `error`, `loading`, `filter`, `search`, `idle_light_1.0_ar_360x800`, `idle_light_1.0_en_768x1024` — plus contact sheet `phase-sv-jobs-light.png` (BEFORE left vs AFTER right).
**Code read-only (grep attribution):** `supervisor_jobs_tab.dart` — `AppPageHeader:71`, `AppPillButton.primary:75`, `AppSearchField:91`, `AppFilterBar:96`, `AppErrorState:108`, `AppShimmerSkeleton.listRows:233`, `AppEmptyState:238,250`, `AppProgressBar:346`, `AppDivider:365`; zero remaining `PrimaryButton`/`EmptyState(`/`AppSkeleton`/`AppInfoPanel`/`AppLinearProgress`/raw `Divider(` in this file. STOP kept: bar bay-search scaffold-owned, no header search icon added.

## Round-2 U0–U14 walk (independent)

| Law | Evidence | Verdict |
|---|---|---|
| U0 | idle-360/tablet: `Camry ABC 1234 → JC-101 Ahmed → bar + 2/5 tasks → pill`; header → `3 on the floor` → slim text strip, no cards | PASS |
| U1 | inline `AppSearchField` always present + rail in every idle/empty/error/loading frame; header = Assign only, no magnifier; different target from bar bay-search per Deviation A | PASS (sanctioned dual-search) |
| U2 | borderless divider rows (`AppDivider`), no table; fold order header + strip + filter + row 1, rows 2–3 visible in scroll frame; tablet single-column | PASS |
| U3 | rows display-only (no chevron/tap); Assign/Clear/Retry map 1:1 to same sheet/reset/refresh per migration | PASS |
| U4 | `JC-101/Camry ABC 1234/Ahmed`, pills from `supervisorStatusKind`; `3 Total · 1/1/1`, empty shows `0` as `0` | PASS |
| U5 | 320: rows intact, hint ellipsis only; 1.3x: strip wraps 2 lines, pills/counts intact; rail edge-cut = scroll affordance | PASS |
| U6 | `loading` shimmer mirrors rows; `empty` 1 icon + `No active jobs` + 1 Assign; `filter` no-match rail + Clear; `error` + Retry; `RefreshIndicator` per pins | PASS |
| U7 | `AppPillButton.primary` header Assign → same `showSupervisorAssignSheet`; no new routes/keys; register-filter vs bay-lookup = different tasks | PASS |
| U8 | empty→Assign, filter→Clear, error→Retry, idle→Assign/filter, pull always; no badge-only rows | PASS |
| U9 | `:71/:91/:96/:108/:238/:365` — same App* family as queue/review/tech | PASS |
| U10 | ar frame: full mirror, `Camry ABC 1234 / JC-101 / 2/5 tasks` LTR-locked, rail on opposite side | PASS |
| U11 | Semantics/header/live-region kept per pins (8/8 GREEN); no overflow in 320/1.3x | PASS (stills-limited) |
| U12 | 360/320 1-col; tablet `768x1024` single-column register, rail + rows max-width (grid N/A by design) | PASS |
| U13 | provider/refresh untouched per migration; no new offline UI; bar owns banner | PASS (code pins) |
| U14 | see tap walk below; keys/sheet/snackbar byte-identical per migration | PASS |

**U-walk fails: 0.**

## Round-2 tap walk (BEFORE ≤ AFTER)

BEFORE (brief): open 1 · find 1 + keystrokes · assign 2 · clear 1 · retry 1 / pull. AFTER (pixels + pins): open ≤1 (tab seat intact) · find same (identical field `:91` + rail `:96`, `search` frame narrows `sara` → 1 row) · assign ≤2 (full-width header Assign + empty-state Assign, same sheet) · clear ≤1 (`filter` frame Clear) · retry ≤1 / pull (error Retry → same refresh). **Tap result: PASS — no budget regresses.**

## Round-2 C16 checklist (incl. dual-search sanction)

borderless light rows ✓ · one filled accent per section (Assign only; bars are meters) ✓ · one-path-per-task (inline register-filter vs bar bay-search = different entity/fields/scope/contract, sanctioned STOP — does NOT fire) ✓ · no permanent pills (data-only) ✓ · no ALL CAPS ✓ · first row above fold + second peeking ✓ · hierarchy title → pill → meta ✓ · taps never regress ✓ · zero as `0` ✓. **No C16 cap. No C17 cap (0 U-fails).**

## Round-2 rubric (only after above)

1:2/2 · 2:1/2 (−1 completed-row full RED bar vs green `Completed` pill — tone mismatch, merit-only) · 3:2/2 · 4:2/2 · 5:2/2 · 6:2/2 · 7:2/2 · 8:2/2. **Merit 15/16, Final 15/16 — PASS (≥12/16).**

## Agreement

**AGREE with round-1.** Score CONFIRMED: **15/16 PASS.** Gating defects found: **ZERO** (no C16 hit, no U-fail, no tap breach). Sole −1 is the already-filed non-gating shared-atom tone nit (complete = danger-red not success-green), owned by `AppProgressBar` phase, not this screen.

(End of file — round 2, 2026-10-22)
