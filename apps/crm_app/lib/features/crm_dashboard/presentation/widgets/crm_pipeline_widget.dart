import 'package:flutter/material.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

class LeadPipelineWidget extends StatelessWidget {
  final LeadStatsEntity stats;

  /// Tapping a stage filters the leads board. Null keeps the widget a pure
  /// readout (existing callers unaffected).
  final ValueChanged<String>? onStageTap;

  /// Uppercase stage currently filtering the board, if any.
  final String selectedStage;

  const LeadPipelineWidget({
    super.key,
    required this.stats,
    this.onStageTap,
    this.selectedStage = '',
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    if (stats.pipeline.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CrmColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.filter_alt_outlined, size: 30, color: CrmColors.textM),
            const SizedBox(height: 10),
            Text(
              t.fnEmpty,
              style: const TextStyle(color: CrmColors.textM, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final maxCount = stats.pipeline.fold<int>(1, (m, s) => s.count > m ? s.count : m);
    final tap = onStageTap;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CrmColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.fnPipeline,
            style: const TextStyle(color: CrmColors.textH, fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...stats.pipeline.map((stage) {
            final (color, bg) = switch (stage.status.toUpperCase()) {
              'WON' => (CrmColors.green, CrmColors.greenBg),
              'LOST' => (CrmColors.red, CrmColors.redBg),
              'UNANSWERED' => (CrmColors.amber, CrmColors.amberBg),
              _ => (CrmColors.accent, CrmColors.accentLight),
            };
            final selected =
                selectedStage.isNotEmpty &&
                stage.status.toUpperCase() == selectedStage;
            final body = Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        stage.status,
                        style: const TextStyle(
                          color: CrmColors.textH,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${stage.count}',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (stage.value > 0) ...[
                        const SizedBox(width: 6),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            'AED ${stage.value.toStringAsFixed(0)}',
                            style: const TextStyle(color: CrmColors.textM, fontSize: 10),
                          ),
                        ),
                      ],
                      if (tap != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.chevron_right_rounded,
                          size: 16,
                          color: selected ? color : CrmColors.textM,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stage.count / maxCount,
                      minHeight: 7,
                      backgroundColor: bg,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
            if (tap == null) return body;
            return InkWell(
              onTap: () => tap(stage.status),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: selected
                    ? BoxDecoration(
                        border: Border.all(color: color.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: body,
              ),
            );
          }),
          const SizedBox(height: 6),
          const Divider(height: 1, color: CrmColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                t.fnConversion,
                style: const TextStyle(color: CrmColors.textM, fontSize: 11),
              ),
              const Spacer(),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${stats.conversionRate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: CrmColors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                t.fnWonRevenue,
                style: const TextStyle(color: CrmColors.textM, fontSize: 11),
              ),
              const Spacer(),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  'AED ${stats.wonValue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: CrmColors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
