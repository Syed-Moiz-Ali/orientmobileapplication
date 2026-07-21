enum JobCardStatus {
  inProgress,
  pendingApproval,
  completed,
  waitingParts,
  qualityCheck,
  cancelled,
}

class JobCardEntity {
  final String id;
  final String customerName;
  final String vehicleInfo;
  final String time;
  final JobCardStatus status;

  const JobCardEntity({
    required this.id,
    required this.customerName,
    required this.vehicleInfo,
    required this.time,
    required this.status,
  });
}
