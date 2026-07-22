import 'package:freezed_annotation/freezed_annotation.dart';

part 'advisor_stats_entity.freezed.dart';

@freezed
class AdvisorStatsEntity with _$AdvisorStatsEntity {
  const factory AdvisorStatsEntity({
    required int newJobCardsToday,
    required int inspectionsToday,
    required int pendingApprovals,
    required int vehiclesWaiting,
    required int readyForDelivery,
    required int totalOpenJobCards,
  }) = _AdvisorStatsEntity;
}
