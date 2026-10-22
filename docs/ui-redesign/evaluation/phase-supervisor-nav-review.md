# Supervisor Shell Nav Review — ui/integration-1 (fresh reviewer) — PASS, 15/16

**Role:** FRESH REVIEWER for the supervisor compact-nav change. Did not build it. Read-only except this file. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/integration-1` (change landed, uncommitted).
**Governance (all gate):** REDESIGN MANDATE (PROGRESS.md rule 13) + C16 hard-reject (any violation caps at 10/16) + U0–U14 C17 (DESIGN_SPEC ~lines 489–546; any violated law caps at 8/16, no exceptions). Pass ≥ 12/16 with caps.
**Read first:** DESIGN_SPEC C16 (~495–510) + C17 (~512–541); brief top-3 tasks; tap table in `docs/ui-redesign/evaluation/supervisor-home-test-migration.md` ("Compact nav" section); `docs/ui-redesign/LOGIC_FOLLOWUPS.md` #8.
**Context (given, verified against code):** compact bar is now `AppBottomNav` with 4 primaries (Floor/Jobs/Queue/Review — the tabs the brief's top-3 tasks need) + 5th More tab opening an `AppBottomSheet` (Reports/Staff/Schedule, 48dp+ rows, same routes). No badges existed so More carries none. Expanded rail keeps all 7.
**Evidence viewed (5/5 via Read, full resolution):**
- `docs/ui-redesign/baseline/after-shell-fix/sv_floor_en_1.0_360x800.png`
- `docs/ui-redesign/baseline/after-shell-fix/sv_floor_ar_1.0_360x800.png`
- `docs/ui-redesign/baseline/after-shell-fix/sv_floor_en_1.3_360x800.png`
- `docs/ui-redesign/baseline/after-shell-fix/sv_floor_en_1.0_320x568.png`
- `docs/ui-redesign/baseline/after-shell-fix/sv_more_open_en_360x800.png`
**Code read-only (region mapping only, no edits):** `apps/staff_app/lib/features/supervisor/presentation/widgets/supervisor_scaffold.dart` (`_kPrimaryTabCount = 4`, `_SupervisorBottomBar`, `_MoreDestinationRow`, `_openMore`, `adaptive.useNavigationRail` branch, `_items` order 0–6).

---

## (1) DESCRIBE — shell/nav region, WITHOUT judging

### Reference: `sv_floor_en_1.0_360x800.png`

- **AppBar row (top):** left title `Floor`; right cluster magnifier, bell, circular avatar `S`. Thin hairline divider below. (Unchanged by this nav change.)
- **Greeting block:** grey overline `Thu, Oct 22`; large title `Floor command, Supervisor`; green-tint pill `▦ 4/16 bays active`.
- **Content header:** large `Workshop floor`, grey subtitle `4 active · 16 bays`, magnifier at far right of title row.
- **Instruction + CTA:** sentence `Dispatch the next job into a free bay.` + single full-width blue pill `Dispatch to technician`.
- **Legend + filter:** four dot+label items `Occupied / Idle / Parts delay / QC`; scrollable chip row `All (filled) / Occupied / Parts delay / QC` + sliver of 5th chip peeking at right edge.
- **Bay grid:** 2-col cards `B-01 Yaris XYZ 5678 JC-207 4/4` (teal dot, `OH` chip), `B-02 Camry ABC 1234 JC-101 2/5` (green), `B-03 Hilux XYZ 1111 JC-900 1/4` (amber), `B-04 Civic BK-301 10:00` (green), `B-05/B-06 Idle` partial above nav.
- **Bottom nav region (the changed region):** five slots, left to right: `Floor` (active, blue grid icon + label), `Jobs` (clipboard), `Queue` (split-arrow), `Review` (check-badge), `More` (three-dot `···`). Outlined glyphs, active = accent. Five labels on one line, whole.

### `sv_more_open_en_360x800.png` (More sheet open)

- Dimmed floor behind (AppBar + greeting + header + Dispatch + legend + chips + B-01/B-02 visible, greyed).
- Foreground bottom sheet: drag handle, title `More`, three rows top to bottom: bar-chart icon + `Reports`, people icon + `Staff`, calendar icon + `Schedule`. Rows are icon + label, left-aligned, generous vertical rhythm. Sheet extends below capture bottom (Schedule fully legible; no `…`).

### `sv_floor_ar_1.0_360x800.png`

- Full RTL mirror. AppBar title `الأرضية` right; greeting `الخميس، ٢٢ أكتوبر` + `قيادة الأرضية، Supervisor` + pill `4/16 منصة قيد العمل`; header `أرضية الورشة` + `4 قيد العمل · 16 منصة` + magnifier left (end side); CTA `إسناد إلى فني`; legend/chips Arabic; bay cards mirrored with LTR codes intact (`B-01`, `JC-207`, `10:00`, plates). Bottom nav five Arabic labels, rightmost active (`الأرضية`), leftmost `المزيد` (More) with `···` glyph.

### `sv_floor_en_1.3_360x800.png`

- Same regions/order, larger text. Greeting wraps to two lines (`Floor command,` / `Supervisor`). Header + sentence + Dispatch intact. Legend + chips intact. Bay cards `B-01/B-02` fully legible above fold. Bottom nav five labels whole on one line each: `Floor / Jobs / Queue / Review / More`. No `…`, no mid-word break, no overflow stripe.

### `sv_floor_en_1.0_320x568.png`

- Same order compressed. AppBar + greeting (2-line title) + header + sentence + Dispatch + legend + chips (`All / Occupied / Parts delay / QC` peeking) visible; only top edges of `B-01/B-02` visible above nav. Bottom nav five labels whole. No `…`, no horizontal overflow stripe.

---

## (2) U0–U14 walk (each with image + region evidence; ANY fail caps at 8/16)

| Law | Evidence (image + region) | Pass / Fail |
|---|---|---|
| U0 — never hunt/scroll/tap more than necessary | `sv_floor_en_1.0` nav region: 4 primaries + More visible at launch, no scroll; `sv_more_open_en_1.0` sheet: 3 rows in one sheet, no hunt. Code: `_kPrimaryTabCount = 4`, More opens one `showAppBottomSheet` with the 3 overflow rows (scaffold lines 219–240). Frequent dispatch/queue/review stay on the bar; infrequent admin behind one disclosed More — standard progressive disclosure, not hunting | PASS |
| U1 — search icon top-right → full-screen search, never inline | `sv_floor_en_1.0 / ar_1.0 / 1.3 / 320` AppBar region: magnifier top-right (mirrored end-side in ar) next to bell/avatar in every frame. No inline field anywhere. Nav change adds no search affordance, removes none | PASS |
| U2 — first actionable item above fold at 360×800 idle | `sv_floor_en_1.0` grid region: `Dispatch to technician` + `B-01/B-02` fully + `B-03/B-04` fully visible above nav. Holds in `ar_1.0` and `1.3` (B-01/B-02 fully above fold). 320 shows tile top-edges only — noted tight but U2 governs 360×800 | PASS |
| U3 — tap counts (detail in §3) | `sv_floor_en_1.0` nav: Floor/Jobs/Queue/Review each 1 tap (code `_SupervisorBottomBar.onTap`: `bar < 4 → onSelected(bar)` directly, lines 283–289). `sv_more_open` sheet: Reports/Staff/Schedule each More → row = 2 taps (code `_openMore` pops index, lines 237–239). Migration-doc tap table verified from code: primaries 1→1, More rows 1→2 (+1, infrequent admin only). Most-frequent dispatch = 1 ≤ 2 | PASS |
| U4 — frequent create/scan reachable without scrolling, lower half or sticky | `sv_floor_en_1.0`: Dispatch CTA + first bays at launch, 0 scroll; nav bar itself is the sticky bottom reachable zone in every frame incl. 320/1.3 | PASS |
| U5 — NO truncation of primary text; rows fit or scroll with clean peek | `sv_floor_en_1.3`: nav `Floor/Jobs/Queue/Review/More` whole, one line each; greeting wraps at word boundary (2 lines), never `…`. `sv_floor_en_1.0_320`: nav whole; chips peek cleanly (`QC` cut at edge with label start visible = scroll affordance, not mid-word cut). `sv_floor_ar_1.0`: five Arabic nav labels whole; bay codes/plates/`JC-*`/`10:00` stay LTR and whole; greeting sentence wraps, no `…`. `sv_more_open`: `Reports/Staff/Schedule` whole, no `…`. Zero `…` fragments in any of the 5 frames | PASS |
| U6 — calm empty (no filled CTA to nothing) | All 5 frames show data (`4 active · 16 bays`, queue-backed bays); the single filled Dispatch leads somewhere that exists (16-bay map with 4 active). More sheet has zero filled CTAs (plain rows). No empty-state violation observable in this nav scope | PASS (stills-limited; no empty frame in this set) |
| U7 — ONE path per task; See-all only when more exists than shown | Nav region `sv_floor_en_1.0`: each primary appears once on the bar. More-sheet region `sv_more_open`: Reports/Staff/Schedule appear once each, inside the sheet. Code: `adaptive.useNavigationRail ? null : _SupervisorBottomBar` (lines 205–212) — rail OR bar, never both on one breakpoint; expanded rail keeps all 7 (lines 122–123, frame passes `items` full list), compact bar shows 4 + More. No co-visible duplication, so rail-vs-sheet is not a duplicate path. No See-all anywhere in these frames (correct: grid shows all, no hidden list) | PASS |
| U8 — relevance (actionable first; feed disorder logged, never silently filtered) | N/A here by construction — say so: shell/nav has no Assigned/To-do list. Bay statuses honest per unchanged derivation (`buildSupervisorBays` untouched per migration doc): B-01 QC-teal / B-02 Occupied-green / B-03 Parts-amber / B-04 Occupied-green. No completed-under-assigned pattern exists to violate; no silent filtering by this nav change | PASS (N/A, stated) |
| U9 — consistency (same element, same place) | `en_1.0` vs `ar_1.0` vs `1.3` vs `320` nav regions: identical order Floor/Jobs/Queue/Review/More, identical glyphs, mirrored correctly in RTL. Code: bar labels come from the same `_items(t)` list as the rail/IndexedStack (lines 41–77, 111, 270–275); More rows reuse `items[i].selectedIcon/item.icon/item.label` with order kept (indices 4/5/6, lines 227–234) and trailing check on the active overflow tab; `barIndex` maps an active overflow tab to the More slot (lines 277–279) so selection state stays truthful. AppBar/search/bell/avatar untouched | PASS |
| U10 — feedback/forgiveness; errors say what to do next | Code: `HapticFeedback.selectionClick()` on bar tap, More open, and More-row tap (lines 220, 315–317); `Semantics(button:true, selected:)` + trailing `check_rounded` on the active More row (lines 311, 346–351). Stills show the check affordance contract (unselected Floor state in `sv_more_open` correctly shows no check). No destructive action in this change; press timing not PNG-provable | PASS (stills-limited) |
| U11 — readable numbers | `sv_floor_en_1.0` greeting pill `4/16 bays active` + header `4 active · 16 bays` + bay meta `4/4`, `2/5`, `1/4`, `10:00`, `JC-207` all fully visible incl. `1.3`/`320`/`ar`. Zero renders `0`-capable (no `-` anywhere). Numbers tabular/labelled/decision-helping; no label/badge number duplication (no badges exist) | PASS |
| U12 — one background colour | All 5 frames: single page background; More sheet is a surface card over dimmed scrim (allowed sheet pattern), not a stray band. No strip behind nav rows | PASS |
| U13 — new-employee test (plain words in 3s) | Nav + sheet labels: `Floor / Jobs / Queue / Review / More` + `Reports / Staff / Schedule` — all plain verbs/nouns. Residual `QC` (legend/chip) is kept from before per brief, not introduced by this nav change | PASS (with pre-existing `QC` note, not counted against nav) |
| U14 — a11y: targets ≥48dp, AA, Semantics, 1.3x + 320px without clipping | Code: `_MoreDestinationRow` wraps content in `ConstrainedBox(minHeight: 48)` + `InkWell` (lines 320–323) — 48dp+ rows as specified; `AppBottomNav` is the shared spec-C8 widget (asserts 1–5 items; 4 + More = 5). Pixels: `1.3` + `320` + `ar` show zero overflow stripes, zero clipped CTA/pill/nav label; `Semantics(selected:)` wired on bar (via `AppBottomNav`) and sheet rows. Exact dp/contrast instrumented proof needs tests (migration doc pins 48dp+ rows + 320/1.3/ar pumps green) | PASS (stills-limited on exact dp/AA) |

**U-walk result: 15/15 PASS, 0 FAIL — U-clean on this nav change.** No 8/16 cap triggered.

Hard-reject cross-check (informational; no U-cap triggered): max-5 bar — 5 slots as rendered (`Floor/Jobs/Queue/Review/More`), satisfies C8/C16 max-5; ONE filled accent per section — nav carries no filled accent (active = accent text/icon only), More sheet carries zero filled CTAs; no duplicate entry — More is the single overflow path, not a second entry (see U7); no permanent status pill — none added (offline banner owns abnormal state, untouched); badges never cover icons — no badges exist on any tab so More carries none (code never wired `badgeIndices/badgeCounts`); no ALL CAPS — sentence-case throughout; no duplicated label/badge numbers — none; above-fold — Dispatch + B-01/B-02 visible at 360×800; card hierarchy / carousel-peek — untouched by this change.

REDESIGN MANDATE check: legacy 7-slot `AppBottomNavigation` overflow replaced by spec-C8 `AppBottomNav` + `AppBottomSheet` (mandate rule 2 — extend-App*/swap, no old widget kept); logic untouched (providers, routes, tab targets, derivation, selection, assign-sheet contract, copy/ARB all untouched per migration doc; no new keys/routes); visible before/after difference present (7-tab bar → 4 + More, confirmed `sv_floor_en_1.0` vs pre-nav goldens); no old structure preserved for convenience.

---

## (3) Tap walk — BEFORE → AFTER (dispatch/queue/review + the three More-moved tasks)

BEFORE counts (brief + migration-doc §Behavior assertions, verified from code): dispatch = bay tap → assign sheet (**1 tap, 0 scroll**); queue = Queue tab (**1 tap**); review = Review tab (**1 tap**); reports/staff/schedule = their tabs (**1 tap** each).

AFTER walk on these pixels + code paths:

1. **Dispatch a job into a bay** — `sv_floor_en_1.0`: tap `B-01…B-04` at launch → assign sheet (**1 tap, 0 scroll**). Alt: hero `Dispatch to technician` (**1 tap, 0 scroll**). Path: Floor primary, unchanged (`onSelected(0)`).
2. **Check what's waiting (Queue)** — bottom `Queue` primary → **1 tap, 0 scroll** (code `onSelected(2)`; `onOpenQueue` callbacks preserved). Rail `Incoming queue` unchanged below grid (optional, not a replacement).
3. **Review a finished job (QC)** — bottom `Review` primary → **1 tap, 0 scroll** (code `onSelected(3)`; route `/supervisor/review` pre-existing). Rail `Review` button same callback.
4. **Operations report (Reports)** — `sv_more_open`: More → `Reports` row → **2 taps** (**+1** vs before). Same tab target/route when tapped (code pops index 4).
5. **Workshop roster (Staff)** — More → `Staff` row → **2 taps** (**+1**). Same target (index 5).
6. **Bay schedule (Schedule)** — More → `Schedule` row → **2 taps** (**+1**). Same target (index 6).

| Task | Before | After | Delta |
|---|---|---|---|
| Dispatch a job into a bay (bay tap → assign sheet; hero Dispatch CTA) | 1 tap, 0 scroll | 1 tap, 0 scroll (Floor primary, unchanged) | ±0 |
| Check what's waiting (Queue tab; floor rail row/button) | 1 tap | 1 tap (Queue primary; rail unchanged) | ±0 |
| Review a finished job (Review tab; rail Review button) | 1 tap | 1 tap (Review primary; rail unchanged) | ±0 |
| Active jobs list (Jobs tab) | 1 tap | 1 tap (Jobs primary) | ±0 |
| Operations report | 1 tap (Reports tab) | 2 taps (More → Reports) | **+1** |
| Workshop roster | 1 tap (Staff tab) | 2 taps (More → Staff) | **+1** |
| Bay schedule | 1 tap (Schedule tab) | 2 taps (More → Schedule) | **+1** |

**Tap-count result: PASS.** Plainly: Reports, Staff and Schedule each cost exactly one extra tap (the More sheet); dispatch, queue, review and jobs cost the same as before. No frequent task takes more taps than before (U3: Reports/Staff/Schedule are infrequent admin destinations, not top-3 tasks); the most frequent (dispatch via bay tap, 1 tap) stays ≤ 2.

---

## (4) Airbnb rubric + score (0–2 each, pass ≥ 12/16) — ONLY after (1)–(3)

| # | Criterion | Score | Reason |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Floor-status → one sentence + CTA → bay map → rail preserved; nav change only re-houses 3 infrequent destinations behind one disclosed More, no widget grid added |
| 2 | Headline-first hierarchy | 2/2 | `Floor` → `Floor command, Supervisor` → `Workshop floor / 4 active · 16 bays` → sentence → single CTA order intact in all 5 frames; nav sits last as chrome |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Bar is 5 plain slots with whitespace separation; More sheet is one clean list (icon + label rows), no nested cards |
| 4 | Sheets for secondary actions | 2/2 | Infrequent Reports/Staff/Schedule correctly behind an `AppBottomSheet` with handle + title + rows (the spec pattern for >5 destinations); assign/search sheets untouched |
| 5 | Sticky CTA (N/A — home has none) | 2/2 | Correctly absent; counted by omission (Dispatch lives in-flow, no sticky bar claimed) |
| 6 | Section structure with Show-all | 2/2 | Legend + filter + full 16-grid + rail intact; See-all correctly absent everywhere (overflow lives behind More, not a second list) |
| 7 | Plain friendly copy, no invented claims | 1/2 | Nav/sheet copy sentence-case, plain words, shared `commonMore` key (en `More` / ar `المزيد`), no renames, no invented badges/counts; −1 carried reserve: pre-existing `Supervisor` English inside the ar greeting title + bare `QC` kept from before (both feed/brief-owned, not introduced by this nav change) |
| 8 | Single emphasized primary action | 2/2 | Exactly one filled Dispatch on every frame; nav + More sheet contribute zero competing filled accents |
| **Merit total** | | **15/16** | Pass on merit (≥12) |
| **C16 cap** | ANY hard-reject caps at 10/16 | **none** | 5 slots satisfy max-5 as rendered; no duplicate path, no second filled accent, no permanent pill, no badge cover, no ALL CAPS, fold met |
| **U-cap** | ANY violated law caps at 8/16 | **none — 15/16** | Zero U-fails in §2 |

**Verdict: PASS — bless the supervisor compact nav as U-clean. 15/16 (merit 15/16, caps none).** The −1 is a carried non-gating content reserve (ar greeting mix + bare `QC`), not a nav defect and not a gating item. Gating items for this change: NONE. Pre-existing shell notes (B-04 `Civic / BK-301 / 10:00` time-vs-progress feed shape; ar server-label English family) remain LOGIC/feed-owned and are not re-gated here.

---

## LOGIC #8 close recommendation — YES, CLOSE

Entry 8 ("Supervisor keeps 7 bottom-nav destinations vs spec max-5") is resolved as a **4 + More presentation decision, nothing hidden silently**:

- No destination removed, merged, or renamed: `_items` keeps all 7 in order (Floor/Jobs/Queue/Review/Reports/Staff/Schedule, indices 0–6); expanded rail keeps all 7 (frame passes full `items` list; rail shown when `adaptive.useNavigationRail`).
- Compact bar satisfies spec-C8 max-5 as rendered: 4 primaries + More = 5 slots (`sv_floor_en_1.0 / ar_1.0 / 1.3 / 320` all show five whole labels; `AppBottomNav` asserts ≤ 5).
- Overflow is the specified pattern for >5, not hiding: More opens an `AppBottomSheet` titled `More` with icon + label 48dp+ rows for Reports/Staff/Schedule in kept order, trailing check on the active overflow tab, same tab targets/routes when tapped (code `_openMore` / `_MoreDestinationRow`).
- Badge honesty: no tab carries badge/count state (scaffold never wired `badgeIndices`/`badgeCounts`), so More carries no dot/count — existing state read only, nothing invented, nothing suppressed.
- Tap impact stated plainly: primaries 1→1; Reports/Staff/Schedule 1→2 (+1 each, infrequent admin) — documented in the migration-doc tap table (§3 above), not silent.
- Product IA question answered: 7-task IA confirmed with More-overflow as the contract (top-3-task primaries on the bar, admin behind More). No further product decision blocks the bar migration — it has landed.

**Recommendation: CLOSE LOGIC #8 (orchestrator closes that file).** Standing open LOGIC items unrelated to this nav (#2 ar branch/shift, #3–#5 owner contracts, #6 stopwatch clock, #7 shared-caps grammar session work, #9 server English labels) are unaffected.
