# Orient Design System

## Principles

The interface should feel operational, calm, premium, and fast. It should not look like a default Flutter template or a set of unrelated cards. Use whitespace, type, sections, dividers, and alignment before adding containers.

## Color

Use `Theme.of(context).colorScheme` and semantic colors from `AppColors`. Brand color is injected through `BrandConfig` and becomes `colorScheme.primary`.

Semantic usage:
- Primary: main action, selected nav, focused input.
- Surface: grouped tools, sheets, dialogs, repeated list items.
- Background: app canvas.
- Success, warning, danger, info: status and feedback only.
- Outline/line: subtle boundaries.

Avoid hardcoded colors inside screens except when extending the shared theme.

## Typography

Use the shared text theme from `AppTypography`. The product typeface is Google Fonts `Inter`, with JetBrains Mono reserved only for compact technical values where a monospaced face helps scanning. Screens should map text by hierarchy:
- Page title: screen identity.
- Section title: task grouping.
- Body: facts and explanatory copy.
- Label: metadata, filters, chips.
- Button: clear action verbs.

Do not scale font size from viewport width. Support platform text scaling by letting Flutter text layout naturally wrap.

## Spacing And Radius

Use `AppDimensions` tokens. Standard page padding comes from `context.pagePadding`. Cards and framed tools should use small to moderate radii; repeated item cards should stay restrained.

## Responsive Pattern

Use `AppResponsive` and `BuildContext` extensions:
- `context.windowClass`
- `context.isCompact`
- `context.isMedium`
- `context.isExpanded`
- `context.isLarge`
- `context.pagePadding`
- `context.contentMaxWidth`
- `context.gridColumns`

Screens should rearrange structure by available space rather than stretch mobile layouts.

## Page Structure

Use `AppResponsivePage` for regular pages. It provides:
- background from theme
- responsive padding
- optional max content width
- scroll behavior
- consistent safe area handling

Use `AppSplitView` where list/detail workflows benefit from side-by-side layouts on larger screens.

## Components

Shared components live in `packages/shared_core`.

Core components:
- `DashboardShell`: app frame with offline state and responsive background.
- `AppResponsivePage`: standard page canvas and constraints.
- `Auth2026Shell`, `Auth2026TextField`, `Auth2026PrimaryButton`, `Auth2026OtpField`: from-scratch auth surfaces.
- `AppCard`: repeated items or framed tools.
- `EmptyState`, `ErrorView`, `LoadingIndicator`: user-facing states.
- `PrimaryButton`, text fields, dropdowns, status pills, avatar, profile sheet.

## Forms

Compact screens use a single column. Medium and larger screens may use two columns when fields are independent. Form width should be constrained so users do not scan long horizontal lines.

## Navigation

Mobile: bottom navigation plus contextual bottom sheets.
Tablet: navigation rail and split views where useful.
Desktop/web: persistent navigation and contextual toolbar or side panel.

Navigation labels should name user goals, not implementation modules.

## Motion

Motion should confirm state changes and guide attention. Keep it short and functional: pressed states, loading transitions, selected navigation, and sheet/dialog transitions. Avoid decorative motion.

## States

Every important surface must handle loading, loaded, empty, error, offline, disabled, selected, hover, pressed, focus, and success states where applicable. Empty and error states must include a useful next action.
