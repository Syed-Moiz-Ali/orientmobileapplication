// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'crm_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CrmLocalizationsEn extends CrmLocalizations {
  CrmLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Orient CRM';

  @override
  String get loginAppName => 'Orient CRM App';

  @override
  String get loginAppPurpose =>
      'Manage customer follow-ups, service communication, leads, reminders, and support activity.';

  @override
  String get loginIntendedUsers => 'For CRM and customer support users';

  @override
  String get authSecurityNotice =>
      'By signing in, you agree to the Orient CRM App Terms of Service and Privacy Policy.';
}
