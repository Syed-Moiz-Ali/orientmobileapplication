import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

class AppDropdownButton extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final Color? dropdownColor;

  const AppDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.dropdownColor,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        );

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.r20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: dropdownColor ?? AppColors.navy,
          style: textStyle,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
          isDense: true,
          onChanged: (v) => onChanged(v ?? value),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item, style: textStyle),
          )).toList(),
        ),
      ),
    );
  }
}
