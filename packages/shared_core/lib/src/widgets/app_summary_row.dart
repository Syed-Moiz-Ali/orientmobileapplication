import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';

/// Bidi-isolates [text] (U+2066…U+2069) so leading numbers never reorder in
/// RTL paragraphs; paragraph direction and alignment follow the locale.
String _isolate(String text) => '\u2066$text\u2069';

/// Label/value row for sticky bars and receipts (phase-1P).
///
/// Total/price/status line inside [AppStickyActionBar] or receipt sheets:
/// label at the `start` (`onSurfaceVariant`), value at the `end`
/// (`onSurface`, semi-bold, tabular figures so columns of numbers align).
///
/// ```dart
/// AppSummaryRow(label: 'Total', value: 'AED 240.00')
/// AppSummaryRow(label: 'المجموع', value: 'AED 240.00') // value stays LTR
/// ```
///
/// - Tokens only, caller-supplied text, Directional-safe (label/value swap
///   sides in RTL automatically).
/// - Value is tabular ([FontFeature.tabularFigures]) and LTR-isolated:
///   numbers/IDs/currency keep Western digits and LTR order inside RTL
///   layouts (product locale policy) via [forceValueLtr]; the label follows
///   the locale. Distinct from [AppDataRow] (grouped info cards,
///   bodyMedium value): this row uses a semi-bold `titleSmall` value tuned
///   for totals in sticky bars — use [AppDataRow] for detail lists, this
///   for bars/receipts.
/// - Wraps at text scale 1.3x and with long Arabic text (no fixed heights,
///   no clipping, no ellipsis on primary content).
/// - Display-only: merged into one Semantics node, read as a single phrase.
class AppSummaryRow extends StatelessWidget {
  /// Start-side label, e.g. "Total".
  final String label;

  /// End-side value, e.g. "AED 240.00".
  final String value;

  /// Custom value widget (replaces the [value] text when provided; the
  /// caller owns its direction/isolation in that case).
  final Widget? valueWidget;

  /// Lock the value to LTR (numbers/IDs/URLs stay Western + LTR in RTL).
  final bool forceValueLtr;

  const AppSummaryRow({
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
      _isolate(value),
      textAlign: TextAlign.end,
      style: textTheme.titleSmall?.copyWith(
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
