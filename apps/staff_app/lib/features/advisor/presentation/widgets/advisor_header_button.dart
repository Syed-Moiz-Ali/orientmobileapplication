import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AdvisorHeaderButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isPrimary;
  final VoidCallback onTap;
  const AdvisorHeaderButton({
    super.key,
    required this.label,
    this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isPrimary ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.r14),
          border: isPrimary ? null : Border.all(color: colors.outlineVariant),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isPrimary ? colors.onPrimary : colors.primary,
                  size: 15,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTextStyles.button(
                  color: isPrimary ? colors.onPrimary : colors.primary,
                ).copyWith(fontSize: 14, letterSpacing: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
