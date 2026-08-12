/// Mirrors the backend job_cards.status ENUM (12 values).
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
  waitingCustomerApproval,
  delivered,
  qualityCheckPassed,
}
