import 'package:flutter/material.dart';

// ── Document Expiry ──
enum ExpiryUrgency { critical, urgent, warning }

class DocumentExpiry {
  final String empId;
  final String employeeName;
  final String designation;
  final String documentType;
  final String expiryDate;
  final int daysLeft;
  final ExpiryUrgency urgency;

  const DocumentExpiry({
    required this.empId,
    required this.employeeName,
    required this.designation,
    required this.documentType,
    required this.expiryDate,
    required this.daysLeft,
    required this.urgency,
  });
}

// ── Job Status ──
enum JobStage {
  waitingInspection,
  waitingPreRequest,
  waitingEstimation,
  waitingApproval,
  waitingParts,
  wip,
  completed,
  invoice,
  gatePassOut,
  cancelled
}

class JobStatus {
  final String jobCardId;
  final String customerName;
  final String vehicleInfo;
  final String assignedTo;
  final String createdDate;
  final String dueDate;
  final JobStage stage;
  final double estimatedAmount;

  const JobStatus({
    required this.jobCardId,
    required this.customerName,
    required this.vehicleInfo,
    required this.assignedTo,
    required this.createdDate,
    required this.dueDate,
    required this.stage,
    required this.estimatedAmount,
  });
}

// ── Pending Approvals ──

class ApprovalCategory {
  final String title;
  final String subtitle;
  final int count;
  final Color iconBg;
  final IconData icon;

  const ApprovalCategory({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.iconBg,
    required this.icon,
  });
}

// ── Pending Job Cards ──
enum JobCardStatus { overdue, pending, inProgress }

class PendingJobCard {
  final String jobCardId;
  final String customerName;
  final String vehicleInfo;
  final String assignedTo;
  final String createdDate;
  final String dueDate;
  final int daysOverdue;
  final JobCardStatus status;
  final double estimatedAmount;

  const PendingJobCard({
    required this.jobCardId,
    required this.customerName,
    required this.vehicleInfo,
    required this.assignedTo,
    required this.createdDate,
    required this.dueDate,
    required this.daysOverdue,
    required this.status,
    required this.estimatedAmount,
  });
}

// ── Active Job Cards ──
enum ActiveJobStatus { inProgress, waitingParts, qualityCheck, completed }

class ActiveJobCard {
  final String id;
  final String customerName;
  final String vehicleInfo;
  final String services;
  final String technician;
  final String estCompletion;
  final double amount;
  final ActiveJobStatus status;

  const ActiveJobCard({
    required this.id,
    required this.customerName,
    required this.vehicleInfo,
    required this.services,
    required this.technician,
    required this.estCompletion,
    required this.amount,
    required this.status,
  });
}

// ── Sales Invoices ──
enum InvoiceStatus { paid, unpaid, overdue }

class SalesInvoice {
  final String id;
  final String customerName;
  final String date;
  final double amount;
  final InvoiceStatus status;

  const SalesInvoice({
    required this.id,
    required this.customerName,
    required this.date,
    required this.amount,
    required this.status,
  });
}

// ── Dashboard KPI ──
class OwnerKpi {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String sub;

  const OwnerKpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.sub,
  });
}

// ── Sales Trend ──
class SalesTrendPoint {
  final String month;
  final double value;
  const SalesTrendPoint(this.month, this.value);
}

// ── Top Sales ──
class TopSalesCategory {
  final String title;
  final List<TopSalesItem> items;

  const TopSalesCategory({
    required this.title,
    required this.items,
  });
}

class TopSalesItem {
  final int sno;
  final String description;
  final String value;

  const TopSalesItem({
    required this.sno,
    required this.description,
    required this.value,
  });
}

// ── Message ──
class Message {
  final String id;
  final String recipient;
  final String message;
  final String time;

  const Message({
    required this.id,
    required this.recipient,
    required this.message,
    required this.time,
  });
}

// ── Job Card Register ──
class JobCardRegisterItem {
  final String label;
  final int open;
  final int completed;
  final int total;

  const JobCardRegisterItem({
    required this.label,
    required this.open,
    required this.completed,
    required this.total,
  });
}
