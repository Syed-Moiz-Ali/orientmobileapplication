# PHASE 04 — Responsive Shell & Navigation System: Completion Report

- **Date:** 2026-10-13
- **Phase:** 04 — Responsive Shell & Navigation (`phases/PHASE_04_RESPONSIVE_SHELL_AND_NAVIGATION.md`)
- **Status:** **IMPLEMENTATION COMPLETE — awaiting product-owner review**
- **Toolchain:** Flutter 3.35.7 stable · Dart 3.9.2 · Windows dev machine
- **Authorities:** `00_DESIGN_SYSTEM_SPEC.md` (§5–§6 nav, §7 registry, §8 a11y),
  `00_RESPONSIVE_STRATEGY.md` (binding), `00_LOCALIZATION_RTL_STRATEGY.md`
  (§5 RTL rules), `00_VISUAL_DIRECTION.md` (frozen V6/V7/V10), Phase 00 prototype
  (`apps/design_prototype/**` — read-only, **0 changes**).

---

## 1. Shell / navigation architecture

One shared shell contract, consumed identically by all four apps:

- **`DashboardShell`** remains the single authenticated frame (app-bar slot,
  offline banner, system-bar `AnnotatedRegion`, exit confirmation, focus
  traversal). Now documents and enforces `resizeToAvoidBottomInset: true` so the
  keyboard lifts the body **and** the bottom bar together and FABs clear the bar.
- **`AppAdaptiveNavigationFrame`** chooses chrome from `context.adaptive`:
  bottom bar (compact) / rail (medium→large, extended at `large`). It now
  carries a direction-mirrored rail border and direction-aware badges.
- **`AppBottomNavigation` + "More" overflow sheet**, **`AppNavigationRail`**
  (compact/extended), **`AppNavDrawer`** (CRM compact), **`OrientBrandMark`**
  header and profile footer — one selection language (cobalt tint + filled icon
  + heavier label + `Semantics(selected)`).
- **New `WorkspaceAppBar`** — the single workspace-header composition (title +
  context subtitle + optional leading/back + contextual selector + trailing
  actions + optional bottom/divider). Finalized here; the four bespoke app bars
  migrate to it in their owning feature/app phases.
- **New `AppBreadcrumbs` + `AppPageHeader.breadcrumbs` slot** — depth ≥2 desktop
  wayfinding.
- **New `AppMasterDetailScaffold`** and **`AppThreePaneScaffold`** — tablet/
  desktop list→detail and catalog|editor|summary templates with documented
  compact degradation.
- **`AppPageFrame`** documented as the canonical page container going forward;
  `AppResponsivePage` remains supported (not deprecated) for simple scroll +
  padding layouts.

### Behavior matrix (window class → chrome → slots)

| Window class | Width | Navigation chrome | Page slots |
|---|---|---|---|
| compact | ≤599 | `AppBottomNavigation` (≤5 + More overflow sheet); `AppNavDrawer` when genuinely many (CRM 8) | Workspace header title + ≤2 actions; pushed pages use `AppTopBar`/`WorkspaceAppBar(showBack)`; single content column |
| medium | 600–1023 | `AppNavigationRail` 76 px (icon + tooltips) | Master–detail template enabled; dialogs for modal forms; two-column content |
| expanded | 1024–1439 | `AppNavigationRail` 92 px | Tables + breadcrumbs for depth ≥2 |
| large | ≥1440 | Extended rail 224 px (labels) | Content caps `contentStandard 1180`/`contentWide 1320`; three-pane template available |

---

## 2. Files changed

### `packages/shared_core` — shell/navigation

New:
- `lib/src/widgets/workspace_app_bar.dart` (`WorkspaceAppBar`)
- `lib/src/widgets/app_breadcrumbs.dart` (`AppBreadcrumbItem`, `AppBreadcrumbs`)
- `lib/src/widgets/app_master_detail_scaffold.dart` (`AppMasterDetailScaffold`, `AppThreePaneScaffold`)

Modified:
- `lib/src/layout/app_adaptive_navigation.dart` — `BorderDirectional` rail border,
  `PositionedDirectional` badges, localized "More" slot + overflow-sheet title,
  localized destination semantics
- `lib/src/widgets/dashboard_shell.dart` — `resizeToAvoidBottomInset` + layout
  contract docs
- `lib/src/widgets/app_page_header.dart` — breadcrumb slot
- `lib/src/widgets/app_page_frame.dart` — usage-rule docs
- `lib/shared_core.dart` — additive exports
- `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` (+ regenerated `lib/l10n/gen/**`)

New tests:
- `test/shared_shell_phase04_test.dart` (14)
- `test/shared_shell_visual_test.dart` (10 goldens)
- `test/support/phase04_shell_gallery.dart`

Regenerated goldens: `test/goldens/shell_family_*.png` (5, Phase 04-owned; were
the recorded missing baselines).

### Evidence — `phases/reports/PHASE_04/`

`screens/` (15 renders), `capture/shell_capture_test.dart`, `baseline/` and
`final_*.txt` logs.

*Not touched:* `apps/design_prototype/**` (git-verified 0 changes); **no
production files in any of the four apps** (that is intentional — the shared
shell API stayed backward compatible, so no consumer needed updating in this
phase; app-bar migration to `WorkspaceAppBar` is a documented per-app task).

---

## 3. Responsive transformations

- Compact → bottom bar with deliberate "More" overflow (6+ destinations),
  content-sized bar that grows with text scale, safe-area aware.
- Medium/expanded → rail 76/92 px, icon + tooltip destinations, profile footer.
- Large → extended rail 224 px with labels and `OrientBrandMark` wordmark.
- Compact master–detail/three-pane degrade to a single pane driven by the caller
  (`detailOpen`/`secondVisible`); medium two panes; expanded three panes.
- Content caps enforced by `AppPageFrame` / `AppResponsivePage`; no mobile
  layout stretched to desktop.

---

## 4. Navigation behavior

- Selection: single tap on the active destination is a no-op (no haptic/nav
  churn); new selections fire one `selectionClick` haptic (unchanged).
- Badges: numeric pill when a real count exists, dot otherwise; hidden overflow
  activity aggregates into the "More" slot; both announced via localized
  semantics.
- Back/exit: workspace root keeps `ExitConfirmationWrapper`; pushed pages keep
  predictable pop (unchanged).
- Overflow sheet keeps every destination reachable and marks the active one.
- Drawer opens from the reading-start edge and mirrors in RTL.

---

## 5. Route compatibility

- **No routes, providers, guards, deep links or navigation contracts changed.**
  This phase touched only `shared_core` presentation widgets (no app router).
- Because the shared shell/navigation APIs are backward compatible (see §9), the
  four apps' shells compile and behave unchanged without edits.
- `00_PHASE_DEPENDENCY_MAP.md` §4.2 respected: no route/provider/API change.

---

## 6. English / Arabic RTL integration

3 new `shared_core` ARB keys, EN+AR complete (parity + untranslated green):
`commonMore` ("More" / "المزيد"), `navBadgeCount` ("{label}, {count} new" /
"{label}، {count} جديد"), `navBadgeDot` ("{label}, new activity" /
"{label}، نشاط جديد").

RTL mirroring proven by tests and renders:
- **Rail border** declared on the reading-end edge (`BorderDirectional(end:)`) —
  left in RTL, right in LTR; asserted per direction.
- **Bottom-bar order mirrors** (first destination at the reading-start edge);
  asserted.
- **Drawer opens from the end edge** (right in RTL); asserted + rendered.
- **Overflow "More" slot + sheet title localized**; destination semantics
  localized.
- Directional chevrons/back arrows flip via `DirectionalIcon`; breadcrumb
  separators mirror.
- Brand mark row order flips automatically; nav labels ellipsize (never wrap);
  technical identifiers keep Latin LTR.

No forced LTR; shared nav copy is owned solely by `shared_core`.

---

## 7. Accessibility results

- Touch targets ≥48 px across bottom bar, rail, drawer, overflow rows.
- `Semantics(button:, selected:, label:)` on every destination; badge counts/dots
  announced; localized in EN + AR.
- Focus: shell body wrapped in `FocusTraversalGroup`; modal surfaces via
  `showAppModalSheet`/dialogs close on **Escape** (desktop) — test-proven.
- Reduced motion respected (nav transitions/skeletons use `AppMotion`).
- 1.6× text scale: rail labels and bottom bar render without clipping in EN and
  AR (test-proven).
- Contrast from Phase 01/03A tokens (selected tint + primary on surface).

---

## 8. Cross-app integration results

Shell composition is shared and identical in structure for all four apps (staff
advisor/supervisor/technician, owner, customer, CRM), which already consume
`DashboardShell` + `AppAdaptiveNavigationFrame` + `AppBottomNavigation`:
- All four app suites compile and pass at baseline (no shell API breakage).
- Rendered review covers each role's destinations (customer 4, staff 3–5, owner
  4, CRM 6/8) at mobile/tablet/desktop in EN/AR.
- Auth→shell transition, nested routes, deep-link destination selection,
  provider/state and offline sync were **not modified** (no code touched in the
  apps), so existing flows are preserved by construction.

---

## 9. Public API compatibility

No exported symbol removed/renamed; all changes additive or behavior-neutral:
- `DashboardShell` — signature unchanged; added `resizeToAvoidBottomInset: true`
  (Scaffold default) + docs.
- `AppAdaptiveNavigationFrame` / `AppBottomNavigation` / `AppNavigationRail` /
  `AppNavDrawer` / `OrientBrandMark` — signatures unchanged; LTR output
  byte-identical, RTL improved.
- `AppPageHeader` — `breadcrumbs` additive (null → identical output).
- `AppPageFrame` — docs only.
- New exports: `WorkspaceAppBar`, `AppBreadcrumbs`, `AppBreadcrumbItem`,
  `AppMasterDetailScaffold`, `AppThreePaneScaffold`.
- `AppBreadcrumbItem` default constructor uses a named `label` (recorded here as
  the one new public API).

---

## 10. Test results

Fresh baseline captured **before** implementation; final after.

| Unit | Baseline (pass/fail) | Final (pass/fail) | New failures | Notes |
|---|---|---|---|---|
| `shared_core` | 216 / 6 | **245 / 1** | **0** | +14 shell tests, +10 shell goldens; **5 `shell_family_*` goldens resolved** (Phase 04-owned); 1 remaining = `app_theme_visual_test` (Phase 01) |
| `shared_auth` | 35 / 11 | **35 / 11** | **0** | unchanged (out of scope) |
| `staff_app` | 277 / 7 | **277 / 7** | **0** | unchanged baseline set |
| `owner_app` | 21 / 0 | **21 / 0** | **0** | unchanged |
| `customer_app` | 511 / 6 | **511 / 6** | **0** | unchanged baseline set |
| `crm_app` | 14 / 0 | **14 / 0** | **0** | unchanged |
| `design_prototype` | 299 / 0 | **299 / 0** | 0 | read-only; git-verified 0 changes |

**Static analysis:** `dart analyze` → **0 issues** on all six production units
and `apps/design_prototype`.

New tests (all passing): `shared_shell_phase04_test.dart` (14) — rail RTL border,
bottom-bar mirror, drawer end edge, localized overflow + badge semantics,
`WorkspaceAppBar`, breadcrumbs + page-header slot, master–detail compact/desktop,
three-pane 1/2/3 panes, 1.6× rail, Escape-closes-modal, focus traversal.
`shared_shell_visual_test.dart` (10 goldens).

---

## 11. Existing versus newly introduced failures

- **Newly introduced:** **none** in any unit.
- **Resolved:** the 5 `shell_family_visual_test` goldens (Phase 04-owned missing
  baselines) now exist and pass — regenerated from the shared shell and visually
  reviewed.
- **Pre-existing (unchanged, recorded baseline):** `app_theme_visual_test`
  (Phase 01); `shared_auth` 11 auth goldens (Phase 05); staff 6 intake overflows
  + 1 advisor-workflow finder; customer 3 light goldens. None caused/touched by
  04.
- No feature-app golden was regenerated; the Phase 00 prototype and its goldens
  are untouched.

---

## 12. Deferred issues and owning phases

| Item | Owner phase |
|---|---|
| Migrate the four bespoke app bars (Owner/Crm/Supervisor/Technician + customer top bar) to `WorkspaceAppBar` | 06, 09, 10, 11, 12, 15A, 19A |
| Localize app destination labels / workspace names (currently app-owned English) | owning feature phases (06–19C) |
| Owner `JobCardRegisterCard` raw `Navigator.push` → `go_router` | 12 |
| Staff `SupervisorSubPageWrapper` hand-rolled app bar → `WorkspaceAppBar` | 06/09 |
| Adopt master–detail template (owner job cards, customer bookings, CRM leads) | 12/13A, 15B/16, 19A |
| Adopt three-pane template (intake large, estimate builder) | 07A, 08 |
| Breadcrumb adoption on owner depth-2 pages + CRM sections | 12/13A, 19C |
| `app_theme_visual_test` baseline | 01/20 |
| Melos 8 workspace migration | tooling (unscheduled) |

---

## 13. Readiness for the next phase

**Ready.** The family-wide shell and navigation are finalized in `shared_core`:

- one shell contract + one app-bar pattern + one selection/badge language, with
  identical behavior across all four apps at every window class;
- RTL mirroring of rail/drawer/bottom bar/breadcrumbs proven by tests;
- master–detail and three-pane templates available and tested;
- 1.6× nav rendering clean in EN and AR; Escape/focus verified;
- all six suites at (or better than) baseline, analyze 0, prototype untouched;
- 15 report renders + 13 shell goldens attached.

**Phase 04 completion checklist**

- [x] Shell + navigation consistent across apps; one shared app-bar pattern
- [x] RTL mirroring (rail border, drawer edge, bottom-bar order) test-proven
- [x] Master–detail + three-pane templates available + tested
- [x] 1.6× nav rendering clean in EN and AR
- [x] Existing tests green; missing Phase 04 shell goldens resolved
- [x] No route/provider changes; no new packages; public APIs additive
- [x] J2 evidence pack attached (`phases/reports/PHASE_04/`)
- [ ] Phase 05 — awaiting explicit authorization (not started)
