import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

final customerDashboardProvider =
    NotifierProvider<CustomerDashboardNotifier, CustomerDashboardState>(
      CustomerDashboardNotifier.new,
    );

final customerBookingsProvider = Provider<List<CustomerBookingEntity>>((ref) {
  try {
    final box = Hive.box<dynamic>('customer_bookings');
    final saved = box.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .where((v) => v['serviceType'] != null || v['serviceName'] != null)
        .map(
          (v) => CustomerBookingEntity(
            service: (v['serviceType'] as String?) ?? (v['serviceName'] as String?) ?? '',
            vehicleName: (v['vehicleName'] as String?) ?? (v['vehicle'] as String?) ?? '',
            plateNumber: (v['plateNumber'] as String?) ?? (v['vehiclePlate'] as String?) ?? '',
            date: (v['bookingDate'] as String?) ?? (v['date'] as String?) ?? '',
            time: v['time'] as String? ?? '',
            status: BookingStatus.values.firstWhere(
              (e) => e.name == v['status'],
              orElse: () => BookingStatus.pending,
            ),
          ),
        )
        .toList();
    return saved.isNotEmpty ? saved : CustomerBookingEntity.mock;
  } catch (e, st) {
    ref.read(loggerProvider).e('Failed to load customer bookings from Hive', error: e, stackTrace: st);
    return CustomerBookingEntity.mock;
  }
});

final customerBreakdownsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  try {
    final box = Hive.box<dynamic>('customer_breakdowns');
    return box.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList()
      ..sort((a, b) => (b['createdAt'] as String? ?? '').compareTo(a['createdAt'] as String? ?? ''));
  } catch (e, st) {
    ref.read(loggerProvider).e('Failed to load breakdowns from Hive', error: e, stackTrace: st);
    return [];
  }
});

class CustomerDashboardState {
  final int selectedIndex;
  final bool isLoading;
  final String selectedVehicle;
  final String selectedServiceType;
  final DateTime? bookingDate;
  final String bookingNotes;
  final String? bookingError;
  final List<CustomerVehicleEntity> vehicles;
  final List<CustomerNotificationEntity> notifications;

  const CustomerDashboardState({
    required this.selectedIndex,
    required this.isLoading,
    required this.selectedVehicle,
    required this.selectedServiceType,
    this.bookingDate,
    required this.bookingNotes,
    this.bookingError,
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
    String? bookingError,
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
      bookingError: bookingError,
      vehicles: vehicles ?? this.vehicles,
      notifications: notifications ?? this.notifications,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  int get servicesThisYear {
    try {
      final box = Hive.box<dynamic>('customer_bookings');
      return box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .where((v) => v['status'] == 'completed')
          .length;
    } catch (e, st) {
      Logger().e('Failed to count services this year from Hive', error: e, stackTrace: st);
      return CustomerBookingEntity.mock
          .where((b) => b.status == BookingStatus.completed)
          .length;
    }
  }

  int get unpaidInvoices => 1;

  String formatAmount(double amount) =>
      '\u00a3${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

class CustomerDashboardNotifier extends Notifier<CustomerDashboardState> {
  @override
  CustomerDashboardState build() {
    final savedVehicles = _loadVehiclesFromHive();
    return CustomerDashboardState(
      selectedIndex: 0,
      isLoading: false,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingNotes: '',
      bookingError: null,
      vehicles: savedVehicles,
      notifications: CustomerNotificationEntity.mock,
    );
  }

  List<CustomerVehicleEntity> _loadVehiclesFromHive() {
    return List.from(CustomerVehicleEntity.mock);
  }

  void selectTab(int index) {
    if (state.selectedIndex == index) return;
    state = state.copyWith(selectedIndex: index);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    final saved = _loadVehiclesFromHive();
    await Future.delayed(const Duration(milliseconds: 200));
    state = state.copyWith(isLoading: false, vehicles: saved);
  }

  void markAllRead() {
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: updated);
  }

  void markRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void addVehicle(CustomerVehicleEntity vehicle) {
    state = state.copyWith(vehicles: [...state.vehicles, vehicle]);
  }

  void setSelectedVehicle(String value) {
    state = state.copyWith(selectedVehicle: value, bookingError: null);
  }

  void setSelectedServiceType(String value) {
    state = state.copyWith(selectedServiceType: value, bookingError: null);
  }

  void setBookingDate(DateTime date) {
    state = state.copyWith(bookingDate: date, bookingError: null);
  }

  void setBookingNotes(String value) {
    state = state.copyWith(bookingNotes: value);
  }

  Future<bool> submitBooking() async {
    if (state.selectedVehicle.isEmpty) {
      state = state.copyWith(bookingError: 'Please select a vehicle');
      return false;
    }
    if (state.selectedServiceType.isEmpty) {
      state = state.copyWith(bookingError: 'Please select a service type');
      return false;
    }
    if (state.bookingDate == null) {
      state = state.copyWith(bookingError: 'Please select a preferred date');
      return false;
    }

    final local = GenericLocalDataSource(
      Hive.box<dynamic>('customer_bookings'),
    );
    final vehicle = state.vehicles.where((v) => v.id == state.selectedVehicle).firstOrNull;
    final payload = {
      'vehicle': state.selectedVehicle,
      'vehicleName': vehicle?.displayName ?? '',
      'plateNumber': vehicle?.plateNumber ?? '',
      'serviceType': state.selectedServiceType,
      'bookingDate': state.bookingDate!.toIso8601String(),
      'notes': state.bookingNotes,
      'status': 'pending',
    };
    final id = await IdGenerator.nextId('BK');
    await local.save(id, payload);

    final queue = ref.read(syncQueueProvider);
    final op = SyncOperation(
      id: id,
      entityType: 'booking',
      entityId: id,
      changeType: ChangeType.create,
      payload: payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await queue.enqueue(op);

    ref.invalidate(customerBookingsProvider);

    state = state.copyWith(
      selectedVehicle: '',
      selectedServiceType: '',
      bookingNotes: '',
      bookingDate: null,
      bookingError: null,
    );
    return true;
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
