import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class SupervisorReportsTab extends ConsumerStatefulWidget {
  const SupervisorReportsTab({super.key});

  @override
  ConsumerState<SupervisorReportsTab> createState() => _SupervisorReportsTabState();
}

class _SupervisorReportsTabState extends ConsumerState<SupervisorReportsTab> {
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Quarter

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final jobTypes = notifier.jobTypes.isNotEmpty
        ? notifier.jobTypes
        : [
            JobTypeEntity(label: 'Major Service', count: 24, color: colorScheme.primary),
            JobTypeEntity(label: 'Diagnostics', count: 18, color: colorScheme.secondary),
            const JobTypeEntity(label: 'Brakes & Suspension', count: 12, color: Color(0xFF10B981)),
            const JobTypeEntity(label: 'Emergency SOS', count: 6, color: Color(0xFFEF4444)),
          ];

    final metrics = notifier.revenueMetrics;
    final total = notifier.totalAssigned > 0 ? notifier.totalAssigned : 48;
    final inProgress = notifier.inProgressCount > 0 ? notifier.inProgressCount : 18;
    final completed = notifier.completedCount > 0 ? notifier.completedCount : 30;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. PERIOD SELECTOR CHIPS ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Financial & Operations Intelligence',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  _PeriodFilterChip(
                    label: '7 Days',
                    isSelected: _selectedPeriod == 0,
                    onTap: () => setState(() => _selectedPeriod = 0),
                  ),
                  _PeriodFilterChip(
                    label: '30 Days',
                    isSelected: _selectedPeriod == 1,
                    onTap: () => setState(() => _selectedPeriod = 1),
                  ),
                  _PeriodFilterChip(
                    label: 'Quarter',
                    isSelected: _selectedPeriod == 2,
                    onTap: () => setState(() => _selectedPeriod = 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 2. STATS OVERVIEW CARDS ───────────────────────────────────
            Row(
              children: [
                _QuickStatCard(
                  label: 'Total Volume',
                  value: '$total',
                  color: colorScheme.primary,
                  icon: Icons.inventory_2_outlined,
                ),
                const SizedBox(width: 8),
                _QuickStatCard(
                  label: 'In Progress',
                  value: '$inProgress',
                  color: colorScheme.secondary,
                  icon: Icons.sync_rounded,
                ),
                const SizedBox(width: 8),
                _QuickStatCard(
                  label: 'Completed',
                  value: '$completed',
                  color: const Color(0xFF10B981),
                  icon: Icons.check_circle_outline_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── 3. INTERACTIVE REVENUE VELOCITY CHART ─────────────────────
            _SectionHeader(title: 'Revenue Trajectory', badge: '+18.4% RUN RATE'),
            const SizedBox(height: 12),
            _RevenueAreaChartCard(periodIndex: _selectedPeriod),
            const SizedBox(height: 28),

            // ── 4. THROUGHPUT & EFFICIENCY DUAL BAR GRAPH ──────────────────
            _SectionHeader(title: 'Daily Bay Throughput', badge: 'CAPACITY VS COMPLETED'),
            const SizedBox(height: 12),
            _ThroughputBarChartCard(primaryColor: colorScheme.primary, secondaryColor: colorScheme.secondary),
            const SizedBox(height: 28),

            // ── 5. JOB CATEGORY DONUT DISTRIBUTION ─────────────────────────
            _SectionHeader(title: 'Job Category Distribution', badge: '${jobTypes.length} CATEGORIES'),
            const SizedBox(height: 12),
            _JobCategoryDonutCard(jobTypes: jobTypes),
            const SizedBox(height: 28),

            // ── 6. REVENUE FINANCIAL BREAKDOWN ────────────────────────────
            _SectionHeader(title: 'Financial Telemetry Logs'),
            const SizedBox(height: 12),
            ...metrics.map(
              (m) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(m.icon, size: 18, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                          Text(
                            m.amount,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurface,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        m.change,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                          fontFeatures: const [FontFeature.tabularFigures()],
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
  }
}

// ─── 1. REVENUE AREA CHART ───────────────────────────────────────────────────
class _RevenueAreaChartCard extends StatelessWidget {
  final int periodIndex;

  const _RevenueAreaChartCard({required this.periodIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final points = periodIndex == 0
        ? [0.25, 0.45, 0.35, 0.68, 0.55, 0.85, 0.94]
        : periodIndex == 1
        ? [0.3, 0.38, 0.5, 0.45, 0.6, 0.72, 0.65, 0.8, 0.88, 0.95]
        : [0.2, 0.4, 0.35, 0.6, 0.55, 0.75, 0.9, 0.85, 0.98];

    final labels = periodIndex == 0
        ? ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
        : periodIndex == 1
        ? ['W1', 'W2', 'W3', 'W4']
        : ['Q1', 'Q2', 'Q3', 'Q4'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$42,850.00',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'Net Gross Inflow (Real-Time)',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 16),
                    SizedBox(width: 4),
                    Text(
                      '+24.6%',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _AreaChartPainter(
                lineColor: colorScheme.primary,
                fillGradient: LinearGradient(
                  colors: [colorScheme.primary.withValues(alpha: 0.35), colorScheme.primary.withValues(alpha: 0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                points: points,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((l) {
              return Text(
                l,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  final Color lineColor;
  final Gradient fillGradient;
  final List<double> points;

  const _AreaChartPainter({required this.lineColor, required this.fillGradient, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final path = Path();
    final fillPath = Path();
    final step = size.width / (points.length - 1);

    path.moveTo(0, size.height * (1.0 - points.first));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height * (1.0 - points.first));

    for (int i = 1; i < points.length; i++) {
      final x = i * step;
      final y = size.height * (1.0 - points[i]);
      final prevX = (i - 1) * step;
      final prevY = size.height * (1.0 - points[i - 1]);

      final controlX = (prevX + x) / 2;
      path.cubicTo(controlX, prevY, controlX, y, x, y);
      fillPath.cubicTo(controlX, prevY, controlX, y, x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Grid dots on highest peaks
    for (int i = 0; i < points.length; i++) {
      if (i == points.length - 1 || points[i] > 0.8) {
        final x = i * step;
        final y = size.height * (1.0 - points[i]);
        canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = lineColor);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) => oldDelegate.points != points;
}

// ─── 2. THROUGHPUT DUAL-BAR CHART ────────────────────────────────────────────
class _ThroughputBarChartCard extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;

  const _ThroughputBarChartCard({required this.primaryColor, required this.secondaryColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final assigned = [14, 18, 22, 19, 26, 30, 16];
    final finished = [12, 16, 20, 18, 25, 28, 15];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text('Assigned', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 14),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: secondaryColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text('Completed', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              Text(
                '94.2% RATE',
                style: textTheme.labelSmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(days.length, (i) {
                final aFrac = assigned[i] / 32;
                final fFrac = finished[i] / 32;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 10,
                          height: 100 * aFrac,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 10,
                          height: 100 * fFrac,
                          decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[i],
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 3. JOB CATEGORY DONUT DISTRIBUTION ──────────────────────────────────────
class _JobCategoryDonutCard extends StatelessWidget {
  final List<JobTypeEntity> jobTypes;
  const _JobCategoryDonutCard({required this.jobTypes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final total = jobTypes.fold(0, (s, t) => s + t.count);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(110, 110),
                  painter: _DonutChartPainter(jobTypes, holeColor: colorScheme.surface),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'JOBS',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: jobTypes.map((t) {
                final pct = total > 0 ? (t.count / total * 100).toStringAsFixed(0) : '0';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: t.color, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.label,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
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
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<JobTypeEntity> types;
  final Color holeColor;

  const _DonutChartPainter(this.types, {required this.holeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final total = types.fold(0, (s, t) => s + t.count);
    if (total == 0) return;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double start = -math.pi / 2;

    for (final t in types) {
      final sweep = 2 * math.pi * (t.count / total);
      canvas.drawArc(rect, start, sweep, true, Paint()..color = t.color);
      start += sweep;
    }
    canvas.drawCircle(size.center(Offset.zero), size.width * 0.35, Paint()..color = holeColor);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => oldDelegate.holeColor != holeColor;
}

// ─── 4. HELPER COMPONENTS & CHIPS ────────────────────────────────────────────
class _PeriodFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodFilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _QuickStatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? badge;
  const _SectionHeader({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 9,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
