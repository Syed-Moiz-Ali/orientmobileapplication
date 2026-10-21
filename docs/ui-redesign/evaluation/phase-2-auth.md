# Phase 2d evaluation — auth redesign (fresh reviewer, branch `ui/phase-2-auth`)

Reviewer stance: harsh. Approving a weak redesign is a failure. READ-ONLY except this file.
No code, test, ARB, or baseline PNG was edited. No commit.

Sources read first: `docs/ui-redesign/DESIGN_SPEC.md` (C8, C9 auth anatomy, C10 states,
C14 RTL/responsive), `docs/ui-redesign/phase-2-auth-notes.md` §§5–8, all 5
`baseline/before/` PNGs, all 5 `evaluation/contact-sheets/phase-2d-*.png`, branch log
(`271e97cd ui(phase-2c): full auth redesign on App* widgets` — App* swaps, Pinput
token-styling, supervisor ARB fixes, legacy `auth_button`/`auth_field`/`auth_notice` deletions; verified via `git show --stat HEAD`).

## Method

- Viewed all 5 side-by-sides (before vs after login) with the Read tool.
- Directly inspected 34 distinct `baseline/after-phase-2/` PNGs covering: every screen family ×
  idle LTR+RTL × light+dark (customer) / light (staff, owner, CRM), every state capture
  (field error, form error/offline+retry, busy, OTP post-send, resend cooldown text, forgot
  reset/done, register idle+error, supervisor idle/busy/field/form error, splash light+dark+AR),
  both text scales (1.0, 1.3) for customer, 320×568 samples, and the 768×1024 tablet samples.
- Remaining files are byte-identical modulo brand strings: all four apps mount the same shared
  `LoginView`/`ForgotPasswordView`; staff/owner/CRM login idles were each spot-opened and confirmed
  pixel-identical to customer apart from the app-name/purpose block. Code-mode presend/postsend
  idles across apps likewise confirmed identical modulo branding. Stated as such below instead of
  re-listing 100 identical files.

## Verdict summary

- **FAIL — redesign NOT accepted. 7 blocking fails (F-1…F-7), all user-visible, all systemic
  (shared widgets, so every app is affected).**
- Judged images: 34 directly inspected + 5 side-by-sides + 5 befores. Extrapolated to all 146:
  **≈110 fail / ≈36 pass** (every image containing the segmented switcher, the password-mode login
  form, the resend row, the done screen, or an RTL directional arrow fails; splash + tablet
  structure + inline error grammar pass).
- Redesign-mandate question ("is the redesign clearly visible versus before?"): **PASS per family**
  (pill `AppSegmentedControl`, pill CTA, token inputs, `AppBanner` grammar are unmistakably new).
  The redesign was delivered but **shipped with regressions** — mandate visibility does not excuse F-1…F-7.

## Blocking fails (must fix before blessing any golden)

- **F-1 — Segmented switcher truncates its primary labels at base size.**
  `customer_login_password_idle_light_1.0_en_360x800.png` (and every login idle/postsend at 360 EN,
  all 4 apps, light+dark): selected/unselected segments render `Password | One-time co…`.
  Before showed the full `One-time code`. Truncating a mode switcher — the screen's primary control —
  violates C3 (truncation only on secondary text) and C14. AR also truncates
  (`رمز لمرة واح…`, `customer_login_password_idle_dark_1.3_ar_360x800.png`). Only the 768px tablet
  sample fits. Fix (visual, no logic): give `AppSegmentedControl` full-width equal segments with
  wrapping/shrinking labels (smaller label style or stacked icon-over-label at compact widths, or
  min-width + horizontal scroll per C8 pill-tabs variant) so both labels render in full at 320–360px
  EN/AR at 1.0x–1.3x. Re-verify F-1 set below.
- **F-2 — `Forgot password?` entry link missing from shared login.**
  All after login-password idles (customer/staff/owner/CRM, EN+AR) show no forgot link; before had it
  right-aligned above Continue, and staff `supervisor_login` after-images DO show it. Users on the
  password tab have no path to recovery (forgot screens exist but are unreachable from login).
  Fix: restore the secondary text-link below the password field (end-aligned, as before) wired to the
  existing `/forgot-password` route. No logic change.
- **F-3 — Resend-cooldown row layout broken (orphan spinner + detached countdown).**
  `customer_login_code_postsend_otp_sent_light_1.0_en_360x800.png`,
  `customer_forgot_reset_field_error_light_1.0_en_360x800.png`, owner AR + dark AR equivalents:
  a lone ○ spinner sits at the row start while `Resend in 30 seconds` floats centered far below with
  a ~200px dead gap. Looks broken in every locale/theme. Fix: single centered row —
  16px spinner + `Resend in {n} seconds` (disabled, tertiary) inline, 12 gap, one line, wraps as a unit.
- **F-4 — Success banner overlaps the resend countdown on forgot-reset.**
  `customer_forgot_reset_otp_sent_light_1.0_en_360x800.png`: the `Recovery code sent…` banner floats
  ON TOP of `Resend in 30 seconds` (countdown text peeks out from behind the banner). Overlap =
  C14 fail. Fix: place the token banner in-flow above the resend row (or pin resend row below banner
  with 12 gap) so nothing overlaps at 360×800; keep the page scrollable.
- **F-5 — Done-screen duplicates its own subtitle.**
  `customer_forgot_done_success_light_1.0_en_360x800.png` and
  `customer_forgot_done_success_dark_1.0_ar_360x800.png`: `Sign in with your new password to
  continue.` appears BOTH under the headline AND under the success icon. Terminal security screen
  showing the same sentence twice reads as broken. Fix: keep one instance (headline + sub, icon,
  CTA — delete the second body line).
- **F-6 — Directional arrows not mirrored in RTL.**
  AR CTA buttons render `متابعة →` / `إرسال الرمز →` (arrow points right = backwards in RTL);
  forgot back-link renders `تسجيل الدخول ←` (should point right for "back" in RTL). C14/C15 require
  direction-implying icons to mirror; digits/`+971`/eye/lock positions are correctly handled, so this
  is purely the arrow glyphs in `AppPillButton` leading icons and the ghost back-link. Fix: mirror
  arrow glyphs under RTL (`matchTextDirection` / Directionality-aware icon), keep positions.
- **F-7 — 1.3x text scale truncates primary actions; 320px compounds it.**
  `customer_login_password_idle_light_1.3_en_360x800.png`: `New customer? Create an acco…` cut with
  ellipsis (primary link, must never truncate). `…_1.3_en_320x568.png`: BOTH segment labels cut
  (`Passw…`, `One-ti…`), label wraps pushing layout. C12/C14 require clean reflow at 1.3x. Fix: allow
  the switcher + links to wrap/grow (no fixed-height text containers, no ellipsis on actions/links);
  at 320px stack or shrink segment labels per F-1 fix and let the CTA link wrap to two lines centered.

## Minor polish notes (non-blocking, fix opportunistically)

- M-1: shared-login AR keeps the English brand/purpose block (`Orient Customer App / Vehicle
  owners…`, `Book service…`) while supervisor AR is fully translated — inconsistent fallback props;
  confirm intended (brand-exempt vs missing translation) in phase 9.
- M-2: password-strength track nearly invisible in dark (`…_register_idle_dark_…`); raise track
  contrast; `Weak` text cue itself is fine (not color-alone).
- M-3: supervisor form-error banner stacks message + right-aligned `Try again` awkwardly; acceptable.
- M-4: email-hint placeholder ellipsis inside the field is normal hint behavior — not a fail (unlike F-1/F-7).
- M-5: `code_error` token banner sits half below the 800px fold (page scrolls) — acceptable if scroll
  verified on device; keep content above fold to the CTA.

## Per-screen table (representative files judged; families marked identical-modulo-branding)

| Screen | App | Theme | Locale | Scale | Size | State | Result | Issues | Fix | Re-verified |
|---|---|---|---|---|---|---|---|---|---|---|
| Login password idle (side-by-side) | customer | light | en | 1.0 | 360×800 | idle | FAIL | F-1 truncation; F-2 forgot link gone; redesign visible → mandate pass | F-1, F-2 | no |
| Login password idle (side-by-side) | customer | dark | en | 1.0 | 360×800 | idle | FAIL | F-1, F-2; mandate pass | F-1, F-2 | no |
| Login password idle (side-by-side) | staff/owner/crm | light | en | 1.0 | 360×800 | idle | FAIL | F-1, F-2; identical modulo brand block | F-1, F-2 | no |
| Login password idle | customer | light | en | 1.0 | 360×800 | idle | FAIL | F-1, F-2 | F-1, F-2 | no |
| Login password idle | customer | light | ar | 1.0 | 360×800 | idle | FAIL | F-1 (AR truncation), F-2, F-6 (CTA arrow →) | F-1, F-2, F-6 | no |
| Login password idle | customer | light/dark | en/ar | 1.3 | 360×800 | idle | FAIL | F-1, F-2, F-7 (link ellipsis) | F-1, F-2, F-7 | no |
| Login password idle | customer | light | en/ar | 1.0 | 320×568 | idle | FAIL | F-1 severe at 320 | F-1 | no |
| Login password idle | customer | light | en | 1.3 | 320×568 | idle | FAIL | F-7 catastrophic (both labels cut, label wraps) | F-1, F-7 | no |
| Login password idle | customer | light | en | 1.0 | 768×1024 | idle | FAIL | F-2 only (segments fit on tablet; card layout good) | F-2 | no |
| Login password idle | customer | dark | en/ar | 1.0–1.3 | 360×800 | idle | FAIL | F-1, F-2 (+F-6/F-7 in ar/1.3) | F-1, F-2, F-6, F-7 | no |
| Login password idle | staff/owner/crm | light | en/ar | 1.0/1.3 | 360×800 | idle | FAIL | same as customer modulo brand (spot-verified) | F-1, F-2 | no |
| Login password field error | customer | light | en (+1.3 ar spot) | 1.0 | 360×800 | field error | FAIL (form) / PASS (error grammar) | inline errors w/ icon correct; host screen has F-1, F-2 | F-1, F-2 | no |
| Login password form error (offline+retry) | customer | light | en | 1.0 | 360×800 | form error | FAIL (form) / PASS (banner) | snackbar+retry fits, keeps data; host F-1, F-2 | F-1, F-2 | no |
| Login password busy | customer | light/dark | en | 1.0 | 360×800 | busy | FAIL (form) / PASS (busy) | `Signing in…` keeps width, fields disabled; host F-1, F-2 | F-1, F-2 | no |
| Login code presend idle | customer | light/dark | en/ar | 1.0/1.3 | 360×800 | idle | FAIL | F-1 (+F-6 AR CTA); `Send code` hierarchy good | F-1, F-6 | no |
| Login code postsend (OTP sent + cooldown) | customer | light/dark | en/ar | 1.0/1.3 | 360×800 | otp-sent | FAIL | F-1, F-3 (orphan spinner + detached countdown); Pinput token styling good, LTR digits locked, focus ring correct | F-1, F-3 | no |
| Login code postsend | owner/crm/staff | light | en/ar | 1.0 | 360×800 | otp-sent | FAIL | same as customer modulo brand (spot-verified AR owner) | F-1, F-3 | no |
| Login code error | customer | light | en | 1.0 | 360×800 | code error | FAIL (form) / PASS (error) | red Pinput ramp + message correct; host F-1, F-3; banner half below fold (M-5) | F-1, F-3 | no |
| Register idle | customer | light/dark | en/ar | 1.0/1.3 | 360×800 | idle | PASS (modulo F-1 n/a: no switcher) | single focus, strength meter + `Weak` label, secondary link; dark track low contrast (M-2) | M-2 | n/a |
| Register field error | customer | light | en | 1.0 | 360×800 | field error | PASS | three inline errors w/ icons, layout holds | — | n/a |
| Forgot identifier idle | customer/owner (spot) | light/dark | en/ar | 1.0 | 360×800 | idle | PASS | step progress, back link (F-6 glyph in AR), single CTA, brand consistent | F-6 | no |
| Forgot identifier field/form error | customer | light | en | 1.0 | 360×800 | field+form error | PASS | inline error + focus ring + offline banner w/ retry all correct | — | n/a |
| Forgot reset (OTP sent) | customer (+staff/crm/owner spot) | light/dark | en/ar | 1.0 | 360×800 | otp-sent | FAIL | F-3, F-4 (banner covers countdown); Pinput + password + strength good | F-3, F-4 | no |
| Forgot reset field/code error | customer | light | en | 1.0 | 360×800 | field error | FAIL (form) / PASS (errors) | error copy + red labels correct; host F-3 | F-3 | no |
| Forgot done (terminal confirmation) | customer/all | light/dark | en/ar | 1.0/1.3 | 360×800 | success | FAIL | F-5 duplicated subtitle (dedicated screen per C10 exception otherwise correct) | F-5 | no |
| Supervisor login idle | staff | light | en/ar | 1.0/1.3 | 360×800 (+320) | idle | PASS | clean App* form, forgot link present, no overflow at 320; AR fully translated (2c ARB fix confirmed); AR CTA arrow → (F-6) | F-6 | no |
| Supervisor busy/field/form error | staff | light | en | 1.0 | 360×800 | busy/field/form | PASS | label-swap busy keeps width; inline errors; banner+retry (no raw `e.message` seen — 2c fix confirmed) | — | n/a |
| Splash | shared | light/dark | en/ar | 1.0/1.3 | 360×800 | loading | PASS | navy signature kept per decision, centered lockup, localized caption, no overflow at 1.3x | — | n/a |

Pass-count note: rows marked PASS with an F-item in Issues (forgot-idle/supervisor-idle AR arrows) inherit the
systemic F-6 glyph fix; their layouts are otherwise accepted.

## 2c claim cross-check (read-only git)

- App* swaps + legacy deletions (`auth_button.dart`, `auth_field.dart`, `auth_notice.dart` removed,
  `auth_otp_field.dart`/`auth_resend_action.dart` added): confirmed in `git show --stat HEAD`.
- Pinput token-styling: confirmed visually (radius-12 token boxes, blue focus ring, red error ramp,
  LTR lock, autofocus caret) in EN+AR, light+dark.
- Supervisor ARB fixes: confirmed — AR supervisor renders full Arabic copy; form-error shows mapped
  copy (`Enter username and password` + retry), no raw exception text in any capture.
- Legacy deletions: no legacy-widget visuals remain in any capture.

## Re-verification protocol (re-capture exactly these after fixes; judge before blessing)

1. F-1/F-2/F-7: `customer_login_password_idle_light_1.0_en_360x800.png`,
   `customer_login_password_idle_light_1.0_ar_360x800.png`,
   `customer_login_password_idle_light_1.3_en_360x800.png`,
   `customer_login_password_idle_light_1.3_en_320x568.png`,
   `customer_login_password_idle_dark_1.0_en_360x800.png`,
   `customer_login_password_idle_light_1.0_en_320x568.png`,
   `customer_login_password_idle_light_1.0_en_768x1024.png` — both segment labels fully visible at
   every size/scale, forgot link present, no ellipsis on any action/link.
2. F-3/F-4: `customer_login_code_postsend_otp_sent_light_1.0_en_360x800.png`,
   `customer_login_code_postsend_otp_sent_dark_1.0_ar_360x800.png`,
   `customer_forgot_reset_otp_sent_light_1.0_en_360x800.png` — spinner+countdown one inline row,
   banner in-flow with zero overlap.
3. F-5: `customer_forgot_done_success_light_1.0_en_360x800.png`,
   `customer_forgot_done_success_dark_1.0_ar_360x800.png` — subtitle appears exactly once.
4. F-6: `customer_login_password_idle_light_1.0_ar_360x800.png`,
   `customer_forgot_identifier_idle_dark_1.0_ar_360x800.png`,
   `staff_supervisor_login_idle_light_1.3_ar_360x800.png` — all directional glyphs mirror (CTA ←-glyph,
   back-link →-glyph); digits/`+971`/Latin stay LTR.
5. Regression sweep (must stay passing): `customer_login_password_busy_light_1.0_en_360x800.png`,
   `customer_login_password_form_error_light_1.0_en_360x800.png`,
   `customer_login_register_idle_dark_1.0_en_360x800.png`,
   `staff_supervisor_login_form_error_light_1.0_en_360x800.png`,
   `splash_loading_idle_dark_1.0_ar_360x800.png`.
6. Only re-bless goldens after all five groups pass; then plain `flutter test` must be green.
