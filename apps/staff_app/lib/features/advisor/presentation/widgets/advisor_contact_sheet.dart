import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'advisor_sheet.dart';
import 'advisor_contact_option.dart';
import 'advisor_solid_action.dart';

/// Reach-the-customer sheet: call / WhatsApp / SMS plus mark-reminder-done.
class AdvisorContactSheet extends StatelessWidget {
  final FollowupReminderEntity r;
  final VoidCallback onCall, onWhatsApp, onSms, onDone;
  const AdvisorContactSheet({
    super.key,
    required this.r,
    required this.onCall,
    required this.onWhatsApp,
    required this.onSms,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return AdvisorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Text(
                  r.customerName.isNotEmpty ? r.customerName[0] : 'C',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.customerName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      '${r.vehicleId} · ${r.task}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s20),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.s18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AdvisorContactOption(
                icon: Icons.phone_rounded,
                label: t.advisorContactCall,
                color: colors.primary,
                onTap: onCall,
              ),
              AdvisorContactOption(
                icon: Icons.chat_rounded,
                label: t.advisorContactWhatsApp,
                color: context.semanticColors.success.base,
                onTap: onWhatsApp,
              ),
              AdvisorContactOption(
                icon: Icons.sms_outlined,
                label: t.advisorContactSms,
                color: context.semanticColors.info.base,
                onTap: onSms,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s18),
          AdvisorSolidAction(
            label: t.advisorActionMarkReminderDone,
            icon: Icons.check_circle_outline_rounded,
            color: context.semanticColors.success.base,
            onTap: onDone,
          ),
        ],
      ),
    );
  }
}
