import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/features/supervisor/domain/entities/supervisor_entities.dart';

class SupervisorStatCard extends StatelessWidget {
  final SupervisorKpiEntity kpi;
  const SupervisorStatCard({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kpi.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                ),
                child: Icon(kpi.icon, color: kpi.color, size: 22),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(AppDimensions.r7),
                ),
                child: Text(
                  kpi.sub,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            kpi.value,
            style: AppTextStyles.orbitronDisplaySmall(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            kpi.label,
            style: AppTextStyles.rajdhaniBodySmall(color: AppColors.text3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
