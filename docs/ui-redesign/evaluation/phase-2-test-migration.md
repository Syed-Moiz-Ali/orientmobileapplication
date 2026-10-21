# Phase-2 test migration — login step flow (2b → steps)

Scope: the 8 frozen 2b characterization files in `packages/shared_auth/test/`
migrated onto the C16 step-flow UI (`AppStepScaffold`, password-first,
register R1/R2/R3, link + countdown resend without the ring). This table lists
EVERY assertion that must change. Rows that keep behavior read `unchanged` in
Class and keep their finder/copy verbatim.

Conventions
- `t` = `enAuthL10n()` (or `arAuthL10n()` where noted).
- Step navigation settles with `pump()` + 500 ms (past the 220 ms
  `AppMotion.standard` token), same as the old `tapAndSettleMode`.
- New helpers (added additively to `test_helpers.dart`, old helpers kept):
  `reachPasswordStep` = enter identifier on Step 1 → tap Continue → settle
  (lands on the password step, ZERO API calls);
  `reachCodeConfirm` = enter identifier on Step 1 → tap the
  `loginStepUseCodeInstead` alt row → settle (sends the code, lands on the
  confirm step);
  `reachRegisterR3` = tap `loginStepCreateAccountRow` → R1 name → Continue →
  R2 contact → Continue (lands on R3, ZERO API calls so far).

## 1. `login_validation_test.dart` (old 25 expects)

| Test | Old assertion | New assertion | Class | Why |
|---|---|---|---|---|
| empty identifier | `tap(find.text(t.loginActionContinue))` then `expect(find.text(t.validationEnterIdentifier), findsOneWidget)` | unchanged (Step 1 CTA keeps the same key) + ADD `expect(find.text(t.loginStepIdentifierTitle), findsOneWidget)` | behavioral: unchanged / structural: added | Step 1 is the same single-CTA surface; headline proves the step |
| empty identifier | `expect(repo.loginCalls, 0)` | unchanged + ADD `expect(repo.sendOtpCalls, 0)` + `expect(repo.sendEmailOtpCalls, 0)` | behavioral: unchanged | Step-1 Continue fires ZERO API calls of any kind |
| email-like without @ | enter `find.byType(TextField).first` + tap Continue → `validationEnterValidEmail` | unchanged | behavioral: unchanged | Step 1 field + local validation identical |
| short phone | tap Continue → `validationEnterValidPhone` | unchanged | behavioral: unchanged | same |
| empty password | enter email → single tap Continue → `validationEnterIdentifier findsNothing` + `validationEnterPassword findsWidgets` + password-field error pin | Step 1: enter email → tap Continue → ADD `expect(find.text(t.loginStepPasswordTitle), findsOneWidget)` (advanced, no error); Step 2: tap Continue → the three old password assertions verbatim | structural: step navigation added / behavioral: unchanged | Password validation now runs on Step 2, not Step 1 |
| register toggle reveals | `tapAndSettleMode(find.text(t.loginNewCustomer))` | `tap(find.text(t.loginStepCreateAccountRow))` + settle | structural | Alt-row copy is the new key; old toggle link removed |
| register toggle reveals | `expect(find.text(t.loginFieldFullName), findsOneWidget)` | unchanged (R1 shows the name field) | behavioral: unchanged | same field, same key |
| register toggle reveals | `expect(find.text(t.loginActionCreateAccount), findsOneWidget)` | `expect(find.text(t.loginActionCreateAccount), findsNothing)` + ADD `expect(find.text(t.loginActionContinue), findsOneWidget)` + ADD `expect(find.text(t.loginStepRegisterNameTitle), findsOneWidget)` | structural | R1 CTA is Continue; Create account lives only on R3 |
| empty name | `openRegister` + `fields.at(1)` email + `fields.at(2)` password + tap CreateAccount → `validationEnterName` | R1: tap Continue (empty name) → `expect(find.text(t.validationEnterName), findsOneWidget)` verbatim + `registerCalls 0` verbatim | structural: single-field R1, Continue CTA / behavioral: unchanged | Name validation runs on R1 |
| short create-password | `fields.at(0/1/2)` + tap CreateAccount → `validationPassword6Chars` | R1 name → Continue → R2 email → Continue → R3 `fields.first` = `123` → tap CreateAccount → old assertion verbatim + `registerCalls 0` verbatim | structural: R1/R2/R3 sequence / behavioral: unchanged | Same rule, collected across 3 steps |
| rtl/ar empty identifier | tap Continue → Arabic `validationEnterIdentifier` | unchanged | behavioral: unchanged | Step 1 RTL identical |

## 2. `login_success_nav_test.dart` (old 8 expects)

| Test | Old assertion | New assertion | Class | Why |
|---|---|---|---|---|
| password success | `fields.at(0)` email + `fields.at(1)` password + tap Continue → `loginCalls 1` + `successes 1` | `reachPasswordStep(email)` → re-query `find.byType(TextField)` (password step) → enter password → tap Continue → old counts verbatim | structural: two-step fill / behavioral: unchanged | Same single `loginWithPassword` call |
| OTP verify success | `tapAndSettleMode(find.text(t.authMethodCode))` | `reachCodeConfirm(phone)` (alt-row send, no switcher) | structural | Segmented switcher removed by the brief |
| OTP verify success | `tap(find.text(t.loginActionSendCode))` | removed (send happens on the alt-row tap); ADD `expect(find.text(t.loginStepCodeTitle), findsOneWidget)` | structural | No presend CTA in the step flow |
| OTP verify success | `setOtp` + tap Verify → `verifyOtpCalls 1` + `successes 1` | unchanged | behavioral: unchanged | Same single verify call |
| failed login | two-field fill + Continue → `successes 0` | two-step fill + Continue → `successes 0` verbatim | structural nav / behavioral: unchanged | Failure never routes to success |

## 3. `login_resend_test.dart` (old 9 expects)

| Test | Old assertion | New assertion | Class | Why |
|---|---|---|---|---|
| after send | `tap(find.text(t.authMethodCode))` + enter + `tap(find.text(t.loginActionSendCode))` | `reachCodeConfirm(phone)` | structural | Switcher + presend CTA removed |
| after send | `expect(container.read(loginProvider).resendCooldown, 30)` | unchanged | behavioral: unchanged | Same 30 s notifier cooldown |
| after send | `expect(find.text(t.loginActionResendIn(30)), findsOneWidget)` | unchanged | behavioral: unchanged | Same countdown copy |
| after send | `expect(find.text(t.loginActionResendCode), findsNothing)` | unchanged | behavioral: unchanged | Still cooling down |
| after send | `AppTextButton(ResendIn).onPressed isNull` | unchanged | behavioral: unchanged | Still disabled |
| after send | `expect(descendant(AuthResendAction, CircularProgressIndicator), findsOneWidget)` | `expect(find.byType(CircularProgressIndicator), findsNothing)` + ADD `expect(find.byType(LoginResendRow), findsOneWidget)` | structural | Cooldown ring deleted; link + text only |
| stable across frames | same switcher/send nav + `cooldown 30` + `ResendIn(30)` | same confirm nav; cooldown/text assertions verbatim | structural nav / behavioral: unchanged | START state still pinned, no waiting |

## 4. `login_register_test.dart` (old 14 expects)

| Test | Old assertion | New assertion | Class | Why |
|---|---|---|---|---|
| toggle reveals | `openRegister` via `loginNewCustomer` | `openRegister` via `loginStepCreateAccountRow` + settle | structural | New alt-row key |
| toggle reveals | `loginFieldFullName findsOne` | unchanged (R1) | behavioral: unchanged | same |
| toggle reveals | `loginFieldCreatePassword findsOne` | moved to R3: on R1 `expect(find.text(t.loginFieldCreatePassword), findsNothing)`; after R1→R2 nav, on R3 `findsOneWidget` | structural | One field group per step |
| toggle reveals | `loginActionCreateAccount findsOne` + `loginActionContinue findsNothing` | inverted: R1 `loginActionContinue findsOne` + `loginActionCreateAccount findsNothing` | structural | Single CTA per step |
| valid registration | `fields.at(0/1/2)` + tap CreateAccount → `registerCalls 1` + `loginCalls 0` + `successes 1` | `reachRegisterR3` + enter password + tap CreateAccount → the three counts verbatim | structural: 3-step fill / behavioral: unchanged | Single `register()` with all fields |
| existing account | same single-screen fill → `registerCalls 1` + `errorAccountExists findsOne` + `SnackBar findsNothing` + `successes 0` | same 3-step fill → the four assertions verbatim | structural nav / behavioral: unchanged | Conflict still maps inline to identifier |

## 5. `login_otp_test.dart` (old 15 expects)

| Test | Old assertion | New assertion | Class | Why |
|---|---|---|---|---|
| helper `reachVerifyStep` | switcher + enter + `loginActionSendCode` | `reachCodeConfirm` (Step 1 enter + `loginStepUseCodeInstead` alt row) | structural | Switcher/presend CTA removed |
| send-code | `expect(repo.sendOtpCalls, 1)` + `otpSent isTrue` | unchanged | behavioral: unchanged | Same send call |
| send-code | `expect(find.text(t.loginActionVerifyCode), findsOneWidget)` + `AuthOtpField findsOne` + `AppBanner findsOne` | unchanged | behavioral: unchanged | Confirm step keeps all three |
| send-code | `expect(find.textContaining('Code sent to'), findsOneWidget)` | `textContaining('We sent a code to')` + `textContaining('••• ••• 567')` + `textContaining('501234567') findsNothing` | structural | Masked destination line is the new key (banner isolates → containing-match; raw number never rendered) |
| expired code | `setOtp` + Verify → `errorOtpExpired findsOne` | unchanged | behavioral: unchanged | Same distinct copy |
| expired code | `find.textContaining('Code sent to')` (banner still up, no error snackbar) | masked-destination containing assertions (new key) | structural | Same banner, new copy key |
| distinct copies | `errorOtpExpired != errorOtpInvalid` + invalid renders `errorOtpInvalid` not `errorOtpExpired` + banner | copy assertions verbatim; banner assertion migrated to the new key | behavioral: unchanged / structural (banner only) | Both copies kept |

## 6. `login_loading_test.dart` (old 9 expects)

| Test | Old assertion | New assertion | Class | Why |
|---|---|---|---|---|
| pending login | two-field fill + tap Continue → `authActionSigningIn findsOne` + spinner + `AppPillButton.isLoading` | two-step fill (`reachPasswordStep` + password + Continue) → the three busy assertions verbatim + ADD step-2 headline still present | structural nav / behavioral: unchanged | Busy label-swap + width-preserved spinner kept via `busyLabel` |
| pending login | gate completes → `successes 1` | unchanged | behavioral: unchanged | same |
| double-tap | two-field fill + tap Continue + tap busy label → `loginCalls 1` … → `loginCalls 1` | two-step fill + same double-tap → counts verbatim | structural nav / behavioral: unchanged | Guard lives in the same submit path |

## 7. `login_error_routing_test.dart` (old 23 expects)

| Test | Old assertion | New assertion | Class | Why |
|---|---|---|---|---|
| helper `submitValidCredentials` | `fields.at(0/1)` + tap Continue + pumps | Step 1 enter → Continue → Step 2 enter → Continue + pumps (same signature) | structural | Same valid pair, two steps |
| unknown identifier | `loginCalls 1` + `errorAccountNotFound findsOne` + `SnackBar findsNothing` | unchanged | behavioral: unchanged | Still inline on identifier (surfaced on Step 2) |
| password failure | `loginCalls 1` + `'wrong password' findsOne` + `SnackBar findsNothing` | unchanged | behavioral: unchanged | Still inline on password |
| invalid code | switcher + enter + SendCode + Verify CTA present → `setOtp` + Verify → `errorOtpInvalid` + `textContaining('Code sent to')` | `reachCodeConfirm` → same verify → `errorOtpInvalid` verbatim; banner → 3 destination expects (`textContaining('We sent a code to')` + masked tail + raw-number `findsNothing`, same pattern as otp tests; V1 review fix — was headline-only) | structural nav + banner / behavioral: unchanged | Code failures never snackbars |
| offline | `loginCalls 1` + `SnackBar findsOne` + `errorOfflineRetry` + `authActionRetry` + inline `AppInputField.error` all null | unchanged | behavioral: unchanged | Same snackbar + retry |
| server retry | `SnackBar` + `errorServerRetryRef` + Retry → tap Retry → `loginCalls 2` | unchanged | behavioral: unchanged | Retry resubmits the same call |

## 8. `forgot_password_test.dart` (old 31 expects)

Forgot keeps its CTA keys and validation timing; the recomposition is
`AuthShell` + `AppStepProgress` → `AppStepScaffold` steps with an isolated
`ForgotResendRow` (no ring — the forgot resend never had a ring assertion).

| Test | Old assertion | New assertion | Class | Why |
|---|---|---|---|---|
| empty identifier | tap SendRecoveryCode → `validationEnterIdentifier` + `forgotCalls 0` | unchanged + ADD `expect(find.text(t.forgotTitle), findsOneWidget)` | behavioral: unchanged / structural: added | Same Step-1 surface |
| invalid email | enter `abc` → `validationEnterValidEmailAddress` + `forgotCalls 0` | unchanged | behavioral: unchanged | same |
| short phone | enter `12` → `validationEnterValidMobile` + `forgotCalls 0` | unchanged | behavioral: unchanged | same |
| valid → reset | `forgotCalls 1` + `forgotFieldNewPassword findsWidgets` + `forgotFieldRecoveryCode findsOne` + `forgotActionUpdatePassword findsOne` + `AppBanner findsOne` + `textContaining('Recovery code sent to')` | unchanged (all keys reused) + ADD `expect(find.text(t.forgotResetTitle), findsOneWidget)` | behavioral: unchanged / structural: added | Same 3 stages as steps |
| short code + password | tap Update → both inline errors + `resetCalls 0` | unchanged | behavioral: unchanged | same |
| expired code | `EditableText.first` OTP + `TextField.first` password + Update → `resetCalls 1` + `errorOtpExpired` + `SnackBar findsNothing` | unchanged | behavioral: unchanged | Same combined submit |
| resend 30 s | `find.text(loginActionResendIn(30))` + `AppTextButton.onPressed isNull` | unchanged + ADD `expect(find.byType(ForgotResendRow), findsOneWidget)` + ADD `expect(find.byType(CircularProgressIndicator), findsNothing)` | behavioral: unchanged / structural: added | Isolated row, no spinner |
| done + CTA | `resetCalls 1` + `forgotDoneTitle` + tap `forgotBackToSignIn` → `backCalls 1` | unchanged (CTA text identical in the sticky bar) + ADD live-region `Semantics(label == forgotDoneTitle)` present | behavioral: unchanged / structural: added | Terminal confirmation kept |

## Counts (step flow)

- Old: 25 + 8 + 9 + 14 + 15 + 9 + 23 + 31 = **134 expects** across the 8 files.
- New: 35 + 10 + 10 + 16 + 22 + 9 + 23 + 39 = **164 expects** across the 8
  files (every file gained or held: loading 9→9 held, the rest grew with
  step-headline, zero-API-call and isolation pins; +3 from the V1 review fix).
- Gate met: the total assertion count did NOT go down (134 → 164), and
  nothing was deleted/weakened/loosened without an equal replacement through
  the new UI.

## 9. One-screen collapse (2026-10-20 superseding decision — password/supervisor)

Scope: the SAME 8 frozen characterization files + `login_step_flow_test.dart` +
`forgot_step_flow_test.dart` + `auth_redesign_test.dart` + the staff-local
`supervisor_login_test.dart`, migrated from the C16 step flow onto the
scoped one-screen rule (`docs/ui-redesign/briefs/phase-2-login.md`):
password login is ONE screen (identifier + password + Continue → the EXISTING
login call), code/register/forgot flows UNCHANGED, supervisor ONE screen.
New ARB keys: `loginTitle` / `loginSubtitle` (en+ar) ONLY for the one-screen
headline/supporting line; every validation/error key stays verbatim.
New/changed helpers (additive, old helpers kept): `fillLoginForm` = enter
identifier in field 0 + password in field 1 on the one-screen form (fires
ZERO API calls by itself — submit happens on Continue).
`reachCodeConfirm` / `reachRegisterR3` keep their signatures AND behavior:
the entry alt row moved from Step 1 to the one-screen form, the send/register
calls did not. `reachPasswordStep` (step-1→step-2 advance) is DELETED — no
such step exists anymore; its usages become `fillLoginForm` + Continue.
Conventions: `t` = `enAuthL10n()` (or `arAuthL10n()` where noted).

| Test | Old assertion | New assertion | Class | Why |
|---|---|---|---|---|
| validation/empty identifier | `loginStepIdentifierTitle findsOne` + Continue → `validationEnterIdentifier` + `loginCalls 0` + `sendOtpCalls 0` + `sendEmailOtpCalls 0` | `loginTitle findsOne` (new one-screen headline) + ADD `AppInputField findsNWidgets(2)` (both fields on one screen) + Continue → the four old assertions verbatim | structural: headline + both-fields pin / behavioral: unchanged | Same local validation, same zero-API Continue |
| validation/email-like, short phone | enter first field + Continue → mapped error + `loginCalls 0` | unchanged + ADD `sendOtpCalls 0` + `sendEmailOtpCalls 0` | behavioral: unchanged / structural: added | One-screen Continue fires no API of any kind on invalid input |
| validation/empty password | Step 1 enter email → Continue (advance, no error) → Step 2 Continue → `validationEnterIdentifier findsNothing` + `validationEnterPassword findsWidgets` + password-field error pin + `loginCalls 0` | Single screen: enter email in field 0 → tap Continue → `validationEnterIdentifier findsNothing` + `validationEnterPassword findsWidgets` + password-field error pin verbatim + `loginCalls 0` verbatim + ADD `sendOtpCalls 0` | structural: one tap, both fields validated together / behavioral: unchanged | Password validation now runs on the same submit as the identifier |
| validation/register rows, rtl | as in §1 | unchanged, except rtl ADDs `loginTitle` (ar) headline pin | behavioral: unchanged / structural: added | Register R1/R2/R3 + ar copy untouched |
| success/password | `reachPasswordStep` (advance, `loginCalls 0`) → enter password → Continue → `loginCalls 1` + `successes 1` | `fillLoginForm` (both fields, `loginCalls 0`) → Continue → `loginCalls 1` verbatim + `successes 1` verbatim + ADD `loginTitle` still present | structural: single-screen fill / behavioral: unchanged | Same single `loginWithPassword` call |
| success/OTP, resend (both), register (all), otp (all) | `reachCodeConfirm` / `reachRegisterR3` from Step 1 | unchanged (helpers keep signature + behavior; only the entry screen changed) | behavioral: unchanged | Code/register flows untouched by the collapse |
| loading/pending + double-tap | two-step fill (`reachPasswordStep` + password) + Continue → busy label + spinner + `isLoading` (+ `successes 1` / `loginCalls 1` twice) | `fillLoginForm` + Continue → the busy assertions verbatim + ADD one-screen `loginTitle` still present while busy | structural nav / behavioral: unchanged | Busy label-swap + width-preserved spinner kept via `busyLabel` |
| error-routing/submit helper | Step 1 enter → Continue → Step 2 enter → Continue + pumps | `fillLoginForm` + Continue + pumps (same signature `(tester, t)`) | structural | Same valid pair, one screen |
| error-routing/unknown + password failure | `loginCalls 1` + mapped copy + `SnackBar findsNothing` | unchanged (identifier/password failures now stay inline on the single screen — no step routing) | behavioral: unchanged | Same split, same surfaces |
| error-routing/invalid code, offline, server | `reachCodeConfirm` / two-step submit + mapped assertions | unchanged | behavioral: unchanged | Code + snackbar paths untouched |
| forgot (both files) | all stages as steps | unchanged | behavioral: unchanged | Forgot keeps its 3 stages + terminal confirmation |
| step-flow/zero-API advance (3 tests) | Step 1 Continue advances with ZERO API to the password step | REPLACED by one-screen submit pins: valid pair → `loginCalls 1` + `sendOtpCalls 0` + `sendEmailOtpCalls 0` + `successes 1`; invalid identifier → mapped error + all calls 0; empty form → both inline errors + all calls 0 | structural: submit replaces advance / behavioral: new (by design — the zero-API step is gone) | The superseding rule deletes the no-API step; Continue now IS the login call |
| step-flow/password back | back keeps identifier, forward keeps password | DELETED (no back on the single screen); replaced by `code back lands on the one-screen with values intact` (`loginStepCodeTitle` → back → `loginTitle` + identifier recap) | structural | Only code/register steps keep Back |
| step-flow/register back chain, resend ticks, register e2e, register-row visibility | step assertions | unchanged | behavioral: unchanged | Register + resend untouched |
| step-flow/per-app defaults | opens on `loginStepIdentifierTitle`, code alt row present | opens on `loginTitle` + BOTH field labels present + `AuthOtpField findsNothing` + alt row present | structural | Password-first default kept, both fields visible |
| step-flow/forgot-link callback | `reachPasswordStep` then tap forgot | tap `loginActionForgotPassword` directly on the one-screen (+ `forgotCalls 1`) | structural | Forgot link lives on the single screen |
| step-flow/headline semantics | header == `loginStepIdentifierTitle` + `loginStepProgress(1, 2)` | header == `loginTitle` + `loginStepProgress(1, 1)` | structural | Single screen is step 1 of 1 |
| step-flow/back 48dp + ar RTL back | password-step back target | code-step back target (same ≥48 dp + tooltip pins); ar: code back returns to the ar `loginTitle` screen | structural | Back survives only where a second step exists |
| step-flow/sticky CTA + 320/1.3x/ar/dark + split | step-1 walk | one-screen walk (empty Continue → `validationEnterIdentifier`; code via alt row; R1; split keeps brand panel + 480 column) | structural | Same U-law gates on the collapsed screen |
| redesign/composition step 1 | `loginStepIdentifierTitle` + single `AppInputField` + `AppTextButton findsNothing` | `loginTitle` + `AppInputField findsNWidgets(2)` + forgot `AppTextButton findsWidgets` (forgot link is on the single screen) + `AppOrDivider` + alt rows | structural | One screen carries both fields + the forgot link |
| redesign/password step | `reachPasswordStep` → password title + forgot + code row | MERGED into the composition test above (no second step to reach) | structural | Deleted navigation, kept pins |
| redesign/R3, code step, forgot stages, contrast, supervisor-copy | as built | unchanged, except the keys test grows to twenty (ADD `loginTitle` + `loginSubtitle` en+ar non-blank, ar distinct) | behavioral: unchanged / structural: added | New headline keys resolve everywhere the old step keys do |
| redesign/small screens | step-1 title + Continue → identifier error | `loginTitle` + Continue → identifier error + ADD password error (both validate together) on 320 px @ 1.3x | structural: added / behavioral: unchanged | Both fields validate on one submit |
| supervisor/structure (4 tests) | step 1 identifier-only + advance + recap + back | ONE screen: `AppStepScaffold` + `AuthShell findsNothing` + `AppInputField findsNWidgets(2)` + password label + forgot link + single CTA + NO back + `loginFieldPassword` visible immediately + `advisorIntakeWizardStepOf(1, 1)` semantics | structural | Same pattern as the shared one-screen |
| supervisor/transitions (2 tests) | step-1 advance (0 calls) → password submit → `loginCalls 1` + slot mapping + persisted session | `fillSupervisorForm` (both fields) → submit → `loginCalls 1` verbatim + slot mapping verbatim + persisted session verbatim | structural nav / behavioral: unchanged | Same `login()` call, same args |
| supervisor/back-preserves | back keeps values + refocuses identifier; forward keeps password | REPLACED by values-survive-failure (controllers untouched across a mapped failure) + focus-order pins (identifier `next` → password, password `done` submits) | structural / behavioral: new pins | No back exists; values still never cleared |
| supervisor/validation, mapped failures, busy, forgot route, compact RTL | step-2 submit + banner + retry + recap + step-2 forgot link | same assertions on the single screen (forgot link needs no advance; compact RTL drops the recap pin, keeps banner + both fields) | structural nav / behavioral: unchanged | Same `_login`, same mapped copy, same retry |
| NEW `login_one_screen_test.dart` | — | single-screen pins: one `AutofillGroup` holds username + password hints together; identifier `next` moves focus to password; password `done` submits; one Continue validates both fields with zero API; same notifier args (email→email slot, phone→normalized phone slot, password passthrough) + counts (`loginCalls 1`, `registerCalls 0`, `sendOtpCalls 0`) + same routing (`successes 1`); password tap count 1→1 | structural: new | Pins the superseding contract the characterization files cannot |

## Counts (one-screen)

- Step-flow totals carried in (`expect(` grep): 35 + 10 + 10 + 16 + 22 + 9 + 26 + 36 = **164**.
- One-screen (`expect(` grep): validation 38 + success-nav 12 + resend 10 + register 16 + otp 22 + loading 10 + error-routing 26 + forgot 36 = **170** across the 8 files (register/resend/otp/error-routing/forgot held verbatim; validation + success-nav + loading grew with both-fields + headline pins).
- Step-flow behavior files: `login_step_flow_test.dart` 102 → 109 (zero-API-advance + password-back rows replaced by one-screen submit + code-back rows; register/resend/motion rows held) and `forgot_step_flow_test.dart` 25 → 25 held verbatim.
- New: `login_one_screen_test.dart` (37 expects: single-screen contract pins above).
- `auth_redesign_test.dart` 73 → 76 (composition + keys + small-screen rows; contrast + forgot rows held).
- Staff-local `supervisor_login_test.dart` migrated structurally (same behavior calls/counts/routing, one-screen finders) + V1/V2 review fixes: restored `errorServerRetryRef` mapped-copy pin alongside the controller-persistence pins, and restored the long-identifier compact-RTL overflow case (77 → 79 expects).
- Gate met: 164 → 170 on the 8 files (plus 109 + 25 + 76 + 37 behavior/structure files), and nothing behavioral is weakened without an equal one-screen replacement.

Note: the masked-destination banner wraps its message in bidi isolates
(AppBanner grammar, same as the old 'Code sent to' banner), so the three OTP
assertions match with `textContaining('We sent a code to')` +
`textContaining('••• ••• 567')` plus the negative
`textContaining('501234567') findsNothing` (raw number never rendered).

## New step tests (new files, behavior-first)

`test/login_step_flow_test.dart` + `test/forgot_step_flow_test.dart` assert what
the characterization files cannot: Step 1 Continue fires ZERO API calls
(`loginCalls == 0`, `sendOtpCalls == 0`, `sendEmailOtpCalls == 0`,
`verifyOtpCalls == 0`, `verifyEmailOtpCalls == 0`, `registerCalls == 0`);
Back preserves typed values; errors land on the right step; resend countdown
ticks without rebuilding the step; register R1→R2→R3 ends in a single
`register()` carrying all fields; forgot identifier → reset → done; every app
is password-first with the code alt row present; motion/a11y (slide + fade via
`AppMotion`, static under reduced motion, header Semantics on the new
headline, `loginStepProgress` step-X-of-Y Semantics, 48 dp RTL-mirroring Back,
sticky CTA above the keyboard, 320 px + 1.3x + ar + dark overflow-free,
expanded 480 column with the brand panel only on split).
