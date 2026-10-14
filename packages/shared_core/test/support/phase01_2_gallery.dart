import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01.2 rendered-review gallery: the seven new foundation primitives
/// plus the density modes and the focus/disabled grammar. Real workshop
/// fixtures only; styling resolves through the active theme.
class Phase012Gallery extends StatelessWidget {
  const Phase012Gallery({super.key});

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

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          section('Filter bar', [
            AppFilterBar(
              options: const ['In progress', 'Waiting parts', 'Completed'],
              selected: 'In progress',
              onSelected: (_) {},
            ),
            AppFilterBar(
              options: const ['In progress', 'Waiting parts', 'Completed'],
              selected: null,
              onSelected: (_) {},
            ),
          ]),
          section('Date range', [
            AppDateRangeField(
              value: DateTimeRange(
                start: DateTime(2026, 10, 7),
                end: DateTime(2026, 10, 14),
              ),
              onChanged: (_) {},
            ),
            AppDateRangeField(value: null, onChanged: (_) {}),
          ]),
          section('Pagination', [
            AppPaginationFooter(
              page: 2,
              totalPages: 8,
              totalResults: 96,
              onPrevious: () {},
              onNext: () {},
            ),
            const AppPaginationFooter(
              page: 1,
              totalPages: 1,
              totalResults: 4,
            ),
          ]),
          section('Command palette', [
            AppCommandPalette(
              commands: [
                AppCommand(
                  id: 'new-job',
                  label: 'Create job card',
                  hint: 'Intake',
                  icon: Icons.add_circle_outline_rounded,
                  onSelected: () {},
                ),
                AppCommand(
                  id: 'search-vin',
                  label: 'Search by VIN',
                  hint: 'WDBJF65J1YB040901',
                  icon: Icons.search_rounded,
                  onSelected: () {},
                ),
              ],
            ),
          ]),
          section('Stepper', [
            const AppStepper(
              steps: ['Intake', 'Inspection', 'Repair', 'Delivery'],
              currentIndex: 1,
            ),
            const AppStepper(
              steps: ['Intake', 'Inspection', 'Repair', 'Delivery'],
              currentIndex: 3,
            ),
          ]),
          section('Timeline', [
            const AppTimeline(
              entries: [
                AppTimelineEntry(
                  title: 'Vehicle received',
                  subtitle: 'Odometer 62,400 km',
                  time: '09:30',
                  tone: StatusColorRole.info,
                  icon: Icons.login_rounded,
                ),
                AppTimelineEntry(
                  title: 'Inspection flagged brakes',
                  subtitle: 'Front pads 2 mm — advisor notified',
                  time: '10:15',
                  tone: StatusColorRole.warning,
                  icon: Icons.warning_amber_rounded,
                ),
                AppTimelineEntry(
                  title: 'Quality check passed',
                  time: '14:05',
                  tone: StatusColorRole.success,
                  icon: Icons.verified_rounded,
                ),
              ],
            ),
          ]),
          section('Trend stats', [
            const AppTrendStat(
              label: 'Revenue today',
              displayValue: 'AED 48,250',
              deltaFraction: 0.184,
            ),
            const AppTrendStat(
              label: 'Average wait time',
              displayValue: '42 min',
              deltaFraction: -0.06,
              upIsGood: false,
            ),
          ]),
          section('Density (comfortable vs compact)', [
            const AppRecordRow(
              identifier: 'JOB-4091',
              title: 'Mercedes-Benz E300',
              subtitle: 'Major 60,000 km service',
            ),
            const AppDensityScope(
              mode: AppDensityMode.compact,
              child: AppRecordRow(
                identifier: 'JOB-4092',
                title: 'Toyota Camry 2022',
                subtitle: 'Brake pad replacement',
              ),
            ),
          ]),
          section('Focus + disabled grammar', [
            const TextField(
              decoration: InputDecoration(hintText: 'Focused input'),
            ),
            const TextField(
              enabled: false,
              decoration: InputDecoration(hintText: 'Disabled input'),
            ),
            const FilledButton(onPressed: null, child: Text('Disabled')),
            const AppChartPlaceholder(height: 140),
          ]),
        ],
      ),
    );
  }
}
