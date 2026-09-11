import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/common/presentation/owner_shimmer_skeletons.dart';
import 'package:owner_app/features/dashboard/presentation/providers/attendance_provider.dart';

class AttendanceView extends ConsumerWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(ownerAttendanceProvider);
    final notifier = ref.read(ownerAttendanceProvider.notifier);
    final records = notifier.filteredRecords;
    final present = state.records
        .where((record) => record.status != 'notPunchedIn')
        .length;
    final completed = state.records
        .where((record) => record.status == 'punchedOut')
        .length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Staff Attendance',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: notifier.load,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        color: colorScheme.primary,
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.badge_rounded, color: colorScheme.primary, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Shift Register',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => _pickDate(context, notifier, state.selectedDate),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, color: colorScheme.primary, size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('dd MMM yyyy').format(state.selectedDate),
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy').format(state.selectedDate),
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time clock in/out status and working hour breakdown across all garage branches.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.s20),

              Row(
                children: [
                  Expanded(
                    child: _Summary(
                      label: 'Total Staff',
                      value: state.records.length,
                      color: colorScheme.primary,
                      icon: Icons.groups_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Summary(
                      label: 'Present',
                      value: present,
                      color: AppColors.success,
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _Summary(
                      label: 'Completed',
                      value: completed,
                      color: colorScheme.secondary,
                      icon: Icons.task_alt_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Summary(
                      label: 'Absent / Pending',
                      value: state.records.length - present,
                      color: colorScheme.error,
                      icon: Icons.do_not_disturb_on_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['all', 'advisor', 'supervisor', 'technician'].map((role) {
                    final sel = state.roleFilter == role;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: sel,
                        showCheckmark: false,
                        label: Text(
                          role == 'all' ? 'All Roles' : _title(role),
                          style: textTheme.labelMedium?.copyWith(
                            color: sel ? colorScheme.onPrimary : colorScheme.onSurface,
                            fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        selectedColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (_) => notifier.setRoleFilter(role),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppDimensions.s16),

              if (state.isLoading)
                const OwnerDashboardSkeleton()
              else if (state.error.isNotEmpty)
                ErrorView(message: state.error, onRetry: notifier.load)
              else if (records.isEmpty)
                const EmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No staff attendance records',
                  message: 'No staff match this date and role filter.',
                )
              else
                ...records.map((record) => _AttendanceCard(record: record)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    OwnerAttendanceNotifier notifier,
    DateTime current,
  ) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected != null) await notifier.selectDate(selected);
  }

  static String _title(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}

class _Summary extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _Summary({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final OwnerAttendanceRecord record;
  const _AttendanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final (label, color) = switch (record.status) {
      'working' => ('WORKING', AppColors.success),
      'onBreak' => ('ON BREAK', AppColors.warning),
      'punchedOut' => ('COMPLETED', colorScheme.primary),
      _ => ('NOT PUNCHED IN', colorScheme.error),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                child: Text(
                  record.name.isEmpty ? '?' : record.name[0].toUpperCase(),
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${record.empId} · ${AttendanceView._title(record.role)}${record.branch.isEmpty ? '' : ' · ${record.branch}'}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: label,
                bg: color.withValues(alpha: 0.12),
                fg: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Value(label: 'Clock In', value: record.punchIn),
              ),
              Expanded(
                child: _Value(label: 'Clock Out', value: record.punchOut),
              ),
              Expanded(
                child: _Value(label: 'Total Hours', value: record.workHours),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  final String label;
  final String value;
  const _Value({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '--' : value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
