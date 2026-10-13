import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'owner_localizations_ar.dart';
import 'owner_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of OwnerLocalizations
/// returned by `OwnerLocalizations.of(context)`.
///
/// Applications need to include `OwnerLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/owner_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: OwnerLocalizations.localizationsDelegates,
///   supportedLocales: OwnerLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the OwnerLocalizations.supportedLocales
/// property.
abstract class OwnerLocalizations {
  OwnerLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static OwnerLocalizations? of(BuildContext context) {
    return Localizations.of<OwnerLocalizations>(context, OwnerLocalizations);
  }

  static const LocalizationsDelegate<OwnerLocalizations> delegate =
      _OwnerLocalizationsDelegate();

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

  /// Application title shown by the OS task switcher
  ///
  /// In en, this message translates to:
  /// **'Orient Owner'**
  String get appTitle;

  /// App identity name shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'Orient Owner App'**
  String get loginAppName;

  /// App purpose shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'Monitor branches, job cards, staff, revenue, approvals, inventory, and workshop performance.'**
  String get loginAppPurpose;

  /// Intended users shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'For workshop owners and admins'**
  String get loginIntendedUsers;

  /// App-specific legal notice under the shared auth form
  ///
  /// In en, this message translates to:
  /// **'By signing in, you agree to the Orient Owner App Terms of Service and Privacy Policy.'**
  String get authSecurityNotice;
}

class _OwnerLocalizationsDelegate
    extends LocalizationsDelegate<OwnerLocalizations> {
  const _OwnerLocalizationsDelegate();

  @override
  Future<OwnerLocalizations> load(Locale locale) {
    return SynchronousFuture<OwnerLocalizations>(
      lookupOwnerLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_OwnerLocalizationsDelegate old) => false;
}

OwnerLocalizations lookupOwnerLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return OwnerLocalizationsAr();
    case 'en':
      return OwnerLocalizationsEn();
  }

  throw FlutterError(
    'OwnerLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
