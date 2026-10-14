import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

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
  final semantic = context.semanticColors;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  final IconData? icon = switch (tone) {
    AppSnackBarTone.neutral => null,
    AppSnackBarTone.success => Icons.check_circle_rounded,
    AppSnackBarTone.danger => Icons.error_outline_rounded,
  };
  final accent = switch (tone) {
    AppSnackBarTone.neutral => colors.inversePrimary,
    AppSnackBarTone.success => semantic.success.base,
    AppSnackBarTone.danger => semantic.danger.base,
  };

  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppDimensions.s16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      content: Row(
        children: [
          // Concept A: a 3 px semantic accent rail anchors the outcome tone.
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: tone == AppSnackBarTone.neutral
                  ? semantic.borderStrong
                  : accent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          if (icon != null) ...[
            Icon(icon, size: AppDimensions.iconMd, color: accent),
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
