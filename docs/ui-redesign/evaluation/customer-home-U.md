# Customer Home — Fresh U-Laws Re-Audit (READ-ONLY, no code touched)

**Role:** FRESH RE-AUDITOR, not builder. Read-only except this file. No code/tests/PNGs edited. No commit.
**Branch:** `ui/phase-6-customer` (customer home landed; advisor rebuild uncommitted alongside — advisor files ignored throughout; the only advisor fact used is the task-given premise that advisor has header search).
**Read first:** `DESIGN_SPEC.md` C16 + C17 + C16 hard-reject list; brief `docs/ui-redesign/phases/phase-6-customer.md`
(note: `docs/ui-redesign/briefs/phase-6-customer-home.md` does NOT exist — searched `briefs/`; the
`phases/phase-6-customer.md` plan served as the brief; it documents no search requirement and no search exemption).
**After images viewed (28/28, all via Read):** `docs/ui-redesign/baseline/after-phase-6-customer/`
`idle_light_1.0_en_360x800`, `idle_dark_1.0_en_360x800`, `idle_light_1.0_ar_360x800`,
`idle_dark_1.0_ar_360x800`, `idle_light_1.3_en_360x800`, `idle_dark_1.3_en_360x800`,
`idle_light_1.3_ar_360x800`, `idle_dark_1.3_ar_360x800`, `idle_light_1.0_en_320x568`,
`idle_dark_1.0_en_320x568`, `idle_light_1.0_en_768x1024`, `idle_light_1.0_en_1180x820`,
`hero-approval_light/dark_1.0_en_360x800`, `hero-payment_light/dark_1.0_en_360x800`,
`hero-service_light/dark_1.0_en_360x800`, `hero-upcoming_light/dark_1.0_en_360x800`,
`hero-nothing_light/dark_1.0_en_360x800`, `empty_light_1.0_en_360x800`,
`loading_light_1.0_en_360x800`, `error_light/dark_1.0_en_360x800`,
`offline_light_1.0_en_360x800`, `field-na_light_1.0_en_360x800`.
**Before images viewed (4/4):** `docs/ui-redesign/baseline/before-customer-home/`
`customer_home_light_en_360x800`, `customer_home_light_ar_360x800`,
`customer_home_dark_en_360x800`, `customer_home_dark_ar_360x800`.
**Before tap-counts:** old code at `git show 7d3fe2b4^:...customer_home_tab.dart`,
`customer_status_notices.dart`, `customer_home_quick_actions.dart`, `customer_scaffold.dart`
(first parent of the recomposition commit = pre-recomposition home), cross-checked against the before-PNGs.

---

## (a) DESCRIBE — what is visible, region by region, at full resolution (no judging)

### Idle light 360 — `idle_light_1.0_en_360x800.png` (reference frame)
- **Header/greeting region (top, no app bar):** muted sentence-case eyebrow `Welcome back`, large bold
  name `Ahmed`, muted sub-line `Your car is in good hands`. No app bar, no search icon, no bell, no avatar.
- **Hero region:** one large white rounded card. Top: light-grey media block with small slate checklist icon.
  Below: bold title `Estimate AED 450 awaiting your approval`, muted sentence
  `Approval needed before work continues`, red-soft pill with dot `Needs your attention`.
- **Hero CTA region:** one full-width outlined pill button `Review estimate` directly under the hero card.
- **Quick-action region:** 2×2 grid of large outlined tiles: row 1 `Book service` (calendar icon, blue
  tint fill = emphasised) + `Breakdown help` (car+`!` icon); row 2 `Invoices` (receipt icon) + `History`
  (clock-arrow icon). All four labels fully visible on one line each.
- **Garage region:** section header `Your garage` left + blue `Show all` right. Two cards side by side with
  the second card peeking at the right edge (carousel peek): card art light-blue block with blue car glyph
  and overlaid status pill (`In service` blue dot / `Last service` dark dot), name below (`Toyota Camry` /
  `Honda Civic` — bottom of frame cuts the spec/plate lines).
- **Recent-activity region:** below the fold at 360 (not visible in this frame; visible at 768/1180 — see below).
- **Nav region:** no bottom nav, no rail, no app bar visible anywhere in this frame.

### Idle dark 360 — `idle_dark_1.0_en_360x800.png`
- Same regions and order on near-black `#121214`-style background. Hero card dark surface, same title /
  sentence / red-soft `Needs your attention` pill. Outline `Review estimate` button. Same 2×2 tiles
  (Book service blue-tinted, others dark surface, full labels). `Your garage` + blue `Show all`, same two
  peeking cards (`In service` / `Last service`). No bottom nav visible.

### Arabic — `idle_light_1.0_ar_360x800.png` / `idle_dark_1.0_ar_360x800.png`
- Mirrored RTL layout: greeting right-aligned (`مرحبًا بعودتك` / `Ahmed` stays LTR / `سيارتك في أيدٍ أمينةة`).
  Hero title right-aligned `تقدير AED 450 بانتظار اعتمادك` (`AED 450` stays LTR), sentence
  `الموافقة مطلوبةة قبل مواصلة العمل`, red-soft pill `تحتاج انتباهك` with dot. Outline button
  `مراجعة التقدير`. Tiles mirrored with translated labels (`احجز صيانة` emphasised blue / `مساعدة الأعطال` /
  `الفواتير` / `السجل`), icons intact. Garage header `مرآبك` right + blue `عرض الكل` left; cards mirrored
  with translated pills (`قيد الصيانة` blue dot / `آخر صيانة` dark dot); `Honda Civic` / `Toyota Camry`
  names stay LTR. No nav visible.

### 1.3x — `idle_light_1.3_en_360x800.png`, `idle_dark_1.3_en_360x800.png`, `idle_light_1.3_ar_360x800.png`, `idle_dark_1.3_ar_360x800.png`
- Same regions and order. Hero title wraps to two lines (`Estimate AED 450 awaiting your` / `approval`),
  sentence wraps to two lines, pill intact. `Review estimate` / `مراجعة التقدير` intact on one line.
  All four tile labels fully visible (`Book service`, `Breakdown help`, `Invoices`, `History`;
  ar `احجز صيانة`, `مساعدة الأعطال`, `الفواتير`, `السجل`) — no truncation, no mid-word breaks, icons intact.
  `Your garage` + `Show all` visible; cards begin below. No overflow markers, no clipped glyphs.

### 320px — `idle_light_1.0_en_320x568.png`, `idle_dark_1.0_en_320x568.png`
- Same order: greeting, hero (`Estimate AED 450 awaiting your approval` wrapped 2 lines + sentence +
  `Needs your attention` + `Review estimate`), 2×2 tiles with full labels (`Book service` /
  `Breakdown help` / `Invoices` / `History`), then garage header. No truncation, no overflow markers.

### 768 medium — `idle_light_1.0_en_768x1024.png`
- Two-column content (no rail visible): left column greeting + hero card + outline `Review estimate`;
  right column the 2×2 quick-action tiles. Below, full-width `Your garage` + `Show all` with two full cards:
  `Toyota Camry` (`2021 · 45000 km · White`, plate chip `ABC 1234`, `In service`) and `Honda Civic`
  (`2019 · 78200 km · Silver`, plate chip `XYZ 5678`, `Last service`). Below: `Recent activity` + blue
  `All bookings`, one row (receipt icon, `Brake pads`, `Honda Civic · 02 May 2026`, `Completed` + `>` chevron).

### 1180 expanded — `idle_light_1.0_en_1180x820.png`
- Same two-column pattern wider: hero left + four tiles in one row right (`Book service` / `Breakdown help` /
  `Invoices` / `History`, `Breakdown help` wraps to two lines). `Your garage` + `Show all`, same two full
  cards with spec lines and plate chips. `Recent activity` + `All bookings` at the bottom edge. No rail, no
  bottom nav visible.

### Hero variants (light + dark 360)
- `hero-approval_*`: identical to idle (single-vehicle case): same estimate hero + `Needs your attention` +
  `Review estimate`; garage header reads `Your vehicle` + `Show all` with one card (`Toyota Camry`).
- `hero-payment_*`: hero title `2 unpaid invoices`, sentence `Review and settle your outstanding invoices.`,
  amber-soft pill `2 unpaid invoices` (title and chip text identical), outline button `Review invoices`;
  tiles + `Your vehicle` + single card below.
- `hero-service_*`: hero title `Full service`, sentence `Current stage · On the lift`, blue-soft pill
  `In service`, outline button `Track service`; tiles + `Your vehicle` + single card.
- `hero-upcoming_*`: hero title `Oil change`, sentence `12 Jun 2026 · 10:00. Your service is booked. Workshop
  updates will appear here once your vehicle is checked in.`, teal pill `Confirmed`, outline button
  `View booking`; tiles + `Your vehicle` + single card with `Booked` pill.
- `hero-nothing_*`: hero title `No active service`, sentence `Your vehicle is not in the workshop right now.`,
  neutral pill `No active service` (title and chip text identical), outline button `Book service`; the same
  `Book service` label repeats as the first quick-action tile; tiles + `Your vehicle` + single card below.

### States (light 360; error also dark)
- `empty_light_1.0_en_360x800`: header `Welcome to Orient` + `Your car is in good hands`; centered light-blue
  circle with car icon; title `Your garage is empty`; sentence `Add your vehicle to book service, follow
  repair progress, and keep every update in ...` (truncated mid-sentence with `...`); one filled blue pill
  `Add your vehicle`; then 3 tiles in a 2-column grid (`Book service` / `Breakdown help` / `Invoices` alone
  on the second row — lone tile), no `History` tile.
- `loading_light_1.0_en_360x800`: flat light skeleton blocks: header lines + avatar circle, one large hero
  block, two medium blocks side by side, one row of four small blocks, three list rows. (Tile row is 4-across;
  the loaded layout uses a 2×2 grid plus a full-width CTA button that has no skeleton counterpart.)
- `error_light/dark_1.0_en_360x800`: centered soft-red circle with `!`, title `We couldn't load your
  information`, sentence `Please try again in a moment.`, filled blue pill `Retry`. No other content.
- `offline_light_1.0_en_360x800`: top warning-tinted banner with title `No connection` on the first row,
  warning-triangle icon on the second row left, blue `Retry` link centred on the third row (title, icon and
  action stacked/misaligned, not baseline-aligned); below it the full nothing-state home (`No active service`
  hero + `Book service` button + 4 tiles + `Your vehicle` header).
- `field-na_light_1.0_en_360x800`: identical to hero-nothing except the single garage card body reads only
  `Vehicle` (nameless-vehicle degradation, no overflow).

### Before (4 PNGs) — structural comparison baseline
- `customer_home_light_en_360x800.png`: small greeting `Welcome back` / `Ahmed` (no subtitle); pink-tinted
  attention box (`Needs your attention`, rows `Estimate AED 450 awaiting your approval >` and
  `1 unpaid invoice >`); section `Your garage` + blue `Manage`; one large vehicle card with dots pagination
  (one card visible + edge peek), spec `2021 · 45000 km · White`, plate `ABC 1234`; below, an `IN SERVICE` /
  `Full service` card cut off at the fold. No quick-action tiles, no hero card, no CTA button, no recent
  activity, no states, no nav visible.
- `customer_home_light_ar_360x800.png`: same structure mirrored; attention rows translated
  (`تقدير AED 450 بانتظار اعتمادك`, `فاتورة واحدة غير مدفوعة`); garage card chip stays English
  (`IN THE WORKSHOP NOW`) while the lower card chip is Arabic (`قيد الصيانة`) — mixed-language chips.
- `customer_home_dark_en_360x800.png` / `customer_home_dark_ar_360x800.png`: same structure on dark
  background; same mixed chips in ar (`IN THE WORKSHOP NOW` English on top card, `قيد الصيانة` on bottom).
- Structural delta after-vs-before: (1) greeting gains headline hierarchy + reassuring subtitle; (2) two-row
  attention box replaced by one hero card (title + sentence + single status pill) plus one explicit verb-first
  outline CTA; (3) NEW 2×2 quick-action tile grid (absent in before-PNGs); (4) garage `Manage` replaced by
  `Show all`, dots pagination replaced by peeking carousel / 2-up grid; (5) NEW `Recent activity` +
  `All bookings` section; (6) NEW full state set (empty/loading/error/offline/field-na); (7) NEW responsive
  behaviour (768 two-column, 1180 hero+tile-row split — no tablet before to compare). Not a recolor: layout,
  hierarchy and information architecture all changed.

---

## (b) U0–U14 walk, one by one (evidence = image + region; ANY violated law caps at 8/16)

| Law | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — fewer steps, never hunt/scroll/tap more than necessary | `idle_light_1.0_en_360x800` hero + CTA + first tile row all visible with zero scroll; top-3 tasks each resolve in 1 tap (see §c). No decorative detours on the path. | PASS |
| U1 — search icon in header top-right, full-screen search, same placement everywhere | No header exists on customer home at all: all 28 after-PNGs start at the greeting; there is no search icon, no bell, no avatar anywhere (idle/nav/header regions). Advisor has header search (task-given premise). The brief documents no search requirement and no exemption. A customer corpus (vehicles, bookings, invoices) exists to search, so the law applies by its own letter ("every dashboard … in every app"). | **FAIL** |
| U2 — primary task first: first actionable item above the fold at 360x800 idle | `idle_light_1.0_en_360x800`: hero card + full `Review estimate` CTA + first tile row all above the 800px fold; the primary actionable item (hero CTA) is fully visible with no scroll. Garage peeks, activity is secondary below fold — correct ordering. | PASS |
| U3 — tap count: brief top-3, none more than before, most frequent ≤ 2 | §(c) table: open active service 1 = 1; book service 1 ≤ 1–2; review approval 1 = 1. Most frequent task = 1 tap. | PASS |
| U4 — frequent create/scan reachable without scrolling, lower half or sticky | `idle_light_1.0_en_360x800`: `Book service` + `Breakdown help` tiles visible with no scroll, starting in the lower half of the 800px frame. | PASS |
| U5 — no truncation of primary text; rows fit or scroll with clean peek | `idle_light_1.3_en/ar_360x800`, `idle_dark_1.3_en/ar_360x800`, `idle_light_1.0_en_320x568`: all four tile labels render as full words (`Book service`, `Breakdown help`, `Invoices`, `History`; ar all four translated), wrapping to 2 lines where narrow — zero mid-word breaks, zero `…` on primary labels. Chips fully visible and translated (`قيد الصيانة`, `آخر صيانة`). 360 garage shows a clean next-card peek; 768/1180 show full 2-up labels. (Note, not fail: empty-state *supporting* sentence ends `… in ...` — secondary text, ellipsis allowed.) | PASS |
| U6 — calm empty states: nothing-to-do collapses to a compact calm status line, no filled CTA | `hero-nothing_light_1.0_en_360x800` + `offline_light_1.0_en_360x800`: the nothing state renders the SAME full-size hero card anatomy as attention heroes (media block + title + sentence + pill) plus a `Book service` CTA — it does not collapse to a compact calm status line (contrast advisor `hero-nothing`, which is a compact check-row with no button). A CTA exists where the law specifies a status line. | **FAIL** |
| U7 — one path per task; See-all only when more items exist | `hero-nothing_*` + `offline_*`: identical `Book service` hero CTA AND `Book service` tile on the same screen — two same-screen paths to one task. Supporting: `hero-payment_*` pairs `Review invoices` CTA with the `Invoices` tile for the same destination; every single-vehicle variant (`Your vehicle` + one card) still shows `Show all` although only one item exists. | **FAIL** |
| U8 — relevance: actionable first, history never under To-do | Hero priority approval > payment > live-service > upcoming > nothing with single-hero suppression (one hero per variant across all 10 hero PNGs). `Recent activity` rows (`Brake pads … Completed`) sit in a plainly labelled history section, never under an action heading. | PASS |
| U9 — consistency: same element, same place, across screens and apps | Search/bell/avatar header chrome exists on advisor (premise) but customer home has no header at all — the `search` element is not in the same place across apps; there is no shared header pattern. (Within home itself, hero CTA / tiles / `Show all` / `All bookings` placement is consistent across all variants, themes and locales.) | **FAIL** |
| U10 — feedback and forgiveness; errors say what to do | `error_*` (light + dark): plain sentence + `Retry`, no raw exceptions. `offline_*`: warning banner + `Retry`, last data kept on screen. `loading_*`: skeleton. `empty_*`: action. Destructive confirmations N/A on home. (Polish note, not fail: offline banner rows are misaligned — `No connection` title, triangle icon and `Retry` stack instead of baseline-aligning; skeleton tile row is 4-across and has no CTA counterpart while the loaded layout is 2×2 + CTA button.) | PASS |
| U11 — readable numbers: zero never `-`, stats labelled, visible, decision-helping | `AED 450` labelled amount; `2 unpaid invoices` count with label; dates `12 Jun 2026 · 10:00`, `02 May 2026`; plates `ABC 1234`, `XYZ 5678` LTR-correct; no `-`, no unlabeled bare stats in any frame. (Polish note: `45000 km` / `78200 km` lack thousands separators required by C11 — add grouping.) | PASS |
| U12 — one background | Light frames: single page background, white cards, no stray bands. Dark frames: single near-black background, surface lift, no stray bands. Offline banner is a proper tinted `AppBanner`, not a background strip. | PASS |
| U13 — new-employee test: plain words in 3 seconds | `Estimate AED 450 awaiting your approval`, `Track service`, `Review estimate`, `View booking`, `Book service`, `Breakdown help`, `Invoices`, `History`, `Confirmed`, `In service`, `No active service` — all plain customer words; no jargon, no codes as titles (IDs/plates are meta only). | PASS |
| U14 — a11y: ≥48dp targets, AA, semantics, 1.3x/320 clean | No overflow or clipping at 1.3x (en + ar) or 320px; tiles are large (clearly ≥48dp by visual estimate), CTA full-width; chips live inside tappable cards. Limits stated: exact dp and AA ratios cannot be measured from PNGs; screen-reader labels verified in code pattern only (Semantics wrappers confirmed in pre-recomposition widgets; recomposition claims same). | PASS |

**U-law fails (4): U1 (no search/header), U6 (nothing-state hero not collapsed), U7 (duplicate Book-service paths; spurious single-vehicle `Show all`), U9 (header chrome inconsistent across apps). Cap applies: max 8/16.**

---

## (c) Top-3 tasks — AFTER taps vs BEFORE taps (no frequent task may take more taps than before)

BEFORE sources: `7d3fe2b4^` code (`customer_home_tab.dart`: attention rows → `approvalsLocation(estimateId)` /
`approvalsLocation()`; journey summary → `customerServiceStatus` / `customerBookingDetail`; quick tiles →
`customerBookService` / `customerBreakdownHelp` / approvals / bookings destination; garage carousel → booking
detail / track service / book-per-vehicle) + before-PNG chevron rows and cards.

| # | Task | BEFORE (taps + scroll) | AFTER (taps + scroll, evidence) | Verdict |
|---|---|---|---|---|
| 1 | Open active service / booking | 1 tap: attention-adjacent journey action or garage `IN SERVICE` card → pushed status/booking page (`onTrackService` / `onViewBooking`, 1× `context.push`; before-PNG card pattern identical) | 1 tap, zero scroll: `Track service` / `View booking` outline CTA visible above fold (`hero-service_*`, `hero-upcoming_*`) | Equal (1 = 1) |
| 2 | Start book-service | 1 tap + scroll on compact (quick tile → `customerBookService`; tile sat below journey + garage, so scrolling on 360); ≥2 taps in the oldest before-PNG layout (no home affordance → tab switch + action) | 1 tap, zero scroll: `Book service` tile visible without scrolling in lower half (`idle_light_1.0_en_360x800`); also hero CTA in nothing-state | Better or equal (1 ≤ 1–2, scroll removed) |
| 3 | Review approval / estimate | 1 tap: attention row → approvals with estimate id (`onReviewEstimate`, matches before-PNG `Estimate AED 450 … >` chevron row) | 1 tap, zero scroll: `Review estimate` CTA above fold (`hero-approval_light/dark_1.0_en_360x800`, `idle_*`) | Equal (1 = 1) |

Most frequent task (open active service / review approval) = 1 tap ≤ 2. No frequent task takes more taps than
before; book-service loses its scroll. **U3 PASSES.**

---

## (d) Airbnb rubric + score (0–2 each, pass ≥ 12/16)

| # | Criterion | Evidence | Score |
|---|---|---|---|
| 1 | One task/screen | Single hero per state (approval > payment > service > upcoming > nothing suppression holds across all 10 hero PNGs); sections ordered hero → actions → garage → activity | 2 |
| 2 | Headline-first | `Welcome back` sentence-case eyebrow + bold `Ahmed` + muted `Your car is in good hands`; left-aligned (mirrored in ar) with short subtitle; no dense toolbar | 2 |
| 3 | Whitespace, no boxes-in-boxes | No nested cards; calm rhythm; hairline tile boundaries only. Deduction: `empty_*` lays 3 tiles out as a 2×2 grid with a lone tile — C16 hard-reject ("never a 2×2 with a lone tile") | 1 |
| 4 | Sheets for secondary | N/A correctly: no filters/pickers on home; `Show all`/`All bookings` navigate rather than sheet — allowed N/A | 2 |
| 5 | Sticky CTA | N/A correctly: home has no sticky bar by design — allowed N/A | 2 |
| 6 | Carousel/peeking + Show all | Idle multi-vehicle: 2-up cards with clean next-card peek + `Show all`. Deduction: every single-vehicle variant shows `Show all` (`Your vehicle` + one card) although only one item exists | 1 |
| 7 | Plain friendly copy + STATUS | Dot + short label + one plain sentence in every hero (`Needs your attention` + `Approval needed before work continues`); sentence-case everywhere incl. chips; ar fully translated (fixes the before mixed-language chips). Deduction: title/chip echo — `2 unpaid invoices`×2 (`hero-payment_*`), `No active service`×2 (`hero-nothing_*`) duplicates the number/label in badge (C16 hard-reject) | 1 |
| 8 | Single primary CTA | Explicit verb-first CTA per variant (`Review estimate`, `Review invoices`, `Track service`, `View booking`). Deduction: nothing/offline screens carry TWO identical `Book service` CTAs (hero button + tile) on one screen | 1 |

**Rubric raw: 2+2+1+2+2+1+1+1 = 12/16 (meets pass line) — CAPPED to 8/16 by the four U-law violations (U1, U6, U7, U9).**

---

## Verdict: FAIL (capped 8/16)

- Regions covered: header/greeting, hero + hero CTA, quick actions, garage carousel, recent activity, nav (absent in all captures), across light/dark 360, ar 360, 1.3x en/ar, 320, 768, 1180, empty/loading/error/offline/field-na; compared against all 4 before-PNGs.
- U-walk fails (4, explicit): **U1** (no search icon/header anywhere on customer home), **U6** (nothing-state hero not collapsed to a compact status line), **U7** (duplicate `Book service` paths; spurious single-vehicle `Show all`), **U9** (header/search chrome inconsistent with advisor). All other laws (U0, U2, U3, U4, U5, U8, U10, U11, U12, U13, U14) pass with evidence.
- Tap-count result: 1 = 1 (open service), 1 ≤ 1–2 (book service, scroll removed), 1 = 1 (review approval). Most frequent = 1 tap. No regressions.
- Scores: rubric raw 12/16 → **final 8/16 after U-law cap**. FAIL.
- Fixes are presentation/copy-only (Submitter-style list): (1) add header search (+ bell/avatar) or record a written search exemption in the brief; (2) collapse nothing-state hero to a compact status line and delete the duplicate hero `Book service` CTA (keep the tile); (3) de-duplicate `2 unpaid invoices` / `No active service` title↔chip echo; (4) hide `Show all` for single-vehicle; fix empty-state lone tile (2×2→row of 3 or sheet); (5) align offline banner rows; refresh skeleton to 2×2 + CTA; add thousands separators (`45,000 km`).

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes for the thing that matters: name + one hero stating the situation in plain words (`Estimate AED 450 awaiting your approval` / `Approval needed before work continues`) with one verb-first button (`Review estimate`), then four plainly labelled tiles. The 3-second read breaks only in the nothing-state, where two identical `Book service` buttons compete and the user must wonder whether they differ.
- **What would an Airbnb product designer reject here?** No search anywhere on a dashboard (and no header at all while advisor has one); two identical `Book service` CTAs on the same screen; the chip parroting the title (`2 unpaid invoices` / `No active service` twice in one card); a full-size hero card with a CTA for the "nothing is happening" state instead of a quiet status line; a 2×2 grid with a lone tile in empty state; `Show all` pointing at a single vehicle; and the small craft slips — misaligned offline banner, stale 4-across skeleton, `45000 km` without grouping, and the empty sentence dying in `...`.

**File path:** `docs/ui-redesign/evaluation/customer-home-U.md` (this file). No code changes. No commit.

---

## Round-2 re-gate (fix round landed, uncommitted) — READ-ONLY re-judge

**Role:** RE-GATE REVIEWER, not involved in building/fixing. READ-ONLY except this section. No code/tests/PNGs edited. No commit.
**Re-captured PNGs viewed (30/30, via Read):** all 28 round-1 files in `docs/ui-redesign/baseline/after-phase-6-customer/` plus NEW `search-open_light_1.0_en_360x800.png` + `search-query_light_1.0_en_360x800.png`. Focus re-checks: search icon + search sheets, nothing-state row, new-customer row, payment hero (chip + 3 tiles), offline banner, skeleton/loading, ar + 1.3x + 320 idles, dark idles.

### (a) DESCRIBE — changed regions only (round-2 delta vs round-1)

- **Header/search region (all idle/hero/empty/offline PNGs):** NEW magnifier icon at top-right on every light/dark idle (`idle_light/dark_1.0_en_360x800`, `hero-nothing_*`, `hero-payment_*`, `offline_*`, `empty_*`); mirrored to top-left in ar (`idle_light_1.0_ar_360x800` shows icon left, greeting right). Previously: no header, no icon anywhere.
- **Search sheets (2 NEW PNGs):** `search-open_*` = full-screen sheet over dimmed home (scrim + grabber visible): title `Search`, input with magnifier + placeholder `Search vehicles and bookings`, helper `Type to search your vehicles and bookings.` `search-query_*` = query `cam|` with blue focus ring + `X` clear, grouped results `Vehicles (1)` → `Toyota Camry / ABC 1234 >` row, `Bookings (1)` → `Oil change / Toyota Camry · 12 Jun 2026 >` row.
- **Nothing-state region (`hero-nothing_light/dark`, `offline_*`):** full hero card (media block + title + sentence + pill) + `Book service` CTA GONE. Replaced by one compact calm status row: white/dark rounded row, green check circle + sentence `Your vehicle is not in the workshop right now.` No button. Single-vehicle card below now under header `Your vehicle` with NO `Show all` (round-1 had `Your vehicle` + `Show all`).
- **New-customer/empty region (`empty_light_*`):** centered art + filled `Add your vehicle` pill GONE. Replaced by explanatory row-card: blue car icon left + full sentence `Add your vehicle to book service, follow repair progress, and keep every update in one place.` + blue text action `Add your vehicle` right (no truncation, no `...`). Tiles below now 3 (`Book service` / `Breakdown help` / `Invoices`).
- **Payment hero region (`hero-payment_light/dark`):** chip changed from `2 unpaid invoices` to `Unpaid` (title `2 unpaid invoices` kept, echo gone). Tile grid now 3 tiles (`Book service` / `Breakdown help` / `History`) — `Invoices` tile suppressed while `Review invoices` CTA remains, so one path. Spec grouping fixed: `45,000 km` (round-1: `45000 km`) visible on `hero-nothing_*` vehicle card (`2021 · 45,000 km · White` + `ABC 1234` chip).
- **Offline banner (`offline_light_*`):** previously stacked/misaligned (title / icon / Retry on 3 rows). Now one baseline-aligned amber row: `⚠ No connection` single pill. Body below = same compact nothing row + 4 tiles.
- **Loading skeleton (`loading_light_*`):** previously 4-across tile row + no CTA counterpart. Now: header lines + avatar circle, large hero block, full-width CTA pill block, then 2-column tile blocks (matches 2×2 layout + CTA). No 4-across row.
- **Unchanged (verified):** 1.3x en/ar wraps cleanly (`idle_light/dark_1.3_en`, `idle_light_1.3_ar` — `Estimate AED 450 awaiting your approval` 2 lines, all tile labels whole words); 320px clean (`idle_light_1.0_en_320x568`); ar mirroring + translated chips intact; dark surfaces intact.

### (b) Round-1 FAILS re-judged (evidence + pass/fail; ANY fail caps at 8/16)

| Law | Evidence (image + region) | Verdict |
|---|---|---|
| U1 — search icon in header top-right, full-screen search, same placement everywhere | `idle_light_1.0_en_360x800` top row: `Welcome back` left + magnifier right; same on dark/hero/empty/offline; ar mirrored left (`idle_light_1.0_ar_360x800`). `search-open_*` = full-screen sheet (title + focused input + helper); `search-query_*` = live grouped vehicle/booking results with clear `X`. Searchable corpus (vehicles/bookings) now searchable in one tap. | **PASS** |
| U6 — nothing-to-do collapses to compact calm status line, no filled CTA | `hero-nothing_light/dark_1.0_en_360x800` + `offline_light_1.0_en_360x800`: compact check-row `Your vehicle is not in the workshop right now.`, no media block, no pill, no CTA button. | **PASS** |
| U7 — one path per task; See-all only when more items exist | Nothing/offline: single `Book service` path (tile only; hero CTA deleted). Payment: `Review invoices` CTA is the sole invoices path (`Invoices` tile suppressed → 3-tile grid). Single-vehicle variants (`hero-nothing_*`, `hero-payment_*`): `Your vehicle` with NO `Show all`; multi-vehicle idle keeps `Your garage` + `Show all` with peek. | **PASS** |
| U9 — same element, same place, across screens and apps | Customer home now has header search at top-right (top-left in RTL = same logical placement) matching the task-given advisor header-search pattern; search opens as a full-screen sheet in both. Within home, hero CTA / tiles / `Show all` placement consistent across themes/locales. | **PASS** |

**Round-1 fail carryover: none. All four now PASS. No 8/16 cap applies.**

### (c) No-NEW-violations sweep — quick U0–U14 with evidence

| Law | Evidence | Verdict |
|---|---|---|
| U0 fewer steps | Top-3 tasks still 1 tap zero scroll (hero CTAs + tiles above fold); search adds 1-tap lookup (type `cam` → 2 grouped hits) with no detour | PASS |
| U1 search | See (b) | PASS |
| U2 primary first | `idle_*`: hero + `Review estimate` CTA + first tile row above 800px fold | PASS |
| U3 tap counts | Unchanged from round-1 (1/1/1, scroll removed); search reduces vehicle/booking lookup to type-to-find | PASS |
| U4 frequent create/scan | `Book service` + `Breakdown help` in lower half, zero scroll; search icon reachable at top | PASS |
| U5 no truncation | 1.3x en/ar + 320: full-word labels, clean wraps; empty sentence now complete (`…in one place.`); plates/dates LTR-correct | PASS |
| U6 calm empty | See (b); empty state is explanatory row + text action, no alarm styling | PASS |
| U7 one path | See (b) | PASS |
| U8 relevance | Priority approval > payment > service > upcoming > nothing holds; `Recent activity` still plainly history-labelled; search groups Vehicles/Bookings separately | PASS |
| U9 consistency | See (b) | PASS |
| U10 feedback | Error/retry/loading/offline retained; offline banner now aligned single row; skeleton now mirrors loaded layout (hero + CTA + 2-col tiles) | PASS |
| U11 readable numbers | `AED 450` labelled; `2 unpaid invoices` counted; `45,000 km` now grouped (fix confirmed); dates/plates labelled, no bare `-` | PASS |
| U12 one background | Light single-bg + white cards; dark near-black + surface lift; amber offline banner is a proper tinted banner, no stray bands | PASS |
| U13 plain words | `Estimate AED 450 awaiting your approval`, `Review estimate/invoices`, `Unpaid`, `Your vehicle is not in the workshop right now.`, `Search vehicles and bookings` — all customer words | PASS |
| U14 a11y/scale | No overflow at 1.3x/320; large tile targets + full-width CTAs; search input focus ring + clear `X`; exact dp/AA still PNG-unmeasurable (stated limit) | PASS |

**Sweep result: no NEW U-violations. 15/15 laws pass (U0–U14).**

### (d) Rubric re-score (0–2 each, pass ≥ 12/16)

| # | Criterion | Evidence | Score |
|---|---|---|---|
| 1 | One task/screen | Single hero per state; nothing-state is a quiet status row, not a competing hero | 2 |
| 2 | Headline-first | `Welcome back` eyebrow + `Ahmed` + `Your car is in good hands`; search is a lone icon, no dense toolbar | 2 |
| 3 | Whitespace, no boxes-in-boxes | No nested cards. Deduction retained: `empty_*` and `hero-payment_*` each lay 3 tiles in a 2-col grid (lone tile on row 2) — C16 shape persists, though now intentional anti-duplication | 1 |
| 4 | Sheets for secondary | Search correctly a full-screen sheet with scrim/grabber/focus/clear/grouped rows (was N/A, now demonstrated) | 2 |
| 5 | Sticky CTA | N/A correctly, no sticky bar by design | 2 |
| 6 | Carousel/peeking + Show all | Idle multi-vehicle 2-up peek + `Show all`; single-vehicle `Show all` REMOVED (`Your vehicle` alone) — prior deduction cleared | 2 |
| 7 | Plain friendly copy + STATUS | Title↔chip echo REMOVED (`2 unpaid invoices`/`Unpaid`); nothing chip gone with hero; empty `...` truncation completed; `45,000 km` grouped; ar chips translated | 2 |
| 8 | Single primary CTA | Duplicate `Book service` CTA REMOVED (tile only); `Review invoices` now sole path (tile suppressed); one verb-first CTA per attention hero | 2 |

**Rubric raw: 2+2+1+2+2+2+2+2 = 15/16. No U-law fails → no cap. Final 15/16.**

### Verdict: PASS (15/16)

- Changed regions re-viewed at full resolution: search icon + 2 search sheets, nothing compact row, new-customer row, payment chip + 3-tile grid, offline banner, skeleton, ar + 1.3x + 320 idles, dark idles.
- U re-judge: **U1 PASS, U6 PASS, U7 PASS, U9 PASS** — all round-1 fails cleared with PNG evidence. Sweep: no new violations across U0–U14.
- Scores: rubric 15/16, final 15/16 (uncapped). **Overall PASS.**
- Residual polish (non-blocking, not U-fails): 3-tile 2-col grids leave a lone tile on row 2 in empty + payment (consider 1-row-of-3 or contextual sheet per C16); skeleton carries extra placeholder rows beyond the loaded 2×2 — harmless.

### The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. Name + one plain-sentence hero (`Estimate AED 450 awaiting your approval` / `Approval needed before work continues`) with one verb-first button (`Review estimate`), then four plain tiles; search magnifier is where the eye expects it and its placeholder says exactly what it searches. The nothing-state no longer competes — one quiet green-check sentence, and `Book service` appears exactly once.
- **What would an Airbnb product designer reject here?** Nothing blocking. At most the lingering craft nits: the lone third tile wrapping to its own row in the 3-tile empty/payment grids, and the skeleton rendering extra placeholder rows beyond the loaded 2×2. The round-1 reject list (no search anywhere, twin `Book service` CTAs, chip parroting the title, full hero for "nothing happening", single-vehicle `Show all`, misaligned banner, 4-across skeleton, `45000 km`, dying `...` sentence) is fully cleared.

**File path:** `docs/ui-redesign/evaluation/customer-home-U.md` (this file). No code changes. No commit.

(End of Round-2 re-gate)
