# Customer notifications list — Fresh review ROUND 1 (PASS 16/16, second-reviewer confirmation pending)

**Role:** FRESH REVIEWER (round 1), never built this screen. READ-ONLY except this file. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/list-customer`.
**Read first:** Brief `docs/ui-redesign/briefs/customer-notifications-list.md` (authoritative, incl. TWO sanctioned deviations: NO search icon — not even > 5 — and NO filter sheet, each with written reason; vehicles > 5 U1-exception pattern does NOT apply here); migration `docs/ui-redesign/evaluation/customer-notifications-list-test-migration.md` (behavior pins: providers/sync/predicates/`groupOf`/`labelOf`/`destination`/read-marker/routes/keys untouched, 0→11→11 tests GREEN). REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 C17 (DESIGN_SPEC ~lines 489–546; brief §§U0–U14 is the authoritative application). Pass ≥ 12/16.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (both per brief §References, confirmed UNMET — not pretended; vehicles-list / bookings-list precedent cited instead).
**Images viewed (12/12 AFTER + 10 BEFORE + 1 contact sheet, full resolution):**
- AFTER `docs/ui-redesign/baseline/after-customer-notifications/`: `idle_light_1.0_en_360x800`, `markall_light_1.0_en_360x800`, `allread_light_1.0_en_360x800`, `stale_light_1.0_en_360x800`, `empty_light_1.0_en_360x800`, `error_light_1.0_en_360x800`, `loading_light_1.0_en_360x800`, `idle_dark_1.0_en_360x800`, `idle_light_1.0_ar_360x800`, `idle_light_1.3_en_360x800`, `idle_light_1.0_en_320x568`, `idle_light_1.0_en_768x1024`.
- BEFORE `docs/ui-redesign/baseline/before-customer-notifications/`: `idle`, `allread`, `empty`, `error`, `loading`, `stale`, `dark`, `ar`, `1.3x`, `320px` (structure only; all 10 viewed for before/after delta).
- Contact sheet `docs/ui-redesign/baseline/phase-notifications-light.png`: BEFORE|AFTER idle side-by-side (viewed).
**Code read-only (attribution only):** `presentation/customer_notifications_view.dart` (`AppScaffold`+`AppAppBar`, `_SummaryRow` `unread>0` predicate, `_GroupSection` `AppSurfaceCard(outlined:false)`, `_NotificationRow` dot+tone+title/body/meta+chevron-iff-destination, `AppBanner` stale/mark-fail, `AppEmptyState` calm no-action, `AppErrorState`, `AppShimmerSkeleton` rows, `RefreshIndicator`).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle en 360 — `idle_light_1.0_en_360x800.png`
- **Bar region:** left back arrow, centered-left title `Notifications`.
- **Summary row:** left bold `2 unread`, right blue `Mark all read`.
- **Group `Service updates`:** card: grey dot + grey calendar-check icon, bold `Booking confirmed`, muted `Your Camry is booked for Saturday at 10:00.`, muted `Booking · 2h ago`, pale chevron right.
- **Group `Approvals`:** card with pale-blue tint: blue dot + blue list-check icon, bold `Estimate needs approval`, muted `Review the brake estimate before work continues.`, muted `Approval · 3h ago`, pale chevron right.
- **Group `Invoices & receipts`:** white card: grey receipt icon (no dot), bold `Invoice ready`, muted `Invoice INV-2041 is ready for payment.`, muted `Invoice · 1d ago`, pale chevron right.
- **Group `General` (partial):** white card top: grey bell icon (no dot), bold `Workshop update`; frame cuts mid-body.

### AFTER markall en 360 — `markall_light_1.0_en_360x800.png`
- Same bar; summary `1 unread` + `Mark all read`; single group `Service updates` with one card (`Booking confirmed`, grey dot, `Booking · 2h ago`, chevron).

### AFTER allread en 360 — `allread_light_1.0_en_360x800.png`
- Same bar; summary muted `All read` (no button); group `Invoices & receipts` (`Invoice ready`, no dot, chevron) + group `General` (`Workshop update`, no dot, no chevron visible).

### AFTER stale en 360 — `stale_light_1.0_en_360x800.png`
- Same bar + `2 unread` + `Mark all read`; below a pale-yellow banner with warning triangle + `We couldn't refresh your information.` + blue `Retry`; then groups `Service updates` / `Approvals` / `Invoices & receipts` / `General` (same row structures as idle, first rows fully visible below banner).

### AFTER empty / loading / error en 360
- **Empty:** bar only, then centered pale-blue circle with bell glyph; bold `You're all caught up`; sentence `Updates about your bookings, estimates and service progress will appear here.`; no button.
- **Loading:** bar + one pale bar + four large pale rounded blocks; no text.
- **Error:** centered pale-red circle with `!`; bold `We couldn't load your notifications.`; sentence `Please try again in a moment.`; full-width blue `Retry`.

### AFTER ar 360 — `idle_light_1.0_ar_360x800.png`
- Title right-aligned `التنبيهات`, back arrow right pointing right; summary `2 غير مقروءة` right + `تعليم الكل كمقروء` left; group titles right (`تحديثات الصيانة`, `الموافقات`, `الفواتير والإيصالات`, `عامةة`); rows mirrored: dot + icon right, chevron left (`<`); titles remain Latin `Booking confirmed`/`Estimate needs approval`/`Invoice ready`/`Workshop update` right-aligned; bodies Latin with `10:00`/`INV-2041` LTR; meta `2h ago · حجز` / `3h ago · موافقة` / `1d ago · فاتورة` with Latin time LTR + Arabic category.

### AFTER dark 360 — `idle_dark_1.0_en_360x800.png`
- Black background; same bar + `2 unread` + `Mark all read`; same four groups on dark-navy bordered surfaces; white titles, muted bodies/metas, blue unread dot + blue icon on `Estimate needs approval`, grey dots/icons elsewhere, pale chevrons.

### AFTER 1.3x 360 — `idle_light_1.3_en_360x800.png`
- Same bar + summary + groups; `Booking confirmed` body wraps `Your Camry is booked for` / `Saturday at 10:00.` (2 lines); `Estimate needs approval` body wraps 2 lines; metas `Booking · 2h ago` / `Approval · 3h ago` 1 line each; no striped overflow markers; all rows legible.

### AFTER 320px — `idle_light_1.0_en_320x568.png`
- Same bar + summary + `Service updates` / `Approvals` / `Invoices & receipts` (partial); single column; `Booking confirmed` body wraps 2 lines; `Approval` row wraps 2 lines; summary `2 unread` + `Mark all read` one row, no clipping.

### AFTER tablet 768 — `idle_light_1.0_en_768x1024.png`
- Same bar + summary + groups stacked single-column centered (max-width); all four groups full structure (`Booking confirmed`, `Estimate needs approval`, `Invoice ready`, `Workshop update`); no rail, no multi-column.

### BEFORE vs AFTER structure (idle + contact sheet)
- BEFORE idle: `Scaffold` + `WorkspaceAppBar` page chrome, hairline divider under app bar; `_SummaryRow` + bordered grouped `DecoratedBox` containers with rows; row = tint `Material` + dot + icon + title/body/meta + chevron.
- AFTER: same bar behavior on `AppScaffold`+`AppAppBar` atoms (no divider line in idle pixels); group surfaces borderless (whitespace + soft shadow, 12 gaps), dark bordered; row atoms rebuilt on tokens with byte-identical behavior (tint, dot + heavier title, chevron-iff-destination, LTR figures). No search icon added (by design), no filter sheet added (sections ARE the facets). Visible before/after difference is structural (chrome + surfaces + states on shared atoms) — redesign delivered. Contact sheet `phase-notifications-light.png` shows the same side-by-side delta.

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail + attribution |
|---|---|---|
| U0 — one read: dot+icon → title → body → `category · time` meta; hierarchy title=workshop title, category=small meta (never a pill), timestamp=meta; borderless light | idle card 1: `●` + calendar icon → `Booking confirmed` → `Your Camry is booked…` → `Booking · 2h ago`; card 2: blue `●` + list icon → `Estimate needs approval` → approval body → `Approval · 3h ago`; no pills anywhere; light frames shadow/whitespace, no borders; code `customer_notifications_view.dart:284-287` (hierarchy comment), `:232-239` (`outlined:false`) | PASS (owner-file) |
| U1 — find fast: NO search icon BY DESIGN (sanctioned deviation 1 with written reason: triage-by-recency, rows short/scannable, categories already ARE sections) | All 12 after frames: NO magnifier anywhere (idle/markall/allread/stale/empty/error/loading/dark/ar/1.3x/320/tablet). Bell placement (shell, top-right) untouched per migration | PASS (sanctioned exception, brief reason — not a fail) |
| U2 — fit content: heterogeneous rows → grouped surfaces, NOT a table (N/A by design); FOLD: summary + FIRST row above fold @360x800 | No table anywhere; idle 360: bar + `2 unread`/`Mark all read` + `Service updates` + first row complete (~500px < usable); stale 360: banner + first row still above fold allowance; pushed page has no bottom nav to clear | PASS (owner-file) |
| U3 — no fake actions: chevron + navigation ONLY when `destination != null`; `Mark all read` ONLY when `unread > 0`; no invented categories/destinations | idle: chevrons on `Booking confirmed`/`Estimate needs approval`/`Invoice ready` (actionable types), NO chevron on `Workshop update` (general, `destination==null` → read-only row, code `:343-345`, `:447-458`); markall (1 unread) HAS button, allread (`All read`) has NONE (`:271-275` predicate) | PASS |
| U4 — no invention: title/body/time/category verbatim; unknown wire → General; counts from `unreadCount`/`length`; zero as `0` | Titles/bodies/times verbatim (`INV-2041`, `10:00`, `2h ago`); `General` fallback mapping kept (`groupOf`/`fromWire` per migration); `2 unread`/`1 unread`/`All read` from counts; zero rendered as digit where counted (no `-`) | PASS |
| U5 — reachable + legible: full-row 48dp+ targets; `Mark all read` upper-half without scroll; title 2-line + body 3-line wrap never mid-word cut; meta 1-line ellipsis SECONDARY only | 1.3x: bodies wrap 2 lines cleanly, metas 1 line, no `…` on any title/body; 320: summary + first row intact, single column, no clipping; full-row `InkWell` targets visually ≥48dp; meta ellipsis (e.g. long `Invoice · 1d ago` truncation, if any) is secondary-only per C3. No primary truncation in any of the 12 frames | PASS (owner-file) |
| U6 — states: skeleton mirrors rows; honest empty (1 icon + 1 sentence, NO action — calm); error + retry; stale kept + banner; mark-fail inline notice + Retry; pull-to-refresh | Loading: summary bar + 4 row cards mirror summary+rows (code `:86-94`); empty: 1 bell icon + `You're all caught up` + 1 sentence, NO button (code `:108-113`, U6 calm comment) — title+message is the `AppEmptyState` pair (same as vehicles precedent), not two actions; error: 1 icon + title + sentence + 1 `Retry` → same `_refresh`; stale: data + `AppBanner` warning + Retry (stale pixels + code `:118-126`); mark-fail `AppBanner` error + Retry (code `:127-135`); `RefreshIndicator AlwaysScrollable` (`:138-141`) | PASS |
| U7 — feedback: row tap marks read optimistic + silent background persist; mark-all failure rolls back + `ntMarkFail` + Retry; destructive: none on this screen | Code: `_open` = mark + conditional push (`destination` mapping, never blocks nav), `_markAllRead` = optimistic + rollback + notice, `_refresh` same contracts per migration; no destructive action exists so no confirm needed (brief deviation 2 reason) | PASS |
| U8 — no dead ends: every actionable row opens its destination; read-only rows carry no chevron; empty needs no CTA | Actionable rows all carry chevrons (idle/stale/dark/ar/320/tablet); `Workshop update`/`General` rows carry none (no dead affordance); empty offers no CTA and needs none (nothing exists to create — U6 calm) | PASS |
| U9 — consistency: same atoms as vehicles/bookings (`AppPageHeader`-grade title row, `AppBanner`, `AppEmptyState`/`AppErrorState`); bell + back unchanged; icon/tone mapping frozen | `AppScaffold`+`AppAppBar` + `AppSurfaceCard(outlined:false)` + `AppBanner` + `AppEmptyState`/`AppErrorState` + `AppShimmerSkeleton` — same family as vehicles/bookings; category tones from frozen `toneColor`/`icon` mapping | PASS |
| U10 — RTL: full mirror; timestamps/figures/digits LTR where mixed; chevron mirrors | ar frame: full mirror (title/arrow, summary, groups, rows, `×`-less sheets N/A); `Booking confirmed` Latin titles right-aligned, `ABC`-grade codes N/A here but `INV-2041`/`10:00`/`2h ago` LTR inside RTL meta; chevron `<` left vs en `>` right (code `DirectionalIcon` `:449-457`); `EdgeInsetsDirectional` in code | PASS |
| U11 — a11y: row `Semantics` (read-state + category + title + body + time) kept; header semantics on group titles; bell announcement kept; 1.3x + 320 without clipping | Code: row `Semantics(button: destination!=null, label: readWord+label+title+body+time)` (`:347-356`), `Semantics(header:true)` on group titles (`:227-230`); 1.3x + 320 frames: no overflow markers | PASS (stills-limited) |
| U12 — density: single column compact; max-width 860 kept; groups stack (no multi-column — triage is recency-ordered, columns would break scan order) | 360/320/1.3x: single column; tablet 768: single column centered (NOT split — correct per brief; `AppResponsivePage` max-width predicate kept) | PASS |
| U13 — offline: stale list kept + refresh notice; retries inline; no permanent `Synced` pill | stale pixels: full list kept + yellow `AppBanner` warning + inline `Retry` (same `_refresh`); mark-fail `AppBanner` error + Retry; no `Synced` pill anywhere | PASS |
| U14 — no regression: tap budgets ceilings; pull-to-refresh, mark-read + notice contracts unchanged | No `ValueKey` added (rows never had key contract); pull-to-refresh kept; no haptics added (none existed); `_open`/`_markAllRead`/`_refresh` same contracts per migration. Tap budgets: see §3 | PASS |

**U-walk fails: 0. Zero owner-file fails; zero shell/shared fails visible in these 12 frames.**

---

## 3. Top-task tap walk BEFORE→AFTER (budgets ≤ before)

BEFORE counts (brief §Top tasks, verified from code per migration doc): open inbox 1 (bell) · open destination 2 (bell+row) · mark-all 2 (bell+Mark all) · mark-one 2 (bell+row).

| Task | Before | After (pixels + code) | Verdict |
|---|---|---|---|
| Open inbox | 1 tap (bell, any tab) | ≤ 1 tap (bell untouched, shell owns it; same `/notifications` route) | same ✓ |
| Open notification destination | 2 taps + scroll (bell + row tap) | ≤ 1 from list / ≤ 2 from launch: rows stay directly tappable (chevron rows in idle/stale/dark/ar/320/tablet pixels; same `destination()` mapping: bookings list / approvals page; read-only rows stay put) | same ✓ |
| Mark all read | 2 taps (bell + `Mark all read`) | ≤ 1 from list / ≤ 2 from launch: `Mark all read` stays in summary row, visible without scrolling when `unread>0` (idle/markall/stale pixels; hidden when all-read per allread pixels; same bulk+rollback contracts) | same ✓ |
| Mark one read | 2 taps (bell + row tap) | ≤ 2 taps: row tap, background persist never blocks nav (same `_open` contracts) | same ✓ |

**Tap result: PASS — every frequent task meets its budget with ≤ same scroll; destinations are existing pages (unchanged).**

---

## 4. Airbnb rubric 0–2 each, /16, pass ≥ 12/16 — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Triage inbox → act. One glance: unread dot + icon → title → body → `category · time` meta → chevron iff actionable. No competing heroes on a pushed inbox page |
| 2 | Headline-first hierarchy | 2/2 | `Notifications` → `2 unread`/`Mark all read` → `Service updates`/`Approvals`/`Invoices & receipts`/`General` → rows; title=workshop title, category/time=small meta last; empty/error keep headline order |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light group surfaces (shadow, 12 gaps, whitespace separation), bordered `DecoratedBox` + divider-less column removed; dark keeps border |
| 4 | Sheets for secondary actions | 2/2 | Correctly absent by omission — the honest facets already ARE the group sections (a filter sheet would duplicate them, U7 two-paths violation); no destructive action exists so no confirm sheet; secondary detail lives on existing destination pages. Sanctioned deviations, not missing pattern |
| 5 | Sticky CTA (list has none) | 2/2 | Correctly absent — `Mark all read` is a text action in the summary row (bulk triage without scroll), not a sticky bar; empty needs no CTA (calm) |
| 6 | Section structure (density/filter) | 2/2 | Header → stacked groups in stable service→approvals→invoices→general order; single column all widths (max-width 860 centered on tablet); stale keeps order + banner |
| 7 | Plain friendly copy, no invented claims | 2/2 | Sentence-case groups/titles, verb-first `Mark all read`/`Retry`, honest empty/error/stale, ar fully translated (Latin titles/codes LTR-locked per truth rules), zero as `0`, no ALL CAPS added |
| 8 | Single emphasized primary action | 2/2 | Idle/stale: zero filled (correct — triage rows are text/chevron, `Mark all read` is text); empty: zero filled (correct — calm, nothing to create); error: exactly one filled (`Retry`); mark-fail/stale banners: text `Retry` (no competing filled CTA) |
| **Merit total** | | **16/16** | Pass on merit (≥ 12) |
| C16 hard-reject cap | borderless-light / one-path-per-task / no-permanent-pills / badges-clear / no-ALL-CAPS / above-fold+peek / hierarchy / zero-as-0 (search-sheet N/A by sanctioned deviation) | **No cap** | ALL PASS: borderless light ✓; one path per slice (sections, no duplicate filter/search) ✓; no permanent pills ✓; no covering badges ✓; no ALL CAPS ✓; summary + first row above fold + second peeking ✓; hierarchy ✓; zero `0` ✓ |
| C17 U-cap | ANY owner-file U-law violated caps at 8/16 | **No cap** | Zero U fails (§2); no-search/no-filter are sanctioned deviations with written reasons, not violations |
| **Final** | | **16/16 — PASS** | Second-reviewer confirmation pending per working rule 12 (zero-gating round-1 PASS) |

**Verdict: PASS — bless as U-clean for notifications-list scope. 16/16 (pass ≥ 12/16). Awaiting second-reviewer confirmation before tag (working rule 12: any zero-gating round-1 PASS needs a second fresh reviewer).**

---

## ROUND-1 DEFECT LIST (gating first, honestly)

**Gating defects: NONE.** No C16 hard-reject hit, no owner-file U-law fail, no tap-budget breach on any top-3 task.

**Non-gating observations (disclosed, filed — do NOT gate this verdict):**
1. **No `mark-all-failure` failure banner PNG in this set.** Evidence is code (`AppBanner` error + Retry, same `_markAllRead` + rollback, `customer_notifications_view.dart:127-135`) + 11 structural tests per migration doc. Capture-phase gap, not a behavior gap — add a `markall-fail` frame to the capture matrix.
2. **Empty has title + message (two text lines), not a literal single sentence.** `empty_light_1.0_en_360x800.png`: `You're all caught up` + `Updates about your bookings…`. This IS the `AppEmptyState` title+message pair (same as vehicles precedent) with NO action — the brief's "1 icon + 1 sentence, NO action" counts the message as the sentence. Calm-empty intent met. Non-gating.
3. **Latin titles/bodies stay untranslated in ar (`Booking confirmed`, `Your Camry is booked…`).** Correct per truth rules (title/message/category/timestamp only from stored fields; backend stores EN) — NOT a defect. Filed here so phase 10/12 does not "fix" it by inventing translations.
4. **Missing process artifacts (not screen defects):** `references/` + `AIRBNB_PATTERNS.md` UNMET per brief (precedent patterns used, honestly recorded).

---

## The two answers

- **Would a first-time user know what to do in 3 seconds?** Yes. `idle_light_1.0_en_360x800.png`: `Notifications / 2 unread` names the pile, `Mark all read` offers the bulk triage, `Service updates — Booking confirmed: Your Camry is booked for Saturday at 10:00` with a chevron says "tap me to see it." Next step is unambiguous: tap the row or `Mark all read`.
- **What would an Airbnb product designer reject here?** Nothing blocking in list scope. Carry-forwards for system owners only: capture the `markall-fail` banner PNG; keep the no-search/no-filter deviations recorded (they are the right call — a search sheet would add chrome without saving a tap on any top-3 task).

(End of file — round 1, 2026-10-22)

---

## SECOND-REVIEWER CONFIRMATION (ROUND 2 — 2026-10-22)

**Role:** FRESH REVIEWER (round 2), NOT the round-1 reviewer, never built this screen. READ-ONLY except this appendix. No branch/commit/push. Never touched `71983229`.
**Images independently viewed (full resolution):** all 12 AFTER `docs/ui-redesign/baseline/after-customer-notifications/` (`idle/markall/allread/stale/empty/error/loading` + `dark/ar/1.3x/320px/tablet`) + `phase-notifications-light.png` contact sheet + BEFORE `idle_light_1.0_en_360x800` for contrast. Brief `docs/ui-redesign/briefs/customer-notifications-list.md` authoritative. Confirmed `docs/ui-redesign/references/` does NOT exist (UNMET, honestly recorded).

**Independent U0–U14 spot-check (after frames):**
- U0/U2/U6/U9/U12 (hierarchy/grouping/states/consistency/density): CONFIRM — dot+icon→title→body→`category · time`, borderless light whitespace separation (dark bordered), 4 stable groups, single-column max-width on tablet, skeleton/empty/error/banner atoms match round-1 description.
- U1 sanctioned NO-search: CONFIRM JUSTIFIED — no magnifier in any of 12 frames; triage-by-recency with 2-line scannable rows + 4 category sections; search would add chrome/tap without saving any top-3 tap. Not a U1 violation.
- U7 sanctioned NO-filter + NO-remove-sheet: CONFIRM JUSTIFIED — sections ARE the facets (service/approvals/invoices/general); filter sheet would duplicate slices (two paths, U7 violation). No destructive action exists (mark-read is non-destructive + rollback), so no remove sheet and no U7/U10 confirm needed.
- U3/U8 (no fake/dead): CONFIRM — chevrons only on `Booking confirmed`/`Estimate needs approval`/`Invoice ready`, none on `Workshop update`/`General` read-only row; `Mark all read` present in idle/markall/stale, absent in allread.
- U4/U13 (truth/offline): CONFIRM — verbatim `INV-2041`/`10:00`/`2h ago`, `2 unread`/`1 unread`/`All read`, stale keeps full list + warning + `Retry`, no `Synced` pill.
- U5/U10/U11 (legibility/RTL/a11y): CONFIRM — 1.3x wraps cleanly (2-line bodies, 1-line metas, no overflow markers), 320px single-column intact, ar fully mirrored with `<` chevron + LTR-locked `10:00`/`INV-2041`/`2h ago`; stills-limited on Semantics contracts, no contrary evidence.
- U0 fold (360x800): CONFIRM — summary + first row above fold in idle; stale banner still leaves first row visible.
- U14/C16: CONFIRM — no table, no ALL CAPS, no permanent pills/badges, empty = 1 bell icon + calm message + NO action, error = exactly 1 filled `Retry`, sentence case, zero as digit.

**Tap walk (independent):** Open inbox ≤1 (bell) ✓; open destination ≤1 from list / ≤2 from launch (direct row-tap, chevron rows) ✓; mark-all ≤1 from list (summary row, no scroll, hidden when all-read) ✓; mark-one ≤2 (row tap, background persist) ✓. Destinations are existing pages. No regression vs before.

**C16 hard-reject / C17 U-cap:** No cap triggered. Zero U fails, zero C16 hits.

**Verdict: CONFIRMED — agree with round-1. Final score 16/16 PASS (≥12/16). Gating defects found: NONE (expect none met).**

(End of file — round 2 confirmation, 2026-10-22)
