import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// P3 (audit): staff/role management — the owner's missing admin flow.
class StaffMember {
  final String id, empId, name, role, branch, phone;
  final bool isActive;
  const StaffMember({
    required this.id, required this.empId, required this.name,
    required this.role, required this.branch, required this.phone,
    required this.isActive,
  });

  factory StaffMember.fromJson(Map<String, dynamic> j) => StaffMember(
        id: '${j['id']}',
        empId: j['empId'] as String? ?? '',
        name: j['name'] as String? ?? '',
        role: j['role'] as String? ?? '',
        branch: j['branch'] as String? ?? '',
        phone: '',
        isActive: j['isActive'] as bool? ?? true,
      );

  StaffMember copyWith({bool? isActive}) => StaffMember(
        id: id, empId: empId, name: name, role: role, branch: branch,
        phone: phone, isActive: isActive ?? this.isActive,
      );
}

class TeamState {
  final bool isLoading;
  final String error;
  final List<StaffMember> staff;
  const TeamState({this.isLoading = true, this.error = '', this.staff = const []});

  TeamState copyWith({bool? isLoading, String? error, List<StaffMember>? staff}) =>
      TeamState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        staff: staff ?? this.staff,
      );
}

class TeamNotifier extends Notifier<TeamState> {
  ApiClient get _client => ref.read(apiClientProvider);

  @override
  TeamState build() {
    load();
    return const TeamState();
  }

  Future<void> load() async {
    try {
      final list = (await _client.get<List<dynamic>>(
        ApiEndpoints.ownerTeam,
        fromJson: (d) => d as List<dynamic>,
      )).when(success: (d) => d, failure: (e) => throw e);
      state = state.copyWith(
        isLoading: false,
        error: '',
        staff: list
            .map((e) => StaffMember.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    } catch (e, st) {
      ref.read(loggerProvider).e('Failed to load team', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: 'Could not load team');
    }
  }

  Future<String?> addMember(Map<String, dynamic> payload) async {
    try {
      await _client.post(ApiEndpoints.ownerTeam, data: payload);
      await load();
      return null;
    } catch (e, st) {
      ref.read(loggerProvider).e('Failed to add staff', error: e, stackTrace: st);
      final message = e is ValidationException ? e.message : 'Could not add staff';
      return message;
    }
  }

  Future<void> toggleActive(StaffMember member) async {
    try {
      if (member.isActive) {
        await _client.put(ApiEndpoints.ownerTeamDeactivate(member.id));
        state = state.copyWith(
          staff: state.staff
              .map((s) => s.id == member.id ? s.copyWith(isActive: false) : s)
              .toList(),
        );
      } else {
        await _client.put(ApiEndpoints.ownerTeamById(member.id),
            data: {'isActive': true});
        state = state.copyWith(
          staff: state.staff
              .map((s) => s.id == member.id ? s.copyWith(isActive: true) : s)
              .toList(),
        );
      }
    } catch (e, st) {
      ref.read(loggerProvider).e('Toggle failed', error: e, stackTrace: st);
    }
  }
}

final teamProvider = NotifierProvider<TeamNotifier, TeamState>(TeamNotifier.new);
