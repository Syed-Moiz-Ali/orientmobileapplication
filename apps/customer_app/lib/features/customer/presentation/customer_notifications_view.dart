import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_notification_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notifications_search_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
///
/// Presentation only — grouping, tones, destinations, read-marker flow,
/// refresh, routes and keys are unchanged; the inbox is rebuilt on shared
/// atoms (AppScaffold, AppAppBar, cards, AppBanner, AppEmptyState/
/// AppErrorState, AppShimmerSkeleton).
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
    final t = context.cx;
    final state = ref.watch(customerDashboardProvider);
    final notifications = state.notifications;
    final unread = state.unreadCount;
    final firstLoadFailed =
        notifications.isEmpty && state.loadError.isNotEmpty && !state.isLoading;

    final groups = _grouped(context, notifications);

    // Ruling (a) + D3 (ui/fix-rulings): AppBar WITH search trigger — the find
    // action lives HERE (top-right, direction-aware AppBar actions, mirrored
    // in RTL); single path by construction. Visible ONLY when loaded > 5
    // (the ONE family rule shared with vehicles/bookings/lists; ≤5/empty
    // show none). Same data, substring filter, no-match + Clear, existing
    // patterns.
    return AppScaffold(
      appBar: AppAppBar(
        title: t.ntTitle,
        showBack: true,
        actions: [
          if (notifications.length > 5)
            AppIconButton(
              icon: Icons.search_rounded,
              tooltip: t.ntSearchTitle,
              onPressed: () {
                HapticFeedback.selectionClick();
                showCustomerNotificationsSearchSheet(
                  context,
                  notifications: notifications,
                  onSelect: _open,
                );
              },
            ),
        ],
      ),
      scrollable: false,
      maxContentWidth: 860,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isLoading && notifications.isEmpty)
            // Skeleton mirrors the rows: summary line + row cards.
            const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppDimensions.s12),
                AppShimmerSkeleton(width: 96, height: 16),
                SizedBox(height: AppDimensions.s12),
                AppShimmerSkeleton.card(height: 86),
                SizedBox(height: AppDimensions.s12),
                AppShimmerSkeleton.card(height: 86),
                SizedBox(height: AppDimensions.s12),
                AppShimmerSkeleton.card(height: 86),
                SizedBox(height: AppDimensions.s12),
                AppShimmerSkeleton.card(height: 86),
              ],
            )
          else if (firstLoadFailed)
            Expanded(
              child: AppErrorState(
                title: t.ntLoadTitle,
                message: t.ntLoadBody,
                retryLabel: t.ntRetry,
                onRetry: _refresh,
              ),
            )
          else if (notifications.isEmpty)
            Expanded(
              child: AppEmptyState(
                icon: Icons.notifications_none_rounded,
                title: t.ntCaughtUp,
                // Calm empty (U6): no action — nothing exists to create.
                message: t.ntCaughtUpBody,
              ),
            )
          else ...[
            const SizedBox(height: AppDimensions.s12),
            _SummaryRow(unread: unread, onMarkAllRead: _markAllRead),
            if (state.loadError.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s12),
              AppBanner(
                kind: AppBannerKind.warning,
                message: t.stRefreshFail,
                actionLabel: t.stRetry,
                onAction: _refresh,
              ),
            ],
            if (_markAllFailed) ...[
              const SizedBox(height: AppDimensions.s12),
              AppBanner(
                kind: AppBannerKind.error,
                message: t.ntMarkFail,
                actionLabel: t.ntRetry,
                onAction: _markAllRead,
              ),
            ],
            const SizedBox(height: AppDimensions.s12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: theme.colorScheme.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.s24,
                  ),
                  children: [
                    for (var g = 0; g < groups.length; g++) ...[
                      _GroupSection(
                        title: groups[g].title,
                        children: [
                          for (var i = 0;
                              i < groups[g].items.length;
                              i++)
                            _NotificationRow(
                              notification: groups[g].items[i],
                              onTap: () => _open(
                                groups[g].items[i],
                              ),
                            ),
                        ],
                      ),
                      if (g < groups.length - 1)
                        const SizedBox(height: AppDimensions.s20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Groups the inbox the way customers triage it: service progress first,
/// then approvals, invoices, and everything else. Group membership derives
/// from the frozen category mapping, so an unknown backend type lands in
/// General instead of a wrong group.
class _Group {
  final String title;
  final List<CustomerNotificationEntity> items;

  const _Group({required this.title, required this.items});
}

List<_Group> _grouped(
  BuildContext context,
  List<CustomerNotificationEntity> notifications,
) {
  final t = context.cx;
  final buckets = <String, List<CustomerNotificationEntity>>{};
  final order = <String>[];
  for (final n in notifications) {
    final k = _NotificationRow.groupOf(context, n.type);
    if (!buckets.containsKey(k)) {
      buckets[k] = [];
      order.add(k);
    }
    buckets[k]!.add(n);
  }
  // Stable group order: service, approvals, invoices, general.
  order.sort((a, b) {
    int r(String k) {
      if (k == t.ntGroupService) return 0;
      if (k == t.ntGroupApprovals) return 1;
      if (k == t.ntGroupInvoices) return 2;
      return 3;
    }

    return r(a).compareTo(r(b));
  });
  return [for (final k in order) _Group(title: k, items: buckets[k]!)];
}

class _GroupSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _GroupSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: SectionHeader(title: title),
        ),
        for (var index = 0; index < children.length; index++) ...[
          AppSurfaceCard(
            // Borderless in light (soft shadow), bordered in dark (C16).
            outlined: false,
            padding: EdgeInsets.zero,
            child: children[index],
          ),
          if (index < children.length - 1)
            const SizedBox(height: AppDimensions.s12),
        ],
      ],
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
    final t = context.cx;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            unread == 0 ? t.ntAllRead : t.ntUnread(unread),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: unread == 0 ? colors.onSurfaceVariant : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (unread > 0)
          TextButton(
            onPressed: () => onMarkAllRead(),
            child: Text(t.ntMarkAll),
          ),
      ],
    );
  }
}

/// One notification. Dense by construction: no decorative tile, no footer —
/// the surrounding card carries the shape.
///
/// Row hierarchy (brief U0 binding): title first (the thing the user
/// recognizes), category/time meta last; unread carries dot + icon + heavier
/// title (never color alone); chevron only when the category genuinely opens
/// something (direction-mirrored in RTL).
class _NotificationRow extends StatelessWidget {
  final CustomerNotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationRow({
    required this.notification,
    required this.onTap,
  });

  /// Group display name for one category (same mapping as the sections).
  static String groupOf(BuildContext context, NotifType type) {
    final t = context.cx;
    return switch (type) {
      NotifType.bookingReceived ||
      NotifType.bookingAssigned ||
      NotifType.completionApproved ||
      NotifType.breakdownAssigned =>
        t.ntGroupService,
      NotifType.approvalNeeded ||
      NotifType.estimateApproved ||
      NotifType.estimateRejected =>
        t.ntGroupApprovals,
      NotifType.invoiceReady || NotifType.paymentReceived =>
        t.ntGroupInvoices,
      NotifType.general => t.ntGroupGeneral,
    };
  }

  /// Row category name. Matches the frozen type vocabulary exactly in
  /// English (pinned by widget tests); localized elsewhere.
  static String labelOf(BuildContext context, NotifType type) {
    final t = context.cx;
    return switch (type) {
      NotifType.bookingReceived || NotifType.bookingAssigned => t.ntTypeBooking,
      NotifType.approvalNeeded => t.ntTypeApproval,
      NotifType.completionApproved => t.ntTypeService,
      NotifType.invoiceReady => t.ntTypeInvoice,
      NotifType.paymentReceived => t.ntTypePayment,
      NotifType.estimateApproved || NotifType.estimateRejected =>
        t.ntTypeApproval,
      NotifType.breakdownAssigned => t.ntTypeBreakdown,
      NotifType.general => t.ntTypeUpdate,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
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

    return Semantics(
      button: destination != null,
      label: [
        unread ? t.ntUnreadWord : t.ntReadWord,
        labelOf(context, notification.type),
        notification.title,
        notification.body,
        notification.time,
      ].where((part) => part.trim().isNotEmpty).join('. '),
      excludeSemantics: true,
      child: Material(
        color: unread
            ? Color.alphaBlend(tone.withValues(alpha: 0.05), colors.surface)
            : colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
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
                          labelOf(context, notification.type),
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
                    padding: const EdgeInsetsDirectional.only(
                      top: AppDimensions.s14,
                      start: AppDimensions.s4,
                    ),
                    child: DirectionalIcon(
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
    );
  }
}
