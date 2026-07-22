import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:orientmobileapplication/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_surface_card.dart';

class CrmRecentLeadsCard extends StatelessWidget {
  final List<CrmLeadEntity> leads;
  const CrmRecentLeadsCard({super.key, required this.leads});

  @override
  Widget build(BuildContext context) {
    return CrmSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: CrmColors.accentLight,
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: Row(
              children: [
                _th('S.No', flex: 1),
                _th('Lead Number', flex: 3),
                _th('Customer Name', flex: 3),
                _th('Source', flex: 2),
                _th('Status', flex: 2),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
          ...leads.asMap().entries.map(
            (e) => _LeadRow(lead: e.value, index: e.key),
          ),
        ],
      ),
    );
  }

  Widget _th(String text, {int flex = 2}) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: const TextStyle(
        color: CrmColors.accent,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    ),
  );
}

class _LeadRow extends StatelessWidget {
  final CrmLeadEntity lead;
  final int index;
  const _LeadRow({required this.lead, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: index.isEven ? AppColors.surfaceAlt : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.r8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${lead.sno}',
              style: const TextStyle(color: CrmColors.textM, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              lead.leadNumber,
              style: const TextStyle(
                color: CrmColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              lead.customerName,
              style: const TextStyle(color: CrmColors.textB, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: lead.sourceColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.r8),
              ),
              child: Text(
                lead.source,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: lead.sourceColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: lead.statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.r8),
              ),
              child: Text(
                lead.status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: lead.statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
