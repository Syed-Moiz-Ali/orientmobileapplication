// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerEntityImpl _$$CustomerEntityImplFromJson(Map<String, dynamic> json) =>
    _$CustomerEntityImpl(
      name: json['name'] as String,
      firstName: json['firstName'] as String,
      avatarInitials: json['avatarInitials'] as String,
      memberId: json['memberId'] as String,
    );

Map<String, dynamic> _$$CustomerEntityImplToJson(
  _$CustomerEntityImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'firstName': instance.firstName,
  'avatarInitials': instance.avatarInitials,
  'memberId': instance.memberId,
};

_$CustomerVehicleEntityImpl _$$CustomerVehicleEntityImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerVehicleEntityImpl(
  id: json['id'] as String,
  brand: json['brand'] as String,
  model: json['model'] as String,
  plateNumber: json['plateNumber'] as String,
  vin: json['vin'] as String,
  color: json['color'] as String,
  year: (json['year'] as num).toInt(),
  mileage: json['mileage'] as String,
  lastService: json['lastService'] as String,
  nextDue: json['nextDue'] as String,
  healthScore: (json['healthScore'] as num).toInt(),
);

Map<String, dynamic> _$$CustomerVehicleEntityImplToJson(
  _$CustomerVehicleEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'brand': instance.brand,
  'model': instance.model,
  'plateNumber': instance.plateNumber,
  'vin': instance.vin,
  'color': instance.color,
  'year': instance.year,
  'mileage': instance.mileage,
  'lastService': instance.lastService,
  'nextDue': instance.nextDue,
  'healthScore': instance.healthScore,
};

_$CustomerBookingEntityImpl _$$CustomerBookingEntityImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerBookingEntityImpl(
  service: json['service'] as String,
  vehicleName: json['vehicleName'] as String,
  plateNumber: json['plateNumber'] as String,
  date: json['date'] as String,
  time: json['time'] as String,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
);

Map<String, dynamic> _$$CustomerBookingEntityImplToJson(
  _$CustomerBookingEntityImpl instance,
) => <String, dynamic>{
  'service': instance.service,
  'vehicleName': instance.vehicleName,
  'plateNumber': instance.plateNumber,
  'date': instance.date,
  'time': instance.time,
  'status': _$BookingStatusEnumMap[instance.status]!,
};

const _$BookingStatusEnumMap = {
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.completed: 'completed',
  BookingStatus.pending: 'pending',
  BookingStatus.cancelled: 'cancelled',
};

_$ServiceStageEntityImpl _$$ServiceStageEntityImplFromJson(
  Map<String, dynamic> json,
) => _$ServiceStageEntityImpl(
  name: json['name'] as String,
  time: json['time'] as String?,
  status: $enumDecode(_$StageStatusEnumMap, json['status']),
);

Map<String, dynamic> _$$ServiceStageEntityImplToJson(
  _$ServiceStageEntityImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  if (instance.time case final value?) 'time': value,
  'status': _$StageStatusEnumMap[instance.status]!,
};

const _$StageStatusEnumMap = {
  StageStatus.done: 'done',
  StageStatus.inProgress: 'inProgress',
  StageStatus.pending: 'pending',
};

_$CustomerServiceEntityImpl _$$CustomerServiceEntityImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerServiceEntityImpl(
  jobCardId: json['jobCardId'] as String,
  plateNumber: json['plateNumber'] as String,
  vehicleName: json['vehicleName'] as String,
  service: json['service'] as String,
  started: json['started'] as String,
  estCompletion: json['estCompletion'] as String,
  progressPercent: (json['progressPercent'] as num).toInt(),
  currentStage: json['currentStage'] as String,
  technicianName: json['technicianName'] as String,
  stages: (json['stages'] as List<dynamic>)
      .map((e) => ServiceStageEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$CustomerServiceEntityImplToJson(
  _$CustomerServiceEntityImpl instance,
) => <String, dynamic>{
  'jobCardId': instance.jobCardId,
  'plateNumber': instance.plateNumber,
  'vehicleName': instance.vehicleName,
  'service': instance.service,
  'started': instance.started,
  'estCompletion': instance.estCompletion,
  'progressPercent': instance.progressPercent,
  'currentStage': instance.currentStage,
  'technicianName': instance.technicianName,
  'stages': instance.stages.map((e) => e.toJson()).toList(),
};

_$CustomerNotificationEntityImpl _$$CustomerNotificationEntityImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerNotificationEntityImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  time: json['time'] as String,
  type: $enumDecode(_$NotifTypeEnumMap, json['type']),
  isRead: json['isRead'] as bool? ?? false,
);

Map<String, dynamic> _$$CustomerNotificationEntityImplToJson(
  _$CustomerNotificationEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'time': instance.time,
  'type': _$NotifTypeEnumMap[instance.type]!,
  'isRead': instance.isRead,
};

const _$NotifTypeEnumMap = {
  NotifType.carReady: 'carReady',
  NotifType.bookingConfirmed: 'bookingConfirmed',
  NotifType.invoiceReady: 'invoiceReady',
  NotifType.approvalNeeded: 'approvalNeeded',
  NotifType.workInProgress: 'workInProgress',
  NotifType.reminder: 'reminder',
};

_$ServiceTypeEntityImpl _$$ServiceTypeEntityImplFromJson(
  Map<String, dynamic> json,
) => _$ServiceTypeEntityImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  price: json['price'] as String,
  duration: json['duration'] as String,
);

Map<String, dynamic> _$$ServiceTypeEntityImplToJson(
  _$ServiceTypeEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'duration': instance.duration,
};
