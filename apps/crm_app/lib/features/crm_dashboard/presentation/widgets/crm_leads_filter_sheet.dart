// List-scoped leads filter (CRM leads list).
//
// Presentation only: single-select source + agent chip groups over the
// honest facets the feed supports (distinct sources / assignees from the
// loaded leads). No new routes, no invented facets. Selection + Apply live
// with the caller; this sheet only draws the chrome.
import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

Future<LeadFilterPick?> showCrmLeadsFilterSheet(
  BuildContext context, {
  required List<String> sources,
  required List<String> agents,
  required String source,
  required String agent,
}) {
  final t = context.cx;
  return showAppModalSheet<LeadFilterPick>(
    context: context,
    title: t.leadsFilterTitle,
      builder: (_) => _LeadsFilterSheet(
      sources: sources,
      agents: agents,
      source: source,
      agent: agent,
    ),
  );
}

class LeadFilterPick {
  final String source;
  final String agent;
  const LeadFilterPick(this.source, this.agent);
}

class _LeadsFilterSheet extends StatefulWidget {
  final List<String> sources;
  final List<String> agents;
  final String source;
  final String agent;

  const _LeadsFilterSheet({
    required this.sources,
    required this.agents,
    required this.source,
    required this.agent,
  });

  @override
  State<_LeadsFilterSheet> createState() => _LeadsFilterSheetState();
}

class _LeadsFilterSheetState extends State<_LeadsFilterSheet> {
  late String _source = widget.source;
  late String _agent = widget.agent;

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.filterSource,
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _chip(t.filterAll, _source.isEmpty, () => setState(() => _source = '')),
              for (final s in widget.sources)
                _chip(s, _source == s, () => setState(() => _source = s)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            t.filterAgent,
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _chip(t.filterAll, _agent.isEmpty, () => setState(() => _agent = '')),
              for (final a in widget.agents)
                _chip(a, _agent == a, () => setState(() => _agent = a)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPillButton.primary(
            label: t.leadsFilterShow,
            onPressed: () => Navigator.of(context).pop(LeadFilterPick(_source, _agent)),
            isExpanded: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextButton(
            label: t.leadsFilterClear,
            onPressed: () => Navigator.of(context).pop(const LeadFilterPick('', '')),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return AppChip(label: label, selected: selected, onSelected: (_) => onTap());
  }
}
