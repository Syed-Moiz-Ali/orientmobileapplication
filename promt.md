# MASTER CODEX PROMPT

## Complete Flutter Application UI/UX, Responsive System, Architecture & QA Overhaul — 2026 Standards

You are taking ownership of an EXISTING production Flutter project.

This is NOT a simple UI cleanup task.

You must operate simultaneously as:

- Principal Flutter Engineer
- Senior Flutter Architect
- Senior Product Designer
- UI/UX Engineer
- Responsive Design Engineer
- Accessibility Engineer
- Flutter Web Engineer
- Flutter Windows/Desktop Engineer
- Android Engineer
- iOS Engineer
- Melos Monorepo Engineer
- Design System Architect
- QA Automation Engineer
- Manual QA Tester
- Performance Engineer
- Code Reviewer
- Product Quality Engineer

Your job is to:

> Analyze the complete repository from root to leaf and then redesign/refactor the application into an extraordinary, premium, modern, clean, responsive, scalable, maintainable, production-quality Flutter application following 2026 engineering and UI/UX standards.

DO NOT only provide recommendations.

DO NOT stop after analysis.

DO NOT create a report and wait for approval.

Perform the actual implementation.

---

# 1. PRIMARY OBJECTIVE

The final application must feel like a professionally designed commercial product, not like a collection of independently designed Flutter screens.

It must have:

- premium modern UI
- excellent UX
- clean visual hierarchy
- consistent typography
- consistent spacing
- consistent component styling
- excellent responsiveness
- adaptive platform behavior
- intuitive navigation
- professional forms
- meaningful states
- polished animations
- accessibility
- keyboard support
- touch support
- mouse support
- responsive dialogs
- responsive sheets
- responsive navigation
- excellent loading states
- excellent error states
- empty states
- disabled states
- success states
- hover states
- focus states
- pressed states
- selected states
- validation states

The application must work properly on:

- small Android phones
- normal Android phones
- large Android phones
- iPhones
- small iPhones
- large iPhones
- tablets
- foldable-like widths
- portrait tablets
- landscape tablets
- Flutter Web
- laptop browsers
- desktop browsers
- Windows desktop
- ultrawide displays

The UI must NOT simply stretch when more space is available.

It must intelligently adapt its structure.

---

# 2. VERY IMPORTANT — FIRST ANALYZE THE ENTIRE PROJECT

Before changing UI code, inspect the entire repository.

Determine:

- Melos workspace structure
- Flutter applications
- shared packages
- feature packages
- UI packages
- theme implementation
- routing
- navigation
- state management
- API layer
- repository layer
- models
- services
- local storage
- authentication
- reusable widgets
- common widgets
- extensions
- utilities
- responsive utilities
- existing breakpoint logic
- typography
- colors
- spacing
- dialogs
- bottom sheets
- forms
- loaders
- notifications
- snackbars
- tables
- lists
- grids
- cards
- charts
- images
- icons
- animations
- localization
- accessibility
- tests
- lint configuration
- assets
- package dependencies
- app-specific duplicated code
- shared duplicated code
- deprecated implementations
- dead UI code
- legacy components
- inconsistent UI patterns

Also identify:

- every screen
- every route
- every dialog
- every modal
- every bottom sheet
- every form
- every reusable section
- every important user interaction
- every CTA
- every navigation path

Create an internal project map before performing the makeover.

---

# 3. DO NOT DESTROY EXISTING BUSINESS LOGIC

UI modernization must NOT unnecessarily rewrite working business logic.

Preserve:

- APIs
- DTOs
- repositories
- authentication
- backend contracts
- model serialization
- business rules
- permissions
- existing working features
- deep links
- storage
- analytics
- backend integrations

unless something is demonstrably broken or poorly structured.

Separate:

UI refactoring

from

business logic modification.

Do not change backend contracts only because the UI is being redesigned.

---

# 4. CREATE A CENTRALIZED DESIGN SYSTEM

One of the most important requirements:

I DO NOT want arbitrary styling inside individual screens.

Create a proper centralized Flutter design system.

Screens should consume the design system.

Create/reorganize an appropriate shared UI/design-system package in the Melos workspace if beneficial.

The architecture may contain concepts such as:

```text
design_system/
  theme/
  tokens/
  typography/
  spacing/
  radius/
  shadows/
  motion/
  icons/
  responsive/
  components/
  layouts/
  feedback/
  forms/
```

Use the project's architecture conventions where appropriate.

Do not blindly create this exact structure if a better architecture already exists.

---

# 5. CENTRALIZED COLORS

Do NOT scatter:

```dart
Colors.white
Colors.black
Color(0xFF...)
```

throughout feature screens unless there is a legitimate contextual reason.

Use centralized semantic colors integrated with Flutter themes.

Prefer:

```dart
Theme.of(context)
```

and appropriate ThemeExtensions / ColorScheme / custom semantic tokens.

Define semantic concepts such as:

- primary
- secondary
- surface
- background
- elevatedSurface
- textPrimary
- textSecondary
- textDisabled
- border
- divider
- success
- warning
- error
- information
- accent
- overlay
- selected
- hover
- focus

Support:

- light mode
- dark mode

if appropriate for the application.

Components should respond automatically to theme changes.

---

# 6. CENTRALIZED TYPOGRAPHY

There must be no random font sizes scattered across screens.

Create a reusable typography hierarchy.

For example:

- displayLarge
- displayMedium
- headingLarge
- headingMedium
- headingSmall
- titleLarge
- titleMedium
- titleSmall
- bodyLarge
- bodyMedium
- bodySmall
- labelLarge
- labelMedium
- caption

Use:

```dart
Theme.of(context).textTheme
```

or a centralized semantic typography layer.

Typography must adapt appropriately to screen classes without destroying readability.

Respect system accessibility text scaling.

Do NOT use hacks that globally disable text scaling.

---

# 7. CENTRALIZED SPACING SYSTEM

Create proper spacing tokens.

For example conceptually:

```text
xxs
xs
sm
md
lg
xl
xxl
section
page
```

Replace arbitrary values like:

```dart
Padding(
  padding: EdgeInsets.all(13.7),
)
```

unless a precise design requirement truly needs it.

Pages, cards, forms, sections and components should share the same spacing rhythm.

---

# 8. CENTRALIZED RADII, ELEVATION & SHADOWS

Create reusable tokens for:

- border radius
- card radius
- input radius
- button radius
- dialog radius
- modal radius
- elevation
- shadows

Avoid every widget having independently invented visual styling.

---

# 9. BUILD ONE CENTRALIZED RESPONSIVE ENGINE

THIS IS A CRITICAL REQUIREMENT.

I do NOT want every screen containing random code such as:

```dart
if (width < 600)
```

or:

```dart
MediaQuery.of(context).size.width
```

everywhere.

Build ONE centralized responsive/adaptive system.

Screens should consume that system.

Example conceptual APIs:

```dart
context.deviceClass
context.isCompact
context.isMedium
context.isExpanded
context.isDesktop
context.isTablet
context.isMobile
```

and/or:

```dart
ResponsiveBuilder
AdaptiveLayout
ResponsiveValue<T>
AppBreakpoints
AppPageConstraint
AppGrid
AppResponsivePadding
```

The exact implementation should follow sound Flutter architecture.

The central engine should determine:

- breakpoints
- horizontal padding
- vertical padding
- max content width
- grid columns
- navigation type
- dialog width
- form width
- card width
- content density
- sidebar behavior
- modal presentation
- number of columns
- master/detail layout
- navigation rail behavior
- bottom navigation behavior

Once defined centrally, screens should receive responsive behavior automatically wherever reasonable.

---

# 10. RESPONSIVE ≠ SCALE EVERYTHING

Do NOT solve responsiveness using proportional scaling of the entire screen.

Avoid:

```dart
width * 0.8
height * 0.09
```

for normal layout decisions.

Avoid blindly multiplying everything by screen width.

Prefer Flutter constraints:

- LayoutBuilder
- Flex
- Expanded
- Flexible
- Wrap
- GridView
- Sliver
- ConstrainedBox
- FractionallySizedBox when appropriate
- Intrinsic sizing only when appropriate
- adaptive columns
- max-width containers
- responsive grid systems

Responsive behavior must be constraint-driven.

---

# 11. RECOMMENDED RESPONSIVE CLASSES

Analyze the application requirements and define suitable breakpoints centrally.

A reasonable starting model could conceptually be:

```text
Compact
Medium
Expanded
Large
Extra Large
```

Do not hardcode these throughout screens.

All breakpoint values must originate from ONE centralized definition.

Different platforms should then consume semantic device/window classes.

---

# 12. CONTENT MAX WIDTH

Large monitors must NOT produce giant stretched forms or unreadable text lines.

Implement centralized page constraints.

For example:

```text
Mobile:
full width with safe padding

Tablet:
larger margins and multi-column opportunities

Desktop:
centered constrained content

Wide Desktop:
max content width + intentional whitespace
```

Forms especially should not stretch across a 1920px screen.

---

# 13. ADAPTIVE NAVIGATION

Navigation must adapt according to available space.

Example behavior:

### Compact

Bottom navigation / drawer / appropriate mobile navigation.

### Medium

Navigation rail where appropriate.

### Expanded

Navigation rail or sidebar.

### Large Desktop

Persistent navigation/sidebar with properly constrained content.

Do not implement this independently on every page.

Create a reusable application shell.

Possible concept:

```dart
AppShell
AdaptiveScaffold
AppNavigationShell
```

The shell should centrally control:

- navigation
- app bar
- sidebar
- navigation rail
- bottom navigation
- drawer
- page container
- content max width
- desktop layout
- selected states

---

# 14. PLATFORM ADAPTATION

Understand differences between:

- Android
- iOS
- Web
- Windows

Do not merely run the same oversized mobile UI everywhere.

Account for:

### Mobile

- touch targets
- thumb reach
- bottom navigation
- sheets
- mobile forms
- gesture expectations

### Tablet

- larger information density
- multi-column layouts
- split views when appropriate

### Web

- browser resizing
- keyboard
- hover
- mouse
- tab navigation
- URL navigation
- responsive widths
- desktop information density

### Windows

- desktop density
- mouse interactions
- keyboard interactions
- window resizing
- hover
- focus
- tooltips
- dialogs
- shortcuts where useful

### iOS

Respect safe areas and expected platform interaction patterns.

Do not unnecessarily duplicate entire screen implementations per platform.

Use adaptive components and shared behavior.

---

# 15. SAFE AREA & SYSTEM UI

Audit:

- SafeArea
- keyboard overlap
- bottom system navigation
- status bar
- notches
- iPhone dynamic island areas
- desktop title/window areas
- responsive keyboard layouts

No important element should be hidden behind system UI.

---

# 16. CREATE PRODUCTION-GRADE REUSABLE COMPONENTS

Identify repeating patterns and convert them into reusable components.

Potential components:

```text
AppButton
AppIconButton
AppTextField
AppSearchField
AppDropdown
AppCheckbox
AppRadio
AppSwitch
AppCard
AppSection
AppHeader
AppBadge
AppChip
AppAvatar
AppListTile
AppEmptyState
AppErrorState
AppLoadingState
AppSkeleton
AppDialog
AppBottomSheet
AppSnackbar
AppToast
AppTable
AppPagination
AppResponsiveGrid
AppPage
AppScaffold
AppShell
AppImage
AppDivider
AppTooltip
AppStatusBadge
AppFormSection
AppDatePicker
```

Do NOT create unnecessary abstraction.

Only extract reusable design behavior.

---

# 17. BUTTON SYSTEM

Buttons must have standardized:

- heights
- spacing
- radius
- typography
- icons
- loading state
- disabled state
- pressed state
- hover state
- focus state

Support semantic variants such as:

- primary
- secondary
- outline
- ghost
- destructive

Avoid manually styling ElevatedButton differently on every screen.

---

# 18. INPUT / FORM SYSTEM

Forms must look polished and behave correctly.

Standardize:

- labels
- placeholders
- helper text
- validation
- error states
- enabled
- disabled
- read-only
- focus
- hover
- prefixes
- suffixes
- password visibility
- formatting
- required fields

Forms should have sensible maximum widths.

Ensure proper keyboard configuration:

```text
text
email
phone
number
decimal
password
multiline
```

Implement:

- next field action
- submit action
- focus traversal
- keyboard dismissal where appropriate

---

# 19. LOADING UX

Do not use only generic spinning indicators everywhere.

Implement context-appropriate loading states.

Use:

- button loading
- page skeletons
- list skeletons
- card skeletons
- progress states

Prevent accidental duplicate API requests from repeated taps.

---

# 20. EMPTY STATES

Every important empty collection needs meaningful UX.

Examples:

- no records
- no search results
- no notifications
- no activity
- no history
- no data

Include helpful action where appropriate.

---

# 21. ERROR STATES

Implement professional error handling UI.

Account for:

- no internet
- timeout
- API error
- server error
- authorization error
- validation error
- unknown error

Where appropriate provide:

- retry
- refresh
- login again
- back
- contextual explanation

Do not expose raw stack traces or backend errors to users.

---

# 22. INTERACTION AUDIT

Inspect EVERY user-interactive element.

Check:

- onTap
- onPressed
- gestures
- CTA buttons
- cards
- dropdowns
- checkboxes
- links
- back buttons
- search
- filters
- dialogs
- date pickers
- navigation
- pagination
- upload
- download
- logout
- delete
- submit

Determine whether each interaction:

- actually works
- gives feedback
- handles loading
- prevents double-click
- handles errors
- handles disabled conditions
- works with mouse
- works with touch
- works with keyboard where appropriate

Remove dead taps.

Do not leave buttons that visually appear interactive but do nothing.

---

# 23. DIALOG SYSTEM

Dialogs must be responsive.

Do not show a huge dialog on desktop or overflowing dialog on mobile.

Implement centralized constraints.

Mobile may use:

- dialog
- bottom sheet
- full-screen sheet

depending on context.

Desktop may use constrained modal dialogs.

---

# 24. BOTTOM SHEETS

Audit every bottom sheet.

Ensure:

- safe areas
- draggable content if appropriate
- keyboard handling
- scrollable content
- maximum desktop width
- responsive behavior

Do not blindly use a phone-style 100%-width bottom sheet on a wide desktop.

---

# 25. LISTS, TABLES & GRIDS

Determine the correct representation based on available width.

For example:

### Mobile

Cards / compact list.

### Tablet

Multi-column cards or richer list.

### Desktop

Data table or detailed row layout where appropriate.

Create shared responsive patterns rather than duplicating features.

---

# 26. INFORMATION HIERARCHY

Every redesigned screen should clearly communicate:

1. Where am I?
2. What is this page?
3. What is the primary information?
4. What is the main action?
5. What are secondary actions?
6. What requires attention?
7. How do I move to the next task?

Remove visual clutter.

Do not over-design.

Premium UI comes from hierarchy and consistency, not random gradients.

---

# 27. 2026 VISUAL DIRECTION

Target:

- clean
- premium
- modern
- confident
- minimal
- spacious
- sophisticated
- high usability
- subtle depth
- polished micro-interactions
- strong typography
- excellent information hierarchy

Avoid:

- excessive gradients
- random glowing borders
- unnecessary glassmorphism
- oversized cards
- excessive pills
- random rounded containers
- huge whitespace without purpose
- tiny text
- excessive animation
- decorative clutter
- inconsistent icons
- heavy shadows

The product should look intentionally designed.

---

# 28. MOTION SYSTEM

Create centralized motion tokens.

Examples:

```text
fast
normal
slow

standard curve
emphasized curve
```

Use subtle animations for:

- navigation
- expansion
- selection
- list insertion
- modal entrance
- state transition
- loading transition

Respect accessibility/reduced motion settings where possible.

Do not animate everything.

---

# 29. ICONOGRAPHY

Audit all icons.

Use a consistent icon language.

Avoid mixing visually unrelated icon families unnecessarily.

Standardize:

- icon sizes
- button icon sizes
- navigation icons
- semantic icons

Use icons only where they improve comprehension.

---

# 30. ACCESSIBILITY

Perform accessibility audit across the project.

Implement/fix:

- semantics
- labels
- touch target sizes
- contrast
- keyboard traversal
- focus states
- screen reader labels
- tooltip support
- text scaling
- logical reading order

Avoid icon-only actions without tooltip/semantic meaning where the action is not obvious.

---

# 31. KEYBOARD & DESKTOP UX

Flutter Web/Windows must support:

- Tab
- Shift+Tab
- Enter
- Escape
- arrow keys where appropriate
- focus indication
- keyboard submission
- keyboard dialog closing
- mouse hover
- scroll wheel
- correct pointer cursor for clickable elements

Users should not be forced to interact like a mobile user on desktop.

---

# 32. RESPONSIVE IMAGE HANDLING

Images must:

- preserve aspect ratio
- use correct fit
- avoid stretching
- handle loading
- handle failure
- be properly constrained
- avoid unnecessarily decoding huge images

Audit every image usage.

---

# 33. TEXT OVERFLOW

Test every important UI with:

- long names
- long email addresses
- long titles
- long descriptions
- long localized strings
- very large numbers
- empty values
- null values

Handle:

- wrapping
- ellipsis
- maxLines
- flexible layouts

Never hide important information accidentally.

---

# 34. STATE MANAGEMENT

Do NOT move business state into UI merely for convenience.

Respect existing state management architecture.

Separate:

```text
View
State
Business logic
Repository
Service/API
```

Refactor only where necessary to improve maintainability.

---

# 35. MELos MONOREPO REQUIREMENTS

Treat this as a Melos-managed professional monorepo.

Analyze:

```text
melos.yaml
pubspec.yaml
workspace dependencies
apps/
packages/
shared packages
feature packages
```

Look for duplicated UI implementations between apps.

Move genuinely reusable UI functionality into shared packages.

Examples:

```text
design_system
core
shared_ui
responsive
common_widgets
```

only if they align with current architecture.

Do NOT unnecessarily create dependencies between unrelated features.

Preserve clean package boundaries.

Run Melos commands from appropriate workspace context.

---

# 36. CENTRALIZATION RULE

If multiple screens need the same behavior, first consider whether it belongs centrally.

Examples:

```text
Screen padding
Breakpoints
Text styles
Buttons
Inputs
Dialogs
Cards
Navigation
Loading UI
Errors
Empty states
Animations
Page width
Grid rules
Accessibility behavior
```

Future developers should be able to build a new screen mostly by composing standardized components.

---

# 37. AVOID OVER-ABSTRACTION

Centralized does NOT mean everything becomes a generic widget.

Avoid abstractions like:

```dart
WidgetFactory.buildThing(
 type: 57,
 variant: 3,
 config: ...
)
```

Prefer simple, explicit, type-safe Flutter APIs.

The design system should make development easier, not harder.

---

# 38. CODE QUALITY

Maintain:

- null safety
- modern Dart
- modern Flutter
- const constructors
- immutable widgets
- final where appropriate
- meaningful naming
- small widgets
- reusable components
- limited build complexity
- clean imports
- no dead code
- no duplicate implementation
- lint compliance

Avoid massive 1000+ line screen files.

Extract logical sections.

---

# 39. PERFORMANCE AUDIT

Review and improve:

- unnecessary rebuilds
- expensive build methods
- nested scrolling
- shrinkWrap misuse
- ListView misuse
- large image decoding
- unnecessary providers/listeners
- repeated API calls
- repeated parsing
- excessive animations
- huge widget trees
- blocking synchronous operations
- poor pagination
- unnecessary GlobalKeys

Maintain smooth scrolling and responsive interaction.

---

# 40. RESPONSIVE TEST MATRIX

Test at minimum conceptually against widths similar to:

```text
320
360
375
390
412
430
480
600
768
820
1024
1280
1366
1440
1600
1920
2560
```

And appropriate heights.

Test:

- portrait
- landscape
- window resizing
- browser resizing

Do not design only for one emulator.

---

# 41. DEVICE TARGETS

Validate UI against representative device classes such as:

### Android

- compact Android
- Pixel-like phone
- large Android phone

### iOS

- compact iPhone
- standard iPhone
- Pro Max sized iPhone

### Tablet

- small tablet
- iPad-like tablet
- large tablet

### Desktop

- 1366×768
- 1440×900
- 1920×1080
- wide screen

---

# 42. CREATE UI/UX TEST CASES

Act as a MANUAL TESTER.

For every screen create/use test scenarios covering:

### Rendering

- page loads
- layout correct
- alignment correct
- no overflow
- no clipped text

### Navigation

- forward
- back
- deep navigation
- repeated navigation

### Buttons

- enabled
- disabled
- loading
- rapid tap

### Forms

- empty
- invalid
- valid
- max length
- special characters
- keyboard
- submission

### API

- loading
- success
- empty
- error
- retry

### Responsive

- compact
- medium
- desktop
- landscape

### Accessibility

- keyboard
- focus
- semantic labels
- text scaling

### Desktop

- mouse
- keyboard
- resizing
- hover

---

# 43. AUTOMATED TESTING

Where practical implement:

### Unit tests

For important UI-related logic and responsive calculations.

### Widget tests

For:

- important reusable components
- forms
- validation
- loading
- errors
- navigation states
- important pages

### Golden tests

Use golden/screenshot tests for important visual components/screens where practical.

Test representative viewport sizes.

Golden coverage is especially useful for detecting UI regressions.

### Integration tests

Cover major end-to-end user flows.

---

# 44. TEST EDGE CASES

Always test:

```text
null
empty
loading
failure
offline
slow network
long text
large accessibility text
rapid taps
double submit
back during loading
rotate screen
resize window
very small width
very large width
keyboard open
keyboard navigation
```

---

# 45. OVERFLOW POLICY

The final application should contain NO avoidable:

```text
RenderFlex overflowed
Bottom overflow
Horizontal overflow
Unbounded constraint errors
Clipped CTA
Unreachable field
```

Fix root causes.

Do not hide errors by wrapping everything in SingleChildScrollView.

---

# 46. SCREEN AUDIT REGISTRY

Create and maintain a persistent file such as:

```text
docs/ui_ux_screen_registry.md
```

or another appropriate location.

Track:

```text
App
Feature
Screen
Route
File
UI Refactored
Responsive
Accessibility
Widget Tests
Golden Tests
Manual QA
Issues
Status
```

Suggested statuses:

```text
NOT_STARTED
IN_PROGRESS
IMPLEMENTED
TESTED
VERIFIED
BLOCKED
```

This must survive future Codex sessions.

When new screens are added later, we should know what has already been completed.

Do NOT repeatedly redesign verified unchanged screens without reason.

---

# 47. DESIGN SYSTEM DOCUMENTATION

Create:

```text
docs/design_system.md
```

Document:

- colors
- typography
- spacing
- radius
- breakpoints
- layout system
- responsive rules
- page constraints
- components
- buttons
- forms
- navigation
- dialogs
- feedback
- animation

A future Flutter developer should understand how to create a compliant screen without inventing styling.

---

# 48. RESPONSIVE SYSTEM DOCUMENTATION

Create:

```text
docs/responsive_system.md
```

Explain:

- breakpoint definitions
- device classes
- content max width
- page padding
- grid behavior
- navigation switching
- dialogs
- sheets
- mobile/tablet/desktop behavior

Include practical usage examples.

---

# 49. UI QA REPORT

Create/update:

```text
docs/ui_qa_report.md
```

Track:

- tested screens
- device classes tested
- edge cases
- failures discovered
- failures fixed
- remaining known issues

Do not claim a test passed unless it was actually executed or logically validated.

---

# 50. IMPLEMENTATION PHASES

Perform the project in a disciplined sequence.

## PHASE 1 — Repository Audit

Inspect everything.

Document architecture, screens, duplicate components and UI problems.

---

## PHASE 2 — Foundation

Build/refactor:

- theme
- color system
- typography
- spacing
- radius
- shadows
- responsive engine
- motion tokens
- page constraints

---

## PHASE 3 — Core Components

Build reusable:

- buttons
- inputs
- cards
- dialogs
- loading
- error
- empty state
- responsive page
- app shell
- navigation

---

## PHASE 4 — Navigation / Shell

Modernize application-level:

- scaffold
- navigation
- sidebar
- rail
- bottom nav
- app bars
- responsive content container

---

## PHASE 5 — Screen-by-Screen Redesign

For EACH screen:

1. understand user objective
2. identify primary CTA
3. identify information hierarchy
4. inspect current UX problems
5. redesign layout
6. reuse design system
7. implement responsive layout
8. implement states
9. verify interactions
10. test mobile
11. test tablet
12. test desktop
13. test web
14. test Windows
15. mark registry

Do NOT only refactor the first few screens.

Continue across the entire app.

---

## PHASE 6 — Interaction Audit

Verify every:

```text
button
tap
gesture
form
dialog
modal
dropdown
navigation action
CTA
link
```

---

## PHASE 7 — Responsive QA

Run against representative screen dimensions.

Fix every discovered overflow/layout defect.

---

## PHASE 8 — Automated Tests

Add/update tests.

---

## PHASE 9 — Full Project Validation

Run relevant commands such as:

```bash
flutter pub get
flutter analyze
flutter test
```

and appropriate Melos equivalents such as:

```bash
melos bootstrap
melos run analyze
melos run test
```

depending on workspace scripts.

Also run formatting/lints required by the repository.

Do NOT assume scripts exist.

Read `melos.yaml` first.

---

# 51. DO NOT MAKE THESE MISTAKES

Do NOT:

- rebuild business logic unnecessarily
- break APIs
- change backend contracts unnecessarily
- scatter colors
- scatter text sizes
- scatter spacing
- scatter breakpoints
- use MediaQuery randomly everywhere
- scale the whole app proportionally
- make desktop look like stretched mobile
- make mobile look like compressed desktop
- hardcode widths unnecessarily
- create giant widget files
- duplicate components
- blindly use SingleChildScrollView
- hide overflow bugs
- overuse gradients
- overuse glass effects
- overuse animations
- use tiny text
- add decorative complexity
- ignore dark mode
- ignore keyboard
- ignore mouse
- ignore accessibility
- ignore empty/error/loading states
- leave non-working buttons
- leave TODO UI
- stop after analyzing

---

# 52. CODEX AUTONOMY

You are authorized to modify project files necessary for this UI/UX modernization.

You should:

1. inspect
2. reason
3. implement
4. run analyzer
5. run tests
6. identify failures
7. fix failures
8. repeat

Do not ask for confirmation for normal implementation decisions.

Use the existing application's product purpose and data to infer appropriate UX.

When there is ambiguity, make the most professional, maintainable choice consistent with the existing product.

---

# 53. KEEP THE PROJECT BUILDABLE

Do not perform hundreds of changes before checking compilation.

Work incrementally.

After meaningful batches:

```text
format
analyze
test
compile/check
```

Fix issues before proceeding.

Never knowingly leave the repository in a broken intermediate state at completion.

---

# 54. NO FAKE COMPLETION

Never say:

```text
All screens are complete
```

unless you actually inspected them.

Never say:

```text
All tests passed
```

unless they actually ran successfully.

Never mark a screen VERIFIED simply because its code was modified.

Use honest statuses.

---

# 55. SCREEN COMPLETION DEFINITION

A screen may only be considered VERIFIED when:

- implementation complete
- design system used
- responsive behavior checked
- no known overflow
- mobile layout checked
- tablet layout checked
- desktop layout checked
- loading checked
- empty checked when relevant
- error checked when relevant
- interactions checked
- accessibility considered
- analyzer clean for modified code
- relevant tests pass

---

# 56. CENTRALIZED RESPONSIVE SUCCESS CRITERIA

After this refactor, adding a new page should NOT require developers to manually decide:

```text
mobile padding
tablet padding
desktop padding
maximum page width
breakpoints
navigation mode
dialog widths
standard component heights
text hierarchy
button styles
input styles
card styles
loading style
error style
spacing rhythm
```

Those should already be available from the centralized system.

A new screen should mostly describe WHAT it contains.

The design system should decide HOW it looks.

---

# 57. PRODUCT QUALITY BAR

Think:

> "Could this application confidently be demonstrated to customers, investors, enterprise clients, designers, senior engineers and QA engineers?"

The answer should become YES.

The UI should feel intentional from the first screen to the last screen.

There should be no screen that looks like it came from a completely different application.

---

# 58. FINAL VALIDATION

Before considering the work complete:

- inspect all changed files
- run formatter
- run Flutter analyzer
- run available unit tests
- run widget tests
- run integration tests where configured
- verify Melos packages
- verify no dependency cycle introduced
- search for old duplicated styling
- search for random breakpoint values
- search for unnecessary hardcoded colors
- search for hardcoded typography
- search for dead widgets
- search for TODO/FIXME introduced during this work
- inspect responsive behavior
- update registry
- update QA documentation

---

# 59. FINAL RESPONSE FORMAT

When implementation is genuinely complete, give me:

## 1. Repository Analysis

Important architecture discoveries.

## 2. Problems Found

UI/UX, responsive, code-quality and architectural problems.

## 3. Design System Created

Explain theme, tokens, typography, spacing and components.

## 4. Responsive Engine

Explain exactly how mobile/tablet/web/Windows layouts are now centrally controlled.

## 5. Screens Redesigned

List each screen and status.

## 6. Components Created/Changed

Reusable component list.

## 7. UX Improvements

Major UX improvements.

## 8. Accessibility Improvements

What was implemented.

## 9. Performance Improvements

What was improved.

## 10. Tests

Show actual:

```text
PASS
FAIL
NOT RUN
```

for:

```text
Flutter analyze
Unit tests
Widget tests
Golden tests
Integration tests
Melos packages
```

## 11. Remaining Problems

Be transparent.

## 12. Important Files

List design-system/responsive/theme/documentation files.

---

# 60. MOST IMPORTANT INSTRUCTION

DO NOT perform a superficial makeover.

I want a COMPLETE APPLICATION-LEVEL TRANSFORMATION.

Analyze the application from the perspective of:

```text
Flutter developer
Flutter architect
Melos architect
UI designer
UX designer
Android user
iPhone user
tablet user
web user
Windows user
accessibility user
manual tester
automation tester
product owner
enterprise customer
```

Every screen should work as part of ONE coherent product.

Centralize what should be centralized.

Reuse what should be reusable.

Adapt what should be adaptive.

Test what should be tested.

Fix what is broken.

Preserve what already works.

The result must be:

**extraordinary + modern + premium + clean + clear + responsive + adaptive + accessible + maintainable + scalable + production-ready.**

Start by inspecting the repository root and `melos.yaml`, map the complete workspace and application surface area, then begin the implementation.

Do not stop at recommendations.

Execute the transformation.
