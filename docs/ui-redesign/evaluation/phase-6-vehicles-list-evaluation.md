# Phase 6 — Customer vehicles list / my garage — Fresh review ROUND 1 (PASS 16/16)

**Role:** FRESH REVIEWER (round 1), did not build. READ-ONLY except this file. No code/tests/PNGs edited. No branch/commit/push. Never touched `7198329`.
**Branch:** `ui/integration-1`.
**Read first:** Brief `docs/ui-redesign/briefs/phase-6-vehicles-list.md` (authoritative, as amended — includes the ONE sanctioned U1 exception: search icon only when > 5 items); migration `docs/ui-redesign/evaluation/phase-6-vehicles-list-test-migration.md` (behavior pins); REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 C17 (DESIGN_SPEC ~lines 489–546; brief §§U0–U14 is the authoritative application). Pass ≥ 12/16 with caps.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (both per brief §References, confirmed UNMET — not pretended; precedent patterns from phase-5/phase-7 cited instead).
**Images viewed (11/11 AFTER via Read, full resolution + 3 BEFORE for structure):**
- AFTER `docs/ui-redesign/baseline/after-vehicles-list/`: `idle-2_light_1.0_en_360x800`, `idle-6_light_1.0_en_360x800`, `search-open_light_1.0_en_360x800`, `empty_light_1.0_en_360x800`, `loading_light_1.0_en_360x800`, `error_light_1.0_en_360x800`, `idle-2_light_1.0_ar_360x800`, `idle-2_dark_1.0_en_360x800`, `idle-2_light_1.3_en_360x800`, `idle-2_light_1.0_en_320x568`, `idle-2_light_1.0_en_768x1024`.
- BEFORE `docs/ui-redesign/baseline/before-vehicles-list/`: `idle-2_light_1.0_en_360x800`, `idle-6_light_1.0_en_360x800`, `empty_light_1.0_en_360x800` (structure only; before loading/error/dark/ar/1.3x/320/tablet exist but add nothing to the verdict).
- Contact sheet `phase-6-vehicles-light.png`: NOT FOUND in `evaluation/contact-sheets/` (glob returns only `phase-6-customer-*`; no vehicles sheet was generated). Noted as missing artifact, not a screen defect — BEFORE vs AFTER compared directly from baseline PNGs.
**Code read-only (attribution only):** `apps/customer_app/.../widgets/customer_vehicles_tab.dart` (header/filter/count `_openSearch`/`_openFilter`/`_confirmRemove`), `customer_vehicle_record.dart` (`_ContextLine`, `_Actions`, `_SyncFailedNotice`/`_DeleteFailedNotice`), `customer_vehicles_search_sheet.dart`, `customer_vehicles_filter_sheet.dart`.

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle-2 en 360 — `idle-2_light_1.0_en_360x800.png`
- **Header region:** first line bold `My vehicles`; second line muted `2 registered vehicles`; third row left-aligned `+ Add vehicle` in blue (no magnifier, no funnel icon on this frame).
- **Card 1 region:** top pale-blue band with centered blue front-car glyph and small white pill `ABC 1000` bottom-left overlapping the band; below: bold `Toyota Camry · 2021`, muted `2021 · White · 45000 km`, muted mono `VIN JT1ABC`; teal pill `● Booked` left with blue `View` right on the same row; bold `Oil change · 12 Jun 2026 · 10:00 AM` below; bottom row blue calendar + `Book service` left, vertical `⋮` dots right.
- **Card 2 region (partial):** same pale-blue band + car glyph + white pill `XYZ 5678`; bold `Honda Civic · 2019`, muted `2019 · Silver · 78200 km`; grey pill `● Last service`; bold `Brake pads · 2 May 2026 · 9:00 AM`; bottom row `Book service` + `⋮` (frame cuts mid-second-card).

### AFTER idle-6 en 360 — `idle-6_light_1.0_en_360x800.png`
- **Header region:** `My vehicles` + `6 registered vehicles`; second row three items left-to-right: grey magnifier, grey funnel, blue `+ Add vehicle`.
- **Card 1:** identical structure to idle-2 card 1 (`ABC 1000`, `Toyota Camry · 2021`, `Booked` + `View`, `Oil change…`, `Book service` + `⋮`).
- **Card 2:** band + `ABC 1001`, `Toyota Camry · 2021`, `2021 · White · 45000 km`, NO pill and NO `View`/detail line, `Book service` + `⋮` row.
- **Card 3 (peeking):** band + car glyph + white pill `ABC 1002`, frame cuts at band bottom.

### AFTER search-open en 360 — `search-open_light_1.0_en_360x800.png`
- **Dimmed list behind:** card 1 greyed (band, `ABC 1000`, title, specs, `Booked`, detail).
- **Sheet region:** white rounded sheet with drag handle, title `Search vehicles` left + `×` right; rounded input with magnifier and hint `Search by name, plate, or colour`; six rows `Toyota Camry` left + plates `ABC 1000`…`ABC 1005` right.

### AFTER empty / loading / error en 360
- **Empty:** `My vehicles` + `Registered vehicles appear here.`; centered pale circle with car glyph; bold `No vehicles added yet`; sentence `Add your first car to book service and keep every visit connected to the right vehicle.`; full-width blue `Add vehicle`. No header `+ Add` on this frame.
- **Loading:** two pale bars (wide + narrow) then one large pale rounded block; no text.
- **Error:** `My vehicles` + `Registered vehicles appear here.`; pale-red circle with `!`; bold `We couldn't load your vehicles`; sentence `Please try again in a moment.`; full-width blue `Retry`.

### AFTER ar 360 — `idle-2_light_1.0_ar_360x800.png`
- Title right-aligned `مركباتي`, subtitle `2 مركبات مسجلة`; `+ إضافة مركبة` below subtitle; cards mirrored: plate pills `ABC 1000` / `XYZ 5678` bottom-right of band (LTR digits), titles `Toyota Camry · 2021` / `Honda Civic · 2019` right-aligned (LTR Latin), specs right-aligned, `VIN JT1ABC` LTR; teal pill `Booked` + `عرض` row mirrored; bottom row `⋮` left, `احجز صيانة` + calendar right.

### AFTER dark 360 — `idle-2_dark_1.0_en_360x800.png`
- Black background; same header + `+ Add vehicle`; cards dark-navy: band darker blue, white pill becomes black pill with white `ABC 1000`; white title, muted specs, `Booked` teal-on-dark, `View` blue, `Book service` blue, `⋮` white.

### AFTER 1.3x 360 — `idle-2_light_1.3_en_360x800.png`
- Same header; card 1 detail wraps to two lines (`Oil change · 12 Jun 2026 ·` / `10:00 AM`); card 2 detail wraps (`Brake pads · 2 May 2026 ·` / `9:00 AM`); all rows legible, no striped overflow markers visible in crop.

### AFTER 320px — `idle-2_light_1.0_en_320x568.png`
- Same header stacked; card 1 full-width single column (`Booked`, detail one line, `Book service` + `⋮` one row); card 2 band peeking at frame bottom.

### AFTER tablet 768 — `idle-2_light_1.0_en_768x1024.png`
- Header same-row: `My vehicles` + `2 registered vehicles` left, `+ Add vehicle` right; two cards single-column centered (max-width), full structure each (`Booked`/`View`, `Last service`/`View`, `Book service` + `⋮`).

### BEFORE vs AFTER structure (idle-2, idle-6, empty)
- BEFORE idle-2/idle-6: header `My vehicles … + Add vehicle` same row; bordered grouped container with dividers; record = art band + `Toyota Camry` (no year) + specs + VIN + grey container `BOOKED`/`LAST SERVICE` (ALL CAPS) + detail + `View`; action row three text buttons `Book service` + `Edit` + red `Remove`.
- AFTER: header stacks at 360 (same-row at 768); grouped borders/dividers gone (separate cards, whitespace gaps); title appends `· year`; `BOOKED`→`Booked`, `LAST SERVICE`→`Last service` pill; `Edit`/`Remove` gone from row into `⋮` menu; no other text changes. Visible before/after difference is structural — redesign delivered.
- BEFORE empty: title + subtitle + bordered panel with `No vehicles added yet` + sentence + small blue `+ Add vehicle` button inside panel. AFTER empty: borderless centered icon + title + sentence + full-width `Add vehicle`.

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail + attribution |
|---|---|---|
| U0 — one read: title → specs → real context → actions; card hierarchy title=make/model/year, plate=meta, pill ONLY from data, tile placeholder, borderless light | idle-2 card 1: `Toyota Camry · 2021` (title) → `2021 · White · 45000 km` → `VIN JT1ABC` → `Booked` + detail → `Book service` + `⋮`; plate `ABC 1000` small chip on band; idle-6 card 2 (`ABC 1001`) shows NO pill and no View when no context; car glyph band on every card (no photo affordance). Code `customer_vehicle_record.dart:68-85` (`outlined: false`, hierarchy comment), `:246-257` (sentence-case `AppStatusChip`, no `toUpperCase`). Light frames show soft shadow, no borders/dividers | PASS (owner-file) |
| U1 — find fast: header search icon top-right opening full-screen search sheet over loaded records; THE ONE sanctioned exception: icon ONLY when > 5 items, ≤ 5 = cards only | idle-2 (2 items): header region has NO magnifier/funnel — cards only ✓. idle-6 (6 items): header row has magnifier + funnel + Add ✓ (`customer_vehicles_tab.dart:124-127` `showFindAids = vehicles.length > 5`). search-open sheet: handle + `×` + `AppSearchField` + 6 name/plate rows; empty query = full list; no-match + Clear in code (`customer_vehicles_search_sheet.dart:104-127`); result tap closes sheet + `ensureVisible` reveal (`customer_vehicles_tab.dart:324-342`), actions stay on record. At 360 actions wrap below title (3 actions cannot fit one row); at 768 Add is top-right same-row — responsive wrap, icon still in-header, never inline in content | PASS (owner-file; threshold correctly applied both directions) |
| U2 — fit content: grouped rows/cards, NEVER a table; FOLD: first card above fold + second peeking @360x800 | All after frames: single-column cards (idle-2) / chunked columns (code `:284-322`: 1-col compact or < 4, else 2/3-col); no table anywhere. idle-2 360: card 1 complete + card 2 band/title/specs peeking; 320: card 1 complete + card 2 band peeking. First card fits above nav allowance (header ~3 rows + ~500px card < 720px usable) | PASS (owner-file) |
| U3 — no fake actions: context lines only from `contextFor`; Book/Edit/Remove/Retry map 1:1 | idle-6 card 2 has no pill/View (zero bookings → nothing offered); cards with context show exactly one `View`/`Track` path; `Book service` + `⋮` on every card; code keeps `customerRemoveVehicle`/`customerRetryVehicleSync`/`_retryRemoval` call sites byte-identical per migration doc | PASS |
| U4 — no invention: plates/specs/VIN verbatim; blank mileage unknown; zero as `0` | Plates `ABC 1000`/`XYZ 5678` verbatim chips; specs `specs()` verbatim; `VIN JT1ABC` mono LTR; `Booked`/`Last service` from `contextFor` only; no health/due claims anywhere; filtered `0 registered vehicles` uses `0` (code `:129-135` subtitle; migration §deviations) | PASS |
| U5 — reachable + legible: 48dp targets, Wrap never clips @320/1.3x, VIN LTR, mixed specs ambient | 1.3x: detail wraps 2 lines, all text legible, no overflow stripes; 320: `Book service` + `⋮` one row, no clipping; Wrap in `_Actions` (`customer_vehicle_record.dart:357-361` spacing/runSpacing); `VIN` wrapped in `Directionality(ltr)` (`:140-151`); ar: plates/VIN/figures LTR-locked, specs follow ambient | PASS (stills-limited for exact dp; targets visually ≥48dp, harness tests GREEN per migration) |
| U6 — states: skeleton mirrors cards; empty 1-icon-1-sentence-1-action; error + retry; stale kept + banner; pull-to-refresh | Loading: header lines + `card(208)` block mirrors header+card shape (code `:146-157`); empty: 1 icon + `No vehicles added yet` + 1 sentence + 1 `Add vehicle` (title+body are the `vhEmptyTitle`/`vhEmptyBody` pair the brief mandates); error: 1 icon + title + sentence + 1 `Retry` → same retry handler (code `:217-225`); `AppBanner` warning/error slots kept (`:184-215`); `RefreshIndicator` kept (`:137-138`) | PASS |
| U7 — feedback: remove confirm = confirmation BOTTOM SHEET (destructive, NO undo); snackbars stay; busy disables acting record only | No remove-sheet PNG captured — code evidence: `_confirmRemove` uses `showAppModalSheet` with `Remove Toyota Camry?` + destructive `FilledButton` (`vhRemoveCta`, error bg) + `Keep vehicle` (`customer_vehicles_tab.dart:352-393`); `customerRemoveVehicle` + snackbar (`vhRemoved`/`vhRemoveFail` + `vhRetry`) unchanged (`:396-420`); `busy` disables only acting record (`_removingId`, record `:199-206`, menu `enabled: !busy`) | PASS (code + 15 structural tests per migration; sheet PNG missing from capture set — capture gap, not behavior gap) |
| U8 — no dead ends: every behind-booking offers View/Track; empty always offers Add | Every pill card shows `View` (Booked→View, Last service→View; live→Track per code `:282-285`); badge-only never shown without action (idle-6 card 2 correctly has neither); empty always offers `Add vehicle` (both empty frames) | PASS |
| U9 — consistency: `AppPageHeader`, card rows, filter sheet, `AppBanner` — same atoms as phase-5/7 | `AppPageHeader` + `AppSurfaceCard(outlined:false)` + `AppStatusChip` + `AppBanner` + `AppEmptyState`/`AppErrorState` + `AppShimmerSkeleton` + `showAppModalSheet` — same shared-atom family as supervisor/technician/owner briefs; header/search/filter/banner grammar matches precedent | PASS |
| U10 — RTL: full mirror; plate/VIN/figures/digits LTR; `PositionedDirectional` kept | ar frame: full mirror (title/Add/cards/actions), `⋮` left vs en right, `عرض` left vs en `View` right; `ABC 1000`, `VIN JT1ABC`, `45000 km`, dates LTR; code keeps `PositionedDirectional` (`customer_vehicle_record.dart:104-108`) + `Directionality(ltr)` plate in search rows | PASS |
| U11 — a11y: record Semantics label kept; live-region on delete-fail; header semantics; 1.3x + 320 without clipping | Code: record `Semantics(label: title+plate+specs+context)` (`:75-82`); 1.3x + 320 frames: no clipping/overflow markers, actions intact; header `AppPageHeader` semantics inherited from shared atom | PASS (stills-limited; no overflow evidence in any of the 11 frames) |
| U12 — density: 1-col compact; 2-col ≥ 4 medium, 3-col large (same chunking predicate) | idle-2 (2 records) single column at 360 AND 768 (correct: < 4 → single even on tablet, code `:284-285`); predicate unchanged (`records.length < 4 || compact → Column`, else 2/3-col); maxWidth 1040 (code `:140-142`) | PASS |
| U13 — offline: bar pill owns offline state; stale list + refresh notice; retries inline | Code: `stRefreshFail`/`stRetry` `AppBanner` when `loadError + non-empty` (`:184-194`), delete-recovery `AppBanner` (`:197-215`), inline `_SyncFailedNotice`/`_DeleteFailedNotice` with same retry handlers (`customer_vehicle_record.dart:169-190`); no full-width offline banner added; shell bar untouched | PASS (no offline PNG in set; code pins per migration) |
| U14 — no regression: tap budgets = ceilings; pull-to-refresh, haptics, keys, confirmation + snackbar unchanged in behavior | Keys `ValueKey('vehicle-<id>')` kept (code `:261`); haptic on search select (`customer_vehicles_search_sheet.dart:139`); `selectDestination` untouched; confirmation+snackbar contracts behavior-identical (dialog→sheet presentation only). Tap budgets: see §3 | PASS |

**U-walk fails: 0. Zero owner-file fails; zero shell/shared fails visible in these 11 frames.**

---

## 3. Top-task tap walk BEFORE→AFTER (budgets ≤ before; Book ≤ 1 from list)

BEFORE counts (brief §Top tasks, verified from code per migration doc): open list 1 (tab) · Book 2 (tab+Book) · Add 2 (tab+header/empty Add) · Edit 2 (tab+Edit) · Remove 2+confirm (tab+Remove+dialog) · View/Track 2 (tab+View) · retry 1 inline.

| Task | Before | After (pixels + code) | Verdict |
|---|---|---|---|
| Open list | 1 tap (tab; 0 deep-linked) | ≤ 1 tap (unchanged `selectTab(2)`, bottom nav kept, no rail) | same ✓ |
| Book service | 2 taps + scroll (tab + record Book) | ≤ 1 from list / ≤ 2 from launch: `Book service` DIRECT on every card (idle-2/idle-6/`⋮` rows; code `:265-267` → `customerBookServiceLocation`) | same-or-better ✓ |
| Add vehicle | 2 taps (tab + header/empty Add → wizard) | ≤ 2: header `+ Add vehicle` when non-empty (idle-2/idle-6 headers), empty-state `Add vehicle` when empty (empty frame) — never both at once; same `customerAddVehicle` route | same ✓ |
| Edit vehicle | 2 taps + scroll (tab + direct Edit) | Menu + Edit item, same `customerEditVehicle(id)` route (code `:268`): +1 menu tap from launch vs before — BRIEF-SANCTIONED (brief orders Edit into card menu; frequent-action binding reserves direct slot for Book only). Infrequent action, existing route | sanctioned ✓ (not a regression hit) |
| Remove vehicle | 2 taps + 1 confirm (tab + Remove + dialog) | Menu + Remove + confirmation BOTTOM SHEET, same `customerRemoveVehicle` + snackbar, NO undo (code `:352-420`) — presentation moved dialog→sheet per brief; +1 menu tap sanctioned as above | sanctioned ✓ |
| Open booking / track | 2 taps (tab + View/Track) | ≤ 2: `View` direct on every context card (both idle frames), same `customerBookingDetail`/`customerServiceStatus` routes (code `:270-272`) | same ✓ |
| Retry sync / removal | 1 tap inline | ≤ 1 inline: `AppBanner` retry + snackbar `Retry` (code `:301-329`, `:201-212`) | same ✓ |

**Tap result: PASS — Book (the frequent action) is ≤ 1 from list; Add/View/retry unchanged; Edit/Remove menu indirection is the brief-mandated pattern on existing routes (disclosed, not counted as regression).**

---

## 4. Airbnb rubric 0–2 each, /16, pass ≥ 12/16 — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find vehicle → act. One glance: identity + plate → specs → real context → Book/menu. No competing heroes on a list screen |
| 2 | Headline-first hierarchy | 2/2 | `My vehicles` → count subtitle → cards; title=thing recognized, plate=meta, pill only from `contextFor`; empty/error keep headline order |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light cards (shadow, whitespace gaps), grouped borders + dividers removed; tile band is placeholder art, not a box-in-box |
| 4 | Sheets for secondary actions | 2/2 | Search = sheet (handle + autofocus field + rows, no inline field); filter = bottom sheet (chips + Show results + Clear); remove = confirmation bottom sheet (destructive + Keep, no undo) |
| 5 | Sticky CTA (list has none) | 2/2 | Correctly absent by omission — Add lives header/empty-state (never both), Book in-flow; no sticky bar claimed |
| 6 | Section structure (density/filter) | 2/2 | Header → single/multi-column list per unchanged predicate (1-col < 4, 2/3-col wider, max-width 1040); filter updates count verbatim, no-match + Clear restores |
| 7 | Plain friendly copy, no invented claims | 2/2 | Sentence-case pills (`Booked`, `Last service` — `BOOKED`/`LAST SERVICE` removed), verb-first Book/View/Add/Retry/Show results/Clear, honest empty/error, ar fully translated with LTR codes, zero as `0`, no ALL CAPS added |
| 8 | Single emphasized primary action | 2/2 | Idle: zero filled (correct — no competing CTA); empty: exactly one filled (`Add vehicle`); error: exactly one filled (`Retry`); remove sheet: exactly one destructive filled + Keep text |
| **Merit total** | | **16/16** | Pass on merit (≥ 12) |
| **C16 hard-reject cap** | borderless-light / one-read / no-duplicate-filled+entry / no-permanent-pills / badges-clear / no-ALL-CAPS / search-sheet / above-fold+peek / hierarchy / zero-as-0 | **No cap** | ALL PASS: borderless light ✓ (shadow, no dividers); one-read ✓; one-filled-per-state + Add never duplicated ✓; pills only from `contextFor` (idle-6 card 2 has none) ✓; plate chip clear of glyph ✓; ALL-CAPS removed ✓; search-sheet w/ progressive disclosure ✓; first card + second peeking @360 ✓; hierarchy ✓; zero `0` ✓ |
| **C17 U-cap** | ANY owner-file U-law violated caps at 8/16 | **No cap** | Zero owner-file U fails (§2). U1 threshold applied in both directions with pixel evidence |
| **Final** | | **16/16** | **PASS, no caps applied** |

**Verdict: PASS — bless as U-clean for vehicles-list scope. 16/16 (pass ≥ 12/16).**

---

## ROUND-1 DEFECT LIST (each: image + region evidence · law/criterion · gating?)

**Gating defects: NONE.** No C16 hard-reject hit, no owner-file U-law fail, no tap-budget breach on the frequent action.

**Non-gating observations (disclosed, filed — NOT defects, do not gate this verdict):**
1. **Edit/Remove +1 menu tap from launch** — idle-2/idle-6 action rows (`Book service` + `⋮`) + code `customer_vehicle_record.dart:371-398`. Brief-STRUCTURE-SANCTIONED (frequent-action binding: Book direct, Edit/Remove in menu, existing routes). Tap table §3. Non-gating.
2. **Search results are compact name+plate rows, not full record cards** — search-open sheet rows + code `customer_vehicles_search_sheet.dart:128-182`. Filed in migration §deviations (one tap closes + reveals via `ensureVisible`, actions stay on record, no new destinations). Meets U1 intent. Non-gating.
3. **`AppSurfaceCard(outlined:false)` rows instead of literal `AppListGroup`** — all idle frames (whitespace separation, no dividers) + migration §deviations (`AppListGroup` is a settings-row widget dimming inert rows to 40%). Same shared-atom family, borderless in light, identical chunking predicate. REDESIGN MANDATE rule-2 reason filed. Non-gating.
4. **Year in title AND specs line** (`Toyota Camry · 2021` + `2021 · White…`) — idle-2 card 1. Brief-mandated both (wireframe title + verbatim `specs()`). Sanctioned duplication. Non-gating.
5. **Filtered count uses `vhCountMany` for 0/1** (`0/1 registered vehicles`) — code `customer_vehicles_tab.dart:129-135`. Brief-mandated verbatim; zero rendered as `0`. Sanctioned. Non-gating.
6. **Missing process artifacts (not screen defects):** contact sheet `phase-6-vehicles-light.png` not generated (glob proves absence); `references/` + `AIRBNB_PATTERNS.md` UNMET per brief (precedent patterns used); remove-sheet and filter-sheet have no PNGs (code + 15 structural tests are the evidence). For owning capture phase / phase 9 (copy keys `vhSearch*`/`vhFilter*` en+ar already added per migration §New ARB keys).

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `idle-2_light_1.0_en_360x800.png`: `My vehicles / 2 registered vehicles` names the place, card 1 says `Toyota Camry · 2021`, plate `ABC 1000`, `Booked — Oil change · 12 Jun 2026` with `View`, and `Book service` sits directly on the card. Next step is unambiguous: tap `Book service` or `+ Add vehicle`.
- **What would an Airbnb product designer reject here?** Nothing blocking in list scope. Carry-forwards for system owners only: generate the missing `phase-6-vehicles-light.png` contact sheet; add remove-sheet + filter-sheet PNGs to the capture set; keep the `AppListGroup`-vs-rich-cards tension resolved at the shared-atom level (this screen's `AppSurfaceCard` resolution is sound and documented).

(End of file — round 1, 2026-10-21)

---

# ROUND 2 — Fresh re-review (2026-10-22) — VERDICT: PASS 15/16

**Role:** FRESH re-reviewer, never built/fixed this screen. READ-ONLY except this file. No branch/commit/push. Never touched `7198329`.
**Scope:** Verify the 3 round-1 fixes + 5 new frames (`remove-sheet en+ar`, `filter-sheet en`, `search-results 6+ en`, `search-open ar`), condensed U0–U14 re-walk, exact tap walk, honest rubric.
**Images viewed (16/16 AFTER):** all 11 round-1 frames (re-checked where relevant) + 5 new: `remove-sheet_light_1.0_en_360x800`, `remove-sheet_light_1.0_ar_360x800`, `filter-sheet_light_1.0_en_360x800`, `search-results_light_1.0_en_360x800`, `search-open_light_1.0_ar_360x800`.
**Code read-only (attribution):** `customer_vehicles_tab.dart:124-131` (find-aid threshold + `vhCount` subtitle), `customer_vehicle_record.dart:68-81` (year-once filter), `:340-409` (`_Actions` menu), `customer_localizations_en.dart:313-322` (ICU plural), `app_en.arb:208-218` / `app_ar.arb:97-100` (plural keys).

## R2-1. FIX 1 — ICU plural `vhCount` (en/ar): VERIFIED (code + pixel, one capture gap)
- Code: en `vhCount` = `=0{0 registered vehicles} =1{1 registered vehicle} other{{count} …}}` (`customer_localizations_en.dart:313-322`, keys `app_en.arb:217-218`); ar `=0{0 مركبات مسجلة} =1{مركبة واحدة مسجلة} other{{count} مركبات مسجلة}}` (`app_ar.arb:100`). Tab uses `vehicles.isEmpty ? vhCountNone : vhCount(n)` / filtered `vhCount(visible.length)` (`customer_vehicles_tab.dart:129-131`). Zero renders as digit `0`, one as singular — no "1 vehicles" in any branch.
- Pixel: `idle-2 en` → `2 registered vehicles`; `idle-6 en` → `6 registered vehicles`; `idle-2 ar` → `2 مركبات مسجلة`; `search-open ar` dimmed header → `6 مركبات مسجلة`. Correct both directions.
- Capture gap (not a behavior gap): no PNG renders the 0-case (`vhCount(0)` occurs only with an active filter returning nothing; empty-unfiltered correctly shows sanctioned `vhCountNone` per `empty_light_1.0_en_360x800.png`) or the 1-case. Filed for capture phase, non-gating.

## R2-2. FIX 2 — Year once: VERIFIED (pixel + code)
- Pixel (`idle-2 en`, `idle-6 en`, both cards): title `Toyota Camry · 2021` keeps year; specs line now `White · 45000 km` / `Silver · 78200 km` — year gone from specs. Same in `idle-2 ar` and all dimmed-card backgrounds of the 4 sheet frames. Round-1 observation #4 closed.
- Code: title carries year (`customer_vehicle_record.dart:74-76`), specs filtered with `yearToken` removed for display, predicate untouched (`:77-81`).

## R2-3. FIX 3 — Exact tap counts: VERIFIED as builder claims
- Book: DIRECT `TextButton.icon` on every card (`customer_vehicle_record.dart:371-378`), pixel-confirmed on all idle frames → **≤ 1 tap from list** (frequent action meets budget).
- Edit: `PopupMenuButton` → `PopupMenuItem('edit')` → same `customerEditVehicle(id)` route (`:379-394`, `customer_vehicles_tab.dart:264`). From launch: tab + ⋮ + Edit = **3 taps** (was 2 direct). +1 menu confirmed.
- Remove: tab + ⋮ + Remove + confirm SHEET (`_confirmRemove`, `customer_vehicles_tab.dart:348+`) = **3 + confirm** (was 2 + dialog-confirm). +1 menu confirmed; confirmation preserved (sheet, destructive, no undo).
- Decision (honest): the +1 is BRIEF-SANCTIONED (frequent-action binding reserves the direct slot for Book; Edit/Remove are infrequent, existing routes), so it is **not a U14 fail and triggers no C17 cap** — but it IS a real remaining cost vs before on a shipped path. A screen with a remaining cost cannot keep a perfect merit score. **−1 merit point** (criterion 4, see rubric). This agrees with the builder's 15/16 claim; round-1's 16/16 disclosure is superseded.

## R2-4. New frames — U-law check (esp. U5/U10/U14)
- **Remove sheet en** (`remove-sheet_light_1.0_en_360x800`): dimmed list behind; sheet has drag handle, title `Remove Toyota Camry?` + ×, body `ABC 1000 will be removed from your vehicles.`, exactly one filled destructive red `Remove vehicle` + `Keep vehicle` text. U7 PASS (destructive confirm sheet, no undo, existing route + snackbar kept per code). U5 PASS. U14 PASS (presentation dialog→sheet only).
- **Remove sheet ar**: full mirror (title right `حذف Toyota Camry؟`, × left, body right-aligned, plate `ABC 1000` LTR inside RTL sentence, red `حذف المركبة` + `إبقاء المركبة`). U10 PASS. U5/U14 PASS as en.
- **Filter sheet** (`filter-sheet_light_1.0_en_360x800`): `Filter vehicles` + ×, chips `All` (selected dark w/ check) / `In the workshop now` / `Booked or requested` / `Last service` / `No active context` wrapping cleanly, filled `Show results` + `Clear` text. Context-backed facets only. U5 PASS, U14 PASS (count update + Clear restore, no new destinations).
- **Search results** (`search-results_light_1.0_en_360x800`): query `ABC 1001` with in-field clear-×, single filtered row `Toyota Camry … ABC 1001`. U1 PASS (compact rows, tap closes + reveals, actions stay on record).
- **Search-open ar**: title `البحث في المركبات` right + × left, hint `ابحث بالاسم أو اللوحة أو اللون`, 6 rows mirrored (Latin name right, plate `ABC 100x` LTR left). U10 PASS (full mirror, LTR codes locked), U1 PASS (sanctioned exception honored: aids only in 6-item context).

## R2-5. Condensed U0–U14 re-walk (changed areas + new frames; rest unchanged from round-1)
| Law | Re-check | Result |
|---|---|---|
| U0 one-read | Year-once cards: `Toyota Camry · 2021` → `White · 45000 km` → `VIN JT1ABC` → pill + detail → `Book service` + ⋮ (idle + dimmed backgrounds) | PASS |
| U1 find fast | >5 shows magnifier+funnel (`idle-6`), ≤5 hides (`idle-2`); ar search + filtered search-results correct | PASS (sanctioned exception both directions) |
| U2/U3/U4 | Single-column cards, no tables; pills only from `contextFor`; plates/specs/VIN verbatim; zero as `0` (code) | PASS |
| U5 reachable/legible | All 5 new sheets: 48dp+ targets, no clipping @360, chips wrap; remove-body padding nit filed as non-gating obs R2-8.3 | PASS |
| U6 states | Empty pairs `vhCountNone` subtitle with 1-icon-1-sentence-1-action; loading/error unchanged | PASS |
| U7 feedback | Remove = destructive confirm SHEET en+ar, no undo; busy disables acting record only (code) | PASS |
| U8 no dead ends | Every pill card shows View; filter `Clear` restores; empty always offers Add | PASS |
| U9 consistency | Same `AppPageHeader`/`AppSurfaceCard`/`AppStatusChip`/`AppBanner`/`showAppModalSheet` atoms on all new sheets | PASS |
| U10 RTL | Remove-sheet ar + search-open ar fully mirrored, plates/VIN/figures/digits LTR | PASS |
| U11 a11y | Record Semantics kept; sheets use standard modal semantics + × affordance; no overflow evidence | PASS (stills-limited) |
| U12 density | Unchanged predicate; sheets are single-column overlays | PASS |
| U13 offline | Untouched pins (banners + inline retries) | PASS |
| U14 no regression | Book ≤1 from list; Add/View/retry unchanged; Edit/Remove +1 menu SANCTIONED (no cap, −1 merit per R2-3) | PASS (with noted cost) |
**U-walk fails: 0. Zero owner-file U fails; zero shell/shared fails visible in these 16 frames.**

## R2-6. Tap walk (after, exact)
Open ≤1 (tab) · Book ≤1 from list (direct) · Add ≤2 · Edit 3 from launch (+1 menu, sanctioned) · Remove 3+confirm (+1 menu, sanctioned, sheet confirm) · View/Track ≤2 · retry 1 inline. Frequent-action budget met; infrequent-action cost disclosed and scored.

## R2-7. Rubric (only after R2-1–R2-6), /16, pass ≥12
| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find vehicle → act; no competing heroes |
| 2 | Headline-first hierarchy | 2/2 | Title keeps year, specs de-duplicated; empty/error order kept |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light cards; sheets clean |
| 4 | Sheets for secondary actions | **1/2** | Pattern correct (menu → sheet, brief-sanctioned) but secondary actions measurably less direct than before (+1 menu layer each). The honest −1 lives here. |
| 5 | Sticky CTA (none) | 2/2 | Correctly absent; Add/Book in-flow; remove sheet exactly one destructive filled + Keep text |
| 6 | Section structure | 2/2 | Unchanged predicate; filter updates count verbatim, Clear restores |
| 7 | Plain friendly copy | 2/2 | Sentence-case, no invented claims, ar translated w/ LTR codes, ICU 0/1 correct, zero as `0` |
| 8 | Single emphasized primary action | 2/2 | One filled per state; no competing CTAs |
| **Merit** | | **15/16** | Pass on merit (≥12) |
| C16 hard-reject cap | borderless/one-read/no-duplicate-filled/no-permanent-pills/badges-clear/no-ALL-CAPS/search-sheet/above-fold+peek/hierarchy/zero-as-0 | **No cap** | ALL PASS (year duplication removed; zero `0` in code; search-sheet w/ disclosure) |
| C17 U-cap | any owner-file U-law fail caps at 8/16 | **No cap** | Zero U fails (R2-5) |
| **Final** | | **15/16 — PASS** | |

## R2-8. DEFECT LIST (each: evidence · law/criterion · gating?)
**Gating defects: NONE.** No C16 hit, no owner-file U fail, frequent-action tap budget met.
**Non-gating (scored or filed, do NOT gate):**
1. **Edit/Remove +1 menu tap from launch — SCORED (−1, criterion 4).** `idle-2/6` action rows (`Book service` + ⋮) + `customer_vehicle_record.dart:379-405`; `customer_vehicles_tab.dart:264-265,348+`. Brief-sanctioned infrequent-action cost; existing routes. Accounted in 15/16, not a cap.
2. **No PNG renders `vhCount(0)` (filtered-zero) or `vhCount(1)`.** Code-verified (`customer_localizations_en.dart:313-322`, `app_ar.arb:100`); empty-unfiltered correctly shows `vhCountNone`. Capture-phase gap. Non-gating.
3. **Remove-sheet description side padding looks tight (en+ar).** `remove-sheet_light_1.0_en/ar_360x800.png`: body line starts at/near sheet edge vs ~24px padding on filter/search sheets. Fully legible, targets fine — cosmetic inconsistency for owning phase, NOT a U5 fail. Non-gating.
4. Round-1 non-gating obs. #2–#3, #6 carry over unchanged (`AppSurfaceCard`-vs-`AppListGroup` resolution stands; missing contact sheet + `references/` UNMET — process artifacts, not screen defects). Round-1 obs. #4 (year duplication) and #5 (`vhCountMany` for 0/1) are CLOSED by fixes 1–2; obs. #1 (menu indirection) is now scored in R2-8.1.

## The two answers (round-2)
- **Would a first-time user know what to do in 3 seconds?** Yes. `idle-2_light_1.0_en_360x800.png`: `My vehicles / 2 registered vehicles`, `ABC 1000 · Toyota Camry · 2021`, `Booked — Oil change…` with `View`, direct `Book service`. Year read once; counts grammatical.
- **What would an Airbnb product designer reject here?** Nothing blocking. One honest nit shipped with the sanctioned pattern: Edit/Remove each cost one extra tap behind ⋮ (−1 merit, criterion 4). Polish carry-forwards: match remove-sheet body padding to filter/search sheets; capture filtered-zero + single-vehicle PNGs and the missing vehicles contact sheet.

(End of file — round 2, 2026-10-22. Round-1 content above preserved verbatim.)
