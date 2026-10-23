// Money ruling: Latin `AED` + Western digits in BOTH locales, LTR-locked.
//
// Locks the owner job-cards ar corruption (`2,450.00 E.E`): the Arabic-script
// `د.إ` run broke under bidi mirroring and in Latin-only mono styles, so the
// shared formatter now returns `AED ...` in ar too. Call sites keep the value
// inside an LTR `Directionality`. Numeric values verbatim — display only.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  const ar = Locale('ar');
  const en = Locale('en');

  group('moneyAED ar: Latin code + Western digits (no feed change)', () {
    test('ar uses the Latin AED prefix, not Arabic script', () {
      final f = AppFormatters(ar);
      expect(f.moneyAED(2450), 'AED 2,450');
      expect(f.moneyAED(2450), contains('AED'));
      expect(f.moneyAED(2450), isNot(contains('د.إ')));
    });

    test('both locales byte-identical for the same value', () {
      expect(AppFormatters(ar).moneyAED(12450), AppFormatters(en).moneyAED(12450));
      expect(AppFormatters(ar).moneyAED(12450), 'AED 12,450');
    });

    test('western digits only in ar', () {
      final f = AppFormatters(ar);
      for (final v in [0, 2450, 899.5, 12450, 1234567.89, -2450.5]) {
        expect(AppFormatters.containsNonLatinDigits(f.moneyAED(v)), isFalse,
            reason: 'moneyAED($v) in ar');
        expect(AppFormatters.containsNonLatinDigits(f.group(v)), isFalse);
      }
    });

    test('thousands grouping holds in ar', () {
      final f = AppFormatters(ar);
      expect(f.moneyAED(12450), 'AED 12,450');
      expect(f.moneyAED(1234567.89), 'AED 1,234,567.89');
    });

    test('large values group correctly', () {
      expect(AppFormatters(ar).moneyAED(1234567890), 'AED 1,234,567,890');
      expect(AppFormatters(en).moneyAED(1234567890), 'AED 1,234,567,890');
    });

    test('negative values keep the sign, same numeric value', () {
      expect(AppFormatters(ar).moneyAED(-2450.5), 'AED -2,450.5');
      expect(AppFormatters(ar).moneyAED(-3), 'AED -3');
      expect(AppFormatters(ar).group(-1234567.89), '-1,234,567.89');
    });

    test('zero: moneyAED trims to AED 0; fixed cents compose to AED 0.00', () {
      // moneyAED trims whole amounts (register uses formatAed2 for cents).
      expect(AppFormatters(ar).moneyAED(0), 'AED 0');
      expect(AppFormatters(en).moneyAED(0), 'AED 0');
      // Shared primitives compose fixed cents without changing the value:
      // formatAed2-equivalent `AED ` + group(head) + `.` + tail.
      final f = AppFormatters(ar);
      expect('AED ${f.decimal(0)}', 'AED 0.00');
      expect('AED ${f.decimal(2450)}', 'AED 2,450.00');
      expect('AED ${f.decimal(899.5)}', 'AED 899.50');
    });

    test('compact money stays Latin in ar', () {
      expect(AppFormatters(ar).compactMoneyAED(1200000), 'AED 1.2 M');
      expect(AppFormatters(ar).compactMoneyAED(48000), contains('AED'));
      expect(
        AppFormatters.containsNonLatinDigits(
          AppFormatters(ar).compactMoneyAED(1200000),
        ),
        isFalse,
      );
    });
  });

  group('RTL placement: LTR-locked span inside an RTL paragraph', () {
    testWidgets('ar money stays LTR-intact inside RTL', (tester) async {
      final money = AppFormatters(ar).moneyAED(2450);
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: _LtrMoneyProbe(value: 'AED 2,450'),
        ),
      );
      // The inner span forces LTR even though the ambient is RTL.
      final inner = tester.widget<Directionality>(
        find.byKey(const Key('money-ltr')),
      );
      expect(inner.textDirection, TextDirection.ltr);
      expect(find.text(money), findsOneWidget);
      // Code stays leading (currency-first) in ar, digits intact.
      expect(money.startsWith('AED '), isTrue);
    });
  });
}

/// Minimal probe: RTL ambient paragraph with the money in an LTR isolate,
/// mirroring every redesigned call site (`Directionality(ltr)` + tabular).
class _LtrMoneyProbe extends StatelessWidget {
  final String value;
  const _LtrMoneyProbe({required this.value});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      key: const Key('money-ltr'),
      textDirection: TextDirection.ltr,
      child: Text(
        value,
        textDirection: TextDirection.ltr,
        style: const TextStyle(
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
