import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/models/vehicle_customer_model.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Searchable brand picker shown inside the intake bottom sheet. Pops with the
/// selected brand (unchanged return contract).
class SelectBrandSheet extends StatefulWidget {
  final String? selected;
  const SelectBrandSheet({super.key, this.selected});

  @override
  State<SelectBrandSheet> createState() => _SelectBrandSheetState();
}

class _SelectBrandSheetState extends State<SelectBrandSheet> {
  final _search = TextEditingController();
  String _query = '';
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> get _filtered => kCarBrands
      .where((b) => b.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return _SearchSheetShell(
      title: t.advisorIntakeMakeHint,
      searchController: _search,
      onQuery: (v) => setState(() => _query = v),
      empty: _filtered.isEmpty,
      children: [
        for (final brand in _filtered)
          _SelectRow(
            label: brand,
            selected: brand == _selected,
            onTap: () => Navigator.of(context).pop(brand),
          ),
      ],
    );
  }
}

/// Searchable model picker for the selected brand. Pops with the chosen model.
class SelectModelSheet extends StatefulWidget {
  final String brand;
  final String? selected;

  const SelectModelSheet({super.key, required this.brand, this.selected});

  @override
  State<SelectModelSheet> createState() => _SelectModelSheetState();
}

class _SelectModelSheetState extends State<SelectModelSheet> {
  final _search = TextEditingController();
  String _query = '';
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> get _filtered => modelsForBrand(widget.brand)
      .where((m) => m.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return _SearchSheetShell(
      title: t.advisorIntakeModelHint,
      searchController: _search,
      onQuery: (v) => setState(() => _query = v),
      empty: _filtered.isEmpty,
      children: [
        for (final model in _filtered)
          _SelectRow(
            label: model,
            selected: model == _selected,
            onTap: () => Navigator.of(context).pop(model),
          ),
      ],
    );
  }
}

class _SearchSheetShell extends StatelessWidget {
  final String title;
  final TextEditingController searchController;
  final ValueChanged<String> onQuery;
  final bool empty;
  final List<Widget> children;

  const _SearchSheetShell({
    required this.title,
    required this.searchController,
    required this.onQuery,
    required this.empty,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedCoreL10n.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusSheet),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.s8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.s20,
              AppDimensions.s16,
              AppDimensions.s12,
              AppDimensions.s8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: t.commonClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s20,
              vertical: AppDimensions.s4,
            ),
            child: AppSearchField(
              controller: searchController,
              hintText: t.commonSearchHint,
              onChanged: onQuery,
              onClear: () {
                searchController.clear();
                onQuery('');
              },
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          Expanded(
            child: empty
                ? EmptyState.noMatch(message: t.commonNoResults)
                : ListView(
                    padding: const EdgeInsets.only(bottom: AppDimensions.s24),
                    children: children,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SelectRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.touchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s20,
            vertical: AppDimensions.s12,
          ),
          color: selected ? colors.primary.withValues(alpha: 0.08) : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded, size: 20, color: colors.primary)
              else
                Icon(
                  Icons.radio_button_unchecked,
                  size: 20,
                  color: colors.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Legacy dead UI retained for Phase 08 removal. Kept compiling and tokenized.
class CustomerTagSheet extends StatefulWidget {
  final List<String> selected;
  const CustomerTagSheet({super.key, required this.selected});

  @override
  State<CustomerTagSheet> createState() => _CustomerTagSheetState();
}

class _CustomerTagSheetState extends State<CustomerTagSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select Customer Tag',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(_selected),
                icon: Icon(Icons.close_rounded, color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          ...kCustomerTags.map((tag) {
            final isSelected = _selected.contains(tag.label);
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.s10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: tag.color),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: Text(
                      tag.label,
                      style: TextStyle(
                        color: tag.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(tag.label);
                        } else {
                          _selected.add(tag.label);
                        }
                      });
                    },
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? colors.primary : colors.outline,
                    ),
                  ),
                ),
                const Divider(height: 1),
              ],
            );
          }),
          const SizedBox(height: AppDimensions.s40),
        ],
      ),
    );
  }
}

Future<String?> showModelYearDialog(
  BuildContext context,
  String? current,
) async {
  final t = StaffLocalizations.of(context)!;
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  String? selected = current;
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusDialog),
            ),
            title: Text(
              t.advisorIntakeModelYearHint,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            content: SizedBox(
              width: 280,
              height: 280,
              child: RadioGroup<String>(
                groupValue: selected,
                onChanged: (v) => setState(() => selected = v),
                child: ListView(
                  children: kModelYears.map((y) {
                    return RadioListTile<String>(
                      value: y,
                      activeColor: colors.primary,
                      title: Text(
                        y,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(SharedCoreL10n.of(ctx).commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(selected),
                child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
              ),
            ],
          );
        },
      );
    },
  );
}
