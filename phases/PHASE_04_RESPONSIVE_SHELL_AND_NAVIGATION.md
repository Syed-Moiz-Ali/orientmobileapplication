# PHASE 04 — Responsive Shell & Navigation System

## A. Phase identity

- **Phase number:** 04
- **Title:** Responsive Shell & Navigation System (finalize the family-wide frame)
- **Objective:** Finalize the authenticated shell, navigation chrome, page frames, and adaptive behavior in `shared_core` so all four apps share one polished, responsive navigation experience across phones, tablets, and desktop — and fix the known shell-level inconsistencies discovered in analysis.
- **Priority:** Critical (blocks all feature phases)
- **Dependencies:** Phases 01–03
- **Estimated scope:** Medium

## B. Repository context

- Shell/navigation files:
  - `packages/shared_core/lib/src/widgets/dashboard_shell.dart`
  - `packages/shared_core/lib/src/layout/app_adaptive_navigation.dart`
  - `packages/shared_core/lib/src/layout/app_responsive.dart`
  - `packages/shared_core/lib/src/widgets/app_top_bar.dart`, `app_page_frame.dart`, `app_page_header.dart`, `app_action_bar.dart`, `exit_confirmation_dialog.dart`, `offline_banner.dart`
- Current consumers:
  - `staff_app`: `AdvisorHomeView`, `SupervisorScaffold`, `TechnicianDashboardView` (all use `DashboardShell` + `AppAdaptiveNavigationFrame` + `AppBottomNavigation`; advisor has no FAB; supervisor has queue badge + FAB `SupervisorScaffold`; technician has 4 tabs).
  - `owner_app`: `DashboardBody` (4 tabs, `OwnerAppBar`).
  - `customer_app`: `CustomerScaffold` (4 tabs, no app bar, `OrientBrandMark` rail header, "My Account" footer).
  - `crm_app`: `CrmDashboardView` (8 tabs → drawer `AppNavDrawer` + adaptive rail; `CrmAppBar`).
  - `staff_app` supervisor sub-pages use a hand-rolled `SupervisorSubPageWrapper` app bar (in `app_router.dart`).
- Known inconsistencies to resolve at shell level:
  - owner `JobCardRegisterCard` uses raw `Navigator.push` instead of `go_router`;
  - ad-hoc app bars per app with duplicated title/subtitle styling;
  - CRM uses `AppNavDrawer` while others never expose a drawer;
  - rail visibility at `medium+` (`useNavigationRail: windowClass != compact`).
- Responsive strategy: `phases/00_RESPONSIVE_STRATEGY.md` (binding).

## C. Design objectives

1. **One shell contract.** `DashboardShell` remains the single authenticated frame (app bar slot, offline banner, system-bar `AnnotatedRegion`, exit confirmation, focus traversal). No screen builds its own Scaffold-with-exit-confirm.
2. **One app-bar pattern.** `AppTopBar` for pushed pages; a standardized workspace header pattern (title + context subtitle + actions: notifications, profile, refresh/period) shared by all app bars — implemented as `WorkspaceAppBar`-style composition or documented slots, replacing four bespoke app bars progressively (staff feature phases adopt it; the shell pattern itself finalized here).
3. **Navigation parity.** Bottom bar (≤5, overflow sheet) on compact; rail (76/92/92 px) medium+; extended rail (224 px) on `large`; drawer only where destination count genuinely needs it on compact (CRM 8 tabs) — otherwise no drawer. Badge language identical everywhere.
4. **Tablet master–detail template.** Provide a documented, tested pattern (list pane + detail pane with selection state; degrades to push navigation on compact) in `shared_core` for later phases (owner job cards, customer bookings, CRM leads).
5. **Desktop polish.** Hover states, focus rings, breadcrumb slot in `AppPageHeader`, content caps enforced by `AppPageFrame`, keyboard traversal verified (`FocusTraversalGroup`, Esc closes modals).
6. **Fixes at shell level:**
   - normalize `AppPageFrame` + `AppResponsivePage` usage rules (one is enough going forward — document which; keep both APIs working);
   - remove remaining raw `Navigator.push` usage inside shared shell-adjacent widgets if any (owner's is a feature-page issue — list it for Phase 12);
   - ensure bottom nav clears keyboard/insets and FABs respect `floatingActionButtonLocation` + bottom bars;
   - offline banner behavior stable on all shells (it already exists centrally).
7. **Motion + haptics.** Nav selection feedback (existing haptics) and transitions use `AppMotion` tokens only.

## D. Screens and workflows

Shell-level surfaces to finalize (visual polish + behavior, consumed by later phases):

1. `DashboardShell` — all four apps' workspaces (staff advisor/supervisor/technician, owner, customer, CRM).
2. `AppBottomNavigation` incl. "More" overflow sheet (CRM on compact ≠ 8 destinations; supervisor 5; technician 4; advisor 3; owner 4; customer 4).
3. `AppNavigationRail` compact/extended + `OrientBrandMark` header + profile/account footer.
4. `AppNavDrawer` (CRM compact; keep available for future >5-destination workspaces).
5. `AppTopBar` (+ `CustomerTopBar` variant) — every pushed page.
6. `AppPageHeader` with breadcrumb slot (owner depth-2 pages later).
7. `AppActionBar` sticky behaviors (forms later).
8. `ExitConfirmationWrapper` root behavior per app.
9. `OfflineBanner` placement (inside shell body, above content — already).

Workflows affected: entering/switching workspace destinations, deep-link entry
into a destination (badge/tab selection must reflect route), pushed-page
back-stack behavior, app exit confirmation, tablet list→detail, desktop
rail → breadcrumb context.

## E. Responsive specifications

- Compact: bottom bar; workspace header collapses to title + 2 actions max;
  pushed pages use `AppTopBar`; sheets for secondary actions.
- Medium: rail 76 px; two-column content templates available; master–detail
  template enabled for list→detail pairs; dialogs for modal forms.
- Expanded: rail 92 px; tables allowed; breadcrumbs for depth ≥2.
- Large: extended rail 224 px; content cap `contentStandard 1180` /
  `contentWide 1320`; three-pane template available (documented; used by later
  phases).
- All: text 1.0–1.6× on nav items without clipping (existing tests extended);
  Arabic labels longer than English must ellipsize gracefully, never wrap a nav
  label to 2 lines.
- Orientation: rail side mirrors in RTL (`BorderDirectional`), drawer edge
  mirrors, bottom-bar order mirrors.

## F. Localization and RTL

- Nav labels/headers/tooltips/badges localized (Phase 02 ARB) and RTL-mirrored:
  rail border uses `BorderDirectional`; drawer opens from the end edge; back
  arrows flip; brand mark row order flips; overflow sheet rows align end in RTL.
- `WorkspaceAppBar` subtitle strings come from localized provider values
  (features pass localized strings).
- Tests: shell RTL test (extend `shell_unification_test.dart` /
  `app_adaptive_navigation_test.dart`) asserting `Directionality.rtl`, mirrored
  rail border, and flipped directional icons.

## G. Design system integration

- Components: `DashboardShell`, `AppBottomNavigation`, `AppNavigationRail`,
  `AppAdaptiveNavigationFrame`, `AppNavDrawer`, `OrientBrandMark`, `AppTopBar`,
  `AppPageHeader`, `AppPageFrame`, `AppActionBar`, `AppConfirmationDialog`
  (exit/back confirm), `OfflineBanner`, `NotificationBell`, `UserAvatar`.
- No new color/type tokens expected; use Phase 01–03 outputs only.
- Master–detail template builds on `AppSplitView` (exists) + selection state
  pattern; document the API (e.g. `AppMasterDetailScaffold`).

## H. Technical implementation

Files to modify/extend:

- `packages/shared_core/lib/src/layout/app_adaptive_navigation.dart` — RTL
  borders, scale-robust labels (already maxLines 1 + ellipsis), extended-rail
  behavior polish, overflow sheet styling to card grammar.
- `packages/shared_core/lib/src/widgets/dashboard_shell.dart` — keep contract;
  minor fixes only.
- `packages/shared_core/lib/src/widgets/app_page_frame.dart` /
  `app_page_header.dart` / `app_top_bar.dart` / `app_action_bar.dart` — polish
  (spacing per tokens, breadcrumb slot, hover/focus, RTL alignment).
- New: `workspace_app_bar.dart` (or documented composition), master–detail
  template file, breadcrumb widget.
- Consumers updated in this phase: none of the feature screens yet — but the
  four apps' shells must be updated **only if** a shell API changes (e.g. app
  bars migrating to the new pattern is a per-app phase task, but the shared
  composition must exist).
- Do not touch routes/providers.

Constraints: no new packages; keep public APIs backward compatible where
feasible; document any deprecation.

## I. Functional preservation

- Exit confirmation on workspace root only (current behavior).
- Offline banner unchanged in behavior.
- Badge counts and queue badge wiring untouched (supervisor queue index 2).
- Pop/back behavior identical; deep links land on the right destination.
- Existing shell tests (`dashboard_shell_test.dart`,
  `app_adaptive_navigation_test.dart`, `shell_unification_test.dart`,
  `shell_family_visual_test.dart`) remain green; regenerate goldens only for
  intentional visual changes with documented diffs.

## J. Testing requirements

- `melos run analyze`; `melos run test:core`; plus the four app suites to prove
  no compile/visual regressions at shell level.
- Widget tests: bottom bar overflow sheet (6+ destinations), rail at
  medium/expanded/large widths, extended rail content, RTL mirroring of
  rail/drawer/bottom bar, 1.6× nav labels, master–detail degrade at <600 px,
  breadcrumb render, Esc closes modal (desktop), focus ring visibility.
- Golden updates for `shell_family_visual_test.dart` if intentional.
- Manual matrix spot-check at 320/390/768/1280 px per `00_RESPONSIVE_STRATEGY.md`
  §5 for one representative screen per app (using existing screens, e.g. owner
  dashboard, advisor home — pre-redesign but shell-level).

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run all four apps' shells and visually review every
   navigation surface redesigned here; no shell may be signed off from
   code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥1280 px) for the shell of each app.
3. **Locales** — EN-LTR and AR-RTL renders for each shell; both reviewed for
   mirroring (rail side, drawer edge, bottom-bar order), clipping and Arabic
   nav labels.
4. **State matrix** — selectable destinations, overflow "More" sheet, badge
   states; skeletons/empty/error belong to feature phases.
5. **Interaction verification** — tab/rail/drawer selection, badge feedback,
   back behavior, exit confirmation, keyboard focus traversal and Esc-closes on
   desktop behave as specified; no dead destinations.
6. **Accessibility** — nav labels clean at 1.0–1.6× scale, focus rings visible,
   semantics labels localized, contrast sampled.
7. **No visual overflow** — bottom bar and rail clean at 320 px in both
   locales.
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_04/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. Shell + navigation behavior identical across all four apps at every window
   class; one app-bar pattern documented and implemented in the shared layer.
2. RTL mirroring of all navigation chrome proven by tests.
3. Master–detail and three-pane templates available + tested (used later).
4. 1.6× text scale nav rendering clean in EN and AR.
5. Existing tests green; goldens updated only if intentionally changed.
6. No route/provider changes; no new packages.

## L. Deliverables

- Shell/navigation component list (modified/added) with file paths.
- Behavior matrix: window class → navigation chrome → slots (final table).
- Test evidence incl. RTL/scale results.
- Documented API for the new app-bar/master–detail templates + migration notes
  for the app phases that will adopt them.

## M. Completion gate

Stop after this phase. Do not begin Phase 05 until explicitly instructed.
