# Adversarial Confirm — Wave 3 CRM (R1 team-gate fix, branch ui/fix-rulings)

**Role:** adversarial confirmer (fresh eyes; did not fix). Assumed still broken; verified strictly.
**Branch:** `ui/fix-rulings` (no switch/commit/push/merge performed; `71983229` untouched).
**Fix under test (fixer claims):** (R1) team shell gate now reads the SAME provider/selector the page renders
(`crmUiProvider.notifier.salesTeam`); leads/tasks gates verified already-aligned (no change).
47 tests green claimed (incl. 8 relocation tests). Everything else stands as previously confirmed.
**Working tree evaluated:** uncommitted changes on `crm_dashboard_view.dart` + team/leads/tasks pages + tests
(HEAD `b8c7e067` still has pre-ruling `shellSearchOnLeads`; all ruling-(a) code below is working-tree).

## Evidence basis (pixel vs code — stated explicitly)

- **PIXEL (page frames — verified by Read):**
  - leads `leads_idle-6_light_1.0_en_360x800.png` (6 leads, header row: title + funnel filter only, no magnifier;
    second header row: kanban toggle + Add Lead) — header zero search confirmed.
  - leads `leads_idle-2_light_1.0_en_360x800.png` (2 leads, same header, no search/filter) — ≤5 header zero confirmed.
  - leads `leads_search-open_light_1.0_en_360x800.png` (sheet `Search leads` over dimmed list) — sheet exists.
  - tasks `tasks_idle-6_light_1.0_en_360x800.png` / `tasks_idle-2_light_1.0_en_360x800.png`
    (header: title + refresh + Add Task only, no magnifier in either state) — header zero both states confirmed.
  - tasks `tasks_search-open_light_1.0_en_360x800.png` (sheet `Search tasks` over dimmed list) — sheet exists.
  - team `team_idle_light_1.0_en_360x800.png` (bare `Leaderboard` header, zero trailing icons) — header zero confirmed.
  - team `team_compare-4_light_1.0_en_360x800.png` (4 rows, bare header) — 4-row ≤5 header zero confirmed.
  - team `team_search-open_light_1.0_en_360x800.png` (sheet `Search team`, 6 rows) — sheet exists.
  - Page-alone harness (proof: `crm_after_leads_capture_test.dart:238`, `crm_after_tasks_capture_test.dart:228`,
    `crm_after_team_capture_test.dart:221` all pump `Scaffold(body: <Page>())`) — **no shell AppBar in frame**,
    so shell trigger counts/regions **cannot be pixel-verified** from these PNGs. No `after-shell-fix/*`
    frame covers the CRM shell (only `sv_floor` / `tech_today` there).
- **CODE (gates — verified):**
  - shell `crm_dashboard_view.dart:284-285` leads/tasks gates; `:291` team gate; `:292-301` contextual branches;
    `:302` `WorkspaceAppBar(onSearch: contextualSearch)`; `:88-89` Ctrl+K palette; `:212-241` sheet helpers + STOP.
  - leads page `crm_leads_page.dart:110` `totalLoaded = ref.watch(crmLeadProvider).length`; `:123`
    `showFilterAid = totalLoaded > 5`; `:185-206` `findAids()` = filter only.
  - tasks page `crm_tasks_page.dart:72` `tasks = ref.watch(crmTaskProvider).tasks`; `:122-134`
    `utilityActions()` = refresh + Add only.
  - team page `crm_sales_team_page.dart:56-57` `ref.read(crmUiProvider.notifier)` + `.salesTeam`;
    `:131-173` `_TeamHeader` title+subtitle only, zero actions.
  - provider `crm_ui_provider.dart:69,130` notifier snapshots `_repository` at `build()`, exposes
    `salesTeam => _repository.salesTeam`; leads `crm_lead_provider.dart:14-17,34-53` (invalidateSelf on mutate);
    tasks `crm_task_provider.dart:18-21,25-28` (invalidateSelf on mutate).
- **TESTS (verified by Read, not re-executed):**
  - `crm_shell_search_relocation_test.dart:178-190` (leads ≤5 expects 0), `:214-225` (tasks ≤5 expects 0),
    `:246-257` (team ≤5 expects 0); `:192-212`, `:227-244`, `:259-276` (>5 expects exactly 1 + sheet opens);
    `:278-301` (non-list palette + Ctrl+K).
  - char tests pin header-zero: leads `:177-178,281-282,296` (`Search leads` findsNothing, filter only on >5);
    tasks `:160,242,252` (`Search tasks` findsNothing); team `:199,216` (`Search team` findsNothing).
  - counts: 15 leads-char + 12 tasks-char + 10 team-char + 8 relocation = 45; +2 fixer-pinned = 47 claimed.
    Arithmetic holds; green status not independently re-executed by this read-only reviewer.

## Verdicts per criterion

### (1) Gate/list alignment per tab — PASS (all three)
- **Leads PASS.** Shell `:284` `ref.watch(crmLeadProvider).length` vs page `:110`
  `ref.watch(crmLeadProvider).length` — identical provider + selector (raw loaded list, `.length`).
  Page renders `_visibleLeads(filteredLeads)` but gates on raw `totalLoaded` by design (same `>5` predicate).
- **Tasks PASS.** Shell `:285` `ref.watch(crmTaskProvider).tasks.length` vs page `:72`
  `ref.watch(crmTaskProvider).tasks` — identical provider + `.tasks` selector.
- **Team PASS (R1 literal).** Shell `:291` `ref.watch(crmUiProvider.notifier).salesTeam.length` vs page
  `:56-57` `ref.read(crmUiProvider.notifier).salesTeam` — identical provider (`crmUiProvider.notifier`)
  + identical selector (`.salesTeam`) + identical `>5` predicate. The cited stale-source defect
  (`crmRepositoryProvider` watch vs notifier snapshot) is gone from the gate; grep confirms zero remaining
  `crmRepositoryProvider` watches in the shell gate path.
- **Caveat (non-gating, aligned-stale):** `watch(notifier)` vs `read(notifier)` share the same snapshot
  semantics — neither subscribes to team-data change by itself (notifier identity is stable; `_bump`
  changes state, not identity). Both sides refresh via parent `CrmDashboardView` rebuild
  (`ref.watch(crmUiProvider)` state incl. `selectTab`/`revision`), so they stay aligned-stale together.
  Leads/tasks gates are live (`invalidateSelf` on mutate) while the team gate rides the parent rebuild —
  a reactivity asymmetry, but NOT a misalignment under the claimed criterion.

### (2) ≤5 zero icons / >5 exactly one — CONDITIONAL PASS (code+tests pass, pixel partial)
- **Code PASS.** `contextualSearch = count > 5 ? … : null` on all three tabs (`:294,296,298`);
  `WorkspaceAppBar` renders exactly one trigger when non-null, none when null. Headers render zero search
  icons in both states (leads filter-only/gone, tasks refresh+Add only, team bare header — lines cited above).
- **Tests PASS.** Relocation test pins 0 on ≤5 (3 tabs) and exactly 1 + sheet-opens on >5 (3 tabs);
  char tests pin header-zero on both states (9 assertions cited above).
- **Pixel PARTIAL (headers pass, shell N/A).** Page frames confirm header-zero on ≤5 AND >5 on all three tabs
  (regions cited in Evidence). Shell trigger counts cannot be pixel-verified — page-alone harness excludes
  `DashboardShell.appBar` by construction. Strict rule: shell half of this criterion rests on code+tests only.
- **Note on prior G1:** the old "EXACTLY ONE in both states" wording made ≤5-zero a gate; the CURRENT task
  explicitly sanctions `≤5 zero / >5 exactly one`, so ≤5-zero is PASS here, not a defect.

### (3) Taps ≤ before — PASS (numeric) with functional caveat
- **Leads PASS (saves a tap).** Before = header-search(1) + result(1) + card-tap to dossier(1) = 3;
  after = shell-search(1) + sheet-result(1) → `LeadDetailSheet.show` directly (`:212-221`) = 2.
- **Tasks/team MARGINAL PASS (2 = 2, reveal lost).** After = shell(1) + result(1) + `selectTab` no-op
  (`:223-241`) = 2 taps; manual scroll replaces the old auto-reveal. Tap budget holds numerically;
  function regressed (STOP honestly filed in `:200-211`, tasks page `:59-62`, team page `:45-48`).
  Not a tap-count gate; carried as caveat R2 below.

### (4) Hunt for NEW gating items — PASS (none found)
- Grep `apps/crm_app/lib`: only three `> 5` gates exist, all in the shell (`:294,296,298` — the relocated
  predicates, not new logic). Only other `> 5` is the pre-existing leads filter aid (`crm_leads_page:123`).
  Zero `Icons.search` in any list page except `Icons.search_off_rounded` empty-icon (`crm_leads_page:415`).
  No new `showSearch`/`showFindAids` flags (team header params deleted), sheets open unconditionally,
  Add/refresh/`isNotEmpty` empty-guards are pre-existing header-XOR-empty pattern, unchanged.

## Score: 14/16 — Verdict: PASS (conditional, caveats carried)
- (1) 4/4 aligned; (2) 3/4 (code+tests full, shell pixel N/A); (3) 3/4 (numeric holds, reveal caveat);
  (4) 4/4 no new gates. No gating defect under the current task criteria. R1 is confirmed fixed literally.

## Ranked defects (gating first — none gating under current criteria)

### GATING: none
- No gate fails (1)–(4) as worded in this task. Prior wave's G1 (≤5 zero-path) is sanctioned by the
  current criterion; prior G2 (reveal loss) is tap-neutral and STOP-documented, hence a caveat, not a tap gate.

### R1 (residual, was the fixer target — now caveat, not gate). Team gate + page share snapshot staleness
- **Evidence:** shell `:291` `ref.watch(crmUiProvider.notifier).salesTeam.length` (watch on stable notifier
  identity — does not subscribe to data change); page `:56-57` `ref.read(...).salesTeam` (same snapshot);
  notifier `crm_ui_provider.dart:69` captures `_repository` via `ref.read` at `build()`.
- **Why not gating:** both sides read the identical object through the identical selector, so they cannot
  disagree with each other — the claimed fix holds literally. Refresh flows through the parent
  (`CrmDashboardView` watches `crmUiProvider` state; `selectTab`/`_bump` rebuilds chrome + pages together).
- **Residual asymmetry to watch:** leads/tasks gates self-invalidate (`invalidateSelf` on every mutate);
  the team gate only refreshes on parent rebuild. A rapid repo mutation with no ui-state bump could leave
  the team tab stale one frame longer than leads/tasks. Fix if ever hit: dedicated reactive team selector
  (e.g. watch a team list provider) for BOTH gate and page together — never split them again.

### R2 (carried functional caveat, not new). Tasks/team shell-result loses auto-reveal
- **Evidence:** `_openTasksSearch:229-230` / `_openTeamSearch:238-240` `onSelect: (_) => notifier.selectTab(4/3)`
  — no-op when already there; STOP comments (`:200-211`, tasks `:59-62`, team `:45-48`); retained-but-dead
  `_scrollKeys` in both pages. Sheets list matches (pixel-confirmed) but no reveal frame exists.
- **Why not gating here:** tap count ties 2 = 2, satisfying criterion (3) numerically. User cost is a manual
  find+scroll the old path automated. Either restore `Scrollable.ensureVisible` via the retained keys or
  keep the STOP and the ≤ claim as-is (current state: honest but degraded).

### R3 (carried duality, pre-existing). Invisible second search path (Ctrl+K palette) coexists on list tabs
- **Evidence:** `crm_dashboard_view.dart:88-89` `WorkspaceSearchShortcuts(onSearch: _openSearch)` always mounted;
  `:171-198` palette over first-50 leads → dossier, distinct from contextual sheets. Relocation test `:278-301`
  pins palette on non-list tabs only; list-tab coexistence unpinned.
- **Why not gating:** invisible, so criterion (2) visible-count holds. Fix: rewire the shortcut to the
  contextual sheet on tabs 1/3/4, or document the duality.

### N1 (non-gating). No pixel proof of shell trigger region adjacent bell/avatar
- Page-alone goldens structurally exclude `DashboardShell.appBar`. Claim rests on
  `workspace_app_bar.dart:177-191` (trigger as `actions[0]`) + `_CrmChrome:302-348`
  (`NotificationBell` + `UserAvatar`). Recommend one shell-level golden (pump `CrmDashboardView`,
  select tab 1/3/4 at >5, crop AppBar trailing row) or keep (1)–(2) shell halves marked code-only.
