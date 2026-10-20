import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_semantic_colors.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Spec-C8 status chip (phase-1c-ii).
///
/// 8 px colored dot + short human label on a `*Soft` fill with matching ink.
/// Meaning is never carried by color alone (dot hue + label text together).
/// Name verified free (no legacy `AppStatusChip`); no rename needed.
///
/// ```dart
/// AppStatusChip(label: 'Active', kind: AppStatusKind.success)
/// AppStatusChip(label: 'Delayed', kind: AppStatusKind.warning)
/// ```
///
/// - Tokens only, resolved from `context.semanticColors` (+ `ColorScheme`
///   for the accent ink — plain `primary` on `primarySubtle` is 4.48:1 light
///   and fails AA, so the label uses `onPrimaryContainer`: 7.1+:1 light,
///   10.5+:1 dark). Caller text. All six inks are asserted >= 4.5:1 in both
///   themes in the identity tests.
/// - Display-only (no tap target); text scale 1.3x wraps, never clips.
///   Pair with [AppInfoTooltip] beside the chip for the one-sentence "why".
enum AppStatusKind { success, warning, error, info, neutral, accent }

class AppStatusChip extends StatelessWidget {
  final String label;
  final AppStatusKind kind;
  final String? semanticLabel;

  const AppStatusChip({
    super.key,
    required this.label,
    required this.kind,
    this.semanticLabel,
  });

  AppStatusColors _family(BuildContext context) {
    final sem = context.semanticColors;
    switch (kind) {
      case AppStatusKind.success:
        return sem.success;
      case AppStatusKind.warning:
        return sem.warning;
      case AppStatusKind.error:
        return sem.danger;
      case AppStatusKind.info:
        return sem.info;
      case AppStatusKind.neutral:
        return sem.neutral;
      case AppStatusKind.accent:
        return AppStatusColors(
          base: sem.primary,
          subtle: sem.primarySubtle,
          border: sem.primaryBorder,
          ink: Theme.of(context).colorScheme.onPrimaryContainer,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final family = _family(context);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: semanticLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: family.subtle,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: family.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: family.base,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              // Visual text is always [label]; [semanticLabel] is exposed
              // only via the outer Semantics (mirrors AppChip's split).
              child: ExcludeSemantics(
                child: Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(color: family.ink),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
