import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/src/localization/app_locales.dart';

/// Hive box that stores user preferences. Registered by [HiveRegistry].
const String kSettingsBoxName = 'settings';

/// Key inside [kSettingsBoxName] that stores the selected language code
/// (`'en'` / `'ar'`). Absent means "follow the system locale".
const String kLocaleStorageKey = 'app_locale';

/// Owns the selected application locale. `null` means "follow the system
/// locale" — the app then resolves supported system → English fallback via
/// [AppLocales.resolve].
///
/// The single source of truth for locale state in the process. Writes are
/// persisted to the shared Hive settings box; reads happen at construction time
/// (after [HiveRegistry.initHive]) so the first frame already renders in the
/// persisted language.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController([super.initialState]);

  /// Reads the persisted selection without requiring a delegate; returns `null`
  /// when nothing valid is stored (or Hive is not available, e.g. tests).
  static Locale? readPersisted() {
    if (!Hive.isBoxOpen(kSettingsBoxName)) return null;
    final dynamic raw = Hive.box<dynamic>(kSettingsBoxName).get(kLocaleStorageKey);
    final String? code = raw is String ? raw : raw?.toString();
    if (code == null || code.isEmpty) return null;
    final Locale locale = Locale(code);
    return AppLocales.isSupported(locale) ? locale : null;
  }

  /// Applies [locale] immediately and persists the choice. `null` clears the
  /// override so the app follows the system locale again.
  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (!Hive.isBoxOpen(kSettingsBoxName)) return;
    final box = Hive.box<dynamic>(kSettingsBoxName);
    if (locale == null) {
      await box.delete(kLocaleStorageKey);
    } else {
      await box.put(kLocaleStorageKey, locale.languageCode);
    }
  }

  /// Convenience for switchers that work with a language code.
  Future<void> setLanguage(String? languageCode) => setLocale(
        (languageCode == null || languageCode.isEmpty)
            ? null
            : Locale(languageCode),
      );

  /// Toggles between English and Arabic.
  Future<void> toggle() => setLocale(
        state?.languageCode == 'ar'
            ? const Locale('en')
            : const Locale('ar'),
      );
}

/// The active locale selection. `null` = follow system. Hydrated from Hive
/// before the first frame.
final localeProvider = StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController(LocaleController.readPersisted());
});
