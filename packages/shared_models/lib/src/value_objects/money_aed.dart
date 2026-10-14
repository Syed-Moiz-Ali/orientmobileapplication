/// Money in UAE dirhams (Phase 01.2 foundation value object).
///
/// Canonical AED authority for display: formatting keeps Latin digits in both
/// locales (`AED 12,450` EN / `12,450 د.إ` AR) per the frozen V5 policy.
/// API payloads stay raw numbers; this type never feeds serialization.
///
/// Replaces ad-hoc `AED …` string interpolation scattered across features.
class MoneyAed {
  final double amount;

  const MoneyAed(this.amount);

  static const String currencyCode = 'AED';
  static const String currencySymbolAr = 'د.إ';

  /// True when the amount is finite (NaN / infinities are invalid).
  bool get isValid => amount.isFinite;

  /// True when the amount is a non-negative, finite value.
  bool get isNonNegative => isValid && amount >= 0;

  /// Grouped display: `AED 12,450` (EN) / `12,450 د.إ` (AR). Latin digits
  /// always; at most 2 decimals (trailing `.0` trimmed like `AppFormatters`).
  String format({bool arabic = false}) {
    final grouped = group(amount);
    return arabic ? '$grouped $currencySymbolAr' : '$currencyCode $grouped';
  }

  /// Plain grouped quantity (`12,450`, `-1,200.50`).
  static String group(num value) {
    final negative = value < 0;
    final abs = value.abs();
    final bool whole = abs == abs.roundToDouble();
    final bool oneDecimal = !whole && abs * 10 == (abs * 10).roundToDouble();
    final raw = abs.toStringAsFixed(whole ? 0 : (oneDecimal ? 1 : 2));
    final parts = raw.split('.');
    final digits = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    final text = parts.length > 1
        ? '${buffer.toString()}.${parts[1]}'
        : buffer.toString();
    return negative ? '-$text' : text;
  }

  /// Parses a user-entered amount (commas / `AED` / `د.إ` tolerated).
  /// Returns null when unparseable.
  static MoneyAed? tryParse(String raw) {
    var cleaned = raw.trim();
    cleaned = cleaned
        .replaceAll('AED', '')
        .replaceAll(currencySymbolAr, '')
        .replaceAll(',', '')
        .replaceAll(' ', '');
    // Latinize eastern-Arabic digits.
    cleaned = _latinize(cleaned);
    final value = double.tryParse(cleaned);
    if (value == null) return null;
    return MoneyAed(value);
  }

  static String _latinize(String value) {
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    const extended = '۰۱۲۳۴۵۶۷۸۹';
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final idx = eastern.indexOf(char);
      final ext = extended.indexOf(char);
      if (idx >= 0) {
        buffer.write(idx);
      } else if (ext >= 0) {
        buffer.write(ext);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is MoneyAed && other.amount == amount;

  @override
  int get hashCode => amount.hashCode;

  @override
  String toString() => 'MoneyAed(${format()})';
}
