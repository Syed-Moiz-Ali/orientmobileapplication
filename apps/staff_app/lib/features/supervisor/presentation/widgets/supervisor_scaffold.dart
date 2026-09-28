import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/common/presentation/profile_screen.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_app_bar.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_assign_sheet.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_dashboard_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_queue_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_review_tab.dart';

class SupervisorScaffold extends ConsumerWidget {
  const SupervisorScaffold({super.key});

  static const _navItems = <AppNavItem>[
    AppNavItem(
      selectedIcon: Icons.dashboard_rounded,
      icon: Icons.dashboard_outlined,
      label: 'Today',
    ),
    AppNavItem(
      selectedIcon: Icons.assignment_rounded,
      icon: Icons.assignment_outlined,
      label: 'Assign',
    ),
    AppNavItem(
      selectedIcon: Icons.alt_route_rounded,
      icon: Icons.alt_route_outlined,
      label: 'Queue',
    ),
    AppNavItem(
      selectedIcon: Icons.verified_rounded,
      icon: Icons.verified_outlined,
      label: 'Review',
    ),
    AppNavItem(
      selectedIcon: Icons.person_rounded,
      icon: Icons.person_outlined,
      label: 'Profile',
    ),
  ];

  static const _pages = <Widget>[
    SupervisorDashboardTab(),
    SupervisorAssignSheet(),
    SupervisorQueueTab(),
    SupervisorReviewTab(),
    StaffProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final adaptive = context.adaptive;
    final effectiveIndex = state.selectedIndex < _pages.length
        ? state.selectedIndex
        : 0;
    final queueBadges = notifier.bookings.isEmpty
        ? const <int>{}
        : const <int>{2};

    return DashboardShell(
      appBar: SupervisorAppBar(selectedIndex: effectiveIndex),
      body: AppAdaptiveNavigationFrame(
        items: _navItems,
        selectedIndex: effectiveIndex,
        onSelected: notifier.selectTab,
        badgeIndices: queueBadges,
        headerBuilder: (ctx, ext) =>
            OrientBrandMark(workspace: 'Supervisor', compact: !ext),
        footerBuilder: (ctx, ext) => InkWell(
          onTap: () => notifier.selectTab(4),
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
                        backgroundColor: Theme.of(
                          ctx,
                        ).colorScheme.primary.withValues(alpha: 0.14),
                        child: Text(
                          'S',
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
                          'Supervisor Profile',
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
                    message: 'Supervisor Profile',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(
                        ctx,
                      ).colorScheme.primary.withValues(alpha: 0.14),
                      child: Text(
                        'S',
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
        child: IndexedStack(index: effectiveIndex, children: _pages),
      ),
      bottomNavigationBar: adaptive.useNavigationRail
          ? null
          : AppBottomNavigation(
              items: _navItems,
              selectedIndex: effectiveIndex,
              onSelected: notifier.selectTab,
              badgeIndices: queueBadges,
            ),
      floatingActionButton: effectiveIndex == 1
          ? FloatingActionButton.extended(
              onPressed: state.isAssignWorkLoading
                  ? null
                  : () async {
                      HapticFeedback.mediumImpact();
                      await notifier.saveAndAssign();
                      if (!context.mounted) return;
                      final message = state.assignWorkSuccess.isNotEmpty
                          ? state.assignWorkSuccess
                          : state.assignWorkError.isNotEmpty
                          ? state.assignWorkError
                          : 'Assignments saved';
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    },
              icon: state.isAssignWorkLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                state.isAssignWorkLoading ? 'Saving' : 'Save and assign',
              ),
            )
          : null,
    );
  }
}
