// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'customer_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CustomerLocalizationsEn extends CustomerLocalizations {
  CustomerLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Orient Customer';

  @override
  String get loginAppName => 'Orient Customer App';

  @override
  String get loginAppPurpose =>
      'Book service, track your vehicle, review estimates, approve repairs, and view invoices.';

  @override
  String get loginIntendedUsers => 'For vehicle owners and service customers';

  @override
  String get authSecurityNotice =>
      'By signing in, you agree to the Orient Customer App Terms of Service and Privacy Policy.';
}
