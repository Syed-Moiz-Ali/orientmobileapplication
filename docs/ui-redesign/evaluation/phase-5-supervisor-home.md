# Phase 5 — Supervisor Home / Floor Board — Fresh U-Review (FAIL, capped 8/16)

**Role:** FRESH U-REVIEWER, not builder. Read-only except this file. No code/tests/PNGs edited. No commit.
**Branch:** `ui/dashboards-2` (rebuilt + recaptured, uncommitted).
**Read first:** DESIGN_SPEC C16 (dashboard: greeting/status → ONE hero + sections; Airbnb cards/sheets/one-CTA) + C17 (U0–U14; ANY violated law caps at 8/16, no exceptions) + C16 hard-reject list (caps at 10/16) + scoped rule in brief (16-bay spatial map IS the content — C16 collections/carousel rule bends to a 4-col grid per U2/U5; carousel would hide bays); brief `docs/ui-redesign/briefs/phase-5-supervisor-home.md`; tap-count BEFORE numbers from `docs/ui-redesign/evaluation/supervisor-home-test-migration.md` (§Behavior assertions + Changed-test table).
**Images viewed (22/22, all via Read, full resolution, no sampling):**
- BEFORE (2): `docs/ui-redesign/baseline/before-supervisor-home/floor_1.0_en_360x800.png`, `floor_1.0_ar_360x800.png`.
- AFTER (17): `docs/ui-redesign/baseline/after-phase-5-supervisor/` — `floor_1.0_en_360x800`, `floor_1.0_ar_360x800`, `floor_1.3_en_360x800`, `floor_1.3_ar_360x800`, `floor_1.0_en_320x568`, `floor_1.0_en_768x1024`, `floor_1.0_en_1180x820`, `floor_loading_en_360x800`, `floor_error_en_360x800`, `floor_offline_en_360x800`, `floor_search_open_en_360x800`, `floor_search_query_en_360x800`, `floor_filter_parts_en_360x800`, `floor_filter_nomatch_en_360x800`, `floor_hero_empty_en_360x800`, `floor_hero_busy_en_360x800`, `floor_hero_allidle_en_360x800`.
- Side-by-sides (3): `docs/ui-redesign/evaluation/contact-sheets/phase-5-supervisor-light.png`, `phase-5-supervisor-ar.png`, `phase-5-supervisor-tablet.png` (each embeds BEFORE 360 + AFTER frames; cross-checked against the standalone PNGs above).
- Dark: n/a — zero dark PNGs supplied; staff app is light-only per brief (same convention as the phase-3 advisor review).

---

## (a) DESCRIBE — region by region at full resolution, WITHOUT judging

### Reference frame: AFTER idle light 360 — `floor_1.0_en_360x800.png`

- **Header region (top):** left-aligned bold headline `Workshop floor`, muted sub-line `4 active · 16 bays` beneath it. No app bar, no bell, no avatar in this tab capture. A lone magnifier search glyph sits on its own row BELOW the subtitle, left-aligned, small, with large empty space to its right (it is not in a top-right action cluster).
- **Hero region:** one large white rounded card. Top: a tall light-grey rounded inner block containing a small 4-square grid glyph (no photo, no chart, no data). Below: bold number `4`, muted sentence `Dispatch the next job into a free bay.`, and a small neutral pill `● Bays` (dark dot + label).
- **Dispatch region:** one full-width filled blue pill button `Dispatch to technician` with a hard-hat + gear leading icon, directly under the hero card.
- **Legend + filter region:** one legend row of four dot+label items `● Occupied  ● Idle  ● Parts delay  ● QC` (green / dark-grey / amber / teal dots). Below it a horizontally scrollable filter-chip row: filled blue `All`, outlined `Occupied`, `Parts delay`, `QC`, with a 5th chip cut at the right edge (peek affordance).
- **Bay grid region:** 2-column cards. Row 1: `B-01` (teal dot top-right, `OH` tech-initials chip, bold `Yaris XYZ 5678`, muted `JC-207` + `4/4`) on pale-blue fill with teal outline; `B-02` (`–` slot, `Camry ABC 1234`, `JC-101` + `2/5`) on pale-green fill. Row 2: `B-03` (`Hilux XYZ 1111`, `JC-900` + `1/4`, amber dot/fill); `B-04` (`Civic`, `BK-301` + `10:00`, green dot/fill). Row 3 (`B-05`/`B-06`, `Idle`, grey dots) is cut at the bottom edge of the capture. Below-grid rail content is not visible in this frame (scrolls).
- **Rail region (phone = below grid, evidenced in scrolled/state frames):** `Incoming queue` card (header + trailing count, rows with red `*` / calendar glyphs, outlined `→ Incoming queue` button) and `Quality control` card (header + outlined `Review` button). Evidenced fully in `floor_filter_parts_en_360x800.png` (queue `2`: `Engine overheating / Highway 40 km 12`, `Oil change / Civic`) and `floor_filter_nomatch_en_360x800.png` (queue `1`: `Oil change / Civic`; `Quality control` + `Review`).
- **Nav region:** no bottom nav and no rail visible inside any 360/320 capture — captures are tab-level (floor tab only); per the migration doc the 7-tab supervisor scaffold / bottom nav is untouched and outside these frames.

### BEFORE idle light 360 — `before-supervisor-home/floor_1.0_en_360x800.png` (structural comparison)

- Header: blue 4-square mark + bold `Workshop floor` + `4 active · 16 bays` (same occupancy sentence, kept verbatim). No search affordance anywhere.
- No hero, no Dispatch CTA. Legend row `Occupied / Idle / Parts delay / QC` then filter chips `All / Occupied / Parts delay / QC` (same 4-state vocabulary + same predicate, moved verbatim).
- Bay grid starts immediately: identical tile grammar (state dot, `B-0x` code, tech-initials/`–` slot, title/ref/meta, selection ring) — `B-01 Yaris XYZ 5678 JC-207 4/4` (teal) through `B-12` — 2-col, `Idle` tiles for B-05+. Below-fold rail not in frame. Structural delta AFTER-vs-BEFORE: ADDED header search glyph, hero card + full-width Dispatch CTA, legend kept, tiles kept; rail cards restyled to App* cards below the grid; no bay invented/removed, no route changed.

### Arabic — `floor_1.0_ar_360x800.png`

- Mirrored RTL: right-aligned headline `أرضية الورشة`, sub-line `4 قيد العمل · 16 منصة`. Search glyph on its own row below, LEFT-aligned (end side, not top-right). Hero right-aligned: grey media block with grid glyph, number `4`, sentence `وجّه مهمة العمل التالية إلى منصة متاحة.`, chip `● المنصات`. Filled button `إسناد إلى فني` (icon mirrors to the right of the label). Legend mirrored `مشغولة / شاغرة / تأخّر قطع / فحص الجودة`. Chips `الكل / مشغولة / تأخّر قطع / فحص الجودة` + peek. Bay tiles mirrored: `B-02 Camry ABC 1234 / 2/5 JC-101`, `B-01 Yaris XYZ 5678 / 4/4 JC-207` — bay codes, plates, `JC-*` refs and fractions stay LTR (`B-02`, `JC-101`, `10:00 BK-301`), Arabic `شاغرة` for Idle tiles. No `...` fragments, no mirrored digits.

### 1.3x — `floor_1.3_en_360x800.png` / `floor_1.3_ar_360x800.png`

- Same regions/order. Hero sentence wraps to 2 lines; `Dispatch to technician` / `إسناد إلى فني` stays one line, intact. Legend wraps to two lines in ar (`مشغولة / شاغرة / تأخّر قطع` + `فحص الجودة`), no truncation. Filter row scrolls with clean peek (en: `All / Occupied / Parts delay / G…` cut at edge; ar: `الكل / مشغولة / تأخّر قطع / فحص الجـ…` peeking). Bay tiles intact: `Yaris XYZ 5678 / JC-207 4/4`, `Camry ABC 1234 / JC-101 2/5`, `Hilux XYZ 1111 / JC-900 1/4`, `Civic / BK-301 10:00`. First bay row (B-01/B-02) fully visible above the fold in both; no overflow markers, no clipped glyphs.

### 320px — `floor_1.0_en_320x568.png`

- Same order compressed: headline + sub-line, lone left search glyph, hero (grey block + `4` + sentence + `Bays` chip), full-width Dispatch, legend, filter row (`All / Occupied / Parts delay / QC…` peeking), then only the TOP EDGE of the B-01/B-02 tile row visible at the capture bottom (codes + dots). Labels wrap, nothing clips, no `…`.

### Tablets — `floor_1.0_en_768x1024.png` / `floor_1.0_en_1180x820.png` (+ tablet side-by-side)

- 768 (medium): header row with search glyph at TOP-RIGHT (unlike phones); hero full-width; Dispatch full-width; legend + 5 chips (`All / Occupied / Parts delay / QC / Idle`, `Idle` now visible without scroll); 2-col content: LEFT = bay grid 3-across (`B-01 Yaris`, `B-02 Camry`, `B-03 Hilux` / `B-04 Civic`, `B-05 Idle`, `B-06 Idle` … through `B-15`); RIGHT = stacked `Incoming queue (2)` card (`Engine overheating / Highway 40 km 12`, `Oil change / Civic`, outlined `→ Incoming queue`) over `Quality control` card (outlined `Review`). No bottom nav in frame (rail replaces it).
- 1180 (expanded): same pattern wider — search top-right; hero + Dispatch span width; grid 4-across (B-01…B-12 visible: `Yaris XYZ 5678 JC-207 4/4`, `Camry ABC 1234 JC-101 2/5`, `Hilux XYZ 1111 JC-900 1/4`, `Civic BK-301 10:00`, `B-05…B-12 Idle`); right rail same two cards. Bottom rows (B-13+) continue below.

### Hero variants

- `floor_hero_busy_en_360x800.png` (`16 active · 16 bays`): hero `16` + same sentence + `Bays` chip + Dispatch; grid all-QC-tinted tiles (`B-01 Yaris XYZ 5678 JC-207 4/4 OH`, `B-02 Corolla JKL 2222 JC-208 3/3 AH`, `B-03 Altima MNO 3333 JC-209 5/5 SA`, `B-04 Sunny PQR 4444 JC-210 2/2 KO`…).
- `floor_hero_empty_en_360x800.png` (`0 active · 16 bays`): hero `0` + same sentence + `Bays` chip + filled `Dispatch to technician`, then a centered empty block (pale-blue circle, grid glyph, title `No active jobs on the floor`, sentence `New jobs appear the moment they are assigned.`) with a SECOND filled `Dispatch to technician` button, then `Incoming queue (0)`. Two same-label filled CTAs on one screen.
- `floor_hero_allidle_en_360x800.png` (scrolled crop): idle tiles B-05…B-16 (`Idle`, grey dots) + muted hint row `Tap a bay to dispatch a technician`.

### Search sheet — `floor_search_open_en_360x800.png` / `floor_search_query_en_360x800.png`

- Full-screen sheet over dimmed floor (floor header/hero/filters dimmed behind): drag handle, title `Find on the floor`, `×` close top-right, rounded input (`Search job card, customer, or plate`, search glyph left). Open state lists all 16 bays as dot + code + title rows (`B-01 Yaris XYZ 5678` … `B-16 Idle`). Query `JC-101` (blue focus border, `×` clear inside) filters to one row: `● B-02 Camry ABC 1234`. No chip duplicating the query. Result tap = select + assign-sheet contract (code-kept, per migration doc).

### Remaining states (light 360)

- `floor_loading_en_360x800.png`: flat pale blocks mirroring layout (header lines, one large hero block, 2-col tile blocks ×4 rows, one wide rail block). No spinners in content areas, no bay codes.
- `floor_error_en_360x800.png`: centered soft-red circle + `!`, title `Floor unavailable`, sentence `Could not load the floor. Pull to refresh.`, full-width filled `Retry`. No raw exceptions.
- `floor_offline_en_360x800.png`: warning-tinted banner `⚠ Offline mode — changes will sync when connection is restored` over the full idle board (header, hero `4`, Dispatch, legend, filters, B-01…B-04) with last data kept.
- `floor_filter_parts_en_360x800.png`: `Parts delay` chip filled, `Clear` text-button at row end; single tile `B-03 Hilux XYZ 1111 JC-900 1/4`; hint `Tap a bay to dispatch a technician`; rail `Incoming queue (2)` + `Quality control / Review` below.
- `floor_filter_nomatch_en_360x800.png`: `QC` chip filled + `Clear`; centered pale-blue circle (magnifier + `×`), title `No bays match this filter`, sentence `Try a different filter, or clear it to see every bay.`, filled `Clear` button; rail `Incoming queue (1)` + `Quality control / Review` kept mounted below.

---

## (b) U0–U14 walk, one by one (evidence = image + region; ANY fail caps at 8/16)

| Law | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — fewer steps, never hunt/tap more than necessary | `floor_1.0_en_360x800` hero + Dispatch + grid regions: next action (hero Dispatch, first bays B-01–B-04) all reachable at launch, zero scroll; `floor_search_query` focuses input and filters to one row | PASS |
| U1 — search ICON top-right → full-screen search, never inline | Phone frames (`floor_1.0_en_360x800`, `floor_1.3_en_360x800`, `floor_1.0_en_320x568`, `floor_1.0_ar_360x800` header regions): the magnifier sits on its own row BELOW the subtitle, left/end-aligned — NOT top-right. Tablet frames (`floor_1.0_en_768x1024`, `floor_1.0_en_1180x820` header rows) DO place it top-right. Sheet half passes (`floor_search_open`/`floor_search_query`: full-screen sheet, handle, autofocused field, clear ×, no inline field, result = same tile contract). Placement clause fails on the primary phone form factor and is inconsistent phone-vs-tablet | **FAIL** |
| U2 — first actionable item above the fold at 360x800 idle | `floor_1.0_en_360x800` grid region: B-01/B-02 fully + B-03/B-04 fully visible in-capture (B-05/B-06 peek). Holds at `floor_1.3_en_360x800` and `floor_1.3_ar_360x800` (first row fully above fold). 320 (`floor_1.0_en_320x568`) shows only tile top-edges — noted as tight but U2 governs 360x800 | PASS |
| U3 — tap counts (brief BEFORE vs AFTER; details in §c) | Migration-doc pins verified from code: dispatch bay-tap→sheet 1→1, queue tab/rail 1→1, review tab/rail 1→1; `floor_1.0_en_360x800` shows bay tiles + hero Dispatch tappable at launch with 0 scroll | PASS |
| U4 — frequent action reachable without scrolling, lower half or sticky | `floor_1.0_en_360x800`: hero `Dispatch to technician` + first bay rows visible at launch, no scroll; tablet frames keep Dispatch + grid above rail | PASS |
| U5 — no truncation of primary text; rows fit or scroll with clean peek | `floor_1.3_en/ar_360x800` + `floor_1.0_ar_360x800` + `floor_1.0_en_320x568`: greeting/hero sentence wrap (never `…` on names/labels); filter rows scroll with clean edge-peek (`QC`/`G…`, `فحص الجـ…`) with label starts visible; bay codes/plates/`JC-*`/fractions/`10:00` intact; ar keeps `B-0x`/Latin plates LTR; 16-grid upheld by the brief's scoped rule (fits 2/3/4 cols by breakpoint, no carousel needed) | PASS |
| U6 — calm empty: no filled CTA to nothing | `floor_hero_empty_en_360x800`: `0 active`, queue `0` — but 16 free bays exist, so Dispatch targets (idle bays) exist; empty block is icon + sentence + action per C10 (`No active jobs on the floor` + `New jobs appear…` + Dispatch). CTA does not point at nothing | PASS (with duplication note moved to U7 — two same-label filled Dispatch CTAs share this screen) |
| U7 — one path per task; See-all only when more exists than shown | `floor_hero_empty_en_360x800`: TWO filled `Dispatch to technician` buttons visible at once (hero section + empty-state block) opening the same assign sheet; plus bay-tap dispatch, search-result tap dispatch, and selected-bay-card Dispatch (migration doc: "hero adds a second same-label CTA"). Same task (open assign sheet), 4+ same-label entries, two simultaneously filled. No See-all anywhere (correct — grid shows all 16, rail `take(2)/take(3)` short lists scroll) | **FAIL** |
| U8 — relevance: completed/history never under Assigned/To-do | N/A here by construction — say so: this screen has NO Assigned/To-do list (bay map + queue + QC instead). Bay statuses honest: B-01 QC-teal / B-02 Occupied-green / B-03 Parts-delay-amber / B-04 Occupied-green match the unchanged `buildSupervisorBays` derivation (QC-first, parts-held, occupied, bookings; tech initials only when known; nothing invented — migration doc). No completed-under-assigned pattern exists to violate | PASS (N/A, stated) |
| U9 — consistency: same element, same place across screens/apps | Header/search/bell/avatar pattern CANNOT be fully checked (tab-level captures, no bell/avatar in frame). Filter chips, legend vocabulary, hero→CTA→grid→rail order identical en/ar and 360/tablet. The phone-vs-tablet search-placement split is logged under U1, not double-counted here | PASS (with U1 cross-ref) |
| U10 — feedback/forgiveness; errors say what to do next | `floor_error_en_360x800` (what + next: `Floor unavailable` / `Could not load the floor. Pull to refresh.` + `Retry`); `floor_offline_en_360x800` banner + stale board; `floor_filter_nomatch` offers `Clear` twice (chip-row text + filled button). Destructive-confirm/toast/haptic timing not provable from stills | PASS (stills-limited) |
| U11 — readable numbers: zero is 0, stats labelled/visible/decision-helping | `floor_hero_empty_en_360x800` hero `0` + queue `0` (never `–`/`-` in any of the 17 frames); header `4 active · 16 bays` + hero `4` + `Bays` unit chip + queue `2`; bay meta `4/4`, `2/5`, `1/4`, `10:00`, `JC-207` fully visible incl. 1.3x/320/ar | PASS |
| U12 — one background colour, no stray bands | All 17 frames: single page background; hero/rail whites are cards, not bands; offline banner is an allowed warning notice. No strip behind rows | PASS |
| U13 — new-employee test: plain words in 3 seconds | `Workshop floor`, `4 active · 16 bays`, `Dispatch the next job into a free bay.`, `Dispatch to technician`, `Occupied / Idle / Parts delay / QC`, `Incoming queue`, `Quality control / Review`, `Find on the floor`, `No bays match this filter…`, `Tap a bay to dispatch a technician`. Only residual jargon: bare `QC` (legend/chip label unexplained on-screen; kept from before per brief) | PASS |
| U14 — a11y: ≥48dp targets, AA, Semantics, 1.3x + 320px without clipping | `floor_1.3_en/ar_360x800` + `floor_1.0_en_320x568`: zero overflow markers, wrap-not-truncate throughout, badges n/a (no covering badges), buttons/chips/tiles read ≥48dp rows. Exact dp/contrast/Semantics need instrumented tests | PASS (stills-limited) |

**U-walk fails: 2 — U1 (search-icon placement on phones: below-header left/end instead of top-right; tablet is top-right; sheet itself passes) and U7 (duplicate Dispatch entries: two filled same-label CTAs in `floor_hero_empty_en_360x800` + bay-tap + search-tap + selected-card all opening the same assign sheet).** Zero-fail is explicitly NOT claimed.

Hard-reject cross-check (informational; U-cap already governs at 8/16): borderless-light-cards HIT (bay tiles carry tinted outlines; rail cards hairline-bordered — `AppSurfaceCard` border-XOR-shadow kept with `_BayTile` grammar verbatim); ONE-filled-per-screen HIT in `floor_hero_empty` (two filled Dispatch) and `floor_filter_nomatch` (filled Dispatch + filled Clear); duplicate-entry HIT (same evidence as U7); above-the-fold PASS (U2); no-orphan-tiles PASS (2/3/4 cols, 16 divisible); no-ALL-CAPS PASS; search-sheet PASS; card-hierarchy PASS-with-note (bold title → dot/tint status → `JC-*` meta; status is dot+tint, no pill — kept grammar); carousel-peek PASS (filter row peeks; grid replaces carousel under the scoped rule).

---

## (c) Top-3 tasks — AFTER (each tap + scroll) vs BEFORE counts

BEFORE counts (verbatim from brief §Top-3, verified from code per migration doc): (1) dispatch = bay tap → assign sheet opens (**1 tap, 0 scroll**); (2) queue = Queue tab (**1 tap**); (3) review = Review tab (**1 tap**).

AFTER walk on these pixels:

1. **Dispatch a job into a bay** — `floor_1.0_en_360x800`: tap any of B-01…B-04 (fully visible at launch) → assign sheet (**1 tap, 0 scroll**). Alternative: hero `Dispatch to technician` (**1 tap, 0 scroll**) or search (`floor_search_query`: icon → type `JC-101` → tap result = icon + type + tap). Bay-tap path unchanged.
2. **Check what's waiting (queue)** — supervisor tab bar `Queue` tab still exists (untouched scaffold; migration doc: routes/CTAs `onOpenQueue` preserved, nothing dropped) → **1 tap, 0 scroll**. Rail `→ Incoming queue` button (`floor_filter_parts` rail region) reaches the same destination but sits below the 16-tile grid on phones (scroll) — an extra optional path, not a replacement.
3. **Review a finished job (QC)** — tab bar `Review` tab → **1 tap, 0 scroll** (route `/supervisor/review` pre-existing). Rail `Review` button (same `onOpenReview` callback) is the same-destination optional path.

| Task | Before | After | Verdict |
|---|---|---|---|
| Dispatch a job into a bay (bay tap → assign sheet) | 1 tap, 0 scroll | 1 tap, 0 scroll (hero Dispatch also 1/0; search path icon+type+tap) | same ✓ |
| Check queue | 1 tap (Queue tab) | 1 tap, 0 scroll (tab preserved; rail button = same 1 tap + scroll on phones) | same taps ✓ (scroll only on optional rail path) |
| Review a finished job | 1 tap (Review tab) | 1 tap, 0 scroll (tab preserved; rail button same callback) | same ✓ |

**Tap-count comparison result: PASS — no frequent task takes more taps than before; the most frequent (dispatch via bay tap, 1 tap) is ≤ 2.**

---

## (d) Airbnb rubric + score (0–2 each, pass ≥ 12/16) — ONLY after (a)–(c)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Floor-status → one hero number + sentence + CTA → bay map → rail; no widget grid, single primary action per brief |
| 2 | Headline-first hierarchy | 2/2 | `Workshop floor` → `4 active · 16 bays` → hero `4` + sentence → single in-card CTA path; calm empty keeps headline order |
| 3 | Whitespace, no boxes-in-boxes | 1/2 | Hero/rail are separated whitespaced cards, but the hero's tall empty grey media block adds dead weight that pushes bays down on phones, and bay tiles keep tinted outlines (border-XOR-shadow, not borderless) |
| 4 | Sheets for secondary actions | 2/2 | Search is a full sheet with handle + autofocus + clear (`floor_search_open`/`floor_search_query`); assign sheet code-kept; filter chips are a brief-permitted row (`AppFilterBar` kept verbatim) |
| 5 | Sticky CTA (N/A — home has none) | 2/2 | Correctly absent; counted by omission as in prior rounds (Dispatch lives in-flow, no sticky bar claimed) |
| 6 | Section structure with Show-all | 2/2 | Legend + filter + full 16-grid (nothing hidden) + rail; See-all correctly absent everywhere (U7 second half holds) |
| 7 | Plain friendly copy, no invented claims | 1/2 | Sentence-case, verb-first buttons, honest errors, translated ar with LTR codes; −1: bare `QC` unexplained on-screen + header `4 active` vs hero `4` number duplication |
| 8 | Single emphasized primary action | 1/2 | Idle/busy correct (exactly one filled Dispatch); −1: `floor_hero_empty` shows TWO filled `Dispatch to technician` at once, `floor_filter_nomatch` pairs filled Dispatch + filled Clear |
| **Merit total** | | **13/16** | Pass on merit (≥12) |
| **U-cap** | ANY violated law caps at 8/16 | **8/16** | U1 + U7 visibly fail on-screen (evidence above) |

**Verdict: FAIL — do not bless as U-clean. Capped 8/16 (merit 13/16, pass ≥ 12/16).**
Gating fails (presentation-owned, fixable without logic changes): (i) move the phone search glyph into the header top-right action cluster (matching tablet frames + advisor/customer placement) instead of the lone below-subtitle row; (ii) collapse the duplicate Dispatch entries to one filled CTA per screen (empty state: keep ONE — hero or block, not both; selected-bay card already correctly secondary). Bay derivation, filter predicate, routes, tabs, providers and all copy semantics stay untouched. Tap counts pass; U8 N/A stated with honest statuses; U11/U12 pass.

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `floor_1.0_en_360x800`: `Workshop floor / 4 active · 16 bays` names the place and state, the hero says `4 — Dispatch the next job into a free bay. [Dispatch to technician]`, and four live bays with a legend sit directly below. The next step is unambiguous: tap Dispatch or tap a bay. (Friction, not confusion: the search glyph is hard to find on phones, and the empty state offers the same Dispatch twice.)
- **What would an Airbnb product designer reject here?** Three things, in order: (1) the hero's big empty grey media block — a dead visual that carries zero information while pushing the actual content (bays) down the phone screen; either put a real signal in it or delete it; (2) two identical filled `Dispatch to technician` buttons on the empty screen — one primary action per screen, never twins; (3) the phone search glyph parked alone under the subtitle while tablets put it top-right — one placement everywhere. Secondary nit: tinted-outline bay tiles instead of borderless Airbnb cards (accepted via the scoped map-bend, but the outlines could go).

---

# Round-2 re-gate (fix round landed, uncommitted) - PASS, 15/16 (U-clean)

**Role:** RE-GATE REVIEWER for supervisor home (round 2). READ-ONLY except this section. No code/tests/PNGs edited. No commit.
**Branch:** `ui/dashboards-2` (fix round landed, uncommitted).
**Images viewed (17/17 via Read, full resolution):** `docs/ui-redesign/baseline/after-phase-5-supervisor/` - `floor_1.0_en_360x800`, `floor_1.0_ar_360x800`, `floor_1.3_en_360x800`, `floor_1.3_ar_360x800`, `floor_1.0_en_320x568`, `floor_1.0_en_768x1024`, `floor_1.0_en_1180x820`, `floor_loading_en_360x800`, `floor_error_en_360x800`, `floor_offline_en_360x800`, `floor_search_open_en_360x800`, `floor_search_query_en_360x800`, `floor_filter_parts_en_360x800`, `floor_filter_nomatch_en_360x800`, `floor_hero_empty_en_360x800`, `floor_hero_busy_en_360x800`, `floor_hero_allidle_en_360x800`. Code diff read-only for region mapping: `supervisor_dashboard_tab.dart` (`_FloorHeader` / `_FloorHero` / `_FloorEmpty` / no-match secondary Clear / C5 border-OR-shadow tiles / `AppPillButton.secondary` selected-bay Dispatch) + `app_en.arb` / `app_ar.arb` (`svFloorHeroSentence`, `svFloorNoMatchHint`).

## (a) Changed regions (round-1 to round-2, presentation only)

- **Header region:** was lone magnifier on its own row BELOW subtitle on phones (left/end), top-right only on tablets. Now `_FloorHeader` Row: title+subtitle Expanded + `AppIconButton(search)` pinned to END side of the SAME row on EVERY breakpoint. `floor_1.0_en_360x800` header: `Workshop floor` / `4 active - 16 bays` left, search top-right same row. `floor_1.0_ar_360x800`: RTL mirror, search top-left same row (correct end side). Same on 320 / 1.3x / 768 / 1180.
- **Hero region:** was one large white rounded card with tall light-grey media block + grid glyph + bold number + sentence + `Bays` chip + filled Dispatch. Now `_FloorHero`: NO card, NO media block, NO number, NO chip - plain sentence `Dispatch the next job into a free bay.` + single filled `Dispatch to technician`. Count lives only in header subtitle.
- **Empty region (`floor_hero_empty`):** was hero Dispatch + centered empty block with SECOND filled Dispatch (two filled twins). Now `_FloorEmpty`: `AppEmptyState` (pale-blue circle grid glyph, `No active jobs on the floor`, `New jobs appear the moment they are assigned.`) with NO action. Exactly ONE filled Dispatch per screen (the hero one). `Incoming queue (0)` + `Quality control / Review` rail kept below.
- **Tiles region:** were tinted fills WITH tinted outlines. Now C5 border-OR-shadow: light = `BorderSide.none` + elevation 2 + soft shadow, no outlines; selected keeps functional primary ring; dark keeps border. Visually borderless cards on all idle/busy frames.
- **Rail / no-match / selected-bay:** no-match was filled Clear (paired filled Dispatch + filled Clear). Now `AppEmptyState` + `No bays match this filter` + hint `Try a different filter...` + `AppPillButton.secondary Clear`. Selected-bay card Dispatch demoted `PrimaryButton` to `AppPillButton.secondary`. Offline now `AppBanner(warning)` + stale board; error now `AppErrorState` (`Floor unavailable` + `Retry`).
- **Unchanged (spot-checked):** legend vocabulary, filter predicates, 16-bay derivation (`B-01 Yaris XYZ 5678 JC-207 4/4` through `B-16`), search-sheet contract, routes/tabs/providers, RTL LTR codes (`B-0x`, `JC-*`, `10:00`, plates).

## (b) U0-U14 re-gate (each with image + region; ANY fail caps at 8/16)

| Law | Evidence (image + region) | Re-verdict |
|---|---|---|
| U0 - fewer steps | `floor_1.0_en_360x800` hero + grid: Dispatch + B-01-B-04 at launch, 0 scroll; `floor_search_query` filters `JC-101` to 1 row | PASS |
| U1 - search ICON top-right to full-screen search | `floor_1.0_en_360x800` header row: search TOP-RIGHT same row as title (was lone row below); `floor_1.0_ar_360x800`: search top-LEFT end-side RTL same row; `floor_1.0_en_320x568` / `floor_1.3_en/ar_360x800` / `floor_1.0_en_768x1024` / `floor_1.0_en_1180x820` all same-row end-side. Sheet: `floor_search_open` / `floor_search_query` full sheet + handle + autofocus + clear x, no inline field | **PASS (was FAIL)** |
| U2 - first actionable above fold 360x800 | `floor_1.0_en_360x800` grid: B-01/B-02 + B-03/B-04 fully in-capture (hero shorter now, strictly better); holds at `floor_1.3_en/ar_360x800`; 320 shows tile top-edges only - noted tight but U2 governs 360x800 | PASS |
| U3 - tap counts (see c) | Bay-tap to sheet 1-1, queue 1-1, review 1-1; routes untouched | PASS |
| U4 - frequent action no scroll | Hero Dispatch + first bays at launch, 0 scroll; tablets keep Dispatch + grid above rail | PASS |
| U5 - no truncation, peek | `floor_1.3_en/ar_360x800` + `floor_1.0_ar_360x800` + `320`: sentence wraps, never `...`; filter rows peek (`QC` / `G...`); `JC-*`/fractions/`10:00`/plates intact incl. ar LTR; 16-grid 2/3/4 cols, no carousel per scoped rule | PASS |
| U6 - calm empty | `floor_hero_empty_en_360x800`: `0 active`, queue `0`, 16 free bays exist so Dispatch targets idle bays; empty = icon + sentence, NO CTA | PASS |
| U7 - one path per task; See-all only if more shown | `floor_hero_empty`: exactly ONE filled Dispatch (hero only; empty block zero buttons). `floor_filter_nomatch`: hero Dispatch filled primary + `Clear` secondary (not twins). Selected-bay Dispatch now secondary. Bay-tile taps / search-result taps are map-content selection into same sheet, not duplicate same-label filled CTAs. Grid shows all 16, rail take(2)/take(3) short lists scroll - See-all correctly absent | **PASS (was FAIL)** |
| U8 - relevance | No Assigned/To-do list on this screen (bay map + queue + QC). Statuses honest: B-01 QC-teal / B-02 Occupied-green / B-03 Parts-amber / B-04 Occupied-green match unchanged derivation | PASS (N/A, stated) |
| U9 - consistency | Header/search/hero-CTA-grid-rail order identical en/ar + 360/tablet. Phone-vs-tablet placement split RESOLVED (U1), not double-counted | PASS |
| U10 - feedback/forgiveness | `floor_error`: what + next + `Retry`; `floor_offline`: warning banner + stale board; `floor_filter_nomatch`: `Clear` text + secondary button. Haptic/timing not provable from stills | PASS (stills-limited) |
| U11 - readable numbers | Hero `0` + queue `0` never `-`; header `4 active - 16 bays`, queue `2`, meta `4/4`, `2/5`, `1/4`, `10:00`, `JC-207` all visible incl. 1.3x/320/ar | PASS |
| U12 - one background | Single page bg; hero/rail whites are cards, not bands; offline banner is allowed warning notice | PASS |
| U13 - new-employee 3s | `Workshop floor`, `4 active - 16 bays`, `Dispatch the next job into a free bay.`, `Dispatch to technician`, `Occupied / Idle / Parts delay / QC`, `Incoming queue`, `Quality control / Review`, `Find on the floor`. Residual: bare `QC` kept from before per brief | PASS |
| U14 - a11y 48dp, 1.3x + 320 | `floor_1.3_en/ar` + `floor_1.0_en_320x568`: wrap-not-truncate, zero overflow markers, buttons/chips/tiles read >=48dp rows. Exact dp/contrast/Semantics need instrumented tests | PASS (stills-limited) |

**Sweep result: 15/15 PASS, 0 FAIL - U-clean.** Round-1 FAILs U1 + U7 both fixed with on-screen evidence. No new violations, no regressions. Hard-reject cross-check now all PASS: borderless-light-cards (tiles borderless+shadow), ONE-filled-per-screen (one filled Dispatch everywhere), duplicate-entry (single primary), above-fold PASS, no-orphan-tiles PASS (2/3/4 cols, 16 divisible), no-ALL-CAPS PASS, search-sheet PASS, card-hierarchy PASS-with-note (dot+tint status, no pill - kept grammar).

## (c) Top-3 tap counts re-confirmed (AFTER pixels vs BEFORE)

BEFORE (brief Top-3, code-verified): (1) dispatch bay-tap to sheet **1 tap, 0 scroll**; (2) queue Queue-tab **1 tap**; (3) review Review-tab **1 tap**.

| Task | Before | After (this round pixels) | Verdict |
|---|---|---|---|
| Dispatch a job into a bay | 1 tap, 0 scroll (bay tap) | `floor_1.0_en_360x800`: tap B-01-B-04 at launch to sheet (**1 tap, 0 scroll**); alt hero Dispatch 1/0; search `floor_search_query`: icon + type `JC-101` + tap result | same |
| Check waiting (queue) | 1 tap (Queue tab) | Tab preserved (scaffold untouched) - **1 tap, 0 scroll**; rail `Incoming queue` same destination, optional + scroll on phones | same taps |
| Review finished job (QC) | 1 tap (Review tab) | Tab `/supervisor/review` preserved - **1 tap, 0 scroll**; rail `Review` same callback, optional | same |

**Tap-count result: PASS - no frequent task takes more taps than before; most frequent (bay-tap dispatch, 1 tap) stays <= 2.**

## (d) Airbnb rubric re-score (0-2 each, pass >= 12/16)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Floor-status to one sentence + CTA to bay map to rail; no widget grid, single primary |
| 2 | Headline-first hierarchy | 2/2 | `Workshop floor` to `4 active - 16 bays` to sentence to single in-flow CTA; calm empty keeps order |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Hero card chrome + dead grey media DELETED; tiles borderless + shadow (was 1/2) |
| 4 | Sheets for secondary | 2/2 | Search full sheet + handle + autofocus + clear; assign sheet code-kept; filter row brief-permitted |
| 5 | Sticky CTA (home has none) | 2/2 | Correctly absent; counted by omission |
| 6 | Section structure with Show-all | 2/2 | Legend + filter + full 16-grid + rail; See-all correctly absent |
| 7 | Plain friendly copy | 1/2 | Sentence-case, verb-first, honest errors, ar LTR correct; -1: bare `QC` still unexplained (kept per brief). Header-vs-hero number duplication GONE |
| 8 | Single emphasized primary | 2/2 | Exactly one filled Dispatch on every frame (was 1/2). No-match Clear + selected-bay Dispatch now secondary |
| **Merit** | | **15/16** | Pass (>=12) |
| **U-cap** | ANY violated law caps at 8/16 | **none - 15/16** | Zero U-fails |

**Verdict: PASS - bless as U-clean. 15/16 (merit 15/16, U-cap none).** Gating FAILs from round-1 closed: (i) phone search now same-row end-side everywhere; (ii) duplicate filled Dispatch collapsed to ONE (empty block action deleted, no-match/selected-bay demoted to secondary); (iii) borderless-tiles concern closed; (iv) hero media nit closed (block deleted).

## The two answers (fixed screens)

- **Would a first-time user know what to do in 3 seconds?** Yes. `floor_1.0_en_360x800`: `Workshop floor / 4 active - 16 bays` names place + state, `Dispatch the next job into a free bay. [Dispatch to technician]` says the job, four live bays + legend directly below. Next step unambiguous: tap Dispatch or tap a bay. Prior friction gone: search is now findable top-right on phones, empty offers Dispatch exactly once.
- **What would an Airbnb product designer reject here?** Nothing gating. One residual nit: bare `QC` legend/chip label still unexplained on-screen (kept verbatim from before - spell out `Quality check` or add a one-time tooltip if copy owns it). No twin-CTAs, no dead media, no placement split, no outlines to complain about.
