// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'staff_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class StaffLocalizationsEn extends StaffLocalizations {
  StaffLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Orient Staff';

  @override
  String get loginAppName => 'Orient Staff App';

  @override
  String get loginAppPurpose =>
      'Confirm bookings, check in vehicles, run inspections, assign repair work, update tasks, and complete QC.';

  @override
  String get loginIntendedUsers => 'For advisors, technicians, and supervisors';

  @override
  String get authSecurityNotice =>
      'By signing in, you agree to the Orient Staff App Terms of Service and Privacy Policy.';

  @override
  String get supervisorLoginTitle => 'Supervisor access';

  @override
  String get supervisorLoginSubtitle =>
      'Sign in to manage bookings, assignments, QC, and workshop operations.';

  @override
  String get supervisorAppName => 'Orient Supervisor Console';

  @override
  String get supervisorAppPurpose =>
      'Review incoming bookings, assign advisors and technicians, monitor jobs, and complete quality checks.';

  @override
  String get supervisorIntendedUsers => 'For workshop supervisors';

  @override
  String get supervisorUsernameLabel => 'Username or email';

  @override
  String get supervisorUsernameHint => 'Enter your username or email';

  @override
  String get supervisorEnterCredentials => 'Enter username and password';

  @override
  String get advisorNavToday => 'Today';

  @override
  String get advisorNavJobs => 'Jobs';

  @override
  String get advisorNavReports => 'Reports';

  @override
  String get advisorWorkspaceName => 'Advisor';

  @override
  String get advisorProfileLabel => 'Advisor Profile';

  @override
  String get advisorRoleEyebrow => 'SERVICE ADVISOR';

  @override
  String get advisorDeskTitle => 'Service Desk';

  @override
  String advisorGreeting(String name) {
    return 'Good to see you, $name';
  }

  @override
  String advisorShiftContext(String branch, String shift) {
    return '$branch · $shift';
  }

  @override
  String get advisorFreshnessLive => 'Live workshop data';

  @override
  String get advisorSearchPillTitle => 'Search intake, customer, or VIN…';

  @override
  String get advisorSearchPillSubtitle =>
      'Lookup repair orders, estimates & history';

  @override
  String get advisorQuickActionsEyebrow => 'Quick Actions';

  @override
  String get advisorActionScanTitle => 'Scan Vehicle';

  @override
  String get advisorActionScanSubtitle => 'VIN / Plate';

  @override
  String get advisorActionNewJobTitle => 'New Job Card';

  @override
  String get advisorActionNewJobSubtitle => 'Client intake';

  @override
  String get advisorActionInspectionTitle => 'Vehicle Inspection';

  @override
  String get advisorActionInspectionSubtitle => 'Checkpoints';

  @override
  String get advisorActionReportsTitle => 'Workshop Reports';

  @override
  String get advisorActionReportsSubtitle => 'Performance logs';

  @override
  String get advisorAttentionTitle => 'Needs Attention';

  @override
  String get advisorWorkSummary => 'Work Summary';

  @override
  String get advisorActionAnalytics => 'Analytics';

  @override
  String get advisorAssignedWorkOrders => 'Assigned Work Orders';

  @override
  String advisorViewAll(int count) {
    return 'View All ($count)';
  }

  @override
  String get advisorNoActiveJobs => 'No active job cards assigned';

  @override
  String get advisorMetricTotalOrders => 'Total Orders';

  @override
  String get advisorMetricInProgress => 'In Progress';

  @override
  String get advisorMetricDelivered => 'Delivered';

  @override
  String get advisorDataError => 'Some live workshop data could not be loaded.';

  @override
  String get advisorOfflineNotice =>
      'Showing saved data. Changes will sync when you\'re back online.';

  @override
  String get advisorActiveArrival => 'ACTIVE ARRIVAL';

  @override
  String get advisorConfirmedAppointment => 'CONFIRMED APPOINTMENT';

  @override
  String advisorClientPrefix(String name) {
    return 'Client: $name';
  }

  @override
  String get advisorJobsTitle => 'Workshop Job Cards';

  @override
  String get advisorJobsSearchHint =>
      'Search by registration, customer, or ID…';

  @override
  String get advisorFilterAll => 'All';

  @override
  String get advisorFilterInProgress => 'In Progress';

  @override
  String get advisorFilterCompleted => 'Completed';

  @override
  String get advisorFilterPending => 'Pending';

  @override
  String get advisorFilterQc => 'QC Check';

  @override
  String get advisorFilterCancelled => 'Cancelled';

  @override
  String get advisorAssignedIntakeQueue => 'Assigned intake queue';

  @override
  String advisorPendingCount(int count) {
    return '$count pending';
  }

  @override
  String get advisorActionCheckIn => 'Check In';

  @override
  String get advisorNoMatchingJobs => 'No matching job cards';

  @override
  String get advisorNoJobs => 'No job cards yet';

  @override
  String get advisorNoJobsHint =>
      'New job cards will appear here as they are created.';

  @override
  String get advisorReportsTitle => 'Advisor Analytics';

  @override
  String get advisorRangeToday => 'Today';

  @override
  String get advisorRangeWeek => 'This Week';

  @override
  String get advisorRangeMonth => 'This Month';

  @override
  String get advisorReportTotalJobs => 'Total jobs';

  @override
  String get advisorReportCompleted => 'Completed';

  @override
  String get advisorReportInProgress => 'In progress';

  @override
  String get advisorReportCancelled => 'Cancelled';

  @override
  String get advisorJobActivity => 'Job Activity';

  @override
  String get advisorStatusAllocation => 'Status Allocation';

  @override
  String get advisorExportCsv => 'Export CSV';

  @override
  String get advisorReportUnavailable =>
      'Report data is unavailable right now. Your job data has not been replaced with zeros.';

  @override
  String get advisorJobDetailsTitle => 'Job Card Details';

  @override
  String get advisorSectionNextStep => 'Next Step';

  @override
  String get advisorSectionCustomerDetails => 'Customer Details';

  @override
  String get advisorSectionVehicleDetails => 'Vehicle Details';

  @override
  String get advisorSectionFuelLevel => 'Fuel Level';

  @override
  String get advisorSectionBodyCondition => 'Vehicle Body Condition';

  @override
  String get advisorSectionWorkItems => 'Work Items';

  @override
  String get advisorSectionInspectionSummary => 'Inspection Summary';

  @override
  String get advisorSectionServiceInformation => 'Service Information';

  @override
  String get advisorSectionCustomerRequests => 'Customer Requests';

  @override
  String get advisorFieldName => 'Name';

  @override
  String get advisorFieldPhone => 'Phone';

  @override
  String get advisorFieldEmail => 'Email';

  @override
  String get advisorFieldGroup => 'Group';

  @override
  String get advisorFieldVehicle => 'Vehicle';

  @override
  String get advisorFieldPlate => 'Plate';

  @override
  String get advisorFieldVin => 'VIN';

  @override
  String get advisorFieldYear => 'Year';

  @override
  String get advisorFieldColor => 'Color';

  @override
  String get advisorFieldOdometer => 'Odometer';

  @override
  String get advisorFieldServiceType => 'Service Type';

  @override
  String get advisorFieldAdvisor => 'Advisor';

  @override
  String get advisorFieldTechnician => 'Technician';

  @override
  String get advisorFieldCreated => 'Created';

  @override
  String get advisorFieldLastUpdated => 'Last Updated';

  @override
  String get advisorFieldReference => 'Reference';

  @override
  String get advisorFieldGaugeLevel => 'Gauge Level';

  @override
  String get advisorServiceTypeInspection => 'Vehicle Inspection';

  @override
  String get advisorAdvisorAssigned => 'Assigned';

  @override
  String advisorOdometerValue(String value) {
    return '$value km';
  }

  @override
  String get advisorActionCallCustomer => 'Call Customer';

  @override
  String get advisorActionDeliverVehicle => 'Deliver Vehicle';

  @override
  String get advisorActionAddInspection => 'Add Inspection';

  @override
  String get advisorActionStartInspection => 'Start Inspection';

  @override
  String get advisorActionCreateEstimate => 'Create Estimate';

  @override
  String get advisorActionWaitingApproval => 'Waiting for Customer Approval';

  @override
  String get advisorActionAssignTechnician => 'Assign Technician';

  @override
  String get advisorActionReviewWorkItems => 'Review Work Items';

  @override
  String get advisorActionRefreshJobCard => 'Refresh Job Card';

  @override
  String get advisorVehicleAlreadyDelivered => 'Vehicle already delivered';

  @override
  String get advisorNextStepInspectionHint =>
      'Complete the inspection before continuing';

  @override
  String get advisorNextStepContinueHint =>
      'Continue this job card through the workshop';

  @override
  String get advisorWorkItemsHint =>
      'Tasks created from the completed inspection';

  @override
  String get advisorBodyConditionHint =>
      'Existing marks and damage recorded at intake';

  @override
  String advisorWorkItemsProgress(int done, int total) {
    return '$done/$total done';
  }

  @override
  String get advisorInspectionGood => 'Good';

  @override
  String get advisorInspectionFair => 'Fair';

  @override
  String get advisorInspectionPoor => 'Poor';

  @override
  String get advisorPackageTitle => 'Choose package';

  @override
  String get advisorPackageSubtitle =>
      'Pick the inspection depth for this vehicle. You can switch packages before starting.';

  @override
  String get advisorPackageQuick => 'Quick 20-Point Check';

  @override
  String get advisorPackageQuickDesc =>
      'Fast safety sweep for intake and express bays.';

  @override
  String get advisorPackageFull => 'Comprehensive 60-Point Check';

  @override
  String get advisorPackageFullDesc =>
      'Full under-hood, brakes, suspension, battery, tires and exterior inspection.';

  @override
  String get advisorPackageSafety => 'Safety and Roadworthiness Audit';

  @override
  String get advisorPackageSafetyDesc =>
      'Brake, steering, restraint and lighting audit for roadworthiness sign-off.';

  @override
  String advisorPackageDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String advisorPackageCheckpoints(int count) {
    return '$count checkpoints';
  }

  @override
  String advisorPackageSections(int count) {
    return '$count sections';
  }

  @override
  String get advisorPackageFocus => 'Focus areas';

  @override
  String get advisorFocusBrakes => 'Brakes';

  @override
  String get advisorFocusEngine => 'Engine';

  @override
  String get advisorFocusSuspension => 'Suspension';

  @override
  String get advisorFocusLighting => 'Lighting';

  @override
  String get advisorPackageRecommended => 'Recommended';

  @override
  String get advisorPackageSelected => 'Selected';

  @override
  String get advisorPackageStart => 'Continue';

  @override
  String get advisorPackageSortRecommended => 'Recommended';

  @override
  String get advisorPackageSortQuickest => 'Quickest';

  @override
  String get advisorPackageSortThorough => 'Most thorough';

  @override
  String get advisorPackageSkip => 'Skip';

  @override
  String get advisorHudTitle => 'Inspection workspace';

  @override
  String advisorHudProgress(int done, int total) {
    return '$done of $total checkpoints';
  }

  @override
  String get advisorHudTabDamage => 'Damage map';

  @override
  String get advisorHudTabChecks => 'Checkpoints';

  @override
  String get advisorHudCanvasTitle => 'Damage canvas';

  @override
  String get advisorHudCanvasHint =>
      'Tap a body part to log damage. Pinch to zoom, drag to pan.';

  @override
  String get advisorHudKindTitle => 'What kind of damage?';

  @override
  String get advisorHudKindMinor => 'Minor scratch';

  @override
  String get advisorHudKindMinorHint => 'Scuff or surface scratch';

  @override
  String get advisorHudKindStructural => 'Structural dent';

  @override
  String get advisorHudKindStructuralHint => 'Deep dent or deformation';

  @override
  String get advisorHudKindGlass => 'Glass or lamp crack';

  @override
  String get advisorHudKindGlassHint => 'Cracked glass or lamp assembly';

  @override
  String get advisorHudPinsTitle => 'Damage pins';

  @override
  String get advisorHudNoPins => 'No damage pinned yet';

  @override
  String get advisorHudNoPinsHint =>
      'Tap the car above to log the first damage point.';

  @override
  String get advisorHudDeletePin => 'Delete pin';

  @override
  String get advisorHudZoneFront => 'Front';

  @override
  String get advisorHudZoneFrontLeft => 'Front left';

  @override
  String get advisorHudZoneSideLeft => 'Left side';

  @override
  String get advisorHudZoneRearLeft => 'Rear left';

  @override
  String get advisorHudZoneRear => 'Rear';

  @override
  String get advisorHudZoneRearRight => 'Rear right';

  @override
  String get advisorHudZoneSideRight => 'Right side';

  @override
  String get advisorHudZoneFrontRight => 'Front right';

  @override
  String get advisorHudRingPass => 'Pass';

  @override
  String get advisorHudRingCaution => 'Caution';

  @override
  String get advisorHudRingFail => 'Fail';

  @override
  String get advisorHudMarkAllPass => 'All pass';

  @override
  String get advisorHudSearchHint => 'Search checkpoints…';

  @override
  String get advisorHudNoMatch => 'No matching checkpoints';

  @override
  String advisorHudSectionRemaining(int count) {
    return '$count remaining';
  }

  @override
  String get advisorHudSectionDone => 'All checkpoints completed';

  @override
  String get advisorHudDockTitle => 'Voice and photo evidence';

  @override
  String get advisorHudVoiceIdle => 'Tap to record a voice note';

  @override
  String advisorHudVoiceRecording(int seconds) {
    return 'Recording… ${seconds}s';
  }

  @override
  String get advisorHudVoicePlay => 'Play';

  @override
  String get advisorHudVoiceDelete => 'Delete recording';

  @override
  String get advisorHudVoiceSaved => 'Voice note saved';

  @override
  String get advisorHudMicDenied => 'Microphone access denied';

  @override
  String get advisorHudMicDeniedHint =>
      'Enable microphone access in system settings to record voice notes.';

  @override
  String get advisorHudCameraDenied => 'Camera access denied';

  @override
  String get advisorHudCameraDeniedHint =>
      'Enable camera access in system settings to capture photo evidence.';

  @override
  String get advisorHudGalleryDenied => 'Gallery access denied';

  @override
  String get advisorHudGalleryDeniedHint =>
      'Enable gallery access in system settings to attach photos.';

  @override
  String get advisorHudOpenSettings => 'Open settings';

  @override
  String get advisorHudPhotoRetry => 'Tap to retry';

  @override
  String get advisorHudPhotoError =>
      'Photo failed to attach. Check storage and try again.';

  @override
  String get advisorHudReview => 'Review inspection';

  @override
  String get advisorHudNotifyOwner => 'Notify owner after submission';

  @override
  String get advisorHudTemplateError =>
      'We couldn\'t load the inspection template. Check your connection and try again.';

  @override
  String get advisorHudRetry => 'Retry';

  @override
  String get advisorHudAddNote => 'Add note';

  @override
  String get advisorHudClear => 'Clear';

  @override
  String get advisorHudResetGrade => 'Reset grade';

  @override
  String get advisorHudDone => 'Done';

  @override
  String get advisorHudDoneMarking => 'Done marking';

  @override
  String get advisorHudContinue => 'Continue';

  @override
  String get advisorHudShowPins => 'Show list';

  @override
  String get advisorHudLegendTitle => 'Severity legend';

  @override
  String get advisorHudHidePins => 'Hide';

  @override
  String get advisorDamageKindScratch => 'Scratch / Scuff';

  @override
  String get advisorDamageKindDent => 'Dent';

  @override
  String get advisorDamageKindCrack => 'Crack';

  @override
  String get advisorDamageKindPaint => 'Paint damage';

  @override
  String get advisorDamageKindBroken => 'Broken / Missing';

  @override
  String get advisorDamageMinor => 'Minor';

  @override
  String get advisorDamageModerate => 'Moderate';

  @override
  String get advisorDamageSevere => 'Severe';

  @override
  String get advisorDamageSizeCoin => 'Coin';

  @override
  String get advisorDamageSizePalm => 'Palm';

  @override
  String get advisorDamageSizeSpan => 'Hand span';

  @override
  String get advisorDamageCatBody => 'Body';

  @override
  String get advisorDamageCatGlass => 'Glass';

  @override
  String get advisorDamageCatWheel => 'Wheel';

  @override
  String get advisorDamageCatLight => 'Light';

  @override
  String get advisorDamageCatMirror => 'Mirror';

  @override
  String get advisorDamageLogTitle => 'Log damage';

  @override
  String get advisorDamageEditTitle => 'Edit damage';

  @override
  String get advisorDamageKindSection => 'Damage kind';

  @override
  String get advisorDamageSeveritySection => 'Severity';

  @override
  String get advisorDamageSizeSection => 'Size';

  @override
  String get advisorDamageSizeOptional => 'Optional';

  @override
  String get advisorDamagePhotoSection => 'Photo evidence';

  @override
  String get advisorDamagePhotoRequired =>
      'A photo is required for Moderate and Severe damage.';

  @override
  String get advisorDamageAddPhoto => 'Add photo';

  @override
  String get advisorDamageNoteHint => 'Add a note (optional)';

  @override
  String get advisorDamageVoiceSection => 'Voice note';

  @override
  String get advisorDamageAddPin => 'Add pin';

  @override
  String get advisorDamageSaveChanges => 'Save changes';

  @override
  String get advisorDamageKindRequired => 'Choose a damage kind to continue.';

  @override
  String get advisorDamageDeleteTitle => 'Delete this pin?';

  @override
  String get advisorDamageDelete => 'Delete';

  @override
  String get advisorDamageEdit => 'Edit';

  @override
  String get advisorDamageMapLoading => 'Loading vehicle map…';

  @override
  String get advisorDamageMapError => 'Vehicle map could not be loaded.';

  @override
  String get advisorDamageResetView => 'Reset view';

  @override
  String get advisorDamageZoomIn => 'Zoom in';

  @override
  String get advisorDamageZoomOut => 'Zoom out';

  @override
  String get advisorPartFrontBumper => 'Front Bumper';

  @override
  String get advisorPartHood => 'Hood / Bonnet';

  @override
  String get advisorPartFrontLeftHeadlight => 'Front Left Headlight';

  @override
  String get advisorPartFrontRightHeadlight => 'Front Right Headlight';

  @override
  String get advisorPartFrontWindshield => 'Front Windshield';

  @override
  String get advisorPartRoof => 'Roof';

  @override
  String get advisorPartRearWindshield => 'Rear Windshield';

  @override
  String get advisorPartTrunk => 'Boot / Trunk';

  @override
  String get advisorPartRearBumper => 'Rear Bumper';

  @override
  String get advisorPartFrontLeftFender => 'Front Left Fender';

  @override
  String get advisorPartFrontRightFender => 'Front Right Fender';

  @override
  String get advisorPartFrontLeftDoor => 'Front Left Door';

  @override
  String get advisorPartRearLeftDoor => 'Rear Left Door';

  @override
  String get advisorPartFrontRightDoor => 'Front Right Door';

  @override
  String get advisorPartRearRightDoor => 'Rear Right Door';

  @override
  String get advisorPartRearLeftQuarter => 'Rear Left Quarter Panel';

  @override
  String get advisorPartRearRightQuarter => 'Rear Right Quarter Panel';

  @override
  String get advisorPartLeftMirror => 'Left Mirror';

  @override
  String get advisorPartRightMirror => 'Right Mirror';

  @override
  String get advisorPartFrontLeftWheel => 'Front Left Wheel / Tyre';

  @override
  String get advisorPartFrontRightWheel => 'Front Right Wheel / Tyre';

  @override
  String get advisorPartRearLeftWheel => 'Rear Left Wheel / Tyre';

  @override
  String get advisorPartRearRightWheel => 'Rear Right Wheel / Tyre';

  @override
  String get advisorPartRearLeftTaillight => 'Rear Left Tail Light';

  @override
  String get advisorPartRearRightTaillight => 'Rear Right Tail Light';

  @override
  String get advisorHealthTitle => 'Vehicle health report';

  @override
  String get advisorHealthSubtitle =>
      'Review every finding before converting or submitting.';

  @override
  String advisorHealthScore(int score) {
    return '$score% overall health';
  }

  @override
  String advisorHealthScoredOf(int done, int total) {
    return '$done of $total checkpoints graded';
  }

  @override
  String get advisorHealthMandatory => 'Mandatory safety items';

  @override
  String get advisorHealthRecommended => 'Recommended maintenance';

  @override
  String get advisorHealthGoodGroup => 'Good condition';

  @override
  String get advisorHealthConvert => 'Convert to estimate';

  @override
  String get advisorHealthSubmit => 'Submit inspection';

  @override
  String get advisorHealthSubmitting => 'Submitting inspection…';

  @override
  String get advisorHealthEmpty => 'No checkpoints rated yet';

  @override
  String get advisorHealthEmptyHint =>
      'Grade at least one checkpoint to build this health report.';

  @override
  String advisorHealthRemaining(int count) {
    return '$count checkpoints still need a condition';
  }

  @override
  String get advisorHealthBackEdit => 'Back to edit';

  @override
  String advisorHealthReady(int count) {
    return '$count checkpoints ready to submit';
  }

  @override
  String get advisorHealthSubmitTitle => 'Submit this inspection?';

  @override
  String get advisorHealthSubmitMessage =>
      'Confirm that the checkpoint grades, damage pins and attachments are correct.';

  @override
  String get advisorHealthReviewAgain => 'Review again';

  @override
  String advisorHealthAttachments(int count) {
    return '$count attachments';
  }

  @override
  String get advisorHealthShare => 'Share';

  @override
  String get advisorHealthExport => 'Export';

  @override
  String get advisorHealthCopied => 'Report copied to clipboard';

  @override
  String get advisorHealthExpand => 'Show';

  @override
  String get advisorHealthCollapse => 'Hide';

  @override
  String get advisorJobDetailLoadError =>
      'We couldn\'t load this job card. Check your connection and try again.';

  @override
  String get advisorProfileMyProfile => 'My Profile';

  @override
  String get advisorProfileAttendance => 'Attendance · Punch In / Out';

  @override
  String get advisorProfileLogout => 'Logout';

  @override
  String get advisorOnShift => 'On Shift';

  @override
  String get advisorNotificationsTitle => 'Notifications';

  @override
  String get advisorClearAll => 'Clear all';

  @override
  String get advisorNoNotifications => 'No notifications yet';

  @override
  String get advisorNoNotificationsHint =>
      'Approval updates and reminders will appear here.';

  @override
  String get advisorSearchTitle => 'Search';

  @override
  String get advisorSearchHint =>
      'Search customers, vehicles, job cards, approvals…';

  @override
  String get advisorNoResults => 'No results found';

  @override
  String get advisorSearchGroupJobCards => 'Job Cards';

  @override
  String get advisorSearchGroupCustomers => 'Customers / Vehicles';

  @override
  String get advisorSearchGroupApprovals => 'Approvals';

  @override
  String get advisorActionSendBack => 'Send Back';

  @override
  String get advisorActionApprove => 'Approve';

  @override
  String get advisorActionReview => 'Review';

  @override
  String get advisorContactCall => 'Call';

  @override
  String get advisorContactWhatsApp => 'WhatsApp';

  @override
  String get advisorContactSms => 'SMS';

  @override
  String get advisorActionMarkReminderDone => 'Mark Reminder as Done';

  @override
  String get advisorStatViewAllHint => 'Tap below to view the full list';

  @override
  String get advisorActionClose => 'Close';

  @override
  String get advisorActionViewAll => 'View all';

  @override
  String advisorToastApproved(String type, String id) {
    return '$type $id approved';
  }

  @override
  String advisorToastRejected(String type, String id) {
    return '$type $id rejected';
  }

  @override
  String advisorToastCalling(String name) {
    return 'Calling $name…';
  }

  @override
  String get advisorToastOpeningWhatsApp => 'Opening WhatsApp…';

  @override
  String get advisorToastSmsSent => 'SMS sent';

  @override
  String get advisorToastMarkedDone => 'Marked as completed';

  @override
  String get advisorStatusPending => 'Pending';

  @override
  String get advisorStatusInProgress => 'In Progress';

  @override
  String get advisorStatusCompleted => 'Completed';

  @override
  String get advisorStatusWaitingParts => 'Waiting Parts';

  @override
  String get advisorStatusQc => 'QC Check';

  @override
  String get advisorStatusCancelled => 'Cancelled';

  @override
  String get advisorStatusAwaitingSupervisor => 'Awaiting Supervisor';

  @override
  String get advisorStatusVehicleReceived => 'Vehicle Received';

  @override
  String get advisorStatusInspected => 'Inspected';

  @override
  String get advisorStatusApproved => 'Approved';

  @override
  String get advisorStatusWorkAssigned => 'Work Assigned';

  @override
  String get advisorStatusWaitingCustomerApproval =>
      'Waiting Customer Approval';

  @override
  String get advisorStatusDelivered => 'Delivered';

  @override
  String get advisorStatusQcPassed => 'QC Passed';

  @override
  String get advisorStatusPendingApproval => 'Pending Approval';

  @override
  String get advisorIntakeTitle => 'Create Job Card';

  @override
  String get advisorIntakeIntroTitleNew => 'New vehicle intake';

  @override
  String get advisorIntakeIntroTitleBooking => 'Complete the vehicle intake';

  @override
  String get advisorIntakeIntroBody =>
      'Find an existing record or enter the customer and vehicle details below.';

  @override
  String get advisorIntakeRequiredHint => 'Only fields marked * are required';

  @override
  String get advisorIntakeLinkedBooking => 'Linked to the assigned booking';

  @override
  String get advisorIntakeStepCustomer => 'Customer';

  @override
  String get advisorIntakeStepVehicle => 'Vehicle';

  @override
  String get advisorIntakeStepMedia => 'Media & docs';

  @override
  String get advisorIntakeStepJob => 'Job';

  @override
  String get advisorIntakeStepSignature => 'Signature';

  @override
  String get advisorIntakeStepReview => 'Save';

  @override
  String get advisorIntakeSectionCustomer => 'Customer details';

  @override
  String get advisorIntakeSectionCustomerSub =>
      'Who is bringing in the vehicle?';

  @override
  String get advisorIntakeSectionVehicle => 'Vehicle details';

  @override
  String get advisorIntakeSectionVehicleSub =>
      'Registration and service information';

  @override
  String get advisorIntakeSectionBody => 'Vehicle body condition';

  @override
  String get advisorIntakeSectionBodySub =>
      'Mark any existing damage before handover';

  @override
  String get advisorIntakeSectionMedia => 'Documents & media';

  @override
  String get advisorIntakeSectionMediaSub =>
      'Attach documents, photos and videos';

  @override
  String get advisorIntakeSectionJob => 'Job description';

  @override
  String get advisorIntakeSectionJobSub => 'Describe the requested work';

  @override
  String get advisorIntakeSectionSignature => 'Signatures';

  @override
  String get advisorIntakeSectionSignatureSub =>
      'Capture customer and advisor consent';

  @override
  String get advisorIntakeSectionReview => 'Review & save';

  @override
  String get advisorIntakeSectionReviewSub =>
      'Confirm the details before creating the job card';

  @override
  String get advisorIntakeFindTitle => 'Find existing record';

  @override
  String get advisorIntakeFindSub =>
      'Avoid duplicate customer and vehicle records';

  @override
  String get advisorIntakeFindHint =>
      'Mobile, customer name, plate number, or VIN';

  @override
  String get advisorIntakeScanVin => 'Scan VIN';

  @override
  String get advisorIntakeScanQr => 'Scan vehicle QR';

  @override
  String get advisorIntakeB2B => 'B2B customer';

  @override
  String get advisorIntakeCustomerName => 'Customer name';

  @override
  String get advisorIntakeCustomerNameHint => 'Customer name';

  @override
  String get advisorIntakePhone => 'Phone number';

  @override
  String get advisorIntakePhoneHint => 'Phone number';

  @override
  String get advisorIntakeEmail => 'Email address';

  @override
  String get advisorIntakeEmailHint => 'Email';

  @override
  String get advisorIntakeCustomerGroup => 'Customer group';

  @override
  String get advisorIntakeCustomerGroupHint => 'Select customer group';

  @override
  String get advisorIntakeGender => 'Gender';

  @override
  String get advisorIntakeGenderHint => 'Select gender';

  @override
  String get advisorIntakeAddress => 'Address';

  @override
  String get advisorIntakeAddressHint => 'Select address';

  @override
  String get advisorIntakeTaxNumber => 'Tax number';

  @override
  String get advisorIntakeSource => 'Source';

  @override
  String get advisorIntakeSourceHint => 'How did you hear about us?';

  @override
  String get advisorIntakeShowMore => 'Show more';

  @override
  String get advisorIntakeShowLess => 'Show less';

  @override
  String get advisorIntakeEmirate => 'Emirate';

  @override
  String get advisorIntakeEmirateHint => 'Select emirate';

  @override
  String get advisorIntakePlateCode => 'Plate code';

  @override
  String get advisorIntakePlateCodeHint => 'A';

  @override
  String get advisorIntakePlateNumber => 'Plate number';

  @override
  String get advisorIntakePlateNumberHint => '2500';

  @override
  String get advisorIntakeVin => 'VIN (chassis number)';

  @override
  String get advisorIntakeVinHint => 'VIN (chassis number)';

  @override
  String get advisorIntakeMake => 'Make';

  @override
  String get advisorIntakeMakeHint => 'Select brand';

  @override
  String get advisorIntakeModel => 'Model';

  @override
  String get advisorIntakeModelHint => 'Select model';

  @override
  String get advisorIntakeModelYear => 'Model year';

  @override
  String get advisorIntakeModelYearHint => 'Select model year';

  @override
  String get advisorIntakeSelectBrandFirst => 'Please select a brand first';

  @override
  String get advisorIntakeCylinders => 'Number of cylinders';

  @override
  String get advisorIntakeCylindersHint => 'Number of cylinders';

  @override
  String get advisorIntakeEngineCapacity => 'Engine capacity';

  @override
  String get advisorIntakeVehicleColor => 'Vehicle colour';

  @override
  String get advisorIntakeFuelType => 'Fuel type';

  @override
  String get advisorIntakeFuelTypeHint => 'Select fuel type';

  @override
  String get advisorIntakeEngineNumber => 'Engine number';

  @override
  String get advisorIntakeRegistrationCertificate => 'Registration certificate';

  @override
  String get advisorIntakeAddDocument => 'Add document';

  @override
  String get advisorIntakeJobCategory => 'Job category';

  @override
  String get advisorIntakeJobCategoryHint => 'Select job category';

  @override
  String get advisorIntakeInsuranceName => 'Insurance name';

  @override
  String get advisorIntakeInsuranceNameHint => 'Select insurance provider';

  @override
  String get advisorIntakeLpoNumber => 'LPO number';

  @override
  String get advisorIntakePolicyNumber => 'Policy number';

  @override
  String get advisorIntakeAccidentNumber => 'Accident number';

  @override
  String get advisorIntakeInsuranceTaxNumber => 'Insurance tax number';

  @override
  String get advisorIntakeInsuranceTaxHint => 'Enter insurance tax number';

  @override
  String get advisorIntakeInsuranceAddress => 'Insurance address';

  @override
  String get advisorIntakeInsuranceExpiry => 'Insurance expiry date';

  @override
  String get advisorIntakeInsuranceDocument => 'Insurance document';

  @override
  String get advisorIntakeMarkupType => 'Markup type';

  @override
  String get advisorIntakeOrderType => 'Order type';

  @override
  String get advisorIntakeJobDescription => 'Job description';

  @override
  String get advisorIntakeAddDescription => 'Add another description';

  @override
  String get advisorIntakeRemoveRow => 'Remove row';

  @override
  String get advisorIntakeDescriptionHint =>
      'Describe the requested work. Use the toolbar to bold or add bullet points.';

  @override
  String get advisorIntakePriority => 'Priority';

  @override
  String get advisorIntakeSelectPriority => 'Select priority';

  @override
  String get advisorIntakeAttachments => 'Attachments';

  @override
  String get advisorIntakePhotos => 'Photos';

  @override
  String get advisorIntakeVideo => 'Video';

  @override
  String get advisorIntakeAudio => 'Audio';

  @override
  String get advisorIntakeBold => 'Bold';

  @override
  String get advisorIntakeItalic => 'Italic';

  @override
  String get advisorIntakeBullet => 'Bullet list';

  @override
  String advisorIntakeCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String advisorIntakeAddLabel(String label) {
    return 'Add $label';
  }

  @override
  String get advisorIntakeOdometer => 'Odometer reading (km)';

  @override
  String get advisorIntakeOdometerHint => 'Odometer (in km)';

  @override
  String get advisorIntakeFuelLevel => 'Fuel level';

  @override
  String get advisorIntakeCustomerConsent => 'Customer consent';

  @override
  String get advisorIntakeJobMedia => 'Job card photos and videos';

  @override
  String get advisorIntakeDigitalSignatures => 'Digital signatures';

  @override
  String get advisorIntakeSignatureCustomer => 'Customer';

  @override
  String get advisorIntakeSignatureAdvisor => 'Advisor';

  @override
  String get advisorIntakeSignatureCustomerTitle => 'Customer signature';

  @override
  String get advisorIntakeSignatureAdvisorTitle => 'Advisor signature';

  @override
  String get advisorIntakeSignatureInstruction => 'Sign in the box below';

  @override
  String get advisorIntakeSignatureClear => 'Clear';

  @override
  String get advisorIntakeSignatureUse => 'Use signature';

  @override
  String get advisorIntakeSignatureCaptured => 'Signed';

  @override
  String get advisorIntakeSignatureRedo => 'Redo';

  @override
  String get advisorIntakeAddRegistration => 'Add registration certificate';

  @override
  String get advisorIntakeAddInsurance => 'Add insurance document';

  @override
  String get advisorIntakeTakePhoto => 'Take a photo';

  @override
  String get advisorIntakeChooseGallery => 'Choose from gallery';

  @override
  String get advisorIntakeRecordVideo => 'Record video';

  @override
  String get advisorIntakeChooseVideo => 'Choose video';

  @override
  String get advisorIntakeAudioTitle => 'Job description audio';

  @override
  String advisorIntakeAudioRecording(int seconds) {
    return 'Recording… $seconds seconds';
  }

  @override
  String get advisorIntakeAudioReplace =>
      'Record again to replace the current audio.';

  @override
  String get advisorIntakeAudioPrompt =>
      'Record a voice note up to 60 seconds.';

  @override
  String get advisorIntakeErrCustomerName => 'Please enter the customer name';

  @override
  String get advisorIntakeErrPhone => 'Please enter a mobile number';

  @override
  String get advisorIntakeErrPhoneValid => 'Please enter a valid mobile number';

  @override
  String get advisorIntakeErrPlate => 'Please enter the plate number';

  @override
  String get advisorIntakeErrMake => 'Please select the vehicle brand';

  @override
  String get advisorIntakeErrModel => 'Please select the vehicle model';

  @override
  String get advisorIntakeSyncedTitle => 'Job card created & synced';

  @override
  String get advisorIntakeLocalTitle => 'Job card saved locally';

  @override
  String get advisorIntakeSyncedBody =>
      'Saved to this device and the server. Would you like to start the inspection?';

  @override
  String get advisorIntakeLocalBody =>
      'The API could not be reached. The job card is safely stored and queued for automatic sync.';

  @override
  String get advisorIntakeAddInspection => 'Add inspection';

  @override
  String get advisorIntakeSkip => 'Skip';

  @override
  String get advisorIntakeSaveFailed =>
      'We could not create the job card. Please check your connection and try again.';

  @override
  String get advisorIntakeOfflineNotice =>
      'You are offline. The job card will be stored on this device and synced automatically.';

  @override
  String get advisorIntakeSummaryTitle => 'Live summary';

  @override
  String get advisorIntakeSummaryEmpty =>
      'Start filling in the details to see a live summary.';

  @override
  String get advisorIntakeSummaryNoName => 'No customer yet';

  @override
  String get advisorIntakeSummaryCustomer => 'Customer';

  @override
  String get advisorIntakeSummaryVehicle => 'Vehicle';

  @override
  String advisorIntakeSummaryProgress(int done, int total) {
    return '$done of $total sections complete';
  }

  @override
  String get advisorIntakeDiscardTitle => 'Discard this intake?';

  @override
  String get advisorIntakeDiscardBody =>
      'You have unsaved changes. Leaving now will lose the information you entered.';

  @override
  String get advisorIntakeDiscardConfirm => 'Discard';

  @override
  String get advisorIntakeDiscardCancel => 'Keep editing';

  @override
  String get advisorIntakeActionCreate => 'Create job card';

  @override
  String get advisorIntakeActionCreating => 'Creating job card…';

  @override
  String get advisorIntakeStatusSaving => 'Saving locally…';

  @override
  String get advisorIntakeStatusQueued => 'Queued (offline)';

  @override
  String get advisorIntakeStatusSent => 'Sent';

  @override
  String advisorIntakeSectionOf(int index, int total) {
    return 'Section $index of $total';
  }

  @override
  String get advisorScanTitle => 'Scan vehicle';

  @override
  String get advisorScanModePlate => 'Plate';

  @override
  String get advisorScanModeVin => 'VIN';

  @override
  String get advisorScanModeQr => 'QR';

  @override
  String get advisorScanHintPlate => 'Point the camera at the license plate';

  @override
  String get advisorScanHintVin => 'Scan the VIN barcode on the dashboard';

  @override
  String get advisorScanHintQr => 'Scan the vehicle QR code';

  @override
  String get advisorScanManual => 'Or enter manually';

  @override
  String get advisorScanManualHint => 'Plate / VIN / Customer name…';

  @override
  String get advisorScanPermissionTitle => 'Camera permission required';

  @override
  String get advisorScanPermissionBody =>
      'Camera access is needed to scan. Enable it in settings to continue.';

  @override
  String get advisorScanOpenSettings => 'Open settings';

  @override
  String get advisorScanGrant => 'Grant permission';

  @override
  String get advisorScanStarting => 'Starting camera…';

  @override
  String get advisorScanScanning => 'Scanning…';

  @override
  String get advisorScanCameraUnavailable => 'Camera not available';

  @override
  String get advisorScanTorch => 'Toggle torch';

  @override
  String get advisorScanResultTitle => 'Scan result';

  @override
  String get advisorScanResultUse => 'Use this value';

  @override
  String get advisorScanEnterValue => 'Enter a value to continue';

  @override
  String get advisorCheckInTitle => 'Vehicle check-in';

  @override
  String get advisorCheckInStepDetails => 'Odometer & fuel';

  @override
  String get advisorCheckInStepCondition => 'Document condition';

  @override
  String get advisorCheckInOdometer => 'Odometer reading (km)';

  @override
  String get advisorCheckInOdometerHint => 'e.g. 14200';

  @override
  String get advisorCheckInFuel => 'Fuel level';

  @override
  String get advisorCheckInNotes => 'Customer notes';

  @override
  String get advisorCheckInNotesHint => 'Add any notes from the customer';

  @override
  String get advisorCheckInNext => 'Next: document condition';

  @override
  String get advisorCheckInBack => 'Back';

  @override
  String get advisorCheckInFront => 'Front';

  @override
  String get advisorCheckInRear => 'Rear';

  @override
  String get advisorCheckInLeft => 'Left side';

  @override
  String get advisorCheckInRight => 'Right side';

  @override
  String get advisorCheckInRoof => 'Roof';

  @override
  String get advisorCheckInAddDamage => 'Add damage';

  @override
  String advisorCheckInDamageTitle(String area) {
    return 'Damage on $area';
  }

  @override
  String get advisorCheckInDamageHint => 'Describe damage (e.g. scratch, dent)';

  @override
  String get advisorCheckInAdd => 'Add';

  @override
  String get advisorCheckInComplete => 'Complete check-in';

  @override
  String get advisorCheckInSuccess => 'Vehicle checked in successfully';

  @override
  String get advisorCheckInFailed => 'Failed to check in. Please try again.';

  @override
  String advisorCheckInError(String message) {
    return 'Error: $message';
  }

  @override
  String get advisorCheckInEmptyDamages => 'No damage recorded yet';

  @override
  String get advisorCheckInSectionDetails => 'Odometer, fuel & notes';

  @override
  String get advisorCheckInSectionDamage => 'Existing damage';

  @override
  String get advisorCheckInSectionDamageSub =>
      'Tap an area to record any existing damage';

  @override
  String get advisorCheckInRemoveDamage => 'Remove damage';

  @override
  String get advisorJobsColumnCustomer => 'Customer';

  @override
  String get advisorJobsColumnJobCard => 'Job Card';

  @override
  String get advisorJobsColumnStatus => 'Status';

  @override
  String get advisorJobsColumnTime => 'Time';

  @override
  String get advisorJobsSelectPrompt =>
      'Select a job card to preview the details';

  @override
  String get advisorActionOpenJob => 'Open Job Card';

  @override
  String get advisorActionMore => 'More actions';

  @override
  String get advisorIntakeWizardNext => 'Continue';

  @override
  String get advisorIntakeWizardBack => 'Back';

  @override
  String advisorIntakeWizardStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get advisorIntakeWizardContactTitle => 'Customer contact';

  @override
  String get advisorIntakeWizardContactSub =>
      'Find an existing customer or add a new one';

  @override
  String get advisorIntakeWizardVehicleTitle => 'Vehicle & plate';

  @override
  String get advisorIntakeWizardVehicleSub =>
      'Plate, VIN, brand, model and year';

  @override
  String get advisorIntakeWizardCaptureTitle => 'Photo capture';

  @override
  String get advisorIntakeWizardCaptureSub => 'Documents, photos and readings';

  @override
  String get advisorIntakeWizardSignoffTitle => 'Scope & sign-off';

  @override
  String get advisorIntakeWizardSignoffSub =>
      'Job scope, signatures and review';

  @override
  String get advisorIntakeWizardDraftRestored => 'Previous draft restored';

  @override
  String get advisorIntakeWizardBlocked => 'Complete this step to continue';

  @override
  String get advisorScanDecodeIdle => 'Align the code inside the frame';

  @override
  String get advisorScanTipsTitle => 'Scanning tips';

  @override
  String get advisorScanTipAlign => 'Hold steady 15–20 cm from the code';

  @override
  String get advisorScanTipLight => 'Use the torch in low light';

  @override
  String get advisorScanTipManual =>
      'Can\'t scan? Enter the value manually — nothing is lost';

  @override
  String get advisorScanViewfinderLabel => 'Camera viewfinder';

  @override
  String get advisorCheckInFuelEmpty => 'Empty';

  @override
  String get advisorCheckInFuelQuarter => '1/4';

  @override
  String get advisorCheckInFuelHalf => '1/2';

  @override
  String get advisorCheckInFuelThreeQuarter => '3/4';

  @override
  String get advisorCheckInFuelFull => 'Full';

  @override
  String get advisorCheckInOdoTitle => 'Odometer drums';

  @override
  String get advisorCheckInOdoUnit => 'km';

  @override
  String get advisorCheckInOdoPlus1k => '+1k';

  @override
  String get advisorCheckInOdoPlus10k => '+10k';

  @override
  String get advisorCheckInOdoClear => 'Reset';

  @override
  String get advisorCheckInConfirmTitle => 'Confirm check-in';

  @override
  String get advisorCheckInConfirmBody =>
      'Review the readings before handing the vehicle to inspection.';

  @override
  String get advisorCheckInClusterSub => 'Live telemetry for this reception';

  @override
  String get advisorDeliveryTitle => 'Vehicle handover';

  @override
  String get advisorDeliverySubtitle => 'Formal delivery protocol';

  @override
  String get advisorDeliveryChecklistTitle => 'Handover checklist';

  @override
  String advisorDeliveryProgress(int done, int total) {
    return '$done of $total verified';
  }

  @override
  String get advisorDeliveryCheckInvoice => 'Invoice copy provided to customer';

  @override
  String get advisorDeliveryCheckKeys => 'Vehicle keys handed over';

  @override
  String get advisorDeliveryCheckDocs => 'Vehicle documents returned';

  @override
  String get advisorDeliveryCheckService => 'Next service reminder given';

  @override
  String get advisorDeliveryCheckWarranty => 'Warranty information explained';

  @override
  String get advisorDeliveryMileage => 'Final mileage (km)';

  @override
  String get advisorDeliveryMileageHint => 'e.g. 48250';

  @override
  String get advisorDeliveryMileageError =>
      'Enter the final mileage to complete handover';

  @override
  String get advisorDeliveryRating => 'Customer satisfaction';

  @override
  String advisorDeliveryRatingValue(int value) {
    return 'Rated $value of 5';
  }

  @override
  String get advisorDeliveryNotes => 'Delivery notes';

  @override
  String get advisorDeliveryNotesHint =>
      'Customer feedback, return requests, warranty notes…';

  @override
  String get advisorDeliverySignature => 'Customer sign-off';

  @override
  String get advisorDeliverySignatureHint =>
      'Capture the customer signature to close the protocol';

  @override
  String get advisorDeliverySignAction => 'Capture signature';

  @override
  String get advisorDeliverySigned => 'Signed';

  @override
  String get advisorDeliveryComplete => 'Complete handover';

  @override
  String advisorDeliveryRemaining(int count) {
    return '$count checks remaining';
  }

  @override
  String get advisorDeliverySuccess => 'Vehicle delivered successfully';

  @override
  String get advisorDeliveryFailed => 'Failed to complete delivery';

  @override
  String advisorDeliveryError(String message) {
    return 'Error: $message';
  }

  @override
  String advisorIntakeAttachmentError(String message) {
    return 'Could not add attachment: $message';
  }
}
