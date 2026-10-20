import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';

/// Spec-C8 key/value row (phase-1c-i).
///
/// Label at the start (textSecondary), value at the end (textPrimary,
/// tabular figures), 12 px gap. Used for grouped info cards
/// (detail screens) and "Advanced details" accordions.
///
/// ```dart
/// AppDataRow(label: 'Invoice total', value: 'AED 1,240.00')
/// AppDataRow(label: 'الحالة', value: 'Active') // value stays LTR
/// ```
///
/// - Tokens only, caller-supplied text, Directional-safe (label/value swap
///   sides in RTL automatically).
/// - Wraps at text scale 1.3x and with long Arabic text (no fixed heights,
///   no clipping); value uses tabular figures so columns of numbers align.
/// - `forceValueLtr` keeps numbers/IDs/currency Western digits and LTR
///   inside RTL layouts (product locale policy); the label follows the
///   locale. Display-only: excluded from tab order, read as one phrase.
class AppDataRow extends StatelessWidget {
  final String label;
  final String value;

  /// Custom value widget (replaces the [value] text when provided).
  final Widget? valueWidget;

  /// Lock the value to LTR (numbers/IDs/URLs stay Western + LTR in RTL).
  final bool forceValueLtr;

  const AppDataRow({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
    this.forceValueLtr = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final valueText = Text(
      value,
      textAlign: TextAlign.end,
      style: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    final resolvedValue = valueWidget ??
        (forceValueLtr
            ? Directionality(
                textDirection: TextDirection.ltr,
                child: valueText,
              )
            : valueText);

    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(child: resolvedValue),
        ],
      ),
    );
  }
}
