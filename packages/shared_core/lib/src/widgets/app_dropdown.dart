import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_tokens.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Spec dropdown, phase-1b name `AppDropdown`.
///
/// Named `AppDropdown` (not `AppDropdownButton`) because the legacy
/// `AppDropdownButton` owns the closest name and is off-limits in phase 1.
/// Same rename story as `AppPillButton`.
///
/// Read-only box with the input chrome; tap opens a token-styled modal bottom
/// sheet (surface, top radius 28, drag handle — the full `AppBottomSheet`
/// arrives in 1e; this sheet is intentionally minimal). Option rows are
/// >= 48 dp, show a check on the selected value, and participate in normal
/// focus traversal (Tab/Enter works on desktop/web). Optional `searchable`
/// filters long lists.
///
/// ```dart
/// AppDropdown<String>(
///   label: 'Branch',
///   options: const ['Deira', 'Sharjah'],
///   value: branch,
///   onChanged: setBranch,
/// )
/// ```
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T)? labelOf;
  final String? hint;
  final String? error;
  final bool enabled;
  final bool searchable;
  final IconData? prefixIcon;

  const AppDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labelOf,
    this.hint,
    this.error,
    this.enabled = true,
    this.searchable = false,
    this.prefixIcon,
  });

  String _textOf(T option) => labelOf?.call(option) ?? '$option';

  Future<void> _openSheet(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;
    final tokens = AppTokens.of(context);
    final query = ValueNotifier<String>('');
    final picked = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (searchable)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        filled: true,
                        fillColor: scheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.input),
                          borderSide: BorderSide(color: tokens.inputBorder),
                        ),
                      ),
                      onChanged: (v) => query.value = v,
                    ),
                  ),
                Flexible(
                  child: ValueListenableBuilder<String>(
                    valueListenable: query,
                    builder: (context, q, _) {
                      final visible = q.isEmpty
                          ? options
                          : options
                              .where((o) => _textOf(o)
                                  .toLowerCase()
                                  .contains(q.toLowerCase()))
                              .toList();
                      if (visible.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'No matches — clear the search.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: visible.length,
                        itemBuilder: (context, i) {
                          final option = visible[i];
                          final selected = option == value;
                          return _OptionRow(
                            label: _textOf(option),
                            selected: selected,
                            autofocus: selected,
                            onTap: () => Navigator.of(context).pop(option),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    query.dispose();
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppTokens.of(context);
    final scheme = theme.colorScheme;
    final hasError = error != null && error!.isNotEmpty;
    final display =
        value == null ? (hint ?? 'Select') : _textOf(value as T);

    BorderSide side(double width) {
      if (hasError) return BorderSide(color: scheme.error, width: 1.5);
      return BorderSide(color: tokens.inputBorder, width: width);
    }

    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.labelValueGap),
          Semantics(
            button: true,
            enabled: enabled,
            label: '$label, ${value == null ? 'not selected' : display}',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? () => _openSheet(context) : null,
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.fromBorderSide(side(1)),
                ),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      DirectionalIcon(
                        prefixIcon!,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                        mirrorInRtl:
                            DirectionalIcon.isDirectional(prefixIcon!),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Text(
                        display,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: value == null
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                    DirectionalIcon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                      mirrorInRtl: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Semantics(
                liveRegion: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 16, color: scheme.error),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Single 48 dp option row with a check on the selected value. Focusable so
/// Tab navigation + Enter activation work on desktop/web.
class _OptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final bool autofocus;
  final VoidCallback onTap;

  const _OptionRow({
    required this.label,
    required this.selected,
    required this.autofocus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        autofocus: autofocus,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w400,
                        color: selected
                            ? scheme.primary
                            : scheme.onSurface,
                      ),
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded,
                    size: 20, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
