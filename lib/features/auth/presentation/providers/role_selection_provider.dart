import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';

class RoleSelectionState {
  final UserRole? selectedRole;
  final bool isLoading;

  const RoleSelectionState({this.selectedRole, this.isLoading = false});

  RoleSelectionState copyWith({UserRole? selectedRole, bool? isLoading}) {
    return RoleSelectionState(
      selectedRole: selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool isLoadingFor(UserRole role) => isLoading && selectedRole == role;
}

class RoleSelectionNotifier extends Notifier<RoleSelectionState> {
  @override
  RoleSelectionState build() => const RoleSelectionState();

  Future<void> selectRole(UserRole role) async {
    state = state.copyWith(selectedRole: role, isLoading: true);

    await Future.delayed(const Duration(milliseconds: 800));

    state = state.copyWith(isLoading: false);
  }

  void reset() {
    state = const RoleSelectionState();
  }
}

final roleSelectionNotifierProvider =
    NotifierProvider<RoleSelectionNotifier, RoleSelectionState>(
      RoleSelectionNotifier.new,
    );
