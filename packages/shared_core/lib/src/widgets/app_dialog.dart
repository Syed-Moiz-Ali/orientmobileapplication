import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_pill_button.dart';

/// Spec-C8 dialog (phase-1e-ii).
///
/// Radius 20, padding 24, title titleLarge, body bodyMedium textSecondary,
/// end-aligned secondary + primary actions, destructive variant, modal
/// focus handling, safe at text scale 1.3x.
///
/// Spec names `AppDialog` / `showAppDialog` verified free in `packages/`
/// (no collisions); no rename needed.
///
/// ```dart
/// AppDialog(
///   title: 'Discard changes?',
///   message: 'Unsent edits will be lost.',
///   secondaryLabel: 'Keep editing',
///   onSecondary: () => Navigator.pop(context),
///   primaryLabel: 'Discard',
///   onPrimary: discard,
/// )
/// AppDialog.destructive(
///   title: "Delete 'Invoice #123'?", // destructive titles name the object
///   message: 'This cannot be undone.',
///   secondaryLabel: 'Cancel',
///   onSecondary: () => Navigator.pop(context),
///   primaryLabel: 'Delete',
///   onPrimary: delete,
/// )
/// ```
///
/// - Tokens only; caller-supplied text; Directional insets; actions mirror
///   in RTL (end-aligned both ways).
/// - Focus: the modal route traps traversal; actions sit in DOM order with
///   the safe choice first (secondary when destructive, primary otherwise).
///   No forced autofocus — [AppPillButton] is off-limits to modify in
///   phase 1, so order (not a focus override) carries the safe default.
/// - 1.3x: actions use [OverflowBar] (wrap vertically, never clip); the
///   body wraps. Both action buttons keep their >= 48 dp targets.
class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool destructive;
  final String? semanticLabel;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.secondaryLabel,
    this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
    this.destructive = false,
    this.semanticLabel,
  });

  const AppDialog.destructive({
    super.key,
    required this.title,
    required this.message,
    this.secondaryLabel,
    this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
    this.semanticLabel,
  }) : destructive = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasSecondary = secondaryLabel != null && onSecondary != null;
    return Dialog(
      backgroundColor: scheme.surface,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.dialog),
        side: BorderSide(color: scheme.outline),
      ),
      child: Semantics(
        label: semanticLabel,
        container: true,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  '\u2066$title\u2069',
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '\u2066$message\u2069',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: AppSpacing.xl),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                overflowAlignment: OverflowBarAlignment.end,
                spacing: AppSpacing.sm,
                overflowSpacing: AppSpacing.sm,
                // IntrinsicWidth: AppPillButton labels size unbounded
                // intrinsically (both would claim the full dialog width and
                // always stack). Intrinsic sizing lets the bar row them
                // end-aligned when they fit and stack them when they don't
                // (1.3x / long RTL labels) — wrap, never clip.
                children: [
                  if (hasSecondary)
                    IntrinsicWidth(
                      child: AppPillButton.secondary(
                        label: secondaryLabel!,
                        onPressed: onSecondary,
                        isExpanded: false,
                      ),
                    ),
                  if (destructive)
                    IntrinsicWidth(
                      child: AppPillButton.destructive(
                        label: primaryLabel,
                        onPressed: onPrimary,
                        size: AppPillButtonSize.medium,
                        isExpanded: false,
                      ),
                    )
                  else
                    IntrinsicWidth(
                      child: AppPillButton.primary(
                        label: primaryLabel,
                        onPressed: onPrimary,
                        size: AppPillButtonSize.medium,
                        isExpanded: false,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Presents [AppDialog] as a scrimmed modal route (phase-1e-ii).
///
/// Scrim is the overlay token. Tap-outside dismisses when [barrierDismissible]
/// (default true) with the localized dismiss label; destructive dialogs
/// should pass false from the caller when the choice must be explicit.
Future<T?> showAppDialog<T>(
  BuildContext context, {
  required String title,
  required String message,
  String? secondaryLabel,
  VoidCallback? onSecondary,
  required String primaryLabel,
  VoidCallback? onPrimary,
  bool destructive = false,
  String? semanticLabel,
  bool barrierDismissible = true,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: dark ? AppDarkColors.overlayScrim : AppColors.overlayScrim,
    builder: (dialogContext) => AppDialog(
      title: title,
      message: message,
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary ?? () => Navigator.of(dialogContext).pop(),
      primaryLabel: primaryLabel,
      onPrimary: onPrimary ?? () => Navigator.of(dialogContext).pop(),
      destructive: destructive,
      semanticLabel: semanticLabel,
    ),
  );
}
