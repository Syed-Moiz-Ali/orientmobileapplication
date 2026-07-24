import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'advisor_sheet.dart';
import 'advisor_handle.dart';
import 'advisor_notification_data.dart';
import 'advisor_notification_row.dart';

class AdvisorNotificationSheet extends StatelessWidget {
  const AdvisorNotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      AdvisorNotificationData(
        'Estimate approved', 'EST-2024-089 approved by customer',
        Icons.check_circle_outline_rounded, AppColors.success, '2m ago',
      ),
      AdvisorNotificationData(
        'Parts arrived', 'Brake pads for JC-2024-087 are ready',
        Icons.inventory_2_outlined, AppColors.accent, '18m ago',
      ),
      AdvisorNotificationData(
        'Awaiting approval', 'EST-2024-088 pending customer sign-off',
        Icons.pending_outlined, AppColors.warning, '1h ago',
      ),
    ];
    return AdvisorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdvisorHandle(),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)),
                  ),
                  child: Text(
                    'Clear all',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((n) => AdvisorNotificationRow(n: n)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

