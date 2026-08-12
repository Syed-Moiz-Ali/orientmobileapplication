import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: AppColors.surface,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s18),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bg,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: AppDimensions.iconSm,
                  color: AppColors.text3,
                ),
              ),
            ),
          if (showBack) const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: AppColors.surface,
      height: AppDimensions.s64,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s18),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Center(
              child: Text(
                avatarInitials,
                style: const TextStyle(
                  fontSize: AppDimensions.s14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
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
                    color: AppColors.text3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onNotif,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: AppDimensions.iconMd,
                    color: AppColors.text2,
                  ),
                ),
                if (notifCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: AppDimensions.s16,
                      height: AppDimensions.s16,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$notifCount',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
