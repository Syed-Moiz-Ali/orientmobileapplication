import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/core/router/app_router.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Presentation-only derivation over the frozen adapter figures.
/// Labels/values stay exactly as the server returned them; only the *choice*
/// of which KPI fronts the hero/pods is made here. Nothing is parsed into
/// money, averaged, or converted — display-only, unit-covered by widget tests.
OwnerKpi? _findKpi(List<OwnerKpi> kpis, List<String> keys) {
  for (final key in keys) {
    for (final kpi in kpis) {
      if (kpi.label.toLowerCase().contains(key)) return kpi;
    }
  }
  return null;
}

/// Display-only trend guess from a server delta line (`+2.1% Ahead`,
/// `-3.0% Behind`). The text itself always renders verbatim; this only picks
/// the badge polarity. Unknown shapes default up (never a red accusation
/// without a minus sign).
TelemetryTrend _trendOf(String sub) =>
    sub.trim().startsWith('-') ? TelemetryTrend.down : TelemetryTrend.up;

/// Executive cockpit (O1, Archetype 8): revenue hero → micro-pods → telemetry
/// curves → job register → quick actions. Every figure is a frozen adapter
/// value rendered verbatim; missing series render placeholders, never zeros
/// dressed as data. Desktop is a 3-column panoramic console (never a
/// stretched phone); compact stacks with swipeable chart pages.
class OwnerDashboardPage extends ConsumerWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);

    final kpis = notifier.kpis;
    final sales = notifier.salesTrend;
    final profit = notifier.profitTrend;
    final expenses = notifier.expensesTrend;
    final register = notifier.registerItems;
    final hasAnyData = kpis.isNotEmpty ||
        sales.isNotEmpty ||
        profit.isNotEmpty ||
        expenses.isNotEmpty ||
        register.isNotEmpty;

    if (state.isLoading && !hasAnyData) {
      return const AppSkeleton.page();
    }

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );
    final medium = context.adaptive.pick(
      compact: false,
      medium: true,
      expanded: true,
      large: true,
    );

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
              ErrorView(
                message: state.errorMessage!,
                onRetry: notifier.refresh,
              ),
              const SizedBox(height: AppDimensions.s16),
            ],
            const _CockpitHeader(),
            const SizedBox(height: AppDimensions.s20),
            _RevenueHero(kpis: kpis),
            const SizedBox(height: AppDimensions.s20),
            _MicroPods(kpis: kpis),
            const SizedBox(height: AppDimensions.s24),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RevenueCurve(sales: sales, profit: profit),
                        const SizedBox(height: AppDimensions.s20),
                        _CostCurve(profit: profit, expenses: expenses),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s24),
                  Expanded(
                    flex: 4,
                    child: _JobRegister(items: register),
                  ),
                  const SizedBox(width: AppDimensions.s24),
                  Expanded(
                    flex: 3,
                    child: _QuickActions(narrow: true),
                  ),
                ],
              )
            else if (medium) ...[
              AppSplitView(
                primary: _RevenueCurve(sales: sales, profit: profit),
                secondary: _CostCurve(profit: profit, expenses: expenses),
              ),
              const SizedBox(height: AppDimensions.s24),
              _JobRegister(items: register),
              const SizedBox(height: AppDimensions.s24),
              const _QuickActions(narrow: false),
            ] else ...[
              _SwipeCharts(
                sales: sales,
                profit: profit,
                expenses: expenses,
              ),
              const SizedBox(height: AppDimensions.s24),
              _JobRegister(items: register),
              const SizedBox(height: AppDimensions.s24),
              const _QuickActions(narrow: false),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

/// Cockpit wayfinding: title + live/count pills derived from the real KPI
/// list (same faces as the 07.1 header, now localized).
class _CockpitHeader extends ConsumerWidget {
  const _CockpitHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final kpis = ref.read(dashboardUiProvider.notifier).kpis;

    final active =
        _findKpi(kpis, ['open', 'active']) ?? (kpis.isEmpty ? null : kpis.first);
    final fresh = _findKpi(kpis, ['new', 'today']) ?? active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPageHeader(
          title: t.ownerOpsTitle,
          subtitle: t.ownerOpsSubtitle,
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
              label: t.ownerPillLive,
              showDot: true,
              fg: colors.primary,
              bg: colors.primary.withValues(alpha: 0.10),
            ),
            if (active != null)
              StatusPill(
                label: t.ownerPillActive(active.value),
                icon: Icons.directions_car_rounded,
                fg: colors.primary,
                bg: colors.primary.withValues(alpha: 0.10),
              ),
            if (fresh != null)
              StatusPill(
                label: t.ownerPillToday(fresh.value),
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

/// Revenue ticker hero: the revenue KPI (or the first KPI when the server
/// does not label one) as a hero pod with its verbatim delta line. No
/// revenue KPI on record renders an explicit empty state — never a zero.
class _RevenueHero extends StatelessWidget {
  final List<OwnerKpi> kpis;

  const _RevenueHero({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final hero = _findKpi(kpis, ['revenue', 'sales', 'turnover']) ??
        (kpis.isEmpty ? null : kpis.first);

    if (hero == null) {
      return EmptyState(
        icon: Icons.payments_outlined,
        message: t.ownerHeroEmpty,
      );
    }
    final delta = hero.sub.trim().isEmpty ? null : hero.sub.trim();
    // Server values stay verbatim; the LTR lock keeps `AED 84K`-style figures
    // reading correctly inside RTL layouts.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TelemetryMetricPod(
        isHero: true,
        label: hero.label,
        value: hero.value,
        deltaLabel: delta,
        trend: delta == null ? TelemetryTrend.flat : _trendOf(delta),
        icon: hero.icon,
      ),
    );
  }
}

/// Operational micro-pods: margin, occupancy and approvals WIP — each shown
/// only when a matching KPI actually exists. A missing family is omitted,
/// never zero-filled.
class _MicroPods extends StatelessWidget {
  final List<OwnerKpi> kpis;

  const _MicroPods({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final pods = <OwnerKpi>[
      ?_findKpi(kpis, ['margin']),
      ?_findKpi(kpis, ['occupancy', 'occupan', 'bay']),
      ?_findKpi(kpis, ['approval']),
    ];
    if (pods.isEmpty) return const SizedBox.shrink();

    final adaptive = context.adaptive;
    return AppAdaptiveGrid(
      columns: adaptive.pick(
        compact: pods.length == 1 ? 1 : 2,
        medium: pods.length,
        expanded: pods.length,
        large: pods.length,
      ),
      minChildWidth: adaptive.isCompact ? 160 : 200,
      spacing: adaptive.itemSpacing,
      runSpacing: adaptive.itemSpacing,
      children: [
        for (final pod in pods)
          Directionality(
            textDirection: TextDirection.ltr,
            // The delta badge already renders the verbatim sub-line; a
            // supporting twin would double the row and squeeze 320px cells.
            child: TelemetryMetricPod(
              label: pod.label,
              value: pod.value,
              deltaLabel:
                  pod.sub.trim().isEmpty ? null : pod.sub.trim(),
              trend: pod.sub.trim().isEmpty
                  ? TelemetryTrend.flat
                  : _trendOf(pod.sub),
              icon: pod.icon,
            ),
          ),
      ],
    );
  }
}

/// Shared curve-card chrome: section header, legend in chart-palette order
/// (mirrored in RTL by the theme), the sparkline itself, and a first/last
/// month rule. Empty series render the chart placeholder — never a blank.
class _CurveCard extends StatelessWidget {
  final String title;
  final List<String> legendLabels;
  final List<List<double>> series;
  final List<String> months;
  final String emptyMessage;

  const _CurveCard({
    required this.title,
    required this.legendLabels,
    required this.series,
    required this.months,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final chart = AppChartTheme.of(context);
    final palette = chart.orderedPalette(legendLabels.length);

    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            padding: const EdgeInsets.only(bottom: AppDimensions.s12),
          ),
          Wrap(
            spacing: AppDimensions.s16,
            runSpacing: AppDimensions.s6,
            children: [
              for (var i = 0; i < legendLabels.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: palette[i],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s6),
                    Text(
                      legendLabels[i],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          SparklineChart(
            series: [
              for (var i = 0; i < series.length; i++)
                SparklineSeries(series[i], color: palette[i]),
            ],
            height: 150,
            emptyMessage: emptyMessage,
          ),
          if (months.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  months.first,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (months.length > 1)
                  Text(
                    months.last,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RevenueCurve extends StatelessWidget {
  final List<SalesTrendPoint> sales;
  final List<SalesTrendPoint> profit;

  const _RevenueCurve({required this.sales, required this.profit});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final months = [for (final p in sales) p.month];
    return _CurveCard(
      title: t.ownerChartSalesProfit,
      legendLabels: [t.ownerChartSales, t.ownerChartProfit],
      series: [
        [for (final p in sales) p.value],
        [for (final p in profit) p.value],
      ],
      months: months,
      emptyMessage: t.ownerChartEmpty,
    );
  }
}

class _CostCurve extends StatelessWidget {
  final List<SalesTrendPoint> profit;
  final List<SalesTrendPoint> expenses;

  const _CostCurve({required this.profit, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    // No target series exists on any endpoint, so the second curve watches
    // cost instead of inventing a target line: profit against expenses.
    final months = [
      for (final p in expenses.isNotEmpty ? expenses : profit) p.month,
    ];
    return _CurveCard(
      title: t.ownerChartCost,
      legendLabels: [t.ownerChartProfit, t.ownerChartExpenses],
      series: [
        [for (final p in profit) p.value],
        [for (final p in expenses) p.value],
      ],
      months: months,
      emptyMessage: t.ownerChartEmpty,
    );
  }
}

/// Compact-only swipeable charts: the two curves as pages with dots. Wider
/// viewports use the split/3-column layouts above instead.
class _SwipeCharts extends StatefulWidget {
  final List<SalesTrendPoint> sales;
  final List<SalesTrendPoint> profit;
  final List<SalesTrendPoint> expenses;

  const _SwipeCharts({
    required this.sales,
    required this.profit,
    required this.expenses,
  });

  @override
  State<_SwipeCharts> createState() => _SwipeChartsState();
}

class _SwipeChartsState extends State<_SwipeCharts> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          // 320px @1.3x wraps the legend to two lines; the fixed height
          // covers both densities without clipping.
          height: 320,
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              _RevenueCurve(sales: widget.sales, profit: widget.profit),
              _CostCurve(profit: widget.profit, expenses: widget.expenses),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s10),
        Semantics(
          label: 'Page ${_page + 1} of 2',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 2; i++)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s4,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page
                        ? colors.primary
                        : colors.outlineVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Job register: dense sortable-feel table on desktop (sticky-ready AppTable
/// with a compact record-row fallback on phones), tapping a row opens the
/// real register. Empty renders the table empty state, never blank space.
class _JobRegister extends StatelessWidget {
  final List<JobCardRegisterItem> items;

  const _JobRegister({required this.items});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final formatters = AppFormatters.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: t.ownerRegisterTitle,
          trailing: TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              context.push(AppRoutes.jobCards);
            },
            child: Text(t.ownerRegisterAll),
          ),
        ),
        AppTable<JobCardRegisterItem>(
          columns: [
            AppTableColumn(label: t.ownerRegisterCategory, flex: 3),
            AppTableColumn(label: t.ownerRegisterOpen, flex: 2),
            AppTableColumn(label: t.ownerRegisterTotal, flex: 2),
          ],
          items: items,
          cells: (context, item) => [
            AppTableCell.text(context, item.label),
            AppTableCell.numeric(context, formatters.group(item.open)),
            AppTableCell.numeric(context, formatters.group(item.total)),
          ],
          onRowTap: (item) {
            HapticFeedback.selectionClick();
            context.push(AppRoutes.jobCards);
          },
          emptyMessage: t.ownerRegisterEmpty,
          compactBuilder: (context, item) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.s8),
            child: AppRecordRow(
              title: item.label,
              metadata: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${t.ownerRegisterOpen}: ${formatters.group(item.open)} · '
                  '${t.ownerRegisterTotal}: ${formatters.group(item.total)}',
                  style: AppTextStyles.mono(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              onTap: () {
                HapticFeedback.selectionClick();
                context.push(AppRoutes.jobCards);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionDef {
  final IconData icon;
  final String label;
  final String hint;
  final void Function(BuildContext, DashboardUiNotifier) run;

  const _ActionDef({
    required this.icon,
    required this.label,
    required this.hint,
    required this.run,
  });
}

/// Quick actions: the twelve real destinations as shared record rows in an
/// adaptive grid. Accent hexes are gone — every tile resolves theme ink.
class _QuickActions extends ConsumerWidget {
  final bool narrow;

  const _QuickActions({required this.narrow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final notifier = ref.read(dashboardUiProvider.notifier);
    final adaptive = context.adaptive;

    void push(String route) => context.push(route);

    final actions = <_ActionDef>[
      _ActionDef(
        icon: Icons.assignment_rounded,
        label: t.ownerActionJobCards,
        hint: t.ownerActionJobCardsHint,
        run: (ctx, _) => push(AppRoutes.jobCards),
      ),
      _ActionDef(
        icon: Icons.inventory_2_rounded,
        label: t.ownerActionInventory,
        hint: t.ownerActionInventoryHint,
        run: (ctx, _) => push(AppRoutes.inventory),
      ),
      _ActionDef(
        icon: Icons.receipt_long_rounded,
        label: t.ownerActionReceivables,
        hint: t.ownerActionReceivablesHint,
        run: (ctx, _) => push(AppRoutes.accountsReceivable),
      ),
      _ActionDef(
        icon: Icons.hourglass_top_rounded,
        label: t.ownerActionApprovals,
        hint: t.ownerActionApprovalsHint,
        run: (ctx, _) => push(AppRoutes.pendingApprovals),
      ),
      _ActionDef(
        icon: Icons.fact_check_rounded,
        label: t.ownerActionJobStatus,
        hint: t.ownerActionJobStatusHint,
        run: (ctx, _) => push(AppRoutes.jobStatus),
      ),
      _ActionDef(
        icon: Icons.event_note_rounded,
        label: t.ownerActionCompliance,
        hint: t.ownerActionComplianceHint,
        run: (ctx, _) => push(AppRoutes.documentExpiry),
      ),
      _ActionDef(
        icon: Icons.rate_review_rounded,
        label: t.ownerActionReviews,
        hint: t.ownerActionReviewsHint,
        run: (ctx, _) => push(AppRoutes.feedbackModeration),
      ),
      _ActionDef(
        icon: Icons.badge_rounded,
        label: t.ownerActionAttendance,
        hint: t.ownerActionAttendanceHint,
        run: (ctx, _) => push(AppRoutes.attendance),
      ),
      _ActionDef(
        icon: Icons.groups_rounded,
        label: t.ownerActionTeam,
        hint: t.ownerActionTeamHint,
        run: (ctx, _) => push(AppRoutes.team),
      ),
      _ActionDef(
        icon: Icons.leaderboard_rounded,
        label: t.ownerActionTopSales,
        hint: t.ownerActionTopSalesHint,
        run: (ctx, n) => n.selectTab(1),
      ),
      _ActionDef(
        icon: Icons.chat_bubble_rounded,
        label: t.ownerActionMessages,
        hint: t.ownerActionMessagesHint,
        run: (ctx, n) => n.selectTab(2),
      ),
      _ActionDef(
        icon: Icons.workspace_premium_rounded,
        label: t.ownerActionSubscription,
        hint: t.ownerActionSubscriptionHint,
        run: (ctx, _) => push(AppRoutes.subscription),
      ),
    ];

    Widget tile(_ActionDef action) => AppRecordRow(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusSm,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              action.icon,
              color: colors.primary,
              size: AppDimensions.iconMd,
            ),
          ),
          title: action.label,
          subtitle: action.hint,
          onTap: () {
            HapticFeedback.selectionClick();
            action.run(context, notifier);
          },
        );

    // A single column renders as an intrinsic-height stream: fixed-height
    // grid cells clip two-line subtitles at 1.3x (audited 320/1280px), so
    // the grid is only used multi-column.
    final singleColumn =
        narrow || adaptive.isCompact;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: SectionHeader(title: t.ownerActionsTitle),
        ),
        if (singleColumn)
          for (final action in actions) ...[
            tile(action),
            const SizedBox(height: AppDimensions.s10),
          ]
        else
          AppAdaptiveGrid(
            columns: adaptive.pick(compact: 1, medium: 3, expanded: 4, large: 4),
            minChildWidth: 200,
            spacing: AppDimensions.s10,
            runSpacing: AppDimensions.s10,
            childAspectRatio: adaptive.pick(
              compact: 3.4,
              // 800px @1.3x needs the extra height for two-line subtitles.
              medium: 1.3,
              expanded: 1.8,
              large: 2.0,
            ),
            children: [for (final action in actions) tile(action)],
          ),
      ],
    );
  }
}
