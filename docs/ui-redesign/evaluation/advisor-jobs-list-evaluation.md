# Advisor jobs register — Fresh review ROUND 1 (PASS 15/16)

**Role:** FRESH REVIEWER (never built this), branch `ui/list-staff-jobs`. READ-ONLY except this file. No branch/commit/push. Never touched `71983229`.
**Read first:** Brief `docs/ui-redesign/briefs/advisor-jobs-list.md` (authoritative; sanctioned: inline filter rail, inline sort, wide AppTable master-detail, search-only-when-> 5); migration `docs/ui-redesign/evaluation/advisor-jobs-test-migration.md` (behavior pins, 12 → 13 tests GREEN); REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 C17 (caps 8/16); pass ≥ 12/16.
**References:** `docs/ui-redesign/references/` does not exist; `AIRBNB_PATTERNS.md` missing repo-wide — both per brief §References, confirmed UNMET. Proceeded on phase-6 vehicles-list precedent as brief directs. Not a screen defect.
**Images viewed (14):**
- BEFORE `docs/ui-redesign/baseline/before-advisor-jobs/`: `jobs_1.0_en_360x800`, `jobs_empty_en_360x800`, `jobs_1.0_ar_360x800`, `jobs_1.0_en_320x568`, `jobs_1.0_en_1280x800` (5).
- AFTER `docs/ui-redesign/baseline/after-advisor-jobs/`: `jobs_1.0_en_360x800` (idle/6), `jobs_empty_en_360x800`, `jobs_search_en_360x800`, `jobs_filter_en_360x800`, `jobs_1.0_ar_360x800`, `jobs_1.3_en_360x800`, `jobs_1.0_en_320x568`, `jobs_1.0_en_1280x800` (8).
- Contact `docs/ui-redesign/baseline/phase-advisor-jobs-light.png` (before/en vs after/en side-by-side).
**Code read-only (attribution only):** `apps/staff_app/lib/features/advisor/presentation/pages/advisor_jobs_view.dart:140-143` (count subtitle), `:205-215` (AppPageHeader + `jobCards.length > 5` trailing), `:547-646` (intake `_BookingRow`), `widgets/advisor_job_card_row.dart:50-160` (card hierarchy, Semantics, LTR locks); `packages/shared_core/lib/src/widgets/app_page_header.dart:49-132` (compact stacks actions below subtitle, `Align(centerLeft)`; wide same-row).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### BEFORE `jobs_1.0_en_360x800`
- **Header region:** first line bold `Workshop Job Cards` left + small bare `5` pill top-right on same row; second row full-width inline search field with magnifier + hint `Search by registration, customer, or I…` (truncated with ellipsis).
- **Filter region:** horizontal chip rail `All` (filled blue) + `Intake 1` + `Inspection 1` + `Approve…` (cut at frame edge, peek).
- **Sort region:** label `Sort` + full-width dropdown `Newest first` with chevron.
- **Intake region:** bordered card `Assigned intake queue` + `1 pending` pill right; inner bordered row: car glyph + `Oil change · Patrol` / `Nadia · 2026-10-21` left, filled `Check In` right.
- **Rows region:** hairline-bordered container with 1px dividers, five 72px rows. Row pattern: status dot + bold name left, status pill center-right, muted time/chevron/overflow right; second line plate pill LTR + vehicle + job id mono LTR. Zara row shows `Pendi…` pill truncated mid-word + `Pending sync` text; Ahmed `Inspect…`; Layla `Approv…`; Omar `In progr…`; Sara `Compl…`.

### BEFORE `jobs_empty_en_360x800`
- Same header + inline search + rail (`Intake 0`, `Inspection 0`, `Approv…`) + sort dropdown; center clipboard glyph in rounded square; bold `No job cards yet`; sentence `New job cards will appear here as they are created.`; filled `+ New job card`.

### BEFORE `jobs_1.0_ar_360x800`
- Mirrored: title right `بطاقات عمل الورشة` + `5` pill top-left; search field with magnifier right; rail `الكل` (filled) + counts right-to-left; `ترتيب` label + dropdown `الأحدث أولاً`; intake card mirrored with `بدء الاستلام` button left; rows mirrored with pills (`بالانتظار`, `تم الفحص`, `تمت الموا…` truncated), ids/plates `JC-2001`/`DXB 111` LTR, `...` overflow left, `Pending sync`/`10:30 AM` Latin.

### BEFORE `jobs_1.0_en_320x568`
- Same structure narrower: intake title truncates `Assigned intake que…`; Zara row reflows to two lines (`Pending` pill full on second line, `Pending sync` below plate); Ahmed row peeks at frame bottom.

### BEFORE `jobs_1.0_en_1280x800`
- Full-width search + rail (`All…Ready 1` all six visible) + sort; left column intake card + table (`Customer / Job Card / Vehicle / Status / Time`); `Corolla · DXB 111` wraps two lines, `Complet…` pill truncates; right pane empty-eye + `Select a job card to preview the details`.

### AFTER `jobs_1.0_en_360x800` (idle, 6 cards)
- **Header region:** first line `Workshop Job Cards`; second line muted `6 job cards`; third row lone magnifier icon left, no inline field.
- **Filter region:** `All` filled + `Intake 2` + `Inspection 1` + `Approve…` (peek); `Sort` label + `Newest first` dropdown full-width.
- **Intake region:** borderless white card (shadow): `Assigned intake queue` + `● 1 pending` pill right; row car glyph + `Oil change · Patrol` / `Nadia · 2026-10-21` left + pill-shaped `Check In` right.
- **Cards region:** borderless white cards with 12-gap. Card pattern: bold `Zara · Corolla` / pill `● Pending` / row `DXB 111` plate pill + `Pending sync` / mono `JC-2001` + `...` right. Second card `Ahmed · Camry` / `● Inspected` / `ABC 1234 10:30 AM` / `JC-2002`. Third `Layla · Yaris` peeks at frame bottom.

### AFTER `jobs_empty_en_360x800`
- Header `Workshop Job Cards` + `No job cards` (words, no digit); rail `All/Intake 0/Inspection 0/Approv…`; sort; center pale circle clipboard glyph; `No job cards yet` + `New job cards will appear here as they are created.`; full-width `New job card` (no `+` prefix).

### AFTER `jobs_search_en_360x800`
- Dimmed list behind; bottom sheet with drag handle: title `Search` left; input with magnifier + `ahmed` + clear-× + scan/QR button right; section `Job Cards (1)`; one row clipboard glyph + `Ahmed` / `Camry · ABC 1234 · JC-2002` + chevron right.

### AFTER `jobs_filter_en_360x800`
- Header `Workshop Job Cards` + `1 job card`; magnifier row left; rail `All / Intake 2 / Inspection 1`(filled) + `Clear` text right; sort; single card `Ahmed · Camry` / `● Inspected` / `ABC 1234 10:30 AM` / `JC-2002`.

### AFTER `jobs_1.0_ar_360x800`
- Title right `بطاقات عمل الورشة` + `6 بطاقة عمل` subtitle; magnifier left below subtitle; rail `الكل` filled + `الاستلام 2` + `الفحص 1` + `معتمد` (peek); `ترتيب` + dropdown; intake card `قائمة الاستلام المسندة` + `1 بالانتظار` pill + `Oil change · Patrol` Latin + `Nadia · 2026-10-21` LTR + `بدء الاستلام` left; cards `Zara · Corolla` / `بالانتظار` pill + `Pending sync` Latin + `DXB 111` / `JC-2001` LTR, `...` left.

### AFTER `jobs_1.3_en_360x800`
- Same as idle enlarged: intake title wraps two lines `Assigned intake / queue`; intake meta reads `Nadia · 2026-1…` (date truncated with ellipsis); Zara/Ahmed cards full structure, pills whole, ids whole.

### AFTER `jobs_1.0_en_320x568`
- Header + `6 job cards` + magnifier left; rail + sort; intake card `Assigned intake queue` whole on one line + `1 pending`; row `Oil change · Patrol` / `Nadia · 2026-10-21` whole; Zara card whole (`Pending`, `DXB 111 Pending sync`, `JC-2001`).

### AFTER `jobs_1.0_en_1280x800` (wide)
- Header `Workshop Job Cards` + `6 job cards` left, magnifier top-right same row; rail six chips fully visible; intake card left-master; table `Customer/Job Card/Vehicle/Status/Time` with 6 rows (`Pending`, `Inspected`, `Approved`, `In progress`, `Completed`, `Vehicle received` — all whole single-line); Ahmed row highlighted/selected; right detail pane avatar `A` + `Ahmed / JC-2002` + `Inspected` pill + `Vehicle Camry · ABC 1234 / Technician -- / Created 10:30 AM` + full-width `Open job card`.

### Contact `phase-advisor-jobs-light.png`
- Left BEFORE (title + `5` pill + inline search + divider rows with truncated pills) vs right AFTER (title + `6 job cards` + icon + borderless cards with whole pills) side-by-side at 360 width.

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law | Evidence | Result |
|---|---|---|
| U0 one read | AFTER idle card: `Zara · Corolla` (title) → `● Pending` (one chip) → `DXB 111 Pending sync` meta → `JC-2001` small mono meta (`advisor_job_card_row.dart:68-143`); wide table same columns + preview pane. No invented statuses. | PASS |
| U1 find fast | AFTER idle (6 cards) shows exactly one magnifier; empty (0) shows none — `> 5` rule (`advisor_jobs_view.dart:208`). Tap opens `AdvisorSearchSheet` (search frame: `ahmed` → 1 result → same detail push per migration doc). Inline field removed (no dual path). Placement note: icon sits below subtitle on compact (see R1-1), function intact. | PASS (flagged placement = non-gating obs, not a U1 fail) |
| U2 fit / above fold | AFTER idle 360: intake card + full Zara card + Ahmed card head visible above fold; header slim (title + subtitle + icon row + rail + sort). Contact sheet confirms first card above nav. | PASS |
| U3 no fake actions | Every control maps: search→sheet, rail→`_jobsFilterProvider`, sort→`_jobsSortProvider`, Check In→`advisorCheckIn`, card→`advisorJobDetail`, overflow→quick sheet, New→`vehicleCustomer`, retry→invalidate (migration §Behavior pins verbatim). | PASS |
| U4 no invention | Plates/ids/times verbatim; counts from loaded lists; zero as words (`No job cards` empty subtitle; `advisorJobsCountNone` code `:140`); cancelled reachable under All only (taxonomy kept). | PASS |
| U5 reachable + legible | Names never `…` (titles ≤2 lines wrap: `advisor_job_card_row.dart:68-72`); pills whole at 360/320/wide (`Pending/Inspected/Approved/In progress/Completed/Vehicle received` all whole in wide frame — fixes before `Pendi…/Complet…`); ids/plates/times LTR-locked (code `:99-110,:114-143`; ar frames show `JC-2001/DXB 111/10:30 AM` LTR). 1.3x booking-date `2026-1…` = secondary meta compression (see R1-2), name intact. | PASS |
| U6 states | Empty: 1 icon + 1 sentence + 1 action (`AppEmptyState` + `vehicleCustomer`); no-match + shared Clear (filter frame `Clear` right, clears both per `_clearAllFilters`); error `AppErrorState` + verbatim retry label; stale `AppBanner` warning + data; skeleton mirrors layout (code `:310-340`); pull-to-refresh kept. | PASS (stills-limited; code + migration pins confirm) |
| U7 feedback | Row tap → immediate `onJobCard` push; sheet preview → Open; no destructive on this surface (explicitly N/A per brief, not missed). | PASS |
| U8 no dead ends | Every card opens; every booking row checks in; empty offers New; no-match offers Clear; All shows everything incl. cancelled path. | PASS |
| U9 consistency | `AppPageHeader` + `AppSurfaceCard` + `AppStatusChip` + `AppFilterBar`/`AppDropdownButton` + `AppEmptyState`/`AppErrorState`/`AppBanner` + `showAppBottomSheet` — same atoms as home/supervisor/technician/owner + vehicles precedent. Placement note (R1-1) is shared-atom behavior, not a custom divergence. | PASS (see adjudication) |
| U10 RTL | AFTER ar: full mirror, ids/plates/times LTR (`JC-2002/ABC 1234/10:30 AM`), chevrons/`...` mirrored, `Directionality` contracts kept in code. | PASS |
| U11 a11y | Row `Semantics(label: customer, id)` (`advisor_job_card_row.dart:50-52`); header `Semantics(header)` via `AppPageHeader`; 48dp targets; AA; 1.3x reflows without clip (only secondary date ellipsizes); 320px intact. | PASS (stills-limited) |
| U12 density | 1-col compact cards; wide keeps master-detail table + preview (brief deviation 3, C9 rule) with `cellFlex [3,2,2,4,2]` so Status owns widest share; max-width per contract. | PASS |
| U13 offline | Shell owns offline; stale list + `AppBanner` warning + inline retry; no permanent sync pill (thin `LinearProgressIndicator` dropped per migration). | PASS (stills-limited) |
| U14 no regression | Tap budgets per migration §Behavior: open 2, search 3+typing (icon replaces field), filter 2, sort 3, check-in 2, preview 2+sheet, new 2, retry 1 — all ≤ before; `ValueKey`s/haptics/sheet+snackbar contracts unchanged (13 tests GREEN). | PASS |
| **U fails** | | **0 — no C17 cap** |

**Flag adjudications (as tasked):**
- **(1) Search-icon placement — NON-GATING, no U1/U9 cap.** Code fact: `AppPageHeader` compact returns `Column[identity, SizedBox, Align(centerLeft, actionBar)]` (`app_page_header.dart:113-122`); `Align(centerLeft)` is non-directional, hence left in en+ar (matches after idle en + ar frames: lone magnifier left below subtitle; wide frame same-row top-right `:125-131`). Brief wireframe wants same-row top-right on compact; owner-home precedent used a plain `Row`. But U1's testable requirement is *find fast, one path, progressive disclosure* — met (one icon, only when > 5, opens full sheet, same predicate/top-hit/push). U9's requirement is *same atoms/placement as home/supervisor/technician/owner* — met because every `AppPageHeader` consumer stacks identically on compact; demanding a one-off Row here would *break* U9 consistency to chase the wireframe sketch. Filed as non-gating merit −1 (criterion 2), never a cap.
- **(2) 1.3x `2026-1…` booking-date ellipsis — NON-GATING, not a U5 primary-text fail.** Code fact: `_BookingRow` line 2 is `customer · date` single-line ellipsis (`advisor_jobs_view.dart:622-629`); line 1 (`service · vehicle`) allows 2-line ellipsis. U5 protects *primary* text (person's name, card title ≤2 lines, never `…` on a name) and explicitly sanctions *pill + time compress first* at 1.3x/320. Evidence: `Nadia` intact in all frames; only the secondary date tail compresses at 1.3x (`Nadia · 2026-1…`), while at 1.0x/320 the full `2026-10-21` renders. Primary intact → secondary compression is the sanctioned behavior. Filed as observation only, no deduction, no cap.

---

## 3. Tap walk before → after (open / search / triage)

Source: brief §Top tasks + migration §Behavior (verified from code; route names verbatim).

| Task | BEFORE | AFTER (evidence) | Budget |
|---|---|---|---|
| Open job card | Jobs tab (1) + row tap (1) = 2 | Tab (1) + card tap (1) = 2 (`onTap: widget.onJobCard` → `advisorJobDetail`; wide: row select + `Open job card`) | ≤ 2 PASS |
| Find via search | Tab + inline field tap + type + row tap = 3 + typing | Tab + header icon tap + type + sheet result tap = 3 + typing (filter frame + search frame; `> 5` gate; Enter = top hit) | ≤ 3 PASS |
| Triage by status | Tab + filter chip = 2 | Unchanged rail inline = 2 (filter frame `Inspection 1` selected + `Clear`; predicates/counts verbatim) | ≤ 2 PASS |
| Check in booking | Tab + Check In = 2 | Same per-row direct `Check In` = 2 (intake card all after frames) | ≤ 2 PASS |
| Quick preview → Open | Tab + overflow + Open = 2 + sheet | Same `...` → `AdvisorJobCardSheet` re-chromed (`showAppBottomSheet`) → Open = 2 + sheet | ≤ 2 PASS |
| Sort | Tab + dropdown + option = 3 | Same inline dropdown, same 3 options (`Customer A–Z` U+2013 kept) = 3 | ≤ 3 PASS |
| New from empty | Tab + New job card = 2 | Same empty CTA → `vehicleCustomer` = 2 | ≤ 2 PASS |
| Retry | Inline 1 | Same invalidate 1 (`advisorActionRefreshJobCard` verbatim) | ≤ 1 PASS |

No step flows added. No taps regressed.

---

## 4. Rubric /16 (ONLY after §§1–3), pass ≥ 12

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find job → open workspace; search/filter/sort/check-in/preview serve it |
| 2 | Headline-first hierarchy | 1/2 | Title → one chip → meta → id-mono correct; −1: header icon stacks below subtitle on compact vs brief same-row top-right wireframe (shared-atom behavior, non-gating) |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Borderless light cards + gaps; bordered divider container gone; wide table sticky header, compact never a squeezed table |
| 4 | Sheets for secondary actions | 2/2 | Search → full sheet; overflow → preview sheet; destructive N/A explicitly, not missed |
| 5 | Sticky CTA (none) / one filled per row | 2/2 | Card tap is the action; per-row Check In only; empty one New CTA; wide one Open CTA |
| 6 | Section structure | 2/2 | Rail inline + counts, sort inline, intake capped at 3, filter Clear restores both |
| 7 | Plain friendly copy | 2/2 | Sentence-case vocab, no invention, zero as words, `Customer A–Z` U+2013 byte-identical, ar + LTR locks |
| 8 | Single emphasized primary action | 2/2 | One visible search icon only when > 5; no inline+icon duplication; above-fold first card + second peeking |
| **Merit** | | **15/16** | |
| C16 hard-reject cap | 11-item checklist | **No cap** | All hold (borderless, one path, one filled/row, search-sheet, above-fold+peek, hierarchy, wide-table/compact-cards, no ALL CAPS, zero words) |
| C17 U-cap | any U fail → 8/16 | **No cap** | 0 U fails (§2) |
| **Final** | | **15/16 — PASS** | |

---

## ROUND-1 DEFECT LIST (gating first, honestly)

**Gating defects: NONE.** No C16 hit, no U-law fail, no tap regression.

**Non-gating (scored or filed):**
1. **Header search icon stacks below subtitle on compact — SCORED (−1, criterion 2).** AFTER idle en + ar: lone magnifier left on its own row; brief wireframe + U1 text want same-row top-right; `app_page_header.dart:113-122` (`Column` + `Align(centerLeft)`). Functional U1/U9 intact (one path, > 5 gate, shared atom), wide same-row correct. Owner-home plain-`Row` precedent predates the shared header — do not one-off this screen; if the wireframe ideal is wanted everywhere, change `AppPageHeader` compact layout globally (out of scope here). Non-gating by adjudication above.
2. **1.3x booking-date tail ellipsizes (`Nadia · 2026-1…`) — FILED, no deduction.** AFTER `jobs_1.3_en_360x800` intake row; `_BookingRow` line-2 single-line (`advisor_jobs_view.dart:622-629`). Name intact; date is secondary meta; sanctioned pill/time-first compression. No action unless brief reclassifies booking dates as primary.
3. **References EMPTY — process artifact, not scored.** `references/` + `AIRBNB_PATTERNS.md` absent as brief declares; vehicles precedent used. No screen impact.
4. **Capture note:** no loading/error/no-match PNGs in `after-advisor-jobs/` this round; covered by code (`AppShimmerSkeleton`/`AppErrorState`/`_JobsNoMatch`) + 13 GREEN characterization tests per migration doc. Suggest capturing in a later pass; non-gating.

**Verdict: PASS 15/16.** First-time user finds the register, triages inline, searches via one icon when the list needs it, and opens the workspace within budget — with pre-existing pill-truncation (`Pendi…/Complet…`) fixed to whole-word chips across compact, 320px, and wide.

---

## FRESH REVIEW ROUND 2 — CONFIRMATION (independent, never built this)

**Role:** FRESH REVIEWER #2 (not round-1 reviewer, never built this), branch `ui/list-staff-jobs`. READ-ONLY except this section. No branch/commit/push. Never touched `71983229`.
**Read first:** Same as round 1 — brief `docs/ui-redesign/briefs/advisor-jobs-list.md` authoritative; REDESIGN MANDATE + C16 (caps 10/16) + U0–U14 C17 (caps 8/16); pass ≥ 12/16. References EMPTY (UNMET, not a screen defect).
**Images independently viewed (14, same set):** before-advisor-jobs/ 5 PNGs + after-advisor-jobs/ 8 PNGs + `phase-advisor-jobs-light.png`. Code read-only (attribution only): `apps/staff_app/.../advisor_jobs_view.dart:205-215` (`> 5` gate confirmed), `packages/shared_core/.../app_page_header.dart:113-122` (compact `Column` + `Align(centerLeft)` confirmed).

**Independent U0–U14 walk (all PASS, 0 fails, no C17 cap):** U0 hierarchy title→one chip→meta→mono id verified on Zara/Ahmed cards + wide table; U1 one icon only when 6 cards, none when 0, sheet `ahmed`→1 hit→same push, inline field removed; U2 intake + full Zara + Ahmed head above fold at 360x800; U3 every control maps 1:1 (search/filter/sort/check-in/open/preview/new/retry); U4 verbatim plates/ids/times, zero as words, cancelled-under-All kept; U5 names never `…`, pills whole at 360/320/wide/ar (fixes before `Pendi…/Complet…`), ids/plates/times LTR; U6 empty 1-icon+1-sentence+1-CTA, filter `Clear` restoring both, skeleton/banner/error per code + migration pins (stills-limited); U7 immediate push, sheet→Open, destructive N/A per brief; U8 all cards open, booking checks in, empty→New, no-match→Clear, All shows everything; U9 same shared atoms (header/cards/chips/rail/sheets/states); U10 full RTL mirror with LTR locks; U11 Semantics + 48dp + 1.3x reflow + 320px intact (stills-limited); U12 1-col compact, wide master-detail table + preview (brief deviation 3); U13 shell owns offline, stale + banner + retry, no permanent pill (stills-limited); U14 all tap budgets ≤ before (2 / 3+typing / 2 / 2 / 2+sheet / 3 / 2 / 1), contracts unchanged.

**Tap walk before→after:** open 2→2, search 3+typing→3+typing, triage 2→2, check-in 2→2, preview 2+sheet→2+sheet, sort 3→3, new 2→2, retry 1→1. No regressions.

**C16 checklist:** all 11 hold — borderless light cards, N/A badge rule, one filled per row/section, exactly one visible search icon, no permanent pill, no ALL CAPS, count once in subtitle, search-sheet over inline, first card + second peeking above fold, title→chip→meta hierarchy, wide sticky table / compact cards. No C16 cap.

**Adjudication 1 — search-icon stacking (CONFIRMED non-gating, −1 criterion 2 only, no U1/U9 cap):** Independently verified `app_page_header.dart:113-122` stacks actions below subtitle on compact via `Align(centerLeft)` in en AND ar (matches after idle en + ar frames; wide same-row correct). U1's testable requirement (find fast, one path, > 5 disclosure, full sheet, same predicate/top-hit) is met; U9's requirement (same shared atoms everywhere) is met — a one-off Row here would break U9 consistency. Wireframe ideal is a merit-level hierarchy note, not a U-law fail. Overturning to gating would misapply C17. Upheld.

**Adjudication 2 — 1.3x `Nadia · 2026-1…` ellipsis (CONFIRMED non-gating, no deduction, no U5 cap):** Independently verified in `jobs_1.3_en_360x800`: name `Nadia` intact, only secondary date tail compresses; at 1.0x/320 the full `2026-10-21` renders. Brief U5 explicitly sanctions pill/time-first compression at 1.3x/320 and protects only primary text (names/titles, never `…` on a name). Overturning to gating would contradict the brief's own U5 text. Upheld.

**Gating items found: NONE. No C16 hit, no U-law fail, no tap regression.**

**Verdict: CONFIRMED — round-1 PASS 15/16 stands (merit 15/16, no caps).** Agree −1 is criterion 2 (headline-first hierarchy, icon below subtitle on compact) and observation-only on the 1.3x secondary date tail.
