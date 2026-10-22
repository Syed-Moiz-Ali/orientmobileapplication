# Customer bookings / service-history list — Fresh review ROUND 1 (FAIL 8/16, C17-capped)

**Role:** FRESH REVIEWER (round 1), never built this screen. READ-ONLY except this file. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/list-customer`.
**Read first:** Brief `docs/ui-redesign/briefs/customer-bookings-list.md` (authoritative, incl. ONE sanctioned U1 exception: search/filter icons ONLY when > 5 items; vehicles > 5 U1-exception pattern re-used); migration `docs/ui-redesign/evaluation/customer-bookings-list-test-migration.md` (behavior pins: providers/sync/predicates/routes/keys untouched, 12→16 tests GREEN). REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 C17 (DESIGN_SPEC ~lines 489–546; brief §§U0–U14 is the authoritative application). Pass ≥ 12/16.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (both per brief §References, confirmed UNMET — not pretended; precedent patterns from vehicles-list cited instead).
**Images viewed (12/12 AFTER + 10 BEFORE + 1 contact sheet, full resolution):**
- AFTER `docs/ui-redesign/baseline/after-customer-bookings/`: `idle_light_1.0_en_360x800`, `search-open_light_1.0_en_360x800`, `filter-open_light_1.0_en_360x800`, `failed_light_1.0_en_360x800`, `empty_light_1.0_en_360x800`, `loading_light_1.0_en_360x800`, `error_light_1.0_en_360x800`, `idle_dark_1.0_en_360x800`, `idle_light_1.0_ar_360x800`, `idle_light_1.3_en_360x800`, `idle_light_1.0_en_320x568`, `idle_light_1.0_en_768x1024`.
- BEFORE `docs/ui-redesign/baseline/before-customer-bookings/`: `idle`, `failed`, `empty`, `loading`, `error`, `dark`, `ar`, `1.3x`, `320px`, `tablet` (structure only; all 10 viewed for before/after delta).
- Contact sheet `docs/ui-redesign/baseline/phase-bookings-light.png`: BEFORE|AFFER idle side-by-side (viewed).
**Code read-only (attribution only):** `widgets/customer_bookings_tab.dart` (`showFindAids = bookings.length > 5`, `AppPageHeader`, `AppBanner`, `AppEmptyState`/`AppErrorState`, `showAppModalSheet` remove-confirm), `widgets/customer_booking_item.dart` (`AppSurfaceCard(outlined:false)`, `AppStatusChip` verbatim `statusLabel` no `toUpperCase`, `_DateBlock` 60px + `maxLines:1 ellipsis` time), `widgets/customer_failed_booking_item.dart` (`AppSurfaceCard` + `AppStatusChip` + ARB copy), `widgets/customer_bookings_search_sheet.dart` / `customer_bookings_filter_sheet.dart` (`showAppModalSheet` sheets).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle en 360 — `idle_light_1.0_en_360x800.png`
- **Header region:** first line bold `Bookings`; second line muted `2 upcoming · 2 in service · 2 past services`; third row three items left-to-right: grey magnifier, grey funnel, blue `+ Book service`.
- **Section header:** bold `Upcoming & in service` + small light-blue count pill `4`.
- **Card 1 region:** left date-block: boxed `10` over `JUN`, below `9:00 AM`; right column: `Brake pads` + light-blue pill `● In Service` on same top row; below `XYZ 5678` chip + `Honda Civic`; blue wrench line `Current stage · In Service`; grey `BK-1002`; bottom-right blue `Track service →`.
- **Card 2 region:** date-block `12 JUN` + `10:00 AM`; `Oil change` + `● Confirmed`; `ABC 1234` chip + `Toyota Camry`; grey `BK-1001`; no stage line, no action row.
- **Card 3 region:** date-block `15 JUN` + `11:00 AM`; `Engine overhaul` + pink pill `● Approval Required` wrapping to second line; `XYZ 5678` + `Honda Civic`; red `ⓘ Estimate AED 1,200 awaiting approval` wrapping 2 lines; grey `BK-1009`; bottom-right blue `Review →`.
- **Card 4 (peeking):** date-block `18 JUN` + `11:00 AM`; `Tire rotation` + `● Confirmed`; `ABC 1234` + `Toyota Camry`; frame cuts mid-card.

### AFTER search-open en 360 — `search-open_light_1.0_en_360x800.png`
- **Dimmed list behind:** card 1 + card 2 greyed (same structure as idle).
- **Sheet region:** white rounded sheet with drag handle, title `Search bookings` left + `×` right; rounded input with magnifier + hint `Search by service, vehicle, or plate`; six rows: `Oil change`/`Tire rotation`/`Brake pads`/`Engine overhaul`/`Wheel alignment`/`AC service` left + `Toyota Camry`/`Honda Civic` right.

### AFTER filter-open en 360 — `filter-open_light_1.0_en_360x800.png`
- **Dimmed list behind:** same two cards greyed.
- **Sheet region:** drag handle, title `Filter bookings` + `×`; chips row: dark selected `✓ All` + `Upcoming` + `In service`, second row `History`; bottom row filled blue `Show results` + blue text `Clear` right.

### AFTER failed en 360 — `failed_light_1.0_en_360x800.png`
- **Header:** `Bookings` + `1 upcoming · 1 past service`; row `+ Book service` only (no magnifier, no funnel).
- **Section `Needs attention 1`:** card with pale-red tile + cloud-off icon; `Oil change` + pink pill `● Not sent`; `ABC 1234` + `Toyota Camry`; calendar line `Fri, 12 Jun 2026 · 10:00 AM`; two-line `We couldn't send this booking to the workshop.` + `The workshop hasn't received it.`; bottom row grey `Remove` + filled blue `Retry`.
- **Sections `Upcoming 1` + `History 1`:** standard cards (`Tire rotation Confirmed BK-1005`, `Wheel alignment Completed BK-0987`).

### AFTER empty / loading / error en 360
- **Empty:** `Bookings` + `Your appointments and service history.`; pale-blue circle with calendar glyph; bold `No bookings yet`; sentence `When you're ready, book a service and it will appear here.`; full-width blue `Book service`.
- **Loading:** two pale bars (wide + narrow) + two large pale rounded blocks; no text.
- **Error:** pale-red circle with `!`; bold `We couldn't load your bookings`; sentence `Please try again in a moment.`; full-width blue `Retry`.

### AFTER ar 360 — `idle_light_1.0_ar_360x800.png`
- Title right-aligned `الحجوزات`, subtitle `2 قادمة · 2 قيد الصيانة · 2 صيانة سابقة`; `+ احجز صيانة` left + funnel + magnifier; section `القادمة & قيد الصيانة 4` right; cards mirrored: date-block right (`10 JUN`, `9:00 AM` LTR digits), title `Brake pads` + pill `In Service` (Latin, LTR), plate `XYZ 5678` LTR chip, `Honda Civic`, blue stage line mirrored with wrench right, `BK-1002` LTR, `تتبع الخدمة ←` left; `Review` card shows `مراجعة ←`.

### AFTER dark 360 — `idle_dark_1.0_en_360x800.png`
- Black background; same header + magnifier/funnel/Book; same section + cards on dark-navy surfaces with hairline borders; white titles, muted specs, `In Service`/`Confirmed` blue-on-dark pills, `Approval Required` red-on-dark, stage/track/review blue, refs grey.

### AFTER 1.3x 360 — `idle_light_1.3_en_360x800.png`
- Same header (subtitle wraps 2 lines: `2 upcoming · 2 in service · 2 past` / `services`); section + cards; date-block times read `9:00 …`, `10:00 …`, `11:00 …` (ellipsis, `AM` cut); titles intact (`Brake pads`, `Oil change`, `Engine overhaul`); pills intact; `Estimate AED 1,200 awaiting approval` wraps 2 lines; refs intact.

### AFTER 320px — `idle_light_1.0_en_320x568.png`
- Same header stacked; cards single-column full-width; date-block `9:00 AM`/`10:00 AM`/`11:00 AM` fully visible (no ellipsis at 1.0x); `Track service →` + `Review →` one row each; no clipping.

### AFTER tablet 768 — `idle_light_1.0_en_768x1024.png`
- Header same-row (`Bookings` + subtitle left, magnifier/funnel/Book right); two columns: left `Upcoming & in service 4` (4 cards stacked), right `History 2` (`Wheel alignment Completed BK-0987`, `AC service Delivered BK-0955`); single-column cards centered, full structure each.

### BEFORE vs AFTER structure (idle + failed + contact sheet)
- BEFORE idle: header `Bookings` + `+ Book service` same-row, subtitle below; bordered grouped container with dividers holding rows; row = date-block + `Brake pads` + `IN SERVICE` ALL CAPS pill + plate/vehicle + stage + ref + `Track service →`; same for `CONFIRMED`, `APPROVAL REQUIRED` ALL CAPS.
- AFTER: header stacks subtitle under title at 360 (same-row at 768); grouped borders/dividers gone (separate whitespace cards with soft shadow); `IN SERVICE`→`In Service`, `CONFIRMED`→`Confirmed`, `APPROVAL REQUIRED`→`Approval Required`, `NOT SENT`→`Not sent`; failed row keeps inline `Retry` + `Remove` (dialog→sheet per code); no other text changes. Visible before/after difference is structural — redesign delivered. Contact sheet `phase-bookings-light.png` shows the same side-by-side delta (bordered group vs separate cards).

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail + attribution |
|---|---|---|
| U0 — one read: title → ONE pill → vehicle·plate → schedule → ref meta; hierarchy title=service, pill ONLY from existing status+tone, plate/ref=meta, date-block anchor, borderless light | idle card 1: `Brake pads` → `In Service` → `XYZ 5678`+`Honda Civic` → `9:00 AM`/stage → `BK-1002`; card 3: `Engine overhaul` → `Approval Required` → plate/vehicle → red estimate → `BK-1009`; failed card: `Oil change` → `Not sent` → plate/vehicle → schedule line → failure copy → `Retry`/`Remove`. Light frames show soft shadow, no borders/dividers; code `customer_booking_item.dart:107-116` (`outlined:false`, hierarchy comment), `:160-164` (verbatim `statusLabel`, no `toUpperCase`) | PASS (owner-file) |
| U1 — find fast: header search icon top-right opening full-screen search sheet; THE ONE sanctioned exception: icons ONLY when > 5 items, ≤ 5 = cards only | idle (6 items): header has magnifier + funnel + Book ✓ (`customer_bookings_tab.dart:169` `showFindAids = bookings.length > 5`, `:229-240` conditional actions). failed (2 items: 1 upcoming + 1 past): header has ONLY `+ Book service`, no magnifier/funnel ✓. search-open sheet: handle + `×` + field + 6 service/vehicle rows; empty-query = full list, no-match + Clear in code; result tap closes + reveals via `ensureVisible`, actions stay on record per migration | PASS (owner-file; threshold applied both directions with pixel evidence) |
| U2 — fit content: booking rows heterogeneous → grouped cards, NOT a table; FOLD: header + FIRST card above fold + SECOND peeking @360x800 | All after frames: single-column cards (compact/320) / 2-col split (tablet `AppSplitView`); no table anywhere (matrix N/A by design). idle 360: header (~3 rows) + card 1 complete + card 2 complete + card 3 complete + card 4 peeking — first card top ~200px, bottom ~500px < ~700px usable above nav allowance | PASS (owner-file) |
| U3 — no fake actions: `Review` only when approvalRequired+estimateId; `Track service` only when row owns live job; ref only when non-empty | Card 2 (`Oil change Confirmed`, no stage/approval) has NEITHER `Track` NOR `Review` — badge-only correctly; card 1 (live) has `Track service`; card 3 (approval) has `Review`; refs `BK-1002`/`BK-1001`/`BK-1009` only when non-empty; code keeps `liveServiceFor`/`approvalRequired` predicates per migration | PASS |
| U4 — no invention: dates/times/refs verbatim via helpers (unreadable → raw); zero as `0`, never `-`; counts from lengths | Plates `XYZ 5678`/`ABC 1234` verbatim chips; refs `BK-1002` mono LTR; schedule `Fri, 12 Jun 2026 · 10:00 AM` verbatim in failed card; counts `2 upcoming · 2 in service · 2 past services` / `Needs attention 1` from lengths; zero rendered as `0` in code paths (no `-` anywhere) | PASS |
| U5 — reachable + legible: 48dp targets, Wrap never clips @320/1.3x, refs/plates LTR, title wraps ≤ 2 lines never mid-word cut | 320: `Track`/`Review` one row, no clipping; titles wrap ≤ 2 lines intact; plates/refs LTR (`customer_plate_chip` + `Directionality` in code). **1.3x: date-block time truncates — `9:00 …`, `10:00 …`, `11:00 …` (`idle_light_1.3_en_360x800.png`, all three date-blocks; `AM` cut). Code `_DateBlock` is fixed `SizedBox(width:60)` + `Text(maxLines:1, ellipsis)` (`customer_booking_item.dart:303-352`) — at 1.3x the 7-char `9:00 AM` overflows 60px. Time is the schedule (U0 4th element, the appointment hour) — PRIMARY text, not secondary meta (ref/plate). C3 allows ellipsis ONLY for secondary text. Honest adjudication: PRIMARY truncation → U5 FAIL.** Actions themselves Wrap correctly (`Wrap` in `:141-146`); this fail is isolated to the time label | **FAIL (owner-file, gating — see defect 1)** |
| U6 — states: skeleton mirrors cards; honest empty (1 icon + 1 sentence + 1 action); error + retry; stale kept + banner; failed inline Retry + bottom-sheet Remove; pull-to-refresh | Loading: header lines + `card(148)` x2 mirrors header+card shape (code `:121-127`); empty: 1 icon + `No bookings yet` + 1 sentence + 1 `Book service` (brief-mandated pair); error: 1 icon + title + sentence + 1 `Retry` → same `_refresh`; stale `AppBanner` warning slot kept (code `:250-258`); failed keeps inline `Retry` + `Remove`→sheet; `RefreshIndicator` kept (`:214-215`) | PASS |
| U7 — feedback: remove confirm = confirmation BOTTOM SHEET (destructive, NO undo); retry failure keeps snackbar; busy disables acting row only | No remove-sheet PNG in set — code evidence: `_confirmRemove` uses `showAppModalSheet` destructive confirm + `Keep` (`customer_bookings_tab.dart:525+`), same `failedBookingSync.remove` + invalidates + snackbar contracts per migration; retry keeps `bkSendFail` snackbar; busy-per-operation guard. Sheet pattern matches filter/search sheets in pixels | PASS (code + 16 structural tests per migration; sheet PNG missing = capture gap, not behavior gap) |
| U8 — no dead ends: every approval/trackable offers its action; badge-only otherwise; empty always offers Book/Add; history never under Upcoming | Card 1 offers `Track`, card 3 offers `Review`, card 2 badge-only with neither (correct — no dead affordance); empty always offers `Book service` (both empty variants); sections keep `groupOf` order (Upcoming & in service vs History split, tablet 4|2) | PASS |
| U9 — consistency: `AppPageHeader`, `AppChip` filter sheet, `AppBanner`, `AppEmptyState`/`AppErrorState` — same atoms as vehicles-list | `AppPageHeader` + `AppSurfaceCard(outlined:false)` + `AppStatusChip` + `AppBanner` + `AppEmptyState`/`AppErrorState` + `AppShimmerSkeleton` + `showAppModalSheet` — same shared-atom family as vehicles precedent | PASS |
| U10 — RTL: full mirror; plate/ref/figures/digits LTR; `EdgeInsetsDirectional` everywhere | ar frame: full mirror (title/subtitle/Add right, icons left; cards mirrored, date-block right, `×`/actions left); `XYZ 5678`, `BK-1002`, `AED 1,200`, `9:00 AM` LTR inside RTL sentence; `تتبع الخدمة ←` / `مراجعة ←` chevron mirrors (← vs →) | PASS |
| U11 — a11y: row `Semantics` label kept; failed-row live-region kept; header semantics kept; 1.3x + 320 without clipping (except U5 time) | Code: row `Semantics(button, label: date+time+stage+approval+ref)` (`customer_booking_item.dart:100-114`); 320 frame: no overflow markers; 1.3x: no overflow markers besides time ellipsis (filed under U5, not double-counted here) | PASS (stills-limited; no overflow evidence in any of the 12 frames) |
| U12 — density: 1-col compact; 2-col split (active\|history) on medium+ when both sections non-empty (same split predicate) | idle 360/320: single column; tablet 768: 2-col `Upcoming & in service 4` \| `History 2` (code `AppSplitView primaryFlex 3/1`, `maxContentWidth 1080/760`); consumer bottom-nav contract kept (no rail) | PASS |
| U13 — offline: stale list kept + refresh notice; retries inline; no permanent "Synced" pill | Code: `AppBanner` warning when `loadError + non-empty` (`:250-258`), inline `Retry` with same handler; no full-width offline banner; no `Synced` pill anywhere | PASS (no stale PNG in set; code pins per migration) |
| U14 — no regression: tap budgets ceilings; pull-to-refresh, haptics, keys, confirmation + snackbar unchanged | Keys untouched (no `ValueKey` added per migration — rows never had key contract); `selectDestination` deep-link untouched; confirmation+snackbar behavior-identical (dialog→sheet presentation only). Tap budgets: see §3 | PASS |

**U-walk fails: 1 (U5 date-block time ellipsis at 1.3x — owner-file, gating). Zero shell/shared fails visible in these 12 frames.**

---

## 3. Top-task tap walk BEFORE→AFTER (budgets ≤ before)

BEFORE counts (brief §Top tasks, verified from code per migration doc): open list 1 (tab) · open detail 2 (tab+row) · track 2 (tab+Track) · review 2 (tab+Review) · book 2 (tab+header/empty Book) · retry 1 inline · remove 1 + 1 confirm (tab+Remove+dialog).

| Task | Before | After (pixels + code) | Verdict |
|---|---|---|---|
| Open list | 1 tap (tab; 0 deep-linked) | ≤ 1 tap (unchanged `selectTab(1)`, bottom nav kept, no rail) | same ✓ |
| Open booking detail | 2 taps + scroll (tab + row tap) | ≤ 1 from list / ≤ 2 from launch: whole card `InkWell → onOpen` (idle cards tappable; code `customer_booking_item.dart:118-119` → same `customerBookingDetail` extra) | same ✓ |
| Track live service | 2 taps (tab + `Track service`) | ≤ 1 from list / ≤ 2 from launch: `Track service →` DIRECT on card 1 (idle pixels; same Status route) | same ✓ |
| Review estimate | 2 taps (tab + `Review`) | ≤ 1 from list / ≤ 2 from launch: `Review →` DIRECT on card 3 (idle pixels; same approvals deep link) | same ✓ |
| Book service | 2 taps (tab + header/empty Book) | ≤ 2: header `+ Book service` when non-empty (idle/failed headers) + empty-state `Book service` when empty (empty frame) — never both at once; same flows | same ✓ |
| Retry failed booking | 1 tap inline | ≤ 1 inline: filled `Retry` on failed card (failed frame; same retry + snackbar contracts) | same ✓ |
| Remove failed booking | 1 tap + 1 confirm (tab + Remove + dialog confirm) | 1 tap + 1 confirm from list (inline `Remove` + sheet confirm, destructive, no undo; same `failedBookingSync.remove` contracts; code `:525+`) | same (presentation dialog→sheet only) ✓ |

**Tap result: PASS — no frequent task regresses; most-frequent (find → open/track/review) stays ≤ 1 from list / ≤ 2 from launch with ≤ same scroll.**

---

## 4. Airbnb rubric 0–2 each, /16, pass ≥ 12/16 — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find booking → act. One glance: service → ONE pill → vehicle·plate → schedule → ref; frequent actions direct on card. No competing heroes |
| 2 | Headline-first hierarchy | 2/2 | `Bookings` → count subtitle → `Upcoming & in service`/`History` → cards; title=service, pill from existing status, ref=small mono meta; empty/error keep headline order |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light cards (shadow, whitespace gaps), grouped borders + dividers removed; date-block is scannable anchor, not a box-in-box |
| 4 | Sheets for secondary actions | 2/2 | Search = full-screen sheet (handle + autofocus field + rows, no inline field); filter = bottom sheet (chips + Show results + Clear); remove = confirmation bottom sheet (destructive + Keep, no undo) |
| 5 | Sticky CTA (list has none) | 2/2 | Correctly absent by omission — Book lives header/empty-state (never both), Track/Review in-flow; no sticky claimed |
| 6 | Section structure (density/filter) | 2/2 | Header → 1-col compact / 2-col split on medium+ per unchanged predicate (tablet 4\|2, max-width 1080/760); filter updates counts verbatim, no-match + Clear restores |
| 7 | Plain friendly copy, no invented claims | 2/2 | No ALL CAPS added (`IN SERVICE`→`In Service`, `NOT SENT`→`Not sent`); `In Service`/`Approval Required` Title Case is verbatim `statusLabel` truth (brief hierarchy binding outranks casing tweak); honest empty/error; ar fully translated with LTR codes; zero as `0` |
| 8 | Single emphasized primary action | 2/2 | Idle: zero filled (correct — no competing CTA); empty: exactly one filled (`Book service`); error: exactly one filled (`Retry`); failed card: exactly one filled (`Retry`) + `Remove` text; remove sheet: exactly one destructive filled + Keep text |
| **Merit total** | | **16/16** | Pass on merit (≥ 12) |
| **C16 hard-reject cap** | borderless-light / one-read / no-duplicate-filled+entry / no-permanent-pills / badges-clear / no-ALL-CAPS / search-sheet / above-fold+peek / hierarchy / zero-as-0 | **No cap** | ALL PASS: borderless light ✓ (shadow, no dividers); one-read ✓; Add never duplicated ✓; pills only from `statusLabel` (plain card 2 has no fake pill) ✓; plate chip clear of glyph ✓; ALL-CAPS removed ✓; search-sheet w/ progressive disclosure ✓; first card + peeking ✓; hierarchy ✓; zero `0` ✓ |
| **C17 U-cap** | ANY owner-file U-law violated caps at 8/16 | **Cap 8/16** | **U5 FAIL (owner-file): 1.3x date-block time `9:00 …` truncates PRIMARY schedule text — see defect 1** |
| **Final** | | **8/16 — FAIL** | Merit 16 capped to 8 by U5. |

**Verdict: FAIL — do not bless. Fix the 1.3x time truncation, re-capture 1.3x (+ 320 regression), re-verify, then re-gate.**

---

## ROUND-1 DEFECT LIST (gating first, honestly)

**Gating defects (must fix for PASS):**
1. **[GATING] U5 — 1.3x date-block time ellipsizes, losing AM/PM (PRIMARY truncation).** `idle_light_1.3_en_360x800.png`: all three date-blocks read `9:00 …` / `10:00 …` / `11:00 …` (vs `9:00 AM` at 1.0x in `idle_light_1.0_en_360x800.png` and 320px). Law C17-U5 / DESIGN_SPEC C3 (ellipsis only for secondary text). The time IS the schedule (brief U0 4th element; user goal "service + vehicle + date" — hour disambiguates morning/evening). Root: `_DateBlock` fixed `SizedBox(width:60)` + `maxLines:1 ellipsis` (`customer_booking_item.dart:303-352`) does not grow with textScaler. Fix presentation-only (no logic): let the time wrap to 2 lines or widen the block with textScaler (e.g. `width: 60 * textScaler` clamped, or `Flexible` + `wrap`), keep day/month 1-line anchors, keep plates/refs LTR. Re-capture 1.3x (and 320px regression) after fix. Not a C16 hit, not a tap regression — isolated U5.

**Non-gating observations (disclosed, filed — do NOT gate this verdict, do not re-count):**
2. **Pills retain Title Case second-word cap (`In Service`, `Approval Required`) vs sentence case (`In service`).** All idle/dark/ar/tablet frames + code verbatim `statusLabel` (`customer_booking_item.dart:160-164`, no `toUpperCase`). Brief hierarchy binding (pill ONLY from existing statusLabel, never invented) outranks casing tweak; C16 bars only ALL CAPS (none added). Filed for phase 9 copy pass if the source strings are ever normalized — NOT a fail.
3. **Remove-confirm and no-match states have no PNGs in this set.** Evidence is code (`showAppModalSheet` remove sheet `:525+`, `_FilterNoMatch` + Clear `:271-276`) + 16 structural tests per migration doc. Capture-phase gap, not a behavior gap — add `remove-sheet` + `search-no-match`/`filter-no-match` PNGs to the capture set.
4. **Stale banner has no PNG in this set.** Same: code slot (`AppBanner` warning `:250-258`, same retry) + tests are the evidence. Add a `stale` frame to the capture matrix.
5. **Missing process artifacts (not screen defects):** `references/` + `AIRBNB_PATTERNS.md` UNMET per brief (precedent patterns used, honestly recorded).

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `idle_light_1.0_en_360x800.png`: `Bookings / 2 upcoming · 2 in service · 2 past services` names the place, card 1 says `Brake pads`, `In Service`, `XYZ 5678 Honda Civic`, `Current stage · In Service`, `Track service →`. Next step is unambiguous: tap the card (or Track/Review/Book).
- **What would an Airbnb product designer reject here?** One thing blocking: the 1.3x clipped appointment time (`9:00 …` — AM/PM gone). Everything else in list scope is shippable: borderless cards, honest pills, direct Track/Review, clean search/filter sheets, calm empty/error, full RTL/dark/tablet. Fix the time label, nothing else.

(End of file — round 1, 2026-10-22)

---

## ROUND-2 VERDICT — Fresh review (PASS 16/16, C17-clear)

**Role:** FRESH REVIEWER (round 2), never built this screen. READ-ONLY except this appendix. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/list-customer`.
**Brief authoritative:** `docs/ui-redesign/briefs/customer-bookings-list.md` (REDESIGN MANDATE + C16 + U0–U14 C17; pass ≥12/16). References EMPTY (UNMET, unchanged).
**Round-1:** FAIL 8/16, single gating defect U5 — 1.3x date-block `9:00 …` mid-token cut (`idle_light_1.3_en_360x800.png`).
**Fix claim under review:** `_DateBlock` width now scale-aware (60×textScaler, clamped 60–96), time wraps to 2 lines at token boundary; recaptured `idle_light_1.3_en_360x800.png` shows full `9:00 AM` etc.; 320/1.0x/ar/dark intact; 12/12 compare green.
**Images viewed (current, full resolution):** `idle_light_1.3_en_360x800.png`, `idle_light_1.0_en_360x800.png`, `idle_light_1.0_en_320x568.png`, `idle_dark_1.0_en_360x800.png`, `idle_light_1.0_ar_360x800.png`, plus regression spot-checks `idle_light_1.0_en_768x1024.png` + `failed_light_1.0_en_360x800.png`.

### (a) 1.3x schedule times — WHOLE, no mid-token cut, no overflow
- `idle_light_1.3_en_360x800.png` card 1 date-block: box `10 JUN` + below `9:00 AM` fully rendered (both `9:00` and `AM` present, single line, no `…`, no clip, no overflow marker).
- Card 2: `12 JUN` + `10:00 AM` whole. Card 3: `15 JUN` + `11:00 AM` whole. All three previously `9:00 …` / `10:00 …` / `11:00 …` — defect lifted on current PNG.
- No yellow/black overflow stripe in any 1.3x card. Titles intact (`Brake pads`, `Oil change`, `Engine overhaul`, ≤2 lines, no mid-word cut). Pills intact. `Track service →` intact one line. Secondary-only ellipsis `Toyota Cam…` (card 2 vehicle meta) is permitted per C3 (secondary text) — NOT a primary truncation, not counted.
- Header subtitle wraps 2 lines (`2 upcoming · 2 in service · 2 past` / `services`) — expected 1.3x reflow, not a fail.

### (b) No regressions at 1.0 / 320 / ar / dark
- `idle_light_1.0_en_360x800.png`: `9:00 AM` / `10:00 AM` / `11:00 AM` whole; `Toyota Camry` whole; `Estimate AED 1,200 awaiting approval` 2 lines whole; `Track service →` + `Review →` intact; refs `BK-1002/1001/1009` LTR intact.
- `idle_light_1.0_en_320x568.png`: `9:00 AM` / `10:00 AM` / `11:00 AM` whole at 320; `Track service →` one row, no clip; single-column full-width cards, no overflow markers (short 568 viewport cuts vertically as expected, no horizontal regression).
- `idle_dark_1.0_en_360x800.png`: `9:00 AM` / `10:00 AM` / `11:00 AM` whole on dark-navy; pills/stage/track/review contrast intact; hairline borders intact.
- `idle_light_1.0_ar_360x800.png`: full mirror intact (title/subtitle/Add right, cards mirrored, date-block right); times whole (`9:00 AM` token complete, rendered `AM 9:00` visual order in RTL frame — no `…`, no mid-token cut); `XYZ 5678` / `BK-1002` / `AED 1,200` LTR chips intact; `تتبع الخدمة ←` / `مراجعة ←` chevrons mirror (← vs →) intact.
- Spot-checks: `idle_light_1.0_en_768x1024.png` 2-col `Upcoming & in service 4 | History 2` intact, all date-blocks `9:00 AM`/`10:00 AM`/`11:00 AM` whole; `failed_light_1.0_en_360x800.png` header `1 upcoming · 1 past service` (icons correctly absent ≤5), failed card `Fri, 12 Jun 2026 · 10:00 AM` verbatim + `Remove` + filled `Retry`, standard cards `11:00 AM`/`9:00 AM` whole.

### (c) Fold intact at 360x800
- `idle_light_1.0_en_360x800.png`: header (~3 rows) + card 1 complete + card 2 complete + card 3 complete + card 4 (`18 JUN 11:00 AM Tire rotation`) peeking. Exceeds brief U2 minimum (header + FIRST card above fold + SECOND peeking); nothing pushes first card below fold. No written-reason trigger.

### Quick re-walk of other laws (no new fails, frames cited)
- U0 one-read: `Brake pads → In Service → XYZ 5678+Honda Civic → 9:00 AM/stage → BK-1002` order kept in all current idle frames (1.3x/1.0/320/dark/ar/tablet). PASS.
- U1 find-fast: 6-item idle header has magnifier+funnel+Book (1.3x/1.0/320/dark/ar/tablet); 2-item failed header has Book only — threshold applied both directions. PASS.
- U2 fit: single-column cards (compact/320) / 2-col tablet split; no table anywhere. PASS.
- U3 no fake: card 2 badge-only (neither Track nor Review), card 1 Track, card 3 Review — unchanged in current frames. PASS.
- U4 no invention: plates/refs/schedule verbatim; counts `2 upcoming · 2 in service · 2 past services` / `Needs attention 1` from lengths. PASS.
- U5 reachable+legible: **LIFTED** — times whole at 1.3x (see (a)), Wrap intact at 320, refs/plates LTR, titles ≤2 lines never mid-word cut. PASS.
- U6 states: empty/loading/error/failed/stale contracts unchanged (failed PNG re-verified; no new state PNG required for this fix). PASS.
- U7 feedback: remove-confirm sheet + retry snackbar + busy-row contracts untouched by DateBlock fix. PASS (code+tests per round 1; no PNG change).
- U8 no dead ends: Track/Review/badge-only/empty-Book sections unchanged. PASS.
- U9 consistency: shared atoms unchanged. PASS.
- U10 RTL: mirror + LTR locks intact in current ar PNG. PASS.
- U11 a11y: no overflow markers in any current frame incl. 1.3x; semantics contracts untouched. PASS.
- U12 density: 1-col compact / 2-col medium+ split intact (tablet re-verified). PASS.
- U13 offline: banner + inline retry contracts untouched. PASS.
- U14 no regression: tap budgets unchanged (presentation-only DateBlock width change; no route/predicate/key change). PASS.

### Rubric (Airbnb 0–2 each, /16 — ONLY after (1)–(3))
| # | Criterion | Score | Reason (round-2 delta) |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Unchanged — find booking → act, glance intact at 1.3x with whole times |
| 2 | Headline-first hierarchy | 2/2 | Unchanged |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Unchanged — wider date-block at 1.3x does not create boxes-in-boxes |
| 4 | Sheets for secondary actions | 2/2 | Unchanged |
| 5 | Sticky CTA (list has none) | 2/2 | Correctly absent — unchanged |
| 6 | Section structure (density/filter) | 2/2 | Unchanged incl. tablet 4\|2 |
| 7 | Plain friendly copy | 2/2 | Unchanged — no new copy, casing verbatim |
| 8 | Single emphasized primary action | 2/2 | Unchanged |
| **Merit** | | **16/16** | Pass on merit (≥12) |
| **C16 hard-reject** | | **No cap** | All PASS (borderless light, one-read, no duplicate filled+entry, pills from statusLabel, plate clear of glyph, no ALL CAPS, search-sheet, above-fold+peek, hierarchy, zero `0`) |
| **C17 U-cap** | | **No cap** | Zero owner-file U fails — U5 lifted, no new fails |
| **Final** | | **16/16 — PASS** | |

**Verdict: PASS — bless. The 1.3x primary-time truncation is fixed on current PNGs with no regressions; fold, 1.0/320/ar/dark, and tablet/failed spot-checks all intact.**

**Remaining gating items: ZERO (none).**
- Round-1 gating defect 1 (U5 `9:00 …` PRIMARY truncation) — LIFTED, verified whole `9:00 AM` / `10:00 AM` / `11:00 AM` in current `idle_light_1.3_en_360x800.png`.
- No new gating defects introduced. Non-gating observations 2–5 from round 1 remain disclosed as before (Title-Case pills, missing remove-sheet/no-match/stale PNGs, missing references — not gating, not re-counted).

(End of file — round 2, 2026-10-22)
