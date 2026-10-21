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
/// (rail ≥ 600px, bottom nav below) with a spec-C8 [AppAppBar] that carries
/// the search trigger, the period selector (dashboard tab only), bell and
/// avatar. Offline state is announced once by the [OfflineBanner] (C16: no
/// permanent "Synced" pill); the bar stays a single 56px row whose actions
/// compress (icon search, capped period trigger, bell, avatar) so 320px and
/// 1.3x never overflow in LTR or ar.
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
      // C16: connectivity announces only when abnormal via the banner — no
      // permanent pill in the bar, never duplicated state.
      showOfflineBanner: true,
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
          // Spec-C8 bar (phase-1e-i): labels wrap to 2 lines and grow the
          // bar at 1.3x instead of mid-word ellipsis. Same 4 destinations,
          // same tab targets — only the bar widget changes.
          : AppBottomNav(
              items: [
                for (final item in items)
                  AppBottomNavItem(label: item.label, icon: item.icon),
              ],
              currentIndex: state.selectedIndex,
              onTap: notifier.selectTab,
            ),
    );

    return WorkspaceSearchShortcuts(
      onSearch: () => _openSearch(context, ref),
      child: shell,
    );
  }
}

/// Phase 07.1 centralized chrome (kept): the bespoke `OwnerAppBar` stays
/// deleted. The shell bar is the shared spec-C8 [AppAppBar] (56, no
/// elevation, hairline): screen title, back-to-overview on drill tabs, the
/// search trigger (U1 icon, same command palette), the period selector on
/// the dashboard tab, bell and avatar. Single row, compressed actions, no
/// offline pill (banner owns abnormal state per C16). Titles, tab targets,
/// palette contract, haptics and keys are unchanged.
class _OwnerChrome extends ConsumerWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final VoidCallback onSearch;

  const _OwnerChrome({required this.selectedIndex, required this.onSearch});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final notifier = ref.read(dashboardUiProvider.notifier);
    // Shell-fix round 2: the dashboard tab reuses the short nav label
    // (`Dashboard`, existing key) instead of the long bar title (`Owner
    // dashboard`): with search + period + bell + avatar in the 56px bar,
    // the 16-char title can never fit 320–360px without `…` on primary
    // text (U5), while the 9-char label fits every matrix cell incl.
    // 320px/1.3x/ar. Same destination, existing key, no new copy — flagged
    // for reviewer adjudication.
    final titles = <String>[
      t.ownerNavDashboard,
      t.ownerBarTopSales,
      t.ownerBarMessages,
      t.ownerBarActivity,
    ];

    return AppAppBar(
      title: titles[selectedIndex],
      showBack: selectedIndex != 0,
      onBack: selectedIndex == 0
          ? null
          : () {
              HapticFeedback.selectionClick();
              notifier.selectTab(0);
            },
      showDivider: true,
      actions: [
        AppIconButton(
          icon: Icons.search_rounded,
          tooltip: t.ownerSearchHint,
          onPressed: onSearch,
        ),
        if (selectedIndex == 0) const PeriodDropdown(),
        const NotificationBell(),
        SizedBox(
          width: 48,
          height: 48,
          child: Center(
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
        ),
      ],
    );
  }
}
