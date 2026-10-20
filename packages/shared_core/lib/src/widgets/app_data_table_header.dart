import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Column descriptor shared by [AppDataTableHeader] and `AppDataTable`.
class AppDataColumn {
  final String label;
  final bool numeric;
  final bool sortable;
  final int flex;

  const AppDataColumn({
    required this.label,
    this.numeric = false,
    this.sortable = false,
    this.flex = 1,
  });
}

/// Header row for `AppDataTable` (phase-1f).
///
/// `surfaceSunken` background, >= 48 px tall (sortable cells meet the tap
/// target on their own). Sortable cells expose a sort-state Semantics label
/// ("Sort by X" / "X, sorted ascending") and an accent arrow when active.
class AppDataTableHeader extends StatelessWidget {
  final List<AppDataColumn> columns;
  final int? sortColumnIndex;
  final bool sortAscending;
  final ValueChanged<int>? onSort;

  const AppDataTableHeader({
    super.key,
    required this.columns,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      color: context.semanticColors.surfaceSunken,
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            Expanded(flex: columns[i].flex, child: _cell(context, i)),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, int index) {
    final column = columns[index];
    final scheme = context.colors;
    final active = sortColumnIndex == index;
    final content = Row(
      mainAxisAlignment: column.numeric
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            column.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: scheme.onSurface),
          ),
        ),
        if (column.sortable && active) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(
            sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 18,
            color: scheme.primary,
          ),
        ],
      ],
    );
    final cell = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Align(
        alignment: column.numeric
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: content,
      ),
    );
    if (!column.sortable || onSort == null) return cell;
    final label = active
        ? '${column.label}, sorted ${sortAscending ? 'ascending' : 'descending'}'
        : 'Sort by ${column.label}';
    // One node, one label: the inner text is excluded so screen readers
    // announce exactly the sort state (no "Amount Amount" doubling).
    return Semantics(
      button: true,
      label: label,
      onTap: () => onSort!(index),
      excludeSemantics: true,
      child: InkWell(onTap: () => onSort!(index), child: cell),
    );
  }
}
