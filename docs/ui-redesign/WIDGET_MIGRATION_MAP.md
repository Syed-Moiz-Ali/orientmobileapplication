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
