import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/customer/domain/entities/customer_entities.dart';

final customerDashboardProvider =
    NotifierProvider<CustomerDashboardNotifier, CustomerDashboardState>(
      CustomerDashboardNotifier.new,
    );

class CustomerDashboardState {
  final int selectedIndex;
  final bool isLoading;
  final String selectedVehicle;
  final String selectedServiceType;
  final DateTime? bookingDate;
  final String bookingNotes;
  final bool bookingSubmitted;
  final List<CustomerVehicleEntity> vehicles;
  final List<CustomerNotificationEntity> notifications;

  const CustomerDashboardState({
    required this.selectedIndex,
    required this.isLoading,
    required this.selectedVehicle,
    required this.selectedServiceType,
    this.bookingDate,
    required this.bookingNotes,
    required this.bookingSubmitted,
    required this.vehicles,
    required this.notifications,
  });

  CustomerDashboardState copyWith({
    int? selectedIndex,
    bool? isLoading,
    String? selectedVehicle,
    String? selectedServiceType,
    DateTime? bookingDate,
    String? bookingNotes,
    bool? bookingSubmitted,
    List<CustomerVehicleEntity>? vehicles,
    List<CustomerNotificationEntity>? notifications,
  }) {
    return CustomerDashboardState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isLoading: isLoading ?? this.isLoading,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedServiceType: selectedServiceType ?? this.selectedServiceType,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingNotes: bookingNotes ?? this.bookingNotes,
      bookingSubmitted: bookingSubmitted ?? this.bookingSubmitted,
      vehicles: vehicles ?? this.vehicles,
      notifications: notifications ?? this.notifications,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  int get servicesThisYear => CustomerBookingEntity.mock
      .where((b) => b.status == BookingStatus.completed)
      .length;

  int get unpaidInvoices => 1;

  String formatAmount(double amount) =>
      '\u00a3${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

class CustomerDashboardNotifier extends Notifier<CustomerDashboardState> {
  @override
  CustomerDashboardState build() {
    return CustomerDashboardState(
      selectedIndex: 0,
      isLoading: false,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingDate: null,
      bookingNotes: '',
      bookingSubmitted: false,
      vehicles: List.from(CustomerVehicleEntity.mock),
      notifications: CustomerNotificationEntity.mock,
    );
  }

  void selectTab(int index) {
    if (state.selectedIndex == index) return;
    state = state.copyWith(selectedIndex: index);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isLoading: false);
  }

  void markAllRead() {
    final updated = state.notifications.map((n) {
      n.isRead = true;
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void markRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id) n.isRead = true;
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void addVehicle(CustomerVehicleEntity vehicle) {
    state = state.copyWith(vehicles: [...state.vehicles, vehicle]);
  }

  void setSelectedVehicle(String value) {
    state = state.copyWith(selectedVehicle: value);
  }

  void setSelectedServiceType(String value) {
    state = state.copyWith(selectedServiceType: value);
  }

  void setBookingDate(DateTime date) {
    state = state.copyWith(bookingDate: date);
  }

  void setBookingNotes(String value) {
    state = state.copyWith(bookingNotes: value);
  }

  void submitBooking() {
    if (state.selectedVehicle.isEmpty ||
        state.selectedServiceType.isEmpty ||
        state.bookingDate == null) {
      return;
    }
    state = state.copyWith(
      bookingSubmitted: true,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingDate: null,
      bookingNotes: '',
    );
  }

  List<ServiceStep> get serviceSteps => const [
    ServiceStep(
      title: 'Job Card Created',
      time: 'Today, 08:30 AM',
      isCompleted: true,
      isCurrent: false,
    ),
    ServiceStep(
      title: 'Vehicle Inspection',
      time: 'Today, 09:15 AM',
      isCompleted: true,
      isCurrent: false,
    ),
    ServiceStep(
      title: 'Parts Ordered',
      time: 'Today, 10:00 AM',
      isCompleted: true,
      isCurrent: false,
    ),
    ServiceStep(
      title: 'Repair In Progress',
      time: 'In progress...',
      isCompleted: false,
      isCurrent: true,
    ),
    ServiceStep(
      title: 'Quality Check',
      time: 'Pending',
      isCompleted: false,
      isCurrent: false,
    ),
    ServiceStep(
      title: 'Ready for Collection',
      time: 'Pending',
      isCompleted: false,
      isCurrent: false,
    ),
  ];

  final List<String> serviceTypes = [
    'Full Service',
    'Oil & Filter Change',
    'Brake Inspection',
    'Tyre Replacement',
    'MOT Check',
    'Air Conditioning Service',
    'Battery Replacement',
    'Diagnostic Check',
    'Wheel Alignment',
    'Clutch Repair',
  ];
}

class ServiceStep {
  final String title;
  final String time;
  final bool isCompleted;
  final bool isCurrent;

  const ServiceStep({
    required this.title,
    required this.time,
    required this.isCompleted,
    required this.isCurrent,
  });
}
