import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';

class JobCardTile extends StatelessWidget {
  final AssignedJobEntity job;
  final void Function(AssignedJobStatus) onStatusChanged;

  const JobCardTile({
    super.key,
    required this.job,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status = job.status;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.s14,
              vertical: AppDimensions.s10,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.r16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 13,
                  color: AppColors.accent,
                ),
                SizedBox(width: AppDimensions.s6),
                Text(
                  job.id,
                  style: AppTextStyles.bodyStrong(color: AppColors.accent),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.s8,
                    vertical: AppDimensions.s4,
                  ),
                  decoration: BoxDecoration(
                    color: status.bgColor,
                    borderRadius: BorderRadius.circular(AppDimensions.r20),
                    border: Border.all(
                      color: status.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    status.label,
                    style: AppTextStyles.bodyStrong(color: status.color),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.s14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.navy, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          job.customerName[0],
                          style: AppTextStyles.bodyStrong(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.s10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.customerName,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            job.vehicle,
                            style: TextStyle(
                              color: AppColors.text3,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.s10),
                Container(height: 1, color: AppColors.border),
                SizedBox(height: AppDimensions.s10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service',
                            style: AppTextStyles.bodySmall(
                              color: AppColors.text3,
                            ),
                          ),
                          Text(
                            job.service,
                            style: TextStyle(
                              color: AppColors.text2,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _AssignedActionButton(
                      label: status.actionLabel,
                      color: status.color,
                      bg: status.bgColor,
                      onTap: () {
                        if (status == AssignedJobStatus.pending) {
                          onStatusChanged(AssignedJobStatus.inProgress);
                        } else if (status == AssignedJobStatus.inProgress) {
                          onStatusChanged(AssignedJobStatus.completed);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedActionButton extends StatelessWidget {
  final String label;
  final Color color, bg;
  final VoidCallback onTap;

  const _AssignedActionButton({
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.s14,
          vertical: AppDimensions.s8,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimensions.r10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall(color: color),
        ),
      ),
    );
  }
}
