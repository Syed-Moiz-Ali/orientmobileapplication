import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/connect_integration_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_kanban_view.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_detail_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_form_sheet.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';

class CrmLeadsPage extends ConsumerStatefulWidget {
  const CrmLeadsPage({super.key});

  @override
  ConsumerState<CrmLeadsPage> createState() => _CrmLeadsPageState();
}

class _CrmLeadsPageState extends ConsumerState<CrmLeadsPage> {
  bool _kanbanMode = false;

  @override
  Widget build(BuildContext context) {
    final ui = ref.read(crmUiProvider.notifier);
    final integrations = ui.integrations;
    final meta = integrations.where((i) => i.isMeta).firstOrNull;
    final anyConnected = integrations.any((i) => i.connected);
    final leadNotifier = ref.read(crmLeadProvider.notifier);
    final sourceFilter = ref.watch(crmLeadSourceFilterProvider);
    final leads = leadNotifier.filteredLeads;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: CrmColors.textH, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search leads...',
                    hintStyle: const TextStyle(color: CrmColors.textM, fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: CrmColors.textM,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                      borderSide: const BorderSide(color: CrmColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                      borderSide: const BorderSide(color: CrmColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                      borderSide: const BorderSide(color: CrmColors.accent, width: 1.5),
                    ),
                  ),
                  onChanged: ui.updateSearch,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _kanbanMode = !_kanbanMode),
                child: Container(
                  width: 44,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _kanbanMode ? CrmColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _kanbanMode ? CrmColors.primary : CrmColors.border,
                    ),
                  ),
                  child: Icon(
                    _kanbanMode ? Icons.view_list_rounded : Icons.space_dashboard_outlined,
                    color: _kanbanMode ? Colors.white : CrmColors.textB,
                    size: 20,
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
                ? _buildEmptyState(context, ref, anyConnected, meta?.connected ?? false)
                : _kanbanMode
                    ? CrmKanbanView(leads: leads)
                    : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            _filterChip('All', '', sourceFilter, leadNotifier, ref),
                            const SizedBox(width: 8),
                            _filterChip('Meta', 'META', sourceFilter, leadNotifier, ref),
                            const SizedBox(width: 8),
                            _filterChip('Zoho', 'ZOHO', sourceFilter, leadNotifier, ref),
                            const SizedBox(width: 8),
                            _filterChip('WhatsApp', 'WhatsApp', sourceFilter, leadNotifier, ref),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => leadNotifier.refresh(),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: CrmColors.accentLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  color: CrmColors.accent,
                                  size: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: CrmColors.accentLight,
                                borderRadius: BorderRadius.circular(AppDimensions.r20),
                                border: Border.all(
                                  color: CrmColors.accent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '${leads.length} Leads',
                                style: const TextStyle(
                                  color: CrmColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => LeadFormSheet.show(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: CrmColors.green,
                                  borderRadius: BorderRadius.circular(AppDimensions.r20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_rounded, size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Add Lead',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!(meta?.connected ?? false))
                              GestureDetector(
                                onTap: () => ConnectIntegrationSheet.show(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: CrmColors.primary,
                                    borderRadius: BorderRadius.circular(AppDimensions.r20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_link_rounded, size: 13, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Connect CRM',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: leads
                              .map((l) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: GestureDetector(
                                      onTap: () => LeadDetailSheet.show(context, l),
                                      child: _CrmLeadDetailCard(lead: l),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
      BuildContext context, WidgetRef ref, bool anyConnected, bool metaConnected) {
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
          const Center(
            child: Text(
              'No third-party CRMs connected',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CrmColors.textH,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Connect Meta, Zoho or other platforms to\nautomatically fetch and manage your leads here',
              textAlign: TextAlign.center,
              style: TextStyle(color: CrmColors.textM, fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => ConnectIntegrationSheet.show(context),
              icon: const Icon(Icons.add_link_rounded, size: 18),
              label: const Text(
                'Connect Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
          const Center(
            child: Text(
              'Leads will appear here automatically once connected',
              style: TextStyle(color: CrmColors.textM, fontSize: 11),
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
          decoration: BoxDecoration(
            color: CrmColors.accentLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.people_outline_rounded, size: 38, color: CrmColors.accent),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'No leads yet',
            style: TextStyle(
              color: CrmColors.textH,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Your CRM is connected. Sync now to fetch leads\nfrom ${metaConnected ? 'Meta' : 'your connected platforms'}.',
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
            label: const Text(
              'Sync Now',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
        const Center(
          child: Text(
            'You can also manage connections in the Integrations tab',
            style: TextStyle(color: CrmColors.textM, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value, String current, CrmLeadNotifier notifier, WidgetRef ref) {
    final selected = current == value;
    return GestureDetector(
      onTap: () {
        ref.read(crmLeadSourceFilterProvider.notifier).state = selected ? '' : value;
        notifier.refresh();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? CrmColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.r20),
          border: Border.all(
            color: selected ? CrmColors.accent : CrmColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : CrmColors.textB,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CrmLeadDetailCard extends StatelessWidget {
  final CrmLeadEntity lead;
  const _CrmLeadDetailCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(color: CrmColors.border),
        boxShadow: [
          BoxShadow(
            color: CrmColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                lead.leadNumber,
                style: const TextStyle(
                  color: CrmColors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: lead.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                ),
                child: Text(
                  lead.status,
                  style: TextStyle(
                    color: lead.statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s10),
          Text(
            lead.customerName,
            style: const TextStyle(
              color: CrmColors.textH,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
          Row(
            children: [
              const Icon(Icons.phone_outlined, color: CrmColors.textM, size: 13),
              const SizedBox(width: 5),
              Text(
                lead.phone,
                style: const TextStyle(color: CrmColors.textB, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.email_outlined, color: CrmColors.textM, size: 13),
              const SizedBox(width: 5),
              Text(
                lead.email,
                style: const TextStyle(color: CrmColors.textB, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: lead.sourceColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.r8),
                ),
                child: Text(
                  lead.source,
                  style: TextStyle(
                    color: lead.sourceColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (lead.leadValue > 0) ...[
                const SizedBox(width: AppDimensions.s8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: CrmColors.greenBg,
                    borderRadius: BorderRadius.circular(AppDimensions.r8),
                  ),
                  child: Text(
                    'AED ${lead.leadValue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: CrmColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: AppDimensions.s8),
              const Icon(Icons.person_outline_rounded, color: CrmColors.textM, size: 13),
              const SizedBox(width: 4),
              Text(
                lead.assignedTo,
                style: const TextStyle(color: CrmColors.textM, fontSize: 11),
              ),
              const Spacer(),
              const Icon(Icons.access_time_rounded, color: CrmColors.textM, size: 11),
              const SizedBox(width: 4),
              Text(
                lead.lastActivity,
                style: const TextStyle(color: CrmColors.textM, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
