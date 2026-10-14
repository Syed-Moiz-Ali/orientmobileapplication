import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

/// Phase 01.2 — shared_models value objects: format / validate / LTR.
void main() {
  group('MoneyAed', () {
    test('formats EN with prefix and AR with suffix (Latin digits)', () {
      const money = MoneyAed(12450);
      expect(money.format(), 'AED 12,450');
      expect(money.format(arabic: true), '12,450 د.إ');
      expect(
        RegExp(r'[\u0660-\u0669\u06F0-\u06F9]').hasMatch(
          money.format(arabic: true),
        ),
        isFalse,
      );
    });

    test('groups decimals and negatives', () {
      expect(MoneyAed.group(1200.5), '1,200.5');
      expect(MoneyAed.group(-1500), '-1,500');
      expect(const MoneyAed(12450.75).format(), 'AED 12,450.75');
    });

    test('validates finiteness', () {
      expect(const MoneyAed(10).isValid, isTrue);
      expect(const MoneyAed(0).isNonNegative, isTrue);
      expect(const MoneyAed(-5).isNonNegative, isFalse);
      expect(
        const MoneyAed(double.nan).isValid,
        isFalse,
      );
    });

    test('parses user entry tolerantly', () {
      expect(MoneyAed.tryParse('AED 12,450')?.amount, 12450);
      expect(MoneyAed.tryParse('12,450 د.إ')?.amount, 12450);
      expect(MoneyAed.tryParse('nope'), isNull);
    });

    test('equality is by amount', () {
      expect(const MoneyAed(10), const MoneyAed(10));
      expect(const MoneyAed(10), isNot(const MoneyAed(11)));
    });
  });

  group('PlateNumber', () {
    test('formats normalized display', () {
      const plate = PlateNumber(emirate: 'DXB', code: 'A', number: '12345');
      expect(plate.format(), 'DXB A 12345');
      expect(plate.isValid, isTrue);
    });

    test('rejects unknown emirates and bad shapes', () {
      expect(
        const PlateNumber(emirate: 'XXX', code: 'A', number: '1').isValid,
        isFalse,
      );
      expect(
        const PlateNumber(emirate: 'DXB', code: 'ABC', number: '1').isValid,
        isFalse,
      );
      expect(
        const PlateNumber(emirate: 'DXB', code: 'A', number: '123456')
            .isValid,
        isFalse,
      );
    });

    test('parses canonical strings, rejects garbage', () {
      expect(PlateNumber.tryParse('dxb a 12345')?.format(), 'DXB A 12345');
      expect(PlateNumber.tryParse('A 12345'), isNull);
      expect(PlateNumber.tryParse('DXB A'), isNull);
      expect(PlateNumber.tryParse(''), isNull);
    });

    test('identifiers are LTR', () {
      expect(PlateNumber.isLtr, isTrue);
    });
  });

  group('Vin', () {
    test('accepts a valid 17-char VIN', () {
      const vin = Vin('WDBJF65J1YB040901');
      expect(vin.isValid, isTrue);
      expect(vin.format(), 'WDBJF65J1YB040901');
    });

    test('rejects short VINs and forbidden letters', () {
      expect(const Vin('SHORT').isValid, isFalse);
      expect(const Vin('WDBJF65J1YB0409I1').isValid, isFalse);
      expect(const Vin('WDBJF65J1YB0409O1').isValid, isFalse);
      expect(const Vin('WDBJF65J1YB0409Q1').isValid, isFalse);
    });

    test('parses case-insensitively, rejects garbage', () {
      expect(
        Vin.tryParse('wdbjf65j1yb040901')?.format(),
        'WDBJF65J1YB040901',
      );
      expect(Vin.tryParse('too short'), isNull);
    });

    test('identifiers are LTR', () {
      expect(Vin.isLtr, isTrue);
    });
  });

  group('PhoneNumber', () {
    test('formats E.164 spaced display', () {
      const phone = PhoneNumber('971501234567');
      expect(phone.e164, '+971501234567');
      expect(phone.format(), '+971 50 123 4567');
      expect(phone.formatNational(), '050 123 4567');
      expect(phone.isValid, isTrue);
    });

    test('rejects non-UAE numbers', () {
      expect(const PhoneNumber('14155552671').isValid, isFalse);
      expect(const PhoneNumber('97150123').isValid, isFalse);
    });

    test('parses local, national and international entry', () {
      expect(
        PhoneNumber.tryParse('0501234567')?.e164,
        '+971501234567',
      );
      expect(
        PhoneNumber.tryParse('501234567')?.e164,
        '+971501234567',
      );
      expect(
        PhoneNumber.tryParse('+971 50 123 4567')?.e164,
        '+971501234567',
      );
      expect(PhoneNumber.tryParse('123')?.isValid ?? false, isFalse);
    });

    test('identifiers are LTR', () {
      expect(PhoneNumber.isLtr, isTrue);
    });
  });
}
