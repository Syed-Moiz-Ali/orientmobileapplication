# PHASE 05 — Authentication & Onboarding

## A. Phase identity

- **Phase number:** 05
- **Title:** Authentication & Onboarding (shared login, recovery, splash, supervisor login)
- **Objective:** Redesign the complete authentication experience of all four apps — a premium, localized, responsive, branded entry into every product — while keeping the existing auth state machine, providers, API calls, OTP flows, cooldowns and role-routing behavior byte-for-byte intact.
- **Priority:** Critical (first user-visible introduction of the new system; blocks feature phases by ordering)
- **Dependencies:** Phases 01–04
- **Estimated scope:** Large

## B. Repository context

- Package: `packages/shared_auth/`
  - Pages: `lib/src/presentation/pages/login_view.dart`, `forgot_password_view.dart`
  - Scaffold/widgets: `auth_surface.dart` (`AuthShell`), `auth_button.dart` (`AuthButton`/`AuthPrimaryButton`/`AuthLinkButton`), `auth_field.dart` (`AuthTextField`, `AuthOtpField`), `auth_notice.dart` (`AuthNotice`, `AuthNoticeSlot`), `auth_loading_view.dart`, `auth_header.dart` (legacy/unused), `auth_background.dart` (legacy/unused), `phone_input_field.dart` + `otp_input_field.dart` (legacy/test-only), `security_badge.dart`
  - Providers: `login_provider.dart` (`LoginNotifier` — methods: password, code (email/SMS), register, 30 s resend cooldown, `PasswordIdentifier {email, phone}`, country-code default 971), `auth_providers.dart`, `auth_state.dart` (`AuthUnauthenticated/Loading/Error/Authenticated`).
  - `SecurityBadge` currently carries workshop-specific wording that leaks into CRM.
- App mounts (pass localized `appName`, `intendedUsers`, `appPurpose`, callbacks):
  - staff: `apps/staff_app/lib/core/router/app_router.dart` (LoginView + ForgotPasswordView + `SupervisorLoginView` at `lib/features/supervisor/presentation/supervisor_login_view.dart` using its own local auth widgets)
  - owner: `apps/owner_app/lib/core/router/app_router.dart`
  - customer: `apps/customer_app/lib/core/router/app_router.dart` (`allowRegistration: true`)
  - crm: `apps/crm_app/lib/core/router/app_router.dart`
- Startup splash: `AuthLoadingView` used as `/` in every router.
- Role routing after success: staff `dashboardForRole(role)`; owner → `/owner-dashboard`; customer → `/customer_dashboard_view`; CRM → `/crm_dashboard_view`. Door gating happens in router redirects (owner/customer/CRM only).
- Spec: `00_DESIGN_SYSTEM_SPEC.md` §7, §14 (T8 auth template), `00_LOCALIZATION_RTL_STRATEGY.md`.

## C. Design objectives

The auth experience must feel like the front door of a serious product family:
calm, trustworthy, fast. Concretely:

1. **One branded shell, four identities.** `AuthShell` renders: brand mark +
   localized app identity (name, purpose, intended users), security note, and the
   focused form. Same layout everywhere; identity copy differs per app via the
   existing constructor props (now localized values).
2. **Sign-in clarity:**
   - Single identifier field that auto-detects email vs phone (existing logic),
     with locale-aware phone handling;
   - Clear method tabs/segmented control for password vs one-time code when both
     are available (preserve the existing `AuthMethod` behaviors exactly);
   - Password field with show/hide, caps-lock aware, autofill hints preserved;
   - OTP: 6-digit `pinput` field restyled to the design system; resend button
     with visible 30 s countdown; per-method labels localized;
   - Primary CTA full-width, loading state inside the button (no layout jump);
   - Errors via `AuthNotice` (live region) with actionable localized copy —
     never raw transport errors (existing `_friendlyError` maps them; extend
     mapping for new localized copy).
3. **Recovery flow** (3 stages: identifier → code + new password → done):
   same stepper with clear progress, localized copy, masked destination,
   password rules stated up front, back navigation safe at every stage.
4. **Registration** (customer only): unchanged semantics (`role: 'customer'`),
   presented in the same shell with clear value copy; validation identical.
5. **Supervisor login** (`staff_app`): rebuilt on the same auth components so
   staff has one auth language; behavior (username/password + continue +
   forgot) preserved.
6. **Splash:** `AuthLoadingView` becomes a calm branded loader (logo + subtle
   progress) with localized semantics, no layout flash before the login/home
   decision.
7. **Keyboard & responsiveness:** forms usable one-handed; field focus order
   logical; submit reachable above keyboard; OTP boxes resize gracefully in RTL.
8. **SecurityBadge** copy becomes app-aware (generic workshop/customer/CRM
   wording via localized ARB per app usage or a `context`/enum prop) — remove
   the "workshop" leak in CRM simply by localizing per-app identity strings.

## D. Screens and workflows

| Screen | Behavior to preserve | Redesign intent |
|---|---|---|
| `LoginView` (all 4 apps) | password / email-OTP / SMS-OTP / register toggle (customer); identifier detection; 30 s cooldown; `onLoginSuccess` firing on `AuthAuthenticated`; door gating left to routers | T8 template; segmented method control; refined fields; localized identity panel; responsive split ≥900 px |
| `ForgotPasswordView` (all 4) | 3 stages; UAE +971 normalization; masked destination; 30 s cooldown; friendly error mapping; `onBackToLogin` | Same stages with step progress; clearer copy; localized; responsive |
| `AuthLoadingView` (all 4) | used at `/`; resolves auth state; semantics live region | Branded loader; localized; no flash |
| `SupervisorLoginView` (staff) | username/password, continue, forgot entry | Rebuilt with shared auth components; same logic |
| `AuthShell` | compact column / boxed card / ≥900 split identity+form; `top`/`footer` slots | Polish to design system; identity panel becomes navy `surfaceStrong`; localized props |
| `AuthNotice`/`AuthNoticeSlot` | live region; tone enum | Restyled to `AppInfoPanel` grammar (semantic tones) |
| `SecurityBadge` | terms footnote | Localized per-app copy; link behavior unchanged |
| Legacy widgets | `AuthHeader`, `AuthBackground`, `PhoneInputField`, `OtpInputField` unused by live views (tests only) | Confirm zero production references → delete; migrate their tests to the live components |

## E. Responsive specifications

- **Compact (≤599):** single column; identity block condensed to brand mark +
  app purpose one-liner; form centered with `pagePadding`; OTP boxes sized to fit
  320 px (6×~44 px + gaps); buttons full width.
- **Medium (600–1023):** boxed card (max ~520 px) centered; rail none (auth is
  pre-workspace); identity above form or side-by-side per existing `AuthShell`
  rules retained.
- **Expanded/large (≥900):** split layout — navy identity panel (brand mark,
  app name, purpose, intended users, security badge, optional subtle pattern)
  + form card (max 460 px, `formMaxWidth` rules).
- **Keyboard/short viewport:** focused-flow alignment via `context.adaptive`
  (`focusedFlowAlignment`); scrollable form; CTA above keyboard.
- **Text scale:** 1.0–1.3× verified; OTP row wraps under extreme scale without
  clipping.
- **Orientation:** no horizontal overflow in landscape phones (form scrolls).

## F. Localization and RTL

- Every auth string localized EN+AR via `shared_auth` ARB (Phase 02
  infrastructure); the per-app identity props are localized strings passed from
  each app's ARB (add those keys to each app in this phase).
- RTL: form fields, OTP pin row, text alignment and icons mirror; phone dial
  code sheet rows align end; back icons flip; the identity panel's decorative
  alignment mirrors.
- Numbers: OTP digits and phone numbers stay Latin digits; countdown text
  localized (`plural` ICU for seconds).
- Tests: login/recovery widget tests run in `en` and `ar` (update existing
  `auth_experience_test.dart`), assert `Directionality.rtl`, no overflow at
  320 px, and localized notice copy.

## G. Design system integration

- Use Phase 01–04 components: `AuthShell` (restyled), `AppButton` system,
  `AppTextField` grammar (auth keeps its own `AuthTextField` only if it maps to
  the same visual/behavioral grammar — prefer converging the API),
  `AppInfoPanel` tones for notices, `AppStepProgress` for recovery stages,
  `AppSkeleton` for any waiting state, `SectionHeader` for identity panel.
- No hard-coded colors/sizes: tokens only. Legacy `AuthBackground`/`AuthHeader`
  deleted; `PhoneInputField`/`OtpInputField` deleted if unwired (confirm first).

## H. Technical implementation

- Modify: `shared_auth/lib/src/presentation/**` + ARBs; `shared_auth` tests.
- Modify apps' router mounts ×4 (localized copy + any constructor changes);
  `supervisor_login_view.dart` rebuilt.
- Preserve: `LoginNotifier`/`login_provider.dart` API and behavior; `AuthState`;
  `authenticate.dart` use-cases; `AuthInterceptor`; push-token scope
  (`AuthenticatedPushNotificationScope` stays wrapping the app, untouched).
- No route path changes; no new packages.
- Keep `pinput` usage; restyle via theme, not replacement.

## I. Functional preservation

- All auth flows end in the exact same provider/state transitions and the same
  post-login navigation per app.
- Cooldowns, OTP resend, identifier detection, UAE +971 default, password rules,
  registration role value, error mapping behavior unchanged.
- Router redirect/gating logic untouched.
- Push notification token lifecycle untouched.
- Existing `login_state_test.dart` behavior tests remain valid (extend, don't
  rewrite logic tests).

## J. Testing requirements

- `melos run analyze`; `melos run test:auth`; plus each app suite to prove
  router mounts compile/pass.
- Widget tests (extend `auth_experience_test.dart`):
  - each method path renders in EN + AR; validation notices as live regions;
  - OTP entry + resend countdown; recovery 3 stages; registration (customer);
  - 320 px and 1.3× scale no-overflow in both locales;
  - RTL mirroring assertions;
  - `SupervisorLoginView` same-suite coverage.
- Goldens for auth at compact + expanded in EN/AR where the project's golden
  approach supports it (add `goldens/` files for auth screens — the earlier
  suite referenced goldens that are missing; re-baseline intentionally here).
- Keyboard: `FocusTraversalGroup` order test (tab order identifier → password →
  submit).

## J2. Visual quality gates (mandatory)

Static analysis and widget tests alone are **not** proof of design quality. This
phase is not complete until all of the following evidence exists:

1. **Rendered review** — run all four apps and visually review login, recovery,
   splash and supervisor login in both themes of the flow; no auth screen may be
   signed off from code-reading alone.
2. **Form factors** — renders captured at mobile (≤430 px), tablet (600–1023 px)
   and desktop (≥900 px split) for each auth screen.
3. **Locales** — EN-LTR and AR-RTL renders for every auth screen; reviewed for
   OTP box alignment, identity-panel mirroring, Arabic typography.
4. **State matrix** — default, focused, invalid credentials, loading CTA, OTP
   entry + resend countdown, registration, recovery stages. Fixtures use
   plausible identifiers — no fake "test@test.com" placeholder screenshots.
5. **Interaction verification** — method switching, show/hide password, OTP
   paste, resend cooldown, back navigation at every recovery stage, submit
   loading, error notices, post-login routing per app.
6. **Accessibility** — 1.0–1.3× scale clean at 320 px; live-region notices;
   focus order identifier → password/OTP → submit; contrast sampled on navy
   identity panel.
7. **No visual overflow** at 320 px in either locale (OTP boxes especially).
8. **Evidence attached** — goldens or a screenshot pack at
   `phases/reports/PHASE_05/` named `screen_width_locale_state.png`. Section K
   is unmet without this evidence.

## K. Acceptance criteria

1. All five auth screens + `AuthShell` redesigned on the new system, EN+AR,
   RTL-correct, responsive at 320/390/768/1280 px.
2. No hard-coded strings remain in `shared_auth` presentation
   (search-verifiable); per-app identity keys exist in each app's ARB.
3. Behavior contracts preserved (state machine, cooldowns, routing) — verified by
   existing + extended tests.
4. `AuthLoadingView` shows branded, localized splash with live-region semantics.
5. Legacy auth widgets removed or explicitly documented as retained with reason.
6. All suites green; goldens regenerated only for auth surfaces.

## L. Deliverables

- Screen-by-screen summary with file paths; ARB key counts (EN/AR) for
  `shared_auth` + the four apps' identity keys.
- Removed legacy widgets/tests (evidence of zero references).
- Test evidence (analyze + suites + new widget tests + goldens).
- Known limitations (e.g. biometric login not in scope; any per-app identity
  copy still needing product sign-off).

## M. Completion gate

Stop after this phase. Do not begin Phase 06 until explicitly instructed.
