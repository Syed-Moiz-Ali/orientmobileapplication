// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'owner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class OwnerLocalizationsEn extends OwnerLocalizations {
  OwnerLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Orient Owner';

  @override
  String get loginAppName => 'Orient Owner App';

  @override
  String get loginAppPurpose =>
      'Monitor branches, job cards, staff, revenue, approvals, inventory, and workshop performance.';

  @override
  String get loginIntendedUsers => 'For workshop owners and admins';

  @override
  String get authSecurityNotice =>
      'By signing in, you agree to the Orient Owner App Terms of Service and Privacy Policy.';
}
