import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/widgets/gradient_banner.dart';

class HeaderBanner extends StatelessWidget {
  const HeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const GradientBanner(
      title: 'Owner Dashboard',
      pills: [
        GradientBannerPill(icon: Icons.work_outline_rounded, label: '145 Active', accent: AppColors.amber400),
        GradientBannerPill(icon: Icons.check_circle_outline_rounded, label: '23 New', accent: AppColors.cyan),
      ],
      icon: Icons.business_center_rounded,
    );
  }
}
