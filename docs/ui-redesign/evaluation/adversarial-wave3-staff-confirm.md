# ADVERSARIAL WAVE-3 STAFF CONFIRM — ui/fix-rulings — PASS 15/16

**Role:** Adversarial confirmer (fresh eyes; did not fix). Assumes still broken.
**Branch:** `ui/fix-rulings` (verified `git branch --show-current`; READ-ONLY except this file; no checkout/commit/push/merge; never touched `71983229`).
**Fixes under test (fixer claims):** (D1) shell search icon scoped to Floor+Jobs / Today+Jobs only (Queue/Review/etc + Productivity/Profile show none); (D2) detail task sheet retitled `Search tasks` with new ARB keys en+ar; (D4) Today no-match has Clear; (D3) result-tap dismisses (no extra close tap — rebuttal with migration note). 112 tests green claimed.
**Governance:** DESIGN_SPEC C16 (any hard-reject caps 10/16) + C17 U0–U14 (any violated law caps 8/16). Pass ≥12/16 with caps.
**Read first:** `evaluation/adversarial-search-relocation-staff.md` (wave-1 FAIL 8/16, D1/D2/D4 gating + D3 taps), `evaluation/supervisor-jobs-list-test-migration.md` §Scope-unification + §D1/D3 close-out, `evaluation/supervisor-home-test-migration.md` §Scope-unification, `evaluation/technician-home-test-migration.md` §Scope-unification + Jobs-addendum, `evaluation/technician-detail-test-migration.md` (all, incl. §D2/D3 close-out).
**Images viewed (full resolution, Read):**
- `after-technician-job-detail/detail_search_open_en_360x800.png` — sheet `Search tasks` + field `oil` → 1 row `Change engine oil / Completed`.
- `after-supervisor-jobs/search_light_1.0_en_360x800.png` — sheet `Active jobs` + field `sara` → 1 row `Civic DEF 9012 / JC-102 Sara`.
- `after-technician-home/today_search_open_en_360x800.png` — sheet `Search jobs` + 3 jobs (empty query).
- `after-supervisor-home-current/sv_home_en_1.0_360x800.png` — shell `Floor | magnifier | bell | S`; page `Workshop floor / 4 active · 16 bays` has NO page icon.
- `after-supervisor-jobs/idle_light_1.0_en_360x800.png` — tab-alone crop (starts `Active jobs`; no shell in frame); rail wraps, no inline field.
- `after-technician-home/today_1.0_en_360x800.png` — tab-alone crop (starts `Today / Morning shift · Working`); NO page icon; no shell in frame.
**Code read (read-only, attribution):** `supervisor_scaffold.dart:_SupervisorChrome` guard + `_openSearch:95-117`; `technician_dashboard_view.dart:_TechChrome` guard + `_openSearch:78-86`; `technician_today_view.dart:_TodayHeader` (no glyph) ; `supervisor_dashboard_tab.dart:_FloorHeader` (no glyph); `supervisor_jobs_tab.dart` (no `AppSearchField`, rail only); `technician_task_search.dart:title:19,hint:74,_results:47-53,onSelect-pop:123-127,Clear:106-112`; `technician_today_search.dart:title:18,Clear-no-match:117-123,pop:135-139`; `supervisor_register_search.dart:title:21,pop:107-112,Clear:90-98`; `job_detail_sheet.dart:onSearch:145-168`; `app_en.arb`/`app_ar.arb` task keys + gen diff; `technician_task_search_test.dart:89-106,108-125`.
**Tests run (read-only, no `--update-goldens`):** `flutter test test/technician_task_search_test.dart` → 3/3 PASS; `flutter test --exclude-tags baseline` in `apps/staff_app` → **112/112 PASS** (fixer 112-green claim VERIFIED; Hive/remote warning logs are caught+logged fakes, not failures).

## Verdict: PASS — 15/16 (no caps apply)

Merit 15/16, C16 no cap (taps tie per brief budgets), C17 no cap (no U-law fail) → **final 15/16 — PASS**.
D1/D2/D4 fixer claims VERIFIED (D4 code-only, pixel-unproven — see N1); D3 rebuttal HOLDS per brief tap definition (see D3 note). No NEW gating items found (strict hunt below).

## Ranked defect list (gating first — none gating)

### GATING — none. All wave-1 gating defects close.

- **D1 [WAS GATING, NOW FIXED — PASS]:** shell icon scoped Floor+Jobs / Today+Jobs only.
  - **Code:** `_SupervisorChrome` now `if (selectedIndex == 0 || selectedIndex == 1)` (was unconditional) — nav map `_items:42-78` confirms 0=Floor, 1=Jobs, 2=Queue, 3=Review, 4=Reports, 5=Staff, 6=Schedule; Queue/Review/Reports/Staff/Schedule (+More overflow) render NO icon. `_TechChrome` now `if (selectedIndex == 0 || selectedIndex == 1)` — `_pages:71-76` confirms 0=Today, 1=Jobs, 2=Productivity, 3=Profile; Productivity/Profile render NO icon. Tooltips per-tab (`svJobsSearchHint` on Jobs else `svSearchTitle`; `techJobsSearch` both tech tabs — same sheet, correct).
  - **Pixels where visible:** Floor `sv_home_en_360x800` shows exactly one magnifier top-right (magnifier→bell→avatar, 56 hairline row) with zero page glyphs — PASS. Detail dim background in `detail_search_open` shows AppBar `[magnifier] + [Synced]` with no other search — PASS. Jobs `idle_light` and Today `today_1.0` are **tab-alone crops** (no shell in frame by harness design) — Jobs/Today shell icons are CODE-ONLY proven, not pixel-proven; Queue/Review/Productivity/Profile have NO frames in the four listed dirs — CODE-ONLY proven. Accept: guards are exact, pattern matches pre-existing `selectedIndex` idiom, characterization `findsOneWidget` pins hold.
  - **Residual (NON-GATING):** `supervisor_scaffold._openSearch:95-117` else-branch still builds the floor sheet for any index — unreachable via UI now (icon hidden on 2+), but dead path remains. Recommend scoping else to floor-only/assert. No user harm.
- **D2 [WAS GATING, NOW FIXED — PASS]:** detail task sheet retitled, distinct entity.
  - **Pixels en:** `detail_search_open_en_360x800` title reads **`Search tasks`** (was `Search jobs` in wave-1) + field `oil` → task row `Change engine oil / Completed` — PASS, byte-distinct from `today_search_open` title `Search jobs` (jobs rows). U9/U10/U13 cured.
  - **Code:** `technician_task_search.dart:19` title `techTaskSearch`, `:74` hint `techTaskSearchHint`, `:89-104` no-match `techTaskNoMatch/Hint` + Clear pill; `app_en.arb`: `techTaskSearch: Search tasks`, `techTaskSearchHint: Search by task name`, `techTaskNoMatch/NoMatchHint`; `app_ar.arb`: `ابحث في مهام الإصلاح / ابحث باسم مهمة الإصلاح / لا توجد مهام إصلاح مطابقة / …تطابق بحثك` — sentence-case en, glossary ar. Gen diff additive only. Test `technician_task_search_test.dart:96` updated to `No matching tasks` — PASS.
  - **Caveat:** no ar `detail_search_open` frame exists (only en 360x800) — ar retitle CODE-ONLY (ARB + gen + delegate wiring verified, no pixel). Acceptable; not a fail.
- **D4 [WAS GATING, NOW FIXED — PASS with pixel/test gap noted]:** Today no-match has Clear.
  - **Code:** `technician_today_search.dart:116-123` no-match column now ends with `AppPillButton.secondary(label: coreT.filterBarClear, onPressed: clear+reset)` — mirrors task/register sheets — U6/U8 live-control restored. PASS.
  - **Gaps (NON-GATING, disclosed):** (a) NO Today no-match frame in `after-technician-home/` (only `today_search_open` empty-query + `today_empty` confirmed-empty, neither exercises the no-match branch) — Clear PIXEL-UNPROVEN; (b) NO behavior test pins the Today Clear (task sheet has `technician_task_search_test.dart:89-106`, register has rewritten characterization, Today has none — harness opens the sheet directly in `technician_home_after_capture_test`). Law satisfied by code path; recommend adding one `enterText zzz → Clear → rows restore` widget test. Not a cap: the violation (no control) is gone on the current code path.
- **D3 [WAS C16-CAPPED, REBUTTAL HOLDS — PASS per brief budgets]:** result-tap dismisses, taps ≤ before.
  - **Code:** all three sheets `pop + onSelect`: register `:107-112`, today `:135-139`, task `:123-127`. Task test pins it (`AppSearchField findsNothing` after select `:118-124`) — 3/3 green verified by run. Floor/Today/detail find = icon (1) + keystrokes + result (1) — ties page-icon path seat-for-seat; Jobs find = icon (1) + keys + result (1, same assign sheet) — ties inline path per the brief's find-definition (find INCLUDES the result tap that opens assign/dossier).
  - **Strict note (accepted cost, documented):** pure-lookup-WITHOUT-select (type → read → close via ×/back without tapping a result) costs +1 dismiss vs the old inline (which narrowed in place). The migration rebuttals (`supervisor-jobs…:192-197`, `technician-detail…:85-89`) define find-with-result as the budget and disclose this; brief tap walks (`supervisor-jobs…:162-167`, detail `…:37-41`) record identical budgets. Under C16 "taps never regress" the budgeted path ties; the unbudgeted peek-and-close pays the unification dismiss. No code fix needed; do not re-litigate without redefining the budget. No cap applied.

## No NEW gating items (strict hunt: U-laws + hard-reject + consistency)

- **Hard-reject sweep:** no new routes (same `showAppModalSheet` seats), no predicate/logic changes (register 4-field `jobCard/customer/vehicle/status`, today `ref/vehicle/customer/plate`, task `description contains` — all verbatim; tab keeps rail-only, header keeps title+subtitle), no ARB renames (task keys additive; gen +48 lines), no provider/sync/route edits. `flutter analyze` per migration notes clean; full `--exclude-tags baseline` run 112/112 green here. No cap.
- **U-law sweep on viewed frames:** U1 locus holds (Floor shell top-right; detail AppBar top-right; sheets full-screen with × + field); U6 calm-empty holds (empty/error/loading + Clear/Retry/Assign preserved; Today no-match Clear added by code); U8 relevance holds (Floor→bays, Jobs→register, Today/Jobs→jobs, detail→tasks; wrong-scope icons removed); U9 consistency holds for the gating instance (two `Search jobs` → `Search jobs` jobs + `Search tasks` tasks — distinct); U10 feedback holds (titles promise what `_results` filters); U13 plain copy holds (sentence-case en, brief verbs); U14 no-regression holds per budgets above. No U-law fail → no 8/16 cap.
- **Truncation/orphan/color:** Jobs idle rail wraps (`All / In progress 1 / Completed 1` + `Parts delay 1` second line, no `Par…` cut — wave-2 D4 stays fixed); row-2 `4/4 tasks` bar success-green (wave-2 D3 stays fixed); floor `Camry ABC 1234` whole; detail result `Change engine oil / Completed` whole. Two pre-existing tolerables unchanged: sv_home rail trailing `Ic…` peek (horizontal-scroll affordance, not mid-word cut) and Today queue `Starts 10:…/11:…` secondary-meta ellipsis (permitted meta). No NEW cut, no red-means-done, no orphan CTA. Non-gating.

## Non-gating nits (process / polish, unscored except −1 merit)

- **N1 (test/pixel gap, the −1):** Today Clear has neither a no-match golden nor a widget test (see D4 gaps). Task + register both pinned; Today is the odd one out. Add one test + one `today_search_nomatch` frame on the next bless. Merit −1 for coverage asymmetry, not for law.
- **N2 (doc staleness):** `supervisor-jobs-list-test-migration.md:169-171` still says "`_SupervisorChrome` always shows the one icon" — true at Scope-unification time, superseded by the D1 guard two sections below (`:185-191`). Harmless (code governs), but the next reader will trip. One-line edit, docs-only.
- **N3 (grammar variance, pre-existing):** four sheet titles now read `Find on the floor` / `Active jobs` / `Search jobs` / `Search tasks` — same sheet pattern, four grammars (U9 tension noted in wave-1 §Consistency). Gating instance (identical title, different entity) is fixed; remaining variance is per-tab scope signaling, not a lie. Leave unless a copy pass unifies verbs.
- **N4 (dead branch):** supervisor `_openSearch` else→floor for 2+ (see D1 residual). Harmless while the icon is hidden; scope or assert to prevent future misuse.

## Consistency cross-check (siblings, read-only)

- Queue/Review tabs keep `search_off` empty art with NO shell icon — art and affordance now AGREE (wave-1 D1 disagreement resolved).
- `supervisor_assign_sheet.dart` inner `AppSearchField` (`svAssignTargetHint`) remains sheet-scoped assign-target lookup (different hint/scope, invisible until Assign) — not counted as a second register path. With D1+D2 fixed the surface has one shell icon + one sheet field per flow; hints/scopes stay distinct.
- Today header + Floor header + Jobs toolbar all title+subtitle/rail only — exactly one visible search path per studied screen (shell-owned), no inline fields anywhere on CURRENT PNGs.

## Airbnb rubric (ONLY after §§above), /16, pass ≥12

| # | Criterion | Score | Why |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Find→assign/dossier coherent on all four; wrong-scope icons gone; D3 ties per budget |
| 2 | Headline-first hierarchy | 2/2 | Vehicle-first → ref+customer → progress → pill holds |
| 3 | Whitespace, no boxes | 2/2 | Borderless divider rows / plain sheets, no cards-in-cards |
| 4 | Sheets for secondary | 2/2 | Sheets correctly used; D2 retitled, D4 Clear present (code) |
| 5 | Sticky CTA | 2/2 | Correctly non-sticky / in-flow only |
| 6 | Section structure | 2/2 | Header+rail+rows clean; scope confusion removed |
| 7 | Plain copy | 1/2 | Verbatim keys + new task keys correct, but N3 four-grammar variance persists |
| 8 | Single primary action | 2/2 | Exactly one filled accent per state |
| **Merit** | | **15/16** | N1+N3 are the −1 (coverage/grammar polish, non-gating) |
| **C16 cap** | taps never regress | **none** | Budgeted paths tie; peek-and-close cost disclosed+accepted |
| **C17 cap** | any U-law fail | **none** | D1 U8/U1, D2 U9/U10/U13, D4 U6/U8 all cured on current code path |
| **Final** | | **15/16 — PASS** | Merit 15, uncapped |

Gating defects: none remaining. N1–N4 are non-gating polish/gaps.

## Answers

- **First-time user in 3s?** Yes on all four studied screens: one magnifier top-right in the shell bar (Floor/Jobs/Today/Jobs/detail), one sheet per scope (`Find on the floor` / `Active jobs` / `Search jobs` / `Search tasks`), one result contract. Off studied screens the promise now holds too (no icon where no list search exists).
- **What would an Airbnb designer reject?** Nothing gating. They would nit the four-grammar sheet titles (N3) and ask for the missing Today no-match frame/test (N1) — in that order. Fix both opportunistically; neither blocks this bless.

*(End — adversarial-wave3-staff-confirm, 2026-10-23, ui/fix-rulings, READ-ONLY except this file.)*
