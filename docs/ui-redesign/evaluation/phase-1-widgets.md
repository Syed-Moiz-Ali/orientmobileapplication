# Phase-1 full evaluation pass (1f evaluator — fresh reviewer)

- Branch: `ui/phase-1-widgets` (evaluator made zero code changes; this file is the only write).
- Date (UTC): 2026-10-20. Evaluator did not build these widgets.
- Inputs read first: `docs/ui-redesign/phases/phase-1-shared-widgets.md` (§1f spec + §8 standing orders),
  `docs/ui-redesign/DESIGN_SPEC.md` C1–C15 (normative: C8 component specs, C14 visual checklist).
- Images viewed: **76/76 gallery PNGs** under `docs/ui-redesign/baseline/gallery/` (every
  `1a/1b/1c-i/1c-ii/1d-i/1d-ii/1e-i/1e-ii/1f` file: light/dark × 1.0/1.3 × LTR/RTL, plus the 4
  `1c-ii-tooltip_*` popover captures) **+ 6/6 contact sheets** under
  `docs/ui-redesign/evaluation/contact-sheets/phase-1{c-i,c-ii,d-i,d-ii,e-i,e-ii}.png`. No sampling.
- Tests executed (read-only, no `--update-goldens`, no commits):
  - `flutter test --exclude-tags baseline` in `packages/shared_core` → **198/198 passed** ("All tests passed!").
  - ONE login baseline compare, customer_app, no update flag:
    `flutter test --tags baseline test/baseline_capture_test.dart --plain-name "baseline customer light (real app root)"`
    in `apps/customer_app` → **passed**, golden `docs/ui-redesign/baseline/customer_light.png` byte-identical.
    Phase-1 work did not leak into app rendering.
- Standing-order note: per this session's orders the evaluator fixes nothing; "Fix applied" below is
  therefore N/A throughout and every defect lists file + what + why + suggested fix for the fix round.

## 0. Normative baseline used for judgement (read this first)

- The approved brand is **hyper-cobalt `#215FE6` (light) / `#3B82F6` (dark)**, NOT the `#FF385C` still
  printed in DESIGN_SPEC C2. Evidence: `PROGRESS.md` decision log ("Spec default #FF385C is NOT used"),
  `DESIGN_SYSTEM.md` §2 accent family table, `AUDIT.md`/`MODULES.md` token-conflict entries, and the frozen
  tokens in `packages/shared_core/lib/src/theme/app_colors.dart` (`primary #215FE6`, `primaryPressed
  #1E40AF`, `accentSoft #E3ECFD`, `successStrong #15803D`, `infoTeal #0E7490`, dark `onPrimary/onError
  #090B10`). Blue primary buttons / links / active nav in the gallery are therefore CORRECT; the stale C2
  hex row is a docs defect, not a widget defect (see §5, item D-3).
- Dark filled controls intentionally use **dark ink `#090B10` on bright fills** (documented 5.35:1 in
  `app_colors.dart:360-362`) instead of spec-letter `textOnAccent #FFFFFF`, because white on `#3B82F6`
  would fail AA. This is an approved AA-driven deviation, asserted in tests. Judged correct.

## 1. Per-part table (Part | Widget | Image(s) | Result | Issue | Fix applied | Re-verified)

### 1a — buttons (AppPillButton, AppIconButton, AppTextButton)

| Widget | Image(s) | Result | Issue | Fix applied | Re-verified |
|---|---|---|---|---|---|
| AppPillButton primary 52/44/36 | `1a-buttons_light_1.0_ltr.png`, `1a-buttons_dark_1.0_ltr.png`, `1a-buttons_light_1.3_ltr.png`, `1a-buttons_dark_1.3_rtl.png`, `1a-buttons_light_1.0_rtl.png`, `1a-buttons_light_1.3_rtl.png`, `1a-buttons_dark_1.0_rtl.png`, `1a-buttons_dark_1.3_ltr.png` | pass | Pill radius, 3 heights visibly stepped, cobalt fill, labelLarge centered; dark uses dark ink on fill per approved deviation; no clip at 1.3x. | N/A | n/a (pass) |
| AppPillButton secondary/ghost/destructive/success | same 8 files | pass | Secondary = surface + borderStrong; ghost = bare accent text; Delete = error fill w/ white; Approve = successStrong fill w/ white (no white-on-`#10B981`, honors the no-white-on-success-green rule). | N/A | n/a (pass) |
| AppPillButton disabled/loading | same 8 files | pass | Disabled = washed fill + faint label (40%-style dim, exempt from AA); loading = 20px spinner, width held. | N/A | n/a (pass) |
| AppPillButton leading icons + RTL | same 8 files | pass | LTR "→ Next / ← Back"; RTL "Next ←-mirrored / Back …→-mirrored": icon side and glyph both mirror. | N/A | n/a (pass) |
| AppIconButton (44 hit, 20 icon) | same 8 files | pass | Circle, border variant, active bell in accentSoft; order mirrors in RTL. | N/A | n/a (pass) |
| AppTextButton (See all / Try again / Disabled) | same 8 files | pass | Accent text, verb-first labels, disabled dimmed. No overflow at 1.3x in either direction. | N/A | n/a (pass) |

### 1b — inputs (AppInputField, AppSearchBar, AppDropdown, Check/Switch/Radio tiles)

| Widget | Image(s) | Result | Issue | Fix applied | Re-verified |
|---|---|---|---|---|---|
| AppInputField variants (email/helper/password/phone-error/disabled/notes+0/280) | `1b-inputs_light_1.0_ltr.png`, `1b-inputs_dark_1.0_ltr.png`, `1b-inputs_light_1.3_rtl.png`, `1b-inputs_dark_1.3_rtl.png`, `1b-inputs_light_1.0_rtl.png`, `1b-inputs_light_1.3_ltr.png`, `1b-inputs_dark_1.0_rtl.png`, `1b-inputs_dark_1.3_ltr.png` | pass with harness note (H-1, §5) | Radius-12, resting `inputBorder` visible against fill, password eye, error = red border + icon + message, disabled dimmed, counter mirrors (right in LTR, left in RTL), `forceLtr` values stay LTR inside RTL. No overflow at 1.3x. The Arabic-label demo row shows tofu boxes in the three en-locale LTR captures ONLY — documented harness font gap (gallery `design_system_gallery_screen.dart:364-367`, demo intentionally ungated at lines 278-283); the same row renders correctly in all RTL captures. | N/A (evaluator fixes nothing) | n/a |
| AppSearchBar (empty + `booking` w/ clear) | same 8 files | pass | Pill radius, search icon + clear ×, icon sides mirror in RTL, 48 height. | N/A | n/a (pass) |
| AppDropdown closed (`Deira`) | same 8 files | pass | Value + chevron, chevron side mirrors. | N/A | n/a (pass) |
| AppCheckTile / AppSwitchTile / AppRadioTile + disabled | same 8 files | pass | Whole-row layout, checked box w/ check, switch off, radio on, disabled dimmed; controls move to start side in RTL. | N/A | n/a (pass) |

### 1c-i — surfaces (AppSurfaceCard→AppCard, AppSection, AppListTile, AppSettingsTile, AppDivider, AppDataRow)

| Widget | Image(s) | Result | Issue | Fix applied | Re-verified |
|---|---|---|---|---|---|
| AppSurfaceCard bordered / elevated / tappable + nesting demo | `1c-i-surfaces_light_1.0_ltr.png`, `1c-i-surfaces_dark_1.0_ltr.png`, `1c-i-surfaces_light_1.3_rtl.png`, `1c-i-surfaces_dark_1.3_rtl.png`, `1c-i-surfaces_light_1.0_rtl.png`, `1c-i-surfaces_light_1.3_ltr.png`, `1c-i-surfaces_dark_1.0_rtl.png`, `1c-i-surfaces_dark_1.3_ltr.png` | pass | Light: bordered card has hairline, elevated card has shadow and no border (border-XOR-shadow holds); dark: border + lift, no shadow. Nesting demo shows the allowed surfaceAlt-block-inside-card only. Tappable chevron mirrors in RTL. | N/A | n/a (pass) |
| AppSection | same 8 files | pass | titleMedium + "See all" ghost + 12 gap; mirrors in RTL. | N/A | n/a (pass) |
| AppListTile grouped (72px inset dividers) / static row | same 8 files | pass | 40px circle leadings, value+chevron trailing, static row has no chevron; dividers inset from the correct side in RTL. Long subtitle ("Yesterday at 18:04") wraps, never clips, at 1.3x. | N/A | n/a (pass) |
| AppSettingsTile (switch/value/disabled) | same 8 files | pass | Switch ON uses token primary track; disabled row dimmed; "Push notifications" wraps to 2 lines and grows the tile at 1.3x (correct reflow). | N/A | n/a (pass) |
| AppDivider full-bleed + inset | same 8 files | pass | Hairline, both variants shown, inset side mirrors. | N/A | n/a (pass) |
| AppDataRow (incl. Arabic label row, long-label wrap) | same 8 files | pass | Label at start, tabular value at end; Western digits + LTR amounts inside RTL ("AED 1,240.00", "+AED 240.00" never flip); الحالة renders; long label wraps at 1.3x. | N/A | n/a (pass) |

### 1c-ii — identity (AppAvatar, AppBadge, AppChip, AppStatusChip, AppInfoTooltip closed)

| Widget | Image(s) | Result | Issue | Fix applied | Re-verified |
|---|---|---|---|---|---|
| AppAvatar 24/32/40/56 | `1c-ii-identity_light_1.0_ltr.png`, `1c-ii-identity_dark_1.0_ltr.png`, `1c-ii-identity_light_1.3_rtl.png`, `1c-ii-identity_dark_1.3_rtl.png`, `1c-ii-identity_light_1.0_rtl.png`, `1c-ii-identity_light_1.3_ltr.png`, `1c-ii-identity_dark_1.0_rtl.png`, `1c-ii-identity_dark_1.3_ltr.png` | pass | Initials on accentSoft, 4 sizes stepped, Arabic-initials avatar renders in RTL captures. | N/A | n/a (pass) |
| AppBadge (3 / 7 / 99+) | same 8 files | **FAIL (minor, non-blocking — D-1)** | The capped label flips direction in RTL: `99+` (LTR captures) renders as `+99` (all four `*_rtl.png` captures). Cause: `app_badge.dart:44` builds `'$maxCount+'` with no bidi isolation, so the trailing `+` migrates under RTL paragraph direction. Still legible, layout intact, but wrong. Suggested fix: wrap the label `Text` in `Directionality(textDirection: TextDirection.ltr, …)` (or U+2066…U+2069 isolates) + add an RTL golden assertion. | N/A (fix round) | NO — needs re-capture after fix |
| AppChip filter (selected carries ✓) | same 8 files | pass | Selected = dark fill + check + white label (non-color cue present); unselected = surface + border; disabled dimmed. Order mirrors in RTL. | N/A | n/a (pass) |
| AppStatusChip all six kinds | same 8 files | pass | 8px dot + human label on soft fills in all six kinds, both themes; light and dark pairs distinguishable (see close-calls §3). | N/A | n/a (pass) |
| Closest pair side-by-side (success-soft vs info-soft) | same 8 files | pass | Pair explicitly staged in every capture; distinguishable in both themes (measured facts in §3). | N/A | n/a (pass) |
| AppInfoTooltip closed (48dp target, 16px glyph) | same 8 identity files (closed row) | pass | Hit circle + glyph, position mirrors in RTL. | N/A | n/a (pass) |

### 1c-ii — tooltip open popover

| Widget | Image(s) | Result | Issue | Fix applied | Re-verified |
|---|---|---|---|---|---|
| AppInfoTooltip popover (radius 12, e2, max-width, RTL placement) | `1c-ii-tooltip_light_ltr.png`, `1c-ii-tooltip_dark_ltr.png`, `1c-ii-tooltip_light_rtl.png`, `1c-ii-tooltip_dark_rtl.png` | **FAIL (minor, non-blocking — D-2)** | Chrome passes (radius-12, e2 shadow, placement flips to the correct side in RTL, dark uses surface+border). But the English demo sentence's trailing period migrates in both `*_rtl.png` captures: LTR ends `…your settings.` while RTL ends `….your settings` (period jumps to the line-start side). Classic missing-isolation: LTR sentence under RTL paragraph direction. Suggested fix: directionally isolate the message (`Directionality` matching the string's base direction, or U+2066…U+2069) and re-verify with a REAL Arabic string (production ARB will be translated; English-in-ar-locale is gallery-only). Dismiss-on-outside-tap, keyboard focus order, and screen-reader behavior are not provable by goldens → phase-15 list (§4). | N/A (fix round) | NO — needs re-capture after fix |

### 1d-i — feedback (AppStatTile, AppProgressBar, AppEmptyState, AppErrorState, AppBanner)

| Widget | Image(s) | Result | Issue | Fix applied | Re-verified |
|---|---|---|---|---|---|
| AppStatTile (label/value/caption/delta/2-col grid) | `1d-i-feedback_light_1.0_ltr.png`, `1d-i-feedback_dark_1.0_ltr.png`, `1d-i-feedback_light_1.3_rtl.png`, `1d-i-feedback_dark_1.3_rtl.png`, `1d-i-feedback_light_1.0_rtl.png`, `1d-i-feedback_light_1.3_ltr.png`, `1d-i-feedback_dark_1.0_rtl.png`, `1d-i-feedback_dark_1.3_ltr.png` | pass | Tabular values, delta rows carry arrow + sign + semantic ink (never color alone), 12px 2-col grid, RTL mirrors with arrows correctly placed after the value. Screen-reader delta labels are code-covered (198-test suite), not golden-provable. | N/A | n/a (pass) |
| AppProgressBar (8px pill, auto tone) | same 8 files | pass | 15% accent / 62% success / 82% warning / 95% error in both themes; label row + end %; fill grows from the correct side in RTL. Track-vs-fill contrast is unit-asserted (≥3:1). | N/A | n/a (pass) |
| AppEmptyState / AppErrorState | same 8 files | pass | 64px circle + 28px icon, title, ≤2-line message, full-width action; friendly copy ("Could not load bookings / Check your connection and try again" — no raw exceptions); centered ≤320; wraps cleanly at 1.3x RTL. | N/A | n/a (pass) |
| AppBanner info/warning/error/success + dismissible | same 8 files | pass | Icon + text + action (`Retry`/`Try again`), × dismiss on error, icon/× sides mirror in RTL, soft-tint fills in light / deep fills in dark, all AA-asserted in tests. | N/A | n/a (pass) |

### 1d-ii — loading (AppShimmerSkeleton→AppSkeleton/AppShimmer, AppLoader, AppNetworkImage)

| Widget | Image(s) | Result | Issue | Fix applied | Re-verified |
|---|---|---|---|---|---|
| AppLoader (28px accent spinner + label) | `1d-ii-loading_light_1.0_ltr.png`, `1d-ii-loading_dark_1.0_ltr.png`, `1d-ii-loading_light_1.3_rtl.png`, `1d-ii-loading_dark_1.3_rtl.png`, `1d-ii-loading_light_1.0_rtl.png`, `1d-ii-loading_light_1.3_ltr.png`, `1d-ii-loading_dark_1.0_rtl.png`, `1d-ii-loading_dark_1.3_ltr.png` | pass | Accent spinner + "Saving changes", centered, both themes. | N/A | n/a (pass) |
| Skeletons (bar / card / text-block / tile rows) | same 8 files | pass | Same radii/heights/gaps as the final layouts they stand in for; tile-row skeletons mirror (avatar block at end side in RTL). Frozen frame in captures by design. Reduced-motion static path is code-covered, not golden-provable → phase 15 (§4). | N/A | n/a (pass) |
| AppNetworkImage (rect + circle-avatar fallback) | same 8 files | pass | Error fallback (broken-image glyph) holds size with the requested radius in both shapes and themes; no empty hole, no stretch. Real-network behavior is stubbed by design → module phases (§4). | N/A | n/a (pass) |

### 1e-i — frame (AppScaffold, AppAppBar, AppBottomNav, AppNavRail, AppSegmentedControl, AppPillTabs)

| Widget | Image(s) | Result | Issue | Fix applied | Re-verified |
|---|---|---|---|---|---|
| AppScaffold (sticky action + safe area + PTR wrapper) | `1e-i-frame_light_1.0_ltr.png`, `1e-i-frame_dark_1.0_ltr.png`, `1e-i-frame_light_1.3_rtl.png`, `1e-i-frame_dark_1.3_rtl.png`, `1e-i-frame_light_1.0_rtl.png`, `1e-i-frame_light_1.3_ltr.png`, `1e-i-frame_dark_1.0_rtl.png`, `1e-i-frame_dark_1.3_ltr.png` | pass | Surface top hairline, ONE full-width primary + secondary text button, padding tokens; no overflow at 1.3x. | N/A | n/a (pass) |
| AppAppBar (56, left/centered/large) | same 8 files | pass | 56 height, no elevation, back ≥48 mirrored in RTL, bell action, large collapsing 32→20 title. | N/A | n/a (pass) |
| AppBottomNav (5 items + badge) | same 8 files | pass with close-call C-1 (§3) | Active = accent icon + textPrimary semibold; badge 3 on Bookings; order mirrors in RTL; rail takes over at medium+. At 1.3x the "Bookings" label wraps to 2 lines ("Bookin/gs") in ALL FOUR `*1.3*` captures and grows the bar — this is the DOCUMENTED contract (`app_bottom_nav.dart:23,129-135`: `maxLines: 2`, ellipsis, grow-don't-clip), tests assert no overflow, nothing clips. Judged: intentional reflow, not a defect — but recorded as close-call C-1 because a 2-line nav label is one long Arabic/German destination label away from a crowded bar; module phases must keep labels short. | N/A | n/a (pass, by documented contract) |
| AppNavRail variant | same 8 files | pass | Rail on the correct side per direction (left LTR / right RTL), soft indicator on Home, badge on Bookings, labels shown. Gallery height is fixed by harness (labeled as such). | N/A | n/a (pass) |
| AppSegmentedControl (3-opt + scrollable many-opt) | same 8 files | pass | surfaceSunken pill track, selected = surface + e1 ("Week"), 40 height; scrollable row clips with a cut-off "Last…" item proving scrollability; order mirrors in RTL. | N/A | n/a (pass) |
| AppPillTabs scrollable | same 8 files | pass | Selected "Open" = accentSoft + accent ink; cut-off "Ca…" proves horizontal scroll; mirrors in RTL. | N/A | n/a (pass) |

### 1e-ii — overlays (AppBottomSheet, AppDialog, AppSnackBar, AppToast)

| Widget | Image(s) | Result | Issue | Fix applied | Re-verified |
|---|---|---|---|---|---|
| AppBottomSheet trigger + static chrome + REAL open route | `1e-ii-overlays_light_1.0_ltr.png`, `1e-ii-overlays_dark_1.0_ltr.png`, `1e-ii-overlays_light_1.3_rtl.png`, `1e-ii-overlays_dark_1.3_rtl.png`, `1e-ii-overlays_light_1.0_rtl.png`, `1e-ii-overlays_light_1.3_ltr.png`, `1e-ii-overlays_dark_1.0_rtl.png`, `1e-ii-overlays_dark_1.3_ltr.png` | pass | Top radius 28, 36×4 handle, title + body + pinned primary ("Apply filters"); the capture has the REAL sheet route open with scrim dimming the gallery behind (proves scrim in both themes). Destructive-title wrap at 1.3x RTL is clean 2-line reflow. Drag-to-dismiss gesture itself is not golden-provable → phase 15 (§4). | N/A | n/a (pass) |
| AppDialog standard + destructive (names the object) | same 8 files | pass | Radius 20, padding 24, titleLarge + bodyMedium-secondary; actions end-aligned secondary+primary with correct RTL mirroring (primary stays at end side); destructive names 'Invoice #123' with red primary. At 1.3x (`1e-ii-overlays_light_1.3_ltr.png`) actions stack vertically full-width instead of overflowing — correct responsive behavior. | N/A | n/a (pass) |
| AppSnackBar with/without action | same 8 files | pass | Floating radius-12, icon + message, success = icon + soft tint (not saturated fill), dark inverse variant; RTL mirrors. 4s auto-dismiss and live-region announcement are code/test-covered, not golden-provable → §4. | N/A | n/a (pass) |
| AppToast success/error centered | same 8 files | pass | Soft tints + icon, centered, non-blocking; mirrors in RTL. | N/A | n/a (pass) |

### 1f — table (AppDataTable→AppTable + AppDataTableHeader)

| Widget | Image(s) | Result | Issue | Fix applied | Re-verified |
|---|---|---|---|---|---|
| Wide table (sticky surfaceSunken header, sortable Amount) | `1f-table_light_1.0_ltr.png`, `1f-table_dark_1.0_ltr.png`, `1f-table_light_1.3_rtl.png`, `1f-table_dark_1.3_rtl.png`, `1f-table_light_1.0_rtl.png`, `1f-table_light_1.3_ltr.png`, `1f-table_dark_1.0_rtl.png`, `1f-table_dark_1.3_ltr.png` | pass | Columns mirror in RTL (Invoice first from the right), sort arrow + accent on Amount with correct side, tabular amounts, `INV-…` IDs and `AED …` values stay LTR inside RTL, no horizontal scroll on the 390-wide canvas. | N/A | n/a (pass) |
| Compact stacked AppSurfaceCards (<600 surface) | same 8 files | pass | Same rows as label/value cards reusing card styling (no parallel card look); label at start side per direction; no overflow at 1.3x. True device-width breakpoint behavior (>600 real widths) is unit-covered, not golden-proven → module phases (§4). | N/A | n/a (pass) |

## 2. Cross-cutting verdict (C14 checklist, with named evidence — no bare "looks good")

- **Layout (no overflow/clip/overlap):** PASS. All 76 gallery captures are clean; the 198-test suite asserts
  `takeException() == null` across the matrix. Deliberate cut-offs (`1e-i` "Last…"/"Ca…" scroll rows,
  `1e-ii` scrimmed background behind the open sheet) are demonstrably intentional, not defects.
- **Hierarchy (one primary focus):** PASS per widget demo. Gallery sections each stage one component family
  with a labeled heading (e.g. `1d-i-feedback_*` stat → delta → grid → progress → empty → error → banners).
- **Spacing:** PASS. 20 screen padding / 24 section rhythm / 12 list gaps / 20 card padding visible and
  consistent across `1a`–`1f` captures and both themes (cross-checked on contact sheets
  `phase-1c-i.png`, `phase-1d-i.png`, `phase-1e-i.png`).
- **Alignment/grid:** PASS on the captured 390-wide compact canvas. Max-width-on-expanded and true
  medium/expanded breakpoints are NOT captured in goldens (only the rail/table demos simulate them) →
  carried to module phases (§4).
- **Typography:** PASS with one harness caveat. Scale/weights match C3 roles; nothing under 12;
  tabular figures verified on `AED 12,450`, `AED 1,240.00`, `INV-2041`, `18:04`, `0/280` across
  `1c-i-surfaces_*`, `1d-i-feedback_*`, `1f-table_*`. Caveat H-1: Arabic-script demo label is tofu in the
  three en-locale LTR `1b-inputs_*` captures (font-coverage gap, §1b row) while correct in all RTL captures.
- **Components (C8 exactness):** PASS except D-1/D-2 (minor, §1). Pill buttons 52/44/36, 44 icon hit areas,
  52 fields, 56 tiles, 40px leadings, 64+safe-area nav, radius-28 sheets, radius-20 dialogs, 8px progress,
  28px loader, 64px state circles, border-XOR-shadow cards, dark-border-no-shadow — all confirmed by eye
  against the files named in §1.
- **Color:** PASS (against the approved Concept-A tokens, §0). Accent strictly for primary/active states;
  green/red strictly semantic; dark is soft charcoal `#090B10`/`#11141D`, never pure black, no glow;
  no gradients. AA is unit-asserted (tap-target, labeled-target, and text-contrast guidelines in the suite).
- **Responsiveness:** PASS on compact; 1.3x reflows by wrapping/growing (tiles in `1c-i-surfaces_*1.3*`,
  nav labels in `1e-i-frame_*1.3*`, dialog actions stacking in `1e-ii-overlays_light_1.3_ltr.png`). No 2.0x
  scale and no real tablet/desktop widths captured → module phases (§4).
- **States:** PASS. Disabled (40%-style dim + still-labeled), loading (spinner holds width / skeletons mirror
  layouts), error (friendly + retry, never raw text), empty (action included), dismissible banner, destructive
  confirm naming the object — all staged in `1a/1b/1d-i/1d-ii/1e-ii` captures.
- **Text scale 1.3x:** PASS (32 of the 76 captures). Zero overflows; reflow points listed above are all
  grow/wrap, never clip. 2.0x is NOT in the gallery matrix → module phases.
- **Locale/RTL:** PASS with two minor fails (D-1 badge `99+`→`+99`; D-2 tooltip trailing-period migration),
  both non-blocking, both with file+fix in §1. Everything else mirrors: button/field/nav/rail/segmented/
  pills/sheet/dialog/snackbar/toast/table/tiles/dividers/chips/counters/chevrons/back-arrows/sort-arrows,
  with Western digits + LTR amounts/IDs/phones preserved inside RTL (`1c-i`, `1d-i`, `1f` evidence above).
- **AA:** PASS by construction + tests (contrast/tap-target/labeled-target guidelines green in the 198-test
  run; token-level ratios documented in `app_colors.dart` and `DESIGN_SYSTEM.md` swatch notes). The two
  deliberate spec-letter deviations (cobalt brand; dark ink on bright fills) are AA improvements, §0.

## 3. Honest close-call list (near-indistinguishable pairs — measured facts)

- **C-1. Bottom-nav label wrap at 1.3x (NOT a defect).** `1e-i-frame_light_1.3_ltr.png`,
  `1e-i-frame_dark_1.3_ltr.png`, `1e-ii… no — 1e-i-frame_light_1.3_rtl.png`, `1e-i-frame_dark_1.3_rtl.png`:
  "Bookings" wraps mid-word ("Bookin/gs") and the bar grows. Contract: `app_bottom_nav.dart:23`
  ("labels wrap to 2 lines and grow the bar") + `maxLines: 2` + ellipsis (lines 129–135); zero overflow
  exceptions in tests. Verdict: intentional reflow, pass. Warning carried forward: a 5-item bar at 1.3x with
  long Arabic/German labels will crowd — module phases must keep destination labels to ≤~8 characters or
  shorten per locale, and re-check at 1.3x RTL.
- **C-2. success-soft vs info-soft (the staged closest pair) — DISTINGUISHABLE, and dot+label carries it
  regardless.** Light: success fill `AppColors.successSubtle #D1FAE5` (emerald) vs info fill
  `AppColors.infoTealSoft #E6F4F7` (cyan-grey); dots `#10B981` vs `#0E7490` (emerald vs teal);
  inks `#166534` vs `#155E75`. Dark: `#064E3B` vs `#0C3238`. Evidence: the side-by-side rows in all eight
  `1c-ii-identity_*` captures + `phase-1c-ii.png` contact sheet — green vs teal read apart at a glance in
  both themes. Even under total color loss, the 8px dot + DIFFERENT human labels ("Active" vs "Syncing")
  carry the distinction, satisfying "never color alone". No action.
- **C-3. Dark filled-button ink (dark-on-blue) vs light (white-on-blue) — INTENTIONAL asymmetry.**
  `1a-buttons_dark_*` shows dark labels on `#3B82F6`; `1a-buttons_light_*` shows white on `#215FE6`.
  Measured basis in code: white-on-`#3B82F6` ≈ 3.9:1 (fails AA 4.5) vs `#090B10`-on-`#3B82F6` = 5.35:1
  (`app_colors.dart:360-362`); light white-on-`#215FE6` = 5.46:1. Same asymmetry on badges (`3`/`99+` dark
  ink in dark captures, white in light). AA-correct; no action, but polish phase must keep this pair in sync
  if the dark primary hex ever moves.
- **C-4. Disabled-state legibility.** Disabled pill (`1a`), disabled field/option (`1b`), disabled chip
  (`1c-ii`), disabled tile (`1c-i`) are all very faint by design (40%-style). Exempt from AA per C10, and
  every dimmed control keeps its text label (no meaning lost). No action — but module phases must always pair
  a disabled control with an explanation string where the reason isn't obvious (C10 rule).
- **C-5. Skeleton shimmer freeze.** `1d-ii-loading_*` captures show the frozen mid-shimmer frame; base vs
  highlight delta is subtle by design (light `#F1F5F9`/`#F8FAFC`, dark `#181C28`/`#262C3D`). Motion quality
  (1200ms loop, reduced-motion static) is code-covered only. Real shimmer feel → phase-15 device check (§4).

## 4. Known issues carried forward (goldens cannot prove these)

**To phase 15 (real-device only):** sheet drag-to-dismiss feel and velocity; dialog focus trap + return-focus;
snackbar 4s auto-dismiss timing and live-region announcement timing; toast non-blocking behavior under
VoiceOver/TalkBack; tooltip outside-tap dismiss + keyboard focus visibility + screen-reader node order;
delta-row and badge Semantics labels announced (unit-asserted, never heard); shimmer 1200ms loop feel +
reduced-motion static path; pull-to-refresh gesture feel; sticky-action-bar keyboard avoidance with a real
IME; real-notch/safe-area behavior; dark-ink-on-blue legibility to human eyes in sunlight; Arabic-script
rendering with production fonts (harness tofu caveat H-1); real-device performance of shimmer/blur/scrim.
**To module phases (need real content/widths):** text scale **2.0x** (gallery stops at 1.3x); real German and
real Arabic (translated, long) strings in every widget incl. nav labels (C-1 warning), dialog titles, banner
text; true ≥600/>1024 device widths for `AppDataTable` breakpoint, rail-vs-nav switch, and max-width rules;
real network images (success/loading/error over slow connections); live-region announcements on locale
switch; chart/table density with production row counts; `INPUT_INVENTORY.md`/`WIDGET_MIGRATION_MAP.md`
conformance per migrated screen.

## 5. Verdict: ZERO blocking defects; 2 minor non-blocking defects + 1 docs drift + 1 harness note

No defect found breaks layout, contrast, touch targets, semantics, or C8 geometry, in any of the 76
captures or 6 contact sheets, and the full `shared_core` suite (198 tests) plus the customer-app login
baseline compare are green with zero app-rendering leakage. **Blocking-defect count: 0.** The fix round
should take these in order (I fixed nothing — files + causes + suggested fixes below):

- **D-1 (minor, non-blocking): badge count bidi flip.** File `packages/shared_core/lib/src/widgets/app_badge.dart:44`
  (`display = '$maxCount+'`, no directional isolation). What: capped badge renders `+99` instead of `99+`
  in all four `1c-ii-identity_*_rtl.png` captures. Why it matters: wrong glyph order in every RTL screen
  using counts. Suggested fix: `Directionality(textDirection: TextDirection.ltr)` around the label `Text`
  (or U+2066…U+2069 isolates) + an RTL pump asserting `99+`; re-capture the four RTL identity images.
- **D-2 (minor, non-blocking): tooltip popover trailing-punctuation migration in RTL.** Widget
  `packages/shared_core/lib/src/widgets/app_info_tooltip.dart` (message `Text`). What: English demo sentence
  ends `…settings.` in `1c-ii-tooltip_light_ltr.png` / `dark_ltr` but `….settings`-leading in
  `1c-ii-tooltip_light_rtl.png` / `dark_rtl`. Why: LTR sentence under RTL paragraph direction without
  isolation. Suggested fix: directionally isolate the message span; re-verify with a REAL Arabic message
  (gallery English-in-ar is artificial); re-capture both RTL tooltip images.
- **D-3 (docs drift, non-blocking): DESIGN_SPEC C2 still prints accent `#FF385C`/`#FF5A78`.**
  File `docs/ui-redesign/DESIGN_SPEC.md:30`. The recorded, implemented, and tested decision is cobalt
  `#215FE6`/`#3B82F6` (PROGRESS decision log, DESIGN_SYSTEM §2, frozen tokens). Suggested fix (polish
  phase, NOT the widget fix round): update the C2 row + color-rules note to the approved brand and stamp the
  deviation approval; until then every future evaluator will re-litigate §0 of this report.
- **H-1 (harness note, non-blocking): en-locale captures cannot render Arabic script.**
  The `forceLtr` demo label (`design_system_gallery_screen.dart:278-283`) is intentionally ungated, so the
  three en-locale LTR `1b-inputs_*` captures show tofu while all RTL captures render
  `البريد الإلكتروني` correctly (Plex Arabic loads only under ar locale; cf. the gated pattern at
  lines 364-367). Suggested improvement: load the Plex Arabic family in the en capture harness too, so
  script rendering is provable in every capture — else Arabic shaping stays RTL-captures-only evidence.

*Report: 82 files viewed (76 gallery + 6 contact sheets, listed by exact name in §1); tests: shared_core
`flutter test --exclude-tags baseline` → 198/198 passed; customer_app login baseline compare (light, no
update flag) → passed, golden byte-identical; verdict: **0 blocking defects** (2 minor + 1 docs drift + 1
harness note above). Evaluation file: `docs/ui-redesign/evaluation/phase-1-widgets.md`.*
