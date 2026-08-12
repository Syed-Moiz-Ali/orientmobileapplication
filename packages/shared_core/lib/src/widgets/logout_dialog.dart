import 'package:flutter/material.dart';
import 'package:shared_core/src/local/hive/hive_cleaner.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

Future<bool?> showLogoutDialog(
  BuildContext context, {
  VoidCallback? onLogout,
}) async {
  final textTheme = Theme.of(context).textTheme;

  if (HiveCleaner.hasPendingSync()) {
    final force = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.sync_problem_rounded,
              color: AppColors.warning,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Sync Pending',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'You have pending sync operations that could not be sent.\n\n'
          'Wait and retry, or log out anyway - unsent changes will be cleared.',
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.text2,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text3,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Logout Anyway',
              style: textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (force != true) return false;
    await HiveCleaner.clearAll();
    onLogout?.call();
    return true;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.r16),
      ),
      title: Row(
        children: [
          const Icon(Icons.logout_rounded, color: AppColors.danger, size: 22),
          const SizedBox(width: 10),
          Text(
            'Logout',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to logout?\nAll local data will be cleared.',
        style: textTheme.bodyLarge?.copyWith(
          color: AppColors.text2,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            'Cancel',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text3,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Yes, Logout',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await HiveCleaner.clearAll();
    onLogout?.call();
    return true;
  }
  return false;
}
