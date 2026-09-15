import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Compact personal header for the Customer Home surface.
///
/// Keeps the greeting and the (real) unread notification state in a single
/// row so the authenticated shell stays the only place that explains which
/// product the user is in.
class CustomerHomeHeader extends StatelessWidget {
  final String firstName;
  final bool isNewCustomer;
  final int unreadCount;
  final VoidCallback onNotifications;

  const CustomerHomeHeader({
    super.key,
    required this.firstName,
    required this.isNewCustomer,
    required this.unreadCount,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = firstName.trim();
    final welcome = isNewCustomer ? 'Welcome to Orient' : 'Welcome back';
    final hasUnread = unreadCount > 0;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (name.isNotEmpty)
                Text(
                  welcome,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              Text(
                name.isNotEmpty ? name : welcome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Tooltip(
          message: 'Notifications',
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: hasUnread
                ? 'Notifications, $unreadCount unread'
                : 'Notifications',
            child: InkWell(
              onTap: onNotifications,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: AppDimensions.touchTarget,
                height: AppDimensions.touchTarget,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: AppDimensions.iconMd,
                        color: colors.onSurface,
                      ),
                    ),
                    if (hasUnread)
                      Positioned(
                        top: 6,
                        right: 5,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 17),
                          height: 17,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.s4,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusPill,
                            ),
                            border: Border.all(
                              color: colors.surface,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onError,
                              fontSize: 10,
                              height: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
