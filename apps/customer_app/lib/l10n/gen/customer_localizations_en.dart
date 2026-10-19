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

  @override
  String get garNavHome => 'Home';

  @override
  String get garNavBookings => 'Bookings';

  @override
  String get garNavVehicles => 'Vehicles';

  @override
  String get garNavProfile => 'Profile';

  @override
  String get garBrand => 'Orient Auto Garage';

  @override
  String get garBrandSub => 'Your car is in good hands';

  @override
  String get garHello => 'Welcome back';

  @override
  String get garWelcome => 'Welcome to Orient';

  @override
  String get garManage => 'Manage';

  @override
  String get garTitleOne => 'Your vehicle';

  @override
  String get garTitleMany => 'Your garage';

  @override
  String get garHeroEmpty => 'Your garage is empty';

  @override
  String get garHeroEmptyBody =>
      'Add your vehicle to book service, follow repair progress, and keep every update in one place.';

  @override
  String get garHeroAdd => 'Add your vehicle';

  @override
  String get garJourneyTitle => 'Active journey';

  @override
  String get garJourneyTrack => 'Track service';

  @override
  String get garJourneyView => 'View booking';

  @override
  String get garJourneyEmpty => 'No active journey right now.';

  @override
  String get garActionsTitle => 'How can we help?';

  @override
  String get garActionBook => 'Book service';

  @override
  String get garActionBookHint => 'Pick a time that suits you';

  @override
  String get garActionSos => 'Breakdown help';

  @override
  String get garActionSosHint => 'Help is on the way';

  @override
  String get garActionInvoices => 'Invoices';

  @override
  String get garActionInvoicesHint => 'Receipts and bills';

  @override
  String get garActionHistory => 'History';

  @override
  String get garActionHistoryHint => 'Past visits';

  @override
  String get garRecentTitle => 'Recent activity';

  @override
  String get garLoadTitle => 'We couldn\'t load your information';

  @override
  String get garLoadBody => 'Please try again in a moment.';

  @override
  String get garRetry => 'Retry';

  @override
  String get garRecentAll => 'All bookings';

  @override
  String get garUpcomingTitle => 'Coming up';

  @override
  String get bkTitle => 'Bookings';

  @override
  String get bkUpcoming => 'Upcoming';

  @override
  String get bkInService => 'In service';

  @override
  String get bkHistory => 'History';

  @override
  String get bkBookCta => 'Book service';

  @override
  String get bkEmptyTitle => 'No bookings yet';

  @override
  String get bkEmptyBody =>
      'When you\'re ready, book a service and it will appear here.';

  @override
  String get bkEmptyVehiclesTitle => 'No vehicle yet';

  @override
  String get bkEmptyVehiclesBody =>
      'Add your car first so the workshop knows what to service.';

  @override
  String get bkFailedTitle => 'Needs attention';

  @override
  String get bkRetry => 'Retry';

  @override
  String get bkRemoveTitle => 'Remove saved booking?';

  @override
  String get bkRemoveBody =>
      'This removes the booking stored on this device. The workshop has not received it.';

  @override
  String get bkRemoveCta => 'Remove booking';

  @override
  String get bkKeepCta => 'Keep booking';

  @override
  String get bkSendFail => 'We couldn\'t send this booking. Please try again.';

  @override
  String get bkLoadFailTitle => 'We couldn\'t load your bookings';

  @override
  String get bkLoadFailBody => 'Please try again in a moment.';

  @override
  String get bkRetryCta => 'Retry';

  @override
  String get bkUpOne => '1 upcoming';

  @override
  String bkUpMany(int count) {
    return '$count upcoming';
  }

  @override
  String get bkInOne => '1 in service';

  @override
  String bkInMany(int count) {
    return '$count in service';
  }

  @override
  String get bkPastOne => '1 past service';

  @override
  String bkPastMany(int count) {
    return '$count past services';
  }

  @override
  String get bkSubDefault => 'Your appointments and service history.';

  @override
  String get bkReview => 'Review';

  @override
  String get bkServiceAppt => 'Service appointment';

  @override
  String get bkApprovalMsg => 'Approval needed before work continues';

  @override
  String bkApprovalEst(String amount) {
    return 'Estimate $amount awaiting approval';
  }

  @override
  String get jsInService => 'IN SERVICE';

  @override
  String get jsInProgress => 'Service in progress';

  @override
  String jsStage(String stage) {
    return 'Current stage · $stage';
  }

  @override
  String jsEta(String value) {
    return 'Estimated completion · $value';
  }

  @override
  String get jsNoService => 'No active service';

  @override
  String get jsIdleOne => 'Your vehicle is not in the workshop right now.';

  @override
  String get jsIdleMany => 'Your vehicles are not in the workshop right now.';

  @override
  String get jsWorkshopBooking => 'Workshop booking';

  @override
  String get vhTitle => 'My vehicles';

  @override
  String get vhCountNone => 'Registered vehicles appear here.';

  @override
  String get vhCountOne => '1 registered vehicle';

  @override
  String vhCountMany(int count) {
    return '$count registered vehicles';
  }

  @override
  String get vhAdd => 'Add vehicle';

  @override
  String get vhEmptyTitle => 'No vehicles added yet';

  @override
  String get vhEmptyBody =>
      'Add your first car to book service and keep every visit connected to the right vehicle.';

  @override
  String get vhLoadFailTitle => 'We couldn\'t load your vehicles';

  @override
  String get vhLoadFailBody => 'Please try again in a moment.';

  @override
  String get vhBook => 'Book service';

  @override
  String get vhEdit => 'Edit';

  @override
  String get vhRemove => 'Remove';

  @override
  String get vhRemoveNoName => 'Remove this vehicle?';

  @override
  String vhRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String vhRemoveBody(String plate) {
    return '$plate will be removed from your vehicles.';
  }

  @override
  String get vhRemoveBodyNoPlate =>
      'This vehicle will no longer appear in your vehicles.';

  @override
  String get vhRemoveCta => 'Remove vehicle';

  @override
  String get vhKeepCta => 'Keep vehicle';

  @override
  String get vhRemoved => 'Vehicle removed.';

  @override
  String get vhRemoveFail =>
      'We couldn\'t remove this vehicle. Please try again.';

  @override
  String get vhSyncFail => 'Vehicle couldn\'t finish saving.';

  @override
  String get vhDeleteFailTitle => 'We couldn\'t remove this vehicle.';

  @override
  String get vhDeleteFailBody =>
      'The vehicle is still in your workshop account.';

  @override
  String get vhRetryRemoval => 'Retry removal';

  @override
  String get vhRetrying => 'Retrying…';

  @override
  String get vhTrack => 'Track';

  @override
  String get vhRetry => 'Retry';

  @override
  String get vhView => 'View';

  @override
  String get vhInService => 'In the workshop now';

  @override
  String get vhFallbackName => 'Vehicle';

  @override
  String get avTitleAdd => 'Add vehicle';

  @override
  String get avTitleEdit => 'Edit vehicle';

  @override
  String get avStepPlate => 'Plate';

  @override
  String get avStepVehicle => 'Vehicle';

  @override
  String get avStepDetails => 'Details';

  @override
  String get avEyebrowReg => 'REGISTRATION';

  @override
  String get avEyebrowVeh => 'VEHICLE';

  @override
  String get avEyebrowDet => 'DETAILS';

  @override
  String get avPlateTitle => 'What is the plate?';

  @override
  String get avPlateBody =>
      'The plate is how the workshop identifies your car.';

  @override
  String get avPlateLabel => 'Plate';

  @override
  String get avPlateHint => 'A 12345';

  @override
  String get avPlateError => 'Enter the registration plate';

  @override
  String get avVehicleTitle => 'Which car is it?';

  @override
  String get avVehicleBody => 'The make is required to register it.';

  @override
  String get avMakeLabel => 'Make';

  @override
  String get avMakeHint => 'Toyota';

  @override
  String get avMakeError => 'Enter the make of your vehicle';

  @override
  String get avModelLabel => 'Model (optional)';

  @override
  String get avModelHint => 'Land Cruiser';

  @override
  String get avYearLabel => 'Year';

  @override
  String get avYearHint => '2021';

  @override
  String avYearError(int max) {
    return 'Enter a year between 1950 and $max';
  }

  @override
  String get avDetailsTitle => 'Anything else?';

  @override
  String get avDetailsBody =>
      'Optional — helps identify your car. Service dates stay untouched.';

  @override
  String get avVinLabel => 'VIN (optional)';

  @override
  String get avVinHint => 'Chassis number';

  @override
  String get avVinHelp => 'The workshop can read this from the car.';

  @override
  String get avColorLabel => 'Colour';

  @override
  String get avColorHint => 'White';

  @override
  String get avMileageLabel => 'Mileage (optional)';

  @override
  String get avMileageHint => '48,200';

  @override
  String get avNext => 'Continue';

  @override
  String get avBack => 'Back';

  @override
  String get avSaveAdd => 'Add vehicle';

  @override
  String get avSaveEdit => 'Save changes';

  @override
  String get avSaving => 'Saving…';

  @override
  String get avNoteKept =>
      'Service dates already on record are left untouched here.';

  @override
  String get avNoteFresh =>
      'This screen never changes the service dates on record.';

  @override
  String get avSaveFailFallback =>
      'We couldn\'t save this vehicle. Please try again.';

  @override
  String get avRetryCta => 'Try again';

  @override
  String get pfTitle => 'Profile';

  @override
  String get pfContact => 'Contact';

  @override
  String get pfAccount => 'Account';

  @override
  String get pfAbout => 'About';

  @override
  String get pfSession => 'Session';

  @override
  String get pfVehicles => 'Vehicles';

  @override
  String get pfVehiclesHint => 'Cars registered to your account';

  @override
  String get pfVehiclesNone => 'None';

  @override
  String get pfSos => 'Roadside assistance';

  @override
  String get pfSosHint => 'Request help when your vehicle breaks down';

  @override
  String get pfPassword => 'Reset password';

  @override
  String get pfPasswordHint =>
      'Verify with a one-time code, then set a new password';

  @override
  String get pfLicences => 'Open source licences';

  @override
  String get pfLicencesHint => 'Software used by this app';

  @override
  String get pfAccountFallback => 'Your account';

  @override
  String get pfEmail => 'Email';

  @override
  String get pfPhone => 'Phone';

  @override
  String get pfSumNone => 'No vehicles yet';

  @override
  String get pfSumOne => '1 vehicle';

  @override
  String pfSumMany(int count) {
    return '$count vehicles';
  }

  @override
  String get pfSumLive => 'Service in progress';

  @override
  String get pfRetry => 'Retry';

  @override
  String get pfLoadFail => 'We couldn\'t load your account.';

  @override
  String get ntTitle => 'Notifications';

  @override
  String get ntMarkAll => 'Mark all read';

  @override
  String get ntAllRead => 'All read';

  @override
  String ntUnread(int count) {
    return '$count unread';
  }

  @override
  String get ntCaughtUp => 'You\'re all caught up';

  @override
  String get ntCaughtUpBody =>
      'Updates about your bookings, estimates and service progress will appear here.';

  @override
  String get ntUnreadWord => 'Unread';

  @override
  String get ntReadWord => 'Read';

  @override
  String get ntLoadTitle => 'We couldn\'t load your notifications.';

  @override
  String get ntLoadBody => 'Please try again in a moment.';

  @override
  String get ntMarkFail => 'We couldn\'t mark your notifications as read.';

  @override
  String get ntRetry => 'Retry';

  @override
  String get ntGroupService => 'Service updates';

  @override
  String get ntGroupApprovals => 'Approvals';

  @override
  String get ntGroupInvoices => 'Invoices & receipts';

  @override
  String get ntGroupGeneral => 'General';

  @override
  String get ntTypeBooking => 'Booking';

  @override
  String get ntTypeApproval => 'Approval';

  @override
  String get ntTypeService => 'Service';

  @override
  String get ntTypeInvoice => 'Invoice';

  @override
  String get ntTypePayment => 'Payment';

  @override
  String get ntTypeBreakdown => 'Breakdown';

  @override
  String get ntTypeUpdate => 'Update';
}
