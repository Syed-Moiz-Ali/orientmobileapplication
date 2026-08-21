import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class CrmSettingsPage extends ConsumerWidget {
  const CrmSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmUiProvider);
    final notifier = ref.read(crmUiProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    return AppResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppPageHeader(
            eyebrow: 'Workspace',
            title: 'Settings',
            subtitle:
                'Control how your team receives work and how new leads enter the queue.',
            leading: Icon(Icons.tune_rounded),
          ),
          SizedBox(height: context.adaptive.sectionSpacing),
          Text('Workflow', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppDimensions.s10),
          AppRecordRow(
            leading: _SettingIcon(
              icon: Icons.notifications_outlined,
              color: colors.primary,
            ),
            title: 'Push notifications',
            subtitle: 'Alert me when a new lead or customer message arrives.',
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
            title: 'Automatically assign leads',
            subtitle:
                'Route incoming leads to available salespeople using the team queue.',
            trailing: Switch.adaptive(
              value: state.autoAssign,
              onChanged: (_) => notifier.toggleAutoAssign(),
            ),
          ),
          SizedBox(height: context.adaptive.sectionSpacing),
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppDimensions.s10),
          AppRecordRow(
            leading: _SettingIcon(
              icon: Icons.dark_mode_outlined,
              color: colors.secondary,
            ),
            title: 'Dark appearance',
            subtitle:
                'Use the darker workspace palette when your app theme supports it.',
            trailing: Switch.adaptive(
              value: state.darkMode,
              onChanged: (_) => notifier.toggleDarkMode(),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          Text(
            'Appearance preferences are saved to this workspace profile.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
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
