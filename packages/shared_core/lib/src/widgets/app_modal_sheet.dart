import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_pill_button.dart';

/// Spec-C8 modal bottom sheet (phase-1e-ii).
///
/// Top radius 28, 36x4 drag handle on the border color, padding 24, max
/// height 90% of the screen, safe-area + keyboard insets, scrimmed modal
/// route, and a pinned primary action that never scrolls away.
///
/// Spec name `AppBottomSheet` is used as-is: the class name is free in
/// `packages/` (verified before building). Only the *file* deviates — it
/// lives in `app_modal_sheet.dart` because the legacy `showAppModalSheet`
/// helper owns `app_bottom_sheet.dart` and is off-limits in phase 1.
/// Rename path: move this class into `app_bottom_sheet.dart` in one codemod
/// once the legacy helper is migrated.
///
/// ```dart
/// showAppBottomSheet<void>(
///   context,
///   title: 'Filter bookings',
///   primaryLabel: 'Apply filters',
///   onPrimary: applyFilters, // pop from the caller when done
///   child: const Text('Filter rows go here'),
/// )
/// ```
///
/// - Tokens only; caller-supplied text; Directional insets throughout.
/// - Drag-to-dismiss, tap-outside dismiss and focus trapping come from the
///   modal route in [showAppBottomSheet]; the widget only draws the chrome,
///   so it stays pumpable without a route in widget tests and the gallery.
/// - Announced as a named route for screen readers.
class AppBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? semanticLabel;

  const AppBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.primaryLabel,
    this.onPrimary,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasPrimary = primaryLabel != null && onPrimary != null;
    return Semantics(
      namesRoute: true,
      label: semanticLabel ?? title,
      container: true,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.9,
            ),
            child: Material(
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.sheetTop),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Container(
                      key: const ValueKey<String>(
                        'AppBottomSheet.dragHandle',
                      ),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outline,
                        borderRadius:
                            BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  if (title != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.xl,
                        AppSpacing.md,
                        AppSpacing.xl,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        '\u2066${title!}\u2069',
                        style: textTheme.titleMedium,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.only(
                        start: AppSpacing.xl,
                        end: AppSpacing.xl,
                        bottom: AppSpacing.xl,
                      ),
                      child: child,
                    ),
                  ),
                  if (hasPrimary)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.xl,
                        0,
                        AppSpacing.xl,
                        AppSpacing.xl,
                      ),
                      child: AppPillButton.primary(
                        label: primaryLabel!,
                        onPressed: onPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Presents [AppBottomSheet] as a scrimmed modal route (phase-1e-ii).
///
/// Scrim is the overlay token (40% black light, 60% dark). Drag and
/// tap-outside dismiss when [isDismissible] (default true); the barrier uses
/// the localized modal-dismiss label. [onPrimary] never pops by itself —
/// pop from the caller so validation can keep the sheet open.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  String? title,
  required Widget child,
  String? primaryLabel,
  VoidCallback? onPrimary,
  String? semanticLabel,
  bool isDismissible = true,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    barrierColor: dark ? AppDarkColors.overlayScrim : AppColors.overlayScrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheetTop),
      ),
    ),
    builder: (sheetContext) => AppBottomSheet(
      title: title,
      primaryLabel: primaryLabel,
      onPrimary: onPrimary,
      semanticLabel: semanticLabel,
      child: child,
    ),
  );
}
