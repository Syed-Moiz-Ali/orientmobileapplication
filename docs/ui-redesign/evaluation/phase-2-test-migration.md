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

## Counts

- Old: 25 + 8 + 9 + 14 + 15 + 9 + 23 + 31 = **134 expects** across the 8 files.
- New: 35 + 10 + 10 + 16 + 22 + 9 + 23 + 39 = **164 expects** across the 8
  files (every file gained or held: loading 9→9 held, the rest grew with
  step-headline, zero-API-call and isolation pins; +3 from the V1 review fix).
- Gate met: the total assertion count did NOT go down (134 → 164), and
  nothing was deleted/weakened/loosened without an equal replacement through
  the new UI.

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
