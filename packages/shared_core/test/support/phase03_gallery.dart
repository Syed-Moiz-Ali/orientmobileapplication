import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 03 rendered-review catalog: the Concept A data-presentation
/// instruments — telemetry metric pods, the sparkline chart, the live service
/// ribbon, the spatial damage HUD and the redesigned sticky/selection-capable
/// data table. Real workshop fixtures only.
///
/// Consumed by `shared_data_components_visual_test.dart`; not part of any app.
class Phase03Gallery extends StatelessWidget {
  const Phase03Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget section(String title, List<Widget> children, {double gap = 12}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                  ),
                ),
                const SizedBox(width: AppDimensions.s8),
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.8,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          for (final child in children) ...[child, SizedBox(height: gap)],
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
          section('Telemetry pods', [
            const TelemetryMetricPod(
              label: 'Revenue velocity',
              value: 'AED 48,250.00',
              unit: '/ day',
              deltaLabel: '+18.4% vs Target',
              trend: TelemetryTrend.up,
              isLive: true,
              icon: Icons.trending_up_rounded,
              isHero: true,
            ),
            const TelemetryMetricPod(
              label: 'Bay occupancy',
              value: '82',
              unit: '%',
              deltaLabel: '-3.1% vs last week',
              trend: TelemetryTrend.down,
              supportingText: '6 of 8 bays active',
            ),
            const TelemetryMetricPod(
              label: 'Avg. cycle time',
              value: '3.4',
              unit: 'days',
              deltaLabel: '-0.6% vs Target',
              trend: TelemetryTrend.down,
              trendIsPositive: true,
              supportingText: 'Lower is better',
            ),
          ]),
          section('Sparkline', [
            const SparklineChart(
              height: 96,
              series: [
                SparklineSeries(<double>[
                  0.42, 0.48, 0.46, 0.55, 0.61, 0.58, 0.66, 0.72, 0.69, 0.78,
                  0.83, 0.91,
                ]),
              ],
            ),
            const SparklineChart(
              height: 96,
              filled: false,
              series: [
                SparklineSeries(<double>[
                  0.9, 0.72, 0.78, 0.6, 0.66, 0.5, 0.55, 0.44, 0.4,
                ]),
                SparklineSeries(<double>[
                  0.3, 0.42, 0.38, 0.5, 0.46, 0.58, 0.52, 0.64, 0.7,
                ]),
              ],
            ),
            const SparklineChart(height: 120, series: []),
          ]),
          section('Service ribbon', [
            const LiveServiceTelemetryRibbon(status: JobCardStatus.pending),
            const SizedBox(height: 14),
            const LiveServiceTelemetryRibbon(status: JobCardStatus.inspected),
            const SizedBox(height: 14),
            const LiveServiceTelemetryRibbon(
              status: JobCardStatus.inProgress,
            ),
            const SizedBox(height: 14),
            const LiveServiceTelemetryRibbon(status: JobCardStatus.qualityCheck),
            const SizedBox(height: 14),
            const LiveServiceTelemetryRibbon(status: JobCardStatus.completed),
            const SizedBox(height: 14),
            const LiveServiceTelemetryRibbon(status: JobCardStatus.cancelled),
          ]),
          section('Spatial damage HUD', [
            const SpatialDamageHud(
              height: 300,
              hotspots: [
                DamageHotspot(
                  zone: VehicleZone.frontLeft,
                  kind: DamageKind.scratch,
                  label: 'Front-left fender',
                  code: 'D-01',
                ),
                DamageHotspot(
                  zone: VehicleZone.sideRight,
                  kind: DamageKind.dent,
                  label: 'Rear door',
                  code: 'D-02',
                ),
                DamageHotspot(
                  zone: VehicleZone.front,
                  kind: DamageKind.glass,
                  label: 'Windshield',
                  code: 'D-03',
                ),
                DamageHotspot(
                  zone: VehicleZone.rearRight,
                  kind: DamageKind.scratch,
                  label: 'Rear bumper',
                  code: 'D-04',
                ),
              ],
            ),
          ]),
          section('Data table', [const _JobTable()]),
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
