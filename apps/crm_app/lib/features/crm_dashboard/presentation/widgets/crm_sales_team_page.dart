// Agent leaderboard in list order: rank badges derive from position, every
// figure is the record's own (revenue verbatim, counts interpolated, win
// rate as provided). There is no period control on the record, so none is
// offered — the subtitle says what the ranking covers.
//
// Presentation-only rebuild (brief `docs/ui-redesign/briefs/crm-sales-team-list.md`):
// AppPageHeader, borderless cards + AppAvatar + theme type, token stat
// blocks, AppProgressBar (pinned accent, same value + semantics),
// action-less AppEmptyState. Feed, rank/medal derivation, figures, order
// and view-only rows are unchanged.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

/// Agent leaderboard in list order: rank badges derive from position, every
/// figure is the record's own (revenue verbatim, counts interpolated, win
/// rate as provided). There is no period control on the record, so none is
/// offered — the subtitle says what the ranking covers.
class CrmSalesTeamPage extends ConsumerWidget {
  const CrmSalesTeamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.cx;
    final ui = ref.read(crmUiProvider.notifier);
    final team = ui.salesTeam;
    if (team.isEmpty) {
      return ListView(
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
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: AppPageHeader(
            title: t.tmTitle,
            subtitle: t.tmSub,
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
              return _LeaderRow(
                rank: i + 1,
                name: m.name,
                role: m.role,
                revenue: m.revenue,
                leads: m.leadsHandled,
                won: m.wonDeals,
                winRate: m.winRate,
              );
            },
          ),
        ),
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
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  revenue,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: context.semanticColors.success.ink,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
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
