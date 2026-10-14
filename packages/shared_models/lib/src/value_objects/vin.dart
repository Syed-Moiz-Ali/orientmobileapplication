/// Vehicle Identification Number (Phase 01.2 foundation value object).
///
/// Canonical VIN authority: 17 uppercase Latin alphanumerics excluding
/// `I`, `O`, `Q` (ISO 3779). Display always stays Latin and LTR — callers
/// render it inside an LTR [Directionality]/`Text` even in RTL layouts.
/// Replaces ad-hoc VIN length checks in features.
class Vin {
  final String value;

  /// Display is always LTR.
  static const bool isLtr = true;

  /// 17 chars, A–Z0–9 minus I/O/Q.
  static final RegExp pattern = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');

  const Vin(this.value);

  /// Normalized display (uppercase, trimmed, Latin).
  String format() => value.trim().toUpperCase();

  bool get isValid => pattern.hasMatch(format());

  /// Parses and normalizes; returns null when invalid.
  static Vin? tryParse(String raw) {
    final candidate = Vin(raw.trim().toUpperCase());
    return candidate.isValid ? candidate : null;
  }

  @override
  bool operator ==(Object other) => other is Vin && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Vin($value)';
}
