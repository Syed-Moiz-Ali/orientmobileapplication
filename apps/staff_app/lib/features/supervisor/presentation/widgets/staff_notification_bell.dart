import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class StaffNotificationBell extends ConsumerStatefulWidget {
  const StaffNotificationBell({super.key});

  @override
  ConsumerState<StaffNotificationBell> createState() => _StaffNotificationBellState();
}

class _StaffNotificationBellState extends ConsumerState<StaffNotificationBell> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final unread = notifier.unreadNotifications;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            HapticFeedback.selectionClick();
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
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Icon(Icons.notifications_none_rounded, color: colorScheme.onSurface, size: 20),
          ),
        ),
        if (unread > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.error,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.surface, width: 1.5),
              ),
              child: Text(
                '$unread',
                style: TextStyle(color: colorScheme.onError, fontSize: 9, fontWeight: FontWeight.w900),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final notifications = notifier.notifications;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 18,
                    decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Staff Feed',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      HapticFeedback.selectionClick();
                      for (final n in notifications.where((n) => !n.isRead)) {
                        await notifier.markNotificationRead(n.id);
                      }
                    },
                    child: Text('Mark all read', style: TextStyle(color: colorScheme.primary)),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: EmptyState(
                        icon: Icons.notifications_none_rounded,
                        message: 'No notifications at this time',
                      ),
                    )
                  : ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      itemBuilder: (_, i) {
                        final n = notifications[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              notifier.markNotificationRead(n.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: n.isRead ? colorScheme.surface : colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: n.isRead
                                      ? colorScheme.outlineVariant
                                      : colorScheme.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    n.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                                    size: 18,
                                    color: n.isRead ? colorScheme.onSurfaceVariant : colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          n.title,
                                          style: textTheme.titleSmall?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                                          ),
                                        ),
                                        if (n.body.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            n.body,
                                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Text(
                                          n.time,
                                          style: textTheme.labelSmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 10,
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
