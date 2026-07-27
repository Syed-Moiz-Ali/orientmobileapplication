import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_app_bar.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_dashboard_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_assign_sheet.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_jobs_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_staff_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_schedule_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_reports_tab.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class SupervisorScaffold extends ConsumerWidget {
  const SupervisorScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.navy,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return DashboardShell(
      appBar: SupervisorAppBar(selectedIndex: state.selectedIndex),
      body: IndexedStack(
        index: state.selectedIndex,
        children: const [
          SupervisorDashboardTab(),
          SupervisorAssignSheet(),
          SupervisorJobsTab(),
          SupervisorStaffTab(),
          SupervisorScheduleTab(),
          SupervisorReportsTab(),
        ],
      ),
      floatingActionButton: state.selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                await notifier.saveAndAssign();
                ref.read(syncEngineProvider).syncAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assignments saved locally'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              backgroundColor: AppColors.accent,
              elevation: 4,
              icon: state.isAssignWorkLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.save_rounded, color: Colors.white),
              label: const Text(
                'Save & Assign',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            )
          : null,
      bottomNavigationBar: _BottomNav(
        selectedIndex: state.selectedIndex,
        onTap: notifier.selectTab,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
      (Icons.assignment_rounded, Icons.assignment_outlined, 'Assign'),
      (Icons.list_alt_rounded, Icons.list_alt_outlined, 'Work List'),
      (Icons.groups_rounded, Icons.groups_outlined, 'Staff'),
      (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Schedule'),
      (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Reports'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: List.generate(items.length, (i) {
              final sel = selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primaryBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppDimensions.r24),
                        ),
                        child: Icon(
                          sel ? items[i].$1 : items[i].$2,
                          color: sel ? AppColors.accent : AppColors.text3,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].$3,
                        style: TextStyle(
                          fontSize: 11,
                          color: sel ? AppColors.accent : AppColors.text3,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                          letterSpacing: sel ? 0.2 : 0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
