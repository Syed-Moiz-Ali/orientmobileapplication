import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';

class AdvisorApprovalRow extends StatelessWidget {
  final PendingApprovalEntity pa;
  final void Function(PendingApprovalEntity) onTap;
  const AdvisorApprovalRow({super.key, required this.pa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(pa),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(AppDimensions.r14),
          border: Border.all(color: AppColors.warningBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.r10),
                border: Border.all(color: AppColors.warningBorder),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.warning,
                size: 18,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pa.estimateId,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pa.customerName} · ${pa.vehicleId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.text2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pa.timeAgo,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'AED ${pa.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.stroke,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
