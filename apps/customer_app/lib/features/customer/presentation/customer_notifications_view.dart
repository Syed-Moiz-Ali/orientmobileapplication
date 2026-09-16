import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_notification_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notice_panel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_status_notices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

/// The customer's notification inbox.
///
/// A contextual page (opened from the Home bell), not a workspace destination.
/// It answers one question — what changed, and what needs my attention — using
/// only what the workshop actually stores: a title, a message, a category and
/// a display timestamp.
///
/// Read state is the workshop's: tapping a row persists a read marker through
/// the backend, so the Home badge and this list agree now and after a restart.
/// A notification only opens a destination its own category genuinely leads to;
/// everything else stays a read-only row rather than guessing.
class CustomerNotificationsView extends ConsumerStatefulWidget {
  const CustomerNotificationsView({super.key});

  @override
  ConsumerState<CustomerNotificationsView> createState() =>
      _CustomerNotificationsViewState();
}

class _CustomerNotificationsViewState
    extends ConsumerState<CustomerNotificationsView> {
  /// True when the bulk read marker was refused, so the badge rolled back and
  /// the customer should know why.
  bool _markAllFailed = false;

  Future<void> _refresh() =>
      ref.read(customerDashboardProvider.notifier).refresh();

  Future<void> _markAllRead() async {
    final saved = await ref
        .read(customerDashboardProvider.notifier)
        .markAllRead();
    if (!mounted) return;
    setState(() => _markAllFailed = !saved);
  }

  void _open(CustomerNotificationEntity notification) {
    // The marker is persisted in the background; navigation is never blocked
    // by a read marker.
    ref.read(customerDashboardProvider.notifier).markRead(notification.id);
    final destination = CustomerNotificationPresentation.destination(
      notification.type,
    );
    if (destination != null) context.push(destination);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(customerDashboardProvider);
    final notifications = state.notifications;
    final unread = state.unreadCount;
    final firstLoadFailed =
        notifications.isEmpty && state.loadError.isNotEmpty && !state.isLoading;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'Notifications'),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                scrollable: false,
                maxContentWidth: 860,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.isLoading && notifications.isEmpty)
                      const _NotificationsSkeleton()
                    else if (firstLoadFailed)
                      Expanded(child: _LoadFailure(onRetry: _refresh))
                    else if (notifications.isEmpty)
                      const Expanded(child: _AllCaughtUp())
                    else ...[
                      const SizedBox(height: AppDimensions.s12),
                      _SummaryRow(unread: unread, onMarkAllRead: _markAllRead),
                      if (state.loadError.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.s12),
                        CustomerRefreshNotice(onRetry: _refresh),
                      ],
                      if (_markAllFailed) ...[
                        const SizedBox(height: AppDimensions.s12),
                        CustomerNoticePanel(
                          message:
                              "We couldn't mark your notifications as read.",
                          actionLabel: 'Retry',
                          onAction: _markAllRead,
                        ),
                      ],
                      const SizedBox(height: AppDimensions.s12),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refresh,
                          color: theme.colorScheme.primary,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.s24,
                            ),
                            itemCount: notifications.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return _NotificationRow(
                                notification: notification,
                                first: index == 0,
                                last: index == notifications.length - 1,
                                onTap: () => _open(notification),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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

/// A compact line that gives the page its structure: how much is new, and the
/// one bulk action, which appears only when there is something to mark.
class _SummaryRow extends StatelessWidget {
  final int unread;
  final Future<void> Function() onMarkAllRead;

  const _SummaryRow({required this.unread, required this.onMarkAllRead});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            unread == 0
                ? 'All read'
                : unread == 1
                ? '1 unread'
                : '$unread unread',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: unread == 0 ? colors.onSurfaceVariant : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (unread > 0)
          TextButton(
            onPressed: () => onMarkAllRead(),
            child: const Text('Mark all read'),
          ),
      ],
    );
  }
}

/// One notification. Dense by construction: no decorative tile, no footer, no
/// per-row card padding — the surrounding grouped surface carries the shape.
class _NotificationRow extends StatelessWidget {
  final CustomerNotificationEntity notification;
  final bool first;
  final bool last;
  final VoidCallback onTap;

  const _NotificationRow({
    required this.notification,
    required this.first,
    required this.last,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final unread = !notification.isRead;
    final tone = CustomerNotificationPresentation.toneColor(
      colors,
      notification.type,
    );
    final destination = CustomerNotificationPresentation.destination(
      notification.type,
    );

    final radius = BorderRadius.vertical(
      top: Radius.circular(first ? AppDimensions.radiusCard : 0),
      bottom: Radius.circular(last ? AppDimensions.radiusCard : 0),
    );

    return Semantics(
      button: destination != null,
      label: [
        unread ? 'Unread' : 'Read',
        CustomerNotificationPresentation.label(notification.type),
        notification.title,
        notification.body,
        notification.time,
      ].where((part) => part.trim().isNotEmpty).join('. '),
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: unread
              ? Color.alphaBlend(tone.withValues(alpha: 0.05), colors.surface)
              : colors.surface,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.s16,
                AppDimensions.s12,
                AppDimensions.s10,
                AppDimensions.s12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A fixed slot keeps read and unread rows aligned, and the dot
                  // is only one of the unread signals (the title is heavier too).
                  SizedBox(
                    width: AppDimensions.s12,
                    child: unread
                        ? Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: tone,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppDimensions.s6),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      CustomerNotificationPresentation.icon(notification.type),
                      size: AppDimensions.iconMd,
                      color: tone,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          notification.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: unread
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        if (notification.body.trim().isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.s4),
                          Text(
                            notification.body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppDimensions.s6),
                        Text(
                          [
                            CustomerNotificationPresentation.label(
                              notification.type,
                            ),
                            notification.time,
                          ].where((part) => part.trim().isNotEmpty).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (destination != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppDimensions.s14,
                        left: AppDimensions.s4,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: AppDimensions.iconMd,
                        color: colors.outline,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Zero notifications, stated truthfully: these are the domains the workshop
/// really sends.
class _AllCaughtUp extends StatelessWidget {
  const _AllCaughtUp();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: AppDimensions.iconXl,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.s12),
            Text(
              "You're all caught up",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s6),
            Text(
              'Updates about your bookings, estimates and service progress '
              'will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _LoadFailure({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: AppDimensions.iconXl,
              color: colors.error,
            ),
            const SizedBox(height: AppDimensions.s12),
            Text(
              "We couldn't load your notifications.",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s6),
            Text(
              'Please try again in a moment.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            FilledButton(
              onPressed: () => onRetry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomerSkeleton(
      builder: (context, block) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.s12),
          CustomerSkeletonBox(width: 96, height: 16, color: block),
          const SizedBox(height: AppDimensions.s12),
          for (var index = 0; index < 6; index++) ...[
            if (index > 0) const SizedBox(height: AppDimensions.s12),
            CustomerSkeletonBox(height: 74, color: block),
          ],
        ],
      ),
    );
  }
}
