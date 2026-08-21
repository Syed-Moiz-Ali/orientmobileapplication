import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/notification_bell.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool showBack;

  const AppTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      color: colorScheme.surface,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s18),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Back',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerLow,
                side: BorderSide(color: colorScheme.outline),
                minimumSize: const Size.square(AppDimensions.touchTarget),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          if (showBack) const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class CustomerTopBar extends StatelessWidget {
  final String avatarInitials;
  final String name;
  final int notifCount;
  final VoidCallback onNotif;

  const CustomerTopBar({
    super.key,
    required this.avatarInitials,
    required this.name,
    required this.notifCount,
    required this.onNotif,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      color: colorScheme.surface,
      height: AppDimensions.s64,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s18),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Center(
              child: Text(
                avatarInitials,
                style: TextStyle(
                  fontSize: AppDimensions.s14,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          NotificationBell(
            showBadge: notifCount > 0,
            badgeCount: notifCount,
            foregroundColor: colorScheme.onSurfaceVariant,
            onPressed: onNotif,
          ),
        ],
      ),
    );
  }
}
