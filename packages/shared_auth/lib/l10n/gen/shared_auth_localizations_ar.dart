// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'shared_auth_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SharedAuthLocalizationsAr extends SharedAuthLocalizations {
  SharedAuthLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get authBrandName => 'أورينت';

  @override
  String get authBrandSub => 'منظومة الورشة';

  @override
  String get authIdentityHeadline => 'منظومة إدارة ورش السيارات المتكاملة.';

  @override
  String get authIdentityBody =>
      'إدارة شاملة لاستقبال المركبات والفحص متعدد النقاط وبطاقات العمل الرقمية وتقديرات العملاء وشراء القطع.';

  @override
  String get authTrustRoles => 'وصول حسب الأدوار وسجل تدقيق متوافق';

  @override
  String get authTrustSync => 'مزامنة مشفّرة تعمل دون اتصال';

  @override
  String get authTrustBays => 'مُحسّن لمنصات الورش عالية الإنتاجية';

  @override
  String get authSecurityBadge =>
      'بتسجيل الدخول، فإنك توافق على شروط الخدمة وسياسة الخصوصية.';

  @override
  String get authRestoringSessionSemantics => 'جارٍ استعادة جلستك الآمنة';

  @override
  String get authRestoringSession => 'جارٍ استعادة جلستك';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authHidePassword => 'إخفاء كلمة المرور';

  @override
  String get authMethodPassword => 'كلمة المرور';

  @override
  String get authMethodCode => 'رمز لمرة واحدة';

  @override
  String get authRecoveryStepIdentify => 'تأكيد الحساب';

  @override
  String get authRecoveryStepReset => 'كلمة مرور جديدة';

  @override
  String get loginWelcomeTitle => 'مرحباً بعودتك';

  @override
  String get loginWelcomeSubtitle =>
      'سجّل الدخول بالبريد الإلكتروني أو رقم الجوال.';

  @override
  String get loginSecurityCodeTitle => 'رمز الأمان';

  @override
  String get loginSecurityCodeSubtitle =>
      'احصل على رمز لمرة واحدة على بريدك أو جوالك.';

  @override
  String get loginOtpSentSubtitle =>
      'أدخل الرمز المكوّن من 6 أرقام الذي أرسلناه إليك.';

  @override
  String get loginRegisterTitle => 'أنشئ حسابك';

  @override
  String get loginRegisterSubtitle => 'أنشئ حسابك في أقل من دقيقة.';

  @override
  String get loginFieldIdentifier => 'البريد الإلكتروني أو رقم الجوال';

  @override
  String get loginFieldIdentifierHint => 'name@company.com أو 501234567';

  @override
  String get loginFieldPassword => 'كلمة المرور';

  @override
  String get loginFieldPasswordHint => 'أدخل كلمة المرور';

  @override
  String get loginFieldVerificationCode => 'رمز التحقق';

  @override
  String get loginFieldFullName => 'الاسم الكامل';

  @override
  String get loginFieldFullNameHint => 'اسمك الكامل';

  @override
  String get loginFieldCreatePassword => 'أنشئ كلمة مرور';

  @override
  String get loginFieldCreatePasswordHint => '6 أحرف على الأقل';

  @override
  String get loginMinCharacters => 'الحد الأدنى 6 أحرف';

  @override
  String get loginActionContinue => 'متابعة';

  @override
  String get loginActionSendCode => 'إرسال الرمز';

  @override
  String get loginActionVerifyCode => 'تحقق من الرمز';

  @override
  String get loginActionForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginActionChangeIdentifier => 'تغيير البريد أو الجوال';

  @override
  String get loginActionResendCode => 'إعادة إرسال الرمز';

  @override
  String loginActionResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'إعادة الإرسال خلال $seconds ثانية',
      one: 'إعادة الإرسال خلال ثانية واحدة',
    );
    return '$_temp0';
  }

  @override
  String get loginActionCreateAccount => 'إنشاء الحساب';

  @override
  String get loginNewCustomer => 'عميل جديد؟ أنشئ حساباً';

  @override
  String get loginAlreadyHaveAccount => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String loginCodeSent(String target) {
    return 'أُرسل الرمز إلى $target.';
  }

  @override
  String get forgotTitle => 'نسيت كلمة المرور؟';

  @override
  String get forgotSubtitle =>
      'أدخل البريد الإلكتروني أو رقم الجوال المرتبط بحسابك وسنرسل إليك رمز الاستعادة.';

  @override
  String get forgotResetTitle => 'اختر كلمة مرور جديدة';

  @override
  String get forgotResetSubtitle => 'أدخل الرمز وعيّن كلمة مرور جديدة.';

  @override
  String get forgotDoneTitle => 'تم تحديث كلمة المرور';

  @override
  String get forgotDoneSubtitle => 'سجّل الدخول بكلمة المرور الجديدة للمتابعة.';

  @override
  String get forgotSignIn => 'تسجيل الدخول';

  @override
  String get forgotFieldRecoveryCode => 'رمز الاستعادة';

  @override
  String get forgotFieldNewPassword => 'كلمة المرور الجديدة';

  @override
  String get forgotFieldNewPasswordHint => 'أدخل كلمة مرور جديدة';

  @override
  String get forgotActionSendRecoveryCode => 'إرسال رمز الاستعادة';

  @override
  String get forgotActionUpdatePassword => 'تحديث كلمة المرور';

  @override
  String forgotCodeSent(String target) {
    return 'أُرسل رمز الاستعادة إلى $target.';
  }

  @override
  String get forgotBackToSignIn => 'العودة لتسجيل الدخول';

  @override
  String get forgotContactSupport =>
      'لا يمكنك الوصول لهذا البريد أو الرقم؟ تواصل مع فريق دعم الورشة.';

  @override
  String get forgotAtLeast6Characters => '6 أحرف على الأقل';

  @override
  String get validationEnterValidPhone => 'أدخل رقم جوال صالح';

  @override
  String get validationEnter6Otp => 'أدخل رمز التحقق المكوّن من 6 أرقام';

  @override
  String get validationEnterValidEmail => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get validationEnterPassword => 'أدخل كلمة المرور';

  @override
  String get validationEnterName => 'أدخل اسمك';

  @override
  String get validationPassword6Chars =>
      'يجب أن تكون كلمة المرور 6 أحرف أو أكثر';

  @override
  String get validationEnterIdentifier => 'أدخل بريدك الإلكتروني أو رقم جوالك.';

  @override
  String get validationEnterValidEmailAddress =>
      'أدخل عنوان بريد إلكتروني صالح.';

  @override
  String get validationEnterValidMobile => 'أدخل رقم جوال صالح.';

  @override
  String get validationEnter6DigitRecovery =>
      'أدخل رمز الاستعادة المكوّن من 6 أرقام.';

  @override
  String get validationUseAtLeast6 => 'استخدم 6 أحرف على الأقل.';

  @override
  String get errorUnreachable =>
      'تعذّر الوصول إلى أورينت. تحقق من اتصالك وحاول مجدداً.';

  @override
  String get errorServerGeneric => 'حدث خطأ من جهتنا. حاول مرة أخرى.';

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';
}
