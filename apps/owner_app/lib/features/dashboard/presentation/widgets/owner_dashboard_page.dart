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

/// Executive cockpit (O1, Archetype 8): revenue hero → micro-pods → blocker
/// banner → telemetry curves → job register → quick actions. Every figure is
/// a frozen adapter value rendered verbatim; missing series render
/// placeholders, never zeros dressed as data. Desktop is a 3-column
/// panoramic console (never a stretched phone); compact stacks the curves
/// (no swipeable pages) with the record-row register fallback. Presentation
/// only: providers/routes/sync/refresh/period logic, filter predicates,
/// bottom nav + rail, pull-to-refresh, haptics and keys are untouched.
class OwnerDashboardPage extends ConsumerWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final coreT = SharedCoreL10n.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);

    final kpis = notifier.kpis;
    final sales = notifier.salesTrend;
    final profit = notifier.profitTrend;
    final expenses = notifier.expensesTrend;
    final register = notifier.registerItems;
    final hasAnyData =
        kpis.isNotEmpty ||
        sales.isNotEmpty ||
        profit.isNotEmpty ||
        expenses.isNotEmpty ||
        register.isNotEmpty;

    if (state.isLoading && !hasAnyData) {
      return const _HomeSkeleton();
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
              AppErrorState(
                title: t.ownerHomeLoadError,
                message: state.errorMessage!,
                onRetry: notifier.refresh,
                retryLabel: coreT.commonRetry,
              ),
              const SizedBox(height: AppDimensions.s16),
            ],
            _HomeHeader(kpis: kpis),
            const SizedBox(height: AppDimensions.s20),
            _RevenueHero(kpis: kpis),
            const SizedBox(height: AppDimensions.s20),
            _MicroPods(kpis: kpis),
            const SizedBox(height: AppDimensions.s24),
            _ApprovalsBlocker(kpis: kpis),
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
                  Expanded(flex: 4, child: _JobRegister(items: register)),
                  const SizedBox(width: AppDimensions.s24),
                  const Expanded(flex: 3, child: _QuickActions()),
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
              const _QuickActions(),
            ] else ...[
              _RevenueCurve(sales: sales, profit: profit),
              const SizedBox(height: AppDimensions.s24),
              _CostCurve(profit: profit, expenses: expenses),
              const SizedBox(height: AppDimensions.s24),
              _JobRegister(items: register),
              const SizedBox(height: AppDimensions.s24),
              const _QuickActions(),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

/// Layout-mirroring loading skeleton: header lines + hero card + pod row +
/// chart card + register rows. Same radii/heights as the content stills.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;
    final pods = adaptive.isCompact ? 2 : 3;
    return AppResponsivePage(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppShimmerSkeleton.textBlock(lines: 2),
          const SizedBox(height: AppDimensions.s20),
          const AppShimmerSkeleton.card(height: 148),
          const SizedBox(height: AppDimensions.s20),
          Row(
            children: [
              for (var i = 0; i < pods; i++) ...[
                if (i > 0) const SizedBox(width: AppDimensions.s12),
                const Expanded(child: AppShimmerSkeleton.card(height: 132)),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.s24),
          const AppShimmerSkeleton.card(height: 190),
          const SizedBox(height: AppDimensions.s24),
          const AppShimmerSkeleton.listRows(rows: 3),
        ],
      ),
    );
  }
}

/// Home wayfinding: ops title + branch subtitle, then live/count pills
/// rebuilt on shared atoms.
///
/// Ruling (a) relocation (ui/fix-rulings): the page header shows NO search
/// action — the shell AppBar owns the single visible search path (same
/// palette via openOwnerSearch, top-right action cluster). Same strings,
/// same text styles; no logic changes.
///
/// The KPI lists arrive from the notifier (frozen derivation below); the
/// header itself takes them as plain parameters so it rebuilds with the
/// data instead of freezing on the first content frame.
class _HomeHeader extends StatelessWidget {
  final List<OwnerKpi> kpis;

  const _HomeHeader({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final active =
        _findKpi(kpis, ['open', 'active']) ??
        (kpis.isEmpty ? null : kpis.first);
    final fresh = _findKpi(kpis, ['new', 'today']) ?? active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.ownerOpsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        Text(
          t.ownerOpsSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppDimensions.s12),
        Wrap(
          spacing: AppDimensions.s8,
          runSpacing: AppDimensions.s8,
          children: [
            AppStatusChip(label: t.ownerPillLive, kind: AppStatusKind.accent),
            if (active != null)
              AppStatusChip(
                label: t.ownerPillActive(active.value),
                kind: AppStatusKind.info,
              ),
            if (fresh != null)
              AppStatusChip(
                label: t.ownerPillToday(fresh.value),
                kind: AppStatusKind.success,
              ),
          ],
        ),
      ],
    );
  }
}

/// Revenue hero: the revenue KPI (or the first KPI when the server does not
/// label one) as a single wide KPI card with its verbatim delta line. No
/// revenue KPI on record renders an explicit empty state — never a zero.
class _RevenueHero extends StatelessWidget {
  final List<OwnerKpi> kpis;

  const _RevenueHero({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final hero =
        _findKpi(kpis, ['revenue', 'sales', 'turnover']) ??
        (kpis.isEmpty ? null : kpis.first);

    if (hero == null) {
      return AppEmptyState(
        icon: Icons.payments_outlined,
        title: t.ownerHeroEmpty,
        message: t.ownerHeroEmptyHint,
      );
    }
    final delta = hero.sub.trim();
    // Server values stay verbatim; the LTR lock keeps `AED 84K`-style figures
    // reading correctly inside RTL layouts.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AppKpiCard.wide(
        label: hero.label,
        value: hero.value,
        // ONE delta line: the trend badge already renders the verbatim
        // sub-line, so supportingText would read it twice.
        trend: delta.isEmpty
            ? null
            : KpiTrend(
                label: delta,
                isPositive: _trendOf(hero.sub) == TelemetryTrend.up,
              ),
        icon: hero.icon,
        semanticState: hero.state,
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
    // Same scale-aware grid contract as the sibling KpiGrid: 2 columns of
    // short cards on compact phones (single column only below 360px), and
    // the cell aspect relaxes with the system text scale so tiles grow
    // instead of clipping at 1.3x+. Medium+ keep one row per pod family.
    // Compact base 1.0: at 360px the 154px cell is ~154px tall against
    // ~148px of wrapped tile content (overline + delta wrap to 2 lines —
    // verified in the shell-fix captures), so the 2-col tiles fit with no
    // overflow and no dead square space; hero + pod row + banner stay
    // above the fold (U2: the first pod row never moves).
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    // R1 (U5/U14): at 1.3x the 2-col cell (~88px label slot after the icon)
    // cannot fit the verbatim server word "occupancy" even on 2 lines, so
    // the overline cut mid-word ("occupan…"). On compact phones fall to a
    // single column once the system scale grows: full-width tiles fit "Bay
    // occupancy" + delta whole. 1.0x keeps 2 columns so the U2 fold is
    // byte-identical; medium+ keep one row per pod family.
    final scaledUp = textScale > 1.0 && adaptive.isCompact;
    final singleColumn = adaptive.isSmallMobile || scaledUp;
    final compactAspect = (singleColumn ? 2.15 : 1.0) / textScale;
    return AppAdaptiveGrid(
      columns: singleColumn
          ? 1
          : adaptive.pick(
              compact: pods.length == 1 ? 1 : 2,
              medium: pods.length,
              expanded: pods.length,
              large: pods.length,
            ),
      minChildWidth: adaptive.isCompact ? 142 : 200,
      childAspectRatio: adaptive.isCompact ? compactAspect : 1,
      spacing: adaptive.itemSpacing,
      runSpacing: adaptive.itemSpacing,
      children: [
        for (final pod in pods)
          Directionality(
            textDirection: TextDirection.ltr,
            // U5: overline + delta wrap to 2 lines instead of `…` on the
            // 2-col phone grid (`Bay occupancy`, `Pending approvals`,
            // `+1.2% vs last week`). Server copy verbatim — no shorter key
            // exists. Tile geometry holds with the 1.0 compact aspect
            // (~154px tile vs ~148px wrapped content), so the fold is
            // unchanged.
            child: AppKpiCard(
              label: pod.label,
              value: pod.value,
              // ONE delta line: the trend badge already renders the verbatim
              // sub-line (see hero).
              trend: pod.sub.trim().isEmpty
                  ? null
                  : KpiTrend(
                      label: pod.sub.trim(),
                      isPositive: _trendOf(pod.sub) == TelemetryTrend.up,
                    ),
              icon: pod.icon,
              semanticState: pod.state,
              labelMaxLines: 2,
              trendMaxLines: 2,
            ),
          ),
      ],
    );
  }
}

/// Conditional blocker: the approvals-WIP KPI becomes an inline banner only
/// when the family exists and work is actually waiting. The value renders
/// verbatim; the drill opens the read-only triage queue (no decision
/// buttons exist anywhere on this surface).
class _ApprovalsBlocker extends StatelessWidget {
  final List<OwnerKpi> kpis;

  const _ApprovalsBlocker({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final approvals = _findKpi(kpis, ['approval']);
    if (approvals == null) return const SizedBox.shrink();
    // Visibility only — never a figure change: unparseable values stay
    // visible (the family exists), an explicit zero stays silent.
    final pending = int.tryParse(approvals.value.trim());
    if (pending != null && pending <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppBanner(
          kind: AppBannerKind.warning,
          message: t.ownerHomeApprovalsBanner(approvals.value),
          actionLabel: t.ownerRegisterAll,
          onAction: () {
            HapticFeedback.selectionClick();
            context.push(AppRoutes.pendingApprovals);
          },
        ),
        const SizedBox(height: AppDimensions.s24),
      ],
    );
  }
}

/// Shared chart card: section header, legend in chart-palette order (mirrored
/// in RTL by the theme), the sparkline itself, and a first/last month rule.
/// Empty series render the chart placeholder — never a blank.
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

/// Job register: sortable-feel table on medium+ screens, an `AppListGroup`
/// of value rows with Show-all on compact (capped at five rows so the
/// section never pushes the quick actions off a small still). Any row — or
/// the Show-all — opens the real register. Empty renders an honest empty
/// state, never blank space.
class _JobRegister extends StatelessWidget {
  /// Compact rows shown before the Show-all appears.
  static const int _compactWindow = 5;

  final List<JobCardRegisterItem> items;

  const _JobRegister({required this.items});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final formatters = AppFormatters.of(context);
    final compact = context.adaptive.isCompact;

    Widget section(Widget body) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: t.ownerRegisterTitle,
          trailing: items.isEmpty
              ? null
              : TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    context.push(AppRoutes.jobCards);
                  },
                  child: Text(t.ownerRegisterAll),
                ),
        ),
        body,
      ],
    );

    if (compact) {
      if (items.isEmpty) {
        return section(
          AppEmptyState(
            icon: Icons.assignment_outlined,
            title: t.ownerRegisterEmpty,
            message: t.ownerRegisterEmptyHint,
          ),
        );
      }
      final shown = items.take(_compactWindow).toList();
      final hasMore = items.length > shown.length;
      return section(
        AppListGroup(
          items: [
            for (final item in shown)
              AppListGroupItem(
                title: item.label,
                valueText:
                    '${t.ownerRegisterOpen}: ${formatters.group(item.open)} · '
                    '${t.ownerRegisterTotal}: ${formatters.group(item.total)}',
                showChevron: true,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push(AppRoutes.jobCards);
                },
              ),
            if (hasMore)
              AppListGroupItem(
                leadingIcon: Icons.expand_more_rounded,
                title: t.ownerRegisterAll,
                showChevron: false,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push(AppRoutes.jobCards);
                },
              ),
          ],
        ),
      );
    }

    return section(
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
      ),
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

/// Quick actions: all twelve real destinations as compact tiles in one
/// responsive grid — nothing is hidden behind an overflow menu. No
/// destination is dropped or invented; routes and tab targets are unchanged.
class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final notifier = ref.read(dashboardUiProvider.notifier);

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

    const gap = AppDimensions.s10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: SectionHeader(title: t.ownerActionsTitle),
        ),
        const SizedBox(height: AppDimensions.s12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 520 ? 4 : 3;
            final tileWidth = constraints.maxWidth.isFinite
                ? (constraints.maxWidth - gap * (columns - 1)) / columns
                : 112.0;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final action in actions)
                  SizedBox(
                    width: tileWidth,
                    child: _QuickActionTile(
                      action: action,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        action.run(context, notifier);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final _ActionDef action;
  final VoidCallback onTap;

  const _QuickActionTile({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Tooltip(
      message: action.hint,
      child: AppCard.subtle(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s8,
          vertical: AppDimensions.s12,
        ),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              alignment: Alignment.center,
              child: Icon(
                action.icon,
                color: colors.primary,
                size: AppDimensions.iconMd,
              ),
            ),
            const SizedBox(height: AppDimensions.s8),
            Text(
              action.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
