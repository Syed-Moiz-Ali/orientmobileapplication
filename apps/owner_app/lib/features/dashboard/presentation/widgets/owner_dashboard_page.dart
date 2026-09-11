import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/header_banner.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/job_card_register_card.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/kpi_grid.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/quick_actions_row.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/sales_trend_card.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/sales_vs_expenses_card.dart';

import 'package:owner_app/features/common/presentation/owner_shimmer_skeletons.dart';

class OwnerDashboardPage extends ConsumerWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);

    if (state.isLoading) {
      return const OwnerDashboardSkeleton();
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.errorMessage != null) ...[
              MaterialBanner(
                content: Text(state.errorMessage!),
                leading: Icon(
                  Icons.cloud_off_rounded,
                  color: colorScheme.error,
                ),
                actions: [
                  TextButton(
                    onPressed: notifier.refresh,
                    child: const Text('RETRY'),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s16),
            ],
            const HeaderBanner(),
            const SizedBox(height: AppDimensions.s24),
            _sectionLabel('KPI Overview', colorScheme, textTheme),
            const SizedBox(height: AppDimensions.s12),
            KpiGrid(kpis: notifier.kpis),
            const SizedBox(height: AppDimensions.s28),

            _sectionLabel('Job Card Register', colorScheme, textTheme),
            const SizedBox(height: AppDimensions.s12),
            JobCardRegisterCard(items: notifier.registerItems),
            const SizedBox(height: AppDimensions.s28),

            _sectionLabel('Analytics', colorScheme, textTheme),
            const SizedBox(height: AppDimensions.s12),
            AppSplitView(
              primary: SalesTrendCard(
                salesData: notifier.salesTrend,
                profitData: notifier.profitTrend,
              ),
              secondary: SalesVsExpensesCard(
                salesData: notifier.salesTrend,
                expenseData: notifier.expensesTrend,
              ),
            ),
            const SizedBox(height: AppDimensions.s28),

            _sectionLabel('Quick Actions', colorScheme, textTheme),
            const SizedBox(height: AppDimensions.s12),
            const QuickActionsRow(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) => Row(
    children: [
      Container(
        width: 4,
        height: 20,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(AppDimensions.r2),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        text,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurface,
        ),
      ),
    ],
  );
}
