import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/app_bottom_sheet.dart';
import 'package:shared_core/src/widgets/app_search_field.dart';

/// One entry in an [AppSelectionSheet].
class AppSelectionOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool enabled;

  const AppSelectionOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });
}

/// Searchable single-select sheet used by dropdowns with many options (brand /
/// model pickers, technician pickers, message recipients) as well as any
/// "choose one" flow.
///
/// - Renders a bottom sheet on compact widths and a bounded centered dialog on
///   ≥600 px (via [showAppModalSheet]).
/// - Search field appears when there are more than [searchThreshold] options.
/// - Localized "no matches" empty state.
/// - Pops with the selected value (or `null` when dismissed); already-selected
///   option shows a check mark and `Semantics(selected: true)`.
class AppSelectionSheet<T> extends StatefulWidget {
  final List<AppSelectionOption<T>> options;
  final T? selected;
  final String? title;
  final String? searchHint;
  final bool searchable;
  final int searchThreshold;

  const AppSelectionSheet({
    super.key,
    required this.options,
    this.selected,
    this.title,
    this.searchHint,
    this.searchable = true,
    this.searchThreshold = 8,
  });

  @override
  State<AppSelectionSheet<T>> createState() => _AppSelectionSheetState<T>();
}

class _AppSelectionSheetState<T> extends State<AppSelectionSheet<T>> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  bool get _showSearch =>
      widget.searchable && widget.options.length > widget.searchThreshold;

  List<AppSelectionOption<T>> get _filtered {
    if (_query.trim().isEmpty) return widget.options;
    final q = _query.toLowerCase();
    return widget.options
        .where(
          (o) =>
              o.label.toLowerCase().contains(q) ||
              (o.subtitle?.toLowerCase().contains(q) ?? false),
        )
        .toList(growable: false);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = SharedCoreL10n.of(context);
    final options = _filtered;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s20,
                  0,
                  AppDimensions.s20,
                  AppDimensions.s12,
                ),
                child: AppSearchField(
                  controller: _search,
                  hintText: widget.searchHint ?? t.commonSearchHint,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () => setState(() => _query = ''),
                ),
              ),
            Flexible(
              child: options.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppDimensions.s32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 32,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(height: AppDimensions.s12),
                          Text(
                            t.commonNoResults,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.s4,
                      ),
                      itemCount: options.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: colors.outline),
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isSelected = option.value == widget.selected;
                        return _SelectionRow(
                          option: option,
                          selected: isSelected,
                          onTap: option.enabled
                              ? () => Navigator.of(context).pop(option.value)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionRow<T> extends StatelessWidget {
  final AppSelectionOption<T> option;
  final bool selected;
  final VoidCallback? onTap;

  const _SelectionRow({
    required this.option,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = onTap != null;
    final labelColor = enabled
        ? colors.onSurface
        : colors.onSurfaceVariant.withValues(alpha: 0.5);

    return Semantics(
      selected: selected,
      button: true,
      enabled: enabled,
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
              if (option.icon != null) ...[
                Icon(
                  option.icon,
                  size: AppDimensions.iconMd,
                  color: enabled ? colors.onSurfaceVariant : labelColor,
                ),
                const SizedBox(width: AppDimensions.s12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: labelColor,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: AppDimensions.s8),
                Icon(
                  Icons.check_rounded,
                  size: AppDimensions.iconMd,
                  color: colors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens an [AppSelectionSheet] on the shared modal surface (bottom sheet on
/// compact, bounded dialog ≥600 px) and returns the chosen value.
Future<T?> showAppSelectionSheet<T>({
  required BuildContext context,
  required List<AppSelectionOption<T>> options,
  T? selected,
  String? title,
  String? searchHint,
  bool searchable = true,
  bool isDismissible = true,
}) {
  final t = SharedCoreL10n.of(context);
  return showAppModalSheet<T>(
    context: context,
    title: title ?? t.commonSelect,
    isDismissible: isDismissible,
    builder: (_) => AppSelectionSheet<T>(
      options: options,
      selected: selected,
      title: title,
      searchHint: searchHint,
      searchable: searchable,
    ),
  );
}
