# ADVERSARIAL CONFIRM — Owner search relocation ruling (a) — PASS

**Role:** Adversarial confirmer (fresh eyes; did not relocate). Branch `ui/fix-rulings`. Repo `E:\syed_moiz_ali\orientmobileapplication`.
**Constraint obeyed:** READ-ONLY except this file. No switch/commit/push/merge. `71983229` untouched.
**Ruling (a) claimed:** owner home search flipped to shell AppBar (unconditional, adjacent bell/avatar); page header title+subtitle+pills only. Single path, same palette, 2 taps, 19 tests green, guard extended to 21 incl 8 locus.
**Scope verified:** CURRENT `docs/ui-redesign/baseline/after-owner-home/` (9 PNGs) + `packages/shared_core/test/app_search_affordance_guard_test.dart` (606 lines) + `apps/owner_app/.../dashboard_body.dart` + `owner_dashboard_page.dart` + `owner_dashboard_characterization_test.dart` + `owner_home_after_capture_test.dart`. Tests re-executed (guard + characterization).

## Verdict: PASS — 9/10, ZERO gating defects

Product relocation is correct. One point deducted for guard/claim weaknesses (non-gating, see D1–D3). No new gating item found. Do not block.

## Checks (strict)

### (1) Search icon top-right IN shell AppBar adjacent bell/avatar — PASS
- Pixels (all 9, Read full-res): `home_1.0_en_360x800.png`, `home_1.3_en_360x800.png`, `home_1.0_en_320x568.png`, `home_empty_en_360x800.png`, `home_error_en_360x800.png`, `home_1.0_en_768x1024.png`, `home_1.0_en_1280x800.png` — AppBar row = `Dashboard` left + magnifier + calendar/`This week` + bell + `O` avatar right. `home_1.0_ar_360x800.png` mirrored: `اللوحة` right + magnifier + calendar + bell + `O` left (end-side). `home_search_open_en_360x800.png` dimmed bar shows same cluster behind sheet.
- Code: `dashboard_body.dart:211-243` `_OwnerChrome.actions` = `[search (Icons.search_rounded, tooltip ownerSearchHint, onPressed onSearch → openOwnerSearch), if selectedIndex==0 PeriodDropdown, NotificationBell, UserAvatar]` — unconditional (no `if selectedIndex != 0`), single 56px `AppAppBar`, same `openOwnerSearch` palette + `WorkspaceSearchShortcuts` Ctrl+K kept (`dashboard_body.dart:160-163`).
- Adjacency note: period selector sits between search and bell (icon on phones, `This week` pill on tablets). Same action cluster, same row — "adjacent cluster" holds strictly; not directly neighbour to bell but no separation row.

### (2) Page header shows none — PASS
- Pixels: every frame header = `Executive Operations Control` + `Real-time overview…` subtitle + `Live operations / 12 active / 5 today` pills only. No magnifier, no second row, no inline field in header band.
- Code: `owner_dashboard_page.dart:204-261` `_HomeHeader` = Column[title, subtitle, Wrap pills] — zero `IconButton`/`search_rounded`/`AppSearchField`. Ruling comment at `:196-199` matches pixels.

### (3) Taps ≤ before — PASS (2, unchanged)
- Before (per `owner-home-test-migration.md`): glance 0 / register 1 / approvals tile 1+scroll / shell search→palette→destination 2.
- After (code+test): `owner_dashboard_characterization_test.dart:394-434` `palette search path reaches approvals in two taps` — Tap1 `find.descendant(of: AppAppBar, matching: byIcon(search))` → `Search destinations…`, Tap2 `find.descendant(of: Dialog, text Approvals)` → `at:pendingApprovals`. Finder scoped to `AppAppBar` (was `OwnerDashboardPage` pre-ruling, `AppAppBar`-hidden pre-audit). Same palette/routes/targets, no new route. `owner_home_after_capture_test.dart:367-380` `_openSearch` identical scope. No budget regresses.

### (4) Hunt for NEW gating items — NONE
- 320px / 1.3x: AppBar holds without striped overflow in PNGs (short `Dashboard` title per `dashboard_body.dart:187-193` comment); pills wrap, no mid-word primary cut visible; bottom crops are viewport scroll cuts, not RenderFlex stripes. Harness still tolerates overflow via `_drainExpected` — silent by design, but no stripe visible to contradict.
- Empty/error: `home_empty…` / `home_error…` keep shell search + header-no-search, honest states (`No figures yet.`, `Could not load the latest figures` + Retry) intact.
- Tablet 768/1280: rail + `This week` pill + bell/avatar all whole, charts/cards intact, no clipping.
- Search-open: `Search destinations…` + `Dashboard/Top sales/Messages/Activity` rows — same command-palette contract (Approvals below fold, proven by characterization Tap2).

### Shared guard — asserts locus, passes 21/21 — VERIFIED
- Run 2026-10-23: `packages/shared_core` `flutter test test/app_search_affordance_guard_test.dart` → `+21: All tests passed!` (13 count + 8 locus + 1 negative = 21; file groups: 5 en + 3 ar + 3 vehicles + 1 matrix + 8 locus + 1 negative).
- Locus helper `_expectTopEndLocus` (`:95-152`) asserts: (i) exactly one `Icons.search_rounded`, (ii) `dy < 35%h` (first header band), (iii) end-side (`dx>50%w` LTR / `<50%w` RTL), (iv) `|dy-titleDy|<48` same-row (stacked-below would be a full text-row lower), (v) ancestor `AppBar OR Row`. All 8 locus tests execute it: shell top-right (`:528-534`), header-row (`:536-542`), advisor (`:544-548`), customer (`:550-554`), vehicles (`:556-562`), ar shell (`:564-572`), ar customer (`:574-582`), 320/1.3x shell (`:584-593`). Strictly position-only, palette/logic untouched.
- Run: `apps/owner_app` `flutter test test/owner_dashboard_characterization_test.dart` → `+10: All tests passed!` (expected `Failed to load dashboard` log in fail-case only). 10 char + 9 after-capture = 19 green as claimed (after-capture goldens not re-run with `--tags baseline` here; PNG mtimes match rebuilt shell).

## Defect list (gating first)

### GATING: NONE
No U/C16/product gate tripped. Single path holds, palette identical, taps 2, locus correct LTR+RTL+extremes.

### D1 [NON-GATING, guard strength] Synthetic shells, not real owner chrome; count group still pins pre-ruling shape
- `app_search_affordance_guard_test.dart:411-414,443-451,496-513` owner count tests use `_specBarHomeShell` (header-kept, shell-hidden) — the pre-ruling shape — while ruling (a) mandates shell-kept. They pass alongside locus shell-kept tests because both synthetics have count 1. The file therefore proves the *contract shape* but cannot fail if real `_OwnerChrome`/`_HomeHeader` regressed; real protection lives in `owner_dashboard_characterization_test.dart:415-419` + after-capture `_openSearch`. Recommend: repoint owner count tests to `_shellSearchHomeShell` or add a real-chrome locus test. Not a product defect.

### D2 [NON-GATING, guard strength] `inAppBar || inRow` is permissive
- `:143-151` any `Row` in the top 35% same-row as title passes, not strictly "header trailing Row". Real code satisfies the strict reading (AppBar cluster), so no pixel failure, but a future mid-page Row at top 35% could slip past. Recommend `find.ancestor` constrained to header/AppBar Row. Merit-only.

### D3 [NON-GATING, claim accuracy] "9 incl. dark" is wrong — 0 dark frames
- `after-owner-home/` holds 9 files, all light: `home_1.0_en_360x800, home_1.0_ar_360x800, home_search_open_en_360x800, home_error_en_360x800, home_empty_en_360x800, home_1.3_en_360x800, home_1.0_en_320x568, home_1.0_en_768x1024, home_1.0_en_1280x800`. No `*dark*`. Harness is light-only by scope (`AppTheme.light`, `owner-home-test-migration.md: owner light-only`, capture header `:11-12`). Task wording "incl. dark" does not match disk. No product impact; fix the claim, not the pixels.

## Score
9/10 — product 10/10 on (1)–(4); −1 for D1+D2 guard weakness and D3 claim error (all non-gating, disclosed above).
