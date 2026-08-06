import 'package:flutter/material.dart';
import 'package:shared_core/src/local/hive/hive_cleaner.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

Future<bool?> showLogoutDialog(
  BuildContext context, {
  VoidCallback? onLogout,
}) async {
  // FIX (audit P0): pending sync no longer blocks logout forever — the user
  // can force-logout (pending ops are cleared with the local data).
  if (HiveCleaner.hasPendingSync()) {
    final force = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.sync_problem_rounded,
              color: AppColors.warning,
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Sync Pending',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'You have pending sync operations that could not be sent.\n\n'
          'Wait and retry, or log out anyway — unsent changes will be cleared.',
          style: TextStyle(fontSize: 14, color: AppColors.text2, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
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
            child: const Text(
              'Logout Anyway',
              style: TextStyle(fontWeight: FontWeight.w700),
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
      title: const Row(
        children: [
          Icon(Icons.logout_rounded, color: AppColors.danger, size: 22),
          SizedBox(width: 10),
          Text(
            'Logout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: const Text(
        'Are you sure you want to logout?\nAll local data will be cleared.',
        style: TextStyle(fontSize: 14, color: AppColors.text2, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancel',
            style: TextStyle(
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
          child: const Text(
            'Yes, Logout',
            style: TextStyle(fontWeight: FontWeight.w700),
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
