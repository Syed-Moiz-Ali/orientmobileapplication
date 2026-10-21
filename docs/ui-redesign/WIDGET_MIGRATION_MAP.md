# WIDGET_MIGRATION_MAP (phase-1f; read-only handoff for module phases 2–8)

Counts = constructor/call-site hits in `apps/*/lib` + `packages/shared_auth/lib`
+ `packages/shared_core/lib` (core numbers include the widget definition +
gallery demos; "homes" = where the migration debt lives). Phase 1 is
additive: every NEW widget below has **zero app-screen usages** — module
phases adopt them screen by screen. Rename paths to the DESIGN_SPEC names
are collected at the bottom; the polish phase renames in one codemod each
once the legacy widget hits zero usages.

## Buttons

| Legacy | Homes (call sites) | New widget | NOT covered yet |
|---|---|---|---|
| `PrimaryButton(` (64) | staff 40, auth 10, owner 8, customer 1 | `AppPillButton.primary` (spec `AppButton`) | trailingIcon + arbitrary bg/fg colors + haptics (deliberate, per 1a); `AuthPrimaryButton` (14, auth) migrates with phase-2 |
| `SecondaryButton(` (45) | staff 37, owner 5, customer 1 | `AppPillButton.secondary` | same rename path as above |
| `AppButton.` factory (21: primary/secondary/tertiary/danger/quietIcon/compactInline) | staff 20 | `AppPillButton` variants + `AppTextButton` (tertiary) + `AppIconButton` (quietIcon) | compactInline density: use 36 px small size; danger maps to destructive variant |

## Status pills / chips / badges / avatars

| Legacy | Homes | New widget | NOT covered yet |
|---|---|---|---|
| `StatusPill` + tones (68 ctors; 86 tone-ctor refs: neutral/info/success/warning/danger/inProgress) | staff ~76 refs, owner ~45, customer 15, crm 12 | `AppStatusChip` (success/warning/error/info/neutral/accent, dot + label, AA) | custom bg/fg escape hatch (deliberate — spec forbids); `inProgress` tone has no dedicated kind → map to info/accent + label (module-phase call) |
| `Chip(`/`InputChip/ChoiceChip/FilterChip` (16 of 72) | customer + staff sheets/forms | `AppChip` (filter, check/weight cue) / filter groups → `AppPillTabs` | dismissible chips: no delete variant in phase 1 |
| `TrustPill`/`PendingSyncChip` (9) | sync/offline surfaces | `AppStatusChip` kinds | sync-state auto-wiring stays caller-side |
| `Badge(` (26) | customer 26 refs incl. garage carousel, staff advisor home, auth surface | `AppBadge` (99+ cap) | none |
| `CircleAvatar` (22) + `UserAvatar` (5) | staff 11, crm 6, owner 6 | `AppAvatar` (24/32/40/56, image/initials) | none |

## Inputs (see also INPUT_INVENTORY.md for per-file homes)

| Legacy | Homes | New widget | NOT covered yet |
|---|---|---|---|
| raw `TextField(` (75; `TextFormField` 0) | staff 28, owner 15, customer 12, auth 9, crm 4 | `AppInputField` (+ `forceLtr`, password toggle, counter) | multiline code/ID fields: use mono style ad hoc (spec allows mono for code only) |
| `Pinput` (20 refs; OTP in `auth_field.dart`) | shared_auth only | stays `Pinput`, styled via tokens (phase-2) | none — deliberate |
| `AppTextField(` (37) | owner 15, staff 14, customer 7 | `AppInputField` (spec `AppTextField`) | rename path below |
| `AppSearchField(` (19) | staff 10, owner 6 | `AppSearchBar` | none |
| `AppDropdownButton`/`AppSelectField` (22) + raw `DropdownButton` (15) | staff 11, owner 3, team/assign sheets | `AppDropdown` (+ searchable) | channel-map style custom dropdowns (crm) migrate ad hoc |
| raw `Switch` (3) / `Checkbox` (2+1 tile) / `Radio` (0) | inspection_widgets, advisor_assign_tasks | `AppCheckTile`/`AppSwitchTile`/`AppRadioTile` (whole-row 48 dp) | none |
| `showDatePicker` (4) + `showTimePicker` (1) | lead_form, attendance, repair_order, vehicle_customer | NONE — native pickers, themed via component themes | module phases only |

## Cards / lists / tables

| Legacy | Homes | New widget | NOT covered yet |
|---|---|---|---|
| `AppCard` + variants (standard/surface/subtle/outlined/interactive/selected/navy/semantic; ~123 refs incl. qualified) | staff 60, owner 20, core 34 (defs), crm 7 | `AppSurfaceCard` (spec `AppCard`; border-XOR-shadow) | `navy` + `semantic` factories (module phases: navy → hero styling, semantic → tone blocks); `selected` → tappable + selected state ad hoc |
| `ListView` (67) + `ListTile` (14) | staff 27, owner 14, crm 9 | `AppListTile`/`AppSettingsTile` grouped in one `AppSurfaceCard` + `AppDivider.inset` | expandable tiles: caller-side ExpansionTile restyled in module phases |
| `DataTable` (0 legacy usages — hits are the new `AppDataTable` only) + legacy `AppTable` (definition only, 0 app usages) | — | `AppDataTable` (spec `AppTable`; surface-width breakpoint, sticky header, sort semantics) | selection checkboxes, pagination footer (legacy `app_pagination_footer.dart` stays), expandable rows |
| `AppRecordRow` (29) | record/detail rows | `AppDataRow` | none (compact table cards reuse `AppDataRow`) |
| `showAppConfirmationDialog` (~15 app sites) + `AlertDialog` (6: crm 2, staff 2, owner 1, checkin 1) + `showDialog` (1) | all apps | `AppDialog` (+destructive) via `showAppDialog` | `confirmDismiss` inline use stays caller-side |
| `Dismissible` (3 app + 14 core) | job_detail, vehicle_customer | caller-side, restyle in module phases | no new widget (gesture pattern, not a component) |

## Loaders / progress / images / states

| Legacy | Homes | New widget | NOT covered yet |
|---|---|---|---|
| `LoadingIndicator` (3) + `CircularProgressIndicator` (28) | crm 8, staff 7, customer 3, auth 2 | `AppLoader` (28 px accent, determinate under reduced-motion) | none |
| `LinearProgressIndicator` (14: staff 4, customer 5, crm 2, auth 1) | quota/meter rows | `AppProgressBar` (threshold tones, AA fill-vs-track) | stepped upload progress stays caller-side |
| `AppSkeleton` legacy (140 refs: customer 49, staff 35, owner 11) + raw shimmer (61) | skeleton lists app-wide | `AppShimmerSkeleton` (spec `AppSkeleton`) + `AppShimmer` | none |
| `Image.network` (1) / `CachedNetworkImage` (0) | — | `AppNetworkImage` (framework Image, frozen-in-tests flag) | no cache dep approved — deliberate |
| `EmptyState` (57) + `ErrorView` (9) | staff 31, owner 18, crm 6 | `AppEmptyState` / `AppErrorState` (friendly copy + action, no raw exceptions) | `GradientBanner` hero styling (6) stays module-phase work |
| `OfflineBanner` (24) + `RefreshIndicator` (38 app-wide) | sync/offline surfaces | `AppBanner` (warning) + `AppScaffold` pull-to-refresh passthrough | auto-subscription logic stays caller-side |

## Sheets / snackbars

| Legacy | Homes | New widget | NOT covered yet |
|---|---|---|---|
| `showAppModalSheet` (32) + raw `showModalBottomSheet` (15) | staff 36 (both), owner 5, crm 5 | `showAppBottomSheet`/`AppBottomSheet` (radius 28, pinned action) | drag-to-dismiss gesture → phase-15 real-device checklist; file move (`app_modal_sheet.dart` → `app_bottom_sheet.dart`) at polish |
| `showAppSnackBar` helper (core 3 + auth 4) + raw `SnackBar`/`ScaffoldMessenger` (~300 refs, incl. core helpers) | staff 94, owner 19, crm 18, customer 20, auth 27 | `AppSnackBar`/`AppToast` (show methods, injectable test duration, live region) | legacy top-end pin on expanded (placement contract differs — module-phase call); errors needing decisions → `AppDialog` per spec |

## Frame / nav / app bars

| Legacy | Homes | New widget | NOT covered yet |
|---|---|---|---|
| raw `Scaffold` (62) | all apps | `AppScaffold` (sticky action bar, max-width, refresh) | none |
| raw `AppBar` (52) | all apps | `AppAppBar` (56, hairline-on-scroll, large slivers variant) | collapsing custom headers migrate ad hoc |
| `WorkspaceAppBar` (~60) + `AppTopBar` (14) | staff/owner/crm frames | `AppAppBar` | domain props (workspace switcher, sync state) → module-phase composition, not a 1:1 swap |
| `BottomNavigationBar` raw (26: customer_scaffold, dashboard_body…) | customer + staff shells | `AppBottomNav` (max 5, badges) + `AppNavRail` on medium/expanded | none |
| raw `NavigationRail` (33) in scaffolds | staff/crm shells | `AppNavRail` (legacy `AppNavigationRail` owns that name — same rename pattern) | rename path below |
| `AppAdaptiveNavigation` (8) + `AppPageFrame` (12) | shells | KEEP (layout authority) + wrap in `AppScaffold` | not widgets to replace |
| `Drawer` (6: crm_drawer + adaptive nav) | crm + shells | NONE in phase 1 | `NavigationDrawer` migration is a module-phase item |
| `Stepper` (12: staff 7) + `TabBar` (2 core) + custom pill rows | forms, supervisor/team filters | `AppSegmentedControl`/`AppPillTabs` + `AppProgressBar` step headers | vertical Stepper flows stay caller-side |

## Rename paths to spec names (polish phase, one codemod each at zero usages)

| Interim (built) | Spec name | Blocked by |
|---|---|---|
| `AppPillButton` | `AppButton` | legacy `AppButton` factory (`primary_button.dart`) |
| `AppInputField` | `AppTextField` | legacy `AppTextField` (`app_text_field.dart`) |
| `AppSurfaceCard` | `AppCard` | legacy `AppCard` (`app_card.dart`) + variants |
| `AppShimmerSkeleton` | `AppSkeleton` | legacy `AppSkeleton` (`app_skeleton.dart`) |
| `AppDataTable` (+ `AppDataTableHeader`) | `AppTable` | legacy `AppTable` (`app_table.dart`) |
| `AppNavRail` | `AppNavigationRail` | legacy `AppNavigationRail` (shells) |
| `AppBottomSheet` file move | `app_bottom_sheet.dart` | legacy `showAppModalSheet` (`app_bottom_sheet.dart`) |

## Phase 6 customer-home recomposition (branch `ui/phase-6-customer`)

Home (`customer_home_tab.dart`) recomposed presentation-only onto 1P pattern
widgets. Deleted legacy home widgets below at zero remaining usages
(verified by repo grep; no other app/package referenced them):

| Deleted legacy widget | Homes before | Replaced by | Notes |
|---|---|---|---|
| `CustomerHomeServiceSummary` (+ `_LiveServicePanel`, `_ActiveBookingPanel`, `_WelcomePanel`, `_IdlePanel`) | customer home tab only (1) | `CustomerHomeHero` (ONE `AppMediaCard`: approval > payment due > in-service > upcoming > idle + "+N more" row into approvals) | Same priority order read from the replaced code; same routes/CTAs; new-customer branch now `AppEmptyState` |
| `CustomerGarageCarousel` (+ `_VehicleCard`, `_ContextBadge`, pager + dots) | customer home tab only (1) | `CustomerHomeGarage` (`AppCarousel`, ~2.2 peek, "Show all" into the vehicles tab) | Cards keep silhouette art + booking-derived context badge + plate; no invented scores/favorites/promos |
| `CustomerAttentionPanel` usage on Home | home only (class kept) | hero/banner position on Home | Class KEPT with reason: still used by `customer_service_status_tab.dart` (Status detail), where full adjudication lives |
| `CustomerRefreshNotice` usage on Home | home only (class kept) | `AppBanner` (warning) + keep last data on Home | Class KEPT with reason: still used by bookings/vehicles/profile/status/notifications tabs |
| `CustomerSurfacePanel` | — (not deleted) | — | KEPT: used by approvals, bookings, breakdown, vehicles, status panels, booking-success |
| legacy `SectionHeader` on Home garage/recent | home garage + recent (2) | `AppCarousel` header / `AppSection` + `AppListGroup` | Shared `SectionHeader` class itself kept (used elsewhere); Home no longer references it |
| legacy `EmptyState`/`ErrorView` on Home loading/error | home (2) | `AppShimmerSkeleton` / `AppEmptyState` / `AppErrorState` | Home now contributes zero `AppSkeleton`-legacy call sites (loading skeleton migrated) |

## Phase 3 advisor-home recomposition (branch `ui/phase-6-customer`)

Home (`advisor_home_view.dart`) recomposed presentation-only onto 1P pattern
widgets. Deleted legacy home widgets below at zero remaining usages
(verified by repo grep; no other app/package referenced them):

| Deleted legacy widget | Homes before | Replaced by | Notes |
|---|---|---|---|
| `_GreetingHeader` (+ `_HeaderBadge`) | advisor home only (1) | `AppPageHeader` (date eyebrow + greeting + branch·shift, trailing: header search + `OfflineStatusPill` + bell/`AppBadge` + `AppAvatar`) | Same identity data, pill, bell count (`notifications + approvals`), avatar, sheets, logout dialog |
| `_SearchHero` (+ `_HeroBloom`, `_RecentChip`, `_PremiumSearchField`) + `SliverAppBar` search hero | advisor home only (1) | Pinned `SliverAppBar` bottom: pill-style `AppSearchBar` (same controller/focus/query/clear) + `AppChip` recents + scan `AppIconButton`; sheet via header search + Ctrl+K shortcut | Same query state, recents, filter predicate, scan route, sheet route; inline typing kept (an `AppSearchPill` is read-only and would have frozen the query state) |
| `_ActionStrip` (+ `_StripTile`, `_CountBadge`) 2x2 grid | advisor home only (1) | ONE horizontal row of 3 `AppPillButton` (Scan secondary, New job primary emphasized, Approvals secondary with inline count) | Per the brief the C16 row overrides the recorded 2026-10-15 owner 2x2-grid preference — flagged, not silent; same routes, haptics kept |
| `_SummaryStrip` (+ `_MetricCell`) slim metrics | advisor home only (1) | ONE hero `AppMediaCard` (key number `advisorHeroDueTitle` + delta sentence + See-all CTA into Jobs tab) + `AppSection` of 3 `AppStatTile` behind See all/Reports tab | Numbers derived from the same providers/list as before; zeros render as muted dash |
| `_AssignedSection` divider rows (+ `_AssignedSkeletonRows`, `_FadeSlideIn`) | advisor home only (1) | `AppSection` + large `AppMediaCard` rows (customer + vehicle/plate/id/time sentence + ONE `AppStatusChip` + tap) with Show all → Jobs tab | Urgent-first sort UNCHANGED; `AdvisorJobCardRow` class KEPT (still used by the Jobs work list) |
| `_DesktopPreview` bespoke side panel | advisor home only (1) | Same 2-col list + preview, preview rebuilt with `AppSurfaceCard` + `AppStatusChip` + `AppPillButton` | Same selection state, same job-detail route; empty prompt kept |
| legacy `EmptyState`/`ErrorView`/`AppSkeleton` on Home loading/error/empty | home (3) | `AppShimmerSkeleton` / `AppEmptyState` (new `advisorHomeEmptyTitle`/`advisorHomeEmptyBody` + New job CTA) / `AppErrorState` + `AppBanner` (warning) offline | Same retry (provider invalidate), same offline-keep-last-data; KEPT: shared `EmptyState`/`ErrorView` classes (used by jobs/sheets elsewhere) |

Kept verbatim (no new usages, no signature changes): `AdvisorProfileSheet`,
`AdvisorNotificationSheet`, `AdvisorSearchSheet`, `AdvisorApprovalSheet`,
`showLogoutDialog`, all providers/routes/sync logic/sort/filter/selection.
Home now contributes zero `AppSkeleton`-legacy call sites on its own surfaces
(loading + summary skeletons migrated); `StatusPill` remains the shared
vocabulary (`advisor_status.dart` untouched) with home cards mapping the same
taxonomy to `AppStatusChip`.
