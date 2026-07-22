import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/header_banner.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/job_card_register_card.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/kpi_grid.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/quick_actions_row.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/sales_trend_card.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/sales_vs_expenses_card.dart';

class OwnerDashboardPage extends ConsumerWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2.5,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      color: AppColors.accent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('KPI Overview'),
                  const SizedBox(height: 12),
                  KpiGrid(kpis: notifier.kpis),
                  const SizedBox(height: 26),

                  _sectionLabel('Job Card Register'),
                  const SizedBox(height: 12),
                  JobCardRegisterCard(items: notifier.registerItems),
                  const SizedBox(height: 26),

                  _sectionLabel('Analytics'),
                  const SizedBox(height: 12),
                  SalesTrendCard(
                    salesData: notifier.salesTrend,
                    profitData: notifier.profitTrend,
                  ),
                  const SizedBox(height: 12),
                  SalesVsExpensesCard(
                    salesData: notifier.salesTrend,
                    expenseData: notifier.expensesTrend,
                  ),
                  const SizedBox(height: 26),

                  _sectionLabel('Quick Actions'),
                  const SizedBox(height: 12),
                  const QuickActionsRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Row(
    children: [
      Container(
        width: 4,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppDimensions.r2),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        text,
        style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
      ),
    ],
  );
}
