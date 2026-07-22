import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class CrmLeadNotifier extends Notifier<List<CrmLeadEntity>> {
  @override
  List<CrmLeadEntity> build() => const [
    CrmLeadEntity(
      sno: 1,
      leadNumber: 'LEAD#A1023',
      customerName: 'James Anderson',
      phone: '+1 (555) 123-4567',
      email: 'james.anderson@email.com',
      source: 'WhatsApp',
      sourceColor: Color(0xFF25D366),
      assignedTo: 'John Doe',
      status: 'ACTIVE',
      statusColor: AppColors.greenAccent,
      lastActivity: '2026-04-29 14:23',
    ),
    CrmLeadEntity(
      sno: 2,
      leadNumber: 'LEAD#A1024',
      customerName: 'Emily Chen',
      phone: '+1 (555) 234-5678',
      email: 'emily.chen@email.com',
      source: 'Instagram',
      sourceColor: Color(0xFFE1306C),
      assignedTo: 'Sarah Smith',
      status: 'WON',
      statusColor: AppColors.greenAccent,
      lastActivity: '2026-04-29 13:45',
    ),
    CrmLeadEntity(
      sno: 3,
      leadNumber: 'LEAD#A1025',
      customerName: 'Michael Roberts',
      phone: '+1 (555) 345-6789',
      email: 'michael.roberts@email.com',
      source: 'Google Ads',
      sourceColor: AppColors.amber500,
      assignedTo: 'Mike Johnson',
      status: 'ACTIVE',
      statusColor: AppColors.greenAccent,
      lastActivity: '2026-04-29 12:15',
    ),
    CrmLeadEntity(
      sno: 4,
      leadNumber: 'LEAD#A1026',
      customerName: 'Sarah Williams',
      phone: '+1 (555) 456-7890',
      email: 'sarah.williams@email.com',
      source: 'Website',
      sourceColor: AppColors.cyanBright,
      assignedTo: 'John Doe',
      status: 'UNANSWERED',
      statusColor: AppColors.warning,
      lastActivity: '2026-04-28 18:30',
    ),
    CrmLeadEntity(
      sno: 5,
      leadNumber: 'LEAD#A1027',
      customerName: 'David Martinez',
      phone: '+1 (555) 567-8901',
      email: 'david.martinez@email.com',
      source: 'SMS',
      sourceColor: AppColors.purpleAccent,
      assignedTo: 'Sarah Smith',
      status: 'LOST',
      statusColor: AppColors.red500,
      lastActivity: '2026-04-27 09:45',
    ),
  ];

  List<CrmLeadEntity> get filteredLeads {
    final query = ref.read(crmUiProvider).searchQuery;
    if (query.isEmpty) return state;
    final q = query.toLowerCase();
    return state
        .where((l) =>
            l.customerName.toLowerCase().contains(q) ||
            l.leadNumber.toLowerCase().contains(q) ||
            l.source.toLowerCase().contains(q))
        .toList();
  }
}

final crmLeadProvider = NotifierProvider<CrmLeadNotifier, List<CrmLeadEntity>>(
  CrmLeadNotifier.new,
);
