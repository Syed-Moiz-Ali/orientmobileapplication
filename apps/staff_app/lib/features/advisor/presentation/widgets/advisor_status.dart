import 'package:shared_core/shared_core.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Localized, token-driven job-card status presentation for the advisor
/// workspace (Phase 06). Keeps status vocabulary in one place so the Today,
/// Jobs, job-detail and sheet surfaces never drift.
String advisorStatusLabel(StaffLocalizations t, JobCardStatus status) =>
    switch (status) {
      JobCardStatus.inProgress => t.advisorStatusInProgress,
      JobCardStatus.pendingApproval => t.advisorStatusPendingApproval,
      JobCardStatus.completed => t.advisorStatusCompleted,
      JobCardStatus.waitingParts => t.advisorStatusWaitingParts,
      JobCardStatus.qualityCheck => t.advisorStatusQc,
      JobCardStatus.cancelled => t.advisorStatusCancelled,
      JobCardStatus.pending => t.advisorStatusPending,
      JobCardStatus.awaitingSupervisor => t.advisorStatusAwaitingSupervisor,
      JobCardStatus.vehicleReceived => t.advisorStatusVehicleReceived,
      JobCardStatus.inspected => t.advisorStatusInspected,
      JobCardStatus.approved => t.advisorStatusApproved,
      JobCardStatus.workAssigned => t.advisorStatusWorkAssigned,
      JobCardStatus.waitingCustomerApproval =>
        t.advisorStatusWaitingCustomerApproval,
      JobCardStatus.delivered => t.advisorStatusDelivered,
      JobCardStatus.qualityCheckPassed => t.advisorStatusQcPassed,
    };

/// A [StatusPill] with the shared semantic tone for [status] and the localized
/// label. State is always encoded by text + tone, never colour alone.
StatusPill advisorStatusPill(StaffLocalizations t, JobCardStatus status) {
  final label = advisorStatusLabel(t, status);
  return switch (status) {
    JobCardStatus.inProgress => StatusPill.inProgress(label),
    JobCardStatus.pending ||
    JobCardStatus.pendingApproval ||
    JobCardStatus.awaitingSupervisor ||
    JobCardStatus.waitingCustomerApproval => StatusPill.warning(label),
    JobCardStatus.completed ||
    JobCardStatus.approved ||
    JobCardStatus.delivered ||
    JobCardStatus.qualityCheckPassed => StatusPill.success(label),
    JobCardStatus.waitingParts => StatusPill.danger(label),
    JobCardStatus.qualityCheck ||
    JobCardStatus.vehicleReceived ||
    JobCardStatus.inspected ||
    JobCardStatus.workAssigned => StatusPill.info(label),
    JobCardStatus.cancelled => StatusPill.neutral(label),
  };
}

/// Stable filter key for the Jobs status chips (locale-independent).
String advisorStatusFilterKey(JobCardStatus status) => switch (status) {
  JobCardStatus.inProgress || JobCardStatus.workAssigned => 'inProgress',
  JobCardStatus.completed ||
  JobCardStatus.approved ||
  JobCardStatus.delivered ||
  JobCardStatus.qualityCheckPassed => 'completed',
  JobCardStatus.pending ||
  JobCardStatus.pendingApproval ||
  JobCardStatus.awaitingSupervisor ||
  JobCardStatus.waitingCustomerApproval ||
  JobCardStatus.waitingParts => 'pending',
  JobCardStatus.qualityCheck ||
  JobCardStatus.vehicleReceived ||
  JobCardStatus.inspected => 'qc',
  JobCardStatus.cancelled => 'cancelled',
};
