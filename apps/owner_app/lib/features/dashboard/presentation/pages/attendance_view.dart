import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/attendance_provider.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Day register (O12): date picker, present/completed summary strip, role
/// filter and per-staff clock cards over the frozen attendance provider.
/// Punch states resolve theme tones (idle stays neutral — never bare red);
/// the selected date formats through `MaterialLocalizations` so Arabic
/// month and weekday names render correctly with Latin digits.
class AttendanceView extends ConsumerStatefulWidget {
  const AttendanceView({super.key});

  @override
  ConsumerState<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends ConsumerState<AttendanceView> {
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context,
    OwnerAttendanceNotifier notifier,
    DateTime current,
  ) async {
    final t = OwnerLocalizations.of(context)!;
    HapticFeedback.selectionClick();
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: t.ownerAtTitle,
    );
    if (selected != null) await notifier.selectDate(selected);
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = ref.watch(ownerAttendanceProvider);
    final notifier = ref.read(ownerAttendanceProvider.notifier);
    final records = notifier.filteredRecords;
    final present = state.records
        .where((record) => record.status != 'notPunchedIn')
        .length;
    final completed = state.records
        .where((record) => record.status == 'punchedOut')
        .length;

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final roles = <String>[
      t.ownerAtAllRoles,
      t.ownerTmAdvisors,
      t.ownerTmSupervisors,
      t.ownerTmTechnicians,
    ];
    const roleValues = <String>['all', 'advisor', 'supervisor', 'technician'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.ownerAtTitle,
        subtitle: t.ownerAtSubtitle,
        showBack: true,
        showOfflineStatus: true,
        actions: [
          IconButton(
            tooltip: MaterialLocalizations.of(context)
                .refreshIndicatorSemanticLabel,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.selectionClick();
              notifier.load();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.load,
          color: colors.primary,
          child: AppResponsivePage(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DateHeader(
                  selectedDate: state.selectedDate,
                  onPick: () =>
                      _pickDate(context, notifier, state.selectedDate),
                ),
                const SizedBox(height: AppDimensions.s16),
                _SummaryStrip(
                  total: state.records.length,
                  present: present,
                  completed: completed,
                  absent: state.records.length - present,
                ),
                const SizedBox(height: AppDimensions.s16),
                AppFilterBar(
                  options: roles.sublist(1),
                  selected: state.roleFilter == 'all'
                      ? null
                      : roles[roleValues.indexOf(state.roleFilter)],
                  onSelected: (label) {
                    HapticFeedback.selectionClick();
                    if (label == null) {
                      notifier.setRoleFilter('all');
                    } else {
                      final value =
                          roleValues[roles.indexOf(label)];
                      notifier.setRoleFilter(
                        state.roleFilter == value ? 'all' : value,
                      );
                    }
                  },
                ),
                const SizedBox(height: AppDimensions.s12),
                if (state.isLoading && state.records.isEmpty)
                  const AppSkeleton.page()
                else if (state.error.isNotEmpty && records.isEmpty)
                  ErrorView(message: state.error, onRetry: notifier.load)
                else if (records.isEmpty)
                  EmptyState(
                    icon: Icons.event_busy_rounded,
                    message: t.ownerAtEmpty,
                  )
                else if (wide)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppDimensions.s12,
                      mainAxisSpacing: AppDimensions.s12,
                      mainAxisExtent: 190,
                    ),
                    itemBuilder: (_, i) =>
                        _AttendanceCard(record: records[i]),
                  )
                else
                  for (final record in records) ...[
                    _AttendanceCard(record: record),
                    const SizedBox(height: AppDimensions.s12),
                  ],
                const SizedBox(height: AppDimensions.s32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Date header: locale-aware full date plus the picker trigger.
class _DateHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPick;

  const _DateHeader({required this.selectedDate, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppCard.standard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MaterialLocalizations.of(context)
                      .formatFullDate(selectedDate),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          SecondaryButton(
            label: MaterialLocalizations.of(context)
                .formatMediumDate(selectedDate),
            leadingIcon: Icons.calendar_month_rounded,
            isExpanded: false,
            onPressed: onPick,
          ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final int total;
  final int present;
  final int completed;
  final int absent;

  const _SummaryStrip({
    required this.total,
    required this.present,
    required this.completed,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final adaptive = context.adaptive;
    final metrics = <_Metric>[
      _Metric(
        label: t.ownerAtTotal,
        value: total,
        icon: Icons.groups_rounded,
      ),
      _Metric(
        label: t.ownerAtPresent,
        value: present,
        icon: Icons.check_circle_rounded,
      ),
      _Metric(
        label: t.ownerAtDone,
        value: completed,
        icon: Icons.task_alt_rounded,
      ),
      _Metric(
        label: t.ownerAtAbsent,
        value: absent,
        icon: Icons.do_not_disturb_on_rounded,
      ),
    ];
    return AppAdaptiveGrid(
      columns: adaptive.pick(compact: 2, medium: 4, expanded: 4, large: 4),
      minChildWidth: 140,
      spacing: adaptive.itemSpacing,
      runSpacing: adaptive.itemSpacing,
      childAspectRatio: adaptive.pick(
        compact: 1.65,
        medium: 1.5,
        expanded: 1.7,
        large: 1.8,
      ),
      children: [
        for (final m in metrics)
          AppCard.standard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  m.icon,
                  size: AppDimensions.iconSm,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppDimensions.s6),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '${m.value}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color:
                              Theme.of(context).colorScheme.onSurface,
                          fontFeatures: const [
                            FontFeature.tabularFigures()
                          ],
                        ),
                  ),
                ),
                Text(
                  m.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Metric {
  final String label;
  final int value;
  final IconData icon;

  const _Metric({required this.label, required this.value, required this.icon});
}

class _AttendanceCard extends StatelessWidget {
  final OwnerAttendanceRecord record;

  const _AttendanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard.standard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Text(
                  record.name.isEmpty
                      ? '?'
                      : record.name.characters.first.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${record.empId} · ${record.role}${record.branch.isEmpty ? '' : ' · ${record.branch}'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _ClockPill(status: record.status),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Expanded(
                child: _ClockValue(label: t.ownerAtIn, value: record.punchIn),
              ),
              Expanded(
                child: _ClockValue(label: t.ownerAtOut, value: record.punchOut),
              ),
              Expanded(
                child: _ClockValue(
                  label: t.ownerAtHours,
                  value: record.workHours,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Punch-state pill: working resolves success, break warning, completion
/// info — and the idle state stays neutral, never an error accusation.
class _ClockPill extends StatelessWidget {
  final String status;

  const _ClockPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    return switch (status) {
      'working' => StatusPill.success(t.ownerAtWorking, showDot: true),
      'onBreak' => StatusPill.warning(t.ownerAtBreak, showDot: true),
      'punchedOut' => StatusPill.info(t.ownerAtComplete, showDot: true),
      _ => StatusPill.neutral(t.ownerAtIdle),
    };
  }
}

class _ClockValue extends StatelessWidget {
  final String label;
  final String value;

  const _ClockValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            value.isEmpty ? '--' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.mono(
              color: theme.colorScheme.onSurface,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
