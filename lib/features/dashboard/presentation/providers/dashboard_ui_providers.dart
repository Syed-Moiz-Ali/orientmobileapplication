import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/features/dashboard/domain/entities/dashboard_entities.dart';

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

  static const periods = ['Today', 'This Week', 'This Month', 'This Year'];

  static const users = [
    'Ahmed Service Advisor',
    'Mohammed Technician',
    'Ali Workshop Manager',
    'Hassan Accountant',
    'Omar Parts Manager',
    'Fatima Admin',
    'Sarah HR Manager',
  ];

  static const kpis = [
    OwnerKpi(label: 'Active Jobs', value: '145', icon: Icons.work_outline_rounded, color: AppColors.accent, sub: '+12 today'),
    OwnerKpi(label: 'New Jobs', value: '23', icon: Icons.add_circle_outline_rounded, color: AppColors.success, sub: '+5 today'),
    OwnerKpi(label: 'Cancelled Jobs', value: '100', icon: Icons.cancel_outlined, color: AppColors.danger, sub: '-2 today'),
    OwnerKpi(label: 'Total Jobs', value: '2,168', icon: Icons.receipt_long_rounded, color: AppColors.info, sub: 'All time'),
    OwnerKpi(label: 'Total Sales', value: 'AED 50K', icon: Icons.trending_up_rounded, color: AppColors.accent, sub: '+8%'),
    OwnerKpi(label: 'Total Purchases', value: 'AED 30K', icon: Icons.shopping_cart_outlined, color: AppColors.warning, sub: '+3%'),
    OwnerKpi(label: 'Receivables', value: 'AED 4K', icon: Icons.account_balance_wallet_outlined, color: AppColors.success, sub: '12 pending'),
    OwnerKpi(label: 'Payables', value: 'AED 15K', icon: Icons.payments_outlined, color: AppColors.danger, sub: '8 due'),
    OwnerKpi(label: 'Total Profit', value: 'AED 20K', icon: Icons.bar_chart_rounded, color: AppColors.success, sub: '+14%'),
    OwnerKpi(label: 'Total Cash', value: 'AED 45K', icon: Icons.attach_money_rounded, color: AppColors.accent, sub: 'In hand'),
    OwnerKpi(label: 'Total Bank', value: 'AED 30K', icon: Icons.account_balance_outlined, color: AppColors.info, sub: 'Balance'),
    OwnerKpi(label: 'Inventory Value', value: 'AED 85K', icon: Icons.inventory_2_outlined, color: AppColors.warning, sub: '1,240 items'),
    OwnerKpi(label: 'Commission', value: 'AED 1,500', icon: Icons.star_outline_rounded, color: AppColors.success, sub: 'Monthly'),
    OwnerKpi(label: 'Invoice Revenue', value: 'AED 25K', icon: Icons.description_outlined, color: AppColors.accent, sub: '+6%'),
    OwnerKpi(label: 'Parts Revenue', value: 'AED 18K', icon: Icons.build_outlined, color: AppColors.warning, sub: '+9%'),
    OwnerKpi(label: 'Labour Revenue', value: 'AED 7K', icon: Icons.engineering_outlined, color: AppColors.info, sub: '+4%'),
  ];

  static const registerItems = [
    JobCardRegisterItem(label: 'Open', open: 40, completed: 0, total: 40),
    JobCardRegisterItem(label: 'Check-In', open: 100, completed: 0, total: 100),
    JobCardRegisterItem(label: 'Invoice Number', open: 10, completed: 0, total: 10),
    JobCardRegisterItem(label: 'Invoice Service', open: 2000, completed: 0, total: 2000),
    JobCardRegisterItem(label: 'Park Fee', open: 2000, completed: 0, total: 2000),
  ];

  static const salesTrend = [
    SalesTrendPoint('Jan', 28000),
    SalesTrendPoint('Feb', 35000),
    SalesTrendPoint('Mar', 30000),
    SalesTrendPoint('Apr', 42000),
    SalesTrendPoint('May', 38000),
    SalesTrendPoint('Jun', 50000),
    SalesTrendPoint('Jul', 45000),
  ];

  static const profitTrend = [
    SalesTrendPoint('Jan', 8000),
    SalesTrendPoint('Feb', 12000),
    SalesTrendPoint('Mar', 10000),
    SalesTrendPoint('Apr', 16000),
    SalesTrendPoint('May', 14000),
    SalesTrendPoint('Jun', 20000),
    SalesTrendPoint('Jul', 18000),
  ];

  static const expensesTrend = [
    SalesTrendPoint('Jan', 20000),
    SalesTrendPoint('Feb', 23000),
    SalesTrendPoint('Mar', 20000),
    SalesTrendPoint('Apr', 26000),
    SalesTrendPoint('May', 24000),
    SalesTrendPoint('Jun', 30000),
    SalesTrendPoint('Jul', 27000),
  ];
}

List<TopSalesCategory> _buildTopSalesCategories() {
  return [
    const TopSalesCategory(
      title: 'Customer Wise',
      items: [
        TopSalesItem(sno: 1, description: 'Ahmed Al Mansoori', value: 'AED 45,600'),
        TopSalesItem(sno: 2, description: 'Mohammed Khan', value: 'AED 38,500'),
        TopSalesItem(sno: 3, description: 'Fatima Hassan', value: 'AED 32,100'),
        TopSalesItem(sno: 4, description: 'Ali Rashid', value: 'AED 28,900'),
        TopSalesItem(sno: 5, description: 'Sarah Abdullah', value: 'AED 25,600'),
      ],
    ),
    const TopSalesCategory(
      title: 'Brand / Model Wise',
      items: [
        TopSalesItem(sno: 1, description: 'Toyota Land Cruiser', value: 'AED 52,000'),
        TopSalesItem(sno: 2, description: 'Mercedes S-Class', value: 'AED 48,300'),
        TopSalesItem(sno: 3, description: 'BMW X5', value: 'AED 41,200'),
        TopSalesItem(sno: 4, description: 'Nissan Patrol', value: 'AED 35,800'),
        TopSalesItem(sno: 5, description: 'Audi Q7', value: 'AED 30,500'),
      ],
    ),
    const TopSalesCategory(
      title: 'Advisor Wise',
      items: [
        TopSalesItem(sno: 1, description: 'Ahmed Service Advisor', value: 'AED 95,800'),
        TopSalesItem(sno: 2, description: 'Mohammed Service Advisor', value: 'AED 82,400'),
        TopSalesItem(sno: 3, description: 'Ali Service Advisor', value: 'AED 67,200'),
        TopSalesItem(sno: 4, description: 'Hassan Service Advisor', value: 'AED 54,300'),
        TopSalesItem(sno: 5, description: 'Omar Service Advisor', value: 'AED 48,100'),
      ],
    ),
    const TopSalesCategory(
      title: 'Profit Wise',
      items: [
        TopSalesItem(sno: 1, description: 'Q2 2025', value: 'AED 62,000'),
        TopSalesItem(sno: 2, description: 'Q1 2025', value: 'AED 54,500'),
        TopSalesItem(sno: 3, description: 'Q3 2024', value: 'AED 48,200'),
        TopSalesItem(sno: 4, description: 'Q4 2024', value: 'AED 44,800'),
        TopSalesItem(sno: 5, description: 'Q2 2024', value: 'AED 38,600'),
      ],
    ),
    const TopSalesCategory(
      title: 'Sales Value Wise',
      items: [
        TopSalesItem(sno: 1, description: 'INV-2025-143', value: 'AED 28,750'),
        TopSalesItem(sno: 2, description: 'INV-2025-138', value: 'AED 25,200'),
        TopSalesItem(sno: 3, description: 'INV-2025-129', value: 'AED 22,100'),
        TopSalesItem(sno: 4, description: 'INV-2025-120', value: 'AED 19,800'),
        TopSalesItem(sno: 5, description: 'INV-2025-112', value: 'AED 17,500'),
      ],
    ),
    const TopSalesCategory(
      title: 'Spare Parts Profit Wise',
      items: [
        TopSalesItem(sno: 1, description: 'Engine Parts', value: 'AED 15,400'),
        TopSalesItem(sno: 2, description: 'Brake System', value: 'AED 12,200'),
        TopSalesItem(sno: 3, description: 'Suspension Parts', value: 'AED 10,800'),
        TopSalesItem(sno: 4, description: 'Electrical Components', value: 'AED 9,500'),
        TopSalesItem(sno: 5, description: 'Body Parts', value: 'AED 8,300'),
      ],
    ),
    const TopSalesCategory(
      title: 'Labour Profit Wise',
      items: [
        TopSalesItem(sno: 1, description: 'Engine Overhaul', value: 'AED 8,500'),
        TopSalesItem(sno: 2, description: 'Body Work', value: 'AED 7,200'),
        TopSalesItem(sno: 3, description: 'Electrical Work', value: 'AED 6,400'),
        TopSalesItem(sno: 4, description: 'AC Service', value: 'AED 5,100'),
        TopSalesItem(sno: 5, description: 'General Maintenance', value: 'AED 4,800'),
      ],
    ),
    const TopSalesCategory(
      title: 'Department Wise',
      items: [
        TopSalesItem(sno: 1, description: 'MECHANICAL DEPARTMENT', value: 'AED 125,000'),
        TopSalesItem(sno: 2, description: 'ELECTRICAL DEPARTMENT', value: 'AED 85,300'),
        TopSalesItem(sno: 3, description: 'WRAPPING DEPARTMENT', value: 'AED 62,700'),
        TopSalesItem(sno: 4, description: 'BODY SHOP', value: 'AED 45,200'),
        TopSalesItem(sno: 5, description: 'AC SPECIALIST', value: 'AED 32,800'),
      ],
    ),
  ];
}

class DashboardUiNotifier extends Notifier<DashboardUiState> {
  final List<TopSalesCategory> _topSalesCategories = _buildTopSalesCategories();
  final Set<int> _expandedIndices = {};

  List<TopSalesCategory> get topSalesCategories => _topSalesCategories;
  Set<int> get expandedCategoryIndices => _expandedIndices;

  @override
  DashboardUiState build() => const DashboardUiState();

  void selectTab(int i) {
    state = state.copyWith(selectedIndex: i);
  }

  void setPeriod(String p) {
    state = state.copyWith(period: p);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 900));
    state = state.copyWith(isLoading: false);
  }

  void selectUser(String user) {
    state = state.copyWith(selectedUser: user);
  }

  void updateMessage(String text) {
    state = state.copyWith(messageText: text);
  }

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

final dashboardUiProvider =
    NotifierProvider<DashboardUiNotifier, DashboardUiState>(
  DashboardUiNotifier.new,
);
