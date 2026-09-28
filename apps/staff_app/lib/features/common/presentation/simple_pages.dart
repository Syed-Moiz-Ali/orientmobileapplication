import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

class ShiftDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ShiftDetailsPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final map = data ?? const {};
    String? get(String key) {
      final val = map[key];
      if (val == null) return null;
      final str = val.toString().trim();
      if (str.isEmpty || str == '--') return null;
      return str;
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canPop = Navigator.of(context).canPop();

    final shift = get('shift') ?? 'Standard Shift';
    final start = get('start');
    final end = get('end');
    final name = get('name');
    final id = get('id');
    final branch = get('branch');

    final hasStaff = name != null || id != null || branch != null;

    final scheduleCard = _ScheduleCard(shift: shift, start: start, end: end);

    final staffCard = hasStaff
        ? _StaffContextCard(name: name, id: id, branch: branch)
        : null;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: AppPageFrame(
          title: 'Shift Details',
          subtitle: 'Scheduled work hours and assignment',
          leading: canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Back',
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    context.pop();
                  },
                )
              : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: scheduleCard),
                    if (staffCard != null) ...[
                      const SizedBox(width: AppDimensions.s24),
                      Expanded(flex: 6, child: staffCard),
                    ],
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  scheduleCard,
                  if (staffCard != null) ...[
                    const SizedBox(height: AppDimensions.s20),
                    staffCard,
                  ],
                  const SizedBox(height: AppDimensions.s24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String shift;
  final String? start;
  final String? end;

  const _ScheduleCard({required this.shift, this.start, this.end});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Shift Schedule'),
        const SizedBox(height: AppDimensions.s8),
        Container(
          padding: const EdgeInsets.all(AppDimensions.s20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.8),
            ),
            boxShadow: AppDimensions.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.schedule_rounded,
                      color: colors.primary,
                      size: AppDimensions.iconSm,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ASSIGNED SHIFT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shift,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (start != null || end != null) ...[
                const SizedBox(height: AppDimensions.s16),
                Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppDimensions.s14),
                Row(
                  children: [
                    if (start != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shift Start',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              start!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontFamily: AppFontFamilies.mono,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (start != null && end != null)
                      Container(
                        width: 1,
                        height: 28,
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.s12,
                        ),
                      ),
                    if (end != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shift End',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              end!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontFamily: AppFontFamilies.mono,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StaffContextCard extends StatelessWidget {
  final String? name;
  final String? id;
  final String? branch;

  const _StaffContextCard({this.name, this.id, this.branch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final rows = <_DetailRowData>[
      if (name != null)
        _DetailRowData(
          icon: Icons.person_outline_rounded,
          label: 'Staff Member',
          value: name!,
        ),
      if (id != null)
        _DetailRowData(
          icon: Icons.badge_outlined,
          label: 'Employee ID',
          value: id!,
          isMono: true,
        ),
      if (branch != null)
        _DetailRowData(
          icon: Icons.business_outlined,
          label: 'Assigned Branch',
          value: branch!,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Assignment Details'),
        const SizedBox(height: AppDimensions.s8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.8),
            ),
            boxShadow: AppDimensions.shadowCard,
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s16,
                    vertical: AppDimensions.s12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          rows[i].icon,
                          size: AppDimensions.iconSm,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rows[i].label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rows[i].value,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFamily: rows[i].isMono
                                    ? AppFontFamilies.mono
                                    : null,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < rows.length - 1)
                  Divider(
                    height: 1,
                    indent: 60,
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRowData {
  final IconData icon;
  final String label;
  final String value;
  final bool isMono;

  const _DetailRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.isMono = false,
  });
}

class SettingsPage extends StatelessWidget {
  final Map<String, dynamic>? data;

  const SettingsPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final rawVersion = data?['version'] as String?;
    final version = rawVersion != null && rawVersion.trim().isNotEmpty
        ? rawVersion.trim()
        : null;

    bool hasPendingSync = false;
    try {
      hasPendingSync = HiveCleaner.hasPendingSync();
    } catch (_) {
      hasPendingSync = false;
    }
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: AppPageFrame(
          title: 'Settings',
          subtitle: 'Application information & local storage',
          leading: canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Back',
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    context.pop();
                  },
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'Data & Sync'),
              const SizedBox(height: AppDimensions.s8),
              Container(
                padding: const EdgeInsets.all(AppDimensions.s16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.8),
                  ),
                  boxShadow: AppDimensions.shadowCard,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: hasPendingSync
                            ? AppColors.warning.withValues(alpha: 0.12)
                            : colors.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        hasPendingSync
                            ? Icons.sync_problem_rounded
                            : Icons.cloud_done_outlined,
                        size: AppDimensions.iconSm,
                        color: hasPendingSync
                            ? AppColors.warning
                            : colors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local Sync Status',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasPendingSync
                                ? 'Pending local operations'
                                : 'No pending local operations',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasPendingSync
                                ? 'Offline changes are queued and will sync when connection is restored.'
                                : 'All recorded offline actions have been processed.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(
                      label: hasPendingSync ? 'PENDING' : 'IDLE',
                      bg: hasPendingSync
                          ? AppColors.warning.withValues(alpha: 0.12)
                          : colors.surfaceContainerHighest,
                      fg: hasPendingSync
                          ? AppColors.warning
                          : colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              if (version != null) ...[
                const SizedBox(height: AppDimensions.s24),
                const SectionHeader(title: 'Application'),
                const SizedBox(height: AppDimensions.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s16,
                    vertical: AppDimensions.s14,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusCard,
                    ),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.8),
                    ),
                    boxShadow: AppDimensions.shadowCard,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: AppDimensions.iconSm,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s14),
                      Expanded(
                        child: Text(
                          'App Version',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        version,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontFamily: AppFontFamilies.mono,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.s32),
            ],
          ),
        ),
      ),
    );
  }
}
