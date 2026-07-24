import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

class GradientBanner extends StatelessWidget {
  final String title;
  final String greeting;
  final String? liveLabel;
  final Color? liveDotColor;
  final List<GradientBannerPill> pills;
  final IconData? icon;
  final LinearGradient gradient;

  const GradientBanner({
    super.key,
    required this.title,
    this.greeting = 'Good Morning,',
    this.liveLabel = 'Live',
    this.liveDotColor,
    this.pills = const [],
    this.icon,
    this.gradient = const LinearGradient(
      colors: [AppColors.navy, AppColors.accent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6, top: 1),
                      decoration: BoxDecoration(
                        color: liveDotColor ?? AppColors.cyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      liveLabel ?? '',
                      style: TextStyle(
                        color: liveDotColor ?? AppColors.cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  greeting,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
                if (pills.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: pills
                        .map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _pill(p.icon, p.label, p.accent),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (icon != null)
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.r22),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
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
