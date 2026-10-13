// PROVISIONAL formatting helpers.
//
// Decision recorded for the whole program (00_VISUAL_DIRECTION.md V5):
// Latin digits everywhere including Arabic; tabular figures for all
// money/quantity data. EN money: `AED 12,450` · AR money: `12,450 د.إ`.
// Phase 02 replaces these helpers with locale-aware `AppFormatters` (`intl`).
import 'package:flutter/widgets.dart';

abstract final class ProtoFormat {
  ProtoFormat._();

  static const List<String> _monthsEn = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const List<String> _monthsAr = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static bool isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  /// `1234567.5` → `1,234,567.5` (no locale digit shaping, by decision).
  static String group(num value) {
    final negative = value < 0;
    final abs = value.abs();
    final raw = abs.toStringAsFixed(abs == abs.roundToDouble() ? 0 : (abs * 10 == (abs * 10).roundToDouble() ? 1 : 2));
    final parts = raw.split('.');
    final digits = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    final text = parts.length > 1 ? '${buffer.toString()}.${parts[1]}' : buffer.toString();
    return negative ? '-$text' : text;
  }

  /// AED money in the locale-appropriate order.
  static String money(BuildContext context, num value) {
    final grouped = group(value);
    return isArabic(context) ? '$grouped د.إ' : 'AED $grouped';
  }

  static String count(BuildContext context, num value) => group(value);

  static String percent(BuildContext context, double fraction, {int decimals = 1}) {
    final value = (fraction * 100).toStringAsFixed(decimals);
    // Trim trailing ".0" so "+12%" reads cleanly.
    final trimmed = value.endsWith('.0') ? value.substring(0, value.length - 2) : value;
    return '$trimmed%';
  }

  /// `13 Oct 2026` / `13 أكتوبر 2026`.
  static String date(BuildContext context, DateTime date) {
    final months = isArabic(context) ? _monthsAr : _monthsEn;
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String monthShort(BuildContext context, int month) {
    final months = isArabic(context) ? _monthsAr : _monthsEn;
    return months[(month - 1).clamp(0, 11)];
  }

  /// `09:30` – identifiers/time stay Latin digits in both locales.
  static String time(BuildContext context, String raw) => raw;
}
