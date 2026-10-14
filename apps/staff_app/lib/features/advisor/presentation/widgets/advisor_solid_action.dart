import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Solid primary action for advisor sheets and dialogs. The [color] drives the
/// fill and a subtle elevation; the label uses the inverse ink token.
class AdvisorSolidAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const AdvisorSolidAction({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Ink on a saturated status fill resolves from the active theme.
    final ink = context.semanticColors.onPrimary;
    return SizedBox(
      height: AppDimensions.touchTarget,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DirectionalIcon(
                icon,
                color: ink,
                size: AppDimensions.iconSm,
                mirrorInRtl: DirectionalIcon.isDirectional(icon),
              ),
              const SizedBox(width: AppDimensions.s8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
