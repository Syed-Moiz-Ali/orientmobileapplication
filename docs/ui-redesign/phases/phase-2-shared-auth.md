# Phase 2 — Shared auth (login / forgot-password for all 4 apps)

## 1. Title + Goal
Redesign the single shared auth flow (`packages/shared_auth`) to Airbnb calm: whitespace, headline + subtitle, full-width CTA, keyboard-safe. Fixes all 4 apps' entry at once.

## 2. Pre-step
Read `docs/ui-redesign/DESIGN_SPEC.md`, `PROGRESS.md`, `MODULES.md` and any previous phase notes. Summarize in 5 lines. Do not touch business logic.

## 3. Scope
In scope: `packages/shared_auth/lib/src/presentation/pages/login_view.dart`, `forgot_password_view.dart`, `widgets/{auth_button,auth_field,auth_notice,auth_password_strength,phone_country,security_badge,auth_surface,auth_loading_view}.dart` (+ `auth_error_mapper.dart` copy only).
Do NOT touch: `data/datasources/*`, `domain/*`, `network/auth_interceptor`, `providers/auth_state/login_provider` logic, per-app `app_router.dart` redirects, ARB structure.

## 4. Design principles
C9 auth anatomy (logo ≤30% height, headlineLarge + bodyLarge, CTA full-width 52, secondary link, max-width 420–560); C8 AppPillButton/TextField/Banner/SnackBar; C10 (loading skeleton, error friendly + Try again, disabled 40%, success snackbar); C11 (no "Submit/OK", no raw exceptions).

## 5. Step-by-step tasks (REDESIGN MANDATE, PROGRESS rule 13, governs all parts)
Execute in four parts on `ui/phase-2-auth` with tags `ui-phase-2b/c/d-done`:
- 2a docs (this file + `phase-2-auth-notes.md` + mandate + DESIGN_SPEC C10 exception). No code.
- 2b SAFETY NET: characterization tests in `packages/shared_auth/test/` against the CURRENT screens with fake providers (validation, field vs form errors, loading disables submit, resend 30s, OTP expired vs invalid, forgot stages, register mode, supervisor login). Green BEFORE the redesign, kept green after.
- 2c REDESIGN (main work): full C9 recomposition of LoginView, ForgotPasswordView (all 3 stages), OTP step, register mode, SupervisorLoginView, AuthLoadingView + every state. Replace legacy auth widgets with App* (extend App* additively + tests where parity requires it; remove legacy at zero usages, record in WIDGET_MIGRATION_MAP.md). Pinput token-styled (third-party concession, reason in notes). Brand hooks per app, primary never leaves #215FE6.
- 2d EVALUATE + FIX: before/after capture matrix + fresh-reviewer judgement (C8/C9/C14 + "redesign clearly visible?") + fix loop to zero fails. Baselines: old → `baseline/before/`, new → `baseline/after-phase-2/`, side-by-side per app. Report in `evaluation/phase-2-auth.md`.

## 6. Screen-by-screen plan
- login_view: current problems — cramped, technical errors, mixed buttons. New: context header → single form card → primary CTA sticky bottom → secondary "Forgot password" link. App* swaps: AuthPrimaryButton→AppPillButton, raw TextField→AppInputField.
- forgot_password_view: same anatomy; success → snackbar + navigate (no dead-end).
- auth_loading_view: skeleton.
- All: C10 states required.

## 7. UX writing rules
Rewrite per C11; keep brand/role terms; create first entries for `COPY_QUESTIONS.md` where backend error meaning unclear.

## 8. Responsive + accessibility checklist
320–1440 widths; keyboard-safe (no CTA hidden); 48dp; semantics; 1.3x no overflow; focus order logical.

## 9. QA checklist
- [ ] Grep scope: zero `Colors./Color(0x/TextStyle(fontSize`/raw insets/radii/hardcoded strings outside tokens/ARB
- [ ] Light+dark OK; loading/empty/error/disabled states; 1.3x + 320px no overflow; ≥48dp
- [ ] UI-only diff; `flutter analyze` clean; 4 apps boot to login

## 10. Definition of done
Tick PROGRESS.md (M2 row), session log, `evaluation/phase-2-auth.md` zero-fail, baselines in `before/` + `after-phase-2/` with side-by-sides, commit message, tags `ui-phase-2b/c/d-done`.

## 11. Ask me first
Role-specific login copy (advisor vs customer wording?), registration link visibility in customer (`allowRegistration:true`), brand logo asset approval.
