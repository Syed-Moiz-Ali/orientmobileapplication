import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

class CustomerNotificationsView extends ConsumerWidget {
  const CustomerNotificationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final unread = state.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bg,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                        color: AppColors.text3,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notifications',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          )),
                        if (unread > 0)
                          Text('$unread unread',
                            style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  if (unread > 0)
                    GestureDetector(
                      onTap: () => notifier.markAllRead(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.s12,
                          vertical: AppDimensions.s6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                        ),
                        child: const Text('Mark all read',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          )),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: state.notifications.isEmpty
                  ? const Center(
                      child: Text('No notifications', style: TextStyle(color: AppColors.text3)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.s8),
                      itemCount: state.notifications.length,
                      itemBuilder: (_, i) => _NotifCard(
                        notif: state.notifications[i],
                        onTap: () => notifier.markRead(state.notifications[i].id),
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
      case NotifType.carReady:         return (AppColors.success,  AppColors.successBg,  Icons.check_circle_rounded);
      case NotifType.bookingConfirmed: return (AppColors.primary,   AppColors.primaryBg,   Icons.calendar_month_rounded);
      case NotifType.invoiceReady:     return (AppColors.warning,  AppColors.warningBg,  Icons.receipt_long_rounded);
      case NotifType.approvalNeeded:   return (AppColors.warning,  AppColors.warningBg,  Icons.warning_rounded);
      case NotifType.workInProgress:   return (AppColors.primary,   AppColors.primaryBg,   Icons.build_rounded);
      case NotifType.reminder:         return (AppColors.info,     AppColors.infoBg,     Icons.notifications_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon) = _style;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.fromLTRB(
          AppDimensions.s16, 0, AppDimensions.s16, AppDimensions.s8,
        ),
        padding: const EdgeInsets.all(AppDimensions.s14),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.surface : color.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(AppDimensions.r14),
          border: Border.all(
            color: notif.isRead ? AppColors.border : color.withValues(alpha: .3),
            width: notif.isRead ? 0.8 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                  const SizedBox(height: AppDimensions.s4),
                  Text(notif.body,
                    style: const TextStyle(fontSize: 12, color: AppColors.text3, height: 1.45)),
                  const SizedBox(height: AppDimensions.s6),
                  Text(notif.time,
                    style: const TextStyle(fontSize: 11, color: AppColors.text4)),
                ],
              ),
            ),
            if (!notif.isRead) ...[
              const SizedBox(width: AppDimensions.s8),
              Container(width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}
