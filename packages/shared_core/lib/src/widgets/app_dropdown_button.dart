import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

class AppDropdownButton extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final Color? dropdownColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  const AppDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
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

    final effectiveBg = backgroundColor ?? colorScheme.surfaceContainerLow;
    final effectiveFg = foregroundColor ?? colorScheme.onSurface;
    final effectiveBorder = borderColor ?? colorScheme.outlineVariant;
    final effectiveDropdownBg = dropdownColor ?? colorScheme.surface;

    final textStyle = textTheme.labelMedium?.copyWith(
      color: effectiveFg,
      fontWeight: FontWeight.w700,
    );

    return Container(
      constraints: const BoxConstraints(minHeight: AppDimensions.touchTarget),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s12),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        border: Border.all(color: effectiveBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: effectiveDropdownBg,
          style: textStyle,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: effectiveFg,
            size: 18,
          ),
          isDense: true,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          onChanged: (v) => onChanged(v ?? value),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: textStyle),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
