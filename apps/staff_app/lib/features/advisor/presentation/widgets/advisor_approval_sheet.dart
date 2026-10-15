import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'advisor_sheet.dart';
import 'advisor_detail_line.dart';
import 'advisor_outline_action.dart';
import 'advisor_solid_action.dart';
import 'advisor_status.dart';

/// Estimate approval sheet: record summary plus approve / send-back actions.
/// Line items beyond the recorded estimate header do not exist on
/// [PendingApprovalEntity], so the sheet presents the recorded diff
/// (amount + identifiers) without inventing line-item rows.

/// Estimate approval sheet: record summary plus approve / send-back actions.
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final money = AppFormatters.of(context).moneyAED(pa.amount);

    return AdvisorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.s20,
              horizontal: AppDimensions.s16,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    pa.isEstimate
                        ? money
                        : advisorApprovalTypeLabel(t, pa.approvalType),
                    style: AppTextStyles.displayMedium(color: colors.onSurface),
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  '${pa.estimateId} · ${pa.customerName}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pa.timeAgo,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AdvisorDetailLine(
            icon: Icons.directions_car_outlined,
            label: t.advisorFieldVehicle,
            value: pa.vehicleId,
          ),
          AdvisorDetailLine(
            icon: pa.isEstimate
                ? Icons.receipt_long_outlined
                : Icons.assignment_turned_in_outlined,
            label: advisorApprovalTypeLabel(t, pa.approvalType),
            value: pa.estimateId,
          ),
          const SizedBox(height: AppDimensions.s16),
          Row(
            children: [
              Expanded(
                child: AdvisorOutlineAction(
                  label: t.advisorActionSendBack,
                  icon: Icons.undo_rounded,
                  color: colors.error,
                  onTap: onReject,
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: AdvisorSolidAction(
                  label: t.advisorActionApprove,
                  icon: Icons.check_rounded,
                  color: context.semanticColors.success.base,
                  onTap: onApprove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
