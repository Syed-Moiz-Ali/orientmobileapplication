import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';

abstract class DocumentExpiryDatasource {
  Future<List<DocumentExpiry>> getDocuments();
}

class MockDocumentExpiryDatasource implements DocumentExpiryDatasource {
  @override
  Future<List<DocumentExpiry>> getDocuments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const DocumentExpiry(empId: 'EMP-001', employeeName: 'Ahmed Al Mansouri', designation: 'Senior Technician', documentType: 'Trade License', expiryDate: '2024-12-31', daysLeft: 15, urgency: ExpiryUrgency.critical),
      const DocumentExpiry(empId: 'EMP-002', employeeName: 'Fatima Hassan', designation: 'Service Advisor', documentType: 'Visa', expiryDate: '2025-02-28', daysLeft: 45, urgency: ExpiryUrgency.urgent),
      const DocumentExpiry(empId: 'EMP-003', employeeName: 'Mohammed Ali', designation: 'Technician', documentType: 'Passport', expiryDate: '2025-04-15', daysLeft: 90, urgency: ExpiryUrgency.warning),
      const DocumentExpiry(empId: 'EMP-004', employeeName: 'Sara Khalid', designation: 'Cashier', documentType: 'ID Card', expiryDate: '2024-11-30', daysLeft: -5, urgency: ExpiryUrgency.critical),
      const DocumentExpiry(empId: 'EMP-005', employeeName: 'Omar Rashid', designation: 'Store Keeper', documentType: 'Driving License', expiryDate: '2025-06-01', daysLeft: 150, urgency: ExpiryUrgency.warning),
    ];
  }
}

abstract class JobStatusDatasource {
  Future<List<JobStatus>> getJobStatuses();
}

class MockJobStatusDatasource implements JobStatusDatasource {
  @override
  Future<List<JobStatus>> getJobStatuses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const JobStatus(jobCardId: 'JC-2024-0042', customerName: 'Al Fahim Motors', vehicleInfo: 'Toyota Land Cruiser 2024', assignedTo: 'Ahmed', createdDate: '2024-12-01', dueDate: '2024-12-08', stage: JobStage.waitingParts, estimatedAmount: 15000),
      const JobStatus(jobCardId: 'JC-2024-0041', customerName: 'Dubai Fleet Services', vehicleInfo: 'Nissan Patrol 2023', assignedTo: 'Khalid', createdDate: '2024-11-28', dueDate: '2024-12-05', stage: JobStage.wip, estimatedAmount: 8500),
      const JobStatus(jobCardId: 'JC-2024-0040', customerName: 'Emirates Transport', vehicleInfo: 'Mitsubishi Pajero 2022', assignedTo: 'Rashid', createdDate: '2024-11-25', dueDate: '2024-12-02', stage: JobStage.waitingEstimation, estimatedAmount: 22000),
      const JobStatus(jobCardId: 'JC-2024-0039', customerName: 'Sharjah Police HQ', vehicleInfo: 'Ford Explorer 2024', assignedTo: 'Saeed', createdDate: '2024-11-20', dueDate: '2024-11-27', stage: JobStage.completed, estimatedAmount: 32000),
      const JobStatus(jobCardId: 'JC-2024-0038', customerName: 'Abu Dhabi Motors', vehicleInfo: 'Mercedes GLE 2024', assignedTo: 'Ahmed', createdDate: '2024-11-15', dueDate: '2024-11-22', stage: JobStage.waitingApproval, estimatedAmount: 45000),
    ];
  }
}

abstract class PendingApprovalsDatasource {
  Future<List<ApprovalCategory>> getCategories();
}

class MockPendingApprovalsDatasource implements PendingApprovalsDatasource {
  @override
  Future<List<ApprovalCategory>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ApprovalCategory(title: 'Purchase Order', subtitle: 'Pending purchase order approvals', count: 12, iconBg: AppColors.blueBg, icon: Icons.shopping_cart_checkout),
      ApprovalCategory(title: 'Open Job Card', subtitle: 'Job cards pending assignment', count: 8, iconBg: AppColors.amberBg, icon: Icons.assignment),
      ApprovalCategory(title: 'Work In Progress', subtitle: 'Jobs waiting for next stage', count: 15, iconBg: AppColors.greenBg, icon: Icons.build_circle),
      ApprovalCategory(title: 'Job Completed', subtitle: 'Completed jobs pending invoice', count: 6, iconBg: AppColors.greenBg, icon: Icons.check_circle),
      ApprovalCategory(title: 'Job Completed', subtitle: 'Awaiting customer inspection', count: 3, iconBg: AppColors.greenBg, icon: Icons.visibility),
      ApprovalCategory(title: 'Job Completed', subtitle: 'Pending delivery to customer', count: 4, iconBg: AppColors.greenBg, icon: Icons.local_shipping),
      ApprovalCategory(title: 'Job Cancelled', subtitle: 'Cancelled jobs pending review', count: 2, iconBg: AppColors.redBg, icon: Icons.cancel),
      ApprovalCategory(title: 'Invoice Raised', subtitle: 'Invoices pending approval', count: 10, iconBg: AppColors.blueBg, icon: Icons.receipt_long),
      ApprovalCategory(title: 'Sales Return', subtitle: 'Return requests pending', count: 5, iconBg: AppColors.amberBg, icon: Icons.replay),
      ApprovalCategory(title: 'Purchase Return', subtitle: 'Supplier return requests', count: 3, iconBg: AppColors.amberBg, icon: Icons.outbound),
      ApprovalCategory(title: 'Petty Cash', subtitle: 'Cash expense approvals', count: 7, iconBg: AppColors.greenBg, icon: Icons.account_balance_wallet),
      ApprovalCategory(title: 'Journal Voucher', subtitle: 'Accounting entries pending', count: 4, iconBg: AppColors.purpleLight, icon: Icons.description),
      ApprovalCategory(title: 'Job Card to Invoice', subtitle: 'Ready for invoicing', count: 9, iconBg: AppColors.blueBg, icon: Icons.picture_as_pdf),
    ];
  }
}

abstract class PendingJobCardsDatasource {
  Future<List<PendingJobCard>> getJobCards();
}

class MockPendingJobCardsDatasource implements PendingJobCardsDatasource {
  @override
  Future<List<PendingJobCard>> getJobCards() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const PendingJobCard(jobCardId: 'JC-2024-0042', customerName: 'Al Fahim Motors', vehicleInfo: 'Toyota Land Cruiser 2024', assignedTo: 'Ahmed Technician', createdDate: '2024-12-01', dueDate: '2024-12-08', daysOverdue: 5, status: PendingJobCardStatus.overdue, estimatedAmount: 15000),
      const PendingJobCard(jobCardId: 'JC-2024-0041', customerName: 'Dubai Fleet Services', vehicleInfo: 'Nissan Patrol 2023', assignedTo: 'Khalid Technician', createdDate: '2024-11-28', dueDate: '2024-12-05', daysOverdue: -3, status: PendingJobCardStatus.inProgress, estimatedAmount: 8500),
      const PendingJobCard(jobCardId: 'JC-2024-0040', customerName: 'Emirates Transport', vehicleInfo: 'Mitsubishi Pajero 2022', assignedTo: 'Rashid M.', createdDate: '2024-11-25', dueDate: '2024-12-02', daysOverdue: 2, status: PendingJobCardStatus.pending, estimatedAmount: 22000),
      const PendingJobCard(jobCardId: 'JC-2024-0039', customerName: 'Sharjah Police HQ', vehicleInfo: 'Ford Explorer 2024', assignedTo: 'Saeed A.', createdDate: '2024-11-20', dueDate: '2024-11-27', daysOverdue: -5, status: PendingJobCardStatus.inProgress, estimatedAmount: 32000),
      const PendingJobCard(jobCardId: 'JC-2024-0038', customerName: 'Abu Dhabi Motors', vehicleInfo: 'Mercedes GLE 2024', assignedTo: 'Ahmed R.', createdDate: '2024-11-15', dueDate: '2024-11-22', daysOverdue: 12, status: PendingJobCardStatus.overdue, estimatedAmount: 45000),
    ];
  }
}

abstract class ActiveJobCardsDatasource {
  Future<List<ActiveJobCard>> getJobCards();
}

class MockActiveJobCardsDatasource implements ActiveJobCardsDatasource {
  @override
  Future<List<ActiveJobCard>> getJobCards() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const ActiveJobCard(id: 'JC-2024-0042', customerName: 'Al Fahim Motors', vehicleInfo: 'Toyota Land Cruiser 2024', services: 'Full Engine Overhaul, Transmission Service, AC Repair', technician: 'Ahmed Hassan', estCompletion: '2024-12-08', amount: 15000, status: JobCardStatus.inProgress),
      const ActiveJobCard(id: 'JC-2024-0041', customerName: 'Dubai Fleet Services', vehicleInfo: 'Nissan Patrol 2023', services: 'Brake Pad Replacement, Oil Change', technician: 'Khalid Mohammed', estCompletion: '2024-12-05', amount: 8500, status: JobCardStatus.waitingParts),
      const ActiveJobCard(id: 'JC-2024-0040', customerName: 'Emirates Transport', vehicleInfo: 'Mitsubishi Pajero 2022', services: 'Suspension Overhaul, Wheel Alignment', technician: 'Rashid Ahmed', estCompletion: '2024-12-02', amount: 22000, status: JobCardStatus.qualityCheck),
      const ActiveJobCard(id: 'JC-2024-0039', customerName: 'Sharjah Police HQ', vehicleInfo: 'Ford Explorer 2024', services: 'AC Repair, Electrical Diagnosis', technician: 'Saeed Ali', estCompletion: '2024-11-27', amount: 32000, status: JobCardStatus.completed),
      const ActiveJobCard(id: 'JC-2024-0038', customerName: 'Abu Dhabi Motors', vehicleInfo: 'Mercedes GLE 2024', services: 'Full Service, Diagnostic Scan', technician: 'Omar Hassan', estCompletion: '2024-12-15', amount: 45000, status: JobCardStatus.inProgress),
    ];
  }
}

abstract class SalesInvoicesDatasource {
  Future<List<SalesInvoice>> getInvoices();
}

class MockSalesInvoicesDatasource implements SalesInvoicesDatasource {
  @override
  Future<List<SalesInvoice>> getInvoices() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const SalesInvoice(id: 'INV-2024-0101', customerName: 'Al Fahim Motors', date: '2024-11-01', amount: 125000, status: InvoiceStatus.paid),
      const SalesInvoice(id: 'INV-2024-0102', customerName: 'Emirates Trading', date: '2024-11-05', amount: 65000, status: InvoiceStatus.unpaid),
      const SalesInvoice(id: 'INV-2024-0103', customerName: 'Dubai Fleet Services', date: '2024-11-10', amount: 210000, status: InvoiceStatus.paid),
      const SalesInvoice(id: 'INV-2024-0104', customerName: 'Abu Dhabi Transport', date: '2024-11-15', amount: 156000, status: InvoiceStatus.overdue),
      const SalesInvoice(id: 'INV-2024-0105', customerName: 'Sharjah Auto Group', date: '2024-11-20', amount: 95000, status: InvoiceStatus.unpaid),
    ];
  }
}
