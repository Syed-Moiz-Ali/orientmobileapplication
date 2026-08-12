import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'advisor_status_badge.dart';

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
    return GestureDetector(
      onTap: () => onTap(jc),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.r14),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 48,
              decoration: BoxDecoration(
                color: s.color,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppDimensions.r2),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        jc.id,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      AdvisorStatusBadge(s.label, s.color, s.bg),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    jc.customerName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.text2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 11,
                        color: AppColors.text3,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          jc.vehicleInfo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.text3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        jc.time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.text3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.stroke,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

