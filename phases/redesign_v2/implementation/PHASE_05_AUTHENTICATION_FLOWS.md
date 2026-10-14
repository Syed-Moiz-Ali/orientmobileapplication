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
