import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/inventory_providers.dart';
import 'package:owner_app/features/job_cards/presentation/widgets/job_status_ui.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Display-only valuation at cost (Σ qty × cost). Accounting basis, never
/// the selling price; derived from frozen items for display only.
double _valuation(List<InvItem> items) =>
    items.fold(0, (sum, i) => sum + i.qtyOnHand * i.costPrice);

/// Inventory (O10): valuation hero, reorder-alert strip over the real
/// `reorderLevel` thresholds (red at zero, amber below level), parts table
/// with a supplier/category filter sheet, suppliers and purchase orders.
/// Stock ± and add-part flows call the frozen notifier; toasts report the
/// returned error strings. Category chips derive from loaded items; a
/// supplier filter is omitted (items carry no supplier linkage — faking one
/// would invent data).
class InventoryView extends ConsumerStatefulWidget {
  const InventoryView({super.key});

  @override
  ConsumerState<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends ConsumerState<InventoryView> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  int _tab = 0;
  String? _category;
  bool _lowOnly = false;
  int? _sortIndex;
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<InvItem> _visible(List<InvItem> items) {
    var out = items;
    if (_category != null) {
      out = out.where((i) => i.category == _category).toList();
    }
    if (_lowOnly) {
      out = out.where((i) => i.lowStock).toList();
    }
    if (_sortIndex != null) {
      final Comparator<InvItem> cmp = switch (_sortIndex) {
        0 => (a, b) => a.name.compareTo(b.name),
        2 => (a, b) => a.qtyOnHand.compareTo(b.qtyOnHand),
        _ => (a, b) => a.sellingPrice.compareTo(b.sellingPrice),
      };
      out = List<InvItem>.of(out)
        ..sort((a, b) => _sortAscending ? cmp(a, b) : cmp(b, a));
    }
    return out;
  }

  void _toast(String msg, {required bool ok}) {
    final ink = context.semanticColors.onPrimary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ok
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              color: ink,
              size: AppDimensions.iconSm,
            ),
            const SizedBox(width: AppDimensions.s8),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: ok
            ? context.semanticColors.success.base
            : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _adjust(InvItem item, int delta) async {
    HapticFeedback.lightImpact();
    final t = OwnerLocalizations.of(context)!;
    final err = await ref.read(inventoryProvider.notifier).adjustStock(
          item.id,
          delta,
        );
    if (!mounted) return;
    if (err != null) _toast('${t.ownerInAdjustFail} $err', ok: false);
  }

  void _openStock(InvItem item) {
    HapticFeedback.selectionClick();
    showAppModalSheet<void>(
      context: context,
      builder: (sheetContext) => _StockSheet(
        item: item,
        onAdjust: (delta) => _adjust(item, delta),
      ),
    );
  }

  void _openFilter(List<String> categories) {
    HapticFeedback.selectionClick();
    final t = OwnerLocalizations.of(context)!;
    String? picked = _category;
    var low = _lowOnly;
    showAppModalSheet<void>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.s20,
              AppDimensions.s8,
              AppDimensions.s20,
              AppDimensions.s20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: SectionHeader(
                    title: t.ownerInFilter,
                    padding:
                        const EdgeInsets.only(bottom: AppDimensions.s12),
                  ),
                ),
                Text(
                  t.ownerInCategory,
                  style: Theme.of(sheetContext).textTheme.labelSmall?.copyWith(
                        color: Theme.of(sheetContext)
                            .colorScheme
                            .onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppDimensions.s8),
                Wrap(
                  spacing: AppDimensions.s8,
                  runSpacing: AppDimensions.s8,
                  children: [
                    _ChoiceChip(
                      label: t.ownerInAllStock,
                      selected: picked == null,
                      onTap: () => setSheet(() => picked = null),
                    ),
                    for (final c in categories)
                      _ChoiceChip(
                        label: c,
                        selected: picked == c,
                        onTap: () =>
                            setSheet(() => picked = picked == c ? null : c),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s16),
                Text(
                  t.ownerInAvailability,
                  style: Theme.of(sheetContext).textTheme.labelSmall?.copyWith(
                        color: Theme.of(sheetContext)
                            .colorScheme
                            .onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppDimensions.s8),
                Wrap(
                  spacing: AppDimensions.s8,
                  children: [
                    _ChoiceChip(
                      label: t.ownerInAllStock,
                      selected: !low,
                      onTap: () => setSheet(() => low = false),
                    ),
                    _ChoiceChip(
                      label: t.ownerInLowOnly,
                      selected: low,
                      onTap: () => setSheet(() => low = true),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s20),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: t.ownerInClear,
                        onPressed: () {
                          setState(() {
                            _category = null;
                            _lowOnly = false;
                          });
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s10),
                    Expanded(
                      child: PrimaryButton(
                        label: t.ownerInApply,
                        icon: Icons.check_rounded,
                        onPressed: () {
                          setState(() {
                            _category = picked;
                            _lowOnly = low;
                          });
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAdd() {
    HapticFeedback.selectionClick();
    showAppModalSheet<void>(
      context: context,
      builder: (sheetContext) => _AddPartSheet(
        onSubmit: (payload) async {
          final err =
              await ref.read(inventoryProvider.notifier).addItem(payload);
          if (!mounted) return false;
          final t = OwnerLocalizations.of(context)!;
          _toast(err == null ? t.ownerInAdded : '${t.ownerInAddFail} $err',
              ok: err == null);
          return err == null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final formatters = AppFormatters.of(context);
    final state = ref.watch(inventoryProvider);
    final notifier = ref.read(inventoryProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final items = _visible(state.filteredItems);
    final categories = <String>{
      for (final i in state.items)
        if (i.category.trim().isNotEmpty) i.category.trim(),
    }.toList()
      ..sort();
    final outCount =
        state.items.where((i) => i.qtyOnHand == 0).length;
    final lowCount =
        state.items.where((i) => i.lowStock && i.qtyOnHand > 0).length;
    final filtering = state.searchQuery.isNotEmpty ||
        _category != null ||
        _lowOnly;

    final tabs = <String>[t.ownerInParts, t.ownerInSuppliers, t.ownerInOrders];

    return WorkspaceSearchShortcuts(
      onSearch: () => _searchFocus.requestFocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: WorkspaceAppBar(
          title: t.ownerInTitle,
          showBack: true,
          showOfflineStatus: true,
          actions: [
            IconButton(
              tooltip: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                HapticFeedback.selectionClick();
                notifier.load();
              },
            ),
          ],
        ),
        floatingActionButton: _tab == 0
            ? FloatingActionButton.extended(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                elevation: 4,
                onPressed: _openAdd,
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  t.ownerInAdd,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              )
            : null,
        body: SafeArea(
          child: state.isLoading && state.items.isEmpty
              ? const AppSkeleton.page()
              : state.error.isNotEmpty && state.items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(context.pagePadding.left),
                        child: ErrorView(
                          message: state.error,
                          onRetry: notifier.load,
                        ),
                      ),
                    )
                  : AppResponsivePage(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ValuationHero(
                            value: formatAed2(
                              formatters,
                              _valuation(state.items),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          _AlertStrip(
                            outCount: outCount,
                            lowCount: lowCount,
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          _TabStrip(
                            tabs: tabs,
                            index: _tab,
                            onSelect: (i) => setState(() => _tab = i),
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          if (_tab == 0) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: AppSearchField(
                                    controller: _searchCtrl,
                                    focusNode: _searchFocus,
                                    hintText: t.ownerInSearchHint,
                                    onChanged: notifier.onSearch,
                                    onClear: () {
                                      _searchCtrl.clear();
                                      notifier.onSearch('');
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.s8),
                                _FilterButton(
                                  active: _category != null || _lowOnly,
                                  onTap: () => _openFilter(categories),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.s12),
                            _PartsTable(
                              items: items,
                              sortIndex: _sortIndex,
                              sortAscending: _sortAscending,
                              onSort: (index) => setState(() {
                                if (_sortIndex == index) {
                                  _sortAscending = !_sortAscending;
                                } else {
                                  _sortIndex = index;
                                  _sortAscending = true;
                                }
                              }),
                              onOpen: _openStock,
                              emptyMessage: filtering
                                  ? t.ownerInNoMatch
                                  : t.ownerInEmpty,
                              maxHeight: wide ? 560 : null,
                            ),
                          ] else if (_tab == 1)
                            _SuppliersList(
                              suppliers: state.suppliers,
                            )
                          else
                            _OrdersList(
                              orders: state.purchaseOrders,
                            ),
                          const SizedBox(height: 96),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

/// Valuation hero: total stock at cost in fixed-decimal tabular money.
class _ValuationHero extends StatelessWidget {
  final String value;

  const _ValuationHero({required this.value});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TelemetryMetricPod(
        isHero: true,
        label: t.ownerInValuation,
        value: value,
        supportingText: t.ownerInAtCost,
        icon: Icons.inventory_2_rounded,
      ),
    );
  }
}

/// Reorder strip: red counts zero-stock, amber counts below-level, calm line
/// when healthy. Thresholds are the items' own `reorderLevel` values.
class _AlertStrip extends StatelessWidget {
  final int outCount;
  final int lowCount;

  const _AlertStrip({required this.outCount, required this.lowCount});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;

    if (outCount == 0 && lowCount == 0) {
      return Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: AppDimensions.iconXs,
            color: semantic.success.base,
          ),
          const SizedBox(width: AppDimensions.s6),
          Expanded(
            child: Text(
              t.ownerInStockOk,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    final tone = outCount > 0 ? semantic.danger : semantic.warning;
    final text = outCount > 0
        ? t.ownerInOut(outCount)
        : t.ownerInLow(lowCount);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s16,
        vertical: AppDimensions.s12,
      ),
      decoration: BoxDecoration(
        color: tone.subtle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: tone.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: AppDimensions.iconSm,
            color: tone.ink,
          ),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tone.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabStrip extends StatelessWidget {
  final List<String> tabs;
  final int index;
  final ValueChanged<int> onSelect;

  const _TabStrip({
    required this.tabs,
    required this.index,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s4),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        ),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelect(i);
                  },
                  child: AnimatedContainer(
                    duration:
                        AppMotion.resolve(context, AppMotion.fast),
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.s10),
                    decoration: BoxDecoration(
                      color:
                          index == i ? colors.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                      boxShadow: index == i
                          ? AppDimensions.shadowCard
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tabs[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: index == i
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: index == i
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _FilterButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: t.ownerInFilter,
      child: Material(
        color: active
            ? colors.primary
            : colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          side: BorderSide(
            color: active ? Colors.transparent : colors.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: SizedBox(
            width: AppDimensions.touchTarget,
            height: AppDimensions.touchTarget,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  color:
                      active ? colors.onPrimary : colors.onSurfaceVariant,
                ),
                if (active)
                  PositionedDirectional(
                    top: 10,
                    end: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.onPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? colors.primary
          : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        side: BorderSide(
          color: selected ? Colors.transparent : colors.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s16,
            vertical: AppDimensions.s10,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? colors.onPrimary : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _PartsTable extends StatelessWidget {
  final List<InvItem> items;
  final int? sortIndex;
  final bool sortAscending;
  final ValueChanged<int> onSort;
  final ValueChanged<InvItem> onOpen;
  final String emptyMessage;
  final double? maxHeight;

  const _PartsTable({
    required this.items,
    required this.sortIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onOpen,
    required this.emptyMessage,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final formatters = AppFormatters.of(context);

    return AppTable<InvItem>(
      columns: [
        AppTableColumn(label: t.ownerInParts, flex: 3, sortable: true),
        AppTableColumn(label: 'SKU', flex: 2),
        AppTableColumn(label: t.ownerArAmount, flex: 2, numeric: true, sortable: true),
        AppTableColumn(label: t.ownerInQtyCol, flex: 1, numeric: true, sortable: true),
      ],
      items: items,
      cells: (context, item) => [
        AppTableCell.text(context, item.name),
        AppTableCell.custom(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              item.sku,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.mono(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          AlignmentDirectional.centerStart,
        ),
        AppTableCell.numeric(
          context,
          formatAed2(formatters, item.sellingPrice),
        ),
        AppTableCell.custom(
          _QtyPill(item: item),
          AlignmentDirectional.centerEnd,
        ),
      ],
      sortIndex: sortIndex,
      sortAscending: sortAscending,
      onSort: onSort,
      onRowTap: onOpen,
      emptyMessage: emptyMessage,
      maxHeight: maxHeight,
      compactBuilder: (context, item) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.s8),
        child: AppRecordRow(
          title: item.name,
          subtitle: '${item.sku} · ${item.category}',
          metadata: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  formatAed2(formatters, item.sellingPrice),
                  style: AppTextStyles.mono(
                    color: Theme.of(context).colorScheme.onSurface,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: AppDimensions.s6),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _QtyPill(item: item),
              ),
            ],
          ),
          onTap: () => onOpen(item),
        ),
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  final InvItem item;

  const _QtyPill({required this.item});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final semantic = context.semanticColors;
    final tone = item.qtyOnHand == 0
        ? semantic.danger
        : item.lowStock
            ? semantic.warning
            : semantic.success;
    return StatusPill(
      label: t.ownerInStockLeft(item.qtyOnHand),
      bg: tone.subtle,
      fg: tone.ink,
    );
  }
}

/// Stock sheet: item facts plus the single ± adjust path over the frozen
/// notifier. Errors surface as toasts; success closes silently after the
/// list reloads (the notifier reloads on every adjust).
class _StockSheet extends StatelessWidget {
  final InvItem item;
  final Future<void> Function(int delta) onAdjust;

  const _StockSheet({required this.item, required this.onAdjust});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final formatters = AppFormatters.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s20,
          AppDimensions.s8,
          AppDimensions.s20,
          AppDimensions.s20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '${item.sku} · ${item.category}',
                style: AppTextStyles.mono(color: colors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            Row(
              children: [
                _StockFact(
                  label: t.ownerInStockLeft(item.qtyOnHand),
                  value: formatAed2(formatters, item.sellingPrice),
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton.filledTonal(
                        tooltip: '-1',
                        onPressed: () => onAdjust(-1),
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      const SizedBox(width: AppDimensions.s8),
                      IconButton.filled(
                        tooltip: '+1',
                        onPressed: () => onAdjust(1),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s16),
            SecondaryButton(
              label: MaterialLocalizations.of(context).closeButtonLabel,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockFact extends StatelessWidget {
  final String label;
  final String value;

  const _StockFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              style: AppTextStyles.mono(
                color: theme.colorScheme.onSurface,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Add-part sheet: the frozen `addItem` contract with shared inputs.
/// Validation reuses the shared required copy; the provider returns the
/// error string (or null) and the caller toasts it.
class _AddPartSheet extends StatefulWidget {
  final Future<bool> Function(Map<String, dynamic> payload) onSubmit;

  const _AddPartSheet({required this.onSubmit});

  @override
  State<_AddPartSheet> createState() => _AddPartSheetState();
}

class _AddPartSheetState extends State<_AddPartSheet> {
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController();
  final _reorder = TextEditingController();
  bool _busy = false;
  String? _nameError;
  String? _skuError;

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _price.dispose();
    _qty.dispose();
    _reorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.s20,
          AppDimensions.s8,
          AppDimensions.s20,
          AppDimensions.s20 +
              MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Semantics(
                  header: true,
                  child: SectionHeader(
                    title: t.ownerInAddTitle,
                    padding:
                        const EdgeInsets.only(bottom: AppDimensions.s12),
                  ),
                ),
                AppTextField(
                  controller: _name,
                  label: t.ownerInName,
                  hint: t.ownerInName,
                  errorText: _nameError,
                ),
                const SizedBox(height: AppDimensions.s12),
                AppTextField(
                  controller: _sku,
                  label: t.ownerInSku,
                  hint: t.ownerInSku,
                  errorText: _skuError,
                ),
                const SizedBox(height: AppDimensions.s12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _price,
                        label: t.ownerInPrice,
                        hint: t.ownerInPrice,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s10),
                    Expanded(
                      child: AppTextField(
                        controller: _qty,
                        label: t.ownerInQty,
                        hint: t.ownerInQty,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s12),
                AppTextField(
                  controller: _reorder,
                  label: t.ownerInReorder,
                  hint: t.ownerInReorder,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppDimensions.s20),
                PrimaryButton(
                  label: t.ownerInSubmit,
                  icon: Icons.add_rounded,
                  isLoading: _busy,
                  onPressed: _busy
                      ? null
                      : () async {
                          final nameOk = _name.text.trim().isNotEmpty;
                          final skuOk = _sku.text.trim().isNotEmpty;
                          setState(() {
                            _nameError =
                                nameOk ? null : t.ownerReqRequired;
                            _skuError =
                                skuOk ? null : t.ownerReqRequired;
                          });
                          if (!nameOk || !skuOk) return;
                          setState(() => _busy = true);
                          final navigator = Navigator.of(context);
                          final ok = await widget.onSubmit({
                            'name': _name.text.trim(),
                            'sku': _sku.text.trim(),
                            'sellingPrice':
                                double.tryParse(_price.text.trim()) ?? 0,
                            'qtyOnHand':
                                int.tryParse(_qty.text.trim()) ?? 0,
                            'reorderLevel':
                                int.tryParse(_reorder.text.trim()) ?? 5,
                          });
                          if (!mounted) return;
                          setState(() => _busy = false);
                          if (ok) navigator.pop();
                        },
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class _SuppliersList extends StatelessWidget {
  final List<InvSupplier> suppliers;

  const _SuppliersList({required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    if (suppliers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s32),
        child: EmptyState(
          icon: Icons.local_shipping_outlined,
          message: t.ownerInNoSuppliers,
        ),
      );
    }
    return Column(
      children: [
        for (final s in suppliers) ...[
          AppRecordRow(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusSm),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.local_shipping_outlined,
                color: colors.primary,
                size: AppDimensions.iconMd,
              ),
            ),
            title: s.name,
            subtitle: s.phone.isEmpty ? t.ownerInNoPhone : s.phone,
          ),
          const SizedBox(height: AppDimensions.s8),
        ],
      ],
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<PurchaseOrderEntity> orders;

  const _OrdersList({required this.orders});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s32),
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          message: t.ownerInNoOrders,
        ),
      );
    }
    return Column(
      children: [
        for (final po in orders) ...[
          AppRecordRow(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusSm),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.receipt_long_rounded,
                color: theme.colorScheme.primary,
                size: AppDimensions.iconMd,
              ),
            ),
            title: po.poRef,
            subtitle: po.status,
            metadata: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                po.total,
                style: AppTextStyles.mono(
                  color: theme.colorScheme.onSurface,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
        ],
      ],
    );
  }
}
