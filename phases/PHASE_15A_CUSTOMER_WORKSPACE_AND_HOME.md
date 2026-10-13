# PHASE 15A — Customer: Workspace Shell, Home & Profile

## A. Phase identity

- **Phase number:** 15A (part 1 of 2; split from the former Phase 15)
- **Title:** Customer Workspace Shell, Home & Profile (navigation model, status-first landing, account surface)
- **Objective:** Redesign the customer's structural surfaces — the workspace shell (4 destinations), the status-first Home tab and the Profile tab — onto the unified system while preserving the contextual routing model (`?tab=` redirects, contextual Status/Approvals pages) and all refresh/offline behaviors.
- **Priority:** High
- **Dependencies:** Phases 01–05
- **Estimated scope:** Large

## B. Repository context

Files (relative to `apps/customer_app/`):

- Shell: `lib/features/customer/presentation/customer_dashboard_view.dart` +
  `widgets/customer_scaffold.dart` — `DashboardShell` +
  `AppAdaptiveNavigationFrame`, `OrientBrandMark(workspace: 'Customer')`,
  "My Account" rail footer, `AppBottomNavigation` on compact, no app bar (tabs
  own headers); `CustomerDestination {home, bookings, vehicles, profile}` +
  legacy `?tab=` redirects in `lib/core/router/app_router.dart`.
- Home: `widgets/customer_home_tab.dart` (+ `customer_home_header.dart`,
  `customer_status_notices.dart` `CustomerAttentionPanel`,
  `customer_home_service_summary.dart` live/active/welcome/idle,
  `customer_home_quick_actions.dart`, `customer_home_garage_summary.dart`,
  `_RecentActivitySection`, `customer_home_skeleton.dart`).
- Profile: `widgets/customer_profile_tab.dart` + `customer_profile_rows.dart`
  (part file); actions: vehicles, roadside, reset password, licences, sign out;
  `customer_notice_panel.dart`, `_ProfileSkeleton`.
- Router error pages: `_RouteErrorPage` in `core/router/app_router.dart`
  (booking-detail/booking-success/breakdown-result/invoice builders +
  `errorBuilder`).
- Dead: `widgets/customer_empty_fallbacks.dart` (unused; legacy colors) —
  delete with proof.
- Shared custom surfaces used here: `customer_surface_panel.dart`,
  `customer_notice_panel.dart`, `customer_status_notices.dart`,
  `customer_plate_chip.dart`, `customer_skeleton.dart`.
- Providers: `providers/customer_providers.dart` (dashboard load, Hive
  fallback), auth-change invalidation + resume refresh in `main.dart`.
- **Bookings/Vehicles tabs + AddVehicleView are Phase 15B** — do not modify
  those files here (the shell must simply keep hosting them unchanged).

## C. Design objectives

1. **Home = "what's happening now".** Priority: attention/status panel (active
   service live state or next appointment, promoted to hero) → service summary
   with the single primary action (Track / Book / Review estimate) → quick
   actions (Book service, Roadside help, Add vehicle, Notifications) → garage
   summary → recent activity. Warmth via copy and spacing, not color noise.
2. **Profile = account + settings.** Identity (name, phone/email) → rows for
   vehicles/roadside/reset password/licences (as wired) → **Language switcher
   row (final placement)** → Sign out (confirm); `CustomerRefreshNotice` for
   stale refresh; profile failure panel preserved.
3. **Shell polish without behavior drift:** tab headers unified (scale/weight),
   no app bar retained (unless the prototype verdict in `00_VISUAL_DIRECTION.md`
   says otherwise — then apply), bottom-nav/rail/badge language identical to
   other apps, "My Account" rail footer preserved.
4. **Router fallbacks:** `_RouteErrorPage` → shared `EmptyState.error` grammar
   (title/message/action) with identical actions/locations; global
   `errorBuilder` page restyled.
5. **Dead-code removal:** delete `customer_empty_fallbacks.dart` after reference
   proof; document the `CustomerSurfacePanel` decision (keep restyled as a
   domain component vs replace by `AppCard` — prototype verdict informs this).
6. **Localization + no behavior change to refresh/offline notices.**

## D. Screens and workflows

| Screen | New hierarchy | Key interactions | States |
|---|---|---|---|
| `CustomerScaffold` | shell + 4 destinations + rail/bottom nav | tab switch, My Account footer | — |
| `CustomerHomeTab` | attention/status → summary + primary action → quick actions → garage → activity | track, book, review estimate, add vehicle, notifications | skeleton, first-load empty + `EmptyState`, refresh notice, error |
| `CustomerProfileTab` | identity → rows → language → sign out | navigate rows, switch language, sign out (confirm) | profile failure panel, skeleton |
| `_RouteErrorPage` (+ `errorBuilder`) | error state with action | recover action per route | — |

Route contracts (unchanged): `?tab=` legacy redirects, contextual status and
approvals links from Home, `/profile` behaviors.

## E. Responsive specifications

- **Compact:** bottom nav (4), header-in-tab pattern; home sections stack;
  quick actions 2-up tiles; 320 px: plate chips never overflow.
- **Medium:** rail; home 2-column (status | actions + garage).
- **Expanded/large:** content capped (`contentStandard`); home three-region
  layout (status hero | quick actions | garage/activity).
- RTL: quick-action grid mirrors; plate chips keep Latin content (logical
  layout); bottom-nav order mirrors.
- 1.3× scale: header and tiles wrap cleanly.

## F. Localization and RTL

- All strings localized (`customerHome*`, `customerProfile*`, router fallback
  copy) EN+AR; dates/times localized; identifiers Latin.
- RTL: full mirroring of tabs/rows/sheets/notices; direction icons flip.
- Tests: home/profile/navigation tests EN+AR; RTL assertions; 320 px clean.

## G. Design system integration

- Use: `AppResponsivePage`, `AppCard`/grouped-surface recipe, `AppRecordRow`,
  `StatusPill`, `AppButton`, `AppInfoPanel` (notices/refresh/failure),
  `AppSkeleton`, `EmptyState`, `ErrorView`, `AppConfirmationDialog`,
  `LanguageSwitcher`, `UserAvatar`, `CustomerPlateChip` (restyled domain
  component), `CustomerRefreshNotice` (restyled domain component).
- Retire: `customer_empty_fallbacks.dart` (delete);
  `CustomerSurfacePanel`/`CustomerSkeleton` decisions documented per C5/C6.
- No new tokens expected.

## H. Technical implementation

- Modify: shell + home (+ home widgets) + profile (+ rows) + router fallback
  pages; customer ARB; tests/goldens.
- Preserve: `CustomerDestination` enum + order, `?tab=` redirects, providers
  (dashboard load + Hive fallback), refresh/resume/auth-invalidation wiring,
  contextual navigation targets from Home.
- No route/provider/API changes; no new packages.

## I. Functional preservation

- Tab order, footer, deep-link redirects and contextual links unchanged.
- Refresh notice trigger logic unchanged.
- Profile sign-out/reset/licences behaviors unchanged.
- Bookings/Vehicles tabs still mount and behave (they are redesigned in 15B —
  do not break their imports/contracts here).
- Existing navigation/home/profile tests pass (copy/layout updates only).

## J. Testing requirements

- `melos run analyze:customer`; `melos run test:customer`.
- Update `customer_navigation_test.dart`, `customer_home_tab_test.dart`,
  `customer_profile_test.dart` for EN+AR, RTL, 320/390/768/1280, 1.3×; add
  attention-hero ordering test with an active-service fixture, router fallback
  pages test.
- Goldens: home + profile regenerated; AR goldens for home.

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run the customer app and visually review the shell,
   Home and Profile (incl. empty and failure states); no screen may be signed
   off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px).
3. **Locales** — EN-LTR and AR-RTL renders; tab mirroring, quick-action grid and
   status hero reviewed in AR.
4. **State matrix** — home: live service, upcoming, idle, first-load empty,
   refresh notice, error; profile: full, missing-field hiding, failure panel.
   Realistic vehicle/booking fixtures.
5. **Interaction verification** — tab switching, quick actions navigation,
   attention panel CTA, language switch live, sign-out confirm, fallback page
   recovery actions.
6. **Accessibility** — 1.0–1.3× scale clean; ≥48 px tiles; semantics on rows
   and status hero; contrast sampled.
7. **No visual overflow** at 320 px in either locale.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_15A/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Section D surfaces redesigned; dead fallbacks deleted with proof;
   `CustomerSurfacePanel`/`CustomerSkeleton` decisions documented.
2. Routing model unchanged; contextual links intact (tests).
3. EN/AR complete; RTL correct; responsive per E.
4. `melos run analyze:customer` + `test:customer` green; J2 evidence attached.

## L. Deliverables

- File changes + deletions; ARB counts; golden diffs; test evidence; known
  limitations.

## M. Completion gate

Stop after this phase. Phase 15B (bookings/garage/vehicle form) follows. Do not
begin until explicitly instructed.
