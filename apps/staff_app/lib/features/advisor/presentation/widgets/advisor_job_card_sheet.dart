import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'advisor_sheet.dart';
import 'advisor_handle.dart';
import 'advisor_divider.dart';
import 'advisor_detail_line.dart';
import 'advisor_outline_action.dart';
import 'advisor_solid_action.dart';
import 'advisor_status_badge.dart';

class _StatusStyle {
  final String label;
  final Color color;
  final Color bg;
  const _StatusStyle(this.label, this.color, this.bg);
}

class AdvisorJobCardSheet extends StatelessWidget {
  final JobCardEntity jc;
  final VoidCallback onOpen;
  const AdvisorJobCardSheet({
    super.key,
    required this.jc,
    required this.onOpen,
  });

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
    ),
  };

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return AdvisorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdvisorHandle(),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.r2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jc.id,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      jc.customerName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.text2,
                      ),
                    ),
                  ],
                ),
              ),
              AdvisorStatusBadge(s.label, s.color, s.bg),
            ],
          ),
          const SizedBox(height: 18),
          const AdvisorDivider(),
          const SizedBox(height: 12),
          AdvisorDetailLine(
            icon: Icons.directions_car_outlined,
            label: 'Vehicle',
            value: jc.vehicleInfo,
          ),
          AdvisorDetailLine(
            icon: Icons.schedule_outlined,
            label: 'Created',
            value: jc.time,
          ),
          AdvisorDetailLine(
            icon: Icons.person_outline_rounded,
            label: 'Advisor',
            value: '',
          ),
          AdvisorDetailLine(
            icon: Icons.build_outlined,
            label: 'Bay',
            value: 'Bay 03',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AdvisorOutlineAction(
                  label: 'Call Customer',
                  icon: Icons.phone_outlined,
                  color: AppColors.accent,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdvisorSolidAction(
                  label: 'Open Job Card',
                  icon: Icons.open_in_new_rounded,
                  gradient: const [AppColors.navy, AppColors.accent],
                  onTap: onOpen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
