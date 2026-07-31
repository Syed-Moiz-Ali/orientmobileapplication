import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

final crmLeadSourceFilterProvider = StateProvider<String>((ref) => '');

class CrmLeadNotifier extends Notifier<List<CrmLeadEntity>> {
  @override
  List<CrmLeadEntity> build() {
    final repo = ref.read(crmRepositoryProvider);
    return repo.getLeads();
  }

  Future<void> refresh() async {
    await ref.read(crmRepositoryProvider).refreshLeads();
    ref.invalidateSelf();
  }

  Future<void> createLead(Map<String, dynamic> data) async {
    await ref.read(crmRepositoryProvider).createLead(data);
    ref.invalidateSelf();
  }

  Future<void> updateLead(String id, Map<String, dynamic> data) async {
    await ref.read(crmRepositoryProvider).updateLead(id, data);
    ref.invalidateSelf();
  }

  Future<void> deleteLead(String id) async {
    await ref.read(crmRepositoryProvider).deleteLead(id);
    ref.invalidateSelf();
  }

  List<CrmLeadEntity> get filteredLeads {
    final filter = ref.read(crmLeadSourceFilterProvider);
    final query = ref.read(crmUiProvider).searchQuery;
    var result = state;
    if (filter.isNotEmpty) {
      result = result.where((l) => l.source.toLowerCase() == filter.toLowerCase()).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where((l) =>
              l.customerName.toLowerCase().contains(q) ||
              l.leadNumber.toLowerCase().contains(q) ||
              l.source.toLowerCase().contains(q) ||
              l.phone.toLowerCase().contains(q) ||
              l.email.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }
}

final crmLeadProvider = NotifierProvider<CrmLeadNotifier, List<CrmLeadEntity>>(
  CrmLeadNotifier.new,
);
