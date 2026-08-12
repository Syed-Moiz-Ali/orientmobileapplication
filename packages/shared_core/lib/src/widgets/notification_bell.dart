import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';

class NotificationBell extends StatelessWidget {
  final bool showBadge;
  final int? badgeCount;
  final double iconSize;
  final VoidCallback? onPressed;

  const NotificationBell({
    super.key,
    this.showBadge = false,
    this.badgeCount,
    this.iconSize = 27,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final badgeStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.white, size: iconSize),
          onPressed: onPressed,
        ),
        if (showBadge)
          Positioned(
            right: 10,
            top: 10,
            child: badgeCount != null
                ? Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${badgeCount!}',
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
