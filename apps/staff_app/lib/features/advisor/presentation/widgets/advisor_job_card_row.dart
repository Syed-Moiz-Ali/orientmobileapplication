import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_status.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// A job card rendered with the shared record-row grammar (spec §7):
/// identifier chip, customer title, vehicle subtitle, time + status metadata.
/// The status pill lives in the metadata row (which wraps) rather than the
/// trailing slot so the row never overflows at 320 px / 1.3x.
class AdvisorJobCardRow extends StatelessWidget {
  final JobCardEntity jc;
  final void Function(JobCardEntity) onTap;
  const AdvisorJobCardRow({super.key, required this.jc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s12),
      child: AppRecordRow(
        identifier: jc.id,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: colors.primary.withValues(alpha: 0.12),
          child: Text(
            jc.customerName.isNotEmpty ? jc.customerName[0] : 'C',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: jc.customerName,
        subtitle: jc.vehicleInfo,
        metadata: Wrap(
          spacing: AppDimensions.s8,
          runSpacing: AppDimensions.s4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: AppDimensions.iconXs,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.s6),
                Text(
                  jc.time,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            advisorStatusPill(t, jc.status),
          ],
        ),
        onTap: () => onTap(jc),
      ),
    );
  }
}
