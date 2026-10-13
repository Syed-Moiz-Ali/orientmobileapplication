import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Centered "see all" action at the bottom of a bounded advisor list section.
class AdvisorSeeAllButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const AdvisorSeeAllButton(this.label, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(AppDimensions.touchTarget),
        foregroundColor: colors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s6),
          DirectionalIcon(
            Icons.arrow_forward_rounded,
            color: colors.primary,
            size: AppDimensions.iconSm,
          ),
        ],
      ),
    );
  }
}
