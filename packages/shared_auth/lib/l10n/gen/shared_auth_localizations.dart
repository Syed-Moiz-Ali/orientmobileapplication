import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'shared_auth_localizations_ar.dart';
import 'shared_auth_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SharedAuthLocalizations
/// returned by `SharedAuthLocalizations.of(context)`.
///
/// Applications need to include `SharedAuthLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/shared_auth_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SharedAuthLocalizations.localizationsDelegates,
///   supportedLocales: SharedAuthLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the SharedAuthLocalizations.supportedLocales
/// property.
abstract class SharedAuthLocalizations {
  SharedAuthLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SharedAuthLocalizations? of(BuildContext context) {
    return Localizations.of<SharedAuthLocalizations>(
      context,
      SharedAuthLocalizations,
    );
  }

  static const LocalizationsDelegate<SharedAuthLocalizations> delegate =
      _SharedAuthLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Brand wordmark shown in the auth shell
  ///
  /// In en, this message translates to:
  /// **'ORIENT'**
  String get authBrandName;

  /// Brand sub-wordmark shown under the mark
  ///
  /// In en, this message translates to:
  /// **'WORKSHOP SUITE'**
  String get authBrandSub;

  /// Identity panel headline on desktop auth
  ///
  /// In en, this message translates to:
  /// **'Automotive Garage ERP & Workshop Suite.'**
  String get authIdentityHeadline;

  /// Identity panel supporting paragraph
  ///
  /// In en, this message translates to:
  /// **'End-to-end management for vehicle check-in, multi-point inspections, digital job cards, customer estimates, and parts procurement.'**
  String get authIdentityBody;

  /// Identity panel trust point: roles
  ///
  /// In en, this message translates to:
  /// **'Role-based access & audit compliance'**
  String get authTrustRoles;

  /// Identity panel trust point: sync
  ///
  /// In en, this message translates to:
  /// **'Encrypted telemetry & offline sync'**
  String get authTrustSync;

  /// Identity panel trust point: performance
  ///
  /// In en, this message translates to:
  /// **'Optimized for high-throughput workshop bays'**
  String get authTrustBays;

  /// Overline above the identity panel headline
  ///
  /// In en, this message translates to:
  /// **'Secure sign-in'**
  String get authEyebrow;

  /// Platform status line on the identity panel
  ///
  /// In en, this message translates to:
  /// **'All systems operational'**
  String get authStatusOk;

  /// Generic legal text under the auth form; apps may override with their own localized security notice
  ///
  /// In en, this message translates to:
  /// **'By signing in, you agree to the Terms of Service and Privacy Policy.'**
  String get authSecurityBadge;

  /// Screen-reader label for the session restore screen
  ///
  /// In en, this message translates to:
  /// **'Restoring your secure session'**
  String get authRestoringSessionSemantics;

  /// Visible label on the session restore screen
  ///
  /// In en, this message translates to:
  /// **'Restoring your session'**
  String get authRestoringSession;

  /// Tooltip of the password visibility toggle (reveal)
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Tooltip of the password visibility toggle (hide)
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Segmented sign-in method label for password sign-in
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authMethodPassword;

  /// Segmented sign-in method label for one-time code sign-in
  ///
  /// In en, this message translates to:
  /// **'One-time code'**
  String get authMethodCode;

  /// Recovery step-progress label for the identifier step
  ///
  /// In en, this message translates to:
  /// **'Verify account'**
  String get authRecoveryStepIdentify;

  /// Recovery step-progress label for the reset step
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authRecoveryStepReset;

  /// Sign-in title
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeTitle;

  /// Sign-in supporting text
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email or mobile number.'**
  String get loginWelcomeSubtitle;

  /// One-time code method title
  ///
  /// In en, this message translates to:
  /// **'Security code'**
  String get loginSecurityCodeTitle;

  /// One-time code method supporting text (before send)
  ///
  /// In en, this message translates to:
  /// **'Get a one-time code on your email or mobile.'**
  String get loginSecurityCodeSubtitle;

  /// One-time code method supporting text (after send)
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent you.'**
  String get loginOtpSentSubtitle;

  /// Registration title
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get loginRegisterTitle;

  /// Registration supporting text
  ///
  /// In en, this message translates to:
  /// **'Set up your account in under a minute.'**
  String get loginRegisterSubtitle;

  /// Label of the email/mobile identifier field
  ///
  /// In en, this message translates to:
  /// **'Email or mobile number'**
  String get loginFieldIdentifier;

  /// Hint for the identifier field
  ///
  /// In en, this message translates to:
  /// **'name@company.com or 501234567'**
  String get loginFieldIdentifierHint;

  /// Label of the password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginFieldPassword;

  /// Hint for the password field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginFieldPasswordHint;

  /// Label of the OTP field
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get loginFieldVerificationCode;

  /// Label of the registration full-name field
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get loginFieldFullName;

  /// Hint for the full-name field
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get loginFieldFullNameHint;

  /// Label of the registration password field
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get loginFieldCreatePassword;

  /// Hint for the registration password field
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get loginFieldCreatePasswordHint;

  /// Inline rule hint beside the registration password field
  ///
  /// In en, this message translates to:
  /// **'Min. 6 characters'**
  String get loginMinCharacters;

  /// Primary sign-in action
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get loginActionContinue;

  /// Send one-time code action
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get loginActionSendCode;

  /// Verify one-time code action
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get loginActionVerifyCode;

  /// Link to password recovery
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginActionForgotPassword;

  /// Change the identifier while entering the code
  ///
  /// In en, this message translates to:
  /// **'Change email or mobile'**
  String get loginActionChangeIdentifier;

  /// Resend the one-time code
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get loginActionResendCode;

  /// Resend countdown with ICU plural on the remaining seconds
  ///
  /// In en, this message translates to:
  /// **'{seconds, plural, =1{Resend in 1 second} other{Resend in {seconds} seconds}}'**
  String loginActionResendIn(int seconds);

  /// Registration submit action
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get loginActionCreateAccount;

  /// Link that opens registration
  ///
  /// In en, this message translates to:
  /// **'New customer? Create an account'**
  String get loginNewCustomer;

  /// Link back to sign-in from registration
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get loginAlreadyHaveAccount;

  /// Confirmation that a code was sent
  ///
  /// In en, this message translates to:
  /// **'Code sent to {target}.'**
  String loginCodeSent(String target);

  /// Step 1 headline of the sign-in step flow
  ///
  /// In en, this message translates to:
  /// **'Log in or sign up'**
  String get loginStepIdentifierTitle;

  /// Step 1 supporting line of the sign-in step flow
  ///
  /// In en, this message translates to:
  /// **'Enter your email or mobile number to continue.'**
  String get loginStepIdentifierSubtitle;

  /// Password step headline of the sign-in step flow
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginStepPasswordTitle;

  /// Password step supporting line with the identifier recap
  ///
  /// In en, this message translates to:
  /// **'Enter your password for {identifier}.'**
  String loginStepPasswordSubtitle(String identifier);

  /// Code-confirm step headline of the sign-in step flow
  ///
  /// In en, this message translates to:
  /// **'Confirm your number'**
  String get loginStepCodeTitle;

  /// Code-confirm step supporting line
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent you.'**
  String get loginStepCodeSubtitle;

  /// Masked destination line on the code-confirm step
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {target}.'**
  String loginStepCodeDestination(String target);

  /// Register R1 headline
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get loginStepRegisterNameTitle;

  /// Register R1 supporting line
  ///
  /// In en, this message translates to:
  /// **'Tell us how to address you.'**
  String get loginStepRegisterNameSubtitle;

  /// Register R2 headline
  ///
  /// In en, this message translates to:
  /// **'How should we contact you?'**
  String get loginStepRegisterContactTitle;

  /// Register R2 supporting line
  ///
  /// In en, this message translates to:
  /// **'Enter your email or mobile number.'**
  String get loginStepRegisterContactSubtitle;

  /// Register R3 headline
  ///
  /// In en, this message translates to:
  /// **'Create your password'**
  String get loginStepRegisterPasswordTitle;

  /// Register R3 supporting line
  ///
  /// In en, this message translates to:
  /// **'Choose a password with at least 6 characters.'**
  String get loginStepRegisterPasswordSubtitle;

  /// Alt row from the password step to the code flow
  ///
  /// In en, this message translates to:
  /// **'Send me a code instead'**
  String get loginStepUseCodeInstead;

  /// Alt row from the code step back to the password step
  ///
  /// In en, this message translates to:
  /// **'Use password instead'**
  String get loginStepUsePasswordInstead;

  /// Alt row from step 1 into the register flow
  ///
  /// In en, this message translates to:
  /// **'New here? Create account'**
  String get loginStepCreateAccountRow;

  /// Divider label between the primary CTA and alternative auth paths
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get loginStepOr;

  /// Screen-reader label for the step-flow back arrow
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get loginStepBack;

  /// Accessible progress label for the step flow
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String loginStepProgress(int step, int total);

  /// Recovery identifier step title
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotTitle;

  /// Recovery identifier step supporting text
  ///
  /// In en, this message translates to:
  /// **'Enter the email address or mobile number linked to your account and we will send you a recovery code.'**
  String get forgotSubtitle;

  /// Recovery reset step title
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get forgotResetTitle;

  /// Recovery reset step supporting text
  ///
  /// In en, this message translates to:
  /// **'Enter the code and set a new password.'**
  String get forgotResetSubtitle;

  /// Recovery success title
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get forgotDoneTitle;

  /// Recovery success supporting text
  ///
  /// In en, this message translates to:
  /// **'Sign in with your new password to continue.'**
  String get forgotDoneSubtitle;

  /// Back-to-sign-in action on recovery
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get forgotSignIn;

  /// Label of the recovery code field
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get forgotFieldRecoveryCode;

  /// Label of the new password field
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get forgotFieldNewPassword;

  /// Hint of the new password field
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get forgotFieldNewPasswordHint;

  /// Send the recovery code action
  ///
  /// In en, this message translates to:
  /// **'Send recovery code'**
  String get forgotActionSendRecoveryCode;

  /// Submit the new password action
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get forgotActionUpdatePassword;

  /// Confirmation the recovery code was sent
  ///
  /// In en, this message translates to:
  /// **'Recovery code sent to {target}.'**
  String forgotCodeSent(String target);

  /// Return to sign-in after recovery
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get forgotBackToSignIn;

  /// Support hint on the recovery identifier step
  ///
  /// In en, this message translates to:
  /// **'Can\'t access this email or mobile number? Contact your workshop support team.'**
  String get forgotContactSupport;

  /// Live password rule on recovery reset
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get forgotAtLeast6Characters;

  /// Validation: invalid phone
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validationEnterValidPhone;

  /// Validation: incomplete OTP
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get validationEnter6Otp;

  /// Validation: invalid email
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationEnterValidEmail;

  /// Validation: missing password
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get validationEnterPassword;

  /// Validation: missing name
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get validationEnterName;

  /// Validation: short registration password
  ///
  /// In en, this message translates to:
  /// **'Password must be 6+ chars'**
  String get validationPassword6Chars;

  /// Recovery validation: missing identifier
  ///
  /// In en, this message translates to:
  /// **'Enter your email or mobile number.'**
  String get validationEnterIdentifier;

  /// Recovery validation: invalid email
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationEnterValidEmailAddress;

  /// Recovery validation: invalid mobile
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number.'**
  String get validationEnterValidMobile;

  /// Recovery validation: incomplete code
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit recovery code.'**
  String get validationEnter6DigitRecovery;

  /// Recovery validation: short password
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters.'**
  String get validationUseAtLeast6;

  /// Transport-level failure copy
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach Orient. Check your connection and try again.'**
  String get errorUnreachable;

  /// Unknown server failure copy
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again.'**
  String get errorServerGeneric;

  /// Empty/unknown failure copy
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Title of the session-expired notice
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get authSessionExpiredTitle;

  /// Body of the session-expired notice
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again to continue.'**
  String get authSessionExpiredMessage;

  /// Re-authenticate action on the session-expired notice
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get authSessionExpiredAction;

  /// Screen-reader label of the password-strength meter
  ///
  /// In en, this message translates to:
  /// **'Password strength'**
  String get authPasswordStrengthLabel;

  /// Password strength level: weak
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get authPasswordStrengthWeak;

  /// Password strength level: fair
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get authPasswordStrengthFair;

  /// Password strength level: good
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get authPasswordStrengthGood;

  /// Password strength level: strong
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get authPasswordStrengthStrong;

  /// Retry action on authentication error notices
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get authActionRetry;

  /// Busy label while a one-time code is being sent
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get authActionSending;

  /// Busy label while a one-time code is being verified
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get authActionVerifying;

  /// Busy label while password sign-in is running
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get authActionSigningIn;

  /// Busy label while the new password is being saved
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get authActionUpdating;

  /// Busy label while registration is running
  ///
  /// In en, this message translates to:
  /// **'Creating account…'**
  String get authActionCreating;

  /// Offline failure copy with a retry action
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Check your connection and try again.'**
  String get errorOfflineRetry;

  /// Authentication failure copy for invalid credentials (401 on sign-in)
  ///
  /// In en, this message translates to:
  /// **'Incorrect details. Check your email or mobile number and password, then try again.'**
  String get errorInvalidCredentials;

  /// Registration conflict copy (409)
  ///
  /// In en, this message translates to:
  /// **'An account already exists for these details. Try signing in instead.'**
  String get errorAccountExists;

  /// Lookup failure copy (404)
  ///
  /// In en, this message translates to:
  /// **'No account was found for these details. Check the email or mobile number.'**
  String get errorAccountNotFound;

  /// One-time-code expired copy, distinct from an incorrect code
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Request a new code and try again.'**
  String get errorOtpExpired;

  /// One-time-code incorrect copy, distinct from an expired code
  ///
  /// In en, this message translates to:
  /// **'This code is incorrect. Check the 6 digits and try again.'**
  String get errorOtpInvalid;

  /// Server failure copy with retry and a support reference
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Try again — if it keeps happening, contact workshop support (ref 500).'**
  String get errorServerRetryRef;

  /// Per-country phone format hint under phone-like identifier fields
  ///
  /// In en, this message translates to:
  /// **'Enter {digits} digits for {code}'**
  String loginPhoneFormatHint(int digits, String code);

  /// Fallback title of the supervisor sign-in screen (staff copy missing)
  ///
  /// In en, this message translates to:
  /// **'Supervisor access'**
  String get supervisorLoginTitle;

  /// Fallback supporting text of the supervisor sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage bookings, assignments, QC, and workshop operations.'**
  String get supervisorLoginSubtitle;

  /// Fallback app identity name shown on the supervisor auth shell
  ///
  /// In en, this message translates to:
  /// **'Orient Supervisor Console'**
  String get supervisorAppName;

  /// Fallback app purpose shown on the supervisor auth shell
  ///
  /// In en, this message translates to:
  /// **'Review incoming bookings, assign advisors and technicians, monitor jobs, and complete quality checks.'**
  String get supervisorAppPurpose;

  /// Fallback intended users shown on the supervisor auth shell
  ///
  /// In en, this message translates to:
  /// **'For workshop supervisors'**
  String get supervisorIntendedUsers;

  /// Fallback label of the supervisor username field
  ///
  /// In en, this message translates to:
  /// **'Username or email'**
  String get supervisorUsernameLabel;

  /// Fallback hint of the supervisor username field
  ///
  /// In en, this message translates to:
  /// **'Enter your username or email'**
  String get supervisorUsernameHint;

  /// Fallback validation when supervisor credentials are empty
  ///
  /// In en, this message translates to:
  /// **'Enter username and password'**
  String get supervisorEnterCredentials;
}

class _SharedAuthLocalizationsDelegate
    extends LocalizationsDelegate<SharedAuthLocalizations> {
  const _SharedAuthLocalizationsDelegate();

  @override
  Future<SharedAuthLocalizations> load(Locale locale) {
    return SynchronousFuture<SharedAuthLocalizations>(
      lookupSharedAuthLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SharedAuthLocalizationsDelegate old) => false;
}

SharedAuthLocalizations lookupSharedAuthLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SharedAuthLocalizationsAr();
    case 'en':
      return SharedAuthLocalizationsEn();
  }

  throw FlutterError(
    'SharedAuthLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
