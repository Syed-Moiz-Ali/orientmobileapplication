# CRM tasks list — Fresh review ROUND 1 (PASS 16/16)

**Role:** FRESH REVIEWER (round 1), never built this screen. READ-ONLY except this file. No code/tests/PNGs edited. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/list-crm`.
**Read first:** Brief `docs/ui-redesign/briefs/crm-tasks-list.md` (authoritative, as amended — includes the ONE sanctioned U1 exception: search icon only when > 5 items, additive find-aid over a zero-search before); migration `docs/ui-redesign/evaluation/crm-tasks-list-test-migration.md` (behavior pins); REDESIGN MANDATE (PROGRESS.md working rule 13) + C16 hard-reject (caps 10/16) + U0–U14 C17 (DESIGN_SPEC §C16–C17; brief §§U-laws is the authoritative application). Pass ≥ 12/16 with caps.
**References:** `docs/ui-redesign/references/` does NOT exist; `AIRBNB_PATTERNS.md` missing repo-wide (both per brief §References, confirmed UNMET — not pretended; phase-5/6/7 precedent patterns cited instead).
**Images viewed (8/8 AFTER via Read + contact sheet + 2 BEFORE for structure):**
- AFTER `docs/ui-redesign/baseline/after-crm-tasks/`: `tasks_idle-2_light_1.0_en_360x800`, `tasks_idle-6_light_1.0_en_360x800`, `tasks_search-open_light_1.0_en_360x800`, `tasks_empty_light_1.0_en_360x800`, `tasks_idle-2_light_1.0_ar_360x800`, `tasks_idle-2_light_1.0_en_320x568`, `tasks_idle-2_light_1.3_en_360x800`, `tasks_idle-2_light_1.0_en_768x1024`.
- Contact sheet `docs/ui-redesign/baseline/phase-crm-tasks-light.png` (BEFORE/AFTER side-by-side, viewed).
- BEFORE `docs/ui-redesign/baseline/before-crm-lists/`: `tasks_idle-2_light_1.0_en_360x800`, `tasks_empty_light_1.0_en_360x800` (structure only).
**Code read-only (attribution only):** `apps/crm_app/.../widgets/crm_tasks_page.dart` (`showFindAids = tasks.length > 5`, 48×48 toggle hit area `:212-214`, `taskToggle_<id>` keys, `showAppDialog` delete `:152`, `AppEmptyState` empty, subtitle null-when-empty `:67`).

---

## 1. DESCRIBE — region by region, WITHOUT judging

### AFTER idle-2 en 360 — `tasks_idle-2_light_1.0_en_360x800.png`
- **Header region:** first line bold `Tasks`; second line muted `2 tasks`. Below, a grey refresh-circular glyph left and blue `+ Add Task` text right. No magnifier on this frame.
- **Card 1 region:** white rounded card. Left: hollow circle outline. Middle: bold `Task 0`, then muted `⚑ Sara` + `▢ No due date` on one line, then pale-red pill `● High` below. Right: two pale-circle buttons — grey pencil, red trash.
- **Card 2 region:** same structure: circle + `Task 1` + `⚑ Unassigned` / `▢ No due date` (two lines) + `High` pill; pencil + trash right. Frame ends below card 2.

### AFTER idle-6 en 360 — `tasks_idle-6_light_1.0_en_360x800.png`
- **Header region:** `Tasks` + `6 tasks`; second row: grey magnifier, grey refresh glyph, blue `+ Add Task`.
- **Cards region:** five cards visible (`Task 0`…`Task 4`, frame cuts mid fifth), each with the card-1 structure (circle + title + assignee/due meta + `High` pill + pencil/trash).

### AFTER search-open en 360 — `tasks_search-open_light_1.0_en_360x800.png`
- **Dimmed list behind:** two cards greyed (`Task 0`, `Task 1`).
- **Sheet region:** white rounded sheet with drag handle, title `Search tasks` left + `×` right; rounded input with magnifier and hint `Search by title or assignee`; six rows `Task 0`…`Task 5` left, assignee (`Sara` on rows 0/2/4, blank elsewhere) right.

### AFTER empty en 360 — `tasks_empty_light_1.0_en_360x800.png`
- **Header region:** `Tasks` only, no subtitle; single grey refresh glyph below, no Add action.
- **Empty region:** pale circle with check-badge glyph; bold `No tasks yet`; muted sentence `Create tasks for your team to follow up on leads`; full-width blue `Add Task`.

### AFTER ar 360 — `tasks_idle-2_light_1.0_ar_360x800.png`
- Title right-aligned `المهام`, subtitle `2 مهمة`; `+ أضف مهمة` + refresh row below (mirrored). Cards mirrored: circle right of `Task 0`/`Task 1` (Latin titles stay LTR), meta `Sara`/`بدون تاريخ` and `غير مُسند`/`بدون تاريخ`, `High` pill in Latin, pencil/trash circles left.

### AFTER 320px — `tasks_idle-2_light_1.0_en_320x568.png`
- Same header stacked; card 1: circle + `Task 0`, meta wraps to two lines (`Sara` / `No due date`), `High` pill below, pencil/trash intact on the right; card 2 below. No clipped controls visible.

### AFTER 1.3x 360 — `tasks_idle-2_light_1.3_en_360x800.png`
- Same two-card stack; meta wraps (`Sara` / `No due date` on separate lines), pills below titles; all rows legible, no overflow markers visible in the still.

### AFTER tablet 768 — `tasks_idle-2_light_1.0_en_768x1024.png`
- Header same-row (`Tasks` + `2 tasks` left, refresh + `+ Add Task` right). Two wide single-column cards: circle + title, then assignee + due + `High` pill all on one meta row; pencil/trash right. No clipping.

### BEFORE vs AFTER structure (idle-2, empty, contact sheet)
- BEFORE idle-2: `2 Tasks` pill (title-case) + refresh tile + dark filled `+ Add Task` on one row; bordered rows with circle + `Task 0` + `Sara`/`No due date` + bare `High` text + small teal pencil / red trash tiles.
- AFTER idle-2: pill gone → `Tasks` + `2 tasks` subtitle; dark Add gone → `+ Add Task` text; bordered rows gone → borderless cards; `High` becomes a dotted `AppStatusChip` pill; pencil/trash become large pale-circle buttons. Visible before/after difference is structural — redesign delivered.
- BEFORE empty: `0 Tasks` pill + refresh + dark `+ Add Task` above `No tasks yet` + sentence + dark `+ Add Task`.
- AFTER empty: pills and header Add gone; calm icon + title + sentence + one blue `Add Task`. The `0 Tasks` pill removal is consistent with the subtitle-null-when-empty rule (code `:67`); zero-as-`0` is carried by the ICU `tkCountN` `=0` branch and the no-match path instead.

---

## 2. U0–U14 walk (brief application; each with image + region evidence)

| Law (brief) | Evidence (image + region) | Pass / Fail + attribution |
|---|---|---|
| U0 — one card = title → assignee/due meta → ONE due/priority signal; CARD HIERARCHY binding | idle-2 card 1: `Task 0` → `Sara` + `No due date` → ONE `High` pill. Card 2 identical with `Unassigned`. Borderless light cards, whitespace gaps. Migration: `AppStatusChip` due/priority pills, verbatim labels, sentence case | PASS (owner-file) |
| U1 — find fast: header search icon top-right over loaded tasks; THE ONE sanctioned exception: icon ONLY when > 5 | idle-2 (2 items): NO magnifier — refresh + Add only ✓. idle-6 (6 items): magnifier + refresh + Add ✓. Code `crm_tasks_page.dart:59` `showFindAids = tasks.length > 5`. Search sheet: `Search tasks` + `×` + hinted field + 6 title/assignee rows; no-match + Clear in code; scroll path unchanged. The zero-search before is the U1 violation this fixes | PASS — search threshold verified both directions; additive, no regression |
| U2 — first task card above fold @360x800, second peeking | idle-2 360: card 1 complete + card 2 complete/peeking; 320: card 1 + card 2 band; tablet: both wide cards stacked. Single-column list everywhere; no tables/carousels | PASS |
| U3 — budgets are ceilings; most frequent (toggle) ≤ 2 from launch, ≤ 1 from list | Toggle sits DIRECTLY on every card (all idle frames). Pixel + code: `taskToggle_<id>` keys kept (`:209`), same `toggleTask` handler (`:129`). No path exceeds before (see §3) | PASS |
| U4 — Add reachable: header when non-empty / empty-state when empty, sticky-safe @320px; complete/reopen without scrolling past one screen where possible | Add in header on all non-empty frames; empty frame has NO header Add and one `Add Task` CTA. 320: header + first card intact. U4-as-applied-in-brief (header/empty-state pattern, same as the sanctioned list precedent) | PASS (brief application governs) |
| U5 — no truncation (titles wrap ≤ 2, meta wraps); 30px targets grow to 48dp; 320px/1.3x without clipping | 320: meta wraps to two lines, pill drops below, icons intact. 1.3x: same wrap, no overflow markers. Tablet: meta row fits one line. **48dp toggles:** code `SizedBox(width: 48, height: 48)` hit area with 24px visual (`:212-214`); edit/delete are `AppIconButton`s (`:302-309`, migration: 48dp, tooltips added). ar: `Task 0/1` LTR, dates/numbers follow locale, pills wrap cleanly | PASS — stills-limited for exact dp; harness suite GREEN per migration (incl. the `Flexible`-meta 6px-overflow fix the suite itself caught) |
| U6 — calm empty (1 icon + 1 sentence + 1 Add → same form); loading skeleton mirroring cards; error + Try again (same refresh); stale kept; pull-to-refresh | Empty: 1 icon + `No tasks yet` + 1 sentence + 1 `Add Task` → same `_showTaskForm`; header Add correctly absent when empty. `RefreshIndicator` kept per migration. No skeleton branch: `isLoading` is never set true by the notifier, so a skeleton on `isLoading && empty` would be dead code — filed as a logic candidate in the session return (LOGIC_FOLLOWUPS.md is owner-edited), not built. Same for the list-level error branch (team-dropdown errors map to `AppBanner` + `AppInputField` hints instead). Matrix requires no loading/error frames for this screen | PASS — no fake states; documented logic gaps, no regression (before had neither) |
| U7 — one path per task (Add header XOR empty-state; never both) | Pixel-verified: non-empty frames carry header Add and no inline CTA; empty frame carries the CTA and no header Add. Never both at once anywhere | PASS |
| U8 — overdue/done ordering kept verbatim (no silent re-sort) | Feed order untouched per migration (`_dueStateOf` parseable-only, never guessed; unparseable = no badge — pixel frames show bare `No due date` rows with no badge, correct). No completion-reorder observed in frames; any future mis-ordering is a LOGIC_FOLLOWUPS item per brief, not filtered here | PASS |
| U9 — same atoms/placements as the leads rebuild on this branch | `AppPageHeader` + ICU count subtitle + `AppIconButton`s + borderless `AppSurfaceCard(outlined: false)` + `AppStatusChip` + `AppEmptyState` + `showAppModalSheet`/`showAppDialog` — identical grammar to leads | PASS |
| U10 — every destructive action confirms (`AppDialog` naming the task); errors say what to do | Delete: `showAppDialog` destructive with `tkDeleteTitle`/`tkDeleteBody(title)` + explicit `onPrimary` pop (`:152`, fixed after a failing test per migration) → same `deleteTask`; NO undo (undo would be logic). **No delete-confirm PNG in the capture set — capture gap, code + structural tests are the evidence** (same standing as vehicles-R1 U7). Team-dropdown error → `AppBanner` (`tkTeamFail` verbatim); validation → `AppInputField.error` | PASS (code + tests; PNG gap filed) |
| U11 — zero as `0`, never `-`; counts from `tasks.length` only | `2 tasks` / `6 tasks` pixel via ICU `tkCountN` (`=0{0 tasks} =1{1 task} other`, `app_en.arb`, `flutter gen-l10n` clean per migration); `=0`/`=1` branches code-verified though no 0/1-count frame is captured (empty hides the subtitle by rule `:67`). Omar-style zero pixel lives on the team screen; due badges only from `_dueStateOf` | PASS |
| U12 — one background (surface-on-background, no stray bands) | All frames: single page background, cards as surface-on-background. The old white-`Container`-on-white duality is preserved in token form, not as stray strips | PASS |
| U13 — plain labels (`Add task`, `Mark done`, new-employee clear) | `Tasks`, `Add Task`, `Search tasks` / `Search by title or assignee`, `No tasks yet`, `No due date`, `Unassigned`, `High/Medium/Low` — plain verbs, no jargon; ar fully translated except verbatim stored names (`High`, person names — same server-label rule as migration) | PASS |
| U14 — 48dp targets (fixes the 30px/32px violations), AA pairs, Semantics on toggle, 320px + 1.3x without clipping | 48dp toggle/edit/delete per code + GREEN harness; `taskToggle_<id>` Semantics/keys kept; 320 + 1.3x + tablet + ar frames show no clipping or overflow markers. Tap budgets: see §3 | PASS (stills-limited for exact dp/contrast met
...[truncated 3881 chars]

---

## ROUND 2 — Fresh independent review (CONFIRM round-1: PASS 16/16, ZERO gating)

**Role:** FRESH REVIEWER (round 2), never built this screen. READ-ONLY except this appended section. No code/tests/PNGs edited. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/list-crm` (verified via `git branch --show-current`).
**Read first:** Brief `docs/ui-redesign/briefs/crm-tasks-list.md` (authoritative, incl. the ONE sanctioned U1 exception: search icon only when > 5 items); migration `docs/ui-redesign/evaluation/crm-tasks-list-test-migration.md`; round-1 rows U0–U14 above (all PASS as surviving on disk; file ends mid-U14 with a literal truncation marker kept verbatim — §3/§4/score sections not present on disk, so this round independently re-verifies everything).
**Images viewed (8/8 AFTER + contact sheet, independently):** `tasks_idle-2_light_1.0_en_360x800`, `tasks_idle-6_light_1.0_en_360x800`, `tasks_search-open_light_1.0_en_360x800`, `tasks_empty_light_1.0_en_360x800`, `tasks_idle-2_light_1.0_ar_360x800`, `tasks_idle-2_light_1.0_en_320x568`, `tasks_idle-2_light_1.3_en_360x800`, `tasks_idle-2_light_1.0_en_768x1024` + `phase-crm-tasks-light.png` (BEFORE/AFTER side-by-side).
**Code read-only (attribution):** `crm_tasks_page.dart` (`showFindAids = tasks.length > 5` :59; subtitle null-when-empty :67; `taskToggle_<id>` :209 + 48px hit area :212-214; same `toggleTask` :129; `showAppDialog` delete :150-164; `AppEmptyState` :109-115; `_dueStateOf` parseable-only :171-181), `crm_tasks_search_sheet.dart` (title/assignee substring filter, no-match + Clear via `leadsFilterClear`, result tap pops + `onSelect` reveal), `app_en.arb`/`app_ar.arb` (`tasksSearchTitle/Hint/NoMatch`, ICU `tkCountN` =0/=1/other), characterization test file (10 `testWidgets` covering header/cards/toggle/edit/add-validation/delete/search/empty/unparseable/matrix).

### Independent U0–U14 walk (own pixel + code evidence)
- U0 — PASS. idle-2: `Task 0` → `Sara` + `No due date` → ONE `High` pill; card 2 same with `Unassigned`. Borderless light cards, whitespace gaps.
- U1 — PASS. idle-2 (2 items): NO magnifier (refresh + Add only). idle-6 (6 items): magnifier + refresh + Add. Code :59 both directions. Sheet: `Search tasks` + hinted field + 6 title/assignee rows; filter/no-match/Clear/result-reveal in code; scroll path unchanged. Sanctioned > 5 exception honored, additive.
- U2 — PASS. 360x800: card 1 complete + card 2 visible; 320: header + first card intact; tablet: two wide single-column cards. No carousels.
- U3 — PASS. Toggle DIRECTLY on every card (all idle frames); same handler, keys kept. No budget exceeded.
- U4 — PASS. Add in header when non-empty; empty frame has NO header Add + exactly one `Add Task` CTA; 320 sticky-safe.
- U5 — PASS. 320/1.3x: meta wraps to two lines, pill drops below, icons intact, no overflow markers; tablet single-row meta. 48dp via code (toggle `SizedBox(48,48)` + 24px visual; edit/delete `AppIconButton`s) + `Flexible` meta. Stills-limited for exact dp — code-measured.
- U6 — PASS. Empty = 1 icon + `No tasks yet` + 1 sentence + 1 `Add Task` → same sheet; `RefreshIndicator` kept. No skeleton/error branches = no fake states (before had neither; `isLoading` never set by notifier — logic candidate, not built). Matrix requires no loading/error frames.
- U7 — PASS. Header-Add XOR empty-CTA, never both, all frames.
- U8 — PASS. Feed order untouched; `_dueStateOf` parseable-only, unparseable = no badge (pixels: bare `No due date` rows, correct).
- U9 — PASS. `AppPageHeader` + ICU subtitle + `AppIconButton`s + borderless `AppSurfaceCard(outlined:false)` + `AppStatusChip` + `AppEmptyState` + `showAppModalSheet`/`showAppDialog` — same grammar as leads.
- U10 — PASS. Delete = `showAppDialog` destructive naming the task → same `deleteTask`, NO undo (undo would be logic). No delete-confirm PNG = capture gap, code + 10 structural tests are the evidence. Team error → `AppBanner`; validation → inline `AppInputField.error`.
- U11 — PASS. `2 tasks`/`6 tasks` pixel via ICU `tkCountN`; `=0`/`=1` branches code-verified (empty correctly hides subtitle :67). No `-` anywhere.
- U12 — PASS. Single background everywhere, cards as surface-on-background, no stray bands.
- U13 — PASS. Plain labels throughout; ar fully translated except verbatim stored names (`High`, person names — same server-label rule as migration).
- U14 — PASS. 48dp targets per code, `taskToggle_<id>` Semantics/keys kept, no clipping at 320/1.3x/tablet/ar. Stills-limited for exact dp/contrast — code + GREEN-harness cited, frames show no markers.

### Independent tap walk (AFTER ≤ BEFORE, no regression)
- Open list: 1 tap (tab) — unchanged. Toggle: ≤1 from list / ≤2 from launch (direct circle). Add: ≤2 (header or empty-state). Edit: ≤2 (48dp icon, same sheet). Delete: ≤2 + 1 confirm (`AppDialog`, same `deleteTask`). Find: scroll unchanged + ≤2 via header search (> 5 only). All within brief budgets.

### C16 checklist (hard-reject — none triggered)
Borderless light cards ✓ · one filled accent per section (empty CTA; header Add is text) ✓ · no orphan tiles (N/A) ✓ · no permanent pills (count in subtitle) ✓ · no ALL CAPS ✓ · search = one top icon → sheet (> 5 only) ✓ · card hierarchy title → meta → pill ✓ · no carousel ✓. **C16 PASS.**

### Verdict
**AGREE with round-1 (CONFIRMED). Final score: 16/16. Pass threshold ≥12/16 met. Gating issues found: ZERO.** Capture gaps noted (no delete-confirm PNG; no 0/1-count frame) are evidence gaps, not gating — same standing as round-1. Round-1 rows U0–U14 above kept verbatim; truncation marker preserved.