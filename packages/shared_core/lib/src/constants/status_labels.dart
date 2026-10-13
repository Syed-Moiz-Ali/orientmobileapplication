import 'package:flutter/widgets.dart';
import 'package:shared_core/l10n/gen/shared_core_localizations.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';

/// One canonical vocabulary for status strings across all apps.
///
/// **Phase 02:** status labels are now locale-aware. Read them through
/// [AppStatusLabels.of] inside a widget build:
///
/// ```dart
/// final labels = AppStatusLabels.of(context);
/// StatusPill(label: labels.booking(job.status));
/// ```
///
/// The legacy static methods (`booking`, `breakdown`, `invoice`,
/// `normalizeJob`) are retained as an English-only compatibility shim so
/// existing feature screens keep compiling; each feature phase migrates its
/// call sites to `AppStatusLabels.of` and the shims are removed in Phase 20.
abstract final class AppStatusLabels {
  AppStatusLabels._();

  static final LocalizedStatusLabels _english =
      LocalizedStatusLabels(lookupSharedCoreLocalizations(const Locale('en')));

  /// Locale-aware labels for the active [context]'s locale.
  static LocalizedStatusLabels of(BuildContext context) =>
      LocalizedStatusLabels(SharedCoreL10n.of(context));

  // ---------------------------------------------------------------------------
  // Legacy English-only compatibility shims (Phase 02).
  //
  // These stay so existing feature screens keep compiling; the locale-aware
  // replacement is `AppStatusLabels.of(context).<method>`. They are intentionally
  // NOT annotated `@Deprecated` yet: doing so would introduce analyzer warnings
  // in the feature apps before their owning phases (see the Phase 02 report's
  // per-app migration list). Phase 20 removes them once every call site has
  // migrated.
  // ---------------------------------------------------------------------------

  /// Legacy English-only. Prefer `AppStatusLabels.of(context).booking(...)`.
  static String booking(String? status) => _english.booking(status);

  /// Legacy English-only. Prefer `AppStatusLabels.of(context).breakdown(...)`.
  static String breakdown(String? status) => _english.breakdown(status);

  /// Legacy English-only. Prefer `AppStatusLabels.of(context).invoice(...)`.
  static String invoice(String? status) => _english.invoice(status);

  /// Legacy English-only. Prefer `AppStatusLabels.of(context).normalizeJob(...)`.
  static String normalizeJob(String? raw) => _english.normalizeJob(raw);
}

/// Locale-aware status label set, obtained from [AppStatusLabels.of].
class LocalizedStatusLabels {
  final SharedCoreLocalizations _t;

  const LocalizedStatusLabels(this._t);

  /// Booking / service job status (backend enum values).
  String booking(String? status) {
    switch (status) {
      case 'pending':
        return _t.statusPending;
      case 'confirmed':
        return _t.statusConfirmed;
      case 'vehicleReceived':
      case 'vehicle_received':
        return _t.statusVehicleReceived;
      case 'approved':
        return _t.statusApproved;
      case 'workAssigned':
        return _t.statusWorkAssigned;
      case 'inProgress':
      case 'in_service':
        return _t.statusInService;
      case 'delivered':
        return _t.statusDelivered;
      case 'completed':
        return _t.statusCompleted;
      case 'cancelled':
        return _t.statusCancelled;
      case 'approvalRequired':
      case 'waitingCustomerApproval':
        return _t.statusApprovalRequired;
      default:
        return status ?? '';
    }
  }

  /// Breakdown status.
  String breakdown(String? status) {
    switch (status) {
      case 'pending':
        return _t.statusPending;
      case 'inProgress':
      case 'dispatched':
        return _t.statusInProgress;
      case 'resolved':
        return _t.statusResolved;
      case 'cancelled':
        return _t.statusCancelled;
      default:
        return status ?? '';
    }
  }

  /// Invoice status.
  String invoice(String? status) {
    switch (status) {
      case 'paid':
        return _t.statusPaid;
      case 'partial':
        return _t.statusPartiallyPaid;
      case 'overdue':
        return _t.statusOverdue;
      case 'unpaid':
        return _t.statusUnpaid;
      default:
        return status ?? '';
    }
  }

  /// The canonical label for any of the raw forms a screen may hold:
  /// "in_service", "inProgress", "In Progress" all map to one string.
  String normalizeJob(String? raw) {
    final v = (raw ?? '').toLowerCase();
    switch (v) {
      case 'pending':
      case 'awaiting':
        return _t.statusPending;
      case 'confirmed':
        return _t.statusConfirmed;
      case 'vehicle_received':
        return _t.statusVehicleReceived;
      case 'in_service':
      case 'inprogress':
      case 'in progress':
      case 'working':
        return _t.statusInService;
      case 'waiting_parts':
      case 'waiting parts':
        return _t.statusWaitingParts;
      case 'completed':
      case 'done':
        return _t.statusCompleted;
      case 'cancelled':
      case 'canceled':
        return _t.statusCancelled;
      case 'rejected':
      case 'sent_back':
        return _t.statusSentBack;
      default:
        return raw ?? '';
    }
  }
}
