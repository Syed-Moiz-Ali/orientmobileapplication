import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/job_cards/domain/entities/job_card.dart';

class JobCardTile extends StatelessWidget {
  final JobCard jobCard;
  final VoidCallback onViewDetails;

  const JobCardTile({
    super.key,
    required this.jobCard,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  jobCard.id,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.text3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _StatusBadge(jobCard: jobCard),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              jobCard.customerName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              jobCard.vehicleDisplay,
              style: const TextStyle(fontSize: 12, color: AppColors.text3),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.line),
            const SizedBox(height: 10),
            _InfoRow(label: 'Services:', value: jobCard.services.join(', ')),
            const SizedBox(height: 5),
            _InfoRow(label: 'Technician:', value: jobCard.technician),
            const SizedBox(height: 5),
            _InfoRow(label: 'Est. Completion:', value: jobCard.estCompletion),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.line),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _formatAmount(jobCard.amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.s14,
                      vertical: 7,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r8),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    final s = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return 'AED $s';
  }
}

class _StatusBadge extends StatelessWidget {
  final JobCard jobCard;
  const _StatusBadge({required this.jobCard});
  @override
  Widget build(BuildContext context) {
    final color = _statusColor(jobCard.status);
    final bg = _statusBg(jobCard.status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s10,
        vertical: AppDimensions.s4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.r20),
      ),
      child: Text(
        _statusLabel(jobCard.status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(JobCardStatus s) => switch (s) {
    JobCardStatus.inProgress => AppColors.primary,
    JobCardStatus.waitingParts => AppColors.warning,
    JobCardStatus.qualityCheck => AppColors.info,
    JobCardStatus.completed => AppColors.success,
    JobCardStatus.cancelled => AppColors.danger,
    JobCardStatus.pendingApproval => AppColors.warning,
  };
  Color _statusBg(JobCardStatus s) => switch (s) {
    JobCardStatus.inProgress => AppColors.primaryBg,
    JobCardStatus.waitingParts => AppColors.warningBg,
    JobCardStatus.qualityCheck => AppColors.infoBg,
    JobCardStatus.completed => AppColors.successBg,
    JobCardStatus.cancelled => AppColors.dangerBg,
    JobCardStatus.pendingApproval => AppColors.warningBg,
  };
  String _statusLabel(JobCardStatus s) => switch (s) {
    JobCardStatus.inProgress => 'In Progress',
    JobCardStatus.waitingParts => 'Waiting Parts',
    JobCardStatus.qualityCheck => 'Quality Check',
    JobCardStatus.completed => 'Completed',
    JobCardStatus.cancelled => 'Cancelled',
    JobCardStatus.pendingApproval => 'Pending Approval',
  };
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text3)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
