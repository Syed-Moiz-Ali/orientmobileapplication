import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';

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
    return Container(
      height: 32,
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
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
          isDense: true,
          onChanged: (v) => onChanged(v ?? value),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          )).toList(),
        ),
      ),
    );
  }
}
