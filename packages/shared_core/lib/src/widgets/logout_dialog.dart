import 'package:flutter/material.dart';
import 'package:shared_core/src/local/hive/hive_cleaner.dart';
import 'package:shared_core/src/widgets/app_confirmation_dialog.dart';

Future<bool?> showLogoutDialog(
  BuildContext context, {
  VoidCallback? onLogout,
}) async {
  if (HiveCleaner.hasPendingSync()) {
    final force = await showAppConfirmationDialog(
      context,
      title: 'Unsynced changes',
      message:
          'Some local changes have not reached the workshop yet. Signing out now will clear those pending changes.',
      confirmLabel: 'Sign out anyway',
      icon: Icons.sync_problem_rounded,
      destructive: true,
    );
    if (!force) return false;
  } else {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Sign out?',
      message: 'You will need to authenticate again to access this workspace.',
      confirmLabel: 'Sign out',
      icon: Icons.logout_rounded,
      destructive: true,
    );
    if (!confirmed) return false;
  }

  await HiveCleaner.clearAll();
  onLogout?.call();
  return true;
}
