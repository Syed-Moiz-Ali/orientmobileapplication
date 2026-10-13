import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';

class KpiCard extends StatelessWidget {
  final OwnerKpi kpi;
  const KpiCard({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: kpi.color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            // Phase 01: the sub chip takes its natural width and only shrinks
            // when it genuinely cannot fit — a Spacer would split the row
            // 50/50 and ellipsize "6 due today" at 1.0x scale.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kpi.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(kpi.icon, color: kpi.color, size: 19),
              ),
              if (kpi.sub.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      kpi.sub,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            kpi.value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            kpi.label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
