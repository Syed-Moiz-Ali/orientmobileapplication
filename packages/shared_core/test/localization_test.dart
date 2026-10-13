import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  group('AppLocales', () {
    test('declares exactly English and Arabic', () {
      expect(
        AppLocales.supported.map((l) => l.languageCode).toList(),
        ['en', 'ar'],
      );
      expect(AppLocales.fallback.languageCode, 'en');
    });

    test('resolves persisted → system → English fallback', () {
      expect(
        AppLocales.resolve(persisted: const Locale('ar'), system: const Locale('en')),
        const Locale('ar'),
      );
      expect(
        AppLocales.resolve(system: const Locale('ar')),
        const Locale('ar'),
      );
      expect(
        AppLocales.resolve(system: const Locale('fr')),
        AppLocales.fallback,
      );
      expect(
        AppLocales.resolve(persisted: const Locale('de')),
        AppLocales.fallback,
      );
    });

    test('isSupported matches by language code', () {
      expect(AppLocales.isSupported(const Locale('ar', 'AE')), isTrue);
      expect(AppLocales.isSupported(const Locale('en')), isTrue);
      expect(AppLocales.isSupported(const Locale('fr')), isFalse);
      expect(AppLocales.isSupported(null), isFalse);
    });
  });

  group('LocaleController persistence', () {
    setUpAll(() async {
      final dir = await Directory.systemTemp.createTemp('orient_locale_test');
      Hive.init(dir.path);
      await Hive.openBox<dynamic>(kSettingsBoxName);
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    test('persists and reads back the selected language', () async {
      final controller = LocaleController();
      expect(controller.state, isNull);

      await controller.setLocale(const Locale('ar'));
      expect(controller.state, const Locale('ar'));
      expect(LocaleController.readPersisted(), const Locale('ar'));
      expect(Hive.box<dynamic>(kSettingsBoxName).get(kLocaleStorageKey), 'ar');

      await controller.setLocale(const Locale('en'));
      expect(LocaleController.readPersisted(), const Locale('en'));

      await controller.setLocale(null);
      expect(controller.state, isNull);
      expect(LocaleController.readPersisted(), isNull);
      expect(Hive.box<dynamic>(kSettingsBoxName).get(kLocaleStorageKey), isNull);
    });

    test('ignores unsupported persisted values', () async {
      await Hive.box<dynamic>(kSettingsBoxName).put(kLocaleStorageKey, 'fr');
      expect(LocaleController.readPersisted(), isNull);
      await Hive.box<dynamic>(kSettingsBoxName).delete(kLocaleStorageKey);
    });
  });

  group('AppFormatters', () {
    final en = AppFormatters(const Locale('en'));
    final ar = AppFormatters(const Locale('ar'));

    test('money is locale-appropriate and uses Latin digits', () {
      expect(en.moneyAED(12450), 'AED 12,450');
      expect(ar.moneyAED(12450), '12,450 د.إ');
      expect(AppFormatters.containsNonLatinDigits(ar.moneyAED(12450)), isFalse);
    });

    test('quantities group with Latin digits in both locales', () {
      expect(en.quantity(1234567), '1,234,567');
      expect(ar.quantity(1234567), '1,234,567');
      expect(en.quantity(-980), '-980');
    });

    test('percent trims trailing zeros', () {
      expect(en.percent(0.124), '12.4%');
      expect(ar.percent(0.12), '12%');
    });

    test('compact counts use K/M/B suffixes', () {
      expect(en.compactCount(950), '950');
      expect(en.compactCount(1200), '1.2 K');
      expect(en.compactCount(1200000), '1.2 M');
    });

    test('dates localize month names but keep Latin digits', () {
      final date = DateTime(2026, 10, 13);
      expect(en.date(date), '13 Oct 2026');
      expect(ar.date(date), '13 أكتوبر 2026');
      expect(AppFormatters.containsNonLatinDigits(ar.date(date)), isFalse);
      expect(en.time(DateTime(2026, 10, 13, 9, 5)), '09:05');
    });

    test('latinize converts eastern-arabic digits', () {
      expect(AppFormatters.latinize('٤٨٢٠٠'), '48200');
    });
  });

  group('Arabic typography', () {
    test('forLocale switches family and applies ×1.05 line height', () {
      final latin = AppTypography.forLocale(const Locale('en'));
      final arabic = AppTypography.forLocale(const Locale('ar'));

      expect(latin.bodyMedium!.fontFamily, AppFontFamilies.app);
      expect(arabic.bodyMedium!.fontFamily, AppFontFamilies.arabic);
      expect(arabic.bodyMedium!.fontFamilyFallback, AppFontFamilies.arabicFallback);
      expect(arabic.bodyMedium!.letterSpacing, 0);
      expect(
        arabic.bodyMedium!.height,
        closeTo(latin.bodyMedium!.height! * 1.05, 0.0001),
      );
    });

    test('mono roles stay Latin in Arabic', () {
      final mono = AppTextStyles.mono(arabic: true);
      expect(mono.fontFamily, AppFontFamilies.mono);
      expect(mono.fontFamilyFallback, isNull);
    });

    test('IBM Plex Sans Arabic assets are bundled', () {
      for (final file in const [
        'IBMPlexSansArabic-Regular.ttf',
        'IBMPlexSansArabic-Medium.ttf',
        'IBMPlexSansArabic-SemiBold.ttf',
        'IBMPlexSansArabic-Bold.ttf',
      ]) {
        expect(
          File('assets/fonts/ibm_plex_sans_arabic/$file').existsSync(),
          isTrue,
          reason: '$file must be bundled under shared_core',
        );
      }
    });
  });
}
