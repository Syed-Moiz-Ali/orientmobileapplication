import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

/// Opens a responsive modal surface:
/// - Mobile (<600px): Bottom Sheet with rounded top corners and drag handle.
/// - Tablet / Desktop (>=600px): Centered Dialog with bounded width.
Future<T?> showAppModalSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  String? title,
  bool isDismissible = true,
  bool enableDrag = true,
  double? maxWidth,
}) {
  final isCompact = context.isCompact;

  if (isCompact) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusSheet),
        ),
      ),
      builder: (bottomSheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.s20,
                    AppDimensions.s4,
                    AppDimensions.s20,
                    AppDimensions.s12,
                  ),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              Flexible(child: builder(bottomSheetContext)),
            ],
          ),
        ),
      ),
    );
  }

  // Tablet / Desktop dialog presentation
  return showDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    builder: (dialogContext) {
      final adaptive = dialogContext.adaptive;
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusDialog),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s32,
          vertical: AppDimensions.s24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? adaptive.dialogMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.s16),
                ],
                Flexible(child: builder(dialogContext)),
              ],
            ),
          ),
        ),
      );
    },
  );
}
