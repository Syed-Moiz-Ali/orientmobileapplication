import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'customer_localizations_ar.dart';
import 'customer_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CustomerLocalizations
/// returned by `CustomerLocalizations.of(context)`.
///
/// Applications need to include `CustomerLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/customer_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CustomerLocalizations.localizationsDelegates,
///   supportedLocales: CustomerLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the CustomerLocalizations.supportedLocales
/// property.
abstract class CustomerLocalizations {
  CustomerLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CustomerLocalizations? of(BuildContext context) {
    return Localizations.of<CustomerLocalizations>(
      context,
      CustomerLocalizations,
    );
  }

  static const LocalizationsDelegate<CustomerLocalizations> delegate =
      _CustomerLocalizationsDelegate();

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
  /// **'Orient Customer'**
  String get appTitle;

  /// App identity name shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'Orient Customer App'**
  String get loginAppName;

  /// App purpose shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'Book service, track your vehicle, review estimates, approve repairs, and view invoices.'**
  String get loginAppPurpose;

  /// Intended users shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'For vehicle owners and service customers'**
  String get loginIntendedUsers;

  /// App-specific legal notice under the shared auth form
  ///
  /// In en, this message translates to:
  /// **'By signing in, you agree to the Orient Customer App Terms of Service and Privacy Policy.'**
  String get authSecurityNotice;

  /// Bottom-nav: garage home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get garNavHome;

  /// Bottom-nav: history
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get garNavBookings;

  /// Bottom-nav: garage
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get garNavVehicles;

  /// Bottom-nav: account
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get garNavProfile;

  /// Shell brand title
  ///
  /// In en, this message translates to:
  /// **'Orient Auto Garage'**
  String get garBrand;

  /// Shell brand subtitle
  ///
  /// In en, this message translates to:
  /// **'Your car is in good hands'**
  String get garBrandSub;

  /// Returning greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get garHello;

  /// First-run greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome to Orient'**
  String get garWelcome;

  /// Garage manage action
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get garManage;

  /// Single-vehicle section
  ///
  /// In en, this message translates to:
  /// **'Your vehicle'**
  String get garTitleOne;

  /// Multi-vehicle section
  ///
  /// In en, this message translates to:
  /// **'Your garage'**
  String get garTitleMany;

  /// Welcome panel title
  ///
  /// In en, this message translates to:
  /// **'Your garage is empty'**
  String get garHeroEmpty;

  /// Welcome panel body
  ///
  /// In en, this message translates to:
  /// **'Add your vehicle to book service, follow repair progress, and keep every update in one place.'**
  String get garHeroEmptyBody;

  /// Welcome panel CTA
  ///
  /// In en, this message translates to:
  /// **'Add your vehicle'**
  String get garHeroAdd;

  /// Journey ribbon title
  ///
  /// In en, this message translates to:
  /// **'Active journey'**
  String get garJourneyTitle;

  /// Journey CTA
  ///
  /// In en, this message translates to:
  /// **'Track service'**
  String get garJourneyTrack;

  /// Journey secondary CTA
  ///
  /// In en, this message translates to:
  /// **'View booking'**
  String get garJourneyView;

  /// Journey empty note
  ///
  /// In en, this message translates to:
  /// **'No active journey right now.'**
  String get garJourneyEmpty;

  /// Quick actions title
  ///
  /// In en, this message translates to:
  /// **'How can we help?'**
  String get garActionsTitle;

  /// Book tile
  ///
  /// In en, this message translates to:
  /// **'Book service'**
  String get garActionBook;

  /// Book tile hint
  ///
  /// In en, this message translates to:
  /// **'Pick a time that suits you'**
  String get garActionBookHint;

  /// SOS tile
  ///
  /// In en, this message translates to:
  /// **'Breakdown help'**
  String get garActionSos;

  /// SOS tile hint
  ///
  /// In en, this message translates to:
  /// **'Help is on the way'**
  String get garActionSosHint;

  /// Invoices tile
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get garActionInvoices;

  /// Invoices tile hint
  ///
  /// In en, this message translates to:
  /// **'Receipts and bills'**
  String get garActionInvoicesHint;

  /// History tile
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get garActionHistory;

  /// History tile hint
  ///
  /// In en, this message translates to:
  /// **'Past visits'**
  String get garActionHistoryHint;

  /// Recent section
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get garRecentTitle;

  /// Load error title
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your information'**
  String get garLoadTitle;

  /// Load error body
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get garLoadBody;

  /// Load retry CTA
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get garRetry;

  /// See-all bookings
  ///
  /// In en, this message translates to:
  /// **'All bookings'**
  String get garRecentAll;

  /// Upcoming section
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get garUpcomingTitle;

  /// Bookings header
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bkTitle;

  /// Upcoming group
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get bkUpcoming;

  /// Live group
  ///
  /// In en, this message translates to:
  /// **'In service'**
  String get bkInService;

  /// History group
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get bkHistory;

  /// Bookings CTA
  ///
  /// In en, this message translates to:
  /// **'Book service'**
  String get bkBookCta;

  /// Empty title
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get bkEmptyTitle;

  /// Empty body
  ///
  /// In en, this message translates to:
  /// **'When you\'re ready, book a service and it will appear here.'**
  String get bkEmptyBody;

  /// No-vehicle empty title
  ///
  /// In en, this message translates to:
  /// **'No vehicle yet'**
  String get bkEmptyVehiclesTitle;

  /// No-vehicle empty body
  ///
  /// In en, this message translates to:
  /// **'Add your car first so the workshop knows what to service.'**
  String get bkEmptyVehiclesBody;

  /// Failed group title
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get bkFailedTitle;

  /// Retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get bkRetry;

  /// Remove confirm title
  ///
  /// In en, this message translates to:
  /// **'Remove saved booking?'**
  String get bkRemoveTitle;

  /// Remove confirm body
  ///
  /// In en, this message translates to:
  /// **'This removes the booking stored on this device. The workshop has not received it.'**
  String get bkRemoveBody;

  /// Remove confirm CTA
  ///
  /// In en, this message translates to:
  /// **'Remove booking'**
  String get bkRemoveCta;

  /// Remove cancel CTA
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get bkKeepCta;

  /// Retry failure toast
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send this booking. Please try again.'**
  String get bkSendFail;

  /// Load error title
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your bookings'**
  String get bkLoadFailTitle;

  /// Load error body
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get bkLoadFailBody;

  /// Load retry CTA
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get bkRetryCta;

  /// Subtitle count
  ///
  /// In en, this message translates to:
  /// **'1 upcoming'**
  String get bkUpOne;

  /// Subtitle count
  ///
  /// In en, this message translates to:
  /// **'{count} upcoming'**
  String bkUpMany(int count);

  /// Subtitle count
  ///
  /// In en, this message translates to:
  /// **'1 in service'**
  String get bkInOne;

  /// Subtitle count
  ///
  /// In en, this message translates to:
  /// **'{count} in service'**
  String bkInMany(int count);

  /// Subtitle count
  ///
  /// In en, this message translates to:
  /// **'1 past service'**
  String get bkPastOne;

  /// Subtitle count
  ///
  /// In en, this message translates to:
  /// **'{count} past services'**
  String bkPastMany(int count);

  /// Default subtitle
  ///
  /// In en, this message translates to:
  /// **'Your appointments and service history.'**
  String get bkSubDefault;

  /// Row review action
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get bkReview;

  /// Untitled fallback
  ///
  /// In en, this message translates to:
  /// **'Service appointment'**
  String get bkServiceAppt;

  /// Approval line
  ///
  /// In en, this message translates to:
  /// **'Approval needed before work continues'**
  String get bkApprovalMsg;

  /// Approval line with amount
  ///
  /// In en, this message translates to:
  /// **'Estimate {amount} awaiting approval'**
  String bkApprovalEst(String amount);

  /// Live pill
  ///
  /// In en, this message translates to:
  /// **'IN SERVICE'**
  String get jsInService;

  /// Untitled service fallback
  ///
  /// In en, this message translates to:
  /// **'Service in progress'**
  String get jsInProgress;

  /// Stage line
  ///
  /// In en, this message translates to:
  /// **'Current stage · {stage}'**
  String jsStage(String stage);

  /// ETA line
  ///
  /// In en, this message translates to:
  /// **'Estimated completion · {value}'**
  String jsEta(String value);

  /// Idle title
  ///
  /// In en, this message translates to:
  /// **'No active service'**
  String get jsNoService;

  /// Idle body, one vehicle
  ///
  /// In en, this message translates to:
  /// **'Your vehicle is not in the workshop right now.'**
  String get jsIdleOne;

  /// Idle body, many vehicles
  ///
  /// In en, this message translates to:
  /// **'Your vehicles are not in the workshop right now.'**
  String get jsIdleMany;

  /// Untitled booking fallback
  ///
  /// In en, this message translates to:
  /// **'Workshop booking'**
  String get jsWorkshopBooking;

  /// Vehicles header
  ///
  /// In en, this message translates to:
  /// **'My vehicles'**
  String get vhTitle;

  /// Zero subtitle
  ///
  /// In en, this message translates to:
  /// **'Registered vehicles appear here.'**
  String get vhCountNone;

  /// One subtitle
  ///
  /// In en, this message translates to:
  /// **'1 registered vehicle'**
  String get vhCountOne;

  /// Many subtitle
  ///
  /// In en, this message translates to:
  /// **'{count} registered vehicles'**
  String vhCountMany(int count);

  /// Add CTA
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get vhAdd;

  /// Empty title
  ///
  /// In en, this message translates to:
  /// **'No vehicles added yet'**
  String get vhEmptyTitle;

  /// Empty body
  ///
  /// In en, this message translates to:
  /// **'Add your first car to book service and keep every visit connected to the right vehicle.'**
  String get vhEmptyBody;

  /// Load error title
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your vehicles'**
  String get vhLoadFailTitle;

  /// Load error body
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get vhLoadFailBody;

  /// Row book action
  ///
  /// In en, this message translates to:
  /// **'Book service'**
  String get vhBook;

  /// Row edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get vhEdit;

  /// Row remove action
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get vhRemove;

  /// Remove title without name
  ///
  /// In en, this message translates to:
  /// **'Remove this vehicle?'**
  String get vhRemoveNoName;

  /// Remove confirm title
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String vhRemoveTitle(String name);

  /// Remove confirm body
  ///
  /// In en, this message translates to:
  /// **'{plate} will be removed from your vehicles.'**
  String vhRemoveBody(String plate);

  /// Remove body without plate
  ///
  /// In en, this message translates to:
  /// **'This vehicle will no longer appear in your vehicles.'**
  String get vhRemoveBodyNoPlate;

  /// Remove confirm CTA
  ///
  /// In en, this message translates to:
  /// **'Remove vehicle'**
  String get vhRemoveCta;

  /// Remove cancel CTA
  ///
  /// In en, this message translates to:
  /// **'Keep vehicle'**
  String get vhKeepCta;

  /// Removed toast
  ///
  /// In en, this message translates to:
  /// **'Vehicle removed.'**
  String get vhRemoved;

  /// Remove failure toast
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t remove this vehicle. Please try again.'**
  String get vhRemoveFail;

  /// Sync failure line
  ///
  /// In en, this message translates to:
  /// **'Vehicle couldn\'t finish saving.'**
  String get vhSyncFail;

  /// Recovery title
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t remove this vehicle.'**
  String get vhDeleteFailTitle;

  /// Recovery body
  ///
  /// In en, this message translates to:
  /// **'The vehicle is still in your workshop account.'**
  String get vhDeleteFailBody;

  /// Recovery CTA
  ///
  /// In en, this message translates to:
  /// **'Retry removal'**
  String get vhRetryRemoval;

  /// Recovery busy label
  ///
  /// In en, this message translates to:
  /// **'Retrying…'**
  String get vhRetrying;

  /// Track action
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get vhTrack;

  /// Generic retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get vhRetry;

  /// View action
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get vhView;

  /// Context pill
  ///
  /// In en, this message translates to:
  /// **'In the workshop now'**
  String get vhInService;

  /// Unnamed fallback
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vhFallbackName;

  /// Add title
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get avTitleAdd;

  /// Edit title
  ///
  /// In en, this message translates to:
  /// **'Edit vehicle'**
  String get avTitleEdit;

  /// Step 1
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get avStepPlate;

  /// Step 2
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get avStepVehicle;

  /// Step 3
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get avStepDetails;

  /// Step eyebrow
  ///
  /// In en, this message translates to:
  /// **'REGISTRATION'**
  String get avEyebrowReg;

  /// Step eyebrow
  ///
  /// In en, this message translates to:
  /// **'VEHICLE'**
  String get avEyebrowVeh;

  /// Step eyebrow
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get avEyebrowDet;

  /// Step 1 title
  ///
  /// In en, this message translates to:
  /// **'What is the plate?'**
  String get avPlateTitle;

  /// Step 1 body
  ///
  /// In en, this message translates to:
  /// **'The plate is how the workshop identifies your car.'**
  String get avPlateBody;

  /// Plate field
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get avPlateLabel;

  /// Plate hint
  ///
  /// In en, this message translates to:
  /// **'A 12345'**
  String get avPlateHint;

  /// Plate error
  ///
  /// In en, this message translates to:
  /// **'Enter the registration plate'**
  String get avPlateError;

  /// Step 2 title
  ///
  /// In en, this message translates to:
  /// **'Which car is it?'**
  String get avVehicleTitle;

  /// Step 2 body
  ///
  /// In en, this message translates to:
  /// **'The make is required to register it.'**
  String get avVehicleBody;

  /// Make field
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get avMakeLabel;

  /// Make hint
  ///
  /// In en, this message translates to:
  /// **'Toyota'**
  String get avMakeHint;

  /// Make error
  ///
  /// In en, this message translates to:
  /// **'Enter the make of your vehicle'**
  String get avMakeError;

  /// Model field
  ///
  /// In en, this message translates to:
  /// **'Model (optional)'**
  String get avModelLabel;

  /// Model hint
  ///
  /// In en, this message translates to:
  /// **'Land Cruiser'**
  String get avModelHint;

  /// Year field
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get avYearLabel;

  /// Year hint
  ///
  /// In en, this message translates to:
  /// **'2021'**
  String get avYearHint;

  /// Year error
  ///
  /// In en, this message translates to:
  /// **'Enter a year between 1950 and {max}'**
  String avYearError(int max);

  /// Step 3 title
  ///
  /// In en, this message translates to:
  /// **'Anything else?'**
  String get avDetailsTitle;

  /// Step 3 body
  ///
  /// In en, this message translates to:
  /// **'Optional — helps identify your car. Service dates stay untouched.'**
  String get avDetailsBody;

  /// VIN field
  ///
  /// In en, this message translates to:
  /// **'VIN (optional)'**
  String get avVinLabel;

  /// VIN hint
  ///
  /// In en, this message translates to:
  /// **'Chassis number'**
  String get avVinHint;

  /// VIN help
  ///
  /// In en, this message translates to:
  /// **'The workshop can read this from the car.'**
  String get avVinHelp;

  /// Colour field
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get avColorLabel;

  /// Colour hint
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get avColorHint;

  /// Mileage field
  ///
  /// In en, this message translates to:
  /// **'Mileage (optional)'**
  String get avMileageLabel;

  /// Mileage hint
  ///
  /// In en, this message translates to:
  /// **'48,200'**
  String get avMileageHint;

  /// Step next CTA
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get avNext;

  /// Step back CTA
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get avBack;

  /// Save CTA
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get avSaveAdd;

  /// Edit save CTA
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get avSaveEdit;

  /// Busy label
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get avSaving;

  /// Workshop-data note
  ///
  /// In en, this message translates to:
  /// **'Service dates already on record are left untouched here.'**
  String get avNoteKept;

  /// Fresh-record note
  ///
  /// In en, this message translates to:
  /// **'This screen never changes the service dates on record.'**
  String get avNoteFresh;

  /// Save fallback error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save this vehicle. Please try again.'**
  String get avSaveFailFallback;

  /// Save retry CTA
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get avRetryCta;

  /// Profile title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get pfTitle;

  /// Contact section
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get pfContact;

  /// Account section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get pfAccount;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get pfAbout;

  /// Session section
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get pfSession;

  /// Vehicles row
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get pfVehicles;

  /// Vehicles hint
  ///
  /// In en, this message translates to:
  /// **'Cars registered to your account'**
  String get pfVehiclesHint;

  /// Zero vehicles label
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get pfVehiclesNone;

  /// SOS row
  ///
  /// In en, this message translates to:
  /// **'Roadside assistance'**
  String get pfSos;

  /// SOS hint
  ///
  /// In en, this message translates to:
  /// **'Request help when your vehicle breaks down'**
  String get pfSosHint;

  /// Password row
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get pfPassword;

  /// Password hint
  ///
  /// In en, this message translates to:
  /// **'Verify with a one-time code, then set a new password'**
  String get pfPasswordHint;

  /// Licences row
  ///
  /// In en, this message translates to:
  /// **'Open source licences'**
  String get pfLicences;

  /// Licences hint
  ///
  /// In en, this message translates to:
  /// **'Software used by this app'**
  String get pfLicencesHint;

  /// Nameless fallback
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get pfAccountFallback;

  /// Email row
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get pfEmail;

  /// Phone row
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get pfPhone;

  /// Summary, no vehicles
  ///
  /// In en, this message translates to:
  /// **'No vehicles yet'**
  String get pfSumNone;

  /// Summary, one vehicle
  ///
  /// In en, this message translates to:
  /// **'1 vehicle'**
  String get pfSumOne;

  /// Summary, many vehicles
  ///
  /// In en, this message translates to:
  /// **'{count} vehicles'**
  String pfSumMany(int count);

  /// Summary live suffix
  ///
  /// In en, this message translates to:
  /// **'Service in progress'**
  String get pfSumLive;

  /// Retry CTA
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pfRetry;

  /// Load error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your account.'**
  String get pfLoadFail;

  /// Inbox title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get ntTitle;

  /// Bulk read CTA
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get ntMarkAll;

  /// All-read line
  ///
  /// In en, this message translates to:
  /// **'All read'**
  String get ntAllRead;

  /// Unread line
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String ntUnread(int count);

  /// Empty title
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get ntCaughtUp;

  /// Empty body
  ///
  /// In en, this message translates to:
  /// **'Updates about your bookings, estimates and service progress will appear here.'**
  String get ntCaughtUpBody;

  /// Semantics unread
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get ntUnreadWord;

  /// Semantics read
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get ntReadWord;

  /// Load error title
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your notifications.'**
  String get ntLoadTitle;

  /// Load error body
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get ntLoadBody;

  /// Bulk failure note
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t mark your notifications as read.'**
  String get ntMarkFail;

  /// Retry CTA
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get ntRetry;

  /// Inbox group
  ///
  /// In en, this message translates to:
  /// **'Service updates'**
  String get ntGroupService;

  /// Inbox group
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get ntGroupApprovals;

  /// Inbox group
  ///
  /// In en, this message translates to:
  /// **'Invoices & receipts'**
  String get ntGroupInvoices;

  /// Inbox group
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get ntGroupGeneral;

  /// Row category
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get ntTypeBooking;

  /// Row category
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get ntTypeApproval;

  /// Row category
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get ntTypeService;

  /// Row category
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get ntTypeInvoice;

  /// Row category
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get ntTypePayment;

  /// Row category
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get ntTypeBreakdown;

  /// Row category
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get ntTypeUpdate;
}

class _CustomerLocalizationsDelegate
    extends LocalizationsDelegate<CustomerLocalizations> {
  const _CustomerLocalizationsDelegate();

  @override
  Future<CustomerLocalizations> load(Locale locale) {
    return SynchronousFuture<CustomerLocalizations>(
      lookupCustomerLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_CustomerLocalizationsDelegate old) => false;
}

CustomerLocalizations lookupCustomerLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return CustomerLocalizationsAr();
    case 'en':
      return CustomerLocalizationsEn();
  }

  throw FlutterError(
    'CustomerLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
