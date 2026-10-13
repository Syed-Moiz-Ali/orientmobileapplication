// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'customer_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class CustomerLocalizationsAr extends CustomerLocalizations {
  CustomerLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أورينت — العملاء';

  @override
  String get loginAppName => 'تطبيق أورينت — العملاء';

  @override
  String get loginAppPurpose =>
      'احجز الخدمة وتابع مركبتك وراجع التقديرات ووافق على الإصلاحات واطّلع على الفواتير.';

  @override
  String get loginIntendedUsers => 'لمالكي المركبات وعملاء الخدمة';

  @override
  String get authSecurityNotice =>
      'بتسجيل الدخول، فإنك توافق على شروط خدمة تطبيق أورينت — العملاء وسياسة الخصوصية.';
}
