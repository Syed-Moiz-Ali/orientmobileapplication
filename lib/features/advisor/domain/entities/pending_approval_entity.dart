class PendingApprovalEntity {
  final String estimateId;
  final String customerName;
  final String vehicleId;
  final double amount;
  final String timeAgo;

  const PendingApprovalEntity({
    required this.estimateId,
    required this.customerName,
    required this.vehicleId,
    required this.amount,
    required this.timeAgo,
  });
}
