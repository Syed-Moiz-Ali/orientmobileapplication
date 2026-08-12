/// Mirrors the backend job_cards.status ENUM (12 values). Anything the backend
/// sends that is missing here would silently fall back to inProgress — keep in
/// sync with JobCardService.VALID_JOB_CARD_STATUSES.
/// FIX (audit QA BUG-025): added pending / awaitingSupervisor / vehicleReceived /
/// waitingCustomerApproval / delivered / qualityCheckPassed.
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
