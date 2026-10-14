import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'staff_localizations_ar.dart';
import 'staff_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of StaffLocalizations
/// returned by `StaffLocalizations.of(context)`.
///
/// Applications need to include `StaffLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/staff_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: StaffLocalizations.localizationsDelegates,
///   supportedLocales: StaffLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the StaffLocalizations.supportedLocales
/// property.
abstract class StaffLocalizations {
  StaffLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static StaffLocalizations? of(BuildContext context) {
    return Localizations.of<StaffLocalizations>(context, StaffLocalizations);
  }

  static const LocalizationsDelegate<StaffLocalizations> delegate =
      _StaffLocalizationsDelegate();

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
  /// **'Orient Staff'**
  String get appTitle;

  /// App identity name shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'Orient Staff App'**
  String get loginAppName;

  /// App purpose shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'Confirm bookings, check in vehicles, run inspections, assign repair work, update tasks, and complete QC.'**
  String get loginAppPurpose;

  /// Intended users shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'For advisors, technicians, and supervisors'**
  String get loginIntendedUsers;

  /// App-specific legal notice under the shared auth form
  ///
  /// In en, this message translates to:
  /// **'By signing in, you agree to the Orient Staff App Terms of Service and Privacy Policy.'**
  String get authSecurityNotice;

  /// Title of the supervisor sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Supervisor access'**
  String get supervisorLoginTitle;

  /// Supporting text of the supervisor sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage bookings, assignments, QC, and workshop operations.'**
  String get supervisorLoginSubtitle;

  /// App identity name shown on the supervisor auth shell
  ///
  /// In en, this message translates to:
  /// **'Orient Supervisor Console'**
  String get supervisorAppName;

  /// App purpose shown on the supervisor auth shell
  ///
  /// In en, this message translates to:
  /// **'Review incoming bookings, assign advisors and technicians, monitor jobs, and complete quality checks.'**
  String get supervisorAppPurpose;

  /// Intended users shown on the supervisor auth shell
  ///
  /// In en, this message translates to:
  /// **'For workshop supervisors'**
  String get supervisorIntendedUsers;

  /// Label of the supervisor username field
  ///
  /// In en, this message translates to:
  /// **'Username or email'**
  String get supervisorUsernameLabel;

  /// Hint of the supervisor username field
  ///
  /// In en, this message translates to:
  /// **'Enter your username or email'**
  String get supervisorUsernameHint;

  /// Validation when supervisor credentials are empty
  ///
  /// In en, this message translates to:
  /// **'Enter username and password'**
  String get supervisorEnterCredentials;

  /// Advisor bottom-nav / rail label for the Today tab
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get advisorNavToday;

  /// Advisor navigation label for the Jobs tab
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get advisorNavJobs;

  /// Advisor navigation label for the Reports tab
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get advisorNavReports;

  /// Workspace name shown in the brand mark header
  ///
  /// In en, this message translates to:
  /// **'Advisor'**
  String get advisorWorkspaceName;

  /// Rail footer label for the advisor profile action
  ///
  /// In en, this message translates to:
  /// **'Advisor Profile'**
  String get advisorProfileLabel;

  /// Role kicker in the Today header
  ///
  /// In en, this message translates to:
  /// **'SERVICE ADVISOR'**
  String get advisorRoleEyebrow;

  /// Today header title
  ///
  /// In en, this message translates to:
  /// **'Service Desk'**
  String get advisorDeskTitle;

  /// Shift greeting with the advisor name
  ///
  /// In en, this message translates to:
  /// **'Good to see you, {name}'**
  String advisorGreeting(String name);

  /// Branch and shift context line
  ///
  /// In en, this message translates to:
  /// **'{branch} · {shift}'**
  String advisorShiftContext(String branch, String shift);

  /// Freshness line under the shift context
  ///
  /// In en, this message translates to:
  /// **'Live workshop data'**
  String get advisorFreshnessLive;

  /// Quick search pill primary text
  ///
  /// In en, this message translates to:
  /// **'Search intake, customer, or VIN…'**
  String get advisorSearchPillTitle;

  /// Quick search pill supporting text
  ///
  /// In en, this message translates to:
  /// **'Lookup repair orders, estimates & history'**
  String get advisorSearchPillSubtitle;

  /// Section kicker above the quick-action tile grid
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get advisorQuickActionsEyebrow;

  /// Quick action: scan vehicle
  ///
  /// In en, this message translates to:
  /// **'Scan Vehicle'**
  String get advisorActionScanTitle;

  /// Quick action subtitle: scan vehicle
  ///
  /// In en, this message translates to:
  /// **'VIN / Plate'**
  String get advisorActionScanSubtitle;

  /// Quick action: new job card
  ///
  /// In en, this message translates to:
  /// **'New Job Card'**
  String get advisorActionNewJobTitle;

  /// Quick action subtitle: new job card
  ///
  /// In en, this message translates to:
  /// **'Client intake'**
  String get advisorActionNewJobSubtitle;

  /// Quick action: vehicle inspection
  ///
  /// In en, this message translates to:
  /// **'Vehicle Inspection'**
  String get advisorActionInspectionTitle;

  /// Quick action subtitle: vehicle inspection
  ///
  /// In en, this message translates to:
  /// **'Checkpoints'**
  String get advisorActionInspectionSubtitle;

  /// Quick action: workshop reports
  ///
  /// In en, this message translates to:
  /// **'Workshop Reports'**
  String get advisorActionReportsTitle;

  /// Quick action subtitle: workshop reports
  ///
  /// In en, this message translates to:
  /// **'Performance logs'**
  String get advisorActionReportsSubtitle;

  /// Section title for pending approvals and reminders
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get advisorAttentionTitle;

  /// Section title for the shift metric tiles
  ///
  /// In en, this message translates to:
  /// **'Work Summary'**
  String get advisorWorkSummary;

  /// Section action opening the Reports tab
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get advisorActionAnalytics;

  /// Section title for recent job cards
  ///
  /// In en, this message translates to:
  /// **'Assigned Work Orders'**
  String get advisorAssignedWorkOrders;

  /// Section action opening the full jobs list
  ///
  /// In en, this message translates to:
  /// **'View All ({count})'**
  String advisorViewAll(int count);

  /// Empty state on Today when no jobs are assigned
  ///
  /// In en, this message translates to:
  /// **'No active job cards assigned'**
  String get advisorNoActiveJobs;

  /// Metric tile label: total orders
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get advisorMetricTotalOrders;

  /// Metric tile label: in progress
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get advisorMetricInProgress;

  /// Metric tile label: delivered
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get advisorMetricDelivered;

  /// Inline notice when live data fails to load
  ///
  /// In en, this message translates to:
  /// **'Some live workshop data could not be loaded.'**
  String get advisorDataError;

  /// Cached-data notice shown when displaying offline data
  ///
  /// In en, this message translates to:
  /// **'Showing saved data. Changes will sync when you\'re back online.'**
  String get advisorOfflineNotice;

  /// Badge on the active intake card
  ///
  /// In en, this message translates to:
  /// **'ACTIVE ARRIVAL'**
  String get advisorActiveArrival;

  /// Status text on the active intake card
  ///
  /// In en, this message translates to:
  /// **'CONFIRMED APPOINTMENT'**
  String get advisorConfirmedAppointment;

  /// Client line on the active intake card
  ///
  /// In en, this message translates to:
  /// **'Client: {name}'**
  String advisorClientPrefix(String name);

  /// Jobs tab title
  ///
  /// In en, this message translates to:
  /// **'Workshop Job Cards'**
  String get advisorJobsTitle;

  /// Jobs search field hint
  ///
  /// In en, this message translates to:
  /// **'Search by registration, customer, or ID…'**
  String get advisorJobsSearchHint;

  /// Jobs status filter: all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get advisorFilterAll;

  /// Jobs status filter: in progress
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get advisorFilterInProgress;

  /// Jobs status filter: completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get advisorFilterCompleted;

  /// Jobs status filter: pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get advisorFilterPending;

  /// Jobs status filter: QC check
  ///
  /// In en, this message translates to:
  /// **'QC Check'**
  String get advisorFilterQc;

  /// Jobs status filter: cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get advisorFilterCancelled;

  /// Title of the assigned-bookings section on the jobs list
  ///
  /// In en, this message translates to:
  /// **'Assigned intake queue'**
  String get advisorAssignedIntakeQueue;

  /// Pending booking count on the assigned intake queue
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String advisorPendingCount(int count);

  /// Action to check in an assigned booking
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get advisorActionCheckIn;

  /// No-match state on the jobs list
  ///
  /// In en, this message translates to:
  /// **'No matching job cards'**
  String get advisorNoMatchingJobs;

  /// Empty state title on the jobs list
  ///
  /// In en, this message translates to:
  /// **'No job cards yet'**
  String get advisorNoJobs;

  /// Empty state supporting text on the jobs list
  ///
  /// In en, this message translates to:
  /// **'New job cards will appear here as they are created.'**
  String get advisorNoJobsHint;

  /// Reports tab title
  ///
  /// In en, this message translates to:
  /// **'Advisor Analytics'**
  String get advisorReportsTitle;

  /// Reports range: today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get advisorRangeToday;

  /// Reports range: this week
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get advisorRangeWeek;

  /// Reports range: this month
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get advisorRangeMonth;

  /// Report hero metric: total jobs
  ///
  /// In en, this message translates to:
  /// **'Total jobs'**
  String get advisorReportTotalJobs;

  /// Report hero metric: completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get advisorReportCompleted;

  /// Report hero metric: in progress
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get advisorReportInProgress;

  /// Report hero metric: cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get advisorReportCancelled;

  /// Reports section title for the bar chart
  ///
  /// In en, this message translates to:
  /// **'Job Activity'**
  String get advisorJobActivity;

  /// Reports section title for the distribution chart
  ///
  /// In en, this message translates to:
  /// **'Status Allocation'**
  String get advisorStatusAllocation;

  /// Reports export action
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get advisorExportCsv;

  /// Reports error notice
  ///
  /// In en, this message translates to:
  /// **'Report data is unavailable right now. Your job data has not been replaced with zeros.'**
  String get advisorReportUnavailable;

  /// Job detail page title
  ///
  /// In en, this message translates to:
  /// **'Job Card Details'**
  String get advisorJobDetailsTitle;

  /// Job detail section: next step
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get advisorSectionNextStep;

  /// Job detail section: customer details
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get advisorSectionCustomerDetails;

  /// Job detail section: vehicle details
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get advisorSectionVehicleDetails;

  /// Job detail section: fuel level
  ///
  /// In en, this message translates to:
  /// **'Fuel Level'**
  String get advisorSectionFuelLevel;

  /// Job detail section: body condition
  ///
  /// In en, this message translates to:
  /// **'Vehicle Body Condition'**
  String get advisorSectionBodyCondition;

  /// Job detail section: work items
  ///
  /// In en, this message translates to:
  /// **'Work Items'**
  String get advisorSectionWorkItems;

  /// Job detail section: inspection summary
  ///
  /// In en, this message translates to:
  /// **'Inspection Summary'**
  String get advisorSectionInspectionSummary;

  /// Job detail section: service information
  ///
  /// In en, this message translates to:
  /// **'Service Information'**
  String get advisorSectionServiceInformation;

  /// Job detail section: customer requests
  ///
  /// In en, this message translates to:
  /// **'Customer Requests'**
  String get advisorSectionCustomerRequests;

  /// Detail field label: name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get advisorFieldName;

  /// Detail field label: phone
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get advisorFieldPhone;

  /// Detail field label: email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get advisorFieldEmail;

  /// Detail field label: customer group
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get advisorFieldGroup;

  /// Detail field label: vehicle
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get advisorFieldVehicle;

  /// Detail field label: plate
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get advisorFieldPlate;

  /// Detail field label: VIN
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get advisorFieldVin;

  /// Detail field label: model year
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get advisorFieldYear;

  /// Detail field label: color
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get advisorFieldColor;

  /// Detail field label: odometer
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get advisorFieldOdometer;

  /// Detail field label: service type
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get advisorFieldServiceType;

  /// Detail field label: advisor
  ///
  /// In en, this message translates to:
  /// **'Advisor'**
  String get advisorFieldAdvisor;

  /// Detail field label: technician
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get advisorFieldTechnician;

  /// Detail field label: created
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get advisorFieldCreated;

  /// Detail field label: last updated
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get advisorFieldLastUpdated;

  /// Detail field label: inspection reference
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get advisorFieldReference;

  /// Detail field label: fuel gauge level
  ///
  /// In en, this message translates to:
  /// **'Gauge Level'**
  String get advisorFieldGaugeLevel;

  /// Default service type value
  ///
  /// In en, this message translates to:
  /// **'Vehicle Inspection'**
  String get advisorServiceTypeInspection;

  /// Default advisor value
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get advisorAdvisorAssigned;

  /// Odometer value with the km unit
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String advisorOdometerValue(String value);

  /// Job detail action: call customer
  ///
  /// In en, this message translates to:
  /// **'Call Customer'**
  String get advisorActionCallCustomer;

  /// Job detail action: deliver vehicle
  ///
  /// In en, this message translates to:
  /// **'Deliver Vehicle'**
  String get advisorActionDeliverVehicle;

  /// Primary action: add inspection
  ///
  /// In en, this message translates to:
  /// **'Add Inspection'**
  String get advisorActionAddInspection;

  /// Primary action: start inspection
  ///
  /// In en, this message translates to:
  /// **'Start Inspection'**
  String get advisorActionStartInspection;

  /// Primary action: create estimate
  ///
  /// In en, this message translates to:
  /// **'Create Estimate'**
  String get advisorActionCreateEstimate;

  /// Primary action: waiting for customer approval
  ///
  /// In en, this message translates to:
  /// **'Waiting for Customer Approval'**
  String get advisorActionWaitingApproval;

  /// Primary action: assign technician
  ///
  /// In en, this message translates to:
  /// **'Assign Technician'**
  String get advisorActionAssignTechnician;

  /// Primary action: review work items
  ///
  /// In en, this message translates to:
  /// **'Review Work Items'**
  String get advisorActionReviewWorkItems;

  /// Primary action: refresh job card
  ///
  /// In en, this message translates to:
  /// **'Refresh Job Card'**
  String get advisorActionRefreshJobCard;

  /// Toast when the vehicle is already delivered
  ///
  /// In en, this message translates to:
  /// **'Vehicle already delivered'**
  String get advisorVehicleAlreadyDelivered;

  /// Next-step hint when an inspection is required
  ///
  /// In en, this message translates to:
  /// **'Complete the inspection before continuing'**
  String get advisorNextStepInspectionHint;

  /// Next-step hint when the job can continue
  ///
  /// In en, this message translates to:
  /// **'Continue this job card through the workshop'**
  String get advisorNextStepContinueHint;

  /// Work items section supporting text
  ///
  /// In en, this message translates to:
  /// **'Tasks created from the completed inspection'**
  String get advisorWorkItemsHint;

  /// Body condition section supporting text
  ///
  /// In en, this message translates to:
  /// **'Existing marks and damage recorded at intake'**
  String get advisorBodyConditionHint;

  /// Work items progress counter
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} done'**
  String advisorWorkItemsProgress(int done, int total);

  /// Inspection count: good
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get advisorInspectionGood;

  /// Inspection count: fair
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get advisorInspectionFair;

  /// Inspection count: poor
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get advisorInspectionPoor;

  /// Job detail load error message
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this job card. Check your connection and try again.'**
  String get advisorJobDetailLoadError;

  /// Profile sheet menu: my profile
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get advisorProfileMyProfile;

  /// Profile sheet menu: attendance
  ///
  /// In en, this message translates to:
  /// **'Attendance · Punch In / Out'**
  String get advisorProfileAttendance;

  /// Profile sheet logout action
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get advisorProfileLogout;

  /// Shift badge fallback when no shift is set
  ///
  /// In en, this message translates to:
  /// **'On Shift'**
  String get advisorOnShift;

  /// Notification sheet title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get advisorNotificationsTitle;

  /// Notification sheet clear-all action
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get advisorClearAll;

  /// Notification sheet empty title
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get advisorNoNotifications;

  /// Notification sheet empty supporting text
  ///
  /// In en, this message translates to:
  /// **'Approval updates and reminders will appear here.'**
  String get advisorNoNotificationsHint;

  /// Search sheet title
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get advisorSearchTitle;

  /// Search sheet field hint
  ///
  /// In en, this message translates to:
  /// **'Search customers, vehicles, job cards, approvals…'**
  String get advisorSearchHint;

  /// Search sheet no-match state
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get advisorNoResults;

  /// Search results group: job cards
  ///
  /// In en, this message translates to:
  /// **'Job Cards'**
  String get advisorSearchGroupJobCards;

  /// Search results group: customers and vehicles
  ///
  /// In en, this message translates to:
  /// **'Customers / Vehicles'**
  String get advisorSearchGroupCustomers;

  /// Search results group: approvals
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get advisorSearchGroupApprovals;

  /// Approval sheet action: send back
  ///
  /// In en, this message translates to:
  /// **'Send Back'**
  String get advisorActionSendBack;

  /// Approval sheet action: approve
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get advisorActionApprove;

  /// Approval row action when there is no amount to show
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get advisorActionReview;

  /// Contact sheet action: call
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get advisorContactCall;

  /// Contact sheet action: WhatsApp
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get advisorContactWhatsApp;

  /// Contact sheet action: SMS
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get advisorContactSms;

  /// Contact sheet action: mark reminder done
  ///
  /// In en, this message translates to:
  /// **'Mark Reminder as Done'**
  String get advisorActionMarkReminderDone;

  /// Stat dialog supporting text
  ///
  /// In en, this message translates to:
  /// **'Tap below to view the full list'**
  String get advisorStatViewAllHint;

  /// Stat dialog action: close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get advisorActionClose;

  /// Stat dialog action: view all
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get advisorActionViewAll;

  /// Toast when an approval is approved
  ///
  /// In en, this message translates to:
  /// **'{type} {id} approved'**
  String advisorToastApproved(String type, String id);

  /// Toast when an approval is sent back
  ///
  /// In en, this message translates to:
  /// **'{type} {id} rejected'**
  String advisorToastRejected(String type, String id);

  /// Toast when calling a customer
  ///
  /// In en, this message translates to:
  /// **'Calling {name}…'**
  String advisorToastCalling(String name);

  /// Toast when opening WhatsApp
  ///
  /// In en, this message translates to:
  /// **'Opening WhatsApp…'**
  String get advisorToastOpeningWhatsApp;

  /// Toast when an SMS is sent
  ///
  /// In en, this message translates to:
  /// **'SMS sent'**
  String get advisorToastSmsSent;

  /// Toast when a reminder is marked done
  ///
  /// In en, this message translates to:
  /// **'Marked as completed'**
  String get advisorToastMarkedDone;

  /// Job status label: pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get advisorStatusPending;

  /// Job status label: in progress
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get advisorStatusInProgress;

  /// Job status label: completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get advisorStatusCompleted;

  /// Job status label: waiting parts
  ///
  /// In en, this message translates to:
  /// **'Waiting Parts'**
  String get advisorStatusWaitingParts;

  /// Job status label: QC check
  ///
  /// In en, this message translates to:
  /// **'QC Check'**
  String get advisorStatusQc;

  /// Job status label: cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get advisorStatusCancelled;

  /// Job status label: awaiting supervisor
  ///
  /// In en, this message translates to:
  /// **'Awaiting Supervisor'**
  String get advisorStatusAwaitingSupervisor;

  /// Job status label: vehicle received
  ///
  /// In en, this message translates to:
  /// **'Vehicle Received'**
  String get advisorStatusVehicleReceived;

  /// Job status label: inspected
  ///
  /// In en, this message translates to:
  /// **'Inspected'**
  String get advisorStatusInspected;

  /// Job status label: approved
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get advisorStatusApproved;

  /// Job status label: work assigned
  ///
  /// In en, this message translates to:
  /// **'Work Assigned'**
  String get advisorStatusWorkAssigned;

  /// Job status label: waiting customer approval
  ///
  /// In en, this message translates to:
  /// **'Waiting Customer Approval'**
  String get advisorStatusWaitingCustomerApproval;

  /// Job status label: delivered
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get advisorStatusDelivered;

  /// Job status label: QC passed
  ///
  /// In en, this message translates to:
  /// **'QC Passed'**
  String get advisorStatusQcPassed;

  /// Job status label: pending approval
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get advisorStatusPendingApproval;

  /// Intake page title / top bar
  ///
  /// In en, this message translates to:
  /// **'Create Job Card'**
  String get advisorIntakeTitle;

  /// Intake intro heading (new record)
  ///
  /// In en, this message translates to:
  /// **'New vehicle intake'**
  String get advisorIntakeIntroTitleNew;

  /// Intake intro heading (from booking)
  ///
  /// In en, this message translates to:
  /// **'Complete the vehicle intake'**
  String get advisorIntakeIntroTitleBooking;

  /// Intake intro supporting text
  ///
  /// In en, this message translates to:
  /// **'Find an existing record or enter the customer and vehicle details below.'**
  String get advisorIntakeIntroBody;

  /// Intake required-fields hint
  ///
  /// In en, this message translates to:
  /// **'Only fields marked * are required'**
  String get advisorIntakeRequiredHint;

  /// Badge when intake is opened from a booking
  ///
  /// In en, this message translates to:
  /// **'Linked to the assigned booking'**
  String get advisorIntakeLinkedBooking;

  /// Intake progress step 1
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get advisorIntakeStepCustomer;

  /// Intake progress step 2
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get advisorIntakeStepVehicle;

  /// Intake progress step 3
  ///
  /// In en, this message translates to:
  /// **'Media & docs'**
  String get advisorIntakeStepMedia;

  /// Intake progress step 4
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get advisorIntakeStepJob;

  /// Intake progress step 5
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get advisorIntakeStepSignature;

  /// Intake progress step 6
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get advisorIntakeStepReview;

  /// Customer section title
  ///
  /// In en, this message translates to:
  /// **'Customer details'**
  String get advisorIntakeSectionCustomer;

  /// Customer section subtitle
  ///
  /// In en, this message translates to:
  /// **'Who is bringing in the vehicle?'**
  String get advisorIntakeSectionCustomerSub;

  /// Vehicle section title
  ///
  /// In en, this message translates to:
  /// **'Vehicle details'**
  String get advisorIntakeSectionVehicle;

  /// Vehicle section subtitle
  ///
  /// In en, this message translates to:
  /// **'Registration and service information'**
  String get advisorIntakeSectionVehicleSub;

  /// Body-condition section title
  ///
  /// In en, this message translates to:
  /// **'Vehicle body condition'**
  String get advisorIntakeSectionBody;

  /// Body-condition section subtitle
  ///
  /// In en, this message translates to:
  /// **'Mark any existing damage before handover'**
  String get advisorIntakeSectionBodySub;

  /// Documents/media section title
  ///
  /// In en, this message translates to:
  /// **'Documents & media'**
  String get advisorIntakeSectionMedia;

  /// Documents/media section subtitle
  ///
  /// In en, this message translates to:
  /// **'Attach documents, photos and videos'**
  String get advisorIntakeSectionMediaSub;

  /// Job description section title
  ///
  /// In en, this message translates to:
  /// **'Job description'**
  String get advisorIntakeSectionJob;

  /// Job description section subtitle
  ///
  /// In en, this message translates to:
  /// **'Describe the requested work'**
  String get advisorIntakeSectionJobSub;

  /// Signature section title
  ///
  /// In en, this message translates to:
  /// **'Signatures'**
  String get advisorIntakeSectionSignature;

  /// Signature section subtitle
  ///
  /// In en, this message translates to:
  /// **'Capture customer and advisor consent'**
  String get advisorIntakeSectionSignatureSub;

  /// Review section title
  ///
  /// In en, this message translates to:
  /// **'Review & save'**
  String get advisorIntakeSectionReview;

  /// Review section subtitle
  ///
  /// In en, this message translates to:
  /// **'Confirm the details before creating the job card'**
  String get advisorIntakeSectionReviewSub;

  /// Record search section title
  ///
  /// In en, this message translates to:
  /// **'Find existing record'**
  String get advisorIntakeFindTitle;

  /// Record search supporting text
  ///
  /// In en, this message translates to:
  /// **'Avoid duplicate customer and vehicle records'**
  String get advisorIntakeFindSub;

  /// Record search field hint
  ///
  /// In en, this message translates to:
  /// **'Mobile, customer name, plate number, or VIN'**
  String get advisorIntakeFindHint;

  /// Scan VIN button
  ///
  /// In en, this message translates to:
  /// **'Scan VIN'**
  String get advisorIntakeScanVin;

  /// Scan QR button
  ///
  /// In en, this message translates to:
  /// **'Scan vehicle QR'**
  String get advisorIntakeScanQr;

  /// B2B toggle label
  ///
  /// In en, this message translates to:
  /// **'B2B customer'**
  String get advisorIntakeB2B;

  /// Customer name label
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get advisorIntakeCustomerName;

  /// Customer name hint
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get advisorIntakeCustomerNameHint;

  /// Phone label
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get advisorIntakePhone;

  /// Phone hint
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get advisorIntakePhoneHint;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get advisorIntakeEmail;

  /// Email hint
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get advisorIntakeEmailHint;

  /// Customer group label
  ///
  /// In en, this message translates to:
  /// **'Customer group'**
  String get advisorIntakeCustomerGroup;

  /// Customer group hint
  ///
  /// In en, this message translates to:
  /// **'Select customer group'**
  String get advisorIntakeCustomerGroupHint;

  /// Gender label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get advisorIntakeGender;

  /// Gender hint
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get advisorIntakeGenderHint;

  /// Address label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get advisorIntakeAddress;

  /// Address hint
  ///
  /// In en, this message translates to:
  /// **'Select address'**
  String get advisorIntakeAddressHint;

  /// Tax number label
  ///
  /// In en, this message translates to:
  /// **'Tax number'**
  String get advisorIntakeTaxNumber;

  /// Source label
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get advisorIntakeSource;

  /// Source hint
  ///
  /// In en, this message translates to:
  /// **'How did you hear about us?'**
  String get advisorIntakeSourceHint;

  /// Show more link
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get advisorIntakeShowMore;

  /// Show less link
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get advisorIntakeShowLess;

  /// Emirate label
  ///
  /// In en, this message translates to:
  /// **'Emirate'**
  String get advisorIntakeEmirate;

  /// Emirate hint
  ///
  /// In en, this message translates to:
  /// **'Select emirate'**
  String get advisorIntakeEmirateHint;

  /// Plate code label
  ///
  /// In en, this message translates to:
  /// **'Plate code'**
  String get advisorIntakePlateCode;

  /// Plate code hint
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get advisorIntakePlateCodeHint;

  /// Plate number label
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get advisorIntakePlateNumber;

  /// Plate number hint
  ///
  /// In en, this message translates to:
  /// **'2500'**
  String get advisorIntakePlateNumberHint;

  /// VIN label
  ///
  /// In en, this message translates to:
  /// **'VIN (chassis number)'**
  String get advisorIntakeVin;

  /// VIN hint
  ///
  /// In en, this message translates to:
  /// **'VIN (chassis number)'**
  String get advisorIntakeVinHint;

  /// Make label
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get advisorIntakeMake;

  /// Make hint
  ///
  /// In en, this message translates to:
  /// **'Select brand'**
  String get advisorIntakeMakeHint;

  /// Model label
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get advisorIntakeModel;

  /// Model hint
  ///
  /// In en, this message translates to:
  /// **'Select model'**
  String get advisorIntakeModelHint;

  /// Model year label
  ///
  /// In en, this message translates to:
  /// **'Model year'**
  String get advisorIntakeModelYear;

  /// Model year hint
  ///
  /// In en, this message translates to:
  /// **'Select model year'**
  String get advisorIntakeModelYearHint;

  /// Message when picking a model before a brand
  ///
  /// In en, this message translates to:
  /// **'Please select a brand first'**
  String get advisorIntakeSelectBrandFirst;

  /// Cylinders label
  ///
  /// In en, this message translates to:
  /// **'Number of cylinders'**
  String get advisorIntakeCylinders;

  /// Cylinders hint
  ///
  /// In en, this message translates to:
  /// **'Number of cylinders'**
  String get advisorIntakeCylindersHint;

  /// Engine capacity label
  ///
  /// In en, this message translates to:
  /// **'Engine capacity'**
  String get advisorIntakeEngineCapacity;

  /// Vehicle colour label
  ///
  /// In en, this message translates to:
  /// **'Vehicle colour'**
  String get advisorIntakeVehicleColor;

  /// Fuel type label
  ///
  /// In en, this message translates to:
  /// **'Fuel type'**
  String get advisorIntakeFuelType;

  /// Fuel type hint
  ///
  /// In en, this message translates to:
  /// **'Select fuel type'**
  String get advisorIntakeFuelTypeHint;

  /// Engine number label
  ///
  /// In en, this message translates to:
  /// **'Engine number'**
  String get advisorIntakeEngineNumber;

  /// Registration document label
  ///
  /// In en, this message translates to:
  /// **'Registration certificate'**
  String get advisorIntakeRegistrationCertificate;

  /// Add document button
  ///
  /// In en, this message translates to:
  /// **'Add document'**
  String get advisorIntakeAddDocument;

  /// Job category label
  ///
  /// In en, this message translates to:
  /// **'Job category'**
  String get advisorIntakeJobCategory;

  /// Job category hint
  ///
  /// In en, this message translates to:
  /// **'Select job category'**
  String get advisorIntakeJobCategoryHint;

  /// Insurance provider label
  ///
  /// In en, this message translates to:
  /// **'Insurance name'**
  String get advisorIntakeInsuranceName;

  /// Insurance provider hint
  ///
  /// In en, this message translates to:
  /// **'Select insurance provider'**
  String get advisorIntakeInsuranceNameHint;

  /// LPO number label
  ///
  /// In en, this message translates to:
  /// **'LPO number'**
  String get advisorIntakeLpoNumber;

  /// Policy number label
  ///
  /// In en, this message translates to:
  /// **'Policy number'**
  String get advisorIntakePolicyNumber;

  /// Accident number label
  ///
  /// In en, this message translates to:
  /// **'Accident number'**
  String get advisorIntakeAccidentNumber;

  /// Insurance tax number label
  ///
  /// In en, this message translates to:
  /// **'Insurance tax number'**
  String get advisorIntakeInsuranceTaxNumber;

  /// Insurance tax number hint
  ///
  /// In en, this message translates to:
  /// **'Enter insurance tax number'**
  String get advisorIntakeInsuranceTaxHint;

  /// Insurance address label
  ///
  /// In en, this message translates to:
  /// **'Insurance address'**
  String get advisorIntakeInsuranceAddress;

  /// Insurance expiry label
  ///
  /// In en, this message translates to:
  /// **'Insurance expiry date'**
  String get advisorIntakeInsuranceExpiry;

  /// Insurance document label
  ///
  /// In en, this message translates to:
  /// **'Insurance document'**
  String get advisorIntakeInsuranceDocument;

  /// Markup type label
  ///
  /// In en, this message translates to:
  /// **'Markup type'**
  String get advisorIntakeMarkupType;

  /// Order type label
  ///
  /// In en, this message translates to:
  /// **'Order type'**
  String get advisorIntakeOrderType;

  /// Job description label
  ///
  /// In en, this message translates to:
  /// **'Job description'**
  String get advisorIntakeJobDescription;

  /// Add job description row button
  ///
  /// In en, this message translates to:
  /// **'Add another description'**
  String get advisorIntakeAddDescription;

  /// Remove job description row
  ///
  /// In en, this message translates to:
  /// **'Remove row'**
  String get advisorIntakeRemoveRow;

  /// Job description field hint
  ///
  /// In en, this message translates to:
  /// **'Describe the requested work. Use the toolbar to bold or add bullet points.'**
  String get advisorIntakeDescriptionHint;

  /// Priority field label
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get advisorIntakePriority;

  /// Priority tooltip
  ///
  /// In en, this message translates to:
  /// **'Select priority'**
  String get advisorIntakeSelectPriority;

  /// Attachments label on a job description row
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get advisorIntakeAttachments;

  /// Photos attachment label
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get advisorIntakePhotos;

  /// Video attachment label
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get advisorIntakeVideo;

  /// Audio attachment label
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get advisorIntakeAudio;

  /// Rich text bold tool
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get advisorIntakeBold;

  /// Rich text italic tool
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get advisorIntakeItalic;

  /// Rich text bullet tool
  ///
  /// In en, this message translates to:
  /// **'Bullet list'**
  String get advisorIntakeBullet;

  /// Attachment button label with count
  ///
  /// In en, this message translates to:
  /// **'{label} ({count})'**
  String advisorIntakeCount(String label, int count);

  /// Add-media tile label
  ///
  /// In en, this message translates to:
  /// **'Add {label}'**
  String advisorIntakeAddLabel(String label);

  /// Odometer label
  ///
  /// In en, this message translates to:
  /// **'Odometer reading (km)'**
  String get advisorIntakeOdometer;

  /// Odometer hint
  ///
  /// In en, this message translates to:
  /// **'Odometer (in km)'**
  String get advisorIntakeOdometerHint;

  /// Fuel level label
  ///
  /// In en, this message translates to:
  /// **'Fuel level'**
  String get advisorIntakeFuelLevel;

  /// Consent toggle label
  ///
  /// In en, this message translates to:
  /// **'Customer consent'**
  String get advisorIntakeCustomerConsent;

  /// Job media label
  ///
  /// In en, this message translates to:
  /// **'Job card photos and videos'**
  String get advisorIntakeJobMedia;

  /// Signatures label
  ///
  /// In en, this message translates to:
  /// **'Digital signatures'**
  String get advisorIntakeDigitalSignatures;

  /// Customer signature button
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get advisorIntakeSignatureCustomer;

  /// Advisor signature button
  ///
  /// In en, this message translates to:
  /// **'Advisor'**
  String get advisorIntakeSignatureAdvisor;

  /// Customer signature sheet title
  ///
  /// In en, this message translates to:
  /// **'Customer signature'**
  String get advisorIntakeSignatureCustomerTitle;

  /// Advisor signature sheet title
  ///
  /// In en, this message translates to:
  /// **'Advisor signature'**
  String get advisorIntakeSignatureAdvisorTitle;

  /// Signature sheet instruction
  ///
  /// In en, this message translates to:
  /// **'Sign in the box below'**
  String get advisorIntakeSignatureInstruction;

  /// Signature clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get advisorIntakeSignatureClear;

  /// Signature confirm button
  ///
  /// In en, this message translates to:
  /// **'Use signature'**
  String get advisorIntakeSignatureUse;

  /// Shown when a signature is captured
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get advisorIntakeSignatureCaptured;

  /// Re-capture signature
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get advisorIntakeSignatureRedo;

  /// Document source sheet title (registration)
  ///
  /// In en, this message translates to:
  /// **'Add registration certificate'**
  String get advisorIntakeAddRegistration;

  /// Document source sheet title (insurance)
  ///
  /// In en, this message translates to:
  /// **'Add insurance document'**
  String get advisorIntakeAddInsurance;

  /// Camera source action
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get advisorIntakeTakePhoto;

  /// Gallery source action
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get advisorIntakeChooseGallery;

  /// Record video action
  ///
  /// In en, this message translates to:
  /// **'Record video'**
  String get advisorIntakeRecordVideo;

  /// Choose video action
  ///
  /// In en, this message translates to:
  /// **'Choose video'**
  String get advisorIntakeChooseVideo;

  /// Audio dialog title
  ///
  /// In en, this message translates to:
  /// **'Job description audio'**
  String get advisorIntakeAudioTitle;

  /// Audio dialog recording status
  ///
  /// In en, this message translates to:
  /// **'Recording… {seconds} seconds'**
  String advisorIntakeAudioRecording(int seconds);

  /// Audio dialog replace hint
  ///
  /// In en, this message translates to:
  /// **'Record again to replace the current audio.'**
  String get advisorIntakeAudioReplace;

  /// Audio dialog prompt
  ///
  /// In en, this message translates to:
  /// **'Record a voice note up to 60 seconds.'**
  String get advisorIntakeAudioPrompt;

  /// Validation: customer name
  ///
  /// In en, this message translates to:
  /// **'Please enter the customer name'**
  String get advisorIntakeErrCustomerName;

  /// Validation: phone empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a mobile number'**
  String get advisorIntakeErrPhone;

  /// Validation: phone invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number'**
  String get advisorIntakeErrPhoneValid;

  /// Validation: plate
  ///
  /// In en, this message translates to:
  /// **'Please enter the plate number'**
  String get advisorIntakeErrPlate;

  /// Validation: make
  ///
  /// In en, this message translates to:
  /// **'Please select the vehicle brand'**
  String get advisorIntakeErrMake;

  /// Validation: model
  ///
  /// In en, this message translates to:
  /// **'Please select the vehicle model'**
  String get advisorIntakeErrModel;

  /// Inspection prompt title (synced)
  ///
  /// In en, this message translates to:
  /// **'Job card created & synced'**
  String get advisorIntakeSyncedTitle;

  /// Inspection prompt title (local only)
  ///
  /// In en, this message translates to:
  /// **'Job card saved locally'**
  String get advisorIntakeLocalTitle;

  /// Inspection prompt body (synced)
  ///
  /// In en, this message translates to:
  /// **'Saved to this device and the server. Would you like to start the inspection?'**
  String get advisorIntakeSyncedBody;

  /// Inspection prompt body (local only)
  ///
  /// In en, this message translates to:
  /// **'The API could not be reached. The job card is safely stored and queued for automatic sync.'**
  String get advisorIntakeLocalBody;

  /// Inspection prompt primary action
  ///
  /// In en, this message translates to:
  /// **'Add inspection'**
  String get advisorIntakeAddInspection;

  /// Inspection prompt secondary action
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get advisorIntakeSkip;

  /// Save failure snackbar
  ///
  /// In en, this message translates to:
  /// **'We could not create the job card. Please check your connection and try again.'**
  String get advisorIntakeSaveFailed;

  /// Offline notice panel
  ///
  /// In en, this message translates to:
  /// **'You are offline. The job card will be stored on this device and synced automatically.'**
  String get advisorIntakeOfflineNotice;

  /// Summary panel title
  ///
  /// In en, this message translates to:
  /// **'Live summary'**
  String get advisorIntakeSummaryTitle;

  /// Summary empty text
  ///
  /// In en, this message translates to:
  /// **'Start filling in the details to see a live summary.'**
  String get advisorIntakeSummaryEmpty;

  /// Summary customer placeholder
  ///
  /// In en, this message translates to:
  /// **'No customer yet'**
  String get advisorIntakeSummaryNoName;

  /// Summary customer heading
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get advisorIntakeSummaryCustomer;

  /// Summary vehicle heading
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get advisorIntakeSummaryVehicle;

  /// Summary progress line
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} sections complete'**
  String advisorIntakeSummaryProgress(int done, int total);

  /// Discard guard title
  ///
  /// In en, this message translates to:
  /// **'Discard this intake?'**
  String get advisorIntakeDiscardTitle;

  /// Discard guard body
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leaving now will lose the information you entered.'**
  String get advisorIntakeDiscardBody;

  /// Discard guard confirm
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get advisorIntakeDiscardConfirm;

  /// Discard guard cancel
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get advisorIntakeDiscardCancel;

  /// Primary save action
  ///
  /// In en, this message translates to:
  /// **'Create job card'**
  String get advisorIntakeActionCreate;

  /// Primary save busy label
  ///
  /// In en, this message translates to:
  /// **'Creating job card…'**
  String get advisorIntakeActionCreating;

  /// Save status: saving locally
  ///
  /// In en, this message translates to:
  /// **'Saving locally…'**
  String get advisorIntakeStatusSaving;

  /// Save status: queued
  ///
  /// In en, this message translates to:
  /// **'Queued (offline)'**
  String get advisorIntakeStatusQueued;

  /// Save status: sent
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get advisorIntakeStatusSent;

  /// Section position
  ///
  /// In en, this message translates to:
  /// **'Section {index} of {total}'**
  String advisorIntakeSectionOf(int index, int total);

  /// Scan screen title
  ///
  /// In en, this message translates to:
  /// **'Scan vehicle'**
  String get advisorScanTitle;

  /// Scan mode: plate
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get advisorScanModePlate;

  /// Scan mode: VIN
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get advisorScanModeVin;

  /// Scan mode: QR
  ///
  /// In en, this message translates to:
  /// **'QR'**
  String get advisorScanModeQr;

  /// Scan hint: plate
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the license plate'**
  String get advisorScanHintPlate;

  /// Scan hint: VIN
  ///
  /// In en, this message translates to:
  /// **'Scan the VIN barcode on the dashboard'**
  String get advisorScanHintVin;

  /// Scan hint: QR
  ///
  /// In en, this message translates to:
  /// **'Scan the vehicle QR code'**
  String get advisorScanHintQr;

  /// Manual entry divider
  ///
  /// In en, this message translates to:
  /// **'Or enter manually'**
  String get advisorScanManual;

  /// Manual entry hint
  ///
  /// In en, this message translates to:
  /// **'Plate / VIN / Customer name…'**
  String get advisorScanManualHint;

  /// Permission denied title
  ///
  /// In en, this message translates to:
  /// **'Camera permission required'**
  String get advisorScanPermissionTitle;

  /// Permission denied body
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to scan. Enable it in settings to continue.'**
  String get advisorScanPermissionBody;

  /// Open settings action
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get advisorScanOpenSettings;

  /// Grant permission action
  ///
  /// In en, this message translates to:
  /// **'Grant permission'**
  String get advisorScanGrant;

  /// Camera starting status
  ///
  /// In en, this message translates to:
  /// **'Starting camera…'**
  String get advisorScanStarting;

  /// Scanning status
  ///
  /// In en, this message translates to:
  /// **'Scanning…'**
  String get advisorScanScanning;

  /// Camera unavailable status
  ///
  /// In en, this message translates to:
  /// **'Camera not available'**
  String get advisorScanCameraUnavailable;

  /// Torch toggle tooltip
  ///
  /// In en, this message translates to:
  /// **'Toggle torch'**
  String get advisorScanTorch;

  /// Scan result confirmation title
  ///
  /// In en, this message translates to:
  /// **'Scan result'**
  String get advisorScanResultTitle;

  /// Confirm scanned value
  ///
  /// In en, this message translates to:
  /// **'Use this value'**
  String get advisorScanResultUse;

  /// Validation when manual entry is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a value to continue'**
  String get advisorScanEnterValue;

  /// Check-in page title
  ///
  /// In en, this message translates to:
  /// **'Vehicle check-in'**
  String get advisorCheckInTitle;

  /// Check-in step 1 label
  ///
  /// In en, this message translates to:
  /// **'Odometer & fuel'**
  String get advisorCheckInStepDetails;

  /// Check-in step 2 label
  ///
  /// In en, this message translates to:
  /// **'Document condition'**
  String get advisorCheckInStepCondition;

  /// Check-in odometer label
  ///
  /// In en, this message translates to:
  /// **'Odometer reading (km)'**
  String get advisorCheckInOdometer;

  /// Check-in odometer hint
  ///
  /// In en, this message translates to:
  /// **'e.g. 14200'**
  String get advisorCheckInOdometerHint;

  /// Check-in fuel label
  ///
  /// In en, this message translates to:
  /// **'Fuel level'**
  String get advisorCheckInFuel;

  /// Check-in notes label
  ///
  /// In en, this message translates to:
  /// **'Customer notes'**
  String get advisorCheckInNotes;

  /// Check-in notes hint
  ///
  /// In en, this message translates to:
  /// **'Add any notes from the customer'**
  String get advisorCheckInNotesHint;

  /// Check-in next action
  ///
  /// In en, this message translates to:
  /// **'Next: document condition'**
  String get advisorCheckInNext;

  /// Check-in back action
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get advisorCheckInBack;

  /// Damage area: front
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get advisorCheckInFront;

  /// Damage area: rear
  ///
  /// In en, this message translates to:
  /// **'Rear'**
  String get advisorCheckInRear;

  /// Damage area: left side
  ///
  /// In en, this message translates to:
  /// **'Left side'**
  String get advisorCheckInLeft;

  /// Damage area: right side
  ///
  /// In en, this message translates to:
  /// **'Right side'**
  String get advisorCheckInRight;

  /// Damage area: roof
  ///
  /// In en, this message translates to:
  /// **'Roof'**
  String get advisorCheckInRoof;

  /// Add damage action
  ///
  /// In en, this message translates to:
  /// **'Add damage'**
  String get advisorCheckInAddDamage;

  /// Damage dialog title
  ///
  /// In en, this message translates to:
  /// **'Damage on {area}'**
  String advisorCheckInDamageTitle(String area);

  /// Damage dialog field hint
  ///
  /// In en, this message translates to:
  /// **'Describe damage (e.g. scratch, dent)'**
  String get advisorCheckInDamageHint;

  /// Damage dialog add action
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get advisorCheckInAdd;

  /// Check-in submit action
  ///
  /// In en, this message translates to:
  /// **'Complete check-in'**
  String get advisorCheckInComplete;

  /// Check-in success toast
  ///
  /// In en, this message translates to:
  /// **'Vehicle checked in successfully'**
  String get advisorCheckInSuccess;

  /// Check-in failure toast
  ///
  /// In en, this message translates to:
  /// **'Failed to check in. Please try again.'**
  String get advisorCheckInFailed;

  /// Check-in error toast
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String advisorCheckInError(String message);

  /// Empty damage list text
  ///
  /// In en, this message translates to:
  /// **'No damage recorded yet'**
  String get advisorCheckInEmptyDamages;

  /// Check-in details section title
  ///
  /// In en, this message translates to:
  /// **'Odometer, fuel & notes'**
  String get advisorCheckInSectionDetails;

  /// Check-in damage section title
  ///
  /// In en, this message translates to:
  /// **'Existing damage'**
  String get advisorCheckInSectionDamage;

  /// Check-in damage section subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap an area to record any existing damage'**
  String get advisorCheckInSectionDamageSub;

  /// Remove a recorded damage
  ///
  /// In en, this message translates to:
  /// **'Remove damage'**
  String get advisorCheckInRemoveDamage;

  /// Jobs matrix column: customer
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get advisorJobsColumnCustomer;

  /// Jobs matrix column: job card id
  ///
  /// In en, this message translates to:
  /// **'Job Card'**
  String get advisorJobsColumnJobCard;

  /// Jobs matrix column: status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get advisorJobsColumnStatus;

  /// Jobs matrix column: timing
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get advisorJobsColumnTime;

  /// Desktop master-detail empty detail prompt
  ///
  /// In en, this message translates to:
  /// **'Select a job card to preview the details'**
  String get advisorJobsSelectPrompt;

  /// Open the full job card workspace
  ///
  /// In en, this message translates to:
  /// **'Open Job Card'**
  String get advisorActionOpenJob;

  /// Contextual row overflow action tooltip
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get advisorActionMore;
}

class _StaffLocalizationsDelegate
    extends LocalizationsDelegate<StaffLocalizations> {
  const _StaffLocalizationsDelegate();

  @override
  Future<StaffLocalizations> load(Locale locale) {
    return SynchronousFuture<StaffLocalizations>(
      lookupStaffLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_StaffLocalizationsDelegate old) => false;
}

StaffLocalizations lookupStaffLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return StaffLocalizationsAr();
    case 'en':
      return StaffLocalizationsEn();
  }

  throw FlutterError(
    'StaffLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
