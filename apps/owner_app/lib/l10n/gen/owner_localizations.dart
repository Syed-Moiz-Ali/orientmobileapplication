import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'owner_localizations_ar.dart';
import 'owner_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of OwnerLocalizations
/// returned by `OwnerLocalizations.of(context)`.
///
/// Applications need to include `OwnerLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/owner_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: OwnerLocalizations.localizationsDelegates,
///   supportedLocales: OwnerLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the OwnerLocalizations.supportedLocales
/// property.
abstract class OwnerLocalizations {
  OwnerLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static OwnerLocalizations? of(BuildContext context) {
    return Localizations.of<OwnerLocalizations>(context, OwnerLocalizations);
  }

  static const LocalizationsDelegate<OwnerLocalizations> delegate =
      _OwnerLocalizationsDelegate();

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
  /// **'Orient Owner'**
  String get appTitle;

  /// App identity name shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'Orient Owner App'**
  String get loginAppName;

  /// App purpose shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'Monitor branches, job cards, staff, revenue, approvals, inventory, and workshop performance.'**
  String get loginAppPurpose;

  /// Intended users shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'For workshop owners and admins'**
  String get loginIntendedUsers;

  /// App-specific legal notice under the shared auth form
  ///
  /// In en, this message translates to:
  /// **'By signing in, you agree to the Orient Owner App Terms of Service and Privacy Policy.'**
  String get authSecurityNotice;

  /// Bottom-nav / rail label: cockpit
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get ownerNavDashboard;

  /// Bottom-nav / rail label: leaderboard
  ///
  /// In en, this message translates to:
  /// **'Top sales'**
  String get ownerNavTopSales;

  /// Bottom-nav / rail label: comms
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get ownerNavMessages;

  /// Bottom-nav / rail label: activity log
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get ownerNavActivity;

  /// Brand-mark workspace word
  ///
  /// In en, this message translates to:
  /// **'Executive'**
  String get ownerShellWorkspace;

  /// Rail footer identity
  ///
  /// In en, this message translates to:
  /// **'Owner suite'**
  String get ownerShellSuite;

  /// App-bar title: cockpit
  ///
  /// In en, this message translates to:
  /// **'Owner dashboard'**
  String get ownerBarDashboard;

  /// App-bar title: leaderboard
  ///
  /// In en, this message translates to:
  /// **'Top sales'**
  String get ownerBarTopSales;

  /// App-bar subtitle: leaderboard
  ///
  /// In en, this message translates to:
  /// **'Performance breakdown by category'**
  String get ownerBarTopSalesSub;

  /// App-bar title: comms
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get ownerBarMessages;

  /// App-bar subtitle: comms
  ///
  /// In en, this message translates to:
  /// **'Internal messaging'**
  String get ownerBarMessagesSub;

  /// App-bar title: activity log
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get ownerBarActivity;

  /// App-bar subtitle: activity log
  ///
  /// In en, this message translates to:
  /// **'Workshop activity feed'**
  String get ownerBarActivitySub;

  /// Back-to-cockpit tooltip
  ///
  /// In en, this message translates to:
  /// **'Back to overview'**
  String get ownerBarBack;

  /// Command-palette hint
  ///
  /// In en, this message translates to:
  /// **'Search destinations…'**
  String get ownerSearchHint;

  /// Period option
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get ownerPeriodToday;

  /// Period option
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get ownerPeriodWeek;

  /// Period option
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get ownerPeriodMonth;

  /// Period option
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get ownerPeriodYear;

  /// Cockpit header title
  ///
  /// In en, this message translates to:
  /// **'Executive Operations Control'**
  String get ownerOpsTitle;

  /// Cockpit header subtitle
  ///
  /// In en, this message translates to:
  /// **'Real-time overview of branch performance, revenue, and active repair pipelines.'**
  String get ownerOpsSubtitle;

  /// Cockpit live pill
  ///
  /// In en, this message translates to:
  /// **'Live operations'**
  String get ownerPillLive;

  /// Active-jobs pill
  ///
  /// In en, this message translates to:
  /// **'{value} active'**
  String ownerPillActive(String value);

  /// Today-jobs pill
  ///
  /// In en, this message translates to:
  /// **'{value} today'**
  String ownerPillToday(String value);

  /// Hero empty state
  ///
  /// In en, this message translates to:
  /// **'No figures yet.'**
  String get ownerHeroEmpty;

  /// Hero empty hint
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh when you are back online.'**
  String get ownerHeroEmptyHint;

  /// Home error title (message carries the detail)
  ///
  /// In en, this message translates to:
  /// **'Could not load the latest figures'**
  String get ownerHomeLoadError;

  /// Blocker banner: approvals WIP need triage (value verbatim)
  ///
  /// In en, this message translates to:
  /// **'{value} waiting for owner review'**
  String ownerHomeApprovalsBanner(String value);

  /// Curve card title
  ///
  /// In en, this message translates to:
  /// **'Sales & profit'**
  String get ownerChartSalesProfit;

  /// Curve legend: sales
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get ownerChartSales;

  /// Curve legend: profit
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get ownerChartProfit;

  /// Cost card title
  ///
  /// In en, this message translates to:
  /// **'Profit & expenses'**
  String get ownerChartCost;

  /// Cost legend: expenses
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get ownerChartExpenses;

  /// Curve placeholder
  ///
  /// In en, this message translates to:
  /// **'No trend data yet.'**
  String get ownerChartEmpty;

  /// Register section title
  ///
  /// In en, this message translates to:
  /// **'Job register'**
  String get ownerRegisterTitle;

  /// Register see-all action
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get ownerRegisterAll;

  /// Register column
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get ownerRegisterCategory;

  /// Register column
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get ownerRegisterOpen;

  /// Register column
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ownerRegisterTotal;

  /// Register empty state
  ///
  /// In en, this message translates to:
  /// **'No register rows.'**
  String get ownerRegisterEmpty;

  /// Register empty hint
  ///
  /// In en, this message translates to:
  /// **'New jobs will appear here when they are booked.'**
  String get ownerRegisterEmptyHint;

  /// Actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get ownerActionsTitle;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Job cards'**
  String get ownerActionJobCards;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Repair register'**
  String get ownerActionJobCardsHint;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get ownerActionInventory;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Spare parts & stock'**
  String get ownerActionInventoryHint;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get ownerActionReceivables;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Ageing & invoices'**
  String get ownerActionReceivablesHint;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get ownerActionApprovals;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Estimates & discounts'**
  String get ownerActionApprovalsHint;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Job status'**
  String get ownerActionJobStatus;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Live repair pipeline'**
  String get ownerActionJobStatusHint;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get ownerActionCompliance;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Document expiry'**
  String get ownerActionComplianceHint;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get ownerActionReviews;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Customer ratings'**
  String get ownerActionReviewsHint;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get ownerActionAttendance;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Shift register'**
  String get ownerActionAttendanceHint;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Team & roles'**
  String get ownerActionTeam;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Staff permissions'**
  String get ownerActionTeamHint;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Top sales'**
  String get ownerActionTopSales;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Category insights'**
  String get ownerActionTopSalesHint;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get ownerActionMessages;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Internal chat'**
  String get ownerActionMessagesHint;

  /// Quick action
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get ownerActionSubscription;

  /// Quick-action subtitle
  ///
  /// In en, this message translates to:
  /// **'Workshop plan'**
  String get ownerActionSubscriptionHint;

  /// Leaderboard header
  ///
  /// In en, this message translates to:
  /// **'Top sales'**
  String get ownerSalesHeader;

  /// Leaderboard count line
  ///
  /// In en, this message translates to:
  /// **'{count} categories'**
  String ownerSalesCount(int count);

  /// Leaderboard empty state
  ///
  /// In en, this message translates to:
  /// **'No sales data.'**
  String get ownerSalesEmpty;

  /// Leaderboard column
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get ownerSalesNo;

  /// Leaderboard column
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get ownerSalesItem;

  /// Leaderboard column
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get ownerSalesRevenue;

  /// Sent-count pill
  ///
  /// In en, this message translates to:
  /// **'{count} sent'**
  String ownerMsgSent(int count);

  /// Composer title
  ///
  /// In en, this message translates to:
  /// **'Broadcast message to team'**
  String get ownerMsgCompose;

  /// Recipient label
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get ownerMsgRecipient;

  /// Recipient hint
  ///
  /// In en, this message translates to:
  /// **'Choose a staff recipient…'**
  String get ownerMsgRecipientHint;

  /// Body label
  ///
  /// In en, this message translates to:
  /// **'Message body'**
  String get ownerMsgBody;

  /// Body hint
  ///
  /// In en, this message translates to:
  /// **'Type internal instructions or workshop notes here…'**
  String get ownerMsgBodyHint;

  /// Send CTA
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get ownerMsgSend;

  /// Send success toast
  ///
  /// In en, this message translates to:
  /// **'Message delivered to staff portal.'**
  String get ownerMsgSentToast;

  /// Send failure toast
  ///
  /// In en, this message translates to:
  /// **'Message failed. Check recipient selection.'**
  String get ownerMsgFailToast;

  /// History section
  ///
  /// In en, this message translates to:
  /// **'Dispatch history'**
  String get ownerMsgHistory;

  /// History empty state
  ///
  /// In en, this message translates to:
  /// **'No broadcasts yet.'**
  String get ownerMsgEmpty;

  /// History empty hint
  ///
  /// In en, this message translates to:
  /// **'Messages to the team will appear here.'**
  String get ownerMsgEmptyHint;

  /// Empty team note
  ///
  /// In en, this message translates to:
  /// **'No active staff found.'**
  String get ownerMsgNoTeam;

  /// Activity empty state
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get ownerActEmpty;

  /// Activity empty hint
  ///
  /// In en, this message translates to:
  /// **'Job cards, approvals and payments will show up here.'**
  String get ownerActEmptyHint;

  /// Activity group: today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get ownerActToday;

  /// Activity group: yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get ownerActYesterday;

  /// Register app-bar title
  ///
  /// In en, this message translates to:
  /// **'Job register'**
  String get ownerRegTitle;

  /// Register app-bar subtitle
  ///
  /// In en, this message translates to:
  /// **'All active workshop jobs'**
  String get ownerRegSubtitle;

  /// Register search hint
  ///
  /// In en, this message translates to:
  /// **'Search job, plate, customer…'**
  String get ownerRegSearchHint;

  /// Filter chip
  ///
  /// In en, this message translates to:
  /// **'Intake'**
  String get ownerRegIntake;

  /// Filter chip
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get ownerRegInspect;

  /// Filter chip
  ///
  /// In en, this message translates to:
  /// **'WIP'**
  String get ownerRegWip;

  /// Filter chip
  ///
  /// In en, this message translates to:
  /// **'QC'**
  String get ownerRegQc;

  /// Filter chip
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ownerRegReady;

  /// Filter chip
  ///
  /// In en, this message translates to:
  /// **'Invoiced'**
  String get ownerRegInvoiced;

  /// Table column
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get ownerRegJob;

  /// Table column
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get ownerRegPlate;

  /// Table column
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get ownerRegCustomer;

  /// Table column
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ownerRegTotal;

  /// Table column
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ownerRegStatus;

  /// Register count pill
  ///
  /// In en, this message translates to:
  /// **'{count} jobs'**
  String ownerRegCount(int count);

  /// Preview pane placeholder
  ///
  /// In en, this message translates to:
  /// **'Select a job to preview.'**
  String get ownerRegSelectPrompt;

  /// Register empty state
  ///
  /// In en, this message translates to:
  /// **'No job cards found.'**
  String get ownerRegEmpty;

  /// Register no-match state
  ///
  /// In en, this message translates to:
  /// **'No jobs match this search.'**
  String get ownerRegNoMatch;

  /// Preview pane open action
  ///
  /// In en, this message translates to:
  /// **'Open register'**
  String get ownerRegOpen;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Intake'**
  String get ownerJsReceived;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get ownerJsInspected;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ownerJsPending;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get ownerJsPendingApproval;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Awaiting supervisor'**
  String get ownerJsAwaitSupervisor;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get ownerJsApproved;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get ownerJsAssigned;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get ownerJsProgress;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Waiting parts'**
  String get ownerJsParts;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Quality check'**
  String get ownerJsQc;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'QC passed'**
  String get ownerJsQcPass;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Awaiting customer'**
  String get ownerJsAwaitCustomer;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ownerJsComplete;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get ownerJsDelivered;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ownerJsCancelled;

  /// Detail breadcrumb root
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get ownerDetJobs;

  /// Detail services panel
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get ownerDetServices;

  /// Services empty state
  ///
  /// In en, this message translates to:
  /// **'No services listed.'**
  String get ownerDetNoServices;

  /// Detail assignment panel
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get ownerDetAssign;

  /// Technician row
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get ownerDetTech;

  /// Handover row
  ///
  /// In en, this message translates to:
  /// **'Est. handover'**
  String get ownerDetEta;

  /// Stage row
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get ownerDetStage;

  /// Totals dock label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ownerDetTotal;

  /// Honest financial-scope note
  ///
  /// In en, this message translates to:
  /// **'Parts/labor split unavailable for this record.'**
  String get ownerDetSplitNote;

  /// Lifecycle step
  ///
  /// In en, this message translates to:
  /// **'Intake'**
  String get ownerDetStepIntake;

  /// Lifecycle step
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get ownerDetStepInspect;

  /// Lifecycle step
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get ownerDetStepEstimate;

  /// Lifecycle step
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get ownerDetStepRepair;

  /// Lifecycle step
  ///
  /// In en, this message translates to:
  /// **'QC'**
  String get ownerDetStepQc;

  /// Lifecycle step
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ownerDetStepReady;

  /// Completion CTA
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get ownerDetComplete;

  /// Share action
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get ownerDetShare;

  /// Completion confirm title
  ///
  /// In en, this message translates to:
  /// **'Mark as complete?'**
  String get ownerDetConfirmTitle;

  /// Completion confirm body
  ///
  /// In en, this message translates to:
  /// **'The job card moves to Completed and syncs to the workshop register.'**
  String get ownerDetConfirmBody;

  /// Completion toast
  ///
  /// In en, this message translates to:
  /// **'Job card marked as completed.'**
  String get ownerDetDone;

  /// Completion failure toast
  ///
  /// In en, this message translates to:
  /// **'Could not complete the job card. Try again.'**
  String get ownerDetFail;

  /// Detail empty state
  ///
  /// In en, this message translates to:
  /// **'No job card selected.'**
  String get ownerDetEmpty;

  /// Detail empty hint
  ///
  /// In en, this message translates to:
  /// **'Open a job from the register.'**
  String get ownerDetEmptyHint;

  /// Dialog cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ownerDetCancel;

  /// Status app-bar title
  ///
  /// In en, this message translates to:
  /// **'Live job pipeline'**
  String get ownerStTitle;

  /// Status app-bar subtitle
  ///
  /// In en, this message translates to:
  /// **'Stage monitor with auto-refresh'**
  String get ownerStSubtitle;

  /// Status search hint
  ///
  /// In en, this message translates to:
  /// **'Search job, customer, vehicle…'**
  String get ownerStSearchHint;

  /// Freshness stamp
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String ownerStUpdated(String time);

  /// Stale banner
  ///
  /// In en, this message translates to:
  /// **'Data may be stale. Pull to refresh.'**
  String get ownerStStale;

  /// Status empty state
  ///
  /// In en, this message translates to:
  /// **'No job cards in this stage.'**
  String get ownerStEmpty;

  /// Queue pod
  ///
  /// In en, this message translates to:
  /// **'Intake queue'**
  String get ownerStPodQueue;

  /// Active pod
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ownerStPodActive;

  /// Done pod
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ownerStPodDone;

  /// Attention pod
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get ownerStPodAttention;

  /// Stage chip
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get ownerStgInspect;

  /// Stage chip
  ///
  /// In en, this message translates to:
  /// **'Pre-request'**
  String get ownerStgPreReq;

  /// Stage chip
  ///
  /// In en, this message translates to:
  /// **'Estimation'**
  String get ownerStgEstimate;

  /// Stage chip
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get ownerStgApproval;

  /// Stage chip
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get ownerStgParts;

  /// Stage chip
  ///
  /// In en, this message translates to:
  /// **'WIP'**
  String get ownerStgWip;

  /// Stage chip
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ownerStgComplete;

  /// Stage chip
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ownerStgCancel;

  /// Approvals app-bar title
  ///
  /// In en, this message translates to:
  /// **'Pending authorizations'**
  String get ownerApTitle;

  /// Approvals app-bar subtitle
  ///
  /// In en, this message translates to:
  /// **'Discounts, goodwill and overrides'**
  String get ownerApSubtitle;

  /// Approvals hero eyebrow
  ///
  /// In en, this message translates to:
  /// **'Awaiting owner review'**
  String get ownerApAwaiting;

  /// Approvals hero count
  ///
  /// In en, this message translates to:
  /// **'{count} requests'**
  String ownerApCount(int count);

  /// Queue section title
  ///
  /// In en, this message translates to:
  /// **'Review queue'**
  String get ownerApList;

  /// Approvals empty state
  ///
  /// In en, this message translates to:
  /// **'No pending approvals.'**
  String get ownerApEmpty;

  /// Approvals empty hint
  ///
  /// In en, this message translates to:
  /// **'Discount, goodwill and override requests will appear here.'**
  String get ownerApEmptyHint;

  /// Honest read-only note
  ///
  /// In en, this message translates to:
  /// **'Approval actions are not available in this version.'**
  String get ownerApNoAction;

  /// Shared required-field error
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get ownerReqRequired;

  /// Shared email error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get ownerReqEmail;

  /// Shared phone error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number.'**
  String get ownerReqPhone;

  /// Shared password error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get ownerReqPassword;

  /// Shared password-match error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get ownerReqMatch;

  /// AR app-bar title
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get ownerArTitle;

  /// AR app-bar subtitle
  ///
  /// In en, this message translates to:
  /// **'Outstanding {amount}'**
  String ownerArSubtitle(String amount);

  /// AR search hint
  ///
  /// In en, this message translates to:
  /// **'Search customer, invoice or AR ID…'**
  String get ownerArSearchHint;

  /// Aging bucket
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get ownerArCurrent;

  /// Aging bucket
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get ownerArOverdue;

  /// Aging bucket
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get ownerArCritical;

  /// Bucket range
  ///
  /// In en, this message translates to:
  /// **'0–30 days'**
  String get ownerArAge030;

  /// Bucket range
  ///
  /// In en, this message translates to:
  /// **'31–60 days'**
  String get ownerArAge3160;

  /// Bucket range
  ///
  /// In en, this message translates to:
  /// **'60+ days'**
  String get ownerArAge61;

  /// Ledger column
  ///
  /// In en, this message translates to:
  /// **'Ref'**
  String get ownerArRef;

  /// Ledger column
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get ownerArCustomer;

  /// Ledger column
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get ownerArAmount;

  /// Ledger column
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ownerArAge;

  /// Age pill
  ///
  /// In en, this message translates to:
  /// **'0–30'**
  String get ownerArAge030pill;

  /// Age pill
  ///
  /// In en, this message translates to:
  /// **'31–60'**
  String get ownerArAge3160pill;

  /// Age pill
  ///
  /// In en, this message translates to:
  /// **'61–90'**
  String get ownerArAge6190pill;

  /// Age pill
  ///
  /// In en, this message translates to:
  /// **'90+'**
  String get ownerArAge90pill;

  /// Ledger empty state
  ///
  /// In en, this message translates to:
  /// **'No receivables found.'**
  String get ownerArEmpty;

  /// Ledger no-match state
  ///
  /// In en, this message translates to:
  /// **'No debtors match this search.'**
  String get ownerArNoMatch;

  /// Contact sheet title
  ///
  /// In en, this message translates to:
  /// **'Billing contact'**
  String get ownerArContact;

  /// Ledger count pill
  ///
  /// In en, this message translates to:
  /// **'{count} debtors'**
  String ownerArCount(int count);

  /// Inventory app-bar title
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get ownerInTitle;

  /// Valuation hero label
  ///
  /// In en, this message translates to:
  /// **'Stock valuation'**
  String get ownerInValuation;

  /// Valuation basis note
  ///
  /// In en, this message translates to:
  /// **'At cost'**
  String get ownerInAtCost;

  /// Reorder strip
  ///
  /// In en, this message translates to:
  /// **'{count} at or below reorder level'**
  String ownerInLow(int count);

  /// Out-of-stock strip
  ///
  /// In en, this message translates to:
  /// **'{count} out of stock'**
  String ownerInOut(int count);

  /// Healthy strip
  ///
  /// In en, this message translates to:
  /// **'Stock levels healthy.'**
  String get ownerInStockOk;

  /// Parts tab
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get ownerInParts;

  /// Suppliers tab
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get ownerInSuppliers;

  /// Orders tab
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ownerInOrders;

  /// Parts search hint
  ///
  /// In en, this message translates to:
  /// **'Search parts by name, SKU or category…'**
  String get ownerInSearchHint;

  /// Filter sheet title
  ///
  /// In en, this message translates to:
  /// **'Filter stock'**
  String get ownerInFilter;

  /// Filter section
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get ownerInCategory;

  /// Filter section
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get ownerInAvailability;

  /// Filter option
  ///
  /// In en, this message translates to:
  /// **'All stock'**
  String get ownerInAllStock;

  /// Filter option
  ///
  /// In en, this message translates to:
  /// **'Low stock only'**
  String get ownerInLowOnly;

  /// Filter apply
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get ownerInApply;

  /// Filter clear
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get ownerInClear;

  /// Parts empty state
  ///
  /// In en, this message translates to:
  /// **'No parts in stock.'**
  String get ownerInEmpty;

  /// Parts no-match state
  ///
  /// In en, this message translates to:
  /// **'No parts match this search.'**
  String get ownerInNoMatch;

  /// Quantity pill
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String ownerInStockLeft(int count);

  /// Add CTA
  ///
  /// In en, this message translates to:
  /// **'Add part'**
  String get ownerInAdd;

  /// Add sheet title
  ///
  /// In en, this message translates to:
  /// **'Add inventory part'**
  String get ownerInAddTitle;

  /// Name field
  ///
  /// In en, this message translates to:
  /// **'Part / item name'**
  String get ownerInName;

  /// SKU field
  ///
  /// In en, this message translates to:
  /// **'SKU / part number'**
  String get ownerInSku;

  /// Price field
  ///
  /// In en, this message translates to:
  /// **'Price (AED)'**
  String get ownerInPrice;

  /// Qty field
  ///
  /// In en, this message translates to:
  /// **'Initial qty'**
  String get ownerInQty;

  /// Qty column
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get ownerInQtyCol;

  /// Reorder field
  ///
  /// In en, this message translates to:
  /// **'Reorder alert level'**
  String get ownerInReorder;

  /// Add submit
  ///
  /// In en, this message translates to:
  /// **'Add to warehouse'**
  String get ownerInSubmit;

  /// Add toast
  ///
  /// In en, this message translates to:
  /// **'Part added to warehouse.'**
  String get ownerInAdded;

  /// Add failure toast
  ///
  /// In en, this message translates to:
  /// **'Could not add item.'**
  String get ownerInAddFail;

  /// Adjust failure toast
  ///
  /// In en, this message translates to:
  /// **'Could not adjust stock.'**
  String get ownerInAdjustFail;

  /// Suppliers empty state
  ///
  /// In en, this message translates to:
  /// **'No suppliers recorded.'**
  String get ownerInNoSuppliers;

  /// Orders empty state
  ///
  /// In en, this message translates to:
  /// **'No purchase orders placed.'**
  String get ownerInNoOrders;

  /// Missing phone note
  ///
  /// In en, this message translates to:
  /// **'No contact phone.'**
  String get ownerInNoPhone;

  /// Team app-bar title
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get ownerTmTitle;

  /// Team app-bar subtitle
  ///
  /// In en, this message translates to:
  /// **'{active} of {total} active'**
  String ownerTmSubtitle(int active, int total);

  /// Directory header
  ///
  /// In en, this message translates to:
  /// **'Staff directory'**
  String get ownerTmDirectory;

  /// Team search hint
  ///
  /// In en, this message translates to:
  /// **'Search name, ID, phone, role or branch…'**
  String get ownerTmSearchHint;

  /// Role chip
  ///
  /// In en, this message translates to:
  /// **'Advisors'**
  String get ownerTmAdvisors;

  /// Role chip
  ///
  /// In en, this message translates to:
  /// **'Supervisors'**
  String get ownerTmSupervisors;

  /// Role chip
  ///
  /// In en, this message translates to:
  /// **'Technicians'**
  String get ownerTmTechnicians;

  /// Directory empty state
  ///
  /// In en, this message translates to:
  /// **'No staff match this filter.'**
  String get ownerTmEmpty;

  /// Active pill
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ownerTmActive;

  /// Inactive pill
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get ownerTmOff;

  /// Clock-in pill
  ///
  /// In en, this message translates to:
  /// **'On shift'**
  String get ownerTmOnShift;

  /// Clock-out pill
  ///
  /// In en, this message translates to:
  /// **'Off shift'**
  String get ownerTmOffShift;

  /// Add CTA
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get ownerTmAdd;

  /// Add sheet title
  ///
  /// In en, this message translates to:
  /// **'Create staff login'**
  String get ownerTmAddTitle;

  /// Add sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'Create their Staff app access and workshop details.'**
  String get ownerTmAddSubtitle;

  /// Name field
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get ownerTmName;

  /// ID field
  ///
  /// In en, this message translates to:
  /// **'Staff ID (e.g. ADV002)'**
  String get ownerTmEmpId;

  /// Role field
  ///
  /// In en, this message translates to:
  /// **'Staff app role'**
  String get ownerTmRole;

  /// Credentials section
  ///
  /// In en, this message translates to:
  /// **'Login credentials'**
  String get ownerTmLogin;

  /// Phone field
  ///
  /// In en, this message translates to:
  /// **'Mobile number with country code'**
  String get ownerTmPhone;

  /// Email field
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get ownerTmEmail;

  /// Password field
  ///
  /// In en, this message translates to:
  /// **'Initial password (minimum 8 characters)'**
  String get ownerTmPassword;

  /// Confirm field
  ///
  /// In en, this message translates to:
  /// **'Confirm initial password'**
  String get ownerTmPassword2;

  /// OTP note
  ///
  /// In en, this message translates to:
  /// **'They can sign in with email or mobile + password, or use an OTP.'**
  String get ownerTmOtpNote;

  /// Work section
  ///
  /// In en, this message translates to:
  /// **'Work details'**
  String get ownerTmWork;

  /// Designation field
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get ownerTmDesignation;

  /// Department field
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get ownerTmDepartment;

  /// Branch field
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get ownerTmBranch;

  /// Branch hint
  ///
  /// In en, this message translates to:
  /// **'Select a branch'**
  String get ownerTmBranchHint;

  /// Empty branches note
  ///
  /// In en, this message translates to:
  /// **'No branches configured.'**
  String get ownerTmNoBranches;

  /// Shift field
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get ownerTmShift;

  /// Add submit
  ///
  /// In en, this message translates to:
  /// **'Create staff account'**
  String get ownerTmSubmit;

  /// Created title
  ///
  /// In en, this message translates to:
  /// **'Staff login created.'**
  String get ownerTmCreated;

  /// Created body
  ///
  /// In en, this message translates to:
  /// **'Share the initial password securely and ask them to change it after signing in.'**
  String get ownerTmCreatedBody;

  /// Dialog done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ownerTmDone;

  /// Attendance app-bar title
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get ownerAtTitle;

  /// Attendance subtitle
  ///
  /// In en, this message translates to:
  /// **'Daily clock register'**
  String get ownerAtSubtitle;

  /// Strip label
  ///
  /// In en, this message translates to:
  /// **'Total staff'**
  String get ownerAtTotal;

  /// Strip label
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get ownerAtPresent;

  /// Strip label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ownerAtDone;

  /// Strip label
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get ownerAtAbsent;

  /// Role chip
  ///
  /// In en, this message translates to:
  /// **'All roles'**
  String get ownerAtAllRoles;

  /// Records empty state
  ///
  /// In en, this message translates to:
  /// **'No attendance records.'**
  String get ownerAtEmpty;

  /// Punch-in row
  ///
  /// In en, this message translates to:
  /// **'Clock in'**
  String get ownerAtIn;

  /// Punch-out row
  ///
  /// In en, this message translates to:
  /// **'Clock out'**
  String get ownerAtOut;

  /// Hours row
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get ownerAtHours;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get ownerAtWorking;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get ownerAtBreak;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ownerAtComplete;

  /// Status pill
  ///
  /// In en, this message translates to:
  /// **'Not punched in'**
  String get ownerAtIdle;

  /// Expiry app-bar title
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get ownerExTitle;

  /// Expiry subtitle
  ///
  /// In en, this message translates to:
  /// **'Licenses, permits and visas'**
  String get ownerExSubtitle;

  /// Expiry search hint
  ///
  /// In en, this message translates to:
  /// **'Search employee, role or document…'**
  String get ownerExSearchHint;

  /// Urgency band
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get ownerExCritical;

  /// Urgency band
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get ownerExUrgent;

  /// Urgency band
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get ownerExWatch;

  /// Countdown pill
  ///
  /// In en, this message translates to:
  /// **'{days}d left'**
  String ownerExDaysLeft(int days);

  /// Overdue pill
  ///
  /// In en, this message translates to:
  /// **'{days}d overdue'**
  String ownerExOverdue(int days);

  /// Expiry empty state
  ///
  /// In en, this message translates to:
  /// **'No documents found.'**
  String get ownerExEmpty;

  /// Alert count pill
  ///
  /// In en, this message translates to:
  /// **'{count} alerts'**
  String ownerExAlerts(int count);

  /// Feedback app-bar title
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get ownerFbTitle;

  /// Feedback subtitle
  ///
  /// In en, this message translates to:
  /// **'Customer ratings inbox'**
  String get ownerFbSubtitle;

  /// Inbox empty state
  ///
  /// In en, this message translates to:
  /// **'No reviews awaiting moderation.'**
  String get ownerFbEmpty;

  /// Anonymous fallback
  ///
  /// In en, this message translates to:
  /// **'Verified customer'**
  String get ownerFbVerified;

  /// Approve CTA
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get ownerFbApprove;

  /// Reject CTA
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get ownerFbReject;

  /// Moderation toast
  ///
  /// In en, this message translates to:
  /// **'Review moderated.'**
  String get ownerFbDone;

  /// Moderation failure toast
  ///
  /// In en, this message translates to:
  /// **'Moderation failed. Try again.'**
  String get ownerFbFail;

  /// Honest read-only note
  ///
  /// In en, this message translates to:
  /// **'Replies are not available in this version.'**
  String get ownerFbNoRespond;

  /// Subscription app-bar title
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get ownerSbTitle;

  /// Tier eyebrow
  ///
  /// In en, this message translates to:
  /// **'Current tier'**
  String get ownerSbCurrent;

  /// Renewal line
  ///
  /// In en, this message translates to:
  /// **'Renews {date}'**
  String ownerSbRenews(String date);

  /// Plans header
  ///
  /// In en, this message translates to:
  /// **'Workshop plans'**
  String get ownerSbPlans;

  /// Plan CTA
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get ownerSbSelect;

  /// Current plan badge
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get ownerSbCurrentPlan;

  /// Plan toast
  ///
  /// In en, this message translates to:
  /// **'Plan updated.'**
  String get ownerSbChanged;

  /// Plan failure toast
  ///
  /// In en, this message translates to:
  /// **'Could not update plan.'**
  String get ownerSbChangeFail;

  /// Plan name
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get ownerSbStarter;

  /// Plan blurb
  ///
  /// In en, this message translates to:
  /// **'Single-branch workshops'**
  String get ownerSbStarterHint;

  /// Plan name
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get ownerSbPro;

  /// Plan blurb
  ///
  /// In en, this message translates to:
  /// **'Multi-branch + CRM + inventory'**
  String get ownerSbProHint;

  /// Plan name
  ///
  /// In en, this message translates to:
  /// **'Enterprise'**
  String get ownerSbEnterprise;

  /// Plan blurb
  ///
  /// In en, this message translates to:
  /// **'SSO, SLAs, dedicated manager'**
  String get ownerSbEnterpriseHint;

  /// Plan price
  ///
  /// In en, this message translates to:
  /// **'AED 499 / mo'**
  String get ownerSbStarterPrice;

  /// Plan price
  ///
  /// In en, this message translates to:
  /// **'AED 1,299 / mo'**
  String get ownerSbProPrice;

  /// Plan price
  ///
  /// In en, this message translates to:
  /// **'AED 2,499 / mo'**
  String get ownerSbEnterprisePrice;
}

class _OwnerLocalizationsDelegate
    extends LocalizationsDelegate<OwnerLocalizations> {
  const _OwnerLocalizationsDelegate();

  @override
  Future<OwnerLocalizations> load(Locale locale) {
    return SynchronousFuture<OwnerLocalizations>(
      lookupOwnerLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_OwnerLocalizationsDelegate old) => false;
}

OwnerLocalizations lookupOwnerLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return OwnerLocalizationsAr();
    case 'en':
      return OwnerLocalizationsEn();
  }

  throw FlutterError(
    'OwnerLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
