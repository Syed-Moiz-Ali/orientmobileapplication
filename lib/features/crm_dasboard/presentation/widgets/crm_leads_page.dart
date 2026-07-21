import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/crm_constants.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/providers/crm_lead_provider.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/providers/crm_ui_provider.dart';
import 'package:orientmobileapplication/features/crm_dasboard/domain/entities/crm_entities.dart';

class CrmLeadsPage extends ConsumerWidget {
  const CrmLeadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.read(crmUiProvider.notifier);
    final leadNotifier = ref.read(crmLeadProvider.notifier);
    final leads = leadNotifier.filteredLeads;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: CrmColors.accentLight,
                  borderRadius: BorderRadius.circular(AppDimensions.r20),
                  border: Border.all(color: CrmColors.accent.withValues(alpha: 0.3)),
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
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.s16),
            itemCount: leads.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.s10),
            itemBuilder: (_, i) => _CrmLeadDetailCard(lead: leads[i]),
          ),
        ),
      ],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
              const SizedBox(width: AppDimensions.s8),
              const Icon(
                Icons.person_outline_rounded,
                color: CrmColors.textM,
                size: 13,
              ),
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
