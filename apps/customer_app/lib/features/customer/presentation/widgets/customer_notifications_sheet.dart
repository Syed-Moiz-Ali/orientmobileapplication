import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

class CustomerNotificationsSheet extends ConsumerWidget {
  const CustomerNotificationsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.r24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.s12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s24,
                vertical: AppDimensions.s16,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (state.unreadCount > 0)
                        Text(
                          '${state.unreadCount} unread',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  if (state.unreadCount > 0)
                    TextButton(
                      onPressed: () => notifier.markAllRead(),
                      child: Text(
                        'Mark all read',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.08),
            ),
            Expanded(
              child: state.notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.s24,
                        vertical: AppDimensions.s12,
                      ),
                      itemCount: state.notifications.length,
                      itemBuilder: (_, i) => _NotifCard(
                        notif: state.notifications[i],
                        onTap: () =>
                            notifier.markRead(state.notifications[i].id),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final CustomerNotificationEntity notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  (Color, IconData) _style(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (notif.type) {
      case NotifType.carReady:
        return (colorScheme.tertiary, Icons.check_circle_rounded);
      case NotifType.bookingConfirmed:
        return (colorScheme.primary, Icons.calendar_month_rounded);
      case NotifType.invoiceReady:
      case NotifType.approvalNeeded:
        return (colorScheme.secondary, Icons.receipt_long_rounded);
      case NotifType.workInProgress:
        return (colorScheme.primary, Icons.build_rounded);
      case NotifType.reminder:
        return (colorScheme.primary, Icons.notifications_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final (color, icon) = _style(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppDimensions.s12),
        padding: const EdgeInsets.all(AppDimensions.s16),
        decoration: BoxDecoration(
          color: notif.isRead
              ? colorScheme.surface
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.r16),
          border: Border.all(
            color: notif.isRead
                ? colorScheme.outline.withValues(alpha: 0.08)
                : color.withValues(alpha: 0.2),
            width: notif.isRead ? 1.0 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: notif.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s4),
                  Text(
                    notif.body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s6),
                  Text(
                    notif.time,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!notif.isRead) ...[
              const SizedBox(width: AppDimensions.s8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
