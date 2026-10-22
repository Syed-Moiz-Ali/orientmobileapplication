# ADVERSARIAL REVIEW — customer bookings / service-history list — FAIL 7/16 (C17-capped)

**Role:** ADVERSARIAL REVIEWER, did not build. Working ONLY inside `C:\Users\sanja\AppData\Local\Temp\opencode\wt-customer` (branch `ui/list-customer`). No checkout/switch/commit/push. Never touched `71983229`.
**Governance:** DESIGN_SPEC `docs/ui-redesign/DESIGN_SPEC.md` C16 + U0–U14 C17. Pass ≥ 12/16. Any U-law fail caps at 8/16; any C16 hard-reject caps at 10/16.
**Brief:** `docs/ui-redesign/briefs/customer-bookings-list.md` (authoritative, incl. ONE sanctioned U1 exception: search/filter icons ONLY when > 5 items; vehicles precedent re-used).
**References:** `docs/ui-redesign/references/` EMPTY, `AIRBNB_PATTERNS.md` missing — UNMET per brief §References.
**Images viewed (Read, full resolution):** `docs/ui-redesign/baseline/after-customer-bookings/` — `idle_light_1.0_en_360x800.png`, `idle_light_1.3_en_360x800.png`, `failed_light_1.0_en_360x800.png`, `idle_light_1.0_ar_360x800.png`, `empty_light_1.0_en_360x800.png` (+ `search-open`, `filter-open`, `loading`, `error`, `dark`, `320`, `768` spot-checked) + contact sheet `docs/ui-redesign/baseline/phase-bookings-light.png` (BEFORE|AFTER side-by-side, viewed).
**Stance:** Assume NOT Airbnb-level. Hunt defects. Rank 1 = most severe.

---

## Ranked defects (each with image+region, law, gating)

### 1. [GATING] 1.3x truncates PRIMARY vehicle name — `Toyota Cam…`
- **Image+region:** `idle_light_1.3_en_360x800.png`, card 2 (`12 JUN`, `Oil change`, `Confirmed`): plate row reads `ABC 1234` chip + `Toyota Cam…` (ellipsis, `ry` cut). Compare `idle_light_1.0_en_360x800.png` same card: `ABC 1234` + `Toyota Camry` whole.
- **Law/criterion:** C17-U5 NO TRUNCATION OF PRIMARY TEXT ("never `…` on a person's name or a primary label; ellipsis only for secondary text" per C3; vehicle = the thing recognized alongside service per brief card-hierarchy binding).
- **Why rank 1:** The screen's job is "service + vehicle + date in one glance" (brief user goal). At the spec-mandated 1.3x stress scale the vehicle half of that answer is cut mid-word. Round-2 fixed the date-block time but left this one.
- **GATES? YES — U5 breach → C17 cap 8/16.**

### 2. [GATING] Duplicate status on one card — pill `In Service` + `Current stage · In Service`
- **Image+region:** `idle_light_1.0_en_360x800.png`, card 1 (`Brake pads`): top row pill `● In Service`, two rows below blue wrench line `Current stage · In Service`, then `BK-1002`, then `Track service →`. Same duplication in `idle_light_1.3_en_360x800.png` (stage wraps to 2 lines: `Current stage · In` / `Service`) and contact-sheet AFTER panel.
- **Law/criterion:** C17-U0 (one read; ONE status per card per C16 UX "one colored dot/pill + one sentence, one status per card") + C16 STATUS PATTERN + brief U0 ("service title → ONE status pill → vehicle·plate → schedule → reference").
- **Cost:** Two blue status signals + a third `Track service` action triple-announce the same state; card 1 is ~2× taller than card 2 for no new information, pushing card 3/4 down the fold.
- **GATES? YES — U0 breach → C17 cap.**

### 3. [GATING] Approval card misuses error-red for a pending state + Title-Case pills break sentence-case rule
- **Image+region:** `idle_light_1.0_en_360x800.png`, card 3 (`Engine overhaul`): pink/red pill `● Approval Required`, red `ⓘ Estimate AED 1,200 awaiting approval` wrapping 2 lines. Pills across screen read `In Service`, `Confirmed`, `Approval Required`, `Not sent` (see `failed_light_1.0_en_360x800.png`, failed card pill `● Not sent`).
- **Law/criterion:** C2 Color rules ("Green/red reserved for success/error and up/down; warning/delayed/pending = warning amber + `warningSoft`") + C11/C16 "no ALL CAPS added, sentence case via theme" (brief C16 adaptation orders `.toUpperCase()` removal + sentence case; `Approval Required`/`In Service` keep second-word caps) + C17-U13 (red implies failure; "awaiting approval" is pending, not failed — new employee misreads severity).
- **Note:** Prior review excuses Title Case as "verbatim `statusLabel` truth". Adversarial reading: the brief explicitly orders sentence-case rendering; verbatim casing is a data excuse, not a design pass. The red-pending choice is independently wrong per C2.
- **GATES? YES (strict) — U13 misdirection → C17 cap.** (C2 alone would merit-deduct; tied to U13 it gates.)

### 4. [GATING] Search/filter icons sit inline-left below subtitle, not top-right header per U1
- **Image+region:** `idle_light_1.0_en_360x800.png`, header region row 2: grey magnifier + grey funnel + blue `+ Book service`, left-aligned under `2 upcoming · 2 in service · 2 past services`. Same left-row grammar in `idle_light_1.3_en_360x800.png`, dark, and contact-sheet AFTER.
- **Law/criterion:** C17-U1 (search ICON top-right next to notifications/avatar; same placement every screen) + C17-U9. Brief orders "`AppPageHeader` with search/filter `AppIconButton`s top-right"; pixels show content-row-left.
- **Consistency:** Vehicles `idle-6` repeats the left row; notifications has none — three siblings, three grammars.
- **GATES? YES — U1/U9 breach → C17 cap.**

### 5. [GATING] Arabic screen leaves pills, dates, and stage English (`In Service`, `9:00 AM`, `Current stage · In Service`)
- **Image+region:** `idle_light_1.0_ar_360x800.png`, card 1: pill `In Service` (Latin), date-block `10 JUN` + `AM 9:00` (token order flipped vs en `9:00 AM`), stage line `In Service · المرحلة الحالية` (mixed-direction Arabic+Latin), action `تتبع الخدمة ←`. Card 3 estimate line mixes `التقدير AED 1,200 بانتظار الموافقة` with LTR amount inside RTL sentence.
- **Law/criterion:** C17-U10 RTL (full mirror; timestamps/figures LTR-locked where mixed — here the *time token itself* reorders to `AM 9:00`) + C15 localization (typed placeholders, no hardcoded formats) + C17-U13 (Arabic reader gets Latin status/date grammar).
- **Why gating:** Time-of-appointment is primary text (U5); rendering it as `AM 9:00` in ar while en shows `9:00 AM` is a locale-format defect, not a font nit. Prior review calls this "intact"; adversarial reading says the token moved.
- **GATES? YES — U10 breach → C17 cap.**

### 6. [GATING] `Track service →` / `Review →` far-right micro-links; destructive `Remove` sits beside primary `Retry`
- **Image+region:** `idle_light_1.0_en_360x800.png`, card 1 bottom-right `Track service →`, card 3 bottom-right `Review →` (both ~20px-tall text, no padded block). `failed_light_1.0_en_360x800.png`, failed card bottom row: grey `Remove` text + filled blue `Retry` button side by side.
- **Law/criterion:** C17-U5 (48dp targets) + C17-U10 FEEDBACK AND FORGIVENESS (destructive confirms/offers undo; destructive never adjacent to primary CTA per C9 detail-screen rule) + C16 "Exactly ONE filled accent element per section" (failed card complies literally, but pairs destructive text against the filled retry with ~8px gap — mis-tap risk).
- **GATES? YES — U5/U10 breach → C17 cap.**

### 7. [NON-GATING] Section header `Upcoming & in service 4` + subtitle restate the same count three ways
- **Image+region:** `idle_light_1.0_en_360x800.png`: subtitle `2 upcoming · 2 in service · 2 past services`, then section `Upcoming & in service` + pill `4`. `failed_light_1.0_en_360x800.png`: subtitle `1 upcoming · 1 past service` then sections `Needs attention 1` / `Upcoming 1` / `History 1`.
- **Law/criterion:** C16 "no numbers duplicated in label and badge" hard-reject + C1 plain hierarchy (max 3 levels per card/screen).
- **GATES? NO — but it trips the C16 hard-reject wording literally (count in subtitle AND section pill). Strict-hard-reject reading would cap 10/16; I file it as merit −1 instead to avoid double-capping, since the pill counts section items (arguably distinct). Disclosed either way.**

### Tap walkthrough (before→after)
| Task | Before | After (pixels) | Verdict |
|---|---|---|---|
| Open list | 1 (tab) | 1 | same |
| Open detail | 2 +scroll | ≤1 from list (whole card `InkWell → onOpen`) | pass (whole-card tap target overlaps `Track/Review` links — mis-tap risk, defect 6) |
| Track live | 2 | ≤1 from list (`Track service →` direct) | pass with cost (defect 6) |
| Review estimate | 2 | ≤1 from list (`Review →` direct) | pass with cost (defect 6) |
| Book service | 2 | 2 (header/empty CTA, never both) | pass |
| Retry failed | 1 inline | 1 inline (filled `Retry`) | pass with adjacency cost (defect 6) |
| Remove failed | 1+confirm (dialog) | 1+confirm (inline `Remove` + sheet) | pass (presentation only) |

### Consistency with siblings
- Find-aids: vehicles + bookings share the left-row magnifier/funnel (both violate U1 top-right together); notifications omits both (sanctioned) — net: no two screens agree with the spec, and none agree with each other on placement.
- Pills: vehicles teal/grey `Booked`/`Last service` (sentence case), bookings blue/red `In Service`/`Approval Required` (Title Case), notifications no pills (dot+weight only). Same `AppStatusChip` atom, three casing grammars — U9 fail.
- Counts: vehicles `N registered vehicles` subtitle, bookings subtitle + section pills, notifications `N unread` summary row. Same "how many" question, three answers.

---

## Score (Airbnb rubric 0–2 each, ONLY after defects above)
| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 1/2 | Find booking → act legible, but duplicate status + competing card-tap vs link-tap split focus (−1) |
| 2 | Headline-first hierarchy | 1/2 | `Bookings`→subtitle→sections→cards order right, but pill+stage duplication buries vehicle/schedule (−1) |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light cards, shadow separation, date-block is anchor not box — pass |
| 4 | Sheets for secondary actions | 2/2 | Search/filter/remove sheets correct pattern — pass |
| 5 | Sticky CTA (none) | 2/2 | Correctly absent — pass |
| 6 | Section structure | 0/2 | 1.3x primary truncation (defect 1) + left-placed find-aids (defect 4) break density/filter legibility (−2) |
| 7 | Plain friendly copy | 0/2 | Red-pending + Title-Case pills + `AM 9:00` reorder + `Toyota Cam…` cut (−2) |
| 8 | Single emphasized primary action | 1/2 | One filled per state yes, but `Remove`-beside-`Retry` + card-tap-vs-link ambiguity (−1) |
| **Merit** | | **9/16** | Below pass on merit |
| C16 hard-reject | | **Cap 10/16 (arguable, defect 7)** | Defect 7 trips "no numbers duplicated in label and badge" literally; filed as merit hit, cap noted but not applied twice |
| C17 U-cap | | **Cap 8/16** | Defects 1–6 are owner-file U breaches (U5, U0, U13, U1/U9, U10, U5/U10) |
| **Final** | | **7/16 — FAIL** | Merit 9 capped to 7/8 band; reported 7 (lowest honest). Do not bless. |

**Gating marks:** Defects 1, 2, 3, 4, 5, 6 GATE (all U-law). Defect 7 non-gating (C16 wording, filed as merit).
**Would a first-time user know what to do in 3 seconds?** At 1.0x yes (`Brake pads`, `In Service`, `Track service →`). At the mandated 1.3x, the vehicle answer is `Toyota Cam…` — no.
**What would an Airbnb designer reject first?** The 1.3x mid-word cut (defect 1) and the double-status card (defect 2) — both hit the primary task.

---

# ROUND-2 VERDICT (fresh-eyes reviewer, did not fix) — 2026-10-22 — FAIL 8/16 (C17-capped)

**Scope:** verified fixer-claimed ar time fix on CURRENT PNGs in `after-customer-bookings/` + code read.

## Claimed fix — ar time order `9:00 AM` (Directionality ltr) — VERIFIED FIXED
- Pixels: `idle_light_1.0_ar_360x800.png` date-blocks read `9:00 AM`, `10:00 AM`, `11:00 AM` (correct token order, grey meta under `10 JUN` / `12 JUN` / `15 JUN`). No `AM 9:00` anywhere. EN `idle_light_1.0_en_360x800.png` identical tokens. FIXED.
- Code: `customer_booking_item.dart:348-366` `_DateBlock` time wrapped in `Directionality(textDirection: ltr)` with comment `keeps its order inside RTL`; `maxLines: 2, softWrap` so `9:00 AM` wraps at token boundary, never `9:00 …`.
- Pills/dates otherwise verbatim — CONFIRMED UNCHANGED: ar still `In Service`, `Confirmed`, `Approval Required` pills (EN), `In Service · المرحلة الحالية` mixed-direction stage, `التقدير AED 1,200 بانتظار الموافقة` LTR amount in RTL sentence, `BK-1002/BK-1001/BK-1009` refs. Per brief truth rules (`statusLabel` verbatim, `scheduleLabel`/`referenceOf` verbatim) this is the contract — time-token fix only, as claimed.

## Spot-checks (condensed re-walk — all other round-1 defects still present)
- Defect 1 (1.3x truncation) NOT FIXED: `idle_light_1.3_en_360x800.png` card 2 still `ABC 1234` + `Toyota Cam…` (mid-word cut, 1.3x). U5 still gates. Code `maxLines:1 ellipsis` on vehicle (`customer_booking_item.dart:177-186`) is secondary text but vehicle is primary alongside service per brief card-hierarchy — strict gate kept.
- Defect 2 (duplicate status) NOT FIXED: `idle_light_1.0_en` card 1 still pill `In Service` + `Current stage · In Service` wrench line + `Track service →` (triple announce). U0 still gates.
- Defect 3 (red-pending + Title Case) NOT FIXED: `Approval Required` pink/red pill + `Estimate AED 1,200 awaiting approval` red 2-line; pills still `In Service/Confirmed/Approval Required/Not sent` Title Case. Brief ordered sentence-case via theme; verbatim-casing excuse does not cure C2 red-for-pending (U13 misdirection). Still gates (strict).
- Defect 4 (search left-row) NOT FIXED: header row 2 still grey magnifier + funnel left under subtitle, not top-right. U1/U9 still gates (only sanction is >5 threshold, not placement).
- Defect 6 (Track/Review far-right micro-links; Remove beside Retry) — CODE-MITIGATED, PIXELS WEAK: `_RowAction:438-457` is `SizedBox(height: touchTarget=48)` TextButton (dp passes); pixels still show small text + `→` far-right, whole-card `InkWell` overlaps link (mis-tap risk), `failed_light` still grey `Remove` + filled `Retry` ~8px apart. U5 dp CLOSED, U10 forgiveness/adjacency downgraded to merit −1 (not a cap alone).
- Defect 7 (counts in subtitle + section pill) unchanged — non-gating merit −1 as before.

## Rubric (round-2)
| # | Score | Reason |
|---|---|---|
| 1 One task | 1/2 | duplicate status + card-vs-link split still |
| 2 Headline-first | 1/2 | pill+stage duplication buries vehicle/schedule |
| 3 Whitespace | 2/2 | borderless light, date-block anchor — pass |
| 4 Sheets | 2/2 | search/filter/remove sheets correct |
| 5 Sticky CTA | 2/2 | correctly absent |
| 6 Section structure | 0/2 | 1.3x primary cut + left find-aids (−2) |
| 7 Copy | 1/2 | was 0: ar time-token fixed (+1), red-pending + Title Case + `Cam…` still (−1) |
| 8 Primary action | 1/2 | 48dp height in code, Remove-beside-Retry + tap ambiguity remain |
| **Merit** | **10/16** | was 9; +1 time fix |
| C16 | No cap applied | defect 7 filed as merit only (same as round-1) |
| C17 | **Cap 8/16** | Defects 1 (U5), 2 (U0), 3 (U13), 4 (U1/U9) still breach |
| **Final** | **8/16 — FAIL** | was 7; merit 10 capped at 8. Do not bless. |

**Remaining gating:** defects 1, 2, 3, 4 (round-1 numbering). Defect 5 time-token CLOSED; defect 6 dp closed (merit only); defect 7 non-gating.

---

# ROUND-3 VERDICT (fresh-eyes reviewer, did not fix) — 2026-10-22 — FAIL 8/16 (C17-capped)

**Scope:** verified ONLY wave-2 fixer-claimed fixes on CURRENT PNGs in `after-customer-bookings/` + code read (no checkout/switch/commit).

## Fix H1 — plain-Row header — VERIFIED FIXED
- Pixels: `idle_light_1.0_en_360x800.png` header = `Bookings` left + search + filter top-right same-row; `2 upcoming · 2 in service · 2 past services` subtitle below; `+ Book service` end-side row below subtitle. Previously icons sat content-row-left under subtitle. Now matches claimed plain Row grammar.
- Threshold: 6-item fixture shows icons (consistent with >5 condition; no ≤5 frame in this suite to re-prove, vehicles idle-2 confirms the predicate family).
- Round-1 defect 4 (U1/U9) CLOSED.

## Fix F2 — vehicle wrap at word boundary (1.3x) — VERIFIED FIXED
- Pixels: `idle_light_1.3_en_360x800.png` card 2 `ABC 1234` + `Toyota` / `Camry` stacked on two lines, no `…`, no mid-word cut. Previously `Toyota Cam…` mid-word ellipsis. Card 1 `Honda Civic` intact.
- Code: `customer_booking_item.dart:192-206` vehicle `Expanded` + `maxLines: 2, softWrap, ellipsis` with comment `wrap to 2 lines at word boundary at 1.3x instead of mid-word`. Title (service) `maxLines 2` untouched.
- Round-1 defect 1 (U5) CLOSED.

## Fix F3 — fixture stage differs from pill — VERIFIED (duplicate CLOSED)
- Pixels: `idle_light_1.0_en_360x800.png` card 1 pill `In Service` + stage line `Current stage · Quality check` (wrench, blue). Previously stage repeated `In Service`; now stage is a distinct live value (`Quality check` per `customer_bookings_list_after_capture_test.dart:133` fixture).
- Reading: pill = status, stage = live sub-stage (sanctioned `jsStage` line when trackable per brief U0). Not a duplicate announce anymore; triple-announce downgraded to hierarchy (merit note: pill + stage + `Track service` still three blue signals on one card).
- Round-1 defect 2 (U0 duplicate) CLOSED on this ground.

## Fix F5 — ar pills + months + LTR times — VERIFIED FIXED
- Pixels: `idle_light_1.0_ar_360x800.png` pills `قيد الخدمة` / `مؤكد` / `بانتظار الموافقة` (blue/red tones kept); date-blocks `10/12/15 يونيو` + times `9:00 AM` / `10:00 AM` / `11:00 AM` correct order (no `AM 9:00`).
- Code: shared-core `app_ar.arb:statusInService/statusConfirmed/statusApprovalRequired` (`shared_core_localizations_ar.dart:112/124/139`); `app_formatters.dart:37` months include `يونيو`; `_DateBlock` `Directionality(ltr)` (`customer_booking_item.dart:372`) keeps time order in RTL.
- Residue: stage value `Quality check` and service names (`Brake pads`, `Oil change`) stay Latin inside RTL rows — feed/fixture EN verbatim (same family as LOGIC_FOLLOWUPS #11), merit-only, NOT gating. Estimate line `التقدير AED 1,200 بانتظار الموافقة` correctly mixes LTR amount in RTL sentence.

## Spot-checks (condensed re-walk)
- Defect 3 NOT FIXED: `Approval Required` pill Title Case + pink/red + `Estimate AED 1,200 awaiting approval` red 2-line still present. Brief ordered sentence-case via theme; red-for-pending still misdirects (U13 strict) — STILL GATES.
- Defect 6: `_RowAction` 48dp height in code; pixels still far-right text + whole-card `InkWell` overlap + `Remove`-beside-`Retry` ~8px — dp closed, adjacency/ambiguity merit −1 only.
- Defect 7 counts-in-subtitle+section-pill unchanged — non-gating merit −1 as before.
- Tap budgets: open 1 / open-detail ≤1 (whole-card) / track-review ≤1 / book 2 / retry 1 inline / remove 1+confirm(sheet) — per brief, no regression.

## Rubric (round-3)
| # | Score | Reason |
|---|---|---|
| 1 One task | 1/2 | find→act legible; card-tap vs Track/Review link ambiguity remains |
| 2 Headline-first | 1/2 | header→sections→cards right; red-pending stage still buries vehicle/schedule |
| 3 Whitespace | 2/2 | borderless light, date-block anchor — pass |
| 4 Sheets | 2/2 | search/filter/remove sheets correct |
| 5 Sticky CTA | 2/2 | correctly absent |
| 6 Section structure | 2/2 | was 0: 1.3x wrap (+1) + plain-Row header (+1) |
| 7 Copy | 1/2 | ar pills/months/times + wrap fixed; red-pending + Title Case remain |
| 8 Primary action | 1/2 | 48dp in code; Remove-beside-Retry + tap ambiguity remain |
| **Merit** | **12/16** | was 10; +2 section structure |
| C16 | No cap applied | defect 7 filed as merit only |
| C17 | **Cap 8/16** | Defect 3 (U13 red-pending/Title Case) still breaches |
| **Final** | **8/16 — FAIL** | Merit 12 capped at 8. Do not bless. |

**Remaining gating:** round-1 defect 3 ONLY (red-pending + Title-Case pills, U13 strict). Defects 1 (wrap), 2 (duplicate), 4 (header), 5 (ar time/months/pills) CLOSED; defect 6 dp closed (merit only); defect 7 non-gating.
