import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Outlined secondary action for advisor sheets and dialogs.
class AdvisorOutlineAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const AdvisorOutlineAction({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.touchTarget,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.45), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
        ),
        icon: DirectionalIcon(
          icon,
          color: color,
          size: AppDimensions.iconSm,
          mirrorInRtl: DirectionalIcon.isDirectional(icon),
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
