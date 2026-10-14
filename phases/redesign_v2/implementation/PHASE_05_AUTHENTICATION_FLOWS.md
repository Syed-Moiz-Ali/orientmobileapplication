# PHASE 05 — Shared Authentication & Access Flow Redesign

**Document ID:** `phases/redesign_v2/implementation/PHASE_05_AUTHENTICATION_FLOWS.md`  
**Prerequisites:** Phase 02 & Phase 04 Completed (`REPORT_PHASE_02.md`, `REPORT_PHASE_04.md`)  
**Target Package:** `packages/shared_auth/`  
**Status:** READY FOR IMPLEMENTATION (Gate 5)  

---

## 1. Primary User & Engineering Objective
Complete visual and interaction redesign of all authentication surfaces using **Archetype 1: Authentication & Identity Access**. Provide a trustworthy, secure, and polished entry experience across Mobile, Tablet, and Desktop in both English and Arabic.

---

## 2. Real Repository File Paths
- `packages/shared_auth/lib/src/presentation/widgets/auth_loading_view.dart` (A1)
- `packages/shared_auth/lib/src/presentation/pages/login_view.dart` (A2)
- `packages/shared_auth/lib/src/presentation/pages/forgot_password_view.dart` (A3)
- `packages/shared_core/lib/src/widgets/logout_dialog.dart` (A4)
- `packages/shared_auth/test/views/login_view_test.dart`

---

## 3. Screen Redesign Requirements
1. **`AuthLoadingView` (A1):**
   - Ambient deep-space backdrop with pulsing security badge (`ORIENT AUTOMOTIVE SUITE • TLS 1.3 SECURE`).
   - Smooth animated progress ring with real-time status messages ("Verifying Credentials...", "Synchronizing Workshop Offline Cache...").
2. **`LoginView` (A2):**
   - **Composition:** Centered security card (max width 420px), elevated surface (`#FFFFFF` / `#11141D`), 1px border.
   - **Role Toggle Pills:** Seamless segment toggle between "Service Advisor" and "Customer".
   - **Input Fields:** Dual identifier support (Password, Email OTP, SMS OTP) with country flag / plate prefix slot.
   - **Desktop Layout (≥1024px):** Split 45/55 view: Left panel featuring luxury vehicle telemetry graphic and Orient brand credentials; right panel featuring focused login card.
3. **`ForgotPasswordView` (A3):**
   - 3-step guided flow: Identity -> OTP Verification -> Password Reset.
   - Animated step indicator with real-time countdown timer for OTP resend.
4. **`LogoutDialog` (A4):**
   - Elevated dialog with session summary and destructive confirm action.

---

## 4. Visual Acceptance Criteria
- Clean, focused login experience with strong visual hierarchy.
- Zero horizontal overflow on 390px mobile screens or Arabic RTL mode.
- Golden screenshots captured with real fonts loaded (`PlusJakartaSans` & `IBMPlexSansArabic`).

---

## 5. Dual Gate Verification
### Gate 1: Engineering Validation
- `dart analyze packages/shared_auth` returns 0 errors and 0 warnings.
- `login_view_test.dart` passes 100% with all auth state transitions tested.

### Gate 2: Visual Aesthetic Validation
- Golden screenshots captured across Mobile (390px EN/AR) and Desktop (1280px EN) with real fonts.
- Generates `phases/redesign_v2/reports/REPORT_PHASE_05.md`.


---

## Styling Authority (Phase 01.1 � Mandatory)
All styling in this phase MUST resolve through the single centralized theme system. Do not select light/dark colors by hand.

- Standard Material roles -> `context.colors` (`ColorScheme`).
- Custom automotive/workshop roles -> `context.semanticColors` (`AppSemanticColors` ThemeExtension).
- **Forbidden:** `dark ? AppDarkColors.x : AppColors.x` ternaries; direct `AppColors.*` / `AppDarkColors.*` palette selection in feature widgets; hardcoded semantic hex; duplicate local theme systems or competing theme providers; hardcoded font styles, spacing, or radii where a theme or `AppDimensions` token exists.
- **Justified exceptions** (brand assets, theme construction, color previews, brightness-dependent behavior) must carry a one-line documented reason.
- Full rules: `00_CONCEPT_A_DESIGN_SYSTEM.md` Sec.6 and `reports/PHASE_01_1_THEME_ARCHITECTURE.md`.

---

## Centralized Widgets (Phase 01.2 — Mandatory)
All UI in this phase MUST reuse `packages/shared_core` centralized widgets. Never build a per-app duplicate when a shared widget exists.

- Use existing: `WorkspaceAppBar`, `DashboardShell`, `OfflineStatusPill`, `AppBreadcrumbs`, `AppPageHeader`, `AppMasterDetailScaffold`, `AppTable`, `AppCard`, `AppKpiCard`, `AppListSurface`, `AppRecordRow`, `AppSearchField`, `AppTextField`, `AppDropdownButton`, `AppFilterBar` / `AppDateRangeField` / `AppPaginationFooter` (01.2), `AppCommandPalette` + `WorkspaceSearchShortcuts` (01.2), `AppStepper` / `AppTimeline` / `AppTrendStat` (01.2), `AppBottomSheet`, `AppConfirmationDialog`, `AppSelectionSheet`, `EmptyState`, `ErrorView`, `AppSkeleton`, `LoadingIndicator`, `StatusPill`, `SectionHeader`, `AppActionBar`, `PrimaryButton`.
- If a needed widget does NOT exist in `shared_core`: create it in `packages/shared_core/lib/src/widgets/` (theme-driven via `context.colors` / `context.semanticColors`, EN/AR, responsive, a11y), export from `shared_core.dart`, add widget tests + goldens, THEN use it in this phase. Do not create `apps/*/lib/.../widgets/` copies.
- Forbidden: app-local copies of shared primitives, hardcoded spacing/radii/fonts, hardcoded colors, bespoke app bars/shells.
- Acceptance: grep shows zero new app-local duplicates; new shared widgets have tests + docs.


---

## Full 100% Redesign Mandate (Binding)
This phase is a SCREEN-LEVEL REDESIGN, not a color refresh, spacing tweak, or bug-fix pass. Minimal-change execution FAILS this phase.

- Rebuild every owned screen composition from its archetype (see 00_SCREEN_ARCHETYPES.md): new visual hierarchy, layout, spacing rhythm, section order, interaction patterns, responsive behavior. The finished screen must look visibly different from the old one side-by-side.
- FORBIDDEN as the whole change: only swapping colors/fonts/padding, only wrapping old layout in new cards, keeping obsolete headers/lists/forms because they exist. If the diff is palette + spacing only, reject and rework.
- Each screen gets a task-specific composition (never the same header + KPI cards + grid + list template on every screen). Attention/action content outranks passive metrics. Remove dead sections, kill obsolete widgets (verify zero references first, like REPORT_PHASE_06 S-section did with 17 legacy files).
- Must use Concept A tokens + centralized shared_core widgets (01.2 block); no per-app duplicates.
- Proof required in report: before/after composition table per screen + deleted-obsolete-files list + side-by-side screenshots. Reviewer compares old vs new at 390 + 1280 EN/AR. If it still resembles the old UI, Gate 2 FAILS.
