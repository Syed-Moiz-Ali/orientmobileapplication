import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_detail_sheet.dart';

class CrmKanbanView extends StatefulWidget {
  final List<CrmLeadEntity> leads;

  const CrmKanbanView({super.key, required this.leads});

  @override
  State<CrmKanbanView> createState() => _CrmKanbanViewState();
}

class _CrmKanbanViewState extends State<CrmKanbanView> {
  static const _knownStages = <String>[
    'ACTIVE',
    'NEW',
    'CONTACTED',
    'QUALIFIED',
    'PROPOSAL',
    'WON',
    'LOST',
    'UNANSWERED',
    'NO_RESPONSE',
  ];

  int _selectedStage = 0;

  List<String> get _stages {
    final present = widget.leads
        .map((lead) => lead.status.toUpperCase())
        .toSet();
    return [
      ..._knownStages.where(present.contains),
      ...present.where((stage) => !_knownStages.contains(stage)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final stages = _stages;
    if (stages.isEmpty) {
      return const EmptyState(
        icon: Icons.view_kanban_outlined,
        title: 'No pipeline stages',
        message: 'New leads will appear here as they enter the pipeline.',
      );
    }

    if (context.isCompact) return _buildCompact(context, stages);
    return _buildBoard(context, stages);
  }

  Widget _buildCompact(BuildContext context, List<String> stages) {
    final selectedIndex = _selectedStage.clamp(0, stages.length - 1);
    final selected = stages[selectedIndex];
    final leads = _leadsFor(selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.s16,
            AppDimensions.s12,
            AppDimensions.s16,
            AppDimensions.s8,
          ),
          child: Row(
            children: List.generate(stages.length, (index) {
              final stage = stages[index];
              final selected = index == selectedIndex;
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.s8),
                child: ChoiceChip(
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedStage = index),
                  label: Text('${_stageLabel(stage)}  ${_leadsFor(stage).length}'),
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.s16,
            AppDimensions.s8,
            AppDimensions.s16,
            AppDimensions.s10,
          ),
          child: Text(
            '${_stageLabel(selected)} · ${leads.length} ${leads.length == 1 ? 'lead' : 'leads'}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Expanded(
          child: leads.isEmpty
              ? const Center(child: Text('No leads in this stage'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.s16,
                    0,
                    AppDimensions.s16,
                    AppDimensions.s16,
                  ),
                  itemCount: leads.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimensions.s8),
                  itemBuilder: (_, index) => _LeadRecord(lead: leads[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildBoard(BuildContext context, List<String> stages) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(context.adaptive.gutter),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: stages.map((stage) {
          final leads = _leadsFor(stage);
          final color = _stageColor(context, stage);
          return Container(
            width: context.isLarge ? 300 : 270,
            margin: const EdgeInsets.only(right: AppDimensions.s12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimensions.r12),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.s14),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s8),
                      Expanded(
                        child: Text(
                          _stageLabel(stage),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      Badge(
                        backgroundColor: color,
                        label: Text('${leads.length}'),
                      ),
                    ],
                  ),
                ),
                Divider(color: Theme.of(context).colorScheme.outline),
                Expanded(
                  child: leads.isEmpty
                      ? Center(
                          child: Text(
                            'No leads',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppDimensions.s8),
                          itemCount: leads.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppDimensions.s8),
                          itemBuilder: (_, index) =>
                              _LeadRecord(lead: leads[index]),
                        ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  List<CrmLeadEntity> _leadsFor(String stage) => widget.leads
      .where((lead) => lead.status.toUpperCase() == stage)
      .toList();

  String _stageLabel(String stage) => stage
      .toLowerCase()
      .split('_')
      .map((word) => word.isEmpty
          ? word
          : '${word.characters.first.toUpperCase()}${word.substring(1)}')
      .join(' ');

  Color _stageColor(BuildContext context, String stage) {
    final colors = Theme.of(context).colorScheme;
    return switch (stage) {
      'WON' => AppColors.success,
      'LOST' => colors.error,
      'UNANSWERED' || 'NO_RESPONSE' => AppColors.warning,
      'NEW' || 'CONTACTED' => colors.secondary,
      _ => colors.primary,
    };
  }
}

class _LeadRecord extends StatelessWidget {
  final CrmLeadEntity lead;

  const _LeadRecord({required this.lead});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contact = lead.phone.isNotEmpty ? lead.phone : lead.email;

    return AppRecordRow(
      padding: const EdgeInsets.all(AppDimensions.s12),
      title: lead.customerName,
      subtitle: contact.isEmpty ? 'No contact information' : contact,
      metadata: Wrap(
        spacing: AppDimensions.s8,
        runSpacing: AppDimensions.s4,
        children: [
          StatusPill(
            label: lead.source,
            bg: lead.sourceColor.withValues(alpha: 0.10),
            fg: lead.sourceColor,
          ),
          Text(
            lead.assignedTo.isEmpty ? 'Unassigned' : lead.assignedTo,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: () => LeadDetailSheet.show(context, lead),
    );
  }
}
