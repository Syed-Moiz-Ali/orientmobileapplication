import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orientmobileapplication/core/presentation/list_state.dart';
import 'package:orientmobileapplication/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/providers/dashboard_providers.dart';

void main() {
  group('DocumentExpiryState', () {
    test('defaults are correct', () {
      const state = DocumentExpiryState();
      expect(state.isLoading, true);
      expect(state.searchQuery, '');
      expect(state.items, isEmpty);
    });

    test('criticalCount returns correct count', () {
      const state = DocumentExpiryState(
        isLoading: false,
        items: [
          DocumentExpiry(empId: '1', employeeName: 'A', designation: 'Tech', documentType: 'License', expiryDate: '2024-01-01', daysLeft: 0, urgency: ExpiryUrgency.critical),
          DocumentExpiry(empId: '2', employeeName: 'B', designation: 'Tech', documentType: 'Visa', expiryDate: '2024-02-01', daysLeft: 10, urgency: ExpiryUrgency.urgent),
          DocumentExpiry(empId: '3', employeeName: 'C', designation: 'Tech', documentType: 'Passport', expiryDate: '2024-03-01', daysLeft: 20, urgency: ExpiryUrgency.critical),
        ],
      );
      expect(state.criticalCount, 2);
      expect(state.urgentCount, 1);
      expect(state.warningCount, 0);
    });
  });

  group('JobStatusState', () {
    test('defaults are correct', () {
      const state = JobStatusState();
      expect(state.isLoading, true);
      expect(state.searchQuery, '');
      expect(state.filterStage, isNull);
      expect(state.items, isEmpty);
    });

    test('filterStage is preserved in copyWith', () {
      const state = JobStatusState(filterStage: JobStage.wip);
      final copy = state.copyWith(isLoading: false);
      expect(copy.filterStage, JobStage.wip);
    });
  });

  group('PendingApprovalsState', () {
    test('defaults are correct', () {
      const state = PendingApprovalsState();
      expect(state.isLoading, true);
      expect(state.categories, isEmpty);
    });

    test('totalPending sums category counts', () {
      const state = PendingApprovalsState(
        categories: [
          ApprovalCategory(title: 'A', subtitle: 'Sub', count: 5, iconBg: Color(0xFFFF0000), icon: Icons.star),
          ApprovalCategory(title: 'B', subtitle: 'Sub', count: 3, iconBg: Color(0xFFFF0000), icon: Icons.star),
        ],
      );
      expect(state.totalPending, 8);
    });
  });

  group('PendingJobCardsState', () {
    test('defaults are correct', () {
      const state = PendingJobCardsState();
      expect(state.isLoading, true);
      expect(state.searchQuery, '');
      expect(state.items, isEmpty);
    });

    test('count getters return correct values', () {
      const state = PendingJobCardsState(
        isLoading: false,
        items: [
          PendingJobCard(jobCardId: '1', customerName: 'A', vehicleInfo: 'V1', assignedTo: 'T1', createdDate: '2024-01-01', dueDate: '2024-01-10', daysOverdue: 5, status: PendingJobCardStatus.overdue, estimatedAmount: 100),
          PendingJobCard(jobCardId: '2', customerName: 'B', vehicleInfo: 'V2', assignedTo: 'T2', createdDate: '2024-01-01', dueDate: '2024-01-10', daysOverdue: 0, status: PendingJobCardStatus.pending, estimatedAmount: 200),
          PendingJobCard(jobCardId: '3', customerName: 'C', vehicleInfo: 'V3', assignedTo: 'T3', createdDate: '2024-01-01', dueDate: '2024-01-10', daysOverdue: -2, status: PendingJobCardStatus.inProgress, estimatedAmount: 300),
        ],
      );
      expect(state.overdueCount, 1);
      expect(state.pendingCount, 1);
      expect(state.inProgressCount, 1);
    });
  });

  group('ActiveJobCardsState', () {
    test('defaults are correct', () {
      const state = ActiveJobCardsState();
      expect(state.isLoading, true);
      expect(state.searchQuery, '');
      expect(state.items, isEmpty);
    });
  });

  group('SalesInvoicesState', () {
    test('defaults are correct', () {
      const state = SalesInvoicesState();
      expect(state.isLoading, true);
      expect(state.searchQuery, '');
      expect(state.items, isEmpty);
    });

    test('totalSales sums invoice amounts', () {
      const state = SalesInvoicesState(
        isLoading: false,
        items: [
          SalesInvoice(id: '1', customerName: 'A', date: '2024-01-01', amount: 1000, status: InvoiceStatus.paid),
          SalesInvoice(id: '2', customerName: 'B', date: '2024-01-02', amount: 2500, status: InvoiceStatus.unpaid),
        ],
      );
      expect(state.totalSales, 3500);
    });
  });

  group('ListState<T> generic behavior', () {
    test('filter returns all items when searchQuery is empty', () {
      const state = ListState(items: ['a', 'b', 'c']);
      final result = state.filter((s) => s.contains('a'));
      expect(result, ['a', 'b', 'c']);
    });

    test('filter applies predicate when searchQuery is non-empty', () {
      const state = ListState(searchQuery: 'x', items: ['a', 'b', 'c']);
      final result = state.filter((s) => s.contains('x'));
      expect(result, isEmpty);
    });

    test('copyWith preserves unrelated fields', () {
      const state = ListState(items: ['a']);
      final copy = state.copyWith(isLoading: false);
      expect(copy.items, ['a']);
      expect(copy.searchQuery, '');
    });
  });
}
