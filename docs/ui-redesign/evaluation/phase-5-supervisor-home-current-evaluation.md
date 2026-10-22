# Phase 5 — Supervisor home (Floor) — CURRENT UI evaluation (fresh re-audit, ui/integration-1)

Scope: current floor UI on branch `ui/integration-1`. READ-ONLY audit; this file is the only write.
Authoritative brief: `docs/ui-redesign/briefs/phase-5-supervisor-home.md` (16-bay spatial map IS the content; C16 collections rule bends to a 4-col grid per U2/U5).
Gate: REDESIGN MANDATE + C16 hard-reject (caps 10/16) + U0–U14 (DESIGN_SPEC ~lines 489–546); pass ≥ 12/16.
Migration evidence: `docs/ui-redesign/evaluation/supervisor-home-test-migration.md` (behavior pins 8/8, compact-nav tap table, fixer round-1 notes).
References: EMPTY (UNMET — no prior precedent cited; nothing pretended).

Evidence (current): `docs/ui-redesign/baseline/after-supervisor-home-current/` — 11 frames:
`sv_home_en_1.0_360x800.png` (base), `sv_home_search_open_en_360x800.png`, `sv_home_more_open_en_360x800.png`,
`sv_home_empty_en_360x800.png`, `sv_home_loading_en_360x800.png`, `sv_home_error_en_360x800.png`,
`sv_home_ar_1.0_360x800.png`, `sv_home_en_1.0_320x568.png`, `sv_home_en_1.3_360x800.png`,
`sv_home_en_1.0_768x1024.png`, `sv_home_en_1.0_1180x820.png`
+ contact sheets `phase-5-supervisor-current-{light,ar,tablet}.png` (re-checked; the tablet sheet visibly shows the B-02 truncation).
History only for before/after contrast: frozen `before-supervisor-home/` and `after-phase-5-supervisor/`
(contact-sheet BEFORE panel = old floor board without shell/greeting/hero/nav).
Code (read-only): `supervisor_dashboard_tab.dart` (910 lines), `supervisor_scaffold.dart` (639 lines).

## Verdict: FAIL — 8/16 (binding cap: U5; secondary cap: C16 orphan)

Raw check count would be higher, but caps bind: U5 truncation caps at 8/16; C16 orphan caps at 10/16. Gating defects first in §4.

---

## 1. Region-by-region description (no judging — what is on screen)

Base frame `sv_home_en_1.0_360x800.png` (idle, 4/16 active), top to bottom:

1. Shell app bar: left title "Floor"; right bell icon + "S" avatar circle. No search icon on this tab.
2. Greeting header: eyebrow "Thu, Oct 22"; large title "Floor command, Supervisor"; status pill "4/16 bays active" (green, grid icon).
3. Board section header: left title "Workshop floor" + subtitle "4 active · 16 bays"; right single search (magnifier) icon on the same row.
4. Hero: one sentence "Dispatch the next job into a free bay." + one full-width blue pill CTA "Dispatch to technician" (worker icon).
5. Filter row: legend dots + labels "Occupied / Idle / Parts delay / QC"; chip row "All (filled) / Occupied / Parts delay / QC / (Idle cut with peek)".
6. Bay grid (2-col on phone): B-01 (teal/QC dot, "OH" chip, "Yaris XYZ 5678", "JC-207  4/4"), B-02 (green, "—", "Camry ABC 1234", "JC-101  2/5"), B-03 (amber parts, "Hilux XYZ 1111", "JC-900  1/4"), B-04 (green, "Civic", "BK-301  10:00"), B-05/B-06 grey idle (partially behind nav).
7. Below fold (scroll): remaining bays B-07…B-16, then rail cards ("Incoming queue", "Quality control" per tablet/empty frames), then bottom nav.
8. Bottom nav (compact): Floor (active) / Jobs / Queue / Review / More. Expanded rail (tablets) shows all 7 destinations + avatar footer.

Other frames: search-open = "Find on the floor" sheet with field + 16 bay rows; more-open = "More" sheet with Reports/Staff/Schedule rows; empty = "0/16 bays active" + "No active jobs on the floor / The queue is clear" + queue card "0 / The queue is clear"; loading = shimmer blocks mirroring header/hero/grid/rail; error = "Floor unavailable / Could not load the floor. Pull to refresh." + Retry; ar = full RTL mirror with LTR bay codes; 320 = same stack, tighter; 1.3x = larger text, same order; 768 = side-by-side board (3-col) + rail ("Incoming queue 2" with 2 rows + button, "Quality control" + Review button); 1180 = same with 4-col board.

Code map: `_FloorHeader` (title+subtitle+search Row), `_FloorHero` (sentence + primary Dispatch), `_FloorFilter` (legend + AppFilterBar), `_FloorBoard` (adaptive 2/3/4/4 cols, `_BayTile`), `_FloorRail` (selected-bay + queue + review cards), `_FloorSkeleton`, `_SupervisorBottomBar` (4 primaries + More), `_SupervisorChrome` (shell bar; search hidden on index 0), `_SupervisorGreetingHeader` + `_FloorStatusPill`.

---

## 2. U0–U14 walk (image + region evidence each)

- U0 (fewer steps): Dispatch = visible hero CTA or any bay tap; queue/review = one nav tap. No extra steps added on floor. Evidence: base frame hero + nav; search sheet rows tap → same assign sheet (code `_onBayTap`). PASS.
- U1 (search icon top-right): Exactly ONE search icon on floor: board section-header row, end side, same row on 360/320/ar/tablet (base, ar, 768, 1180 frames). Shell bar deliberately hides its search on index 0 (`if (selectedIndex != 0)`), so no duplicate. Same glyph/tooltip contract (`svSearchTitle`), opens floor-data sheet. Strict-literal note: it sits in the content header row, not next to the shell bell/avatar — but there is exactly one path with a consistent end-side placement, which is what the brief permitted ("verify current placement"). PASS with noted placement nuance (see nits).
- U2 (primary task first / fold 360x800): First bay row (B-01/B-02, fully rendered tiles) is visible above the bottom nav in idle base frame; hero CTA also above fold. Brief wireframe demanded first bay row above nav — met at 360x800. 320x568 frame is tighter (B-01/B-02 headers peek just above nav) but U2's bar is 360x800. PASS (320 noted as tight, not a U2 fail).
- U3 (tap counts): See §3. Dispatch/queue/review unchanged at 1 tap; +1 only on Reports/Staff/Schedule behind More (infrequent admin, brief-consistent). Most-frequent (dispatch) = 1 ≤ 2. PASS.
- U4 (reachability): Hero Dispatch CTA + first bay tiles reachable without scrolling on 360x800 base frame; More sheet rows are 48dp+ (code `ConstrainedBox minHeight 48`, migration pins). PASS.
- U5 (no truncation of primary text): FAIL — tablet-768 frame, board tile B-02 reads `Camry ABC 12…` — vehicle identity cut mid-token with ellipsis (code `_BayTile` title `maxLines: 1, overflow: ellipsis`). The brief's bend explicitly demands "full-word/short labels"; a mid-plate cut (`12…`) is a mid-word cut of the tile's primary line (title = vehicle identity per `supervisor_components.dart`: "Primary tile line — vehicle identity"). Phone/1180 fit; 768 3-col does not. Gating (caps 8/16).
- U6 (calm empty): Empty frame keeps hero sentence + filled Dispatch with `0/16` pill, board slot calm (`AppEmptyState`, no action), rail queue-empty text pinned. Brief STATES line explicitly wants "empty floor (icon + sentence + action)" and free bays exist to dispatch into, so the hero CTA is brief-mandated, not gratuitous. PASS.
- U7 (one path per task): Search = one path (floor header only; shell deduped). Dispatch = one filled CTA (hero primary; tile taps open the sheet with no filled button; selected-bay card is secondary — exactly one filled Dispatch per state, verified on base/empty/error frames). Queue rail button + Queue tab coexist as preview-card + destination (brief-mandated rail: "rail (queue/review/breakdowns)"), i.e. card-preview → full list, not two competing entries for one search. PASS.
- U8 (relevance): Urgent-first derivation untouched (`buildSupervisorBays`: QC → parts → occupied → bookings); no silent filtering (predicate moved verbatim). PASS.
- U9 (consistency): End-side search on every breakpoint (base/ar/320/1.3x/tablets); bell/avatar always shell-right; primary CTA pattern stable. Minor note: shell search visible off-floor but hidden on floor (intentional U7 dedup) — documented, not drift. PASS.
- U10 (feedback/forgiveness): Press/haptic on tiles/nav/More rows (code `HapticFeedback`); error gives "Pull to refresh" + Retry; offline banner keeps stale board (migration). PASS.
- U11 (readable numbers): `0` renders `0` (empty frame "0/16", "0 active", queue "0"); counts labeled; occupancy count lives once in header subtitle + once as pill sentence (redundancy nit, not a "-"). PASS.
- U12 (one background): Single page background; tiles tinted by state (tone surfaces), no stray bands. PASS.
- U13 (new-employee test): Plain words ("Workshop floor", "Dispatch to technician", "Incoming queue", "Quality control", "Reports/Staff/Schedule"). PASS.
- U14 (a11y): 48dp+ More rows; Semantics on tiles/selected; AA assumed from tokens; 320 pumps with 0 overflow (migration); 1.3x frame shows no clipping (legend wraps, tiles intact). PASS.

Nav evidence (U3/U7): base frame 4+More bar (Floor/Jobs/Queue/Review + More); more-open frame lists exactly Reports/Staff/Schedule; tablet rail keeps all 7 destinations. Single search icon: base/ar/768/1180 each show exactly one magnifier in the board header row, none duplicated in shell on floor tab.

---

## 3. Top-3 tap walk, before → after (+ More-moved tasks)

BEFORE (brief + migration §Behavior assertions, verified from code): dispatch = bay tap → assign sheet (1 tap, 0 scroll); queue = Queue tab (1 tap); review = Review tab (1 tap). AFTER (measured on current frames + code): Floor primary tab selected → bay tap still opens same sheet (1 tap, 0 scroll; `_onBayTap` → `onOpenAssign`); hero Dispatch also 1 tap; Queue primary 1 tap (rail rows/button unchanged targets); Review primary 1 tap (rail Review button unchanged). Deltas ±0.

| Task | Before | After | Delta |
|---|---|---|---|
| Dispatch into bay (bay tap → sheet; hero CTA) | 1 tap, 0 scroll | 1 tap, 0 scroll (Floor primary) | ±0 |
| Check queue | 1 tap | 1 tap (Queue primary; rail unchanged) | ±0 |
| Review finished job (QC) | 1 tap | 1 tap (Review primary; rail button unchanged) | ±0 |
| Active jobs list (Jobs) | 1 tap | 1 tap (Jobs primary) | ±0 |
| Operations report | 1 tap (Reports tab) | 2 taps (More → Reports) | +1 |
| Workshop roster | 1 tap (Staff tab) | 2 taps (More → Staff) | +1 |
| Bay schedule | 1 tap (Schedule tab) | 2 taps (More → Schedule) | +1 |

The +1 trio are infrequent admin destinations (not top-3), explicitly accepted in the migration tap table; no frequent task regressed. Before/after contrast (contact-sheet BEFORE panel vs current): old board-only floor → current adds shell bar + greeting + occupancy pill + hero sentence/CTA + compact 4+More nav; board tiles, filter predicate, derivation, routes, copy semantics unchanged.

---

## 4. Rubric /16 with caps (ONLY after §§1–3)

Scoring: 16 checks = C16 hard-reject aggregate (1) + U0–U14 (15). Caps apply first: any C16 hard-reject caps at 10/16; any violated U-law caps at 8/16.

- C16 aggregate: FAIL (gating) — orphan tile at medium breakpoint: `_FloorBoard` uses 3 cols at medium for 16 bays (16 mod 3 = 1 orphan in last row; 768 frame board is 3-col with B-16 falling to a lone short row). Brief bent C16 only to a 4-col grid (16/4 exact, used at expanded/large); medium 3-col reintroduces the orphan the hard-reject list forbids. Caps at 10/16. (All other C16 items pass: borderless light tiles + shadow per code, one filled accent per state, no badge/ALL CAPS/sync-pill issues, fold met at 360x800, filter-chip peek is clean by design.)
- U0 PASS, U1 PASS (see nuance), U2 PASS, U3 PASS, U4 PASS, U5 FAIL (gating — `Camry ABC 12…` mid-token cut, tablet-768 B-02; caps at 8/16), U6 PASS, U7 PASS, U8 PASS, U9 PASS, U10 PASS, U11 PASS, U12 PASS, U13 PASS, U14 PASS.

Check count: 14/16, binding cap min(10, 8) = 8. **Score: 8/16 — FAIL (gating defects must clear first).**

### ROUND-1 DEFECT LIST (gating first, honestly)

Gating (must fix for pass):
1. [U5 — cap 8] Tablet-768 board tile B-02 truncates vehicle identity mid-token (`Camry ABC 12…`). Evidence: `sv_home_en_1.0_768x1024.png` + contact-sheet tablet panel; code `_BayTile` title `maxLines: 1, ellipsis`. Brief bend requires full-word/short labels. Fix (presentation-only, no logic): at medium breakpoint use 2-col or 4-col board (matching brief's 4-col bend and expanded behavior), and/or allow title 2-line wrap / smaller plate handling so no mid-word cut; re-capture 768.
2. [C16 — cap 10] Orphan tile at medium 3-col: 16 bays in 3 cols leaves a lone tile in the last row. Same fix as (1): medium board cols 2 or 4 (16/2 and 16/4 exact, no orphan). Re-capture 768 + 1180 to confirm 4x4 / 8x2 grids.

Non-gating nits (fix opportunistically, no cap):
- N1. Occupancy number shown twice ("4/16 bays active" pill + "4 active · 16 bays" subtitle). Not label+badge duplication but redundant; consider single source.
- N2. U1 literal placement: floor search lives in the board header row, not beside the shell bell/avatar (shell hides its search on floor for U7 dedup). Documented and single-path; keep, but record the deviation from the strict "next to notifications" wording.
- N3. 320px fold is tight (first bay headers peek just above nav). Passes U2's 360x800 bar, but verify no CTA is stranded below fold at 320.
- N4. References: EMPTY (UNMET) — no precedent available; this evaluation cites none rather than inventing any.

What is already good (do not regress): single search path end-side on all breakpoints; exactly one filled Dispatch per state; borderless light tiles; unchanged tap counts on top-3 tasks; intact derivation/predicate/routes/copy; RTL LTR bay codes; shimmer/error/empty/offline states.

---

## Round-2 re-audit (2026-10-22, ui/integration-1) — gating defects only

Scope: re-walk ONLY the two round-1 gating defects against the regenerated
`sv_home_en_1.0_768x1024.png` (235,529 bytes, was 255,528; medium `_FloorBoard`
3-col -> 2-col, `_BayTile` title `maxLines: 1` -> `2` per fixer round-2 in
`supervisor-home-test-migration.md`; this audit changed no code). The other 10
frames were not regenerated — the regression check is the byte-identical
compare below. Round 1 above is kept verbatim.

### G1 — U5 mid-token cut → FIXED
- Round-1 defect: tablet-768 board tile B-02 read `Camry ABC 12…` (mid-plate
  cut, `maxLines: 1` ellipsis).
- Round-2 evidence: `sv_home_en_1.0_768x1024.png` (1536x2048 px), board grid
  top row, right tile (B-02): title line reads `Camry ABC 1234` in full on one
  line, no ellipsis; ref row `JC-101  2/5` intact below; green occupied dot
  top-right. Tile close-up re-checked: whole plate visible, no `…`. PASS.

### G2 — C16 orphan tile → FIXED
- Round-1 defect: medium 3-col board -> 16 mod 3 = 1 orphan (B-16 lone short
  row).
- Round-2 evidence: same 768 frame, board region rows 1–5 render as exact
  pairs (B-01/B-02, B-03/B-04, B-05/B-06, B-07/B-08, B-09/B-10); 2-col x 16
  bays = 8 exact rows, no lone tile. 1180 frame untouched (compare-identical,
  still 4-col per round 1). No orphan at any breakpoint. PASS.

### Regression check (other 10 frames)
- Full-file compare-mode runs back-to-back in the 11:23 window, no
  `--update-goldens`: **11/11 pass twice**. The 10 non-regenerated frames
  (360/ar/320/1.3x/1180/empty/loading/error/search-open/more-open) match
  byte-identically — fold, single search path, hero CTA, rail cards,
  shimmer/error/empty states all unchanged. `test/failures/` debris: none
  found. Zero regressions.

### Round-2 verdict: PASS — 16/16
- C16 aggregate: PASS (exact 2-col tiling at medium, 4-col at expanded/large).
  U5: PASS (full-word vehicle identity, no mid-token cut). U0–U4, U6–U14:
  unchanged PASS (frames byte-identical). Both caps lifted.
- **Score: 16/16 — supervisor home current-state PASS.**
- Remaining gating items: **none**. Round-1 non-gating nits N1–N4 persist as
  documented (occupancy double-count, U1 placement nuance, tight 320 fold,
  empty references) — no cap impact.
