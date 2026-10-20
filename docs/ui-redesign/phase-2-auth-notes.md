# Phase 2a — shared auth analysis (read-only, no code changed)

Branch: `ui/phase-2-auth` (from `airbnb_style` @ `acc8a645`, phase-1 merged + tagged `ui-phase-1-done`).
Base rule for 2b/2c: presentation layer only. Any behavior doubt → keep old behavior, report it.

## 1. Premise correction

`phases/phase-2-shared-auth.md` describes the OLD auth ("cramped, technical errors, mixed buttons").
That is stale: both shared screens were already rebuilt ("Archetype 1", pre-existing commits on this
history). Phase 2 is therefore a **component-swap + gap-fix + evaluation** pass, not a from-scratch redesign.

## 2. Screen inventory (all in `packages/shared_auth/lib`)

| Screen | File | Modes / stages | States today |
|---|---|---|---|
| Login | `presentation/pages/login_view.dart` | password / code (OTP send→verify) / register (progressive disclosure, customer only) | idle, inline field errors, form errors as snackbar+retry, busy CTA (label swap + spinner), `otpSent` success snackbar, 30s resend cooldown |
| Forgot password | `presentation/pages/forgot_password_view.dart` | identifier → reset (code + new password together — backend issues/consumes the code in one `reset-password` call, so no separate verify gate is possible) → warm success screen | same error grammar as login; 2-step `AppStepProgress`; success = confirmation screen + single CTA (KEPT per user decision, see §7) |
| Supervisor login | `apps/staff_app/.../supervisor/supervisor_login_view.dart` (staff-local) | username/password + continue + forgot | idle, busy, single `_error` string (RAW `e.message` — defect), hardcoded English `??` fallbacks (defect) |
| Startup | `presentation/widgets/auth_loading_view.dart` | branded navy splash while session restores | KEPT per user decision (no content layout to skeleton-ize); 2b cleans tokens + Semantics only |

No other OTP / register / verify / reset screens exist. `packages/shared_auth/test/` does not exist —
2b writes widget tests against the OLD screens first (validation, loading, success/failure nav), then
keeps them green after the swap.

Shared auth widgets: `AuthShell` (`auth_surface.dart`: compact full-bleed / medium boxed card /
expanded+ 1440 split with navy identity panel, 480 form max, keyboard-aware align, scroll),
`AuthTextField` (label-above, LTR force, obscure toggle w/ labeled tooltip, `belowField` slot),
`AuthOtpField` (`Pinput` 6-digit, token-styled, LTR-locked, live-region errors),
`AuthPrimaryButton` (52px, busy keeps cobalt + spinner, genuinely-disabled falls back),
`AuthLinkButton`, `AuthResendAction`, `AuthNotice`/`AuthNoticeSlot`, `AuthPasswordStrength`,
`AuthCountryCodeButton` + `phoneCountryFor` (UAE default, per-country digit hint), `auth_error_mapper`
(field-mapped inline vs form-mapped snackbar+retry; expired-vs-invalid OTP copy).

## 3. Per-app embeds (routers)

All mount shared `LoginView` / `ForgotPasswordView` at `/login` + `/forgot-password` with localized
`appName` / `intendedUsers` / `appPurpose` / `securityNotice` (+ hardcoded English fallbacks).

| App | Registration | Forgot back-nav | Login success | Extra |
|---|---|---|---|---|
| customer | `allowRegistration: true` | `go(login)` | fixed dashboard | — |
| staff | no | `pop()` | `dashboardForRole(role)` | `/supervisor-login` → staff-local `SupervisorLoginView` |
| owner | no | `pop()` | fixed dashboard | — |
| crm | no | `pop()` | fixed dashboard | — |

Brand hook = the four string props (no `BrandConfig` class; shell resolves everything through the
app theme). 2c verifies `BrandConfig`-equivalent behavior: primary stays `#215FE6` in every theme.

## 4. Do NOT touch (logic)

`LoginNotifier` (all setters, `sendSmsOtp`/`verifySmsOtp`/`sendEmailOtp`/`verifyEmailOtp`,
`loginWithPassword`, `register`, `toggleRegister`, `reset`), `LoginState`/`AuthState` fields,
`auth_providers.dart` use cases, `data/` + `domain/` + `network/auth_interceptor`,
router redirects / route names / `dashboardForRole`, Pinput behavior (autofocus, digitsOnly,
`onCompleted`→verify), autofill hints, Keys, error-mapping rules, `_fullPhone`/`_mask*` helpers,
`_roleTokens` parsing, focus-node ownership, double-submit guards, `_otpAnnounced` once-per-send.

## 5. Layout proposal per screen (C9 auth anatomy)

- **Login:** keep `AuthShell` anatomy (already C9: lockup → context → headline+subtitle → single
  column → full-width 52 CTA → secondary links → footer note, 480 max, keyboard-safe scroll).
  2b swaps: `AuthTextField`→`AppInputField` (parity: obscure toggle, LTR force, autofill, focus order,
  `belowField`→strength slot, error live-region), `AuthPrimaryButton`→`AppPillButton.primary`
  (parity: busy label-swap + spinner, disabled semantics, 52 height). Form failures stay
  snackbar+retry (auth keeps no "last data", so an `AppBanner` has nothing to preserve — documented
  deviation, reviewer to confirm). Verify 320px + 1.3x + RTL + customer dark.
- **Forgot:** same swaps; keep 2-step progress (`AppStepProgress` pre-exists in core — reuse, no change);
  keep code+password combined (backend constraint); keep warm success screen (user decision).
- **OTP:** `Pinput` stays (migration-map ruling); audit its token styling against the `AppInputField`
  border ramp + measure contrast; keep LTR lock, autofocus, digitsOnly, completion behavior.
- **Supervisor:** same component swaps + fix the two real defects with NEW ARB keys (no renames):
  raw `e.message` → mapped copy via `mapAuthError`; hardcoded `??` fallbacks → shared_auth ARB keys.
  List both keys for the phase-9 ux-writing pass.
- **Splash:** tokens + Semantics cleanup only.

## 6. States checklist for 2b/2c captures

Per screen: idle, field error, form error, loading (CTA busy — no spinner overlays), offline
(retryable snackbar path), success. Copy stays on existing ARB strings; anything missing/unclear is
listed for phase 9, never hardcoded.

## 7. Decisions (user, 2026-10-20)

1. Base = `airbnb_style`; phase-1 merged as `acc8a645` + tag `ui-phase-1-done`. Work branches from there.
2. `71983229` (user's parallel staff-management work: team_view + team_providers + Java backend) stays
   OUT of the redesign until reviewed. It lives only at the tip of `ui/phase-1-widgets`.
3. Warm forgot-password success screen KEPT (terminal security-flow confirmation beats snackbar+navigate).
   User adds a DESIGN_SPEC exception: "snackbar for in-place success, confirmation screen for terminal
   security flows".
4. Navy splash KEPT (no content layout to mimic → skeleton rule N/A); tokens + Semantics cleanup only.
5. Copy rewording is phase 9. 2b/2c fix only: supervisor raw `e.message` + hardcoded fallbacks, via new
   ARB keys, listed for phase 9.

## 8. Real-device checklist additions (phase 15)

Old Pinput/OTP styling on devices, SMS/autofill code behavior, keyboard covering CTA/autofill/IME,
focus order with OTP autofocus, resend-cooldown timing, supervisor flow on small screens.

## 9. Open questions

None. Waiting for go to start 2b.
