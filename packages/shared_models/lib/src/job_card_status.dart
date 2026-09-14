/// Mirrors the backend job_cards.status ENUM.
/// NOTE: apps consume shared_core's JobCardStatus; keep both in sync.
enum JobCardStatus {
  inProgress,
  waitingParts,
  qualityCheck,
  completed,
  cancelled,
  pendingApproval,
  pending,
  awaitingSupervisor,
  vehicleReceived,
  inspected,
  approved,
  workAssigned,
  waitingCustomerApproval,
  delivered,
  qualityCheckPassed,
}
