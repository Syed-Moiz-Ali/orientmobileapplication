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
  String get advisorTodayEyebrow => 'Today';

  @override
  String get advisorFilterIntake => 'Intake';

  @override
  String get advisorFilterInspection => 'Inspection';

  @override
  String get advisorFilterApproved => 'Approved';

  @override
  String get advisorFilterWip => 'WIP';

  @override
  String get advisorFilterReady => 'Ready';

  @override
  String get advisorSortLabel => 'Sort';

  @override
  String get advisorSortNewest => 'Newest first';

  @override
  String get advisorSortOldest => 'Oldest first';

  @override
  String get advisorSortCustomer => 'Customer A–Z';

  @override
  String get advisorSeeAll => 'See all';

  @override
  String get advisorMetricReady => 'Ready';

  @override
  String get advisorDueToday => 'Due today';

  @override
  String advisorHomeUpdatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String get advisorActionApprovalsTitle => 'Approvals';

  @override
  String get advisorActionApprovalsSubtitle => 'Pending sign-off';

  @override
  String get advisorActionSearchTitle => 'Search';

  @override
  String get advisorActionSearchSubtitle => 'Jobs and customers';

  @override
  String advisorDeltaToday(int count) {
    return '+$count today';
  }

  @override
  String get advisorSectionStages => 'Stages';

  @override
  String get advisorSectionChecklist => 'Checklist';

  @override
  String get advisorSectionEstimates => 'Estimates';

  @override
  String get advisorSectionInvoices => 'Invoices';

  @override
  String get advisorSectionNotes => 'Notes';

  @override
  String get advisorStageIntake => 'Intake';

  @override
  String get advisorStageInspection => 'Inspection';

  @override
  String get advisorStageEstimate => 'Estimate';

  @override
  String get advisorStageRepair => 'Repair';

  @override
  String get advisorStageQc => 'QC';

  @override
  String get advisorStageReady => 'Ready';

  @override
  String get advisorEmptyEstimates => 'No estimates for this job yet.';

  @override
  String get advisorEmptyInvoices => 'No invoices for this job yet.';

  @override
  String get advisorEmptyNotes => 'No notes for this job yet.';

  @override
  String get advisorEmptyChecklist => 'No checklist items recorded yet.';

  @override
  String get advisorSectionActivity => 'Activity';

  @override
  String get advisorSearchRecent => 'Recent';

  @override
  String get advisorShowLess => 'Show less';

  @override
  String get advisorApprovalTypeEstimate => 'Estimate';

  @override
  String get advisorApprovalTypeJobCard => 'Job card';

  @override
  String get advisorApprovalTypeInspection => 'Inspection';

  @override
  String get advisorPriorityHigh => 'Urgent';

  @override
  String get advisorPriorityMedium => 'Follow-up';

  @override
  String get advisorPriorityLow => 'Reminder';

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

  @override
  String get advisorStudioTitle => 'Repair Estimate';

  @override
  String get advisorStudioSubtitle =>
      'Build the customer estimate for this job card';

  @override
  String get advisorStudioStepParts => 'Parts';

  @override
  String get advisorStudioStepLabor => 'Labor';

  @override
  String get advisorStudioStepReview => 'Review';

  @override
  String get advisorStudioTierMandatory => 'Mandatory Safety Repairs';

  @override
  String get advisorStudioTierOptional => 'Optional Enhancements';

  @override
  String get advisorStudioCategoryParts => 'Parts';

  @override
  String get advisorStudioCategoryLabor => 'Labor';

  @override
  String get advisorStudioCategorySublet => 'Sublet';

  @override
  String advisorStudioEmptyCategory(String category) {
    return 'No $category items yet';
  }

  @override
  String advisorStudioAddItem(String category) {
    return 'Add $category';
  }

  @override
  String advisorStudioStockIn(int bay) {
    return 'In-Stock · Bay $bay';
  }

  @override
  String advisorStudioStockOrder(String hours) {
    return 'Order · $hours';
  }

  @override
  String advisorStudioLaborDetail(String hours, String rate) {
    return '${hours}h × $rate';
  }

  @override
  String get advisorStudioLineTotal => 'Line total';

  @override
  String get advisorStudioQuantity => 'Quantity';

  @override
  String get advisorStudioUnitPrice => 'Unit price';

  @override
  String get advisorStudioDiscountPct => 'Discount %';

  @override
  String get advisorStudioSuggestPrice => 'Suggest price from history';

  @override
  String get advisorStudioRemoveItem => 'Remove item';

  @override
  String get advisorStudioPartsSubtotal => 'Parts subtotal';

  @override
  String get advisorStudioLabor => 'Labor';

  @override
  String get advisorStudioVat => 'VAT (5%)';

  @override
  String get advisorStudioTotal => 'Total';

  @override
  String get advisorStudioTrustLine =>
      'Statutory 5% VAT · Prices in UAE dirhams';

  @override
  String get advisorStudioConfirm => 'Review Estimate';

  @override
  String get advisorStudioAddItems => 'Add Estimate Items';

  @override
  String get advisorStudioLoading => 'Loading estimate items…';

  @override
  String get advisorStudioError => 'Could not load estimate items.';

  @override
  String get advisorStudioNoMatch => 'No matching items';

  @override
  String advisorStudioRemoved(String name) {
    return '$name removed';
  }

  @override
  String get advisorStudioFromInspection => 'Inspection completed and attached';

  @override
  String get advisorStudioReset => 'Reset';

  @override
  String get advisorStudioResetTitle => 'Clear this estimate?';

  @override
  String get advisorStudioResetBody =>
      'All services, parts, pricing and notes entered here will be removed.';

  @override
  String get advisorStudioResetKeep => 'Keep editing';

  @override
  String get advisorStudioResetConfirm => 'Clear estimate';

  @override
  String get advisorStudioSelectServicesTitle => 'Select required services';

  @override
  String get advisorStudioSelectServicesSubtitle =>
      'Pricing can be entered after adding them';

  @override
  String get advisorStudioSearchServices => 'Search services';

  @override
  String get advisorStudioSelectPartsTitle => 'Select required parts';

  @override
  String get advisorStudioSelectPartsSubtitle =>
      'Quantity and price can be updated after adding them';

  @override
  String get advisorStudioSearchParts => 'Search parts';

  @override
  String get advisorStudioNoServices => 'No services found';

  @override
  String get advisorStudioNoParts => 'No parts found';

  @override
  String advisorStudioSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get advisorStudioDone => 'Done';

  @override
  String get advisorStudioAddSelectedServices => 'Add services';

  @override
  String get advisorStudioAddSelectedParts => 'Add parts';

  @override
  String get advisorStudioTapToAdd => 'Tap to add';

  @override
  String get advisorStudioAdded => 'Added to estimate';

  @override
  String get advisorStudioSubletHint =>
      'Vendor work is booked outside this estimate.';

  @override
  String get advisorEstimateShareTitle => 'Share estimate';

  @override
  String get advisorEstimateInvoiceTitle => 'ESTIMATE';

  @override
  String get advisorEstimateCustomer => 'Customer';

  @override
  String get advisorEstimateVehicle => 'Vehicle';

  @override
  String get advisorEstimatePreparedOn => 'Prepared on';

  @override
  String get advisorEstimateShareWhatsApp => 'Share on WhatsApp';

  @override
  String get advisorEstimateCopyLink => 'Copy link';

  @override
  String get advisorEstimateLinkCopied => 'Estimate link copied';

  @override
  String get advisorEstimateShareHint =>
      'Send the customer an interactive estimate for approval.';

  @override
  String get advisorEstimateSummaryTitle => 'Summary';

  @override
  String get advisorEstimateSubTotal => 'Subtotal';

  @override
  String get advisorEstimateGrandTotal => 'Grand total';

  @override
  String get advisorEstimateNoContact => 'No customer phone on file';

  @override
  String get advisorEstimateCreateOrder => 'Create Repair Order';

  @override
  String get advisorEstimateAddSignature => 'Add signature';

  @override
  String get advisorEstimateSigned => 'Signed';

  @override
  String get advisorEstimateSignatureLabel => 'CUSTOMER SIGNATURE';

  @override
  String get advisorEstimateSignatureTitle => 'Customer Signature';

  @override
  String get advisorEstimateSignatureClear => 'Clear';

  @override
  String get advisorEstimateSignatureUse => 'Use signature';

  @override
  String get advisorEstimateReviewTitle => 'Review Estimate';

  @override
  String get advisorEstimateMissingJob => 'Job Card is missing';

  @override
  String get advisorEstimateNoItems =>
      'No repair items found. Add extra work or retry after inspection.';

  @override
  String get advisorEstimateCreated => 'Repair order created';

  @override
  String get advisorEstimateCreateFailed => 'Could not create the repair order';

  @override
  String get advisorDispatchTitle => 'Bay Dispatch';

  @override
  String get advisorDispatchSubtitle => 'Assign repair tasks to a technician';

  @override
  String get advisorDispatchTechnicianSection => 'Technician';

  @override
  String get advisorDispatchSelectTech => 'Select a technician';

  @override
  String advisorDispatchLoad(int count) {
    return '$count active jobs';
  }

  @override
  String get advisorDispatchFree => 'Free now';

  @override
  String advisorDispatchAvailableIn(String hours) {
    return 'Free in $hours';
  }

  @override
  String get advisorDispatchSkillBrakes => 'Brakes';

  @override
  String get advisorDispatchSkillAc => 'AC';

  @override
  String get advisorDispatchSkillElectrical => 'Electrical';

  @override
  String get advisorDispatchTaskSection => 'Repair items';

  @override
  String get advisorDispatchAddExtraWork => 'Add extra work';

  @override
  String get advisorDispatchHoursHint => 'hrs';

  @override
  String get advisorDispatchTaskHint => 'Add extra work item';

  @override
  String get advisorDispatchEmpty => 'No generated work items found.';

  @override
  String advisorDispatchSelected(String name) {
    return '$name selected';
  }

  @override
  String advisorDispatchCta(int count) {
    return 'Assign $count tasks';
  }

  @override
  String get advisorDispatchCtaOne => 'Assign 1 task';

  @override
  String get advisorDispatchNeedTech => 'Please select a technician';

  @override
  String get advisorDispatchNeedTask => 'Please add at least one task';

  @override
  String get advisorDispatchSuccess => 'Tasks assigned successfully';

  @override
  String get advisorDispatchFailed => 'Failed to assign tasks';

  @override
  String advisorDispatchError(String message) {
    return 'Error: $message';
  }

  @override
  String advisorDispatchAssignedTo(String name) {
    return 'Assigned to $name';
  }

  @override
  String get advisorDispatchLoading => 'Loading repair items…';

  @override
  String get advisorStudioDetails => 'Estimate details';

  @override
  String get advisorStudioReference => 'Reference number';

  @override
  String get advisorStudioReferenceHint => 'Example: LPO-2026-001';

  @override
  String get advisorStudioRequests => 'Customer requests';

  @override
  String get advisorStudioRequestsHint => 'Customer requests / complaints';

  @override
  String get advisorStudioRecommendations => 'Garage recommendations';

  @override
  String get advisorStudioRecommendationsHint =>
      'Enter garage recommendations here';

  @override
  String get advisorStudioDelivery => 'Estimated delivery';

  @override
  String get advisorStudioDeliveryPick => 'Select date & time';

  @override
  String get advisorStudioNotify => 'Notify owner (SMS & email)';

  @override
  String get advisorStudioTag => 'Tag';

  @override
  String get advisorStudioTagHint => 'Enter a tag (e.g. VIP, Fleet, Insurance)';

  @override
  String get advisorStudioTagAction => 'Set tag';

  @override
  String get advisorStudioMedia => 'Pre-service media';

  @override
  String get advisorStudioMediaAdd => 'Add media';

  @override
  String get advisorStudioMediaCamera => 'Take photo';

  @override
  String get advisorStudioMediaGallery => 'Choose from gallery';

  @override
  String get advisorStudioMediaVideo => 'Record video';

  @override
  String get advisorEstimateApprovalTitle => 'Customer approval';

  @override
  String get advisorEstimateApprovalSubtitle =>
      'Choose how the customer will approve this estimate.';

  @override
  String get advisorEstimateApprovalHere => 'Customer approved here';

  @override
  String get advisorEstimateApprovalHereHint =>
      'Use when the customer reviewed and accepted the estimate with you.';

  @override
  String get advisorEstimateApprovalApp => 'Send to customer app';

  @override
  String get advisorEstimateApprovalAppHint =>
      'The job waits until the customer approves from their account.';

  @override
  String get advisorEstimateSubmit => 'Submit estimate';

  @override
  String get advisorEstimateSubmitting => 'Submitting estimate…';

  @override
  String get techNavToday => 'Today';

  @override
  String get techNavJobs => 'Jobs';

  @override
  String get techNavProductivity => 'Productivity';

  @override
  String get techNavProfile => 'Profile';

  @override
  String get techProfileLabel => 'Technician Profile';

  @override
  String get techWorkspaceName => 'Technician';

  @override
  String techGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get techShiftStart => 'Start shift';

  @override
  String get techShiftBreak => 'Take break';

  @override
  String get techShiftResume => 'Resume shift';

  @override
  String get techShiftDone => 'Shift complete';

  @override
  String get techShiftEnd => 'End shift';

  @override
  String get techShiftClockInHint => 'Clock in to begin today\'s work';

  @override
  String techShiftWorked(String work, String rest) {
    return '$work worked · $rest break';
  }

  @override
  String get techAttendanceNotPunchedIn => 'Not Punched In';

  @override
  String get techAttendanceWorking => 'Working';

  @override
  String get techAttendanceOnBreak => 'On Break';

  @override
  String get techAttendancePunchedOut => 'Punched Out';

  @override
  String get techBannerActive => 'Active job';

  @override
  String get techBannerReady => 'Ready for assignment';

  @override
  String get techBannerReadyHint =>
      'Your next repair appears here when the desk assigns it.';

  @override
  String get techBannerPause => 'Pause';

  @override
  String get techBannerResume => 'Resume';

  @override
  String get techBannerOpen => 'Open job';

  @override
  String techBannerStarted(String time) {
    return 'Started $time';
  }

  @override
  String get techTodayCurrentWork => 'CURRENT WORK';

  @override
  String get techTodayOnBay => 'On the bay';

  @override
  String get techTodayReady => 'Ready for assignment';

  @override
  String get techTodayNoActive => 'No active repair right now';

  @override
  String get techTodayNoActiveHint =>
      'Open your queue to review the next assigned vehicle, or start the next job below.';

  @override
  String get techTodayOpenJobs => 'Open my jobs';

  @override
  String get techTodayQueue => 'Assigned queue';

  @override
  String get techTodayUpNext => 'UP NEXT';

  @override
  String get techTodayViewAll => 'View all';

  @override
  String get techTodayQueueClear => 'Queue clear';

  @override
  String get techTodayQueueClearHint =>
      'No other repairs are waiting. New assignments appear here as they are scheduled.';

  @override
  String get techTodaySummary => 'Shift summary';

  @override
  String get techTodayActiveBay => 'Active bay';

  @override
  String get techTodayTasksDone => 'Tasks done';

  @override
  String get techTodayRepairsDone => 'Repairs done';

  @override
  String get techTodayEmpty => 'No assigned jobs right now';

  @override
  String get techTodayEmptyHint =>
      'You have no repairs assigned for this shift. Pull to refresh, or check back when the desk schedules work.';

  @override
  String get techTodayRefresh => 'Refresh';

  @override
  String get techTodayLoadError => 'We couldn\'t load today\'s work';

  @override
  String get techTodayErrorHint => 'Check your connection and try again.';

  @override
  String get techTodayRetry => 'Retry';

  @override
  String get techTodayJobDetails => 'Job details';

  @override
  String get techTodayTasks => 'Tasks';

  @override
  String get techTodayRequestPart => 'Request part';

  @override
  String get techTodayEscalate => 'Escalate';

  @override
  String get techTodayCompleteTask => 'Complete task';

  @override
  String get techTodayStartTask => 'Start next task';

  @override
  String get techTodayReviewJob => 'Review job';

  @override
  String get techTodayNextTask => 'NEXT TASK';

  @override
  String get techTodayInProgress => 'IN PROGRESS';

  @override
  String get techTodayJobOnHold => 'Job on hold';

  @override
  String get techTodayDelayedHint =>
      'This repair is marked delayed at the workshop.';

  @override
  String techTodayProgress(int done, int total) {
    return '$done of $total tasks completed';
  }

  @override
  String techTodayStartsAt(String time) {
    return 'Starts $time';
  }

  @override
  String techTodayUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get techPlateMissing => 'Plate not recorded';

  @override
  String get techVehicleFallback => 'Vehicle';

  @override
  String get techJobsSearch => 'Search jobs';

  @override
  String get techJobsLoadError => 'We couldn\'t load your jobs';

  @override
  String get techJobsEmpty => 'No assigned jobs';

  @override
  String get techJobsEmptyHint =>
      'There are no jobs assigned to you right now.';

  @override
  String get techJobsNoMatch => 'No matching jobs';

  @override
  String get techJobsNoMatchHint => 'No jobs match your search and filter.';

  @override
  String get techJobsClearFilters => 'Clear filters';

  @override
  String techJobsFilterSemantics(String label, int count) {
    return 'Filter jobs: $label, $count jobs';
  }

  @override
  String techJobsProgress(int done, int total) {
    return '$done of $total tasks completed';
  }

  @override
  String get techDetailTitle => 'Job details';

  @override
  String get techDetailCurrentTask => 'CURRENT TASK';

  @override
  String get techDetailCurrentTitle => 'Current task';

  @override
  String get techDetailNextTask => 'NEXT TASK';

  @override
  String get techDetailNextTitle => 'Next task';

  @override
  String get techDetailOnHold => 'ON HOLD';

  @override
  String get techDetailAllDone => 'Repair tasks complete';

  @override
  String get techDetailNoTasks => 'No tasks';

  @override
  String get techDetailExecution => 'EXECUTION';

  @override
  String techDetailTasksAssigned(int count) {
    return '$count assigned';
  }

  @override
  String get techDetailAllTasks => 'ALL TASKS';

  @override
  String get techDetailCompleteTask => 'Complete task';

  @override
  String get techDetailStartTask => 'Start next task';

  @override
  String get techDetailResumeTask => 'Resume task';

  @override
  String get techDetailStarting => 'Starting…';

  @override
  String get techDetailCompleting => 'Completing…';

  @override
  String get techDetailResuming => 'Resuming…';

  @override
  String get techDetailStart => 'Start';

  @override
  String get techDetailHold => 'Hold';

  @override
  String get techDetailHoldTask => 'Hold task';

  @override
  String get techDetailResume => 'Resume';

  @override
  String get techDetailComplete => 'Complete';

  @override
  String get techDetailElapsed => 'Elapsed';

  @override
  String get techDetailPaused => 'Paused';

  @override
  String get techDetailNoTasksHint =>
      'No tasks have been added to this job. Ask the advisor before starting work.';

  @override
  String get techDetailQcNotice =>
      'Repair work has been submitted for supervisor QC review.';

  @override
  String get techDetailLockedNotice =>
      'This repair is completed. Technician edits are locked.';

  @override
  String get techDetailDelayed => 'Delayed';

  @override
  String get techDetailDelayedHint =>
      'This repair is marked as delayed at the workshop. You can continue the tasks below once the issue is resolved.';

  @override
  String get techDetailSupport => 'Support';

  @override
  String get techDetailNeedHelp => 'NEED HELP?';

  @override
  String get techDetailCompleteRepair => 'Complete repair';

  @override
  String get techDetailConfirmTitle => 'Complete repair?';

  @override
  String get techDetailConfirmBody =>
      'All remaining tasks will be recorded as completed and the job sent to supervisor QC review.';

  @override
  String get techDetailCancel => 'Cancel';

  @override
  String techDetailTaskLabel(int index, String desc, String status) {
    return 'Task $index, $desc, $status';
  }

  @override
  String get techProdTitle => 'Today\'s productivity';

  @override
  String get techProdToday => 'TODAY';

  @override
  String get techProdWorkDone => 'WORK COMPLETED';

  @override
  String get techProdRepairOne => 'repair completed today';

  @override
  String get techProdRepairMany => 'repairs completed today';

  @override
  String get techProdNoTasks => 'No tasks recorded in your loaded work.';

  @override
  String get techProdQueue => 'YOUR QUEUE';

  @override
  String techProdAssigned(int count) {
    return '$count assigned';
  }

  @override
  String get techProdInProgress => 'In progress';

  @override
  String get techProdPending => 'Pending';

  @override
  String get techProdDelayed => 'Delayed';

  @override
  String get techProdQc => 'QC review';

  @override
  String get techProdCompleted => 'Completed';

  @override
  String get techProdShift => 'SHIFT';

  @override
  String get techProdClockedIn => 'Clocked in';

  @override
  String get techProdBreakTaken => 'Break taken';

  @override
  String get techProdNetHours => 'Net hours';

  @override
  String get techProdClockedOut => 'Clocked out';

  @override
  String get techProdShiftDone => 'Shift complete for today.';

  @override
  String get techProdEmpty => 'No productivity data yet';

  @override
  String get techProdEmptyHint =>
      'Completed work will appear here as you progress through your assigned jobs.';

  @override
  String get techProdLoadError => 'We couldn\'t load your productivity';

  @override
  String get techProdFigures => 'Workshop figures';

  @override
  String get techProdEfficiency => 'Efficiency';

  @override
  String get techProdDayProgress => 'Today\'s progress';

  @override
  String techProdDelayedAlert(int count) {
    return '$count delayed — needs attention';
  }

  @override
  String get techProdTimePerRepair => 'Time per repair';

  @override
  String get techProdHoursLogged => 'Hours logged';

  @override
  String get techPartsTitle => 'Request a part';

  @override
  String get techPartsClose => 'Close';

  @override
  String get techPartsName => 'Part name';

  @override
  String get techPartsNameHint => 'What part or material do you need?';

  @override
  String get techPartsNameError => 'Enter the part you need';

  @override
  String get techPartsNumber => 'Part number (optional)';

  @override
  String get techPartsNumberHint => 'OEM or workshop reference';

  @override
  String get techPartsQty => 'Quantity';

  @override
  String get techPartsQtyHint => 'Units needed';

  @override
  String get techPartsDec => 'Decrease quantity';

  @override
  String get techPartsInc => 'Increase quantity';

  @override
  String get techPartsUrgency => 'Urgency';

  @override
  String get techPartsNormal => 'Normal';

  @override
  String get techPartsUrgent => 'Urgent';

  @override
  String get techPartsNotes => 'Notes (optional)';

  @override
  String get techPartsNotesHint => 'Fitment details or preferred alternatives';

  @override
  String techPartsSendCount(int count) {
    return 'Send request · $count';
  }

  @override
  String get techPartsSending => 'Sending…';

  @override
  String get techPartsSent => 'Part request sent.';

  @override
  String get techPartsError =>
      'We couldn\'t send the request. Check your connection and try again.';

  @override
  String get techEscTitle => 'Escalate an issue';

  @override
  String get techEscWhat => 'What happened?';

  @override
  String get techEscDetails => 'Issue details';

  @override
  String get techEscDetailsHint => 'Describe what you found and what you need…';

  @override
  String get techEscDetailsError => 'Describe the issue';

  @override
  String get techEscSafety =>
      'For an immediate safety risk, stop work and contact the supervisor directly.';

  @override
  String get techEscSend => 'Escalate issue';

  @override
  String get techEscSending => 'Sending…';

  @override
  String get techEscSent => 'Escalation sent.';

  @override
  String get techEscError =>
      'We couldn\'t send the escalation. Check your connection and try again.';

  @override
  String get svWorkspaceName => 'Supervisor';

  @override
  String svGreeting(String name) {
    return 'Floor command, $name';
  }

  @override
  String svBaysOccupied(int occupied, int total) {
    return '$occupied/$total bays active';
  }

  @override
  String get svNavFloor => 'Floor';

  @override
  String get svNavJobs => 'Jobs';

  @override
  String get svNavQueue => 'Queue';

  @override
  String get svNavReview => 'Review';

  @override
  String get svNavReports => 'Reports';

  @override
  String get svNavStaff => 'Staff';

  @override
  String get svNavSchedule => 'Schedule';

  @override
  String get svProfileLabel => 'Supervisor profile';

  @override
  String get svNotificationsTitle => 'Floor notifications';

  @override
  String get svNotificationsEmpty => 'No notifications';

  @override
  String get svNotificationsEmptyMessage => 'You are all caught up.';

  @override
  String get svNotificationsMarkAll => 'Mark all read';

  @override
  String get svSearchTitle => 'Find on the floor';

  @override
  String get svSearchHint => 'Search job card, customer, or plate';

  @override
  String get svFloorTitle => 'Workshop floor';

  @override
  String svFloorSubtitle(int count, int total) {
    return '$count active · $total bays';
  }

  @override
  String get svFloorLegend => 'Bay status';

  @override
  String get svBayOccupied => 'Occupied';

  @override
  String get svBayIdle => 'Idle';

  @override
  String get svBayPartsDelay => 'Parts delay';

  @override
  String get svBayQc => 'QC';

  @override
  String get svFloorTapHint => 'Tap a bay to dispatch a technician';

  @override
  String get svFloorEmpty => 'No active jobs on the floor';

  @override
  String get svFloorEmptyMessage =>
      'New jobs appear the moment they are assigned.';

  @override
  String get svFloorNoMatch => 'No bays match this filter';

  @override
  String get svFloorErrorTitle => 'Floor unavailable';

  @override
  String get svFloorError => 'Could not load the floor. Pull to refresh.';

  @override
  String get svFloorQueueTitle => 'Incoming queue';

  @override
  String get svFloorQueueEmpty => 'The queue is clear';

  @override
  String get svFloorUtilisation => 'Floor utilisation';

  @override
  String get svBaysLabel => 'Bays';

  @override
  String get svQueueTitle => 'Incoming queue';

  @override
  String get svQueueSubtitle => 'Priority-sorted bookings and breakdowns';

  @override
  String get svQueuePriorityVip => 'VIP';

  @override
  String get svQueuePriorityPromised => 'Promised today';

  @override
  String get svQueuePriorityInsurance => 'Insurance';

  @override
  String get svQueuePriorityEmergency => 'Emergency';

  @override
  String get svQueueBookings => 'Bookings';

  @override
  String get svQueueBreakdowns => 'Breakdowns';

  @override
  String get svQueueAssign => 'Assign advisor';

  @override
  String get svQueueEmpty => 'The queue is clear';

  @override
  String get svQueueEmptyMessage => 'No bookings or breakdowns waiting.';

  @override
  String get svQueueNoMatch => 'No matching queue items';

  @override
  String get svQueueError => 'Could not refresh the dispatch queue.';

  @override
  String get svQueueAssignTitle => 'Route to advisor';

  @override
  String get svQueueAssignHint => 'Service advisor';

  @override
  String get svQueueAssigned => 'Booking assigned';

  @override
  String get svQueueDispatched => 'Breakdown dispatched';

  @override
  String get svQueueAssignFailed => 'Could not assign. Try again.';

  @override
  String get svQueueNoAdvisors => 'No active advisors available to assign';

  @override
  String get svJobsTitle => 'Active jobs';

  @override
  String svJobsSubtitle(int count) {
    return '$count on the floor';
  }

  @override
  String get svJobsSearchHint => 'Search job card, customer, or plate';

  @override
  String get svJobsEmpty => 'No active jobs';

  @override
  String get svJobsEmptyMessage => 'Assign work to see jobs on the floor.';

  @override
  String get svJobsNoMatch => 'No matching jobs';

  @override
  String get svJobsError => 'Could not load active jobs.';

  @override
  String get svJobsTotal => 'Total';

  @override
  String get svJobsInProgress => 'In progress';

  @override
  String get svJobsCompleted => 'Completed';

  @override
  String svJobsTasks(int done, int total) {
    return '$done/$total tasks';
  }

  @override
  String get svJobsAssign => 'Assign work';

  @override
  String get svReviewTitle => 'Quality control';

  @override
  String get svReviewSubtitle => 'Verify completed repairs before delivery';

  @override
  String get svReviewStart => 'Start QC';

  @override
  String get svReviewEmpty => 'Nothing awaiting sign-off';

  @override
  String get svReviewEmptyMessage =>
      'Completed repairs appear here for verification.';

  @override
  String get svReviewError => 'Could not load QC work.';

  @override
  String svReviewProgress(int done, int total) {
    return '$done/$total done';
  }

  @override
  String get svQcTitle => 'Quality control review';

  @override
  String get svQcRepairVerification => 'Repair verification';

  @override
  String get svQcRoadTest => 'Road test';

  @override
  String get svQcTorque => 'Torque audit';

  @override
  String get svQcFluid => 'Fluid levels';

  @override
  String get svQcWash => 'Final wash';

  @override
  String get svQcCheckpoints => 'Sign-off checkpoints';

  @override
  String get svQcPhotoProof => 'Photo proof';

  @override
  String get svQcPhotoAdd => 'Add photo';

  @override
  String get svQcPhotoAttached => 'Attached';

  @override
  String get svQcPhotoUnavailable =>
      'Photo capture is not available for this job.';

  @override
  String get svQcNotes => 'Inspector notes';

  @override
  String get svQcNotesHint =>
      'Required when sending back — describe the rework needed';

  @override
  String get svQcReject => 'Send back';

  @override
  String get svQcApprove => 'Approve & pass';

  @override
  String svQcVerified(int count, int total) {
    return '$count/$total verified';
  }

  @override
  String get svQcRejectReasonRequired =>
      'Add revision details before sending back.';

  @override
  String get svQcVerifyAll => 'Verify every checkpoint to approve.';

  @override
  String get svQcApproved => 'QC passed — job approved';

  @override
  String get svQcRejected => 'Sent back for revision';

  @override
  String get svQcFailed => 'Could not complete QC review. Try again.';

  @override
  String get svReportsTitle => 'Operations report';

  @override
  String get svReportsSubtitle => 'Throughput, rework, and floor utilisation';

  @override
  String get svReportsThroughput => 'Throughput';

  @override
  String get svReportsRework => 'Rework';

  @override
  String get svReportsUtilisation => 'Utilisation';

  @override
  String get svReportsJobsPerTech => 'Jobs per technician';

  @override
  String get svReportsCategories => 'Job categories';

  @override
  String get svReportsCategoriesEmpty => 'No category data recorded';

  @override
  String get svReportsWorkload => 'Advisor load';

  @override
  String get svReportsWorkloadEmpty => 'No workload data recorded';

  @override
  String get svReportsFloor => 'Floor status';

  @override
  String get svReportsTechnicians => 'Technicians';

  @override
  String get svReportsDepartments => 'Departments';

  @override
  String get svReportsInQueue => 'In queue';

  @override
  String get svReportsFinancial => 'Financials';

  @override
  String get svReportsEmpty => 'No report data';

  @override
  String get svReportsError => 'Live report data is unavailable right now.';

  @override
  String get svReportsNoHistory =>
      'No history yet — showing current floor figures only.';

  @override
  String get svStaffTitle => 'Workshop roster';

  @override
  String svStaffSubtitle(int count) {
    return '$count specialists on shift';
  }

  @override
  String get svStaffTechnicians => 'Technicians';

  @override
  String get svStaffDepartments => 'Departments';

  @override
  String get svStaffEmpty => 'No staff on shift';

  @override
  String get svStaffEmptyMessage => 'No registered technicians.';

  @override
  String get svStaffDeptEmpty => 'No departments';

  @override
  String get svStaffDeptEmptyMessage => 'No registered workshop units.';

  @override
  String get svStaffRole => 'Floor specialist';

  @override
  String get svStaffOnShift => 'On shift';

  @override
  String svStaffLoad(int count) {
    return '$count active';
  }

  @override
  String get svScheduleTitle => 'Bay schedule';

  @override
  String get svScheduleSubtitle => 'Today\'s appointment agenda';

  @override
  String get svScheduleTime => 'Time';

  @override
  String get svScheduleVehicle => 'Customer · vehicle';

  @override
  String get svScheduleService => 'Service';

  @override
  String get svScheduleStatus => 'Status';

  @override
  String get svScheduleEmpty => 'No appointments scheduled';

  @override
  String get svScheduleEmptyMessage => 'Upcoming bookings appear here.';

  @override
  String get svScheduleViewInQueue => 'View in queue';

  @override
  String get svScheduleToday => 'Today';

  @override
  String get svScheduleError => 'Could not load the schedule.';

  @override
  String get svAssignTitle => 'Dispatch to technician';

  @override
  String get svAssignSubtitle => 'Pick a technician to take this job';

  @override
  String get svAssignTarget => 'Target job';

  @override
  String get svAssignTargetHint => 'Job card number (e.g. JC-2026-1042)';

  @override
  String get svAssignTechTitle => 'Technicians';

  @override
  String get svAssignSkills => 'Skills';

  @override
  String svAssignLoad(int count) {
    return '$count active';
  }

  @override
  String get svAssignDispatch => 'Dispatch';

  @override
  String svAssignDispatched(String name) {
    return 'Dispatched to $name';
  }

  @override
  String get svAssignEmpty => 'No technicians available';

  @override
  String get svAssignEmptyMessage => 'Register technicians to dispatch work.';

  @override
  String get svAssignNoTarget => 'Add a target job card before dispatching.';

  @override
  String get svAssignFailed => 'Could not dispatch. Try again.';

  @override
  String get svAssignBrief => 'Task brief (optional)';

  @override
  String get svAssignBriefHint => 'Describe the work for the technician';

  @override
  String get svRouteAssignTitle => 'Work assignment';

  @override
  String get svRouteAssignSubtitle => 'Dispatch tasks to technicians';

  @override
  String get svRouteJobsTitle => 'Active jobs';

  @override
  String get svRouteJobsSubtitle => 'Workshop operations';

  @override
  String get svRouteQueueTitle => 'Incoming work';

  @override
  String get svRouteQueueSubtitle => 'Bookings & breakdowns';

  @override
  String get svRouteReviewTitle => 'Quality control';

  @override
  String get svRouteReviewSubtitle => 'Verify completed repairs';

  @override
  String get svRouteStaffTitle => 'Workshop roster';

  @override
  String get svRouteStaffSubtitle => 'Technicians & departments';

  @override
  String get svRouteScheduleTitle => 'Scheduled appointments';

  @override
  String get svRouteScheduleSubtitle => 'Today\'s bookings';

  @override
  String get svRouteReportsTitle => 'Operations report';

  @override
  String get svRouteReportsSubtitle => 'Workshop summary & metrics';

  @override
  String get svBreadcrumbConsole => 'Supervisor console';

  @override
  String get svProfileShift => 'Shift timeline';

  @override
  String get svProfileSettings => 'Settings';

  @override
  String get staffProfileTitle => 'Profile';

  @override
  String get staffProfileWork => 'Work Information';

  @override
  String get staffProfileContact => 'Contact Details';

  @override
  String get staffProfileDesignation => 'Designation';

  @override
  String get staffProfileDepartment => 'Department';

  @override
  String get staffProfileBranch => 'Branch';

  @override
  String get staffProfileShift => 'Shift';

  @override
  String get staffProfileEmail => 'Email';

  @override
  String get staffProfilePhone => 'Phone';

  @override
  String get staffProfileAccount => 'Account';

  @override
  String get staffProfileResetPassword => 'Reset password';

  @override
  String get staffProfileResetSubtitle =>
      'Verify your identity, then choose a new password';

  @override
  String get staffProfileLicences => 'Open source licences';

  @override
  String get staffProfileLicencesSubtitle =>
      'Legal notices for the software in this app';

  @override
  String get staffProfilePrefs => 'Preferences';

  @override
  String get staffProfileChangePassword => 'Change password';

  @override
  String get staffProfileChangePasswordTitle => 'Change password?';

  @override
  String get staffProfileChangePasswordBody =>
      'Password changes use one-time-code verification. Continue to the recovery flow to choose a new password.';

  @override
  String get staffProfileContinue => 'Continue';

  @override
  String get staffProfileCancel => 'Cancel';

  @override
  String get staffProfileStorage => 'Storage & sync';

  @override
  String get staffProfileStorageSubtitle =>
      'Offline copies, sync status and cache';

  @override
  String get staffProfileDanger => 'Danger zone';

  @override
  String get staffProfileSignOut => 'Sign out';

  @override
  String get staffProfileSignOutTitle => 'Sign out?';

  @override
  String get staffProfileSignOutMessage =>
      'You will need to sign in again to continue.';

  @override
  String get staffProfileSignOutUnsyncedTitle => 'Sign out with unsynced work?';

  @override
  String get staffProfileSignOutUnsyncedMessage =>
      'Some work is still waiting to sync. Signing out will remove the changes saved on this device.';

  @override
  String get staffProfileStaySignedIn => 'Stay signed in';

  @override
  String get staffAttTitle => 'Attendance';

  @override
  String get staffAttNotPunched => 'Not punched in';

  @override
  String get staffAttWorking => 'Working';

  @override
  String get staffAttOnBreak => 'On break';

  @override
  String get staffAttShiftComplete => 'Shift complete';

  @override
  String get staffAttNotPunchedHint =>
      'Your shift has not started yet. Punch in to begin recording today\'s hours.';

  @override
  String get staffAttWorkingHint =>
      'Active shift in progress. Your hours are being recorded.';

  @override
  String get staffAttBreakHint => 'Shift is temporarily paused on break.';

  @override
  String get staffAttDoneHint =>
      'Today\'s shift is finished. Recorded hours have been submitted.';

  @override
  String get staffAttCurrentStatus => 'CURRENT STATUS';

  @override
  String get staffAttPunchIn => 'Punch In';

  @override
  String get staffAttPunchingIn => 'Punching in…';

  @override
  String get staffAttPunchOut => 'Punch Out';

  @override
  String get staffAttPunchingOut => 'Punching out…';

  @override
  String get staffAttPunchInTitle => 'Punch in now?';

  @override
  String get staffAttPunchInBody =>
      'Your arrival time will be recorded by the workshop server.';

  @override
  String get staffAttPunchOutTitle => 'Punch out now?';

  @override
  String get staffAttPunchOutBody =>
      'This completes today\'s shift and records your work hours.';

  @override
  String get staffAttInToast => 'You are punched in.';

  @override
  String get staffAttOutToast => 'You are punched out.';

  @override
  String get staffAttFailToast => 'Attendance was not updated.';

  @override
  String get staffAttTodayRecord => 'Today\'s Recorded Time';

  @override
  String get staffAttPunchInRow => 'Punch in';

  @override
  String get staffAttPunchOutRow => 'Punch out';

  @override
  String get staffAttHours => 'Hours worked';

  @override
  String get staffAttBreakRow => 'Break time';

  @override
  String get staffAttDoneLine =>
      'Today’s shift is complete. Your recorded hours are shown above.';

  @override
  String staffAttPunchedAt(String time) {
    return 'Punched in at $time';
  }

  @override
  String staffAttOutAt(String time) {
    return 'Punched out at $time';
  }

  @override
  String staffAttOnShiftFor(String time) {
    return 'On shift for $time';
  }

  @override
  String get staffAttBasis => '8h workday basis';

  @override
  String get staffAttMonthTitle => 'This month';

  @override
  String get staffAttHistoryNote =>
      'Only today\'s record is kept on this device. Past days need a workshop history feed.';

  @override
  String get staffAttDayTitle => 'Day record';

  @override
  String get staffAttNoRecord => 'No record for this day.';

  @override
  String get staffShiftTitle => 'Shift Details';

  @override
  String get staffShiftSubtitle => 'Scheduled work hours and assignment';

  @override
  String get staffShiftSchedule => 'Shift Schedule';

  @override
  String get staffShiftAssigned => 'ASSIGNED SHIFT';

  @override
  String get staffShiftStart => 'Shift Start';

  @override
  String get staffShiftEnd => 'Shift End';

  @override
  String get staffShiftAssignment => 'Assignment Details';

  @override
  String get staffShiftMember => 'Staff Member';

  @override
  String get staffShiftEmpId => 'Employee ID';

  @override
  String get staffShiftBranch => 'Assigned Branch';

  @override
  String get staffShiftSupervisor => 'Supervisor on duty';

  @override
  String get staffShiftBay => 'Assigned bay';

  @override
  String get staffShiftBreaks => 'Breaks';

  @override
  String get staffShiftDefault => 'Standard Shift';

  @override
  String get staffShiftEmpty =>
      'No shift details were shared with this device.';

  @override
  String get staffSettingsTitle => 'Settings';

  @override
  String get staffSettingsSubtitle => 'Application information & local storage';

  @override
  String get staffSettingsSync => 'Data & Sync';

  @override
  String get staffSettingsSyncStatus => 'Local Sync Status';

  @override
  String staffSettingsPending(int count) {
    return '$count pending operations';
  }

  @override
  String get staffSettingsPendingHint =>
      'Offline changes are queued and will sync when connection is restored.';

  @override
  String get staffSettingsIdle => 'No pending local operations';

  @override
  String get staffSettingsIdleHint =>
      'All recorded offline actions have been processed.';

  @override
  String get staffSettingsPendingPill => 'PENDING';

  @override
  String get staffSettingsIdlePill => 'IDLE';

  @override
  String get staffSettingsForceSync => 'Force Sync Now';

  @override
  String get staffSettingsSyncing => 'Syncing…';

  @override
  String get staffSettingsSyncedToast => 'Sync finished.';

  @override
  String get staffSettingsSyncFailed =>
      'Sync failed. Will retry automatically.';

  @override
  String staffSettingsLastAttempt(String time) {
    return 'Last attempt $time (this session)';
  }

  @override
  String get staffSettingsApp => 'Application';

  @override
  String get staffSettingsVersion => 'App Version';

  @override
  String get staffSettingsDevice => 'Device';

  @override
  String get staffSettingsCache => 'Cached data';

  @override
  String staffSettingsCacheHint(int count) {
    return '$count items stored on this device';
  }

  @override
  String get staffSettingsClearCache => 'Clear cache';

  @override
  String get staffSettingsClearTitle => 'Clear cached data?';

  @override
  String get staffSettingsClearBody =>
      'Removes offline job copies, drafts and queued uploads from this device. Your account and server records are untouched.';

  @override
  String get staffSettingsCacheCleared => 'Cache cleared.';

  @override
  String get advisorClientBroughtBy => 'Brought by';

  @override
  String get advisorClientBroughtByHint =>
      'Name of the person who brought the vehicle';

  @override
  String get advisorClientBroughtByQueued =>
      'Saved on this device · queued (needs server field)';

  @override
  String get advisorClientBroughtByMissing =>
      'No server field for brought-by yet — kept locally and queued.';

  @override
  String advisorClientAdvisorHandled(String name) {
    return 'Handled by $name';
  }

  @override
  String advisorClientQueuedBy(String name) {
    return 'Queued by $name';
  }

  @override
  String get advisorClientComments => 'Comments';

  @override
  String get advisorClientCommentsEmpty => 'No comments yet.';

  @override
  String get advisorClientCommentsAdd => 'Add comment';

  @override
  String get advisorClientCommentsHint => 'Write a comment…';

  @override
  String get advisorClientCommentsDeleteTitle => 'Delete this comment?';

  @override
  String get advisorClientCommentsQueued =>
      'Saved on this device · queued (needs server field)';

  @override
  String get advisorClientSignatures => 'Signatures';

  @override
  String get advisorClientSigCustomer => 'Customer';

  @override
  String get advisorClientSigAdvisor => 'Advisor';

  @override
  String advisorClientSigSignedOn(String time) {
    return 'Signed $time';
  }

  @override
  String get advisorClientSigMissing => 'Not signed yet';

  @override
  String get advisorClientSigClear => 'Clear';

  @override
  String get advisorClientShareTitle => 'Share job card';

  @override
  String advisorClientShareSummary(String id, String customer, String vehicle) {
    return 'Job $id · $customer · $vehicle';
  }

  @override
  String get advisorClientShareWhatsApp => 'WhatsApp';

  @override
  String get advisorClientShareEmail => 'Email';

  @override
  String get advisorClientShareWhatsAppDone =>
      'Opened WhatsApp with the job summary (no PDF yet).';

  @override
  String get advisorClientShareEmailDone =>
      'Opened email with the job summary (no PDF yet).';

  @override
  String get advisorClientShareNoPhone =>
      'Add a customer number to share on WhatsApp.';

  @override
  String get advisorClientPdfMissing =>
      'PDF export needs a client generator — sharing the job link and summary instead.';

  @override
  String get advisorClientSignLink => 'Customer sign link';

  @override
  String get advisorClientSendSignLink => 'Send sign link';

  @override
  String get advisorClientSignLinkSoon =>
      'Coming soon — needs a server sign-link endpoint.';

  @override
  String get advisorClientPlatesTitle => 'Existing plates';

  @override
  String get advisorClientPlatesNew => 'New plate';

  @override
  String get advisorClientPlatesHint => 'Choose a plate or enter a new one';

  @override
  String get advisorClientPlatesNone =>
      'No plates on file for this number — enter it manually.';
}
