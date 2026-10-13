import 'package:flutter/widgets.dart';

/// Single source of truth for the locale contract shared by every application.
///
/// Defined once in `shared_core` so no app can drift from the supported set.
/// Priority order for the active locale is: persisted user selection →
/// system locale (when supported) → [fallback] (English).
abstract final class AppLocales {
  AppLocales._();

  /// Languages shipped by the Orient suite. Adding a locale happens here only.
  static const List<Locale> supported = <Locale>[Locale('en'), Locale('ar')];

  /// Fallback when neither a persisted selection nor a supported system locale
  /// exists.
  static const Locale fallback = Locale('en');

  /// True when [locale]'s language is one of the supported languages.
  static bool isSupported(Locale? locale) {
    if (locale == null) return false;
    return supported.any((l) => l.languageCode == locale.languageCode);
  }

  /// Resolves the effective locale with the documented priority order.
  static Locale resolve({Locale? persisted, Locale? system}) {
    if (isSupported(persisted)) return persisted!;
    if (isSupported(system)) return system!;
    return fallback;
  }
}
