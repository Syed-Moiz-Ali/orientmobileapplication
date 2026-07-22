// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'technician_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceSummaryEntityImpl _$$AttendanceSummaryEntityImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceSummaryEntityImpl(
  punchIn: json['punchIn'] as String? ?? '--:--',
  punchOut: json['punchOut'] as String? ?? '--:--',
  breakTime: json['breakTime'] as String? ?? '0 min',
  workHours: json['workHours'] as String? ?? '0h 0m',
);

Map<String, dynamic> _$$AttendanceSummaryEntityImplToJson(
  _$AttendanceSummaryEntityImpl instance,
) => <String, dynamic>{
  'punchIn': instance.punchIn,
  'punchOut': instance.punchOut,
  'breakTime': instance.breakTime,
  'workHours': instance.workHours,
};

_$TechnicianJobEntityImpl _$$TechnicianJobEntityImplFromJson(
  Map<String, dynamic> json,
) => _$TechnicianJobEntityImpl(
  jobCardNo: json['jobCardNo'] as String,
  dateOfWork: json['dateOfWork'] as String,
  startTime: json['startTime'] as String,
  vehicleBrand: json['vehicleBrand'] as String,
  vehicleModel: json['vehicleModel'] as String,
  plateNumber: json['plateNumber'] as String,
  status:
      $enumDecodeNullable(_$TechJobStatusEnumMap, json['status']) ??
      TechJobStatus.pending,
  tasks: (json['tasks'] as List<dynamic>)
      .map((e) => WorkTaskEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String? ?? '',
);

Map<String, dynamic> _$$TechnicianJobEntityImplToJson(
  _$TechnicianJobEntityImpl instance,
) => <String, dynamic>{
  'jobCardNo': instance.jobCardNo,
  'dateOfWork': instance.dateOfWork,
  'startTime': instance.startTime,
  'vehicleBrand': instance.vehicleBrand,
  'vehicleModel': instance.vehicleModel,
  'plateNumber': instance.plateNumber,
  'status': _$TechJobStatusEnumMap[instance.status],
  'tasks': instance.tasks.map((e) => e.toJson()).toList(),
  'notes': instance.notes,
};

const _$TechJobStatusEnumMap = {
  TechJobStatus.inProgress: 'inProgress',
  TechJobStatus.completed: 'completed',
  TechJobStatus.delayed: 'delayed',
  TechJobStatus.pending: 'pending',
};
