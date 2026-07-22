import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/bar_chart_painter.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/card_title.dart';
import 'package:orientmobileapplication/core/widgets/app_card.dart';

class SalesVsExpensesCard extends StatelessWidget {
  final List<SalesTrendPoint> salesData;
  final List<SalesTrendPoint> expenseData;
  const SalesVsExpensesCard({
    super.key,
    required this.salesData,
    required this.expenseData,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CardTitle('Sales vs Expenses'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.r20),
                ),
                child: const Text(
                  'This Year',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 160,
            child: CustomPaint(
              size: Size.infinite,
              painter: BarChartPainter(
                salesData: salesData,
                expenseData: expenseData,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _legend(AppColors.accent, 'Sales'),
              const SizedBox(width: 16),
              _legend(AppColors.warning, 'Expenses'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimensions.r3),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(
          color: AppColors.text3,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
