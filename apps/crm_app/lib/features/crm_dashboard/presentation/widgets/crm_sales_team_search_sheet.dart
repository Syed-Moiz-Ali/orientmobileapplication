// List-scoped team search (CRM sales team leaderboard).
//
// Presentation only: filters the already-loaded roster by name or role
// substring (case-insensitive). No new routes, no server queries, no
// invented entries. Result taps close the sheet and reveal the row;
// rows stay view-only (no destinations invented).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

Future<void> showCrmSalesTeamSearchSheet(
  BuildContext context, {
  required List<SalesTeamMember> team,
  required ValueChanged<SalesTeamMember> onSelect,
}) {
  final t = context.cx;
  return showAppModalSheet<void>(
    context: context,
    title: t.tmSearchTitle,
    builder: (_) => _SalesTeamSearchSheet(team: team, onSelect: onSelect),
  );
}

class _SalesTeamSearchSheet extends StatefulWidget {
  final List<SalesTeamMember> team;
  final ValueChanged<SalesTeamMember> onSelect;

  const _SalesTeamSearchSheet({required this.team, required this.onSelect});

  @override
  State<_SalesTeamSearchSheet> createState() => _SalesTeamSearchSheetState();
}

class _SalesTeamSearchSheetState extends State<_SalesTeamSearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<SalesTeamMember> _results() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.team;
    return widget.team.where((m) {
      return m.name.toLowerCase().contains(q) ||
          m.role.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final results = _results();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: AppSearchField(
            controller: _ctrl,
            hintText: t.tmSearchHint,
            onChanged: (v) => setState(() => _query = v),
            onClear: () => setState(() {
              _ctrl.clear();
              _query = '';
            }),
          ),
        ),
        Flexible(
          child: results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.tmSearchNoMatch,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => setState(() {
                          _ctrl.clear();
                          _query = '';
                        }),
                        child: Text(t.leadsFilterClear),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (rowContext, index) {
                    final member = results[index];
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(rowContext).pop();
                        widget.onSelect(member);
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppDimensions.s20,
                          AppDimensions.s8,
                          AppDimensions.s20,
                          AppDimensions.s8,
                        ),
                        child: Row(
                          children: [
                            AppAvatar(
                              name: member.name.isEmpty ? '?' : member.name,
                            ),
                            const SizedBox(width: AppDimensions.s10),
                            Expanded(
                              child: Text(
                                member.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (member.role.trim().isNotEmpty) ...[
                              const SizedBox(width: AppDimensions.s10),
                              Flexible(
                                child: Text(
                                  member.role,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
