# Adversarial Review — Search Relocation CRM (Ruling a, branch ui/fix-rulings)

**Role:** adversarial confirmer (fresh eyes; did not relocate). Assume ruling (a) is still wrong.
**Branch:** `ui/fix-rulings` (no switch/commit/push performed; `71983229` untouched).
**Ruling under test:** shell AppBar trigger is the SINGLE visible search icon on leads/tasks/team tabs
(contextual per tab, same >5 gate relocated, same sheets); list headers show no search icons.
**Counts:** `after-crm-leads/` 11, `after-crm-tasks/` 8, `after-crm-sales-team/` 9 — confirmed on disk.

## Evidence basis (pixel vs code — stated explicitly)

- **PIXEL (page frames):** harness pumps the page alone, so NO shell chrome is in frame.
  Proof: `apps/crm_app/test/crm_after_leads_capture_test.dart:238`
  `home: const Scaffold(body: CrmLeadsPage())`;
  `crm_after_tasks_capture_test.dart:228` `Scaffold(body: CrmTasksPage())`;
  `crm_after_team_capture_test.dart:221` `Scaffold(body: CrmSalesTeamPage())`.
  Consequence: criteria (1) shell-icon placement **cannot be pixel-verified** from these 28 PNGs.
- **PIXEL (list headers — verified):** inspected via Read:
  leads `leads_idle-6_light_1.0_en_360x800.png` (title row + funnel filter only, top-right;
  no magnifier), `leads_idle-2_light_1.0_en_360x800.png` (no search, no filter),
  `leads_search-open_light_1.0_en_360x800.png` (sheet exists, bg cards dimmed),
  `leads_filter-open_light_1.0_en_360x800.png` (filter sheet, no search in header);
  tasks `tasks_idle-6_light_1.0_en_360x800.png` (refresh + Add only, no magnifier),
  `tasks_idle-2_light_1.0_en_360x800.png` (same), `tasks_search-open_light_1.0_en_360x800.png`
  (sheet `Search tasks` over dimmed list); team `team_idle_light_1.0_en_360x800.png`
  (bare `Leaderboard` header, zero trailing icons), `team_search-open_light_1.0_en_360x800.png`
  (sheet over dimmed board), `team_scrolled_light_1.0_en_360x800.png` (scrolled rows, no header icons).
- **CODE (shell — verified):** `apps/crm_app/lib/features/crm_dashboard/presentation/crm_dashboard_view.dart:284-296`
  (contextual gates), `:297-305` (`WorkspaceAppBar(onSearch: contextualSearch)`),
  `:317-343` (actions = refresh?, `NotificationBell`, `UserAvatar`), `:88-89` (Ctrl+K palette),
  `:200-241` (sheet helpers + STOP); `packages/shared_core/lib/src/widgets/workspace_app_bar.dart:178`
  (`if (onSearch != null) _buildSearchTrigger`), `:211-286` (trigger = `Icons.search_rounded`,
  actions-row position before pill/bell/avatar).
- **CODE (pages — verified):** leads `:117-123` (comment) + `:185-206` (`findAids()` = filter only,
  grep: zero `Icons.search` in page except `search_off` empty icon `:415`);
  tasks `:75-78` + `:122-134` (utilityActions = refresh + Add only);
  team `:62-65` + `:131-173` (`_TeamHeader` = title+subtitle Row, no actions at all).
- **TEST (admission):** `apps/crm_app/test/crm_shell_search_relocation_test.dart:178-190`
  (leads ≤5 expects 0 icons), `:214-225` (tasks ≤5 expects 0), `:246-257` (team ≤5 expects 0);
  `:192-212`, `:227-244`, `:259-276` (>5 expects exactly 1 + sheet opens); `:278-301`
  (non-list tab palette + Ctrl+K).

## Verdicts per criterion

### (1) Search icon top-right IN shell AppBar row adjacent bell/avatar — CONDITIONAL PASS (code-only)
- **CODE: PASS.** `WorkspaceAppBar` renders the trigger as `actions[0]`
  (`workspace_app_bar.dart:177-191`), i.e. in the same trailing row as the offline pill and the
  caller-supplied `actions` (`NotificationBell` + `UserAvatar` from `_CrmChrome:326-343`).
  Icon is `Icons.search_rounded` (`:243`), tooltip carries the shortcut hint.
- **PIXEL: N/A / UNVERIFIED.** All 28 listed PNGs are page-alone frames (see harness lines above);
  no AppBar/bell/avatar pixels exist to measure a region from. No `after-shell-fix/*` frame covers
  the CRM shell. Strict rule: pixel region evidence **missing**.
- Verdict: passes on code, fails pixel proof. Not a ship-blocker alone, but it is why this review
  cannot be a clean PASS.

### (2) EXACTLY ONE visible search path per tab, both ≤5 and >5 — FAIL
- **>5: PASS (pixel + code).** Pixel: idle-6 frames on all three tabs show zero header magnifiers
  (regions cited above); code: shell supplies exactly one non-null `onSearch` per tab
  (`crm_dashboard_view.dart:288-296`), `WorkspaceAppBar` renders exactly one trigger when non-null,
  relocation test asserts `_searchIconCount() == 1` on >5 for all three tabs.
- **≤5: FAIL (by design, test-enshrined).** Code sets `contextualSearch = null` when
  `leadsCount <= 5 || teamCount <= 5 || tasksCount <= 5`, and `WorkspaceAppBar` renders nothing
  when `onSearch == null`. Relocation test *requires* 0 icons on ≤5 (lines cited above) and calls
  it "sanctioned exception". Result: **zero visible search paths** on ≤5 on all three tabs.
  The strict brief wording ("EXACTLY ONE … both ≤5 and >5") is therefore violated 3/3 tabs in the
  small-list state. Carried over from before (same gate relocated), but still a gate against the
  stated criterion.

### (3) Taps ≤ before — PASS (numeric) with functional caveat
- Leads: before = header-search(1) + result(1) + card-tap to dossier(1) = 3;
  after = shell-search(1) + sheet-result(1) → `LeadDetailSheet.show` directly
  (`crm_dashboard_view.dart:212-221`) = 2. **Saves a tap. PASS.**
- Tasks/team: before = header(1) + result(1) + auto-reveal = 2 + reveal;
  after = shell(1) + result(1) + `selectTab` no-op (`:223-241`) + **manual scroll** = 2 taps but
  reveal lost. Taps numerically ≤; function regressed (STOP filed in code comments). **Marginal PASS.**
- 47-test arithmetic holds: 15 (leads char) + 12 (tasks char) + 10 (team char) + 8 (relocation) + 2
  (leads fixer) = 47 `testWidgets`. Green status not re-executed by this reviewer (read-only run
  omitted); count matches claim, pass/fail of each not independently re-proven here.

### (4) Hunt for NEW gating items — FOUND (1 gating, 2 risks)
- See defect list below. No *additional* header gates introduced (filter >5 on leads pre-exists;
  sheets unconditional; Add/refresh untouched).

## Score: 6/16 — Verdict: FAIL (gating)

One strict-criterion gate fails (≤5 zero-path, 3 tabs) + one functional regression (reveal loss on
2 tabs) + pixel proof missing for the shell claim. >5 relocation itself is correctly implemented.

## Ranked defects (gating first)

### G1. ≤5 lists have ZERO visible search paths — gates strict criterion (2)
- **Evidence (code):** `crm_dashboard_view.dart:288-293`
  `leadsCount > 5 ? … : null`, same for team/tasks; `workspace_app_bar.dart:178` hides trigger on null.
- **Evidence (test admission):** `crm_shell_search_relocation_test.dart:187` (`expect(_searchIconCount(), 0)`),
  `:223`, `:255` — same expectation on all three tabs.
- **Evidence (pixel, consistent):** `leads_idle-2…`, `tasks_idle-2…`, `team_idle…` (3-row) frames show
  no header search (correct per gate) — and no shell is in frame to compensate.
- **Why it gates:** strict task demands one visible path in *both* states. Users with 2–5 records lose
  discoverable search entirely (only invisible Ctrl+K palette remains). Either the criterion or the
  gate must change; as written this is a FAIL.
- **Fix:** keep >5 sheet path; add an ungated (or lower-gated) shell trigger on ≤5, or amend the
  criterion to sanction zero-path on ≤5 explicitly.

### G2. Tasks/team shell-result does not reveal the record (auto-scroll lost) — gates function
- **Evidence (code):** `_openTasksSearch:229-230` / `_openTeamSearch:238-240` `onSelect: (_) => notifier.selectTab(4/3)`
  — no-op when already there; comments admit STOP (`:200-211`, tasks page `:59-62`, team page `:45-48`).
- **Pixel:** `tasks_search-open…` / `team_search-open…` sheets list matches; no reveal frame exists.
- **Why it gates (function, not taps):** tap count ties 2=2, but the user pays a manual find+scroll the
  old auto-reveal did. STOP is honestly filed; still a regression vs "same sheets, same targets".
- **Fix:** restore `Scrollable.ensureVisible` via the retained `_scrollKeys` (currently dead-kept) or
  downgrade the claim to "taps equal, reveal manual".

### R1 (risk). Team gate watches a different provider path than the page reads
- **Evidence:** shell `:286` `ref.watch(crmRepositoryProvider).salesTeam.length`; page reads
  `ref.read(crmUiProvider.notifier).salesTeam` (`crm_sales_team_page.dart:56-57`) which snapshots
  `_repository` at notifier `build()` (`crm_ui_provider.dart:69,130`). Same object today, but shell
  rebuilds on provider identity while an in-place `loadAll()` mutation may never change identity →
  stale gate possible. Leads/tasks gates watch their live list providers and do not share this risk.
- **Fix:** gate team on the same watched list the page renders (or selectTab-independent selector).

### R2 (risk). Invisible second functional search path remains on list tabs (Ctrl+K palette)
- **Evidence:** `crm_dashboard_view.dart:88-89` `WorkspaceSearchShortcuts(onSearch: _openSearch)` is
  always mounted; `_openSearch:171-198` opens the omnichannel palette (first-50 leads → dossier),
  distinct destination from the contextual list sheets. Not *visible*, so (2) holds on >5, but two
  functional searches coexist with different semantics — the exact duplication the relocation claims
  to end. Relocation test `:278-301` pins palette on non-list tabs only; list-tab coexistence unpinned.
- **Fix:** rewire the shortcut to the contextual sheet on tabs 1/3/4, or document the duality.

### N1 (non-gating). No pixel proof of shell trigger region adjacent bell/avatar
- Page-alone goldens structurally exclude `DashboardShell.appBar`. Claim rests on code
  (`workspace_app_bar.dart:177-191` + `_CrmChrome:297-343`). Add one shell-level golden
  (pump `CrmDashboardView`, select tab 1/3/4 at >5, crop AppBar trailing row) or mark (1) code-only.
