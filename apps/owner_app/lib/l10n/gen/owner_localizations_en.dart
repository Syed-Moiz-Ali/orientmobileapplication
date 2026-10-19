// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'owner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class OwnerLocalizationsEn extends OwnerLocalizations {
  OwnerLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Orient Owner';

  @override
  String get loginAppName => 'Orient Owner App';

  @override
  String get loginAppPurpose =>
      'Monitor branches, job cards, staff, revenue, approvals, inventory, and workshop performance.';

  @override
  String get loginIntendedUsers => 'For workshop owners and admins';

  @override
  String get authSecurityNotice =>
      'By signing in, you agree to the Orient Owner App Terms of Service and Privacy Policy.';

  @override
  String get ownerNavDashboard => 'Dashboard';

  @override
  String get ownerNavTopSales => 'Top sales';

  @override
  String get ownerNavMessages => 'Messages';

  @override
  String get ownerNavActivity => 'Activity';

  @override
  String get ownerShellWorkspace => 'Executive';

  @override
  String get ownerShellSuite => 'Owner suite';

  @override
  String get ownerBarDashboard => 'Owner dashboard';

  @override
  String get ownerBarTopSales => 'Top sales';

  @override
  String get ownerBarTopSalesSub => 'Performance breakdown by category';

  @override
  String get ownerBarMessages => 'Messages';

  @override
  String get ownerBarMessagesSub => 'Internal messaging';

  @override
  String get ownerBarActivity => 'Activity';

  @override
  String get ownerBarActivitySub => 'Workshop activity feed';

  @override
  String get ownerBarBack => 'Back to overview';

  @override
  String get ownerSearchHint => 'Search destinations…';

  @override
  String get ownerPeriodToday => 'Today';

  @override
  String get ownerPeriodWeek => 'This week';

  @override
  String get ownerPeriodMonth => 'This month';

  @override
  String get ownerPeriodYear => 'This year';

  @override
  String get ownerOpsTitle => 'Executive Operations Control';

  @override
  String get ownerOpsSubtitle =>
      'Real-time overview of branch performance, revenue, and active repair pipelines.';

  @override
  String get ownerPillLive => 'Live operations';

  @override
  String ownerPillActive(String value) {
    return '$value active';
  }

  @override
  String ownerPillToday(String value) {
    return '$value today';
  }

  @override
  String get ownerHeroEmpty => 'No figures yet.';

  @override
  String get ownerHeroEmptyHint => 'Pull to refresh when you are back online.';

  @override
  String get ownerChartSalesProfit => 'Sales & profit';

  @override
  String get ownerChartSales => 'Sales';

  @override
  String get ownerChartProfit => 'Profit';

  @override
  String get ownerChartCost => 'Profit & expenses';

  @override
  String get ownerChartExpenses => 'Expenses';

  @override
  String get ownerChartEmpty => 'No trend data yet.';

  @override
  String get ownerRegisterTitle => 'Job register';

  @override
  String get ownerRegisterAll => 'View all';

  @override
  String get ownerRegisterCategory => 'Category';

  @override
  String get ownerRegisterOpen => 'Open';

  @override
  String get ownerRegisterTotal => 'Total';

  @override
  String get ownerRegisterEmpty => 'No register rows.';

  @override
  String get ownerActionsTitle => 'Quick actions';

  @override
  String get ownerActionJobCards => 'Job cards';

  @override
  String get ownerActionJobCardsHint => 'Repair register';

  @override
  String get ownerActionInventory => 'Inventory';

  @override
  String get ownerActionInventoryHint => 'Spare parts & stock';

  @override
  String get ownerActionReceivables => 'Receivables';

  @override
  String get ownerActionReceivablesHint => 'Ageing & invoices';

  @override
  String get ownerActionApprovals => 'Approvals';

  @override
  String get ownerActionApprovalsHint => 'Estimates & discounts';

  @override
  String get ownerActionJobStatus => 'Job status';

  @override
  String get ownerActionJobStatusHint => 'Live repair pipeline';

  @override
  String get ownerActionCompliance => 'Compliance';

  @override
  String get ownerActionComplianceHint => 'Document expiry';

  @override
  String get ownerActionReviews => 'Reviews';

  @override
  String get ownerActionReviewsHint => 'Customer ratings';

  @override
  String get ownerActionAttendance => 'Attendance';

  @override
  String get ownerActionAttendanceHint => 'Shift register';

  @override
  String get ownerActionTeam => 'Team & roles';

  @override
  String get ownerActionTeamHint => 'Staff permissions';

  @override
  String get ownerActionTopSales => 'Top sales';

  @override
  String get ownerActionTopSalesHint => 'Category insights';

  @override
  String get ownerActionMessages => 'Messages';

  @override
  String get ownerActionMessagesHint => 'Internal chat';

  @override
  String get ownerActionSubscription => 'Subscription';

  @override
  String get ownerActionSubscriptionHint => 'Workshop plan';

  @override
  String get ownerSalesHeader => 'Top sales';

  @override
  String ownerSalesCount(int count) {
    return '$count categories';
  }

  @override
  String get ownerSalesEmpty => 'No sales data.';

  @override
  String get ownerSalesNo => 'No.';

  @override
  String get ownerSalesItem => 'Item';

  @override
  String get ownerSalesRevenue => 'Revenue';

  @override
  String ownerMsgSent(int count) {
    return '$count sent';
  }

  @override
  String get ownerMsgCompose => 'Broadcast message to team';

  @override
  String get ownerMsgRecipient => 'Recipient';

  @override
  String get ownerMsgRecipientHint => 'Choose a staff recipient…';

  @override
  String get ownerMsgBody => 'Message body';

  @override
  String get ownerMsgBodyHint =>
      'Type internal instructions or workshop notes here…';

  @override
  String get ownerMsgSend => 'Send message';

  @override
  String get ownerMsgSentToast => 'Message delivered to staff portal.';

  @override
  String get ownerMsgFailToast => 'Message failed. Check recipient selection.';

  @override
  String get ownerMsgHistory => 'Dispatch history';

  @override
  String get ownerMsgEmpty => 'No broadcasts yet.';

  @override
  String get ownerMsgEmptyHint => 'Messages to the team will appear here.';

  @override
  String get ownerMsgNoTeam => 'No active staff found.';

  @override
  String get ownerActEmpty => 'No activity yet';

  @override
  String get ownerActEmptyHint =>
      'Job cards, approvals and payments will show up here.';

  @override
  String get ownerActToday => 'Today';

  @override
  String get ownerActYesterday => 'Yesterday';

  @override
  String get ownerRegTitle => 'Job register';

  @override
  String get ownerRegSubtitle => 'All active workshop jobs';

  @override
  String get ownerRegSearchHint => 'Search job, plate, customer…';

  @override
  String get ownerRegIntake => 'Intake';

  @override
  String get ownerRegInspect => 'Inspection';

  @override
  String get ownerRegWip => 'WIP';

  @override
  String get ownerRegQc => 'QC';

  @override
  String get ownerRegReady => 'Ready';

  @override
  String get ownerRegInvoiced => 'Invoiced';

  @override
  String get ownerRegJob => 'Job';

  @override
  String get ownerRegPlate => 'Plate';

  @override
  String get ownerRegCustomer => 'Customer';

  @override
  String get ownerRegTotal => 'Total';

  @override
  String get ownerRegStatus => 'Status';

  @override
  String ownerRegCount(int count) {
    return '$count jobs';
  }

  @override
  String get ownerRegSelectPrompt => 'Select a job to preview.';

  @override
  String get ownerRegEmpty => 'No job cards found.';

  @override
  String get ownerRegNoMatch => 'No jobs match this search.';

  @override
  String get ownerRegOpen => 'Open register';

  @override
  String get ownerJsReceived => 'Intake';

  @override
  String get ownerJsInspected => 'Inspection';

  @override
  String get ownerJsPending => 'Pending';

  @override
  String get ownerJsPendingApproval => 'Pending approval';

  @override
  String get ownerJsAwaitSupervisor => 'Awaiting supervisor';

  @override
  String get ownerJsApproved => 'Approved';

  @override
  String get ownerJsAssigned => 'Assigned';

  @override
  String get ownerJsProgress => 'In progress';

  @override
  String get ownerJsParts => 'Waiting parts';

  @override
  String get ownerJsQc => 'Quality check';

  @override
  String get ownerJsQcPass => 'QC passed';

  @override
  String get ownerJsAwaitCustomer => 'Awaiting customer';

  @override
  String get ownerJsComplete => 'Completed';

  @override
  String get ownerJsDelivered => 'Delivered';

  @override
  String get ownerJsCancelled => 'Cancelled';

  @override
  String get ownerDetJobs => 'Jobs';

  @override
  String get ownerDetServices => 'Services';

  @override
  String get ownerDetNoServices => 'No services listed.';

  @override
  String get ownerDetAssign => 'Assignment';

  @override
  String get ownerDetTech => 'Specialist';

  @override
  String get ownerDetEta => 'Est. handover';

  @override
  String get ownerDetStage => 'Stage';

  @override
  String get ownerDetTotal => 'Total';

  @override
  String get ownerDetSplitNote =>
      'Parts/labor split unavailable for this record.';

  @override
  String get ownerDetStepIntake => 'Intake';

  @override
  String get ownerDetStepInspect => 'Inspection';

  @override
  String get ownerDetStepEstimate => 'Estimate';

  @override
  String get ownerDetStepRepair => 'Repair';

  @override
  String get ownerDetStepQc => 'QC';

  @override
  String get ownerDetStepReady => 'Ready';

  @override
  String get ownerDetComplete => 'Mark complete';

  @override
  String get ownerDetShare => 'Share';

  @override
  String get ownerDetConfirmTitle => 'Mark as complete?';

  @override
  String get ownerDetConfirmBody =>
      'The job card moves to Completed and syncs to the workshop register.';

  @override
  String get ownerDetDone => 'Job card marked as completed.';

  @override
  String get ownerDetFail => 'Could not complete the job card. Try again.';

  @override
  String get ownerDetEmpty => 'No job card selected.';

  @override
  String get ownerDetEmptyHint => 'Open a job from the register.';

  @override
  String get ownerDetCancel => 'Cancel';

  @override
  String get ownerStTitle => 'Live job pipeline';

  @override
  String get ownerStSubtitle => 'Stage monitor with auto-refresh';

  @override
  String get ownerStSearchHint => 'Search job, customer, vehicle…';

  @override
  String ownerStUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get ownerStStale => 'Data may be stale. Pull to refresh.';

  @override
  String get ownerStEmpty => 'No job cards in this stage.';

  @override
  String get ownerStPodQueue => 'Intake queue';

  @override
  String get ownerStPodActive => 'Active';

  @override
  String get ownerStPodDone => 'Done';

  @override
  String get ownerStPodAttention => 'Attention';

  @override
  String get ownerStgInspect => 'Inspection';

  @override
  String get ownerStgPreReq => 'Pre-request';

  @override
  String get ownerStgEstimate => 'Estimation';

  @override
  String get ownerStgApproval => 'Approval';

  @override
  String get ownerStgParts => 'Parts';

  @override
  String get ownerStgWip => 'WIP';

  @override
  String get ownerStgComplete => 'Completed';

  @override
  String get ownerStgCancel => 'Cancelled';

  @override
  String get ownerApTitle => 'Pending authorizations';

  @override
  String get ownerApSubtitle => 'Discounts, goodwill and overrides';

  @override
  String get ownerApAwaiting => 'Awaiting owner review';

  @override
  String ownerApCount(int count) {
    return '$count requests';
  }

  @override
  String get ownerApList => 'Review queue';

  @override
  String get ownerApEmpty => 'No pending approvals.';

  @override
  String get ownerApEmptyHint =>
      'Discount, goodwill and override requests will appear here.';

  @override
  String get ownerApNoAction =>
      'Approval actions are not available in this version.';
}
