# ADVERSARIAL CONFIRM — wave-3 customer notifications fix (D3 + D4) — PASS 14/16 (C17-capped at 14; no hard-reject cap)

**Role:** ADVERSARIAL CONFIRMER (fresh eyes; did not fix). Branch `ui/fix-rulings`. READ-ONLY except this file. No switch/commit/push/merge. Never touched `71983229`.
**Governance:** DESIGN_SPEC C16 + U0–U14 C17. Pass ≥ 12/16. Any U-law fail caps at 8/16; any C16 hard-reject caps at 10/16. Strict: assume still broken.
**Fixes under test (fixer claims):** (D3) notifications search now >5-gated (≤5 shows none; 6 shows one) + brief override paragraph recorded; (D4) notifications search rows render whole at 1.0x/320/1.3x/ar (no mid-word cuts); (D2) home search untouched (rebuttal stands); (D5) red-pending/Title-Case still filed (unchanged). 59 tests green claimed.
**Briefs (authoritative):** `docs/ui-redesign/briefs/customer-notifications-list.md` (incl. ruling-(a) OVERRIDE lines 111–117), `customer-bookings-list.md`, `phase-6-vehicles-list.md`, `phase-6-customer-home.md`.
**Images viewed (Read, full resolution, CURRENT PNGs):**
- `baseline/after-customer-notifications/` — `idle_light_1.0_en_360x800.png` (6-item inbox), `markall_light_1.0_en_360x800.png` (1-item), `allread_light_1.0_en_360x800.png` (2-item), `empty_light_1.0_en_360x800.png`, `search-open_light_1.0_en_360x800.png` (NEW), `idle_light_1.0_en_320x568.png`, `idle_light_1.0_ar_360x800.png`, `idle_light_1.3_en_360x800.png`, `idle_dark_1.0_en_360x800.png`, `stale_light_1.0_en_360x800.png`
- `baseline/after-vehicles-list/` — `idle-6_light_1.0_en_360x800.png`, `search-open_light_1.0_en_360x800.png`, `search-results_light_1.0_en_360x800.png`
- `baseline/after-customer-bookings/` — `idle_light_1.0_en_360x800.png`, `search-open_light_1.0_en_360x800.png`, `filter-open_light_1.0_en_360x800.png`
**Code read (no edits):** `customer_notifications_view.dart:75-99`, `customer_notifications_search_sheet.dart:128-191`, `customer_scaffold.dart:134-154`, `customer_bookings_tab.dart:179-182`, `customer_vehicles_tab.dart:139-142`, `customer-notifications-list-test-migration.md:187-231`, both after-capture + characterization tests.
**Stance:** Assume the fix is still broken. Hunt defects. Gating first.

---

## Claim-by-claim verification

### (1) >5 gating BOTH directions on notifications — PASS (pixels + code agree)
- **Code:** `customer_notifications_view.dart:86` — `if (notifications.length > 5)` (was `isNotEmpty` at ruling-(a) landing, tightened by D3 fix). Comment lines 75–80 records the ONE family rule verbatim.
- **Pixels 6 → one:** `after-customer-notifications/idle_light_1.0_en_360x800.png` (6-item inbox: Service x2 + Approvals x2 + Invoices x1 + General x1) — AppBar row shows back + `Notifications` + magnifier top-right. Exactly one.
- **Pixels ≤5 → none (three independent frames):** `markall_light_1.0_en_360x800.png` (1-item) — AppBar back + title only, zero magnifier; `allread_light_1.0_en_360x800.png` (2-item) — same, zero magnifier; `empty_light_1.0_en_360x800.png` — same, zero magnifier. Characterization pins the same: 2-item inbox `findsNothing` on `Search notifications` tooltip + search icon; empty `findsNothing` (`customer_notifications_list_characterization_test.dart:153-157,220-222`); 6-item `_inbox6` `findsOneWidget` + sheet opens (`:225-235`).
- **Brief override recorded:** `briefs/customer-notifications-list.md:111-117` — OVERRIDE (ruling a) paragraph present: inbox now exposes the SAME >5-gated search path as the vehicles/bookings/lists family (visible ONLY when loaded >5; ≤5/empty show none; single AppBar action). Deviation text kept for history; no-search exception no longer applies. Taps recorded as find ≤1+keys, budgets unchanged. **Override text PASS.**
- **Verdict (1): PASS.** Both directions pixel-confirmed on CURRENT PNGs. D3 fixed on its own terms.

### (2) Whole result rows (no mid-word cuts) — PASS at 1.0x observed; 320/1.3x/ar code-plausible but pixel-unverified (disclosed, non-gating)
- **Pixels 1.0x:** `after-customer-notifications/search-open_light_1.0_en_360x800.png` — sheet `Search notifications` + `Search by title or message` + 6 rows, ALL titles whole: `Booking confirmed`, `Technician assigned`, `Estimate needs approval`, `Estimate approved`, `Invoice ready`, `Workshop update`. Bodies whole (`Your Camry is booked for Saturday at 10:00.`, `Ali will handle your Camry service today.`, `Review the brake estimate before work continues.`, `The brake estimate was approved. Work resumes today.`, `Invoice INV-2041 is ready for payment.`, `Holiday hours next week.`). Times whole (`2h ago` … `2d ago`). Zero `appr…` / `booked f…` / `Camr…` cuts that failed the last wave. **Prior D4 mid-word truncation GONE.**
- **Code:** `customer_notifications_search_sheet.dart:128-191` — vertical stack (no Row width competition): title maxLines 2 softWrap + body maxLines 2 softWrap + time meta 1-line secondary-only ellipsis; `AppDimensions.s20/s8/s4` tokens; 320/1.3x/ar fit by construction. Characterization pins titles at maxLines 2 (`:238-243`).
- **Coverage gap (strict disclosure):** there is NO `search-open` variant for 320px / 1.3x / ar / dark in `after-customer-notifications/` (only `search-open_light_1.0_en_360x800.png`). So "whole at 320/1.3x/ar" is code-plausible + pin-backed but NOT pixel-confirmed. Not counted as defect (single 1.0x frame shows zero cuts and the stack removes the Row-competition cause), recorded as capture gap. Siblings corroborate the pattern: `after-vehicles-list/search-open_*` and `after-customer-bookings/search-open_*` rows render whole in CURRENT PNGs.
- **Verdict (2): PASS** (observed scale fixed; other scales code-sound, pixel-unverifiable — filed below as O1, non-gating).

### (3) Taps ≤ before (find ≤1+keys) — PASS
| Task | Before (brief) | After (code+pixels) | Verdict |
|---|---|---|---|
| Open inbox | 1 (bell) | 1 bell, untouched (`_BellButton` → `/notifications`) | same |
| Open destination | 2 (bell+row) | ≤1 from list (row tap, chevron rows in idle/stale/dark/ar/320/tablet pixels; same `destination()` mapping, `_open` = background `markRead` + conditional push, never blocks) | same |
| Mark all read | 2 (bell+`Mark all read`) | ≤1 from list (summary row, visible when unread>0 in idle/markall/stale; hidden in allread; same bulk+rollback) | same |
| Mark one read | 2 (bell+row) | ≤2 (row tap, background persist) | same |
| Find (NEW capability) | n/a (no find-aid) | ≤1 tap + keys (AppBar search → sheet → result; empty query = full list; no-match + Clear) | new, no budget regression |
- No budgeted task regresses. `openSearch` guards (`bookings.isEmpty return`, `vehicles.isEmpty return`) match the >5 shell gate (shell never calls when ≤5). Result tap closes sheet + reuses row contract (`_open`), same routes, no new routes.
- **Verdict (3): PASS.**

### (4) Hunt for NEW gating items the fix introduced — NONE FOUND (residuals disclosed, not new)
- `git diff --stat` + header diffs confirm this wave touches notifications view + search sheet + tests + brief override + recaptured `after-customer-notifications/` frames. No new routes, no new predicates on list behavior, no new chrome beyond the already-sanctioned (now brief-overridden) AppBar action. Vehicles/bookings CURRENT PNGs show no regression (search-open rows whole, idle headers filter-only + shell-owned search per ruling a, cards/actions intact).
- The "59 tests green" claim is UNVERIFIED by this reviewer (no suite run in a read-only pixel+code confirm; not counted as defect, recorded as unverified). Characterization counts never down (11 → 12 at ruling a, 12 → 12 here with updated loci: ≤5 = 0 icons, 6 = exactly 1 + sheet filter/no-match/Clear + maxLines-2 pin).
- Residuals that are NOT new (see Ranked defects): home-always vs lists->5 vs profile-never predicate split (ruling-a residue), home global-search duplication (D2 rebutted/untouched), bookings red-pending/Title-Case (D5 STOP). None introduced by THIS wave.
- **Verdict (4): PASS — no NEW gating item.**

---

## Ranked defects (gating first, honestly)

### Gating defects introduced by THIS wave: NONE
- D3 (was gating: non-empty ≥1 vs family >5) — FIXED, both directions pixel-confirmed + override recorded.
- D4 (was gating: mid-word `…` cuts at 1.0x) — FIXED, 1.0x frame shows 6/6 whole titles + whole bodies.
- D1 brief-conflict half (notifications search vs brief no-search deviation) — RESOLVED by the D3 brief amendment (ruling-(a) OVERRIDE lines 111–117); deviation text kept for history. No code revert needed; EVERY-screen mandate stands with written sanction.

### Disclosed carry-overs (NOT new, NOT charged to this wave; strict governance notes)
- **D2 [PRE-EXISTING, ruling-a residue — home global search duplicates home sections].** Code unchanged this wave: `customer_scaffold.dart:139-140` — index 0 `always` opens `_openHomeSearch` (vehicles+bookings → `customerBookServiceLocation` / `customerBookingDetail` direct jumps); header shows none. Fixer left untouched per instruction; rebuttal (search-as-transport) stands. Strict U7/C16 reading still flags it as a second entry point, but it is NOT a regression of THIS wave — filed here so the next wave owns it. Does NOT gate this notifications-fix verdict (owner-file is the inbox, which now has exactly one sanctioned path).
- **D5 [PRE-EXISTING, still filed — red-pending + Title-Case pills].** `after-customer-bookings/idle_light_1.0_en_360x800.png` card 3: pink/red pill `Approval Required` + red `Estimate AED 1,200 awaiting approval` (2 lines); pills `In Service`, `Confirmed` Title Case. Unchanged in CURRENT PNGs, correctly filed as shared tones/vocab STOP (no per-screen fix attempted). Sibling scope, not inbox owner-file — does NOT gate this verdict.
- **D3-residual [ruling-a residue, not new — three predicates behind one shell magnifier concept].** Shell `onSearch` null-rules still differ: home ALWAYS / bookings+vehicles+notifications >5 / profile NEVER (`customer_scaffold.dart:139-154` + `customer_notifications_view.dart:86`). Within the LISTS family the rule is now ONE (>5 everywhere — the D3 fix). Home-always (no list to gate) and profile-never (no content) are different surfaces, not different list rules. Not counted as a NEW violation; noted for the shell owner.
- **D6 [NON-GATING, ruling-a residue].** Find-aids split across two chrome rows (search shell / filter page) on vehicles/bookings; stale comment `customer_bookings_tab.dart:505-506` still says "title row keeps search/filter top-right" though the header renders filter-only. Hygiene, merit −1, no cap.

### Non-gating observations (filed, do not gate)
- **O1 — no 320/1.3x/ar/dark `search-open` frames.** Only `search-open_light_1.0_en_360x800.png` exists. 320/1.3x/ar wholeness is code-sound (vertical stack, softWrap, maxLines-2 pin) but pixel-unverifiable. Recommend adding `search-open` 320 + 1.3x + ar frames to the capture matrix next wave.
- **O2 — 59-tests-green unverified.** Counts never down on paper (11 → 12 → 12); no suite run by this reviewer. Recommend citing the exact `flutter test --exclude-tags baseline` + `flutter analyze` output in the migration doc next wave.
- **O3 — Latin stored-field copy in ar inbox correct per Truth rules** (title/body/time verbatim; only category label localized). Not a defect; filed so phase 10/12 does not "fix" it.

---

## Tap walkthrough (before → after, per brief budgets)
Covered in claim (3) table. Net: every budgeted task ≤ budgets with ≤ same scroll; find is a new ≤1+keys capability with no budget regressed. No dead affordance added (search hidden when ≤5/empty/loading/error; exactly one AppBar action when shown; no-match + Clear; result taps reuse `_open`).

## Consistency with siblings
- Lists family now uniform: vehicles + bookings + notifications all `length > 5` gated, single AppBar/shell action, same `AppSearchField` + no-match + Clear pattern, same reveal/route contracts. CURRENT `after-vehicles-list/` + `after-customer-bookings/` PNGs show no regression (whole search rows, filter-only page headers, cards/actions intact).
- Empty states calm and search-free in all suites (`empty_*`: one icon + sentence; notifications caught-up has no CTA by design).
- Home/profile split unchanged (home always-search, profile never) — ruling-a residue, not this wave.

---

## Score (Airbnb rubric 0–2 each, scoped to THIS wave: notifications D3+D4 + blast radius)
| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Inbox triage → act; search now brief-sanctioned (>5, single AppBar path), find ≤1+keys, no duplicate within inbox |
| 2 | Headline-first hierarchy | 2/2 | `Notifications` → `2 unread`/`Mark all read` → stable groups → title-first rows; order intact in CURRENT PNGs |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light surfaces + 12 gaps preserved; search sheet clean |
| 4 | Sheets for secondary actions | 2/2 | Same-sheet pattern; D4 truncation gone (6/6 whole at 1.0x) |
| 5 | Sticky CTA (none) | 2/2 | Correctly absent; `Mark all read` text action, empty calm |
| 6 | Section structure | 1/2 | Inbox structure clean; −1 for ruling-a split-find-aid residue on siblings + stale search/filter comment (D6, non-gating) |
| 7 | Plain friendly copy | 2/2 | Sentence case, verb-first `Mark all read`/`Retry`, ar fully mirrored, zero as digit, no ALL CAPS |
| 8 | Single emphasized primary action | 1/2 | One search path in form; −1 for evidence gap (no 320/1.3x/ar search-open frames to prove wholeness beyond 1.0x — O1) |
| **Merit** | | **14/16** | Above pass on merit |
| C16 hard-reject | | **No cap** | One-path-per-task now sanctioned via written override; borderless-light / no-permanent-pills / no-ALL-CAPS / above-fold+peek / hierarchy / zero-as-0 all hold |
| C17 U-cap | | **No cap on owner-file** | Zero inbox U-law fails in CURRENT PNGs (U1 sanctioned, U5 fixed at observed scale; 320/1.3x/ar search rows code-sound, pixel-unverified → observation, not fail). D2/D5 are sibling/pre-existing scopes, not owner-file fails |
| **Final** | | **14/16 — PASS** | Merit 14, no cap triggered by THIS wave. Bless the D3+D4 fix. D2/D5/O1-O3 carried as disclosed follow-ups |

**Gating marks (this wave):** none. D3 FIXED, D4 FIXED, D1-brief-half RESOLVED via override. D2/D5 disclosed as pre-existing (untouched/still-filed per instruction, not charged here). D6/O1-O3 non-gating.
**Evidence caveat:** 320/1.3x/ar search-row wholeness is code+pin-backed but has no CURRENT `search-open` PNGs beyond 1.0x en — filed as O1; re-capture those three frames to close it. "59 tests green" unverified by this reviewer — filed as O2.
**Would a first-time user know what to do in 3 seconds?** Inbox yes: `Notifications / 2 unread` + `Mark all read` + first row `Booking confirmed: Your Camry is booked for Saturday at 10:00` with chevron; with 6 items the lone magnifier invites text-find without competing chrome; with ≤5 there is no magnifier to mislead.
**What would an Airbnb designer reject first?** Nothing blocking in THIS wave — the mid-word `appr…` cuts are gone and the ≤5/6 gate behaves in both directions. Next: add the three missing `search-open` scale frames (O1) and let the shell owner reconcile the home-always vs lists->5 predicate note.

(End of file)
