# Jobs-Search Single-Affordance Audit Review — ui/integration-1 (fresh reviewer) — PASS, 16/16

**Role:** FRESH REVIEWER for the technician Jobs-tab single-search fix + supervisor STOP adjudication. Did not build it. READ-ONLY except this file. No branch/commit/push. Never touched `71983229`.
**Branch:** `ui/integration-1` (fix landed, uncommitted).
**Governance (all gate):** REDESIGN MANDATE (PROGRESS.md rule 13) + C16 hard-reject (any violation caps at 10/16; one path per task) + U0–U14 C17 (DESIGN_SPEC ~lines 489–546; any violated law caps at 8/16, no exceptions). Pass ≥ 12/16 with caps.
**Read first:** DESIGN_SPEC C16 (~495–510) + C17 (~512–541); `docs/ui-redesign/evaluation/technician-home-test-migration.md` §Behavior assertions + Addendum (2026-10-22 Jobs-tab single-search audit).
**Scope (narrow fix review, NOT a full home re-audit):** this file scores ONLY the jobs-search change — technician inline-field removal + supervisor STOP. All full-home verdicts stand as previously recorded and are not re-opened here.

**Context (given, verified against code in §1):** audit found the technician Jobs view showed an inline `AppSearchField` AND a header search icon opening the SAME target (same 5-field predicate over `allJobs`) → inline field removed presentation-only (toolbar keeps `AppFilterBar` rail; providers/sheet/routes untouched). Supervisor Jobs tab keeps BOTH (bar search over `SupervisorBay` vs inline filter over `AssignedJobEntity` — genuinely different targets, STOP, not collapsed). Owner/advisor/customer jobs surfaces each show exactly one affordance.

---

## (1) VERIFY — technician inline removal kept all behavior (code evidence, read-only)

**Inline field is gone from the Jobs toolbar, filter rail intact:**
- `technician_jobs_view.dart:225-243` — `_JobsToolbar.build` returns a `Column` whose ONLY child is `AppFilterBar` (options = `filterOptions` minus `All`, live `counts` keyed by localized All + per-status, `countSemantics` via `techJobsFilterSemantics`, `onSelected` → `notifier.updateFilter`). No `AppSearchField`, no `SizedBox` spacer, no controller, no `onChanged` wiring remains in this file (grep: zero `AppSearchField` hits in `technician_jobs_view.dart`; the only remaining `AppSearchField` in the technician widgets dir is the sheet's own at `technician_today_search.dart:82`).
- Sort/order untouched: `technician_jobs_view.dart:52` still renders `_urgentFirst(notifier.filteredJobs)`; `_urgentFirst` (`:98-109`, delayed 0 / inProgress 1 / pending 2 / qcReview 3 / completed 4) verbatim. Filtered list still flows through the same `filteredJobs` getter.

**Predicate/routes intact (providers/sheet/chrome frozen as claimed):**
- Provider predicate verbatim: `technician_providers.dart:150-163` — `filteredJobs` matches `jobCardNo` / `vehicleBrand` / `vehicleModel` / `customerName` / normalized-plate (`_normalizedPlate`, `:165-166`), plus `selectedFilter` gate (`:160-161`). `updateSearch` (`:592-594`, lowercases on write) and `updateFilter` (`:606-608`) and `filterOptions` (`:134-141`) all still present, untouched.
- Sheet predicate identical: `technician_today_search.dart:51-64` — same five fields (`jobCardNo` / `vehicleBrand` / `vehicleModel` / `customerName` / `_normalizedPlate` both sides), same case-insensitive contains, same `allJobs` scope (caller passes `notifier.allJobs`). The only mechanical difference is lowercasing at read-time (`_query.trim().toLowerCase()`) vs the provider's write-time lowercasing — behaviorally identical for the same input. Same scope, same fields, same normalization: the "SAME target" premise of the audit holds, so collapsing to one affordance loses nothing.
- Same route/dossier contract both ends: Jobs-row tap `_openJob` (`technician_jobs_view.dart:186-194`: `openJob` + `push(technicianJobDetail)` + `closeJob` on complete) vs search-result tap in the shell (`technician_dashboard_view.dart:287-295`: identical `openJob` + `push(technicianJobDetail)` + `closeJob`). No new routes, none dropped.
- Header icon opens the same sheet: `_TechChrome` (`technician_dashboard_view.dart:364-369`) renders `AppIconButton(Icons.search_rounded, tooltip: techJobsSearch, onPressed: onSearch)` whenever `selectedIndex != 0` (Jobs tab is index 1 → icon present on the Jobs tab); `onSearch` = `_openSearch` (`:78-86`) → `showTechnicianTodaySearch(jobs: notifier.allJobs, onSelect: _openJobDetail)`. Today tab (index 0) keeps its own in-page header search over the same sheet per the migration doc, and the bar trigger stays hidden there (`selectedIndex != 0` guard) — so neither tab shows two search icons after the fix.

**Non-gating residue (recorded, not counted):** `state.searchQuery` is still read for the `filtering` flag (`:59`) and `updateSearch('')` is still called by the no-match Clear (`:153-156`) alongside `updateFilter('All')`. With the inline field gone, `searchQuery` can never become non-empty via UI, so the search branch of `filtering` is dormant and that half of the Clear is a harmless no-op reset. This is the instructed trade-off ("providers frozen", migration addendum says so explicitly) — zero user-visible effect, keeps the change presentation-only and reversible. Not a gating item.

**Result §1: PASS** — removal is presentation-only exactly as claimed; filter/sort/search behavior preserved (predicate, options, counts, ordering, routes, sheet all intact).

---

## (2) ADJUDICATE — supervisor STOP (keep BOTH affordances): UPHELD, legitimate non-collapse

The STOP claims the supervisor Jobs tab's two search surfaces have genuinely different targets. Verified from code — they differ in entity, scope, fields, AND result contract:

| Dimension | Bar search (shell icon) | Inline filter (Jobs tab) |
|---|---|---|
| Entity | `List<SupervisorBay>` — derived presentation model (`supervisor_components.dart:24-60`: bay number/state/ref/title/subtitle/techInitials/meta) | `List<AssignedJobEntity>` — raw register records (`supervisor_entities.dart:127-145`: jobCard/customer/vehicle/dateAssigned/done/total/status) |
| Scope | Floor-wide 16-bay board derived from THREE sources (`supervisor_scaffold.dart:92-105`: `buildSupervisorBays(awaiting, jobs, bookings)` — includes QC-awaiting, assigned jobs, queued bookings, plus idle bays) | Jobs register only (`supervisor_jobs_tab.dart:29`: `notifier.jobs`) — no bookings, no QC-awaiting records, no idle bays |
| Predicate | 3-field bay lookup: `bayCode` / `ref` / `title` (`supervisor_floor_search.dart:47-55`), hint `svSearchHint`, no-match `svFloorNoMatch` | 4-field register filter: `jobCard` / `customer` / `vehicle` / `status` (`supervisor_jobs_tab.dart:31-42`), hint `svJobsSearchHint`, no-match `svJobsNoMatch` + status-bucket rail |
| Result contract | Bay tap → assign sheet (`_openSearch` onSelect → `showSupervisorAssignSheet`; floor tab `_onBayTap` → same sheet) | Register row (display; status rail + progress); empty-state action → assign sheet. Different destination semantics |
| Visibility guard | Bar icon renders only OFF the floor tab (`supervisor_scaffold.dart:401`: `selectedIndex != 0`; floor tab owns its own header search at `supervisor_dashboard_tab.dart:247`) — floor home never shows two icons | Inline field lives only inside the Jobs tab body (`supervisor_jobs_tab.dart:90-93`) |

C16 "one path per task" fires only when two affordances serve the SAME task over the SAME target. Here the tasks differ (floor-wide bay lookup incl. bookings/idle bays vs register filtering incl. status text), the entities differ (`SupervisorBay` vs `AssignedJobEntity`), and 3 of 4+ predicate fields differ. Collapsing would LOSE scope either way: pointing the Jobs inline at bays would drop status-text search and the status rail's meaning; pointing the bar icon at `AssignedJobEntity` would hide bookings, QC-awaiting records, and idle bays from floor search. The addendum's "genuinely different targets" claim is accurate.

Co-visibility is also not a violation: on the Jobs tab the bar icon (floor-bay task) and the inline field (register task) are different tasks, like a global palette next to a list filter — no same-label twins, no duplicate filled CTA.

**Adjudication: STOP UPHELD — supervisor keeps BOTH, correctly NOT collapsed. No unification required.** Any future reviewer re-proposing collapse must show field-level target identity, which does not exist today.

Spot-check of the remaining surfaces (task premise confirmed): owner register shows inline `AppSearchField` + `AppFilterBar` with a count-pill-only app bar (no search icon, `job_cards_list_view.dart:239-251`); advisor jobs page shows inline `AppSearchField` + `AppFilterBar` under a title/count row with no second search icon on that page (`advisor_jobs_view.dart:156-221`); the advisor header search icon lives on the home greeting header, a different surface (`advisor_home_view.dart:759-765`). Each jobs surface exposes exactly one search affordance — no further collapses owed.

---

## (3) U1/U7 WALK — technician Jobs view (tap evidence from code paths)

U1 (search: one top affordance → full search, never inline):
- Jobs tab chrome: header search icon present (shell, end-side, `technician_dashboard_view.dart:364-369`), body contains ZERO text fields (toolbar is filter rail only, `:225-243`). Search path count on this surface: exactly 1. PASS.
- Sheet contract: icon tap → `showTechnicianTodaySearch` full-screen sheet (title + `AppSearchField` + `×` clear + no-match `techJobsNoMatch(Hint)`, result tap = dossier push). Same sheet the Today header opens. PASS.

U7 (one path per task; See-all only when more exists than shown):
- Search task: before = inline field (live inline filter) + header icon (sheet) → 2 paths, same predicate/target = violation. After = header icon only → 1 path. PASS (violation cured, nothing else added).
- Filter task: `AppFilterBar` rail only, one chip row, options/counts/selection identical to before (code §1). No second filter UI anywhere on the tab. PASS.
- Open-job task: row tap → dossier (1 tap); search-result tap → same dossier (1 tap + prior sheet open, which is the search task's cost, not a second job-open path — different labels/styling, navigation entries, same accepted pattern as the Today tab). PASS.
- No See-all on this tab (full list shown; queue window/`take(5)` + View-all belong to the Today tab, unchanged). Nothing hidden behind an undisclosed second list. PASS.

Tap table (BEFORE → AFTER, from code paths):

| Task | Before | After | Delta |
|---|---|---|---|
| Find a job by ref/vehicle/customer/plate | inline type (0-tap focus + keystrokes, inline filter) OR header icon → sheet → result tap (1 + keystrokes + 1) — 2 paths | header icon → sheet → type → result tap (**1 + keystrokes + 1**) — 1 path | −1 path (the duplicate); per-path cost unchanged |
| Filter by status | chip tap → `updateFilter` (**1 tap**) | identical (**1 tap**) | ±0 |
| Clear no-match | `Clear filters` → `updateSearch('')` + `updateFilter('All')` (**1 tap**) | identical call, identical cost (**1 tap**) | ±0 |
| Open a job dossier | row tap (**1 tap, 0 scroll**) | identical (**1 tap, 0 scroll**) | ±0 |
| Refresh / freshness | pull-to-refresh + footer (unchanged) | identical | ±0 |

**Tap result: PASS.** No task costs more than before; the most frequent (open job, 1 tap) stays ≤ 2; the duplicate path is deleted, not relocated.

---

## (4) AIRBNB RUBRIC + SCORE (0–2 each, pass ≥ 12/16) — the jobs-search change ONLY

| # | Criterion | Score | Reason (narrow to this change) |
|---|---|---|---|
| 1 | One task per screen | 2/2 | Jobs tab now owns exactly one search path (header icon → sheet) + one filter path (rail). The duplicate same-target entry is deleted; supervisor non-collapse defended in §2 |
| 2 | Headline-first hierarchy | 2/2 | Unchanged by this fix: toolbar deletion removes a mid-column field, filter rail + list + freshness order intact; no title/meta reordering |
| 3 | Whitespace, no boxes-in-boxes | 2/2 | Deletion strictly reduces chrome: rail + `s16` gap + list; no new containers, no nested cards introduced |
| 4 | Sheets for secondary actions | 2/2 | The surviving path IS the spec pattern (full-screen sheet, handle + field + clear + no-match + same dossier contract); sheet/route untouched |
| 5 | Sticky CTA (N/A — jobs list has none) | 2/2 | Correctly absent before and after; counted by omission |
| 6 | Section structure with Show-all | 2/2 | Rail + full list + empty/no-match/error/skeleton states all intact (`:111-178`); See-all correctly absent (nothing hidden) |
| 7 | Plain friendly copy, no invented claims | 2/2 | Zero copy/key changes (addendum claims zero new keys; `techJobsSearch`/`techJobsNoMatch(Hint)`/`techJobsClearFilters` reused verbatim on both surviving surfaces) |
| 8 | Single emphasized primary action | 2/2 | No filled CTA added or duplicated; rows stay ghost/navigation entries; empty/error single actions unchanged |
| **Merit total** | | **16/16** | Pass on merit (≥12) |
| **C16 cap** | ANY hard-reject caps at 10/16 | **none** | Duplicate path removed (was the C16 exposure); no new duplicate, no second accent, no permanent pill, no ALL CAPS, no badge/label duplication |
| **U-cap** | ANY violated law caps at 8/16 | **none — U1/U7 PASS** | §3 walk: U1 single path verified, U7 no duplicate verified; remaining U-laws out of this fix's scope per the narrow-review instruction (full-home verdicts stand) |

**Verdict: PASS — bless the technician Jobs-tab single-search fix. 16/16 (merit 16/16, caps none).**
**STOP adjudication: UPHELD — supervisor keeps BOTH affordances (different entity + fields + scope + result contract); no unification required.**
**Gating items for this change: NONE.** Non-gating notes (not re-gated here): (a) dormant `searchQuery` read + no-op `updateSearch('')` half of Clear — intentional provider-freeze residue, zero user-visible effect; (b) full-home verdicts (technician/supervisor/owner/advisor/customer) stand untouched — this review neither re-audits nor re-opens them.

---

## RETURN (as instructed)

- **Verdict: PASS**
- **Score: 16/16** (merit 16/16; C16 cap none; U-cap none on the walked laws U1/U7)
- **STOP adjudication: UPHELD** — supervisor Jobs tab correctly keeps BOTH search surfaces; bar search (`SupervisorBay`: bayCode/ref/title over floor-wide awaiting+jobs+bookings incl. idle bays → assign sheet) vs inline filter (`AssignedJobEntity`: jobCard/customer/vehicle/status over the jobs register) are different entity + fields + scope + result contract, so C16 one-path-per-task does not fire and collapse would lose scope. No unification required.
- **Gating items: NONE.**
