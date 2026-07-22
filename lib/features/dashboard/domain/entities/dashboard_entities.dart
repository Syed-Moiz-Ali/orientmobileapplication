import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'dashboard_entities.freezed.dart';

// ── Enums ──

enum ExpiryUrgency { critical, urgent, warning }

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

enum PendingJobCardStatus { overdue, pending, inProgress }

enum ActiveJobStatus { inProgress, waitingParts, qualityCheck, completed }

enum InvoiceStatus { paid, unpaid, overdue }

// ── Entities ──

@freezed
class DocumentExpiry with _$DocumentExpiry {
  const factory DocumentExpiry({
    required String empId,
    required String employeeName,
    required String designation,
    required String documentType,
    required String expiryDate,
    required int daysLeft,
    required ExpiryUrgency urgency,
  }) = _DocumentExpiry;
}

@freezed
class JobStatus with _$JobStatus {
  const factory JobStatus({
    required String jobCardId,
    required String customerName,
    required String vehicleInfo,
    required String assignedTo,
    required String createdDate,
    required String dueDate,
    required JobStage stage,
    required double estimatedAmount,
  }) = _JobStatus;
}

@freezed
class ApprovalCategory with _$ApprovalCategory {
  const factory ApprovalCategory({
    required String title,
    required String subtitle,
    required int count,
    required Color iconBg,
    required IconData icon,
  }) = _ApprovalCategory;
}

@freezed
class PendingJobCard with _$PendingJobCard {
  const factory PendingJobCard({
    required String jobCardId,
    required String customerName,
    required String vehicleInfo,
    required String assignedTo,
    required String createdDate,
    required String dueDate,
    required int daysOverdue,
    required PendingJobCardStatus status,
    required double estimatedAmount,
  }) = _PendingJobCard;
}

@freezed
class ActiveJobCard with _$ActiveJobCard {
  const factory ActiveJobCard({
    required String id,
    required String customerName,
    required String vehicleInfo,
    required String services,
    required String technician,
    required String estCompletion,
    required double amount,
    required ActiveJobStatus status,
  }) = _ActiveJobCard;
}

@freezed
class SalesInvoice with _$SalesInvoice {
  const factory SalesInvoice({
    required String id,
    required String customerName,
    required String date,
    required double amount,
    required InvoiceStatus status,
  }) = _SalesInvoice;
}

@freezed
class OwnerKpi with _$OwnerKpi {
  const factory OwnerKpi({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String sub,
  }) = _OwnerKpi;
}

@freezed
class SalesTrendPoint with _$SalesTrendPoint {
  const factory SalesTrendPoint(String month, double value) = _SalesTrendPoint;
}

@freezed
class TopSalesCategory with _$TopSalesCategory {
  const factory TopSalesCategory({
    required String title,
    required List<TopSalesItem> items,
  }) = _TopSalesCategory;
}

@freezed
class TopSalesItem with _$TopSalesItem {
  const factory TopSalesItem({
    required int sno,
    required String description,
    required String value,
  }) = _TopSalesItem;
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String recipient,
    required String message,
    required String time,
  }) = _Message;
}

@freezed
class JobCardRegisterItem with _$JobCardRegisterItem {
  const factory JobCardRegisterItem({
    required String label,
    required int open,
    required int completed,
    required int total,
  }) = _JobCardRegisterItem;
}
