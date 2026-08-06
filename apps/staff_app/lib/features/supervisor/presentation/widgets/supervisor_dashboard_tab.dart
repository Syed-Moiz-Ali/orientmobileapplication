// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_stats_grid.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class SupervisorDashboardTab extends ConsumerWidget {
  const SupervisorDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final state = ref.watch(supervisorDashboardProvider);

    if (state.isDashboardLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2.5,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refreshDashboard,
      color: AppColors.accent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Overview'),
                  const SizedBox(height: AppDimensions.s12),
                  SupervisorStatsGrid(kpis: notifier.kpis),
                  const SizedBox(height: AppDimensions.s24),
                  _SectionLabel('Job Analysis'),
                  const SizedBox(height: AppDimensions.s12),
                  _AdvisorBarCard(data: notifier.advisorJobData),
                  const SizedBox(height: AppDimensions.s12),
                  _JobTypeCard(types: notifier.jobTypes),
                  const SizedBox(height: AppDimensions.s24),
                  _SectionLabel('Revenue Overview'),
                  const SizedBox(height: AppDimensions.s12),
                  _RevenueGrid(metrics: notifier.revenueMetrics),
                  const SizedBox(height: AppDimensions.s12),
                  const _RevenueTrendCard(),
                  const SizedBox(height: AppDimensions.s24),
                  _SectionLabel('Pending Status'),
                  const SizedBox(height: AppDimensions.s12),
                  _PendingGrid(statuses: notifier.pendingStatuses),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _SectionLabel(String text) => Row(
  children: [
    Container(
      width: 4,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppDimensions.r2),
      ),
    ),
    const SizedBox(width: 10),
    Text(
      text,
      style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
    ),
  ],
);

class _HeaderBanner extends ConsumerWidget {
  const _HeaderBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    // FIX (audit P0): '24 Pending / 8 Delivery' were fabricated constants —
    // the pills now show real KPI values from the backend.
    String pending = '0';
    String delivery = '0';
    for (final k in notifier.kpis) {
      if (k.label.contains('Pending')) pending = k.value;
      if (k.label.contains('Delivery')) delivery = k.value;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6, top: 1),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text(
                      'Live',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Good Morning,',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  'Supervisor',
                  style: AppTextStyles.orbitronDisplayMedium(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _pill(
                      Icons.pending_actions_rounded,
                      '$pending Pending',
                      AppColors.warningBorder,
                    ),
                    const SizedBox(width: 8),
                    _pill(
                      Icons.check_circle_outline_rounded,
                      '$delivery Delivery',
                      AppColors.accent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.garage_rounded,
              color: Colors.white,
              size: AppDimensions.iconXl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.r22),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: AppDimensions.iconSm),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisorBarCard extends StatelessWidget {
  final List<AdvisorJobEntity> data;
  const _AdvisorBarCard({required this.data});

  @override
  Widget build(BuildContext context) {
    // FIX (audit P0): crash guard — reduce() on an empty list crashed the
    // dashboard on first launch or when the advisor-jobs API returned [].
    if (data.isEmpty) {
      return AppCard.surface(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardTitle('Job Cards \u2014 Advisor Wise'),
              const SizedBox(height: 8),
              const Text(
                'No advisor job data yet',
                style: TextStyle(color: AppColors.text2, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    final maxVal = data.map((d) => d.count).reduce((a, b) => a > b ? a : b);

    return AppCard.surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle('Job Cards \u2014 Advisor Wise'),
          const SizedBox(height: AppDimensions.s20),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((b) {
                final frac = maxVal > 0 ? b.count / maxVal : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${b.count.toInt()}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 130 * frac,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, AppColors.navy],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.name.split(' ').first,
                          style: const TextStyle(
                            color: AppColors.text2,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobTypeCard extends StatelessWidget {
  final List<JobTypeEntity> types;
  const _JobTypeCard({required this.types});

  @override
  Widget build(BuildContext context) {
    final total = types.fold(0, (s, t) => s + t.count);
    return AppCard.surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle('Job Card by Type'),
          const SizedBox(height: AppDimensions.s18),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(painter: _PiePainter(types)),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  children: types.map((t) {
                    final pct = total > 0
                        ? (t.count / total * 100).toStringAsFixed(0)
                        : '0';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: t.color,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              t.label,
                              style: const TextStyle(
                                color: AppColors.text2,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<JobTypeEntity> types;
  const _PiePainter(this.types);

  @override
  void paint(Canvas canvas, Size size) {
    final total = types.fold(0, (s, t) => s + t.count);
    if (total == 0) return;
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    double start = -1.5708;
    for (final t in types) {
      final sweep = 2 * 3.14159 * t.count / total;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = t.color);
      start += sweep;
    }
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width * 0.30,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RevenueGrid extends StatelessWidget {
  final List<RevenueMetricEntity> metrics;
  const _RevenueGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < metrics.length; i += 2) {
      final left = metrics[i];
      final right = i + 1 < metrics.length ? metrics[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _RevenueMetricCard(metric: left)),
            const SizedBox(width: AppDimensions.s12),
            right != null
                ? Expanded(child: _RevenueMetricCard(metric: right))
                : const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < metrics.length) {
        rows.add(const SizedBox(height: AppDimensions.s12));
      }
    }
    return Column(children: rows);
  }
}

class _RevenueMetricCard extends StatelessWidget {
  final RevenueMetricEntity metric;
  const _RevenueMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                ),
                child: Icon(metric.icon, color: AppColors.accent, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(AppDimensions.r7),
                ),
                child: Text(
                  metric.change,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metric.amount,
            style: AppTextStyles.orbitronDisplaySmall(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            metric.label,
            style: AppTextStyles.rajdhaniBodySmall(color: AppColors.text3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RevenueTrendCard extends StatelessWidget {
  const _RevenueTrendCard();

  @override
  Widget build(BuildContext context) {
    // FIX (audit P0): this card previously rendered a HARDCODED line chart
    // presented as "This Year" revenue. No daily revenue endpoint exists yet,
    // so we show an honest placeholder instead of invented numbers.
    return AppCard.surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle('Revenue Trend'),
          const SizedBox(height: 18),
          const SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'Daily revenue chart appears once revenue data is available',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.text3, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingGrid extends StatelessWidget {
  final List<PendingStatusEntity> statuses;
  const _PendingGrid({required this.statuses});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < statuses.length; i += 2) {
      final left = statuses[i];
      final right = i + 1 < statuses.length ? statuses[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _PendingCard(status: left)),
            const SizedBox(width: AppDimensions.s12),
            right != null
                ? Expanded(child: _PendingCard(status: right))
                : const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < statuses.length) {
        rows.add(const SizedBox(height: AppDimensions.s12));
      }
    }
    return Column(children: rows);
  }
}

class _PendingCard extends StatelessWidget {
  final PendingStatusEntity status;
  const _PendingCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final bgTint = Color.lerp(AppColors.surface, status.color, 0.06)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 11, 14),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(
          color: status.color.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: status.color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: Icon(status.icon, color: status.color, size: 19),
          ),
          const SizedBox(height: 10),
          Text(
            status.count,
            style: AppTextStyles.orbitronKpiNumber(color: status.color),
          ),
          const SizedBox(height: 5),
          Text(
            status.label,
            style: AppTextStyles.rajdhaniBodySmall(color: AppColors.text2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.rajdhaniButton(color: AppColors.textPrimary),
  );
}
