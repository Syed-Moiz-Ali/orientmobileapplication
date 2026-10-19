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
}
