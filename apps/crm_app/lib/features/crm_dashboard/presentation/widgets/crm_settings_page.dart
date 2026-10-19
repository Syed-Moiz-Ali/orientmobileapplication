import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

/// Workspace settings: the three real provider toggles plus the shared
/// language switcher. Every row maps 1:1 to a provider bool — no invented
/// routing selectors, no fake sync toggles.
class CrmSettingsPage extends ConsumerWidget {
  const CrmSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.cx;
    final state = ref.watch(crmUiProvider);
    final notifier = ref.read(crmUiProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    return AppResponsivePage(
      maxContentWidth: 720,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            eyebrow: t.seWorkspace,
            title: t.seTitle,
            subtitle: t.seSub,
            leading: const Icon(Icons.tune_rounded),
          ),
          SizedBox(height: context.adaptive.sectionSpacing),
          SectionHeader(title: t.seWorkflow),
          const SizedBox(height: AppDimensions.s10),
          AppRecordRow(
            leading: _SettingIcon(
              icon: Icons.notifications_outlined,
              color: colors.primary,
            ),
            title: t.sePush,
            subtitle: t.sePushBody,
            trailing: Switch.adaptive(
              value: state.notificationsEnabled,
              onChanged: (_) => notifier.toggleNotifications(),
            ),
          ),
          const SizedBox(height: AppDimensions.s10),
          AppRecordRow(
            leading: _SettingIcon(
              icon: Icons.alt_route_rounded,
              color: colors.tertiary,
            ),
            title: t.seAutoAssign,
            subtitle: t.seAutoAssignBody,
            trailing: Switch.adaptive(
              value: state.autoAssign,
              onChanged: (_) => notifier.toggleAutoAssign(),
            ),
          ),
          SizedBox(height: context.adaptive.sectionSpacing),
          SectionHeader(title: t.seAppearance),
          const SizedBox(height: AppDimensions.s10),
          AppRecordRow(
            leading: _SettingIcon(
              icon: Icons.dark_mode_outlined,
              color: colors.secondary,
            ),
            title: t.seDark,
            subtitle: t.seDarkBody,
            trailing: Switch.adaptive(
              value: state.darkMode,
              onChanged: (_) => notifier.toggleDarkMode(),
            ),
          ),
          const SizedBox(height: AppDimensions.s10),
          // Phase 02: minimal language entry point (self-labeling).
          const LanguageSwitcher(),
          const SizedBox(height: AppDimensions.s16),
          Text(
            t.seLangNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SettingIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimensions.r10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
