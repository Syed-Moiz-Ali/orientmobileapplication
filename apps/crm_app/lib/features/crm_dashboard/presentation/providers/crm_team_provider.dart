import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class TeamNotifier extends AsyncNotifier<List<TeamMemberEntity>> {
  @override
  Future<List<TeamMemberEntity>> build() async {
    final repo = ref.read(crmRepositoryProvider);
    return repo.getTeamMembers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(crmRepositoryProvider);
      return repo.getTeamMembers();
    });
  }
}

final teamMembersProvider = AsyncNotifierProvider<TeamNotifier, List<TeamMemberEntity>>(
  TeamNotifier.new,
);

final teamMemberNamesProvider = Provider<Future<List<String>>>((ref) async {
  final members = await ref.watch(teamMembersProvider.future);
  return members.map((m) => m.name).toList();
});
