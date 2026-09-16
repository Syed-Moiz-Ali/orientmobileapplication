import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';

/// The booking's current workshop state and the action it needs, if any.
///
/// Only real data is shown: the current stage (humanised), real progress and a
/// real expected completion when the backend provides them, or the real
/// estimate awaiting the customer's decision. The full stage journey stays in
/// Service Status, which this surface links to.
class CustomerBookingDetailService extends StatelessWidget {
  final CustomerBookingEntity booking;

  /// The canonical live job, but only when it belongs to this booking.
  final CustomerServiceEntity? liveService;

  /// True when this booking genuinely has a pending estimate decision.
  final bool approvalPending;

  /// Customer-facing description of the pending decision, already formatted
  /// from real estimate data.
  final String approvalMessage;
  final VoidCallback onReviewEstimate;
  final VoidCallback onTrackService;

  const CustomerBookingDetailService({
    super.key,
    required this.booking,
    required this.approvalPending,
    required this.approvalMessage,
    required this.onReviewEstimate,
    required this.onTrackService,
    this.liveService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final stage = CustomerServiceTracking.humanize(
      liveService?.currentStage ?? '',
    );
    final progress = (liveService?.progressPercent ?? 0).clamp(0, 100);
    final eta = liveService?.estCompletion.trim() ?? '';
    final trackable = liveService != null;

    return CustomerSurfacePanel(
      accent: approvalPending ? colors.error : colors.primary,
      emphasised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A pending decision is what blocks the work, so it comes first.
          if (approvalPending) ...[
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: AppDimensions.iconSm,
                  color: colors.error,
                ),
                const SizedBox(width: AppDimensions.s6),
                Expanded(
                  child: Text(
                    'Action required',
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s6),
            Text(
              approvalMessage,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            FilledButton.icon(
              onPressed: onReviewEstimate,
              icon: const Icon(Icons.fact_check_outlined, size: 18),
              label: const Text('Review estimate'),
            ),
          ],
          if (trackable) ...[
            if (approvalPending) ...[
              const SizedBox(height: AppDimensions.s16),
              Divider(height: 1, color: colors.outlineVariant),
              const SizedBox(height: AppDimensions.s14),
            ],
            Text(
              'Current stage',
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              stage.isEmpty ? 'Service in progress' : stage,
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (progress > 0) ...[
              const SizedBox(height: AppDimensions.s12),
              Semantics(
                excludeSemantics: true,
                label: 'Service progress, $progress percent',
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusPill,
                        ),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 6,
                          backgroundColor: colors.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    Text(
                      '$progress%',
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (eta.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s10),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: AppDimensions.iconSm,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.s6),
                  Expanded(
                    child: Text(
                      'Estimated completion \u00b7 $eta',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppDimensions.s16),
            // The decision owns the primary action whenever there is one.
            if (approvalPending)
              OutlinedButton.icon(
                onPressed: onTrackService,
                icon: const Icon(Icons.track_changes_rounded, size: 18),
                label: const Text('Track service'),
              )
            else
              FilledButton.icon(
                onPressed: onTrackService,
                icon: const Icon(Icons.track_changes_rounded, size: 18),
                label: const Text('Track service'),
              ),
          ],
        ],
      ),
    );
  }
}
