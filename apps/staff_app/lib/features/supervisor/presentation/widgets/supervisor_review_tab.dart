import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/qc_checklist_sheet.dart';

class SupervisorReviewTab extends ConsumerWidget {
  const SupervisorReviewTab({super.key});

  // The _approve and _reject methods are no longer needed here as they've moved to QcChecklistSheet

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final awaiting = notifier.awaitingCompletions;

    return RefreshIndicator(
      onRefresh: notifier.refreshReview,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.s16),
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF238636),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Completion Review',
                style: AppTextStyles.rajdhaniTitle(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (state.isReviewLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: notifier.refreshReview,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.text3,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Every work item was completed — check the evidence and approve or send back.',
            style: TextStyle(fontSize: 13, color: AppColors.text3),
          ),
          const SizedBox(height: 16),
          if (awaiting.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: EmptyState(
                icon: Icons.verified_outlined,
                message: 'Nothing awaiting review',
              ),
            )
          else
            ...awaiting.map(
              (job) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(AppDimensions.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              job.jobCardRef,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          StatusPill(
                            label: '${job.done}/${job.total} done',
                            bg: AppColors.primaryBg,
                            fg: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${job.customerName} · ${job.vehicleInfo}',
                        style: const TextStyle(
                          color: AppColors.text3,
                          fontSize: 13,
                        ),
                      ),
                      if (job.technician.isNotEmpty)
                        Text(
                          'Technician: ${job.technician}',
                          style: const TextStyle(
                            color: AppColors.text3,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Updated ${job.updatedAt}',
                        style: const TextStyle(
                          color: AppColors.text4,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: job.total > 0 ? job.done / job.total : 0,
                          minHeight: 6,
                          backgroundColor: AppColors.primaryBg,
                          color: const Color(0xFF238636),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...job.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Icon(
                                item.status == 'completed'
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 16,
                                color: item.status == 'completed'
                                    ? AppColors.success
                                    : AppColors.text4,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.description,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12.5,
                                    fontWeight: item.status == 'completed'
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              Text(
                                item.itemType == 'INSPECTION'
                                    ? 'Inspection'
                                    : 'Work',
                                style: const TextStyle(
                                  color: AppColors.text4,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.empName,
                                style: const TextStyle(
                                  color: AppColors.text3,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F6FEB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r10,
                              ),
                            ),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => QcChecklistSheet(
                                jobCardId: job.jobCardId,
                                jobCardRef: job.jobCardRef,
                                customerName: job.customerName,
                                vehicleInfo: job.vehicleInfo,
                                // FE-FLOW: checklist driven by the actual
                                // completed work items (was hardcoded).
                                workItems: job.items
                                    .map((e) => e.description)
                                    .where((d) => d.isNotEmpty)
                                    .toList(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.fact_check_rounded, size: 18),
                          label: const Text(
                            'Start QC Review',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
