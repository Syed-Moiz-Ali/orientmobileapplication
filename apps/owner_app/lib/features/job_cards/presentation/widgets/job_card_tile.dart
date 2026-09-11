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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  jobCard.id,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontFamily: AppFontFamilies.mono,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              _StatusBadge(jobCard: jobCard),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                child: Text(
                  jobCard.customerName.isNotEmpty
                      ? jobCard.customerName[0].toUpperCase()
                      : 'C',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobCard.customerName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      jobCard.vehicleDisplay,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
          const SizedBox(height: 10),
          _InfoRow(label: 'Services:', value: jobCard.services.join(', ')),
          const SizedBox(height: 4),
          _InfoRow(label: 'Specialist:', value: jobCard.technician),
          const SizedBox(height: 4),
          _InfoRow(label: 'Est. Completion:', value: jobCard.estCompletion),
          const SizedBox(height: 12),
          Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimate Total',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'AED ${jobCard.amount.toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: onViewDetails,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text(
                  'Details',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
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
    return StatusPill(
      label: _statusLabel(jobCard.status),
      fg: color,
      bg: bg,
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
