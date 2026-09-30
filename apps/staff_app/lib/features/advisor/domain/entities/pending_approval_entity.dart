class PendingApprovalEntity {
  final String estimateId;
  final String approvalType;
  final String customerName;
  final String vehicleId;
  final double amount;
  final String timeAgo;

  const PendingApprovalEntity({
    required this.estimateId,
    this.approvalType = 'estimate',
    required this.customerName,
    required this.vehicleId,
    required this.amount,
    this.timeAgo = 'now',
  });

  bool get isEstimate => approvalType == 'estimate';

  String get typeLabel => switch (approvalType) {
    'job_card' => 'Job card',
    'inspection' => 'Inspection',
    _ => 'Estimate',
  };
}
