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
  /// **'Quick actions'**
  String get advisorQuickActionsEyebrow;

  /// Quick action: scan vehicle
  ///
  /// In en, this message translates to:
  /// **'Scan vehicle'**
  String get advisorActionScanTitle;

  /// Quick action subtitle: scan vehicle
  ///
  /// In en, this message translates to:
  /// **'VIN / plate'**
  String get advisorActionScanSubtitle;

  /// Quick action: new job card
  ///
  /// In en, this message translates to:
  /// **'New job card'**
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

  /// Section title for the shift metric strip
  ///
  /// In en, this message translates to:
  /// **'Work summary'**
  String get advisorWorkSummary;

  /// Legacy section action (unused on home; retained for parity)
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get advisorActionAnalytics;

  /// Section title for recent job cards
  ///
  /// In en, this message translates to:
  /// **'Assigned work orders'**
  String get advisorAssignedWorkOrders;

  /// Neutral section title: the work-orders feed is status-agnostic (U8), so Assigned would over-promise
  ///
  /// In en, this message translates to:
  /// **'Work orders'**
  String get advisorWorkOrdersTitle;

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
  /// **'Total orders'**
  String get advisorMetricTotalOrders;

  /// Metric tile label: in progress
  ///
  /// In en, this message translates to:
  /// **'In progress'**
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
  /// **'In progress'**
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
  /// **'QC check'**
  String get advisorFilterQc;

  /// Jobs status filter: cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get advisorFilterCancelled;

  /// Today-tab eyebrow above the greeting
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get advisorTodayEyebrow;

  /// Jobs status filter: intake
  ///
  /// In en, this message translates to:
  /// **'Intake'**
  String get advisorFilterIntake;

  /// Jobs status filter: inspection
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get advisorFilterInspection;

  /// Jobs status filter: approved
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get advisorFilterApproved;

  /// Jobs status filter: work in progress
  ///
  /// In en, this message translates to:
  /// **'WIP'**
  String get advisorFilterWip;

  /// Jobs status filter: ready
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get advisorFilterReady;

  /// Jobs sort control label
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get advisorSortLabel;

  /// Jobs sort option: newest first
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get advisorSortNewest;

  /// Jobs sort option: oldest first
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get advisorSortOldest;

  /// Jobs sort option: customer name
  ///
  /// In en, this message translates to:
  /// **'Customer A–Z'**
  String get advisorSortCustomer;

  /// See-all affordance on capped sections
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get advisorSeeAll;

  /// Home summary metric: ready job cards
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get advisorMetricReady;

  /// Urgent-row microcopy for work due today
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get advisorDueToday;

  /// Home freshness timestamp after pull-refresh
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String advisorHomeUpdatedAt(String time);

  /// Home hero key number: inspections due today
  ///
  /// In en, this message translates to:
  /// **'{count} inspections due today'**
  String advisorHeroDueTitle(int count);

  /// Home hero plain-language sentence under the key number
  ///
  /// In en, this message translates to:
  /// **'Review what\'s urgent first.'**
  String get advisorHeroSentence;

  /// Home hero primary action opening the Jobs tab
  ///
  /// In en, this message translates to:
  /// **'View jobs'**
  String get advisorHeroViewJobs;

  /// Home hero sentence when nothing is due today
  ///
  /// In en, this message translates to:
  /// **'You\'re caught up — new jobs will appear here.'**
  String get advisorHeroCaughtUp;

  /// Empty assigned-list title on the advisor home
  ///
  /// In en, this message translates to:
  /// **'No jobs assigned yet'**
  String get advisorHomeEmptyTitle;

  /// Empty assigned-list body on the advisor home
  ///
  /// In en, this message translates to:
  /// **'New job cards will appear here. Create one to get started.'**
  String get advisorHomeEmptyBody;

  /// Quick-action tile: approvals
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get advisorActionApprovalsTitle;

  /// Quick-action tile subtitle: approvals
  ///
  /// In en, this message translates to:
  /// **'Pending sign-off'**
  String get advisorActionApprovalsSubtitle;

  /// Quick-action tile: search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get advisorActionSearchTitle;

  /// Quick-action tile subtitle: search
  ///
  /// In en, this message translates to:
  /// **'Jobs and customers'**
  String get advisorActionSearchSubtitle;

  /// Metric delta line for today's intake
  ///
  /// In en, this message translates to:
  /// **'+{count} today'**
  String advisorDeltaToday(int count);

  /// Job detail section: lifecycle stages
  ///
  /// In en, this message translates to:
  /// **'Stages'**
  String get advisorSectionStages;

  /// Job detail section: inspection checklist
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get advisorSectionChecklist;

  /// Job detail section: estimates
  ///
  /// In en, this message translates to:
  /// **'Estimates'**
  String get advisorSectionEstimates;

  /// Job detail section: invoices
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get advisorSectionInvoices;

  /// Job detail section: notes
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get advisorSectionNotes;

  /// Lifecycle stage: intake
  ///
  /// In en, this message translates to:
  /// **'Intake'**
  String get advisorStageIntake;

  /// Lifecycle stage: inspection
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get advisorStageInspection;

  /// Lifecycle stage: estimate
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get advisorStageEstimate;

  /// Lifecycle stage: repair
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get advisorStageRepair;

  /// Lifecycle stage: quality control
  ///
  /// In en, this message translates to:
  /// **'QC'**
  String get advisorStageQc;

  /// Lifecycle stage: ready
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get advisorStageReady;

  /// Empty estimates section on job detail
  ///
  /// In en, this message translates to:
  /// **'No estimates for this job yet.'**
  String get advisorEmptyEstimates;

  /// Empty invoices section on job detail
  ///
  /// In en, this message translates to:
  /// **'No invoices for this job yet.'**
  String get advisorEmptyInvoices;

  /// Empty notes section on job detail
  ///
  /// In en, this message translates to:
  /// **'No notes for this job yet.'**
  String get advisorEmptyNotes;

  /// Empty checklist section on job detail
  ///
  /// In en, this message translates to:
  /// **'No checklist items recorded yet.'**
  String get advisorEmptyChecklist;

  /// Job detail rail section: activity history
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get advisorSectionActivity;

  /// Search sheet section: recent searches
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get advisorSearchRecent;

  /// Collapse affordance on expanded sections
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get advisorShowLess;

  /// Localized approval type: estimate
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get advisorApprovalTypeEstimate;

  /// Localized approval type: job card
  ///
  /// In en, this message translates to:
  /// **'Job card'**
  String get advisorApprovalTypeJobCard;

  /// Localized approval type: inspection
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get advisorApprovalTypeInspection;

  /// Reminder urgency: high
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get advisorPriorityHigh;

  /// Reminder urgency: medium
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get advisorPriorityMedium;

  /// Reminder urgency: low
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get advisorPriorityLow;

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

  /// Package picker screen title
  ///
  /// In en, this message translates to:
  /// **'Choose package'**
  String get advisorPackageTitle;

  /// Package picker supporting text
  ///
  /// In en, this message translates to:
  /// **'Pick the inspection depth for this vehicle. You can switch packages before starting.'**
  String get advisorPackageSubtitle;

  /// Quick inspection package name
  ///
  /// In en, this message translates to:
  /// **'Quick 20-Point Check'**
  String get advisorPackageQuick;

  /// Quick package description
  ///
  /// In en, this message translates to:
  /// **'Fast safety sweep for intake and express bays.'**
  String get advisorPackageQuickDesc;

  /// Comprehensive inspection package name
  ///
  /// In en, this message translates to:
  /// **'Comprehensive 60-Point Check'**
  String get advisorPackageFull;

  /// Comprehensive package description
  ///
  /// In en, this message translates to:
  /// **'Full under-hood, brakes, suspension, battery, tires and exterior inspection.'**
  String get advisorPackageFullDesc;

  /// Safety audit package name
  ///
  /// In en, this message translates to:
  /// **'Safety and Roadworthiness Audit'**
  String get advisorPackageSafety;

  /// Safety package description
  ///
  /// In en, this message translates to:
  /// **'Brake, steering, restraint and lighting audit for roadworthiness sign-off.'**
  String get advisorPackageSafetyDesc;

  /// Estimated package duration chip
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String advisorPackageDuration(int minutes);

  /// Package checkpoint count
  ///
  /// In en, this message translates to:
  /// **'{count} checkpoints'**
  String advisorPackageCheckpoints(int count);

  /// Package section count
  ///
  /// In en, this message translates to:
  /// **'{count} sections'**
  String advisorPackageSections(int count);

  /// Package focus areas label
  ///
  /// In en, this message translates to:
  /// **'Focus areas'**
  String get advisorPackageFocus;

  /// Focus area: brakes
  ///
  /// In en, this message translates to:
  /// **'Brakes'**
  String get advisorFocusBrakes;

  /// Focus area: engine
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get advisorFocusEngine;

  /// Focus area: suspension
  ///
  /// In en, this message translates to:
  /// **'Suspension'**
  String get advisorFocusSuspension;

  /// Focus area: lighting
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get advisorFocusLighting;

  /// Recommended package badge
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get advisorPackageRecommended;

  /// Selected package badge
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get advisorPackageSelected;

  /// Package picker primary CTA
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get advisorPackageStart;

  /// Package sort: recommended order
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get advisorPackageSortRecommended;

  /// Package sort: fastest first
  ///
  /// In en, this message translates to:
  /// **'Quickest'**
  String get advisorPackageSortQuickest;

  /// Package sort: most checkpoints first
  ///
  /// In en, this message translates to:
  /// **'Most thorough'**
  String get advisorPackageSortThorough;

  /// Package picker skip action
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get advisorPackageSkip;

  /// Inspection sheet screen title
  ///
  /// In en, this message translates to:
  /// **'Inspection workspace'**
  String get advisorHudTitle;

  /// Inspection progress subtitle
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} checkpoints'**
  String advisorHudProgress(int done, int total);

  /// HUD tab: damage map
  ///
  /// In en, this message translates to:
  /// **'Damage map'**
  String get advisorHudTabDamage;

  /// HUD tab: checkpoints
  ///
  /// In en, this message translates to:
  /// **'Checkpoints'**
  String get advisorHudTabChecks;

  /// Damage canvas section title
  ///
  /// In en, this message translates to:
  /// **'Damage canvas'**
  String get advisorHudCanvasTitle;

  /// Damage canvas hint
  ///
  /// In en, this message translates to:
  /// **'Tap a body part to log damage. Pinch to zoom, drag to pan.'**
  String get advisorHudCanvasHint;

  /// Damage kind picker title
  ///
  /// In en, this message translates to:
  /// **'What kind of damage?'**
  String get advisorHudKindTitle;

  /// Damage kind: minor scratch
  ///
  /// In en, this message translates to:
  /// **'Minor scratch'**
  String get advisorHudKindMinor;

  /// Minor damage hint
  ///
  /// In en, this message translates to:
  /// **'Scuff or surface scratch'**
  String get advisorHudKindMinorHint;

  /// Damage kind: structural dent
  ///
  /// In en, this message translates to:
  /// **'Structural dent'**
  String get advisorHudKindStructural;

  /// Structural damage hint
  ///
  /// In en, this message translates to:
  /// **'Deep dent or deformation'**
  String get advisorHudKindStructuralHint;

  /// Damage kind: glass or lamp
  ///
  /// In en, this message translates to:
  /// **'Glass or lamp crack'**
  String get advisorHudKindGlass;

  /// Glass damage hint
  ///
  /// In en, this message translates to:
  /// **'Cracked glass or lamp assembly'**
  String get advisorHudKindGlassHint;

  /// Damage pins list title
  ///
  /// In en, this message translates to:
  /// **'Damage pins'**
  String get advisorHudPinsTitle;

  /// Empty pins state
  ///
  /// In en, this message translates to:
  /// **'No damage pinned yet'**
  String get advisorHudNoPins;

  /// Empty pins hint
  ///
  /// In en, this message translates to:
  /// **'Tap the car above to log the first damage point.'**
  String get advisorHudNoPinsHint;

  /// Delete damage pin action
  ///
  /// In en, this message translates to:
  /// **'Delete pin'**
  String get advisorHudDeletePin;

  /// Damage zone: front
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get advisorHudZoneFront;

  /// Damage zone: front left
  ///
  /// In en, this message translates to:
  /// **'Front left'**
  String get advisorHudZoneFrontLeft;

  /// Damage zone: left side
  ///
  /// In en, this message translates to:
  /// **'Left side'**
  String get advisorHudZoneSideLeft;

  /// Damage zone: rear left
  ///
  /// In en, this message translates to:
  /// **'Rear left'**
  String get advisorHudZoneRearLeft;

  /// Damage zone: rear
  ///
  /// In en, this message translates to:
  /// **'Rear'**
  String get advisorHudZoneRear;

  /// Damage zone: rear right
  ///
  /// In en, this message translates to:
  /// **'Rear right'**
  String get advisorHudZoneRearRight;

  /// Damage zone: right side
  ///
  /// In en, this message translates to:
  /// **'Right side'**
  String get advisorHudZoneSideRight;

  /// Damage zone: front right
  ///
  /// In en, this message translates to:
  /// **'Front right'**
  String get advisorHudZoneFrontRight;

  /// Checkpoint ring: pass
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get advisorHudRingPass;

  /// Checkpoint ring: caution
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get advisorHudRingCaution;

  /// Checkpoint ring: fail
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get advisorHudRingFail;

  /// Mark remaining checkpoints pass
  ///
  /// In en, this message translates to:
  /// **'All pass'**
  String get advisorHudMarkAllPass;

  /// Checkpoint search hint
  ///
  /// In en, this message translates to:
  /// **'Search checkpoints…'**
  String get advisorHudSearchHint;

  /// Checkpoint search empty state
  ///
  /// In en, this message translates to:
  /// **'No matching checkpoints'**
  String get advisorHudNoMatch;

  /// Remaining checkpoints in section
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String advisorHudSectionRemaining(int count);

  /// Section complete state
  ///
  /// In en, this message translates to:
  /// **'All checkpoints completed'**
  String get advisorHudSectionDone;

  /// Evidence dock title
  ///
  /// In en, this message translates to:
  /// **'Voice and photo evidence'**
  String get advisorHudDockTitle;

  /// Voice recorder idle state
  ///
  /// In en, this message translates to:
  /// **'Tap to record a voice note'**
  String get advisorHudVoiceIdle;

  /// Voice recorder recording state
  ///
  /// In en, this message translates to:
  /// **'Recording… {seconds}s'**
  String advisorHudVoiceRecording(int seconds);

  /// Play voice note
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get advisorHudVoicePlay;

  /// Delete voice note
  ///
  /// In en, this message translates to:
  /// **'Delete recording'**
  String get advisorHudVoiceDelete;

  /// Voice note saved state
  ///
  /// In en, this message translates to:
  /// **'Voice note saved'**
  String get advisorHudVoiceSaved;

  /// Microphone permission denied title
  ///
  /// In en, this message translates to:
  /// **'Microphone access denied'**
  String get advisorHudMicDenied;

  /// Microphone permission denied hint
  ///
  /// In en, this message translates to:
  /// **'Enable microphone access in system settings to record voice notes.'**
  String get advisorHudMicDeniedHint;

  /// Camera permission denied title
  ///
  /// In en, this message translates to:
  /// **'Camera access denied'**
  String get advisorHudCameraDenied;

  /// Camera permission denied hint
  ///
  /// In en, this message translates to:
  /// **'Enable camera access in system settings to capture photo evidence.'**
  String get advisorHudCameraDeniedHint;

  /// Gallery permission denied title
  ///
  /// In en, this message translates to:
  /// **'Gallery access denied'**
  String get advisorHudGalleryDenied;

  /// Gallery permission denied hint
  ///
  /// In en, this message translates to:
  /// **'Enable gallery access in system settings to attach photos.'**
  String get advisorHudGalleryDeniedHint;

  /// Open system settings action
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get advisorHudOpenSettings;

  /// Photo retry action
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get advisorHudPhotoRetry;

  /// Photo attach error
  ///
  /// In en, this message translates to:
  /// **'Photo failed to attach. Check storage and try again.'**
  String get advisorHudPhotoError;

  /// Sheet footer primary action
  ///
  /// In en, this message translates to:
  /// **'Review inspection'**
  String get advisorHudReview;

  /// Notify owner toggle label
  ///
  /// In en, this message translates to:
  /// **'Notify owner after submission'**
  String get advisorHudNotifyOwner;

  /// Template load error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the inspection template. Check your connection and try again.'**
  String get advisorHudTemplateError;

  /// Retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get advisorHudRetry;

  /// Add checkpoint note action
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get advisorHudAddNote;

  /// Clear search action
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get advisorHudClear;

  /// Reset checkpoint grade action
  ///
  /// In en, this message translates to:
  /// **'Reset grade'**
  String get advisorHudResetGrade;

  /// Dismiss sheet action
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get advisorHudDone;

  /// Damage tab primary CTA
  ///
  /// In en, this message translates to:
  /// **'Done marking'**
  String get advisorHudDoneMarking;

  /// Review sheet primary CTA
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get advisorHudContinue;

  /// Expand collapsed pins strip
  ///
  /// In en, this message translates to:
  /// **'Show list'**
  String get advisorHudShowPins;

  /// Damage map severity legend title
  ///
  /// In en, this message translates to:
  /// **'Severity legend'**
  String get advisorHudLegendTitle;

  /// Collapse pins strip
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get advisorHudHidePins;

  /// Damage kind: scratch or scuff
  ///
  /// In en, this message translates to:
  /// **'Scratch / Scuff'**
  String get advisorDamageKindScratch;

  /// Damage kind: dent
  ///
  /// In en, this message translates to:
  /// **'Dent'**
  String get advisorDamageKindDent;

  /// Damage kind: crack
  ///
  /// In en, this message translates to:
  /// **'Crack'**
  String get advisorDamageKindCrack;

  /// Damage kind: paint damage
  ///
  /// In en, this message translates to:
  /// **'Paint damage'**
  String get advisorDamageKindPaint;

  /// Damage kind: broken or missing part
  ///
  /// In en, this message translates to:
  /// **'Broken / Missing'**
  String get advisorDamageKindBroken;

  /// Damage severity: minor
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get advisorDamageMinor;

  /// Damage severity: moderate
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get advisorDamageModerate;

  /// Damage severity: severe
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get advisorDamageSevere;

  /// Damage size: coin-sized
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get advisorDamageSizeCoin;

  /// Damage size: palm-sized
  ///
  /// In en, this message translates to:
  /// **'Palm'**
  String get advisorDamageSizePalm;

  /// Damage size: hand-span
  ///
  /// In en, this message translates to:
  /// **'Hand span'**
  String get advisorDamageSizeSpan;

  /// Part category: body
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get advisorDamageCatBody;

  /// Part category: glass
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get advisorDamageCatGlass;

  /// Part category: wheel
  ///
  /// In en, this message translates to:
  /// **'Wheel'**
  String get advisorDamageCatWheel;

  /// Part category: light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get advisorDamageCatLight;

  /// Part category: mirror
  ///
  /// In en, this message translates to:
  /// **'Mirror'**
  String get advisorDamageCatMirror;

  /// Damage detail sheet title (new pin)
  ///
  /// In en, this message translates to:
  /// **'Log damage'**
  String get advisorDamageLogTitle;

  /// Damage detail sheet title (edit pin)
  ///
  /// In en, this message translates to:
  /// **'Edit damage'**
  String get advisorDamageEditTitle;

  /// Damage kind picker section
  ///
  /// In en, this message translates to:
  /// **'Damage kind'**
  String get advisorDamageKindSection;

  /// Damage severity picker section
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get advisorDamageSeveritySection;

  /// Damage size picker section
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get advisorDamageSizeSection;

  /// Damage size optional tag
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get advisorDamageSizeOptional;

  /// Damage photo section
  ///
  /// In en, this message translates to:
  /// **'Photo evidence'**
  String get advisorDamagePhotoSection;

  /// Photo-required rule note
  ///
  /// In en, this message translates to:
  /// **'A photo is required for Moderate and Severe damage.'**
  String get advisorDamagePhotoRequired;

  /// Add damage photo action
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get advisorDamageAddPhoto;

  /// Damage note field hint
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get advisorDamageNoteHint;

  /// Damage voice note section
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get advisorDamageVoiceSection;

  /// Confirm new damage pin
  ///
  /// In en, this message translates to:
  /// **'Add pin'**
  String get advisorDamageAddPin;

  /// Confirm damage pin edits
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get advisorDamageSaveChanges;

  /// Kind-required validation error
  ///
  /// In en, this message translates to:
  /// **'Choose a damage kind to continue.'**
  String get advisorDamageKindRequired;

  /// Inline pin delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete this pin?'**
  String get advisorDamageDeleteTitle;

  /// Confirm pin delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get advisorDamageDelete;

  /// Edit pin action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get advisorDamageEdit;

  /// Vehicle map loading state
  ///
  /// In en, this message translates to:
  /// **'Loading vehicle map…'**
  String get advisorDamageMapLoading;

  /// Vehicle map error state
  ///
  /// In en, this message translates to:
  /// **'Vehicle map could not be loaded.'**
  String get advisorDamageMapError;

  /// Reset map zoom and pan
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get advisorDamageResetView;

  /// Map zoom-in stepper
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get advisorDamageZoomIn;

  /// Map zoom-out stepper
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get advisorDamageZoomOut;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Front Bumper'**
  String get advisorPartFrontBumper;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Hood / Bonnet'**
  String get advisorPartHood;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Front Left Headlight'**
  String get advisorPartFrontLeftHeadlight;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Front Right Headlight'**
  String get advisorPartFrontRightHeadlight;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Front Windshield'**
  String get advisorPartFrontWindshield;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Roof'**
  String get advisorPartRoof;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Rear Windshield'**
  String get advisorPartRearWindshield;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Boot / Trunk'**
  String get advisorPartTrunk;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Rear Bumper'**
  String get advisorPartRearBumper;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Front Left Fender'**
  String get advisorPartFrontLeftFender;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Front Right Fender'**
  String get advisorPartFrontRightFender;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Front Left Door'**
  String get advisorPartFrontLeftDoor;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Rear Left Door'**
  String get advisorPartRearLeftDoor;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Front Right Door'**
  String get advisorPartFrontRightDoor;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Rear Right Door'**
  String get advisorPartRearRightDoor;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Rear Left Quarter Panel'**
  String get advisorPartRearLeftQuarter;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Rear Right Quarter Panel'**
  String get advisorPartRearRightQuarter;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Left Mirror'**
  String get advisorPartLeftMirror;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Right Mirror'**
  String get advisorPartRightMirror;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Front Left Wheel / Tyre'**
  String get advisorPartFrontLeftWheel;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Front Right Wheel / Tyre'**
  String get advisorPartFrontRightWheel;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Rear Left Wheel / Tyre'**
  String get advisorPartRearLeftWheel;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Rear Right Wheel / Tyre'**
  String get advisorPartRearRightWheel;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Rear Left Tail Light'**
  String get advisorPartRearLeftTaillight;

  /// Vehicle part name
  ///
  /// In en, this message translates to:
  /// **'Rear Right Tail Light'**
  String get advisorPartRearRightTaillight;

  /// Preview screen title
  ///
  /// In en, this message translates to:
  /// **'Vehicle health report'**
  String get advisorHealthTitle;

  /// Preview subtitle
  ///
  /// In en, this message translates to:
  /// **'Review every finding before converting or submitting.'**
  String get advisorHealthSubtitle;

  /// Overall health score
  ///
  /// In en, this message translates to:
  /// **'{score}% overall health'**
  String advisorHealthScore(int score);

  /// Health score coverage
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} checkpoints graded'**
  String advisorHealthScoredOf(int done, int total);

  /// Fail group title
  ///
  /// In en, this message translates to:
  /// **'Mandatory safety items'**
  String get advisorHealthMandatory;

  /// Caution group title
  ///
  /// In en, this message translates to:
  /// **'Recommended maintenance'**
  String get advisorHealthRecommended;

  /// Pass group title
  ///
  /// In en, this message translates to:
  /// **'Good condition'**
  String get advisorHealthGoodGroup;

  /// Convert to estimate action
  ///
  /// In en, this message translates to:
  /// **'Convert to estimate'**
  String get advisorHealthConvert;

  /// Submit inspection action
  ///
  /// In en, this message translates to:
  /// **'Submit inspection'**
  String get advisorHealthSubmit;

  /// Submitting state
  ///
  /// In en, this message translates to:
  /// **'Submitting inspection…'**
  String get advisorHealthSubmitting;

  /// Preview empty state
  ///
  /// In en, this message translates to:
  /// **'No checkpoints rated yet'**
  String get advisorHealthEmpty;

  /// Preview empty hint
  ///
  /// In en, this message translates to:
  /// **'Grade at least one checkpoint to build this health report.'**
  String get advisorHealthEmptyHint;

  /// Remaining checkpoints notice
  ///
  /// In en, this message translates to:
  /// **'{count} checkpoints still need a condition'**
  String advisorHealthRemaining(int count);

  /// Back to edit action
  ///
  /// In en, this message translates to:
  /// **'Back to edit'**
  String get advisorHealthBackEdit;

  /// Ready to submit line
  ///
  /// In en, this message translates to:
  /// **'{count} checkpoints ready to submit'**
  String advisorHealthReady(int count);

  /// Submit confirmation title
  ///
  /// In en, this message translates to:
  /// **'Submit this inspection?'**
  String get advisorHealthSubmitTitle;

  /// Submit confirmation message
  ///
  /// In en, this message translates to:
  /// **'Confirm that the checkpoint grades, damage pins and attachments are correct.'**
  String get advisorHealthSubmitMessage;

  /// Submit confirmation cancel
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get advisorHealthReviewAgain;

  /// Attachment count per finding
  ///
  /// In en, this message translates to:
  /// **'{count} attachments'**
  String advisorHealthAttachments(int count);

  /// Dossier share action
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get advisorHealthShare;

  /// Dossier export action
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get advisorHealthExport;

  /// Dossier copied confirmation
  ///
  /// In en, this message translates to:
  /// **'Report copied to clipboard'**
  String get advisorHealthCopied;

  /// Expand finding group
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get advisorHealthExpand;

  /// Collapse finding group
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get advisorHealthCollapse;

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
  /// **'In progress'**
  String get advisorStatusInProgress;

  /// Job status label: completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get advisorStatusCompleted;

  /// Job status label: waiting parts
  ///
  /// In en, this message translates to:
  /// **'Waiting parts'**
  String get advisorStatusWaitingParts;

  /// Job status label: QC check
  ///
  /// In en, this message translates to:
  /// **'QC check'**
  String get advisorStatusQc;

  /// Job status label: cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get advisorStatusCancelled;

  /// Job status label: awaiting supervisor
  ///
  /// In en, this message translates to:
  /// **'Awaiting supervisor'**
  String get advisorStatusAwaitingSupervisor;

  /// Job status label: vehicle received
  ///
  /// In en, this message translates to:
  /// **'Vehicle received'**
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
  /// **'Work assigned'**
  String get advisorStatusWorkAssigned;

  /// Job status label: waiting customer approval
  ///
  /// In en, this message translates to:
  /// **'Waiting customer approval'**
  String get advisorStatusWaitingCustomerApproval;

  /// Job status label: delivered
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get advisorStatusDelivered;

  /// Job status label: QC passed
  ///
  /// In en, this message translates to:
  /// **'QC passed'**
  String get advisorStatusQcPassed;

  /// Job status label: pending approval
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
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
  /// **'Open job card'**
  String get advisorActionOpenJob;

  /// Contextual row overflow action tooltip
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get advisorActionMore;

  /// Wizard advance action
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get advisorIntakeWizardNext;

  /// Wizard return action
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get advisorIntakeWizardBack;

  /// Wizard position label
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String advisorIntakeWizardStepOf(int current, int total);

  /// Wizard step 1 title
  ///
  /// In en, this message translates to:
  /// **'Customer contact'**
  String get advisorIntakeWizardContactTitle;

  /// Wizard step 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Find an existing customer or add a new one'**
  String get advisorIntakeWizardContactSub;

  /// Wizard step 2 title
  ///
  /// In en, this message translates to:
  /// **'Vehicle & plate'**
  String get advisorIntakeWizardVehicleTitle;

  /// Wizard step 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Plate, VIN, brand, model and year'**
  String get advisorIntakeWizardVehicleSub;

  /// Wizard step 3 title
  ///
  /// In en, this message translates to:
  /// **'Photo capture'**
  String get advisorIntakeWizardCaptureTitle;

  /// Wizard step 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Documents, photos and readings'**
  String get advisorIntakeWizardCaptureSub;

  /// Wizard step 4 title
  ///
  /// In en, this message translates to:
  /// **'Scope & sign-off'**
  String get advisorIntakeWizardSignoffTitle;

  /// Wizard step 4 subtitle
  ///
  /// In en, this message translates to:
  /// **'Job scope, signatures and review'**
  String get advisorIntakeWizardSignoffSub;

  /// Draft restore notice
  ///
  /// In en, this message translates to:
  /// **'Previous draft restored'**
  String get advisorIntakeWizardDraftRestored;

  /// Blocked wizard advance hint
  ///
  /// In en, this message translates to:
  /// **'Complete this step to continue'**
  String get advisorIntakeWizardBlocked;

  /// Scanner idle readout
  ///
  /// In en, this message translates to:
  /// **'Align the code inside the frame'**
  String get advisorScanDecodeIdle;

  /// Scanner guidance title
  ///
  /// In en, this message translates to:
  /// **'Scanning tips'**
  String get advisorScanTipsTitle;

  /// Scanner tip: distance
  ///
  /// In en, this message translates to:
  /// **'Hold steady 15–20 cm from the code'**
  String get advisorScanTipAlign;

  /// Scanner tip: torch
  ///
  /// In en, this message translates to:
  /// **'Use the torch in low light'**
  String get advisorScanTipLight;

  /// Scanner tip: manual fallback
  ///
  /// In en, this message translates to:
  /// **'Can\'t scan? Enter the value manually — nothing is lost'**
  String get advisorScanTipManual;

  /// Viewfinder semantics label
  ///
  /// In en, this message translates to:
  /// **'Camera viewfinder'**
  String get advisorScanViewfinderLabel;

  /// Fuel dial: empty
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get advisorCheckInFuelEmpty;

  /// Fuel dial: quarter
  ///
  /// In en, this message translates to:
  /// **'1/4'**
  String get advisorCheckInFuelQuarter;

  /// Fuel dial: half
  ///
  /// In en, this message translates to:
  /// **'1/2'**
  String get advisorCheckInFuelHalf;

  /// Fuel dial: three quarters
  ///
  /// In en, this message translates to:
  /// **'3/4'**
  String get advisorCheckInFuelThreeQuarter;

  /// Fuel dial: full
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get advisorCheckInFuelFull;

  /// Odometer drum picker title
  ///
  /// In en, this message translates to:
  /// **'Odometer drums'**
  String get advisorCheckInOdoTitle;

  /// Odometer unit
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get advisorCheckInOdoUnit;

  /// Odometer quick add one thousand
  ///
  /// In en, this message translates to:
  /// **'+1k'**
  String get advisorCheckInOdoPlus1k;

  /// Odometer quick add ten thousand
  ///
  /// In en, this message translates to:
  /// **'+10k'**
  String get advisorCheckInOdoPlus10k;

  /// Odometer reset action
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get advisorCheckInOdoClear;

  /// Check-in confirmation title
  ///
  /// In en, this message translates to:
  /// **'Confirm check-in'**
  String get advisorCheckInConfirmTitle;

  /// Check-in confirmation body
  ///
  /// In en, this message translates to:
  /// **'Review the readings before handing the vehicle to inspection.'**
  String get advisorCheckInConfirmBody;

  /// Telemetry cluster subtitle
  ///
  /// In en, this message translates to:
  /// **'Live telemetry for this reception'**
  String get advisorCheckInClusterSub;

  /// Delivery page title
  ///
  /// In en, this message translates to:
  /// **'Vehicle handover'**
  String get advisorDeliveryTitle;

  /// Delivery page subtitle
  ///
  /// In en, this message translates to:
  /// **'Formal delivery protocol'**
  String get advisorDeliverySubtitle;

  /// Delivery checklist title
  ///
  /// In en, this message translates to:
  /// **'Handover checklist'**
  String get advisorDeliveryChecklistTitle;

  /// Delivery checklist progress
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} verified'**
  String advisorDeliveryProgress(int done, int total);

  /// Delivery check: invoice
  ///
  /// In en, this message translates to:
  /// **'Invoice copy provided to customer'**
  String get advisorDeliveryCheckInvoice;

  /// Delivery check: keys
  ///
  /// In en, this message translates to:
  /// **'Vehicle keys handed over'**
  String get advisorDeliveryCheckKeys;

  /// Delivery check: documents
  ///
  /// In en, this message translates to:
  /// **'Vehicle documents returned'**
  String get advisorDeliveryCheckDocs;

  /// Delivery check: service reminder
  ///
  /// In en, this message translates to:
  /// **'Next service reminder given'**
  String get advisorDeliveryCheckService;

  /// Delivery check: warranty
  ///
  /// In en, this message translates to:
  /// **'Warranty information explained'**
  String get advisorDeliveryCheckWarranty;

  /// Delivery mileage label
  ///
  /// In en, this message translates to:
  /// **'Final mileage (km)'**
  String get advisorDeliveryMileage;

  /// Delivery mileage hint
  ///
  /// In en, this message translates to:
  /// **'e.g. 48250'**
  String get advisorDeliveryMileageHint;

  /// Delivery mileage validation
  ///
  /// In en, this message translates to:
  /// **'Enter the final mileage to complete handover'**
  String get advisorDeliveryMileageError;

  /// Delivery rating label
  ///
  /// In en, this message translates to:
  /// **'Customer satisfaction'**
  String get advisorDeliveryRating;

  /// Delivery rating value
  ///
  /// In en, this message translates to:
  /// **'Rated {value} of 5'**
  String advisorDeliveryRatingValue(int value);

  /// Delivery notes label
  ///
  /// In en, this message translates to:
  /// **'Delivery notes'**
  String get advisorDeliveryNotes;

  /// Delivery notes hint
  ///
  /// In en, this message translates to:
  /// **'Customer feedback, return requests, warranty notes…'**
  String get advisorDeliveryNotesHint;

  /// Delivery signature label
  ///
  /// In en, this message translates to:
  /// **'Customer sign-off'**
  String get advisorDeliverySignature;

  /// Delivery signature hint
  ///
  /// In en, this message translates to:
  /// **'Capture the customer signature to close the protocol'**
  String get advisorDeliverySignatureHint;

  /// Delivery signature action
  ///
  /// In en, this message translates to:
  /// **'Capture signature'**
  String get advisorDeliverySignAction;

  /// Delivery signed state
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get advisorDeliverySigned;

  /// Delivery submit action
  ///
  /// In en, this message translates to:
  /// **'Complete handover'**
  String get advisorDeliveryComplete;

  /// Delivery remaining checks
  ///
  /// In en, this message translates to:
  /// **'{count} checks remaining'**
  String advisorDeliveryRemaining(int count);

  /// Delivery success toast
  ///
  /// In en, this message translates to:
  /// **'Vehicle delivered successfully'**
  String get advisorDeliverySuccess;

  /// Delivery failure toast
  ///
  /// In en, this message translates to:
  /// **'Failed to complete delivery'**
  String get advisorDeliveryFailed;

  /// Delivery error toast
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String advisorDeliveryError(String message);

  /// Attachment failure snackbar
  ///
  /// In en, this message translates to:
  /// **'Could not add attachment: {message}'**
  String advisorIntakeAttachmentError(String message);

  /// Work order studio screen title
  ///
  /// In en, this message translates to:
  /// **'Repair Estimate'**
  String get advisorStudioTitle;

  /// Work order studio supporting line
  ///
  /// In en, this message translates to:
  /// **'Build the customer estimate for this job card'**
  String get advisorStudioSubtitle;

  /// Studio stepper step: parts
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get advisorStudioStepParts;

  /// Studio stepper step: labor
  ///
  /// In en, this message translates to:
  /// **'Labor'**
  String get advisorStudioStepLabor;

  /// Studio stepper step: review
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get advisorStudioStepReview;

  /// Tier group: mandatory safety
  ///
  /// In en, this message translates to:
  /// **'Mandatory Safety Repairs'**
  String get advisorStudioTierMandatory;

  /// Tier group: optional enhancements
  ///
  /// In en, this message translates to:
  /// **'Optional Enhancements'**
  String get advisorStudioTierOptional;

  /// Category mini-header: parts
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get advisorStudioCategoryParts;

  /// Category mini-header: labor
  ///
  /// In en, this message translates to:
  /// **'Labor'**
  String get advisorStudioCategoryLabor;

  /// Category mini-header: sublet
  ///
  /// In en, this message translates to:
  /// **'Sublet'**
  String get advisorStudioCategorySublet;

  /// Collapsed empty category message
  ///
  /// In en, this message translates to:
  /// **'No {category} items yet'**
  String advisorStudioEmptyCategory(String category);

  /// Add CTA for a category
  ///
  /// In en, this message translates to:
  /// **'Add {category}'**
  String advisorStudioAddItem(String category);

  /// Parts stock pill when the item is on the shelf
  ///
  /// In en, this message translates to:
  /// **'In-Stock · Bay {bay}'**
  String advisorStudioStockIn(int bay);

  /// Parts stock pill when the item must be ordered
  ///
  /// In en, this message translates to:
  /// **'Order · {hours}'**
  String advisorStudioStockOrder(String hours);

  /// Labor operation hours and unit rate
  ///
  /// In en, this message translates to:
  /// **'{hours}h × {rate}'**
  String advisorStudioLaborDetail(String hours, String rate);

  /// Accessible label for a row line total
  ///
  /// In en, this message translates to:
  /// **'Line total'**
  String get advisorStudioLineTotal;

  /// Quantity stepper semantic label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get advisorStudioQuantity;

  /// Rate field label on a studio row
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get advisorStudioUnitPrice;

  /// Discount percent field label on a studio row
  ///
  /// In en, this message translates to:
  /// **'Discount %'**
  String get advisorStudioDiscountPct;

  /// Auto-price suggestion tooltip
  ///
  /// In en, this message translates to:
  /// **'Suggest price from history'**
  String get advisorStudioSuggestPrice;

  /// Remove row tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get advisorStudioRemoveItem;

  /// Money dock: parts subtotal
  ///
  /// In en, this message translates to:
  /// **'Parts subtotal'**
  String get advisorStudioPartsSubtotal;

  /// Money dock: labor total
  ///
  /// In en, this message translates to:
  /// **'Labor'**
  String get advisorStudioLabor;

  /// Money dock: statutory VAT line
  ///
  /// In en, this message translates to:
  /// **'VAT (5%)'**
  String get advisorStudioVat;

  /// Money dock: grand total
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get advisorStudioTotal;

  /// Money dock trust line
  ///
  /// In en, this message translates to:
  /// **'Statutory 5% VAT · Prices in UAE dirhams'**
  String get advisorStudioTrustLine;

  /// Money dock primary confirm CTA
  ///
  /// In en, this message translates to:
  /// **'Review Estimate'**
  String get advisorStudioConfirm;

  /// Money dock CTA when the estimate is empty
  ///
  /// In en, this message translates to:
  /// **'Add Estimate Items'**
  String get advisorStudioAddItems;

  /// Studio loading state
  ///
  /// In en, this message translates to:
  /// **'Loading estimate items…'**
  String get advisorStudioLoading;

  /// Studio error state message
  ///
  /// In en, this message translates to:
  /// **'Could not load estimate items.'**
  String get advisorStudioError;

  /// Studio no-match state message
  ///
  /// In en, this message translates to:
  /// **'No matching items'**
  String get advisorStudioNoMatch;

  /// Toast after removing a line
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String advisorStudioRemoved(String name);

  /// Banner when the estimate follows an inspection
  ///
  /// In en, this message translates to:
  /// **'Inspection completed and attached'**
  String get advisorStudioFromInspection;

  /// Reset estimate action
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get advisorStudioReset;

  /// Reset confirmation title
  ///
  /// In en, this message translates to:
  /// **'Clear this estimate?'**
  String get advisorStudioResetTitle;

  /// Reset confirmation body
  ///
  /// In en, this message translates to:
  /// **'All services, parts, pricing and notes entered here will be removed.'**
  String get advisorStudioResetBody;

  /// Reset confirmation cancel action
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get advisorStudioResetKeep;

  /// Reset confirmation destructive action
  ///
  /// In en, this message translates to:
  /// **'Clear estimate'**
  String get advisorStudioResetConfirm;

  /// Service picker intro title
  ///
  /// In en, this message translates to:
  /// **'Select required services'**
  String get advisorStudioSelectServicesTitle;

  /// Service picker intro subtitle
  ///
  /// In en, this message translates to:
  /// **'Pricing can be entered after adding them'**
  String get advisorStudioSelectServicesSubtitle;

  /// Service picker search hint
  ///
  /// In en, this message translates to:
  /// **'Search services'**
  String get advisorStudioSearchServices;

  /// Parts picker intro title
  ///
  /// In en, this message translates to:
  /// **'Select required parts'**
  String get advisorStudioSelectPartsTitle;

  /// Parts picker intro subtitle
  ///
  /// In en, this message translates to:
  /// **'Quantity and price can be updated after adding them'**
  String get advisorStudioSelectPartsSubtitle;

  /// Parts picker search hint
  ///
  /// In en, this message translates to:
  /// **'Search parts'**
  String get advisorStudioSearchParts;

  /// Service picker no-match message
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get advisorStudioNoServices;

  /// Parts picker no-match message
  ///
  /// In en, this message translates to:
  /// **'No parts found'**
  String get advisorStudioNoParts;

  /// Picker selected count pill
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String advisorStudioSelectedCount(int count);

  /// Picker confirm action when nothing is selected
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get advisorStudioDone;

  /// Picker confirm action for services
  ///
  /// In en, this message translates to:
  /// **'Add services'**
  String get advisorStudioAddSelectedServices;

  /// Picker confirm action for parts
  ///
  /// In en, this message translates to:
  /// **'Add parts'**
  String get advisorStudioAddSelectedParts;

  /// Picker row idle hint
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get advisorStudioTapToAdd;

  /// Picker row selected hint
  ///
  /// In en, this message translates to:
  /// **'Added to estimate'**
  String get advisorStudioAdded;

  /// Sublet category helper line
  ///
  /// In en, this message translates to:
  /// **'Vendor work is booked outside this estimate.'**
  String get advisorStudioSubletHint;

  /// Share sheet title
  ///
  /// In en, this message translates to:
  /// **'Share estimate'**
  String get advisorEstimateShareTitle;

  /// Invoice document heading
  ///
  /// In en, this message translates to:
  /// **'ESTIMATE'**
  String get advisorEstimateInvoiceTitle;

  /// Invoice customer label
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get advisorEstimateCustomer;

  /// Invoice vehicle label
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get advisorEstimateVehicle;

  /// Invoice prepared-on label
  ///
  /// In en, this message translates to:
  /// **'Prepared on'**
  String get advisorEstimatePreparedOn;

  /// Share sheet WhatsApp CTA
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get advisorEstimateShareWhatsApp;

  /// Share sheet copy-link action
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get advisorEstimateCopyLink;

  /// Copy-link toast
  ///
  /// In en, this message translates to:
  /// **'Estimate link copied'**
  String get advisorEstimateLinkCopied;

  /// Share sheet helper line
  ///
  /// In en, this message translates to:
  /// **'Send the customer an interactive estimate for approval.'**
  String get advisorEstimateShareHint;

  /// Invoice summary heading
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get advisorEstimateSummaryTitle;

  /// Invoice subtotal row
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get advisorEstimateSubTotal;

  /// Invoice grand total row
  ///
  /// In en, this message translates to:
  /// **'Grand total'**
  String get advisorEstimateGrandTotal;

  /// WhatsApp share disabled reason
  ///
  /// In en, this message translates to:
  /// **'No customer phone on file'**
  String get advisorEstimateNoContact;

  /// Preview submit action
  ///
  /// In en, this message translates to:
  /// **'Create Repair Order'**
  String get advisorEstimateCreateOrder;

  /// Preview signature capture action
  ///
  /// In en, this message translates to:
  /// **'Add signature'**
  String get advisorEstimateAddSignature;

  /// Preview signature captured state
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get advisorEstimateSigned;

  /// Signature block eyebrow
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER SIGNATURE'**
  String get advisorEstimateSignatureLabel;

  /// Signature sheet title
  ///
  /// In en, this message translates to:
  /// **'Customer Signature'**
  String get advisorEstimateSignatureTitle;

  /// Signature clear action
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get advisorEstimateSignatureClear;

  /// Signature confirm action
  ///
  /// In en, this message translates to:
  /// **'Use signature'**
  String get advisorEstimateSignatureUse;

  /// Preview screen title
  ///
  /// In en, this message translates to:
  /// **'Review Estimate'**
  String get advisorEstimateReviewTitle;

  /// Preview guard when job card is absent
  ///
  /// In en, this message translates to:
  /// **'Job Card is missing'**
  String get advisorEstimateMissingJob;

  /// Preview guard when no lines exist
  ///
  /// In en, this message translates to:
  /// **'No repair items found. Add extra work or retry after inspection.'**
  String get advisorEstimateNoItems;

  /// Preview create success
  ///
  /// In en, this message translates to:
  /// **'Repair order created'**
  String get advisorEstimateCreated;

  /// Preview create failure
  ///
  /// In en, this message translates to:
  /// **'Could not create the repair order'**
  String get advisorEstimateCreateFailed;

  /// Assign tasks screen title
  ///
  /// In en, this message translates to:
  /// **'Bay Dispatch'**
  String get advisorDispatchTitle;

  /// Assign tasks supporting line
  ///
  /// In en, this message translates to:
  /// **'Assign repair tasks to a technician'**
  String get advisorDispatchSubtitle;

  /// Technician section heading
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get advisorDispatchTechnicianSection;

  /// Technician section helper
  ///
  /// In en, this message translates to:
  /// **'Select a technician'**
  String get advisorDispatchSelectTech;

  /// Technician load caption
  ///
  /// In en, this message translates to:
  /// **'{count} active jobs'**
  String advisorDispatchLoad(int count);

  /// Technician availability: free
  ///
  /// In en, this message translates to:
  /// **'Free now'**
  String get advisorDispatchFree;

  /// Technician availability after a delay
  ///
  /// In en, this message translates to:
  /// **'Free in {hours}'**
  String advisorDispatchAvailableIn(String hours);

  /// Technician skill chip: brakes
  ///
  /// In en, this message translates to:
  /// **'Brakes'**
  String get advisorDispatchSkillBrakes;

  /// Technician skill chip: air conditioning
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get advisorDispatchSkillAc;

  /// Technician skill chip: electrical
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get advisorDispatchSkillElectrical;

  /// Task list section heading
  ///
  /// In en, this message translates to:
  /// **'Repair items'**
  String get advisorDispatchTaskSection;

  /// Add task row action
  ///
  /// In en, this message translates to:
  /// **'Add extra work'**
  String get advisorDispatchAddExtraWork;

  /// Task hours field hint
  ///
  /// In en, this message translates to:
  /// **'hrs'**
  String get advisorDispatchHoursHint;

  /// Task description field hint
  ///
  /// In en, this message translates to:
  /// **'Add extra work item'**
  String get advisorDispatchTaskHint;

  /// Task list empty message
  ///
  /// In en, this message translates to:
  /// **'No generated work items found.'**
  String get advisorDispatchEmpty;

  /// Toast after selecting a technician
  ///
  /// In en, this message translates to:
  /// **'{name} selected'**
  String advisorDispatchSelected(String name);

  /// Dispatch CTA with task count
  ///
  /// In en, this message translates to:
  /// **'Assign {count} tasks'**
  String advisorDispatchCta(int count);

  /// Dispatch CTA for a single task
  ///
  /// In en, this message translates to:
  /// **'Assign 1 task'**
  String get advisorDispatchCtaOne;

  /// Validation: no technician selected
  ///
  /// In en, this message translates to:
  /// **'Please select a technician'**
  String get advisorDispatchNeedTech;

  /// Validation: no task selected
  ///
  /// In en, this message translates to:
  /// **'Please add at least one task'**
  String get advisorDispatchNeedTask;

  /// Assign success toast
  ///
  /// In en, this message translates to:
  /// **'Tasks assigned successfully'**
  String get advisorDispatchSuccess;

  /// Assign failure toast
  ///
  /// In en, this message translates to:
  /// **'Failed to assign tasks'**
  String get advisorDispatchFailed;

  /// Assign error toast
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String advisorDispatchError(String message);

  /// Dock caption of the chosen technician
  ///
  /// In en, this message translates to:
  /// **'Assigned to {name}'**
  String advisorDispatchAssignedTo(String name);

  /// Task list loading state
  ///
  /// In en, this message translates to:
  /// **'Loading repair items…'**
  String get advisorDispatchLoading;

  /// Estimate metadata section heading
  ///
  /// In en, this message translates to:
  /// **'Estimate details'**
  String get advisorStudioDetails;

  /// Reference number field label
  ///
  /// In en, this message translates to:
  /// **'Reference number'**
  String get advisorStudioReference;

  /// Reference number field hint
  ///
  /// In en, this message translates to:
  /// **'Example: LPO-2026-001'**
  String get advisorStudioReferenceHint;

  /// Customer requests field label
  ///
  /// In en, this message translates to:
  /// **'Customer requests'**
  String get advisorStudioRequests;

  /// Customer requests field hint
  ///
  /// In en, this message translates to:
  /// **'Customer requests / complaints'**
  String get advisorStudioRequestsHint;

  /// Garage recommendations field label
  ///
  /// In en, this message translates to:
  /// **'Garage recommendations'**
  String get advisorStudioRecommendations;

  /// Garage recommendations field hint
  ///
  /// In en, this message translates to:
  /// **'Enter garage recommendations here'**
  String get advisorStudioRecommendationsHint;

  /// Estimated delivery field label
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery'**
  String get advisorStudioDelivery;

  /// Estimated delivery picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select date & time'**
  String get advisorStudioDeliveryPick;

  /// Notify owner toggle label
  ///
  /// In en, this message translates to:
  /// **'Notify owner (SMS & email)'**
  String get advisorStudioNotify;

  /// Tag field label
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get advisorStudioTag;

  /// Tag field hint
  ///
  /// In en, this message translates to:
  /// **'Enter a tag (e.g. VIP, Fleet, Insurance)'**
  String get advisorStudioTagHint;

  /// Tag dialog confirm action
  ///
  /// In en, this message translates to:
  /// **'Set tag'**
  String get advisorStudioTagAction;

  /// Pre-service media section label
  ///
  /// In en, this message translates to:
  /// **'Pre-service media'**
  String get advisorStudioMedia;

  /// Add pre-service media action
  ///
  /// In en, this message translates to:
  /// **'Add media'**
  String get advisorStudioMediaAdd;

  /// Media source: camera
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get advisorStudioMediaCamera;

  /// Media source: gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get advisorStudioMediaGallery;

  /// Media source: video
  ///
  /// In en, this message translates to:
  /// **'Record video'**
  String get advisorStudioMediaVideo;

  /// Approval method picker title
  ///
  /// In en, this message translates to:
  /// **'Customer approval'**
  String get advisorEstimateApprovalTitle;

  /// Approval method picker subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose how the customer will approve this estimate.'**
  String get advisorEstimateApprovalSubtitle;

  /// Approval method: in person
  ///
  /// In en, this message translates to:
  /// **'Customer approved here'**
  String get advisorEstimateApprovalHere;

  /// Approval method in-person hint
  ///
  /// In en, this message translates to:
  /// **'Use when the customer reviewed and accepted the estimate with you.'**
  String get advisorEstimateApprovalHereHint;

  /// Approval method: customer app
  ///
  /// In en, this message translates to:
  /// **'Send to customer app'**
  String get advisorEstimateApprovalApp;

  /// Approval method customer-app hint
  ///
  /// In en, this message translates to:
  /// **'The job waits until the customer approves from their account.'**
  String get advisorEstimateApprovalAppHint;

  /// Preview submit action
  ///
  /// In en, this message translates to:
  /// **'Submit estimate'**
  String get advisorEstimateSubmit;

  /// Preview submit in-flight label
  ///
  /// In en, this message translates to:
  /// **'Submitting estimate…'**
  String get advisorEstimateSubmitting;

  /// Technician nav: today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get techNavToday;

  /// Technician nav: jobs
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get techNavJobs;

  /// Technician nav: productivity
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get techNavProductivity;

  /// Technician nav: profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get techNavProfile;

  /// Technician rail profile label
  ///
  /// In en, this message translates to:
  /// **'Technician Profile'**
  String get techProfileLabel;

  /// Technician workspace name
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get techWorkspaceName;

  /// Technician greeting with name
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String techGreeting(String name);

  /// Shift action: punch in
  ///
  /// In en, this message translates to:
  /// **'Start shift'**
  String get techShiftStart;

  /// Shift action: start break
  ///
  /// In en, this message translates to:
  /// **'Take break'**
  String get techShiftBreak;

  /// Shift action: end break
  ///
  /// In en, this message translates to:
  /// **'Resume shift'**
  String get techShiftResume;

  /// Shift terminal state
  ///
  /// In en, this message translates to:
  /// **'Shift complete'**
  String get techShiftDone;

  /// Shift action: punch out
  ///
  /// In en, this message translates to:
  /// **'End shift'**
  String get techShiftEnd;

  /// Shift hint before punch in
  ///
  /// In en, this message translates to:
  /// **'Clock in to begin today\'s work'**
  String get techShiftClockInHint;

  /// Shift summary line
  ///
  /// In en, this message translates to:
  /// **'{work} worked · {rest} break'**
  String techShiftWorked(String work, String rest);

  /// Attendance state
  ///
  /// In en, this message translates to:
  /// **'Not Punched In'**
  String get techAttendanceNotPunchedIn;

  /// Attendance state
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get techAttendanceWorking;

  /// Attendance state
  ///
  /// In en, this message translates to:
  /// **'On Break'**
  String get techAttendanceOnBreak;

  /// Attendance state
  ///
  /// In en, this message translates to:
  /// **'Punched Out'**
  String get techAttendancePunchedOut;

  /// Pinned banner eyebrow
  ///
  /// In en, this message translates to:
  /// **'Active job'**
  String get techBannerActive;

  /// Pinned banner empty title
  ///
  /// In en, this message translates to:
  /// **'Ready for assignment'**
  String get techBannerReady;

  /// Pinned banner empty hint
  ///
  /// In en, this message translates to:
  /// **'Your next repair appears here when the desk assigns it.'**
  String get techBannerReadyHint;

  /// Banner inline pause action
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get techBannerPause;

  /// Banner inline resume action
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get techBannerResume;

  /// Banner open action
  ///
  /// In en, this message translates to:
  /// **'Open job'**
  String get techBannerOpen;

  /// Banner started-at line
  ///
  /// In en, this message translates to:
  /// **'Started {time}'**
  String techBannerStarted(String time);

  /// Today section eyebrow
  ///
  /// In en, this message translates to:
  /// **'CURRENT WORK'**
  String get techTodayCurrentWork;

  /// Today active title
  ///
  /// In en, this message translates to:
  /// **'On the bay'**
  String get techTodayOnBay;

  /// Today idle title
  ///
  /// In en, this message translates to:
  /// **'Ready for assignment'**
  String get techTodayReady;

  /// Today idle empty title
  ///
  /// In en, this message translates to:
  /// **'No active repair right now'**
  String get techTodayNoActive;

  /// Today idle empty hint
  ///
  /// In en, this message translates to:
  /// **'Open your queue to review the next assigned vehicle, or start the next job below.'**
  String get techTodayNoActiveHint;

  /// Today idle action
  ///
  /// In en, this message translates to:
  /// **'Open my jobs'**
  String get techTodayOpenJobs;

  /// Today queue title
  ///
  /// In en, this message translates to:
  /// **'Assigned queue'**
  String get techTodayQueue;

  /// Today queue eyebrow
  ///
  /// In en, this message translates to:
  /// **'UP NEXT'**
  String get techTodayUpNext;

  /// Queue view-all action
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get techTodayViewAll;

  /// Queue empty title
  ///
  /// In en, this message translates to:
  /// **'Queue clear'**
  String get techTodayQueueClear;

  /// Queue empty hint
  ///
  /// In en, this message translates to:
  /// **'No other repairs are waiting. New assignments appear here as they are scheduled.'**
  String get techTodayQueueClearHint;

  /// Shift summary title
  ///
  /// In en, this message translates to:
  /// **'Shift summary'**
  String get techTodaySummary;

  /// Shift summary metric
  ///
  /// In en, this message translates to:
  /// **'Active bay'**
  String get techTodayActiveBay;

  /// Shift summary metric
  ///
  /// In en, this message translates to:
  /// **'Tasks done'**
  String get techTodayTasksDone;

  /// Shift summary metric
  ///
  /// In en, this message translates to:
  /// **'Repairs done'**
  String get techTodayRepairsDone;

  /// Today empty title
  ///
  /// In en, this message translates to:
  /// **'No assigned jobs right now'**
  String get techTodayEmpty;

  /// Today empty hint
  ///
  /// In en, this message translates to:
  /// **'You have no repairs assigned for this shift. Pull to refresh, or check back when the desk schedules work.'**
  String get techTodayEmptyHint;

  /// Today refresh action
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get techTodayRefresh;

  /// Today load error title
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load today\'s work'**
  String get techTodayLoadError;

  /// Today error hint
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get techTodayErrorHint;

  /// Today retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get techTodayRetry;

  /// Today detail action
  ///
  /// In en, this message translates to:
  /// **'Job details'**
  String get techTodayJobDetails;

  /// Today quick action
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get techTodayTasks;

  /// Today quick action
  ///
  /// In en, this message translates to:
  /// **'Request part'**
  String get techTodayRequestPart;

  /// Today quick action
  ///
  /// In en, this message translates to:
  /// **'Escalate'**
  String get techTodayEscalate;

  /// Today primary action
  ///
  /// In en, this message translates to:
  /// **'Complete task'**
  String get techTodayCompleteTask;

  /// Today primary action
  ///
  /// In en, this message translates to:
  /// **'Start next task'**
  String get techTodayStartTask;

  /// Today primary action
  ///
  /// In en, this message translates to:
  /// **'Review job'**
  String get techTodayReviewJob;

  /// Today next-task eyebrow
  ///
  /// In en, this message translates to:
  /// **'NEXT TASK'**
  String get techTodayNextTask;

  /// Today running eyebrow
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get techTodayInProgress;

  /// Today blocker title
  ///
  /// In en, this message translates to:
  /// **'Job on hold'**
  String get techTodayJobOnHold;

  /// Today blocker hint
  ///
  /// In en, this message translates to:
  /// **'This repair is marked delayed at the workshop.'**
  String get techTodayDelayedHint;

  /// Task progress line
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} tasks completed'**
  String techTodayProgress(int done, int total);

  /// Job start-time pill
  ///
  /// In en, this message translates to:
  /// **'Starts {time}'**
  String techTodayStartsAt(String time);

  /// Freshness footer
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String techTodayUpdated(String time);

  /// Plate fallback
  ///
  /// In en, this message translates to:
  /// **'Plate not recorded'**
  String get techPlateMissing;

  /// Vehicle fallback
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get techVehicleFallback;

  /// Jobs search hint
  ///
  /// In en, this message translates to:
  /// **'Search jobs'**
  String get techJobsSearch;

  /// Jobs load error title
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your jobs'**
  String get techJobsLoadError;

  /// Jobs empty title
  ///
  /// In en, this message translates to:
  /// **'No assigned jobs'**
  String get techJobsEmpty;

  /// Jobs empty hint
  ///
  /// In en, this message translates to:
  /// **'There are no jobs assigned to you right now.'**
  String get techJobsEmptyHint;

  /// Jobs no-match title
  ///
  /// In en, this message translates to:
  /// **'No matching jobs'**
  String get techJobsNoMatch;

  /// Jobs no-match hint
  ///
  /// In en, this message translates to:
  /// **'No jobs match your search and filter.'**
  String get techJobsNoMatchHint;

  /// Jobs clear action
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get techJobsClearFilters;

  /// Filter chip semantics
  ///
  /// In en, this message translates to:
  /// **'Filter jobs: {label}, {count} jobs'**
  String techJobsFilterSemantics(String label, int count);

  /// Jobs progress line
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} tasks completed'**
  String techJobsProgress(int done, int total);

  /// Job detail title
  ///
  /// In en, this message translates to:
  /// **'Job details'**
  String get techDetailTitle;

  /// Detail running eyebrow
  ///
  /// In en, this message translates to:
  /// **'CURRENT TASK'**
  String get techDetailCurrentTask;

  /// Detail running section title
  ///
  /// In en, this message translates to:
  /// **'Current task'**
  String get techDetailCurrentTitle;

  /// Detail next eyebrow
  ///
  /// In en, this message translates to:
  /// **'NEXT TASK'**
  String get techDetailNextTask;

  /// Detail next section title
  ///
  /// In en, this message translates to:
  /// **'Next task'**
  String get techDetailNextTitle;

  /// Detail held eyebrow
  ///
  /// In en, this message translates to:
  /// **'ON HOLD'**
  String get techDetailOnHold;

  /// Detail done eyebrow
  ///
  /// In en, this message translates to:
  /// **'Repair tasks complete'**
  String get techDetailAllDone;

  /// Detail empty eyebrow
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get techDetailNoTasks;

  /// Detail section eyebrow
  ///
  /// In en, this message translates to:
  /// **'EXECUTION'**
  String get techDetailExecution;

  /// Task list header
  ///
  /// In en, this message translates to:
  /// **'{count} assigned'**
  String techDetailTasksAssigned(int count);

  /// Task list eyebrow
  ///
  /// In en, this message translates to:
  /// **'ALL TASKS'**
  String get techDetailAllTasks;

  /// Detail primary action
  ///
  /// In en, this message translates to:
  /// **'Complete task'**
  String get techDetailCompleteTask;

  /// Detail primary action
  ///
  /// In en, this message translates to:
  /// **'Start next task'**
  String get techDetailStartTask;

  /// Detail primary action
  ///
  /// In en, this message translates to:
  /// **'Resume task'**
  String get techDetailResumeTask;

  /// Detail busy label
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get techDetailStarting;

  /// Detail busy label
  ///
  /// In en, this message translates to:
  /// **'Completing…'**
  String get techDetailCompleting;

  /// Detail busy label
  ///
  /// In en, this message translates to:
  /// **'Resuming…'**
  String get techDetailResuming;

  /// Task action
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get techDetailStart;

  /// Task action
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get techDetailHold;

  /// Task hold action
  ///
  /// In en, this message translates to:
  /// **'Hold task'**
  String get techDetailHoldTask;

  /// Task resume action
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get techDetailResume;

  /// Task complete action
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get techDetailComplete;

  /// Stopwatch label
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get techDetailElapsed;

  /// Stopwatch paused label
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get techDetailPaused;

  /// Detail empty tasks hint
  ///
  /// In en, this message translates to:
  /// **'No tasks have been added to this job. Ask the advisor before starting work.'**
  String get techDetailNoTasksHint;

  /// QC notice
  ///
  /// In en, this message translates to:
  /// **'Repair work has been submitted for supervisor QC review.'**
  String get techDetailQcNotice;

  /// Locked notice
  ///
  /// In en, this message translates to:
  /// **'This repair is completed. Technician edits are locked.'**
  String get techDetailLockedNotice;

  /// Delayed notice title
  ///
  /// In en, this message translates to:
  /// **'Delayed'**
  String get techDetailDelayed;

  /// Delayed notice hint
  ///
  /// In en, this message translates to:
  /// **'This repair is marked as delayed at the workshop. You can continue the tasks below once the issue is resolved.'**
  String get techDetailDelayedHint;

  /// Support section title
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get techDetailSupport;

  /// Support section eyebrow
  ///
  /// In en, this message translates to:
  /// **'NEED HELP?'**
  String get techDetailNeedHelp;

  /// Handover action
  ///
  /// In en, this message translates to:
  /// **'Complete repair'**
  String get techDetailCompleteRepair;

  /// Handover confirm title
  ///
  /// In en, this message translates to:
  /// **'Complete repair?'**
  String get techDetailConfirmTitle;

  /// Handover confirm body
  ///
  /// In en, this message translates to:
  /// **'All remaining tasks will be recorded as completed and the job sent to supervisor QC review.'**
  String get techDetailConfirmBody;

  /// Handover cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get techDetailCancel;

  /// Task row semantics
  ///
  /// In en, this message translates to:
  /// **'Task {index}, {desc}, {status}'**
  String techDetailTaskLabel(int index, String desc, String status);

  /// Productivity title
  ///
  /// In en, this message translates to:
  /// **'Today\'s productivity'**
  String get techProdTitle;

  /// Productivity eyebrow
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get techProdToday;

  /// Productivity dossier eyebrow
  ///
  /// In en, this message translates to:
  /// **'WORK COMPLETED'**
  String get techProdWorkDone;

  /// Singular repair caption
  ///
  /// In en, this message translates to:
  /// **'repair completed today'**
  String get techProdRepairOne;

  /// Plural repair caption
  ///
  /// In en, this message translates to:
  /// **'repairs completed today'**
  String get techProdRepairMany;

  /// Productivity no-tasks hint
  ///
  /// In en, this message translates to:
  /// **'No tasks recorded in your loaded work.'**
  String get techProdNoTasks;

  /// Productivity queue eyebrow
  ///
  /// In en, this message translates to:
  /// **'YOUR QUEUE'**
  String get techProdQueue;

  /// Queue header
  ///
  /// In en, this message translates to:
  /// **'{count} assigned'**
  String techProdAssigned(int count);

  /// Breakdown row
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get techProdInProgress;

  /// Breakdown row
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get techProdPending;

  /// Breakdown row
  ///
  /// In en, this message translates to:
  /// **'Delayed'**
  String get techProdDelayed;

  /// Breakdown row
  ///
  /// In en, this message translates to:
  /// **'QC review'**
  String get techProdQc;

  /// Breakdown row
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get techProdCompleted;

  /// Shift eyebrow
  ///
  /// In en, this message translates to:
  /// **'SHIFT'**
  String get techProdShift;

  /// Shift line
  ///
  /// In en, this message translates to:
  /// **'Clocked in'**
  String get techProdClockedIn;

  /// Shift line
  ///
  /// In en, this message translates to:
  /// **'Break taken'**
  String get techProdBreakTaken;

  /// Shift line
  ///
  /// In en, this message translates to:
  /// **'Net hours'**
  String get techProdNetHours;

  /// Shift line
  ///
  /// In en, this message translates to:
  /// **'Clocked out'**
  String get techProdClockedOut;

  /// Shift terminal hint
  ///
  /// In en, this message translates to:
  /// **'Shift complete for today.'**
  String get techProdShiftDone;

  /// Productivity empty title
  ///
  /// In en, this message translates to:
  /// **'No productivity data yet'**
  String get techProdEmpty;

  /// Productivity empty hint
  ///
  /// In en, this message translates to:
  /// **'Completed work will appear here as you progress through your assigned jobs.'**
  String get techProdEmptyHint;

  /// Productivity error title
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your productivity'**
  String get techProdLoadError;

  /// Server figures strip title
  ///
  /// In en, this message translates to:
  /// **'Workshop figures'**
  String get techProdFigures;

  /// Server efficiency label
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get techProdEfficiency;

  /// Day progress label
  ///
  /// In en, this message translates to:
  /// **'Today\'s progress'**
  String get techProdDayProgress;

  /// Delayed alert
  ///
  /// In en, this message translates to:
  /// **'{count} delayed — needs attention'**
  String techProdDelayedAlert(int count);

  /// Server avg time label
  ///
  /// In en, this message translates to:
  /// **'Time per repair'**
  String get techProdTimePerRepair;

  /// Server hours label
  ///
  /// In en, this message translates to:
  /// **'Hours logged'**
  String get techProdHoursLogged;

  /// Parts sheet title
  ///
  /// In en, this message translates to:
  /// **'Request a part'**
  String get techPartsTitle;

  /// Sheet close action
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get techPartsClose;

  /// Part name label
  ///
  /// In en, this message translates to:
  /// **'Part name'**
  String get techPartsName;

  /// Part name hint
  ///
  /// In en, this message translates to:
  /// **'What part or material do you need?'**
  String get techPartsNameHint;

  /// Part name error
  ///
  /// In en, this message translates to:
  /// **'Enter the part you need'**
  String get techPartsNameError;

  /// Part number label
  ///
  /// In en, this message translates to:
  /// **'Part number (optional)'**
  String get techPartsNumber;

  /// Part number hint
  ///
  /// In en, this message translates to:
  /// **'OEM or workshop reference'**
  String get techPartsNumberHint;

  /// Quantity label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get techPartsQty;

  /// Quantity hint
  ///
  /// In en, this message translates to:
  /// **'Units needed'**
  String get techPartsQtyHint;

  /// Quantity tooltip
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get techPartsDec;

  /// Quantity tooltip
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get techPartsInc;

  /// Urgency label
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get techPartsUrgency;

  /// Urgency option
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get techPartsNormal;

  /// Urgency option
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get techPartsUrgent;

  /// Notes label
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get techPartsNotes;

  /// Notes hint
  ///
  /// In en, this message translates to:
  /// **'Fitment details or preferred alternatives'**
  String get techPartsNotesHint;

  /// Counter submit CTA
  ///
  /// In en, this message translates to:
  /// **'Send request · {count}'**
  String techPartsSendCount(int count);

  /// Parts busy label
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get techPartsSending;

  /// Parts success toast
  ///
  /// In en, this message translates to:
  /// **'Part request sent.'**
  String get techPartsSent;

  /// Parts error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send the request. Check your connection and try again.'**
  String get techPartsError;

  /// Escalation title
  ///
  /// In en, this message translates to:
  /// **'Escalate an issue'**
  String get techEscTitle;

  /// Escalation chips label
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get techEscWhat;

  /// Escalation details label
  ///
  /// In en, this message translates to:
  /// **'Issue details'**
  String get techEscDetails;

  /// Escalation details hint
  ///
  /// In en, this message translates to:
  /// **'Describe what you found and what you need…'**
  String get techEscDetailsHint;

  /// Escalation details error
  ///
  /// In en, this message translates to:
  /// **'Describe the issue'**
  String get techEscDetailsError;

  /// Escalation safety note
  ///
  /// In en, this message translates to:
  /// **'For an immediate safety risk, stop work and contact the supervisor directly.'**
  String get techEscSafety;

  /// Escalation submit
  ///
  /// In en, this message translates to:
  /// **'Escalate issue'**
  String get techEscSend;

  /// Escalation busy label
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get techEscSending;

  /// Escalation success toast
  ///
  /// In en, this message translates to:
  /// **'Escalation sent.'**
  String get techEscSent;

  /// Escalation error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send the escalation. Check your connection and try again.'**
  String get techEscError;

  /// Supervisor workspace label on the brand mark
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get svWorkspaceName;

  /// Supervisor greeting header
  ///
  /// In en, this message translates to:
  /// **'Floor command, {name}'**
  String svGreeting(String name);

  /// Floor status pill in the header
  ///
  /// In en, this message translates to:
  /// **'{occupied}/{total} bays active'**
  String svBaysOccupied(int occupied, int total);

  /// Supervisor navigation: floor grid
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get svNavFloor;

  /// Supervisor navigation: active jobs
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get svNavJobs;

  /// Supervisor navigation: incoming queue
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get svNavQueue;

  /// Supervisor navigation: quality control
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get svNavReview;

  /// Supervisor navigation: reports
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get svNavReports;

  /// Supervisor navigation: roster
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get svNavStaff;

  /// Supervisor navigation: schedule
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get svNavSchedule;

  /// Supervisor profile tooltip
  ///
  /// In en, this message translates to:
  /// **'Supervisor profile'**
  String get svProfileLabel;

  /// Notifications sheet title
  ///
  /// In en, this message translates to:
  /// **'Floor notifications'**
  String get svNotificationsTitle;

  /// Notifications empty title
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get svNotificationsEmpty;

  /// Notifications empty message
  ///
  /// In en, this message translates to:
  /// **'You are all caught up.'**
  String get svNotificationsEmptyMessage;

  /// Mark all notifications read
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get svNotificationsMarkAll;

  /// Supervisor search title
  ///
  /// In en, this message translates to:
  /// **'Find on the floor'**
  String get svSearchTitle;

  /// Supervisor search hint
  ///
  /// In en, this message translates to:
  /// **'Search job card, customer, or plate'**
  String get svSearchHint;

  /// Floor grid section title
  ///
  /// In en, this message translates to:
  /// **'Workshop floor'**
  String get svFloorTitle;

  /// Floor grid subtitle
  ///
  /// In en, this message translates to:
  /// **'{count} active · {total} bays'**
  String svFloorSubtitle(int count, int total);

  /// Floor legend label
  ///
  /// In en, this message translates to:
  /// **'Bay status'**
  String get svFloorLegend;

  /// Bay status: occupied
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get svBayOccupied;

  /// Bay status: idle
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get svBayIdle;

  /// Bay status: parts delay
  ///
  /// In en, this message translates to:
  /// **'Parts delay'**
  String get svBayPartsDelay;

  /// Bay status: QC pending
  ///
  /// In en, this message translates to:
  /// **'QC'**
  String get svBayQc;

  /// Floor grid tap hint
  ///
  /// In en, this message translates to:
  /// **'Tap a bay to dispatch a technician'**
  String get svFloorTapHint;

  /// Floor empty title
  ///
  /// In en, this message translates to:
  /// **'No active jobs on the floor'**
  String get svFloorEmpty;

  /// Floor empty message
  ///
  /// In en, this message translates to:
  /// **'New jobs appear the moment they are assigned.'**
  String get svFloorEmptyMessage;

  /// Floor no-match message
  ///
  /// In en, this message translates to:
  /// **'No bays match this filter'**
  String get svFloorNoMatch;

  /// Floor no-match helper under the title
  ///
  /// In en, this message translates to:
  /// **'Try a different filter, or clear it to see every bay.'**
  String get svFloorNoMatchHint;

  /// Floor hero supporting sentence under the occupancy
  ///
  /// In en, this message translates to:
  /// **'Dispatch the next job into a free bay.'**
  String get svFloorHeroSentence;

  /// Floor error title
  ///
  /// In en, this message translates to:
  /// **'Floor unavailable'**
  String get svFloorErrorTitle;

  /// Floor error message
  ///
  /// In en, this message translates to:
  /// **'Could not load the floor. Pull to refresh.'**
  String get svFloorError;

  /// Floor side queue rail title
  ///
  /// In en, this message translates to:
  /// **'Incoming queue'**
  String get svFloorQueueTitle;

  /// Floor side queue empty
  ///
  /// In en, this message translates to:
  /// **'The queue is clear'**
  String get svFloorQueueEmpty;

  /// Floor utilisation label
  ///
  /// In en, this message translates to:
  /// **'Floor utilisation'**
  String get svFloorUtilisation;

  /// Bays metric label
  ///
  /// In en, this message translates to:
  /// **'Bays'**
  String get svBaysLabel;

  /// Queue tab title
  ///
  /// In en, this message translates to:
  /// **'Incoming queue'**
  String get svQueueTitle;

  /// Queue tab subtitle
  ///
  /// In en, this message translates to:
  /// **'Priority-sorted bookings and breakdowns'**
  String get svQueueSubtitle;

  /// Queue priority filter: VIP
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get svQueuePriorityVip;

  /// Queue priority: promised today
  ///
  /// In en, this message translates to:
  /// **'Promised today'**
  String get svQueuePriorityPromised;

  /// Queue priority: insurance
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get svQueuePriorityInsurance;

  /// Queue priority: emergency breakdown
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get svQueuePriorityEmergency;

  /// Queue section: bookings
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get svQueueBookings;

  /// Queue section: breakdowns
  ///
  /// In en, this message translates to:
  /// **'Breakdowns'**
  String get svQueueBreakdowns;

  /// Queue row assign action
  ///
  /// In en, this message translates to:
  /// **'Assign advisor'**
  String get svQueueAssign;

  /// Queue empty title
  ///
  /// In en, this message translates to:
  /// **'The queue is clear'**
  String get svQueueEmpty;

  /// Queue empty message
  ///
  /// In en, this message translates to:
  /// **'No bookings or breakdowns waiting.'**
  String get svQueueEmptyMessage;

  /// Queue no-match message
  ///
  /// In en, this message translates to:
  /// **'No matching queue items'**
  String get svQueueNoMatch;

  /// Queue error message
  ///
  /// In en, this message translates to:
  /// **'Could not refresh the dispatch queue.'**
  String get svQueueError;

  /// Assign advisor sheet title
  ///
  /// In en, this message translates to:
  /// **'Route to advisor'**
  String get svQueueAssignTitle;

  /// Assign advisor dropdown label
  ///
  /// In en, this message translates to:
  /// **'Service advisor'**
  String get svQueueAssignHint;

  /// Booking assigned toast
  ///
  /// In en, this message translates to:
  /// **'Booking assigned'**
  String get svQueueAssigned;

  /// Breakdown dispatched toast
  ///
  /// In en, this message translates to:
  /// **'Breakdown dispatched'**
  String get svQueueDispatched;

  /// Assign failure toast
  ///
  /// In en, this message translates to:
  /// **'Could not assign. Try again.'**
  String get svQueueAssignFailed;

  /// No advisors available
  ///
  /// In en, this message translates to:
  /// **'No active advisors available to assign'**
  String get svQueueNoAdvisors;

  /// Jobs tab title
  ///
  /// In en, this message translates to:
  /// **'Active jobs'**
  String get svJobsTitle;

  /// Jobs tab subtitle
  ///
  /// In en, this message translates to:
  /// **'{count} on the floor'**
  String svJobsSubtitle(int count);

  /// Jobs search hint
  ///
  /// In en, this message translates to:
  /// **'Search job card, customer, or plate'**
  String get svJobsSearchHint;

  /// Jobs empty title
  ///
  /// In en, this message translates to:
  /// **'No active jobs'**
  String get svJobsEmpty;

  /// Jobs empty message
  ///
  /// In en, this message translates to:
  /// **'Assign work to see jobs on the floor.'**
  String get svJobsEmptyMessage;

  /// Jobs no-match title
  ///
  /// In en, this message translates to:
  /// **'No matching jobs'**
  String get svJobsNoMatch;

  /// Jobs error message
  ///
  /// In en, this message translates to:
  /// **'Could not load active jobs.'**
  String get svJobsError;

  /// Jobs metric: total
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get svJobsTotal;

  /// Jobs metric: in progress
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get svJobsInProgress;

  /// Jobs metric: completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get svJobsCompleted;

  /// Jobs task progress
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} tasks'**
  String svJobsTasks(int done, int total);

  /// Jobs assign action
  ///
  /// In en, this message translates to:
  /// **'Assign work'**
  String get svJobsAssign;

  /// Review tab title
  ///
  /// In en, this message translates to:
  /// **'Quality control'**
  String get svReviewTitle;

  /// Review tab subtitle
  ///
  /// In en, this message translates to:
  /// **'Verify completed repairs before delivery'**
  String get svReviewSubtitle;

  /// Start QC action
  ///
  /// In en, this message translates to:
  /// **'Start QC'**
  String get svReviewStart;

  /// Review empty title
  ///
  /// In en, this message translates to:
  /// **'Nothing awaiting sign-off'**
  String get svReviewEmpty;

  /// Review empty message
  ///
  /// In en, this message translates to:
  /// **'Completed repairs appear here for verification.'**
  String get svReviewEmptyMessage;

  /// Review error message
  ///
  /// In en, this message translates to:
  /// **'Could not load QC work.'**
  String get svReviewError;

  /// Review progress
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} done'**
  String svReviewProgress(int done, int total);

  /// QC sheet title
  ///
  /// In en, this message translates to:
  /// **'Quality control review'**
  String get svQcTitle;

  /// QC checklist group: repair items
  ///
  /// In en, this message translates to:
  /// **'Repair verification'**
  String get svQcRepairVerification;

  /// QC checkpoint: road test
  ///
  /// In en, this message translates to:
  /// **'Road test'**
  String get svQcRoadTest;

  /// QC checkpoint: torque audit
  ///
  /// In en, this message translates to:
  /// **'Torque audit'**
  String get svQcTorque;

  /// QC checkpoint: fluid levels
  ///
  /// In en, this message translates to:
  /// **'Fluid levels'**
  String get svQcFluid;

  /// QC checkpoint: final wash
  ///
  /// In en, this message translates to:
  /// **'Final wash'**
  String get svQcWash;

  /// QC checkpoints group label
  ///
  /// In en, this message translates to:
  /// **'Sign-off checkpoints'**
  String get svQcCheckpoints;

  /// QC photo section label
  ///
  /// In en, this message translates to:
  /// **'Photo proof'**
  String get svQcPhotoProof;

  /// QC add photo action
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get svQcPhotoAdd;

  /// QC photo attached state
  ///
  /// In en, this message translates to:
  /// **'Attached'**
  String get svQcPhotoAttached;

  /// QC photo unavailability note
  ///
  /// In en, this message translates to:
  /// **'Photo capture is not available for this job.'**
  String get svQcPhotoUnavailable;

  /// QC notes label
  ///
  /// In en, this message translates to:
  /// **'Inspector notes'**
  String get svQcNotes;

  /// QC notes hint
  ///
  /// In en, this message translates to:
  /// **'Required when sending back — describe the rework needed'**
  String get svQcNotesHint;

  /// QC reject action
  ///
  /// In en, this message translates to:
  /// **'Send back'**
  String get svQcReject;

  /// QC approve action
  ///
  /// In en, this message translates to:
  /// **'Approve & pass'**
  String get svQcApprove;

  /// QC verified counter
  ///
  /// In en, this message translates to:
  /// **'{count}/{total} verified'**
  String svQcVerified(int count, int total);

  /// QC reject requires a reason
  ///
  /// In en, this message translates to:
  /// **'Add revision details before sending back.'**
  String get svQcRejectReasonRequired;

  /// QC approve requires all checkpoints
  ///
  /// In en, this message translates to:
  /// **'Verify every checkpoint to approve.'**
  String get svQcVerifyAll;

  /// QC approved toast
  ///
  /// In en, this message translates to:
  /// **'QC passed — job approved'**
  String get svQcApproved;

  /// QC rejected toast
  ///
  /// In en, this message translates to:
  /// **'Sent back for revision'**
  String get svQcRejected;

  /// QC failure toast
  ///
  /// In en, this message translates to:
  /// **'Could not complete QC review. Try again.'**
  String get svQcFailed;

  /// Reports tab title
  ///
  /// In en, this message translates to:
  /// **'Operations report'**
  String get svReportsTitle;

  /// Reports tab subtitle
  ///
  /// In en, this message translates to:
  /// **'Throughput, rework, and floor utilisation'**
  String get svReportsSubtitle;

  /// Report metric: throughput
  ///
  /// In en, this message translates to:
  /// **'Throughput'**
  String get svReportsThroughput;

  /// Report metric: rework
  ///
  /// In en, this message translates to:
  /// **'Rework'**
  String get svReportsRework;

  /// Report metric: utilisation
  ///
  /// In en, this message translates to:
  /// **'Utilisation'**
  String get svReportsUtilisation;

  /// Report metric: jobs per technician
  ///
  /// In en, this message translates to:
  /// **'Jobs per technician'**
  String get svReportsJobsPerTech;

  /// Report section: job categories
  ///
  /// In en, this message translates to:
  /// **'Job categories'**
  String get svReportsCategories;

  /// Report categories empty
  ///
  /// In en, this message translates to:
  /// **'No category data recorded'**
  String get svReportsCategoriesEmpty;

  /// Report section: advisor workload
  ///
  /// In en, this message translates to:
  /// **'Advisor load'**
  String get svReportsWorkload;

  /// Report workload empty
  ///
  /// In en, this message translates to:
  /// **'No workload data recorded'**
  String get svReportsWorkloadEmpty;

  /// Report section: floor status
  ///
  /// In en, this message translates to:
  /// **'Floor status'**
  String get svReportsFloor;

  /// Report floor: technicians
  ///
  /// In en, this message translates to:
  /// **'Technicians'**
  String get svReportsTechnicians;

  /// Report floor: departments
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get svReportsDepartments;

  /// Report floor: queue count
  ///
  /// In en, this message translates to:
  /// **'In queue'**
  String get svReportsInQueue;

  /// Report section: financials
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get svReportsFinancial;

  /// Report empty message
  ///
  /// In en, this message translates to:
  /// **'No report data'**
  String get svReportsEmpty;

  /// Report error message
  ///
  /// In en, this message translates to:
  /// **'Live report data is unavailable right now.'**
  String get svReportsError;

  /// Report history honesty note
  ///
  /// In en, this message translates to:
  /// **'No history yet — showing current floor figures only.'**
  String get svReportsNoHistory;

  /// Staff tab title
  ///
  /// In en, this message translates to:
  /// **'Workshop roster'**
  String get svStaffTitle;

  /// Staff tab subtitle
  ///
  /// In en, this message translates to:
  /// **'{count} specialists on shift'**
  String svStaffSubtitle(int count);

  /// Staff section: technicians
  ///
  /// In en, this message translates to:
  /// **'Technicians'**
  String get svStaffTechnicians;

  /// Staff section: departments
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get svStaffDepartments;

  /// Staff empty title
  ///
  /// In en, this message translates to:
  /// **'No staff on shift'**
  String get svStaffEmpty;

  /// Staff empty message
  ///
  /// In en, this message translates to:
  /// **'No registered technicians.'**
  String get svStaffEmptyMessage;

  /// Staff departments empty
  ///
  /// In en, this message translates to:
  /// **'No departments'**
  String get svStaffDeptEmpty;

  /// Staff departments empty message
  ///
  /// In en, this message translates to:
  /// **'No registered workshop units.'**
  String get svStaffDeptEmptyMessage;

  /// Staff role label
  ///
  /// In en, this message translates to:
  /// **'Floor specialist'**
  String get svStaffRole;

  /// Staff on-shift pill
  ///
  /// In en, this message translates to:
  /// **'On shift'**
  String get svStaffOnShift;

  /// Staff load chip
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String svStaffLoad(int count);

  /// Schedule tab title
  ///
  /// In en, this message translates to:
  /// **'Bay schedule'**
  String get svScheduleTitle;

  /// Schedule tab subtitle
  ///
  /// In en, this message translates to:
  /// **'Today\'s appointment agenda'**
  String get svScheduleSubtitle;

  /// Schedule matrix column: time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get svScheduleTime;

  /// Schedule matrix column: customer and vehicle
  ///
  /// In en, this message translates to:
  /// **'Customer · vehicle'**
  String get svScheduleVehicle;

  /// Schedule matrix column: service
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get svScheduleService;

  /// Schedule matrix column: status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get svScheduleStatus;

  /// Schedule empty title
  ///
  /// In en, this message translates to:
  /// **'No appointments scheduled'**
  String get svScheduleEmpty;

  /// Schedule empty message
  ///
  /// In en, this message translates to:
  /// **'Upcoming bookings appear here.'**
  String get svScheduleEmptyMessage;

  /// Schedule row action
  ///
  /// In en, this message translates to:
  /// **'View in queue'**
  String get svScheduleViewInQueue;

  /// Schedule today highlight
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get svScheduleToday;

  /// Schedule error message
  ///
  /// In en, this message translates to:
  /// **'Could not load the schedule.'**
  String get svScheduleError;

  /// Assign sheet title
  ///
  /// In en, this message translates to:
  /// **'Dispatch to technician'**
  String get svAssignTitle;

  /// Assign sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'Pick a technician to take this job'**
  String get svAssignSubtitle;

  /// Assign sheet target job label
  ///
  /// In en, this message translates to:
  /// **'Target job'**
  String get svAssignTarget;

  /// Assign target job hint
  ///
  /// In en, this message translates to:
  /// **'Job card number (e.g. JC-2026-1042)'**
  String get svAssignTargetHint;

  /// Assign sheet technician list title
  ///
  /// In en, this message translates to:
  /// **'Technicians'**
  String get svAssignTechTitle;

  /// Assign technician skills label
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get svAssignSkills;

  /// Assign technician load
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String svAssignLoad(int count);

  /// Assign dispatch action
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get svAssignDispatch;

  /// Assign success toast
  ///
  /// In en, this message translates to:
  /// **'Dispatched to {name}'**
  String svAssignDispatched(String name);

  /// Assign empty title
  ///
  /// In en, this message translates to:
  /// **'No technicians available'**
  String get svAssignEmpty;

  /// Assign empty message
  ///
  /// In en, this message translates to:
  /// **'Register technicians to dispatch work.'**
  String get svAssignEmptyMessage;

  /// Assign requires a target job
  ///
  /// In en, this message translates to:
  /// **'Add a target job card before dispatching.'**
  String get svAssignNoTarget;

  /// Assign failure toast
  ///
  /// In en, this message translates to:
  /// **'Could not dispatch. Try again.'**
  String get svAssignFailed;

  /// Assign task brief label
  ///
  /// In en, this message translates to:
  /// **'Task brief (optional)'**
  String get svAssignBrief;

  /// Assign task brief hint
  ///
  /// In en, this message translates to:
  /// **'Describe the work for the technician'**
  String get svAssignBriefHint;

  /// Pushed sub-page title: assignment
  ///
  /// In en, this message translates to:
  /// **'Work assignment'**
  String get svRouteAssignTitle;

  /// Pushed sub-page subtitle: assignment
  ///
  /// In en, this message translates to:
  /// **'Dispatch tasks to technicians'**
  String get svRouteAssignSubtitle;

  /// Pushed sub-page title: jobs
  ///
  /// In en, this message translates to:
  /// **'Active jobs'**
  String get svRouteJobsTitle;

  /// Pushed sub-page subtitle: jobs
  ///
  /// In en, this message translates to:
  /// **'Workshop operations'**
  String get svRouteJobsSubtitle;

  /// Pushed sub-page title: queue
  ///
  /// In en, this message translates to:
  /// **'Incoming work'**
  String get svRouteQueueTitle;

  /// Pushed sub-page subtitle: queue
  ///
  /// In en, this message translates to:
  /// **'Bookings & breakdowns'**
  String get svRouteQueueSubtitle;

  /// Pushed sub-page title: review
  ///
  /// In en, this message translates to:
  /// **'Quality control'**
  String get svRouteReviewTitle;

  /// Pushed sub-page subtitle: review
  ///
  /// In en, this message translates to:
  /// **'Verify completed repairs'**
  String get svRouteReviewSubtitle;

  /// Pushed sub-page title: staff
  ///
  /// In en, this message translates to:
  /// **'Workshop roster'**
  String get svRouteStaffTitle;

  /// Pushed sub-page subtitle: staff
  ///
  /// In en, this message translates to:
  /// **'Technicians & departments'**
  String get svRouteStaffSubtitle;

  /// Pushed sub-page title: schedule
  ///
  /// In en, this message translates to:
  /// **'Scheduled appointments'**
  String get svRouteScheduleTitle;

  /// Pushed sub-page subtitle: schedule
  ///
  /// In en, this message translates to:
  /// **'Today\'s bookings'**
  String get svRouteScheduleSubtitle;

  /// Pushed sub-page title: reports
  ///
  /// In en, this message translates to:
  /// **'Operations report'**
  String get svRouteReportsTitle;

  /// Pushed sub-page subtitle: reports
  ///
  /// In en, this message translates to:
  /// **'Workshop summary & metrics'**
  String get svRouteReportsSubtitle;

  /// Breadcrumb root for supervisor sub-pages
  ///
  /// In en, this message translates to:
  /// **'Supervisor console'**
  String get svBreadcrumbConsole;

  /// Profile sheet menu: shift timeline
  ///
  /// In en, this message translates to:
  /// **'Shift timeline'**
  String get svProfileShift;

  /// Profile sheet menu: settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get svProfileSettings;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get staffProfileTitle;

  /// Work fields section
  ///
  /// In en, this message translates to:
  /// **'Work Information'**
  String get staffProfileWork;

  /// Contact fields section
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get staffProfileContact;

  /// Designation field
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get staffProfileDesignation;

  /// Department field
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get staffProfileDepartment;

  /// Branch field
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get staffProfileBranch;

  /// Shift field
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get staffProfileShift;

  /// Email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get staffProfileEmail;

  /// Phone field
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get staffProfilePhone;

  /// Account section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get staffProfileAccount;

  /// Reset password action
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get staffProfileResetPassword;

  /// Reset password hint
  ///
  /// In en, this message translates to:
  /// **'Verify your identity, then choose a new password'**
  String get staffProfileResetSubtitle;

  /// Licences action
  ///
  /// In en, this message translates to:
  /// **'Open source licences'**
  String get staffProfileLicences;

  /// Licences hint
  ///
  /// In en, this message translates to:
  /// **'Legal notices for the software in this app'**
  String get staffProfileLicencesSubtitle;

  /// Preferences section
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get staffProfilePrefs;

  /// Change password action
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get staffProfileChangePassword;

  /// Change password sheet title
  ///
  /// In en, this message translates to:
  /// **'Change password?'**
  String get staffProfileChangePasswordTitle;

  /// Change password sheet body
  ///
  /// In en, this message translates to:
  /// **'Password changes use one-time-code verification. Continue to the recovery flow to choose a new password.'**
  String get staffProfileChangePasswordBody;

  /// Sheet continue action
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get staffProfileContinue;

  /// Sheet cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get staffProfileCancel;

  /// Storage settings nav row
  ///
  /// In en, this message translates to:
  /// **'Storage & sync'**
  String get staffProfileStorage;

  /// Storage nav hint
  ///
  /// In en, this message translates to:
  /// **'Offline copies, sync status and cache'**
  String get staffProfileStorageSubtitle;

  /// Danger section
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get staffProfileDanger;

  /// Sign out action
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get staffProfileSignOut;

  /// Sign out confirm title
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get staffProfileSignOutTitle;

  /// Sign out confirm body
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to continue.'**
  String get staffProfileSignOutMessage;

  /// Unsynced sign out title
  ///
  /// In en, this message translates to:
  /// **'Sign out with unsynced work?'**
  String get staffProfileSignOutUnsyncedTitle;

  /// Unsynced sign out body
  ///
  /// In en, this message translates to:
  /// **'Some work is still waiting to sync. Signing out will remove the changes saved on this device.'**
  String get staffProfileSignOutUnsyncedMessage;

  /// Sign out cancel action
  ///
  /// In en, this message translates to:
  /// **'Stay signed in'**
  String get staffProfileStaySignedIn;

  /// Attendance screen title
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get staffAttTitle;

  /// Attendance state
  ///
  /// In en, this message translates to:
  /// **'Not punched in'**
  String get staffAttNotPunched;

  /// Attendance state
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get staffAttWorking;

  /// Attendance state
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get staffAttOnBreak;

  /// Attendance state
  ///
  /// In en, this message translates to:
  /// **'Shift complete'**
  String get staffAttShiftComplete;

  /// Idle hint
  ///
  /// In en, this message translates to:
  /// **'Your shift has not started yet. Punch in to begin recording today\'s hours.'**
  String get staffAttNotPunchedHint;

  /// Working hint
  ///
  /// In en, this message translates to:
  /// **'Active shift in progress. Your hours are being recorded.'**
  String get staffAttWorkingHint;

  /// Break hint
  ///
  /// In en, this message translates to:
  /// **'Shift is temporarily paused on break.'**
  String get staffAttBreakHint;

  /// Done hint
  ///
  /// In en, this message translates to:
  /// **'Today\'s shift is finished. Recorded hours have been submitted.'**
  String get staffAttDoneHint;

  /// Status eyebrow
  ///
  /// In en, this message translates to:
  /// **'CURRENT STATUS'**
  String get staffAttCurrentStatus;

  /// Punch in CTA
  ///
  /// In en, this message translates to:
  /// **'Punch In'**
  String get staffAttPunchIn;

  /// Punch in busy label
  ///
  /// In en, this message translates to:
  /// **'Punching in…'**
  String get staffAttPunchingIn;

  /// Punch out CTA
  ///
  /// In en, this message translates to:
  /// **'Punch Out'**
  String get staffAttPunchOut;

  /// Punch out busy label
  ///
  /// In en, this message translates to:
  /// **'Punching out…'**
  String get staffAttPunchingOut;

  /// Punch in confirm title
  ///
  /// In en, this message translates to:
  /// **'Punch in now?'**
  String get staffAttPunchInTitle;

  /// Punch in confirm body
  ///
  /// In en, this message translates to:
  /// **'Your arrival time will be recorded by the workshop server.'**
  String get staffAttPunchInBody;

  /// Punch out confirm title
  ///
  /// In en, this message translates to:
  /// **'Punch out now?'**
  String get staffAttPunchOutTitle;

  /// Punch out confirm body
  ///
  /// In en, this message translates to:
  /// **'This completes today\'s shift and records your work hours.'**
  String get staffAttPunchOutBody;

  /// Punch in toast
  ///
  /// In en, this message translates to:
  /// **'You are punched in.'**
  String get staffAttInToast;

  /// Punch out toast
  ///
  /// In en, this message translates to:
  /// **'You are punched out.'**
  String get staffAttOutToast;

  /// Punch failure toast
  ///
  /// In en, this message translates to:
  /// **'Attendance was not updated.'**
  String get staffAttFailToast;

  /// Time grid title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Recorded Time'**
  String get staffAttTodayRecord;

  /// Punch in row label
  ///
  /// In en, this message translates to:
  /// **'Punch in'**
  String get staffAttPunchInRow;

  /// Punch out row label
  ///
  /// In en, this message translates to:
  /// **'Punch out'**
  String get staffAttPunchOutRow;

  /// Hours row label
  ///
  /// In en, this message translates to:
  /// **'Hours worked'**
  String get staffAttHours;

  /// Break row label
  ///
  /// In en, this message translates to:
  /// **'Break time'**
  String get staffAttBreakRow;

  /// Shift done line
  ///
  /// In en, this message translates to:
  /// **'Today’s shift is complete. Your recorded hours are shown above.'**
  String get staffAttDoneLine;

  /// Punch timestamp microcopy
  ///
  /// In en, this message translates to:
  /// **'Punched in at {time}'**
  String staffAttPunchedAt(String time);

  /// Punch out microcopy
  ///
  /// In en, this message translates to:
  /// **'Punched out at {time}'**
  String staffAttOutAt(String time);

  /// Elapsed microcopy
  ///
  /// In en, this message translates to:
  /// **'On shift for {time}'**
  String staffAttOnShiftFor(String time);

  /// Progress bar basis caption
  ///
  /// In en, this message translates to:
  /// **'8h workday basis'**
  String get staffAttBasis;

  /// Calendar title
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get staffAttMonthTitle;

  /// History limitation note
  ///
  /// In en, this message translates to:
  /// **'Only today\'s record is kept on this device. Past days need a workshop history feed.'**
  String get staffAttHistoryNote;

  /// Day sheet title
  ///
  /// In en, this message translates to:
  /// **'Day record'**
  String get staffAttDayTitle;

  /// Day empty state
  ///
  /// In en, this message translates to:
  /// **'No record for this day.'**
  String get staffAttNoRecord;

  /// Shift page title
  ///
  /// In en, this message translates to:
  /// **'Shift Details'**
  String get staffShiftTitle;

  /// Shift page subtitle
  ///
  /// In en, this message translates to:
  /// **'Scheduled work hours and assignment'**
  String get staffShiftSubtitle;

  /// Schedule section
  ///
  /// In en, this message translates to:
  /// **'Shift Schedule'**
  String get staffShiftSchedule;

  /// Shift eyebrow
  ///
  /// In en, this message translates to:
  /// **'ASSIGNED SHIFT'**
  String get staffShiftAssigned;

  /// Start label
  ///
  /// In en, this message translates to:
  /// **'Shift Start'**
  String get staffShiftStart;

  /// End label
  ///
  /// In en, this message translates to:
  /// **'Shift End'**
  String get staffShiftEnd;

  /// Assignment section
  ///
  /// In en, this message translates to:
  /// **'Assignment Details'**
  String get staffShiftAssignment;

  /// Member label
  ///
  /// In en, this message translates to:
  /// **'Staff Member'**
  String get staffShiftMember;

  /// Employee id label
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get staffShiftEmpId;

  /// Branch label
  ///
  /// In en, this message translates to:
  /// **'Assigned Branch'**
  String get staffShiftBranch;

  /// Supervisor label
  ///
  /// In en, this message translates to:
  /// **'Supervisor on duty'**
  String get staffShiftSupervisor;

  /// Bay label
  ///
  /// In en, this message translates to:
  /// **'Assigned bay'**
  String get staffShiftBay;

  /// Breaks label
  ///
  /// In en, this message translates to:
  /// **'Breaks'**
  String get staffShiftBreaks;

  /// Shift fallback
  ///
  /// In en, this message translates to:
  /// **'Standard Shift'**
  String get staffShiftDefault;

  /// Shift empty state
  ///
  /// In en, this message translates to:
  /// **'No shift details were shared with this device.'**
  String get staffShiftEmpty;

  /// Settings title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get staffSettingsTitle;

  /// Settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Application information & local storage'**
  String get staffSettingsSubtitle;

  /// Sync section
  ///
  /// In en, this message translates to:
  /// **'Data & Sync'**
  String get staffSettingsSync;

  /// Sync status label
  ///
  /// In en, this message translates to:
  /// **'Local Sync Status'**
  String get staffSettingsSyncStatus;

  /// Pending count
  ///
  /// In en, this message translates to:
  /// **'{count} pending operations'**
  String staffSettingsPending(int count);

  /// Pending hint
  ///
  /// In en, this message translates to:
  /// **'Offline changes are queued and will sync when connection is restored.'**
  String get staffSettingsPendingHint;

  /// Idle line
  ///
  /// In en, this message translates to:
  /// **'No pending local operations'**
  String get staffSettingsIdle;

  /// Idle hint
  ///
  /// In en, this message translates to:
  /// **'All recorded offline actions have been processed.'**
  String get staffSettingsIdleHint;

  /// Pending pill
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get staffSettingsPendingPill;

  /// Idle pill
  ///
  /// In en, this message translates to:
  /// **'IDLE'**
  String get staffSettingsIdlePill;

  /// Force sync CTA
  ///
  /// In en, this message translates to:
  /// **'Force Sync Now'**
  String get staffSettingsForceSync;

  /// Sync busy label
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get staffSettingsSyncing;

  /// Sync done toast
  ///
  /// In en, this message translates to:
  /// **'Sync finished.'**
  String get staffSettingsSyncedToast;

  /// Sync fail toast
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Will retry automatically.'**
  String get staffSettingsSyncFailed;

  /// Last attempt line
  ///
  /// In en, this message translates to:
  /// **'Last attempt {time} (this session)'**
  String staffSettingsLastAttempt(String time);

  /// App section
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get staffSettingsApp;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get staffSettingsVersion;

  /// Device label
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get staffSettingsDevice;

  /// Cache label
  ///
  /// In en, this message translates to:
  /// **'Cached data'**
  String get staffSettingsCache;

  /// Cache count hint
  ///
  /// In en, this message translates to:
  /// **'{count} items stored on this device'**
  String staffSettingsCacheHint(int count);

  /// Clear cache action
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get staffSettingsClearCache;

  /// Clear confirm title
  ///
  /// In en, this message translates to:
  /// **'Clear cached data?'**
  String get staffSettingsClearTitle;

  /// Clear confirm body
  ///
  /// In en, this message translates to:
  /// **'Removes offline job copies, drafts and queued uploads from this device. Your account and server records are untouched.'**
  String get staffSettingsClearBody;

  /// Clear done toast
  ///
  /// In en, this message translates to:
  /// **'Cache cleared.'**
  String get staffSettingsCacheCleared;

  /// Brought-by field label after odometer
  ///
  /// In en, this message translates to:
  /// **'Brought by'**
  String get advisorClientBroughtBy;

  /// Brought-by field hint
  ///
  /// In en, this message translates to:
  /// **'Name of the person who brought the vehicle'**
  String get advisorClientBroughtByHint;

  /// Dossier handled-by line with advisor name
  ///
  /// In en, this message translates to:
  /// **'Handled by {name}'**
  String advisorClientAdvisorHandled(String name);

  /// Job card comments section title
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get advisorClientComments;

  /// Empty comments state
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get advisorClientCommentsEmpty;

  /// Add comment action
  ///
  /// In en, this message translates to:
  /// **'Add comment'**
  String get advisorClientCommentsAdd;

  /// Comment field hint
  ///
  /// In en, this message translates to:
  /// **'Write a comment…'**
  String get advisorClientCommentsHint;

  /// Comment delete confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete this comment?'**
  String get advisorClientCommentsDeleteTitle;

  /// Job card signatures section title
  ///
  /// In en, this message translates to:
  /// **'Signatures'**
  String get advisorClientSignatures;

  /// Customer signature label
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get advisorClientSigCustomer;

  /// Advisor signature label
  ///
  /// In en, this message translates to:
  /// **'Advisor'**
  String get advisorClientSigAdvisor;

  /// Signature timestamp line
  ///
  /// In en, this message translates to:
  /// **'Signed {time}'**
  String advisorClientSigSignedOn(String time);

  /// Unsigned state
  ///
  /// In en, this message translates to:
  /// **'Not signed yet'**
  String get advisorClientSigMissing;

  /// Signature clear action
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get advisorClientSigClear;

  /// Share section title
  ///
  /// In en, this message translates to:
  /// **'Share job card'**
  String get advisorClientShareTitle;

  /// Shared job summary text
  ///
  /// In en, this message translates to:
  /// **'Job {id} · {customer} · {vehicle}'**
  String advisorClientShareSummary(String id, String customer, String vehicle);

  /// WhatsApp share action
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get advisorClientShareWhatsApp;

  /// Email share action
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get advisorClientShareEmail;

  /// WhatsApp share disabled reason
  ///
  /// In en, this message translates to:
  /// **'Add a customer number to share on WhatsApp.'**
  String get advisorClientShareNoPhone;

  /// Existing plates dropdown label
  ///
  /// In en, this message translates to:
  /// **'Existing plates'**
  String get advisorClientPlatesTitle;

  /// Manual plate entry option
  ///
  /// In en, this message translates to:
  /// **'New plate'**
  String get advisorClientPlatesNew;

  /// Plate dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Choose a plate or enter a new one'**
  String get advisorClientPlatesHint;

  /// On-device truth pill (never a sync claim)
  ///
  /// In en, this message translates to:
  /// **'Saved on device'**
  String get advisorClientSavedOnDevice;

  /// Activity byline with the advisor name
  ///
  /// In en, this message translates to:
  /// **'Saved on device by {name}'**
  String advisorClientSavedBy(String name);

  /// Comment composer save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get advisorClientCommentsSave;

  /// Comment delete confirm action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get advisorClientCommentsDeleteConfirm;

  /// Request customer signature via WhatsApp
  ///
  /// In en, this message translates to:
  /// **'Request signature'**
  String get advisorClientSigRequest;

  /// Resend signature request
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get advisorClientSigResend;

  /// Confirm the signature was captured
  ///
  /// In en, this message translates to:
  /// **'Mark signed'**
  String get advisorClientSigMarkSigned;

  /// Signature requested state with timestamp
  ///
  /// In en, this message translates to:
  /// **'Requested via WhatsApp · {time}'**
  String advisorClientSigRequested(String time);

  /// Toast after firing the sign request
  ///
  /// In en, this message translates to:
  /// **'Signature request sent via WhatsApp'**
  String get advisorClientSigRequestSent;

  /// Sign/share link failure toast
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open WhatsApp. Try again.'**
  String get advisorClientSigLinkError;

  /// Share sheet primary action
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get advisorClientSharePdf;

  /// Toast after the PDF is shared
  ///
  /// In en, this message translates to:
  /// **'PDF shared'**
  String get advisorClientSharePdfDone;

  /// Share failure toast with retry
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share the PDF. Try again.'**
  String get advisorClientSharePdfFail;

  /// PDF building state
  ///
  /// In en, this message translates to:
  /// **'Preparing PDF…'**
  String get advisorClientSharePdfBuilding;

  /// PDF document title
  ///
  /// In en, this message translates to:
  /// **'Job Card'**
  String get advisorClientPdfTitle;

  /// PDF customer section
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get advisorClientPdfCustomer;

  /// PDF vehicle section
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get advisorClientPdfVehicle;

  /// PDF work-lines section
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get advisorClientPdfWork;

  /// PDF estimate total row
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get advisorClientPdfTotal;

  /// Plate lookup loading row
  ///
  /// In en, this message translates to:
  /// **'Searching plates…'**
  String get advisorClientPlatesSearching;
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
