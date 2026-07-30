import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:crm_app/features/crm_dashboard/data/datasources/crm_remote_adapter.dart';
import 'package:crm_app/features/crm_dashboard/data/datasources/crm_remote_datasource.dart';
import 'package:crm_app/features/crm_dashboard/data/repositories/crm_repository_impl.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';

final crmRepositoryProvider = Provider<CrmRepository>((ref) {
  final adapter = CrmRemoteAdapter(CrmRemoteDataSource(ref.read(apiClientProvider)));
  adapter.loadAll();
  return CrmRepositoryImpl(adapter);
});

class CrmUiState {
  final int selectedIndex;
  final String period;
  final String salesperson;
  final bool isLoading;
  final String searchQuery;
  final bool notificationsEnabled;
  final bool darkMode;
  final bool autoAssign;

  const CrmUiState({
    required this.selectedIndex,
    required this.period,
    required this.salesperson,
    required this.isLoading,
    required this.searchQuery,
    required this.notificationsEnabled,
    required this.darkMode,
    required this.autoAssign,
  });

  CrmUiState copyWith({
    int? selectedIndex,
    String? period,
    String? salesperson,
    bool? isLoading,
    String? searchQuery,
    bool? notificationsEnabled,
    bool? darkMode,
    bool? autoAssign,
  }) {
    return CrmUiState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      period: period ?? this.period,
      salesperson: salesperson ?? this.salesperson,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      autoAssign: autoAssign ?? this.autoAssign,
    );
  }
}

class CrmUiNotifier extends Notifier<CrmUiState> {
  late final CrmRepository _repository;

  @override
  CrmUiState build() {
    _repository = ref.read(crmRepositoryProvider);
    return const CrmUiState(
      selectedIndex: 0,
      period: 'Today',
      salesperson: 'All Salespeople',
      isLoading: false,
      searchQuery: '',
      notificationsEnabled: true,
      darkMode: true,
      autoAssign: true,
    );
  }

  int get selectedIndex => state.selectedIndex;
  String get period => state.period;
  String get salesperson => state.salesperson;
  bool get isLoading => state.isLoading;
  String get searchQuery => state.searchQuery;
  bool get notificationsEnabled => state.notificationsEnabled;
  bool get darkMode => state.darkMode;
  bool get autoAssign => state.autoAssign;

  final List<String> periods = ['Today', 'This Week', 'This Month', 'This Year'];

  void setPeriod(String p) => state = state.copyWith(period: p);

  final List<String> salespeople = [
    'All Salespeople',
    'John Doe',
    'Sarah Smith',
    'Mike Johnson',
    'Joe Brown',
  ];

  void setSalesperson(String s) => state = state.copyWith(salesperson: s);
  void selectTab(int i) => state = state.copyWith(selectedIndex: i);
  void updateSearch(String q) => state = state.copyWith(searchQuery: q);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 900));
    state = state.copyWith(isLoading: false);
  }

  void toggleNotifications() => state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  void toggleDarkMode() => state = state.copyWith(darkMode: !state.darkMode);
  void toggleAutoAssign() => state = state.copyWith(autoAssign: !state.autoAssign);

  List<CrmKpiEntity> get kpis => _repository.kpis;
  List<CrmChannelEntity> get channels => _repository.channels;
  List<CrmTrendPoint> get conversionTrend => _repository.conversionTrend;
  List<SalespersonPerf> get salespersonPerf => _repository.salespersonPerf;
  List<ResponseTimeBucket> get responseTimeBuckets => _repository.responseTimeBuckets;
  List<LeadSourceSlice> get leadSources => _repository.leadSources;
  List<CrmKeyMetric> get keyMetrics => _repository.keyMetrics;
  List<IntegrationEntity> get integrations => _repository.integrations;
  List<SalesTeamMember> get salesTeam => _repository.salesTeam;
  List<ConversationEntity> get conversations => _repository.conversations;
}

final crmUiProvider = NotifierProvider<CrmUiNotifier, CrmUiState>(
  CrmUiNotifier.new,
);
