import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const SectionCard({super.key, required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.s16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r18),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(color: colors.shadow.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.s16, vertical: AppDimensions.s12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.r2),
                  ),
                ),
                SizedBox(width: AppDimensions.s10),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.r8),
                  ),
                  child: Icon(icon, color: colors.primary, size: 15),
                ),
                SizedBox(width: AppDimensions.s10),
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(AppDimensions.s16), child: child),
        ],
      ),
    );
  }
}
