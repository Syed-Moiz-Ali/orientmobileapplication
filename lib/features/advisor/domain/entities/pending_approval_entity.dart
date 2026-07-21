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

  factory PendingApprovalEntity.fromMap(Map<String, dynamic> map) =>
      PendingApprovalEntity(
        estimateId: map['estimateId'] as String? ?? '',
        customerName: map['customerName'] as String? ?? '',
        vehicleId: map['vehicleId'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        timeAgo: map['timeAgo'] as String? ?? 'now',
      );
}
