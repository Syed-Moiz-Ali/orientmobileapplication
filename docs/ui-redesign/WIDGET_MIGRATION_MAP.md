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
