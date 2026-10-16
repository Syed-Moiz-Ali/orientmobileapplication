import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Floor operations report: a metric strip plus sparse data tables. Every
/// figure is real provider data; there are no decorative charts and no
/// fabricated trend deltas (no history endpoint exists — the honesty note makes
/// that explicit rather than inventing a direction).
class SupervisorReportsTab extends ConsumerWidget {
  const SupervisorReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final jobTypes = notifier.jobTypes;
    final metrics = notifier.revenueMetrics;
    final total = notifier.totalAssigned;
    final inProgress = notifier.inProgressCount;
    final completed = notifier.completedCount;
    final techCount = notifier.technicians.length;
    final deptCount = notifier.departments.length;
    final queueCount = notifier.bookings.length + notifier.breakdowns.length;
    final perTech = techCount > 0 ? (total / techCount) : 0.0;

    return RefreshIndicator(
      onRefresh: notifier.refreshDashboard,
      color: context.colors.primary,
      backgroundColor: context.colors.surface,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s16,
          context.pagePadding.right,
          AppDimensions.s40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPageHeader(
              title: t.svReportsTitle,
              subtitle: t.svReportsSubtitle,
              leading: const Icon(Icons.analytics_outlined),
            ),
            const SizedBox(height: AppDimensions.s16),
            if (state.dashboardError.isNotEmpty) ...[
              AppInfoPanel.danger(message: t.svReportsError),
              const SizedBox(height: AppDimensions.s16),
            ],
            _MetricStrip(
              throughput: completed,
              inProgress: inProgress,
              utilisation: perTech,
            ),
            const SizedBox(height: AppDimensions.s8),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: AppDimensions.iconXs,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.s6),
                Expanded(
                  child: Text(
                    t.svReportsNoHistory,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s20),
            SectionHeader(
              title: t.svReportsCategories,
              leadingIcon: Icons.category_outlined,
              count: jobTypes.length,
            ),
            _CategoryTable(jobTypes: jobTypes, totalJobs: total),
            const SizedBox(height: AppDimensions.s20),
            SectionHeader(
              title: t.svReportsFloor,
              leadingIcon: Icons.grid_view_rounded,
            ),
            _FloorTable(
              techCount: techCount,
              deptCount: deptCount,
              queueCount: queueCount,
              inProgress: inProgress,
            ),
            if (metrics.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s20),
              SectionHeader(
                title: t.svReportsFinancial,
                leadingIcon: Icons.receipt_long_outlined,
              ),
              for (final m in metrics)
                _FinancialRow(
                  icon: m.icon,
                  label: m.label,
                  amount: m.amount,
                  change: m.change,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  final int throughput;
  final int inProgress;
  final double utilisation;

  const _MetricStrip({
    required this.throughput,
    required this.inProgress,
    required this.utilisation,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final columns = context.adaptive.pick(
      compact: 1,
      medium: 3,
      expanded: 3,
      large: 3,
    );
    final tiles = <Widget>[
      AppKpiCard.wide(
        label: t.svReportsThroughput,
        value: '$throughput',
        icon: Icons.check_circle_outline_rounded,
      ),
      AppKpiCard.wide(
        label: t.svReportsUtilisation,
        value: utilisation.toStringAsFixed(1),
        icon: Icons.engineering_outlined,
        semanticState: KpiSemanticState.info,
      ),
      AppKpiCard.wide(
        label: t.svReportsJobsPerTech,
        value: inProgress.toString(),
        icon: Icons.sync_rounded,
        semanticState: KpiSemanticState.warning,
      ),
    ];
    if (columns == 1) {
      return Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(height: AppDimensions.s10),
            tiles[i],
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: AppDimensions.s10),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

class _CategoryTable extends StatelessWidget {
  final List<JobTypeEntity> jobTypes;
  final int totalJobs;

  const _CategoryTable({required this.jobTypes, required this.totalJobs});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final sum = totalJobs > 0
        ? totalJobs
        : jobTypes.fold<int>(0, (s, e) => s + e.count);
    return AppTable<JobTypeEntity>(
      columns: [
        AppTableColumn(label: t.svReportsCategories, flex: 3),
        AppTableColumn(label: t.svJobsTotal, numeric: true),
        AppTableColumn(label: '%', numeric: true),
      ],
      items: jobTypes,
      emptyMessage: t.svReportsCategoriesEmpty,
      cells: (ctx, item) {
        final share = sum > 0 ? (item.count / sum * 100).round() : 0;
        return [
          AppTableCell.text(ctx, item.label),
          AppTableCell.numeric(ctx, '${item.count}'),
          AppTableCell.numeric(ctx, '$share%'),
        ];
      },
      compactBuilder: (ctx, item) {
        final share = sum > 0 ? (item.count / sum * 100).round() : 0;
        return Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ),
            Text(
              '${item.count}',
              style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            Text(
              '$share%',
              style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FloorTable extends StatelessWidget {
  final int techCount;
  final int deptCount;
  final int queueCount;
  final int inProgress;

  const _FloorTable({
    required this.techCount,
    required this.deptCount,
    required this.queueCount,
    required this.inProgress,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return AppTable<({String label, IconData icon, int value})>(
      columns: [
        AppTableColumn(label: t.svReportsFloor, flex: 3),
        AppTableColumn(label: t.svJobsTotal, numeric: true),
      ],
      items: [
        (label: t.svReportsTechnicians, icon: Icons.engineering_outlined, value: techCount),
        (label: t.svReportsDepartments, icon: Icons.domain_rounded, value: deptCount),
        (label: t.svReportsInQueue, icon: Icons.inbox_outlined, value: queueCount),
        (label: t.svJobsInProgress, icon: Icons.sync_rounded, value: inProgress),
      ],
      cells: (ctx, item) => [
        AppTableCell.text(ctx, item.label),
        AppTableCell.numeric(ctx, '${item.value}'),
      ],
      compactBuilder: (ctx, item) => Row(
        children: [
          Icon(item.icon, size: AppDimensions.iconSm, color: context.colors.primary),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: Text(item.label, style: Theme.of(ctx).textTheme.bodyMedium),
          ),
          Text(
            '${item.value}',
            style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final String change;

  const _FinancialRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s10),
          child: Row(
            children: [
              Icon(icon, size: AppDimensions.iconMd, color: context.colors.primary),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  amount,
                  style: AppTextStyles.mono(
                    color: context.colors.onSurface,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (change.isNotEmpty) ...[
                const SizedBox(width: AppDimensions.s8),
                StatusPill.neutral(change),
              ],
            ],
          ),
        ),
        Divider(height: 1, color: context.colors.outlineVariant),
      ],
    );
  }
}
