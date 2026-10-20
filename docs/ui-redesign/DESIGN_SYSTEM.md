# DESIGN_SYSTEM — tokens, theme, usage rules (phase-0b)

Single source of truth for the additive token layer. Spec = `DESIGN_SPEC.md`
(C2–C7). Nothing here renames or deletes existing symbols; component-theme
geometry is untouched (deferred to module phases).

## 1. File tree (`packages/shared_core/lib/src/theme/` + localization)

```
app_colors.dart            AppColors (light) + AppDarkColors (dark) — authorities
app_semantic_colors.dart   AppSemanticColors ThemeExtension (status families)
app_tokens.dart            AppTokens ThemeExtension (spec-C2 names) [0b NEW]
app_dimensions.dart        existing 8pt scale, radii, shadows, layout (UNCHANGED)
app_spacing.dart           AppSpacing spec-C4 scale [0b NEW]
app_radius.dart            AppRadius spec-C5 scale [0b NEW]
app_shadows.dart           AppShadows e0–e3, light only [0b NEW]
app_durations.dart         AppDurations 150/200/300 [0b NEW]
app_motion.dart            AppMotion 100/160/220/280 (existing authority, UNCHANGED)
breakpoints.dart           Breakpoints <600 / 600–1024 / >1024 [0b NEW]
context_extensions.dart    text / tokens / screenWidth / gutter [0b NEW]
app_theme_context.dart     colors / semanticColors (existing, UNCHANGED)
app_theme.dart             light()+dark() + extensions [semantic, density, tokens]
../localization/app_formatters.dart  AppFormatters + 0b additive methods
```

`isCompact/isMedium/isExpanded` live in `src/layout/app_responsive.dart`
(window-class based) and are NOT duplicated — a 0b draft defining them on
`BuildContext` broke every app (extension collision) and was removed.

## 2. Accent family (brand #215FE6, unchanged hue)

| Token | Light | Dark | Use | AA |
|---|---|---|---|---|
| accent (`AppColors.primary`) | #215FE6 | #3B82F6 | primary buttons, active nav | white on light 5.46:1 ✓ |
| accentPressed | #1E40AF | #2563EB | pressed state | white on light 8.72:1 ✓ |
| accentPressedInk | #FFFFFF | #FFFFFF | text ON pressed fill | light 8.72:1 ✓ / dark 5.17:1 ✓ |
| accentSoft | #E3ECFD | #1E2A4A | chips, selected rows, icon tiles | ink on soft 7.34 / 10.59 ✓ |
| accentInk | #1E40AF | #D5DEFF | text on accentSoft | (same rows) ✓ |
| text on accent (dark base) | #090B10 on #3B82F6 | — | dark button labels (Phase 01.1) | 5.36:1 ✓ |

Rules: ONE accent. Dark buttons MUST flip label ink to `accentPressedInk`
(white) while pressed — dark ink (#090B10) on the pressed fill (#2563EB) is
only 3.81:1 (pre-existing shipped behavior; button themes adopt the flip in
module phases, not in 0b). No gradients. No decorative brand color.

## 3. Info teal-cyan family (NEW semantic resolution in 0b)

| Token | Light | Dark | Use | AA |
|---|---|---|---|---|
| infoBase (`infoTeal`) | #0E7490 | #45B7C7 | dots, icons, strong fills | white 5.36 / dot-on-canvas 5.18 (light) ✓; dot-on-canvas 8.30 (dark) ✓ |
| infoSoft (`infoTealSoft`) | #E6F4F7 | #0C3238 | chip/banner fill | ink on soft 6.45 / 8.63 ✓ |
| infoBorder (`infoTealBorder`) | #9FD0D9 | #1E5A64 | hairline ring (decorative, ~1.5:1 vs soft — not a text pair) | n/a |
| infoInk (`infoTealInk`) | #155E75 | #8FD9E3 | text on soft / teal body text | (same rows) ✓ |

Swatch verdict (viewed `baseline/token_swatch_{light,dark}.png`): info reads
clearly different from accent (teal vs cobalt) in both modes. Against
success: dark mode unmistakable; LIGHT soft fills are near-neighbors (pale
mint vs pale teal) — the pairing rule (icon/dot + label, never color alone)
and the distinct inks (#166534 vs #155E75) carry the distinction. Keep an eye
on it in module phases; no change needed in 0b. Chart series keep ice blue
(per decision) — teal-vs-emerald proximity stays out of charts.

## 4. What the repoint changed (single hunk, easy revert)

`AppSemanticColors.light.info` and `.dark.info` now resolve to the teal
family above (was ice blue #0284C7 / #38BDF8). Everything reading
`semantic.info` / `StatusPill.info` / `StatusColorRole.info` follows:
in-progress stats, QC review, damage-glass minor, KPI info, journey steps.
Domain aliases (`syncQueued`, `damageMinor`) follow automatically.

REVERT (if disliked): in `app_semantic_colors.dart`, restore the light block
to `base/subtle/border/ink = AppColors.info / infoSubtle / infoBorder /
Color(0xFF1D4ED8)` and the dark block to `AppDarkColors.info / infoSubtle /
infoBorder / info`. Nothing else references the teal constants except the
swatch test and this doc.

## 5. Intentionally NOT moved (decided, keep until module phases)

- Supervisor + CRM role-picker icon backgrounds (`AppColors.info` direct) —
  stay ice blue.
- CRM `cyan`/`cyanLight`/`cyanBright` (live dot, accentLight, channel colors)
  — migrate with the CRM module.
- Chart series ice blue (`AppColors.chartSeries[2]`) — charts unchanged.
- `IC.purple`/`purpleBg` in inspection_widgets — dead alias, no usages.
- Hardcoded blue literals in app code: **0** in all 4 apps (only
  `PdfColors.blue900` in PDF generation — not screen UI, out of scope).

## 6. Spacing / radius / shadow / duration / breakpoints (new names)

- `AppSpacing`: xxs 2, xs 4, sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 48,
  huge 64 + screen/card/section/field geometry per C4. Overlap mapping:
  s4→xs, s8→sm, s12→md, s16→lg, s20≈xl(24 — deliberate 20→24 step-up for
  rhythm), s24→xl, s32→xxl. `AppDimensions.s*` untouched.
- `AppRadius`: xs 6, sm 8, md 12, lg 16, xl 20, xxl 28, pill 999 (+ semantic
  aliases card/cardLarge/input/button/chip/dialog/sheetTop/image).
- `AppShadows`: e0 none, e1/e2/e3 per C5 (light only; dark = surface lift +
  border, no shadow). Card rule: border OR shadow, never both.
- `AppDurations`: fast 150, normal 200, slow 300, pageTransition 250,
  shimmerLoop 1200 (+ curves). `AppMotion` (100/160/220/280) stays
  authoritative for existing widgets; new spec work uses these.
- `Breakpoints`: compact <600, medium 600–1024, expanded >1024,
  contentMaxWidth 1200, formMaxWidth 560.

## 7. Context + formatters

- `context.text` (TextTheme), `context.tokens` (AppTokens), `context.gutter`
  (20/24/32 by breakpoint), `context.screenWidth`. No `isCompact` /
  `isMedium` / `isExpanded` here — a 0b draft defining them broke every app
  (extension collision); the existing `AppResponsive`
  (`src/layout/app_responsive.dart`, windowClass-based) owns those names.
  Module phases must use `AppResponsive`, never expect them on context.
- `AppFormatters` existing APIs unchanged. Added: `signedGroup`,
  `signedPercent`, `decimal(decimals:)`, `compactMoneyAED`. Numeral policy
  (frozen): Latin digits 0–9 + ',' grouping in EVERY locale, including ar —
  ar changes month names (`أكتوبر`) and currency placement (`12,450 د.إ`)
  only. `ar` default numeral system: **Western (0-9)**. Covered by
  `test/app_formatters_test.dart` (en + ar, digits/grouping/currency/date/
  relative time + new methods).

## 8. Widget naming (phase-1a, extended 1b)

- **Rule: never collide with an existing widget.** Check `src/widgets/`
  for the spec name first. If taken, build alongside under a distinct
  spec-style name and record the rename path here; module phases adopt the
  new widget, and the polish phase renames it to the spec name in one
  codemod once the legacy widget has zero usages.
- `AppPillButton` (spec `AppButton`; legacy factory owns it).
- `AppInputField` (spec `AppTextField`; legacy owns it). `AppSearchBar` and
  `AppDropdown` verified free — no rename needed.
- `AppSurfaceCard` (spec `AppCard`; legacy `app_card.dart` owns it). Rename path: `AppSurfaceCard` → `AppCard` in one codemod in the polish phase once the legacy card is removed.
- Phase-1d-i naming check: `AppStatTile`, `AppProgressBar`, `AppEmptyState`, `AppErrorState`, `AppBanner` — all spec names verified free in `packages/` (no collisions), no rename path.
- Phase-1d-ii naming check: `AppShimmer`, `AppLoader`, `AppNetworkImage` verified free — no rename. `AppShimmerSkeleton` (spec `AppSkeleton`; legacy `app_skeleton.dart` owns it). Rename path: `AppShimmerSkeleton` → `AppSkeleton` in one codemod in the polish phase once the legacy skeleton is removed.

- New pill button is `AppPillButton` (spec name `AppButton`; renamed because
  the legacy `AppButton` factory in `primary_button.dart` owns that name and
  is off-limits in phase 1). Rename path: once the legacy factory is removed
  in the polish phase, rename `AppPillButton` → `AppButton` in one codemod.
- Same collision rule for later parts: if a spec C8 name already exists in
  `src/widgets/` (`app_text_field.dart`, `app_search_field.dart`,
  `app_dropdown_button.dart`, `app_card.dart` …), build alongside under a
  distinct name and record it here — never modify the existing widget.

## 9. Remaining debt / watch list

- Success base + white (#10B981) = 2.54:1 — pre-existing, fails AA for
  filled buttons; never pair them (use ink-on-soft). Not changed in 0b.
- Dark pressed ink flip (see §2) — adopt in button themes per module phase.
- Teal-vs-success light fills are close — pairing rule (C11/C12) is load
  bearing; reviewers should check status chips side by side in module goldens.
