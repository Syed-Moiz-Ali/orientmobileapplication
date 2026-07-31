import 'package:flutter/material.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_detail_sheet.dart';

class CrmKanbanView extends StatelessWidget {
  final List<CrmLeadEntity> leads;
  const CrmKanbanView({super.key, required this.leads});

  static const _columns = ['ACTIVE', 'WON', 'LOST', 'UNANSWERED'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 250,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _columns.map((status) {
            final columnLeads = leads.where((l) => l.status.toUpperCase() == status).toList();
            return _column(context, status, columnLeads);
          }).toList(),
        ),
      ),
    );
  }

  Widget _column(BuildContext context, String status, List<CrmLeadEntity> columnLeads) {
    final (color, bg) = switch (status) {
      'WON' => (CrmColors.green, CrmColors.greenBg),
      'LOST' => (CrmColors.red, CrmColors.redBg),
      'UNANSWERED' => (CrmColors.amber, CrmColors.amberBg),
      _ => (CrmColors.accent, CrmColors.accentLight),
    };

    return Container(
      width: 240,
      height: double.infinity,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${columnLeads.length}',
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: columnLeads.isEmpty
                ? const Center(
                    child: Text(
                      'No leads',
                      style: TextStyle(color: CrmColors.textM, fontSize: 11),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 8),
                    children: columnLeads.map((l) => _card(context, l)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, CrmLeadEntity lead) {
    return GestureDetector(
      onTap: () => LeadDetailSheet.show(context, lead),
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CrmColors.border),
          boxShadow: [
            BoxShadow(
              color: CrmColors.primary.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lead.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CrmColors.textH,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: lead.sourceColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    lead.source,
                    style: TextStyle(color: lead.sourceColor, fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (lead.phone.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 11, color: CrmColors.textM),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      lead.phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: CrmColors.textB, fontSize: 11),
                    ),
                  ),
                ],
              ),
            if (lead.email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 11, color: CrmColors.textM),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      lead.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: CrmColors.textB, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              lead.assignedTo.isEmpty ? 'Unassigned' : lead.assignedTo,
              style: const TextStyle(color: CrmColors.textM, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
