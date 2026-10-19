// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'crm_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CrmLocalizationsEn extends CrmLocalizations {
  CrmLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Orient CRM';

  @override
  String get loginAppName => 'Orient CRM App';

  @override
  String get loginAppPurpose =>
      'Manage customer follow-ups, service communication, leads, reminders, and support activity.';

  @override
  String get loginIntendedUsers => 'For CRM and customer support users';

  @override
  String get authSecurityNotice =>
      'By signing in, you agree to the Orient CRM App Terms of Service and Privacy Policy.';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navLeads => 'Leads';

  @override
  String get navConversations => 'Conversations';

  @override
  String get navSalesTeam => 'Sales Team';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navReports => 'Reports';

  @override
  String get navIntegrations => 'Integrations';

  @override
  String get navSettings => 'Settings';

  @override
  String get shellCrm => 'CRM';

  @override
  String get shellWorkspace => 'Sales workspace';

  @override
  String get shellSubtitle => 'Orient CRM';

  @override
  String get shellBranch => 'Branch';

  @override
  String get shellAdminName => 'Admin';

  @override
  String get shellAdminRole => 'CRM administrator';

  @override
  String get shellAdminBadge => 'Admin';

  @override
  String get chromeSearch => 'Search leads…';

  @override
  String get chromeSearchHint => 'Type to filter leads and conversations';

  @override
  String get chromeOpenNav => 'Open navigation';

  @override
  String get chromeRefresh => 'Refresh workspace';

  @override
  String get chromeSettings => 'CRM Settings';

  @override
  String get chromeShortcut => 'Ctrl+K';

  @override
  String get shellBranchName => 'Bircon, Hifri';

  @override
  String get dashLive => 'Live';

  @override
  String get dashTitle => 'CRM Dashboard';

  @override
  String dashLeadsPill(int count) {
    return '$count Leads';
  }

  @override
  String dashWonPill(int count) {
    return '$count Won';
  }

  @override
  String get dashPulse => 'Sales pulse';

  @override
  String get dashAttention => 'Attention queue';

  @override
  String get dashChannels => 'Channel performance';

  @override
  String get dashActivity => 'Recent activity';

  @override
  String get dashRecentLeads => 'Recent leads';

  @override
  String get dashNoPipeline => 'No pipeline data';

  @override
  String get dashNoPipelineBody => 'Leads will build your pipeline here';

  @override
  String get dashNoChannel => 'No channel data yet';

  @override
  String get dashNoChannelBody =>
      'Messages from connected platforms will appear here';

  @override
  String get dashNoLeads => 'No leads yet';

  @override
  String get dashSyncBody => 'Sync your connected CRM to fetch leads';

  @override
  String get dashConnectBody => 'Connect a CRM to start receiving leads';

  @override
  String get dashNoCrm => 'No CRMs connected';

  @override
  String get dashNoCrmBody => 'Connect Meta or Zoho to see live leads here';

  @override
  String get dashConnect => 'Connect';

  @override
  String get dashSyncing => 'Syncing leads...';

  @override
  String get dashEmptySync => 'Your CRM is connected but no leads yet';

  @override
  String get dashSyncNow => 'Sync Now';

  @override
  String get fnTitle => 'Pipeline funnel';

  @override
  String get fnPipeline => 'Lead Pipeline';

  @override
  String get fnEmpty => 'No pipeline data yet';

  @override
  String get fnConversion => 'Conversion Rate';

  @override
  String get fnWonRevenue => 'Won Revenue';

  @override
  String get fnClear => 'Clear filter';

  @override
  String fnShowing(String stage) {
    return 'Showing $stage leads';
  }

  @override
  String get fuEmpty => 'No follow-ups scheduled';

  @override
  String get fuTitle => 'Upcoming Follow-ups';

  @override
  String get fuOverdue => 'OVERDUE';

  @override
  String get acEmpty => 'No activity yet';

  @override
  String get acTitle => 'Recent Activity';

  @override
  String get rlNo => 'S.No';

  @override
  String get rlNumber => 'Lead Number';

  @override
  String get rlName => 'Customer Name';

  @override
  String get rlSource => 'Source';

  @override
  String get rlStatus => 'Status';

  @override
  String get leadsSearch => 'Search leads...';

  @override
  String get leadsTableView => 'Table view';

  @override
  String get leadsKanbanView => 'Kanban view';

  @override
  String leadsCount(int count) {
    return '$count Leads';
  }

  @override
  String get leadsAdd => 'Add Lead';

  @override
  String get leadsConnectCrm => 'Connect CRM';

  @override
  String get leadsNoCrm => 'No third-party CRMs connected';

  @override
  String get leadsNoCrmBody =>
      'Connect Meta, Zoho or other platforms to automatically fetch and manage your leads here';

  @override
  String get leadsConnectNow => 'Connect Now';

  @override
  String get leadsAutoNote =>
      'Leads will appear here automatically once connected';

  @override
  String get leadsEmpty => 'No leads yet';

  @override
  String leadsEmptySync(String source) {
    return 'Sync now to fetch leads from $source.';
  }

  @override
  String get leadsIntegNote =>
      'You can also manage connections in the Integrations tab';

  @override
  String get leadsPlatforms => 'your connected platforms';

  @override
  String get leadsSyncNow => 'Sync Now';

  @override
  String get colLead => 'Lead';

  @override
  String get colPhone => 'Phone';

  @override
  String get colValue => 'Value';

  @override
  String get colStage => 'Stage';

  @override
  String get colAgent => 'Agent';

  @override
  String get filterSource => 'Source';

  @override
  String get filterAgent => 'Agent';

  @override
  String get filterAll => 'All';

  @override
  String get kbEmptyStage => 'No leads in this stage';

  @override
  String get kbNoContact => 'No contact information';

  @override
  String get kbUnassigned => 'Unassigned';

  @override
  String get kbLeadOne => 'lead';

  @override
  String get kbLeadsMany => 'leads';

  @override
  String get kbNoStages => 'No pipeline stages';

  @override
  String get kbNoStagesBody =>
      'New leads will appear here as they enter the pipeline.';

  @override
  String kbMoveTo(String stage) {
    return 'Move to $stage';
  }

  @override
  String kbMoved(String stage) {
    return 'Lead moved to $stage';
  }

  @override
  String get dtPhone => 'Phone';

  @override
  String get dtEmail => 'Email';

  @override
  String get dtSource => 'Source';

  @override
  String get dtAssigned => 'Assigned to';

  @override
  String get dtValue => 'Lead Value';

  @override
  String get dtFollowUp => 'Follow-up';

  @override
  String get dtLastActivity => 'Last activity';

  @override
  String get dtUnassigned => 'Unassigned';

  @override
  String get dtNotes => 'Notes';

  @override
  String get dtActivity => 'Activity History';

  @override
  String get dtNoActivity => 'No activity yet';

  @override
  String get dtChangeStatus => 'Change Status';

  @override
  String get dtDeleteTitle => 'Delete Lead';

  @override
  String dtDeleteBody(String name, String number) {
    return 'Delete $name ($number)? This cannot be undone.';
  }

  @override
  String get dtCancel => 'Cancel';

  @override
  String get dtDelete => 'Delete';

  @override
  String get dtDeleted => 'Lead deleted';

  @override
  String dtMarked(String status) {
    return 'Lead marked as $status';
  }

  @override
  String get dtWhatsApp => 'WhatsApp';

  @override
  String get dtCall => 'Call';

  @override
  String get dtEdit => 'Edit lead';

  @override
  String get dtCallFail => 'Unable to open the phone app.';

  @override
  String get dtWaFail => 'Unable to open WhatsApp.';

  @override
  String get fmAddLead => 'Add Lead';

  @override
  String get fmEditLead => 'Edit Lead';

  @override
  String get fmName => 'Customer Name';

  @override
  String get fmPhone => 'Phone';

  @override
  String get fmPhoneHint => '050 123 4567';

  @override
  String get fmEmail => 'Email';

  @override
  String get fmSource => 'Source';

  @override
  String get fmAssigned => 'Assigned To';

  @override
  String get fmValue => 'Lead Value (AED)';

  @override
  String get fmFollowUp => 'Follow-up Date';

  @override
  String get fmNotes => 'Notes';

  @override
  String get fmStatus => 'Status';

  @override
  String fmSelectOption(String label) {
    return 'Select $label';
  }

  @override
  String get fmSelectAssignee => 'Select assignee';

  @override
  String get fmSelectDate => 'Select a date';

  @override
  String get fmNotesHint => 'Add notes about this lead...';

  @override
  String get fmLoadingTeam => 'Loading team...';

  @override
  String get fmTeamFail => 'Could not load team';

  @override
  String get fmSaving => 'Saving...';

  @override
  String get fmSaveChanges => 'Save Changes';

  @override
  String get fmNameRequired => 'Customer name is required';

  @override
  String get fmPhoneInvalid => 'Enter a valid UAE mobile number.';

  @override
  String get fmUpdated => 'Lead updated';

  @override
  String get fmCreated => 'Lead created';

  @override
  String get fmUnassigned => 'Unassigned';

  @override
  String tkCount(int count) {
    return '$count Tasks';
  }

  @override
  String get tkAdd => 'Add Task';

  @override
  String get tkEmpty => 'No tasks yet';

  @override
  String get tkEmptyBody => 'Create tasks for your team to follow up on leads';

  @override
  String get tkDeleteTitle => 'Delete Task';

  @override
  String tkDeleteBody(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get tkCancel => 'Cancel';

  @override
  String get tkDelete => 'Delete';

  @override
  String get tkFormEdit => 'Edit Task';

  @override
  String get tkFormAdd => 'Add Task';

  @override
  String get tkFormTitle => 'Task Title';

  @override
  String get tkFormAssigned => 'Assigned To';

  @override
  String get tkFormDue => 'Due Date';

  @override
  String get tkFormPriority => 'Priority';

  @override
  String get tkHigh => 'High';

  @override
  String get tkMedium => 'Medium';

  @override
  String get tkLow => 'Low';

  @override
  String get tkLoadingTeam => 'Loading team...';

  @override
  String get tkTeamFail => 'Could not load team';

  @override
  String get tkSelectAssignee => 'Select assignee';

  @override
  String get tkSaving => 'Saving...';

  @override
  String get tkSaveChanges => 'Save Changes';

  @override
  String get tkTitleRequired => 'Task title is required';

  @override
  String get tkUnassigned => 'Unassigned';

  @override
  String get tkNoDue => 'No due date';

  @override
  String get tkOverdue => 'Overdue';

  @override
  String get tkDueToday => 'Due today';

  @override
  String get tkMarkDone => 'Mark done';

  @override
  String get tkReopen => 'Reopen';

  @override
  String get cvInbox => 'Inbox';

  @override
  String get cvTitle => 'Conversations';

  @override
  String get cvEmptySub =>
      'Customer messages from connected channels will appear here.';

  @override
  String get cvThreadsOne => '1 active customer thread across every channel.';

  @override
  String cvThreadsMany(int count) {
    return '$count active customer threads across every channel.';
  }

  @override
  String get cvEmpty => 'No conversations yet';

  @override
  String get cvEmptyBody =>
      'Connect a messaging channel to bring customer conversations into one queue.';

  @override
  String cvUnread(int count) {
    return '$count unread messages';
  }

  @override
  String get cvLatest => 'Latest message';

  @override
  String get cvNoThread => 'Select a conversation';

  @override
  String get cvNoThreadBody =>
      'Pick a thread to read the latest message and customer details.';

  @override
  String get cvBack => 'Back';

  @override
  String get cvDossier => 'Customer dossier';

  @override
  String get cvStatus => 'Status';

  @override
  String get cvChannel => 'Channel';

  @override
  String get cvTime => 'Time';

  @override
  String get cvHistoryNote =>
      'Full message history lives in the connected channel — newest message shown here.';

  @override
  String get tmTitle => 'Leaderboard';

  @override
  String get tmSub => 'Ranked by revenue won this period.';

  @override
  String get tmLeads => 'Leads';

  @override
  String get tmWon => 'Won';

  @override
  String get tmWinRate => 'Win Rate';

  @override
  String get tmEmpty => 'No salespeople yet';

  @override
  String get tmEmptyBody => 'Team members appear here once added.';

  @override
  String get rpConversion => 'Conversion Trends';

  @override
  String get rpNoConversion => 'No conversion data yet';

  @override
  String get rpWon => 'Won';

  @override
  String get rpLost => 'Lost';

  @override
  String get rpActive => 'Active';

  @override
  String get rpSources => 'Lead Sources';

  @override
  String get rpNoSources => 'No source data yet';

  @override
  String get rpPerf => 'Salesperson Performance';

  @override
  String get rpNoPerf => 'No salesperson data yet';

  @override
  String get rpLeads => 'Leads';

  @override
  String get rpResponse => 'Response Time Analysis';

  @override
  String get rpNoResponse => 'No response time data yet';

  @override
  String get rpMetrics => 'Key Metrics';

  @override
  String get rpTotal => 'Total';

  @override
  String get itDataSources => 'Data sources';

  @override
  String get itTitle => 'Integrations';

  @override
  String get itSub =>
      'Connect a source to bring leads and customer messages into this workspace.';

  @override
  String itConnected(int done, int total) {
    return '$done of $total sources connected and available to sync.';
  }

  @override
  String get itSyncing => 'Syncing...';

  @override
  String get itSyncError => 'Sync error';

  @override
  String get itConnectedBadge => 'Connected';

  @override
  String get itNotConnected => 'Not connected';

  @override
  String get itLeads => 'leads';

  @override
  String get itConnectedTitle => 'Connected & syncing leads';

  @override
  String get itJustConnected => 'Connected';

  @override
  String get itLeadsFetched => 'Leads fetched';

  @override
  String get itLastSync => 'Last sync';

  @override
  String get itStatus => 'Status';

  @override
  String get itReady => 'Ready';

  @override
  String get itSyncNow => 'Sync Now';

  @override
  String get itDisconnect => 'Disconnect';

  @override
  String get itSyncFail => 'Sync failed. Check credentials.';

  @override
  String get itSyncDone => 'Sync completed - leads updated';

  @override
  String itDisconnected(String name) {
    return '$name disconnected';
  }

  @override
  String get seWorkspace => 'Workspace';

  @override
  String get seTitle => 'Settings';

  @override
  String get seSub =>
      'Control how your team receives work and how new leads enter the queue.';

  @override
  String get seWorkflow => 'Workflow';

  @override
  String get sePush => 'Push notifications';

  @override
  String get sePushBody =>
      'Alert me when a new lead or customer message arrives.';

  @override
  String get seAutoAssign => 'Automatically assign leads';

  @override
  String get seAutoAssignBody =>
      'Route incoming leads to available salespeople using the team queue.';

  @override
  String get seAppearance => 'Appearance';

  @override
  String get seDark => 'Dark appearance';

  @override
  String get seDarkBody =>
      'Use the darker workspace palette when your app theme supports it.';

  @override
  String get seLangNote =>
      'Appearance preferences are saved to this workspace profile.';

  @override
  String get csTitle => 'Connect a CRM';

  @override
  String get csSub => 'Choose a platform to automatically fetch leads';

  @override
  String get csMetaSub => 'Facebook & Instagram Lead Ads';

  @override
  String get csZohoSub => 'Zoho CRM Leads';

  @override
  String get csPageId => 'Page ID';

  @override
  String get csPageIdHint => 'e.g. 123456789012345';

  @override
  String get csToken => 'Access Token';

  @override
  String get csTokenHint => 'Long-lived page access token';

  @override
  String get csMetaHelp =>
      'Get these from developers.facebook.com > your app > Lead Ads > API setup';

  @override
  String get csClientId => 'Client ID';

  @override
  String get csClientIdHint => 'Zoho OAuth client ID';

  @override
  String get csSecret => 'Client Secret';

  @override
  String get csSecretHint => 'Zoho OAuth client secret';

  @override
  String get csRefresh => 'Refresh Token';

  @override
  String get csRefreshHint => 'Zoho OAuth refresh token';

  @override
  String get csZohoHelp =>
      'Create an app in Zoho API Console > Server-based client > CRM Leads scope';

  @override
  String get csConnecting => 'Connecting...';

  @override
  String csConnect(String platform) {
    return 'Connect $platform';
  }

  @override
  String get csNeedMeta => 'Enter both Page ID and Access Token';

  @override
  String get csNeedZoho => 'Enter Client ID, Client Secret and Refresh Token';

  @override
  String csDone(String platform) {
    return '$platform connected! Tap Sync Now to fetch leads';
  }

  @override
  String get csFail =>
      'Connection failed. Check your credentials and try again.';
}
