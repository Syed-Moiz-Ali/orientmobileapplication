import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class CrmAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CrmUiNotifier notifier;

  const CrmAppBar({super.key, required this.notifier});

  static const _titles = [
    'Sales workspace',
    'Leads',
    'Conversations',
    'Sales team',
    'Tasks',
    'Reports',
    'Integrations',
    'Settings',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final useRail = context.adaptive.useNavigationRail;

    return AppBar(
      backgroundColor: colors.surface,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      leading: useRail
          ? Icon(Icons.hub_outlined, color: colors.primary)
          : Builder(
              builder: (scaffoldContext) => IconButton(
                tooltip: 'Open navigation',
                onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _titles[notifier.selectedIndex],
            style: theme.textTheme.titleMedium,
          ),
          Text(
            'Orient CRM · Bircon, Hifri',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh workspace',
          onPressed: notifier.refresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        const NotificationBell(),
        Padding(
          padding: const EdgeInsets.only(right: AppDimensions.s12),
          child: UserAvatar(
            initials: 'A',
            onTap: () => showProfileSheet(context, _profileData),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(color: colors.outline),
      ),
    );
  }
}

const _profileData = ProfileSheetData(
  name: 'Admin',
  initials: 'A',
  roleLabel: 'CRM administrator',
  roleBadge: 'Admin',
  branch: 'Bircon, Hifri',
);
