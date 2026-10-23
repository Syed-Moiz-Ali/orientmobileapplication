# ADVERSARIAL SEARCH-RELOCATION REVIEW — staff (ruling a) — FAIL

**Role:** Adversarial confirmer (fresh eyes; did not relocate). Assumes ruling is still wrong.
**Branch:** `ui/fix-rulings` (verified `git branch --show-current`; READ-ONLY except this file; no checkout/commit/push/merge; never touched `71983229`).
**Ruling under test (a):** sv Jobs tab — NEW register search sheet + AppBar icon (inline removed, old dual-search STOP resolved); sv floor + tech Today — shell icon unhidden, page icons removed; tech detail — NEW task find sheet + AppBar search action. Claims: single path each, taps ≤ before, 112 tests green.
**Governance:** DESIGN_SPEC C16 (any hard-reject caps 10/16) + C17 U0–U14 (any violated law caps 8/16). Pass ≥12/16 with caps.
**Read first:** `evaluation/supervisor-jobs-list-test-migration.md` §Scope-unification, `evaluation/supervisor-home-test-migration.md` §Scope-unification, `evaluation/technician-home-test-migration.md` §Scope-unification + Jobs-addendum, `evaluation/technician-detail-test-migration.md` (all of it).
**Images viewed (full resolution, Read):**
- `after-supervisor-jobs/idle_light_1.0_en_360x800.png` — no inline field, rail only.
- `after-supervisor-jobs/search_light_1.0_en_360x800.png` — sheet `Active jobs` + field `sara` → 1 row `Civic DEF 9012 / JC-102 Sara / Completed`.
- `after-supervisor-home-current/sv_home_en_1.0_360x800.png` — shell row `Floor | magnifier | bell | S avatar`; page `Workshop floor / 4 active · 16 bays` has NO icon.
- `after-supervisor-home-current/sv_home_search_open_en_360x800.png` — sheet `Find on the floor` + 16 bays.
- `after-technician-home/today_1.0_en_360x800.png` — page `Today / Morning shift · Working` has NO icon (tab-alone crop; shell owns icon per shell-fix).
- `after-technician-home/today_search_open_en_360x800.png` — sheet `Search jobs` + 3 jobs.
- `after-technician-job-detail/detail_1.0_en_360x800.png` — AppBar `← Job details | [magnifier] | [Synced]`; body has NO other search.
- `after-technician-job-detail/detail_search_open_en_360x800.png` — sheet `Search jobs` + field `oil` → 1 row `Change engine oil / Completed`.
- `after-shell-fix/sv_floor_en_1.0_360x800.png` — shell `Floor | magnifier | bell | S` (same as home-current base).
- `after-shell-fix/tech_today_en_1.0_360x800.png` — shell `Today | magnifier | bell | OH avatar` + page `Today / Morning shift · Working` with NO page icon.
**Code read (read-only, attribution):** `supervisor_scaffold.dart:_SupervisorChrome:405-419,_openSearch:95-117`; `supervisor_jobs_tab.dart:30-33,95-114` (no `AppSearchField`); `supervisor_dashboard_tab.dart:_FloorHeader:190-225` (title+subtitle only); `supervisor_register_search.dart:_results:49-58,showSupervisorRegisterSearch:14-24`; `supervisor_floor_search.dart:19-20,81-83`; `supervisor_assign_sheet.dart:106-109`; `technician_dashboard_view.dart:_TechChrome:365-369,_openSearch:78-86`; `technician_today_view.dart:_TodayHeader:264-309` (no glyph); `technician_jobs_view.dart:_JobsToolbar:193-239` (rail only); `technician_today_search.dart:_results:51-64,title:18,hint:84`; `technician_task_search.dart:title:19,hint:74,_results:47-53,onSelect:150-167`; `job_detail_sheet.dart:138-168` (`WorkspaceAppBar:onSearch`).

## Verdict: FAIL — 8/16 (binding cap: U-law; secondary cap: C16 taps)

Merit 13/16, C16 taps-regress caps at 10/16, any U-law fail caps at 8/16 → **final 8/16 — FAIL**.
112-tests-green claim **UNVERIFIED** under read-only constraint (no test run; counts 8/11/3 cited from migration docs only; stills + code verified instead).

## Ranked defect list (gating first, strict)

### D1 — [GATING] Shell search on NON-search tabs opens the WRONG scope (U8 relevance + U1) — caps 8/16
- **Pixels + code:** `sv_floor_en_1.0_360x800` / `tech_today_en_1.0_360x800` prove the icon sits top-right in the shell AppBar row adjacent bell/avatar (magnifier → bell → avatar, same 56 hairline row). Code proves it shows on **every** tab: `_SupervisorChrome:405-419` has NO `selectedIndex` guard (guard `selectedIndex != 0` deleted per migration); `_TechChrome:365-369` likewise unconditional.
- **Wrong target:** `supervisor_scaffold.dart:95-117` `_openSearch`: `if (_navIndex==1)` register else **floor sheet for everything else**. So Queue (2) / Review (3) / Reports (4) / Staff (5) / Schedule (6) all open `showSupervisorFloorSearch` over `buildSupervisorBays` — a floor lookup while the user is on Queue/Review. `technician_dashboard_view.dart:78-86` `_openSearch` **always** opens `showTechnicianTodaySearch` over `allJobs`; so Productivity (2) / Profile (3) show a jobs search while on non-jobs tabs.
- **Law:** C17-U8 (relevance: completed/history never under wrong list; by extension a search must search the visible list), C17-U1 (search icon top-right → full-screen search **for that screen's data**). A Queue-tab magnifier that searches bays, or a Productivity-tab magnifier that searches jobs, is the exact forbidden mismatch. The ruling claim "per-tab scope" is true only for Floor/Jobs/Today; the shipped code is "Jobs-scope else floor-scope" / "always jobs-scope".
- **Fix:** gate `_openSearch` per tab (Queue→queue sheet or NO icon; Review→review sheet or NO icon; Reports/Staff/Schedule/Productivity/Profile→NO icon), or scope the icon visibility per tab instead of always-on. Presentation/flow-wiring only.

### D2 — [GATING] Detail task sheet mislabeled `Search jobs` — identical title to Today jobs sheet, different entity (U9 consistency + U10 feedback + U13 plain copy) — caps 8/16
- **Pixels:** `detail_search_open_en_360x800.png` title `Search jobs` + field `oil` → row `Change engine oil / Completed` (a **task**). `today_search_open_en_360x800.png` title `Search jobs` → rows `Toyota Camry JC-101… / Nissan Yaris JC-102… / Toyota Hilux JC-103…` ( **jobs**). Two different sheets, byte-identical title, different data.
- **Code:** `technician_task_search.dart:19` `title: techJobsSearch`, `:74` `hintText: techJobsSearch`; `technician_today_search.dart:18` same `techJobsSearch`, `:84` same. Migration boasts "zero new keys (reused `techJobsSearch`…)" — reuse is the bug: the title promises jobs while `_results:47-53` filters `WorkTaskEntity.description` only.
- **Law:** C17-U9 (same element same place; here same title different element), C17-U10 (feedback lies about what is being searched), C17-U13 (new employee reads `Search jobs`, gets tasks). A first-time tech cannot distinguish the two `Search jobs` sheets by title.
- **Fix:** new ARB keys `techTaskSearch / techTaskSearchHint / techTaskNoMatch` (or at minimum title `Search tasks`); zero logic change. The "zero new keys" constraint does not cure a U-law.

### D3 — [GATING] sv Jobs find-only tap REGRESSION — inline 1+keys vs sheet 1+keys+close (C16 taps-never-regress + U14) — caps 10/16 (also U14)
- **Pixels:** `idle_light_360` (before inline) filtered in place; `search_light_360` (after) filters inside the modal sheet; background register dimmed behind.
- **Count:** BEFORE find-only = tap field (1) + keystrokes (rows narrow in place, no dismiss). AFTER find-only = tap AppBar icon (1) + keystrokes + tap `×`/close or back (1) to return to the register without assigning = **2 taps + keys vs 1 tap + keys**. Migration §Behavior counts find as `icon (1) + keystrokes + result (1)` — that merges find with assign (result tap opens `showSupervisorAssignSheet` per `supervisor_scaffold.dart:100-104` + `supervisor_register_search.dart:107-112`). Find-without-assign regresses by exactly the dismiss.
- **Criterion:** C16 hard-reject list "taps never regress"; U14 "no regression". Floor/Today hold (page-icon 1+keys+result → shell-icon 1+keys+result, same), detail holds (2→≤2). Jobs find-only does not.
- **Fix:** acknowledge as accepted cost of scope-unification (update brief tap budget) or add sheet `Show N results / Apply` that pops back to a filtered register instead of forcing assign-or-close. Do not pretend budgets are identical.

### D4 — [GATING, secondary] Today sheet no-match has NO Clear / no live control (U6 calm-empty + U8 no dead ends) — caps 8/16
- **Code:** `technician_today_search.dart:93-117` no-match = two `Text` (`techJobsNoMatch` + Hint), **no button**. Siblings both have Clear: register `supervisor_register_search.dart:90-98` (`AppEmptyState` + `filterBarClear`), task `technician_task_search.dart:106-112` (secondary Clear pill).
- **Law:** C17-U6/U8: every state offers a live control; no-match must offer Clear that restores rows. Today no-match strands the user (must manually delete query or close sheet). Pre-existing, exposed by regen, not introduced — but present on CURRENT PNGs' code path, so gates the relocation bless.
- **Fix:** add the same secondary Clear pill (presentation only).

## What PASSED (strictly verified, with evidence)

- **(1) Search icon top-right in shell AppBar row adjacent bell/avatar:** sv floor — `sv_home_en_1.0_360x800` top row `Floor | magnifier | bell | S` + `after-shell-fix/sv_floor` identical; tech Today — `after-shell-fix/tech_today_en_1.0_360x800` top row `Today | magnifier | bell | OH`; sv Jobs — same `_SupervisorChrome` component (`supervisor_scaffold.dart:415-432`: `AppIconButton search | StaffNotificationBell | UserAvatar` in one `AppAppBar` row; tooltip `svJobsSearchHint` on index 1 else `svSearchTitle`); detail — `detail_1.0_en_360x800` AppBar row `← Job details | [magnifier box] | [Synced pill]` (`job_detail_sheet.dart:138-168`). Detail has no bell/avatar by design (WorkspaceAppBar, not DashboardShell) — adjacency N/A there, placement top-right holds.
- **(2) EXACTLY ONE visible search path (studied surfaces):** sv Jobs idle — zero `AppSearchField` in tab (`supervisor_jobs_tab.dart` grep: none; only `AppFilterBar` rail); floor base — `_FloorHeader` title+subtitle only, no glyph; Today idle — `_TodayHeader` title+subtitle only; Jobs toolbar — rail only; detail idle — exactly one `onSearch` in AppBar, no inline. No inline fields anywhere on CURRENT PNGs. (Caveat: D1 shows the one icon exists on tabs where it should not; count is one, scope is wrong.)
- **(3) Register sheet same predicate (spot-check narrowing + result contract):** `sara` → 3→1 `Civic DEF 9012 / JC-102 Sara` (customer-field hit). Code `_results:49-58` = `jobCard/customer/vehicle/status lower-contains` — same 4 fields claimed for inline. Result tap = `pop + onSelect → showSupervisorAssignSheet` (`supervisor_register_search.dart:107-112` + `supervisor_scaffold.dart:100-104`) — same assign contract. **Gap disclosed:** floor sheet (16 bays, empty query) and Today sheet (3 jobs, empty query) show NO narrowing query in any CURRENT frame — narrowing for those two scopes is code-only (`supervisor_floor_search.dart`, `technician_today_search.dart:51-64`), unproven by pixels. Detail sheet narrowing PROVEN: `oil` → `Change engine oil / Completed` over `description contains` (`technician_task_search.dart:47-53`); result = existing toggle (`inProgress→complete else start`, completed/QC-locked no-op per `job_detail_sheet.dart:155-165`) — sticky bar + keyboard-safe intact per code.
- **(4) Taps (except D3):** floor 1+keys+result 1 same seat change; Today same; detail find = icon 1 + keys + result 1 = ≤2 from detail (start/complete contract unchanged). Assign/Dispatch/Clear/Retry/pull unchanged per code (rail `AppFilterBar`, `RefreshIndicator`, `AppErrorState` untouched).
- **No NEW truncation/orphan/color regression on viewed frames:** Jobs rail wraps (`All / In progress 1 / Completed 1` + `Parts delay 1` second line, no `Par…` cut); row-2 bar stays success-green full `4/4 tasks` (D3 from adversarial-sv-jobs stays fixed); floor `Camry ABC 1234` whole; Today stacked CTAs whole.

## Consistency cross-check (siblings actually opened)

- sv floor sheet title `Find on the floor` vs register sheet `Active jobs` vs tech Today + detail both `Search jobs` — three grammars for the same sheet pattern (U9 tension; D2 is the gating instance).
- `supervisor_assign_sheet.dart:106` retains an `AppSearchField` (`svAssignTargetHint` → `updateJobCardSearch`) inside the Assign sheet. Not counted as a second register path (sheet-scoped assign-target lookup, different hint/scope, invisible until Assign), but with D1+D2 the surface now has **three** search-field visuals across the flow (shell icon → register sheet field; Assign sheet field; floor sheet field) — keep hints/scopes distinct or reviewers will conflate them.
- Queue/Review tabs (`supervisor_queue_tab.dart:131`, `supervisor_review_tab.dart` equivalents) show `search_off` empty art but the shell now offers a search icon on those tabs that searches floor — empty-state art and bar affordance disagree (D1).

## Airbnb rubric (ONLY after §§above), /16, pass ≥12

| # | Criterion | Score | Why |
|---|---|---|---|
| 1 | One task per screen | 1/2 | Find→assign coherent on studied tabs, but D1 wrong-scope icons + D3 extra dismiss |
| 2 | Headline-first hierarchy | 2/2 | Vehicle-first → ref+customer → progress → pill holds on all four |
| 3 | Whitespace, no boxes | 2/2 | Borderless divider rows / plain sheets, no cards-in-cards |
| 4 | Sheets for secondary | 1/2 | Sheets used correctly, but D2 wrong title + D4 Today no-match no Clear |
| 5 | Sticky CTA | 2/2 | Correctly non-sticky / in-flow only |
| 6 | Section structure | 1/2 | Header+rail+rows clean, but D1 scope confusion leaks across tabs |
| 7 | Plain copy | 1/2 | Verbatim keys, zero new, but D2 `Search jobs` for tasks |
| 8 | Single primary action | 2/2 | Exactly one filled accent per state |
| **Merit** | | **12/16** | |
| **C16 cap** | taps never regress | **caps at 10** | D3 find-only +1 |
| **C17 cap** | any U-law fail | **caps at 8** | D1 U8/U1, D2 U9/U10/U13, D4 U6/U8 |
| **Final** | | **8/16 — FAIL** | Merit 12, capped to 8 |

Gating defects: D1–D4 each independently gate; D1–D2 are relocation-introduced. Non-gating nits: shell-fix rail `Id` peek (`sv_floor` filter row trailing `Id` cut — start-visible peek, tolerable); Today queue `Starts 10:…` secondary ellipsis (permitted meta); `references/` + `AIRBNB_PATTERNS.md` still UNMET (process debt, unscored).

## Answers

- **First-time user in 3s?** On the four studied screens, yes — one magnifier top-right, one sheet, one result contract. Off those screens, no: a Queue-tab magnifier that searches the floor, and two `Search jobs` sheets that search different entities (jobs vs tasks), break the promise.
- **What would an Airbnb designer reject?** Wrong-scope shell icons (D1), `Search jobs` title on a tasks sheet (D2), and the extra dismiss on Jobs find-only (D3) — in that order. Fix D1+D2 (both presentation-only, no logic), add Today no-match Clear (D4), and either fix or formally accept D3's tap budget.

*(End — adversarial-search-relocation-staff, 2026-10-23, ui/fix-rulings, READ-ONLY except this file.)*
