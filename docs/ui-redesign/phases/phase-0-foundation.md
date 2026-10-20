# Phase 0 — Foundation (tokens, theme, extensions)

## 1. Title + Goal
Build the Airbnb-calibre token/theme foundation in `packages/shared_core` (bridge or swap of the existing Concept-A system) so every later phase has exactly one source of truth. No screens migrated.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: `packages/shared_core/lib/src/theme/*`, new `lib/core/design_system/` tree per C13 (`tokens/`, `theme/`, `extensions/`, `utils/formatters.dart`), `docs/ui-redesign/DESIGN_SYSTEM.md`, wiring into all 4 `main.dart` (`staff/owner/customer/crm`) without breaking existing screens (mixed look expected).
Do NOT touch: `packages/shared_auth/*`, any `apps/*/lib/features/**`, routing, providers/repositories, ARB files, assets.

## 4. Design principles for this phase
C1 (calm/spacious), C2 colors, C3 typography, C4 spacing/breakpoints, C5 shape/elevation, C7 motion, C12 (contrast, text-scale), C13 folder conventions. Light default; dark refined (no pure black).

## 5. Step-by-step tasks
1. Confirm with user: accent (`#FF385C` spec vs existing `#215FE6` + guard test) and font (Inter vs existing Plus Jakarta Sans Variable + IBM Plex Sans Arabic). Record in PROGRESS.md decisions log.
2. Propose folder tree adapting C13 to existing `shared_core/src/theme/` conventions (keep `AppTheme/AppColors/AppDimensions` names where possible; add `AppTokens` ThemeExtension, `AppSpacing/AppRadius/AppShadows/AppDurations`, `Breakpoints`).
3. Implement tokens: `app_colors.dart` (light+dark incl. accent/soft/success/warning/error/info + shimmer pair), `app_typography.dart` (display→label + tabular numbers), spacing/radius/shadow/duration/breakpoints per C2–C7.
4. Build `app_theme.dart` light+dark `ThemeData` with ALL component themes listed in C13; `theme_controller.dart` on riverpod (light/dark/system, persist via existing storage); `context_extensions.dart` (`context.colors/text/spacing/radius/isCompact/isMedium/isExpanded`); `formatters.dart` (currency/number/percent/compact/date/relative, locale-aware via intl).
5. Wire `MaterialApp.router` theme in 4 mains; add `docs/ui-redesign/DESIGN_SYSTEM.md` (token tables + usage rules + file tree).
6. Run `flutter analyze`, boot each app light+dark, grep forbidden patterns inside new files (must be zero).

## 6. Screen-by-screen plan
N/A (no screens). Gallery placeholder only; screens come from phase-1 onward.

## 7. UX writing rules
No user-facing strings in this phase except debug gallery labels (lowercase, sentence case).

## 8. Responsive + accessibility checklist
Tokens meet AA (verify accent on white + white on accent); no text < 12; breakpoints helper works at 320/360/390/768/1180/1440; `ThemeMode.system` option respected; reduced-motion honored in durations.

## 9. QA checklist (pass/fail)
- [ ] No `Color(0x`/`Colors.`/`TextStyle(fontSize`/raw EdgeInsets/BorderRadius/Duration outside `core/design_system/` additions
- [ ] Light + dark boot in all 4 apps
- [ ] No overflow at 1.3x text scale on gallery placeholder
- [ ] Tap targets ≥ 48dp where applicable
- [ ] `git diff --stat` shows theme/token files only
- [ ] `flutter analyze` clean

## 10. Definition of done
Update PROGRESS.md (tick phase-0, session log), finalize DESIGN_SYSTEM.md, give commit message (e.g. `design-system: add Airbnb tokens + light/dark theme foundation`).

## 11. Ask me first
Accent color swap vs bridge (guard test!), font choice, light-first vs dark parity scope, whether to keep Concept-A names (`AppDimensions.s*`) or migrate to `AppSpacing`.
