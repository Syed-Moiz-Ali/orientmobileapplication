// Deal terminal: sortable table or Kanban swimlanes over the same
// live leads, source + agent filters, and a side dossier on wide
// screens. Sorting and the agent/stage filters are presentation-only state
// applied locally over the frozen `filteredLeads`; stage moves reuse the
// exact status-change payload through the existing `updateLead` endpoint.
//
// Presentation-only rebuild (brief `docs/ui-redesign/briefs/crm-leads-list.md`):
// AppPageHeader + header find-aids (search/filter icons only when > 5
// loaded leads), borderless cards with Call direct on each card, sheets for
// search/filter, AppEmptyState/AppShimmerSkeleton. Providers, filters,
// sort, refresh, routes and Keys are unchanged.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_board_filter.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/lead_contact_actions.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/connect_integration_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_kanban_view.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_leads_filter_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_leads_search_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_detail_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_form_sheet.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';

class CrmLeadsPage extends ConsumerStatefulWidget {
  const CrmLeadsPage({super.key});

  @override
  ConsumerState<CrmLeadsPage> createState() => _CrmLeadsPageState();
}

/// Sentence-case display for backend stage codes (`ACTIVE` -> `Active`,
/// `NO_RESPONSE` -> `No Response`). Matching stays uppercase; only the
/// chip label is reformatted (same class of display fix as the
/// vehicles-list `.toUpperCase()` removal).
String _displayStatus(String status) {
  final words = status.toLowerCase().split('_');
  return words
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

AppStatusKind _statusKind(String status) {
  switch (status.toUpperCase()) {
    case 'WON':
      return AppStatusKind.success;
    case 'LOST':
      return AppStatusKind.error;
    case 'UNANSWERED':
    case 'NO_RESPONSE':
      return AppStatusKind.warning;
    default:
      return AppStatusKind.accent;
  }
}

/// Customer-name-first title (C16 hierarchy, round-2 adversarial fix #1):
/// the thing the user recognizes — name, then dialable contact, then email —
/// with the database ID only as a last resort. The ID always also renders as
/// small trailing meta (value line), so cards/table/dossier never lead with
/// it. Display mapping only; entity fields are read verbatim.
String _leadTitle(CrmLeadEntity lead) {
  if (lead.customerName.trim().isNotEmpty) return lead.customerName;
  if (lead.phone.trim().isNotEmpty) return lead.phone;
  if (lead.email.trim().isNotEmpty) return lead.email;
  return lead.leadNumber;
}

/// Why-line from existing fields only (round-2 fix #6): source/agent/
/// last-touch verbatim values joined for display; never invented. Empty parts
/// are dropped; an empty result renders nothing.
String _leadContextLine(CrmLeadEntity lead) {
  return <String>[
    lead.source.trim(),
    lead.assignedTo.trim(),
    lead.lastActivity.trim(),
  ].where((s) => s.isNotEmpty).join(' · ');
}

class _CrmLeadsPageState extends ConsumerState<CrmLeadsPage> {
  bool _kanbanMode = false;
  String? _selectedLeadId;
  int _sortIndex = 0;
  bool _sortAscending = true;
  String _agentFilter = '';

  /// Scroll anchors for search-result reveals (presentation only).
  final Map<String, GlobalKey> _scrollKeys = {};

  GlobalKey _scrollKeyFor(String id) =>
      _scrollKeys.putIfAbsent(id, () => GlobalKey());

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final ui = ref.read(crmUiProvider.notifier);
    final integrations = ui.integrations;
    final meta = integrations.where((i) => i.isMeta).firstOrNull;
    final anyConnected = integrations.any((i) => i.connected);
    final leadNotifier = ref.read(crmLeadProvider.notifier);
    final sourceFilter = ref.watch(crmLeadSourceFilterProvider);
    final stageFilter = ref.watch(crmLeadStageFilterProvider);
    final uiState = ref.watch(crmUiProvider);
    final totalLoaded = ref.watch(crmLeadProvider).length;
    final leads = _visibleLeads(leadNotifier.filteredLeads);
    final adaptive = context.adaptive;
    _scrollKeys.removeWhere(
      (id, _) => !leads.any((lead) => lead.id == id),
    );

    // Progressive disclosure (the ONE sanctioned U1 exception on this
    // screen, same as the vehicles list): the search + filter find-aids
    // appear ONLY when the loaded list has MORE THAN 5 items.
    // Scope note (round-2 fix #4): this icon opens the LIST-scoped sheet
    // (filters the loaded leads in place). The shell command palette
    // (WorkspaceAppBar search trigger -> jump-to-dossier over the first 50)
    // is app-chrome in a different scope with a different target, so the
    // pair is not a same-target duplicate and is not collapsed.
    final showFindAids = totalLoaded > 5;
    final filtersActive =
        sourceFilter.isNotEmpty || stageFilter.isNotEmpty || _agentFilter.isNotEmpty;
    final subtitle = filtersActive
        ? '${t.leadsCountN(leads.length)} · ${t.leadsFilterTitle}'
        : t.leadsCountN(leads.length);

    final sources = <String>{
      for (final l in ref.read(crmLeadProvider)) l.source,
    }.where((s) => s.isNotEmpty).toList()
      ..sort();
    final agents = <String>{
      for (final l in ref.read(crmLeadProvider)) l.assignedTo,
    }.where((s) => s.isNotEmpty).toList()
      ..sort();

    return Column(
      children: [
        Padding(
          // Plain-Row header (F6, owner/supervisor precedent): the title and
          // the search/filter find-aids share ONE Row so the icons stay
          // top-end same-row on compact. AppPageHeader stacked every action
          // below the title on compact (Align centerLeft), which read as a
          // body toolbar row. Four trailing actions cannot share one 360px
          // row with the title, so on compact the view toggle + Add sit in
          // an end-aligned second header row (still header chrome, never
          // body); on wide screens everything shares one row as before.
          // Rows mirror in RTL, so icons land top-start in Arabic (correct
          // end side). Same >5 conditions, same sheets, same targets —
          // placement only.
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final titleBlock = Expanded(
                child: Semantics(
                  header: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.navLeads,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (totalLoaded > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
              List<Widget> findAids() => [
                    if (showFindAids) ...[
                      AppIconButton(
                        icon: Icons.search_rounded,
                        tooltip: t.leadsSearchTitle,
                        onPressed: () => showCrmLeadsSearchSheet(
                          context,
                          leads: leads,
                          onSelect: (lead) => _revealLead(
                              lead, adaptive.isCompact && !_kanbanMode),
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.filter_list_rounded,
                        tooltip: t.leadsFilterTitle,
                        onPressed: () async {
                          final pick = await showCrmLeadsFilterSheet(
                            context,
                            sources: sources,
                            agents: agents,
                            source: sourceFilter,
                            agent: _agentFilter,
                          );
                          if (pick == null || !mounted) return;
                          ref
                              .read(crmLeadSourceFilterProvider.notifier)
                              .state = pick.source;
                          setState(() => _agentFilter = pick.agent);
                          leadNotifier.refresh();
                        },
                      ),
                    ],
                  ];
              List<Widget> utilityActions() => [
                    AppIconButton(
                      icon: _kanbanMode
                          ? Icons.view_list_rounded
                          : Icons.space_dashboard_outlined,
                      tooltip:
                          _kanbanMode ? t.leadsTableView : t.leadsKanbanView,
                      onPressed: () =>
                          setState(() => _kanbanMode = !_kanbanMode),
                    ),
                    if (totalLoaded > 0)
                      TextButton.icon(
                        onPressed: () => LeadFormSheet.show(context),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(t.leadsAdd),
                      ),
                  ];
              if (constraints.maxWidth >= 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    const SizedBox(width: AppDimensions.s12),
                    ...findAids(),
                    const SizedBox(width: AppDimensions.s8),
                    ...utilityActions(),
                  ],
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleBlock,
                      const SizedBox(width: AppDimensions.s12),
                      ...findAids(),
                    ],
                  ),
                  if (utilityActions().isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Wrap(
                        spacing: AppDimensions.s8,
                        runSpacing: AppDimensions.s8,
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: utilityActions(),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        if (stageFilter.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppChip(
                label: '× $stageFilter',
                selected: true,
                onSelected: (_) => ref
                    .read(crmLeadStageFilterProvider.notifier)
                    .state = '',
              ),
            ),
          ),
        ],
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => leadNotifier.refresh(),
            child: _body(
              leads: leads,
              totalLoaded: totalLoaded,
              anyConnected: anyConnected,
              metaConnected: meta?.connected ?? false,
              isLoading: uiState.isLoading,
              adaptiveCompact: adaptive.isCompact,
            ),
          ),
        ),
      ],
    );
  }

  Widget _body({
    required List<CrmLeadEntity> leads,
    required int totalLoaded,
    required bool anyConnected,
    required bool metaConnected,
    required bool isLoading,
    required bool adaptiveCompact,
  }) {
    if (isLoading && leads.isEmpty) {
      // Skeleton mirrors the cards: header lines + card shape.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          AppShimmerSkeleton(width: 160, height: 26),
          SizedBox(height: AppDimensions.s10),
          AppShimmerSkeleton(width: 180, height: 12),
          SizedBox(height: AppDimensions.s20),
          AppShimmerSkeleton.card(height: 148),
          SizedBox(height: AppDimensions.s12),
          AppShimmerSkeleton.card(height: 148),
        ],
      );
    }
    if (leads.isEmpty) {
      // A filtered-to-zero list is a no-match (with Clear), not an empty
      // workspace: the old tree showed the connect/sync empties here.
      if (totalLoaded > 0) return _buildNoMatch();
      return _buildEmptyState(anyConnected, metaConnected);
    }
    if (adaptiveCompact && !_kanbanMode) return _buildList(leads);
    if (_kanbanMode) return CrmKanbanView(leads: leads);
    if (adaptiveCompact) return _buildList(leads);
    return _buildWide(leads);
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

  void _revealLead(CrmLeadEntity lead, bool listMode) {
    if (listMode) {
      final ctx = _scrollKeys[lead.id]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
        );
        return;
      }
    }
    if (!mounted) return;
    if (_kanbanMode) {
      LeadDetailSheet.show(context, lead);
    } else {
      setState(() => _selectedLeadId = lead.id);
    }
  }

  Widget _buildList(List<CrmLeadEntity> leads) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: leads.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final lead = leads[index];
        return Container(
          key: _scrollKeyFor(lead.id),
          child: _LeadCard(
            lead: lead,
            onOpen: () => LeadDetailSheet.show(context, lead),
            onEdit: () => LeadFormSheet.show(context, lead: lead),
            onDelete: () => _confirmDelete(lead),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(CrmLeadEntity lead) async {
    final t = context.cx;
    final confirmed = await showAppDialog<bool>(
      context,
      title: t.dtDeleteTitle,
      message: t.dtDeleteBody(
        lead.customerName.isEmpty ? lead.leadNumber : lead.customerName,
        lead.leadNumber,
      ),
      secondaryLabel: t.dtCancel,
      primaryLabel: t.dtDelete,
      destructive: true,
      onPrimary: () => Navigator.of(context).pop(true),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(crmLeadProvider.notifier).deleteLead(lead.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.dtDeleted),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildNoMatch() {
    final t = context.cx;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 64),
        AppEmptyState(
          icon: Icons.search_off_rounded,
          title: t.leadsFilterNoMatch,
          message: t.leadsCountN(0),
          actionLabel: t.leadsFilterClear,
          onAction: () {
            ref.read(crmLeadSourceFilterProvider.notifier).state = '';
            ref.read(crmLeadStageFilterProvider.notifier).state = '';
            setState(() => _agentFilter = '');
            ref.read(crmLeadProvider.notifier).refresh();
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool anyConnected, bool metaConnected) {
    final t = context.cx;
    if (!anyConnected) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 64),
          AppEmptyState(
            icon: Icons.link_off_rounded,
            title: t.leadsNoCrm,
            message: t.leadsNoCrmBody,
            actionLabel: t.leadsConnectNow,
            onAction: () => ConnectIntegrationSheet.show(context),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              t.leadsAutoNote,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // Round-2 fix #3: empties keep their single primary action
          // (Connect/Sync) and gain a secondary Add path below it, so a
          // hand-entered lead is never a dead end. Header-XOR-empty holds:
          // the header Add renders only when non-empty (totalLoaded > 0).
          const SizedBox(height: 4),
          Center(
            child: TextButton.icon(
              onPressed: () => LeadFormSheet.show(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(t.leadsAdd),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 64),
        AppEmptyState(
          icon: Icons.people_outline_rounded,
          title: t.leadsEmpty,
          message: t.leadsEmptySync(metaConnected ? 'Meta' : t.leadsPlatforms),
          actionLabel: t.leadsSyncNow,
          onAction: () => ref.read(crmLeadProvider.notifier).refresh(),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            t.leadsIntegNote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // Same secondary Add path as above (fix #3, header-XOR-empty).
        const SizedBox(height: 4),
        Center(
          child: TextButton.icon(
            onPressed: () => LeadFormSheet.show(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(t.leadsAdd),
          ),
        ),
      ],
    );
  }

  Widget _buildWide(List<CrmLeadEntity> leads) {
    final t = context.cx;
    return AppMasterDetailScaffold(
      // Caller-local pane floor (same class of caller param as the advisor
      // list's masterMaxWidth): at 768px the default 45% master (~345px)
      // leaves the Agent header ~2px short of whole. 380px keeps every
      // header + cell whole; wider screens still clamp to 420. Detail keeps
      // ~387px for the dossier. No shared-atom change.
      masterMinWidth: 380,
      master: _buildTable(leads),
      detail: _buildDossier(leads),
      detailOpen: _selectedLeadId != null,
      placeholder: Center(
        child: Text(
          t.leadsSelectLead,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildTable(List<CrmLeadEntity> leads) {
    final t = context.cx;
    return AppTable<CrmLeadEntity>(
      columns: [
        AppTableColumn(label: t.colLead, flex: 4, sortable: true),
        AppTableColumn(label: t.colPhone, flex: 3),
        AppTableColumn(label: t.colValue, flex: 3, numeric: true, sortable: true),
        // Wide-tablet fix (U5, round-2 fix #2): the master pane is ~45% of
        // 768px, so every text cell wraps in a scale-down FittedBox exactly
        // like the round-1 Stage fix — whole primary text, never mid-word
        // ellipsis. Flex leans toward Lead/Phone/Value/Stage; compact cards
        // are untouched (separate _buildList branch).
        AppTableColumn(label: t.colStage, flex: 3),
        AppTableColumn(label: t.colAgent, flex: 2),
      ],
      // Mirror the header flexes in the rows (AppTableRow defaults to 1
      // per cell, which squeezed Stage even narrower than the header).
      cellFlex: const [4, 3, 3, 3, 2],
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
        // Whole-word scale-down (never mid-word ellipsis): softWrap false +
        // visible overflow lets the Text size to its intrinsic single-line
        // width so the FittedBox scales the whole string instead of cutting
        // it. Title follows the customer-name-first chain (fix #1); value is
        // grouped tabular money via the existing AppFormatters (fix #5).
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            _leadTitle(lead),
            softWrap: false,
            overflow: TextOverflow.visible,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              lead.phone,
              softWrap: false,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              AppFormatters.of(context).moneyAED(lead.leadValue),
              softWrap: false,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        // Scale-down (never mid-word wrap): if a longer stage label still
        // exceeds the tablet cell, the whole chip shrinks instead of
        // stacking one letter per line. Same record, same chip, no logic.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: AppStatusChip(
            label: _displayStatus(lead.status),
            kind: _statusKind(lead.status),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            lead.assignedTo,
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
      compactBuilder: (context, lead) => _LeadCard(
        lead: lead,
        onOpen: () => LeadDetailSheet.show(context, lead),
        onEdit: () => LeadFormSheet.show(context, lead: lead),
        onDelete: () => _confirmDelete(lead),
      ),
    );
  }

  /// Side dossier for the selected lead: the same real record the sheet
  /// shows, with call/WhatsApp/edit actions and a way into the full sheet.
  /// Read-only composition over frozen fields — no new data, no new logic.
  Widget _buildDossier(List<CrmLeadEntity> leads) {
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
                  _leadTitle(lead),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AppStatusChip(
                label: _displayStatus(lead.status),
                kind: _statusKind(lead.status),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${AppFormatters.of(context).moneyAED(lead.leadValue)} · ${lead.leadNumber}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppDataRow(label: t.dtPhone, value: lead.phone),
          AppDataRow(label: t.dtEmail, value: lead.email),
          AppDataRow(label: t.dtSource, value: lead.source, forceValueLtr: false),
          AppDataRow(
            label: t.dtAssigned,
            value: lead.assignedTo.isEmpty ? t.dtUnassigned : lead.assignedTo,
            forceValueLtr: false,
          ),
          AppDataRow(label: t.dtFollowUp, value: lead.followUpDate),
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
                child: AppPillButton.secondary(
                  label: t.dtEdit,
                  onPressed: () => LeadDetailSheet.show(context, lead),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Borderless lead card (C16): title = customer name (the thing the user
/// recognizes), ONE status pill (existing `status`, sentence-case), meta =
/// contact + LTR value. Frequent action binding: Call sits DIRECTLY on the
/// card (≤ 1 tap from the list); WhatsApp/Edit/Delete live in the card
/// menu (existing destinations only). Wraps at 320px / 1.3x.
class _LeadCard extends StatelessWidget {
  final CrmLeadEntity lead;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LeadCard({
    required this.lead,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final title = _leadTitle(lead);
    final contact = lead.phone.isNotEmpty ? lead.phone : lead.email;
    final contextLine = _leadContextLine(lead);

    return AppSurfaceCard(
      outlined: false,
      onTap: onOpen,
      semanticLabel: contact.isEmpty || contact == title ? title : '$title, $contact',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AppStatusChip(
                label: _displayStatus(lead.status),
                kind: _statusKind(lead.status),
              ),
            ],
          ),
          if (contact.isNotEmpty && contact != title) ...[
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                contact,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          // Grouped tabular value (round-2 fix #5, existing AppFormatters —
          // display mapping only) with the value label and the ID as small
          // trailing meta (round-2 fix #1: plate/ID last, never the title).
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${t.colValue} · ${AppFormatters.of(context).moneyAED(lead.leadValue)} · ${lead.leadNumber}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (contextLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              contextLine,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              if (lead.phone.isNotEmpty)
                TextButton.icon(
                  onPressed: () => callLeadPhone(context, lead.phone),
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: Text(t.dtCall),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              PopupMenuButton<String>(
                tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  if (value == 'whatsapp') {
                    whatsAppLeadPhone(context, lead.phone);
                  } else if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (itemContext) => [
                  if (lead.phone.isNotEmpty)
                    PopupMenuItem(
                      value: 'whatsapp',
                      child: Text(itemContext.cx.dtWhatsApp),
                    ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(itemContext.cx.dtEdit),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      itemContext.cx.dtDelete,
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
