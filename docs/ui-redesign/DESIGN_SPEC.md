BEGIN DESIGN SPEC

## C1. Design philosophy
- Calm, spacious, warm, confident. Content first, chrome last.
- ONE primary focus per screen. The user must understand "what is this, what is happening, what can
  I do next" within 5 seconds.
- Plain language over jargon. Technical detail is available (tooltip / "Details" expander) but never
  the default.
- Consistency over cleverness. Same component = same look everywhere.
- Light theme is the default. Dark theme is refined (soft charcoal, never pure black, no neon/glow).
- Depth comes from spacing, soft shadows and surface contrast, NOT from heavy borders or gradients.
- Motion is subtle and purposeful.

## C2. Color tokens
Define as `AppColors` (light + dark) exposed through a `ThemeExtension<AppTokens>` and
`ColorScheme`. Hex values are the defaults; ask me before changing the accent.

| Token | Light | Dark | Use |
|---|---|---|---|
| background | #FAFAF8 | #121214 | scaffold background |
| surface | #FFFFFF | #1B1B1F | cards, sheets, dialogs, app bar |
| surfaceAlt | #F5F5F2 | #232328 | inputs fill, skeleton base, subtle blocks, selected rows |
| surfaceSunken | #EFEFEA | #0E0E10 | segmented-control track, code/table headers |
| border | #EBEBEB | #2C2C32 | 1px hairlines, dividers |
| borderStrong | #DDDDDD | #3A3A42 | input border, outlined buttons |
| textPrimary | #222222 | #F2F2F3 | titles, key values, body |
| textSecondary | #6B6B6B | #A0A0A8 | supporting text, labels |
| textTertiary | #9A9A9A | #6F6F78 | placeholders, disabled, meta |
| textOnAccent | #FFFFFF | #FFFFFF | text/icons on accent |
| accent | #FF385C | #FF5A78 | primary buttons, active nav, links, key highlights |
| accentPressed | #E31C5F | #FF7A92 | pressed state |
| accentSoft | #FFF0F3 | #3A1B24 | tinted backgrounds for accent chips/icons |
| success | #16A34A | #3FBF7F | success, profit/up |
| successSoft | #E8F6EE | #14281E | success chip/banner bg |
| warning | #D97706 | #F0A33A | caution, delayed, pending |
| warningSoft | #FFF4E0 | #2E2210 | warning chip/banner bg |
| error | #DC2626 | #F06A6A | errors, loss/down, destructive |
| errorSoft | #FDECEC | #301616 | error chip/banner bg |
| info | #2563EB | #5B9BF5 | neutral information |
| infoSoft | #EAF1FE | #14233D | info chip/banner bg |
| overlay | #000000 @ 40% | #000000 @ 60% | modal scrim |
| shimmerBase / shimmerHighlight | #EDEDE8 / #F7F7F3 | #232328 / #2C2C32 | skeletons |

Color rules:
- ONE accent color. Everything else is neutral. Do not introduce extra brand colors.
- Green/red are reserved for success/error and up/down (profit/loss). Never use them decoratively.
- Never rely on color alone: pair with an icon, sign (+/-) or label.
- Text on any background must meet WCAG AA (4.5:1 body, 3:1 large). Verify and adjust if needed.
- No pure #000000 backgrounds, no pure white text on dark; no gradients except a very subtle one on
  hero cards if the product needs it (max 4% tint).
- Charts: neutral gridlines (border color at 60%), 1.5px lines, series colors from accent + 3 muted
  neutrals/blues; up/down candles use success/error desaturated.

## C3. Typography
Font: Inter (preferred) or Plus Jakarta Sans via google_fonts or bundled assets (ask me which; default
Inter). Monospace is allowed ONLY for code/IDs. Numbers use proportional font with
`FontFeature.tabularFigures()` so digits align.

| Style | Size / line height | Weight | Letter spacing | Use |
|---|---|---|---|---|
| displayLarge | 36 / 44 | 700 | -0.5 | hero numbers (balance, price) |
| displayMedium | 32 / 40 | 700 | -0.4 | large screen titles |
| headlineLarge | 28 / 36 | 700 | -0.3 | screen titles (auth, onboarding) |
| headlineMedium | 24 / 32 | 600 | -0.2 | section hero titles |
| titleLarge | 20 / 28 | 600 | 0 | app bar title, card titles |
| titleMedium | 18 / 26 | 600 | 0 | section headers |
| titleSmall | 16 / 24 | 600 | 0 | list item titles |
| bodyLarge | 16 / 24 | 400 | 0 | primary reading text |
| bodyMedium | 14 / 20 | 400 | 0 | DEFAULT body |
| bodySmall | 13 / 18 | 400 | 0 | supporting text |
| labelLarge | 14 / 20 | 600 | 0.1 | buttons |
| labelMedium | 12 / 16 | 500 | 0.2 | chips, field labels, captions |
| labelSmall | 12 / 16 | 500 | 0.2 | meta (minimum size in the app) |
| numberLarge | 32 / 40 | 700 | -0.4 | key stat value (tabular) |
| numberMedium | 20 / 28 | 600 | 0 | card values (tabular) |
| numberSmall | 14 / 20 | 500 | 0 | table/list numbers (tabular) |

Rules: nothing below 12. No ALL CAPS labels (use sentence case; muted color for hierarchy). Max 2
weights per card. Max line length ~70 chars for paragraphs. Support text scale up to 1.3x without
overflow (use Flexible/Expanded, wrap, ellipsis only for secondary text).

## C4. Spacing, layout grid, breakpoints
Spacing scale (`AppSpacing`): xxs 2, xs 4, sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 48, huge 64.
Use ONLY these values.

- Screen horizontal padding: 20 (phone, min 16), 24 (tablet), 32 (desktop).
- Card inner padding: 20 (compact cards 16, hero cards 24).
- Gap between cards / sections: 24 (min 16). Gap between list items: 12. Gap between label and value: 4.
- Gap between form fields: 16; between form groups: 24.
- Bottom of scroll content: 24 + safe area (+80 if a FAB / bottom bar overlaps).

Breakpoints: compact < 600 (single column), medium 600-1024 (two columns for dashboards, side
sheets), expanded > 1024 (NavigationRail 80 or drawer 280, content max width 1200, forms/auth max 560).
Use LayoutBuilder / a `Breakpoints` helper; never hardcode device checks.

## C5. Shape, borders, elevation
Radius (`AppRadius`): xs 6, sm 8, md 12, lg 16, xl 20, xxl 28, pill 999.
- Cards 16-20, inputs 12, buttons pill, chips pill, dialogs 20, bottom sheets top 28, images 12-16,
  avatars circle.
Borders: 1px `border` color. Use EITHER a border OR a shadow on a card, never both.
Shadows (`AppShadows`), light mode only (dark mode uses surface lift + border, no shadow):
- e0: none
- e1: 0 1px 2px rgba(0,0,0,.04), 0 2px 8px rgba(0,0,0,.04) (cards)
- e2: 0 4px 16px rgba(0,0,0,.08) (floating bars, popovers)
- e3: 0 8px 28px rgba(0,0,0,.12) (dialogs, sheets)

## C6. Iconography
One icon set (Lucide via `lucide_icons`, or Material Symbols Rounded if already used). Size 20 default
(18 inline in text, 24 in nav, 28-32 in empty states). Stroke ~1.75. Icon color = textSecondary by
default, accent when active, semantic color only for status.

## C7. Motion
Durations (`AppDurations`): fast 150ms, normal 200ms, slow 300ms. Curve: easeOutCubic (enter),
easeInCubic (exit). Page transitions: fade-through or shared-axis, 250ms. Skeleton shimmer 1200ms
loop. Number changes: animated count/crossfade 300ms. Press feedback: scale 0.98 + ripple/opacity.
Respect reduced-motion. No bouncing, no parallax, no looping decorative animation.

## C8. Component specs (all in `lib/core/design_system/widgets/`, prefix `App`)
Every widget: reads only theme/tokens, supports light+dark, Semantics labels, 48dp min tap target,
const constructor where possible, doc comment with usage example, works at text scale 1.3x.
Phase-1d-i naming check: `AppStatTile`, `AppProgressBar`, `AppEmptyState`,
`AppErrorState`, `AppBanner` are all free in `packages/` — built under their
spec names, no rename path needed.

**AppPillButton** (spec name `AppButton`; renamed — the legacy `AppButton`
factory owns that name and is off-limits; rename this class to `AppButton`
once the legacy factory is removed): variants primary (accent fill,
textOnAccent), secondary (surface, borderStrong 1px,
textPrimary), ghost/text (no fill, accent text), destructive (error fill or error outline).
Height 52 (large, default for full-width CTAs) / 44 (medium) / 36 (small). Pill radius. labelLarge.
Min width 88. States: pressed (accentPressed + scale .98), disabled (40% opacity), loading (replace label
with 20px spinner, keep width). Optional leading icon 18. Full-width option. One primary button per
screen section.
**AppIconButton**: 44x44 hit area, 20 icon, circle, optional border/fill variant.
**AppInputField** (spec name `AppTextField`; renamed — the legacy
`AppTextField` owns that name and is off-limits; same rename path as
`AppPillButton`): fill surfaceAlt, 1px `inputBorder` resting boundary
(AA 3:1 vs page + card), radius 12, height 52 (min 48 hit area), padding h16.
Label above field (labelMedium, textSecondary), helper/error below (bodySmall;
error = error color + icon, announced via live region). Focus: 1.5px accent
border. Error: 1.5px error border. Prefix/suffix icons 20. Password toggle
built in. Disabled 40%. `forceLtr` values stay LTR inside RTL layouts.
**AppSearchBar**: AppInputField variant, pill radius, search icon, clear
button, height 48.
**AppCard**: surface, radius 16-20, padding 20, shadow e1 OR 1px border. Tappable variant with ripple +
chevron optional. Optional header (title + trailing action) and footer. Never nest a bordered card
inside a bordered card; use surfaceAlt blocks inside cards instead. Interim name `AppSurfaceCard` (legacy `app_card.dart` owns `AppCard` in phase 1); rename path: `AppSurfaceCard` → `AppCard` in one codemod once the legacy card has zero usages.
**AppSection**: titleMedium heading + optional "See all" ghost button + optional subtitle; 12 gap to content.
**AppListTile / AppSettingsTile**: min height 56, leading icon in 40px circle (accentSoft bg or
surfaceAlt), title (titleSmall), subtitle (bodySmall textSecondary), trailing (chevron/switch/value).
Dividers inset 72px, 1px border. Group tiles inside one AppCard.
**AppChip / AppStatusChip**: pill, height 32, labelMedium. StatusChip = 8px colored dot + short human
label on `*Soft` background with matching text color; optional info tooltip. Filter chips: selected =
textPrimary fill with white text (or accentSoft + accent text), unselected = surface + border.
**AppBadge**: 18-20px pill, counts, accent or error fill.
**AppInfoTooltip**: 16px "i" icon (textTertiary) that opens a small popover (radius 12, e2) with plain
language explanation; keyboard/screen-reader accessible.
**AppStatTile**: label (labelMedium textSecondary) above value (numberMedium/numberLarge), optional delta
row (arrow icon + signed value in success/error) and caption. Used in 2-column grids with 12 gap.
**AppProgressBar**: 8px height, pill, track surfaceAlt, fill accent (success/warning/error by threshold),
label row above ("0% of 10% limit").
**AppAvatar**: circle 24/32/40/56, image or initials on accentSoft.
**AppScaffold**: SafeArea, background token, consistent horizontal padding, optional large collapsing
title (32 -> 20), optional sticky bottom action bar, pull-to-refresh support, keyboard-safe.
**AppAppBar**: height 56, surface or transparent, no elevation (hairline border on scroll), centered
or left title (titleLarge), back button 44 hit area.
**AppBottomNav**: max 5 items, height 64 + safe area, surface, top hairline, icon 24 + label 12,
active = accent icon + textPrimary label (no pill indicator or a very soft accentSoft one), inactive =
textTertiary. Tablet/desktop: NavigationRail.
**AppSegmentedControl / AppPillTabs**: track surfaceSunken, radius pill, selected segment = surface with
e1, height 40, labelLarge. Scrollable pill row variant for many options (timeframes, categories).
**AppBottomSheet**: top radius 28, drag handle 36x4 (border color) with 12 top gap, padding 24, max height
90%, scrimmed overlay, safe-area bottom padding, primary action pinned at bottom.
**AppDialog**: radius 20, padding 24, title titleLarge, body bodyMedium textSecondary, actions right-aligned
(secondary + primary); destructive confirmations name the object ("Delete 'Invoice #123'?").
**AppSnackBar / AppToast**: floating, radius 12, surface inverse (textPrimary bg), icon + message,
4s, optional action; success/error variants use icon + soft tint, not full saturated fills.
**AppEmptyState**: 64px circle (accentSoft or surfaceAlt) with 28px icon, titleMedium, bodyMedium muted
(max 2 lines), optional AppPillButton. Centered, max width 320.
**AppErrorState**: same layout with error icon, friendly message (what happened + what to do), "Try
again" button; never show raw exceptions (log them instead).
**AppSkeleton / AppShimmer**: mimic the final layout (same radii, heights, gaps); no spinners for
content areas. Interim name `AppShimmerSkeleton` (legacy `app_skeleton.dart` owns `AppSkeleton` in phase 1); rename path: `AppShimmerSkeleton` → `AppSkeleton` in one codemod once the legacy skeleton has zero usages. `AppShimmer` (shimmer-package wrapper), `AppLoader` and `AppNetworkImage` below verified free — no rename.
**AppLoader**: centered 28px accent spinner, only for blocking short actions.
**AppNetworkImage**: radius param, shimmer placeholder, graceful error placeholder.
**AppBanner**: full-width inline notice (info/warning/error/success) with icon, text, optional action,
used for offline / delayed data / maintenance.
**AppDataRow / AppKeyValue**: label left (textSecondary) value right (textPrimary, tabular), 12 gap.
**AppTable (responsive)**: desktop = real table with sticky header (surfaceSunken); mobile = stacked
AppCards per row. Never horizontal-scroll a table on phones unless unavoidable.
**AppChartCard**: AppCard with title, timeframe pills, chart, legend; muted grid, 1.5px lines.

## C9. Screen anatomy (how screens are structured)

**Universal screen skeleton** (top to bottom):
1. `AppScaffold` (SafeArea, background token)
2. `AppAppBar` / large title: screen name (+ 1 optional trailing action)
3. Body scroll view, padding H 20, top 8:
   a. Context header (optional): one-line status/greeting/summary
   b. PRIMARY block: the single most important content (hero card, main list, main form)
   c. Secondary sections, each `AppSection` + cards, 24 gap
   d. Advanced/technical info collapsed in an "Advanced details" accordion (closed by default)
4. Optional sticky bottom action bar: surface, top hairline, padding 16 + safe area, ONE primary
   button (full width) + optional secondary text button
5. Optional bottom nav (top-level screens only)

**Dashboard / home**: greeting or status header -> ONE hero summary card (the key number/status,
numberLarge, plus delta and a plain-language sentence) -> quick actions (horizontal row of 3-4 icon
tiles, 72px) -> sections (recent activity, alerts, insights) as cards. Max 5 sections above the fold
budget; rest behind "See all". Two-column grid on medium/expanded.

**List screen**: AppSearchBar -> horizontal filter pills -> result count/sort row -> list of AppCards or
tiles (12 gap) -> infinite-scroll loader -> pull-to-refresh. States: skeleton list (5 items), empty
(with action), error (retry), no-results-for-filter (with "Clear filters").

**Detail screen**: hero (image/summary) -> title block (titleLarge, subtitle, status chip) -> key stats
(2-col AppStatTile grid) -> grouped info cards (AppDataRow lists) -> related items section -> sticky
action bar for the primary action. Destructive actions live in an overflow menu or at the bottom in
a separated "Danger zone" card, never next to the primary CTA.

**Form screen**: single column (max 560 on large screens), grouped sections with titleMedium headings,
label above field, helper text under, inline validation on blur/submit with clear messages, sticky
bottom primary button, disable + loading state on submit, success feedback via snackbar then navigate.
Long forms: stepper/progress at top (AppProgressBar + "Step 2 of 4").

**Settings screen**: sections with label heading (labelMedium muted), each section is one AppCard of
AppSettingsTiles; account header (avatar + name + email) at top; destructive/logout at bottom,
separated.

**Auth / onboarding**: lots of whitespace, logo or illustration (max 30% height), headlineLarge +
bodyLarge subtitle, form or 1-3 value points, full-width primary CTA, small secondary link below,
no bottom nav, keyboard-safe, max width 420-560.

**Data-heavy / analytics / monitoring screens**: header with asset/entity switcher (pills) and big
live value -> status chip with plain-language explanation -> chart card (primary) -> grid of
AppStatTiles -> explanation cards ("What the system is doing", "Why") -> details accordion. Tables become
cards on mobile. Live data shows "Updated Xs ago" and connection state (AppBanner when delayed/offline).

**Bottom sheet flows**: use for quick pickers/filters/confirmations (<= 1 screen of content). Heavy
flows get their own screen.

**Navigation**: bottom nav (<=5 top-level destinations) on compact, NavigationRail on larger screens;
consistent back behavior; transitions per C7; no nested app bars; modals are sheets or dialogs.

## C10. State patterns (EVERY data-driven screen/card must implement all)
- Loading: skeleton matching final layout (no full-screen spinner except blocking actions).
- Empty: AppEmptyState with friendly line + next action.
- Error: AppErrorState with plain explanation + "Try again"; partial failures use AppBanner so
  the rest of the screen stays usable.
- Offline/stale: AppBanner (warning) + keep showing last data with "Updated Xm ago".
- Success: AppSnackBar with icon, auto-dismiss 4s.
- Disabled: 40% opacity + explanation when not obvious.
- Refresh: pull-to-refresh where the data can change.

## C11. UX writing rules
- Plain, calm, friendly, active voice. Sentence case. No jargon, abbreviations or ALL CAPS.
- Keep the technical term available through AppInfoTooltip or a "Details" expander.
- Buttons: verb-first and short ("Save changes", "Try again"). Avoid "Submit"/"OK".
- Errors: what happened + what to do next. Never expose raw exception text.
- Empty states: friendly + tell the user what will appear here and how to start.
- STATUS PATTERN everywhere: short human label + colored dot/chip + one-sentence "why"
  (e.g. chip "Watching the market" + "The bot is waiting for a clear signal before acting.").
- Numbers: thousands separators, consistent decimals, explicit +/- on deltas, currency symbols,
  relative time ("2 min ago") via central formatters only.
- All strings live in `lib/core/strings/app_strings.dart` (or the project's existing l10n/ARB).

## C12. Accessibility & responsiveness
- Tap targets >= 48x48dp. Semantics labels on icon-only buttons, images, charts (summary text).
- AA contrast in both themes. Visible focus states for keyboard/desktop. Logical focus order.
- Text scale up to 1.3x with no overflow. No information conveyed by color alone.
- Test on small phones (320-360 wide), large phones, tablet, desktop/web widths.
- Respect reduced motion and system dark/light setting (ThemeMode.system as an option).

## C13. Code conventions & folder layout
```
lib/core/design_system/
  tokens/        app_colors.dart, app_spacing.dart, app_radius.dart, app_shadows.dart,
                 app_typography.dart, app_durations.dart, breakpoints.dart
  theme/         app_theme.dart (light + dark ThemeData + AppTokens ThemeExtension),
                 theme_controller.dart (use the project's existing state management)
  extensions/    context_extensions.dart -> context.text, context.tokens,
                   context.gutter, context.screenWidth (context.colors and
                   context.semanticColors live in app_theme_context.dart;
                   isCompact/isMedium/isExpanded are NOT on context — use
                   AppResponsive in src/layout/app_responsive.dart)
  widgets/       one file per App* widget + widgets.dart barrel
  utils/         formatters.dart (currency, number, percent, compact, date, relative time)
  gallery/       design_system_gallery_screen.dart (kDebugMode only)
lib/core/strings/app_strings.dart
```
- Component themes configured in ThemeData: colorScheme, textTheme, scaffoldBackgroundColor,
  appBarTheme, cardTheme, elevated/outlined/text button themes, inputDecorationTheme, chipTheme,
  bottomSheetTheme, dialogTheme, navigationBarTheme, bottomNavigationBarTheme, tabBarTheme,
  snackBarTheme, switchTheme, checkboxTheme, radioTheme, dividerTheme, listTileTheme,
  progressIndicatorTheme, tooltipTheme, pageTransitionsTheme.
- Screens are thin: split into small section widgets (<~150 lines each) in the module's
  `presentation/widgets/` folder. Module-specific widgets still use tokens and App* parts only.
- Use `const` aggressively; avoid rebuilding large trees; keep UI free of logic.
- Forbidden outside `core/design_system/`: `Color(0x`, `Colors.` (except Colors.transparent),
  `TextStyle(fontSize`, raw `EdgeInsets.all(<number>)`/`SizedBox(height: <number>)` with non-token
  values, `BorderRadius.circular(<number>)`, hardcoded `Duration(milliseconds:`, hardcoded user-facing
  strings. Phase QA greps for these.
- Migration adapters: if an old widget is used widely, keep it as a thin wrapper that delegates to the
  new App* widget, then remove it once usages hit zero.

## C14. Testing standard: golden images + responsive evaluation
Goal: prove every screen looks right on every device class, theme, text scale and language, using
generated images that Claude Code actually LOOKS at and judges against this spec.

**Harness (phase-N+5)**
- Use `flutter_test` goldens (`matchesGoldenFile`) with a small project helper
  (`test/goldens/helpers/golden_harness.dart`). Ask me before adding `alchemist` or similar.
- Determinism is mandatory: bundled fonts loaded via `FontLoader` (the default test font Ahem makes
  useless images), `debugDisableShadows = false` so shadows render, fixed clock/time, fake data
  (fakes/mocks at the provider/bloc boundary, never real network/Firebase/websocket), network images
  stubbed with a local asset, animations/shimmer frozen at a fixed frame, no random values.
- Wrap each screen with the REAL app theme, localization delegates, `MediaQuery` (size, devicePixelRatio,
  textScaler, padding for notch/home-indicator), `Directionality`, and navigation shell as in production.
- Goldens are platform-sensitive: generate and compare on ONE consistent platform (document which).
  If the team uses mixed OSes, use a tolerant comparator (threshold <= 0.5%) and document it.
- Output path: `test/goldens/<module>/<screen>/<state>/<device>_<theme>_<locale>_ts<scale>.png`.

**Device matrix (logical px @ dpr)**
| Class | Name | Size | Use |
|---|---|---|---|
| Core | phone-compact | 360x800 @3 | common Android |
| Core | phone-standard | 390x844 @3 | iPhone-size |
| Core | tablet-portrait | 768x1024 @2 | medium breakpoint |
| Core | tablet-landscape | 1180x820 @2 | medium/expanded, nav rail |
| Core | desktop | 1440x900 @1 | expanded, max content width |
| Stress | phone-small | 320x568 @2 | smallest supported, overflow hunter |
| Stress | phone-large | 430x932 @3 | large phones |
| Stress | desktop-wide | 1920x1080 @1 | ultra-wide max-width behavior |
Matrix per screen:
- CORE: Core devices x light/dark x states (loaded, loading, empty, error) x text scale 1.0 x default locale
- STRESS (every screen): phone-small and phone-large x light/dark x loaded x scale 1.0; phone-compact x
  scale 1.3 and 2.0 x loaded
- LOCALE (every screen): phone-compact + tablet-portrait x loaded x each supported language
  (longest-string language and every RTL language mandatory) x light
- Skip combinations that are meaningless (e.g. bottom nav on desktop) but list what was skipped.

**Automated checks alongside images**
- Fail on any `RenderFlex overflowed` / layout exception (`tester.takeException()` must be null).
- `meetsGuideline(androidTapTargetGuideline)`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`,
  `textContrastGuideline` on key screens.
- Forbidden-pattern grep (C13) must be clean for the module before generating images.

**Evaluation loop (phase-N+6, repeat per module)**
1. Generate images (`flutter test --update-goldens` into a staging folder first, NOT as accepted baselines).
2. Build contact sheets per screen (one sheet per state/theme, devices side by side) into
   `docs/ui-redesign/evaluation/contact-sheets/` (use Python/PIL or a Dart script if available).
3. LOOK at every image/contact sheet (view the PNGs). Judge each against the checklist below.
4. Write `docs/ui-redesign/evaluation/<module>.md`: table Screen | Device | Theme | Locale | Scale |
   Result (pass/fail) | Issues | Fix | Re-verified.
5. Fix failures in the UI code (presentation only), regenerate, re-evaluate. Loop until zero fails.
6. Only then bless the images as the baseline goldens and commit them. Never bless unreviewed images.
7. After blessing, plain `flutter test` must pass; CI diffs show changed goldens as review artifacts.

**Visual evaluation checklist (each image)**
- Layout: no overflow, clipping, overlapping, cut-off text, unexpected scroll, empty dead space.
- Hierarchy: ONE clear primary focus; the answer to "what is this / what is happening / what can I do"
  is obvious in 5 seconds.
- Spacing: follows tokens (20 screen padding, 24 section gaps, 12 list gaps, card padding 20); rhythm is consistent.
- Alignment and grid: edges align, columns match the breakpoint rules in C4, content max-width respected
  on large screens, nothing stretched edge-to-edge on desktop.
- Typography: scale per C3, nothing < 12, numbers tabular and aligned, line-height not cramped,
  truncation only on secondary text.
- Components: look exactly like C8 specs (radius, heights, states, chip/dot pattern, buttons pill 44-52).
- Color: accent only for primary actions/active states; green/red only for semantics; contrast AA;
  dark mode not pure black, no shadows, borders/surfaces readable.
- Responsiveness: compact = single column + bottom nav; medium = two columns/side sheets; expanded =
  rail/drawer + max width; tables become cards on compact.
- States: skeleton mirrors final layout; empty/error states centered, friendly, with an action.
- Text scale 1.3x/2.0x: no overflow, layouts reflow, tap targets still >= 48dp.
- Locale/RTL: mirrored layout, icons that imply direction flipped, numbers/dates correct, long
  translations wrap or grow gracefully, script-appropriate font and line-height.
Be a harsh reviewer. Report what is wrong, not what is fine. Never write "looks good" without evidence
(name the image files you inspected).

**Limits (be honest in reports)**: goldens prove layout and styling, not performance, gestures,
keyboard behavior or real notches. The polish phase includes a manual real-device pass
(at least one Android phone, one iPhone, one tablet/web window) with a checklist I run.

## C15. Localization standard
Do NOT guess languages. The localization setup phase STARTS with a quiz (below). Build it properly,
once, in the Flutter-recommended way.

**Quiz (ask me in chat, wait for answers; use the AskUserQuestion tool or equivalent multiple-choice
prompts, 3-4 questions per round, then summarize decisions and ask me to confirm)**
1. Which languages must ship at launch? (multi-select: English, Hindi, Urdu, Arabic, Bengali, Spanish,
   French, German, Portuguese, Indonesian, Turkish, Russian, Chinese (Simplified/Traditional),
   Japanese, Korean, Other: type it). Which are phase-2 "later" languages?
2. Default/source language and fallback language when a translation is missing?
3. Language selection behavior: follow device language, in-app switcher, or both? Persist the choice?
4. Any RTL language (Arabic, Urdu, Hebrew, Persian)? If yes, full layout mirroring is required.
5. Translation source: Claude drafts all translations (flagged "needs native review"), I supply some,
   or a mix? Is there a glossary/brand-term list that must not be translated (product names, tickers,
   currency codes, technical terms)?
6. Regional formats: dates, numbers, currency per locale or fixed? Numeral system for Arabic/Urdu/Hindi
   (Western 0-9 vs native digits)? First day of week? 12h vs 24h time?
7. Is any user-visible text coming from the backend/API/Firebase (error messages, notifications,
   content)? Translate client-side by code, ask backend for locale, or leave as is?
8. Platforms in scope (Android, iOS, web, desktop)? (affects platform locale configuration)
9. Fonts: OK to bundle/download script-specific fonts (e.g. Noto Sans Arabic, Noto Nastaliq Urdu,
   Noto Sans Devanagari/Bengali, Noto Sans CJK) as fallbacks to the main font?
Record answers in `docs/ui-redesign/l10n/DECISIONS.md` and in PROGRESS.md before writing code.

**Architecture (the only accepted approach)**
- `flutter_localizations` + `intl` + official `gen-l10n`: `l10n.yaml`, `lib/l10n/app_<locale>.arb`
  (template = source language), generated `AppLocalizations`. Extension `context.l10n`.
- If `app_strings.dart` exists from the UX-writing phase, MIGRATE it into ARB (delete the Dart constants
  once usages are zero). No parallel string systems.
- ARB rules: every key has `@key` metadata with `description`; typed placeholders
  (`{count}` int, `{amount}` num/currency, `{date}` DateTime with format); ICU `plural`/`select` for
  counts and gender; NEVER concatenate or manually build sentences; keys named
  `<module>_<screen>_<element>` (e.g. `home_balance_title`), shared ones `common_<name>`; no HTML,
  no styling inside strings; rich text via placeholders/spans.
- Formatting: `formatters.dart` takes the active locale and uses `intl` (`NumberFormat`,
  `DateFormat`, currency, compact, relative time). No hardcoded formats, no hardcoded currency symbols.
- `LocaleController` using the project's existing state management; persists choice in existing
  storage; supports "System default"; updates `MaterialApp.locale`, `supportedLocales`,
  `localizationsDelegates`, and `localeResolutionCallback` with the agreed fallback.
- Language picker: Settings row -> AppBottomSheet list (native language names, e.g. "हिन्दी", "العربية",
  "اردو", with the English name as secondary text, current language marked with accent check,
  "System default" first). Built from design-system widgets only.
- Layout robustness: use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start/end`
  (never left/right) everywhere; icons that imply direction (chevrons, back, progress arrows) must
  mirror in RTL (`matchTextDirection` or `Directionality` checks); numbers/IDs/URLs stay LTR inside RTL
  text (use Unicode bidi isolates where needed); charts keep time axes LTR unless I say otherwise.
- Text growth: design for +40% (German/Finnish) and tall scripts (Hindi/Bengali/Arabic need extra
  line-height): add per-script line-height adjustments to typography tokens; never use fixed-height
  text containers; avoid truncating primary content.
- Fonts: main font plus `fontFamilyFallback` per script (C3 font does not cover Arabic/Devanagari/
  Bengali/CJK). Bundle only what the chosen languages need; verify glyphs render (no tofu boxes).
- Platform config: iOS `CFBundleLocalizations`, Android `resourceConfigurations`/locale config, web
  `lang`/`dir`; localized app name/permission strings if applicable.
- Tooling: `flutter gen-l10n` clean, `untranslated-messages-file` reviewed, a check that every ARB has
  every template key with identical placeholders (script or test), no hardcoded user-facing strings left
  (grep for `Text('`, `Text("`, `title: '` etc. outside design_system/gallery and tests).
- Pseudo-localization: add a debug-only pseudo-locale (accented + 40% longer + bracketed, e.g.
  "[Ĥóḿé !!!]") to reveal untranslated text and overflow quickly.
- Glossary: `docs/ui-redesign/l10n/GLOSSARY.md` of domain terms with approved translations per language;
  brand/product/ticker names stay untranslated. Translations are consistent with it.
- Translation quality: Claude drafts natural, UI-appropriate translations (not literal), respects tone from
  C11, keeps strings short, and flags uncertain ones in `docs/ui-redesign/l10n/REVIEW_NEEDED.md` with
  context for a native speaker. Never claim translations are verified.
- Tests: locale-switch widget test, plural/format unit tests for each language, and golden coverage for
  every supported language + RTL (C14 LOCALE matrix).
