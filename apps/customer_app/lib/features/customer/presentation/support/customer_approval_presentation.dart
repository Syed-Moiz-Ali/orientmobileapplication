import 'package:flutter/material.dart';

/// Presentation-only vocabulary for one estimate approval decision.
///
/// The backend stores the decision in `Approval.action` with the values
/// `pending`, `approved` and `rejected` (see CustomerApprovalService), and this
/// is the single place that turns those into customer-facing wording and tone —
/// so the list, the detail and every attention surface describe the same
/// decision the same way. Unknown values are passed through untouched rather
/// than guessed.
abstract final class CustomerApprovalPresentation {
  CustomerApprovalPresentation._();

  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';

  static String normalize(String? raw) => (raw ?? '').trim().toLowerCase();

  /// True while the customer still has to decide.
  static bool isPending(String? raw) => normalize(raw) == pending;

  /// True once the customer has decided (approved or rejected).
  static bool isDecided(String? raw) {
    final value = normalize(raw);
    return value == approved || value == rejected;
  }

  /// `Awaiting approval`, `Approved`, `Rejected`, or the raw backend value when
  /// it is something this product does not know yet.
  static String statusLabel(String? raw) {
    switch (normalize(raw)) {
      case pending:
        return 'Awaiting approval';
      case approved:
        return 'Approved';
      case rejected:
        return 'Rejected';
      default:
        return (raw ?? '').trim();
    }
  }

  /// Semantic tone shared with the booking surfaces: a pending decision is
  /// urgent, an approved estimate is positive, and a rejection is a neutral
  /// customer choice — never an application error.
  static Color statusTone(ColorScheme colors, String? raw) {
    switch (normalize(raw)) {
      case pending:
        return colors.error;
      case approved:
        return colors.tertiary;
      case rejected:
        return colors.onSurfaceVariant;
      default:
        return colors.primary;
    }
  }

  /// A real line total, using the documented per-line fields: quantity × rate
  /// less the line's own discount. Returns null when the backend did not send
  /// enough to state an amount honestly.
  ///
  /// The estimate's own `servicesTotal`/`partsTotal`/`grandTotal` always come
  /// from the API and stay authoritative.
  static double? lineAmount(double price, int quantity, double discount) {
    if (price <= 0 && quantity <= 0) return null;
    final gross = price * (quantity <= 0 ? 1 : quantity);
    final net = gross - (discount > 0 ? discount : 0);
    return net < 0 ? 0 : net;
  }
}
