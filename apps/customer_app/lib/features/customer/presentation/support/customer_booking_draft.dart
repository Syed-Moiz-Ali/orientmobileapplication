import 'package:shared_core/shared_core.dart';

/// Pure helpers for the booking wizard draft.
///
/// Everything here is presentation composition over values the workshop
/// already published (catalogue names/prices) or the customer typed
/// (notes, address). No endpoint, payload key or validation rule changes:
/// multi-select names travel in the existing `serviceType` string field and
/// the valet choice travels inside the existing free-text `notes` field
/// (the backend rejects unknown keys, so no new key may be added).
class CustomerBookingDraft {
  /// The `serviceType` value for the selected catalogue entries, in
  /// catalogue order: `Major Service + AC Refresh`.
  static String serviceNames(List<ServiceTypeResponse> services) =>
      services.map((s) => s.name.trim()).where((n) => n.isNotEmpty).join(' + ');

  /// The `notes` value: the customer's typed note plus the valet pick-up
  /// line when valet is chosen. The valet marker stays English because the
  /// workshop operations queue reads English; it is data, not UI copy.
  static String notesWithValet({
    required String typed,
    required bool valet,
    required String address,
  }) {
    final base = typed.trim();
    if (!valet) return base;
    const marker = 'Valet pick-up:';
    final line = '$marker ${address.trim()}';
    if (base.isEmpty) return line;
    return '$base\n$line';
  }

  /// A catalogue price (`AED 1,450`) to its numeric value, or null when the
  /// workshop left the entry unpriced.
  static double? parsePrice(String raw) {
    final cleaned = raw.replaceAll(',', '');
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(cleaned);
    if (match == null) return null;
    return double.tryParse(match.group(0)!);
  }

  /// `1570` → `AED 1,570`. Whole dirhams render without decimals; fractional
  /// values keep up to two.
  static String formatAed(double value) {
    final whole = value.truncate();
    final grouped = whole
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    final fraction = value - whole;
    if (fraction.abs() < 0.005) return 'AED $grouped';
    return 'AED $grouped.${((fraction * 100).round()).toString().padLeft(2, '0')}';
  }

  /// Running total over the selected entries, or null when any selected
  /// entry has no parseable price (the dock then says the total is
  /// confirmed at the workshop instead of inventing one).
  static double? totalFor(List<ServiceTypeResponse> services) {
    if (services.isEmpty) return null;
    var total = 0.0;
    for (final service in services) {
      final price = parsePrice(service.price);
      if (price == null) return null;
      total += price;
    }
    return total;
  }
}
