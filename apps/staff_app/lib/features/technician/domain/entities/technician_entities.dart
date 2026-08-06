import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'work_task_entity.dart';
export 'work_task_entity.dart';

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

class TechnicianProfileEntity {
  final String name;
  final String empId;
  final String role;
  final String branch;
  final String shift;
  final String avatarInitials;

  const TechnicianProfileEntity({
    required this.name,
    required this.empId,
    required this.role,
    required this.branch,
    required this.shift,
    required this.avatarInitials,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'empId': empId,
        'role': role,
        'branch': branch,
        'shift': shift,
        'avatarInitials': avatarInitials,
      };

  factory TechnicianProfileEntity.fromJson(Map<String, dynamic> json) =>
      TechnicianProfileEntity(
        name: json['name'] as String? ?? '',
        empId: json['empId'] as String? ?? '',
        role: json['role'] as String? ?? 'Technician',
        branch: json['branch'] as String? ?? '',
        shift: json['shift'] as String? ?? '',
        avatarInitials: json['avatarInitials'] as String? ?? 'T',
      );
}

class AttendanceSummaryEntity {
  final String punchIn;
  final String punchOut;
  final String breakTime;
  final String workHours;

  const AttendanceSummaryEntity({
    this.punchIn = '--:--',
    this.punchOut = '--:--',
    this.breakTime = '0 min',
    this.workHours = '0h 0m',
  });

  static const empty = AttendanceSummaryEntity();

  AttendanceSummaryEntity copyWith({
    String? punchIn,
    String? punchOut,
    String? breakTime,
    String? workHours,
  }) {
    return AttendanceSummaryEntity(
      punchIn: punchIn ?? this.punchIn,
      punchOut: punchOut ?? this.punchOut,
      breakTime: breakTime ?? this.breakTime,
      workHours: workHours ?? this.workHours,
    );
  }

  factory AttendanceSummaryEntity.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryEntity(
      punchIn: (json['punchIn'] as String?) ?? '--:--',
      punchOut: (json['punchOut'] as String?) ?? '--:--',
      breakTime: (json['breakTime'] as String?) ?? '0 min',
      workHours: (json['workHours'] as String?) ?? '0h 0m',
    );
  }
}

class TechnicianStatsEntity {
  final int assignedJobs;
  final int inProgress;
  final int completedToday;
  final double efficiency;
  final String avgTimePerJob;
  final String totalHoursWorked;

  const TechnicianStatsEntity({
    required this.assignedJobs,
    required this.inProgress,
    required this.completedToday,
    required this.efficiency,
    required this.avgTimePerJob,
    required this.totalHoursWorked,
  });
}

class AssignedJobEntity {
  final String id;
  final String customerName;
  final String vehicle;
  final String service;
  final double amount;
  final AssignedJobStatus status;

  const AssignedJobEntity({
    required this.id,
    required this.customerName,
    required this.vehicle,
    required this.service,
    required this.amount,
    required this.status,
  });

  AssignedJobEntity copyWith({AssignedJobStatus? status}) {
    return AssignedJobEntity(
      id: id,
      customerName: customerName,
      vehicle: vehicle,
      service: service,
      amount: amount,
      status: status ?? this.status,
    );
  }
}

class TechnicianJobEntity {
  final String jobCardNo;
  final String dateOfWork;
  final String startTime;
  final String vehicleBrand;
  final String vehicleModel;
  final String plateNumber;
  final TechJobStatus status;
  final List<WorkTaskEntity> tasks;
  final String notes;

  const TechnicianJobEntity({
    required this.jobCardNo,
    required this.dateOfWork,
    required this.startTime,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.plateNumber,
    this.status = TechJobStatus.pending,
    required this.tasks,
    this.notes = '',
  });

  int get completedTasks =>
      tasks.where((t) => t.status == TaskStatus.completed).length;

  double get progressPercent =>
      tasks.isEmpty ? 0.0 : completedTasks / tasks.length;

  TechnicianJobEntity copyWith({
    String? jobCardNo,
    String? dateOfWork,
    String? startTime,
    String? vehicleBrand,
    String? vehicleModel,
    String? plateNumber,
    TechJobStatus? status,
    List<WorkTaskEntity>? tasks,
    String? notes,
  }) {
    return TechnicianJobEntity(
      jobCardNo: jobCardNo ?? this.jobCardNo,
      dateOfWork: dateOfWork ?? this.dateOfWork,
      startTime: startTime ?? this.startTime,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      plateNumber: plateNumber ?? this.plateNumber,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      notes: notes ?? this.notes,
    );
  }

  factory TechnicianJobEntity.fromJson(Map<String, dynamic> json) {
    return TechnicianJobEntity(
      jobCardNo: json['jobCardNo'] as String,
      dateOfWork: json['dateOfWork'] as String,
      startTime: (json['startTime'] as String?) ?? '',
      vehicleBrand: (json['vehicleBrand'] as String?) ?? '',
      vehicleModel: (json['vehicleModel'] as String?) ?? '',
      plateNumber: (json['plateNumber'] as String?) ?? '',
      status: TechJobStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TechJobStatus.pending,
      ),
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map(
                (t) => WorkTaskEntity.fromJson(Map<String, dynamic>.from(t)),
              )
              .toList() ??
          [],
      notes: (json['notes'] as String?) ?? '',
    );
  }
}
