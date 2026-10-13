import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'shared_core_localizations_ar.dart';
import 'shared_core_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SharedCoreLocalizations
/// returned by `SharedCoreLocalizations.of(context)`.
///
/// Applications need to include `SharedCoreLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/shared_core_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SharedCoreLocalizations.localizationsDelegates,
///   supportedLocales: SharedCoreLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the SharedCoreLocalizations.supportedLocales
/// property.
abstract class SharedCoreLocalizations {
  SharedCoreLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SharedCoreLocalizations? of(BuildContext context) {
    return Localizations.of<SharedCoreLocalizations>(
      context,
      SharedCoreLocalizations,
    );
  }

  static const LocalizationsDelegate<SharedCoreLocalizations> delegate =
      _SharedCoreLocalizationsDelegate();

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

  /// Generic retry action for error states
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Generic cancel action in dialogs and forms
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic close action
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Generic back navigation label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Default title of the error/empty error state
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonErrorTitle;

  /// Default hint text of the shared search field
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearchHint;

  /// Tooltip of the clear button in the shared search field
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get commonClearSearch;

  /// Language section/row label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get commonLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get commonEnglish;

  /// Arabic language option (always shown in Arabic)
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get commonArabic;

  /// Title of the language picker sheet
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get commonSelectLanguage;

  /// Tooltip of the shared top bar back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get topBarBackTooltip;

  /// Tooltip of the notification bell
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// Tooltip of the close button on shared sheets/dialogs
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogCloseTooltip;

  /// Shared offline banner visible copy
  ///
  /// In en, this message translates to:
  /// **'Offline mode — changes will sync when connection is restored'**
  String get offlineBannerMessage;

  /// Screen-reader label for the shared offline banner
  ///
  /// In en, this message translates to:
  /// **'Offline mode. Changes will sync when connection is restored.'**
  String get offlineBannerSemantics;

  /// Sign-out confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get logoutDialogTitle;

  /// Sign-out confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'You will need to authenticate again to access this workspace.'**
  String get logoutDialogMessage;

  /// Sign-out confirmation action
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logoutDialogConfirm;

  /// Sign-out dialog title when local changes are pending sync
  ///
  /// In en, this message translates to:
  /// **'Unsynced changes'**
  String get logoutUnsyncedTitle;

  /// Sign-out dialog body when local changes are pending sync
  ///
  /// In en, this message translates to:
  /// **'Some local changes have not reached the workshop yet. Signing out now will clear those pending changes.'**
  String get logoutUnsyncedMessage;

  /// Sign-out action when local changes are pending sync
  ///
  /// In en, this message translates to:
  /// **'Sign out anyway'**
  String get logoutUnsyncedConfirm;

  /// Application exit confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Exit Orient Workshop?'**
  String get exitDialogTitle;

  /// Application exit confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'Your current work is saved. Close the application now?'**
  String get exitDialogMessage;

  /// Application exit confirmation action
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitDialogConfirm;

  /// Greeting prefix shown above the user name in the customer top bar
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get profileWelcomeBack;

  /// Sign-out row label in the shared profile sheet
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// Default hint of the shared date selector shell
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get dateSelectorHint;

  /// Default label of the shared media upload shell
  ///
  /// In en, this message translates to:
  /// **'Click to upload inspection photos or documents'**
  String get mediaUploadLabel;

  /// Default helper of the shared media upload shell
  ///
  /// In en, this message translates to:
  /// **'Supports JPG, PNG, PDF up to 25MB'**
  String get mediaUploadHelper;

  /// Retry label for a failed status surface
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get statusPillRetry;

  /// Status: pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Status: confirmed
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// Status: vehicle received
  ///
  /// In en, this message translates to:
  /// **'Vehicle Received'**
  String get statusVehicleReceived;

  /// Status: approved
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// Status: work assigned
  ///
  /// In en, this message translates to:
  /// **'Work Assigned'**
  String get statusWorkAssigned;

  /// Status: in service
  ///
  /// In en, this message translates to:
  /// **'In Service'**
  String get statusInService;

  /// Status: in progress
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// Status: delivered
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// Status: completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Status: cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Status: approval required
  ///
  /// In en, this message translates to:
  /// **'Approval Required'**
  String get statusApprovalRequired;

  /// Status: waiting parts
  ///
  /// In en, this message translates to:
  /// **'Waiting Parts'**
  String get statusWaitingParts;

  /// Status: sent back
  ///
  /// In en, this message translates to:
  /// **'Sent Back'**
  String get statusSentBack;

  /// Status: resolved
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// Status: invoice paid in full
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// Status: partially paid
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get statusPartiallyPaid;

  /// Status: overdue
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// Status: unpaid
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// Relative time: just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get formatterJustNow;

  /// Relative time: minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String formatterMinutesAgo(int count);

  /// Relative time: hours ago
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String formatterHoursAgo(int count);

  /// Relative time: days ago
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String formatterDaysAgo(int count);

  /// Relative time: weeks ago
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String formatterWeeksAgo(int count);

  /// Relative time: months ago
  ///
  /// In en, this message translates to:
  /// **'{count}mo ago'**
  String formatterMonthsAgo(int count);

  /// Relative time: years ago
  ///
  /// In en, this message translates to:
  /// **'{count}y ago'**
  String formatterYearsAgo(int count);

  /// Undo action in a snackbar after an optimistic change
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// Screen-reader label for a busy/loading control
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get commonLoading;

  /// Screen-reader label for the increment control of a quantity stepper
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get commonIncrease;

  /// Screen-reader label for the decrement control of a quantity stepper
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get commonDecrease;

  /// Default title of a shared selection sheet
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// Empty-results state of a searchable selection sheet or search field
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get commonNoResults;

  /// Tooltip of the reveal-password toggle on an obscured text field
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get commonShowPassword;

  /// Tooltip of the hide-password toggle on an obscured text field
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get commonHidePassword;

  /// Screen-reader label for a tappable user avatar
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get userAvatarOpenProfile;

  /// Pending-sync chip: a local change has not reached the server yet
  ///
  /// In en, this message translates to:
  /// **'Not sent yet'**
  String get pendingSyncNotSent;

  /// Pending-sync chip: a local change is queued for sync
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get pendingSyncQueued;

  /// Pending-sync chip: a local change failed to sync
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get pendingSyncFailed;

  /// Pending-sync chip: a local change has been synchronized
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get pendingSyncSynced;

  /// Marker for a non-required form field (spec §12)
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// Default title of an empty chart/analytics placeholder
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get commonNoData;

  /// Default body copy of an empty chart placeholder
  ///
  /// In en, this message translates to:
  /// **'No chart data available for this period'**
  String get chartEmptyMessage;

  /// Label of the navigation overflow destination (bottom bar More slot / overflow sheet title)
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get commonMore;

  /// Screen-reader label for a navigation destination with a numeric activity badge
  ///
  /// In en, this message translates to:
  /// **'{label}, {count} new'**
  String navBadgeCount(String label, int count);

  /// Screen-reader label for a navigation destination with an unread dot badge
  ///
  /// In en, this message translates to:
  /// **'{label}, new activity'**
  String navBadgeDot(String label);
}

class _SharedCoreLocalizationsDelegate
    extends LocalizationsDelegate<SharedCoreLocalizations> {
  const _SharedCoreLocalizationsDelegate();

  @override
  Future<SharedCoreLocalizations> load(Locale locale) {
    return SynchronousFuture<SharedCoreLocalizations>(
      lookupSharedCoreLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SharedCoreLocalizationsDelegate old) => false;
}

SharedCoreLocalizations lookupSharedCoreLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SharedCoreLocalizationsAr();
    case 'en':
      return SharedCoreLocalizationsEn();
  }

  throw FlutterError(
    'SharedCoreLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
