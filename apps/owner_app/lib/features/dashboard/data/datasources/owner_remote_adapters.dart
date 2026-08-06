import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_datasource.dart';
import 'package:owner_app/features/dashboard/domain/entities/accounts_receivable.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';

// ============ Abstract Interfaces ============
abstract class DocumentExpiryDatasource { Future<List<DocumentExpiry>> getDocuments(); }
abstract class JobStatusDatasource { Future<List<JobStatus>> getJobStatuses(); }
abstract class PendingApprovalsDatasource { Future<List<ApprovalCategory>> getCategories(); }
abstract class PendingJobCardsDatasource { Future<List<PendingJobCard>> getJobCards(); }
abstract class ActiveJobCardsDatasource { Future<List<ActiveJobCard>> getJobCards(); }
abstract class SalesInvoicesDatasource { Future<List<SalesInvoice>> getInvoices(); }
abstract class ARDatasource { Future<ARSummary> getSummary(); Future<List<ARRecord>> getRecords(); }
abstract class JobCardDatasource { Future<List<JobCard>> getJobCards(); Future<bool> updateJobCardStatus(String id, String status); }
abstract class DashboardDataSource {
  List<OwnerKpi> get kpis;
  List<JobCardRegisterItem> get registerItems;
  List<SalesTrendPoint> get salesTrend;
  List<SalesTrendPoint> get profitTrend;
  List<SalesTrendPoint> get expensesTrend;
  List<TopSalesCategory> get topSalesCategories;
}

// ============ DocumentExpiry ============
class DocumentExpiryRemoteDatasource implements DocumentExpiryDatasource {
  final OwnerRemoteDataSource _r;
  DocumentExpiryRemoteDatasource(this._r);
  @override Future<List<DocumentExpiry>> getDocuments() async {
    final items = await _r.getDocumentExpiry();
    return items.map((e) => DocumentExpiry(
      empId: e.empId, employeeName: e.employeeName, designation: e.designation,
      documentType: e.documentType, expiryDate: e.expiryDate,
      daysLeft: e.daysLeft, urgency: _parseUrgency(e.urgency),
    )).toList();
  }
  ExpiryUrgency _parseUrgency(String? u) => switch (u) { 'critical' => ExpiryUrgency.critical, 'urgent' => ExpiryUrgency.urgent, _ => ExpiryUrgency.warning };
}

// ============ JobStatus ============
class JobStatusRemoteDatasource implements JobStatusDatasource {
  final OwnerRemoteDataSource _r;
  JobStatusRemoteDatasource(this._r);
  @override Future<List<JobStatus>> getJobStatuses() async {
    final items = await _r.getJobsByStatus('');
    return items.map((e) => JobStatus(
      jobCardId: e.jobCardId, customerName: e.customerName, vehicleInfo: e.vehicleInfo,
      assignedTo: e.assignedTo, createdDate: e.createdDate, dueDate: e.dueDate,
      stage: _parseStage(e.stage), estimatedAmount: e.estimatedAmount,
    )).toList();
  }
  JobStage _parseStage(String? s) => JobStage.values.firstWhere((e) => e.name == s, orElse: () => JobStage.wip);
}

// ============ PendingApprovals ============
class PendingApprovalsRemoteDatasource implements PendingApprovalsDatasource {
  final OwnerRemoteDataSource _r;
  PendingApprovalsRemoteDatasource(this._r);
  @override Future<List<ApprovalCategory>> getCategories() async {
    final items = await _r.getApprovalCategories();
    final colors = [AppColors.blueBg, AppColors.amberBg, AppColors.greenBg, AppColors.greenBg, AppColors.greenBg, AppColors.greenBg, AppColors.redBg, AppColors.blueBg, AppColors.amberBg, AppColors.amberBg, AppColors.greenBg, AppColors.purpleLight, AppColors.blueBg];
    final icons = [Icons.shopping_cart_checkout, Icons.assignment, Icons.build_circle, Icons.check_circle, Icons.visibility, Icons.local_shipping, Icons.cancel, Icons.receipt_long, Icons.replay, Icons.outbound, Icons.account_balance_wallet, Icons.description, Icons.picture_as_pdf];
    return items.asMap().entries.map((e) => ApprovalCategory(
      title: e.value.title, subtitle: e.value.subtitle, count: e.value.count,
      iconBg: e.key < colors.length ? colors[e.key] : AppColors.blueBg,
      icon: e.key < icons.length ? icons[e.key] : Icons.approval,
    )).toList();
  }
}

// ============ PendingJobCards ============
class PendingJobCardsRemoteDatasource implements PendingJobCardsDatasource {
  final OwnerRemoteDataSource _r;
  PendingJobCardsRemoteDatasource(this._r);
  @override Future<List<PendingJobCard>> getJobCards() async {
    final items = await _r.getPendingJobs();
    return items.map((e) => PendingJobCard(
      jobCardId: e.jobCardId, customerName: e.customerName, vehicleInfo: e.vehicleInfo,
      assignedTo: e.assignedTo, createdDate: e.createdDate, dueDate: e.dueDate,
      daysOverdue: e.daysOverdue, estimatedAmount: e.estimatedAmount,
      status: _parsePendingStatus(e.status),
    )).toList();
  }
  PendingJobCardStatus _parsePendingStatus(String? s) => switch (s) { 'overdue' => PendingJobCardStatus.overdue, 'pending' => PendingJobCardStatus.pending, _ => PendingJobCardStatus.inProgress };
}

// ============ ActiveJobCards ============
class ActiveJobCardsRemoteDatasource implements ActiveJobCardsDatasource {
  final OwnerRemoteDataSource _r;
  ActiveJobCardsRemoteDatasource(this._r);
  @override Future<List<ActiveJobCard>> getJobCards() async {
    final items = await _r.getActiveJobs();
    return items.map((e) => ActiveJobCard(
      id: e.id, customerName: e.customerName, vehicleInfo: e.vehicle,
      services: e.services, technician: e.technician,
      estCompletion: e.estCompletion, amount: e.amount,
      status: _parseJobCardStatus(e.status),
    )).toList();
  }
  JobCardStatus _parseJobCardStatus(String? s) => JobCardStatus.values.firstWhere((e) => e.name == s, orElse: () => JobCardStatus.inProgress);
}

// ============ SalesInvoices ============
class SalesInvoicesRemoteDatasource implements SalesInvoicesDatasource {
  final OwnerRemoteDataSource _r;
  SalesInvoicesRemoteDatasource(this._r);
  @override Future<List<SalesInvoice>> getInvoices() async {
    final items = await _r.getInvoices(null);
    return items.map((e) => SalesInvoice(
      id: e.id, customerName: e.customerName, date: e.date,
      amount: e.amount, status: _parseInvoiceStatus(e.status),
    )).toList();
  }
  InvoiceStatus _parseInvoiceStatus(String? s) => switch (s) { 'paid' => InvoiceStatus.paid, 'unpaid' => InvoiceStatus.unpaid, _ => InvoiceStatus.overdue };
}

// ============ AR ============
class ARRemoteDatasource implements ARDatasource {
  final OwnerRemoteDataSource _r;
  ARRemoteDatasource(this._r);
  @override Future<ARSummary> getSummary() async {
    final s = await _r.getArSummary();
    return ARSummary(
      totalOutstanding: s.totalOutstanding.toDouble(), days0to30: s.days0to30.toDouble(),
      days31to60: s.days31to60.toDouble(), days61to90: s.days61to90.toDouble(), days90plus: s.days90plus.toDouble(),
    );
  }
  @override Future<List<ARRecord>> getRecords() async {
    final items = await _r.getArRecords();
    return items.map((e) => ARRecord(
      arId: e.arId, customer: e.customer, invoiceDate: e.invoiceDate,
      dueDate: e.dueDate, amount: e.amount, outstanding: e.outstanding,
      aging: _parseAging(e.aging), contactPerson: e.contactPerson, phone: e.phone,
    )).toList();
  }
  AgingBucket _parseAging(String? a) => switch (a) { 'days31to60' => AgingBucket.days31to60, 'days61to90' => AgingBucket.days61to90, 'days90plus' => AgingBucket.days90plus, _ => AgingBucket.days0to30 };
}

// ============ JobCard ============
class JobCardRemoteDatasource implements JobCardDatasource {
  final OwnerRemoteDataSource _r;
  JobCardRemoteDatasource(this._r);
  @override Future<List<JobCard>> getJobCards() async {
    final items = await _r.getOwnerJobCards();
    return items.map((e) => JobCard(
      id: e.id, customerName: e.customerName, vehicle: e.vehicle,
      plateNumber: e.plateNumber, services: _parseServices(e.services),
      technician: e.technician, estCompletion: e.estCompletion,
      amount: e.amount, status: _parseJobCardStatus(e.status),
    )).toList();
  }
  JobCardStatus _parseJobCardStatus(String? s) => JobCardStatus.values.firstWhere((e) => e.name == s, orElse: () => JobCardStatus.inProgress);
  List<String> _parseServices(String? s) => (s ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  // FE-FIX (audit P1): "Mark as Complete" was local-only — now persisted.
  @override
  Future<bool> updateJobCardStatus(String id, String status) =>
      _r.updateJobCardStatus(id, status);
}

// ============ DashboardUI ============
class DashboardUIRemoteAdapter implements DashboardDataSource {
  final OwnerRemoteDataSource _r;
  DashboardUIRemoteAdapter(this._r);

  List<OwnerKpi> _kpis = [];
  List<JobCardRegisterItem> _registerItems = [];
  List<SalesTrendPoint> _salesTrend = [];
  List<SalesTrendPoint> _profitTrend = [];
  List<SalesTrendPoint> _expensesTrend = [];
  List<TopSalesCategory> _topSalesCategories = [];

  @override List<OwnerKpi> get kpis => _kpis;
  @override List<JobCardRegisterItem> get registerItems => _registerItems;
  @override List<SalesTrendPoint> get salesTrend => _salesTrend;
  @override List<SalesTrendPoint> get profitTrend => _profitTrend;
  @override List<SalesTrendPoint> get expensesTrend => _expensesTrend;
  @override List<TopSalesCategory> get topSalesCategories => _topSalesCategories;

  Future<void> loadAll() async {
    final kpiIcons = [Icons.work_outline_rounded, Icons.add_circle_outline_rounded, Icons.cancel_outlined, Icons.receipt_long_rounded, Icons.trending_up_rounded, Icons.shopping_cart_outlined, Icons.account_balance_wallet_outlined, Icons.payments_outlined, Icons.bar_chart_rounded, Icons.attach_money_rounded, Icons.account_balance_outlined, Icons.inventory_2_outlined, Icons.star_outline_rounded, Icons.description_outlined, Icons.build_outlined, Icons.engineering_outlined];
    final kpiColors = [AppColors.accent, AppColors.success, AppColors.danger, AppColors.info, AppColors.accent, AppColors.warning, AppColors.success, AppColors.danger, AppColors.success, AppColors.accent, AppColors.info, AppColors.warning, AppColors.success, AppColors.accent, AppColors.warning, AppColors.info];

    final kpis = await _r.getKpis();
    _kpis = kpis.asMap().entries.map((e) => OwnerKpi(
      label: e.value.label, value: e.value.value,
      icon: kpiIcons[e.key < kpiIcons.length ? e.key : 0],
      color: kpiColors[e.key < kpiColors.length ? e.key : 0],
      sub: e.value.sub,
    )).toList();

    final results = await Future.wait([
      _r.getSalesTrend(), _r.getProfitTrend(), _r.getExpensesTrend(),
      _r.getJobCardRegister(), _r.getTopSales(),
    ]);

    _salesTrend = (results[0] as List).map((e) => SalesTrendPoint((e as TrendPointResponse).month, _v(e.value))).toList();
    _profitTrend = (results[1] as List).map((e) => SalesTrendPoint((e as TrendPointResponse).month, _v(e.value))).toList();
    _expensesTrend = (results[2] as List).map((e) => SalesTrendPoint((e as TrendPointResponse).month, _v(e.value))).toList();

    _registerItems = (results[3] as List).map((e) => JobCardRegisterItem(
      label: (e as JobCardRegisterResponse).label, open: e.open, completed: e.completed, total: e.total,
    )).toList();

    _topSalesCategories = (results[4] as List).asMap().entries.map((e) => TopSalesCategory(
      title: (e.value as TopSalesCategoryResponse).title,
      items: e.value.items.asMap().entries.map((i) => TopSalesItem(sno: i.value.sno, description: i.value.description, value: i.value.value)).toList(),
    )).toList();
  }

  double _v(int v) => v.toDouble();
}
