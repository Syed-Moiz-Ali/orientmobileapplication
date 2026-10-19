import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
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
        children: [
          SizedBox(height: context.adaptive.sectionSpacing),
          EmptyState(
            icon: Icons.groups_outlined,
            title: t.tmEmpty,
            message: t.tmEmptyBody,
          ),
        ],
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(context.adaptive.gutter),
      itemCount: team.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.s12),
      itemBuilder: (_, i) {
        if (i == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: t.tmTitle, subtitle: t.tmSub),
              const SizedBox(height: AppDimensions.s12),
            ],
          );
        }
        final m = team[i - 1];
        return _LeaderRow(rank: i, name: m.name, role: m.role, revenue: m.revenue, leads: m.leadsHandled, won: m.wonDeals, winRate: m.winRate);
      },
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
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(
          color: medal
              ? colors.primary.withValues(alpha: 0.4)
              : colors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CrmColors.gStart, CrmColors.gEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CrmColors.textH,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (role.trim().isNotEmpty)
                      Text(
                        role.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CrmColors.textM,
                          fontSize: 12,
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
                  style: const TextStyle(
                    color: CrmColors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Row(
            children: [
              _statPill(t.tmLeads, '$leads', CrmColors.accent),
              const SizedBox(width: AppDimensions.s8),
              _statPill(t.tmWon, '$won', CrmColors.green),
              const SizedBox(width: AppDimensions.s8),
              _statPill(
                t.tmWinRate,
                '${(winRate * 100).round()}%',
                CrmColors.purple,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          Semantics(
            excludeSemantics: true,
            label: '${t.tmWinRate} ${(winRate * 100).round()}%',
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: LinearProgressIndicator(
                value: winRate.clamp(0.0, 1.0),
                backgroundColor: CrmColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  CrmColors.accent,
                ),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.r10),
        ),
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CrmColors.textM,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
