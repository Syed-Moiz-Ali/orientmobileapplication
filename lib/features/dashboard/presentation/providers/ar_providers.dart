import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/dashboard/data/datasources/mock_ar_datasource.dart';
import 'package:orientmobileapplication/features/dashboard/data/repositories/ar_repository_impl.dart';
import 'package:orientmobileapplication/features/dashboard/domain/entities/accounts_receivable.dart';
import 'package:orientmobileapplication/features/dashboard/domain/repositories/accounts_receivable_repository.dart';

final arDatasourceProvider = Provider<MockARDatasource>((ref) {
  return MockARDatasource();
});

final arRepositoryProvider = Provider<AccountsReceivableRepository>((ref) {
  return ARRepositoryImpl(ref.watch(arDatasourceProvider));
});

class AccountsReceivableState {
  final bool isLoading;
  final ARSummary summary;
  final List<ARRecord> records;
  final String searchQuery;

  const AccountsReceivableState({
    this.isLoading = true,
    this.summary = const ARSummary(
      totalOutstanding: 0,
      days0to30: 0,
      days31to60: 0,
      days61to90: 0,
      days90plus: 0,
    ),
    this.records = const [],
    this.searchQuery = '',
  });

  AccountsReceivableState copyWith({
    bool? isLoading,
    ARSummary? summary,
    List<ARRecord>? records,
    String? searchQuery,
  }) {
    return AccountsReceivableState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      records: records ?? this.records,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<ARRecord> get filteredRecords {
    if (searchQuery.isEmpty) return records;
    final q = searchQuery.toLowerCase();
    return records.where((r) =>
      r.arId.toLowerCase().contains(q) ||
      r.customer.toLowerCase().contains(q)
    ).toList();
  }
}

class AccountsReceivableNotifier
    extends Notifier<AccountsReceivableState> {
  @override
  AccountsReceivableState build() {
    loadData();
    return const AccountsReceivableState();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(arRepositoryProvider);
    final summary = await repo.getSummary();
    final records = await repo.getRecords();
    state = state.copyWith(
      isLoading: false,
      summary: summary,
      records: records,
    );
  }

  void onSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final accountsReceivableProvider = NotifierProvider<
    AccountsReceivableNotifier, AccountsReceivableState>(
  AccountsReceivableNotifier.new,
);
