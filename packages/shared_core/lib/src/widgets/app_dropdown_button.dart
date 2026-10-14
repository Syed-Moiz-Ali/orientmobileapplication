import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_interaction_states.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/app_selection_sheet.dart';

/// Compact inline dropdown (menu-based) for short option sets (≤8 options).
///
/// For larger or searchable option sets (brand/model pickers, technician
/// pickers, recipients) use [AppSelectField], which routes through the shared
/// searchable selection sheet.
///
/// The control is 52 px tall, uses the input radius and keeps a visible focus
/// ring; it mirrors alignment in RTL.
class AppDropdownButton extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? hint;

  /// When false the control is shown in its disabled treatment.
  final bool enabled;
  final bool isExpanded;
  final Color? dropdownColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  const AppDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.enabled = true,
    this.isExpanded = true,
    this.dropdownColor,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveBg =
        backgroundColor ?? context.semanticColors.surfaceSunken;
    final effectiveFg = enabled
        ? (foregroundColor ?? colorScheme.onSurface)
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    final effectiveBorder = borderColor ?? colorScheme.outline;
    final effectiveDropdownBg = dropdownColor ?? colorScheme.surface;

    final textStyle = textTheme.bodyLarge?.copyWith(
      color: effectiveFg,
      fontWeight: FontWeight.w600,
    );

    final control = Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s12),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        border: Border.all(color: effectiveBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: hint != null
              ? Text(
                  hint!,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          dropdownColor: effectiveDropdownBg,
          style: textStyle,
          isExpanded: isExpanded,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: effectiveFg,
            size: 20,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          onChanged: enabled ? (v) => onChanged(v ?? value) : null,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );

    final themed = Focus(canRequestFocus: false, child: control);

    if (label == null) return themed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label!,
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.s6),
        themed,
      ],
    );
  }
}

/// Field-style single-select that opens the shared searchable selection sheet.
///
/// Use this instead of [AppDropdownButton] whenever the option list is long or
/// benefits from search (spec §7: selection sheets get a title + search when
/// there are more than 8 options). The trigger mirrors in RTL and shows the
/// selected option's label or the placeholder [hint].
class AppSelectField<T> extends StatelessWidget {
  final List<AppSelectionOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String? label;
  final String? hint;
  final String? sheetTitle;
  final String? searchHint;
  final IconData? leadingIcon;
  final bool enabled;
  final int searchThreshold;

  const AppSelectField({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.sheetTitle,
    this.searchHint,
    this.leadingIcon,
    this.enabled = true,
    this.searchThreshold = 8,
  });

  String? get _selectedLabel {
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedLabel = _selectedLabel;
    final hasValue = selectedLabel != null;

    final control = InkWell(
      onTap: enabled
          ? () async {
              final result = await showAppSelectionSheet<T>(
                context: context,
                options: options,
                selected: value,
                title: sheetTitle ?? label,
                searchHint: searchHint,
              );
              if (result != null) onChanged(result);
            }
          : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
      overlayColor: AppInteractionStates.overlays(
        colors.surface,
        colors.onSurface,
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s16,
          vertical: AppDimensions.s12,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? context.semanticColors.surfaceSunken
              : colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(
            color: enabled
                ? context.semanticColors.borderDefault
                : colors.outline,
          ),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: AppDimensions.iconMd,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.s12),
            ],
            Expanded(
              child: Text(
                hasValue ? selectedLabel : (hint ?? ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: enabled
                      ? (hasValue
                            ? colors.onSurface
                            : colors.onSurfaceVariant.withValues(alpha: 0.7))
                      : colors.onSurfaceVariant.withValues(alpha: 0.5),
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );

    if (label == null) return control;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label!,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.s6),
        control,
      ],
    );
  }
}
