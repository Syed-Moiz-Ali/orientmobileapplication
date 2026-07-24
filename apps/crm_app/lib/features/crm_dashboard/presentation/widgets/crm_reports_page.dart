import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';

class CrmCardTitle extends StatelessWidget {
  final String text;
  const CrmCardTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: CrmColors.textH,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  );
}

class CrmReportsPage extends ConsumerWidget {
  const CrmReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.read(crmUiProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        children: [
          AppCard.surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CrmCardTitle('Conversion Trends'),
                const SizedBox(height: AppDimensions.s16),
                SizedBox(
                  height: 130,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _CrmConversionTrendPainter(
                      data: ui.conversionTrend,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.s10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ui.conversionTrend
                      .map(
                        (p) => Text(
                          p.month,
                          style: const TextStyle(
                            color: CrmColors.textM,
                            fontSize: 10,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppDimensions.s10),
                Row(
                  children: [
                    _legendDot(CrmColors.green, 'Won'),
                    const SizedBox(width: AppDimensions.s12),
                    _legendDot(CrmColors.red, 'Lost'),
                    const SizedBox(width: AppDimensions.s12),
                    _legendDot(CrmColors.accent, 'Active'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Expanded(
                child: AppCard.surface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CrmCardTitle('Lead Sources'),
                      const SizedBox(height: AppDimensions.s12),
                      SizedBox(
                        height: 140,
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _CrmPieChartPainter(slices: ui.leadSources),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s10),
                      ...ui.leadSources
                          .take(4)
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: s.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      s.label,
                                      style: const TextStyle(
                                        color: CrmColors.textM,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${s.percent.round()}%',
                                    style: TextStyle(
                                      color: s.color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: AppCard.surface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CrmCardTitle('Salesperson\nPerformance'),
                      const SizedBox(height: AppDimensions.s12),
                      SizedBox(
                        height: 140,
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _CrmSalespersonBarPainter(
                            data: ui.salespersonPerf,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s10),
                      Row(
                        children: [
                          _legendRect(CrmColors.accent, 'Leads'),
                          const SizedBox(width: AppDimensions.s8),
                          _legendRect(CrmColors.green, 'Won'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          AppCard.surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CrmCardTitle('Response Time Analysis'),
                const SizedBox(height: AppDimensions.s16),
                SizedBox(
                  height: 120,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _CrmResponseTimePainter(
                      data: ui.responseTimeBuckets,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.s8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ui.responseTimeBuckets
                      .map(
                        (b) => Text(
                          b.label,
                          style: const TextStyle(
                            color: CrmColors.textM,
                            fontSize: 9,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          AppCard.surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CrmCardTitle('Key Metrics'),
                const SizedBox(height: AppDimensions.s12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: ui.keyMetrics.length,
                  itemBuilder: (_, i) =>
                      _CrmKeyMetricCard(metric: ui.keyMetrics[i]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: CrmColors.textM, fontSize: 10)),
    ],
  );

  Widget _legendRect(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimensions.r2),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: CrmColors.textM, fontSize: 10)),
    ],
  );
}

class _CrmKeyMetricCard extends StatelessWidget {
  final CrmKeyMetric metric;
  const _CrmKeyMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: metric.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: metric.color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            metric.label,
            style: const TextStyle(color: CrmColors.textM, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            metric.value,
            style: TextStyle(
              color: metric.color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.sub,
            style: TextStyle(
              color: metric.up ? CrmColors.green : CrmColors.red,
              fontSize: 9,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CrmConversionTrendPainter extends CustomPainter {
  final List<CrmTrendPoint> data;
  const _CrmConversionTrendPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final wonVals = data.map((d) => d.won).toList();
    final lostVals = data.map((d) => d.lost).toList();
    final activeVals = data.map((d) => d.active).toList();
    final allVals = [...wonVals, ...lostVals, ...activeVals];
    final maxVal = allVals.reduce(math.max);

    void drawLine(List<double> values, Color color) {
      final path = Path();
      final fill = Path();
      for (var i = 0; i < values.length; i++) {
        final x = size.width * i / (values.length - 1);
        final y = size.height * (1 - values[i] / maxVal);
        if (i == 0) {
          path.moveTo(x, y);
          fill.moveTo(x, y);
        } else {
          path.lineTo(x, y);
          fill.lineTo(x, y);
        }
      }
      fill
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill,
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      for (var i = 0; i < values.length; i++) {
        final x = size.width * i / (values.length - 1);
        final y = size.height * (1 - values[i] / maxVal);
        canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = color);
        canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = Colors.white);
      }
    }

    drawLine(activeVals, CrmColors.accent);
    drawLine(wonVals, CrmColors.green);
    drawLine(lostVals, CrmColors.red);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CrmPieChartPainter extends CustomPainter {
  final List<LeadSourceSlice> slices;
  const _CrmPieChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    double startAngle = -math.pi / 2;

    for (final slice in slices) {
      final sweep = 2 * math.pi * (slice.percent / 100);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = slice.color
          ..strokeWidth = 18
          ..style = PaintingStyle.stroke,
      );
      startAngle += sweep;
    }

    final tp = TextPainter(
      text: TextSpan(
        children: const [
          TextSpan(
            text: '1,247\n',
            style: TextStyle(
              color: CrmColors.textH,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: 'Total',
            style: TextStyle(color: CrmColors.textM, fontSize: 9),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CrmSalespersonBarPainter extends CustomPainter {
  final List<SalespersonPerf> data;
  const _CrmSalespersonBarPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = data.map((d) => d.leads).reduce(math.max);
    const bottomPad = 16.0;
    final chartH = size.height - bottomPad;
    final groupW = size.width / data.length;
    final barW = groupW * 0.3;
    const gap = 3.0;

    for (var i = 0; i < data.length; i++) {
      final gx = groupW * i + groupW / 2;
      final lh = chartH * data[i].leads / maxVal;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(gx - barW - gap, chartH - lh, barW, lh),
          const Radius.circular(4),
        ),
        Paint()
          ..shader = const LinearGradient(
            colors: [CrmColors.gEnd, CrmColors.gStart],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, barW, 200)),
      );

      final wh = chartH * data[i].won / maxVal;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(gx + gap, chartH - wh, barW, wh),
          const Radius.circular(4),
        ),
        Paint()..color = CrmColors.green.withValues(alpha: 0.8),
      );

      final nameShort = data[i].name.split(' ').first;
      final tp = TextPainter(
        text: TextSpan(
          text: nameShort,
          style: const TextStyle(color: CrmColors.textM, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(gx - tp.width / 2, size.height - tp.height));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CrmResponseTimePainter extends CustomPainter {
  final List<ResponseTimeBucket> data;
  const _CrmResponseTimePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = data.map((d) => d.count).reduce(math.max);
    const bottomPad = 14.0;
    final chartH = size.height - bottomPad;
    final barW = size.width / data.length * 0.55;
    final spacing = size.width / data.length;

    for (var i = 0; i < data.length; i++) {
      final x = spacing * i + spacing / 2 - barW / 2;
      final h = chartH * data[i].count / maxVal;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, chartH - h, barW, h),
          const Radius.circular(4),
        ),
        Paint()
          ..shader = const LinearGradient(
            colors: [CrmColors.gEnd, CrmColors.accentMid],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(x, 0, barW, h)),
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
