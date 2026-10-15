// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'shared_auth_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SharedAuthLocalizationsEn extends SharedAuthLocalizations {
  SharedAuthLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authBrandName => 'ORIENT';

  @override
  String get authBrandSub => 'WORKSHOP SUITE';

  @override
  String get authIdentityHeadline => 'Automotive Garage ERP & Workshop Suite.';

  @override
  String get authIdentityBody =>
      'End-to-end management for vehicle check-in, multi-point inspections, digital job cards, customer estimates, and parts procurement.';

  @override
  String get authTrustRoles => 'Role-based access & audit compliance';

  @override
  String get authTrustSync => 'Encrypted telemetry & offline sync';

  @override
  String get authTrustBays => 'Optimized for high-throughput workshop bays';

  @override
  String get authEyebrow => 'Secure sign-in';

  @override
  String get authStatusOk => 'All systems operational';

  @override
  String get authSecurityBadge =>
      'By signing in, you agree to the Terms of Service and Privacy Policy.';

  @override
  String get authRestoringSessionSemantics => 'Restoring your secure session';

  @override
  String get authRestoringSession => 'Restoring your session';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authMethodPassword => 'Password';

  @override
  String get authMethodCode => 'One-time code';

  @override
  String get authRecoveryStepIdentify => 'Verify account';

  @override
  String get authRecoveryStepReset => 'New password';

  @override
  String get loginWelcomeTitle => 'Welcome back';

  @override
  String get loginWelcomeSubtitle =>
      'Sign in with your email or mobile number.';

  @override
  String get loginSecurityCodeTitle => 'Security code';

  @override
  String get loginSecurityCodeSubtitle =>
      'Get a one-time code on your email or mobile.';

  @override
  String get loginOtpSentSubtitle => 'Enter the 6-digit code we sent you.';

  @override
  String get loginRegisterTitle => 'Create your account';

  @override
  String get loginRegisterSubtitle => 'Set up your account in under a minute.';

  @override
  String get loginFieldIdentifier => 'Email or mobile number';

  @override
  String get loginFieldIdentifierHint => 'name@company.com or 501234567';

  @override
  String get loginFieldPassword => 'Password';

  @override
  String get loginFieldPasswordHint => 'Enter your password';

  @override
  String get loginFieldVerificationCode => 'Verification code';

  @override
  String get loginFieldFullName => 'Full name';

  @override
  String get loginFieldFullNameHint => 'Your full name';

  @override
  String get loginFieldCreatePassword => 'Create a password';

  @override
  String get loginFieldCreatePasswordHint => 'At least 6 characters';

  @override
  String get loginMinCharacters => 'Min. 6 characters';

  @override
  String get loginActionContinue => 'Continue';

  @override
  String get loginActionSendCode => 'Send code';

  @override
  String get loginActionVerifyCode => 'Verify code';

  @override
  String get loginActionForgotPassword => 'Forgot password?';

  @override
  String get loginActionChangeIdentifier => 'Change email or mobile';

  @override
  String get loginActionResendCode => 'Resend code';

  @override
  String loginActionResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Resend in $seconds seconds',
      one: 'Resend in 1 second',
    );
    return '$_temp0';
  }

  @override
  String get loginActionCreateAccount => 'Create account';

  @override
  String get loginNewCustomer => 'New customer? Create an account';

  @override
  String get loginAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String loginCodeSent(String target) {
    return 'Code sent to $target.';
  }

  @override
  String get forgotTitle => 'Forgot your password?';

  @override
  String get forgotSubtitle =>
      'Enter the email address or mobile number linked to your account and we will send you a recovery code.';

  @override
  String get forgotResetTitle => 'Choose a new password';

  @override
  String get forgotResetSubtitle => 'Enter the code and set a new password.';

  @override
  String get forgotDoneTitle => 'Password updated';

  @override
  String get forgotDoneSubtitle =>
      'Sign in with your new password to continue.';

  @override
  String get forgotSignIn => 'Sign in';

  @override
  String get forgotFieldRecoveryCode => 'Recovery code';

  @override
  String get forgotFieldNewPassword => 'New password';

  @override
  String get forgotFieldNewPasswordHint => 'Enter a new password';

  @override
  String get forgotActionSendRecoveryCode => 'Send recovery code';

  @override
  String get forgotActionUpdatePassword => 'Update password';

  @override
  String forgotCodeSent(String target) {
    return 'Recovery code sent to $target.';
  }

  @override
  String get forgotBackToSignIn => 'Back to sign in';

  @override
  String get forgotContactSupport =>
      'Can\'t access this email or mobile number? Contact your workshop support team.';

  @override
  String get forgotAtLeast6Characters => 'At least 6 characters';

  @override
  String get validationEnterValidPhone => 'Enter a valid phone number';

  @override
  String get validationEnter6Otp => 'Enter 6-digit OTP';

  @override
  String get validationEnterValidEmail => 'Enter a valid email';

  @override
  String get validationEnterPassword => 'Enter your password';

  @override
  String get validationEnterName => 'Enter your name';

  @override
  String get validationPassword6Chars => 'Password must be 6+ chars';

  @override
  String get validationEnterIdentifier => 'Enter your email or mobile number.';

  @override
  String get validationEnterValidEmailAddress => 'Enter a valid email address.';

  @override
  String get validationEnterValidMobile => 'Enter a valid mobile number.';

  @override
  String get validationEnter6DigitRecovery =>
      'Enter the 6-digit recovery code.';

  @override
  String get validationUseAtLeast6 => 'Use at least 6 characters.';

  @override
  String get errorUnreachable =>
      'We couldn\'t reach Orient. Check your connection and try again.';

  @override
  String get errorServerGeneric =>
      'Something went wrong on our side. Please try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get authSessionExpiredTitle => 'Session expired';

  @override
  String get authSessionExpiredMessage =>
      'Your session has expired. Sign in again to continue.';

  @override
  String get authSessionExpiredAction => 'Sign in again';

  @override
  String get authPasswordStrengthLabel => 'Password strength';

  @override
  String get authPasswordStrengthWeak => 'Weak';

  @override
  String get authPasswordStrengthFair => 'Fair';

  @override
  String get authPasswordStrengthGood => 'Good';

  @override
  String get authPasswordStrengthStrong => 'Strong';

  @override
  String get authActionRetry => 'Try again';

  @override
  String get authActionSending => 'Sending…';

  @override
  String get authActionVerifying => 'Verifying…';

  @override
  String get authActionSigningIn => 'Signing in…';

  @override
  String get authActionUpdating => 'Updating…';

  @override
  String get authActionCreating => 'Creating account…';

  @override
  String get errorOfflineRetry =>
      'You\'re offline. Check your connection and try again.';

  @override
  String get errorInvalidCredentials =>
      'Incorrect details. Check your email or mobile number and password, then try again.';

  @override
  String get errorAccountExists =>
      'An account already exists for these details. Try signing in instead.';

  @override
  String get errorAccountNotFound =>
      'No account was found for these details. Check the email or mobile number.';

  @override
  String get errorOtpExpired =>
      'This code has expired. Request a new code and try again.';

  @override
  String get errorOtpInvalid =>
      'This code is incorrect. Check the 6 digits and try again.';

  @override
  String get errorServerRetryRef =>
      'Something went wrong on our side. Try again — if it keeps happening, contact workshop support (ref 500).';

  @override
  String loginPhoneFormatHint(int digits, String code) {
    return 'Enter $digits digits for $code';
  }
}
