import 'package:flutter/material.dart';

class SupervisorKpiEntity {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String sub;

  const SupervisorKpiEntity({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.sub,
  });
}

class AdvisorJobEntity {
  final String name;
  final double count;

  const AdvisorJobEntity({required this.name, required this.count});
}

class JobTypeEntity {
  final String label;
  final int count;
  final Color color;

  const JobTypeEntity({
    required this.label,
    required this.count,
    required this.color,
  });
}

class RevenueMetricEntity {
  final IconData icon;
  final String amount;
  final String label;
  final String change;

  const RevenueMetricEntity({
    required this.icon,
    required this.amount,
    required this.label,
    required this.change,
  });
}

class PendingStatusEntity {
  final IconData icon;
  final Color color;
  final String count;
  final String label;

  const PendingStatusEntity({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
  });
}

class WorkAssignmentEntity {
  final int id;
  final String description;
  final String department;
  final String technicianName;
  final String dateOfWork;
  final int statusPercent;
  final String stdTime;
  final String remarks;

  const WorkAssignmentEntity({
    required this.id,
    this.description = '',
    this.department = '',
    this.technicianName = '',
    this.dateOfWork = '',
    this.statusPercent = 0,
    this.stdTime = '',
    this.remarks = '',
  });

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

  WorkAssignmentEntity copyWith({
    int? id,
    String? description,
    String? department,
    String? technicianName,
    String? dateOfWork,
    int? statusPercent,
    String? stdTime,
    String? remarks,
  }) {
    return WorkAssignmentEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      department: department ?? this.department,
      technicianName: technicianName ?? this.technicianName,
      dateOfWork: dateOfWork ?? this.dateOfWork,
      statusPercent: statusPercent ?? this.statusPercent,
      stdTime: stdTime ?? this.stdTime,
      remarks: remarks ?? this.remarks,
    );
  }
}

class AssignedJobEntity {
  final String jobCard;
  final String customer;
  final String vehicle;
  final String dateAssigned;
  final int done;
  final int total;
  final String status;

  const AssignedJobEntity({
    required this.jobCard,
    required this.customer,
    required this.vehicle,
    required this.dateAssigned,
    required this.done,
    required this.total,
    required this.status,
  });
}
