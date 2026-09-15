import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';

class JobCardTile extends StatelessWidget {
  final AssignedJobEntity job;
  final void Function(AssignedJobStatus) onStatusChanged;

  const JobCardTile({super.key, required this.job, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = job.status;
    final canAdvance =
        status == AssignedJobStatus.pending ||
        status == AssignedJobStatus.inProgress;
    return Semantics(
      container: true,
      label:
          '${job.id}, ${job.customerName}, ${job.vehicle}, ${job.plateNumber}, ${status.label}',
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.r16),
          border: Border.all(color: colors.outlineVariant),
          boxShadow: [
            BoxShadow(color: colors.shadow.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.s14, vertical: AppDimensions.s10),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_rounded, size: 13, color: colors.primary),
                  SizedBox(width: AppDimensions.s6),
                  Text(
                    job.id,
                    style: textTheme.labelLarge?.copyWith(color: colors.primary, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.s8, vertical: AppDimensions.s4),
                    decoration: BoxDecoration(
                      color: status.bgColor,
                      borderRadius: BorderRadius.circular(AppDimensions.r20),
                      border: Border.all(color: status.color.withValues(alpha: 0.3)),
                    ),
                    child: Text(status.label, style: AppTextStyles.bodyStrong(color: status.color)),
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
                            job.customerName.trim().isEmpty
                                ? 'C'
                                : job.customerName.trim()[0].toUpperCase(),
                            style: AppTextStyles.bodyStrong(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.s10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.customerName.trim().isEmpty
                                  ? 'Customer'
                                  : job.customerName,
                              style: textTheme.titleSmall?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              [
                                if (job.vehicle.trim().isNotEmpty) job.vehicle,
                                if (job.plateNumber.trim().isNotEmpty)
                                  'Plate ${job.plateNumber}',
                              ].join('  |  '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            if (job.customerPhone.trim().isNotEmpty ||
                                job.customerEmail.trim().isNotEmpty)
                              Text(
                                [
                                  job.customerPhone,
                                  job.customerEmail,
                                ].where((v) => v.trim().isNotEmpty).join('  |  '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.s10),
                  Container(height: 1, color: colors.outlineVariant),
                  SizedBox(height: AppDimensions.s10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service',
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              job.service,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _AssignedActionButton(
                        label: status.actionLabel,
                        color: status.color,
                        bg: status.bgColor,
                        onTap: canAdvance ? () {
                          if (status == AssignedJobStatus.pending) {
                            onStatusChanged(AssignedJobStatus.inProgress);
                          } else if (status == AssignedJobStatus.inProgress) {
                            onStatusChanged(AssignedJobStatus.completed);
                          }
                        } : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignedActionButton extends StatelessWidget {
  final String label;
  final Color color, bg;
  final VoidCallback? onTap;

  const _AssignedActionButton({required this.label, required this.color, required this.bg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.r10),
          child: Ink(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.s14, vertical: AppDimensions.s8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDimensions.r10),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Text(label, style: AppTextStyles.bodySmall(color: color)),
          ),
        ),
      ),
    );
  }
}
