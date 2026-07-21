import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';

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

  static const mock = TechnicianProfileEntity(
    name: 'Mohammed Hassan',
    empId: 'EMP-001',
    role: 'Technician',
    branch: 'Main Dubai',
    shift: '8:00 AM - 6:00 PM',
    avatarInitials: 'MH',
  );
}

enum AttendanceStatus { notPunchedIn, working, onBreak, punchedOut }

extension AttendanceStatusX on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.notPunchedIn: return 'Not Punched In';
      case AttendanceStatus.working:      return 'Working';
      case AttendanceStatus.onBreak:      return 'On Break';
      case AttendanceStatus.punchedOut:   return 'Punched Out';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.notPunchedIn: return AppColors.text3;
      case AttendanceStatus.working:      return AppColors.success;
      case AttendanceStatus.onBreak:      return AppColors.warning;
      case AttendanceStatus.punchedOut:   return AppColors.danger;
    }
  }

  Color get bgColor {
    switch (this) {
      case AttendanceStatus.notPunchedIn: return AppColors.surfaceAlt;
      case AttendanceStatus.working:      return AppColors.successBg;
      case AttendanceStatus.onBreak:      return AppColors.warningBg;
      case AttendanceStatus.punchedOut:   return AppColors.dangerBg;
    }
  }
}

class AttendanceSummaryEntity {
  final String punchIn;
  final String punchOut;
  final String breakTime;
  final String workHours;

  const AttendanceSummaryEntity({
    required this.punchIn,
    required this.punchOut,
    required this.breakTime,
    required this.workHours,
  });

  static const empty = AttendanceSummaryEntity(
    punchIn: '--:--',
    punchOut: '--:--',
    breakTime: '0 min',
    workHours: '0h 0m',
  );
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

enum AssignedJobStatus { inProgress, pending, waitingParts, completed }

extension AssignedJobStatusX on AssignedJobStatus {
  String get label {
    switch (this) {
      case AssignedJobStatus.inProgress:   return 'In Progress';
      case AssignedJobStatus.pending:      return 'Pending';
      case AssignedJobStatus.waitingParts: return 'Waiting Parts';
      case AssignedJobStatus.completed:    return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case AssignedJobStatus.inProgress:   return AppColors.primary;
      case AssignedJobStatus.pending:      return AppColors.text3;
      case AssignedJobStatus.waitingParts: return AppColors.warning;
      case AssignedJobStatus.completed:    return AppColors.success;
    }
  }

  Color get bgColor {
    switch (this) {
      case AssignedJobStatus.inProgress:   return AppColors.primaryBg;
      case AssignedJobStatus.pending:      return AppColors.surfaceAlt;
      case AssignedJobStatus.waitingParts: return AppColors.warningBg;
      case AssignedJobStatus.completed:    return AppColors.successBg;
    }
  }

  String get actionLabel {
    switch (this) {
      case AssignedJobStatus.inProgress:   return 'In Progress';
      case AssignedJobStatus.pending:      return 'Start Job';
      case AssignedJobStatus.waitingParts: return 'On Hold';
      case AssignedJobStatus.completed:    return 'Complete';
    }
  }
}

class AssignedJobEntity {
  final String id;
  final String customerName;
  final String vehicle;
  final String service;
  final double amount;
  AssignedJobStatus status;

  AssignedJobEntity({
    required this.id,
    required this.customerName,
    required this.vehicle,
    required this.service,
    required this.amount,
    required this.status,
  });

  static List<AssignedJobEntity> get mockData => [
    AssignedJobEntity(
      id: 'JC-2024-1245',
      customerName: 'Ahmed Al Mansouri',
      vehicle: 'Toyota Camry - AA-12345',
      service: 'Engine Diagnostics',
      amount: 1.2,
      status: AssignedJobStatus.inProgress,
    ),
    AssignedJobEntity(
      id: 'JC-2024-1246',
      customerName: 'Fatima Ali',
      vehicle: 'Honda Accord - BB-67890',
      service: 'Brake Pad Replacement',
      amount: 0,
      status: AssignedJobStatus.pending,
    ),
    AssignedJobEntity(
      id: 'JC-2024-1247',
      customerName: 'Khalid Rashid',
      vehicle: 'Nissan Patrol - CC-11223',
      service: 'AC Repair',
      amount: 0,
      status: AssignedJobStatus.waitingParts,
    ),
    AssignedJobEntity(
      id: 'JC-2024-1248',
      customerName: 'Mariam Salem',
      vehicle: 'BMW X5 - DD-44556',
      service: 'Full Service',
      amount: 0,
      status: AssignedJobStatus.completed,
    ),
  ];
}

enum TechJobStatus { inProgress, completed, delayed, pending }

extension TechJobStatusX on TechJobStatus {
  String get label {
    switch (this) {
      case TechJobStatus.inProgress: return 'In Progress';
      case TechJobStatus.completed:  return 'Completed';
      case TechJobStatus.delayed:    return 'Delayed';
      case TechJobStatus.pending:    return 'Pending';
    }
  }

  Color get color {
    switch (this) {
      case TechJobStatus.inProgress: return AppColors.primary;
      case TechJobStatus.completed:  return AppColors.success;
      case TechJobStatus.delayed:    return AppColors.danger;
      case TechJobStatus.pending:    return AppColors.warning;
    }
  }

  Color get bgColor {
    switch (this) {
      case TechJobStatus.inProgress: return AppColors.primaryBg;
      case TechJobStatus.completed:  return AppColors.successBg;
      case TechJobStatus.delayed:    return AppColors.dangerBg;
      case TechJobStatus.pending:    return AppColors.warningBg;
    }
  }
}

enum TaskStatus { pending, inProgress, completed }

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.pending:    return 'Pending';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.completed:  return 'Completed';
    }
  }
}

class WorkTaskEntity {
  final int id;
  final String description;
  TaskStatus status;
  String? startTime;
  String? endTime;

  WorkTaskEntity({
    required this.id,
    required this.description,
    this.status = TaskStatus.pending,
    this.startTime,
    this.endTime,
  });

  WorkTaskEntity copyWith({
    TaskStatus? status,
    String? startTime,
    String? endTime,
  }) =>
      WorkTaskEntity(
        id: id,
        description: description,
        status: status ?? this.status,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
      );
}

class TechnicianJobEntity {
  final String jobCardNo;
  final String dateOfWork;
  final String startTime;
  final String vehicleBrand;
  final String vehicleModel;
  final String plateNumber;
  TechJobStatus status;
  List<WorkTaskEntity> tasks;
  String notes;

  TechnicianJobEntity({
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
}
