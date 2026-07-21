import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/job_cards/data/datasources/mock_job_card_datasource.dart';
import 'package:orientmobileapplication/features/job_cards/data/repositories/job_card_repository_impl.dart';
import 'package:orientmobileapplication/features/job_cards/domain/entities/job_card.dart';
import 'package:orientmobileapplication/features/job_cards/domain/repositories/job_card_repository.dart';

final jobCardDatasourceProvider = Provider<MockJobCardDatasource>((ref) => MockJobCardDatasource());
final jobCardRepositoryProvider = Provider<JobCardRepository>((ref) => JobCardRepositoryImpl(ref.watch(jobCardDatasourceProvider)));

class JobCardsState {
  final bool isLoading;
  final String searchQuery;
  final JobCardStatus? activeFilter;
  final List<JobCard> all;
  final List<JobCard> filtered;

  const JobCardsState({
    this.isLoading = true,
    this.searchQuery = '',
    this.activeFilter,
    this.all = const [],
    this.filtered = const [],
  });

  JobCardsState copyWith({
    bool? isLoading,
    String? searchQuery,
    JobCardStatus? activeFilter,
    List<JobCard>? all,
    List<JobCard>? filtered,
  }) {
    return JobCardsState(
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter,
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
    );
  }
}

class JobCardsNotifier extends Notifier<JobCardsState> {
  @override
  JobCardsState build() {
    load();
    return const JobCardsState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final cards = await ref.read(jobCardRepositoryProvider).getJobCards();
    state = state.copyWith(isLoading: false, all: cards, filtered: _applyFilters(cards, '', null));
  }

  Future<void> refresh() async {
    await load();
  }

  void onSearch(String query) {
    state = state.copyWith(searchQuery: query, filtered: _applyFilters(state.all, query, state.activeFilter));
  }

  void setFilter(JobCardStatus? status) {
    state = state.copyWith(activeFilter: status, filtered: _applyFilters(state.all, state.searchQuery, status));
  }

  List<JobCard> _applyFilters(List<JobCard> cards, String query, JobCardStatus? status) {
    var result = cards;
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((jc) =>
        jc.customerName.toLowerCase().contains(q) ||
        jc.id.toLowerCase().contains(q) ||
        jc.vehicle.toLowerCase().contains(q) ||
        jc.plateNumber.toLowerCase().contains(q)
      ).toList();
    }
    if (status != null) {
      result = result.where((jc) => jc.status == status).toList();
    }
    return result;
  }
}

final jobCardsProvider = NotifierProvider<JobCardsNotifier, JobCardsState>(JobCardsNotifier.new);

final selectedJobCardProvider = StateProvider<JobCard?>((ref) => null);
