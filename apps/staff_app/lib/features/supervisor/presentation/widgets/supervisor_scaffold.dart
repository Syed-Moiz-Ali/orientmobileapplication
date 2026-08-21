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

    return DashboardShell(
      appBar: SupervisorAppBar(selectedIndex: effectiveIndex),
      body: AppAdaptiveNavigationFrame(
        items: _navItems,
        selectedIndex: effectiveIndex,
        onSelected: notifier.selectTab,
        child: IndexedStack(index: effectiveIndex, children: _pages),
      ),
      bottomNavigationBar: adaptive.useNavigationRail
          ? null
          : AppBottomNavigation(
              items: _navItems,
              selectedIndex: effectiveIndex,
              onSelected: (index) {
                HapticFeedback.selectionClick();
                notifier.selectTab(index);
              },
              badgeIndices: notifier.bookings.isEmpty ? const {} : const {2},
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
