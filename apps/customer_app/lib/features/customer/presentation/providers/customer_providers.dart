import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/domain/repositories/customer_repository.dart';

final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>((ref) {
  return CustomerRemoteDataSource(ref.read(apiClientProvider));
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(customerRemoteDataSourceProvider));
});

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
        .map((v) => CustomerBookingEntity(
          service: (v['serviceType'] as String?) ?? (v['serviceName'] as String?) ?? '',
          vehicleName: (v['vehicleName'] as String?) ?? (v['vehicle'] as String?) ?? '',
          plateNumber: (v['plateNumber'] as String?) ?? (v['vehiclePlate'] as String?) ?? '',
          date: (v['bookingDate'] as String?) ?? (v['date'] as String?) ?? '',
          time: v['time'] as String? ?? '',
          status: BookingStatus.values.firstWhere(
            (e) => e.name == v['status'], orElse: () => BookingStatus.pending),
        ))
        .toList();
    return saved;
  } catch (e, st) {
    ref.read(loggerProvider).e('Failed to load customer bookings from Hive', error: e, stackTrace: st);
    return [];
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
  final CustomerServiceEntity? activeService;
  final CustomerEntity? profile;

  const CustomerDashboardState({
    required this.selectedIndex, required this.isLoading,
    required this.selectedVehicle, required this.selectedServiceType,
    this.bookingDate, required this.bookingNotes, this.bookingError,
    required this.vehicles, required this.notifications,
    this.activeService, this.profile,
  });

  CustomerDashboardState copyWith({
    int? selectedIndex, bool? isLoading, String? selectedVehicle,
    String? selectedServiceType, DateTime? bookingDate, String? bookingNotes,
    String? bookingError, List<CustomerVehicleEntity>? vehicles,
    List<CustomerNotificationEntity>? notifications,
    CustomerServiceEntity? activeService, CustomerEntity? profile,
    bool clearActiveService = false, bool clearProfile = false,
  }) => CustomerDashboardState(
    selectedIndex: selectedIndex ?? this.selectedIndex,
    isLoading: isLoading ?? this.isLoading,
    selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    selectedServiceType: selectedServiceType ?? this.selectedServiceType,
    bookingDate: bookingDate ?? this.bookingDate,
    bookingNotes: bookingNotes ?? this.bookingNotes,
    bookingError: bookingError,
    vehicles: vehicles ?? this.vehicles,
    notifications: notifications ?? this.notifications,
    activeService: clearActiveService ? null : (activeService ?? this.activeService),
    profile: clearProfile ? null : (profile ?? this.profile),
  );

  int get unreadCount => notifications.where((n) => !n.isRead).length;
  int get servicesThisYear {
    try {
      final box = Hive.box<dynamic>('customer_bookings');
      return box.values.whereType<Map>().map((m) => Map<String, dynamic>.from(m))
          .where((v) => v['status'] == 'completed').length;
    } catch (_) { return 0; }
  }
  int get unpaidInvoices => 1;
  String formatAmount(double amount) => '\u00a3${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

class CustomerDashboardNotifier extends Notifier<CustomerDashboardState> {
  @override
  CustomerDashboardState build() {
    _loadData();
    return CustomerDashboardState(
      selectedIndex: 0, isLoading: true, selectedVehicle: '',
      selectedServiceType: '', bookingNotes: '', vehicles: [], notifications: [],
    );
  }

  Future<void> _loadData() async {
    final repo = ref.read(customerRepositoryProvider);
    final results = await Future.wait([
      repo.getVehicles(), repo.getNotifications(),
      repo.getActiveService(), repo.getCustomerProfile(),
    ]);
    state = state.copyWith(
      isLoading: false,
      vehicles: results[0] as List<CustomerVehicleEntity>,
      notifications: results[1] as List<CustomerNotificationEntity>,
      activeService: results[2] as CustomerServiceEntity,
      profile: results[3] as CustomerEntity,
    );
  }

  void selectTab(int index) {
    if (state.selectedIndex == index) return;
    state = state.copyWith(selectedIndex: index);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadData();
  }

  void markAllRead() {
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  void markRead(String id) {
    final updated = state.notifications.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
    state = state.copyWith(notifications: updated);
  }

  void addVehicle(CustomerVehicleEntity vehicle) {
    state = state.copyWith(vehicles: [...state.vehicles, vehicle]);
  }

  void removeVehicle(String id) {
    state = state.copyWith(vehicles: state.vehicles.where((v) => v.id != id).toList());
  }

  void setSelectedVehicle(String value) => state = state.copyWith(selectedVehicle: value, bookingError: null);
  void setSelectedServiceType(String value) => state = state.copyWith(selectedServiceType: value, bookingError: null);
  void setBookingDate(DateTime date) => state = state.copyWith(bookingDate: date, bookingError: null);
  void setBookingNotes(String value) => state = state.copyWith(bookingNotes: value);

  Future<bool> submitBooking() async {
    if (state.selectedVehicle.isEmpty) { state = state.copyWith(bookingError: 'Please select a vehicle'); return false; }
    if (state.selectedServiceType.isEmpty) { state = state.copyWith(bookingError: 'Please select a service type'); return false; }
    if (state.bookingDate == null) { state = state.copyWith(bookingError: 'Please select a preferred date'); return false; }

    final local = GenericLocalDataSource(Hive.box<dynamic>('customer_bookings'));
    final vehicle = state.vehicles.where((v) => v.id == state.selectedVehicle).firstOrNull;
    final payload = {
      'vehicle': state.selectedVehicle, 'vehicleName': vehicle?.displayName ?? '',
      'plateNumber': vehicle?.plateNumber ?? '', 'serviceType': state.selectedServiceType,
      'bookingDate': state.bookingDate!.toIso8601String(), 'notes': state.bookingNotes, 'status': 'pending',
    };
    final id = await IdGenerator.nextId('BK');
    await local.save(id, payload);

    final queue = ref.read(syncQueueProvider);
    await queue.enqueue(SyncOperation(
      id: id, entityType: 'booking', entityId: id,
      changeType: ChangeType.create, payload: payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));

    ref.invalidate(customerBookingsProvider);
    state = state.copyWith(selectedVehicle: '', selectedServiceType: '', bookingNotes: '', bookingDate: null, bookingError: null);
    return true;
  }

  final List<String> serviceTypes = [
    'Full Service', 'Oil & Filter Change', 'Brake Inspection',
    'Tyre Replacement', 'MOT Check', 'Air Conditioning Service',
    'Battery Replacement', 'Diagnostic Check', 'Wheel Alignment', 'Clutch Repair',
  ];
}
