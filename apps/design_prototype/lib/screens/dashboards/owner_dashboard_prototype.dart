// D1 · Owner Dashboard prototype.
//
// Mirrors the production composition (owner_dashboard_page.dart):
//   top bar → HeaderBanner (as navy identity/period hero) → KPI grid →
//   Job Card Register → Analytics (trend + bars, side-by-side ≥ tablet) →
//   12 quick actions, plus the production adaptive navigation frame
//   (bottom bar on compact, rail on medium+, extended at large).
// States: populated / loading / empty register / error.
import 'package:flutter/material.dart';

import '../../design/prototype_theme.dart';
import '../../design/provisional_tokens.dart';
import '../../fixtures/owner_dashboard_fixtures.dart';
import '../../l10n/proto_format.dart';
import '../../l10n/provisional_strings.dart';
import '../../widgets/proto_charts.dart';
import '../../widgets/proto_nav.dart';
import '../../widgets/proto_primitives.dart';

class OwnerDashboardPrototype extends StatefulWidget {
  final String variant;
  final VoidCallback? onOpenJobCards;

  const OwnerDashboardPrototype({super.key, required this.variant, this.onOpenJobCards});

  @override
  State<OwnerDashboardPrototype> createState() => _OwnerDashboardPrototypeState();
}

class _OwnerDashboardPrototypeState extends State<OwnerDashboardPrototype> {
  int _tabIndex = 0;
  int _periodIndex = 1; // "This Week" like production default
  bool _interactiveLoading = false;

  static const _periodKeys = [
    'common.today',
    'common.thisWeek',
    'common.thisMonth',
    'common.thisYear',
  ];

  bool get _loading => widget.variant == 'loading' || _interactiveLoading;
  bool get _error => widget.variant == 'error';
  bool get _emptyRegister => widget.variant == 'empty';

  void _simulateRefresh() {
    setState(() => _interactiveLoading = true);
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _interactiveLoading = false);
    });
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final compact = context.windowClass.isCompact;

    final navItems = [
      ProtoNavItem(
        icon: Icons.space_dashboard_outlined,
        selectedIcon: Icons.space_dashboard_rounded,
        label: context.s('dashboard.nav.dashboard'),
      ),
      ProtoNavItem(
        icon: Icons.leaderboard_outlined,
        selectedIcon: Icons.leaderboard_rounded,
        label: context.s('dashboard.nav.topSales'),
      ),
      ProtoNavItem(
        icon: Icons.chat_bubble_outline_rounded,
        selectedIcon: Icons.chat_bubble_rounded,
        label: context.s('dashboard.nav.messages'),
        badge: 3,
      ),
      ProtoNavItem(
        icon: Icons.monitor_heart_outlined,
        selectedIcon: Icons.monitor_heart_rounded,
        label: context.s('dashboard.nav.activity'),
      ),
    ];

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopBar(
          periodLabel: context.s(_periodKeys[_periodIndex]),
          onPeriodTap: () => _pickPeriod(context),
          onRefresh: _simulateRefresh,
          onNotificationTap: () => _notify(context.s('dashboard.notifications')),
          onProfileTap: () => _notify(context.s('dashboard.profile')),
        ),
        Expanded(
          child: _loading
              ? const _DashboardSkeleton()
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    ProtoSpace.gutterCompact,
                    ProtoSpace.s16,
                    ProtoSpace.gutterCompact,
                    ProtoSpace.bottomNavClearance,
                  ),
                  child: ProtoPageFrame(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_error) ...[
                          ProtoErrorBanner(
                            title: context.s('common.errorTitle'),
                            body: context.s('dashboard.error.banner'),
                            onRetry: _simulateRefresh,
                          ),
                          const SizedBox(height: ProtoSpace.s16),
                        ],
                        _HeroStrip(
                          periodLabel: context.s(_periodKeys[_periodIndex]),
                          onPeriodTap: () => _pickPeriod(context),
                        ),
                        const SizedBox(height: ProtoSpace.s24),
                        _KpiStrip(onTap: (label) => _notify(label)),
                        const SizedBox(height: ProtoSpace.s28),
                        _RegisterCard(
                          empty: _emptyRegister,
                          onRowTap: (row) => _showRegisterDialog(context, row),
                          onViewAll: widget.onOpenJobCards,
                        ),
                        const SizedBox(height: ProtoSpace.s28),
                        ProtoSectionHeader(
                          eyebrow: context.s('dashboard.analytics.title'),
                          title: context.s('dashboard.analytics.title'),
                        ),
                        const SizedBox(height: ProtoSpace.s12),
                        const _AnalyticsRow(),
                        const SizedBox(height: ProtoSpace.s28),
                        ProtoSectionHeader(
                          eyebrow: context.s('dashboard.actions.title'),
                          title: context.s('dashboard.actions.title'),
                        ),
                        const SizedBox(height: ProtoSpace.s12),
                        _QuickActionsGrid(
                          onJobCards: widget.onOpenJobCards,
                          onOther: (label) => _notify('${context.s('console.disclaimer')} · $label'),
                        ),
                        SizedBox(height: p.isDark ? ProtoSpace.s24 : ProtoSpace.s16),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );

    if (compact) {
      return Column(
        children: [
          Expanded(child: content),
          ProtoWorkspaceNav(
            items: navItems,
            selectedIndex: _tabIndex,
            onSelect: (i) => setState(() => _tabIndex = i),
          ),
        ],
      );
    }

    return Row(
      children: [
        ProtoWorkspaceNav(
          items: navItems,
          selectedIndex: _tabIndex,
          onSelect: (i) => setState(() => _tabIndex = i),
        ),
        Expanded(child: content),
      ],
    );
  }

  Future<void> _pickPeriod(BuildContext context) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _periodKeys.length; i++)
              ListTile(
                leading: Icon(
                  i == _periodIndex ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  size: 20,
                  color: i == _periodIndex ? context.palette.primary : context.palette.textMuted,
                ),
                title: Text(context.s(_periodKeys[i])),
                onTap: () => Navigator.pop(context, i),
              ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) setState(() => _periodIndex = selected);
  }

  Future<void> _showRegisterDialog(BuildContext context, RegisterFixtureRow row) {
    final label = context.s(row.labelKey);
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.s('dashboard.register.drillTitle', {'category': label})),
        content: Text(context.s('dashboard.register.drillBody', {
          'n': '${row.open}',
          'state': context.s(row.stateKey),
          'amount': ProtoFormat.money(context, row.amount),
        })),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.s('common.close')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onOpenJobCards?.call();
            },
            child: Text(context.s('dashboard.action.jobCards')),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String periodLabel;
  final VoidCallback onPeriodTap;
  final VoidCallback onRefresh;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const _TopBar({
    required this.periodLabel,
    required this.onPeriodTap,
    required this.onRefresh,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final compact = context.windowClass.isCompact;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.borderDefault)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s16),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              if (!compact) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: p.primary,
                    borderRadius: BorderRadius.circular(ProtoRadius.control),
                  ),
                  child: const Icon(Icons.build_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: ProtoSpace.s12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.s('dashboard.appTitle'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: types.pageTitle.copyWith(fontSize: compact ? 18 : 20),
                    ),
                    Text(
                      context.s('dashboard.branch'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: types.metadata.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                _PeriodButton(label: periodLabel, onTap: onPeriodTap),
                const SizedBox(width: ProtoSpace.s6),
              ],
              Tooltip(
                message: context.s('common.retry'),
                child: IconButton(
                  onPressed: onRefresh,
                  icon: Icon(Icons.refresh_rounded, size: 20, color: p.textSecondary),
                ),
              ),
              ProtoNotificationBell(count: 4, onTap: onNotificationTap),
              const SizedBox(width: ProtoSpace.s4),
              ProtoAvatar(initials: 'KS', onTap: onProfileTap),
              const SizedBox(width: ProtoSpace.s8),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PeriodButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ProtoRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: ProtoSpace.s8),
        decoration: BoxDecoration(
          color: p.primarySubtle,
          borderRadius: BorderRadius.circular(ProtoRadius.pill),
          border: Border.all(color: p.primaryBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, size: 13, color: p.primary),
            const SizedBox(width: ProtoSpace.s6),
            Text(
              label,
              style: context.types.label.copyWith(color: p.primary, fontSize: 12),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: p.primary),
          ],
        ),
      ),
    );
  }
}

/// Navy identity/period hero - the ONE high-emphasis surface of this screen.
class _HeroStrip extends StatelessWidget {
  final String periodLabel;
  final VoidCallback? onPeriodTap;

  const _HeroStrip({required this.periodLabel, this.onPeriodTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final periodHandler = onPeriodTap;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ProtoSpace.s20),
      decoration: BoxDecoration(
        color: p.navy,
        borderRadius: BorderRadius.circular(ProtoRadius.panel),
        boxShadow: ProtoElevation.navy,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(ProtoRadius.pill),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: ProtoSpace.s6),
                    Text(
                      context.s('dashboard.hero.live'),
                      style: types.metadata.copyWith(
                        color: const Color(0xFF6EE7B7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!context.windowClass.isCompact)
                Flexible(
                  child: Text(
                    context.s('dashboard.hero.eyebrow'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: types.eyebrow.copyWith(color: p.onNavySecondary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: ProtoSpace.s16),
          Text(
            context.s('dashboard.hero.title'),
            style: types.displaySmall.copyWith(color: p.textInverse, height: 1.15),
          ),
          const SizedBox(height: ProtoSpace.s6),
          Text(
            context.s('dashboard.hero.subtitle'),
            style: types.bodySmall.copyWith(color: p.onNavySecondary),
          ),
          const SizedBox(height: ProtoSpace.s18),
          Wrap(
            spacing: ProtoSpace.s8,
            runSpacing: ProtoSpace.s8,
            children: [
              _HeroChip(
                icon: Icons.calendar_today_rounded,
                label: ProtoFormat.date(context, dashboardFixtureDate),
              ),
              _HeroChip(
                icon: Icons.speed_rounded,
                label: periodLabel,
                onTap: periodHandler,
              ),
              _HeroChip(
                icon: Icons.directions_car_rounded,
                label: context.s('dashboard.hero.pillActive', {'n': '24'}),
              ),
              _HeroChip(
                icon: Icons.check_circle_rounded,
                label: context.s('dashboard.hero.pillCompleted', {'n': '11'}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _HeroChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: ProtoSpace.s8),
      decoration: BoxDecoration(
        color: p.navyRaised,
        borderRadius: BorderRadius.circular(ProtoRadius.control),
        border: Border.all(color: ProtoPalette.light.navyRaised.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9DB4FF)),
          const SizedBox(width: ProtoSpace.s8),
          Text(
            label,
            style: context.types.label.copyWith(color: p.textInverse, fontSize: 12),
          ),
          if (onTap != null) ...[
            const SizedBox(width: ProtoSpace.s4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF9DB4FF)),
          ],
        ],
      ),
    );
    if (onTap == null) return chip;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(ProtoRadius.control), child: chip);
  }
}

class _KpiStrip extends StatelessWidget {
  final void Function(String label) onTap;

  const _KpiStrip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Production-aligned KPI density (KpiGrid): 1 column on small phones,
        // 2 columns through tablet, 4 columns on desktop. Two columns at
        // 600–1023 keep full KPI labels readable (no truncation).
        final windowClass = context.windowClass;
        final densePhone = MediaQuery.sizeOf(context).width < 360;
        final columns = switch (windowClass) {
          ProtoWindowClass.compact => densePhone ? 1 : 2,
          ProtoWindowClass.medium => 2,
          _ => 4,
        };
        const gap = ProtoSpace.s12;
        final tileWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        // Base 156 px covers the Arabic line-height (×1.05) at 320 px width;
        // the tile then grows with the system text scale so 1.3× never clips
        // (spec §3.3: no forced text-scale lock).
        final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
        final tileHeight = 156.0 * textScale;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final kpi in ownerKpiFixtures)
              SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: ProtoKpiTile(
                  icon: kpi.icon,
                  label: context.s(kpi.labelKey),
                  sub: context.s(kpi.subKey),
                  value: kpi.labelKey == 'dashboard.kpi.revenue'
                      ? ProtoFormat.money(context, 86450)
                      : context.s(kpi.valueKey),
                  onTap: () => onTap(context.s(kpi.labelKey)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RegisterCard extends StatelessWidget {
  final bool empty;
  final void Function(RegisterFixtureRow row) onRowTap;
  final VoidCallback? onViewAll;

  const _RegisterCard({required this.empty, required this.onRowTap, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return ProtoCard(
      padding: EdgeInsets.zero,
      child: empty
          ? SizedBox(
              height: 260,
              child: ProtoEmptyState(
                icon: Icons.assignment_outlined,
                title: context.s('dashboard.register.empty'),
                body: context.s('dashboard.register.emptyBody'),
                actionLabel: context.s('dashboard.action.jobCards'),
                onAction: onViewAll,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ProtoSpace.s16,
                    ProtoSpace.s14,
                    ProtoSpace.s8,
                    ProtoSpace.s4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.s('dashboard.register.title'),
                          style: types.cardTitle.copyWith(color: p.textPrimary, fontSize: 15),
                        ),
                      ),
                      TextButton(
                        onPressed: onViewAll,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(context.s('common.viewAll')),
                            const SizedBox(width: ProtoSpace.s4),
                            const ProtoDirIcon(Icons.arrow_forward_rounded, size: 15),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ProtoSpace.s16,
                    ProtoSpace.s8,
                    ProtoSpace.s16,
                    ProtoSpace.s12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          context.s('dashboard.register.category'),
                          style: types.tableHeader.copyWith(color: p.textMuted),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          context.s('dashboard.register.open'),
                          textAlign: TextAlign.center,
                          style: types.tableHeader.copyWith(color: p.textMuted),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          context.s('dashboard.register.total'),
                          textAlign: TextAlign.center,
                          style: types.tableHeader.copyWith(color: p.textMuted),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          context.s('dashboard.register.amount'),
                          textAlign: TextAlign.end,
                          style: types.tableHeader.copyWith(color: p.textMuted),
                        ),
                      ),
                      const SizedBox(width: 22),
                    ],
                  ),
                ),
                Divider(height: 1, color: p.borderDefault),
                for (final row in ownerRegisterFixtures)
                  _RegisterRow(row: row, onTap: () => onRowTap(row)),
              ],
            ),
    );
  }
}

class _RegisterRow extends StatelessWidget {
  final RegisterFixtureRow row;
  final VoidCallback onTap;

  const _RegisterRow({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: p.hover,
        child: Container(
          constraints: const BoxConstraints(minHeight: ProtoSpace.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s16, vertical: ProtoSpace.s12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.borderSubtle)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  context.s(row.labelKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: types.bodyStrong.copyWith(color: p.textPrimary, fontSize: 13.5),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${row.open}',
                  textAlign: TextAlign.center,
                  style: types.monoStrong.copyWith(color: p.primary),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${row.total}',
                  textAlign: TextAlign.center,
                  style: types.monoStrong.copyWith(color: p.textPrimary),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  ProtoFormat.money(context, row.amount),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: types.mono.copyWith(color: p.textSecondary, fontSize: 12),
                ),
              ),
              SizedBox(
                width: 22,
                child: Center(
                  child: ProtoDirIcon(Icons.chevron_right_rounded, size: 18, color: p.textDisabled),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  const _AnalyticsRow();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final wide = !context.windowClass.isCompact;
    final labels = [for (final m in trendMonths) ProtoFormat.monthShort(context, m)];

    final trend = ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.s('dashboard.trend.title'),
                  style: types.cardTitle.copyWith(color: p.textPrimary),
                ),
              ),
              ProtoChartLegend(color: p.primary, label: context.s('dashboard.trend.sales')),
              const SizedBox(width: ProtoSpace.s12),
              ProtoChartLegend(color: p.success, label: context.s('dashboard.trend.profit')),
            ],
          ),
          const SizedBox(height: ProtoSpace.s16),
          ProtoTrendChart(
            primary: ProtoSeries(
              label: context.s('dashboard.trend.sales'),
              values: salesTrendFixture,
              color: p.primary,
            ),
            secondary: ProtoSeries(
              label: context.s('dashboard.trend.profit'),
              values: profitTrendFixture,
              color: p.success,
            ),
            xLabels: labels,
          ),
        ],
      ),
    );

    final bars = ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.s('dashboard.expenses.title'),
                  style: types.cardTitle.copyWith(color: p.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s8, vertical: 3),
                decoration: BoxDecoration(
                  color: p.primarySubtle,
                  borderRadius: BorderRadius.circular(ProtoRadius.pill),
                  border: Border.all(color: p.primaryBorder),
                ),
                child: Text(
                  context.s('dashboard.expenses.badge'),
                  style: types.metadata.copyWith(color: p.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: ProtoSpace.s16),
          ProtoBarChart(
            sales: ProtoSeries(
              label: context.s('dashboard.expenses.sales'),
              values: salesTrendFixture,
              color: p.primary,
            ),
            expenses: ProtoSeries(
              label: context.s('dashboard.expenses.expenses'),
              values: expensesTrendFixture,
              color: p.warning,
            ),
            xLabels: labels,
          ),
          const SizedBox(height: ProtoSpace.s12),
          Row(
            children: [
              ProtoChartLegend(color: p.primary, label: context.s('dashboard.expenses.sales')),
              const SizedBox(width: ProtoSpace.s16),
              ProtoChartLegend(color: p.warning, label: context.s('dashboard.expenses.expenses')),
            ],
          ),
        ],
      ),
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [trend, const SizedBox(height: ProtoSpace.s12), bars],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: trend),
        const SizedBox(width: ProtoSpace.s12),
        Expanded(child: bars),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onJobCards;
  final void Function(String label) onOther;

  const _QuickActionsGrid({this.onJobCards, required this.onOther});

  @override
  Widget build(BuildContext context) {
    final columns = switch (context.windowClass) {
      ProtoWindowClass.compact => 2,
      ProtoWindowClass.medium => 3,
      _ => 4,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = ProtoSpace.s10;
        final tileWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final action in ownerActionFixtures)
              SizedBox(
                width: tileWidth,
                child: ProtoActionTile(
                  icon: action.icon,
                  label: context.s(action.labelKey),
                  subtitle: context.s(action.subKey),
                  showChevron: !context.windowClass.isCompact,
                  onTap: action.labelKey == 'dashboard.action.jobCards'
                      ? (onJobCards ?? () {})
                      : () => onOther(context.s(action.labelKey)),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Loading skeleton that mirrors the final layout (spec §7 `AppSkeleton`).
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ProtoSpace.gutterCompact),
      child: ProtoPageFrame(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ProtoSkeleton(height: 190, radius: ProtoRadius.panel),
            const SizedBox(height: ProtoSpace.s24),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = (constraints.maxWidth - ProtoSpace.s12 * 3) / 4;
                return Wrap(
                  spacing: ProtoSpace.s12,
                  runSpacing: ProtoSpace.s12,
                  children: [
                    for (var i = 0; i < 4; i++)
                      SizedBox(
                        width: context.windowClass.isCompact
                            ? (constraints.maxWidth - ProtoSpace.s12) / 2
                            : tileWidth,
                        child: const ProtoSkeleton(height: 146, radius: ProtoRadius.panel),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: ProtoSpace.s28),
            const ProtoSkeleton(height: 18, width: 180),
            const SizedBox(height: ProtoSpace.s12),
            const ProtoSkeleton(height: 240, radius: ProtoRadius.card),
            const SizedBox(height: ProtoSpace.s28),
            const ProtoSkeleton(height: 18, width: 140),
            const SizedBox(height: ProtoSpace.s12),
            Row(
              children: [
                const Expanded(child: ProtoSkeleton(height: 240, radius: ProtoRadius.card)),
                if (!context.windowClass.isCompact) ...[
                  const SizedBox(width: ProtoSpace.s12),
                  const Expanded(child: ProtoSkeleton(height: 240, radius: ProtoRadius.card)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
