import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'advisor_sheet.dart';
import 'advisor_handle.dart';
import 'advisor_divider.dart';
import 'advisor_contact_option.dart';
import 'advisor_solid_action.dart';

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
  Widget build(BuildContext context) => AdvisorSheet(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AdvisorHandle(),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  r.customerName.substring(0, 1),
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.customerName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    '${r.vehicleId} · ${r.task}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.text2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const AdvisorDivider(),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AdvisorContactOption(
              icon: Icons.phone_rounded,
              label: 'Call',
              color: AppColors.accent,
              onTap: onCall,
            ),
            AdvisorContactOption(
              icon: Icons.chat_rounded,
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              onTap: onWhatsApp,
            ),
            AdvisorContactOption(
              icon: Icons.sms_outlined,
              label: 'SMS',
              color: AppColors.info,
              onTap: onSms,
            ),
          ],
        ),
        const SizedBox(height: 18),
        AdvisorSolidAction(
          label: 'Mark Reminder as Done',
          icon: Icons.check_circle_outline_rounded,
          gradient: const [AppColors.success, Color(0xFF2DD4BF)],
          onTap: onDone,
        ),
        const SizedBox(height: 6),
      ],
    ),
  );
}
