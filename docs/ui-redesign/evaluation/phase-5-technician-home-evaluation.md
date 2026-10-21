# Phase 5 — Technician Home / Today — Fresh Re-Review ROUND 2 (PASS, 15/16)

**Role:** FRESH RE-REVIEWER (round 2, post-fix). Did not build or fix this screen. READ-ONLY except this file. No production/tests/ARB/captures edited. No branch switch, commit, or push.
**Branch:** `ui/dashboards-2`.
**Governance read first:** `docs/ui-redesign/briefs/phase-5-technician-home.md` (authoritative); round-1 evaluation in this file's history (single U5 gating fail — hero CTA truncation; fixer stacked CTAs vertically full-width).
**Redesign mandate + caps:** C16 hard-reject (caps 10/16) + U0–U14 C17 (ANY U-law fail caps 8/16). Pass ≥ 12/16 with caps applied.
**Dark:** n/a — zero dark PNGs supplied; staff app is light-only per brief.
**Stopwatch caveat:** ticking `TechnicianStopwatch` HH:MM:SS causes small drift across frames (14:21:20 / :21 / :22) — layout/structure judged, not stopwatch glyph pixels. Not a layout fail.
**Queue-meta note:** plate / `Starts …` ellipsis in queue rows is permitted secondary-text truncation, not a U5 fail.
**Images viewed (10 after + 3 contact sheets, full resolution):**
- AFTER (10): `docs/ui-redesign/baseline/after-technician-home/` — `today_1.0_en_360x800`, `today_1.0_ar_360x800`, `today_1.3_en_360x800`, `today_1.3_ar_360x800`, `today_1.0_en_320x568`, `today_1.0_en_768x1024`, `today_1.0_en_1180x820`, `today_empty_en_360x800`, `today_error_en_360x800`, `today_search_open_en_360x800`.
- Contact sheets (3): `docs/ui-redesign/baseline/` — `phase-5-technician-light.png` (BEFORE en 360x800 vs AFTER en 360x800), `phase-5-technician-ar.png` (BEFORE ar vs AFTER ar), `phase-5-technician-tablet.png` (BEFORE en 360x800 vs AFTER 768x1024 vs AFTER 1180x820). Cross-checked against standalone PNGs; consistent.
**Code read (read-only, tap-count verification):** `apps/staff_app/lib/features/technician/presentation/widgets/technician_today_view.dart` (hero now `Column`-stacked primary + secondary, `_primaryAction` path unchanged), `technician_today_search.dart` (unchanged from round 1).

---

## 1. DESCRIPTION — region by region, WITHOUT judging

### Reference frame: AFTER idle light 360 — `today_1.0_en_360x800.png`

- **Header region (top):** left-aligned bold headline `Today`, muted sub-line `Morning shift · Working` beneath it. A magnifier search glyph sits at the TOP-RIGHT, on the SAME row as the title.
- **Hero current-work card region:** one large white rounded card. Top row: `Toyota Camry` (left) + pale-blue pill `● In Progress` (right, sentence case). Second row: muted mono `JC-101` (left) + outlined plate chip `ABC 1234` (right). Then bold task title `Replace brake pads`. Then stopwatch row `● ELAPSED 14:21:20` (blue `ELAPSED`, tabular digits). Then `1 of 3 tasks completed` + full-width progress bar (~1/3 filled). Bottom: TWO FULL-WIDTH BUTTONS STACKED VERTICALLY — filled blue `✓ Complete task` on top, outlined `👁 Job details` below, both labels whole.
- **Quick-action tile region:** three equal white rounded tiles in one row: `Tasks` (blue checklist icon), `Request part` (blue box icon), `Escalate` (red warning-triangle icon). Labels single-line at 1.0x.
- **Up-next region:** section header row `Assigned queue` (left) + blue `View all` (right). Two flat rows with hairline separators: row 1 pale-blue-tinted `Nissan Yaris` / `JC-102` with red `● ⓘ DELAYED` pill + `XYZ 5678` plate chip + `Starts 10:…` (ellipsis) + `>`; row 2 white `Toyota Hilux` / `JC-103` with amber `● ◷ PENDING` pill + `DEF 9012` + `Starts 11:…` (ellipsis) + `>`. Red/amber left status bars on each row.
- **Task-steps region:** heading `Tasks`, then step rows with status icons + hairline dividers: `✓ Task 1, Change engine oil, Completed` (further steps below fold in this frame; full 3-step list visible in tablet frames).
- **Nav region:** no bottom nav/rail visible inside any 360/320 capture — captures are tab-level (Today tab only).

### BEFORE vs AFTER (per `phase-5-technician-light.png` contact sheet)

- BEFORE: punch strip card (`Working`, `1h 0m worked · O…`, filled `Take break`), `On the bay` + ALL-CAPS eyebrow `CURRENT WORK`, bordered card with ALL-CAPS blue `IN PROGRESS` + ALL-CAPS chip `● IN PROGRESS`, side-by-side `👁 Jo…` + `Complete task` row, three OUTLINED tiles, `Assigned queue` + `View all` + ALL-CAPS eyebrow `UP NEXT`, same tinted queue rows, `Shift summary` strip (`1`, `1/6`, `0`) at the bottom.
- AFTER deltas: punch strip + `CURRENT WORK`/`UP NEXT` eyebrows + summary strip gone (shift/attendance folded into header subtitle); hero gains vehicle + ref + sentence-case chip; CTAs stacked vertically full-width; tiles lose outlines (shadow instead); `View all`, queue grammar, steps grammar kept; search icon ADDED top-right; no job invented/removed, no route changed.

### Arabic — `today_1.0_ar_360x800.png` (+ `phase-5-technician-ar.png`)

- Mirrored RTL: right-aligned `اليوم`, sub-line `يعمل · Morning shift` (shift name English LTR, attendance Arabic). Search glyph top-LEFT (end side), same row as title. Hero mirrored: `Toyota Camry` + `In Progress` chip (English LTR), `ABC 1234` + `JC-101` LTR, `Replace brake pads` (English), `● المنقضي 14:21:20` (digits LTR), `1 من 3 مهام` + progress bar filling from the right. Buttons stacked vertically, both full: filled `إكمال المهمة ✓`, outlined `تفاصيل المهمة` with eye icon — no truncation. Tiles mirrored with Arabic labels (`تصعيد` / `طلب قطعة` / `المهام`). Queue mirrored: `قائمة المهام المسندة` + `عرض الكل`, rows with English ALL-CAPS `DELAYED`/`PENDING` pills + LTR plates + `يبدأ 10:30` / `يبدأ 11:15`, chevron `<` flipped. Steps: `المهام` heading, mixed Arabic + English step grammar. No `…` on Arabic words; no mirrored digits.

### 1.3x — `today_1.3_en_360x800.png` / `today_1.3_ar_360x800.png` (U5 re-check frames)

- en 1.3x: same regions/order. Hero shows full-width `✓ Complete task` then full-width `👁 Job details` — BOTH labels whole. `Request part` tile wraps to two lines (`Request` / `part`); queue rows show `XYZ 56…` / `Starts …` secondary-text ellipsis. Steps below fold.
- ar 1.3x: filled `إكمال المهمة ✓` whole, outlined `تفاصيل المهمة` whole; queue meta `يبدأ…` / `XYZ 56…` secondary ellipsis.
- No overflow markers, no clipped glyphs in either 1.3x frame.

### 320px — `today_1.0_en_320x568.png` (U5 re-check frame)

- Same order compressed: header + top-right search intact; hero with full-width `✓ Complete task` then full-width `👁 Job details` — BOTH labels whole at 320. Three tiles intact in one row (`Request part` wraps to 2 lines); `Assigned queue` + `View all` header at capture bottom. Nothing clips, no overflow markers.

### Tablets — `today_1.0_en_768x1024.png` / `today_1.0_en_1180x820.png` (+ tablet contact sheet)

- 768 (medium): header row with search top-right; LEFT column = hero (stacked full `Complete task` + `Job details`, both whole) + three tiles (`Request part` single-line) ; queue rows (`XYZ 5…` / `Starts …` secondary ellipsis); RIGHT column = `Assigned queue` + `View all` + queue rows, `Tasks` steps (all 3 visible: Completed / In Progress / Pending) + `Updated 09:41` freshness footer.
- 1180 (expanded): same two-column split wider — stacked hero buttons whole; queue rows full (`XYZ 5678 Starts 10:30`, `DEF 9012 Starts 11:15`); freshness `Updated 09:41` bottom-right.

### Search sheet — `today_search_open_en_360x800.png`

- Full-screen sheet over dimmed Today board (hero/buttons dimmed behind): drag handle, title `Search jobs`, `×` close top-right, rounded input (`🔍 Search jobs`, empty query), then three result rows in shared queue grammar with progress sub-lines: `Toyota Camry JC-101 ● IN PROGRESS ABC 1234 Starts 08:30 ≋ 1 of 3 tasks completed`; `Nissan Yaris JC-102 ● DELAYED XYZ 5678 Starts 10:30 ≋ 0 of 1`; `Toyota Hilux JC-103 ● PENDING DEF 9012 Starts 11:15 ≋ 0 of 2`. Result rows carry `>` chevrons. No query chip duplicating input.

### Remaining states (light 360)

- `today_empty_en_360x800.png`: header (`Today` + subtitle + search) kept mounted; centered pale-blue circle clipboard glyph; title `No assigned jobs right now`; message `You have no repairs assigned for this shift. Pull to refresh, or check back when the de…` (2-line ellipsis); ONE full-width filled `Refresh`.
- `today_error_en_360x800.png`: centered soft-red circle `!`; title `We couldn't load today's work`; sentence `Check your connection and try again.`; full-width filled `Retry`. No raw exceptions.

---

## 2. U0–U14 walk (each with image + region evidence; ANY fail caps at 8/16)

| Law | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — fewer steps, never hunt/tap more than necessary | `today_1.0_en_360x800` hero + tiles + queue rows: next action (hero `Complete task`), parts, escalate, first queue rows all reachable at launch, zero scroll; `today_search_open` focuses input and lists all loaded jobs with zero typing | PASS |
| U1 — search ICON top-right → full-screen search, never inline | `today_1.0_en_360x800` / `320` / `1.3x` / `768` / `1180` header regions: search glyph pinned to END side of the SAME title row on EVERY breakpoint; `today_1.0_ar_360x800` + `today_1.3_ar_360x800`: mirrored top-LEFT same-row (correct end side). Sheet (`today_search_open`): full-screen sheet + handle + search field + `×` close, no inline field | PASS |
| U2 — first actionable item above the fold at 360x800 idle | `today_1.0_en_360x800`: hero card + `Complete task` CTA + all three tiles + first queue row fully in-capture. Holds at `today_1.3_en_360x800` (stacked CTA block in-capture) | PASS |
| U3 — tap counts (brief BEFORE vs AFTER; details in §3) | Code-verified 1→1 on all three (see §3 table); `today_1.0_en_360x800` shows hero primary CTA + both tiles tappable at launch, 0 scroll | PASS |
| U4 — frequent action reachable without scrolling, lower half or sticky | `today_1.0_en_360x800`: `Complete task` + `Request part` + `Escalate` all above the fold at launch, 0 scroll; tablet frames keep hero CTA + tiles in the left column | PASS |
| U5 — no truncation of primary text; rows fit or scroll with clean peek (ROUND-1 GATING ITEM — RE-CHECKED) | `today_1.0_en_320x568.png`: hero shows FULL `✓ Complete task` + FULL `👁 Job details` (no `…` anywhere in the CTA block). `today_1.3_en_360x800.png`: FULL `✓ Complete task` + FULL `👁 Job details` at large text (prior `Complete ta…` gone). `today_1.3_ar_360x800.png`: FULL `إكمال المهمة` + FULL `تفاصيل المهمة`. `today_1.0_en_360x800` / `today_1.0_ar_360x800` / `768` / `1180`: both buttons whole. Queue `Starts 10:…` / plate ellipsis is permitted secondary-text meta and is NOT counted; empty-message 2-line ellipsis is C8-compliant (max 2 lines) and is NOT counted | **PASS (fix verified)** |
| U6 — calm empty: no filled CTA to nothing | `today_empty_en_360x800`: `Refresh` targets a real reload; `today_error_en_360x800`: `Retry` targets a real reload. One filled action each; no CTA pointing at nothing | PASS |
| U7 — one path per task; See-all only when more exists than shown | Exactly ONE filled CTA per screen state (hero `Complete task`; empty `Refresh`; error `Retry`). `Tasks`-tile + `Job details`-secondary + queue/search rows open the same dossier but with DIFFERENT labels and secondary/ghost styling — navigation entries, not same-label filled twins. `View all` shown only when queue non-empty (code `seeAllLabel: upcoming.isEmpty ? null`), hidden when empty; destination is the fuller Jobs tab (`selectTab(1)`), brief-mandated. No See-all on the Tasks steps (full checklist shown) | PASS (View-all nuance disclosed in §3) |
| U8 — relevance: completed/history never under Assigned/To-do | N/A here by construction — say so: this screen has NO Assigned/To-do list. The `Assigned queue` excludes completed + qcReview by predicate; the `Tasks` steps checklist shows per-step honest statuses (`Completed` / `In Progress` / `Pending`). No completed-under-assigned pattern exists to violate | PASS (N/A, stated) |
| U9 — consistency: same element, same place across screens/apps | Header/search/hero→tiles→queue→steps order identical across en/ar/360/320/1.3x/tablets. Stacked-CTA shape identical on every frame (only width changes) | PASS |
| U10 — feedback/forgiveness; errors say what to do next | `today_error_en_360x800` (what + next: `We couldn't load today's work` / `Check your connection and try again.` + `Retry`); `today_empty_en_360x800` (what + `Refresh`). No offline/stale frame supplied — `AppBanner` + stale-board claim UNVERIFIED from stills. Haptic/toast timing not provable from stills | PASS (stills-limited; offline frame missing) |
| U11 — readable numbers: zero is 0, stats labelled/visible/decision-helping | `1 of 3 tasks completed`, `JC-101`, `ABC 1234`, tabular stopwatch digits, queue `Starts 08:30/10:30/11:15` all fully visible at 1.0x; ar keeps `JC-101`/`ABC 1234`/digits LTR. No `–`/`-` anywhere in the 10 after frames | PASS |
| U12 — one background colour, no stray bands | All 10 after frames: single page background; hero/tiles are white cards, not bands. Note (not counted): the emphasised first queue row carries a full-bleed pale-blue status tint — shared queue grammar, always paired with dot + label (never color alone) | PASS (with noted tint) |
| U13 — new-employee test: plain words in 3 seconds | `Today`, `Morning shift · Working`, `Replace brake pads`, `Complete task`, `Job details`, `Request part`, `Escalate`, `Assigned queue`, `View all`, `1 of 3 tasks completed`. Residual (not counted): ALL-CAPS `DELAYED`/`PENDING` chips + `ELAPSED` label (brief-KEPT shared grammar), backend shift string `Morning shift` untranslated inside the ar subtitle, domain step labels in English inside ar steps | PASS (residuals disclosed) |
| U14 — a11y: ≥48dp targets, AA, Semantics, 1.3x + 320px without clipping | `today_1.3_en/ar_360x800` + `today_1.0_en_320x568`: zero overflow markers, ellipsis-instead-of-clipping throughout, three tiles fit one row at 320 (`Request part` wraps to 2 lines, no clip), stacked buttons full-width ≥48dp rows, code carries `Semantics` labels on tiles/steps/progress. Exact dp/contrast/Semantics need instrumented tests | PASS (stills-limited) |

**U-walk fails: 0.** Round-1 U5 gating fail is FIXED and verified at all three mandated frames (`today_1.0_en_320x568.png`, `today_1.3_en_360x800.png`, `today_1.3_ar_360x800.png`) plus base/tablets. Nothing double-counted.

---

## 3. Top-3 tap-count walk — BEFORE → AFTER (from code structure; fixer changed presentation only)

BEFORE counts (brief §Top-3, verified against before pixels + code): (1) start/complete = task-card CTA (**1 tap, 0 scroll**); (2) request part = parts action → request sheet (**1 tap, 0 scroll**); (3) escalate = escalate action → sheet (**1 tap, 0 scroll**).

AFTER walk (code `technician_today_view.dart` + pixels; read-only grep confirms hero is now a `Column` of primary + secondary with `onPrimaryAction: () => _primaryAction(activeJob)` unchanged, code ll.127–154, 211):

1. **Start / complete the current task** — `today_1.0_en_360x800` hero: tap filled `Complete task` → `_primaryAction` → `notifier.completeTask(job, running)` DIRECTLY (no intermediate screen; held→resume, pending→start same path). **1 tap, 0 scroll.** Alternative: `Tasks` tile / `Job details` → dossier (navigation, not required).
2. **Request a part** — tap `Request part` tile → `_openPartRequest` → `showAppModalSheet(PartsRequestSheet)`. **1 tap, 0 scroll.**
3. **Escalate / report a blocker** — tap `Escalate` tile → `_openEscalation` → `showAppModalSheet(EscalationSheet)`. **1 tap, 0 scroll.**

| Task | Before | After | Verdict |
|---|---|---|---|
| Start / complete current task (hero primary CTA) | 1 tap, 0 scroll (task-card CTA) | 1 tap, 0 scroll (stacked full-width primary → direct `completeTask`/`startTask`) | same ✓ |
| Request a part (tile → sheet) | 1 tap, 0 scroll | 1 tap, 0 scroll (tile → `PartsRequestSheet` sheet) | same ✓ |
| Escalate (tile → sheet) | 1 tap, 0 scroll | 1 tap, 0 scroll (tile → `EscalationSheet` sheet) | same ✓ |

**Tap-count result: PASS — no frequent task takes more taps than before; the most frequent (start/complete, 1 tap) is ≤ 2.**
**Show-all check:** `View all` rendered ONLY when queue non-empty (`seeAllLabel: upcoming.isEmpty ? null`) → correctly absent on empty queue; with 2/2 rows shown + `View all` visible in captures, the destination is the fuller Jobs tab (`selectTab(1)`), not a same-list expansion, and the queue is a `take(5)` window so more can exist in production — brief-mandated pattern, disclosed, not a U7 hit.
**Search-icon U1 check:** search icon end-side of the SAME header row on every breakpoint → full-screen search sheet over loaded jobs (`today_search_open_en_360x800`), ref/vehicle/customer/plate match, LTR refs, result tap = same dossier contract — no new routes/logic. PASS.

---

## 4. Airbnb rubric 0–2 each (8 criteria, total /16, pass ≥ 12/16) — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Execution screen: current-work hero (ONE primary CTA) → tiles → queue → steps; no widget grid, single primary action per state |
| 2 | Headline-first hierarchy | 2/2 | `Today` → `Morning shift · Working` → hero vehicle/task → CTA; empty/error keep headline order; calm empty keeps header mounted |
| 3 | Whitespace, no boxes-in-cards | 2/2 | Hero/tiles/queue separated by whitespace, queue is flat rows with hairline dividers (never cards-in-cards), tiles borderless+shadow in light; round-1 CTA-row squeeze GONE — stacked full-width buttons render whole on every frame including 320 and 1.3x |
| 4 | Sheets for secondary actions | 2/2 | Search is a full sheet (handle + autofocus field + clear + rows); parts/escalation are bottom sheets; no dialogs-for-pickers; destructive n/a |
| 5 | Sticky CTA (home has none) | 2/2 | Correctly absent — counted by omission per prior rounds (primary CTA lives in-flow, no sticky bar claimed) |
| 6 | Section structure with Show-all | 2/2 | Header → hero → tiles → Assigned queue + View all → Tasks steps → freshness footer; View-all correctly absent when queue empty (code); steps show the full checklist |
| 7 | Plain friendly copy, no invented claims | 1/2 | Sentence-case hero chip, verb-first buttons, honest error/empty, translated ar with LTR codes, zero new keys, no invented statuses/times — but residual ALL-CAPS `DELAYED`/`PENDING` chips (queue + search rows) and ALL-CAPS `ELAPSED` stopwatch label persist from brief-KEPT shared grammar (−1) |
| 8 | Single emphasized primary action | 2/2 | Exactly one filled CTA in every captured state (hero `Complete task`; empty `Refresh`; error `Retry`); `Job details` correctly secondary/outlined |
| **Merit total** | | **15/16** | Pass on merit (≥12) |
| **C17 cap** | ANY U-law violated caps at **8/16** | n/a | Zero U-law fails in round 2 — no cap applied |
| **C16 hard-reject** (caps 10/16) | checklist | all PASS | borderless-light-cards PASS (hero/tiles shadow, no outlines); ONE-filled-per-screen PASS; duplicate-entry PASS (different-label/secondary navigation entries only); above-the-fold PASS (§U2); no-orphan-tiles PASS (3-col row fits 320–1180, wraps without clipping); search-sheet PASS (§U1); card-hierarchy PASS (vehicle → meta → task → progress → stacked CTA); carousel-peek n/a PASS. Residual ALL-CAPS (criterion 7) is brief-KEPT shared grammar with zero new ALL CAPS added by this rebuild — disclosed, not a fresh HIT |

**Verdict: PASS — bless as U-clean. 15/16 (merit 15/16, pass ≥ 12/16, no caps applied). Round-1 gating U5 fail fixed and verified.**

### Remaining violations: none gating. One non-gating residual (same as round 1, out of scope for this phase)

1. **(Non-gating)** Screen still shows ALL-CAPS `DELAYED`/`PENDING` (queue + search rows) and `ELAPSED` (stopwatch) — owned by brief-KEPT shared components (out of scope here; do NOT touch shared components in the technician fix round). Recommend the owning phase move shared pills/stopwatch to sentence case. Costs only Airbnb criterion 7 (−1); no U-law hit.

### The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `today_1.0_en_360x800`: `Today / Morning shift · Working` names the place and state, the hero says `Toyota Camry — Replace brake pads — 1 of 3 tasks completed — [Complete task]`, with `Job details` + `Tasks / Request part / Escalate` directly below. The next step is unambiguous: tap `Complete task`. The round-1 friction (unidentifiable `Jo…` secondary, `Complete ta…` primary at large text) is gone — both buttons read in full on every frame.
- **What would an Airbnb product designer reject here?** Nothing blocking. One nit to carry forward: residual ALL-CAPS status pills (`DELAYED`/`PENDING`) and `ELAPSED` next to an otherwise sentence-case screen — owned by shared grammar, fix at the owning phase.
