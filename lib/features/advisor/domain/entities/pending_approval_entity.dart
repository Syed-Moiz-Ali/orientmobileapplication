import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_approval_entity.freezed.dart';
part 'pending_approval_entity.g.dart';

@freezed
class PendingApprovalEntity with _$PendingApprovalEntity {
  const factory PendingApprovalEntity({
    required String estimateId,
    required String customerName,
    required String vehicleId,
    required double amount,
    @Default('now') String timeAgo,
  }) = _PendingApprovalEntity;

  factory PendingApprovalEntity.fromJson(Map<String, dynamic> json) =>
      _$PendingApprovalEntityFromJson(json);
}
