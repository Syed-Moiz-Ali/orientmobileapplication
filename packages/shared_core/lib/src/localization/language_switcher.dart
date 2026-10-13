import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/src/localization/locale_provider.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/app_bottom_sheet.dart';
import 'package:shared_core/src/widgets/app_record_row.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// A single record row that shows the active language and opens the shared
/// language picker. Apps place this in their profile / settings surface.
///
/// Uses the shared [AppRecordRow] grammar so it matches every other settings
/// row; the picker opens as a bottom sheet on phones and a bounded dialog on
/// tablets/desktop via [showAppModalSheet].
class LanguageSwitcher extends ConsumerWidget {
  final bool showSubtitle;

  const LanguageSwitcher({super.key, this.showSubtitle = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = SharedCoreL10n.of(context);
    final theme = Theme.of(context);
    final selected = ref.watch(localeProvider) ?? Localizations.localeOf(context);
    final currentLabel =
        selected.languageCode == 'ar' ? t.commonArabic : t.commonEnglish;

    return AppRecordRow(
      leading: Icon(
        Icons.language_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: t.commonLanguage,
      subtitle: showSubtitle ? currentLabel : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppDimensions.s4),
          DirectionalIcon(
            Icons.chevron_right_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: () => showLanguagePickerSheet(context),
    );
  }
}

/// Opens the language picker (bottom sheet on compact, dialog on ≥600 px).
Future<void> showLanguagePickerSheet(BuildContext context) {
  return showAppModalSheet<void>(
    context: context,
    title: SharedCoreL10n.of(context).commonSelectLanguage,
    builder: (sheetContext) => const _LanguageOptions(),
  );
}

class _LanguageOptions extends ConsumerWidget {
  const _LanguageOptions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = SharedCoreL10n.of(context);
    final theme = Theme.of(context);
    final selected = ref.watch(localeProvider) ?? Localizations.localeOf(context);

    final options = <({String code, String label})>[
      (code: 'en', label: t.commonEnglish),
      (code: 'ar', label: t.commonArabic),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in options)
          ListTile(
            title: Text(option.label),
            trailing: option.code == selected.languageCode
                ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).setLanguage(option.code);
              Navigator.of(context).maybePop();
            },
          ),
      ],
    );
  }
}
