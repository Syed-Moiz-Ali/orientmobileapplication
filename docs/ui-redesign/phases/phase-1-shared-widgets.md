# Phase 1 — Shared widgets (App* suite + gallery, split 1a–1f)

## 1. Title + Goal
Build every C8 component in `packages/shared_core/lib/src/widgets/` (one file
per App* widget + widgets barrel) plus a debug-only gallery. Migrate zero
screens. Old and new UI coexist; nothing existing is replaced or rewired.

Naming rule (applies to every part): verify each widget name is free first
(legacy names often collide — e.g. `AppButton`, `AppTextField`,
`AppSearchField`, `AppDropdownButton`). On collision, build alongside under a
distinct spec-style name and record the rename path to the spec name in code
docs, DESIGN_SPEC, DESIGN_SYSTEM and PROGRESS. The polish phase renames to
spec names in one codemod once legacy widgets hit zero usages.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any
previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope (all parts)
In scope: NEW files under `packages/shared_core/lib/src/widgets/` (+ barrel),
`lib/src/gallery/design_system_gallery_screen.dart` (grows per part),
gallery captures in `docs/ui-redesign/baseline/gallery/`, widget unit tests.
Do NOT touch: `apps/*/lib/features/**` screens, `shared_auth`, routing,
providers, ARB files. Additive only — no existing screen or local duplicate
widget in any app is replaced or rewired. `INPUT_INVENTORY.md` and
`WIDGET_MIGRATION_MAP.md` (1f) are the handoff docs for module phases.

## 4. Design principles
C8 exact specs; C10 states per widget; C12 (48dp, semantics, 1.3x scale, AA);
C13 (tokens only, const, <150-line files); standing order 4 (widget contract).

## 5. Parts (ONE part per session, commit between)

- [x] **1a — buttons + harness.** AppPillButton, AppIconButton, AppTextButton
  + successStrong token + gallery shell + capture harness. DONE (09de7a7e).
- [x] **1b — inputs.** AppInputField, AppSearchBar, AppDropdown,
  AppCheckTile/AppSwitchTile/AppRadioTile + inputBorder token +
  INPUT_INVENTORY.md. DONE (5e43e050).
- [ ] **1c-i** — AppCard, AppSection, AppListTile, AppSettingsTile,
  AppDivider, AppDataRow.
- [ ] **1c-ii** — AppAvatar, AppBadge, AppChip, AppStatusChip, AppInfoTooltip.
- [ ] **1d-i** — AppStatTile, AppProgressBar, AppEmptyState, AppErrorState,
  AppBanner.
- [ ] **1d-ii** — AppSkeleton/AppShimmer, AppLoader, AppNetworkImage.
- [ ] **1e-i** — AppScaffold, AppAppBar, AppBottomNav (+ NavigationRail
  variant), AppSegmentedControl/AppPillTabs.
- [ ] **1e-ii** — AppBottomSheet, AppDialog, AppSnackBar/AppToast.
- [ ] **1f** — AppTable (responsive) + FULL gallery evaluation pass over ALL
  phase-1 widgets + WIDGET_MIGRATION_MAP.md + DESIGN_SYSTEM component
  catalog update.

If any part turns out too big in its own session, split it further
(e.g. 1d-ii-a / 1d-ii-b), record it in PROGRESS, and tell the user.

## 6. Specs per part (normative for each session)

### 1c-i — surfaces & structure
- AppCard: border OR shadow, never both (C5). Dark = border + surface lift,
  no shadow. Tappable variant with ripple, whole card >= 48dp, optional
  chevron. Never nest a bordered card in a bordered card; show the allowed
  nesting (surfaceAlt block inside a card) in the gallery.
- AppSection: titleMedium heading, optional "See all" ghost action, optional
  subtitle, 12 gap.
- AppListTile / AppSettingsTile: min height 56, leading 40px circle,
  whole-row tap target, trailing variants (chevron/switch/value), inset
  dividers mirror in RTL.
- AppDivider: hairline, inset variants.
- AppDataRow: label at start, value at end, tabular figures, wraps correctly
  at text scale 1.3 and with long Arabic text; numbers stay Western digits
  and LTR inside RTL.

### 1c-ii — identity & status
- AppStatusChip: dot + short human label on a soft fill, AA text contrast,
  meaning never carried by color alone. Variants: success, warning, error,
  info, neutral, accent. Gallery: put success-soft and info-soft side by
  side (the closest pair), print the measured colour difference and judge if
  dot + label are enough.
- AppChip (filter): selected/unselected with AA contrast and a non-color
  selected cue (check icon or weight); 48dp hit area while looking 32dp.
- AppInfoTooltip: works on touch (tap, not hover-only), keyboard focus and
  screen readers; popover radius 12, shadow e2, max width, dismiss on
  outside tap, RTL placement.
- AppAvatar: initials on accentSoft with AA contrast; image fallback;
  sizes 24/32/40/56.
- AppBadge: count cap (99+), contrast, 20px min.

### 1d-i — data & feedback
- AppStatTile: label above value (tabular numbers), optional delta row
  (arrow icon + signed value + semantic color, never color alone, with a
  screen-reader label), 2-column grid friendly, wraps at 1.3x.
- AppProgressBar: 8px, pill, track surfaceAlt, fill with threshold colors
  (accent/success/warning/error), fill vs track >= 3:1 non-text contrast,
  label row, Semantics value.
- AppEmptyState: 64px circle icon, title, message (max 2 lines), optional
  AppPillButton, max width 320.
- AppErrorState: friendly message (what happened + what to do), Try again
  button, never raw exceptions.
- AppBanner: info/warning/error/success, icon + text + optional action,
  optional dismiss, live-region announcement, AA contrast.

### 1d-ii — loading & images
- AppSkeleton/AppShimmer: uses the approved `shimmer` package (tell the user
  before touching pubspec). Skeletons mirror the final layout (same radii/
  heights/gaps). Respect reduced-motion (static when on). Frozen frame in
  tests.
- AppLoader: 28px accent spinner, Semantics busy, for short blocking actions
  only.
- AppNetworkImage: radius param, placeholder + error placeholder,
  deterministic stub in tests. ASK before adding cached_network_image; if the
  user says no, build on what the apps already use.

### 1e-i — frame & navigation
- AppScaffold: SafeArea, background token, horizontal padding by breakpoint
  using the existing AppResponsive, max content width on expanded, optional
  sticky bottom action bar (surface, top hairline, one primary button),
  keyboard-safe, pull-to-refresh support.
- AppAppBar: 56 high, no elevation, hairline border on scroll, left or
  centered title, back button >= 48 hit area that mirrors in RTL, optional
  large collapsing title.
- AppBottomNav: max 5 items, 64 + safe area, icon 24 + label 12, active =
  accent icon + textPrimary label, inactive textTertiary (verify AA), badge
  support, 48 hit area, labels survive 1.3x; NavigationRail variant for
  medium/expanded.
- AppSegmentedControl / AppPillTabs: track surfaceSunken, pill, 40 high with
  48 hit area, selected segment surface + e1, scrollable variant, selected
  state in Semantics.

### 1e-ii — overlays
- AppBottomSheet: top radius 28, drag handle 36x4, padding 24, max height
  90%, safe area + keyboard inset, drag-to-dismiss, scrim, pinned primary
  action, focus/Semantics for modal.
- AppDialog: radius 20, padding 24, actions end-aligned (secondary +
  primary), destructive confirmation variant, focus handling, scales at
  1.3x.
- AppSnackBar/AppToast: floating, radius 12, icon + message, 4s
  auto-dismiss, optional action, live-region announcement, must not cover
  the bottom nav or sticky action bar.

### 1f — table + full evaluation
- AppTable: table on wide screens (sticky header surfaceSunken, tabular
  numbers), stacked AppCards per row on compact; optional sort semantics.
- FULL EVALUATION: render ALL phase-1 widgets in the gallery in the full
  matrix (light/dark x text scale 1.0/1.3 x LTR/RTL with locale ar), view
  every image, write `docs/ui-redesign/evaluation/phase-1-widgets.md`
  (table: Widget | Image | Result | Issues | Fix | Re-verified), fix,
  re-capture until zero fails.
- Write `docs/ui-redesign/WIDGET_MIGRATION_MAP.md`: for each legacy
  widget/pattern found in the apps (PrimaryButton, StatusPill, old text
  fields, cards, loaders, dialogs...), which new widget replaces it, which
  variants are not covered yet, and the rename path to the spec names.
  Update DESIGN_SYSTEM.md's component catalog (names, rename path, usage).

## 7. Per-part tasks (every part 1c-i … 1f)
Same as the 1a/1b loop: implement to C8 + part spec; unit tests (states,
AA where colors are involved); gallery + captures; view/judge/fix/
re-capture; 5 login baselines byte-identical; tool scripts green; PROGRESS
update; stop with commit message; no self-commit.

## 8. Standing orders (apply to every part — read every session)
1. One part per session. Stop when its QA passes. Never start the next part.
2. Additive only: new widgets in shared_core/src/widgets/. Do NOT replace or
   rewire any existing screen or duplicate widget in any app. Existing app UI
   must stay byte-identical: re-run the 5 login baselines at the end and
   list any difference (expected: none).
3. Names: before building, verify each widget name is free (legacy names
   often collide), choose a distinct name if not, and record the rename
   path to the spec name in code docs, DESIGN_SPEC, DESIGN_SYSTEM and
   PROGRESS.
4. Widget contract: tokens only, caller-supplied text, Directional
   insets/alignment, >= 48dp targets, Semantics, light + dark, text scale
   1.3 safe (wrap/grow, never clip), no hardcoded strings or colors, doc
   comment with a usage example, no white text on the success green (use
   successStrong), measured AA/3:1 contrast asserted in tests where colors
   are involved, state tests (disabled/loading/error/selected as relevant).
5. Gallery grows per part. Captures to docs/ui-redesign/baseline/gallery/
   (light + dark, scale 1.0 and 1.3, LTR + RTL with locale ar, banner off).
   VIEW the images and judge them against DESIGN_SPEC C8/C14. Name the image
   files you inspected; list every problem found and how you fixed it; never
   say "looks good" without evidence. Re-capture after fixes.
6. Dependencies: only `shimmer` is approved. Ask before adding anything else.
7. Run tool/analyze_all.sh and tool/test_all.sh through Git Bash. Report apps
   affected (expected: none visually).
8. Things goldens cannot prove (gestures, drag-to-dismiss, keyboard/IME,
   focus behavior, haptics, real notches) go into a checklist block in
   PROGRESS.md for the phase-15 real-device pass.
9. Be honest in the report: do not copy findings from earlier sessions into
   the current one; list only what happened in THIS session.
10. END OF EVERY PART: tick it in PROGRESS.md, add a session log row, rewrite
    "Next session starts here" with the next part and its exact widget list,
    give the commit message `ui(phase-1<part>): <summary>` + git diff --stat,
    and print the exact prompt the user should use to start the next session.
    No self-commit.

## 9. Ask me first
Icon set (stay Material); `cached_network_image` vs hand-rolled (1d-ii);
`shimmer` pubspec touch (1d-ii); AppTable desktop interactions (1f); any
ambiguity in C8 sizes or part specs above.
