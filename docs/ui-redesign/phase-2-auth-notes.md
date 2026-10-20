# Phase 2a — shared auth analysis + REDESIGN plan (docs only, no code changed)

Branch: `ui/phase-2-auth` (from `airbnb_style` @ `acc8a645`, phase-1 merged + tagged `ui-phase-1-done`).
Governing rules: REDESIGN MANDATE (PROGRESS.md working rule 13) + do-not-touch list (§4) + hard stops.
"Already looks okay" is never a reason to skip. Doubt about behavior → extend App*, never silently keep.

## 1. Premise correction

`phases/phase-2-shared-auth.md` describes the OLD auth ("cramped, technical errors, mixed buttons").
That is stale: both shared screens were already rebuilt ("Archetype 1", pre-existing commits on this
history). Under the mandate this changes nothing — every screen still gets the full C8/C9 redesign,
and the already-built local widgets (`AuthTextField`, `AuthPrimaryButton`, …) are replaced by App*
widgets and then removed.

## 2. Screen inventory (all in `packages/shared_auth/lib`)

| Screen | File | Modes / stages | States today |
|---|---|---|---|
| Login | `presentation/pages/login_view.dart` | password / code (OTP send→verify) / register (progressive disclosure, customer only) | idle, inline field errors, form errors as snackbar+retry, busy CTA (label swap + spinner), `otpSent` success snackbar, 30s resend cooldown |
| Forgot password | `presentation/pages/forgot_password_view.dart` | identifier → reset (code + new password together — backend issues/consumes the code in one `reset-password` call, so no separate verify gate is possible) → warm success screen | same error grammar as login; 2-step `AppStepProgress`; success = confirmation screen + single CTA (redesigned as terminal confirmation, DESIGN_SPEC C10 exception) |
| Supervisor login | `apps/staff_app/.../supervisor/supervisor_login_view.dart` (staff-local) | username/password + continue + forgot | idle, busy, single `_error` string (RAW `e.message` — defect), hardcoded English `??` fallbacks (defect) |
| Startup | `presentation/widgets/auth_loading_view.dart` | branded navy splash while session restores | skeleton N/A (no content layout); redesign within navy signature: tokens + Semantics + layout polish |

No other OTP / register / verify / reset screens exist. `packages/shared_auth/test/` does not exist —
2b creates it (characterization tests vs current screens, fakes, green BEFORE the redesign).

Replaceable local widgets: `AuthShell` internals stay (layout authority, already C9) but its CHILD
controls go App*: `AuthTextField`, `AuthPrimaryButton`, `AuthLinkButton`→(App* text-button equivalent),
`AuthNotice`/`AuthNoticeSlot`→`AppBanner`/`AppInfoPanel` grammar, `_MethodSwitcher`→`AppSegmentedControl`,
`AuthResendAction` (re-evaluate vs App* — replace or token-rebuild), `AuthCountryCodeButton`,
`AuthPasswordStrength` (keep concept, restyle), `AuthOtpField` (Pinput — stays ONLY as third-party
concession, full token-style pass, reason recorded here). Removal at zero usages, recorded in
`WIDGET_MIGRATION_MAP.md`.

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
app theme). 2c verifies primary stays `#215FE6` in every theme while each app keeps its own hooks.

## 4. Do NOT touch (logic — unchanged from user order)

`LoginNotifier` (all setters, `sendSmsOtp`/`verifySmsOtp`/`sendEmailOtp`/`verifyEmailOtp`,
`loginWithPassword`, `register`, `toggleRegister`, `reset`), `LoginState`/`AuthState` fields,
`auth_providers.dart` use cases, `data/` + `domain/` + `network/auth_interceptor`,
router redirects / route names / `dashboardForRole`, Pinput behavior (autofocus, digitsOnly,
`onCompleted`→verify), autofill hints, Keys, error-mapping rules, `_fullPhone`/`_mask*` helpers,
`_roleTokens` parsing, focus-node ownership, double-submit guards, `_otpAnnounced` once-per-send.

## 5. Redesign proposal per screen (C9 auth anatomy + mandate)

- **Login:** full recomposition: whitespace, lockup ≤30% height, headline + subtitle, single column,
  full-width 52 `AppPillButton`, secondary text links, footer note, 480 max, keyboard-safe scroll,
  premium split on expanded. Parity gaps → EXTEND the App* widget additively + tests first
  (verify: obscure toggle, LTR force, autofill, focus order, `belowField` strength slot, busy
  label-swap, error live-region). `AuthNoticeSlot` → `AppBanner` for form-level where it fits;
  transient post-submit failures may keep snackbar+retry — reviewer judges fit per state.
- **Forgot:** same swaps across all 3 stages; keep 2-step progress via `AppStepProgress`; keep
  code+password combined (backend constraint — concrete technical blocker, documented here).
- **OTP step:** Pinput stays (third-party concession) with a full token-styling pass against the
  `AppInputField` border ramp + measured contrast; LTR lock, autofocus, digitsOnly, completion kept.
- **Supervisor:** full redesign + the two real defects via NEW ARB keys (no renames): raw `e.message`
  → `mapAuthError` copy; hardcoded `??` fallbacks → shared_auth keys. Both keys listed for phase 9.
- **Splash:** navy signature kept; tokens + Semantics + layout polish.

## 6. States + 2d capture matrix

Per screen: idle, loading (CTA busy, no spinner overlays), field error, form error, offline
(retryable path), success. Copy stays on existing ARB strings; gaps listed for phase 9, never hardcoded.
Captures: every screen × state × (customer light+dark, staff/owner/CRM light) × (LTR, RTL ar) ×
(1.0, 1.3) × (360×800, 320×568) + tablet-portrait login → `baseline/after-phase-2/`, old PNGs moved to
`baseline/before/`, side-by-side per app. Reviewer judges C8/C9/C14 AND "redesign clearly visible vs
before?" — a too-similar after-image is a FAIL.

## 7. Decisions (user, 2026-10-20)

1. Base = `airbnb_style`; phase-1 merged as `acc8a645` + tag `ui-phase-1-done`. Work branches from there.
2. `71983229` (parallel staff-management work) stays OUT of the redesign until reviewed.
3. Warm forgot-password success screen KEPT (terminal-flow confirmation); DESIGN_SPEC C10 exception added
   in 2a: "snackbar for in-place success, confirmation screen for terminal security flows".
4. Navy splash KEPT (skeleton N/A); tokens + Semantics + layout polish only.
5. Copy rewording is phase 9. 2b/2c fix only: supervisor raw `e.message` + hardcoded fallbacks, via new
   ARB keys, listed for phase 9.
6. REDESIGN MANDATE adopted (PROGRESS rule 13): full Airbnb look on every screen; extend App*, don't keep
   legacy; legacy removed at zero usages; visible before/after difference required.
7. Split: 2a docs → 2b safety-net tests → 2c redesign → 2d evaluation; tags `ui-phase-2b/c/d-done`.

## 8. Real-device checklist additions (phase 15)

OTP autofill, password manager, keyboard covering fields, Pinput on 320px (plus prior: resend timing,
focus order with OTP autofocus, supervisor on small screens, sunlight/toasts per phase-1 list).

## 9. Open questions

None. Proceeding to 2b.
