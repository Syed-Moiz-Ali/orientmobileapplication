import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_density.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/app_skeleton.dart';

/// Column definition shared by [AppTableHeader] and [AppTable].
///
/// Set [numeric] for money/quantity columns: the cell is rendered with tabular
/// figures and aligned to the reading-end edge (`centerEnd`), which mirrors
/// correctly in RTL (spec §13).
class AppTableColumn {
  final String label;
  final int flex;
  final bool numeric;
  final bool sortable;
  final AlignmentGeometry alignment;
  final double? minWidth;

  const AppTableColumn({
    required this.label,
    this.flex = 1,
    this.numeric = false,
    this.sortable = false,
    this.alignment = AlignmentDirectional.centerStart,
    this.minWidth,
  });
}

/// Desktop-class table header: sortable indicator slot, sticky-capable, with a
/// leading (selection) and trailing (kebab) column slot.
class AppTableHeader extends StatelessWidget {
  final List<AppTableColumn> columns;
  final int? sortIndex;
  final bool sortAscending;
  final ValueChanged<int>? onSort;
  final Widget? leading;
  final Widget? trailing;
  final double leadingWidth;
  final double trailingWidth;
  final bool dense;

  const AppTableHeader({
    super.key,
    required this.columns,
    this.sortIndex,
    this.sortAscending = true,
    this.onSort,
    this.leading,
    this.trailing,
    this.leadingWidth = 44,
    this.trailingWidth = 44,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      height: dense
          ? AppDimensions.tableRowCompact
          : AppDimensions.tableHeaderHeight,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: Row(
        children: [
          if (leading != null)
            SizedBox(
              width: leadingWidth,
              child: Center(child: leading),
            ),
          for (var i = 0; i < columns.length; i++)
            Expanded(
              flex: columns[i].flex,
              child: _headerCell(context, columns[i], i, sortIndex == i),
            ),
          if (trailing != null) SizedBox(width: trailingWidth, child: trailing),
        ],
      ),
    );
  }

  Widget _headerCell(
    BuildContext context,
    AppTableColumn column,
    int index,
    bool active,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = Text(
      column.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.tableHeader(
        color: colors.onSurfaceVariant,
        arabic: AppTypography.isArabic(Localizations.maybeLocaleOf(context)),
      ),
    );

    final content = Row(
      mainAxisAlignment: column.numeric
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(child: label),
        if (column.sortable && active) ...[
          const SizedBox(width: 4),
          Icon(
            sortAscending
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: AppDimensions.iconXs + 2,
            color: colors.primary,
          ),
        ],
      ],
    );

    final aligned = Align(alignment: column.alignment, child: content);

    if (!column.sortable || onSort == null) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: AppDimensions.s12),
        child: aligned,
      );
    }

    return Semantics(
      button: true,
      label:
          '${column.label} — ${active ? (sortAscending ? 'ascending' : 'descending') : 'sort'}',
      child: InkWell(
        onTap: () => onSort!(index),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: AppDimensions.s12),
          child: aligned,
        ),
      ),
    );
  }
}

/// Desktop-class table data row: hover + selected states, 36–44 px density and
/// leading/kebab slots. Tappable rows are exposed as semantic buttons.
class AppTableRow extends StatelessWidget {
  final List<Widget> cells;

  /// Optional per-cell flex, defaulting to 1 (must mirror the header flexes).
  final List<int>? flex;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool dense;
  final double leadingWidth;
  final double trailingWidth;
  final EdgeInsetsGeometry? padding;
  final Color? selectedColor;

  /// Alternating-row tint flag (applied by [AppTable] for odd rows).
  final bool zebra;

  /// Override for the alternating-row tint; defaults to the semantic recessed
  /// surface so it follows the active theme.
  final Color? zebraColor;

  const AppTableRow({
    super.key,
    required this.cells,
    this.flex,
    this.selected = false,
    this.onTap,
    this.leading,
    this.trailing,
    this.dense = false,
    this.leadingWidth = 44,
    this.trailingWidth = 44,
    this.padding,
    this.selectedColor,
    this.zebra = false,
    this.zebraColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final minHeight = dense
        ? AppDimensions.tableRowCompact
        : AppDimensions.tableRowRegular;

    final Color? background = selected
        ? (selectedColor ?? colors.primary.withValues(alpha: 0.08))
        : zebra
        ? (zebraColor ?? context.semanticColors.surfaceSubtle)
        : null;

    final row = Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: AppDimensions.s8),
      color: background,
      child: Row(
        children: [
          if (leading != null)
            SizedBox(
              width: leadingWidth,
              child: Center(child: leading),
            ),
          for (var i = 0; i < cells.length; i++)
            Expanded(
              flex: i < (flex?.length ?? 0) ? flex![i] : 1,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  end: AppDimensions.s12,
                ),
                child: cells[i],
              ),
            ),
          if (trailing != null)
            SizedBox(
              width: trailingWidth,
              child: Center(child: trailing),
            ),
        ],
      ),
    );

    // A selected row carries a 3 px cobalt rail on the reading-start edge
    // (start = right in RTL, so it always hugs the logical start).
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: selected
          ? Stack(
              children: [
                row,
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 3, color: colors.primary),
                ),
              ],
            )
          : row,
    );

    if (onTap == null) return decorated;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: colors.primary.withValues(alpha: 0.04),
          child: decorated,
        ),
      ),
    );
  }
}

/// In-table empty / no-match block.
class AppTableEmpty extends StatelessWidget {
  final String? title;
  final String message;
  final IconData icon;
  final bool isNoMatch;
  final Widget? action;

  const AppTableEmpty({
    super.key,
    this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.isNoMatch = false,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final t = SharedCoreL10n.of(context);
    final resolvedTitle = title ?? (isNoMatch ? t.commonNoResults : null);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s24,
        vertical: AppDimensions.s40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: colors.onSurfaceVariant),
          const SizedBox(height: AppDimensions.s12),
          if (resolvedTitle != null) ...[
            Text(
              resolvedTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.s4),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: AppDimensions.s16),
            action!,
          ],
        ],
      ),
    );
  }
}

/// One cell builder result. Helper constructors keep alignment consistent.
abstract final class AppTableCell {
  AppTableCell._();

  /// Default text cell (start-aligned).
  static Widget text(BuildContext context, String value) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  /// Money / quantity cell: tabular figures, reading-end aligned (mirrors RTL).
  static Widget numeric(BuildContext context, String value) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: AppTextStyles.mono(
          color: Theme.of(context).colorScheme.onSurface,
          arabic: AppTypography.isArabic(Localizations.maybeLocaleOf(context)),
        ),
      ),
    );
  }

  /// Free-form cell with explicit alignment.
  static Widget custom(Widget child, AlignmentGeometry alignment) =>
      Align(alignment: alignment, child: child);
}

/// Responsive desktop table with a documented compact fallback.
///
/// * `expanded`/`large` → full table at [AppDimensions.tableRowRegular].
/// * `medium`           → compact table at [AppDimensions.tableRowCompact].
/// * `compact` (<600)   → [compactBuilder] per item (an `AppRecordRow` list).
///
/// Presentation only: sorting/filtering are performed by the caller; this
/// widget renders whatever order it is given and reports sort taps via
/// [onSort].
class AppTable<T> extends StatelessWidget {
  final List<AppTableColumn> columns;
  final List<T> items;

  /// Builds the list of cells for one row (one widget per column).
  final List<Widget> Function(BuildContext context, T item) cells;

  final List<int>? cellFlex;
  final Key? Function(T item)? itemKey;
  final void Function(T item)? onRowTap;
  final bool Function(T item)? isSelected;
  final Widget Function(BuildContext context, T item)? kebab;
  final Widget? Function(BuildContext context, T item)? leadingCell;
  final Widget? leadingHeader;

  /// Compact (<600 px) representation of a row — typically an `AppRecordRow`.
  final Widget Function(BuildContext context, T item)? compactBuilder;

  // Empty / loading / error states.
  final bool isLoading;
  final int skeletonRows;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final String? noMatchMessage;
  final bool isNoMatch;
  final Widget? emptyAction;

  // Sorting (presentation only).
  final int? sortIndex;
  final bool sortAscending;
  final ValueChanged<int>? onSort;

  /// Table title/overflow shown above the header (optional).
  final Widget? toolbar;

  /// When set, the desktop/tablet body scrolls inside a fixed height with the
  /// header row pinned (sticky). Null keeps the intrinsic-height table.
  final double? maxHeight;

  const AppTable({
    super.key,
    required this.columns,
    required this.items,
    required this.cells,
    this.cellFlex,
    this.itemKey,
    this.onRowTap,
    this.isSelected,
    this.kebab,
    this.leadingCell,
    this.leadingHeader,
    this.compactBuilder,
    this.isLoading = false,
    this.skeletonRows = 6,
    this.isError = false,
    this.errorMessage,
    this.onRetry,
    this.emptyMessage,
    this.noMatchMessage,
    this.isNoMatch = false,
    this.emptyAction,
    this.sortIndex,
    this.sortAscending = true,
    this.onSort,
    this.toolbar,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;
    // Phase 01.2 density: compact mode forces dense rows on every breakpoint;
    // medium screens stay dense even in comfortable mode.
    final dense = adaptive.isMedium || context.density.isCompact;
    final theme = Theme.of(context);

    return Theme(
      data: theme,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (toolbar != null)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.s12),
                child: toolbar,
              ),
            _buildBody(context, dense),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool dense) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.s8),
        child: AppSkeleton.table(rows: skeletonRows, columns: columns.length),
      );
    }
    if (isError && errorMessage != null) {
      return AppTableEmpty(
        message: errorMessage!,
        icon: Icons.error_outline_rounded,
        action: onRetry == null
            ? null
            : TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(SharedCoreL10n.of(context).commonRetry),
              ),
      );
    }
    if (items.isEmpty) {
      return AppTableEmpty(
        message:
            (isNoMatch ? noMatchMessage : emptyMessage) ??
            SharedCoreL10n.of(context).commonNoData,
        isNoMatch: isNoMatch,
        action: emptyAction,
      );
    }

    final useFallback = context.isCompact && compactBuilder != null;
    if (useFallback) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              key: itemKey?.call(items[i]),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s12,
                vertical: AppDimensions.s6,
              ),
              child: compactBuilder!(context, items[i]),
            ),
            if (i != items.length - 1)
              Divider(height: 1, color: Theme.of(context).colorScheme.outline),
          ],
        ],
      );
    }

    final header = AppTableHeader(
      columns: columns,
      dense: dense,
      sortIndex: sortIndex,
      sortAscending: sortAscending,
      onSort: onSort,
      leading: leadingHeader,
    );

    Widget buildRow(int index) {
      final item = items[index];
      return AppTableRow(
        key: itemKey?.call(item),
        dense: dense,
        selected: isSelected?.call(item) ?? false,
        zebra: index.isOdd,
        onTap: onRowTap == null ? null : () => onRowTap!(item),
        leading: leadingCell?.call(context, item),
        trailing: kebab?.call(context, item),
        cells: cells(context, item),
        flex: cellFlex,
      );
    }

    if (maxHeight != null) {
      return SizedBox(
        height: maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (context, index) => buildRow(index),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        for (var i = 0; i < items.length; i++) buildRow(i),
      ],
    );
  }
}
