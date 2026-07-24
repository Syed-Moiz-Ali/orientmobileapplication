import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'advisor_sheet.dart';
import 'advisor_handle.dart';
import 'advisor_detail_line.dart';
import 'advisor_outline_action.dart';
import 'advisor_solid_action.dart';

class AdvisorApprovalSheet extends StatelessWidget {
  final PendingApprovalEntity pa;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const AdvisorApprovalSheet({
    super.key,
    required this.pa,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) => AdvisorSheet(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AdvisorHandle(),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(AppDimensions.r14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              Text(
                'AED ${pa.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${pa.estimateId} · ${pa.customerName}',
                style: const TextStyle(fontSize: 13, color: AppColors.text2),
              ),
              const SizedBox(height: 2),
              Text(
                pa.timeAgo,
                style: const TextStyle(fontSize: 11, color: AppColors.text3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AdvisorDetailLine(icon: Icons.directions_car_outlined, label: 'Vehicle', value: pa.vehicleId),
        AdvisorDetailLine(icon: Icons.receipt_long_outlined, label: 'Estimate', value: pa.estimateId),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AdvisorOutlineAction(
                label: 'Send Back',
                icon: Icons.undo_rounded,
                color: AppColors.danger,
                onTap: onReject,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AdvisorSolidAction(
                label: 'Approve',
                icon: Icons.check_rounded,
                gradient: const [AppColors.success, Color(0xFF2DD4BF)],
                onTap: onApprove,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
      ],
    ),
  );
}

