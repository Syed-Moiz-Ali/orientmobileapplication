import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/qc_checklist_sheet.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Quality-control queue: completed repairs awaiting sign-off, opened into the
/// QC checklist sheet. Presentation only.
class SupervisorReviewTab extends ConsumerWidget {
  const SupervisorReviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final awaiting = notifier.awaitingCompletions;
    final loading = state.isReviewLoading && awaiting.isEmpty;

    return RefreshIndicator(
      onRefresh: notifier.refreshReview,
      color: context.colors.primary,
      backgroundColor: context.colors.surface,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s16,
          context.pagePadding.right,
          AppDimensions.s40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPageHeader(
              title: t.svReviewTitle,
              subtitle: t.svReviewSubtitle,
              leading: const Icon(Icons.verified_outlined),
              actions: [
                IconButton(
                  tooltip: SharedCoreL10n.of(context).commonRetry,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    notifier.refreshReview();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s16),
            if (state.reviewError.isNotEmpty)
              AppErrorState(
                title: SharedCoreL10n.of(context).commonErrorTitle,
                message: t.svReviewError,
                retryLabel: SharedCoreL10n.of(context).commonRetry,
                onRetry: notifier.refreshReview,
              )
            else if (loading)
              const AppShimmerSkeleton.listRows(rows: 5)
            else if (awaiting.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.s40,
                ),
                child: AppEmptyState(
                  icon: Icons.verified_outlined,
                  title: t.svReviewEmpty,
                  message: t.svReviewEmptyMessage,
                ),
              )
            else
              for (final job in awaiting)
                _QcRow(
                  jobCardId: job.jobCardId,
                  jobCardRef: job.jobCardRef,
                  customerName: job.customerName,
                  vehicleInfo: job.vehicleInfo,
                  technician: job.technician,
                  done: job.done,
                  total: job.total,
                  workItems: job.items
                      .map((e) => e.description)
                      .where((d) => d.trim().isNotEmpty)
                      .toList(),
                ),
          ],
        ),
      ),
    );
  }
}

class _QcRow extends StatelessWidget {
  final int jobCardId;
  final String jobCardRef;
  final String customerName;
  final String vehicleInfo;
  final String technician;
  final int done;
  final int total;
  final List<String> workItems;

  const _QcRow({
    required this.jobCardId,
    required this.jobCardRef,
    required this.customerName,
    required this.vehicleInfo,
    required this.technician,
    required this.done,
    required this.total,
    required this.workItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = StaffLocalizations.of(context)!;
    final progress = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        jobCardRef,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: supervisorMono(
                          context,
                          color: context.colors.onSurface,
                        ).copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s8),
                  AppStatusChip(
                    label: t.svReviewProgress(done, total),
                    kind: AppStatusKind.info,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$customerName · $vehicleInfo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (technician.isNotEmpty) ...[
                    const SizedBox(width: AppDimensions.s8),
                    // U13: initials stay compact by design (brief-kept), but
                    // the feed's full technician name is one long-press away
                    // and exposed to screen readers. Zero new copy.
                    Tooltip(
                      message: technician,
                      child: Text(
                        initialsOf(technician),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimensions.s10),
              // C2: complete pins success (never the auto error red), partial
              // pins neutral accent — the meter never contradicts the pill.
              // Same progress value, token only.
              AppProgressBar(
                value: progress,
                tone: total > 0 && done >= total
                    ? AppProgressTone.success
                    : AppProgressTone.accent,
              ),
              const SizedBox(height: AppDimensions.s12),
              AppPillButton.primary(
                label: t.svReviewStart,
                icon: Icons.fact_check_rounded,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  showQcChecklistSheet(
                    context,
                    jobCardId: jobCardId,
                    jobCardRef: jobCardRef,
                    customerName: customerName,
                    vehicleInfo: vehicleInfo,
                    workItems: workItems,
                  );
                },
              ),
            ],
          ),
        ),
        const AppDivider(),
      ],
    );
  }
}
