# ADVERSARIAL REVIEW — search relocation to customer shell (ruling a) — FAIL 7/16 (C17-capped)

**Role:** ADVERSARIAL CONFIRMER (fresh eyes; did not relocate). Branch `ui/fix-rulings`. READ-ONLY everywhere except this file. No switch/commit/push/merge. Never touched `71983229`.
**Governance:** DESIGN_SPEC C16 + U0–U14 C17. Pass ≥ 12/16. Any U-law fail caps at 8/16; any C16 hard-reject caps at 10/16. Strict: any U-law/hard-reject breach gates.
**Ruling under test (a):** search icon moved INTO the customer shell AppBar (top-right, adjacent bell/avatar); page headers show none. Same sheets/targets, same >5 gating relocated to the shell trigger. Notifications AppBar gained a search action (new sheet). Claims: single visible search path per screen, taps unchanged, 59 tests green.
**Briefs (authoritative):** `docs/ui-redesign/briefs/phase-6-vehicles-list.md`, `customer-bookings-list.md`, `customer-notifications-list.md`, `phase-6-customer-home.md`, `briefs/_TEMPLATE.md` (hard-reject + U0–U14 checklists).
**Images viewed (Read, full resolution, CURRENT PNGs):**
- `baseline/after-vehicles-list/` — `idle-6_light_1.0_en_360x800.png`, `idle-2_light_1.0_en_360x800.png`, `search-open_light_1.0_en_360x800.png`, `search-results_light_1.0_en_360x800.png`, `empty_light_1.0_en_360x800.png`
- `baseline/after-customer-bookings/` — `idle_light_1.0_en_360x800.png`, `search-open_light_1.0_en_360x800.png`, `empty_light_1.0_en_360x800.png`
- `baseline/after-customer-notifications/` — `idle_light_1.0_en_360x800.png`, `search-open_light_1.0_en_360x800.png`, `empty_light_1.0_en_360x800.png`
- `baseline/after-phase-6-customer/` — `idle_light_1.0_en_360x800.png`, `search-open_light_1.0_en_360x800.png`, `empty_light_1.0_en_360x800.png`
- Code read (no edits): `customer_scaffold.dart`, `customer_vehicles_tab.dart`, `customer_bookings_tab.dart`, `customer_notifications_view.dart`, `customer_home_tab.dart`, `customer_home_header.dart`.
**Stance:** Assume the ruling is still wrong. Hunt defects. Gating first.

---

## Claim-by-claim verification

### (1) Search icon top-right adjacent bell/avatar in the SHELL AppBar row (not page, never mid-page) — UNVERIFIED → FAILS CONFIRMATION
- Code (read-only) says the icon lives there: `customer_scaffold.dart:134-166` — `WorkspaceAppBar(onSearch: shellSearch, actions: [_BellButton, _ProfileAvatar])`, gated `bookings.length > 5` / `vehicles.length > 5`, home always, profile null.
- Pixels CANNOT confirm it: every tab-screen capture (`after-vehicles-list/idle-6`, `idle-2`; `after-customer-bookings/idle`; `after-phase-6-customer/idle`) is a **page-content crop that excludes the shell AppBar entirely** (frames start at `My vehicles` / `Bookings` / `Welcome back` — no bell, no avatar, no shell row visible). There is no image+region on any tab screen showing a magnifier adjacent to bell/avatar.
- The ONLY AppBar-with-search visible in pixels is the **notifications pushed-page AppBar** (`after-customer-notifications/idle`: back arrow + `Notifications` + magnifier top-right) — that is the page's own `AppAppBar` (`customer_notifications_view.dart:80-98`), NOT the shell (inbox is a contextual pushed page per its brief, not a workspace destination).
- Strict adversarial reading: an unobservable claim is a failed confirmation. **Claim (1) is code-plausible but pixel-unverifiable → FAIL.**
- Page-header half of the claim PASSES in pixels: `idle-6` header row shows title + funnel filter only (no magnifier); `idle-2` shows title + count + `+ Add vehicle`, zero icons; bookings `idle` shows title + funnel only; empties show zero icons. Never mid-page anywhere. (Conceded.)

### (2) EXACTLY ONE visible search path per screen (idle-2/empty show zero) — PARTIAL (page half passes, total unverifiable; notifications violates by existing)
- Page content: `idle-2` (2 vehicles) shows ZERO search affordances — complies with the >5 progressive-disclosure exception. All three `empty_*` PNGs show zero search in content. Conceded for the page layer.
- Total-per-screen is unverifiable on tabs for the same crop reason as (1): shell row unseen, so "exactly one" (idle-6: page 0 + shell 1) cannot be counted from CURRENT PNGs.
- Notifications `idle` shows EXACTLY ONE magnifier (AppBar top-right, no second path in content) — count passes, but **the path itself is unsanctioned** (see D1). A single violation is still a violation.
- **Claim (2): page-layer PASS, screen-total UNVERIFIED, notifications SANCTION-FAIL.**

### (3) Sheets open the same targets (spot-check result taps) — PASS for lists, DIVERGENT for home/notifications-new
- Vehicles: `search-open` lists 6 `Toyota Camry / ABC 100x` rows; `search-results` query `ABC 1001` narrows to the single matching row — filter predicate works. Code `onSelect` → `Scrollable.ensureVisible` reveal, record actions unchanged (`customer_vehicles_tab.dart:324-342`). Same targets. PASS.
- Bookings: `search-open` lists 6 service/vehicle rows (`Oil change`, `Tire rotation`, `Brake pads`, …). Code `onSelect` → `ensureVisible` reveal (`customer_bookings_tab.dart:295-313`). Same targets. PASS (static pixels cannot show the tap itself; code path is the pre-existing reveal).
- Notifications: NEW sheet (`search-open`: `Search by title or message`, rows `Booking confirmed / Technician assigned / Estimate needs appr…` + relative times). Code `onSelect: _open` → `markRead` + conditional `push(destination)` (`customer_notifications_view.dart:53-61`) — same destinations as row taps. Targets match rows. PASS on targets (sheet itself is the violation — D1/D5).
- Home: NEW global sheet (`search-open`: `Search vehicles and bookings`, `Type to search…`). Code `onSelectVehicle` pushes `customerBookServiceLocation(vehicleId)` and `onSelectBooking` pushes `customerBookingDetail` directly (`customer_scaffold.dart:225-238`) — these are deeper destinations than the home rows that aggregate them (carousel `Show all` → vehicles tab; recent-activity rows → detail). Same route table, but a NEW direct-jump entry point that bypasses the home's own section grammar. DIVERGENT (see D2).

### (4) Taps ≤ before per brief tables — HOLDS for briefed tasks, NEW parallel paths add cost
| Task | Before (brief) | After (code+pixels) | Verdict |
|---|---|---|---|
| Open list (vehicles/bookings) | 1 (tab) | 1 | same |
| Open search sheet (>5) | 1 (page header icon) | 1 (shell icon) | same (unverifiable in pixels — shell unseen) |
| Bookings: open detail / track / review | ≤1 from list | row-tap + `Track service`/`Review` direct on card still present in `idle` pixels | pass |
| Vehicles: book/edit/remove/retry | ≤ budgets, bottom-sheet remove | card `Book service` + `···` + `View` present in `idle-6`/`idle-2` pixels | pass (no pixel regression) |
| Notifications: open inbox / open destination / mark-all/one | 1 bell / 2 / ≤2 | bell untouched; row taps + `Mark all read` unchanged in `idle` pixels | pass for briefed paths |
| Notifications via NEW search | did not exist (0 taps possible) | bell (1) + search (1) + result (1) = 3 taps to a destination reachable in 2 | NEW longer parallel path (cost, see D1) |
| Home via NEW global search | did not exist | shell search (1) + result (1) = 2 taps jumping past section structure | NEW parallel path (cost, see D2) |
- No briefed task regresses. But "taps unchanged" ignores the two ADDED find paths, each duplicating an existing shorter-or-equal route. Conceded narrowly, failed broadly.

### (5) Hunt for NEW gating items the relocation introduced — FOUND (see D1–D5). Claim FAILS.
- The "59 tests green" claim is UNVERIFIED by this reviewer (no test run; running suites is out of read-only scope for a pixel/code confirmer). Not counted as defect; recorded as unverified.

---

## Ranked defects (gating first; image+region + law + gating each)

### D1. [GATING — NEW] Notifications search violates the brief's sanctioned no-search deviation (U0/U7 + C16 one-path)
- **Image+region:** `after-customer-notifications/idle_light_1.0_en_360x800.png`, AppBar row: back arrow + `Notifications` + magnifier top-right. `search-open_*`: full `Search notifications` sheet over the inbox.
- **Law:** Brief `customer-notifications-list.md` DEVIATION 1 (sanctioned, with written reason): "NO search icon (not even > 5) … A search sheet would add chrome (and a tap) without saving any tap on any top-3 task, violating U0 and C16 (one path per task)." The relocation builds exactly the forbidden chrome. Trips C17-U0 (least effort — chrome with no saved tap), C17-U7 (one path per task), and C16 hard-reject "One path per task (no duplicate entry points)".
- **Cost:** Triage-by-recency screen gains a text-find path to destinations already one row-tap away; the via-search route costs 3 taps vs the direct 2.
- **GATES? YES — U0/U7 breach → C17 cap 8/16; independently C16 hard-reject → cap 10/16.**

### D2. [GATING — NEW] Home global search duplicates existing home paths (U7 + C16 one-path)
- **Image+region:** `after-phase-6-customer/search-open_light_1.0_en_360x800.png` — `Search / Search vehicles and bookings / Type to search…` sheet over `Welcome back Ahmed`. Shell trigger always visible on index 0 (`customer_scaffold.dart:140`, no threshold — no threshold ever existed on home because no search ever existed there).
- **Law:** Home brief sanctions NO search; the dashboard grammar is greeting → hero → garage carousel (`Show all` → vehicles tab) → quick-action tiles → recent-activity rows. A cross-entity find sheet whose results push `customerBookServiceLocation` / `customerBookingDetail` directly is a second entry point to tasks the sections already own (Book-service tile, `Show all`, activity rows). Trips C17-U7 + C16 hard-reject "One path per task (no duplicate entry points)" (+ template hard-reject "Search = one top pill/screen" is met in form but not sanctioned on this screen — form compliance does not cure duplication).
- **GATES? YES — U7 breach → C17 cap; C16 one-path → cap 10/16.**

### D3. [GATING — NEW] Three different search-visibility predicates behind one shared shell magnifier (U9)
- **Code+image regions:** shell `onSearch` null-rules differ per tab (`customer_scaffold.dart:139-154`: home ALWAYS; bookings/vehicles ONLY when loaded >5; profile NEVER) while the notifications pushed page uses a fourth rule (visible when inbox NON-EMPTY, i.e. ≥1, `customer_notifications_view.dart:84`). Pixels corroborate the family: `idle-2` page shows no aids (consistent with >5), notifications `empty_*` shows NO magnifier in its AppBar (consistent with non-empty rule — correct per code, but a different threshold than the >5 family).
- **Law:** C17-U9 consistency — "same placement every screen" now holds for position but the SAME icon means different availability logic per tab (always / >5 / ≥1 / never). A customer learns "magnifier appears when…" three different ways inside one AppBar.
- **GATES? YES (strict) — U9 breach → C17 cap.**

### D4. [GATING — NEW] Notifications search-result rows truncate PRIMARY titles mid-word at 1.0x (U5)
- **Image+region:** `after-customer-notifications/search-open_light_1.0_en_360x800.png`, result rows: `Estimate needs appr…`, `Your Camry is booked f…`, `Ali will handle your Camr…`, `The brake estimate was …`, `Invoice INV-2041 is rea…`, `Review the brake estim…` — mid-word `…` cuts on the notification title (the thing the user recognizes, cf. brief card-hierarchy binding: title first) at the baseline 360x800/1.0x capture, not a stress scale.
- **Law:** C17-U5 (no truncation of primary text; ellipsis secondary-only) + template U5 (wrap ≤2, fit or clean peek). Pre-existing inbox rows wrap 2–3 lines; the NEW sheet rows cut instead.
- **GATES? YES — U5 breach → C17 cap.** (List sheets do not share it: vehicles/bookings `search-open` rows render whole.)

### D5. [GATING — PRE-EXISTING, still binding] Red-for-pending + Title-Case status pills (U13/C2)
- **Image+region:** `after-customer-bookings/idle_light_1.0_en_360x800.png`, card 3: pink/red pill `Approval Required` + red `Estimate AED 1,200 awaiting approval` (2 lines); pills `In Service`, `Confirmed` Title Case (round-3 residue, unchanged in CURRENT PNGs).
- **Law:** Brief ordered sentence-case via theme + C2 (red = error; pending = amber). Strict U13 misdirection. NOT introduced by the relocation, but strict governance ("any U-law breach gates") keeps it capping regardless.
- **GATES? YES — still caps 8/16. Disclosed as pre-existing so the relocator is not charged with inventing it.**

### D6. [NON-GATING] Find-aids split across two chrome rows (search shell / filter page) — U9 cost
- **Image+region:** `idle-6` title row: funnel filter top-right of PAGE content while search (per code) sits in the unseen SHELL row; bookings `idle` identical split. Briefs ordered search+filter as sibling `AppIconButton`s top-right together; they are now owned by different bars.
- **Law:** C17-U9 (same placement/grammar every screen). Filed as merit −1, not a cap alone. (Stale residue: `customer_bookings_tab.dart:505-506` comment still says "title row keeps search/filter top-right" though the header renders filter-only — hygiene note, not scored.)

---

## Tap walkthrough (before → after, per brief budgets)
Covered in claim (4) table. Net: briefed tasks ≤ budgets ( PASS narrowly); two NEW parallel find paths (notifications 3-tap via-search vs 2-tap direct; home direct-jump vs section navigation) add unbudgeted duplicate entries (see D1/D2).

## Consistency with siblings
- Find-aid grammar now: vehicles/bookings = shell-search + page-filter (>5-gated); notifications = page-AppBar search (≥1-gated); home = shell-search (always); profile = none. Four surfaces, three predicates, two chrome owners — U9 fail (D3).
- Sheets share the same bottom-sheet + `AppSearchField` + no-match + Clear pattern (U9 form pass; noted).
- Empty states calm and search-free in all three suites (`empty_*` PNGs: one icon + sentence + single CTA / no CTA for notifications caught-up) — the one clean row in this review.

---

## Score (Airbnb rubric 0–2 each, scoped to the relocation + its blast radius)
| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 1/2 | Lists still find→act; notifications/home gain second find entries (D1/D2) (−1) |
| 2 | Headline-first hierarchy | 2/2 | Headers/counts/cards order intact in CURRENT PNGs — pass |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light cards preserved — pass |
| 4 | Sheets for secondary actions | 1/2 | Same-sheet pattern kept, but notifications/home sheets are unsanctioned surfaces + U5 truncation in one (D1/D4) (−1) |
| 5 | Sticky CTA (none) | 2/2 | Correctly absent — pass |
| 6 | Section structure | 1/2 | Split find-aid rows + three predicates (D3/D6) (−1) |
| 7 | Plain friendly copy | 1/2 | Sheet copy clean; red-pending + Title-Case pills persist (D5, pre-existing) (−1) |
| 8 | Single emphasized primary action | 1/2 | One search path per screen in form, but duplicated task entries (D1/D2) (−1) |
| **Merit** | | **11/16** | Below pass on merit |
| C16 hard-reject | | **Cap 10/16** | One-path-per-task violated twice (D1, D2) |
| C17 U-cap | | **Cap 8/16** | D1 (U0/U7), D2 (U7), D3 (U9), D4 (U5); D5 (U13) independently |
| **Final** | | **7/16 — FAIL** | Merit 11 capped at 8; multiple NEW gating items push to the 7 band. Do not bless. |

**Gating marks:** D1, D2, D3, D4 GATE (all NEW, all U-law; D1/D2 also C16 hard-reject). D5 gates as pre-existing. D6 non-gating.
**Evidence caveat:** claims (1) shell placement and (2) screen-total single-path are UNVERIFIABLE from CURRENT PNGs (tab captures exclude shell chrome) — confirmation fails on evidence even where code looks compliant. Re-capture full frames (shell AppBar + bell/avatar + magnifier in one shot per tab, plus ≤5/empty shell states) to make (1)/(2) checkable.
**Would a first-time user know what to do in 3 seconds?** On lists yes; on notifications the new magnifier invites text-search on a recency-triage screen (the exact confusion the brief's deviation pre-empted); on home the always-on search duplicates the tiles/sections beside it.
**What would an Airbnb designer reject first?** The unsanctioned notifications search (D1) — it re-opens a deviation the brief closed with a written reason — and the mid-word `appr…` truncation inside the brand-new sheet (D4).
