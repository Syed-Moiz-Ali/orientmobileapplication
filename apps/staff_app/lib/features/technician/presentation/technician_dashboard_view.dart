import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_header_widget.dart';
import 'package:staff_app/features/technician/presentation/widgets/attendance_section.dart';
import 'package:staff_app/features/technician/presentation/widgets/productivity_section.dart';
import 'package:staff_app/features/technician/presentation/widgets/assigned_jobs_section.dart';
import 'package:staff_app/features/technician/presentation/widgets/job_detail_sheet.dart';

class TechnicianDashboardView extends ConsumerWidget {
  const TechnicianDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _TechBody();
  }
}

class _TechBody extends ConsumerWidget {
  const _TechBody();

  static const _pages = <Widget>[_DashboardTab(), _EfficiencyTab()];
  static const _navItems = <AppNavItem>[
    AppNavItem(
      selectedIcon: Icons.dashboard_rounded,
      icon: Icons.dashboard_outlined,
      label: 'Today',
    ),
    AppNavItem(
      selectedIcon: Icons.assignment_turned_in_rounded,
      icon: Icons.assignment_outlined,
      label: 'My jobs',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final adaptive = context.adaptive;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return DashboardShell(
      body: Column(
        children: [
          const TechnicianHeaderWidget(),
          Divider(height: 1, color: colorScheme.outlineVariant),
          if (!adaptive.useNavigationRail) ...[
            _TechTabBar(
              selectedTab: state.selectedTab,
              onTap: notifier.selectTab,
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
          ],
          Expanded(
            child: AppAdaptiveNavigationFrame(
              items: _navItems,
              selectedIndex: state.selectedTab,
              onSelected: notifier.selectTab,
              child: IndexedStack(index: state.selectedTab, children: _pages),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechTabBar extends StatelessWidget {
  final int selectedTab;
  final void Function(int) onTap;
  const _TechTabBar({required this.selectedTab, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    const tabs = [
      AppNavItem(
        selectedIcon: Icons.dashboard_rounded,
        icon: Icons.dashboard_outlined,
        label: 'Dashboard',
      ),
      AppNavItem(
        selectedIcon: Icons.assignment_turned_in_rounded,
        icon: Icons.assignment_outlined,
        label: 'My Jobs',
      ),
    ];

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final sel = selectedTab == i;
          return Expanded(
            child: Semantics(
              button: true,
              selected: sel,
              label: tabs[i].label,
              child: InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        sel ? tabs[i].selectedIcon : tabs[i].icon,
                        size: 20,
                        color: sel
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tabs[i].label,
                        style: textTheme.labelLarge?.copyWith(
                          color: sel
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: notifier.refresh,
      child: AppResponsivePage(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.s16,
                vertical: AppDimensions.s12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppDimensions.r2),
                    ),
                  ),
                  SizedBox(width: AppDimensions.s10),
                  Text(
                    'Technician Dashboard',
                    style: AppTextStyles.title(color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: notifier.refresh,
                    child: state.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.accent,
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            color: AppColors.text3,
                            size: 20,
                          ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.border),
            SizedBox(height: AppDimensions.s14),
            const AttendanceSection(),
            SizedBox(height: AppDimensions.s16),
            const ProductivitySection(),
            SizedBox(height: AppDimensions.s16),
            const AssignedJobsSection(),
            SizedBox(height: AppDimensions.s24),
          ],
        ),
      ),
    );
  }
}

class _EfficiencyTab extends ConsumerWidget {
  const _EfficiencyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: notifier.refresh,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _KpiChip(
                        label: 'Total',
                        value: '${notifier.totalJobs}',
                        color: AppColors.accent,
                        bg: AppColors.accent.withValues(alpha: 0.12),
                      ),
                      SizedBox(width: AppDimensions.s8),
                      _KpiChip(
                        label: 'In Progress',
                        value: '${notifier.inProgressJobs}',
                        color: AppColors.warning,
                        bg: AppColors.warningBg,
                      ),
                      SizedBox(width: AppDimensions.s8),
                      _KpiChip(
                        label: 'Done',
                        value: '${notifier.completedJobs}',
                        color: AppColors.success,
                        bg: AppColors.successBg,
                      ),
                      SizedBox(width: AppDimensions.s8),
                      _KpiChip(
                        label: 'Delayed',
                        value: '${notifier.delayedJobs}',
                        color: AppColors.danger,
                        bg: AppColors.dangerBg,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: notifier.updateSearch,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search job card, vehicle, plate...',
                            hintStyle: AppTextStyles.subtitle(
                              color: AppColors.text3,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: AppColors.text3,
                              size: 18,
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 11,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r12,
                              ),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r12,
                              ),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r12,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.accent,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.s10),
                      Container(
                        height: 44,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.s10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.r12,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list_rounded,
                              color: AppColors.text3,
                              size: 16,
                            ),
                            SizedBox(width: AppDimensions.s4),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.selectedFilter,
                                dropdownColor: AppColors.surface,
                                style: AppTextStyles.bodySmall(
                                  color: AppColors.textPrimary,
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.text3,
                                  size: 16,
                                ),
                                onChanged: (v) =>
                                    notifier.updateFilter(v ?? 'All Status'),
                                items: notifier.filterOptions
                                    .map(
                                      (f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(f),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.s10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.r12),
                    ),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 3, child: _ColHead('JOB CARD #')),
                      Expanded(flex: 2, child: _ColHead('DATE')),
                      Expanded(flex: 2, child: _ColHead('BRAND')),
                      Expanded(flex: 2, child: _ColHead('MODEL')),
                      Expanded(flex: 2, child: _ColHead('PLATE')),
                      Expanded(flex: 2, child: _ColHead('STATUS')),
                    ],
                  ),
                ),
              ),
              notifier.filteredJobs.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.text3,
                            ),
                            SizedBox(height: AppDimensions.s12),
                            Text(
                              'No jobs found',
                              style: AppTextStyles.bodyStrong(
                                color: AppColors.text3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final job = notifier.filteredJobs[i];
                        return _JobRow(
                          job: job,
                          isEven: i % 2 == 0,
                          onTap: () => _openDetail(context, ref, job),
                        );
                      }, childCount: notifier.filteredJobs.length),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(
    BuildContext context,
    WidgetRef ref,
    TechnicianJobEntity job,
  ) {
    ref.read(technicianDashboardProvider.notifier).openJob(job);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobDetailSheet(job: job),
    ).whenComplete(() {
      ref.read(technicianDashboardProvider.notifier).closeJob();
    });
  }
}

class _KpiChip extends StatelessWidget {
  final String label, value;
  final Color color, bg;
  const _KpiChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.s10,
          vertical: AppDimensions.s10,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.r14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.displaySmall(color: color)),
            Text(
              label,
              style: AppTextStyles.bodySmall(color: AppColors.text3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColHead extends StatelessWidget {
  final String text;
  const _ColHead(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.bodySmall(color: AppColors.accent));
}

class _JobRow extends StatelessWidget {
  final TechnicianJobEntity job;
  final bool isEven;
  final VoidCallback onTap;
  const _JobRow({required this.job, required this.isEven, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppDimensions.s16),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.s12,
          vertical: AppDimensions.s14,
        ),
        decoration: BoxDecoration(
          color: isEven ? AppColors.surface : AppColors.surfaceAlt,
          border: Border(
            left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                job.jobCardNo,
                style: AppTextStyles.bodySmall(color: AppColors.accent),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                job.dateOfWork,
                style: TextStyle(color: AppColors.text2, fontSize: 11),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                job.vehicleBrand,
                style: TextStyle(color: AppColors.text2, fontSize: 11),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                job.vehicleModel,
                style: TextStyle(color: AppColors.text2, fontSize: 11),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                job.plateNumber,
                style: TextStyle(color: AppColors.text2, fontSize: 11),
              ),
            ),
            Expanded(flex: 2, child: _StatusBadge(status: job.status)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TechJobStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.s8,
        vertical: AppDimensions.s4,
      ),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.r8),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppDimensions.s4),
          Flexible(
            child: Text(
              status.label,
              style: AppTextStyles.bodySmall(color: status.color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class AssignedJobsDetailSheet extends StatefulWidget {
  final TechnicianJobEntity job;
  const AssignedJobsDetailSheet({super.key, required this.job});

  @override
  State<AssignedJobsDetailSheet> createState() =>
      _AssignedJobsDetailSheetState();
}

class _AssignedJobsDetailSheetState extends State<AssignedJobsDetailSheet> {
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.job.notes);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(technicianDashboardProvider);
        final notifier = ref.read(technicianDashboardProvider.notifier);

        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.97,
          builder: (_, ctrl) => Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.r28),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: AppDimensions.s10,
                    bottom: AppDimensions.s4,
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(AppDimensions.r2),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.navy, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.r28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            job.jobCardNo,
                            style: AppTextStyles.displaySmall(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: AppDimensions.s10),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.s8,
                              vertical: AppDimensions.s4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r20,
                              ),
                              border: Border.all(color: Colors.white38),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: AppDimensions.s4),
                                Text(
                                  job.status.label,
                                  style: AppTextStyles.bodySmall(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s8),
                      Row(
                        children: [
                          Text(
                            '${job.vehicleBrand} ${job.vehicleModel}',
                            style: AppTextStyles.bodySmall(
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(width: AppDimensions.s10),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.s8,
                              vertical: AppDimensions.s4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r8,
                              ),
                            ),
                            child: Text(
                              job.plateNumber,
                              style: AppTextStyles.bodySmall(
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s14),
                      Row(
                        children: [
                          Text(
                            'Job Progress',
                            style: AppTextStyles.bodySmall(
                              color: Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${job.completedTasks}/${job.tasks.length} tasks (${(job.progressPercent * 100).toInt()}%)',
                            style: AppTextStyles.bodySmall(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.r6),
                        child: LinearProgressIndicator(
                          value: job.progressPercent,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                          minHeight: 7,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r2,
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.s10),
                          Text(
                            'Work Tasks',
                            style: AppTextStyles.title(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s4),
                      Text(
                        'Track and update task progress',
                        style: AppTextStyles.bodySmall(color: AppColors.text3),
                      ),
                      SizedBox(height: AppDimensions.s12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.s10,
                          vertical: AppDimensions.s8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppDimensions.r10),
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 28, child: _ColHead('S.No')),
                            Expanded(flex: 4, child: _ColHead('Description')),
                            SizedBox(width: 46, child: _ColHead('Start')),
                            SizedBox(width: 38, child: _ColHead('End')),
                            SizedBox(width: 88, child: _ColHead('Status')),
                            SizedBox(width: 64, child: _ColHead('Action')),
                          ],
                        ),
                      ),
                      ...job.tasks.asMap().entries.map((e) {
                        final task = e.value;
                        return _TaskRow(
                          index: e.key + 1,
                          task: task,
                          isEven: e.key % 2 == 0,
                          onStart: () => notifier.startTask(job, task),
                          onComplete: () => notifier.completeTask(job, task),
                          onStatusChanged: (s) =>
                              notifier.updateTaskStatus(job, task, s),
                        );
                      }),
                      Container(
                        height: 1,
                        margin: EdgeInsets.only(bottom: AppDimensions.s20),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: AppColors.border),
                            right: BorderSide(color: AppColors.border),
                            bottom: BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r2,
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.s10),
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: 16,
                            color: AppColors.text3,
                          ),
                          SizedBox(width: AppDimensions.s6),
                          Text(
                            'Technician Notes',
                            style: AppTextStyles.subtitle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s8),
                      TextField(
                        controller: _notesCtrl,
                        maxLines: 4,
                        onChanged: (v) => notifier.updateNotes(job, v),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Add any notes or observations about this job...',
                          hintStyle: AppTextStyles.bodySmall(
                            color: AppColors.text3,
                          ),
                          filled: true,
                          fillColor: AppColors.bg,
                          contentPadding: EdgeInsets.all(AppDimensions.s14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r12,
                            ),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r12,
                            ),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r12,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.accent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.s24),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: const Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.text2,
                            side: BorderSide(color: AppColors.border),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.s20,
                              vertical: AppDimensions.s14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r12,
                              ),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: AppTextStyles.bodySmall(
                              color: AppColors.text2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: state.isSaving
                              ? null
                              : () => notifier.saveChanges(job),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            side: BorderSide(
                              color: AppColors.accent,
                              width: 1.5,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.s14,
                              vertical: AppDimensions.s14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r12,
                              ),
                            ),
                          ),
                          icon: state.isSaving
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accent,
                                  ),
                                )
                              : const Icon(Icons.save_rounded, size: 16),
                          label: Text('Save', style: AppTextStyles.bodySmall()),
                        ),
                        SizedBox(width: AppDimensions.s8),
                        GestureDetector(
                          onTap: state.isSaving
                              ? null
                              : () async {
                                  await notifier.completeJob(job);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.s14,
                              vertical: AppDimensions.s14,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.navy, AppColors.accent],
                              ),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r12,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.30,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: AppDimensions.s6),
                                Text(
                                  'Complete Job',
                                  style: AppTextStyles.bodySmall(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TaskRow extends StatelessWidget {
  final int index;
  final WorkTaskEntity task;
  final bool isEven;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final void Function(TaskStatus) onStatusChanged;

  const _TaskRow({
    required this.index,
    required this.task,
    required this.isEven,
    required this.onStart,
    required this.onComplete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.s10,
        vertical: AppDimensions.s10,
      ),
      decoration: BoxDecoration(
        color: isEven ? AppColors.surface : AppColors.surfaceAlt,
        border: const Border(
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: AppTextStyles.bodySmall(color: AppColors.text3),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              task.description,
              style: TextStyle(color: AppColors.text2, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 46,
            child: Text(
              task.startTime ?? '\u2013',
              style: TextStyle(color: AppColors.text3, fontSize: 11),
            ),
          ),
          SizedBox(
            width: 38,
            child: Text(
              task.endTime ?? '\u2013',
              style: TextStyle(color: AppColors.text3, fontSize: 11),
            ),
          ),
          SizedBox(
            width: 88,
            child: _TaskStatusDropdown(
              status: task.status,
              onChanged: onStatusChanged,
            ),
          ),
          SizedBox(
            width: 64,
            child: _TaskActionButton(
              task: task,
              onStart: onStart,
              onComplete: onComplete,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskStatusDropdown extends StatelessWidget {
  final TaskStatus status;
  final void Function(TaskStatus) onChanged;
  const _TaskStatusDropdown({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Color border, bg;
    switch (status) {
      case TaskStatus.completed:
        border = AppColors.success;
        bg = AppColors.successBg;
        break;
      case TaskStatus.inProgress:
        border = AppColors.accent;
        bg = AppColors.accent.withValues(alpha: 0.12);
        break;
      default:
        border = AppColors.border;
        bg = AppColors.bg;
    }
    return Container(
      height: 30,
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.s6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.r8),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaskStatus>(
          value: status,
          isDense: true,
          dropdownColor: AppColors.surface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 12,
            color: AppColors.text3,
          ),
          style: AppTextStyles.bodySmall(color: AppColors.textPrimary),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: TaskStatus.values
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.label, style: AppTextStyles.bodySmall()),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TaskActionButton extends StatelessWidget {
  final WorkTaskEntity task;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  const _TaskActionButton({
    required this.task,
    required this.onStart,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (task.status == TaskStatus.completed) {
      return const SizedBox.shrink();
    }
    final inProg = task.status == TaskStatus.inProgress;
    // P3 (audit): labelled control with a WCAG-compliant touch target.
    return Semantics(
      button: true,
      label: inProg ? 'Complete task' : 'Start task',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: inProg ? onComplete : onStart,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.s8,
            vertical: AppDimensions.s4,
          ),
          decoration: BoxDecoration(
            color: inProg
                ? AppColors.successBg
                : AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.r8),
            border: Border.all(
              color: inProg ? AppColors.success : AppColors.accent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                inProg
                    ? Icons.check_circle_outline_rounded
                    : Icons.play_arrow_rounded,
                color: inProg ? AppColors.success : AppColors.accent,
                size: 12,
              ),
              SizedBox(width: AppDimensions.s4),
              Text(
                inProg ? 'Done' : 'Start',
                style: AppTextStyles.bodySmall(
                  color: inProg ? AppColors.success : AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
