import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
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
///
/// Placement follows the window class from the single responsive authority:
/// compact/medium dock the toast at the bottom (thumb reach), expanded/large
/// pin a 400dp card to the top end (out of the way of the centered canvas).
/// The surface is theme-driven ([ColorScheme.surfaceContainerHighest] with
/// [ColorScheme.onSurface] ink) so the toast flips with light/dark instead of
/// sitting as a fixed black slab.
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

  // Breakpoint from the centralized spec only — no width literals here. The
  // size read below is pure overlay offset math (top-end pin), never a
  // breakpoint decision.
  final wide = context.isExpanded || context.isLarge;
  final EdgeInsets margin;
  if (wide) {
    final size = MediaQuery.sizeOf(context);
    margin = EdgeInsets.only(
      left: (size.width - 424).clamp(24.0, double.infinity).toDouble(),
      right: AppDimensions.s24,
      // Pin the card near the top: the bottom margin consumes the rest of
      // the viewport height.
      top: AppDimensions.s24,
      bottom: (size.height - 140).clamp(24.0, double.infinity).toDouble(),
    );
  } else {
    margin = const EdgeInsets.all(AppDimensions.s16);
  }

  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: margin,
      elevation: 0,
      backgroundColor: colors.surfaceContainerHighest,
      dismissDirection: wide ? DismissDirection.up : DismissDirection.down,
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
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: colors.primary,
              onPressed: onAction,
            )
          : null,
    ),
  );
}
