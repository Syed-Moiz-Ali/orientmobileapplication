import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

Future<bool> showAppConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  IconData icon = Icons.help_outline_rounded,
  bool destructive = false,
}) async {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final accent = destructive ? colors.error : colors.primary;
  final effectiveCancelLabel =
      cancelLabel ?? SharedCoreL10n.of(context).commonCancel;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      iconPadding: const EdgeInsets.only(top: AppDimensions.s24),
      icon: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppDimensions.radiusDialog),
            border: Border.all(color: accent.withValues(alpha: 0.20)),
          ),
          child: Icon(icon, color: accent, size: 26),
        ),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
        ),
      ),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowButtonSpacing: AppDimensions.s8,
      actions: [
        TextButton(
          // Destructive confirmations put the safe choice (cancel) under the
          // thumb and give it initial focus (spec §8.7 — safest choice first).
          autofocus: destructive,
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(effectiveCancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
