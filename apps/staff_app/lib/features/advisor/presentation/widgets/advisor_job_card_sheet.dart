import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_status.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'advisor_divider.dart';
import 'advisor_detail_line.dart';
import 'advisor_outline_action.dart';
import 'advisor_solid_action.dart';

/// Quick job-card preview sheet (S10). Opened from the jobs list overflow
/// action so an advisor can scan the essentials without leaving the list. The
/// full workspace remains a pushed route via [onOpen].
///
/// Chrome note (GROUP-B list rebuild): presented via [showAppBottomSheet], so
/// this widget renders content only — no sheet wrapper of its own.
class AdvisorJobCardSheet extends StatelessWidget {
  final JobCardEntity jc;
  final VoidCallback onOpen;
  const AdvisorJobCardSheet({
    super.key,
    required this.jc,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jc.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mono(color: colors.onSurface),
                    ),
                    const SizedBox(height: AppDimensions.xxs),
                    Text(
                      jc.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              advisorStatusPill(t, jc.status),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          const AdvisorDivider(),
          const SizedBox(height: AppDimensions.s12),
          AdvisorDetailLine(
            icon: Icons.directions_car_outlined,
            label: t.advisorFieldVehicle,
            value: jc.vehicleInfo,
          ),
          if (jc.technician.isNotEmpty)
            AdvisorDetailLine(
              icon: Icons.engineering_outlined,
              label: t.advisorFieldTechnician,
              value: jc.technician,
            ),
          AdvisorDetailLine(
            icon: Icons.schedule_outlined,
            label: t.advisorFieldCreated,
            value: jc.time,
          ),
          if (jc.odometer != null)
            AdvisorDetailLine(
              icon: Icons.speed_rounded,
              label: t.advisorFieldOdometer,
              value: t.advisorOdometerValue('${jc.odometer}'),
            ),
          const SizedBox(height: AppDimensions.s6),
          Row(
            children: [
              Expanded(
                child: AdvisorOutlineAction(
                  label: t.advisorActionClose,
                  icon: Icons.close_rounded,
                  color: colors.onSurfaceVariant,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: AdvisorSolidAction(
                  label: t.advisorActionOpenJob,
                  icon: Icons.open_in_new_rounded,
                  color: colors.primary,
                  onTap: onOpen,
                ),
              ),
            ],
          ),
        ],
    );
  }
}
