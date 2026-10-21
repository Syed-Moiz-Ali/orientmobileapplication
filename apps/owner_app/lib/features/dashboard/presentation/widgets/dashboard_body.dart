import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/core/models/profile_data.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/messages_page.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_activity_feed_tab.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_dashboard_page.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_search.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/top_sales_page.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/period_dropdown.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

List<AppNavItem> _ownerNavItems(OwnerLocalizations t) => <AppNavItem>[
      AppNavItem(
        selectedIcon: Icons.dashboard_rounded,
        icon: Icons.dashboard_outlined,
        label: t.ownerNavDashboard,
      ),
      AppNavItem(
        selectedIcon: Icons.leaderboard_rounded,
        icon: Icons.leaderboard_outlined,
        label: t.ownerNavTopSales,
      ),
      AppNavItem(
        selectedIcon: Icons.chat_bubble_rounded,
        icon: Icons.chat_bubble_outline_rounded,
        label: t.ownerNavMessages,
      ),
      AppNavItem(
        selectedIcon: Icons.notifications_rounded,
        icon: Icons.notifications_outlined,
        label: t.ownerNavActivity,
      ),
    ];

/// Owner shell: the shared [DashboardShell] + [AppAdaptiveNavigationFrame]
/// (rail ≥ 600px, bottom nav below) with a frosted [WorkspaceAppBar] that
/// carries the period selector, search trigger, offline pill, bell and
/// avatar. The pill owns offline state, so the full-width banner stays off.
class DashboardBody extends ConsumerWidget {
  const DashboardBody({super.key});

  static const _pages = <Widget>[
    OwnerDashboardPage(),
    TopSalesPage(),
    MessagesPage(),
    OwnerActivityFeedTab(),
  ];

  void _openSearch(BuildContext context, WidgetRef ref) =>
      openOwnerSearch(context, ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final items = _ownerNavItems(t);
    final notifier = ref.read(dashboardUiProvider.notifier);
    final adaptive = context.adaptive;
    final state = ref.watch(dashboardUiProvider);

    final shell = DashboardShell(
      // The app-bar pill announces connectivity; the banner stays off so
      // offline state is never duplicated.
      showOfflineBanner: false,
      appBar: _OwnerChrome(
        selectedIndex: state.selectedIndex,
        onSearch: () => _openSearch(context, ref),
      ),
      body: AppAdaptiveNavigationFrame(
        items: items,
        selectedIndex: state.selectedIndex,
        onSelected: notifier.selectTab,
        headerBuilder: (ctx, ext) => OrientBrandMark(
          workspace: t.ownerShellWorkspace,
          compact: !ext,
        ),
        footerBuilder: (ctx, ext) => InkWell(
          onTap: () => notifier.selectTab(3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ext ? AppDimensions.s8 : 0,
              vertical: AppDimensions.s4,
            ),
            child: ext
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(ctx)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.14),
                        child: Text(
                          ownerProfileData.initials,
                          style: TextStyle(
                            color: Theme.of(ctx).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s10),
                      Expanded(
                        child: Text(
                          t.ownerShellSuite,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(ctx).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  )
                : Tooltip(
                    message: t.ownerShellSuite,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(ctx)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.14),
                      child: Text(
                        ownerProfileData.initials,
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        child: IndexedStack(index: state.selectedIndex, children: _pages),
      ),
      bottomNavigationBar: adaptive.useNavigationRail
          ? null
          : AppBottomNavigation(
              items: items,
              selectedIndex: state.selectedIndex,
              onSelected: notifier.selectTab,
            ),
    );

    return WorkspaceSearchShortcuts(
      onSearch: () => _openSearch(context, ref),
      child: shell,
    );
  }
}

/// Phase 07.1 centralized chrome (kept): the bespoke `OwnerAppBar` stays
/// deleted — titles, branch subtitle, back-to-overview leading, the period
/// selector, search trigger, offline pill, bell and avatar compose the shared
/// [WorkspaceAppBar]. Desktop renders frosted (with the built-in
/// reduced-transparency fallback); the search trigger opens the command
/// palette of real destinations.
class _OwnerChrome extends ConsumerWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final VoidCallback onSearch;

  const _OwnerChrome({required this.selectedIndex, required this.onSearch});

  @override
  Size get preferredSize => const Size.fromHeight(57);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final notifier = ref.read(dashboardUiProvider.notifier);
    final titles = <String>[
      t.ownerBarDashboard,
      t.ownerBarTopSales,
      t.ownerBarMessages,
      t.ownerBarActivity,
    ];
    final subtitles = <String?>[
      ownerProfileData.branch,
      t.ownerBarTopSalesSub,
      t.ownerBarMessagesSub,
      t.ownerBarActivitySub,
    ];

    return WorkspaceAppBar(
      title: titles[selectedIndex],
      subtitle: subtitles[selectedIndex],
      toolbarHeight: 56,
      // Frosted on desktop; the widget falls back to a solid surface when
      // the platform requests reduced transparency.
      frosted: !context.isCompact,
      contextSelector:
          selectedIndex == 0 ? const PeriodDropdown() : null,
      onSearch: onSearch,
      // Connectivity pill; no queued-operations count exists in the owner
      // app, so the pill reports connectivity only — never a fabricated zero.
      showOfflineStatus: true,
      leading: selectedIndex == 0
          ? Icon(
              Icons.directions_car_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            )
          : IconButton(
              tooltip: t.ownerBarBack,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                HapticFeedback.selectionClick();
                notifier.selectTab(0);
              },
            ),
      actions: [
        const NotificationBell(),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: UserAvatar(
            initials: ownerProfileData.initials,
            onTap: () {
              HapticFeedback.selectionClick();
              showProfileSheet(
                context,
                ownerProfileData,
                onLogout: () {
                  ref.read(authNotifierProvider.notifier).logout();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
