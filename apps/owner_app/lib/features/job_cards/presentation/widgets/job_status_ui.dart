import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Fixed-decimal tabular AED (`AED 2,450.00`, Latin digits + Latin code both
/// locales). The shared `moneyAED` trims whole amounts to `AED 2,450`;
/// the register acceptance demands fixed cents, so this display-only helper
/// groups through the shared formatter and appends the exact cents. No
/// rounding policy beyond half-cent display rounding; never feeds payloads.
///
/// U10: the code stays Latin `AED` in BOTH locales (same family as LOGIC
/// entry #9 — server codes like `AED` and plates stay LTR by design). The
/// Arabic-script `د.إ` run broke under bidi mirroring (rendered `E.E` with
/// the order flipped to number-first in ar goldens), so it is not used here.
/// Call sites keep the value inside an LTR `Directionality` with tabular
/// figures so ar renders `AED 2,450.00` LTR-intact.
String formatAed2(AppFormatters f, double amount) {
  final cents = (amount * 100).round();
  final sign = cents < 0 ? '-' : '';
  final abs = cents.abs();
  final head = f.group(abs ~/ 100);
  final tail = (abs % 100).toString().padLeft(2, '0');
  return 'AED $sign$head.$tail';
}

/// Lifecycle position for the six-step dossier stepper
/// (Intake → Inspection → Estimate → Repair → QC → Ready). Terminal
/// cancellation rests at the start while its pill carries the state.
int jobLifecycleIndex(JobCardStatus status) => switch (status) {
      JobCardStatus.vehicleReceived || JobCardStatus.pending => 0,
      JobCardStatus.inspected => 1,
      JobCardStatus.waitingCustomerApproval ||
      JobCardStatus.pendingApproval ||
      JobCardStatus.awaitingSupervisor ||
      JobCardStatus.approved => 2,
      JobCardStatus.workAssigned ||
      JobCardStatus.inProgress ||
      JobCardStatus.waitingParts => 3,
      JobCardStatus.qualityCheck || JobCardStatus.qualityCheckPassed => 4,
      JobCardStatus.completed || JobCardStatus.delivered => 5,
      JobCardStatus.cancelled => 0,
    };

String jobStatusLabel(OwnerLocalizations t, JobCardStatus status) =>
    switch (status) {
      JobCardStatus.vehicleReceived => t.ownerJsReceived,
      JobCardStatus.inspected => t.ownerJsInspected,
      JobCardStatus.pending => t.ownerJsPending,
      JobCardStatus.pendingApproval => t.ownerJsPendingApproval,
      JobCardStatus.awaitingSupervisor => t.ownerJsAwaitSupervisor,
      JobCardStatus.approved => t.ownerJsApproved,
      JobCardStatus.workAssigned => t.ownerJsAssigned,
      JobCardStatus.inProgress => t.ownerJsProgress,
      JobCardStatus.waitingParts => t.ownerJsParts,
      JobCardStatus.qualityCheck => t.ownerJsQc,
      JobCardStatus.qualityCheckPassed => t.ownerJsQcPass,
      JobCardStatus.waitingCustomerApproval => t.ownerJsAwaitCustomer,
      JobCardStatus.completed => t.ownerJsComplete,
      JobCardStatus.delivered => t.ownerJsDelivered,
      JobCardStatus.cancelled => t.ownerJsCancelled,
    };

/// Single tone contract for every owner job pill (replaces the per-file
/// hardcoded hex maps): forward motion resolves info/success, waiting
/// resolves warning, cancellation resolves danger. Theme roles only.
Widget jobStatusPill(
  BuildContext context,
  OwnerLocalizations t,
  JobCardStatus status, {
  bool showDot = true,
}) {
  final label = jobStatusLabel(t, status);
  return switch (status) {
    JobCardStatus.completed ||
    JobCardStatus.delivered ||
    JobCardStatus.approved ||
    JobCardStatus.qualityCheckPassed =>
      StatusPill.success(label, showDot: showDot),
    JobCardStatus.cancelled => StatusPill.danger(label, showDot: showDot),
    JobCardStatus.inProgress => StatusPill.inProgress(label),
    JobCardStatus.vehicleReceived ||
    JobCardStatus.inspected ||
    JobCardStatus.workAssigned =>
      StatusPill.info(label, showDot: showDot),
    _ => StatusPill.warning(label, showDot: showDot),
  };
}
