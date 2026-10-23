import 'package:flutter/widgets.dart';
import 'package:shared_core/l10n/gen/shared_core_localizations.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';

/// Locale-aware, display-only formatting for dates, money, and quantities.
///
/// Product decision (frozen V5, money ruling): Latin digits are used in
/// **both** locales for all numeric data; identifiers (VIN, plate, phone,
/// refs) always stay Latin. Eastern Arabic numerals are explicitly out of
/// scope. Arabic therefore changes month names and ordinal copy — never the
/// digit glyphs — and money keeps the Latin `AED` code in both locales
/// (LTR-locked at call sites).
///
/// API payloads remain raw ISO-8601 strings / enums; formatting here never
/// feeds serialization.
class AppFormatters {
  /// Active locale.
  final Locale locale;

  final SharedCoreLocalizations? _l10n;

  const AppFormatters(this.locale, [this._l10n]);

  /// Builds a formatter bound to the ambient locale and copy.
  factory AppFormatters.of(BuildContext context) => AppFormatters(
        Localizations.localeOf(context),
        SharedCoreL10n.of(context),
      );

  bool get isArabic => locale.languageCode == 'ar';

  static const List<String> _monthsEn = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _monthsAr = <String>[
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static final RegExp _arabicDigits = RegExp(r'[\u0660-\u0669\u06F0-\u06F9]');
  static const String _arabicDigitChars = '٠١٢٣٤٥٦٧٨٩';
  static const String _arabicDigitCharsExtended = '۰۱۲۳۴۵۶۷۸۹';

  /// Forces Latin digits even if a caller passes localized text.
  static String _latinize(String value) {
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final idx = _arabicDigitChars.indexOf(char);
      final extIdx = _arabicDigitCharsExtended.indexOf(char);
      if (idx >= 0) {
        buffer.write(idx);
      } else if (extIdx >= 0) {
        buffer.write(extIdx);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  /// Full month name in the active locale (`October` / `أكتوبر`).
  String monthName(int month) {
    final months = isArabic ? _monthsAr : _monthsEn;
    return months[(month - 1).clamp(0, 11)];
  }

  /// Short month name (same table; future locales may shorten).
  String monthShort(int month) => monthName(month);

  /// `13 Oct 2026` / `13 أكتوبر 2026` — Latin digits in both locales.
  String date(DateTime date) =>
      '${date.day} ${monthName(date.month)} ${date.year}';

  /// `13 Oct` / `13 أكتوبر`.
  String dateShort(DateTime date) => '${date.day} ${monthShort(date.month)}';

  /// `09:30` — Latin digits, 24-hour.
  String time(DateTime date) => '${_two(date.hour)}:${_two(date.minute)}';

  /// `13 Oct 2026, 09:30`.
  String dateTime(DateTime date) => '${this.date(date)}, ${time(date)}';

  /// Locale-appropriate AED money: `AED 12,450` in BOTH locales.
  ///
  /// U10: the code stays Latin `AED` in Arabic too (same family as server
  /// codes/plates). The Arabic-script `د.إ` run broke under bidi mirroring
  /// and in Latin-only mono styles (rendered `E.E` with number-first order
  /// in ar goldens), so it is not used. Call sites keep the value inside an
  /// LTR `Directionality` with tabular figures so ar renders LTR-intact.
  /// Digits are always Western (0-9) with `,` grouping; numeric value verbatim.
  String moneyAED(num value) => 'AED ${group(value)}';

  /// Plain grouped quantity (`12,450`).
  String quantity(num value) => group(value);

  /// Grouped number honoring negatives, with at most 2 decimals.
  String group(num value) {
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

  /// `12%` / `12.4%` — Latin digits; trailing `.0` is trimmed.
  String percent(double fraction, {int decimals = 1}) {
    final value = (fraction * 100).toStringAsFixed(decimals);
    final trimmed =
        value.endsWith('.0') ? value.substring(0, value.length - 2) : value;
    return '$trimmed%';
  }

  /// Compact counts: `1.2K`, `1.2M`, `1.2B` (Latin digits).
  String compactCount(num value) {
    final negative = value < 0;
    final abs = value.abs();
    final (double scaled, String suffix) = abs >= 1e9
        ? (abs / 1e9, 'B')
        : abs >= 1e6
            ? (abs / 1e6, 'M')
            : abs >= 1e3
                ? (abs / 1e3, 'K')
                : (abs.toDouble(), '');
    final text = suffix.isEmpty
        ? group(abs)
        : '${_trimTrailingZero(scaled)} $suffix';
    return negative ? '-$text' : text;
  }

  static String _trimTrailingZero(double value) {
    final fixed = value.toStringAsFixed(1);
    return fixed.endsWith('.0')
        ? fixed.substring(0, fixed.length - 2)
        : fixed;
  }

  // ---------------------------------------------------------------------------
  // Phase-0b additions (additive; existing APIs unchanged). All new methods
  // follow the frozen Latin-digit policy: digits 0-9 and ',' grouping in
  // every locale; Arabic changes month names only (money keeps Latin `AED`).
  // ---------------------------------------------------------------------------

  /// Signed grouped quantity for deltas: `+12,450` / `-3` / `+0`.
  /// Pair with a success/error color or an up/down icon — never color alone.
  String signedGroup(num value) =>
      '${value < 0 ? '-' : '+'}${group(value.abs())}';

  /// Signed percent for deltas: `+12.4%` / `-3%`.
  String signedPercent(double fraction, {int decimals = 1}) {
    final magnitude = percent(fraction.abs(), decimals: decimals);
    return '${fraction < 0 ? '-' : '+'}$magnitude';
  }

  /// Fixed-decimal grouped number: `12,450.50` (decimals=2).
  String decimal(num value, {int decimals = 2}) {
    final negative = value < 0;
    final fixed = value.abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final grouped = group(num.parse(parts.first));
    final text = decimals > 0 ? '$grouped.${parts[1]}' : grouped;
    return negative ? '-$text' : text;
  }

  /// Compact money: `AED 1.2M` in BOTH locales (Latin code, LTR-locked
  /// at call sites; see [moneyAED]).
  String compactMoneyAED(num value) => 'AED ${compactCount(value)}';

  /// Locale-aware relative time (display only).
  String relativeTime(DateTime then, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final delta = reference.difference(then);
    final t = _l10n;
    if (delta.inSeconds < 60) {
      return t?.formatterJustNow ?? 'Just now';
    }
    if (delta.inMinutes < 60) {
      return t?.formatterMinutesAgo(delta.inMinutes) ?? '${delta.inMinutes}m ago';
    }
    if (delta.inHours < 24) {
      return t?.formatterHoursAgo(delta.inHours) ?? '${delta.inHours}h ago';
    }
    if (delta.inDays < 7) {
      return t?.formatterDaysAgo(delta.inDays) ?? '${delta.inDays}d ago';
    }
    if (delta.inDays < 30) {
      final weeks = (delta.inDays / 7).floor();
      return t?.formatterWeeksAgo(weeks) ?? '${weeks}w ago';
    }
    if (delta.inDays < 365) {
      final months = (delta.inDays / 30).floor();
      return t?.formatterMonthsAgo(months) ?? '${months}mo ago';
    }
    final years = (delta.inDays / 365).floor();
    return t?.formatterYearsAgo(years) ?? '${years}y ago';
  }

  /// True when [value] contains non-Latin (eastern Arabic) digits — used in
  /// tests to prove the Latin-digit policy holds.
  static bool containsNonLatinDigits(String value) =>
      _arabicDigits.hasMatch(value);

  /// Latinizes any eastern-Arabic digits in [value] (identifier safety net).
  static String latinize(String value) => _latinize(value);
}
