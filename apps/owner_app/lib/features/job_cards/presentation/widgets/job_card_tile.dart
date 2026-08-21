import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppDimensions.r20,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                jobCard.id,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: AppFontFamilies.mono,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _StatusBadge(jobCard: jobCard),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            jobCard.customerName,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            jobCard.vehicleDisplay,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 10),
          _InfoRow(label: 'Services:', value: jobCard.services.join(', ')),
          const SizedBox(height: 4),
          _InfoRow(label: 'Specialist:', value: jobCard.technician),
          const SizedBox(height: 4),
          _InfoRow(label: 'Est. Completion:', value: jobCard.estCompletion),
          const SizedBox(height: 12),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'AED ${jobCard.amount.toStringAsFixed(2)}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: onViewDetails,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r10),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
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
    JobCardStatus.pending => AppColors.warning,
    JobCardStatus.awaitingSupervisor => AppColors.warning,
    JobCardStatus.vehicleReceived => AppColors.info,
    JobCardStatus.waitingCustomerApproval => AppColors.warning,
    JobCardStatus.delivered => AppColors.success,
    JobCardStatus.qualityCheckPassed => AppColors.success,
  };
  Color _statusBg(JobCardStatus s) => switch (s) {
    JobCardStatus.inProgress => AppColors.primaryBg,
    JobCardStatus.waitingParts => AppColors.warningBg,
    JobCardStatus.qualityCheck => AppColors.infoBg,
    JobCardStatus.completed => AppColors.successBg,
    JobCardStatus.cancelled => AppColors.dangerBg,
    JobCardStatus.pendingApproval => AppColors.warningBg,
    JobCardStatus.pending => AppColors.warningBg,
    JobCardStatus.awaitingSupervisor => AppColors.warningBg,
    JobCardStatus.vehicleReceived => AppColors.infoBg,
    JobCardStatus.waitingCustomerApproval => AppColors.warningBg,
    JobCardStatus.delivered => AppColors.successBg,
    JobCardStatus.qualityCheckPassed => AppColors.successBg,
  };
  String _statusLabel(JobCardStatus s) => switch (s) {
    JobCardStatus.inProgress => 'In Progress',
    JobCardStatus.waitingParts => 'Waiting Parts',
    JobCardStatus.qualityCheck => 'Quality Check',
    JobCardStatus.completed => 'Completed',
    JobCardStatus.cancelled => 'Cancelled',
    JobCardStatus.pendingApproval => 'Pending Approval',
    JobCardStatus.pending => 'Pending',
    JobCardStatus.awaitingSupervisor => 'Awaiting Supervisor',
    JobCardStatus.vehicleReceived => 'Vehicle Received',
    JobCardStatus.waitingCustomerApproval => 'Waiting Customer Approval',
    JobCardStatus.delivered => 'Delivered',
    JobCardStatus.qualityCheckPassed => 'QC Passed',
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
