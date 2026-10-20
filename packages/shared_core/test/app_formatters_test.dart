// Phase-0b: formatter unit tests (en + ar).
//
// Locks the frozen product decision: Latin digits (0-9) and ',' grouping in
// BOTH locales. Arabic changes month names and currency placement — never
// the digit glyphs. Existing APIs and the four new additive ones are covered.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  const en = Locale('en');
  const ar = Locale('ar');

  group('digits policy (both locales use Latin digits)', () {
    test('grouped output contains no eastern-Arabic digits', () {
      for (final locale in [en, ar]) {
        final f = AppFormatters(locale);
        expect(AppFormatters.containsNonLatinDigits(f.group(12450)), isFalse);
        expect(
          AppFormatters.containsNonLatinDigits(f.moneyAED(12450)),
          isFalse,
        );
        expect(
          AppFormatters.containsNonLatinDigits(f.compactCount(1200000)),
          isFalse,
        );
        expect(
          AppFormatters.containsNonLatinDigits(
            f.date(DateTime(2026, 10, 20)),
          ),
          isFalse,
        );
      }
    });

    test('ar uses western digits by default (not ٠١٢٣)', () {
      final f = AppFormatters(ar);
      expect(f.group(12450), '12,450');
      expect(f.moneyAED(12450), contains('12,450'));
    });
  });

  group('grouping', () {
    test('en groups with commas, negatives, decimals', () {
      final f = AppFormatters(en);
      expect(f.group(12450), '12,450');
      expect(f.group(-3), '-3');
      expect(f.group(1234567.89), '1,234,567.89');
      expect(f.group(0), '0');
    });

    test('ar grouping identical to en', () {
      final f = AppFormatters(ar);
      expect(f.group(1234567.89), '1,234,567.89');
    });
  });

  group('currency', () {
    test('en: AED prefix', () {
      expect(AppFormatters(en).moneyAED(12450), 'AED 12,450');
    });

    test('ar: suffix placement, Latin digits', () {
      expect(AppFormatters(ar).moneyAED(12450), '12,450 د.إ');
    });

    test('compact money both locales', () {
      // Existing compactCount style keeps a space before the suffix.
      expect(AppFormatters(en).compactMoneyAED(1200000), 'AED 1.2 M');
      expect(AppFormatters(ar).compactMoneyAED(1200000), '1.2 M د.إ');
    });
  });

  group('dates', () {
    test('en date parts', () {
      final f = AppFormatters(en);
      expect(f.date(DateTime(2026, 10, 20)), '20 Oct 2026');
      expect(f.dateShort(DateTime(2026, 1, 5)), '5 Jan');
      expect(f.time(DateTime(2026, 10, 20, 9, 5)), '09:05');
    });

    test('ar month names, Latin digits', () {
      final f = AppFormatters(ar);
      expect(f.date(DateTime(2026, 10, 20)), '20 أكتوبر 2026');
    });
  });

  group('relative time (fixed clock)', () {
    final now = DateTime(2026, 10, 20, 12);
    test('en buckets', () {
      final f = AppFormatters(en);
      expect(
        f.relativeTime(now.subtract(const Duration(seconds: 30)), now: now),
        'Just now',
      );
      expect(
        f.relativeTime(now.subtract(const Duration(minutes: 5)), now: now),
        '5m ago',
      );
      expect(
        f.relativeTime(now.subtract(const Duration(hours: 3)), now: now),
        '3h ago',
      );
      expect(
        f.relativeTime(now.subtract(const Duration(days: 2)), now: now),
        '2d ago',
      );
    });

    test('ar falls back to latin-digit short forms without delegates', () {
      final f = AppFormatters(ar);
      expect(
        f.relativeTime(now.subtract(const Duration(minutes: 5)), now: now),
        '5m ago',
      );
    });
  });

  group('signed deltas (phase-0b additions)', () {
    test('signedGroup always shows an explicit sign', () {
      final f = AppFormatters(en);
      expect(f.signedGroup(12450), '+12,450');
      expect(f.signedGroup(-3), '-3');
      expect(f.signedGroup(0), '+0');
    });

    test('signedPercent keeps percent formatting', () {
      final f = AppFormatters(en);
      expect(f.signedPercent(0.124), '+12.4%');
      expect(f.signedPercent(-0.03), '-3%');
    });

    test('decimal fixes fraction digits', () {
      final f = AppFormatters(en);
      expect(f.decimal(12450.5), '12,450.50');
      expect(f.decimal(-7, decimals: 0), '-7');
    });
  });
}
