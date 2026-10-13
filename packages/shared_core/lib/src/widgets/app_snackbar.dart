import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

/// Outcome tone for an [showAppSnackBar] message.
enum AppSnackBarTone { neutral, success, danger }

/// Shows a single-line outcome toast with an optional action (Undo / Retry).
///
/// Spec §10: snackbars are for plain outcomes plus one optional action — never
/// for errors that require a decision (use an [AppInfoPanel] or a dialog).
/// The action re-enters application logic through [onAction]; the snackbar
/// itself never fakes success.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  AppSnackBarTone tone = AppSnackBarTone.neutral,
  Duration duration = const Duration(seconds: 4),
}) {
  final colors = Theme.of(context).colorScheme;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  final IconData? icon = switch (tone) {
    AppSnackBarTone.neutral => null,
    AppSnackBarTone.success => Icons.check_circle_rounded,
    AppSnackBarTone.danger => Icons.error_outline_rounded,
  };
  final iconColor = switch (tone) {
    AppSnackBarTone.neutral => colors.onInverseSurface,
    AppSnackBarTone.success => AppColors.success,
    AppSnackBarTone.danger => AppColors.danger,
  };

  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppDimensions.iconMd, color: iconColor),
            const SizedBox(width: AppDimensions.s10),
          ],
          Expanded(child: Text(message)),
        ],
      ),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: colors.inversePrimary,
              onPressed: onAction,
            )
          : null,
    ),
  );
}
