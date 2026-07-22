import 'package:flutter_test/flutter_test.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';
import 'package:orientmobileapplication/features/auth/presentation/providers/role_selection_provider.dart';

void main() {
  group('RoleSelectionState', () {
    test('defaults are correct', () {
      const state = RoleSelectionState();
      expect(state.selectedRole, isNull);
      expect(state.isLoading, false);
    });

    test('isLoadingFor returns true only when loading that role', () {
      const state = RoleSelectionState(selectedRole: UserRole.owner, isLoading: true);
      expect(state.isLoadingFor(UserRole.owner), isTrue);
      expect(state.isLoadingFor(UserRole.advisor), isFalse);
    });

    test('isLoadingFor returns false when not loading', () {
      const state = RoleSelectionState();
      expect(state.isLoadingFor(UserRole.owner), isFalse);
    });

    test('copyWith updates selectedRole', () {
      const state = RoleSelectionState();
      final copy = state.copyWith(selectedRole: UserRole.technician);
      expect(copy.selectedRole, UserRole.technician);
      expect(copy.isLoading, false);
    });

    test('copyWith updates isLoading', () {
      const state = RoleSelectionState();
      final copy = state.copyWith(isLoading: true);
      expect(copy.isLoading, true);
      expect(copy.selectedRole, isNull);
    });
  });
}
