import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/app_data_row.dart';
import 'package:shared_core/src/widgets/app_data_table_header.dart';
import 'package:shared_core/src/widgets/app_surface_card.dart';

/// Spec-C8 responsive table (phase-1f). Named `AppDataTable` (not spec
/// `AppTable`) because the legacy `AppTable` in `app_table.dart` owns that
/// name and is off-limits in phase 1. Rename path: `AppDataTable` ->
/// `AppTable` in one codemod once the legacy table has zero usages.
///
/// ```dart
/// AppDataTable(
///   columns: const [AppDataColumn(label: 'Invoice'),
///     AppDataColumn(label: 'Amount', numeric: true, sortable: true)],
///   rows: const [['INV-101', 'AED 1,240.00']],
///   sortColumnIndex: 1, sortAscending: true, onSort: sortRows,
/// )
/// ```
///
/// Wide surfaces (>= 600 px): real table ([AppDataTableHeader] on
/// `surfaceSunken`, numbers tabular + end-aligned and LTR-locked). With
/// [maxHeight] the body scrolls under a pinned header. Compact surfaces:
/// one [AppSurfaceCard] per row (spec "tables become cards"; reuse keeps
/// card chrome identical). The breakpoint reads the incoming surface width
/// via `AppResponsive`, so narrow sheets degrade gracefully too.
class AppDataTable extends StatelessWidget {
  final List<AppDataColumn> columns;
  final List<List<String>> rows;
  final int? sortColumnIndex;
  final bool sortAscending;
  final ValueChanged<int>? onSort;
  final double? maxHeight;

  const AppDataTable({
    super.key, required this.columns, required this.rows, this.sortColumnIndex,
    this.sortAscending = true, this.onSort, this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) =>
          AppResponsive.specFor(context, constraints: c).isCompact
          ? _cards(context)
          : _wide(context),
    );
  }

  Widget _cell(BuildContext context, AppDataColumn column, String value) {
    final scheme = context.colors;
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: scheme.onSurface,
      fontFeatures: column.numeric
          ? const [FontFeature.tabularFigures()]
          : null,
    );
    final text = Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: column.numeric ? TextAlign.end : TextAlign.start,
      style: style,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: column.numeric
          ? Directionality(textDirection: TextDirection.ltr, child: text)
          : text,
    );
  }

  Widget _wide(BuildContext context) {
    final scheme = context.colors;
    final header = AppDataTableHeader(
      columns: columns,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      onSort: onSort,
    );
    Widget row(int index) => Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outline)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            Expanded(
              flex: columns[i].flex,
              child: _cell(context, columns[i], rows[index][i]),
            ),
        ],
      ),
    );
    final body = maxHeight == null
        ? Column(children: [for (var i = 0; i < rows.length; i++) row(i)])
        : SizedBox(
            height: maxHeight,
            child: Column(children: [
              header,
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: rows.length,
                  itemBuilder: (context, i) => row(i),
                ),
              ),
            ]),
          );
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: scheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: maxHeight == null ? Column(children: [header, body]) : body,
    );
  }

  Widget _cards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          AppSurfaceCard(
            padding: AppSpacing.cardPaddingCompactAll,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  AppDataRow(label: columns[i].label, value: rows[r][i], forceValueLtr: columns[i].numeric),
                ],
              ],
            ),
          ),
          if (r != rows.length - 1) const SizedBox(height: AppSpacing.listGap),
        ],
      ],
    );
  }
}
