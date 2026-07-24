import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owner_app/features/dashboard/data/datasources/dashboard_mock_datasource.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';

final dashboardDataSourceProvider = Provider<DashboardDataSource>((ref) => DashboardMockDataSource());

class DashboardUiState {
  final int selectedIndex;
  final String period;
  final bool isLoading;
  final String selectedUser;
  final String messageText;
  final List<Message> sentMessages;

  const DashboardUiState({
    this.selectedIndex = 0,
    this.period = 'This Week',
    this.isLoading = false,
    this.selectedUser = '',
    this.messageText = '',
    this.sentMessages = const [],
  });

  DashboardUiState copyWith({
    int? selectedIndex,
    String? period,
    bool? isLoading,
    String? selectedUser,
    String? messageText,
    List<Message>? sentMessages,
  }) {
    return DashboardUiState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      period: period ?? this.period,
      isLoading: isLoading ?? this.isLoading,
      selectedUser: selectedUser ?? this.selectedUser,
      messageText: messageText ?? this.messageText,
      sentMessages: sentMessages ?? this.sentMessages,
    );
  }
}

class DashboardUiNotifier extends Notifier<DashboardUiState> {
  late final DashboardDataSource _dataSource;
  final Set<int> _expandedIndices = {};

  @override
  DashboardUiState build() {
    _dataSource = ref.read(dashboardDataSourceProvider);
    return const DashboardUiState();
  }

  List<OwnerKpi> get kpis => _dataSource.kpis;
  List<JobCardRegisterItem> get registerItems => _dataSource.registerItems;
  List<SalesTrendPoint> get salesTrend => _dataSource.salesTrend;
  List<SalesTrendPoint> get profitTrend => _dataSource.profitTrend;
  List<SalesTrendPoint> get expensesTrend => _dataSource.expensesTrend;
  List<TopSalesCategory> get topSalesCategories => _dataSource.topSalesCategories;
  Set<int> get expandedCategoryIndices => _expandedIndices;

  void selectTab(int i) => state = state.copyWith(selectedIndex: i);
  void setPeriod(String p) => state = state.copyWith(period: p);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 900));
    state = state.copyWith(isLoading: false);
  }

  void selectUser(String user) => state = state.copyWith(selectedUser: user);
  void updateMessage(String text) => state = state.copyWith(messageText: text);

  void sendMessage() {
    if (state.selectedUser.isEmpty || state.messageText.trim().isEmpty) return;
    final now = TimeOfDay.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final min = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour < 12 ? 'AM' : 'PM';
    final msg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipient: state.selectedUser,
      message: state.messageText.trim(),
      time: '$hour:$min $ampm',
    );
    state = state.copyWith(
      sentMessages: [msg, ...state.sentMessages],
      selectedUser: '',
      messageText: '',
    );
  }

  void toggleCategory(int index) {
    if (_expandedIndices.contains(index)) {
      _expandedIndices.remove(index);
    } else {
      _expandedIndices.add(index);
    }
  }
}

final dashboardUiProvider = NotifierProvider<DashboardUiNotifier, DashboardUiState>(
  DashboardUiNotifier.new,
);
