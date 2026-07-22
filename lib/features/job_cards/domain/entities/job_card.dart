import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:orientmobileapplication/core/domain/job_card_status.dart';
export 'package:orientmobileapplication/core/domain/job_card_status.dart';

part 'job_card.freezed.dart';

@freezed
class JobCard with _$JobCard {
  const factory JobCard({
    required String id,
    required String customerName,
    required String vehicle,
    required String plateNumber,
    required List<String> services,
    required String technician,
    required String estCompletion,
    required double amount,
    required JobCardStatus status,
  }) = _JobCard;

  const JobCard._();

  String get vehicleDisplay => '$vehicle - $plateNumber';
}
