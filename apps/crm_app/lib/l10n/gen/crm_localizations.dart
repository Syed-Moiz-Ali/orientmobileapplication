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
