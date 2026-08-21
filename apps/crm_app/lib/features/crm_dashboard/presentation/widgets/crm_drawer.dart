import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class CrmDrawer extends ConsumerWidget {
  final CrmUiNotifier notifier;

  const CrmDrawer({super.key, required this.notifier});

  static const _items = <AppNavItem>[
    AppNavItem(
      selectedIcon: Icons.dashboard_rounded,
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
    ),
    AppNavItem(
      selectedIcon: Icons.person_search_rounded,
      icon: Icons.person_search_outlined,
      label: 'Leads',
    ),
    AppNavItem(
      selectedIcon: Icons.chat_bubble_rounded,
      icon: Icons.chat_bubble_outline_rounded,
      label: 'Conversations',
    ),
    AppNavItem(
      selectedIcon: Icons.groups_rounded,
      icon: Icons.groups_outlined,
      label: 'Sales team',
    ),
    AppNavItem(
      selectedIcon: Icons.task_alt_rounded,
      icon: Icons.task_outlined,
      label: 'Tasks',
    ),
    AppNavItem(
      selectedIcon: Icons.bar_chart_rounded,
      icon: Icons.bar_chart_outlined,
      label: 'Reports',
    ),
    AppNavItem(
      selectedIcon: Icons.power_rounded,
      icon: Icons.power_outlined,
      label: 'Integrations',
    ),
    AppNavItem(
      selectedIcon: Icons.settings_rounded,
      icon: Icons.settings_outlined,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final leadCount = ref.watch(crmLeadProvider).length;

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCard,
                      ),
                    ),
                    child: Icon(
                      Icons.hub_outlined,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Orient CRM', style: theme.textTheme.titleMedium),
                        Text(
                          'Sales workspace',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: colors.outline),
            Expanded(
              child: NavigationDrawer(
                selectedIndex: notifier.selectedIndex,
                onDestinationSelected: (index) {
                  notifier.selectTab(index);
                  Navigator.pop(context);
                },
                children: [
                  for (var index = 0; index < _items.length; index++)
                    NavigationDrawerDestination(
                      icon: index == 1 && leadCount > 0
                          ? Badge(
                              label: Text('$leadCount'),
                              child: Icon(_items[index].icon),
                            )
                          : Icon(_items[index].icon),
                      selectedIcon: Icon(_items[index].selectedIcon),
                      label: Text(_items[index].label),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s12),
              child: AppRecordRow(
                leading: const UserAvatar(initials: 'A'),
                title: 'Admin',
                subtitle: 'CRM administrator',
                trailing: Icon(Icons.logout_rounded, color: colors.error),
                onTap: () async {
                  final confirmed = await showLogoutDialog(context);
                  if (confirmed == true && context.mounted) {
                    await ref.read(authNotifierProvider.notifier).logout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
