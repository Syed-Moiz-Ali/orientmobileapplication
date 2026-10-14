# PHASE 04 — Responsive Navigation Shells & Application Scaffolds

**Document ID:** `phases/redesign_v2/implementation/PHASE_04_NAVIGATION_SHELLS.md`  
**Prerequisites:** Phase 02 Completed (`REPORT_PHASE_02.md`)  
**Target Package:** `packages/shared_navigation/` & `packages/shared_core/`  
**Status:** READY FOR IMPLEMENTATION (Gate 4)  

---

## 1. Primary User & Engineering Objective
Re-architect the responsive navigation framework across the entire monorepo. Replace generic Material scaffolds with purpose-built Concept A shells: bottom navigation docks for mobile, collapsible navigation rails for desktop, frosted glass AppBars with integrated offline status indicators, and master-detail split views.

---

## 2. Real Repository File Paths
- `packages/shared_navigation/lib/src/responsive_scaffold.dart`
- `packages/shared_navigation/lib/src/desktop_navigation_rail.dart`
- `packages/shared_navigation/lib/src/mobile_bottom_bar.dart`
- `packages/shared_core/lib/src/widgets/app_top_bar.dart` & `workspace_app_bar.dart`
- `packages/shared_core/lib/src/widgets/app_master_detail_scaffold.dart`
- `packages/shared_core/lib/src/widgets/dashboard_shell.dart`
- `packages/shared_navigation/test/responsive_navigation_test.dart`

---

## 3. New Screen & Component Composition
1. **`ResponsiveScaffold`:**
   - **Compact Mobile (<600px):** Full-width canvas, sticky top bar, floating bottom action bar / bottom navigation dock.
   - **Adaptive Tablet (600–1023px):** Side drawer or compact icon rail, 2-column master-detail layout.
   - **Desktop Workspace (≥1024px):** Persistent left rail (72px collapsed / 240px expanded), top workspace bar with breadcrumbs and user avatar, max canvas width 1440px.
2. **`WorkspaceAppBar`:**
   - Translucent frosted glass effect (`BackdropFilter(sigma: 10)`).
   - Hairline bottom border (`#E2E8F0` / `#262C3D`).
   - Integrated offline telemetry pill with auto-sync indicator.
   - Omnichannel search trigger (`Cmd+K`).
3. **`AppMasterDetailScaffold`:** Two-pane split view with fluid resize animation, dividing border, and mobile single-column push/pop transition.

---

## 4. Visual Acceptance Criteria
- Seamless transitions between mobile bottom bar and desktop navigation rail.
- Frosted glass header maintains readability against scrolled content.
- Golden tests generated with real fonts loaded across 390px, 768px, and 1280px.

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze` passes with 0 errors across `packages/shared_navigation` and `packages/shared_core`.
- `responsive_navigation_test.dart` passes across 390px, 768px, and 1280px in both LTR and RTL.

### Gate 2: Visual Aesthetic Validation
- Golden captures verify navigation layout at all three breakpoints with real fonts loaded.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_04.md`.


---

## Styling Authority (Phase 01.1 � Mandatory)
All styling in this phase MUST resolve through the single centralized theme system. Do not select light/dark colors by hand.

- Standard Material roles -> `context.colors` (`ColorScheme`).
- Custom automotive/workshop roles -> `context.semanticColors` (`AppSemanticColors` ThemeExtension).
- **Forbidden:** `dark ? AppDarkColors.x : AppColors.x` ternaries; direct `AppColors.*` / `AppDarkColors.*` palette selection in feature widgets; hardcoded semantic hex; duplicate local theme systems or competing theme providers; hardcoded font styles, spacing, or radii where a theme or `AppDimensions` token exists.
- **Justified exceptions** (brand assets, theme construction, color previews, brightness-dependent behavior) must carry a one-line documented reason.
- Full rules: `00_CONCEPT_A_DESIGN_SYSTEM.md` Sec.6 and `reports/PHASE_01_1_THEME_ARCHITECTURE.md`.
