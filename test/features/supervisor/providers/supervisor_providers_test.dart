import 'package:flutter_test/flutter_test.dart';
import 'package:orientmobileapplication/features/supervisor/providers/supervisor_providers.dart';

void main() {
  group('SupervisorDashboardState', () {
    test('defaults are correct', () {
      final state = SupervisorDashboardState();
      expect(state.selectedIndex, 0);
      expect(state.isDashboardLoading, false);
      expect(state.isAssignWorkLoading, false);
      expect(state.isWorkListLoading, false);
      expect(state.searchQuery, '');
      expect(state.jobCardSearch, '');
      expect(state.assignmentRows.length, 1);
      expect(state.assignmentRows.first.id, 1);
      expect(state.nextRowId, 2);
    });

    test('copyWith updates selectedIndex', () {
      final state = SupervisorDashboardState();
      final copy = state.copyWith(selectedIndex: 2);
      expect(copy.selectedIndex, 2);
    });

    test('copyWith updates searchQuery', () {
      final state = SupervisorDashboardState();
      final copy = state.copyWith(searchQuery: 'test');
      expect(copy.searchQuery, 'test');
    });

    test('copyWith updates jobCardSearch', () {
      final state = SupervisorDashboardState();
      final copy = state.copyWith(jobCardSearch: 'JC-001');
      expect(copy.jobCardSearch, 'JC-001');
    });

    test('copyWith updates assignmentRows', () {
      final state = SupervisorDashboardState();
      final copy = state.copyWith(nextRowId: 10);
      expect(copy.nextRowId, 10);
      expect(copy.assignmentRows.length, 1);
    });

    test('copyWith preserves isLoading flags', () {
      final state = SupervisorDashboardState(isDashboardLoading: true, isAssignWorkLoading: true);
      final copy = state.copyWith(selectedIndex: 1);
      expect(copy.isDashboardLoading, true);
      expect(copy.isAssignWorkLoading, true);
    });
  });
}
