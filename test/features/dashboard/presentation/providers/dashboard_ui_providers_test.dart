import 'package:flutter_test/flutter_test.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/providers/dashboard_ui_providers.dart';

void main() {
  group('DashboardUiState', () {
    test('defaults are correct', () {
      const state = DashboardUiState();
      expect(state.selectedIndex, 0);
      expect(state.period, 'This Week');
      expect(state.isLoading, false);
      expect(state.selectedUser, '');
      expect(state.messageText, '');
      expect(state.sentMessages, isEmpty);
    });

    test('copyWith updates selectedIndex', () {
      const state = DashboardUiState();
      final copy = state.copyWith(selectedIndex: 2);
      expect(copy.selectedIndex, 2);
      expect(copy.period, 'This Week');
    });

    test('copyWith updates period', () {
      const state = DashboardUiState();
      final copy = state.copyWith(period: 'Today');
      expect(copy.period, 'Today');
    });

    test('copyWith updates isLoading', () {
      const state = DashboardUiState();
      final copy = state.copyWith(isLoading: true);
      expect(copy.isLoading, true);
    });

    test('copyWith updates selectedUser', () {
      const state = DashboardUiState();
      final copy = state.copyWith(selectedUser: 'John');
      expect(copy.selectedUser, 'John');
    });

    test('copyWith updates messageText', () {
      const state = DashboardUiState();
      final copy = state.copyWith(messageText: 'Hello');
      expect(copy.messageText, 'Hello');
    });
  });
}
