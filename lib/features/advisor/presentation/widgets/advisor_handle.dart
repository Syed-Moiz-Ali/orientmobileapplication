import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';

class AdvisorHandle extends StatelessWidget {
  const AdvisorHandle({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(AppDimensions.r2),
      ),
    ),
  );
}
