import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/qc_checklist_sheet.dart';

/// Quality control verification tab for completed technician repair orders.
class SupervisorReviewTab extends ConsumerWidget {
  const SupervisorReviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final awaiting = notifier.awaitingCompletions;
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: RefreshIndicator(
            onRefresh: notifier.refreshReview,
            color: colorScheme.primary,
            backgroundColor: colorScheme.surface,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // ── Header Bar ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quality Control Inspection',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Inspect and verify completed repair orders before delivery',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.isReviewLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        tooltip: 'Refresh Inspections',
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          notifier.refreshReview();
                        },
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Error notice if present
                if (state.reviewError.isNotEmpty) ...[
                  _ReviewNotice(
                    message: state.reviewError,
                    onRetry: notifier.refreshReview,
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Cards List or Grid ──────────────────────────────────
                if (awaiting.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: EmptyState(
                      icon: Icons.verified_outlined,
                      title: 'No repairs awaiting QC sign-off',
                      message:
                          'All completed technician work orders have been verified and closed.',
                    ),
                  )
                else if (isWide)
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: awaiting.map((job) {
                      return SizedBox(
                        width: (1100 - 48) / 2,
                        child: _QcJobCard(job: job),
                      );
                    }).toList(),
                  )
                else
                  ...awaiting.map(
                    (job) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _QcJobCard(job: job),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QcJobCard extends StatelessWidget {
  final dynamic job;

  const _QcJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final int total = job.total as int? ?? 0;
    final int done = job.done as int? ?? 0;
    final double progress = total > 0 ? done / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        job.jobCardRef as String? ?? 'Job Card',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$done/$total DONE',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${job.customerName} · ${job.vehicleInfo}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => QcChecklistSheet(
                    jobCardId: job.jobCardId as int? ?? 0,
                    jobCardRef: job.jobCardRef as String? ?? '',
                    customerName: job.customerName as String? ?? '',
                    vehicleInfo: job.vehicleInfo as String? ?? '',
                    workItems: (job.items as List<dynamic>? ?? [])
                        .map((e) => (e.description as String? ?? '').trim())
                        .where((d) => d.isNotEmpty)
                        .toList(),
                  ),
                );
              },
              icon: const Icon(Icons.fact_check_rounded, size: 16),
              label: const Text(
                'Start QC Inspection',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ReviewNotice({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: colors.onErrorContainer,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onErrorContainer),
            ),
          ),
          IconButton(
            tooltip: 'Retry',
            visualDensity: VisualDensity.compact,
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
