import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';

class _StatusStyle {
  final String label;
  final Color color;
  final Color bg;
  const _StatusStyle(this.label, this.color, this.bg);
}

class AdvisorJobCardRow extends StatelessWidget {
  final JobCardEntity jc;
  final void Function(JobCardEntity) onTap;
  const AdvisorJobCardRow({super.key, required this.jc, required this.onTap});

  _StatusStyle get _s => switch (jc.status) {
    JobCardStatus.inProgress => _StatusStyle(
      'In Progress',
      AppColors.accent,
      AppColors.accent.withValues(alpha: 0.12),
    ),
    JobCardStatus.pendingApproval => _StatusStyle(
      'Pending',
      AppColors.warning,
      AppColors.warningBg,
    ),
    JobCardStatus.completed => _StatusStyle(
      'Completed',
      AppColors.success,
      AppColors.successBg,
    ),
    JobCardStatus.waitingParts => _StatusStyle(
      'Waiting Parts',
      AppColors.danger,
      AppColors.dangerBg,
    ),
    JobCardStatus.qualityCheck => _StatusStyle(
      'QC Check',
      AppColors.info,
      AppColors.infoBg,
    ),
    JobCardStatus.cancelled => _StatusStyle(
      'Cancelled',
      AppColors.text3,
      AppColors.surfaceAlt,
    ),    JobCardStatus.pending => _StatusStyle(
      'Pending',
      AppColors.warning,
      AppColors.warningBg,
    ),
    JobCardStatus.awaitingSupervisor => _StatusStyle(
      'Awaiting Supervisor',
      AppColors.warning,
      AppColors.warningBg,
    ),
    JobCardStatus.vehicleReceived => _StatusStyle(
      'Vehicle Received',
      AppColors.info,
      AppColors.infoBg,
    ),
    JobCardStatus.waitingCustomerApproval => _StatusStyle(
      'Waiting Customer Approval',
      AppColors.warning,
      AppColors.warningBg,
    ),
    JobCardStatus.delivered => _StatusStyle(
      'Delivered',
      AppColors.success,
      AppColors.successBg,
    ),
    JobCardStatus.qualityCheckPassed => _StatusStyle(
      'QC Passed',
      AppColors.success,
      AppColors.successBg,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => onTap(jc),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 52,
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            jc.id,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                          StatusPill(
                            label: s.label,
                            fg: s.color,
                            bg: s.bg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jc.customerName,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              jc.vehicleInfo,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            jc.time,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.outlineVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

