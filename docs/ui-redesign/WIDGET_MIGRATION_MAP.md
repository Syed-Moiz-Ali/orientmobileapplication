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

## Auth controls (phase-2c — shared_auth + supervisor login)

| Legacy (auth-local) | Homes (call sites) | App* replacement | Notes |
|---|---|---|---|
| `AuthTextField` | login (6), forgot (3), supervisor (2) | `AppInputField` (+ `belowField`, `labelTrailing`, localized toggle tooltips, `textCapitalization` extensions) | DELETED (`auth_field.dart` → `auth_otp_field.dart`). LTR force, autofill, focus order, keyboard actions preserved via pass-through |
| `AuthPrimaryButton` (+ `AuthButton` alias) | login (4), forgot (3), supervisor (1), `AuthSessionExpiredView` (1) | `AppPillButton.primary` (+ `busyLabel` extension) | DELETED (`auth_button.dart` removed). Busy label-swap + disabled treatment preserved via `busyLabel` |
| `AuthLinkButton` | login (3), forgot (2), supervisor (1), recovery progress (1) | `AppTextButton` | DELETED. 48dp target, icon support kept where used |
| `AuthNotice` / `AuthNoticeSlot` | supervisor (1) | `AppBanner` (error kind + retry action) | DELETED (`auth_notice.dart` removed). Form-level failures stay snackbar+retry in shared views (reviewer-judged fit) |
| `_MethodSwitcher` (private) | login (1) | `AppSegmentedControl` (+ `icon` on `AppSegmentedOption`) | DELETED (inline `AppSegmentedControl`, icons preserved via extension) |
| `AuthResendAction` | login (1), forgot (1) | token-rebuilt on `AppTextButton` (same class name) | KEPT as auth-scoped composite: no App* countdown control exists; internals now pure tokens + `AppTextButton`, Row→Wrap (fixes a 320px transient overflow) |
| `AuthCountryCodeButton` | login (1, phone-like entry) | none (token-refresh in place) | KEPT: domain-specific dial-code picker on tokens + `AppSelectionSheet`; no App* equivalent. Aligned to the input border ramp |
| `AuthPasswordStrength` | login register (1), forgot reset (1) | none (restyled, feeds `AppInputField.belowField`) | KEPT as auth-scoped scoring UI; concept retained per plan |
| `AuthOtpField` (Pinput) | login code (1), forgot reset (1) | none — third-party concession | KEPT: full token-styling pass (resting = `inputBorder` token, 1.5px focus/error, AA pairs asserted). LTR lock, autofocus, digitsOnly, completion untouched |
| `SecurityBadge` | `AuthShell` footer (all auth screens) | none | KEPT: app-aware legal composite, token-only |
| `AuthShell` / `AuthSurface` internals | login, forgot, supervisor | none (layout authority) | KEPT per plan (already C9) |

## Auth controls (phase-2 step flow — shared_auth login/forgot; supervisor untouched)

| Legacy (auth-local) | Homes (call sites) | App* replacement | Notes |
|---|---|---|---|
| `_MethodSwitcher` + `AppSegmentedControl` login usage | login (1) | step progression (`AppStepScaffold` 1/2 + `AppAltAuthRow`) | REMOVED from login by the step flow (password-first; code is the alt row). `AppSegmentedControl` itself stays in shared_core untouched |
| `AuthResendAction` (cooldown ring) | login (0), forgot (0) | `LoginResendRow` / `ForgotResendRow` (`auth_step_resend.dart`, link + countdown text only) | DELETED (`auth_resend_action.dart` removed, export swapped). Ring + detached row replaced per brief; rows rebuild in isolation (`select` / `ValueListenableBuilder`) so the 1 Hz ticks never rebuild the step |
| `AuthShell` page usage | login (0), forgot (0) | `AppStepScaffold` (+ `AuthStepBrandPanel` on split) | KEPT with reason: still the exported layout authority and still referenced by the frozen supervisor slice (`supervisor_login_test.dart` negative assertion); deleting the class would break that slice. Zero page usages after the step flow |
| `AuthOtpField` (Pinput) | login code (1), forgot reset (1) | none — third-party concession | KEPT: token-styled, LTR lock, autofocus, digitsOnly, completion untouched |
| `AuthCountryCodeButton` | login identifier (2: Step 1 + R2) | none — domain picker | KEPT: dial-code picker on tokens + `AppSelectionSheet`; no App* equivalent |
| `AuthPasswordStrength` | login R3 (1), forgot reset (1) | none (feeds `AppInputField.belowField`) | KEPT as auth-scoped scoring UI |
| `SecurityBadge` | Step 1 trust line + split brand panel | none | KEPT: per-app `securityNotice` passthrough + shared fallback; no new claims |
| `AppStepScaffold` | shared_core (extended) | n/a (additive `busyLabel` passthrough) | EXTENDED additively: optional `busyLabel` → sticky CTA label-swap (Signing in…/Verifying…/Creating account…/Sending…/Updating…), width preserved. No existing behavior changed |

| Legacy (auth-local) | Homes (call sites) | App* replacement | Notes |
|---|---|---|---|
| `AuthTextField` | login (6), forgot (3), supervisor (2) | `AppInputField` (+ `belowField`, `labelTrailing`, localized toggle tooltips, `textCapitalization` extensions) | DELETED (`auth_field.dart` → `auth_otp_field.dart`). LTR force, autofill, focus order, keyboard actions preserved via pass-through |
| `AuthPrimaryButton` (+ `AuthButton` alias) | login (4), forgot (3), supervisor (1), `AuthSessionExpiredView` (1) | `AppPillButton.primary` (+ `busyLabel` extension) | DELETED (`auth_button.dart` removed). Busy label-swap + disabled treatment preserved via `busyLabel` |
| `AuthLinkButton` | login (3), forgot (2), supervisor (1), recovery progress (1) | `AppTextButton` | DELETED. 48dp target, icon support kept where used |
| `AuthNotice` / `AuthNoticeSlot` | supervisor (1) | `AppBanner` (error kind + retry action) | DELETED (`auth_notice.dart` removed). Form-level failures stay snackbar+retry in shared views (reviewer-judged fit) |
| `_MethodSwitcher` (private) | login (1) | `AppSegmentedControl` (+ `icon` on `AppSegmentedOption`) | DELETED (inline `AppSegmentedControl`, icons preserved via extension) |
| `AuthResendAction` | login (1), forgot (1) | token-rebuilt on `AppTextButton` (same class name) | KEPT as auth-scoped composite: no App* countdown control exists; internals now pure tokens + `AppTextButton`, Row→Wrap (fixes a 320px transient overflow) |
| `AuthCountryCodeButton` | login (1, phone-like entry) | none (token-refresh in place) | KEPT: domain-specific dial-code picker on tokens + `AppSelectionSheet`; no App* equivalent. Aligned to the input border ramp |
| `AuthPasswordStrength` | login register (1), forgot reset (1) | none (restyled, feeds `AppInputField.belowField`) | KEPT as auth-scoped scoring UI; concept retained per plan |
| `AuthOtpField` (Pinput) | login code (1), forgot reset (1) | none — third-party concession | KEPT: full token-styling pass (resting = `inputBorder` token, 1.5px focus/error, AA pairs asserted). LTR lock, autofocus, digitsOnly, completion untouched |
| `SecurityBadge` | `AuthShell` footer (all auth screens) | none | KEPT: app-aware legal composite, token-only |
| `AuthShell` / `AuthSurface` internals | login, forgot, supervisor | none (layout authority) | KEPT per plan (already C9) |

## Auth one-screen collapse (phase-2 one-screen, 2026-10-20 superseding rule)

Password + supervisor collapsed from step flows to the single-screen pattern
(identifier + password + Continue → existing `login()`; code/register/forgot
steps unchanged). Local scaffolding deleted at zero usages:

| Removed (auth-local) | Was used by | Replacement | Notes |
|---|---|---|---|
| `_LoginStep.identifier` step | login (step-1 advance) | one-screen `_LoginStep.password` (1 of 1, no back) | The no-API advance step is gone by design; Continue IS the login call |
| `_IdentifierStepContent` | login step 1 | `_PasswordScreenContent` (both fields + forgot + alt rows + trust line in one `AutofillGroup`) | Single username+password group, focus identifier → password, `done` submits |
| `_PasswordStepContent` (recap variant) | login step 2 | same `_PasswordScreenContent` | Identifier recap deleted (both fields visible, nothing to recap) |
| `_continueFromIdentifier` (+ step-1 advance path) | login | `_submitPassword` directly on Continue | Same validation + same notifier calls, one tap |
| supervisor `_step` state + `_continueFromIdentifier` + `_backToIdentifier` | supervisor 2-step flow | single-screen build (no step state, `onBack: null`) | Same `_login` byte-for-byte; forgot link + banner + retry kept |
| test helpers `reachPasswordStep`, `continueToPasswordStep`, `submitPasswordStep`, `settleStepTransition` | shared/staff tests | `fillLoginForm` / `fillSupervisorForm` + `submitSupervisorForm` (same screens, no nav) | `reachCodeConfirm` / `reachRegisterR3` kept verbatim (entry screen only changed) |

KEPT with written reason: Pinput (`AuthOtpField`, third-party concession),
`AuthCountryCodeButton` (domain dial-code picker), `AuthPasswordStrength`
(auth-scoped scoring UI), `AuthShell` (still the exported layout authority +
still pinned by the supervisor negative assertion `findsNothing(AuthShell)`),
`AuthStepBrandPanel` + `LoginResendRow`/`ForgotResendRow` (untouched steps),
`AppStepScaffold` (extended additively before; one-screen uses step 1 of 1,
code step 2 of 2, register 1–3 of 3 — no shared_core change).

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
(verified by repo grep; no other app/package referenced them).
NOTE: the first recomposition was SUPERSEDED by the U-law rebuild (same commit
series); the mapping below describes the CURRENT tree, not the interim one
(no pinned search pill, no scrolling 3-pill row, no summary strip, no See-all
hero CTA — all removed again at zero usages in the rebuild):

| Deleted legacy widget | Homes before | Replaced by | Notes |
|---|---|---|---|
| `_GreetingHeader` (+ `_HeaderBadge`) | advisor home only (1) | Compact custom header (sentence-case date + 2-line greeting + muted branch·shift; search icon + bell + avatar top-right) | Same identity data, bell count, avatar, sheets, logout dialog; badge offset clear of glyph |
| `_SearchHero` (+ `_HeroBloom`, `_RecentChip`, `_PremiumSearchField`) + `SliverAppBar` search hero | advisor home only (1) | Header search icon → existing `AdvisorSearchSheet` (extended additively: session recents + `onRemember`); same controller/focus/query/filter/scan route; full-screen sheet | Same query state, recents, filter predicate, scan route; inline typing preserved (a read-only `AppSearchPill` would have frozen query state); U1 one search path |
| `_ActionStrip` (+ `_StripTile`, `_CountBadge`) 2x2 grid, then interim 3-pill row | advisor home only (1) | 3 EQUAL columns (icon + ≤2-line labels, approvals badge-only count, no filled tile) | Per C16 the row overrides the recorded 2026-10-15 owner 2x2-grid preference — flagged in brief; same routes, haptics kept |
| `_SummaryStrip` (+ `_MetricCell`) slim metrics | advisor home only (1) | REMOVED (derivable from the list; zero-as-dash violated U11, second See-all violated U7) — no replacement surface | No logic touched; numbers still computed by the same providers |
| `_AssignedSection` divider rows (+ `_AssignedSkeletonRows`, `_FadeSlideIn`) | advisor home only (1) | `AppSection` + large `AppMediaCard` rows (customer/vehicle → ONE `AppStatusChip` → meta sentence → small mono ID + chevron); conditional See-all (only when more than shown); first card above the fold at 360x800 | Urgent-first sort UNCHANGED; `AdvisorJobCardRow` class KEPT (still used by the Jobs work list) |
| `_DesktopPreview` bespoke side panel | advisor home only (1) | Same 2-col list + preview (medium = 600–1024 now 2-col), preview rebuilt with App* cards | Same selection state, same job-detail route; empty prompt kept |
| legacy `EmptyState`/`ErrorView`/`AppSkeleton` on Home loading/error/empty | home (3) | `AppShimmerSkeleton` (layout-mirroring) / `AppEmptyState` / `AppErrorState` + `AppBanner` (warning) offline | Same retry (provider invalidate), same offline-keep-last-data; KEPT: shared `EmptyState`/`ErrorView` classes (used by jobs/sheets elsewhere) |

Kept verbatim (no new usages, no signature changes): `AdvisorProfileSheet`,
`AdvisorNotificationSheet`, `AdvisorSearchSheet`, `AdvisorApprovalSheet`,
`showLogoutDialog`, all providers/routes/sync logic/sort/filter/selection.
Home now contributes zero `AppSkeleton`-legacy call sites on its own surfaces
(loading + summary skeletons migrated); `StatusPill` remains the shared
vocabulary (`advisor_status.dart` untouched) with home cards mapping the same
taxonomy to `AppStatusChip`.

## Phase 3 advisor-home REBUILD (C16 hard-reject pass, branch `ui/phase-6-customer`)

Same file recomposed again, presentation + widget-tree only (no provider /
route / logic / ARB-structure change; no new keys):

| Before (round-2 tree) | After (rebuild) | Notes |
|---|---|---|
| Header: `AppPageHeader` + header search icon + `OfflineStatusPill` + bell badge (inside glyph corner) + avatar | Compact custom header row: sentence-case date + greeting (maxLines 2) + muted branch·shift; bell badge offset ABOVE the glyph (top -8, rect-disjoint) + avatar top-right; no search icon, no pill | One search path (pinned pill); sync only as `AppBanner` when abnormal (offline warning / queued info); normal case renders nothing |
| Hero `AppSurfaceCard` (default outlined) | `AppSurfaceCard(outlined: false)` + single `View jobs` CTA | Borderless light path (shadow); dark keeps shared border |
| Quick actions: 3 equal pills / 2x2 reflow with orphan spacer, emphasized (filled) New-job tile, `Approvals (2)` label + badge, scan `AppIconButton` beside search | ONE horizontal `SingleChildScrollView` tile row (120px neutral tiles, icon + 2-line label, peek); no filled tile; approvals count on badge ONLY; scan lives only in the tile row | C16 orphan-tile + one-primary + count-once rules |
| Pinned `AppSearchBar` + separate scan button; submit only filters inline | Same controller/focus/query/recents/filter predicate; submit ALSO opens the existing `AdvisorSearchSheet` (sheet keeps its own predicate/recents/scan CTA); Ctrl+K unchanged | Pill is the one search path, sheet is its continuation |
| Assigned cards: job-id-first title | Customer/vehicle-first title, then ONE `AppStatusChip`, then meta sentence, job id as small LTR mono meta; `outlined: false`; chevron kept | C16 card hierarchy; borderless light |
| Preview `AppSurfaceCard` (default outlined) | `AppSurfaceCard(outlined: false)` | Same selection state, same route |
| Assigned as cards (always) | Assigned stays a LIST, not a carousel | N <= 6, statuses need side-by-side comparison; carousel would hide urgent items and cost the above-the-fold first order at 360x800 |

New guard coverage: `packages/shared_core/test/app_hard_reject_guards_test.dart`
(borderless cards, no-uppercase, >= 48dp targets, badge-glyph disjoint).

## Phase 5 supervisor-home recomposition (branch `ui/dashboards-2`)

Floor tab (`supervisor_dashboard_tab.dart`) recomposed presentation-only onto
1P pattern widgets; new `supervisor_floor_search.dart` (floor-data search
sheet). Legacy usages below drop to zero on the floor tab (verified by grep;
the shared classes themselves are kept — still used by the supervisor
queue/review/jobs/staff/schedule tabs):

| Deleted legacy widget | Homes before | Replaced by | Notes |
|---|---|---|---|
| bespoke `_FloorMasthead` (`SectionHeader` floor title + subtitle) | floor tab (1) | `AppPageHeader` (title `svFloorTitle` + subtitle `svFloorSubtitle`, trailing search `AppIconButton` per U1) | Same title/copy; occupancy sentence kept verbatim; no eyebrow (C3 no-ALL-CAPS) |
| bespoke hero (none — masthead only) | floor tab (1) | ONE `AppMediaCard` (active-bay count + `svFloorHeroSentence` + `Bays` unit chip) + ONE `AppPillButton.primary` Dispatch (`svAssignTitle`, existing assign entry) | New key `svFloorHeroSentence` only for the sentence; count is the bare number (`0` never `-`) |
| `AppInfoPanel.danger` floor error | floor tab (1) | `AppErrorState` (`svFloorErrorTitle`/`svFloorError` + `commonRetry` label kept) + same `refreshDashboard` retry | Same copy/retry; offline gets `AppBanner` (shared `offlineBannerMessage`) + stale board |
| `AppSkeleton` floor skeleton | floor tab (1) | `AppShimmerSkeleton` mirroring header + hero + grid + rail | Same loading contract (`isDashboardLoading && isEmpty`) |
| `AppCard.standard` no-match card + `EmptyState.noMatch` | floor tab (1) | `AppEmptyState` (`svFloorNoMatch` + new `svFloorNoMatchHint` + shared `Clear`) | Same predicate/clear contract |
| `AppCard.standard` rail cards + `PrimaryButton`/`SecondaryButton` CTAs | floor tab (3 cards) | `AppSurfaceCard` (header + count trailing + rows + `AppPillButton.secondary` CTAs, verbatim labels/routes) | Row mapping verbatim; selected-bay card keeps code/title/subtitle + dispatch |
| (no search affordance) | floor tab (0) | `SupervisorFloorSearchSheet`: `showAppModalSheet` + `AppSearchField` over derived bays, result tap = tile contract | Permitted "search over floor data"; no new routes/logic |

Kept verbatim (shared tile grammar — `supervisor_components.dart` untouched):
`_BayTile` (state dot + LTR `B-01` + tech-initials slot + title/ref/meta +
selection ring), `_BayLegend`, `_RailRow`, `_TechSlot`, `buildSupervisorBays`
derivation, `SupervisorBayState` filter predicate, selection state,
pull-to-refresh, bottom nav, scaffold. Floor tab now contributes zero
`SectionHeader`/`AppCard`/`AppInfoPanel`/`AppSkeleton`/legacy-button call
sites on its own surfaces.

## Phase 5 technician-home recomposition (branch `ui/dashboards-2`)

Today tab (`technician_today_view.dart`) recomposed presentation-only onto
1P pattern widgets; new `technician_today_search.dart` (loaded-jobs search
sheet). Legacy usages below drop to zero on the Today tab (verified by grep;
the shared classes themselves are kept — still used by the Jobs /
productivity / detail / sheet surfaces):

| Deleted legacy widget | Homes before | Replaced by | Notes |
|---|---|---|---|
| bespoke `_ShiftStrip` + `_ShiftSlimStrip` (punch/summary strips) | today tab (2) | Header subtitle (shift + attendance, real state) | No invented data; punch actions stay on attendance surfaces; providers/routes untouched |
| `SectionHeader` titles + ALL-CAPS eyebrows (`CURRENT WORK`/`UP NEXT`/`NEXT TASK`/`IN PROGRESS`) | today tab (2) | `_TodayHeader` Row (title `techNavToday` + subtitle, same-row end-side `AppIconButton` search per U1) + `AppSection` (`techTodayQueue` + `View all`) + `Tasks` heading | Plain Row, not `AppPageHeader` (compact stacks actions below subtitle — supervisor round-2 lesson) |
| bespoke `_TaskFocusCard` (`AppCard.standard` + `PrimaryButton`/`SecondaryButton` + `AppLinearProgress`) | today tab (1) | `_TodayHero` (`AppSurfaceCard(outlined: false)` borderless-light + `AppPillButton.primary`/`secondary` + labelless `AppProgressBar` + plain progress text) | ONE filled CTA; job ref line added (hero identity); view-level resume prefers held over pending (provider state machine untouched) |
| bespoke `_QuickAction` tiles (bordered, 1-line labels) | today tab (3) | `_TodayQuickTile` (borderless-light + e1 shadow, 72 min-height, ≤2-line wrap labels) | 1-tap each preserved; icons/labels/destinations verbatim |
| bespoke `_BlockerNotice` (error-tinted container) | today tab (1) | `AppBanner(error)` (`techTodayJobOnHold` + `techTodayDelayedHint`) | Same copy/condition (delayed status) |
| bespoke `_ConnectionNotice` (errorContainer + tap) | today tab (1) | `AppBanner(warning)` (`dashboardError` verbatim + `Retry` action) + stale board | Same message/contract; stale jobs kept |
| `EmptyState.error` first-load error | today tab (1) | `AppErrorState` (`techTodayLoadError` + `techTodayErrorHint` + `techTodayRetry`) | Same copy/retry |
| `EmptyState` no-jobs / no-active / queue-clear | today tab (3) | `AppEmptyState` (same keys; `Refresh` / `Open my jobs` actions kept; queue-clear action-less) | Same copy/destinations |
| `AppSkeleton` today skeleton | today tab (1) | `AppShimmerSkeleton` mirroring header + hero + tiles + queue rows | Same loading contract (`isLoading && isEmpty`) |
| `technicianStatusPill` (ALL-CAPS label) on this tab | today tab (1) | `AppStatusChip` (sentence-case `TechJobStatus.label`) | Shared component kept (Jobs/detail sheets still use it); this tab drops the uppercase |
| (no search affordance) | today tab (0) | `TechnicianTodaySearchSheet`: `showAppModalSheet` + `AppSearchField` over loaded jobs, result tap = dossier contract | Permitted "full-screen search over technician jobs"; no new routes/logic |

Kept verbatim (shared tile grammar — `technician_components.dart`
untouched): `TechnicianJobSummary` (queue + search rows, emphasised first
row, hairline dividers), `TechnicianStopwatch`, `TechnicianPlateChip`,
`_activeJob` / `_urgentFirst` derivation, `take(5)` queue window, View-all
visibility + `selectTab(1)` destination, progress math, pull-to-refresh,
freshness footer, haptics. Zero new ARB keys (all copy reused).

## Phase 7 owner-home recomposition (branch `ui/dashboards-2`)

Owner home (`owner_dashboard_page.dart` + palette source
`dashboard_body.dart` → shared `owner_search.dart`) recomposed
presentation-only onto App* pattern widgets; providers/routes/sync/
refresh/period logic, `_findKpi` / `_trendOf` derivation, filter
predicates, bottom nav + rail, pull-to-refresh, haptics and keys
untouched. Legacy usages below drop to zero on the home surface
(verified by grep; the shared classes themselves are kept — still used
by the approvals/register/chart/tab surfaces):

| Deleted legacy widget | Homes before | Replaced by | Notes |
|---|---|---|---|
| bespoke `_CockpitHeader` chrome (analytics trailing `Container` + `StatusPill` live/active/today pills) | home (1 header + 3 pills) | `AppPageHeader` (ops title + branch subtitle + end-side `AppIconButton` search opening the existing palette, U1) + `AppStatusChip` pills (accent/info/success, verbatim labels) | Same titles/subtitle/pill copy; search opens the shared `owner_search.dart` palette (same 9 destinations, no new route); header takes `kpis` as params so pills populate (fixes the const+`ref.read` freeze, providers untouched) |
| `TelemetryMetricPod` hero + micro-pods | home (1 hero + 3 pods) | `AppKpiCard.wide` hero + `AppKpiCard` 2-col grid (LTR-locked figures, verbatim labels/values/deltas, `semanticState` from the adapter) | ONE delta line each (trend badge only); missing families omitted, never zero-filled; overline casing unchanged (both uppercase non-Arabic) |
| conditional blockers (none — silent) | home (0) | `AppBanner(warning)` approvals-WIP only (`ownerHomeApprovalsBanner`, value verbatim, `View all` drills to read-only triage) | Overdue-AR banner STOPPED (AR not in dashboard payload — new fetch would be logic); no decision buttons (no endpoint) |
| bespoke `_CurveCard` chrome + compact swipeable `PageView` | home (2 curves) | Same shared atoms (`AppCard.standard` + `SectionHeader` + `SparklineChart` + first/last month rule); curves stack on compact | No `AppChartCard` in shared_core — composition, not invention; timeframe pills STOPPED (period does not drive trends; pills would be fake) |
| `AppTable` compact duality (`compactBuilder` record rows) | home (1 register) | `AppTable` on medium+ (same columns/cells/routes/empty copy); `AppListGroup` of value rows on compact (LTR-locked `Open: X · Total: Y`, chevron, Show-all past 5 rows, `ownerRegisterAll` → same `jobCards` route) | View-all trailing kept, shown only when rows exist; empty → `AppEmptyState` (`ownerRegisterEmpty` + `ownerHeroEmptyHint`) |
| bespoke quick-action record rows (12-row single column) | home (12) | Top-4 equal tiles (72px min-height, 4-across / 2×2 compact, wrap-safe) + inline Show-all `AppListGroup` for the remaining 8 (preview subtitle, expand-only) | All 12 destinations survive with identical routes/tabs (10 pushes + `selectTab(1/2)`); order preserved |
| `AppSkeleton.page` loading | home (1) | `AppShimmerSkeleton` layout-mirroring (header lines + hero card + pod row + chart card + 3 rows) | Same loading contract (`isLoading && !hasAnyData`) |
| legacy `ErrorView` | home (1) | `AppErrorState` (`ownerHomeLoadError` + server message verbatim + shared `commonRetry`) | Same message/retry; stale data kept; offline owned by the shell pill (no new banner) |
| shell-local palette destination list (`_Destination`) | shell (1) | shared `openOwnerSearch` (`owner_search.dart`), used by shell trigger + header search | Ids/labels/hints/icons/run targets verbatim; no new routes |

Kept verbatim: `_findKpi` / `_trendOf` (byte-identical, display-only),
all 12 action defs (icons/labels/hints/routes/tabs in order),
`AppSplitView` medium + wide 5/4/3 flexes, `RefreshIndicator` +
`AppResponsivePage`, dashboard shell (app bar, bottom nav/rail, search
shortcuts). Two new ARB keys (`ownerHomeApprovalsBanner`,
`ownerHomeLoadError`, en+ar, gen-l10n from the package dir).

## Phase 6 vehicles-list recomposition (branch `ui/integration-1`)

Vehicles list (`customer_vehicles_tab.dart` + `customer_vehicle_record.dart`
+ new `customer_vehicles_search_sheet.dart` +
`customer_vehicles_filter_sheet.dart`) recomposed presentation-only;
providers/sync/refresh, `contextFor`/`specs`/`plateLabel`/`mileageLabel`
predicates, `selectTab`, all routes, Keys and error mapping untouched.
Legacy usages below drop to zero on the vehicles surface (verified by grep;
the shared classes themselves are kept — still used by booking/detail
sheets and other customer surfaces):

| Deleted legacy widget | Homes before | Replaced by | Notes |
|---|---|---|---|
| bespoke `_Header` (title + count + `TextButton.icon` Add) | vehicles tab (1) | `AppPageHeader` (title `vhTitle` + count subtitle, same copy; search + filter `AppIconButton`s top-right ONLY when loaded list > 5 — the ONE sanctioned U1 exception; `TextButton.icon` Add kept when non-empty) | Same title/count/Add copy + destinations; ≤ 5 items = cards only, no find-aids |
| (no search affordance) | vehicles tab (0) | `CustomerVehiclesSearchSheet`: `showAppModalSheet` + `AppSearchField` (`vhSearchHint`) over loaded records (name/plate/specs substring, plates punctuation-insensitive); result tap closes + reveals the record via `ensureVisible`; no-match (`vhSearchNoMatch`) + `Clear` | Permitted "list-scoped search over loaded records"; no new routes/logic |
| (no filter affordance) | vehicles tab (0) | `CustomerVehiclesFilterSheet`: `showAppModalSheet` + `AppChip` single-select (All / `vhInService` / `vhFilterBooked` / `vhFilterLastService` / `vhFilterNone`) + `Show results` + `Clear`; in-place filter, filtered count, no-match + `Clear` | Only honest facets (context derived via existing `contextFor`); no new routes/logic |
| bespoke `_Grouped` bordered container + dividers | vehicles tab (1 per column) | whitespace-separated `AppSurfaceCard(outlined: false)` rows (borderless light w/ shadow, bordered dark) with the same chunking predicate (single column compact or < 4; 2-col medium, 3-col large) | `AppListGroup` is settings-rows only and would dim rich cards; same atoms, same layout rule |
| bespoke record chrome (silhouette `Stack`, `_ContextLine` container, `_Actions` Wrap, `_SyncFailedNotice`, `_DeleteFailedNotice` styling) | record (per card) | art band kept (`VehicleSilhouetteArt` + `CustomerPlateChip` overlay, `PositionedDirectional`) clipped to the card top; title = make/model/year; plate = LTR meta; status pill ONLY from `contextFor` via `AppStatusChip` (sentence case — `.toUpperCase()` removed); context detail + `View`/`Track` kept; sync/delete notices → `AppBanner` (same retry handlers); action row = direct `Book service` + overflow menu (`Edit`/`Remove`, existing routes) | Card hierarchy binding (title/plate/pill/tile, no pill when none); taps never regress (Book ≤ 1 from list) |
| bespoke `_NoVehicles` / `_LoadFailure` panels | vehicles tab (1 + 1) | `AppEmptyState` (exactly 1 icon + 1 sentence + 1 `vhAdd` action → same wizard) / `AppErrorState` (`vhLoadFail*` + `vhRetry`, same retry) | Same copy/retry/destinations |
| bespoke `_UnmatchedDeleteRecovery` + `CustomerRefreshNotice` | vehicles tab (1 + 1) | `AppBanner` error per missing operation (same retry) + `AppBanner` warning (same `stRefreshFail` + retry) | Same copy/retry; stale data kept |
| `AppSkeleton` vehicles skeleton | vehicles tab (1) | `AppShimmerSkeleton` (header lines + `card(208)`) mirroring the cards | Same loading contract (`isLoading && isEmpty`) |
| `showAppConfirmationDialog` (destructive) on this surface | vehicles tab (1) | confirmation bottom sheet via `showAppModalSheet` (same title/body/`customerRemoveVehicle` + snackbar contracts, destructive confirm, NO undo) | Same handler/copy; presentation only |

Kept verbatim (shared tile grammar — `customer_vehicle_presentation.dart`,
`customer_plate_chip.dart`, providers, router untouched):
`contextFor`/`bookingsFor`/`specs`/`plateLabel`/`mileageLabel` (blank stays
unknown, plate upper-cased single-spaced, zero as `0`), VIN LTR lock,
`_confirmRemove`/`_retryRemoval` handler flow, `ValueKey('vehicle-<id>')`,
confirmation + snackbar contracts, `RefreshIndicator` + `AppResponsivePage`
(max 1040), bottom nav (no rail — consumer contract), haptics, RTL mirroring.
Eleven new ARB keys (`vhSearchTitle/Hint/NoMatch`,
`vhFilterTitle/All/Booked/LastService/None/Show/NoMatch/Clear`, en+ar,
gen-l10n from `apps/customer_app`).

## Supervisor compact nav (branch `ui/integration-1`, resolves LOGIC #8)

`supervisor_scaffold.dart` compact bottom bar migrated presentation-only
onto spec-C8 tokens; providers/routes/tab content/tab targets/IndexedStack
order/selection/haptics/copy/ARB untouched (no new keys — More label is the
shared `commonMore`); expanded rail keeps all 7 destinations.

| Deleted legacy widget | Surface | Replaced by | Notes |
|---|---|---|---|
| 7-slot `AppBottomNavigation` compact bar (legacy shared overflow) | supervisor shell (1) | `AppBottomNav` (4 primaries: Floor/Jobs/Queue/Review + 5th More slot; outlined glyphs, active = accent, `currentIndex` maps overflow tabs to More) + `showAppBottomSheet`/`AppBottomSheet` More sheet (Reports/Staff/Schedule rows: icon + label, 48dp+ targets, trailing check on active, same tab targets/routes when tapped) | No routes removed, no tab content changed; More carries no badge (no tab wires badge/count state — read existing state only, nothing invented); tap counts: primaries ≤ before, More-moved tasks +1 each (see `evaluation/supervisor-home-test-migration.md` tap table) |

## Phase 6 vehicles-list round-1 fixer (branch `ui/integration-1`, no widget swaps)

Presentation-only copy/display fixes; no legacy widget added/removed, no
provider/sync/predicate/route/handler/Key change (predicates `contextFor` /
`specs` / `plateLabel` / `mileageLabel` byte-identical):

| Change | Surface | Replacement | Notes |
|---|---|---|---|
| `vhCountMany(0/1)` → `vhCount(n)` ICU plural (`=0{0 …}` / `=1{1 …}` / `other{{count} …}`, en+ar, no renames) | vehicles header subtitle (all + filtered, ≤5 and >5) | `vhCount` | Fixes "1 registered vehicles"; zero renders as `0` (U11); `vhCountNone` kept for truly empty; `gen-l10n` from `apps/customer_app` |
| Year shown twice (title + specs) → ONCE | record card (`customer_vehicle_record.dart` display only) | title keeps `Make Model · Year`; specs line shows colour + mileage (`White · 45000 km`) | `specs()` untouched; display filters the year token; VIN untouched; search still matches year via `specs()` |

## Customer bookings-list recomposition (branch `ui/list-customer`)

Bookings list (`customer_bookings_tab.dart` + `customer_booking_item.dart` +
`customer_failed_booking_item.dart` + new `customer_bookings_search_sheet.dart`
+ `customer_bookings_filter_sheet.dart`) recomposed presentation-only;
providers/sync/refresh, `groupOf`/`sortByUpcoming`/`sortByRecent`/
`scheduleLabel`/`referenceOf`/`bookingKey` predicates, `selectTab`, all routes,
Keys and error mapping untouched. Legacy usages below drop to zero on the
bookings surface (verified by grep; the shared classes themselves are kept —
still used by home/status/detail/approval sheets and other customer surfaces):

| Deleted legacy widget | Homes before | Replaced by | Notes |
|---|---|---|---|
| bespoke `_BookingsHeader` (headline + subtitle + `TextButton.icon` Book) | bookings tab (1) | `AppPageHeader` (title `bkTitle` + verbatim `_subtitle`, same copy; search + filter `AppIconButton`s top-right ONLY when loaded list > 5 — the ONE sanctioned U1 exception, vehicles-list precedent; `TextButton.icon` Book kept when non-empty) | Same title/count/Book copy + destinations; ≤ 5 items = cards only, no find-aids |
| (no search affordance) | bookings tab (0) | `CustomerBookingsSearchSheet`: `showAppModalSheet` + `AppSearchField` (`bkSearchHint`) over loaded records (service/vehicle/plate/reference substring, plates punctuation-insensitive); result tap closes + reveals the record via `ensureVisible`; no-match (`bkSearchNoMatch`) + `Clear` | Permitted "list-scoped search over loaded records"; no new routes/logic |
| (no filter affordance) | bookings tab (0) | `CustomerBookingsFilterSheet`: `showAppModalSheet` + `AppChip` single-select (All / `bkFilterUpcoming` / `bkFilterInService` / `bkFilterHistory`) + `Show results` + `Clear`; in-place filter via existing `groupOf`, counts update verbatim, no-match + `Clear` | Only honest facets (group derived via existing predicate); no new routes/logic |
| bespoke `_BookingSection` bordered `DecoratedBox` + dividers | bookings tab (1 per section) | whitespace-separated `AppSurfaceCard(outlined: false)` rows (borderless light w/ shadow, bordered dark) with the same split predicate (two sections → `AppSplitView`, else single) | `AppListGroup` is settings-rows only; same atoms, same layout rule |
| bespoke row chrome (`StatusPill.toUpperCase`, `_DateBlock`/`_IconTile` container, `_StateLine`, `_RowAction` styling; hardcoded EN copy) | row (per card) | date-block anchor kept; title = service (`bkServiceAppt` fallback); `AppStatusChip` sentence-case (`.toUpperCase()` removed, tone→kind mapping preserves semantics); stage via `jsStage`, approval via `bkApprovalMsg`/`bkApprovalEst`, track via `bkdTrack`, review via `bkReview`; reference mono LTR; direct `Review`/`Track service` + row-tap open kept | Card hierarchy binding (title/status/meta); taps never regress |
| bespoke failed row chrome (`StatusPill('NOT SENT')`, hardcoded EN body, `TextButton`/`FilledButton` styling) | failed row (per card) | `AppStatusChip` (`bkfNotSent`, sentence case); ARB body (`bkfSendBody`/`bkfWaitingBody`); inline Retry (`bkRetry`/`bkfRetrying` busy) + Remove (`vhRemove` reuse) | Same retry/remove handlers; busy guard kept |
| bespoke `_NoBookings` panel (`CustomerSurfacePanel` + icon + title/body + filled CTA) | bookings tab (1) | `AppEmptyState` (exactly 1 icon + 1 sentence + 1 action: `bkBookCta` with vehicles, `garHeroAdd` without) | Same copy/destinations |
| `EmptyState` first-load error | bookings tab (1) | `AppErrorState` (`bkLoadFailTitle`/`bkLoadFailBody` + `bkRetryCta`, same retry) | Same copy/retry |
| `AppSkeleton` bookings skeleton | bookings tab (1) | `AppShimmerSkeleton` (header lines + `card(148)` x2) mirroring the cards | Same loading contract (`isLoading && isEmpty`) |
| `CustomerRefreshNotice` stale notice | bookings tab (1) | `AppBanner` warning (same `stRefreshFail` + `stRetry` + retry) | Same copy/retry; stale data kept |
| `showAppConfirmationDialog` (destructive) on this surface | failed section (1) | confirmation bottom sheet via `showAppModalSheet` (same `bkRemoveTitle`/`bkRemoveBody`/`bkRemoveCta`/`bkKeepCta` + invalidate contracts, destructive confirm, NO undo) | Same handler/copy; presentation only |

Kept verbatim (predicates, providers, router untouched):
`groupOf`/`sortByUpcoming`/`sortByRecent`/`scheduleLabel`/`timeLabel`/
`referenceOf`/`bookingKey`/`identityKey` reconciliation,
`CustomerServiceTracking.bookingTone`/`bookingForJobCard`/`humanize`/
`isLiveService`, `dash.formatAmount`, `_subtitle` parts, `AppSplitView`
predicate, `RefreshIndicator`, bottom nav (no rail — consumer contract),
haptics, confirmation + snackbar (`bkSendFail`) contracts. No new routes.
Fifteen new ARB keys (`bkSearchTitle/Hint/NoMatch`,
`bkFilterTitle/All/Upcoming/InService/History/Show/NoMatch/Clear`,
`bkfNotSent/SendBody/WaitingBody/Retrying`, en+ar, gen-l10n from
`apps/customer_app`).

Fixer note (gating U5, `_DateBlock` in `customer_booking_item.dart`,
presentation-only, same date/time data + predicates/routes): the fixed
`SizedBox(width: 60)` + `maxLines: 1` ellipsis cut schedule time to `9:00 …`
at 1.3x (AM cut; 1.0x/320px full). The block is now scale-aware — width
`60 × textScaler` (clamped 60–96) and the time wraps once at the token
boundary (`maxLines: 2`, center, `9:00` / `AM`) — so `9:00 AM`-style times
render whole at 1.3x/360 and stay intact at 320px/1.0x/ar/dark (guard:
`customer_booking_date_block_scale_test.dart`; living-record frames
`after-customer-bookings` re-captured + compared back-to-back green).

## Customer notifications-list recomposition (branch `ui/list-customer`)

Notifications inbox (`customer_notifications_view.dart`) recomposed
presentation-only; providers/sync/refresh, `groupOf`/`labelOf`/`tone`/
`destination` predicates, `markRead`/`markAllRead` + rollback, all routes, Keys
and error mapping untouched. Legacy usages below drop to zero on the inbox
surface (verified by grep; the shared classes themselves are kept — still used
by approvals/detail/status/profile/book-service/breakdown surfaces):

| Deleted legacy widget | Homes before | Replaced by | Notes |
|---|---|---|---|
| `Scaffold` + `WorkspaceAppBar` page chrome | inbox (1) | `AppScaffold` + `AppAppBar` (title `ntTitle`, same back behavior; max-width 860 kept) | Same title/back/width; bell entry (shell) untouched |
| (no search/filter affordances) | inbox (0) | NONE BY DESIGN (brief deviations with written reasons: recency triage needs no text-find; categories already are the group sections — a filter would duplicate them, U7; no destructive action exists for a remove sheet) | No new routes/logic; no invented find-aids |
| bespoke `_GroupSection` bordered `DecoratedBox` | inbox (1 per group) | whitespace-separated `AppSurfaceCard(outlined: false)` rows (borderless light w/ shadow, bordered dark; 12 gaps) | Same group titles/order; `AppListGroup` is settings-rows only |
| bespoke row chrome (tint `Material` + `InkWell` + dot `Container` + icon + chevron `Padding`; `left` padding) | row (per notification) | same atoms (unread tint, dot slot, icon, `DirectionalIcon` chevron — mirrors in RTL, `EdgeInsetsDirectional`) with byte-identical behavior; hierarchy binding (title → body → category·time meta) | Same tappability/chevron predicate; Semantics label kept |
| bespoke `_SummaryRow` styling | inbox (1) | same row rebuilt on tokens (count text + `Mark all read` iff `unread > 0`) | Same copy/predicate/handler |
| bespoke `_AllCaughtUp` / `_LoadFailure` panels | inbox (1 + 1) | `AppEmptyState` (exactly 1 icon + 1 sentence, NO action — calm empty, U6) / `AppErrorState` (`ntLoadTitle`/`ntLoadBody` + `ntRetry`, same `_refresh`) | Same copy/retry; adding a CTA would be a fake action |
| `AppSkeleton` inbox skeleton | inbox (1) | `AppShimmerSkeleton` (summary line + `card(86)` x4) mirroring the rows | Same loading contract (`isLoading && isEmpty`) |
| `CustomerRefreshNotice` stale + `CustomerNoticePanel` mark-fail | inbox (1 + 1) | `AppBanner` warning (`stRefreshFail` + `stRetry`, same retry) + `AppBanner` error (`ntMarkFail` + `ntRetry`, same `_markAllRead`, rollback kept) | Same copy/retry; stale data kept |

Kept verbatim (predicates, providers, router untouched): `groupOf`/`labelOf`
frozen mappings, `_grouped` bucketing + stable order, `icon`/`tone`/`toneColor`/
`destination`/`isActionable`, `NotifType.fromWire` fallback, `markRead`
background persist, `markAllRead` bulk + rollback, `RefreshIndicator` +
pull-to-refresh, bell + badge (shell), back behavior, Semantics contracts
 (bell announcement, row label, group headers). No new routes. No new ARB keys
 (all copy reuses existing `nt*` + `stRefreshFail`/`stRetry`).
## Advisor jobs register (branch `ui/list-staff-jobs`, GROUP-B screens 1+2)

Jobs list (`advisor_jobs_view.dart` + `advisor_job_card_row.dart` +
`advisor_job_card_sheet.dart`) recomposed presentation-only onto App* pattern
widgets; providers/routes/sync logic, `advisorStatusFilterKey` taxonomy,
search/filter/sort predicates, selection state, sheet contracts and all copy
semantics untouched (one new count key only, see below). Screen 2
(inspection / repair-order lists) has no separate surface — the jobs register
IS the unified surface (see `briefs/advisor-inspection-repairorder-lists.md`
for the router/grep evidence) — so this single mapping governs both screens.
No new routes. Filter rail + sort stay inline (top-3 tap budgets forbid a
filter sheet; see brief deviations 1–2); wide keeps the `AppTable`
master-detail matrix (C9 responsive rule; deviation 3).

| Deleted legacy widget | Homes (call sites) | App* replacement | Notes |
|---|---|---|---|
| bespoke title row (`titleLarge` 800 + `StatusPill.neutral(count)`) | jobs header (1) | `AppPageHeader` (title `advisorJobsTitle` + count subtitle via new `advisorJobsCountNone/One/Many`) + search `AppIconButton` top-right ONLY when loaded `jobCards.length > 5` | Same title/copy; count once in subtitle; U1-exception note as on vehicles-list |
| inline `AppSearchField` (mid-page) | jobs list (1) | header icon → existing `AdvisorSearchSheet` full-screen (same predicate/recents/scan/Enter/top-hit/result-push; `onScan` → `AppRoutes.scanVehicle` home parity) | Same query state + routes; inline field removed (audit: exactly one visible search icon per screen) |
| `AppInfoPanel.danger` error styling | jobs list (2: top banner + first-load) | `AppBanner` warning (stale + last data) / `AppErrorState` (first-load + Try again) | Same messages (`advisorDataError` + `advisorOfflineNotice`); same invalidate retry; retry label stays verbatim `advisorActionRefreshJobCard` |
| `LinearProgressIndicator` thin bar | jobs loading (1) | dropped (skeleton owns loading; no permanent chrome) | C16 no-permanent-status-chrome |
| `AppSkeleton.listRows` compact skeleton | jobs loading (1) | `AppShimmerSkeleton.card` x3 mirroring the cards | Same loading contract (`isLoading && isEmpty`); wide `AppTable` skeleton kept (already App*) |
| `EmptyState` / `EmptyState.noMatch` + bespoke buttons | jobs empty/no-match (2) | `AppEmptyState` (1 icon + 1 sentence + 1 New-job-card action → same wizard) / `_JobsNoMatch` (one sentence + shared Clear, vehicles precedent) | Same copy/routes; Clear resets search AND filter verbatim |
| bordered divider container + `AdvisorJobCardRow` 72px rows | compact list (per card) | same class rewritten as borderless `AppSurfaceCard(outlined: false)` rows (customer·vehicle title → ONE `AppStatusChip` → meta + LTR mono id + chevron/more) | Tap = open preserved; overflow → same quick sheet; fixes 360px pill mid-word truncation |
| `AppCard.standard` + `PrimaryButton` Check In + `StatusPill.info` | intake-queue section (1 + ≤3 rows) | `AppSurfaceCard(outlined: false)` (header + info `AppStatusChip`) + per-row `_BookingRow` + `AppPillButton.primary` small Check In | Same copy/routes/extras/cap of 3; one filled action per row (vehicles Book-direct precedent) |
| `showModalBottomSheet` + `AdvisorSheet` chrome | quick preview sheet (1) | `showAppBottomSheet` + `AppBottomSheet` chrome; `AdvisorJobCardSheet` now content-only | Content + Close/Open + handlers byte-identical |
| `_JobAvatar` bespoke circle | wide preview (1) | `AppAvatar` small | Same identity data |
| `_JobPreviewTile` bespoke label/value rows + `AppCard.standard` + `PrimaryButton` | wide preview (1) | `AppDataRow` rows (mono `valueWidget` for id/odometer) + `AppSurfaceCard(outlined: false)` + `AppPillButton.primary` Open | Same fields/routes/selection; `_shown()` keeps `--` for blanks; `cellFlex: [3,2,2,4,2]` added (rows ignore column flex — Status owns the widest share so single-word chips never break mid-word) |
| `PrimaryButton` / `SecondaryButton` / legacy buttons | jobs surfaces (all above) | `AppPillButton` variants (map above) | Same emphasis/routes; module contributes zero legacy-button call sites on its surfaces |
| `StatusPill` via `advisorStatusPill` | jobs list + preview + table (3 sites) | new additive `advisorStatusChip(t, status)` (same vocabulary, same kind mapping) | `advisorStatusPill` itself untouched (home/detail/sheets still use it) |

New ARB keys (`advisorJobsCountNone/One/Many`, en+ar, `gen-l10n` from
`apps/staff_app`): header count subtitle (One/Many pair convention, no ICU —
same as `techProdRepairOne/Many`); `Customer A–Z` keeps its U+2013 en dash
 byte-identical (found during characterization).
## GROUP-C supervisor Jobs list (branch `ui/list-ops`, screen 1)

`supervisor_jobs_tab.dart` recomposed presentation-only onto App* pattern
widgets; providers/predicates/buckets/progress math/routes/sheets/copy/keys
untouched (zero new ARB keys); scaffold bar guard + compact 4+More + expanded
7-rail untouched; STOP honored (inline register filter + bar bay-search kept:
different entity/fields/scope/contract, see
`evaluation/phase-jobs-search-audit-review.md` §2).

| Deleted legacy widget | Surface | Replaced by | Notes |
|---|---|---|---|
| `PrimaryButton(` (Jobs header Assign, 1 site) | supervisor Jobs tab | `AppPillButton.primary` (small, non-expanded, same label/icon/handler) | One filled accent per section kept (Assign only) |
| `EmptyState(` + `EmptyState.noMatch(` (2 sites) | supervisor Jobs tab empty + no-match | `AppEmptyState` (icon/title/message/action 1:1; no-match title reuses shared `commonNoResults`, zero new keys) | Bidi-isolated title/message; tests match by containment |
| `AppSkeleton.listRows(` (1 site) | supervisor Jobs tab loading | `AppShimmerSkeleton.listRows(rows: 6)` (row-mirroring) | Same row count |
| `AppInfoPanel.danger(` (1 site) | supervisor Jobs tab error | `AppErrorState` (title reuses shared `commonErrorTitle`, message `svJobsError` verbatim, retry `commonRetry` → same refresh) | Live-region kept |
| `AppLinearProgress(` (1 site) | supervisor Jobs tab row meter | `AppProgressBar(value:)` (auto tone; status meaning stays on rail + pill) | Progress math byte-identical |
| `Divider(` (1 site) | supervisor Jobs tab row separator | `AppDivider()` (spec hairline) | Full-bleed kept |
| KEPT (STOP/pinned, not legacy) | supervisor Jobs tab | `AppFilterBar` + `AppPageHeader` + `supervisorStatusPill/Tone/Mono` | Status-rail + bucket predicate byte-identical |
| MOVED (ruling (a) scope unification, `ui/fix-rulings`) | supervisor Jobs tab inline `AppSearchField` (1 site) | NEW `supervisor_register_search.dart` sheet: `showAppModalSheet` + `AppSearchField` (`svJobsSearchHint`) over `AssignedJobEntity` (same 4-field predicate: `jobCard`/`customer`/`vehicle`/`status`); result tap = same assign sheet; Jobs-tab shell icon opens it, inline removed | Supersedes the §2 dual-search STOP by scope unification (recorded in `evaluation/supervisor-jobs-list-test-migration.md`); zero new keys; one visible search path per screen |

## GROUP-C supervisor Queue list (branch `ui/list-ops`, screen 2)

`supervisor_queue_tab.dart` recomposed presentation-only onto App* pattern
widgets: providers/sort/buckets/refresh/picker-sheet/toast contracts/copy/keys
untouched (zero new ARB keys); scaffold bar guard + compact 4+More + expanded
7-rail untouched; no list-scoped search icon added (brief deviation B: the
bar bay-search is this surface's single search path); header subtitle stays
static with counts on the section labels (deviation A).

| Deleted legacy widget | Surface | Replaced by | Notes |
|---|---|---|---|
| `SecondaryButton(` (row Assign) | supervisor Queue rows | `AppPillButton.secondary` (full-width, same label/icon/handler) | Frequent action stays directly on each card |
| `PrimaryButton(` (picker confirm) | supervisor Queue advisor picker | `AppPillButton.primary` (same label/icon/handler) | Same sheet, same notifier, same toasts |
| `StatusPill.danger/warning/info/neutral` (priority pills) | supervisor Queue rows | `AppStatusChip` (error/warning/info/neutral, same labels; normal renders no pill) | Dot + label, meaning never color-alone |
| `EmptyState(` + `EmptyState.noMatch(` | supervisor Queue empty + no-match | `AppEmptyState` (1:1 copy; no-match title reuses shared `commonNoResults`) | Honest empty carries NO action (nothing to create); tests match copy by containment (bidi isolation) |
| `AppSkeleton.listRows(` | supervisor Queue loading | `AppShimmerSkeleton.listRows(rows: 6)` | Row-mirroring |
| `AppInfoPanel.danger(` | supervisor Queue error | `AppErrorState` (title `commonErrorTitle`, message `svQueueError` verbatim, retry `commonRetry`) | Error/skeleton are refresh-driven (provider-owned quirk pinned: first load surfaces empty; untouched) |
| `Divider(` | supervisor Queue row separators | `AppDivider()` | Full-bleed kept |
| KEPT (pinned/not legacy) | supervisor Queue | `AppPageHeader` + header refresh + `AppFilterBar` + `showAppModalSheet` picker + `showSupervisorToast` + `_SectionLabel` badge layout + `_EmptyLine` | Badge stays token-only layout (accent `AppBadge` would add a second filled accent per section — C16); scaffold bar + nav untouched |

## GROUP-C supervisor Review list (branch `ui/list-ops`, screen 3)

`supervisor_review_tab.dart` recomposed presentation-only onto App* pattern
widgets: providers/awaiting derivation/progress math/refresh/sheet-entry
contracts/copy/keys untouched (zero new ARB keys); scaffold bar guard +
compact 4+More + expanded 7-rail untouched; no list-scoped search icon, no
filter rail (brief deviations B/C: bar bay-search — which covers awaiting
records via `buildSupervisorBays(awaiting: ...)` — is the single search path;
nothing honest to facet); header subtitle stays static (deviation A: no
honest existing count key).

| Deleted legacy widget | Surface | Replaced by | Notes |
|---|---|---|---|
| `PrimaryButton(` (row Start QC) | supervisor Review rows | `AppPillButton.primary` (full-width, same label/icon/handler) | Frequent action stays directly on each card; sheet entry verbatim (sheet internals untouched) |
| `StatusPill.info(` (progress pill) | supervisor Review rows | `AppStatusChip` (info, same `svReviewProgress(done,total)` label) | Dot + label, meaning never color-alone |
| `EmptyState(` (no action) | supervisor Review empty | `AppEmptyState` (1:1 copy, no action — honest empty) | Tests match copy by containment (bidi isolation) |
| `AppSkeleton.listRows(` | supervisor Review loading | `AppShimmerSkeleton.listRows(rows: 5)` | Row-mirroring |
| `AppInfoPanel.danger(` | supervisor Review error | `AppErrorState` (title `commonErrorTitle`, message `svReviewError` verbatim, retry `commonRetry`) | Error/skeleton are refresh-driven (provider-owned quirk pinned: first load surfaces empty; untouched) |
| `AppLinearProgress(` | supervisor Review row meter | `AppProgressBar(value:)` (auto tone) | Progress math byte-identical |
| `Divider(` | supervisor Review row separator | `AppDivider()` | Full-bleed kept |
| KEPT (pinned/not legacy) | supervisor Review | `AppPageHeader` + header refresh + `showQcChecklistSheet` entry + sheet/toast contracts + mono/initials helpers | No filter rail (U3: inventing one would be a fake control); scaffold bar + nav untouched |

## GROUP-C technician jobs list (branch `ui/list-ops`, screen 4)

`technician_jobs_view.dart` recomposed presentation-only onto App* pattern
widgets: providers/order/predicates/refresh/routing/dossier/sheet contracts,
copy/keys untouched (zero new ARB keys); shell `_TechChrome` guard + tab
targets + search sheet untouched; no inline search re-added (blessed STOP);
no in-body header (shell owns the title — deviation A); no > 5 gate on the
blessed shell icon (deviation B); no per-row buttons (would duplicate dossier
actions — deviation C); shared rows untouched (deviation D: STOP boundary —
`TechnicianJobSummary` is shared with Today + the search sheet).

| Deleted legacy widget | Surface | Replaced by | Notes |
|---|---|---|---|
| `EmptyState.error(` | technician Jobs first-load error | `AppErrorState` (title `commonErrorTitle`, message `techJobsLoadError` verbatim, retry `commonRetry` → same refresh) | Live-region kept; tests match copy by containment (bidi isolation) |
| `EmptyState(` | technician Jobs empty | `AppEmptyState` (same icon/title/message/Refresh → same refresh) | Honest empty, one action |
| `EmptyState.noMatch(` | technician Jobs no-match | `AppEmptyState` (icon search_off, same title/message/Clear → `updateSearch('')` + `updateFilter('All')`) | Same reset contract |
| `AppSkeleton.listRows(` | technician Jobs loading | `AppShimmerSkeleton.listRows(rows: 4)` | Row-mirroring |
| `_SavedDataNotice` bespoke Container | technician Jobs stale notice | `AppBanner` warning (same `dashboardError` copy, live-region) | Abnormal-only banner, no permanent pill |
| `Divider(` (separator) | technician Jobs row separators | `AppDivider()` | Full-bleed kept |
| KEPT (STOP/pinned, not legacy) | technician Jobs | `AppFilterBar` rail + `TechnicianJobSummary` rows + `_urgentFirst` + `_FreshnessFooter` + `openJob`/`push`/`closeJob` + shell chrome + search sheet | Zero `AppSearchField` in this file (blessed single-search); shell + sheet + Today untouched |

## GROUP-C owner job-cards register (branch `ui/list-ops`, screen 5)

`job_cards_list_view.dart` recomposed presentation-only onto App* pattern
widgets: providers/predicate/presentation-sort/selection/open/table/row atoms,
copy/keys untouched (zero new ARB keys); app bar + nav untouched; no header
search icon at any size (audited single affordance — deviation B); no
`AppPageHeader` swap (workspace chrome ownership — deviation A); table kept on
wide — the homogeneous-audit case (deviation C); shared atoms/helpers kept
(deviation D: STOP boundaries — `AppTable`/`AppRecordRow` are shared-core
atoms, `jobStatusPill` is shared with the detail view). Owner dark verified
with before/after dark frames (no regression).

| Deleted legacy widget | Surface | Replaced by | Notes |
|---|---|---|---|
| `StatusPill.neutral(` (bar count) | owner register app bar | `AppStatusChip` neutral (same `ownerRegCount` label) | Header with count kept; still zero header search icons |
| `AppCard.standard(` (preview prompt + dossier-mini) | owner register wide preview | `AppSurfaceCard` (same padding/body; border-XOR-shadow; dark keeps border) | Same select + Open contracts |
| `EmptyState(` (select prompt) | owner register wide preview | `AppEmptyState` (title reuses existing `ownerRegTitle`, message `ownerRegSelectPrompt` verbatim, no action) | One icon + one sentence, no action |
| `PrimaryButton(` (preview Open) | owner register wide preview | `AppPillButton.primary` (same label/handler) | One filled accent per pane |
| KEPT (STOP/pinned, not legacy) | owner register | `WorkspaceAppBar` + back + header search (icon + full sheet, same predicate) + `AppFilterBar` + milestone mapping + `AppTable` + `compactBuilder` + `AppRecordRow` + pill-block fix + `jobStatusPill` (shared helper now renders sentence-case display-side, item-1 fix, data verbatim) + `formatAed2` + providers/sort/selection/open/routes/keys | Inline field removed (header-icon + full sheet, same predicate); detail view + shared atoms untouched; no error panel exists on this surface (provider has no error branch — pinned) |
## CRM lists recomposition (branch `ui/list-crm`)

Leads (`crm_leads_page.dart`), tasks (`crm_tasks_page.dart`) and sales
team (`crm_sales_team_page.dart`) recomposed presentation-only;
providers/sync/predicates/refresh/sort/routes/Keys/handlers untouched.
New shared sheets: `crm_leads_search_sheet.dart`,
`crm_leads_filter_sheet.dart`, `crm_tasks_search_sheet.dart`,
`support/lead_contact_actions.dart` (byte-identical dialer/WhatsApp
intents). Legacy usages below drop to zero on these three surfaces
(verified by grep; the shared classes themselves are kept — still used
by kanban/detail/form/connect sheets and other CRM surfaces):

| Deleted legacy widget | Homes before | Replaced by | Notes |
|---|---|---|---|
| inline `AppSearchField` (leads) | leads page (1) | `AppPageHeader` + header search `AppIconButton` ONLY when loaded > 5 (sanctioned U1 exception) + list-scoped search sheet (`showAppModalSheet` + `AppSearchField` over rendered records, result reveals record, no-match + Clear) | Collapses the inline+palette duplicate per the single-affordance rule (brief §Single-affordance audit); no new routes/logic |
| bespoke `_filterToolbar` (`AppFilterBar` x2 + tonal Add + pills) | leads page (1) | source/agent filter bottom sheet (`AppChip` groups + Show results + Clear; same provider/local predicates + `refresh()` call sites) + `leadsCountN` ICU header subtitle + dismissible stage `AppChip` | Fixes "1 Leads"; `leadsCount`/`filter*` keys kept (no renames); new keys `leadsSearchTitle/NoMatch`, `leadsFilterTitle/Show/NoMatch/Clear`, `leadsCountN` (en+ar, `gen-l10n` from `apps/crm_app`) |
| `AppRecordRow` + `StatusPill` record styling | leads cards (per record) | borderless `AppSurfaceCard(outlined: false)` + `AppStatusChip` (sentence-case display, kind by status name) + LTR value meta + direct `Call` `TextButton.icon` + `PopupMenuButton` (WhatsApp/Edit/Delete, existing destinations) | Card hierarchy (name → pill → meta); stage codes verbatim, matching uppercase; entity `statusColor` not mapped (would be guessing) |
| bespoke empty panels (link-off/people + `ElevatedButton.icon`) | leads page (2) | `AppEmptyState` (1 icon + 1 sentence + 1 action → same connect/sync handlers) + verbatim captions kept | New: filtered-to-zero is a real no-match + Clear (old tree showed connect/sync empties there) |
| (no skeleton) | leads page (0) | `AppShimmerSkeleton` (header lines + `card(148)`) when `ui.isLoading && empty` | No error branch: no error signal in lead providers (logic candidate, filed in session return) |
| `AppTable` cell `StatusPill` + dossier `StatusPill`/`_DossierRow`/hardcoded styles | leads wide table + dossier (medium+) | `AppStatusChip` + `AppDataRow` (LTR-locked) + `AppPillButton.secondary` Edit (same dossier destination) | Same columns/sort/selection; kanban + detail/form/connect sheets kept verbatim |
| bespoke header row (count `Container` + 32px refresh + Add pill) + raw `showModalBottomSheet`/`AlertDialog` | tasks page + form + delete (3) | `AppPageHeader` (title + `tkCountN` ICU subtitle) + search icon ONLY when > 5 + refresh `AppIconButton` + `TextButton.icon` Add; form via `showAppModalSheet` (`AppInputField`s + `AppDropdown` assignee + `AppChip` priority + `AppPillButton` save w/ `busyLabel`); delete via `showAppDialog` destructive (explicit `onPrimary` pops `true` — default pops null) | Same toggle/CRUD/refresh/`_dueStateOf`/team source/`Unassigned → ''` mapping; new keys `tasksSearchTitle/Hint/NoMatch`, `tkCountN` (old `tkCount` kept); `showAppDialog` null-pop found by failing test, fixed in production |
| white `Container` task card (border AND shadow, 30px targets, bare meta `Text`s) | tasks cards (per task) | borderless `AppSurfaceCard(outlined: false)` + 48dp toggle (24px visual, same `taskToggle_<id>` keys) + `Flexible` meta (ellipsis) + `AppStatusChip` due/priority pills + 48dp `AppIconButton` edit/delete with tooltips | `Flexible` fixes a 6px Row overflow the suite caught; priority labels verbatim (server English, LOGIC #9 family), kinds by name |
| bespoke `_TaskFormSheet` chrome (raw `TextField`s, custom dropdown/priority containers, `ElevatedButton`) + team loading/error containers | tasks form (1) | `AppInputField` (title w/ error, due LTR) + `AppDropdown` assignee (loading → disabled hint; error → `AppBanner` error, verbatim `tkTeamFail`) + `AppChip` priority + `AppPillButton` save | Same fields/validation/save mapping; no skeleton branch (`isLoading` never set — logic candidate) |
| `SectionHeader` + bespoke card `Container` (border+shadow, gradient avatar, hardcoded styles) + legacy `EmptyState` | sales team page (1 header + per-row cards) | `AppPageHeader` (title + subtitle, no count suffix — would misread against `tmLeads`) + borderless `AppSurfaceCard(outlined: false)` + `AppAvatar` (40) + theme type + rank badge (`#n`, accent tint ≤ 3) + tabular LTR revenue (success ink) + token stat blocks (`surfaceContainerHighest`) + `AppProgressBar` (pinned accent, same value + semantics) + action-less `AppEmptyState` (U6 calm) | No new ARB keys (all `tm*` reused); no search (reasoned U1 exception — roster fits one screen, no per-row destinations); gradient removed (C16); no skeleton/error signals in feed (logic candidates) |

## DETAIL technician job detail (branch `ui/detail-technician`, screen 1)

`job_detail_sheet.dart` (`TechnicianJobDetailView`) recomposed
presentation-only onto App* pattern widgets: providers, status machines
(task + derived job sync + `completeJob` handover), sync/offline queue,
routes, sheet contracts, copy semantics, shell chrome untouched; no new
routes. One new ARB key (`techDetailCompleteRepairOn`, en+ar, `gen-l10n`
from `apps/staff_app`); seven dead detail-only keys removed. Search wired
to the existing `showTechnicianTodaySearch` sheet (same jobs/predicate,
same `openJob`/`push`/`closeJob` contract — U1 placement).

| Deleted legacy widget | Surface | Replaced by | Notes |
|---|---|---|---|
| `AppCard.standard(` (hero + focus + rows + notice) | technician detail hero/focus/rows | `AppSurfaceCard(outlined: false)` (borderless light, shadow; dark keeps border) | Hero carries identity + progress only (second pill removed — one pill per screen) |
| bespoke `_GreaseButton.fill` (cobalt/amber/emerald) + `_TaskAction` (filled/outlined triplets) | technician detail focus + rows | `AppPillButton.primary` (focus next step, `busyLabel`) + `ghost` (Hold) / `secondary` + `ghost` small (rows) | One filled accent per section; meaning via icon + label, never color alone |
| bespoke `PrimaryButton` dock | technician detail sticky CTA | `_HandoverBar` (spec chrome, CTA-priority flex) on compact; `AppPillButton.primary` in the wide rail (never both) | Atom split 50/50 truncates the CTA at 320px (U5) — custom composition keeps the full label |
| `showAppConfirmationDialog` | technician detail handover | `showAppDialog` (title `techDetailCompleteRepairOn(ref)` names the object — U10; explicit bool pops) | Body/cancel/confirm verbatim |
| `showAppModalSheet` | technician detail parts/escalation openers | `showAppBottomSheet` (same sheet content, own submit — no added steps) | Taps stay 3 = 3 |
| bespoke `_DelayedNotice` Container | technician detail delayed | `AppBanner` warning (`techDetailDelayedHint` verbatim) | Abnormal-only banner, live region |
| `SectionHeader` (ALL CAPS subtitles) + bespoke `_HelpActions` outlined buttons | technician detail sections + support | `AppSection` (sentence-case titles, `View all` only when > 3 — U7) + `AppListGroup` (Support rows → sheets, chevrons, inset dividers) | Dead ALL-CAPS ARB keys removed |
| no-tasks hint `Text` + `AppLinearProgress` | technician detail empty + hero progress | `AppEmptyState` (no action — U6) + `AppProgressBar` (same value + label, pinned accent) | Zero as 0; tests match copy by containment (bidi isolation) |
| KEPT (STOP/pinned, not legacy) | technician detail | `WorkspaceAppBar` (+ permanent `Synced` pill — shared chrome STOP) + `onSearch` wiring + `technicianStatusPill`/`StatusPill` + `TechnicianStopwatch`/`TechnicianPlateChip` + sheets content + providers/routes/sync/machines + medium single-column + sticky bar (verbatim `adaptive.pick` parity) + offline/pending chrome | Status machine + transitions honored verbatim (start/complete/hold/resume/`completeJob`/read-only locked); loading/error states live on the list screens (entity-driven detail) |
