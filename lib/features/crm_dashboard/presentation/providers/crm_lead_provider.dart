import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class CrmLeadNotifier extends Notifier<List<CrmLeadEntity>> {
  @override
  List<CrmLeadEntity> build() {
    final ds = ref.read(crmDataSourceProvider);
    return ds.getLeads();
  }

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
