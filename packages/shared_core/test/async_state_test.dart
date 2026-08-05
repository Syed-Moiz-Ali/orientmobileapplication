import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  group('AsyncState', () {
    test('when() maps every state', () {
      const AsyncState<int> initial = AsyncInitial();
      const AsyncState<int> loading = AsyncLoading();
      const AsyncState<int> data = AsyncData(7);
      const AsyncState<int> error = AsyncError('nope');

      expect(
        initial.when(
          initial: () => 'init',
          loading: () => 'loading',
          data: (_) => 'data',
          error: (_, __) => 'error',
        ),
        'init',
      );
      expect(
        loading.when(
          initial: () => 'init',
          loading: () => 'loading',
          data: (_) => 'data',
          error: (_, __) => 'error',
        ),
        'loading',
      );
      expect(
        data.when(
          initial: () => 'init',
          loading: () => 'loading',
          data: (d) => 'data:$d',
          error: (_, __) => 'error',
        ),
        'data:7',
      );
      expect(
        error.when(
          initial: () => 'init',
          loading: () => 'loading',
          data: (_) => 'data',
          error: (m, r) => 'error:$m',
        ),
        'error:nope',
      );
    });
  });

  group('JobCardStatus', () {
    test('all values round-trip through name', () {
      for (final status in JobCardStatus.values) {
        final parsed = JobCardStatus.values.firstWhere(
          (e) => e.name == status.name,
          orElse: () => JobCardStatus.pendingApproval,
        );
        expect(parsed, status);
      }
    });

    test('unknown names fall back to pendingApproval', () {
      final parsed = JobCardStatus.values.firstWhere(
        (e) => e.name == 'not-a-status',
        orElse: () => JobCardStatus.pendingApproval,
      );
      expect(parsed, JobCardStatus.pendingApproval);
    });
  });
}
