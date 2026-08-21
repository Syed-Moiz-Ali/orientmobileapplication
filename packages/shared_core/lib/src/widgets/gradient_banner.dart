import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/status_pill.dart';

/// A legacy-named contextual header retained for API compatibility. Its default
/// treatment is now a calm operational surface; gradients are opt-in only.
class GradientBanner extends StatelessWidget {
  final String title;
  final String greeting;
  final String? liveLabel;
  final Color? liveDotColor;
  final List<GradientBannerPill> pills;
  final IconData? icon;
  final LinearGradient? gradient;

  const GradientBanner({
    super.key,
    required this.title,
    this.greeting = 'Good morning',
    this.liveLabel = 'Live',
    this.liveDotColor,
    this.pills = const [],
    this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final onSurface = gradient == null ? colors.onSurface : colors.onPrimary;
    final secondary = gradient == null
        ? colors.onSurfaceVariant
        : colors.onPrimary.withValues(alpha: 0.78);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s20),
      decoration: BoxDecoration(
        color: gradient == null ? colors.surface : null,
        gradient: gradient,
        border: Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (liveLabel != null) ...[
                  StatusPill(
                    label: liveLabel!,
                    fg: liveDotColor ?? colors.primary,
                    bg: (liveDotColor ?? colors.primary).withValues(
                      alpha: 0.10,
                    ),
                    showDot: true,
                  ),
                  const SizedBox(height: AppDimensions.s12),
                ],
                Text(
                  greeting,
                  style: theme.textTheme.bodyMedium?.copyWith(color: secondary),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: onSurface,
                  ),
                ),
                if (pills.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.s14),
                  Wrap(
                    spacing: AppDimensions.s8,
                    runSpacing: AppDimensions.s8,
                    children: pills
                        .map(
                          (pill) => StatusPill(
                            label: pill.label,
                            icon: pill.icon,
                            fg: pill.accent,
                            bg: pill.accent.withValues(alpha: 0.10),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: AppDimensions.s16),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              ),
              child: Icon(icon, color: colors.primary, size: 26),
            ),
          ],
        ],
      ),
    );
  }
}

class GradientBannerPill {
  final IconData icon;
  final String label;
  final Color accent;

  const GradientBannerPill({
    required this.icon,
    required this.label,
    required this.accent,
  });
}
