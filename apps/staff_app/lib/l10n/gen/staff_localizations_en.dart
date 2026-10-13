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
}
