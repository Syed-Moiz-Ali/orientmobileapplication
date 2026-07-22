// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_view_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemMediaImpl _$$ItemMediaImplFromJson(Map<String, dynamic> json) =>
    _$ItemMediaImpl(
      photoPaths:
          (json['photoPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      videoPaths:
          (json['videoPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      audioPath: json['audioPath'] as String? ?? '',
      note: json['note'] as String? ?? '',
    );

Map<String, dynamic> _$$ItemMediaImplToJson(_$ItemMediaImpl instance) =>
    <String, dynamic>{
      'photoPaths': instance.photoPaths,
      'videoPaths': instance.videoPaths,
      'audioPath': instance.audioPath,
      'note': instance.note,
    };

_$ServiceLineItemImpl _$$ServiceLineItemImplFromJson(
  Map<String, dynamic> json,
) => _$ServiceLineItemImpl(
  name: json['name'] as String,
  qty: (json['qty'] as num?)?.toInt() ?? 1,
  rate: (json['rate'] as num?)?.toDouble() ?? 0,
  discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
  discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$ServiceLineItemImplToJson(
  _$ServiceLineItemImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'qty': instance.qty,
  'rate': instance.rate,
  'discountPercent': instance.discountPercent,
  'discountAmount': instance.discountAmount,
};

_$PartLineItemImpl _$$PartLineItemImplFromJson(Map<String, dynamic> json) =>
    _$PartLineItemImpl(
      name: json['name'] as String,
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$PartLineItemImplToJson(_$PartLineItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'qty': instance.qty,
      'rate': instance.rate,
      'discountPercent': instance.discountPercent,
      'discountAmount': instance.discountAmount,
    };
