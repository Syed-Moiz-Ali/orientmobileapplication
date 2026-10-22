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
  String get ownerHomeLoadError => 'Could not load the latest figures';

  @override
  String ownerHomeApprovalsBanner(String value) {
    return '$value waiting for owner review';
  }

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
  String get ownerRegisterEmptyHint =>
      'New jobs will appear here when they are booked.';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jobs',
      one: '1 job',
      zero: '0 jobs',
    );
    return '$_temp0';
  }

  @override
  String get ownerRegSelectPrompt => 'Select a job to preview.';

  @override
  String get ownerRegEmpty => 'No job cards found.';

  @override
  String get ownerRegNoMatch => 'No jobs match this search.';

  @override
  String get ownerRegOpen => 'Open job';

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

  @override
  String get ownerReqRequired => 'This field is required.';

  @override
  String get ownerReqEmail => 'Enter a valid email address.';

  @override
  String get ownerReqPhone => 'Enter a valid mobile number.';

  @override
  String get ownerReqPassword => 'Password must be at least 8 characters.';

  @override
  String get ownerReqMatch => 'Passwords do not match.';

  @override
  String get ownerArTitle => 'Receivables';

  @override
  String ownerArSubtitle(String amount) {
    return 'Outstanding $amount';
  }

  @override
  String get ownerArSearchHint => 'Search customer, invoice or AR ID…';

  @override
  String get ownerArCurrent => 'Current';

  @override
  String get ownerArOverdue => 'Overdue';

  @override
  String get ownerArCritical => 'Critical';

  @override
  String get ownerArAge030 => '0–30 days';

  @override
  String get ownerArAge3160 => '31–60 days';

  @override
  String get ownerArAge61 => '60+ days';

  @override
  String get ownerArRef => 'Ref';

  @override
  String get ownerArCustomer => 'Customer';

  @override
  String get ownerArAmount => 'Amount';

  @override
  String get ownerArAge => 'Age';

  @override
  String get ownerArAge030pill => '0–30';

  @override
  String get ownerArAge3160pill => '31–60';

  @override
  String get ownerArAge6190pill => '61–90';

  @override
  String get ownerArAge90pill => '90+';

  @override
  String get ownerArEmpty => 'No receivables found.';

  @override
  String get ownerArNoMatch => 'No debtors match this search.';

  @override
  String get ownerArContact => 'Billing contact';

  @override
  String ownerArCount(int count) {
    return '$count debtors';
  }

  @override
  String get ownerInTitle => 'Inventory';

  @override
  String get ownerInValuation => 'Stock valuation';

  @override
  String get ownerInAtCost => 'At cost';

  @override
  String ownerInLow(int count) {
    return '$count at or below reorder level';
  }

  @override
  String ownerInOut(int count) {
    return '$count out of stock';
  }

  @override
  String get ownerInStockOk => 'Stock levels healthy.';

  @override
  String get ownerInParts => 'Parts';

  @override
  String get ownerInSuppliers => 'Suppliers';

  @override
  String get ownerInOrders => 'Orders';

  @override
  String get ownerInSearchHint => 'Search parts by name, SKU or category…';

  @override
  String get ownerInFilter => 'Filter stock';

  @override
  String get ownerInCategory => 'Category';

  @override
  String get ownerInAvailability => 'Availability';

  @override
  String get ownerInAllStock => 'All stock';

  @override
  String get ownerInLowOnly => 'Low stock only';

  @override
  String get ownerInApply => 'Apply';

  @override
  String get ownerInClear => 'Clear';

  @override
  String get ownerInEmpty => 'No parts in stock.';

  @override
  String get ownerInNoMatch => 'No parts match this search.';

  @override
  String ownerInStockLeft(int count) {
    return '$count left';
  }

  @override
  String get ownerInAdd => 'Add part';

  @override
  String get ownerInAddTitle => 'Add inventory part';

  @override
  String get ownerInName => 'Part / item name';

  @override
  String get ownerInSku => 'SKU / part number';

  @override
  String get ownerInPrice => 'Price (AED)';

  @override
  String get ownerInQty => 'Initial qty';

  @override
  String get ownerInQtyCol => 'Qty';

  @override
  String get ownerInReorder => 'Reorder alert level';

  @override
  String get ownerInSubmit => 'Add to warehouse';

  @override
  String get ownerInAdded => 'Part added to warehouse.';

  @override
  String get ownerInAddFail => 'Could not add item.';

  @override
  String get ownerInAdjustFail => 'Could not adjust stock.';

  @override
  String get ownerInNoSuppliers => 'No suppliers recorded.';

  @override
  String get ownerInNoOrders => 'No purchase orders placed.';

  @override
  String get ownerInNoPhone => 'No contact phone.';

  @override
  String get ownerTmTitle => 'Team';

  @override
  String ownerTmSubtitle(int active, int total) {
    return '$active of $total active';
  }

  @override
  String get ownerTmDirectory => 'Staff directory';

  @override
  String get ownerTmSearchHint => 'Search name, ID, phone, role or branch…';

  @override
  String get ownerTmAdvisors => 'Advisors';

  @override
  String get ownerTmSupervisors => 'Supervisors';

  @override
  String get ownerTmTechnicians => 'Technicians';

  @override
  String get ownerTmEmpty => 'No staff match this filter.';

  @override
  String get ownerTmActive => 'Active';

  @override
  String get ownerTmOff => 'Off';

  @override
  String get ownerTmOnShift => 'On shift';

  @override
  String get ownerTmOffShift => 'Off shift';

  @override
  String get ownerTmAdd => 'Add member';

  @override
  String get ownerTmAddTitle => 'Create staff login';

  @override
  String get ownerTmAddSubtitle =>
      'Create their Staff app access and workshop details.';

  @override
  String get ownerTmName => 'Full name';

  @override
  String get ownerTmEmpId => 'Staff ID (e.g. ADV002)';

  @override
  String get ownerTmRole => 'Staff app role';

  @override
  String get ownerTmLogin => 'Login credentials';

  @override
  String get ownerTmPhone => 'Mobile number with country code';

  @override
  String get ownerTmEmail => 'Email address';

  @override
  String get ownerTmPassword => 'Initial password (minimum 8 characters)';

  @override
  String get ownerTmPassword2 => 'Confirm initial password';

  @override
  String get ownerTmOtpNote =>
      'They can sign in with email or mobile + password, or use an OTP.';

  @override
  String get ownerTmWork => 'Work details';

  @override
  String get ownerTmDesignation => 'Designation';

  @override
  String get ownerTmDepartment => 'Department';

  @override
  String get ownerTmBranch => 'Branch';

  @override
  String get ownerTmBranchHint => 'Select a branch';

  @override
  String get ownerTmNoBranches => 'No branches configured.';

  @override
  String get ownerTmShift => 'Shift';

  @override
  String get ownerTmSubmit => 'Create staff account';

  @override
  String get ownerTmCreated => 'Staff login created.';

  @override
  String get ownerTmCreatedBody =>
      'Share the initial password securely and ask them to change it after signing in.';

  @override
  String get ownerTmDone => 'Done';

  @override
  String get ownerAtTitle => 'Attendance';

  @override
  String get ownerAtSubtitle => 'Daily clock register';

  @override
  String get ownerAtTotal => 'Total staff';

  @override
  String get ownerAtPresent => 'Present';

  @override
  String get ownerAtDone => 'Completed';

  @override
  String get ownerAtAbsent => 'Absent';

  @override
  String get ownerAtAllRoles => 'All roles';

  @override
  String get ownerAtEmpty => 'No attendance records.';

  @override
  String get ownerAtIn => 'Clock in';

  @override
  String get ownerAtOut => 'Clock out';

  @override
  String get ownerAtHours => 'Hours';

  @override
  String get ownerAtWorking => 'Working';

  @override
  String get ownerAtBreak => 'On break';

  @override
  String get ownerAtComplete => 'Completed';

  @override
  String get ownerAtIdle => 'Not punched in';

  @override
  String get ownerExTitle => 'Compliance';

  @override
  String get ownerExSubtitle => 'Licenses, permits and visas';

  @override
  String get ownerExSearchHint => 'Search employee, role or document…';

  @override
  String get ownerExCritical => 'Critical';

  @override
  String get ownerExUrgent => 'Urgent';

  @override
  String get ownerExWatch => 'Watch';

  @override
  String ownerExDaysLeft(int days) {
    return '${days}d left';
  }

  @override
  String ownerExOverdue(int days) {
    return '${days}d overdue';
  }

  @override
  String get ownerExEmpty => 'No documents found.';

  @override
  String ownerExAlerts(int count) {
    return '$count alerts';
  }

  @override
  String get ownerFbTitle => 'Reviews';

  @override
  String get ownerFbSubtitle => 'Customer ratings inbox';

  @override
  String get ownerFbEmpty => 'No reviews awaiting moderation.';

  @override
  String get ownerFbVerified => 'Verified customer';

  @override
  String get ownerFbApprove => 'Approve';

  @override
  String get ownerFbReject => 'Reject';

  @override
  String get ownerFbDone => 'Review moderated.';

  @override
  String get ownerFbFail => 'Moderation failed. Try again.';

  @override
  String get ownerFbNoRespond => 'Replies are not available in this version.';

  @override
  String get ownerSbTitle => 'Subscription';

  @override
  String get ownerSbCurrent => 'Current tier';

  @override
  String ownerSbRenews(String date) {
    return 'Renews $date';
  }

  @override
  String get ownerSbPlans => 'Workshop plans';

  @override
  String get ownerSbSelect => 'Select';

  @override
  String get ownerSbCurrentPlan => 'Current';

  @override
  String get ownerSbChanged => 'Plan updated.';

  @override
  String get ownerSbChangeFail => 'Could not update plan.';

  @override
  String get ownerSbStarter => 'Starter';

  @override
  String get ownerSbStarterHint => 'Single-branch workshops';

  @override
  String get ownerSbPro => 'Professional';

  @override
  String get ownerSbProHint => 'Multi-branch + CRM + inventory';

  @override
  String get ownerSbEnterprise => 'Enterprise';

  @override
  String get ownerSbEnterpriseHint => 'SSO, SLAs, dedicated manager';

  @override
  String get ownerSbStarterPrice => 'AED 499 / mo';

  @override
  String get ownerSbProPrice => 'AED 1,299 / mo';

  @override
  String get ownerSbEnterprisePrice => 'AED 2,499 / mo';
}
