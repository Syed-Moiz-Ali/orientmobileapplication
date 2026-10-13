# PHASE 05 — Authentication & Onboarding: Completion Report

- **Date:** 2026-10-13
- **Phase:** 05 — Authentication & Onboarding (`phases/PHASE_05_AUTHENTICATION_AND_ONBOARDING.md`)
- **Status:** **IMPLEMENTATION COMPLETE — awaiting product-owner review**
- **Toolchain:** Flutter 3.35.7 stable · Dart 3.9.2 · Windows dev machine
- **Authorities:** `00_DESIGN_SYSTEM_SPEC.md` (§7 components, §14 T8 auth template,
  §8 a11y, §9 l10n/RTL), `00_VISUAL_DIRECTION.md` (frozen V1–V14; V12 auth
  identity panel), `00_RESPONSIVE_STRATEGY.md`, `00_LOCALIZATION_RTL_STRATEGY.md`,
  Phase 00 prototype (`apps/design_prototype/**` — read-only, **0 changes**).

---

## 1. Phase objective and scope

Redesign the complete authentication experience shared by all four apps — a
premium, localized, responsive, branded entry into every product — while keeping
the existing auth state machine, providers, API calls, OTP flows, cooldowns and
role-routing behavior byte-for-byte intact.

In scope: `LoginView`, `ForgotPasswordView`, `AuthLoadingView`, `AuthShell`,
`AuthNotice`/`AuthNoticeSlot`, `SecurityBadge`, and the staff
`SupervisorLoginView`; the four app router mounts (localized identity + security
notice); the legacy auth widgets; and the `shared_auth` test suite + auth goldens.
Out of scope: any feature screen, backend/API, route paths, permissions.

---

## 2. Screens and workflows completed

| Screen | Apps | Redesign delivered |
|---|---|---|
| `LoginView` | all 4 | `AuthShell` T8; segmented password / one-time-code control; refined fields (LTR identifier content, show/hide, autofill); localized identity panel; responsive split ≥900 px |
| `ForgotPasswordView` | all 4 | 3 stages (identifier → code + new password → done); `AppStepProgress` step rail; masked destination; resend countdown; responsive |
| `AuthLoadingView` | all 4 | Branded navy splash (mark + wordmark + calm progress) with live-region semantics; no layout flash |
| `SupervisorLoginView` | staff | Rebuilt on shared `AuthShell`/`AuthTextField`/`AuthPrimaryButton`/`AuthLinkButton`/`AuthNoticeSlot`; localized EN+AR; username/password + continue + forgot logic unchanged |
| `AuthShell` | shared | Navy `surfaceStrong` identity panel; token-only surfaces/radii/shadows; `top`/`footer` slots; `FocusTraversalGroup` |
| `AuthNotice` / `AuthNoticeSlot` | shared | Restyled onto `AppInfoPanel` semantic tones (danger/primary/success); live region preserved |
| `SecurityBadge` | shared | App-aware copy via optional `text`; shared generic default removes the workshop leak in CRM |

Behavior preserved exactly: `LoginNotifier`/`login_provider.dart`, `AuthState`,
`authenticate.dart` use-cases, `AuthInterceptor`, `PasswordIdentifier`/`AuthMethod`
transitions, 30 s resend cooldown, UAE +971 default, identifier auto-detection,
registration `role: 'customer'`, friendly error mapping, router gating and
post-login navigation, and `AuthenticatedPushNotificationScope`.

---

## 3. Files changed

### `packages/shared_auth`

New:
- `lib/src/presentation/widgets/phone_country.dart` (`PhoneCountry`, `phoneCountries`)
- `test/auth_phase05_test.dart` (15)
- `test/auth_phase05_visual_test.dart` (12 goldens)
- `test/goldens/**` (auth baseline, now present)

Modified:
- `lib/src/presentation/widgets/auth_surface.dart` — navy identity panel,
  token-only surfaces, `securityNotice`, `FocusTraversalGroup`
- `lib/src/presentation/widgets/auth_button.dart` — RTL-mirroring `DirectionalIcon`
- `lib/src/presentation/widgets/auth_field.dart` — `textDirection` (LTR identifiers)
- `lib/src/presentation/widgets/auth_notice.dart` — `AppInfoPanel` grammar
- `lib/src/presentation/widgets/auth_loading_view.dart` — branded splash
- `lib/src/presentation/widgets/security_badge.dart` — app-aware `text`
- `lib/src/presentation/pages/login_view.dart` — segmented method control
- `lib/src/presentation/pages/forgot_password_view.dart` — `AppStepProgress`
- `lib/shared_auth.dart` — exports (removed legacy, added `phone_country`)
- `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` + regenerated `lib/l10n/gen/**`
- `test/auth_experience_test.dart`, `test/login_state_test.dart`,
  `test/localized_auth_test.dart`

Deleted (zero production references, confirmed):
- `auth_header.dart`, `auth_background.dart`, `otp_input_field.dart`,
  `phone_input_field.dart`

### Four apps

- `apps/*/lib/core/router/app_router.dart` ×4 — pass localized
  `securityNotice: t?.authSecurityNotice` to `LoginView`/`ForgotPasswordView`
- `apps/*/lib/l10n/app_en.arb`, `app_ar.arb` ×4 — `authSecurityNotice` (+ staff
  supervisor keys) + regenerated `lib/l10n/gen/**`
- `apps/staff_app/lib/features/supervisor/presentation/supervisor_login_view.dart` —
  rebuilt on shared auth components, localized
- `apps/staff_app/test/supervisor_login_phase05_test.dart` (5) + 2 goldens

### Narrowly-scoped technical adjustment (documented)

Deleting the legacy `PhoneInputField` required one non-visual reference swap in a
**07A-owned** screen: `apps/staff_app/lib/features/advisor/presentation/pages/
vehicle_customer_view.dart` now reads `phoneCountries.first.code` (UAE +971)
instead of `PhoneInputField.countries.first.code`. No visual or behavioral change.

*Not touched:* `apps/design_prototype/**` (git-verified 0 changes); no route paths,
providers, API/DTO shapes, permissions or persistence.

---

## 4. Shared component integration

- `AuthShell` — the single T8 auth template (compact column / boxed card / ≥900
  split), navy `AppColors.navy` identity panel with `navySurfaceRaised` context
  card and trust points, token radii/shadows/motion only.
- `AppButton` family semantics — `AuthPrimaryButton` (busy-in-button, WCAG AA ink),
  `AuthLinkButton` (48 px target, RTL `DirectionalIcon`).
- `AuthTextField` — the `AppTextField` grammar (label-above, icon slots,
  focus/error borders) + identifier LTR content.
- `AppInfoPanel` tones — `AuthNotice`/`AuthNoticeSlot`.
- `AppStepProgress` — recovery step rail.
- `DirectionalIcon` — back/forward glyphs flip in RTL.
- `AppMotion` — all durations resolve through `AppMotion.resolve` (reduced-motion).

---

## 5. Responsive results

- **Compact ≤599:** single column, condensed identity block, full-width CTA,
  `pagePadding`; OTP boxes fit 320 px.
- **Medium 600–1023:** boxed card (max 460) centered (rendered at 768).
- **Expanded ≥900:** split — navy identity panel + form (rendered at 1280).
- **Keyboard/short viewport:** `AppResponsive.specFor` + `focusedFlowAlignment`;
  form scrolls, CTA clears the keyboard.
- **Text scale:** 1.0–1.3× verified EN + AR at 320 px; zero overflow.
- **RTL parity:** every layout statement holds mirrored (identity panel swaps to
  the reading-end side, fields/rows/segmented control mirror, icons flip).

---

## 6. English / Arabic translation coverage

- `shared_auth` now ships **74 EN keys** (was 79): **−9** legacy-widget keys
  removed, **+4** redesign keys (`authMethodPassword`, `authMethodCode`,
  `authRecoveryStepIdentify`, `authRecoveryStepReset`), `loginActionResendIn`
  converted to **ICU plural**, and `authSecurityBadge` genericized.
- **+4** app keys (`authSecurityNotice` ×4) + **+8** staff supervisor keys.
- Parity tests pass for `shared_auth` and all four apps; `l10n_untranslated.json`
  is `{}` for every unit. `flutter gen-l10n` regenerated.
- **Zero hard-coded user-visible strings** remain in `shared_auth` presentation.
- RTL: identifier fields force `TextDirection.ltr`; OTP digits/phone numbers stay
  Latin; the resend countdown uses plural ICU; the security notice is per-app
  localized (CRM no longer shows workshop wording).

---

## 7. Accessibility checks

- Live-region notices (`Semantics(liveRegion: true)`) for errors, code-sent and
  the splash; validated by tests in EN + AR.
- Touch targets ≥48 px (buttons, links, method tabs).
- Focus: `FocusTraversalGroup` (reading order); tab order identifier → password
  test-proven.
- Contrast: navy identity panel uses `AppColors.textInverse` /
  `AppColors.onNavySecondary`; primary CTA follows the Phase 01.1 AA on-primary
  ink (unchanged test still passes).
- 320 px @ 1.3× clean in both locales; reduced-motion respected via `AppMotion`.

---

## 8. Visual evidence

`phases/reports/PHASE_05/screens/` — **24 renders**, named
`screen_width_locale_state.png`:

- `login_{390,768,1280}_{en,ar}_default.png`
- `login_390_{en,ar}_otp.png`, `login_390_en_code.png`, `login_390_en_otp_sent.png`
- `register_390_en_default.png`
- `recovery_390_{en,ar}_identifier.png`, `recovery_390_en_reset.png`,
  `recovery_390_en_done.png`, `recovery_390_en_reset_shell.png`
- `splash_390_{en,ar}_default.png`
- `supervisor_login_390_{en,ar}_default.png`
- legacy-reference renders for regression comparison.

Goldens live at `packages/shared_auth/test/goldens/` (12 Phase 05) and
`apps/staff_app/test/goldens/supervisor_login_compact_{en,ar}.png`. All renders
were reviewed (EN + AR, mobile/tablet/desktop, default/otp/recovery/splash).

---

## 9. Regression test results

Fresh baseline captured **before** implementation; final after.

| Unit | Baseline (pass/fail) | Final (pass/fail) | New failures | Notes |
|---|---|---|---|---|
| `shared_auth` | 35 / 11 | **73 / 0** | **0** | 11 missing auth goldens **resolved** (Phase 05-owned, reviewed); +15 functional, +12 visual tests |
| `staff_app` | 277 / 7 | **282 / 7** | **0** | +5 supervisor tests; 7 failures identical to baseline (6 intake overflows + 1 advisor-workflow finder — pre-existing, owned by 07A/06) |
| `owner_app` | 21 / 0 | **21 / 0** | **0** | unchanged |
| `customer_app` | 511 / 6 | **511 / 6** | **0** | unchanged baseline set |
| `crm_app` | 14 / 0 | **14 / 0** | **0** | unchanged |
| `design_prototype` | 299 / 0 | 299 / 0 | 0 | read-only; git-verified 0 changes |

**Static analysis:** `dart analyze` → **0 issues** on all six production units.

Goldens regenerated **only** for the auth surfaces intentionally redesigned in
Phase 05 and visually reviewed before re-baselining; no feature-app golden was
touched.

---

## 10. Remaining issues and their owning phases

| Item | Owner |
|---|---|
| Caps-lock hint on the password field — not implemented; Flutter exposes no stable caps-lock API (documented limitation) | revisit on product request |
| Per-app identity/security copy is passed from each app's ARB; fallback literals in the routers remain for safety | feature phases when routers are revisited |
| Pre-existing staff intake overflow failures (6) + advisor-workflow finder (1) | 07A / 06 |
| Pre-existing customer golden set (6) | customer phases |
| Migrate the four app bars to `WorkspaceAppBar` | 06/09/10/11/12/15A/19A |
| Biometric login | not in scope |

---

## 11. Readiness for the next phase

**Ready.** The complete authentication experience is redesigned on the approved
2026 system, localized EN+AR, RTL-correct, responsive at 320/390/768/1280 px, and
behavior-preserving.

**Phase 05 completion checklist**

- [x] All five auth screens + `AuthShell` redesigned, EN+AR, RTL, 320/390/768/1280
- [x] No hard-coded strings in `shared_auth` presentation; per-app identity keys exist
- [x] Behavior contracts preserved (state machine, cooldowns, routing)
- [x] `AuthLoadingView` branded, localized splash with live-region semantics
- [x] Legacy auth widgets removed (or documented); `PhoneInputField` data retained as `phoneCountries`
- [x] All suites green (no new failures); auth goldens regenerated and reviewed
- [x] J2 evidence pack attached (`phases/reports/PHASE_05/`, 24 renders)
- [ ] Phase 06 — awaiting explicit authorization (not started)
