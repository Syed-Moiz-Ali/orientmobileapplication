// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_card_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobCardEntityImpl _$$JobCardEntityImplFromJson(Map<String, dynamic> json) =>
    _$JobCardEntityImpl(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      vehicleInfo: json['vehicleInfo'] as String,
      time: json['time'] as String,
      createdDate: json['createdDate'] as String? ?? '',
      lastUpdated: json['lastUpdated'] as String? ?? '',
      status: $enumDecode(_$JobCardStatusEnumMap, json['status']),
      technician: json['technician'] as String? ?? '',
    );

Map<String, dynamic> _$$JobCardEntityImplToJson(_$JobCardEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'vehicleInfo': instance.vehicleInfo,
      'time': instance.time,
      'createdDate': instance.createdDate,
      'lastUpdated': instance.lastUpdated,
      'status': _$JobCardStatusEnumMap[instance.status]!,
      'technician': instance.technician,
    };

const _$JobCardStatusEnumMap = {
  JobCardStatus.inProgress: 'inProgress',
  JobCardStatus.waitingParts: 'waitingParts',
  JobCardStatus.qualityCheck: 'qualityCheck',
  JobCardStatus.completed: 'completed',
  JobCardStatus.cancelled: 'cancelled',
  JobCardStatus.pendingApproval: 'pendingApproval',
};
