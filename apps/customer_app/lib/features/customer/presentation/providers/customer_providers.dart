import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/core/local/sync_providers.dart';
import 'package:customer_app/core/local/vehicle_identity_store.dart';
import 'package:customer_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/domain/repositories/customer_repository.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_vehicle_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/vehicle_booking_decision.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';

final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>((
  ref,
) {
  return CustomerRemoteDataSource(ref.read(apiClientProvider));
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(customerRemoteDataSourceProvider));
});

final customerDashboardProvider =
    NotifierProvider<CustomerDashboardNotifier, CustomerDashboardState>(
      CustomerDashboardNotifier.new,
    );

final customerBookingsProvider = FutureProvider<List<CustomerBookingEntity>>((
  ref,
) async {
  final local = _bookingsFromHive();
  try {
    final remote = await ref
        .read(customerRemoteDataSourceProvider)
        .getBookings();
    final remoteEntities = remote
        .map(
          (b) => CustomerBookingEntity(
            id: b.id,
            service: b.service,
            vehicleName: b.vehicleName,
            plateNumber: b.plateNumber,
            date: b.date,
            time: b.time,
            status: CustomerBookingEntity.parseStatus(
              bookingStatus: b.status,
              jobCardStatus: b.jobCardStatus,
              approvalRequired: b.approvalRequired,
            ),
            jobCardId: b.jobCardId,
            bookingRef: b.bookingRef,
            jobCardRef: b.jobCardRef,
            jobCardStatus: b.jobCardStatus,
            estimateId: b.estimateId,
            estimateAmount: b.estimateAmount,
          ),
        )
        .toList();
    // The workshop formats dates as `d MMM yyyy` while the device cache stores
    // the submitted ISO value, so identity is compared on the real date, the
    // normalised plate and the service â€” never on raw strings.
    String keyOf(CustomerBookingEntity b) =>
        '${CustomerBookingsPresentation.identityKey(vehicleName: b.vehicleName, plateNumber: b.plateNumber, date: b.date)}|${b.service.trim().toLowerCase()}|${b.time.trim()}';

    final remoteKeys = remoteEntities.map(keyOf).toSet();
    final merged = [
      ...remoteEntities,
      ...local.where((b) => !remoteKeys.contains(keyOf(b))),
    ];
    return merged;
  } catch (e, st) {
    ref
        .read(loggerProvider)
        .e(
          'Failed to load bookings from API â€” using local',
          error: e,
          stackTrace: st,
        );
    return local;
  }
});

List<CustomerBookingEntity> _bookingsFromHive() {
  try {
    final legacy = Hive.box<dynamic>(
      'customer_bookings',
    ).values.whereType<Map>().map((m) => Map<String, dynamic>.from(m));
    final cache = Hive.box<dynamic>('customer_cache').get('cached_bookings');
    final cached = cache is List
        ? cache.whereType<Map>().map((m) => Map<String, dynamic>.from(m))
        : const <Map<String, dynamic>>[];
    final saved = [...legacy, ...cached]
        .where((v) => v['serviceType'] != null || v['serviceName'] != null)
        .map(
          (v) => CustomerBookingEntity(
            service:
                (v['serviceType'] as String?) ??
                (v['serviceName'] as String?) ??
                '',
            vehicleName:
                (v['vehicleName'] as String?) ??
                (v['vehicle'] as String?) ??
                '',
            plateNumber:
                (v['plateNumber'] as String?) ??
                (v['vehiclePlate'] as String?) ??
                '',
            date: (v['bookingDate'] as String?) ?? (v['date'] as String?) ?? '',
            time: v['time'] as String? ?? '',
            status: CustomerBookingEntity.parseStatus(
              bookingStatus: (v['status'] ?? '').toString(),
              jobCardStatus: (v['jobCardStatus'] ?? '').toString(),
              approvalRequired: v['approvalRequired'] as bool? ?? false,
            ),
            jobCardId: (v['jobCardId'] ?? '').toString(),
            bookingRef: (v['bookingRef'] ?? '').toString(),
            jobCardRef: (v['jobCardRef'] ?? '').toString(),
            jobCardStatus: (v['jobCardStatus'] ?? '').toString(),
            estimateId: (v['estimateId'] ?? '').toString(),
            estimateAmount: (v['estimateAmount'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();
    return saved;
  } catch (_) {
    return [];
  }
}

class CustomerDashboardState {
  final int selectedIndex;
  final bool isLoading;
  final String selectedVehicle;
  final String selectedServiceType;
  final DateTime? bookingDate;
  final String bookingNotes;
  final String? bookingError;
  final String loadError;
  final List<CustomerVehicleEntity> vehicles;
  final List<CustomerNotificationEntity> notifications;
  final CustomerServiceEntity? activeService;
  final CustomerEntity? profile;
  final int unpaidInvoices;

  const CustomerDashboardState({
    required this.selectedIndex,
    required this.isLoading,
    required this.selectedVehicle,
    required this.selectedServiceType,
    this.bookingDate,
    required this.bookingNotes,
    this.bookingError,
    this.loadError = '',
    required this.vehicles,
    required this.notifications,
    this.activeService,
    this.profile,
    this.unpaidInvoices = 0,
  });

  CustomerDashboardState copyWith({
    int? selectedIndex,
    bool? isLoading,
    String? selectedVehicle,
    String? selectedServiceType,
    DateTime? bookingDate,
    String? bookingNotes,
    String? loadError,
    String? bookingError,
    List<CustomerVehicleEntity>? vehicles,
    List<CustomerNotificationEntity>? notifications,
    CustomerServiceEntity? activeService,
    CustomerEntity? profile,
    int? unpaidInvoices,
    bool clearActiveService = false,
    bool clearProfile = false,
  }) => CustomerDashboardState(
    selectedIndex: selectedIndex ?? this.selectedIndex,
    isLoading: isLoading ?? this.isLoading,
    selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    selectedServiceType: selectedServiceType ?? this.selectedServiceType,
    bookingDate: bookingDate ?? this.bookingDate,
    bookingNotes: bookingNotes ?? this.bookingNotes,
    bookingError: bookingError,
    loadError: loadError ?? this.loadError,
    vehicles: vehicles ?? this.vehicles,
    notifications: notifications ?? this.notifications,
    activeService: clearActiveService
        ? null
        : (activeService ?? this.activeService),
    profile: clearProfile ? null : (profile ?? this.profile),
    unpaidInvoices: unpaidInvoices ?? this.unpaidInvoices,
  );

  int get unreadCount => notifications.where((n) => !n.isRead).length;
  int get servicesThisYear {
    try {
      final box = Hive.box<dynamic>('customer_bookings');
      return box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .where((v) => v['status'] == 'completed')
          .length;
    } catch (_) {
      return 0;
    }
  }

  // FIX (audit): GBP â†’ AED for the UAE market.
  String formatAmount(double amount) =>
      'AED ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

class CustomerDashboardNotifier extends Notifier<CustomerDashboardState> {
  @override
  CustomerDashboardState build() {
    _loadData();
    return CustomerDashboardState(
      selectedIndex: 0,
      isLoading: true,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingNotes: '',
      vehicles: [],
      notifications: [],
    );
  }

  /// The canonical dashboard load, coalesced.
  ///
  /// A burst of pushes (or a resume landing on top of one) must not become a
  /// request storm, and a slow response must never overwrite a newer one, so
  /// concurrent callers share a single in-flight load plus at most one rerun.
  Future<void>? _loadInFlight;
  bool _loadRerunRequested = false;

  Future<void> _loadData() {
    final inFlight = _loadInFlight;
    if (inFlight != null) {
      _loadRerunRequested = true;
      return inFlight;
    }
    return _loadInFlight = _runLoadLoop();
  }

  Future<void> _runLoadLoop() async {
    try {
      do {
        _loadRerunRequested = false;
        await _fetchDashboard();
      } while (_loadRerunRequested);
    } finally {
      _loadInFlight = null;
    }
  }

  Future<void> _fetchDashboard() async {
    final repo = ref.read(customerRepositoryProvider);
    final remote = ref.read(customerRemoteDataSourceProvider);
    // FIX (audit P1): any throw previously left isLoading=true forever and the
    // home screen rendered a skeleton indefinitely with no retry.
    try {
      final results = await Future.wait([
        repo.getVehicles(),
        repo.getNotifications(),
        repo.getActiveService(),
        repo.getCustomerProfile(),
        remote.getInvoices(),
      ]);
      final invoices = results[4] as List<InvoiceResponse>;
      state = state.copyWith(
        isLoading: false,
        loadError: '',
        vehicles: _dedupeVehicles(results[0] as List<CustomerVehicleEntity>),
        notifications: _withPendingReads(
          results[1] as List<CustomerNotificationEntity>,
        ),
        activeService: results[2] as CustomerServiceEntity,
        profile: results[3] as CustomerEntity,
        unpaidInvoices: invoices.where((i) => i.status == 'unpaid').length,
      );
    } catch (e, st) {
      ref
          .read(loggerProvider)
          .e('Failed to load customer dashboard', error: e, stackTrace: st);
      if (e is UnauthorizedException) {
        await ref.read(authNotifierProvider.notifier).logout();
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(
        isLoading: false,
        loadError:
            'Could not load your data. Check your connection and try again.',
      );
    }
  }

  /// Re-applies read markers that are still in flight to a freshly loaded
  /// list, so a refresh that races a tap cannot flash a row back to unread.
  List<CustomerNotificationEntity> _withPendingReads(
    List<CustomerNotificationEntity> fresh,
  ) {
    if (_pendingReadIds.isEmpty && !_markingAllRead) return fresh;
    return [
      for (final notification in fresh)
        _markingAllRead || _pendingReadIds.contains(notification.id)
            ? notification.copyWith(isRead: true)
            : notification,
    ];
  }

  void selectTab(int index) {
    if (state.selectedIndex == index) return;
    state = state.copyWith(selectedIndex: index);
  }

  /// Selects a permanent workspace destination.
  ///
  /// Prefer this over [selectTab] so callers never depend on destination
  /// ordering: the order lives in [CustomerDestination] only.
  void selectDestination(CustomerDestination destination) =>
      selectTab(destination.index);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadData();
  }

  /// Notifications read in this session whose marker is still in flight.
  ///
  /// A load that lands mid-flight must not flash them back to unread; once the
  /// request settles the server's own list governs.
  final Set<String> _pendingReadIds = {};
  bool _markingAllRead = false;

  /// Marks one notification read.
  ///
  /// The row updates immediately — it is what the customer just did — and the
  /// marker is persisted to the workshop and the offline cache. A failed
  /// persistence is deliberately *not* surfaced and does not block anything:
  /// the local state is kept so the customer's tap is respected, and the next
  /// load restores the server's truth. Tapping an already-read row is a no-op,
  /// so a notification is never marked twice.
  Future<void> markRead(String id) async {
    final index = state.notifications.indexWhere((n) => n.id == id);
    if (index < 0 || state.notifications[index].isRead) return;

    _pendingReadIds.add(id);
    state = state.copyWith(
      notifications: [
        for (final n in state.notifications)
          n.id == id ? n.copyWith(isRead: true) : n,
      ],
    );

    try {
      await ref.read(customerRepositoryProvider).markNotificationRead(id);
    } catch (e, st) {
      ref
          .read(loggerProvider)
          .e('Failed to persist notification read', error: e, stackTrace: st);
      if (e is UnauthorizedException) {
        await ref.read(authNotifierProvider.notifier).logout();
      }
    } finally {
      _pendingReadIds.remove(id);
    }
  }

  /// Marks every notification read through the backend's bulk endpoint.
  ///
  /// Returns false when the workshop did not accept the bulk marker, in which
  /// case the optimistic state is rolled back so the badge keeps telling the
  /// truth instead of showing a state the server never stored.
  Future<bool> markAllRead() async {
    if (_markingAllRead) return false;
    if (state.unreadCount == 0) return true;

    _markingAllRead = true;
    final before = state.notifications;
    state = state.copyWith(
      notifications: [for (final n in before) n.copyWith(isRead: true)],
    );

    var saved = false;
    try {
      saved = await ref
          .read(customerRepositoryProvider)
          .markAllNotificationsRead();
    } catch (e, st) {
      ref
          .read(loggerProvider)
          .e('Failed to persist read-all', error: e, stackTrace: st);
      if (e is UnauthorizedException) {
        await ref.read(authNotifierProvider.notifier).logout();
      }
    } finally {
      _markingAllRead = false;
    }

    if (!saved) state = state.copyWith(notifications: before);
    return saved;
  }

  void addVehicle(CustomerVehicleEntity vehicle) {
    state = state.copyWith(
      vehicles: _dedupeVehicles([...state.vehicles, vehicle]),
    );
  }

  List<CustomerVehicleEntity> _dedupeVehicles(
    List<CustomerVehicleEntity> vehicles,
  ) {
    final byKey = <String, CustomerVehicleEntity>{};
    for (final vehicle in vehicles) {
      final id = vehicle.id.trim();
      final plate = vehicle.plateNumber.trim().toUpperCase();
      final key = id.isNotEmpty ? 'id:$id' : 'plate:$plate';
      if (key == 'plate:') continue;
      byKey[key] = vehicle;
    }
    return byKey.values.toList();
  }

  /// Drops a vehicle from local state and the device cache only.
  ///
  /// Used for a vehicle that was never persisted at the workshop, so no API
  /// call can or should be made for it.
  void removeVehicleLocally(String id) {
    try {
      final cache = Hive.box<dynamic>('customer_cache');
      final cached = cache.get('cached_vehicles');
      if (cached is List) {
        cache.put(
          'cached_vehicles',
          cached
              .where((item) => item is! Map || item['id'].toString() != id)
              .toList(),
        );
      }
    } catch (_) {
      // Local state is still updated below.
    }
    state = state.copyWith(
      vehicles: state.vehicles.where((v) => v.id != id).toList(),
    );
  }

  Future<bool> removeVehicle(String id) async {
    try {
      await ref.read(customerRemoteDataSourceProvider).deleteVehicle(id);
    } catch (e) {
      if (e is UnauthorizedException) {
        await ref.read(authNotifierProvider.notifier).logout();
        return false;
      }
      if (e is! NetworkException) return false;
      await ref
          .read(syncQueueProvider)
          .enqueue(
            SyncOperation(
              id: 'vehicle-delete-$id',
              entityType: 'vehicle',
              entityId: id,
              changeType: ChangeType.delete,
              payload: const {},
              timestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    }
    // The vehicle is gone at the workshop; a cache that cannot be written must
    // not turn that into a failure.
    try {
      final cache = Hive.box<dynamic>('customer_cache');
      final cached = cache.get('cached_vehicles');
      if (cached is List) {
        await cache.put(
          'cached_vehicles',
          cached
              .where((item) => item is! Map || item['id'].toString() != id)
              .toList(),
        );
      }
    } catch (_) {}
    state = state.copyWith(
      vehicles: state.vehicles.where((v) => v.id != id).toList(),
    );
    return true;
  }

  void setSelectedVehicle(String value) =>
      state = state.copyWith(selectedVehicle: value, bookingError: null);
  void setSelectedServiceType(String value) =>
      state = state.copyWith(selectedServiceType: value, bookingError: null);
  void setBookingDate(DateTime date) =>
      state = state.copyWith(bookingDate: date, bookingError: null);
  void setBookingNotes(String value) =>
      state = state.copyWith(bookingNotes: value);

  // legacy field only feeds the unused book-service tab.
  final List<String> serviceTypes = const [];
}

// ---------- Seamless flows: estimate approvals & invoices ----------

final customerApprovalsRefreshProvider = StateProvider<int>((ref) => 0);

final customerApprovalsProvider =
    FutureProvider<List<CustomerApprovalSummaryResponse>>((ref) async {
      ref.watch(customerApprovalsRefreshProvider);
      final remote = ref.read(customerRemoteDataSourceProvider);
      try {
        return await remote.getPendingApprovals();
      } catch (e, st) {
        ref
            .read(loggerProvider)
            .e('Failed to load pending approvals', error: e, stackTrace: st);
        return const [];
      }
    });

/// One estimate's decision detail: the line items and totals the customer is
/// being asked to approve.
///
/// Fetched on demand (only the detail endpoint carries the breakdown), and
/// re-read after a decision so the page can switch to its read-only state.
final customerApprovalDetailProvider =
    FutureProvider.family<CustomerApprovalDetailResponse, String>((
      ref,
      estimateId,
    ) async {
      final remote = ref.read(customerRemoteDataSourceProvider);
      return remote.getApprovalDetail(estimateId);
    });

/// Outcome of submitting a service booking.
///
/// A booking is either created by the workshop's API, accepted locally to sync
/// when the device is back online, or not accepted at all â€” in which case the
/// customer keeps every selection and can try again.
class BookingSubmission {
  final bool accepted;
  final bool queuedOffline;

  /// Server booking id when created, the local id when queued.
  final String bookingId;

  /// The workshop's public booking reference, when the API returned one.
  final String bookingRef;

  /// Friendly, customer-facing reason when the booking was not accepted.
  final String error;

  /// True when the blocker is a vehicle registration that needs an explicit
  /// retry before the booking can be made.
  final bool retryVehicleSync;

  const BookingSubmission({
    required this.accepted,
    this.queuedOffline = false,
    this.bookingId = '',
    this.bookingRef = '',
    this.error = '',
    this.retryVehicleSync = false,
  });
}

/// Creates one booking.
///
/// The single place a booking is created: the real `POST /bookings` contract
/// (which returns the id and the public `BK-â€¦` reference), the existing
/// offline-first queue when the device has no connection, and the provider
/// refreshes that make the new booking appear in Bookings and on Home.
Future<BookingSubmission> customerSubmitBooking(
  WidgetRef ref, {
  required CustomerVehicleEntity vehicle,
  required String serviceName,
  required String bookingDate,
  required String bookingTime,
  required String notes,
  required String localId,
}) async {
  // A vehicle the workshop has not persisted yet cannot be booked online: its
  // temporary local id does not exist server-side. The decision is pure, so this
  // guarantee is directly testable.
  final resolution = resolveVehicleForBooking(ref, vehicle.id);
  if (!resolution.canSubmitOnline &&
      resolution.outcome != VehicleBookingOutcome.pendingOffline) {
    return BookingSubmission(
      accepted: false,
      retryVehicleSync: resolution.needsVehicleRetry,
      error: resolution.needsVehicleRetry
          ? "We couldn't finish saving this vehicle. Retry its sync, then book "
                'again.'
          : "This vehicle hasn't finished saving at the workshop yet. Sync it, "
                'then book again.',
    );
  }
  final vehicleId = resolution.serverId ?? vehicle.id;

  // Exactly the documented `CreateBookingRequest` fields: the backend's Jackson
  // mapper is configured with the library default, so any extra key makes the
  // request fail.
  final apiPayload = <String, dynamic>{
    'vehicleId': vehicleId,
    'vehicleName': vehicle.displayName,
    'plateNumber': vehicle.plateNumber,
    'serviceType': serviceName,
    'bookingDate': bookingDate,
    'bookingTime': bookingTime,
    'notes': notes,
  };
  // The device copy additionally carries what the app needs to render the
  // booking before (or without) the workshop confirming it.
  final localRecord = <String, dynamic>{
    ...apiPayload,
    'status': 'pending',
    'date': bookingDate,
    'time': bookingTime,
  };

  try {
    final response = await ref
        .read(customerRemoteDataSourceProvider)
        .createBooking(apiPayload);
    if (response.id.isEmpty && response.bookingRef.isEmpty) {
      return const BookingSubmission(
        accepted: false,
        error: "We couldn't confirm this booking. Please try again.",
      );
    }
    localRecord['id'] = response.id;
    localRecord['bookingRef'] = response.bookingRef;
    await _cacheBooking(localRecord, localId: localId);
    _refreshBookingState(ref);
    return BookingSubmission(
      accepted: true,
      bookingId: response.id,
      bookingRef: response.bookingRef,
    );
  } catch (e, st) {
    if (e is NetworkException) {
      // A timeout is the one case where the workshop may already have the
      // booking, so queueing it would risk a duplicate.
      if (e.message.toLowerCase().contains('receive data')) {
        return const BookingSubmission(
          accepted: false,
          error:
              'The request timed out. Check My Bookings before booking again '
              'so you do not book twice.',
        );
      }
      await _queueBookingOffline(ref, apiPayload, localRecord, localId);
      return BookingSubmission(
        accepted: true,
        queuedOffline: true,
        bookingId: localId,
        error: '',
      );
    }
    ref
        .read(loggerProvider)
        .e('Failed to create booking', error: e, stackTrace: st);
    return BookingSubmission(
      accepted: false,
      error: e is AppException
          ? e.message
          : "We couldn't create this booking. Please try again.",
    );
  }
}

/// Stores the booking on the device so it appears in Bookings immediately.
///
/// De-duplication only ever removes a confirmed entry: a queued booking has no
/// reference yet, and treating "no reference" as a match would delete other
/// queued bookings.
Future<void> _cacheBooking(
  Map<String, dynamic> payload, {
  required String localId,
}) async {
  try {
    final box = Hive.box<dynamic>('customer_cache');
    final cached = List<Map<String, dynamic>>.from(
      (box.get('cached_bookings') as List?)?.whereType<Map>() ?? const [],
    );
    final ref0 = (payload['bookingRef'] ?? '').toString().trim();
    cached.removeWhere((entry) {
      final ref = (entry['bookingRef'] ?? '').toString().trim();
      if (ref.isNotEmpty && ref0.isNotEmpty) return ref == ref0;
      return (entry['id'] ?? '').toString().trim() == localId;
    });
    cached.add(payload);
    await box.put('cached_bookings', cached);
  } catch (_) {
    // The booking itself is confirmed; a cache miss must never fail it.
  }
}

/// Offline-first path: stored on the device and queued with the existing sync
/// engine, which replays the documented API payload when connectivity returns.
Future<void> _queueBookingOffline(
  WidgetRef ref,
  Map<String, dynamic> apiPayload,
  Map<String, dynamic> localRecord,
  String localId,
) async {
  try {
    final box = Hive.box<dynamic>('customer_cache');
    final local = GenericLocalDataSource(box);
    await local.save('booking_$localId', localRecord);
    await _cacheBooking(localRecord, localId: localId);
    await ref
        .read(syncQueueProvider)
        .enqueue(
          SyncOperation(
            id: localId,
            entityType: 'booking',
            entityId: localId,
            changeType: ChangeType.create,
            payload: apiPayload,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    await ref.read(syncEngineProvider).syncAll();
  } catch (e, st) {
    ref
        .read(loggerProvider)
        .e('Failed to queue booking offline', error: e, stackTrace: st);
  }
  _refreshBookingState(ref);
}

void _refreshBookingState(WidgetRef ref) {
  ref.invalidate(customerBookingsProvider);
  ref.read(customerDashboardProvider.notifier).refresh();
}

/// True while the workshop has not yet accepted this vehicle.
///
/// Based on the durable local marker written when a vehicle is created offline
/// (and cleared when its create completes or it is deleted), so the answer does
/// not depend on the queued operation still being present, and survives restart.
bool isVehiclePendingSync(WidgetRef ref, String vehicleId) {
  final id = vehicleId.trim();
  if (id.isEmpty) return false;
  if (VehicleIdentityStore.isPending(id)) return true;
  if (VehicleIdentityStore.serverIdFor(id) != null) return false;
  try {
    return ref
        .read(syncQueueProvider)
        .peekAll()
        .any(
          (operation) =>
              operation.entityType == 'vehicle' &&
              operation.entityId == id &&
              operation.changeType == ChangeType.create,
        );
  } catch (_) {
    return false;
  }
}

/// The server id for a vehicle the customer is about to book.
///
/// A vehicle the workshop has not accepted yet has no id the booking API can
/// use. Its registration completes independently through the sync engine (and
/// reconciles the identity map); until then an online submission is refused
/// with honest copy rather than sending a temporary id, and an offline one is
/// queued with its payload rewritten the moment the vehicle syncs.
/// Whether the selected vehicle may be booked, and with which id.
///
/// The decision itself is pure ([decideVehicleBooking]); this only supplies the
/// plugin-backed connectivity state and the local identity facts.
VehicleBookingResolution resolveVehicleForBooking(
  WidgetRef ref,
  String selectedVehicleId,
) {
  final online =
      ref.read(connectivityStatusProvider).value != ConnectivityResult.none;
  return decideVehicleBooking(
    selectedVehicleId: selectedVehicleId,
    isOnline: online,
    identity: ref.read(vehicleIdentityReaderProvider),
  );
}

/// Retries a vehicle registration that exhausted its retries.
///
/// Uses the sync engine's own failed-operation retry, so the same operation —
/// and therefore the same idempotency key — is replayed. A retry can never
/// create a second vehicle.
Future<void> customerRetryVehicleSync(WidgetRef ref) async {
  try {
    await ref.read(syncEngineProvider).retryFailed();
  } catch (_) {}
  await ref.read(customerDashboardProvider.notifier).refresh();
}

/// Outcome of registering or updating one vehicle.
class VehicleSaveResult {
  final bool accepted;
  final bool queuedOffline;

  /// The saved vehicle: the server's record online, the submitted one offline.
  final CustomerVehicleEntity? vehicle;

  /// Friendly, customer-facing reason when the save was not accepted.
  final String error;

  const VehicleSaveResult({
    required this.accepted,
    this.queuedOffline = false,
    this.vehicle,
    this.error = '',
  });
}

/// Registers or updates one vehicle.
///
/// The single write path: the documented `AddVehicleRequest` contract, the
/// existing offline-first queue, and the canonical vehicle state refresh.
Future<VehicleSaveResult> customerSaveVehicle(
  WidgetRef ref, {
  required CustomerVehicleEntity vehicle,
  required bool isEdit,
  required String localId,
}) async {
  final payload = CustomerVehiclePresentation.apiPayload(vehicle);
  final notifier = ref.read(customerDashboardProvider.notifier);

  // A vehicle the workshop has not accepted yet cannot be updated by id: there
  // is no server record to update. Its queued create is rewritten instead, so
  // editing never produces a second registration.
  if (isEdit && isVehiclePendingSync(ref, vehicle.id)) {
    await _queueVehicleOffline(
      ref,
      vehicle: vehicle,
      isEdit: false,
      payload: payload,
      localId: vehicle.id,
    );
    return VehicleSaveResult(
      accepted: true,
      queuedOffline: true,
      vehicle: vehicle,
    );
  }

  try {
    final response = isEdit
        ? await ref
              .read(customerRemoteDataSourceProvider)
              .updateVehicle(vehicle.id, payload)
        : await ref.read(customerRemoteDataSourceProvider).addVehicle(payload);
    final saved = _vehicleFrom(response, fallbackId: vehicle.id);
    notifier.addVehicle(saved);
    await notifier.refresh();
    return VehicleSaveResult(accepted: true, vehicle: saved);
  } catch (e, st) {
    if (e is UnauthorizedException) {
      await ref.read(authNotifierProvider.notifier).logout();
      return const VehicleSaveResult(
        accepted: false,
        error: 'Your session expired. Please sign in again.',
      );
    }
    if (e is NetworkException) {
      await _queueVehicleOffline(
        ref,
        vehicle: vehicle,
        isEdit: isEdit,
        payload: payload,
        localId: localId,
      );
      return VehicleSaveResult(
        accepted: true,
        queuedOffline: true,
        vehicle: vehicle,
      );
    }
    ref
        .read(loggerProvider)
        .e('Failed to save vehicle', error: e, stackTrace: st);
    return VehicleSaveResult(
      accepted: false,
      error: e is AppException
          ? e.message
          : "We couldn't save this vehicle. Please try again.",
    );
  }
}

CustomerVehicleEntity _vehicleFrom(
  VehicleResponse response, {
  required String fallbackId,
}) => CustomerVehicleEntity(
  id: response.id.trim().isEmpty ? fallbackId : response.id,
  brand: response.brand,
  model: response.model,
  plateNumber: response.plateNumber,
  vin: response.vin,
  color: response.color,
  year: response.year,
  mileage: response.mileage,
  lastService: response.lastService,
  nextDue: response.nextDue,
  healthScore: response.healthScore,
);

/// Stores the vehicle on the device and queues the documented payload, so the
/// vehicle is usable (and bookable) before the server has it.
Future<void> _queueVehicleOffline(
  WidgetRef ref, {
  required CustomerVehicleEntity vehicle,
  required bool isEdit,
  required Map<String, dynamic> payload,
  required String localId,
}) async {
  final id = vehicle.id.trim().isEmpty ? localId : vehicle.id;
  final local = CustomerVehicleEntity(
    id: id,
    brand: vehicle.brand,
    model: vehicle.model,
    plateNumber: vehicle.plateNumber,
    vin: vehicle.vin,
    color: vehicle.color,
    year: vehicle.year,
    mileage: vehicle.mileage,
    lastService: vehicle.lastService,
    nextDue: vehicle.nextDue,
    healthScore: vehicle.healthScore,
  );
  try {
    final box = Hive.box<dynamic>('customer_cache');
    final cached = List<Map<String, dynamic>>.from(
      (box.get('cached_vehicles') as List?)?.whereType<Map>() ?? const [],
    );
    cached.removeWhere((entry) => (entry['id'] ?? '').toString() == id);
    cached.add(<String, dynamic>{
      'id': local.id,
      'brand': local.brand,
      'model': local.model,
      'plateNumber': local.plateNumber,
      'vin': local.vin,
      'color': local.color,
      'year': local.year,
      'mileage': local.mileage,
      'lastService': local.lastService,
      'nextDue': local.nextDue,
      'healthScore': local.healthScore,
    });
    await box.put('cached_vehicles', cached);
    await ref
        .read(syncQueueProvider)
        .enqueue(
          SyncOperation(
            id: '$id-${isEdit ? 'update' : 'create'}',
            entityType: 'vehicle',
            entityId: id,
            changeType: isEdit ? ChangeType.update : ChangeType.create,
            payload: payload,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  } catch (e, st) {
    ref
        .read(loggerProvider)
        .e('Failed to queue vehicle offline', error: e, stackTrace: st);
  }
  await VehicleIdentityStore.markPending(id);
  ref.read(customerDashboardProvider.notifier).addVehicle(local);
}

/// Removes one vehicle.
///
/// A vehicle that exists only on this device is dropped locally, and its queued
/// create is withdrawn so the sync engine cannot bring it back. A vehicle the
/// workshop knows about goes through the API, with the same queue used when the
/// device is offline.
Future<bool> customerRemoveVehicle(WidgetRef ref, String id) async {
  final notifier = ref.read(customerDashboardProvider.notifier);
  // A queue that cannot be read (no local storage) is never treated as proof
  // that the vehicle is local-only.
  var isLocalOnly = false;
  try {
    isLocalOnly = ref
        .read(syncQueueProvider)
        .peekAll()
        .any(
          (operation) =>
              operation.entityType == 'vehicle' &&
              operation.entityId == id &&
              operation.changeType == ChangeType.create,
        );
  } catch (_) {
    isLocalOnly = false;
  }

  if (!isLocalOnly) {
    final removed = await notifier.removeVehicle(id);
    if (!removed) return false;
  } else {
    try {
      final queue = ref.read(syncQueueProvider);
      for (final operation
          in queue
              .peekAll()
              .where(
                (operation) =>
                    operation.entityType == 'vehicle' &&
                    operation.entityId == id,
              )
              .toList()) {
        await queue.remove(operation.id);
      }
    } catch (e, st) {
      ref
          .read(loggerProvider)
          .e('Failed to withdraw queued vehicle', error: e, stackTrace: st);
    }
    await VehicleIdentityStore.clearPending(id);
    notifier.removeVehicleLocally(id);
  }
  await ref.read(customerDashboardProvider.notifier).refresh();
  return true;
}

/// Reads the durable vehicle identity facts. The only storage/plugin-aware
/// part of the booking decision, and the seam tests override.
final vehicleIdentityReaderProvider = Provider<VehicleIdentityReader>(
  (ref) => const StoreVehicleIdentityReader(),
);

final customerInvoicesProvider = FutureProvider<List<InvoiceResponse>>((
  ref,
) async {
  final remote = ref.read(customerRemoteDataSourceProvider);
  try {
    return await remote.getInvoices();
  } catch (e, st) {
    ref
        .read(loggerProvider)
        .e('Failed to load invoices', error: e, stackTrace: st);
    return const [];
  }
});

Future<bool> customerProcessApproval(
  WidgetRef ref,
  String estimateId,
  String action,
) async {
  final remote = ref.read(customerRemoteDataSourceProvider);
  final ok = await remote.processApproval(estimateId, action);
  if (ok) {
    ref.read(customerApprovalsRefreshProvider.notifier).state++;
    ref.invalidate(customerApprovalDetailProvider);
    ref.invalidate(customerBookingsProvider);
    ref.invalidate(customerInvoicesProvider);
    ref.read(customerDashboardProvider.notifier).refresh();
  }
  return ok;
}
