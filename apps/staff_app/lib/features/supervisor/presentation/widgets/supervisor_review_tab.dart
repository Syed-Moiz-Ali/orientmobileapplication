import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class SupervisorReviewTab extends ConsumerWidget {
  const SupervisorReviewTab({super.key});

  Future<void> _approve(BuildContext context, WidgetRef ref, int jobCardId, String refLabel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Approve completion?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Approve $refLabel — the invoice will be raised automatically.',
          style: const TextStyle(color: AppColors.text3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve', style: TextStyle(color: AppColors.success)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final msg = await ref.read(supervisorDashboardProvider.notifier).approveCompletion(jobCardId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, int jobCardId, String refLabel) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Send back for revision', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'All completed items of $refLabel will be reset to pending with this reason.',
              style: const TextStyle(color: AppColors.text3, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: 'Reason (e.g. re-check headlight alignment)',
                hintStyle: TextStyle(color: AppColors.text4),
                filled: true,
                fillColor: AppColors.primaryBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              reasonCtrl.text.trim().isEmpty ? 'Work needs revision' : reasonCtrl.text.trim(),
            ),
            child: const Text('Send back', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == null) return;
    final msg = await ref.read(supervisorDashboardProvider.notifier).rejectCompletion(jobCardId, confirmed);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

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
                style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
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
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.text3, size: 20),
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
                          StatusPill(label: '${job.done}/${job.total} done', bg: AppColors.primaryBg, fg: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${job.customerName} · ${job.vehicleInfo}',
                        style: const TextStyle(color: AppColors.text3, fontSize: 13),
                      ),
                      if (job.technician.isNotEmpty)
                        Text(
                          'Technician: ${job.technician}',
                          style: const TextStyle(color: AppColors.text3, fontSize: 12),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Updated ${job.updatedAt}',
                        style: const TextStyle(color: AppColors.text4, fontSize: 11),
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
                                item.itemType == 'INSPECTION' ? 'Inspection' : 'Work',
                                style: const TextStyle(color: AppColors.text4, fontSize: 10),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.empName,
                                style: const TextStyle(color: AppColors.text3, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppDimensions.r10),
                                  ),
                                ),
                                onPressed: () => _approve(context, ref, job.jobCardId, job.jobCardRef),
                                child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  side: const BorderSide(color: AppColors.danger),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppDimensions.r10),
                                  ),
                                ),
                                onPressed: () => _reject(context, ref, job.jobCardId, job.jobCardRef),
                                child: const Text('Send back', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ],
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
