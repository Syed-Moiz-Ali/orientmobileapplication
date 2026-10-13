import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// A pending approval card. Uses a narrow-safe composition (Expanded title +
/// money, and a wrapping status row) so it never overflows at 320 px / 1.3x.
class AdvisorApprovalRow extends StatelessWidget {
  final PendingApprovalEntity pa;
  final void Function(PendingApprovalEntity) onTap;
  const AdvisorApprovalRow({super.key, required this.pa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final money = AppFormatters.of(context).moneyAED(pa.amount);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s8),
      child: AppCard.standard(
        onTap: () => onTap(pa),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: colors.primary,
                  size: AppDimensions.iconMd,
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Text(
                    pa.estimateId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                if (pa.isEstimate) ...[
                  const SizedBox(width: AppDimensions.s8),
                  Text(
                    money,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              '${pa.customerName} · ${pa.vehicleId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.s8),
            Wrap(
              spacing: AppDimensions.s8,
              runSpacing: AppDimensions.s4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusPill.warning(pa.typeLabel),
                Text(
                  pa.timeAgo,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (!pa.isEstimate)
                  Text(
                    t.advisorActionReview,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
