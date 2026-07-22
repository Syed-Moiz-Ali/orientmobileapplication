// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_approval_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PendingApprovalEntityImpl _$$PendingApprovalEntityImplFromJson(
  Map<String, dynamic> json,
) => _$PendingApprovalEntityImpl(
  estimateId: json['estimateId'] as String,
  customerName: json['customerName'] as String,
  vehicleId: json['vehicleId'] as String,
  amount: (json['amount'] as num).toDouble(),
  timeAgo: json['timeAgo'] as String? ?? 'now',
);

Map<String, dynamic> _$$PendingApprovalEntityImplToJson(
  _$PendingApprovalEntityImpl instance,
) => <String, dynamic>{
  'estimateId': instance.estimateId,
  'customerName': instance.customerName,
  'vehicleId': instance.vehicleId,
  'amount': instance.amount,
  'timeAgo': instance.timeAgo,
};
