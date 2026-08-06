import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// FE-FIX (frontend pass): shared locale/RTL infrastructure.
///
/// Honest scope: this wires the locale plumbing (English + Arabic) so the
/// apps are READY for Arabic — system strings (date pickers, back buttons,
/// text direction) localize automatically and the UI flips to RTL. The
/// in-app English strings are NOT translated yet (a full AR string pass is a
/// separate task).
abstract final class AppLocales {
  static const supported = [Locale('en'), Locale('ar')];
  static const fallback = Locale('en');

  static bool isRtl(Locale l) => l.languageCode == 'ar';
  static String displayName(Locale l) =>
      l.languageCode == 'ar' ? 'العربية' : 'English';
}

class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final box = Hive.box<dynamic>('app_settings');
    final saved = box.get('locale') as String? ?? 'en';
    return saved == 'ar' ? const Locale('ar') : AppLocales.fallback;
  }

  Future<void> setLocale(Locale locale) async {
    await Hive.box<dynamic>('app_settings').put('locale', locale.languageCode);
    state = locale;
  }
}

final appLocaleProvider =
    NotifierProvider<AppLocaleNotifier, Locale>(AppLocaleNotifier.new);
