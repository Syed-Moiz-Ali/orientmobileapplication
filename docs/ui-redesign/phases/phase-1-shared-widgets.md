# Phase 1 — Shared widgets (App* suite + gallery, split 1a–1f)

## 1. Title + Goal
Build every C8 component in `packages/shared_core/lib/src/widgets/` (one file
per App* widget + barrel) plus a debug-only gallery, in six parts. Migrate
zero screens. Old and new UI coexist; nothing existing is replaced or rewired.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any
previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope (all parts)
In scope: NEW files under `packages/shared_core/lib/src/widgets/` (+ barrel),
`gallery/design_system_gallery_screen.dart` (kDebugMode only), widget unit
tests, gallery captures in `docs/ui-redesign/baseline/gallery/`.
Do NOT touch: `apps/*/lib/features/**` screens, `shared_auth`, routing,
providers, ARB files. Additive only — no existing screen or local duplicate
widget is replaced or rewired in phase 1 (adapters come in module phases).

## 4. Design principles
C8 exact specs; C10 states per widget; C12 (48dp, semantics, 1.3x scale, AA);
C13 (tokens only, const, <150-line files). Light default, refined dark.

## 5. Parts (ONE part per session, commit between parts)

- **1a — Gallery shell + capture harness + buttons + successStrong token.**
  Widgets: AppPillButton, AppIconButton, AppTextButton. Plus: gallery shell
  (section nav, light/dark toggle hooks for capture), gallery capture test
  harness (FontLoader fonts + MaterialIcons, shadows on, tagged baseline,
  light+dark × 1.0/1.3 × LTR/RTL), and the `successStrong` token (AA-proof
  filled success — white on #10B981 is 2.54:1, fails; add light+dark darker
  greens verified ≥4.5:1, additive consts only).
- **1b — Inputs.** AppInputField, AppSearchBar, AppDropdown (spec names AppTextField/AppSearchBar/AppDropdownButton; AppInputField renamed for the legacy collision — AppSearchBar/AppDropdown verified free),
  checkbox/switch/radio tiles (AppCheckTile/AppSwitchTile/AppRadioTile or
  one file if small — max ~6 widgets, split further if it overflows).
- **1c — Surfaces & display.** AppCard, AppSection, AppListTile,
  AppSettingsTile, AppDivider, AppAvatar, AppBadge, AppChip, AppStatusChip,
  AppInfoTooltip, AppDataRow (split further if it overflows — ~6 max).
- **1d — Data & feedback.** AppStatTile, AppProgressBar, AppEmptyState,
  AppErrorState, AppBanner, AppSkeleton/AppShimmer, AppLoader,
  AppNetworkImage. ASK BEFORE touching pubspec for `shimmer` or any
  image-cache package.
- **1e — Navigation & overlays.** AppScaffold, AppAppBar, AppBottomNav,
  AppSegmentedControl/AppPillTabs, AppBottomSheet, AppDialog,
  AppSnackBar/AppToast.
- **1f — AppTable + FINAL gallery pass.** AppTable (responsive: real table
  on wide, stacked cards on compact) + full-matrix capture over ALL widgets
  (light/dark × 1.0/1.3 × LTR/RTL), evaluation report, fixes, re-capture.

## 6. Per-part tasks (every part 1a–1f)
1. Implement this part's widgets to exact C8 sizes (button 52/44/36 pill,
   hit areas 48dp, chip h32 pill, etc.), tokens only, caller-supplied text,
   RTL-safe (Directional insets/alignment), Semantics labels, light+dark,
   1.3x-safe, doc comment with usage example.
2. Widget unit tests for states (disabled/loading/error where relevant).
3. Grow the gallery: add this part's widgets; capture PNGs to
   `docs/ui-redesign/baseline/gallery/` (light+dark × 1.0/1.3 × LTR+RTL for
   this part's widgets). VIEW every image, judge against C8/C14, list
   problems, fix, re-capture. Name inspected files; never "looks good"
   without evidence.
4. Re-run the 5 login baselines; list any difference (expected: none).
5. Run `tool/analyze_all.sh` + `tool/test_all.sh` (Git Bash). Report apps
   affected (should be "none visually").
6. Update PROGRESS.md (tick part, session log, next-session note with the
   next part + exact widget list). Stop. Commit message
   `ui(phase-1<part>): <summary>` + `git diff --stat`. No self-commit.

## 7. UX writing rules
Gallery placeholder copy only (sentence case, verb-first buttons). Real copy
comes in phase-9; no new user-facing strings in app code.

## 8. Responsive + accessibility checklist (each part)
Semantics on icon-only buttons/images; visible focus states; 48dp targets;
1.3x no overflow at 320px; AA in both themes; reduced-motion honored;
no information by color alone (chip = dot + label).

## 9. QA checklist (each part, pass/fail)
- [ ] This part's widgets match C8 (sizes, states, radii, motion)
- [ ] Tokens only (grep: no `Color(0x`/`Colors.`/raw sizes/hardcoded strings)
- [ ] RTL-safe widgets, 48dp targets, semantics labels
- [ ] Light + dark gallery OK at 1.0 and 1.3, LTR + RTL
- [ ] Widget unit tests green (states covered)
- [ ] 5 login baselines still match (diffs listed)
- [ ] `tool/analyze_all.sh` + `tool/test_all.sh` green; UI-only diff

## 10. Definition of done (whole phase)
All 1a–1f ticked, gallery complete, full-matrix evaluation report written,
PROGRESS module row updated, commit per part, suggest tag `ui-phase-1-done`.

## 11. Ask me first
Icon set (stay Material — decided), `cached_network_image` vs hand-rolled,
`shimmer` pubspec addition (1d), `AppTable` desktop interactions,
anything ambiguous in C8 sizes.
