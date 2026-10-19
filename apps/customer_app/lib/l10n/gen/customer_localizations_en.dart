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

  @override
  String get wizTitle => 'Book a service';

  @override
  String get wizStepVehicle => 'Vehicle';

  @override
  String get wizStepPackage => 'Package';

  @override
  String get wizStepSlot => 'Time';

  @override
  String get wizStepDropoff => 'Drop-off';

  @override
  String get wizVehicleTitle => 'Which car is coming in?';

  @override
  String get wizVehicleSub =>
      'Pick the registered vehicle the workshop will receive.';

  @override
  String get wizGarageEmptyTitle => 'No vehicle yet';

  @override
  String get wizGarageEmptyBody =>
      'A booking needs a registered vehicle. Add yours in under a minute.';

  @override
  String get wizAddVehicle => 'Add your vehicle';

  @override
  String get wizPackageTitle => 'What does it need?';

  @override
  String get wizPackageSub =>
      'Pick one or more services. Prices are upfront, in dirhams.';

  @override
  String get wizServicesLoadFail => 'We couldn\'t load the services.';

  @override
  String get wizRetryServices => 'Retry services';

  @override
  String get wizNoServicesTitle => 'No services right now';

  @override
  String get wizNoServicesBody =>
      'The workshop catalogue is empty. Try again in a little while.';

  @override
  String get wizSlotTitle => 'When suits you?';

  @override
  String get wizSlotSub =>
      'Days and times come straight from the workshop diary.';

  @override
  String get wizChooseDate => 'Choose a day';

  @override
  String get wizTimesFor => 'Available times';

  @override
  String get wizNoDateBody => 'Choose a day above to see its times.';

  @override
  String get wizSlotsLoadFail => 'We couldn\'t load the available times.';

  @override
  String get wizRetryTimes => 'Retry times';

  @override
  String get wizNoTimesTitle => 'No times left on this day';

  @override
  String get wizNoTimesBody =>
      'Try another day — new slots open as the diary moves.';

  @override
  String get wizMorning => 'Morning';

  @override
  String get wizAfternoon => 'Afternoon';

  @override
  String get wizDropTitle => 'How does it reach us?';

  @override
  String get wizDropSub =>
      'Drop it off yourself, or let our driver collect it.';

  @override
  String get wizSelfTitle => 'Self drop-off';

  @override
  String get wizSelfBody => 'Bring the car to the workshop at your slot.';

  @override
  String get wizValetTitle => 'Valet pick-up';

  @override
  String get wizValetBody =>
      'Our driver collects it and returns it after the work.';

  @override
  String get wizAddressLabel => 'Pick-up address';

  @override
  String get wizAddressHint => 'Street, building, landmark';

  @override
  String get wizAddressRequired =>
      'Add a pick-up address so the driver can find you.';

  @override
  String get wizNotesLabel => 'Notes for the workshop';

  @override
  String get wizNotesHint => 'Optional — e.g. noise when braking';

  @override
  String get wizNeedVehicle => 'Pick a vehicle to continue.';

  @override
  String get wizNeedPackage => 'Pick at least one service to continue.';

  @override
  String get wizNeedSlot => 'Pick a day and a time to continue.';

  @override
  String get wizSummaryTitle => 'Your booking';

  @override
  String get wizSummaryEmpty =>
      'Nothing picked yet — your choices appear here.';

  @override
  String get wizRowVehicle => 'Vehicle';

  @override
  String get wizRowServices => 'Services';

  @override
  String get wizRowSlot => 'Appointment';

  @override
  String get wizTotal => 'Total';

  @override
  String get wizTotalPending => 'Confirmed at the workshop';

  @override
  String get wizTrust => 'Free re-check within 7 days';

  @override
  String get wizContinue => 'Continue';

  @override
  String get wizBack => 'Back';

  @override
  String get wizConfirm => 'Confirm booking';

  @override
  String get wizBooking => 'Booking…';

  @override
  String get wizChange => 'Change';

  @override
  String get wizSubmitFail =>
      'We couldn\'t create this booking. Please try again.';

  @override
  String get wizRetrySync => 'Retry vehicle sync';

  @override
  String get wizTryAgain => 'Try again';

  @override
  String get bkdTitle => 'Booking Details';

  @override
  String get bkdPassTitle => 'Workshop pass';

  @override
  String get bkdPassHint => 'Show this at arrival';

  @override
  String get bkdAddCalendar => 'Add to calendar';

  @override
  String get bkdCalendarFail => 'We couldn\'t open the calendar.';

  @override
  String get bkdApprovalTitle => 'Approval needed before work continues';

  @override
  String get bkdServiceLabel => 'Service';

  @override
  String get bkdVehicleLabel => 'Vehicle';

  @override
  String get bkdApptLabel => 'Appointment';

  @override
  String get bkdDateLabel => 'Service date';

  @override
  String get bkdRefLabel => 'Booking reference';

  @override
  String get bkdConfirmedNote =>
      'Your car is booked in. We will take it from here once you arrive.';

  @override
  String get bkdRequestedNote =>
      'The workshop has your request and will confirm the slot shortly.';

  @override
  String get bkdTrack => 'Track service';

  @override
  String get bkdReviewEstimate => 'Review estimate';

  @override
  String get bkdCancelTitle => 'Cancel booking?';

  @override
  String get bkdCancelBody => 'The workshop will be told straight away.';

  @override
  String get bkdCancelCta => 'Cancel booking';

  @override
  String get bkdKeepCta => 'Keep booking';

  @override
  String get bkdCancelling => 'Cancelling…';

  @override
  String get bkdCancelled => 'Booking cancelled.';

  @override
  String get bkdCancelFail =>
      'We couldn\'t cancel this booking. Please try again.';

  @override
  String get bkdRetry => 'Retry';

  @override
  String get bksRequested => 'Booking requested';

  @override
  String get bksSaved => 'Booking saved';

  @override
  String get bksRequestedSub => 'The workshop will confirm your slot shortly.';

  @override
  String get bksSavedSub =>
      'It will reach the workshop when you are back online.';

  @override
  String get bksRefLabel => 'Booking reference';

  @override
  String get bksStatusLabel => 'Status';

  @override
  String get bksNotSent => 'Not sent yet';

  @override
  String get bksServiceLabel => 'Service';

  @override
  String get bksVehicleLabel => 'Vehicle';

  @override
  String get bksApptLabel => 'Appointment';

  @override
  String get bksQueuedTitle => 'Stored on this device';

  @override
  String get bksQueuedBody =>
      'It will be sent automatically when connection is back.';

  @override
  String get bksPendingBody =>
      'Your appointment is not confirmed yet. The workshop will confirm the slot.';

  @override
  String get bksPendingTitle => 'Not confirmed yet';

  @override
  String get bksNextTitle => 'What happens next';

  @override
  String get bksNextOne => 'The workshop confirms your slot.';

  @override
  String get bksNextTwo => 'Drop off the car — or wait for the valet.';

  @override
  String get bksNextThree => 'Track every stage from Bookings.';

  @override
  String get bksDone => 'Done';

  @override
  String get bksViewBooking => 'View booking';

  @override
  String get bksViewBookings => 'View bookings';

  @override
  String get sosTitle => 'Roadside assistance';

  @override
  String get sosSub => 'Help is one tap away, day or night.';

  @override
  String get sosVehicleTitle => 'Which vehicle needs help?';

  @override
  String get sosLocationTitle => 'Where are you?';

  @override
  String get sosLocationHint => 'Enter your current location or landmark';

  @override
  String get sosLocationHelp => 'Type an address, exit or nearby landmark.';

  @override
  String get sosLocationRequired =>
      'Add where the vehicle is so the workshop can find you.';

  @override
  String get sosIssueTitle => 'What\'s wrong?';

  @override
  String get sosDetailHint => 'Anything the driver should know (optional)';

  @override
  String get sosIssueRequired =>
      'Tell us what\'s wrong so the workshop can help.';

  @override
  String get sosTyre => 'Flat tyre';

  @override
  String get sosNoStart => 'Won\'t start';

  @override
  String get sosBattery => 'Dead battery';

  @override
  String get sosOverheat => 'Overheating';

  @override
  String get sosBrake => 'Brake problem';

  @override
  String get sosWarning => 'Warning light';

  @override
  String get sosAccident => 'Accident damage';

  @override
  String get sosLockout => 'Locked out';

  @override
  String get sosOther => 'Something else';

  @override
  String get sosCallWorkshop => 'Call the workshop';

  @override
  String get sosSend => 'Request assistance';

  @override
  String get sosSending => 'Sending request…';

  @override
  String get sosRetry => 'Retry sending';

  @override
  String get sosRetrying => 'Retrying…';

  @override
  String get sosRemove => 'Remove request';

  @override
  String get sosKeep => 'Keep request';

  @override
  String get sosRemoveTitle => 'Remove saved request?';

  @override
  String get sosRemoveBody =>
      'This removes the copy stored on this device. The workshop has not received it.';

  @override
  String get sosSavedTitle => 'Saved on this device';

  @override
  String get sosSavedBody =>
      'It hasn\'t been sent yet. Retry when you are back online.';

  @override
  String get sosDialFail => 'Unable to open the phone dialer.';

  @override
  String get sosSent => 'Request sent';

  @override
  String get sosSaved => 'Request saved';

  @override
  String get sosSentBody => 'The workshop has received your request.';

  @override
  String get sosRef => 'Reference';

  @override
  String get sosDetails => 'What you asked for';

  @override
  String get sosDone => 'Done';

  @override
  String get sosWhatNext => 'What happens next';

  @override
  String get sosNextSentOne => 'The workshop calls you to confirm dispatch.';

  @override
  String get sosNextSentTwo => 'Stay with the vehicle and keep your phone on.';

  @override
  String get sosNextSavedOne => 'Your request is stored on this device.';

  @override
  String get sosNextSavedTwo => 'Retry sending once you are back online.';

  @override
  String get sosWaitingTitle => 'Waiting for the workshop';

  @override
  String get sosWaitingBody =>
      'The workshop confirms dispatch by phone — there is no live arrival time yet.';

  @override
  String get bkdActionRequired => 'Action required';

  @override
  String get bkdCurrentStage => 'Current stage';

  @override
  String get bkdInProgress => 'Service in progress';

  @override
  String bkdEstCompletion(String eta) {
    return 'Estimated completion · $eta';
  }

  @override
  String bkdProgressLabel(int progress) {
    return 'Service progress, $progress percent';
  }

  @override
  String get bkdYourVehicle => 'Your vehicle';

  @override
  String get sosSendingNote => 'Sending your request…';

  @override
  String get sosRecoveryOne => 'We couldn\'t send your roadside request';

  @override
  String get sosRecoveryMany => 'We couldn\'t send your roadside requests';

  @override
  String get sosRecoveryBodyOne =>
      'It\'s saved on this device, but the workshop has not received it. Try sending it again, or call the workshop if you need help now.';

  @override
  String get sosRecoveryBodyMany =>
      'They are saved on this device, but the workshop has not received them. Try again, or call the workshop if you need help now.';

  @override
  String sosSavedCount(int count) {
    return '$count saved requests';
  }

  @override
  String get sosRetryDone => 'Your saved request was sent to the workshop.';

  @override
  String get sosRetryFail =>
      'We still couldn\'t send your request. The workshop has not received it.';

  @override
  String get sosRemoved => 'Saved request removed.';

  @override
  String get sosTimeout =>
      'We couldn\'t confirm whether the workshop received this request. Check your connection and try again.';

  @override
  String get sosSendFail => 'We couldn\'t send your request. Please try again.';

  @override
  String get sosQueueFail => 'We couldn\'t save this request on your device.';

  @override
  String get sosNoVehicles => 'No vehicles registered yet';

  @override
  String get sosNoVehiclesBody =>
      'You can still send a request. Adding the vehicle helps the workshop keep your history in one place.';

  @override
  String get sosAddVehicle => 'Add vehicle';

  @override
  String get sosDetailLabel => 'Anything else? (optional)';

  @override
  String get sosDetailHint2 => 'e.g. Parked in the basement, hard to see';

  @override
  String get sosIntro =>
      'Tell the workshop which vehicle needs help, where it is, and what\'s wrong.';

  @override
  String get sosHotlineLabel => 'Workshop hotline';

  @override
  String get sosNoVehicle => 'No vehicle selected';

  @override
  String get sosLocationRow => 'Location';

  @override
  String get sosIssueRow => 'What\'s wrong';

  @override
  String get sosSavedOutcome =>
      'Saved on this device — it hasn\'t been sent yet.';

  @override
  String get sosQueuedNote =>
      'It will be sent automatically when you\'re back online. Until then the workshop cannot see this request — call the workshop if you need help now.';

  @override
  String get sosNotifySent =>
      'We\'ll notify you when the workshop assigns an advisor to this request.';

  @override
  String get sosNotifyQueued =>
      'We\'ll send this request and notify you as soon as a connection is available.';

  @override
  String get stLiveBadge => 'IN SERVICE';

  @override
  String get stServiceFallback => 'Service in progress';

  @override
  String get stCurrentStage => 'Current stage';

  @override
  String stProgressLabel(int progress) {
    return 'Service progress, $progress percent';
  }

  @override
  String stEstCompletion(String eta) {
    return 'Estimated completion · $eta';
  }

  @override
  String get stViewBooking => 'View booking';

  @override
  String get stWorkshopBooking => 'Workshop booking';

  @override
  String get stApptScheduled => 'Appointment scheduled';

  @override
  String get stBookedNote =>
      'Your service is booked. Workshop updates will appear here once your vehicle is checked in.';

  @override
  String get stJobRef => 'Job reference';

  @override
  String get stStarted => 'Started';

  @override
  String get stTechnician => 'Technician';

  @override
  String get stBookingRef => 'Booking reference';

  @override
  String get stIdleTitle => 'Nothing to track right now';

  @override
  String get stIdleWithVehicles =>
      'Your vehicle is not currently booked or in the workshop.';

  @override
  String get stIdleNoVehicles =>
      'Add your vehicle to book service and follow its progress here.';

  @override
  String get stBookService => 'Book service';

  @override
  String get stViewBookings => 'View bookings';

  @override
  String get stAddVehicle => 'Add your vehicle';

  @override
  String get stTitle => 'Service status';

  @override
  String get stLiveSub => 'Your vehicle is in the workshop right now.';

  @override
  String get stBookedSub => 'Your appointment is booked.';

  @override
  String get stIdleSub => 'Nothing is booked or in progress.';

  @override
  String get stLoadFail => 'We couldn\'t load your service status';

  @override
  String get stLoadRetry => 'Please try again in a moment.';

  @override
  String get stRetry => 'Retry';

  @override
  String get stActionRequired => 'Action required';

  @override
  String get stOtherOne => '1 more upcoming booking';

  @override
  String stOtherMany(int count) {
    return '$count more upcoming bookings';
  }

  @override
  String get stJourneyTitle => 'Service journey';

  @override
  String get stDone => 'Done';

  @override
  String get stCurrent => 'Current';

  @override
  String get stUpcoming => 'Upcoming';

  @override
  String get stStageFallback => 'Workshop stage';

  @override
  String get stAttentionTitle => 'Needs your attention';

  @override
  String stAttentionEst(String amount) {
    return 'Estimate $amount awaiting your approval';
  }

  @override
  String get stAttentionGeneric => 'An estimate is awaiting your approval';

  @override
  String get stRefreshFail => 'We couldn\'t refresh your information.';

  @override
  String get stServiceDetails => 'Service details';

  @override
  String get stWaitingTitle => 'Waiting for the workshop';

  @override
  String get stWaitingBody =>
      'The workshop confirms progress from the bay — no arrival time is promised.';

  @override
  String stAttentionEstMany(int count) {
    return '$count estimates awaiting your approval';
  }

  @override
  String get stUnpaidOne => '1 unpaid invoice';

  @override
  String stUnpaidMany(int count) {
    return '$count unpaid invoices';
  }

  @override
  String get apTitle => 'Approvals & billing';

  @override
  String get apDetailTitle => 'Approval';

  @override
  String get apNeedsDecision => 'Needs your decision';

  @override
  String get apInvoices => 'Invoices';

  @override
  String get apLoadFail => 'We couldn\'t load your approvals';

  @override
  String get apPullRetry => 'Pull down to try again.';

  @override
  String get apEmptyTitle => 'Nothing waiting';

  @override
  String get apEmptyBody =>
      'When the workshop sends an estimate, job card, or inspection for your approval, it appears here and on your booking.';

  @override
  String get apInvoicesEmpty =>
      'Invoices appear here once your work has been billed.';

  @override
  String get apActionRequired => 'ACTION REQUIRED';

  @override
  String get apReviewPrefix => 'Review';

  @override
  String apSentAt(String date) {
    return 'Sent $date';
  }

  @override
  String get apTypeEstimate => 'Estimate';

  @override
  String get apTypeJobCard => 'Job card';

  @override
  String get apTypeInspection => 'Inspection';

  @override
  String get apDetailLoadFail => 'We couldn\'t load this request';

  @override
  String get apDetailReplaced =>
      'The workshop may have replaced it. You can try again or review your other approvals.';

  @override
  String get apTryAgain => 'Try again';

  @override
  String get apViewAll => 'View all approvals';

  @override
  String get apRecordJobCard => 'Job card approval';

  @override
  String get apRecordInspection => 'Inspection approval';

  @override
  String get apRecordEstimate => 'Estimated total';

  @override
  String get apCovers => 'What this estimate covers';

  @override
  String get apServices => 'Services';

  @override
  String get apParts => 'Parts';

  @override
  String get apItemFallback => 'Item';

  @override
  String apQtyRate(int qty, String rate) {
    return 'Qty $qty × $rate';
  }

  @override
  String apDiscount(String pct) {
    return '−$pct%';
  }

  @override
  String get apSummary => 'Summary';

  @override
  String get apTotal => 'Total';

  @override
  String get apDecidedApprovedEst =>
      'You approved this estimate. The workshop will carry out the work listed above.';

  @override
  String apDecidedApprovedSubject(String subject) {
    return 'You approved this $subject. The workshop has been told.';
  }

  @override
  String get apDecidedRejectedEst =>
      'You rejected this estimate. The workshop has been told and can send a revised one.';

  @override
  String apDecidedRejectedSubject(String subject) {
    return 'You rejected this $subject. The workshop has been told.';
  }

  @override
  String get apSubjectEstimate => 'estimate';

  @override
  String get apSubjectJobCard => 'job card';

  @override
  String get apSubjectInspection => 'inspection';

  @override
  String apApproveSubject(String subject) {
    return 'Approve $subject';
  }

  @override
  String apRejectSubject(String subject) {
    return 'Reject $subject';
  }

  @override
  String get apSending => 'Sending…';

  @override
  String get apSendingNote => 'Sending your decision to the workshop…';

  @override
  String apConfirmApproveTitle(String subject) {
    return 'Approve $subject?';
  }

  @override
  String apConfirmRejectTitle(String subject) {
    return 'Reject $subject?';
  }

  @override
  String apConfirmApproveEst(String amount) {
    return 'You are approving work totaling $amount.';
  }

  @override
  String apConfirmApproveEstVehicle(String amount, String vehicle) {
    return 'You are approving work totaling $amount for $vehicle.';
  }

  @override
  String apConfirmApproveSubject(String subject) {
    return 'You are approving this $subject.';
  }

  @override
  String apConfirmApproveSubjectVehicle(String subject, String vehicle) {
    return 'You are approving this $subject for $vehicle.';
  }

  @override
  String get apConfirmRejectEst =>
      'The workshop will be told you do not accept this estimate. You can ask them for a revised one.';

  @override
  String apConfirmRejectSubject(String subject) {
    return 'The workshop will be told you do not accept this $subject.';
  }

  @override
  String get apConfirm => 'Approve';

  @override
  String apConfirmReject(String subject) {
    return 'Reject $subject';
  }

  @override
  String get apNotNow => 'Not now';

  @override
  String get apKeepReviewing => 'Keep reviewing';

  @override
  String apApprovedToast(String label) {
    return '$label approved — the workshop has been told.';
  }

  @override
  String apRejectedToast(String label) {
    return '$label rejected — the workshop has been told.';
  }

  @override
  String get apDecisionFail =>
      'We couldn\'t send your decision. Please try again.';

  @override
  String get apRetry => 'Retry';

  @override
  String get apLabelEstimate => 'Estimate';

  @override
  String get apLabelJobCard => 'Job card';

  @override
  String get apLabelInspection => 'Inspection';

  @override
  String get invTitle => 'Invoice Detail';

  @override
  String get invBilledTo => 'Billed to';

  @override
  String get invIssued => 'Issued';

  @override
  String get invSubtotal => 'Subtotal';

  @override
  String invVat(String pct) {
    return 'VAT ($pct%)';
  }

  @override
  String get invTotal => 'Total';

  @override
  String get invReceiptNote => 'Your itemized workshop receipt.';

  @override
  String get fbTitle => 'Feedback';

  @override
  String get fbSubmitFail => 'Failed to submit feedback. Try again.';

  @override
  String get fbNext => 'Next';

  @override
  String get fbSubmit => 'Submit';

  @override
  String get fbThanks => 'Thank You';

  @override
  String get fbThanksBody => 'Your feedback helps us improve our service.';

  @override
  String get fbBookNext => 'Book Next Service';

  @override
  String get fbBackHome => 'Back to Home';

  @override
  String get fbOverallTitle => 'How was your experience?';

  @override
  String get fbCategoriesTitle => 'Rate specific areas';

  @override
  String get fbCatWork => 'Work Quality';

  @override
  String get fbCatComm => 'Communication';

  @override
  String get fbCatTime => 'Timeliness';

  @override
  String get fbCatValue => 'Value for Money';

  @override
  String get fbCommentTitle => 'Any other comments?';

  @override
  String get fbCommentHint => 'Tell us more (optional)';

  @override
  String get fbRecommend => 'Would you recommend us?';

  @override
  String get fbYes => 'Yes';

  @override
  String get fbNo => 'No';

  @override
  String get fbTagsTitle => 'What stood out?';

  @override
  String get fbTagFast => 'Fast Service';

  @override
  String get fbTagClean => 'Clean Bay';

  @override
  String get fbTagClear => 'Clear Advice';
}
