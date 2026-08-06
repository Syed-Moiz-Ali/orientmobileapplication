import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_adapters.dart';
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_datasource.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';

final dashboardDataSourceProvider = Provider<DashboardDataSource>((ref) {
  final adapter = DashboardUIRemoteAdapter(OwnerRemoteDataSource(ref.read(apiClientProvider)));
  adapter.loadAll();
  return adapter;
});

final ownerRemoteDataSourceProvider = Provider<OwnerRemoteDataSource>(
  (ref) => OwnerRemoteDataSource(ref.read(apiClientProvider)),
);

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
    final saved = _loadMessages();
    return DashboardUiState(sentMessages: saved);
  }

  List<Message> _loadMessages() {
    try {
      final box = Hive.box<dynamic>('owner_messages');
      return box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .map((m) => Message(
                id: m['id'] as String? ?? '',
                recipient: m['recipient'] as String? ?? '',
                message: m['message'] as String? ?? '',
                time: m['time'] as String? ?? '',
              ))
          .toList()
        ..sort((a, b) => b.id.compareTo(a.id));
    } catch (_) {
      return [];
    }
  }

  List<OwnerKpi> get kpis => _dataSource.kpis;
  List<JobCardRegisterItem> get registerItems => _dataSource.registerItems;
  List<SalesTrendPoint> get salesTrend => _dataSource.salesTrend;
  List<SalesTrendPoint> get profitTrend => _dataSource.profitTrend;
  List<SalesTrendPoint> get expensesTrend => _dataSource.expensesTrend;
  List<TopSalesCategory> get topSalesCategories => _dataSource.topSalesCategories;
  Set<int> get expandedCategoryIndices => _expandedIndices;
  List<Message> get sentMessages => state.sentMessages;

  void selectTab(int i) => state = state.copyWith(selectedIndex: i);
  void setPeriod(String p) => state = state.copyWith(period: p);

  Future<void> refresh() async {
    // FE-FIX (audit P1): this was a 900ms fake with zero network activity.
    state = state.copyWith(isLoading: true);
    try {
      await (_dataSource as DashboardUIRemoteAdapter).loadAll();
    } catch (e, st) {
      ref.read(loggerProvider).e('Failed to refresh dashboard', error: e, stackTrace: st);
    }
    state = state.copyWith(isLoading: false);
  }

  void selectUser(String user) => state = state.copyWith(selectedUser: user);
  void updateMessage(String text) => state = state.copyWith(messageText: text);

  // FE-FIX (audit): server-sent messages merged into the visible list.
  void mergeMessages(List<Message> server) {
    final ids = state.sentMessages.map((m) => m.id).toSet();
    final fresh = server.where((m) => !ids.contains(m.id)).toList();
    if (fresh.isEmpty) return;
    state = state.copyWith(sentMessages: [...fresh, ...state.sentMessages]);
  }

  Future<void> sendMessage() async {
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
    // Send through the backend; keep a local copy for offline resilience.
    try {
      final remote = ref.read(ownerRemoteDataSourceProvider);
      final response = await remote.sendMessage(msg.recipient, msg.message);
      final delivered = response.recipient.isNotEmpty;
      final payload = {
        'id': msg.id,
        'recipient': msg.recipient,
        'message': msg.message,
        'time': msg.time,
        'delivered': delivered,
      };
      GenericLocalDataSource(Hive.box<dynamic>('owner_messages'))
          .save(msg.id, payload);
      state = state.copyWith(
        sentMessages: [msg, ...state.sentMessages],
        selectedUser: '',
        messageText: '',
      );
    } catch (_) {
      // Offline: keep the message locally and clear the compose box.
      GenericLocalDataSource(Hive.box<dynamic>('owner_messages'))
          .save(msg.id, {
        'id': msg.id,
        'recipient': msg.recipient,
        'message': msg.message,
        'time': msg.time,
        'delivered': false,
      });
      state = state.copyWith(
        sentMessages: [msg, ...state.sentMessages],
        selectedUser: '',
        messageText: '',
      );
    }
  }

  void toggleCategory(int index) {
    // FE-FIX (audit P1): the expanded set lived outside state — the UI never
    // rebuilt, so the only drill-down in the app was a no-op.
    final next = Set<int>.from(_expandedIndices);
    if (next.contains(index)) {
      next.remove(index);
    } else {
      next.add(index);
    }
    _expandedIndices
      ..clear()
      ..addAll(next);
    state = state.copyWith();
  }
}

final dashboardUiProvider = NotifierProvider<DashboardUiNotifier, DashboardUiState>(
  DashboardUiNotifier.new,
);
