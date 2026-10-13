// Fixtures mirror the real owner dashboard data shapes:
// `OwnerKpi`, `JobCardRegisterItem`, `SalesTrendPoint` (dashboard_entities.dart)
// with category labels from the production register widget and quick-action
// labels from `quick_actions_row.dart`.
import 'package:flutter/material.dart';

/// one of: open / inProgress / waitingParts / qc / completed
class RegisterFixtureRow {
  final String labelKey;
  final String stateKey;
  final int open;
  final int total;
  final double amount;

  const RegisterFixtureRow({
    required this.labelKey,
    required this.stateKey,
    required this.open,
    required this.total,
    required this.amount,
  });
}

class KpiFixture {
  final IconData icon;
  final String labelKey;
  final String subKey;
  final String valueKey; // formatted numeric string, prefers moneyFree values
  final double? money;

  const KpiFixture({
    required this.icon,
    required this.labelKey,
    required this.subKey,
    this.valueKey = '',
    this.money,
  });
}

class ActionFixture {
  final IconData icon;
  final String labelKey;
  final String subKey;

  const ActionFixture({required this.icon, required this.labelKey, required this.subKey});
}

const List<KpiFixture> ownerKpiFixtures = [
  KpiFixture(
    icon: Icons.payments_rounded,
    labelKey: 'dashboard.kpi.revenue',
    subKey: 'dashboard.kpi.revenueSub',
    valueKey: '86450',
  ),
  KpiFixture(
    icon: Icons.directions_car_filled_rounded,
    labelKey: 'dashboard.kpi.cars',
    subKey: 'dashboard.kpi.carsSub',
    valueKey: '24',
  ),
  KpiFixture(
    icon: Icons.hourglass_top_rounded,
    labelKey: 'dashboard.kpi.approvals',
    subKey: 'dashboard.kpi.approvalsSub',
    valueKey: '7',
  ),
  KpiFixture(
    icon: Icons.task_alt_rounded,
    labelKey: 'dashboard.kpi.completed',
    subKey: 'dashboard.kpi.completedSub',
    valueKey: '11',
  ),
];

const List<RegisterFixtureRow> ownerRegisterFixtures = [
  RegisterFixtureRow(
    labelKey: 'jobs.status.pendingApproval',
    stateKey: 'dashboard.register.rowState.open',
    open: 14,
    total: 38,
    amount: 96200,
  ),
  RegisterFixtureRow(
    labelKey: 'jobs.status.inProgress',
    stateKey: 'dashboard.register.rowState.inProgress',
    open: 9,
    total: 24,
    amount: 141800,
  ),
  RegisterFixtureRow(
    labelKey: 'jobs.status.waitingParts',
    stateKey: 'dashboard.register.rowState.waitingParts',
    open: 5,
    total: 11,
    amount: 38400,
  ),
  RegisterFixtureRow(
    labelKey: 'jobs.status.qc',
    stateKey: 'dashboard.register.rowState.qc',
    open: 3,
    total: 7,
    amount: 12900,
  ),
  RegisterFixtureRow(
    labelKey: 'jobs.status.completed',
    stateKey: 'dashboard.register.rowState.completed',
    open: 11,
    total: 11,
    amount: 84300,
  ),
];

/// Six monthly trend points (Aug → Jan), values in AED.
const List<double> salesTrendFixture = [52000, 61500, 58000, 72400, 68900, 86450];
const List<double> profitTrendFixture = [14200, 17800, 16500, 21400, 19800, 26150];
const List<double> expensesTrendFixture = [31000, 33500, 30200, 36800, 34900, 38450];
const List<int> trendMonths = [8, 9, 10, 11, 12, 1];

/// Labels/subtitles come verbatim from the production quick-action grid.
const List<ActionFixture> ownerActionFixtures = [
  ActionFixture(
      icon: Icons.assignment_rounded,
      labelKey: 'dashboard.action.jobCards',
      subKey: 'dashboard.action.jobCardsSub'),
  ActionFixture(
      icon: Icons.inventory_2_rounded,
      labelKey: 'dashboard.action.inventory',
      subKey: 'dashboard.action.inventorySub'),
  ActionFixture(
      icon: Icons.receipt_long_rounded,
      labelKey: 'dashboard.action.receivables',
      subKey: 'dashboard.action.receivablesSub'),
  ActionFixture(
      icon: Icons.hourglass_top_rounded,
      labelKey: 'dashboard.action.approvals',
      subKey: 'dashboard.action.approvalsSub'),
  ActionFixture(
      icon: Icons.fact_check_rounded,
      labelKey: 'dashboard.action.jobStatus',
      subKey: 'dashboard.action.jobStatusSub'),
  ActionFixture(
      icon: Icons.event_note_rounded,
      labelKey: 'dashboard.action.compliance',
      subKey: 'dashboard.action.complianceSub'),
  ActionFixture(
      icon: Icons.rate_review_rounded,
      labelKey: 'dashboard.action.reviews',
      subKey: 'dashboard.action.reviewsSub'),
  ActionFixture(
      icon: Icons.badge_rounded,
      labelKey: 'dashboard.action.attendance',
      subKey: 'dashboard.action.attendanceSub'),
  ActionFixture(
      icon: Icons.groups_rounded,
      labelKey: 'dashboard.action.team',
      subKey: 'dashboard.action.teamSub'),
  ActionFixture(
      icon: Icons.leaderboard_rounded,
      labelKey: 'dashboard.action.topSales',
      subKey: 'dashboard.action.topSalesSub'),
  ActionFixture(
      icon: Icons.chat_bubble_rounded,
      labelKey: 'dashboard.action.messages',
      subKey: 'dashboard.action.messagesSub'),
  ActionFixture(
      icon: Icons.workspace_premium_rounded,
      labelKey: 'dashboard.action.subscription',
      subKey: 'dashboard.action.subscriptionSub'),
];

/// Fixed review date so rendered output is deterministic.
final DateTime dashboardFixtureDate = DateTime(2026, 10, 13);
