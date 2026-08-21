import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/core/models/profile_data.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/period_dropdown.dart';

class OwnerAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const OwnerAppBar({super.key});

  static const _titles = [
    'Owner Dashboard',
    'Top Sales',
    'Messages',
    'Activity',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppBar(
      backgroundColor: colors.surface,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      leading: state.selectedIndex == 0
          ? Icon(Icons.directions_car_rounded, color: colors.primary, size: 24)
          : IconButton(
              tooltip: 'Back to overview',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => notifier.selectTab(0),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _titles[state.selectedIndex],
            style: theme.textTheme.titleMedium,
          ),
          Text(
            state.selectedIndex == 0
                ? ownerProfileData.branch
                : _subtitles(state.selectedIndex),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        if (state.selectedIndex == 0)
          const Padding(
            padding: EdgeInsets.only(right: 6),
            child: PeriodDropdown(),
          ),
        const NotificationBell(),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: UserAvatar(
            initials: ownerProfileData.initials,
            onTap: () => showProfileSheet(
              context,
              ownerProfileData,
              onLogout: () {
                ref.read(authNotifierProvider.notifier).logout();
              },
            ),
          ),
        ),
      ],
    );
  }

  static String _subtitles(int index) {
    switch (index) {
      case 1:
        return 'Performance Breakdown by Category';
      case 2:
        return 'Internal Messaging';
      case 3:
        return 'Workshop Activity Feed';
      default:
        return '';
    }
  }
}
