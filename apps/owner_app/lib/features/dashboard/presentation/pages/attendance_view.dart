import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/attendance_provider.dart';

class AttendanceView extends ConsumerWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
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
      appBar: AppBar(title: const Text('Staff Attendance')),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientBanner(
                greeting: 'Daily attendance register',
                title: DateFormat(
                  'EEEE, d MMMM yyyy',
                ).format(state.selectedDate),
                icon: Icons.fact_check_rounded,
                liveLabel: null,
              ),
              const SizedBox(height: AppDimensions.s16),
              OutlinedButton.icon(
                onPressed: () =>
                    _pickDate(context, notifier, state.selectedDate),
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Choose attendance date'),
              ),
              const SizedBox(height: AppDimensions.s16),
              AppAdaptiveGrid(
                minChildWidth: 140,
                childAspectRatio: 2.2,
                children: [
                  _Summary(
                    label: 'Total staff',
                    value: state.records.length,
                    color: colors.primary,
                  ),
                  _Summary(
                    label: 'Present',
                    value: present,
                    color: AppColors.success,
                  ),
                  _Summary(
                    label: 'Shift complete',
                    value: completed,
                    color: colors.secondary,
                  ),
                  _Summary(
                    label: 'Not punched in',
                    value: state.records.length - present,
                    color: colors.error,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s16),
              Wrap(
                spacing: 8,
                children: const ['all', 'advisor', 'supervisor', 'technician']
                    .map(
                      (role) => ChoiceChip(
                        label: Text(role == 'all' ? 'All roles' : _title(role)),
                        selected: state.roleFilter == role,
                        onSelected: (_) => notifier.setRoleFilter(role),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppDimensions.s16),
              if (state.isLoading)
                const LoadingIndicator(message: 'Loading attendance…')
              else if (state.error.isNotEmpty)
                ErrorView(message: state.error, onRetry: notifier.load)
              else if (records.isEmpty)
                const EmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No staff found',
                  message: 'No staff match this date and role filter.',
                )
              else
                ...records.map((record) => _AttendanceCard(record: record)),
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
  const _Summary({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          foregroundColor: color,
          child: Text('$value'),
        ),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
      ],
    ),
  );
}

class _AttendanceCard extends StatelessWidget {
  final OwnerAttendanceRecord record;
  const _AttendanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, color) = switch (record.status) {
      'working' => ('WORKING', AppColors.success),
      'onBreak' => ('ON BREAK', AppColors.warning),
      'punchedOut' => ('COMPLETED', colors.primary),
      _ => ('NOT PUNCHED IN', colors.error),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s10),
      child: AppCard(
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    record.name.isEmpty ? '?' : record.name[0].toUpperCase(),
                  ),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${record.empId} · ${AttendanceView._title(record.role)}${record.branch.isEmpty ? '' : ' · ${record.branch}'}',
                      ),
                    ],
                  ),
                ),
                StatusPill(
                  label: label,
                  bg: color.withValues(alpha: .12),
                  fg: color,
                ),
              ],
            ),
            const Divider(height: AppDimensions.s24),
            Row(
              children: [
                Expanded(
                  child: _Value(label: 'In', value: record.punchIn),
                ),
                Expanded(
                  child: _Value(label: 'Out', value: record.punchOut),
                ),
                Expanded(
                  child: _Value(label: 'Hours', value: record.workHours),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Value extends StatelessWidget {
  final String label;
  final String value;
  const _Value({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Text(
        value.isEmpty ? '--' : value,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
}
