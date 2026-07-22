import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/card_title.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/dual_line_painter.dart';
import 'package:orientmobileapplication/core/widgets/app_card.dart';

class SalesTrendCard extends StatelessWidget {
  final List<SalesTrendPoint> salesData;
  final List<SalesTrendPoint> profitData;
  const SalesTrendCard({
    super.key,
    required this.salesData,
    required this.profitData,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CardTitle('Sales Trend'),
              const Spacer(),
              _chip(
                AppColors.accent,
                AppColors.accent.withValues(alpha: 0.12),
                'Sales',
              ),
              const SizedBox(width: 6),
              _chip(AppColors.success, AppColors.successBg, 'Profit'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: Size.infinite,
              painter: DualLinePainter(
                primaryData: salesData,
                secondaryData: profitData,
                primaryColor: AppColors.accent,
                secondaryColor: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: salesData
                .map(
                  (p) => Text(
                    p.month,
                    style: const TextStyle(
                      color: AppColors.text3,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip(Color color, Color bg, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.r20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
