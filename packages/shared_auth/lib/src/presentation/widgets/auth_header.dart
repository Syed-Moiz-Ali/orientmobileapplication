import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AuthHeader extends StatelessWidget {
  final BrandConfig brand;
  final String title;
  final String subtitle;
  final IconData? customIcon;

  const AuthHeader({
    super.key,
    required this.brand,
    required this.title,
    required this.subtitle,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconData = customIcon ?? brand.icon;
    final accentColor = brand.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            iconData,
            color: accentColor,
            size: 22,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : AppColors.text3,
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
