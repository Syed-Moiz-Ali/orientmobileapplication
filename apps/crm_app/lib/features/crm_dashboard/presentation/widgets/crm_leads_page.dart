import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_board_filter.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/connect_integration_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_kanban_view.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_detail_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_form_sheet.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';

/// Deal terminal: dense sortable table or Kanban swimlanes over the same
/// live leads, source + agent + stage filters, and a side dossier on wide
/// screens. Sorting and the agent/stage filters are presentation-only state
/// applied locally over the frozen `filteredLeads`; stage moves reuse the
/// exact status-change payload through the existing `updateLead` endpoint.
class CrmLeadsPage extends ConsumerStatefulWidget {
  const CrmLeadsPage({super.key});

  @override
  ConsumerState<CrmLeadsPage> createState() => _CrmLeadsPageState();
}

class _CrmLeadsPageState extends ConsumerState<CrmLeadsPage> {
  bool _kanbanMode = false;
  String? _selectedLeadId;
  int _sortIndex = 0;
  bool _sortAscending = true;
  String _agentFilter = '';

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final ui = ref.read(crmUiProvider.notifier);
    final integrations = ui.integrations;
    final meta = integrations.where((i) => i.isMeta).firstOrNull;
    final anyConnected = integrations.any((i) => i.connected);
    final leadNotifier = ref.read(crmLeadProvider.notifier);
    final sourceFilter = ref.watch(crmLeadSourceFilterProvider);
    final stageFilter = ref.watch(crmLeadStageFilterProvider);
    final leads = _visibleLeads(leadNotifier.filteredLeads);
    final adaptive = context.adaptive;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: AppSearchField(
                  hintText: t.leadsSearch,
                  onChanged: ui.updateSearch,
                ),
              ),
              const SizedBox(width: 10),
              Semantics(
                button: true,
                label: _kanbanMode ? t.leadsTableView : t.leadsKanbanView,
                excludeSemantics: true,
                child: IconButton.filledTonal(
                  tooltip: _kanbanMode ? t.leadsTableView : t.leadsKanbanView,
                  onPressed: () =>
                      setState(() => _kanbanMode = !_kanbanMode),
                  icon: Icon(
                    _kanbanMode
                        ? Icons.view_list_rounded
                        : Icons.space_dashboard_outlined,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => leadNotifier.refresh(),
            color: CrmColors.accent,
            child: leads.isEmpty
                ? _buildEmptyState(
                    context,
                    ref,
                    anyConnected,
                    meta?.connected ?? false,
                  )
                : Column(
                    children: [
                      _filterToolbar(
                        context,
                        ref,
                        leads,
                        sourceFilter,
                        stageFilter,
                        leadNotifier,
                      ),
                      Expanded(
                        child: adaptive.isCompact && !_kanbanMode
                            ? _buildList(context, leads)
                            : _kanbanMode
                            ? CrmKanbanView(leads: leads)
                            : adaptive.isCompact
                            ? _buildList(context, leads)
                            : AppMasterDetailScaffold(
                                master: _buildTable(context, leads),
                                detail: _buildDossier(context, leads),
                                detailOpen: _selectedLeadId != null,
                                placeholder: Center(
                                  child: Text(
                                    t.leadsSearch,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  /// Frozen source/search results plus presentation-only agent + stage
  /// filters and local sorting. No provider logic is touched.
  List<CrmLeadEntity> _visibleLeads(List<CrmLeadEntity> base) {
    final stageFilter = ref.read(crmLeadStageFilterProvider);
    var result = base;
    if (stageFilter.isNotEmpty) {
      result = result
          .where((l) => l.status.toUpperCase() == stageFilter.toUpperCase())
          .toList();
    }
    if (_agentFilter.isNotEmpty) {
      result = result.where((l) => l.assignedTo == _agentFilter).toList();
    }
    result = List.of(result);
    result.sort((a, b) {
      final cmp = _sortIndex == 1
          ? a.leadValue.compareTo(b.leadValue)
          : a.customerName.toLowerCase().compareTo(
              b.customerName.toLowerCase(),
            );
      return _sortAscending ? cmp : -cmp;
    });
    return result;
  }

  Widget _filterToolbar(
    BuildContext context,
    WidgetRef ref,
    List<CrmLeadEntity> leads,
    String sourceFilter,
    String stageFilter,
    CrmLeadNotifier leadNotifier,
  ) {
    final t = context.cx;
    final sources = <String>{
      for (final l in ref.read(crmLeadProvider)) l.source,
    }.where((s) => s.isNotEmpty).toList()
      ..sort();
    final agents = <String>{
      for (final l in ref.read(crmLeadProvider)) l.assignedTo,
    }.where((s) => s.isNotEmpty).toList()
      ..sort();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppFilterBar(
                  options: [t.filterAll, ...sources],
                  selected: sourceFilter.isEmpty
                      ? t.filterAll
                      : (sources.contains(sourceFilter) ? sourceFilter : null),
                  showAllOption: false,
                  onSelected: (option) {
                    final value = option == null || option == t.filterAll
                        ? ''
                        : option;
                    ref
                        .read(crmLeadSourceFilterProvider.notifier)
                        .state = value;
                    leadNotifier.refresh();
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: () => LeadFormSheet.show(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(t.leadsAdd),
              ),
            ],
          ),
          if (agents.isNotEmpty) ...[
            const SizedBox(height: 8),
            AppFilterBar(
              options: [t.filterAll, ...agents],
              selected: _agentFilter.isEmpty
                  ? t.filterAll
                  : (agents.contains(_agentFilter) ? _agentFilter : null),
              showAllOption: false,
              onSelected: (option) => setState(() {
                _agentFilter = (option == null || option == t.filterAll)
                    ? ''
                    : option;
              }),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              StatusPill(
                label: t.leadsCount(leads.length),
                fg: Theme.of(context).colorScheme.primary,
                bg: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.10),
              ),
              if (stageFilter.isNotEmpty) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      ref.read(crmLeadStageFilterProvider.notifier).state = '',
                  child: StatusPill(
                    label: '× $stageFilter',
                    fg: Theme.of(context).colorScheme.onSurfaceVariant,
                    bg: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<CrmLeadEntity> leads) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: leads.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final lead = leads[index];
        final contact = lead.phone.isNotEmpty ? lead.phone : lead.email;
        return AppRecordRow(
          title: lead.customerName.isEmpty ? lead.leadNumber : lead.customerName,
          subtitle: contact,
          metadata: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusPill(
                label: lead.status,
                bg: lead.statusColor.withValues(alpha: 0.10),
                fg: lead.statusColor,
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  'AED ${lead.leadValue.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => LeadDetailSheet.show(context, lead),
        );
      },
    );
  }

  Widget _buildTable(BuildContext context, List<CrmLeadEntity> leads) {
    final t = context.cx;
    return AppTable<CrmLeadEntity>(
      columns: [
        AppTableColumn(label: t.colLead, flex: 3, sortable: true),
        AppTableColumn(label: t.colPhone, flex: 2),
        AppTableColumn(label: t.colValue, flex: 2, numeric: true, sortable: true),
        AppTableColumn(label: t.colStage, flex: 2),
        AppTableColumn(label: t.colAgent, flex: 2),
      ],
      items: leads,
      sortIndex: _sortIndex == 0 ? 0 : 2,
      sortAscending: _sortAscending,
      onSort: (index) => setState(() {
        final mapped = index == 0 ? 0 : 1;
        if (_sortIndex == mapped) {
          _sortAscending = !_sortAscending;
        } else {
          _sortIndex = mapped;
          _sortAscending = true;
        }
      }),
      onRowTap: (lead) => setState(() => _selectedLeadId = lead.id),
      isSelected: (lead) => lead.id == _selectedLeadId,
      cells: (context, lead) => [
        Text(
          lead.customerName.isEmpty ? lead.leadNumber : lead.customerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            lead.phone,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            'AED ${lead.leadValue.toStringAsFixed(0)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        StatusPill(
          label: lead.status,
          bg: lead.statusColor.withValues(alpha: 0.10),
          fg: lead.statusColor,
        ),
        Text(
          lead.assignedTo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
      compactBuilder: (context, lead) => AppRecordRow(
        title: lead.customerName.isEmpty ? lead.leadNumber : lead.customerName,
        subtitle: lead.phone,
        onTap: () => LeadDetailSheet.show(context, lead),
      ),
    );
  }

  /// Side dossier for the selected lead: the same real record the sheet
  /// shows, with call/WhatsApp/edit actions and a way into the full sheet.
  /// Read-only composition over frozen fields — no new data, no new logic.
  Widget _buildDossier(BuildContext context, List<CrmLeadEntity> leads) {
    final t = context.cx;
    final lead = leads.where((l) => l.id == _selectedLeadId).firstOrNull;
    if (lead == null) return const SizedBox.shrink();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lead.customerName.isEmpty ? lead.leadNumber : lead.customerName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              StatusPill(
                label: lead.status,
                bg: lead.statusColor.withValues(alpha: 0.10),
                fg: lead.statusColor,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              'AED ${lead.leadValue.toStringAsFixed(0)} · ${lead.leadNumber}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DossierRow(label: t.dtPhone, value: lead.phone, ltr: true),
          _DossierRow(label: t.dtEmail, value: lead.email, ltr: true),
          _DossierRow(label: t.dtSource, value: lead.source),
          _DossierRow(
            label: t.dtAssigned,
            value: lead.assignedTo.isEmpty ? t.dtUnassigned : lead.assignedTo,
          ),
          _DossierRow(label: t.dtFollowUp, value: lead.followUpDate, ltr: true),
          if (lead.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              lead.notes.trim(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => LeadDetailSheet.show(context, lead),
                  icon: const Icon(Icons.open_in_full_rounded, size: 18),
                  label: Text(t.dtEdit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    bool anyConnected,
    bool metaConnected,
  ) {
    final t = context.cx;
    if (!anyConnected) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        children: [
          const SizedBox(height: 90),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: CrmColors.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: CrmColors.primary.withValues(alpha: 0.15)),
            ),
            child: const Icon(Icons.link_off_rounded, size: 38, color: CrmColors.primary),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              t.leadsNoCrm,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CrmColors.textH,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              t.leadsNoCrmBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: CrmColors.textM, fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => ConnectIntegrationSheet.show(context),
              icon: const Icon(Icons.add_link_rounded, size: 18),
              label: Text(
                t.leadsConnectNow,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CrmColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              t.leadsAutoNote,
              style: const TextStyle(color: CrmColors.textM, fontSize: 11),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        const SizedBox(height: 90),
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: CrmColors.accentLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.people_outline_rounded, size: 38, color: CrmColors.accent),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            t.leadsEmpty,
            style: const TextStyle(
              color: CrmColors.textH,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            t.leadsEmptySync(metaConnected ? 'Meta' : t.leadsPlatforms),
            textAlign: TextAlign.center,
            style: const TextStyle(color: CrmColors.textM, fontSize: 13, height: 1.5),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => ref.read(crmLeadProvider.notifier).refresh(),
            icon: const Icon(Icons.sync_rounded, size: 18),
            label: Text(
              t.leadsSyncNow,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: CrmColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            t.leadsIntegNote,
            style: const TextStyle(color: CrmColors.textM, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _DossierRow extends StatelessWidget {
  final String label;
  final String value;
  final bool ltr;

  const _DossierRow({required this.label, required this.value, this.ltr = false});

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    final text = ltr
        ? Directionality(
            textDirection: TextDirection.ltr,
            child: Text(value.trim()),
          )
        : Text(value.trim());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: text),
        ],
      ),
    );
  }
}
