# Phase 1 — Shared widgets (App* suite + gallery)

## 1. Title + Goal
Build every C8 component in `lib/core/design_system/widgets/` (one file per App* widget + barrel) plus app-specific shared replacements found in the audit, with a debug-only gallery. Migrate zero screens.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: `packages/shared_core/lib/src/widgets/*` (AppButton/IconButton/TextField/SearchBar/Card/Section/ListTile/SettingsTile/Chip/StatusChip/Badge/InfoTooltip/StatTile/ProgressBar/Avatar/Scaffold/AppBar/BottomNav/SegmentedControl/PillTabs/BottomSheet/Dialog/SnackBar/Empty/Error/Skeleton/Shimmer/Loader/NetworkImage/Banner/DataRow/KeyValue/Table/ChartCard), `gallery/design_system_gallery_screen.dart` (kDebugMode only), thin adapters for `PrimaryButton/SecondaryButton→AppButton`, `StatusPill→AppStatusChip`, `ProfileSheet→AppBottomSheet`.
Do NOT touch: `apps/*/lib/features/**` screens, `shared_auth`, routing, providers.

## 4. Design principles
C2–C8 full component specs; C10 states per widget; C12 (48dp, semantics, 1.3x scale, AA); C13 (tokens only, const, <150-line files).

## 5. Step-by-step tasks
1. Implement widgets to exact C8 sizes (button 52/44/36 pill; textfield h52 r12; chip h32 pill; sheet r28+handle; dialog r20 pad24; card r16–20 pad20; skeleton mirrors layout; shimmer 1200ms frozen in tests).
2. Dedupe audit findings: absorb private `_SignOutButton/_GreaseButton/_BellButton/_FilterButton` into AppButton/IconButton; route `NotificationBell/PendingSyncChip/OfflineBanner` through new tokens.
3. Build gallery showing each component × variant × state in light+dark.
4. Grep forbidden patterns in `shared_core` widgets; fix.

## 6. Screen-by-screen plan
Gallery only: sections per C8 group (actions/inputs/cards/tiles/feedback/states). Each demo notes which old widget it replaces and adapter path.

## 7. UX writing rules
Use C11 placeholder copy only (no real strings yet); buttons verb-first; errors `what happened + what to do`.

## 8. Responsive + accessibility checklist
Semantics on icon-only buttons/images/charts; focus states; 48dp; 1.3x scale gallery pass at 320/390/768 widths.

## 9. QA checklist
- [ ] All C8 widgets exist with doc example + const
- [ ] Light+dark gallery OK; states (loading/empty/error/disabled) present
- [ ] No forbidden patterns in scope; `flutter analyze` clean; UI-only diff

## 10. Definition of done
Update PROGRESS.md, document new widgets in DESIGN_SYSTEM.md, commit message (e.g. `design-system: add App* widget suite + gallery`).

## 11. Ask me first
Icon set (Lucide vs Material Symbols Rounded — `lucide_icons` not installed, ask before adding); `cached_network_image` vs hand-rolled `AppNetworkImage`; keeping `PrimaryButton` name as adapter.
