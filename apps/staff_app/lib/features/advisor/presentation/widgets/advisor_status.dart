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

/// An [AppStatusChip] with the shared semantic tone for [status] and the same
/// localized vocabulary as [advisorStatusLabel] (sentence case, never color
/// alone). Presentation-only twin of [advisorStatusPill] for App* surfaces;
/// the pill stays untouched for the surfaces that still use it.
AppStatusChip advisorStatusChip(StaffLocalizations t, JobCardStatus status) {
  final label = advisorStatusLabel(t, status);
  return AppStatusChip(label: label, kind: _statusKind(status));
}

/// Shared kind mapping for the App* status chip (same taxonomy as
/// [advisorStatusPill]: pending/approval/waiting → warning, finished →
/// success, parts → danger, active/inspected → info, cancelled → neutral).
AppStatusKind _statusKind(JobCardStatus status) => switch (status) {
  JobCardStatus.pending ||
  JobCardStatus.pendingApproval ||
  JobCardStatus.awaitingSupervisor ||
  JobCardStatus.waitingCustomerApproval =>
    AppStatusKind.warning,
  JobCardStatus.completed ||
  JobCardStatus.approved ||
  JobCardStatus.delivered ||
  JobCardStatus.qualityCheckPassed => AppStatusKind.success,
  JobCardStatus.waitingParts => AppStatusKind.error,
  JobCardStatus.qualityCheck ||
  JobCardStatus.inProgress ||
  JobCardStatus.workAssigned ||
  JobCardStatus.inspected ||
  JobCardStatus.vehicleReceived => AppStatusKind.info,
  JobCardStatus.cancelled => AppStatusKind.neutral,
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

/// Localized approval-type label for the advisor workspace. The domain
/// entity's `typeLabel` getter is frozen English copy, so presentation
/// resolves its own localized wording from the raw `approvalType` value.
String advisorApprovalTypeLabel(StaffLocalizations t, String approvalType) =>
    switch (approvalType) {
      'job_card' => t.advisorApprovalTypeJobCard,
      'inspection' => t.advisorApprovalTypeInspection,
      _ => t.advisorApprovalTypeEstimate,
    };

/// Stable filter key for the Jobs work-matrix filter rail
/// (locale-independent). Taxonomy follows the Phase 06 rework §3 rail:
/// All / Intake / Inspection / Approved / WIP / Ready. Cancelled cards are
/// reachable under All only. Filtering is presentation state; status
/// semantics are unchanged.
String advisorStatusFilterKey(JobCardStatus status) => switch (status) {
  JobCardStatus.vehicleReceived || JobCardStatus.pending => 'intake',
  JobCardStatus.inspected || JobCardStatus.qualityCheck => 'inspection',
  JobCardStatus.approved ||
  JobCardStatus.pendingApproval ||
  JobCardStatus.awaitingSupervisor ||
  JobCardStatus.waitingCustomerApproval => 'approved',
  JobCardStatus.inProgress ||
  JobCardStatus.workAssigned ||
  JobCardStatus.waitingParts => 'wip',
  JobCardStatus.completed ||
  JobCardStatus.qualityCheckPassed ||
  JobCardStatus.delivered => 'ready',
  JobCardStatus.cancelled => 'cancelled',
};
