class AdvisorStatsEntity {
  final int newJobCardsToday;
  final int inspectionsToday;
  final int pendingApprovals;
  final int vehiclesWaiting;
  final int readyForDelivery;
  final int totalOpenJobCards;

  /// Number of jobs delivered (completed) today. The backend does not expose
  /// this directly, so it is derived client-side from job card data.
  final int delivered;

  const AdvisorStatsEntity({
    required this.newJobCardsToday,
    required this.inspectionsToday,
    required this.pendingApprovals,
    required this.vehiclesWaiting,
    required this.readyForDelivery,
    required this.totalOpenJobCards,
    this.delivered = 0,
  });
}
