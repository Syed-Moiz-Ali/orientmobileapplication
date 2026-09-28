import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

/// Clean linear progress bar with optional label and percentage.
class AppLinearProgress extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final String? label;
  final bool showPercentage;
  final Color? color;
  final double height;

  const AppLinearProgress({
    super.key,
    required this.value,
    this.label,
    this.showPercentage = false,
    this.color,
    this.height = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final progressColor = color ?? theme.colorScheme.primary;
    final clampedValue = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              if (showPercentage)
                Text(
                  '${(clampedValue * 100).round()}%',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: progressColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.s6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          child: LinearProgressIndicator(
            value: clampedValue,
            minHeight: height,
            backgroundColor: AppColors.borderDefault,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}

/// Definition of an individual workflow or process step.
class AppProgressStep {
  final String label;
  final String? subtitle;
  final IconData? icon;

  const AppProgressStep({
    required this.label,
    this.subtitle,
    this.icon,
  });
}

/// Step-by-step numbered/icon progress indicator (completed, active, upcoming).
class AppStepProgress extends StatelessWidget {
  final List<AppProgressStep> steps;
  final int currentStep; // 0-indexed

  const AppStepProgress({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Left connector line
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == 0
                            ? Colors.transparent
                            : (i <= currentStep
                                ? colors.primary
                                : AppColors.borderDefault),
                      ),
                    ),
                    // Step bubble
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < currentStep
                            ? AppColors.success
                            : (i == currentStep
                                ? colors.primary
                                : colors.surface),
                        border: Border.all(
                          color: i < currentStep
                              ? AppColors.success
                              : (i == currentStep
                                  ? colors.primary
                                  : AppColors.borderStrong),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: i < currentStep
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: i == currentStep
                                      ? Colors.white
                                      : colors.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    // Right connector line
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == steps.length - 1
                            ? Colors.transparent
                            : (i < currentStep
                                ? colors.primary
                                : AppColors.borderDefault),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s6),
                Text(
                  steps[i].label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: i == currentStep
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: i == currentStep
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
