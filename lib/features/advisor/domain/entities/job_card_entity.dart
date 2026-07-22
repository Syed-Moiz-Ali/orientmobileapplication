import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:orientmobileapplication/core/domain/job_card_status.dart';
export 'package:orientmobileapplication/core/domain/job_card_status.dart';

part 'job_card_entity.freezed.dart';
part 'job_card_entity.g.dart';

@freezed
class JobCardEntity with _$JobCardEntity {
  const factory JobCardEntity({
    required String id,
    required String customerName,
    required String vehicleInfo,
    required String time,
    @Default('') String createdDate,
    @Default('') String lastUpdated,
    required JobCardStatus status,
    @Default('') String technician,
  }) = _JobCardEntity;

  factory JobCardEntity.fromJson(Map<String, dynamic> json) =>
      _$JobCardEntityFromJson(json);
}
