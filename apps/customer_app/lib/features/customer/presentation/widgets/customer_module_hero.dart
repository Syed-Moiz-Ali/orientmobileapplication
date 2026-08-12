import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class CustomerModuleHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String metricLabel;
  final String metricValue;
  final Color accent;
  final Widget? action;

  const CustomerModuleHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.metricLabel,
    required this.metricValue,
    required this.accent,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final adaptive = context.adaptive;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        adaptive.pick(
          compact: AppDimensions.s18,
          medium: AppDimensions.s24,
          expanded: AppDimensions.s24,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r18),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -18,
            child: Icon(
              icon,
              size: adaptive.pick(compact: 92.0, medium: 116.0),
              color: accent.withValues(alpha: 0.08),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppDimensions.r14),
                      ),
                      child: Icon(icon, color: accent),
                    ),
                    const SizedBox(height: AppDimensions.s16),
                    Text(
                      title,
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Text(
                        subtitle,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.text3,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (action != null) ...[
                      const SizedBox(height: AppDimensions.s16),
                      action!,
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s14,
                  vertical: AppDimensions.s12,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimensions.r14),
                  border: Border.all(color: accent.withValues(alpha: 0.16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      metricValue,
                      style: textTheme.headlineSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      metricLabel,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.text3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
