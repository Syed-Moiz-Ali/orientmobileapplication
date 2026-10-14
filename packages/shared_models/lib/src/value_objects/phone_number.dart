/// UAE phone number (Phase 01.2 foundation value object).
///
/// Canonical phone authority: E.164 (`+971501234567`) with a spaced display
/// (`+971 50 123 4567`). Digits always stay Latin and LTR — callers render
/// with an LTR [Directionality]/`Text` even in RTL layouts. Replaces the
/// duplicated `replaceAll(RegExp(r'[^\d]'))` phone munging in
/// `LoginNotifier` and features.
class PhoneNumber {
  /// E.164 digits without the leading `+` (e.g. `971501234567`).
  final String e164Digits;

  /// Display is always LTR.
  static const bool isLtr = true;

  static const String defaultCountryCode = '+971';

  const PhoneNumber(this.e164Digits);

  /// `+971501234567`.
  String get e164 => '+$e164Digits';

  /// `+971 50 123 4567` (Latin digits, LTR-safe).
  String format() {
    final d = e164Digits;
    if (d.length == 12 && d.startsWith('971')) {
      final national = d.substring(3);
      return '+971 ${national.substring(0, 2)} '
          '${national.substring(2, 5)} ${national.substring(5)}';
    }
    return e164;
  }

  /// National display without country code (`050 123 4567`).
  String formatNational() {
    final d = e164Digits;
    if (d.length == 12 && d.startsWith('971')) {
      final national = d.substring(3);
      return '0${national.substring(0, 2)} '
          '${national.substring(2, 5)} ${national.substring(5)}';
    }
    return e164;
  }

  /// Valid E.164 for the UAE: `971` + 9 digits starting with 5.
  bool get isValid => RegExp(r'^9715\d{8}$').hasMatch(e164Digits);

  /// Normalizes user entry (`0501234567`, `501234567`, `+971…`, spaces and
  /// dashes tolerated) to E.164 digits. Returns null when unparseable.
  static PhoneNumber? tryParse(String raw, {String countryCode = '+971'}) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    final cc = countryCode.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return null;
    final String normalized;
    if (digits.startsWith(cc)) {
      normalized = digits;
    } else if (digits.startsWith('0')) {
      normalized = '$cc${digits.substring(1)}';
    } else if (digits.length <= 10) {
      normalized = '$cc$digits';
    } else {
      normalized = digits;
    }
    final candidate = PhoneNumber(normalized);
    return candidate.isValid ? candidate : null;
  }

  /// Lenient normalization that never returns null (for search/SMS payloads);
  /// prefer [tryParse] for validation.
  static String normalizeLoose(String raw, {String countryCode = '+971'}) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    final cc = countryCode.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith(cc)) return digits;
    if (digits.startsWith('0')) return '$cc${digits.substring(1)}';
    return '$cc$digits';
  }

  @override
  bool operator ==(Object other) =>
      other is PhoneNumber && other.e164Digits == e164Digits;

  @override
  int get hashCode => e164Digits.hashCode;

  @override
  String toString() => 'PhoneNumber(${format()})';
}
