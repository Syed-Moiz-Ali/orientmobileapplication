import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Floor notifications bell + sheet, presented through the shared responsive
/// modal. Polling cadence and read-marking contracts are unchanged.
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
    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
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
    final t = StaffLocalizations.of(context)!;
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final unread = notifier.unreadNotifications;

    return Semantics(
      button: true,
      label: t.svNotificationsTitle,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AppButton.quietIcon(
            icon: Icons.notifications_none_rounded,
            tooltip: t.svNotificationsTitle,
            onPressed: () async {
              HapticFeedback.selectionClick();
              await notifier.loadNotifications();
              if (!context.mounted) return;
              showAppModalSheet<void>(
                context: context,
                title: t.svNotificationsTitle,
                builder: (_) => const _NotificationsContent(),
              );
            },
          ),
          if (unread > 0)
            PositionedDirectional(
              top: 2,
              end: 2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18),
                height: 18,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.error,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  border: Border.all(color: context.colors.surface, width: 1.5),
                ),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: TextStyle(
                    color: context.colors.onError,
                    fontSize: 10,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationsContent extends ConsumerWidget {
  const _NotificationsContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final notifications = notifier.notifications;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (notifications.any((n) => !n.isRead))
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () async {
                HapticFeedback.selectionClick();
                for (final n in notifications.where((n) => !n.isRead)) {
                  await notifier.markNotificationRead(n.id);
                }
              },
              child: Text(t.svNotificationsMarkAll),
            ),
          ),
        if (notifications.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s24),
            child: EmptyState(
              icon: Icons.notifications_none_rounded,
              title: t.svNotificationsEmpty,
              message: t.svNotificationsEmptyMessage,
            ),
          )
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.s8),
              itemBuilder: (_, i) {
                final n = notifications[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.markNotificationRead(n.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.s12),
                    decoration: BoxDecoration(
                      color: n.isRead
                          ? context.semanticColors.surfaceRaised
                          : context.semanticColors.info.subtle,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCard,
                      ),
                      border: Border.all(
                        color: n.isRead
                            ? context.semanticColors.borderDefault
                            : context.semanticColors.info.border,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          n.isRead
                              ? Icons.notifications_none_rounded
                              : Icons.notifications_active_rounded,
                          size: AppDimensions.iconSm,
                          color: n.isRead
                              ? context.colors.onSurfaceVariant
                              : context.colors.primary,
                        ),
                        const SizedBox(width: AppDimensions.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: context.colors.onSurface,
                                  fontWeight: n.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                ),
                              ),
                              if (n.body.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  n.body,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              if (n.time.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  n.time,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: AppDimensions.s8),
      ],
    );
  }
}
