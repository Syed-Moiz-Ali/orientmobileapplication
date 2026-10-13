import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
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

    final rtl = Directionality.of(context) == TextDirection.rtl;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: SharedCoreL10n.of(context).notificationsTooltip,
          icon: Icon(
            Icons.notifications_outlined,
            color: effectiveForeground,
            size: iconSize,
          ),
          onPressed: onPressed,
        ),
        if (showBadge)
          Positioned(
            // The badge follows the top-end corner in both directions.
            right: rtl ? null : 4,
            left: rtl ? 4 : null,
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
