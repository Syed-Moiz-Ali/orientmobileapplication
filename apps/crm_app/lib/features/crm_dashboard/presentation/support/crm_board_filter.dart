import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';

/// Presentation-only stage filter shared by the dashboard funnel and the
/// leads board.
///
/// This is UI filter state (like a tab-local toggle, but cross-page): it
/// never mutates leads, stages or tasks and never touches the frozen
/// providers. The leads page applies it locally over `filteredLeads`.
final crmLeadStageFilterProvider = StateProvider<String>((ref) => '');

/// The exact status-change payload the detail sheet sends, shared so every
/// stage move (sheet chips, kanban quick-select) writes identical fields.
/// Same keys, same values, same `updateLead` endpoint — no new behavior.
Map<String, dynamic> crmLeadStatusMap(CrmLeadEntity lead, String status) => {
  'customerName': lead.customerName,
  'phone': lead.phone,
  'email': lead.email,
  'source': lead.source,
  'assignedTo': lead.assignedTo,
  'status': status,
  'lastActivity': 'Status changed to $status',
  'notes': lead.notes,
  'leadValue': lead.leadValue,
  'followUpDate': lead.followUpDate,
};
