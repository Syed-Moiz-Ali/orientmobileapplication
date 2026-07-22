import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'supervisor_entities.freezed.dart';

// ── KPI Stats ──
@freezed
class SupervisorKpiEntity with _$SupervisorKpiEntity {
  const factory SupervisorKpiEntity({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    required String sub,
  }) = _SupervisorKpiEntity;
}

// ── Advisor Bar Data ──
@freezed
class AdvisorJobEntity with _$AdvisorJobEntity {
  const factory AdvisorJobEntity({
    required String name,
    required double count,
  }) = _AdvisorJobEntity;
}

// ── Job Type ──
@freezed
class JobTypeEntity with _$JobTypeEntity {
  const factory JobTypeEntity({
    required String label,
    required int count,
    required Color color,
  }) = _JobTypeEntity;
}

// ── Revenue Metric ──
@freezed
class RevenueMetricEntity with _$RevenueMetricEntity {
  const factory RevenueMetricEntity({
    required IconData icon,
    required String amount,
    required String label,
    required String change,
  }) = _RevenueMetricEntity;
}

// ── Pending Status ──
@freezed
class PendingStatusEntity with _$PendingStatusEntity {
  const factory PendingStatusEntity({
    required IconData icon,
    required Color color,
    required String count,
    required String label,
  }) = _PendingStatusEntity;
}

// ── Work Assignment ──
@freezed
class WorkAssignmentEntity with _$WorkAssignmentEntity {
  const factory WorkAssignmentEntity({
    required int id,
    @Default('') String description,
    @Default('') String department,
    @Default('') String technicianName,
    @Default('') String dateOfWork,
    @Default(0) int statusPercent,
    @Default('') String stdTime,
    @Default('') String remarks,
  }) = _WorkAssignmentEntity;

  factory WorkAssignmentEntity.fromMap(Map<String, dynamic> map) =>
      WorkAssignmentEntity(
        id: map['id'] as int? ?? 0,
        description: map['description'] as String? ?? '',
        department: map['department'] as String? ?? '',
        technicianName: map['technicianName'] as String? ?? '',
        dateOfWork: map['dateOfWork'] as String? ?? '',
        statusPercent: map['statusPercent'] as int? ?? 0,
        stdTime: map['stdTime'] as String? ?? '',
        remarks: map['remarks'] as String? ?? '',
      );
}

// ── Assigned Job ──
@freezed
class AssignedJobEntity with _$AssignedJobEntity {
  const factory AssignedJobEntity({
    required String jobCard,
    required String customer,
    required String vehicle,
    required String dateAssigned,
    required int done,
    required int total,
    required String status,
  }) = _AssignedJobEntity;
}
