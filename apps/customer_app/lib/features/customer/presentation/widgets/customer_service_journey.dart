import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';

/// The real workshop stage list for the active job.
///
/// Rendered only when the backend actually supplies stages — nothing is
/// synthesised. Each row carries a single, complete semantic label so screen
/// readers announce `"<stage>, <state>[, <time>]"`.
class CustomerServiceJourney extends StatelessWidget {
  final List<ServiceStageEntity> stages;

  const CustomerServiceJourney({super.key, required this.stages});

  @override
  Widget build(BuildContext context) {
    if (stages.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Service journey'),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.s14),
            child: Column(
              children: [
                for (var index = 0; index < stages.length; index++)
                  _JourneyStage(
                    stage: stages[index],
                    isLast: index == stages.length - 1,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _JourneyStage extends StatelessWidget {
  final ServiceStageEntity stage;
  final bool isLast;

  const _JourneyStage({required this.stage, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = CustomerServiceTracking.humanize(stage.name);
    final time = stage.time?.trim() ?? '';
    final stateLabel = switch (stage.status) {
      StageStatus.done => 'Done',
      StageStatus.inProgress => 'Current',
      StageStatus.pending => 'Upcoming',
    };
    final tone = switch (stage.status) {
      StageStatus.done => colors.tertiary,
      StageStatus.inProgress => colors.primary,
      StageStatus.pending => colors.onSurfaceVariant,
    };
    final isPending = stage.status == StageStatus.pending;

    return Semantics(
      excludeSemantics: true,
      label: '$label, $stateLabel${time.isEmpty ? '' : ', $time'}',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isPending
                        ? Colors.transparent
                        : tone.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPending
                          ? colors.outlineVariant
                          : tone.withValues(alpha: 0.9),
                      width: stage.status == StageStatus.inProgress ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: stage.status == StageStatus.done
                        ? Icon(Icons.check_rounded, size: 14, color: tone)
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isPending ? Colors.transparent : tone,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(
                        vertical: AppDimensions.s4,
                      ),
                      color: stage.status == StageStatus.done
                          ? colors.tertiary.withValues(alpha: 0.45)
                          : colors.outlineVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: AppDimensions.s4,
                  bottom: isLast ? 0 : AppDimensions.s14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label.isEmpty ? 'Workshop stage' : label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isPending
                                  ? colors.onSurfaceVariant
                                  : colors.onSurface,
                              fontWeight: isPending
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                          if (time.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              time,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (stage.status != StageStatus.pending) ...[
                      const SizedBox(width: AppDimensions.s8),
                      StatusPill(
                        label: stateLabel,
                        bg: tone.withValues(alpha: 0.12),
                        fg: tone,
                      ),
                    ],
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
