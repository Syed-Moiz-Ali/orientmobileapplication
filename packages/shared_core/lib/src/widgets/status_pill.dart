import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

class StatusPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const StatusPill({
    super.key,
    required this.label,
    this.bg = AppColors.primaryBg,
    this.fg = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s10,
        vertical: AppDimensions.s4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.rPill),
      ),
      child: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
