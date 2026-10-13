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
