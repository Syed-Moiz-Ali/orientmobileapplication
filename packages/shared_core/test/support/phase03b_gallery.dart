import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 03B rendered-review gallery: skeleton variants, the list-surface
/// recipe states, a desktop data table with compact fallback, chart-theme
/// samples and the empty-chart placeholder. Real workshop fixtures only.
class Phase03bGallery extends StatelessWidget {
  const Phase03bGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget section(String title, List<Widget> children, {double gap = 12}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          for (final child in children) ...[child, SizedBox(height: gap)],
        ],
      );
    }

    Widget panel(String label, Widget child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(height: 280, child: child),
          ),
        ],
      );
    }

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          section('Skeletons', [
            const AppSkeleton.textBlock(),
            const AppSkeleton.listRows(rows: 2),
            const AppSkeleton.card(height: 90),
            const AppSkeleton.grid(columns: 3, rows: 1, itemHeight: 80),
            const AppSkeleton.chart(height: 140),
            const AppSkeleton.table(rows: 3, columns: 3),
          ]),
          section('List surface recipe', [
            panel(
              'Loading',
              const AppListSurface(
                isLoading: true,
                skeletonRows: 3,
                child: SizedBox.shrink(),
              ),
            ),
            panel(
              'Empty',
              const AppListSurface(
                isEmpty: true,
                emptyMessage: 'No job cards yet',
                child: SizedBox.shrink(),
              ),
            ),
            panel(
              'No match',
              const AppListSurface(
                isNoMatch: true,
                noMatchMessage: 'No job cards match "brake"',
                child: SizedBox.shrink(),
              ),
            ),
            panel(
              'Error + retry',
              AppListSurface(
                isError: true,
                errorMessage: 'Could not load job cards',
                onRetry: () {},
                child: const SizedBox.shrink(),
              ),
            ),
            panel('Loaded', const _LoadedList()),
          ]),
          section('Data table', [const _JobTable()]),
          section('Charts', [
            const AppChartPlaceholder(height: 140),
            _sparkline(context),
          ]),
          section('Telemetry pods', [
            const TelemetryMetricPod(
              label: 'Revenue velocity',
              value: 'AED 48,250.00',
              unit: '/ day',
              deltaLabel: '+18.4% vs Target',
              trend: TelemetryTrend.up,
              isLive: true,
              supportingText: 'Rolling 30-day workshop revenue',
            ),
            const SizedBox(height: 12),
            const TelemetryMetricPod(
              label: 'Bay occupancy',
              value: '82',
              unit: '%',
              deltaLabel: '-3.1% vs last week',
              trend: TelemetryTrend.down,
              supportingText: '6 of 8 bays active',
            ),
          ]),
          section('Service ribbon', [
            const LiveServiceTelemetryRibbon(status: JobCardStatus.inProgress),
            const SizedBox(height: 12),
            const LiveServiceTelemetryRibbon(
              status: JobCardStatus.waitingParts,
            ),
            const SizedBox(height: 12),
            const LiveServiceTelemetryRibbon(
              status: JobCardStatus.cancelled,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sparkline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Revenue velocity (last 12 weeks)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        const SparklineChart(
          height: 90,
          series: [
            SparklineSeries(<double>[
              0.42, 0.48, 0.46, 0.55, 0.61, 0.58, 0.66, 0.72, 0.69, 0.78,
              0.83, 0.91,
            ]),
          ],
        ),
      ],
    );
  }
}

class _LoadedList extends StatelessWidget {
  const _LoadedList();

  @override
  Widget build(BuildContext context) {
    return AppListSurface(
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.s8),
        children: const [
          AppRecordRow(
            identifier: 'JOB-4091',
            title: 'Mercedes-Benz E300',
            subtitle: 'Major 60,000 km service',
            status: StatusPill.inProgress('In progress'),
          ),
          SizedBox(height: 8),
          AppRecordRow(
            identifier: 'JOB-4092',
            title: 'Toyota Camry 2022',
            subtitle: 'Brake pad replacement',
            status: StatusPill.warning('Waiting parts'),
          ),
        ],
      ),
    );
  }
}

class _JobRow {
  final String plate;
  final String service;
  final String amount;
  final String status;
  const _JobRow(this.plate, this.service, this.amount, this.status);
}

const _jobs = <_JobRow>[
  _JobRow('A 12345', 'Brake pad replacement', 'AED 1,250', 'In progress'),
  _JobRow('B 98765', 'Major 60,000 km service', 'AED 3,480', 'Waiting parts'),
  _JobRow('C 45678', 'Air-conditioning recharge', 'AED 690', 'Completed'),
  _JobRow('D 11223', 'Tyre rotation & balancing', 'AED 420', 'Completed'),
];

class _JobTable extends StatelessWidget {
  const _JobTable();

  @override
  Widget build(BuildContext context) {
    return AppTable<_JobRow>(
      columns: const [
        AppTableColumn(label: 'Plate', flex: 2),
        AppTableColumn(label: 'Service', flex: 3),
        AppTableColumn(label: 'Status', flex: 2),
        AppTableColumn(label: 'Amount', numeric: true, sortable: true),
      ],
      items: _jobs,
      onRowTap: (_) {},
      isSelected: (job) => job.status == 'In progress',
      kebab: (context, job) => AppButton.quietIcon(
        icon: Icons.more_vert_rounded,
        onPressed: () {},
        tooltip: 'Row actions',
      ),
      cells: (context, job) => [
        AppTableCell.text(context, job.plate),
        AppTableCell.text(context, job.service),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: StatusPill.neutral(job.status),
        ),
        AppTableCell.numeric(context, job.amount),
      ],
      compactBuilder: (context, job) => AppRecordRow(
        title: job.plate,
        subtitle: job.service,
        status: StatusPill.neutral(job.status),
        trailing: Text(job.amount, style: AppTextStyles.mono()),
      ),
    );
  }
}
