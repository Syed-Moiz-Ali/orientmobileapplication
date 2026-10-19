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

  /// Wizard app bar title
  ///
  /// In en, this message translates to:
  /// **'Book a service'**
  String get wizTitle;

  /// Wizard step 1
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get wizStepVehicle;

  /// Wizard step 2
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get wizStepPackage;

  /// Wizard step 3
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get wizStepSlot;

  /// Wizard step 4
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get wizStepDropoff;

  /// Wizard step 1 title
  ///
  /// In en, this message translates to:
  /// **'Which car is coming in?'**
  String get wizVehicleTitle;

  /// Wizard step 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Pick the registered vehicle the workshop will receive.'**
  String get wizVehicleSub;

  /// Wizard empty garage
  ///
  /// In en, this message translates to:
  /// **'No vehicle yet'**
  String get wizGarageEmptyTitle;

  /// Wizard empty garage body
  ///
  /// In en, this message translates to:
  /// **'A booking needs a registered vehicle. Add yours in under a minute.'**
  String get wizGarageEmptyBody;

  /// Wizard quick-add CTA
  ///
  /// In en, this message translates to:
  /// **'Add your vehicle'**
  String get wizAddVehicle;

  /// Wizard step 2 title
  ///
  /// In en, this message translates to:
  /// **'What does it need?'**
  String get wizPackageTitle;

  /// Wizard step 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Pick one or more services. Prices are upfront, in dirhams.'**
  String get wizPackageSub;

  /// Catalogue load error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the services.'**
  String get wizServicesLoadFail;

  /// Catalogue retry
  ///
  /// In en, this message translates to:
  /// **'Retry services'**
  String get wizRetryServices;

  /// Empty catalogue
  ///
  /// In en, this message translates to:
  /// **'No services right now'**
  String get wizNoServicesTitle;

  /// Empty catalogue body
  ///
  /// In en, this message translates to:
  /// **'The workshop catalogue is empty. Try again in a little while.'**
  String get wizNoServicesBody;

  /// Wizard step 3 title
  ///
  /// In en, this message translates to:
  /// **'When suits you?'**
  String get wizSlotTitle;

  /// Wizard step 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Days and times come straight from the workshop diary.'**
  String get wizSlotSub;

  /// Day picker label
  ///
  /// In en, this message translates to:
  /// **'Choose a day'**
  String get wizChooseDate;

  /// Slot list header
  ///
  /// In en, this message translates to:
  /// **'Available times'**
  String get wizTimesFor;

  /// No date picked hint
  ///
  /// In en, this message translates to:
  /// **'Choose a day above to see its times.'**
  String get wizNoDateBody;

  /// Slots load error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the available times.'**
  String get wizSlotsLoadFail;

  /// Slots retry
  ///
  /// In en, this message translates to:
  /// **'Retry times'**
  String get wizRetryTimes;

  /// Empty slots
  ///
  /// In en, this message translates to:
  /// **'No times left on this day'**
  String get wizNoTimesTitle;

  /// Empty slots body
  ///
  /// In en, this message translates to:
  /// **'Try another day — new slots open as the diary moves.'**
  String get wizNoTimesBody;

  /// AM slot group
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get wizMorning;

  /// PM slot group
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get wizAfternoon;

  /// Wizard step 4 title
  ///
  /// In en, this message translates to:
  /// **'How does it reach us?'**
  String get wizDropTitle;

  /// Wizard step 4 subtitle
  ///
  /// In en, this message translates to:
  /// **'Drop it off yourself, or let our driver collect it.'**
  String get wizDropSub;

  /// Drop-off option
  ///
  /// In en, this message translates to:
  /// **'Self drop-off'**
  String get wizSelfTitle;

  /// Drop-off option body
  ///
  /// In en, this message translates to:
  /// **'Bring the car to the workshop at your slot.'**
  String get wizSelfBody;

  /// Valet option
  ///
  /// In en, this message translates to:
  /// **'Valet pick-up'**
  String get wizValetTitle;

  /// Valet option body
  ///
  /// In en, this message translates to:
  /// **'Our driver collects it and returns it after the work.'**
  String get wizValetBody;

  /// Valet address label
  ///
  /// In en, this message translates to:
  /// **'Pick-up address'**
  String get wizAddressLabel;

  /// Valet address hint
  ///
  /// In en, this message translates to:
  /// **'Street, building, landmark'**
  String get wizAddressHint;

  /// Valet address validation
  ///
  /// In en, this message translates to:
  /// **'Add a pick-up address so the driver can find you.'**
  String get wizAddressRequired;

  /// Notes label
  ///
  /// In en, this message translates to:
  /// **'Notes for the workshop'**
  String get wizNotesLabel;

  /// Notes hint
  ///
  /// In en, this message translates to:
  /// **'Optional — e.g. noise when braking'**
  String get wizNotesHint;

  /// Step 1 inline validation
  ///
  /// In en, this message translates to:
  /// **'Pick a vehicle to continue.'**
  String get wizNeedVehicle;

  /// Step 2 inline validation
  ///
  /// In en, this message translates to:
  /// **'Pick at least one service to continue.'**
  String get wizNeedPackage;

  /// Step 3 inline validation
  ///
  /// In en, this message translates to:
  /// **'Pick a day and a time to continue.'**
  String get wizNeedSlot;

  /// Running summary title
  ///
  /// In en, this message translates to:
  /// **'Your booking'**
  String get wizSummaryTitle;

  /// Empty summary
  ///
  /// In en, this message translates to:
  /// **'Nothing picked yet — your choices appear here.'**
  String get wizSummaryEmpty;

  /// Summary vehicle row
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get wizRowVehicle;

  /// Summary services row
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get wizRowServices;

  /// Summary slot row
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get wizRowSlot;

  /// Dock total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get wizTotal;

  /// Unpriced total fallback
  ///
  /// In en, this message translates to:
  /// **'Confirmed at the workshop'**
  String get wizTotalPending;

  /// Dock trust line
  ///
  /// In en, this message translates to:
  /// **'Free re-check within 7 days'**
  String get wizTrust;

  /// Dock continue CTA
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get wizContinue;

  /// Step back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get wizBack;

  /// Dock confirm CTA
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get wizConfirm;

  /// Dock busy label
  ///
  /// In en, this message translates to:
  /// **'Booking…'**
  String get wizBooking;

  /// Summary change link
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get wizChange;

  /// Submit error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t create this booking. Please try again.'**
  String get wizSubmitFail;

  /// Vehicle retry action
  ///
  /// In en, this message translates to:
  /// **'Retry vehicle sync'**
  String get wizRetrySync;

  /// Submit retry action
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get wizTryAgain;

  /// Detail app bar title
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bkdTitle;

  /// Pass card title
  ///
  /// In en, this message translates to:
  /// **'Workshop pass'**
  String get bkdPassTitle;

  /// Pass card hint
  ///
  /// In en, this message translates to:
  /// **'Show this at arrival'**
  String get bkdPassHint;

  /// Calendar action
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get bkdAddCalendar;

  /// Calendar failure
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open the calendar.'**
  String get bkdCalendarFail;

  /// Approval banner
  ///
  /// In en, this message translates to:
  /// **'Approval needed before work continues'**
  String get bkdApprovalTitle;

  /// Detail service row
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get bkdServiceLabel;

  /// Detail vehicle row
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get bkdVehicleLabel;

  /// Detail appointment row
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get bkdApptLabel;

  /// History date row
  ///
  /// In en, this message translates to:
  /// **'Service date'**
  String get bkdDateLabel;

  /// Reference row
  ///
  /// In en, this message translates to:
  /// **'Booking reference'**
  String get bkdRefLabel;

  /// Confirmed note
  ///
  /// In en, this message translates to:
  /// **'Your car is booked in. We will take it from here once you arrive.'**
  String get bkdConfirmedNote;

  /// Requested note
  ///
  /// In en, this message translates to:
  /// **'The workshop has your request and will confirm the slot shortly.'**
  String get bkdRequestedNote;

  /// Track action
  ///
  /// In en, this message translates to:
  /// **'Track service'**
  String get bkdTrack;

  /// Estimate action
  ///
  /// In en, this message translates to:
  /// **'Review estimate'**
  String get bkdReviewEstimate;

  /// Cancel dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel booking?'**
  String get bkdCancelTitle;

  /// Cancel dialog body
  ///
  /// In en, this message translates to:
  /// **'The workshop will be told straight away.'**
  String get bkdCancelBody;

  /// Cancel confirm
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get bkdCancelCta;

  /// Cancel dismiss
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get bkdKeepCta;

  /// Cancel busy
  ///
  /// In en, this message translates to:
  /// **'Cancelling…'**
  String get bkdCancelling;

  /// Cancel success
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled.'**
  String get bkdCancelled;

  /// Cancel error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t cancel this booking. Please try again.'**
  String get bkdCancelFail;

  /// Cancel retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get bkdRetry;

  /// Success title online
  ///
  /// In en, this message translates to:
  /// **'Booking requested'**
  String get bksRequested;

  /// Success title offline
  ///
  /// In en, this message translates to:
  /// **'Booking saved'**
  String get bksSaved;

  /// Success subtitle online
  ///
  /// In en, this message translates to:
  /// **'The workshop will confirm your slot shortly.'**
  String get bksRequestedSub;

  /// Success subtitle offline
  ///
  /// In en, this message translates to:
  /// **'It will reach the workshop when you are back online.'**
  String get bksSavedSub;

  /// Success reference row
  ///
  /// In en, this message translates to:
  /// **'Booking reference'**
  String get bksRefLabel;

  /// Success status row
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get bksStatusLabel;

  /// Queued status pill
  ///
  /// In en, this message translates to:
  /// **'Not sent yet'**
  String get bksNotSent;

  /// Success service row
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get bksServiceLabel;

  /// Success vehicle row
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get bksVehicleLabel;

  /// Success appointment row
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get bksApptLabel;

  /// Queued panel title
  ///
  /// In en, this message translates to:
  /// **'Stored on this device'**
  String get bksQueuedTitle;

  /// Queued panel body
  ///
  /// In en, this message translates to:
  /// **'It will be sent automatically when connection is back.'**
  String get bksQueuedBody;

  /// Pending panel body
  ///
  /// In en, this message translates to:
  /// **'Your appointment is not confirmed yet. The workshop will confirm the slot.'**
  String get bksPendingBody;

  /// Pending panel title
  ///
  /// In en, this message translates to:
  /// **'Not confirmed yet'**
  String get bksPendingTitle;

  /// Next steps title
  ///
  /// In en, this message translates to:
  /// **'What happens next'**
  String get bksNextTitle;

  /// Next step 1
  ///
  /// In en, this message translates to:
  /// **'The workshop confirms your slot.'**
  String get bksNextOne;

  /// Next step 2
  ///
  /// In en, this message translates to:
  /// **'Drop off the car — or wait for the valet.'**
  String get bksNextTwo;

  /// Next step 3
  ///
  /// In en, this message translates to:
  /// **'Track every stage from Bookings.'**
  String get bksNextThree;

  /// Success Done CTA
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get bksDone;

  /// Success secondary link
  ///
  /// In en, this message translates to:
  /// **'View booking'**
  String get bksViewBooking;

  /// Success fallback link
  ///
  /// In en, this message translates to:
  /// **'View bookings'**
  String get bksViewBookings;

  /// SOS app bar title
  ///
  /// In en, this message translates to:
  /// **'Roadside assistance'**
  String get sosTitle;

  /// SOS subtitle
  ///
  /// In en, this message translates to:
  /// **'Help is one tap away, day or night.'**
  String get sosSub;

  /// SOS vehicle section
  ///
  /// In en, this message translates to:
  /// **'Which vehicle needs help?'**
  String get sosVehicleTitle;

  /// SOS location section
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get sosLocationTitle;

  /// SOS location hint
  ///
  /// In en, this message translates to:
  /// **'Enter your current location or landmark'**
  String get sosLocationHint;

  /// SOS location help
  ///
  /// In en, this message translates to:
  /// **'Type an address, exit or nearby landmark.'**
  String get sosLocationHelp;

  /// SOS location validation
  ///
  /// In en, this message translates to:
  /// **'Add where the vehicle is so the workshop can find you.'**
  String get sosLocationRequired;

  /// SOS issue section
  ///
  /// In en, this message translates to:
  /// **'What\'s wrong?'**
  String get sosIssueTitle;

  /// SOS detail hint
  ///
  /// In en, this message translates to:
  /// **'Anything the driver should know (optional)'**
  String get sosDetailHint;

  /// SOS issue validation
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s wrong so the workshop can help.'**
  String get sosIssueRequired;

  /// SOS symptom
  ///
  /// In en, this message translates to:
  /// **'Flat tyre'**
  String get sosTyre;

  /// SOS symptom
  ///
  /// In en, this message translates to:
  /// **'Won\'t start'**
  String get sosNoStart;

  /// SOS symptom
  ///
  /// In en, this message translates to:
  /// **'Dead battery'**
  String get sosBattery;

  /// SOS symptom
  ///
  /// In en, this message translates to:
  /// **'Overheating'**
  String get sosOverheat;

  /// SOS symptom
  ///
  /// In en, this message translates to:
  /// **'Brake problem'**
  String get sosBrake;

  /// SOS symptom
  ///
  /// In en, this message translates to:
  /// **'Warning light'**
  String get sosWarning;

  /// SOS symptom
  ///
  /// In en, this message translates to:
  /// **'Accident damage'**
  String get sosAccident;

  /// SOS symptom
  ///
  /// In en, this message translates to:
  /// **'Locked out'**
  String get sosLockout;

  /// SOS symptom
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get sosOther;

  /// SOS hotline CTA
  ///
  /// In en, this message translates to:
  /// **'Call the workshop'**
  String get sosCallWorkshop;

  /// SOS submit CTA
  ///
  /// In en, this message translates to:
  /// **'Request assistance'**
  String get sosSend;

  /// SOS busy label
  ///
  /// In en, this message translates to:
  /// **'Sending request…'**
  String get sosSending;

  /// SOS retry
  ///
  /// In en, this message translates to:
  /// **'Retry sending'**
  String get sosRetry;

  /// SOS retry busy
  ///
  /// In en, this message translates to:
  /// **'Retrying…'**
  String get sosRetrying;

  /// SOS remove
  ///
  /// In en, this message translates to:
  /// **'Remove request'**
  String get sosRemove;

  /// SOS remove dismiss
  ///
  /// In en, this message translates to:
  /// **'Keep request'**
  String get sosKeep;

  /// SOS remove dialog
  ///
  /// In en, this message translates to:
  /// **'Remove saved request?'**
  String get sosRemoveTitle;

  /// SOS remove dialog body
  ///
  /// In en, this message translates to:
  /// **'This removes the copy stored on this device. The workshop has not received it.'**
  String get sosRemoveBody;

  /// SOS queued panel
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get sosSavedTitle;

  /// SOS queued panel body
  ///
  /// In en, this message translates to:
  /// **'It hasn\'t been sent yet. Retry when you are back online.'**
  String get sosSavedBody;

  /// SOS dialer failure
  ///
  /// In en, this message translates to:
  /// **'Unable to open the phone dialer.'**
  String get sosDialFail;

  /// SOS result sent
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get sosSent;

  /// SOS result saved
  ///
  /// In en, this message translates to:
  /// **'Request saved'**
  String get sosSaved;

  /// SOS result sent body
  ///
  /// In en, this message translates to:
  /// **'The workshop has received your request.'**
  String get sosSentBody;

  /// SOS reference row
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get sosRef;

  /// SOS details section
  ///
  /// In en, this message translates to:
  /// **'What you asked for'**
  String get sosDetails;

  /// SOS result Done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get sosDone;

  /// SOS next steps
  ///
  /// In en, this message translates to:
  /// **'What happens next'**
  String get sosWhatNext;

  /// SOS next sent 1
  ///
  /// In en, this message translates to:
  /// **'The workshop calls you to confirm dispatch.'**
  String get sosNextSentOne;

  /// SOS next sent 2
  ///
  /// In en, this message translates to:
  /// **'Stay with the vehicle and keep your phone on.'**
  String get sosNextSentTwo;

  /// SOS next saved 1
  ///
  /// In en, this message translates to:
  /// **'Your request is stored on this device.'**
  String get sosNextSavedOne;

  /// SOS next saved 2
  ///
  /// In en, this message translates to:
  /// **'Retry sending once you are back online.'**
  String get sosNextSavedTwo;

  /// SOS indeterminate ETA
  ///
  /// In en, this message translates to:
  /// **'Waiting for the workshop'**
  String get sosWaitingTitle;

  /// SOS indeterminate ETA body
  ///
  /// In en, this message translates to:
  /// **'The workshop confirms dispatch by phone — there is no live arrival time yet.'**
  String get sosWaitingBody;

  /// Detail service action banner
  ///
  /// In en, this message translates to:
  /// **'Action required'**
  String get bkdActionRequired;

  /// Detail service stage label
  ///
  /// In en, this message translates to:
  /// **'Current stage'**
  String get bkdCurrentStage;

  /// Detail unnamed stage fallback
  ///
  /// In en, this message translates to:
  /// **'Service in progress'**
  String get bkdInProgress;

  /// Detail live ETA line
  ///
  /// In en, this message translates to:
  /// **'Estimated completion · {eta}'**
  String bkdEstCompletion(String eta);

  /// Detail progress semantics
  ///
  /// In en, this message translates to:
  /// **'Service progress, {progress} percent'**
  String bkdProgressLabel(int progress);

  /// Detail unnamed vehicle fallback
  ///
  /// In en, this message translates to:
  /// **'Your vehicle'**
  String get bkdYourVehicle;

  /// SOS sending panel
  ///
  /// In en, this message translates to:
  /// **'Sending your request…'**
  String get sosSendingNote;

  /// SOS recovery singular
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send your roadside request'**
  String get sosRecoveryOne;

  /// SOS recovery plural
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send your roadside requests'**
  String get sosRecoveryMany;

  /// SOS recovery body singular
  ///
  /// In en, this message translates to:
  /// **'It\'s saved on this device, but the workshop has not received it. Try sending it again, or call the workshop if you need help now.'**
  String get sosRecoveryBodyOne;

  /// SOS recovery body plural
  ///
  /// In en, this message translates to:
  /// **'They are saved on this device, but the workshop has not received them. Try again, or call the workshop if you need help now.'**
  String get sosRecoveryBodyMany;

  /// SOS saved count
  ///
  /// In en, this message translates to:
  /// **'{count} saved requests'**
  String sosSavedCount(int count);

  /// SOS retry success
  ///
  /// In en, this message translates to:
  /// **'Your saved request was sent to the workshop.'**
  String get sosRetryDone;

  /// SOS retry failure
  ///
  /// In en, this message translates to:
  /// **'We still couldn\'t send your request. The workshop has not received it.'**
  String get sosRetryFail;

  /// SOS remove notice
  ///
  /// In en, this message translates to:
  /// **'Saved request removed.'**
  String get sosRemoved;

  /// SOS timeout notice
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm whether the workshop received this request. Check your connection and try again.'**
  String get sosTimeout;

  /// SOS send error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send your request. Please try again.'**
  String get sosSendFail;

  /// SOS queue error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save this request on your device.'**
  String get sosQueueFail;

  /// SOS empty garage
  ///
  /// In en, this message translates to:
  /// **'No vehicles registered yet'**
  String get sosNoVehicles;

  /// SOS empty garage body
  ///
  /// In en, this message translates to:
  /// **'You can still send a request. Adding the vehicle helps the workshop keep your history in one place.'**
  String get sosNoVehiclesBody;

  /// SOS quick-add
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get sosAddVehicle;

  /// SOS detail label
  ///
  /// In en, this message translates to:
  /// **'Anything else? (optional)'**
  String get sosDetailLabel;

  /// SOS detail hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Parked in the basement, hard to see'**
  String get sosDetailHint2;

  /// SOS intro line
  ///
  /// In en, this message translates to:
  /// **'Tell the workshop which vehicle needs help, where it is, and what\'s wrong.'**
  String get sosIntro;

  /// SOS hotline label
  ///
  /// In en, this message translates to:
  /// **'Workshop hotline'**
  String get sosHotlineLabel;

  /// SOS result no vehicle
  ///
  /// In en, this message translates to:
  /// **'No vehicle selected'**
  String get sosNoVehicle;

  /// SOS result location row
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get sosLocationRow;

  /// SOS result issue row
  ///
  /// In en, this message translates to:
  /// **'What\'s wrong'**
  String get sosIssueRow;

  /// SOS result saved headline
  ///
  /// In en, this message translates to:
  /// **'Saved on this device — it hasn\'t been sent yet.'**
  String get sosSavedOutcome;

  /// SOS result queued note
  ///
  /// In en, this message translates to:
  /// **'It will be sent automatically when you\'re back online. Until then the workshop cannot see this request — call the workshop if you need help now.'**
  String get sosQueuedNote;

  /// SOS result next step sent
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when the workshop assigns an advisor to this request.'**
  String get sosNotifySent;

  /// SOS result next step queued
  ///
  /// In en, this message translates to:
  /// **'We\'ll send this request and notify you as soon as a connection is available.'**
  String get sosNotifyQueued;

  /// Status live badge
  ///
  /// In en, this message translates to:
  /// **'IN SERVICE'**
  String get stLiveBadge;

  /// Status unnamed service
  ///
  /// In en, this message translates to:
  /// **'Service in progress'**
  String get stServiceFallback;

  /// Status stage label
  ///
  /// In en, this message translates to:
  /// **'Current stage'**
  String get stCurrentStage;

  /// Status progress semantics
  ///
  /// In en, this message translates to:
  /// **'Service progress, {progress} percent'**
  String stProgressLabel(int progress);

  /// Status live ETA line
  ///
  /// In en, this message translates to:
  /// **'Estimated completion · {eta}'**
  String stEstCompletion(String eta);

  /// Status view booking
  ///
  /// In en, this message translates to:
  /// **'View booking'**
  String get stViewBooking;

  /// Status unnamed booking
  ///
  /// In en, this message translates to:
  /// **'Workshop booking'**
  String get stWorkshopBooking;

  /// Status no-date fallback
  ///
  /// In en, this message translates to:
  /// **'Appointment scheduled'**
  String get stApptScheduled;

  /// Status upcoming note
  ///
  /// In en, this message translates to:
  /// **'Your service is booked. Workshop updates will appear here once your vehicle is checked in.'**
  String get stBookedNote;

  /// Status job ref row
  ///
  /// In en, this message translates to:
  /// **'Job reference'**
  String get stJobRef;

  /// Status started row
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get stStarted;

  /// Status technician row
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get stTechnician;

  /// Status booking ref row
  ///
  /// In en, this message translates to:
  /// **'Booking reference'**
  String get stBookingRef;

  /// Status idle title
  ///
  /// In en, this message translates to:
  /// **'Nothing to track right now'**
  String get stIdleTitle;

  /// Status idle body
  ///
  /// In en, this message translates to:
  /// **'Your vehicle is not currently booked or in the workshop.'**
  String get stIdleWithVehicles;

  /// Status idle no-vehicle body
  ///
  /// In en, this message translates to:
  /// **'Add your vehicle to book service and follow its progress here.'**
  String get stIdleNoVehicles;

  /// Status book CTA
  ///
  /// In en, this message translates to:
  /// **'Book service'**
  String get stBookService;

  /// Status bookings link
  ///
  /// In en, this message translates to:
  /// **'View bookings'**
  String get stViewBookings;

  /// Status add CTA
  ///
  /// In en, this message translates to:
  /// **'Add your vehicle'**
  String get stAddVehicle;

  /// Status page title
  ///
  /// In en, this message translates to:
  /// **'Service status'**
  String get stTitle;

  /// Status live subtitle
  ///
  /// In en, this message translates to:
  /// **'Your vehicle is in the workshop right now.'**
  String get stLiveSub;

  /// Status booked subtitle
  ///
  /// In en, this message translates to:
  /// **'Your appointment is booked.'**
  String get stBookedSub;

  /// Status idle subtitle
  ///
  /// In en, this message translates to:
  /// **'Nothing is booked or in progress.'**
  String get stIdleSub;

  /// Status load error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your service status'**
  String get stLoadFail;

  /// Status load retry hint
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get stLoadRetry;

  /// Status retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get stRetry;

  /// Status attention title
  ///
  /// In en, this message translates to:
  /// **'Action required'**
  String get stActionRequired;

  /// Status other bookings one
  ///
  /// In en, this message translates to:
  /// **'1 more upcoming booking'**
  String get stOtherOne;

  /// Status other bookings many
  ///
  /// In en, this message translates to:
  /// **'{count} more upcoming bookings'**
  String stOtherMany(int count);

  /// Journey title
  ///
  /// In en, this message translates to:
  /// **'Service journey'**
  String get stJourneyTitle;

  /// Journey done stage
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get stDone;

  /// Journey current stage
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get stCurrent;

  /// Journey upcoming stage
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get stUpcoming;

  /// Journey unnamed stage
  ///
  /// In en, this message translates to:
  /// **'Workshop stage'**
  String get stStageFallback;

  /// Attention panel title
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get stAttentionTitle;

  /// Attention estimate line
  ///
  /// In en, this message translates to:
  /// **'Estimate {amount} awaiting your approval'**
  String stAttentionEst(String amount);

  /// Attention generic line
  ///
  /// In en, this message translates to:
  /// **'An estimate is awaiting your approval'**
  String get stAttentionGeneric;

  /// Refresh notice
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t refresh your information.'**
  String get stRefreshFail;

  /// Details title
  ///
  /// In en, this message translates to:
  /// **'Service details'**
  String get stServiceDetails;

  /// Status indeterminate wait
  ///
  /// In en, this message translates to:
  /// **'Waiting for the workshop'**
  String get stWaitingTitle;

  /// Status indeterminate wait body
  ///
  /// In en, this message translates to:
  /// **'The workshop confirms progress from the bay — no arrival time is promised.'**
  String get stWaitingBody;

  /// Attention estimates line
  ///
  /// In en, this message translates to:
  /// **'{count} estimates awaiting your approval'**
  String stAttentionEstMany(int count);

  /// Attention invoice line one
  ///
  /// In en, this message translates to:
  /// **'1 unpaid invoice'**
  String get stUnpaidOne;

  /// Attention invoice line many
  ///
  /// In en, this message translates to:
  /// **'{count} unpaid invoices'**
  String stUnpaidMany(int count);

  /// Approvals app bar
  ///
  /// In en, this message translates to:
  /// **'Approvals & billing'**
  String get apTitle;

  /// Approval detail app bar
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get apDetailTitle;

  /// Approvals section
  ///
  /// In en, this message translates to:
  /// **'Needs your decision'**
  String get apNeedsDecision;

  /// Invoices section
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get apInvoices;

  /// Approvals load error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your approvals'**
  String get apLoadFail;

  /// Approvals pull hint
  ///
  /// In en, this message translates to:
  /// **'Pull down to try again.'**
  String get apPullRetry;

  /// Approvals empty
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting'**
  String get apEmptyTitle;

  /// Approvals empty body
  ///
  /// In en, this message translates to:
  /// **'When the workshop sends an estimate, job card, or inspection for your approval, it appears here and on your booking.'**
  String get apEmptyBody;

  /// Invoices empty
  ///
  /// In en, this message translates to:
  /// **'Invoices appear here once your work has been billed.'**
  String get apInvoicesEmpty;

  /// Approval row badge
  ///
  /// In en, this message translates to:
  /// **'ACTION REQUIRED'**
  String get apActionRequired;

  /// Approval review prefix
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get apReviewPrefix;

  /// Approval sent line
  ///
  /// In en, this message translates to:
  /// **'Sent {date}'**
  String apSentAt(String date);

  /// Approval type
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get apTypeEstimate;

  /// Approval type
  ///
  /// In en, this message translates to:
  /// **'Job card'**
  String get apTypeJobCard;

  /// Approval type
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get apTypeInspection;

  /// Approval detail error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this request'**
  String get apDetailLoadFail;

  /// Approval detail replaced
  ///
  /// In en, this message translates to:
  /// **'The workshop may have replaced it. You can try again or review your other approvals.'**
  String get apDetailReplaced;

  /// Approval retry
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get apTryAgain;

  /// Approval overview link
  ///
  /// In en, this message translates to:
  /// **'View all approvals'**
  String get apViewAll;

  /// Approval record title
  ///
  /// In en, this message translates to:
  /// **'Job card approval'**
  String get apRecordJobCard;

  /// Approval record title
  ///
  /// In en, this message translates to:
  /// **'Inspection approval'**
  String get apRecordInspection;

  /// Approval record title
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get apRecordEstimate;

  /// Approval breakdown title
  ///
  /// In en, this message translates to:
  /// **'What this estimate covers'**
  String get apCovers;

  /// Approval services group
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get apServices;

  /// Approval parts group
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get apParts;

  /// Approval unnamed line
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get apItemFallback;

  /// Approval line meta
  ///
  /// In en, this message translates to:
  /// **'Qty {qty} × {rate}'**
  String apQtyRate(int qty, String rate);

  /// Approval line discount
  ///
  /// In en, this message translates to:
  /// **'−{pct}%'**
  String apDiscount(String pct);

  /// Approval summary title
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get apSummary;

  /// Approval total row
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get apTotal;

  /// Decided note
  ///
  /// In en, this message translates to:
  /// **'You approved this estimate. The workshop will carry out the work listed above.'**
  String get apDecidedApprovedEst;

  /// Decided note
  ///
  /// In en, this message translates to:
  /// **'You approved this {subject}. The workshop has been told.'**
  String apDecidedApprovedSubject(String subject);

  /// Decided note
  ///
  /// In en, this message translates to:
  /// **'You rejected this estimate. The workshop has been told and can send a revised one.'**
  String get apDecidedRejectedEst;

  /// Decided note
  ///
  /// In en, this message translates to:
  /// **'You rejected this {subject}. The workshop has been told.'**
  String apDecidedRejectedSubject(String subject);

  /// Decision subject
  ///
  /// In en, this message translates to:
  /// **'estimate'**
  String get apSubjectEstimate;

  /// Decision subject
  ///
  /// In en, this message translates to:
  /// **'job card'**
  String get apSubjectJobCard;

  /// Decision subject
  ///
  /// In en, this message translates to:
  /// **'inspection'**
  String get apSubjectInspection;

  /// Approve CTA
  ///
  /// In en, this message translates to:
  /// **'Approve {subject}'**
  String apApproveSubject(String subject);

  /// Reject CTA
  ///
  /// In en, this message translates to:
  /// **'Reject {subject}'**
  String apRejectSubject(String subject);

  /// Decision busy
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get apSending;

  /// Decision busy note
  ///
  /// In en, this message translates to:
  /// **'Sending your decision to the workshop…'**
  String get apSendingNote;

  /// Approve dialog title
  ///
  /// In en, this message translates to:
  /// **'Approve {subject}?'**
  String apConfirmApproveTitle(String subject);

  /// Reject dialog title
  ///
  /// In en, this message translates to:
  /// **'Reject {subject}?'**
  String apConfirmRejectTitle(String subject);

  /// Approve dialog body
  ///
  /// In en, this message translates to:
  /// **'You are approving work totaling {amount}.'**
  String apConfirmApproveEst(String amount);

  /// Approve dialog body
  ///
  /// In en, this message translates to:
  /// **'You are approving work totaling {amount} for {vehicle}.'**
  String apConfirmApproveEstVehicle(String amount, String vehicle);

  /// Approve dialog body
  ///
  /// In en, this message translates to:
  /// **'You are approving this {subject}.'**
  String apConfirmApproveSubject(String subject);

  /// Approve dialog body
  ///
  /// In en, this message translates to:
  /// **'You are approving this {subject} for {vehicle}.'**
  String apConfirmApproveSubjectVehicle(String subject, String vehicle);

  /// Reject dialog body
  ///
  /// In en, this message translates to:
  /// **'The workshop will be told you do not accept this estimate. You can ask them for a revised one.'**
  String get apConfirmRejectEst;

  /// Reject dialog body
  ///
  /// In en, this message translates to:
  /// **'The workshop will be told you do not accept this {subject}.'**
  String apConfirmRejectSubject(String subject);

  /// Dialog confirm
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get apConfirm;

  /// Dialog confirm reject
  ///
  /// In en, this message translates to:
  /// **'Reject {subject}'**
  String apConfirmReject(String subject);

  /// Dialog dismiss
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get apNotNow;

  /// Dialog dismiss
  ///
  /// In en, this message translates to:
  /// **'Keep reviewing'**
  String get apKeepReviewing;

  /// Approve toast
  ///
  /// In en, this message translates to:
  /// **'{label} approved — the workshop has been told.'**
  String apApprovedToast(String label);

  /// Reject toast
  ///
  /// In en, this message translates to:
  /// **'{label} rejected — the workshop has been told.'**
  String apRejectedToast(String label);

  /// Decision error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send your decision. Please try again.'**
  String get apDecisionFail;

  /// Decision retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get apRetry;

  /// Toast label
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get apLabelEstimate;

  /// Toast label
  ///
  /// In en, this message translates to:
  /// **'Job card'**
  String get apLabelJobCard;

  /// Toast label
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get apLabelInspection;

  /// Invoice app bar
  ///
  /// In en, this message translates to:
  /// **'Invoice Detail'**
  String get invTitle;

  /// Invoice customer row
  ///
  /// In en, this message translates to:
  /// **'Billed to'**
  String get invBilledTo;

  /// Invoice date row
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get invIssued;

  /// Invoice subtotal row
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get invSubtotal;

  /// Invoice VAT row
  ///
  /// In en, this message translates to:
  /// **'VAT ({pct}%)'**
  String invVat(String pct);

  /// Invoice total row
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get invTotal;

  /// Invoice honesty note
  ///
  /// In en, this message translates to:
  /// **'Your itemized workshop receipt.'**
  String get invReceiptNote;

  /// Feedback app bar
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get fbTitle;

  /// Feedback error
  ///
  /// In en, this message translates to:
  /// **'Failed to submit feedback. Try again.'**
  String get fbSubmitFail;

  /// Feedback next
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get fbNext;

  /// Feedback submit
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get fbSubmit;

  /// Feedback thanks
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get fbThanks;

  /// Feedback thanks body
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve our service.'**
  String get fbThanksBody;

  /// Feedback book CTA
  ///
  /// In en, this message translates to:
  /// **'Book Next Service'**
  String get fbBookNext;

  /// Feedback home link
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get fbBackHome;

  /// Feedback overall step
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get fbOverallTitle;

  /// Feedback categories step
  ///
  /// In en, this message translates to:
  /// **'Rate specific areas'**
  String get fbCategoriesTitle;

  /// Feedback category
  ///
  /// In en, this message translates to:
  /// **'Work Quality'**
  String get fbCatWork;

  /// Feedback category
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get fbCatComm;

  /// Feedback category
  ///
  /// In en, this message translates to:
  /// **'Timeliness'**
  String get fbCatTime;

  /// Feedback category
  ///
  /// In en, this message translates to:
  /// **'Value for Money'**
  String get fbCatValue;

  /// Feedback comment step
  ///
  /// In en, this message translates to:
  /// **'Any other comments?'**
  String get fbCommentTitle;

  /// Feedback comment hint
  ///
  /// In en, this message translates to:
  /// **'Tell us more (optional)'**
  String get fbCommentHint;

  /// Feedback recommend
  ///
  /// In en, this message translates to:
  /// **'Would you recommend us?'**
  String get fbRecommend;

  /// Feedback yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get fbYes;

  /// Feedback no
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get fbNo;

  /// Feedback tags title
  ///
  /// In en, this message translates to:
  /// **'What stood out?'**
  String get fbTagsTitle;

  /// Feedback tag
  ///
  /// In en, this message translates to:
  /// **'Fast Service'**
  String get fbTagFast;

  /// Feedback tag
  ///
  /// In en, this message translates to:
  /// **'Clean Bay'**
  String get fbTagClean;

  /// Feedback tag
  ///
  /// In en, this message translates to:
  /// **'Clear Advice'**
  String get fbTagClear;
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
