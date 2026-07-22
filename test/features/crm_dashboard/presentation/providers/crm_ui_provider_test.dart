import 'package:flutter_test/flutter_test.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

void main() {
  group('CrmUiState', () {
    test('defaults via constructor are configurable', () {
      const state = CrmUiState(
        selectedIndex: 0,
        period: 'Today',
        salesperson: 'All',
        isLoading: false,
        searchQuery: '',
        notificationsEnabled: true,
        darkMode: true,
        autoAssign: true,
      );
      expect(state.selectedIndex, 0);
      expect(state.period, 'Today');
      expect(state.salesperson, 'All');
      expect(state.isLoading, false);
      expect(state.searchQuery, '');
      expect(state.notificationsEnabled, true);
      expect(state.darkMode, true);
      expect(state.autoAssign, true);
    });

    test('copyWith updates single field', () {
      const state = CrmUiState(
        selectedIndex: 0, period: 'Today', salesperson: 'All',
        isLoading: false, searchQuery: '', notificationsEnabled: true,
        darkMode: true, autoAssign: true,
      );
      final copy = state.copyWith(selectedIndex: 2);
      expect(copy.selectedIndex, 2);
      expect(copy.period, 'Today');
    });

    test('copyWith updates multiple fields', () {
      const state = CrmUiState(
        selectedIndex: 0, period: 'Today', salesperson: 'All',
        isLoading: false, searchQuery: '', notificationsEnabled: true,
        darkMode: true, autoAssign: true,
      );
      final copy = state.copyWith(isLoading: true, searchQuery: 'test');
      expect(copy.isLoading, true);
      expect(copy.searchQuery, 'test');
    });

    test('copyWith preserves other fields', () {
      const state = CrmUiState(
        selectedIndex: 3, period: 'This Month', salesperson: 'John',
        isLoading: true, searchQuery: 'search', notificationsEnabled: false,
        darkMode: false, autoAssign: false,
      );
      final copy = state.copyWith(isLoading: false);
      expect(copy.selectedIndex, 3);
      expect(copy.period, 'This Month');
      expect(copy.salesperson, 'John');
      expect(copy.notificationsEnabled, false);
      expect(copy.darkMode, false);
      expect(copy.autoAssign, false);
    });
  });
}
