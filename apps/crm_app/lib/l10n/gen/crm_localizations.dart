import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'crm_localizations_ar.dart';
import 'crm_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CrmLocalizations
/// returned by `CrmLocalizations.of(context)`.
///
/// Applications need to include `CrmLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/crm_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CrmLocalizations.localizationsDelegates,
///   supportedLocales: CrmLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the CrmLocalizations.supportedLocales
/// property.
abstract class CrmLocalizations {
  CrmLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CrmLocalizations? of(BuildContext context) {
    return Localizations.of<CrmLocalizations>(context, CrmLocalizations);
  }

  static const LocalizationsDelegate<CrmLocalizations> delegate =
      _CrmLocalizationsDelegate();

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
  /// **'Orient CRM'**
  String get appTitle;

  /// App identity name shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'Orient CRM App'**
  String get loginAppName;

  /// App purpose shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'Manage customer follow-ups, service communication, leads, reminders, and support activity.'**
  String get loginAppPurpose;

  /// Intended users shown on the shared auth shell
  ///
  /// In en, this message translates to:
  /// **'For CRM and customer support users'**
  String get loginIntendedUsers;

  /// App-specific legal notice under the shared auth form
  ///
  /// In en, this message translates to:
  /// **'By signing in, you agree to the Orient CRM App Terms of Service and Privacy Policy.'**
  String get authSecurityNotice;

  /// Nav destination
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Nav destination
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get navLeads;

  /// Nav destination
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get navConversations;

  /// Nav destination
  ///
  /// In en, this message translates to:
  /// **'Sales Team'**
  String get navSalesTeam;

  /// Nav destination
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// Nav destination
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// Nav destination
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get navIntegrations;

  /// Nav destination
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Shell brand mark
  ///
  /// In en, this message translates to:
  /// **'CRM'**
  String get shellCrm;

  /// Shell title dashboard
  ///
  /// In en, this message translates to:
  /// **'Sales workspace'**
  String get shellWorkspace;

  /// Shell subtitle
  ///
  /// In en, this message translates to:
  /// **'Orient CRM'**
  String get shellSubtitle;

  /// Profile branch label
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get shellBranch;

  /// Profile name
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get shellAdminName;

  /// Profile role
  ///
  /// In en, this message translates to:
  /// **'CRM administrator'**
  String get shellAdminRole;

  /// Profile badge
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get shellAdminBadge;

  /// Search trigger
  ///
  /// In en, this message translates to:
  /// **'Search leads…'**
  String get chromeSearch;

  /// Search palette hint
  ///
  /// In en, this message translates to:
  /// **'Type to filter leads and conversations'**
  String get chromeSearchHint;

  /// Drawer tooltip
  ///
  /// In en, this message translates to:
  /// **'Open navigation'**
  String get chromeOpenNav;

  /// Refresh tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh workspace'**
  String get chromeRefresh;

  /// Settings tooltip
  ///
  /// In en, this message translates to:
  /// **'CRM Settings'**
  String get chromeSettings;

  /// Search shortcut hint
  ///
  /// In en, this message translates to:
  /// **'Ctrl+K'**
  String get chromeShortcut;

  /// Branch name
  ///
  /// In en, this message translates to:
  /// **'Bircon, Hifri'**
  String get shellBranchName;

  /// Pulse eyebrow
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get dashLive;

  /// Dashboard header
  ///
  /// In en, this message translates to:
  /// **'CRM Dashboard'**
  String get dashTitle;

  /// Lead count pill
  ///
  /// In en, this message translates to:
  /// **'{count} Leads'**
  String dashLeadsPill(int count);

  /// Won count pill
  ///
  /// In en, this message translates to:
  /// **'{count} Won'**
  String dashWonPill(int count);

  /// Dashboard section
  ///
  /// In en, this message translates to:
  /// **'Sales pulse'**
  String get dashPulse;

  /// Dashboard section
  ///
  /// In en, this message translates to:
  /// **'Attention queue'**
  String get dashAttention;

  /// Dashboard section
  ///
  /// In en, this message translates to:
  /// **'Channel performance'**
  String get dashChannels;

  /// Dashboard section
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get dashActivity;

  /// Dashboard section
  ///
  /// In en, this message translates to:
  /// **'Recent leads'**
  String get dashRecentLeads;

  /// Empty pipeline
  ///
  /// In en, this message translates to:
  /// **'No pipeline data'**
  String get dashNoPipeline;

  /// Empty pipeline body
  ///
  /// In en, this message translates to:
  /// **'Leads will build your pipeline here'**
  String get dashNoPipelineBody;

  /// Empty channels
  ///
  /// In en, this message translates to:
  /// **'No channel data yet'**
  String get dashNoChannel;

  /// Empty channels body
  ///
  /// In en, this message translates to:
  /// **'Messages from connected platforms will appear here'**
  String get dashNoChannelBody;

  /// Empty leads
  ///
  /// In en, this message translates to:
  /// **'No leads yet'**
  String get dashNoLeads;

  /// Empty sync body
  ///
  /// In en, this message translates to:
  /// **'Sync your connected CRM to fetch leads'**
  String get dashSyncBody;

  /// Empty connect body
  ///
  /// In en, this message translates to:
  /// **'Connect a CRM to start receiving leads'**
  String get dashConnectBody;

  /// No integration
  ///
  /// In en, this message translates to:
  /// **'No CRMs connected'**
  String get dashNoCrm;

  /// No integration body
  ///
  /// In en, this message translates to:
  /// **'Connect Meta or Zoho to see live leads here'**
  String get dashNoCrmBody;

  /// Connect CTA
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get dashConnect;

  /// Syncing state
  ///
  /// In en, this message translates to:
  /// **'Syncing leads...'**
  String get dashSyncing;

  /// Empty after sync
  ///
  /// In en, this message translates to:
  /// **'Your CRM is connected but no leads yet'**
  String get dashEmptySync;

  /// Sync CTA
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get dashSyncNow;

  /// Funnel title
  ///
  /// In en, this message translates to:
  /// **'Pipeline funnel'**
  String get fnTitle;

  /// Pipeline widget title
  ///
  /// In en, this message translates to:
  /// **'Lead Pipeline'**
  String get fnPipeline;

  /// Pipeline empty
  ///
  /// In en, this message translates to:
  /// **'No pipeline data yet'**
  String get fnEmpty;

  /// Conversion row
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get fnConversion;

  /// Won revenue row
  ///
  /// In en, this message translates to:
  /// **'Won Revenue'**
  String get fnWonRevenue;

  /// Funnel clear
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get fnClear;

  /// Funnel filter note
  ///
  /// In en, this message translates to:
  /// **'Showing {stage} leads'**
  String fnShowing(String stage);

  /// Follow-ups empty
  ///
  /// In en, this message translates to:
  /// **'No follow-ups scheduled'**
  String get fuEmpty;

  /// Follow-ups title
  ///
  /// In en, this message translates to:
  /// **'Upcoming Follow-ups'**
  String get fuTitle;

  /// Overdue badge
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get fuOverdue;

  /// Activity empty
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get acEmpty;

  /// Activity title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get acTitle;

  /// Recent table header
  ///
  /// In en, this message translates to:
  /// **'S.No'**
  String get rlNo;

  /// Recent table header
  ///
  /// In en, this message translates to:
  /// **'Lead Number'**
  String get rlNumber;

  /// Recent table header
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get rlName;

  /// Recent table header
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get rlSource;

  /// Recent table header
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get rlStatus;

  /// Leads search hint
  ///
  /// In en, this message translates to:
  /// **'Search leads...'**
  String get leadsSearch;

  /// View toggle
  ///
  /// In en, this message translates to:
  /// **'Table view'**
  String get leadsTableView;

  /// View toggle
  ///
  /// In en, this message translates to:
  /// **'Kanban view'**
  String get leadsKanbanView;

  /// Leads count
  ///
  /// In en, this message translates to:
  /// **'{count} Leads'**
  String leadsCount(int count);

  /// Add lead CTA
  ///
  /// In en, this message translates to:
  /// **'Add Lead'**
  String get leadsAdd;

  /// Connect CTA
  ///
  /// In en, this message translates to:
  /// **'Connect CRM'**
  String get leadsConnectCrm;

  /// Empty integrations
  ///
  /// In en, this message translates to:
  /// **'No third-party CRMs connected'**
  String get leadsNoCrm;

  /// Empty integrations body
  ///
  /// In en, this message translates to:
  /// **'Connect Meta, Zoho or other platforms to automatically fetch and manage your leads here'**
  String get leadsNoCrmBody;

  /// Connect CTA
  ///
  /// In en, this message translates to:
  /// **'Connect Now'**
  String get leadsConnectNow;

  /// Auto note
  ///
  /// In en, this message translates to:
  /// **'Leads will appear here automatically once connected'**
  String get leadsAutoNote;

  /// Empty leads
  ///
  /// In en, this message translates to:
  /// **'No leads yet'**
  String get leadsEmpty;

  /// Empty sync body
  ///
  /// In en, this message translates to:
  /// **'Sync now to fetch leads from {source}.'**
  String leadsEmptySync(String source);

  /// Integrations note
  ///
  /// In en, this message translates to:
  /// **'You can also manage connections in the Integrations tab'**
  String get leadsIntegNote;

  /// Platforms fallback
  ///
  /// In en, this message translates to:
  /// **'your connected platforms'**
  String get leadsPlatforms;

  /// Sync CTA
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get leadsSyncNow;

  /// Table header
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get colLead;

  /// Table header
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get colPhone;

  /// Table header
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get colValue;

  /// Table header
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get colStage;

  /// Table header
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get colAgent;

  /// Filter group
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get filterSource;

  /// Filter group
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get filterAgent;

  /// Filter all option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Kanban empty column
  ///
  /// In en, this message translates to:
  /// **'No leads in this stage'**
  String get kbEmptyStage;

  /// Kanban no contact
  ///
  /// In en, this message translates to:
  /// **'No contact information'**
  String get kbNoContact;

  /// Kanban unassigned
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get kbUnassigned;

  /// Count singular
  ///
  /// In en, this message translates to:
  /// **'lead'**
  String get kbLeadOne;

  /// Count plural
  ///
  /// In en, this message translates to:
  /// **'leads'**
  String get kbLeadsMany;

  /// Kanban empty
  ///
  /// In en, this message translates to:
  /// **'No pipeline stages'**
  String get kbNoStages;

  /// Kanban empty body
  ///
  /// In en, this message translates to:
  /// **'New leads will appear here as they enter the pipeline.'**
  String get kbNoStagesBody;

  /// Stage quick-select
  ///
  /// In en, this message translates to:
  /// **'Move to {stage}'**
  String kbMoveTo(String stage);

  /// Stage change notice
  ///
  /// In en, this message translates to:
  /// **'Lead moved to {stage}'**
  String kbMoved(String stage);

  /// Detail row
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get dtPhone;

  /// Detail row
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get dtEmail;

  /// Detail row
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get dtSource;

  /// Detail row
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get dtAssigned;

  /// Detail row
  ///
  /// In en, this message translates to:
  /// **'Lead Value'**
  String get dtValue;

  /// Detail row
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get dtFollowUp;

  /// Detail row
  ///
  /// In en, this message translates to:
  /// **'Last activity'**
  String get dtLastActivity;

  /// Detail fallback
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get dtUnassigned;

  /// Detail section
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get dtNotes;

  /// Detail section
  ///
  /// In en, this message translates to:
  /// **'Activity History'**
  String get dtActivity;

  /// Detail empty activities
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get dtNoActivity;

  /// Detail section
  ///
  /// In en, this message translates to:
  /// **'Change Status'**
  String get dtChangeStatus;

  /// Delete dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Lead'**
  String get dtDeleteTitle;

  /// Delete dialog body
  ///
  /// In en, this message translates to:
  /// **'Delete {name} ({number})? This cannot be undone.'**
  String dtDeleteBody(String name, String number);

  /// Dialog dismiss
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dtCancel;

  /// Dialog confirm
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dtDelete;

  /// Delete notice
  ///
  /// In en, this message translates to:
  /// **'Lead deleted'**
  String get dtDeleted;

  /// Status change notice
  ///
  /// In en, this message translates to:
  /// **'Lead marked as {status}'**
  String dtMarked(String status);

  /// WhatsApp action
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get dtWhatsApp;

  /// Call action
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get dtCall;

  /// Edit action
  ///
  /// In en, this message translates to:
  /// **'Edit lead'**
  String get dtEdit;

  /// Dialer failure
  ///
  /// In en, this message translates to:
  /// **'Unable to open the phone app.'**
  String get dtCallFail;

  /// WhatsApp failure
  ///
  /// In en, this message translates to:
  /// **'Unable to open WhatsApp.'**
  String get dtWaFail;

  /// Form title
  ///
  /// In en, this message translates to:
  /// **'Add Lead'**
  String get fmAddLead;

  /// Form title
  ///
  /// In en, this message translates to:
  /// **'Edit Lead'**
  String get fmEditLead;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get fmName;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fmPhone;

  /// Form hint
  ///
  /// In en, this message translates to:
  /// **'050 123 4567'**
  String get fmPhoneHint;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fmEmail;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get fmSource;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Assigned To'**
  String get fmAssigned;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Lead Value (AED)'**
  String get fmValue;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Follow-up Date'**
  String get fmFollowUp;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fmNotes;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fmStatus;

  /// Dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select {label}'**
  String fmSelectOption(String label);

  /// Assignee hint
  ///
  /// In en, this message translates to:
  /// **'Select assignee'**
  String get fmSelectAssignee;

  /// Date hint
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get fmSelectDate;

  /// Notes hint
  ///
  /// In en, this message translates to:
  /// **'Add notes about this lead...'**
  String get fmNotesHint;

  /// Team loading
  ///
  /// In en, this message translates to:
  /// **'Loading team...'**
  String get fmLoadingTeam;

  /// Team error
  ///
  /// In en, this message translates to:
  /// **'Could not load team'**
  String get fmTeamFail;

  /// Save busy
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get fmSaving;

  /// Save CTA
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get fmSaveChanges;

  /// Name validation
  ///
  /// In en, this message translates to:
  /// **'Customer name is required'**
  String get fmNameRequired;

  /// Phone validation
  ///
  /// In en, this message translates to:
  /// **'Enter a valid UAE mobile number.'**
  String get fmPhoneInvalid;

  /// Update notice
  ///
  /// In en, this message translates to:
  /// **'Lead updated'**
  String get fmUpdated;

  /// Create notice
  ///
  /// In en, this message translates to:
  /// **'Lead created'**
  String get fmCreated;

  /// Assignee fallback
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get fmUnassigned;

  /// Tasks count
  ///
  /// In en, this message translates to:
  /// **'{count} Tasks'**
  String tkCount(int count);

  /// Add task CTA
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get tkAdd;

  /// Empty tasks
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get tkEmpty;

  /// Empty tasks body
  ///
  /// In en, this message translates to:
  /// **'Create tasks for your team to follow up on leads'**
  String get tkEmptyBody;

  /// Delete dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get tkDeleteTitle;

  /// Delete dialog body
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String tkDeleteBody(String title);

  /// Dialog dismiss
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tkCancel;

  /// Dialog confirm
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tkDelete;

  /// Form title
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get tkFormEdit;

  /// Form title
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get tkFormAdd;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get tkFormTitle;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Assigned To'**
  String get tkFormAssigned;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get tkFormDue;

  /// Form label
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get tkFormPriority;

  /// Priority
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get tkHigh;

  /// Priority
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get tkMedium;

  /// Priority
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get tkLow;

  /// Team loading
  ///
  /// In en, this message translates to:
  /// **'Loading team...'**
  String get tkLoadingTeam;

  /// Team error
  ///
  /// In en, this message translates to:
  /// **'Could not load team'**
  String get tkTeamFail;

  /// Assignee hint
  ///
  /// In en, this message translates to:
  /// **'Select assignee'**
  String get tkSelectAssignee;

  /// Save busy
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get tkSaving;

  /// Save CTA
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get tkSaveChanges;

  /// Title validation
  ///
  /// In en, this message translates to:
  /// **'Task title is required'**
  String get tkTitleRequired;

  /// Assignee fallback
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get tkUnassigned;

  /// Due fallback
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get tkNoDue;

  /// Overdue badge
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get tkOverdue;

  /// Due badge
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get tkDueToday;

  /// Complete action
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get tkMarkDone;

  /// Reopen action
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get tkReopen;

  /// Conversations eyebrow
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get cvInbox;

  /// Conversations title
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get cvTitle;

  /// Conversations empty subtitle
  ///
  /// In en, this message translates to:
  /// **'Customer messages from connected channels will appear here.'**
  String get cvEmptySub;

  /// Thread count singular
  ///
  /// In en, this message translates to:
  /// **'1 active customer thread across every channel.'**
  String get cvThreadsOne;

  /// Thread count plural
  ///
  /// In en, this message translates to:
  /// **'{count} active customer threads across every channel.'**
  String cvThreadsMany(int count);

  /// Conversations empty
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get cvEmpty;

  /// Conversations empty body
  ///
  /// In en, this message translates to:
  /// **'Connect a messaging channel to bring customer conversations into one queue.'**
  String get cvEmptyBody;

  /// Unread semantics
  ///
  /// In en, this message translates to:
  /// **'{count} unread messages'**
  String cvUnread(int count);

  /// Thread message label
  ///
  /// In en, this message translates to:
  /// **'Latest message'**
  String get cvLatest;

  /// Thread placeholder
  ///
  /// In en, this message translates to:
  /// **'Select a conversation'**
  String get cvNoThread;

  /// Thread placeholder body
  ///
  /// In en, this message translates to:
  /// **'Pick a thread to read the latest message and customer details.'**
  String get cvNoThreadBody;

  /// Thread back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cvBack;

  /// Dossier title
  ///
  /// In en, this message translates to:
  /// **'Customer dossier'**
  String get cvDossier;

  /// Dossier row
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get cvStatus;

  /// Dossier row
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get cvChannel;

  /// Dossier row
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get cvTime;

  /// Thread honesty note
  ///
  /// In en, this message translates to:
  /// **'Full message history lives in the connected channel — newest message shown here.'**
  String get cvHistoryNote;

  /// Team header
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get tmTitle;

  /// Team subtitle
  ///
  /// In en, this message translates to:
  /// **'Ranked by revenue won this period.'**
  String get tmSub;

  /// Team pill
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get tmLeads;

  /// Team pill
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get tmWon;

  /// Team pill
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get tmWinRate;

  /// Team revenue label
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get tmRevenue;

  /// Team search sheet title
  ///
  /// In en, this message translates to:
  /// **'Search team'**
  String get tmSearchTitle;

  /// Team search hint
  ///
  /// In en, this message translates to:
  /// **'Search by name or role'**
  String get tmSearchHint;

  /// Team search no-match
  ///
  /// In en, this message translates to:
  /// **'No team members match your search.'**
  String get tmSearchNoMatch;

  /// Team empty
  ///
  /// In en, this message translates to:
  /// **'No salespeople yet'**
  String get tmEmpty;

  /// Team empty body
  ///
  /// In en, this message translates to:
  /// **'Team members appear here once added.'**
  String get tmEmptyBody;

  /// Reports chart
  ///
  /// In en, this message translates to:
  /// **'Conversion Trends'**
  String get rpConversion;

  /// Reports empty
  ///
  /// In en, this message translates to:
  /// **'No conversion data yet'**
  String get rpNoConversion;

  /// Chart legend
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get rpWon;

  /// Chart legend
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get rpLost;

  /// Chart legend
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get rpActive;

  /// Reports chart
  ///
  /// In en, this message translates to:
  /// **'Lead Sources'**
  String get rpSources;

  /// Reports empty
  ///
  /// In en, this message translates to:
  /// **'No source data yet'**
  String get rpNoSources;

  /// Reports chart
  ///
  /// In en, this message translates to:
  /// **'Salesperson Performance'**
  String get rpPerf;

  /// Reports empty
  ///
  /// In en, this message translates to:
  /// **'No salesperson data yet'**
  String get rpNoPerf;

  /// Chart legend
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get rpLeads;

  /// Reports chart
  ///
  /// In en, this message translates to:
  /// **'Response Time Analysis'**
  String get rpResponse;

  /// Reports empty
  ///
  /// In en, this message translates to:
  /// **'No response time data yet'**
  String get rpNoResponse;

  /// Reports section
  ///
  /// In en, this message translates to:
  /// **'Key Metrics'**
  String get rpMetrics;

  /// Donut center
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get rpTotal;

  /// Integrations eyebrow
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get itDataSources;

  /// Integrations title
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get itTitle;

  /// Integrations subtitle
  ///
  /// In en, this message translates to:
  /// **'Connect a source to bring leads and customer messages into this workspace.'**
  String get itSub;

  /// Connected summary
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} sources connected and available to sync.'**
  String itConnected(int done, int total);

  /// Sync badge
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get itSyncing;

  /// Sync badge
  ///
  /// In en, this message translates to:
  /// **'Sync error'**
  String get itSyncError;

  /// Sync badge
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get itConnectedBadge;

  /// Sync badge
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get itNotConnected;

  /// Lead count suffix
  ///
  /// In en, this message translates to:
  /// **'leads'**
  String get itLeads;

  /// Connected sheet title
  ///
  /// In en, this message translates to:
  /// **'Connected & syncing leads'**
  String get itConnectedTitle;

  /// Connected sheet title
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get itJustConnected;

  /// Connected sheet row
  ///
  /// In en, this message translates to:
  /// **'Leads fetched'**
  String get itLeadsFetched;

  /// Connected sheet row
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get itLastSync;

  /// Connected sheet row
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get itStatus;

  /// Status value
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get itReady;

  /// Sync CTA
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get itSyncNow;

  /// Disconnect CTA
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get itDisconnect;

  /// Sync failure
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Check credentials.'**
  String get itSyncFail;

  /// Sync success
  ///
  /// In en, this message translates to:
  /// **'Sync completed - leads updated'**
  String get itSyncDone;

  /// Disconnect notice
  ///
  /// In en, this message translates to:
  /// **'{name} disconnected'**
  String itDisconnected(String name);

  /// Settings eyebrow
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get seWorkspace;

  /// Settings title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get seTitle;

  /// Settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Control how your team receives work and how new leads enter the queue.'**
  String get seSub;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get seWorkflow;

  /// Settings row
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get sePush;

  /// Settings row body
  ///
  /// In en, this message translates to:
  /// **'Alert me when a new lead or customer message arrives.'**
  String get sePushBody;

  /// Settings row
  ///
  /// In en, this message translates to:
  /// **'Automatically assign leads'**
  String get seAutoAssign;

  /// Settings row body
  ///
  /// In en, this message translates to:
  /// **'Route incoming leads to available salespeople using the team queue.'**
  String get seAutoAssignBody;

  /// Settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get seAppearance;

  /// Settings row
  ///
  /// In en, this message translates to:
  /// **'Dark appearance'**
  String get seDark;

  /// Settings row body
  ///
  /// In en, this message translates to:
  /// **'Use the darker workspace palette when your app theme supports it.'**
  String get seDarkBody;

  /// Settings note
  ///
  /// In en, this message translates to:
  /// **'Appearance preferences are saved to this workspace profile.'**
  String get seLangNote;

  /// Connect sheet title
  ///
  /// In en, this message translates to:
  /// **'Connect a CRM'**
  String get csTitle;

  /// Connect sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose a platform to automatically fetch leads'**
  String get csSub;

  /// Platform subtitle
  ///
  /// In en, this message translates to:
  /// **'Facebook & Instagram Lead Ads'**
  String get csMetaSub;

  /// Platform subtitle
  ///
  /// In en, this message translates to:
  /// **'Zoho CRM Leads'**
  String get csZohoSub;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Page ID'**
  String get csPageId;

  /// Field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. 123456789012345'**
  String get csPageIdHint;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Access Token'**
  String get csToken;

  /// Field hint
  ///
  /// In en, this message translates to:
  /// **'Long-lived page access token'**
  String get csTokenHint;

  /// Field help
  ///
  /// In en, this message translates to:
  /// **'Get these from developers.facebook.com > your app > Lead Ads > API setup'**
  String get csMetaHelp;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get csClientId;

  /// Field hint
  ///
  /// In en, this message translates to:
  /// **'Zoho OAuth client ID'**
  String get csClientIdHint;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Client Secret'**
  String get csSecret;

  /// Field hint
  ///
  /// In en, this message translates to:
  /// **'Zoho OAuth client secret'**
  String get csSecretHint;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Refresh Token'**
  String get csRefresh;

  /// Field hint
  ///
  /// In en, this message translates to:
  /// **'Zoho OAuth refresh token'**
  String get csRefreshHint;

  /// Field help
  ///
  /// In en, this message translates to:
  /// **'Create an app in Zoho API Console > Server-based client > CRM Leads scope'**
  String get csZohoHelp;

  /// Connect busy
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get csConnecting;

  /// Connect CTA
  ///
  /// In en, this message translates to:
  /// **'Connect {platform}'**
  String csConnect(String platform);

  /// Meta validation
  ///
  /// In en, this message translates to:
  /// **'Enter both Page ID and Access Token'**
  String get csNeedMeta;

  /// Zoho validation
  ///
  /// In en, this message translates to:
  /// **'Enter Client ID, Client Secret and Refresh Token'**
  String get csNeedZoho;

  /// Connect success
  ///
  /// In en, this message translates to:
  /// **'{platform} connected! Tap Sync Now to fetch leads'**
  String csDone(String platform);

  /// Connect error
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Check your credentials and try again.'**
  String get csFail;

  /// Leads search sheet title
  ///
  /// In en, this message translates to:
  /// **'Search leads'**
  String get leadsSearchTitle;

  /// Leads search no-match
  ///
  /// In en, this message translates to:
  /// **'No leads match your search.'**
  String get leadsSearchNoMatch;

  /// Leads filter sheet title
  ///
  /// In en, this message translates to:
  /// **'Filter leads'**
  String get leadsFilterTitle;

  /// Filter apply CTA
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get leadsFilterShow;

  /// Filter no-match
  ///
  /// In en, this message translates to:
  /// **'No leads match this filter.'**
  String get leadsFilterNoMatch;

  /// Filter/search clear
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get leadsFilterClear;

  /// Leads count (ICU plural; zero renders as 0)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 leads} =1{1 lead} other{{count} leads}}'**
  String leadsCountN(int count);

  /// Tasks search sheet title
  ///
  /// In en, this message translates to:
  /// **'Search tasks'**
  String get tasksSearchTitle;

  /// Tasks search hint
  ///
  /// In en, this message translates to:
  /// **'Search by title or assignee'**
  String get tasksSearchHint;

  /// Tasks search no-match
  ///
  /// In en, this message translates to:
  /// **'No tasks match your search.'**
  String get tasksSearchNoMatch;

  /// Tasks count (ICU plural; zero renders as 0)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 tasks} =1{1 task} other{{count} tasks}}'**
  String tkCountN(int count);

  /// Wide-layout dossier placeholder
  ///
  /// In en, this message translates to:
  /// **'Select a lead to view details'**
  String get leadsSelectLead;
}

class _CrmLocalizationsDelegate
    extends LocalizationsDelegate<CrmLocalizations> {
  const _CrmLocalizationsDelegate();

  @override
  Future<CrmLocalizations> load(Locale locale) {
    return SynchronousFuture<CrmLocalizations>(lookupCrmLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_CrmLocalizationsDelegate old) => false;
}

CrmLocalizations lookupCrmLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return CrmLocalizationsAr();
    case 'en':
      return CrmLocalizationsEn();
  }

  throw FlutterError(
    'CrmLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
