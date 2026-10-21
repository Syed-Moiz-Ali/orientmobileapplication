import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_modal_sheet.dart';
import 'package:shared_core/src/widgets/app_search_bar.dart';
import 'package:shared_core/src/widgets/app_tile_row.dart';

/// One selectable row inside an [AppSheetPicker] (phase-1P).
class AppSheetPickerOption {
  final IconData? leadingIcon;
  final bool accentLeading;
  final String title;
  final String? subtitle;

  /// Renders the row with an accent check cue + selected Semantics.
  final bool selected;

  const AppSheetPickerOption({
    this.leadingIcon,
    this.accentLeading = false,
    required this.title,
    this.subtitle,
    this.selected = false,
  });
}

/// C16 filter/picker bottom sheet (phase-1P).
///
/// Modal bottom sheet with a drag handle (via [AppBottomSheet] /
/// [showAppBottomSheet]: drag-to-dismiss, scrim, 90% max height), an
/// optional search field, option rows, and a sticky "Show N results"
/// primary button pinned below the scroll area (never scrolls away).
///
/// ```dart
/// showAppSheetPicker<void>(
///   context,
///   title: 'Filter by status',
///   searchHint: 'Search statuses',
///   options: statuses.map((s) => AppSheetPickerOption(title: s)).toList(),
///   resultCount: 12,
///   onSelected: (i) => setState(() => picked = i),
///   onShowResults: () => Navigator.of(context).pop(applyFilters()),
/// )
/// ```
///
/// - Chrome reuses [AppBottomSheet] (handle, padding, pinned CTA); search
///   reuses [AppSearchBar]; rows reuse [AppTileRow] + [buildTileLeading].
/// - [resultCount] is caller-controlled (e.g. total matches behind the
///   current filter); the button label is `resultsLabelBuilder(count)`.
/// - Search filters rows locally by title; option titles are caller text.
/// - Whole rows are >= 48 dp (min height 56); selected rows expose
///   selected Semantics + an accent check cue (never color alone).
/// - 1.3x-safe: rows wrap; the CTA stays pinned via [AppBottomSheet].
class AppSheetPicker extends StatelessWidget {
  final String? title;
  final String? searchHint;
  final List<AppSheetPickerOption> options;
  final ValueChanged<int>? onSelected;

  /// Total behind the filter; shown in the sticky primary button.
  final int resultCount;

  /// Builds the sticky button label. Defaults to `Show <n> results`.
  final String Function(int count)? resultsLabelBuilder;

  final VoidCallback? onShowResults;
  final String? semanticLabel;

  const AppSheetPicker({
    super.key,
    this.title,
    this.searchHint,
    required this.options,
    this.onSelected,
    required this.resultCount,
    this.resultsLabelBuilder,
    this.onShowResults,
    this.semanticLabel,
  });

  String get _resultsLabel =>
      resultsLabelBuilder?.call(resultCount) ?? 'Show $resultCount results';

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: title,
      primaryLabel: _resultsLabel,
      onPrimary: onShowResults,
      semanticLabel: semanticLabel,
      child: _PickerContent(
        searchHint: searchHint,
        options: options,
        onSelected: onSelected,
      ),
    );
  }
}

/// Presents an [AppSheetPicker] as a scrimmed modal route (phase-1P).
///
/// [onShowResults] never pops by itself — pop from the caller so validation
/// can keep the sheet open (same contract as [showAppBottomSheet]).
Future<T?> showAppSheetPicker<T>(
  BuildContext context, {
  String? title,
  String? searchHint,
  required List<AppSheetPickerOption> options,
  ValueChanged<int>? onSelected,
  required int resultCount,
  String Function(int count)? resultsLabelBuilder,
  VoidCallback? onShowResults,
  String? semanticLabel,
  bool isDismissible = true,
}) {
  final label =
      resultsLabelBuilder?.call(resultCount) ?? 'Show $resultCount results';
  return showAppBottomSheet<T>(
    context,
    title: title,
    primaryLabel: label,
    onPrimary: onShowResults,
    semanticLabel: semanticLabel,
    isDismissible: isDismissible,
    child: _PickerContent(
      searchHint: searchHint,
      options: options,
      onSelected: onSelected,
    ),
  );
}

/// Search field + option rows shared by [AppSheetPicker] and
/// [showAppSheetPicker] so both stay identical.
class _PickerContent extends StatefulWidget {
  final String? searchHint;
  final List<AppSheetPickerOption> options;
  final ValueChanged<int>? onSelected;

  const _PickerContent({
    this.searchHint,
    required this.options,
    this.onSelected,
  });

  @override
  State<_PickerContent> createState() => _PickerContentState();
}

class _PickerContentState extends State<_PickerContent> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final matches = <int>[];
    for (var i = 0; i < widget.options.length; i++) {
      if (_filter.isEmpty ||
          widget.options[i].title
              .toLowerCase()
              .contains(_filter.toLowerCase())) {
        matches.add(i);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.searchHint != null) ...[
          AppSearchBar(
            hint: widget.searchHint,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: matches.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: scheme.outline),
            itemBuilder: (context, k) {
              final i = matches[k];
              final option = widget.options[i];
              final onTap = widget.onSelected == null
                  ? null
                  : () => widget.onSelected!(i);
              final row = AppTileRow(
                leading: buildTileLeading(
                  context: context,
                  icon: option.leadingIcon,
                  accent: option.accentLeading,
                ),
                title: option.title,
                subtitle: option.subtitle,
                trailing: option.selected
                    ? Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: scheme.primary,
                      )
                    : null,
              );
              if (onTap == null) return row;
              return Semantics(
                button: true,
                enabled: true,
                selected: option.selected,
                label: option.title,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onTap, child: row),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
