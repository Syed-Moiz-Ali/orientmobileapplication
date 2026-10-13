import 'package:flutter/material.dart';
import 'package:shared_core/src/local/hive/hive_cleaner.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/widgets/app_confirmation_dialog.dart';

Future<bool?> showLogoutDialog(
  BuildContext context, {
  VoidCallback? onLogout,
}) async {
  final t = SharedCoreL10n.of(context);
  if (HiveCleaner.hasPendingSync()) {
    final force = await showAppConfirmationDialog(
      context,
      title: t.logoutUnsyncedTitle,
      message: t.logoutUnsyncedMessage,
      confirmLabel: t.logoutUnsyncedConfirm,
      icon: Icons.sync_problem_rounded,
      destructive: true,
    );
    if (!force) return false;
  } else {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: t.logoutDialogTitle,
      message: t.logoutDialogMessage,
      confirmLabel: t.logoutDialogConfirm,
      icon: Icons.logout_rounded,
      destructive: true,
    );
    if (!confirmed) return false;
  }

  await HiveCleaner.clearAll();
  onLogout?.call();
  return true;
}
