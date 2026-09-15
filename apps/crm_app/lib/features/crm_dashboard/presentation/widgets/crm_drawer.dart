import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

/// CRM exposes eight top-level destinations, which is too many for a phone
/// bottom bar, so it keeps the drawer pattern — now rendered with the shared
/// navigation language so it matches every other Orient workspace.
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
    final colors = Theme.of(context).colorScheme;
    final leadCount = ref.watch(crmLeadProvider).length;

    return AppNavDrawer(
      title: 'Orient CRM',
      subtitle: 'Sales workspace',
      icon: Icons.hub_outlined,
      items: _items,
      selectedIndex: notifier.selectedIndex,
      badgeCounts: leadCount > 0 ? {1: leadCount} : const <int, int>{},
      onSelected: (index) {
        notifier.selectTab(index);
        Navigator.pop(context);
      },
      footer: Padding(
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
    );
  }
}
