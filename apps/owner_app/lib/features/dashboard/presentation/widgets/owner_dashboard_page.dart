import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/job_card_register_card.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/kpi_grid.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/quick_actions_row.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/sales_trend_card.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/sales_vs_expenses_card.dart';


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
      return const AppSkeleton.page();
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
            const _OwnerOpsHeader(),
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
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    ],
  );
}

/// Phase 07.1 centralized operations header: the bespoke `HeaderBanner` is
/// deleted — the live/count pills and title now compose [AppPageHeader] +
/// [StatusPill] with identical copy. The two hardcoded `0xFF10B981` accents
/// resolve through the theme (primary + semantic success) instead.
class _OwnerOpsHeader extends ConsumerWidget {
  const _OwnerOpsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final notifier = ref.read(dashboardUiProvider.notifier);
    final kpis = notifier.kpis;

    String activeLabel = '0 Active Jobs';
    String newLabel = '0 Today';
    if (kpis.isNotEmpty) {
      final active = kpis.firstWhere(
        (k) => k.label.toLowerCase().contains('open') ||
            k.label.toLowerCase().contains('active'),
        orElse: () => kpis.first,
      );
      final fresh = kpis.firstWhere(
        (k) => k.label.toLowerCase().contains('new') ||
            k.label.toLowerCase().contains('today'),
        orElse: () => active,
      );
      activeLabel = '${active.value} Active';
      newLabel = '${fresh.value} Today';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPageHeader(
          title: 'Executive Operations Control',
          subtitle:
              'Real-time overview of branch performance, revenue, and active repair pipelines.',
          trailing: Container(
            padding: const EdgeInsets.all(AppDimensions.s8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            ),
            child: Icon(
              Icons.analytics_rounded,
              color: colors.primary,
              size: AppDimensions.iconMd,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.s12),
        Wrap(
          spacing: AppDimensions.s8,
          runSpacing: AppDimensions.s8,
          children: [
            StatusPill(
              label: 'Live Operations',
              showDot: true,
              fg: colors.primary,
              bg: colors.primary.withValues(alpha: 0.10),
            ),
            StatusPill(
              label: activeLabel,
              icon: Icons.directions_car_rounded,
              fg: colors.primary,
              bg: colors.primary.withValues(alpha: 0.10),
            ),
            StatusPill(
              label: newLabel,
              icon: Icons.check_circle_rounded,
              fg: semantic.success.base,
              bg: semantic.success.subtle,
            ),
          ],
        ),
      ],
    );
  }
}
