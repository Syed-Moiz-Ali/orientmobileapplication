// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_task_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkTaskEntityImpl _$$WorkTaskEntityImplFromJson(Map<String, dynamic> json) =>
    _$WorkTaskEntityImpl(
      id: (json['id'] as num).toInt(),
      description: json['description'] as String,
      status:
          $enumDecodeNullable(_$TaskStatusEnumMap, json['status']) ??
          TaskStatus.pending,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );

Map<String, dynamic> _$$WorkTaskEntityImplToJson(
  _$WorkTaskEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'description': instance.description,
  'status': _$TaskStatusEnumMap[instance.status],
  if (instance.startTime case final value?) 'startTime': value,
  if (instance.endTime case final value?) 'endTime': value,
};

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.inProgress: 'inProgress',
  TaskStatus.completed: 'completed',
};
