import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_app_bar.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_dashboard_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_assign_sheet.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_jobs_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_staff_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_schedule_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_reports_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_queue_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_review_tab.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class SupervisorScaffold extends ConsumerWidget {
  const SupervisorScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: SupervisorAppBar(selectedIndex: state.selectedIndex),
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: state.selectedIndex,
            children: const [
              SupervisorDashboardTab(),
              SupervisorAssignSheet(),
              SupervisorJobsTab(),
              SupervisorQueueTab(),
              SupervisorReviewTab(),
              SupervisorStaffTab(),
              SupervisorScheduleTab(),
              SupervisorReportsTab(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _StreamlinedBottomNav(
              selectedIndex: state.selectedIndex,
              onTap: (index) {
                HapticFeedback.selectionClick();
                notifier.selectTab(index);
              },
              hasQueueBadge: notifier.bookings.isNotEmpty,
            ),
          ),
        ],
      ),
      floatingActionButton: state.selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await notifier.saveAndAssign();
                if (context.mounted) {
                  final msg = state.assignWorkSuccess.isNotEmpty
                      ? state.assignWorkSuccess
                      : state.assignWorkError.isNotEmpty
                      ? state.assignWorkError
                      : 'Assignments saved';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: state.assignWorkError.isNotEmpty ? colorScheme.error : colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 84),
                    ),
                  );
                }
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 4,
              icon: state.isAssignWorkLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2.5),
                    )
                  : Icon(Icons.save_rounded, color: colorScheme.onPrimary),
              label: Text(
                'Save & Assign',
                style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w800),
              ),
            )
          : null,
    );
  }
}

class _StreamlinedBottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  final bool hasQueueBadge;

  const _StreamlinedBottomNav({required this.selectedIndex, required this.onTap, this.hasQueueBadge = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Primary 4 Tabs mapped to their tab indices: 0: Dashboard, 1: Assign, 3: Queue, 4: Review
    const items = [
      _NavDef(index: 0, selectedIcon: Icons.dashboard_rounded, icon: Icons.dashboard_outlined, label: 'Command'),
      _NavDef(index: 1, selectedIcon: Icons.assignment_rounded, icon: Icons.assignment_outlined, label: 'Assign'),
      _NavDef(index: 3, selectedIcon: Icons.alt_route_rounded, icon: Icons.alt_route_outlined, label: 'Queue'),
      _NavDef(index: 4, selectedIcon: Icons.verified_rounded, icon: Icons.verified_outlined, label: 'Review'),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: items.map((item) {
              final isSelected = selectedIndex == item.index;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(item.index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.primary.withValues(alpha: 0.14) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            if (item.index == 3 && hasQueueBadge)
                              Positioned(
                                top: -2,
                                right: -4,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: textTheme.labelSmall?.copyWith(
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavDef {
  final int index;
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  const _NavDef({required this.index, required this.selectedIcon, required this.icon, required this.label});
}
