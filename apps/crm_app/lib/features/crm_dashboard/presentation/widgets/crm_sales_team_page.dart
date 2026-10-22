// Agent leaderboard in list order: rank badges derive from position, every
// figure is the record's own (revenue display-mapped, counts interpolated,
// win rate as provided). There is no period control on the record, so none
// is offered — the subtitle says what the ranking covers.
//
// Presentation-only rebuild (brief `docs/ui-redesign/briefs/crm-sales-team-list.md`):
// plain-Row header, borderless cards + AppAvatar + theme type, token stat
// blocks, AppProgressBar (pinned accent, same value + semantics),
// list-scoped search sheet when the roster exceeds 5 rows (family > 5 rule),
// action-less AppEmptyState. Feed, rank/medal derivation, figures, order
// and view-only rows are unchanged.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_sales_team_search_sheet.dart';

/// Display-only revenue mapping (F7, same class as the leads fix): the
/// String feed field renders through the existing `AppFormatters.moneyAED`
/// so figures group (`AED 12,000` en / `12,000 د.إ` ar, Latin digits per
/// the frozen policy). Digits are extracted for display only — feed order,
/// rank math and the raw field are untouched (no parsing semantics change).
/// Unparseable values render verbatim, never invented.
String _displayRevenue(BuildContext context, String revenue) {
  final numeric = revenue.replaceAll(RegExp(r'[^0-9.\-]'), '');
  if (numeric.isEmpty || numeric == '-' || numeric == '.') return revenue;
  final value = double.tryParse(numeric);
  if (value == null) return revenue;
  return AppFormatters.of(context).moneyAED(value);
}

/// Agent leaderboard in list order: rank badges derive from position, every
/// figure is the record's own (revenue verbatim, counts interpolated, win
/// rate as provided). There is no period control on the record, so none is
/// offered — the subtitle says what the ranking covers.
class CrmSalesTeamPage extends ConsumerStatefulWidget {
  const CrmSalesTeamPage({super.key});

  @override
  ConsumerState<CrmSalesTeamPage> createState() => _CrmSalesTeamPageState();
}

class _CrmSalesTeamPageState extends ConsumerState<CrmSalesTeamPage> {
  /// Scroll anchors for search-result reveals (presentation only).
  final Map<String, GlobalKey> _scrollKeys = {};

  GlobalKey _scrollKeyFor(String id) =>
      _scrollKeys.putIfAbsent(id, () => GlobalKey());

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final ui = ref.read(crmUiProvider.notifier);
    final team = ui.salesTeam;
    _scrollKeys.removeWhere(
      (id, _) => !team.asMap().entries.any((e) => 'row_${e.key}' == id),
    );

    // Family > 5 search rule (F8): the brief's no-search exception covered
    // the 3-row idle; a 6-row roster scrolls (scrolled golden proves
    // overflow), so the list-scoped search sheet applies — same threshold
    // as the leads/tasks lists.
    final showFindAids = team.length > 5;

    void reveal(int index) {
      final ctx = _scrollKeys['row_$index']?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
        );
      }
    }

    Future<void> openSearch() => showCrmSalesTeamSearchSheet(
          context,
          team: team,
          onSelect: (member) => reveal(team.indexOf(member)),
        );

    if (team.isEmpty) {
      // Empty keeps the header (U0 orientation) above the calm
      // action-less empty state — same header contract as the content branch.
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _TeamHeader(
              title: t.tmTitle,
              subtitle: t.tmSub,
              showSearch: false,
              onSearch: openSearch,
            ),
          ),
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 64),
                AppEmptyState(
                  icon: Icons.groups_outlined,
                  title: t.tmEmpty,
                  message: t.tmEmptyBody,
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _TeamHeader(
            title: t.tmTitle,
            subtitle: t.tmSub,
            showSearch: showFindAids,
            onSearch: openSearch,
          ),
        ),
        Expanded(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: team.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final m = team[i];
              return Container(
                key: _scrollKeyFor('row_$i'),
                child: _LeaderRow(
                  rank: i + 1,
                  name: m.name,
                  role: m.role,
                  revenue: m.revenue,
                  leads: m.leadsHandled,
                  won: m.wonDeals,
                  winRate: m.winRate,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Plain-Row header (F6 pattern shared with the leads/tasks lists): title
/// and the find-aid share ONE Row so the search icon stays top-end
/// same-row on compact. Row mirrors in RTL (search lands top-start in
/// Arabic — correct end side). Same >5 condition, same sheet — placement
/// only.
class _TeamHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showSearch;
  final VoidCallback onSearch;

  const _TeamHeader({
    required this.title,
    required this.subtitle,
    required this.showSearch,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showSearch) ...[
          const SizedBox(width: AppDimensions.s12),
          AppIconButton(
            icon: Icons.search_rounded,
            tooltip: t.tmSearchTitle,
            onPressed: onSearch,
          ),
        ],
      ],
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final int rank;
  final String name;
  final String role;
  final String revenue;
  final int leads;
  final int won;
  final double winRate;

  const _LeaderRow({
    required this.rank,
    required this.name,
    required this.role,
    required this.revenue,
    required this.leads,
    required this.won,
    required this.winRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;
    final medal = rank <= 3;
    final percent = (winRate * 100).round();
    return AppSurfaceCard(
      outlined: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: name.isEmpty ? '?' : name),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (role.trim().isNotEmpty)
                      Text(
                        role.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (medal)
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '#$rank',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Text(
                  '#$rank',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(width: AppDimensions.s8),
              // Grouped tabular revenue (F7 display mapping) with the
              // small `Revenue` label above the figure.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.tmRevenue,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      _displayRevenue(context, revenue),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: context.semanticColors.success.ink,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Row(
            children: [
              _statBlock(context, t.tmLeads, '$leads'),
              const SizedBox(width: AppDimensions.s8),
              _statBlock(context, t.tmWon, '$won'),
              const SizedBox(width: AppDimensions.s8),
              _statBlock(context, t.tmWinRate, '$percent%'),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          AppProgressBar(
            value: winRate.clamp(0.0, 1.0),
            tone: AppProgressTone.accent,
            semanticLabel: '${t.tmWinRate} $percent%',
          ),
        ],
      ),
    );
  }

  Widget _statBlock(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.r10),
        ),
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
