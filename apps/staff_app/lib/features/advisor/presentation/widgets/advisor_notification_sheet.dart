import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'advisor_sheet.dart';
import 'advisor_handle.dart';
import 'advisor_notification_data.dart';
import 'advisor_notification_row.dart';

class AdvisorNotificationSheet extends ConsumerWidget {
  const AdvisorNotificationSheet({super.key});

  List<AdvisorNotificationData> _loadNotifications() {
    try {
      final box = Hive.box<dynamic>('inspections');
      final items = box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .where((m) => m['type'] == 'notification')
          .map(
            (m) => AdvisorNotificationData(
              m['title'] as String? ?? '',
              m['message'] as String? ?? '',
              Icons.notifications_outlined,
              AppColors.accent,
              m['timeAgo'] as String? ?? '',
            ),
          )
          .toList();
      if (items.isNotEmpty) return items;
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localItems = _loadNotifications();
    final remoteAsync = ref.watch(advisorNotificationsProvider);
    final remoteItems =
        (remoteAsync.value ?? const <StaffNotificationResponse>[])
            .map(
              (n) => AdvisorNotificationData(
                n.title,
                n.body,
                n.isRead
                    ? Icons.notifications_outlined
                    : Icons.notifications_active_rounded,
                n.isRead ? AppColors.text3 : AppColors.accent,
                n.time,
              ),
            )
            .toList();
    final items = [...remoteItems, ...localItems];
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
              if (items.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    try {
                      final box = Hive.box<dynamic>('inspections');
                      final keys = box.keys.where((k) {
                        final v = box.get(k);
                        return v is Map && v['type'] == 'notification';
                      }).toList();
                      for (final k in keys) {
                        box.delete(k);
                      }
                    } catch (_) {}
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.r8),
                      ),
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
          if (items.isNotEmpty)
            ...items.map((n) => AdvisorNotificationRow(n: n)),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(AppDimensions.r16),
                    ),
                    child: const Icon(
                      Icons.notifications_off_outlined,
                      color: AppColors.text3,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: AppColors.text3,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Approval updates and reminders will appear here.',
                    style: TextStyle(color: AppColors.text4, fontSize: 11),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
