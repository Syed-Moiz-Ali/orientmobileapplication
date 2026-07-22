import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_view_model.freezed.dart';
part 'inspection_view_model.g.dart';

@freezed
class ItemMedia with _$ItemMedia {
  const factory ItemMedia({
    @Default(<String>[]) List<String> photoPaths,
    @Default(<String>[]) List<String> videoPaths,
    @Default('') String audioPath,
    @Default('') String note,
  }) = _ItemMedia;

  const ItemMedia._();

  bool get hasMedia => photoPaths.isNotEmpty || videoPaths.isNotEmpty || audioPath.isNotEmpty || note.isNotEmpty;

  factory ItemMedia.fromJson(Map<String, dynamic> json) => _$ItemMediaFromJson(json);
}

@freezed
class ServiceLineItem with _$ServiceLineItem {
  const factory ServiceLineItem({
    required String name,
    @Default(1) int qty,
    @Default(0) double rate,
    @Default(0) double discountPercent,
    @Default(0) double discountAmount,
  }) = _ServiceLineItem;

  const ServiceLineItem._();

  double get amount => (rate * qty) - discountAmount;

  factory ServiceLineItem.fromJson(Map<String, dynamic> json) => _$ServiceLineItemFromJson(json);
}

@freezed
class PartLineItem with _$PartLineItem {
  const factory PartLineItem({
    required String name,
    @Default(1) int qty,
    @Default(0) double rate,
    @Default(0) double discountPercent,
    @Default(0) double discountAmount,
  }) = _PartLineItem;

  const PartLineItem._();

  double get amount => (rate * qty) - discountAmount;

  factory PartLineItem.fromJson(Map<String, dynamic> json) => _$PartLineItemFromJson(json);
}
