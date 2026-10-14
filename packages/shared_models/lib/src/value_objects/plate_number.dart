/// UAE vehicle plate number (Phase 01.2 foundation value object).
///
/// Canonical plate authority: `EMIRATE CODE NUMBER` (e.g. `DXB A 12345`,
/// `AUH 12 34567`). Display always stays Latin and LTR — callers render it
/// inside `Directionality(textDirection: TextDirection.ltr)` even in RTL
/// layouts — per the frozen V5 identifier policy. Replaces ad-hoc plate
/// string munging in features.
class PlateNumber {
  /// Emirate code (`DXB`, `AUH`, `SHJ`, `AJM`, `UAQ`, `RAK`, `FUJ`).
  final String emirate;

  /// Plate code (1–2 Latin letters, e.g. `A`, `AB`).
  final String code;

  /// Plate digits (1–5 Latin digits).
  final String number;

  /// Display is always LTR: render inside an LTR [Directionality]/`Text`
  /// even in RTL layouts.
  static const bool isLtr = true;

  static const Set<String> emirates = {
    'DXB',
    'AUH',
    'SHJ',
    'AJM',
    'UAQ',
    'RAK',
    'FUJ',
  };

  static final RegExp _codePattern = RegExp(r'^[A-Z]{1,2}$');
  static final RegExp _numberPattern = RegExp(r'^\d{1,5}$');

  const PlateNumber({
    required this.emirate,
    required this.code,
    required this.number,
  });

  /// Normalized display: `DXB A 12345` (Latin, LTR).
  String format() => '$emirate $code $number';

  bool get isValid =>
      emirates.contains(emirate) &&
      _codePattern.hasMatch(code) &&
      _numberPattern.hasMatch(number);

  /// Parses `EMIRATE CODE NUMBER` (extra spaces tolerated, case-insensitive).
  /// Returns null when the shape is wrong.
  static PlateNumber? tryParse(String raw) {
    final parts = raw
        .trim()
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length != 3) return null;
    final candidate = PlateNumber(
      emirate: parts[0],
      code: parts[1],
      number: parts[2],
    );
    return candidate.isValid ? candidate : null;
  }

  @override
  bool operator ==(Object other) =>
      other is PlateNumber &&
      other.emirate == emirate &&
      other.code == code &&
      other.number == number;

  @override
  int get hashCode => Object.hash(emirate, code, number);

  @override
  String toString() => 'PlateNumber(${format()})';
}
