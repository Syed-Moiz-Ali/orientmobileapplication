import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';

class NotificationBell extends StatelessWidget {
  final bool showBadge;
  final int? badgeCount;
  final double iconSize;
  final VoidCallback? onPressed;
  final Color? foregroundColor;

  const NotificationBell({
    super.key,
    this.showBadge = false,
    this.badgeCount,
    this.iconSize = 27,
    this.onPressed,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveForeground = foregroundColor ?? theme.colorScheme.onSurface;
    final badgeStyle = theme.textTheme.labelSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w800,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Notifications',
          icon: Icon(
            Icons.notifications_outlined,
            color: effectiveForeground,
            size: iconSize,
          ),
          onPressed: onPressed,
        ),
        if (showBadge)
          Positioned(
            right: 4,
            top: 4,
            child: badgeCount != null
                ? Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        badgeCount! > 99 ? '99+' : '${badgeCount!}',
                        style: badgeStyle,
                      ),
                    ),
                  )
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.warningBorder,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.navy, width: 1.5),
                    ),
                  ),
          ),
      ],
    );
  }
}
