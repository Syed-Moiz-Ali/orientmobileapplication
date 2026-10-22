# ADVERSARIAL REVIEW — customer vehicles list (My garage) — FAIL 8/16 (C17-capped)

**Role:** ADVERSARIAL REVIEWER, did not build. Working ONLY inside `C:\Users\sanja\AppData\Local\Temp\opencode\wt-customer` (branch `ui/list-customer`). No checkout/switch/commit/push. Never touched `71983229`.
**Governance:** DESIGN_SPEC `docs/ui-redesign/DESIGN_SPEC.md` C16 + U0–U14 C17. Pass ≥ 12/16. Any U-law fail caps at 8/16; any C16 hard-reject caps at 10/16.
**Brief:** `docs/ui-redesign/briefs/phase-6-vehicles-list.md` (authoritative, incl. ONE sanctioned U1 exception: search/filter icons ONLY when > 5 items).
**References:** `docs/ui-redesign/references/` EMPTY, `AIRBNB_PATTERNS.md` missing repo-wide — UNMET per brief §References. No pattern file consulted.
**Images viewed (Read, full resolution):** `docs/ui-redesign/baseline/after-vehicles-list/` — `idle-2_light_1.0_en_360x800.png`, `idle-6_light_1.0_en_360x800.png`, `idle-2_light_1.3_en_360x800.png`, `idle-2_light_1.0_ar_360x800.png`, `search-open_light_1.0_en_360x800.png`, `filter-sheet_light_1.0_en_360x800.png`, `remove-sheet_light_1.0_en_360x800.png`, `empty_light_1.0_en_360x800.png` (+ `idle-2_dark`, `idle-2_320`, `idle-2_768`, `search-results`, `remove-sheet_ar`, `search-open_ar` spot-checked via prior eval descriptions; contact sheet: none exists for vehicles — missing artifact, noted).
**Stance:** Assume NOT Airbnb-level. Hunt defects. Rank 1 = most severe.

---

## Ranked defects (≥5, each with image+region, law, gating)

### 1. [GATING] Mileage without thousands separators — `45000 km`, `78200 km`
- **Image+region:** `idle-2_light_1.0_en_360x800.png`, card 1 specs line `White · 45000 km`, card 2 `Silver · 78200 km`. Same in `idle-6_light_1.0_en_360x800.png` (`White · 45000 km` twice) and `idle-2_light_1.0_ar_360x800.png` (`White · 45000 km` LTR inside RTL card).
- **Law/criterion:** C17-U11 READABLE NUMBERS + C11 Numbers ("thousands separators, consistent decimals" via central formatters only) + brief U4 ("zero as `0`" / verbatim helpers — helpers evidently bypass `formatters.dart`).
- **Why severe:** Every card shows the violation; a 5-digit figure without grouping is harder to scan and contradicts the spec's only number rule. New-employee test also suffers (`45000` vs `45,000`).
- **GATES? YES — U11 breach → C17 cap 8/16.**

### 2. [GATING] Edit/Remove buried behind `⋮` = +1 tap regression on shipped paths
- **Image+region:** `idle-2_light_1.0_en_360x800.png`, card 1 bottom row `Book service` left + tiny vertical `⋮` right (same on card 2, and all `idle-6` cards). No direct Edit/Remove visible.
- **Law/criterion:** C17-U0 (fewer steps; frequent-action binding reserves direct slot for Book only) + C17-U14 no-regression + U3 tap budgets (brief: Edit 2 taps, Remove 2+confirm; after: tab + `⋮` + item = 3 taps / 3+confirm).
- **Tap walk:** Before Edit 2 → After 3; Before Remove 2+confirm → After 3+confirm. Brief-sanctioned as "infrequent", but it IS more taps than before on a shipped path. Round-2 already conceded −1 merit here.
- **GATES? YES — U0/U14 breach (strict reading: any extra tap on a brief-budgeted task gates), C17 cap.**

### 3. [GATING] Search/filter icons sit inline-left below subtitle, not top-right header per U1
- **Image+region:** `idle-6_light_1.0_en_360x800.png`, header region row 2: grey magnifier + grey funnel + blue `+ Add vehicle`, all left-aligned under `6 registered vehicles` subtitle.
- **Law/criterion:** C17-U1 ("search ICON in the header at the TOP RIGHT next to notifications and avatar. Same placement on every dashboard/list screen") + C17-U9 consistency. Brief orders "`AppPageHeader` with search icon top-right"; pixels show content-row-left.
- **Consistency:** Bookings `idle_light_1.0_en_360x800.png` repeats the same left-row placement; notifications has no icon at all (sanctioned) — three siblings, three grammars.
- **GATES? YES — U1/U9 breach → C17 cap.**

### 4. [GATING] Decorative art band dominates hierarchy, wastes fold
- **Image+region:** `idle-2_light_1.0_en_360x800.png`, card 1 top: ~200px pale-blue band with large centered car glyph; plate chip `ABC 1000` overlaps band bottom-left. Title `Toyota Camry · 2021` sits ~300px below screen top. Same on every card (`idle-6`, `search-open` dimmed background, `filter-sheet` dimmed background).
- **Law/criterion:** C17-U0 (one read: identity first; no competing heroes on a list screen) + C17-U2 (fit the content; FOLD: first card above fold + second peeking — met only because cards are so tall the peek is a sliver) + C1 (content first, chrome last) + C16 structure (whitespace separation, not giant placeholder bands).
- **Why:** The band is chrome, not content (API has no photography — brief allows "tile placeholder", not a billboard). It pushes `Booked/View/Book service` ~500px down, forces scroll for card 2's actions at 360×800, and repeats identically on 6 cards (no information).
- **GATES? YES — U0/U2 breach → C17 cap.**

### 5. [GATING] `View` far-right micro-link + `Book service` compete; `View` tap target suspect
- **Image+region:** `idle-2_light_1.0_en_360x800.png`, card 1 mid-row: teal `● Booked` pill left, blue `View` text hard-right on same baseline; bottom row blue `Book service` left + `⋮` right. Same pattern card 2 (`Last service` + `View`).
- **Law/criterion:** C17-U5 (48dp targets; actions Wrap never clip) + C17-U0 (one primary action per card) + C16 "Exactly ONE filled accent element per section / one primary CTA" spirit + C12 tap-target guideline.
- **Evidence:** `View` is ~20px-tall text with no padding block visible; horizontal gap pill→View spans ~60% of card width (hunt distance); two blue text actions on one card (View vs Book service) split the "what do I tap" answer. Stills-limited on exact dp, but visually below the 48dp block that `Book service` enjoys.
- **GATES? YES — U5 breach → C17 cap.**

### 6. [GATING] Arabic cards leave status pills in English (`Booked`, `Last service`)
- **Image+region:** `idle-2_light_1.0_ar_360x800.png`, card 1 pill `Booked` (Latin, LTR) + detail `Oil change · 12 Jun 2026 · 10:00 AM` (Latin) inside otherwise RTL card (`مركباتي`, `إضافة مركبة`, `عرض`, `احجز صيانة` translated). Card 2 pill `Last service` likewise untranslated.
- **Law/criterion:** C17-U13 NEW-EMPLOYEE TEST (plain words a new employee understands in 3 seconds) + C15 localization (ARB sentence-case, no hardcoded EN) + C17-U10 RTL (full mirror includes strings, not just layout).
- **Note:** Prior review defends pills as "verbatim `statusLabel` truth". Adversarial reading: verbatim-EN inside an ar layout is still untranslated UI; brief's own C16 adaptation demands sentence-case via theme, implying the pill IS localizable chrome.
- **GATES? YES — U13 (strict) → C17 cap.**

### 7. [GATING] VIN line `VIN JT1ABC` is a truncated stub, presented as fact
- **Image+region:** `idle-2_light_1.0_en_360x800.png`, card 1 meta line 3: `VIN JT1ABC` (6 chars). Real VINs are 17 chars; specs line shows full `White · 45000 km` but VIN is cut with no ellipsis affordance.
- **Law/criterion:** C17-U4 no invention (plates/specs/VIN verbatim via existing helpers; never present partial data as complete) + C11 (monospace only for code/IDs — this VIN is proportional grey, not mono/LTR-locked block).
- **GATES? YES — U4 breach → C17 cap (minor severity, still strict-gating).**

### Tap walkthrough (before→after, brief budgets)
| Task | Before | After (pixels) | Verdict |
|---|---|---|---|
| Open list | 1 (tab) | 1 (tab) | same |
| Book service | 2 +scroll | ≤1 from list (direct `Book service` on every card) | pass |
| Add vehicle | 2 | 2 (header `+ Add` / empty-state CTA, never both) | pass |
| Edit | 2 | 3 (tab+`⋮`+Edit) | **FAIL — defect 2** |
| Remove | 2+confirm | 3+confirm (tab+`⋮`+Remove+sheet) | **FAIL — defect 2** |
| View/Track | 2 | 2 (`View` direct, far-right) | pass with usability cost (defect 5) |
| Retry | 1 inline | 1 inline | pass |

### Consistency with siblings
- Header grammar: vehicles (`My vehicles` + count + left-row icons + `+ Add`), bookings (`Bookings` + count + left-row icons + `+ Book service`), notifications (`← Notifications` + `N unread`/`Mark all read`, no icons). Three patterns for "list header" — U9 fail (defect 3).
- Count language: vehicles `N registered vehicles`, bookings `N upcoming · N in service · N past services`, notifications `N unread` — no shared count atom.
- Card language: vehicles art-band cards, bookings date-block cards, notifications dot+icon rows — justified by content, but shared atoms (`AppSurfaceCard(outlined:false)`, `AppStatusChip`) render three different pill grammars (teal `Booked` / blue `In Service` / grey-dot rows with no pill).

---

## Score (Airbnb rubric 0–2 each, ONLY after defects above)
| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 1/2 | Find vehicle → act is legible, but art band + dual View/Book split focus (−1) |
| 2 | Headline-first hierarchy | 1/2 | Title→specs→context→actions order right, but band-before-title inverts visual weight (−1) |
| 3 | Whitespace, no boxes-in-boxes | 1/2 | Borderless + shadow yes, but 200px placeholder band per card is chrome-box (−1) |
| 4 | Sheets for secondary actions | 1/2 | Search/filter/remove sheets correct pattern, but secondary Edit/Remove cost +1 tap each (−1, as round-2 conceded) |
| 5 | Sticky CTA (none) | 2/2 | Correctly absent |
| 6 | Section structure | 1/2 | Chunking predicate kept, but left-placed find-aids + wrapped header rows break header grammar (−1) |
| 7 | Plain friendly copy | 0/2 | `45000 km` (no grouping), EN pills in ar, `VIN JT1ABC` stub (−2) |
| 8 | Single emphasized primary action | 1/2 | One filled per state yes, but View-vs-Book competition per card (−1) |
| **Merit** | | **8/16** | Below pass on merit alone |
| C16 hard-reject | | No cap | Borderless-light, no duplicate filled/entry, no permanent pills, no ALL CAPS, search-sheet w/ disclosure, fold+peek (thin), hierarchy title=vehicle, zero `0` — all pass; art band is not in the hard-reject list |
| C17 U-cap | | **Cap 8/16** | Defects 1–7 are all owner-file U breaches (U11, U0/U14, U1/U9, U0/U2, U5, U13, U4) |
| **Final** | | **8/16 — FAIL** | Merit 8, capped at 8. Do not bless. |

**Gating marks:** Defects 1, 2, 3, 4, 5, 6, 7 GATE (all U-law). C16: no gate.
**Would a first-time user know what to do in 3 seconds?** Probably — `Book service` is visible — but they must skip a billboard band, choose between `View` and `Book service`, and parse `45000 km`. That is not Airbnb-level calm.
**What would an Airbnb designer reject first?** The numbers (defect 1) and the billboard band (defect 4) — both hit every card.

---

# ROUND-2 VERDICT (fresh-eyes reviewer, did not fix) — 2026-10-22 — FAIL 8/16 (C17-capped)

**Scope:** verified ONLY fixer-claimed fixes on CURRENT PNGs in `after-vehicles-list/` + code read (no checkout/commit, no writes outside this worktree).

## Fix 1 — grouped mileage — VERIFIED FIXED
- Pixels: `idle-2_light_1.0_en_360x800.png` card1 `White · 45,000 km`, card2 `Silver · 78,200 km`; `idle-6_light_1.0_en_360x800.png` same grouping; `idle-2_light_1.0_ar_360x800.png` `White · 45,000 km` / `Silver · 78,200 km` (Latin digits, LTR token inside RTL card — frozen product policy); `idle-2_light_1.3_en_360x800.png` grouping intact (wraps, not clipped).
- Code: `customer_vehicle_record.dart:77-83` uses `displayMileage()` → `AppFormatters.group`; `customer_vehicle_presentation.dart:27-39` confirms grouping helper, raw `mileageLabel` kept for payloads.
- Round-1 defect 1 CLOSED. U11 on this point passes.

## Fix 2 — 48dp View/Track targets — VERIFIED AT CODE LEVEL, WEAK IN PIXELS
- Code: `_ContextLine:287-302` wraps View/Track in `SizedBox(height: AppDimensions.touchTarget)` (=48 per `packages/shared_core/.../app_dimensions.dart:145`), same pattern as bookings `_RowAction`. Hit area meets U5/U14 numerically.
- Pixels: `idle-2` en+ar still show `View`/`عرض` as small ~20px blue text far-right on pill baseline, ~60% card width from pill; `Book service` vs `View` still two blue actions per card.
- Verdict: U5 dp-breach CLOSED (no longer gating on size); U0 competition/hunt downgraded to merit −1, not a cap. Stills cannot prove 48dp height — code is the evidence.

## Spot-checks (condensed re-walk, no other fixes claimed)
- Edit/Remove still `tab+⋮+item` = 3 taps vs before 2 (brief sanctions menu but budget table says ≤2 — strict U0/U14 still gates). NOT FIXED.
- Search/filter still content-row-left in `idle-6` (left under subtitle), not top-right header per U1. NOT FIXED — U1/U9 still gates.
- Art band still ~200px pale-blue billboard per card, title ~300px down, card-2 actions below fold at 360×800. NOT FIXED — U0/U2 still gates.
- AR pills still EN (`Booked`, `Last service`, `Oil change · 12 Jun 2026 · 10:00 AM` Latin inside RTL card). Brief truth rules (verbatim helpers) excuse it, but ar triage still in English — strict U13 still gates.
- `VIN JT1ABC` stub still 6 chars, now mono LTR-locked (C11 mono fixed) but truncated fixture as fact. Downgraded to merit-only (fixture, not code).

## Rubric (round-2, Airbnb 0–2)
| # | Score | Reason |
|---|---|---|
| 1 One task | 1/2 | Book legible, View-vs-Book split remains |
| 2 Headline-first | 1/2 | order right, band-before-title still inverts weight |
| 3 Whitespace | 1/2 | borderless yes, 96px band per card still chrome-box |
| 4 Sheets | 1/2 | sheets correct, Edit/Remove +1 tap each |
| 5 Sticky CTA | 2/2 | correctly absent |
| 6 Section structure | 1/2 | left find-aids break header grammar |
| 7 Copy | 1/2 | was 0: grouping fixed (+1), EN-in-ar still (−1) |
| 8 Primary action | 1/2 | 48dp height fixed, competition remains |
| **Merit** | **9/16** | was 8; +1 grouping |
| C16 | No cap | borderless-light, zero handling, fold-peek thinly met |
| C17 | **Cap 8/16** | Edit/Remove taps (U0/U14), U1 placement (U1/U9), art band (U0/U2), EN pills (U13 strict) |
| **Final** | **8/16 — FAIL** | Merit 9 capped at 8. Do not bless. |

**Remaining gating:** defects 2, 3, 4, 6 (round-1 numbering). Defect 1 closed, defect 5 dp closed (usability merit only), defect 7 merit-only.

---

# ROUND-3 VERDICT (fresh-eyes reviewer, did not fix) — 2026-10-22 — FAIL 8/16 (C17-capped)

**Scope:** verified ONLY wave-2 fixer-claimed fixes on CURRENT PNGs in `after-vehicles-list/` + code read (no checkout/switch/commit, no writes outside this worktree).

## Fix H1 — plain-Row header — VERIFIED FIXED
- Pixels: `idle-6_light_1.0_en_360x800.png` header = `My vehicles` left + search + filter top-right same-row; `6 registered vehicles` subtitle below; `+ Add vehicle` end-side row below subtitle. Previously (round-1 defect 3) icons sat content-row-left under subtitle. Now matches claimed plain Row grammar.
- Threshold kept: `idle-2_light_1.0_en_360x800.png` (2 items) shows NO search/filter icons, only title + subtitle + Add — same >5 condition as brief.
- Round-1 defect 3 (U1/U9) CLOSED.

## Fix F5 — ar pills localized — VERIFIED FIXED (pills only)
- Pixels: `idle-2_light_1.0_ar_360x800.png` card 1 pill `محجوز`, card 2 pill `آخر صيانة` (RTL, dot + Arabic). EN `idle-2_light_1.0_en` still `Booked` / `Last service`.
- Code: `app_ar.arb:vhStatusBooked/vhStatusLastService` + `customer_vehicle_presentation.dart:185-189 upcomingLabel(l10n)`; `customer_localizations_ar.dart:449/455` confirm.
- Detail line stays Latin (`Oil change · 12 Jun 2026 · 10:00 AM` in ar card) — INTENTIONAL per `customer_vehicle_presentation.dart:145-149,195` bidi-safety note (Arabic month inside mixed `service · date · time` line corrupts order; detail stays LTR-locked Latin like plate/VIN, pills carry Arabic). Same family as LOGIC_FOLLOWUPS #11 verbatim rule — merit-only, NOT gating.
- Grouping intact: `45,000 km` / `78,200 km` in en + ar; 1.3x wraps (`10:00 AM` second line) not clipped.

## Spot-checks (condensed re-walk, no other fixes claimed)
- Edit/Remove still `tab+⋮+item` = 3 taps vs brief budget ≤2 (brief sanctions menu but budget table says ≤2 — strict U0/U14 still gates). NOT FIXED.
- Art band still ~96px pale-blue billboard per card, title ~300px down, card-2 actions below fold at 360×800. NOT FIXED — U0/U2 still gates.
- `View`/`عرض` still far-right micro-text vs `Book service` (48dp height in code per round-2, competition/hunt stays merit −1).
- `VIN JT1ABC` stub still 6 chars mono LTR-locked — fixture, merit-only.

## Rubric (round-3)
| # | Score | Reason |
|---|---|---|
| 1 One task | 1/2 | Book legible, View-vs-Book split remains |
| 2 Headline-first | 1/2 | order right, band-before-title still inverts weight |
| 3 Whitespace | 1/2 | borderless yes, band per card still chrome-box |
| 4 Sheets | 1/2 | sheets correct, Edit/Remove +1 tap each |
| 5 Sticky CTA | 2/2 | correctly absent |
| 6 Section structure | 2/2 | was 1: plain-Row header fixed (+1), >5 threshold kept |
| 7 Copy | 1/2 | pills localized, grouping kept; detail Latin by bidi contract |
| 8 Primary action | 1/2 | 48dp in code, competition remains |
| **Merit** | **10/16** | was 9; +1 header |
| C16 | No cap | borderless-light, zero handling, fold-peek thinly met |
| C17 | **Cap 8/16** | Edit/Remove taps (U0/U14) + art band (U0/U2) still breach |
| **Final** | **8/16 — FAIL** | Merit 10 capped at 8. Do not bless. |

**Remaining gating:** round-1 defects 2 (Edit/Remove taps), 4 (art band). Defects 1 (mileage), 3 (header U1), 6-pills CLOSED; defect 5 dp closed (merit only); defect 7 + detail-Latin merit-only.
