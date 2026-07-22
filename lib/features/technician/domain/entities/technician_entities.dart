import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/features/technician/domain/entities/work_task_entity.dart';
export 'package:orientmobileapplication/features/technician/domain/entities/work_task_entity.dart';

part 'technician_entities.freezed.dart';
part 'technician_entities.g.dart';

// ── Enums ──

enum AttendanceStatus { notPunchedIn, working, onBreak, punchedOut }

extension AttendanceStatusX on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.notPunchedIn:
        return 'Not Punched In';
      case AttendanceStatus.working:
        return 'Working';
      case AttendanceStatus.onBreak:
        return 'On Break';
      case AttendanceStatus.punchedOut:
        return 'Punched Out';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.notPunchedIn:
        return AppColors.text3;
      case AttendanceStatus.working:
        return AppColors.success;
      case AttendanceStatus.onBreak:
        return AppColors.warning;
      case AttendanceStatus.punchedOut:
        return AppColors.danger;
    }
  }

  Color get bgColor {
    switch (this) {
      case AttendanceStatus.notPunchedIn:
        return AppColors.surfaceAlt;
      case AttendanceStatus.working:
        return AppColors.successBg;
      case AttendanceStatus.onBreak:
        return AppColors.warningBg;
      case AttendanceStatus.punchedOut:
        return AppColors.dangerBg;
    }
  }
}

enum AssignedJobStatus { inProgress, pending, waitingParts, completed }

extension AssignedJobStatusX on AssignedJobStatus {
  String get label {
    switch (this) {
      case AssignedJobStatus.inProgress:
        return 'In Progress';
      case AssignedJobStatus.pending:
        return 'Pending';
      case AssignedJobStatus.waitingParts:
        return 'Waiting Parts';
      case AssignedJobStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case AssignedJobStatus.inProgress:
        return AppColors.primary;
      case AssignedJobStatus.pending:
        return AppColors.text3;
      case AssignedJobStatus.waitingParts:
        return AppColors.warning;
      case AssignedJobStatus.completed:
        return AppColors.success;
    }
  }

  Color get bgColor {
    switch (this) {
      case AssignedJobStatus.inProgress:
        return AppColors.primaryBg;
      case AssignedJobStatus.pending:
        return AppColors.surfaceAlt;
      case AssignedJobStatus.waitingParts:
        return AppColors.warningBg;
      case AssignedJobStatus.completed:
        return AppColors.successBg;
    }
  }

  String get actionLabel {
    switch (this) {
      case AssignedJobStatus.inProgress:
        return 'In Progress';
      case AssignedJobStatus.pending:
        return 'Start Job';
      case AssignedJobStatus.waitingParts:
        return 'On Hold';
      case AssignedJobStatus.completed:
        return 'Complete';
    }
  }
}

enum TechJobStatus { inProgress, completed, delayed, pending }

extension TechJobStatusX on TechJobStatus {
  String get label {
    switch (this) {
      case TechJobStatus.inProgress:
        return 'In Progress';
      case TechJobStatus.completed:
        return 'Completed';
      case TechJobStatus.delayed:
        return 'Delayed';
      case TechJobStatus.pending:
        return 'Pending';
    }
  }

  Color get color {
    switch (this) {
      case TechJobStatus.inProgress:
        return AppColors.primary;
      case TechJobStatus.completed:
        return AppColors.success;
      case TechJobStatus.delayed:
        return AppColors.danger;
      case TechJobStatus.pending:
        return AppColors.warning;
    }
  }

  Color get bgColor {
    switch (this) {
      case TechJobStatus.inProgress:
        return AppColors.primaryBg;
      case TechJobStatus.completed:
        return AppColors.successBg;
      case TechJobStatus.delayed:
        return AppColors.dangerBg;
      case TechJobStatus.pending:
        return AppColors.warningBg;
    }
  }
}

// ── Entities ──

@freezed
class TechnicianProfileEntity with _$TechnicianProfileEntity {
  const factory TechnicianProfileEntity({
    required String name,
    required String empId,
    required String role,
    required String branch,
    required String shift,
    required String avatarInitials,
  }) = _TechnicianProfileEntity;

  static const mock = TechnicianProfileEntity(
    name: 'Mohammed Hassan',
    empId: 'EMP-001',
    role: 'Technician',
    branch: 'Main Dubai',
    shift: '8:00 AM - 6:00 PM',
    avatarInitials: 'MH',
  );
}

@freezed
class AttendanceSummaryEntity with _$AttendanceSummaryEntity {
  const factory AttendanceSummaryEntity({
    @Default('--:--') String punchIn,
    @Default('--:--') String punchOut,
    @Default('0 min') String breakTime,
    @Default('0h 0m') String workHours,
  }) = _AttendanceSummaryEntity;

  static const empty = AttendanceSummaryEntity();

  factory AttendanceSummaryEntity.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSummaryEntityFromJson(json);
}

@freezed
class TechnicianStatsEntity with _$TechnicianStatsEntity {
  const factory TechnicianStatsEntity({
    required int assignedJobs,
    required int inProgress,
    required int completedToday,
    required double efficiency,
    required String avgTimePerJob,
    required String totalHoursWorked,
  }) = _TechnicianStatsEntity;
}

@freezed
class AssignedJobEntity with _$AssignedJobEntity {
  const factory AssignedJobEntity({
    required String id,
    required String customerName,
    required String vehicle,
    required String service,
    required double amount,
    required AssignedJobStatus status,
  }) = _AssignedJobEntity;

  static List<AssignedJobEntity> get mockData => [
        const AssignedJobEntity(
          id: 'JC-2024-1245',
          customerName: 'Ahmed Al Mansouri',
          vehicle: 'Toyota Camry - AA-12345',
          service: 'Engine Diagnostics',
          amount: 1.2,
          status: AssignedJobStatus.inProgress,
        ),
        const AssignedJobEntity(
          id: 'JC-2024-1246',
          customerName: 'Fatima Ali',
          vehicle: 'Honda Accord - BB-67890',
          service: 'Brake Pad Replacement',
          amount: 0,
          status: AssignedJobStatus.pending,
        ),
        const AssignedJobEntity(
          id: 'JC-2024-1247',
          customerName: 'Khalid Rashid',
          vehicle: 'Nissan Patrol - CC-11223',
          service: 'AC Repair',
          amount: 0,
          status: AssignedJobStatus.waitingParts,
        ),
        const AssignedJobEntity(
          id: 'JC-2024-1248',
          customerName: 'Mariam Salem',
          vehicle: 'BMW X5 - DD-44556',
          service: 'Full Service',
          amount: 0,
          status: AssignedJobStatus.completed,
        ),
      ];
}

@freezed
class TechnicianJobEntity with _$TechnicianJobEntity {
  const factory TechnicianJobEntity({
    required String jobCardNo,
    required String dateOfWork,
    required String startTime,
    required String vehicleBrand,
    required String vehicleModel,
    required String plateNumber,
    @Default(TechJobStatus.pending) TechJobStatus status,
    required List<WorkTaskEntity> tasks,
    @Default('') String notes,
  }) = _TechnicianJobEntity;

  const TechnicianJobEntity._();

  factory TechnicianJobEntity.fromJson(Map<String, dynamic> json) =>
      _$TechnicianJobEntityFromJson(json);

  int get completedTasks =>
      tasks.where((t) => t.status == TaskStatus.completed).length;

  double get progressPercent =>
      tasks.isEmpty ? 0.0 : completedTasks / tasks.length;
}
