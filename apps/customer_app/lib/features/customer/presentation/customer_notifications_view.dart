import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

class CustomerNotificationsView extends ConsumerWidget {
  const CustomerNotificationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final unread = state.unreadCount;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: 'Notifications',
              trailing: unread > 0
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusPill(
                          label: '$unread unread',
                          bg: AppColors.primaryBg,
                          fg: AppColors.primary,
                        ),
                        const SizedBox(width: AppDimensions.s8),
                        TextButton(
                          onPressed: notifier.markAllRead,
                          child: const Text('Clear'),
                        ),
                      ],
                    )
                  : null,
            ),
            const Divider(height: 1),
            Expanded(
              child: state.notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.text3,
                        ),
                      ),
                    )
                  : AppResponsivePage(
                      child: AppAdaptiveGrid(
                        minChildWidth: 360,
                        childAspectRatio: 3.7,
                        children: [
                          for (final notification in state.notifications)
                            _NotifCard(
                              notif: notification,
                              onTap: () => notifier.markRead(notification.id),
                            ),
                        ],
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

  (Color, Color, IconData) get _style {
    switch (notif.type) {
      case NotifType.carReady:
        return (
          AppColors.success,
          AppColors.successBg,
          Icons.check_circle_rounded,
        );
      case NotifType.bookingConfirmed:
        return (
          AppColors.primary,
          AppColors.primaryBg,
          Icons.calendar_month_rounded,
        );
      case NotifType.invoiceReady:
        return (
          AppColors.warning,
          AppColors.warningBg,
          Icons.receipt_long_rounded,
        );
      case NotifType.approvalNeeded:
        return (AppColors.warning, AppColors.warningBg, Icons.warning_rounded);
      case NotifType.workInProgress:
        return (AppColors.primary, AppColors.primaryBg, Icons.build_rounded);
      case NotifType.reminder:
        return (AppColors.info, AppColors.infoBg, Icons.notifications_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (color, bg, icon) = _style;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s14),
      borderColor: notif.isRead
          ? AppColors.border
          : color.withValues(alpha: 0.3),
      color: notif.isRead ? AppColors.surface : color.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    notif.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: notif.isRead
                          ? FontWeight.w700
                          : FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s4),
                  Text(
                    notif.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.text3,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s6),
                  Text(
                    notif.time,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.text4,
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
