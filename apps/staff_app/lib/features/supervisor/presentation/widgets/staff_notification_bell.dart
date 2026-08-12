import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

/// Phase 6 — in-app notification feed for staff (supervisor/advisor/tech).
class StaffNotificationBell extends ConsumerStatefulWidget {
  const StaffNotificationBell({super.key});

  @override
  ConsumerState<StaffNotificationBell> createState() =>
      _StaffNotificationBellState();
}

class _StaffNotificationBellState extends ConsumerState<StaffNotificationBell> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    // FE-FIX (pre-deployment): poll for new notifications so the unread badge
    // and the queue stay live without manual refreshes. The timer only ticks
    // while the bell is actually visible (TickerMode is disabled for hidden
    // IndexedStack tabs).
    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!TickerMode.of(context)) return;
      ref.read(supervisorDashboardProvider.notifier).loadNotifications();
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final unread = notifier.unreadNotifications;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () async {
            await notifier.loadNotifications();
            if (!context.mounted) return;
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const _StaffNotificationsSheet(),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        if (unread > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StaffNotificationsSheet extends ConsumerWidget {
  const _StaffNotificationsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final notifications = notifier.notifications;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.r28),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Notifications',
                    style: AppTextStyles.title(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      for (final n in notifications.where((n) => !n.isRead)) {
                        await notifier.markNotificationRead(n.id);
                      }
                    },
                    child: const Text('Mark all read'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: EmptyState(
                        icon: Icons.notifications_none_rounded,
                        message: 'No notifications yet',
                      ),
                    )
                  : ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.all(12),
                      itemCount: notifications.length,
                      itemBuilder: (_, i) {
                        final n = notifications[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => notifier.markNotificationRead(n.id),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: n.isRead
                                    ? AppColors.surfaceAlt
                                    : AppColors.primaryBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    n.isRead
                                        ? Icons.notifications_none_rounded
                                        : Icons.notifications_active_rounded,
                                    size: 18,
                                    color: n.isRead
                                        ? AppColors.text4
                                        : AppColors.accent,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          n.title,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: n.isRead
                                                ? FontWeight.w600
                                                : FontWeight.w800,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                        if (n.body.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            n.body,
                                            style: const TextStyle(
                                              color: AppColors.text3,
                                              fontSize: 12.5,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Text(
                                          n.time,
                                          style: const TextStyle(
                                            color: AppColors.text4,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
