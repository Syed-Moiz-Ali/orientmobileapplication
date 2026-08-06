import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/src/l10n/app_locale.dart';
import 'package:shared_core/src/theme/app_colors.dart';

/// FE-FIX (frontend pass): language picker (English / العربية) that flips the
/// whole app to RTL. Persisted in Hive via [appLocaleProvider].
class LanguageSwitcherTile extends ConsumerWidget {
  const LanguageSwitcherTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appLocaleProvider);
    return ListTile(
      leading: const Icon(Icons.language_rounded, color: AppColors.accent),
      title: const Text(
        'Language',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        AppLocales.displayName(current),
        style: const TextStyle(fontSize: 12, color: AppColors.text3),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App Language',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                for (final locale in AppLocales.supported)
                  ListTile(
                    leading: Icon(
                      locale.languageCode == current.languageCode
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    title: Text(
                      AppLocales.displayName(locale),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: locale.languageCode == current.languageCode
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onTap: () {
                      ref.read(appLocaleProvider.notifier).setLocale(locale);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
