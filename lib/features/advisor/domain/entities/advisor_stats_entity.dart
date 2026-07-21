class AdvisorStatsEntity {
  final int newJobCardsToday;
  final int inspectionsToday;
  final int pendingApprovals;
  final int vehiclesWaiting;
  final int readyForDelivery;
  final int totalOpenJobCards;

  const AdvisorStatsEntity({
    required this.newJobCardsToday,
    required this.inspectionsToday,
    required this.pendingApprovals,
    required this.vehiclesWaiting,
    required this.readyForDelivery,
    required this.totalOpenJobCards,
  });
}
