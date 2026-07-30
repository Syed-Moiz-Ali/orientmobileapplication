import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl(this.remoteDataSource);

  @override
  Future<CustomerEntity> getCustomerProfile() async {
    try {
      final r = await remoteDataSource.getProfile();
      final entity = CustomerEntity(name: r.name, firstName: r.firstName,
          avatarInitials: r.avatarInitials, memberId: r.memberId);
      _cacheProfile(entity);
      return entity;
    } catch (_) {
      return _loadCachedProfile();
    }
  }

  @override
  Future<List<CustomerVehicleEntity>> getVehicles() async {
    try {
      final list = await remoteDataSource.getVehicles();
      final entities = list.map((v) => CustomerVehicleEntity(
        id: v.id, brand: v.brand, model: v.model,
        plateNumber: v.plateNumber, vin: v.vin, color: v.color,
        year: v.year, mileage: v.mileage, lastService: v.lastService,
        nextDue: v.nextDue, healthScore: v.healthScore,
      )).toList();
      _cacheVehicles(entities);
      return entities;
    } catch (_) {
      return _loadCachedVehicles();
    }
  }

  @override
  Future<List<CustomerBookingEntity>> getBookings() async {
    try {
      final list = await remoteDataSource.getBookings();
      final entities = list.map((b) => CustomerBookingEntity(
        service: b.service, vehicleName: b.vehicleName,
        plateNumber: b.plateNumber, date: b.date, time: b.time,
        status: BookingStatus.values.firstWhere(
            (s) => s.name == b.status, orElse: () => BookingStatus.pending),
      )).toList();
      _cacheBookings(entities);
      return entities;
    } catch (_) {
      return _loadCachedBookings();
    }
  }

  @override
  Future<List<CustomerNotificationEntity>> getNotifications() async {
    try {
      final list = await remoteDataSource.getNotifications();
      final entities = list.map((n) => CustomerNotificationEntity(
        id: n.id, title: n.title, body: n.body, time: n.time,
        type: NotifType.values.firstWhere(
            (t) => t.name == n.type, orElse: () => NotifType.carReady),
        isRead: n.isRead,
      )).toList();
      _cacheNotifications(entities);
      return entities;
    } catch (_) {
      return _loadCachedNotifications();
    }
  }

  @override
  Future<CustomerServiceEntity> getActiveService() async {
    try {
      final r = await remoteDataSource.getActiveService();
      final entity = CustomerServiceEntity(
        jobCardId: r.jobCardId, plateNumber: r.plateNumber,
        vehicleName: r.vehicleName, service: r.service,
        started: r.started, estCompletion: r.estCompletion,
        progressPercent: r.progressPercent, currentStage: r.currentStage,
        technicianName: r.technicianName,
        stages: r.stages.map((s) => ServiceStageEntity(
          name: s.name, time: s.time,
          status: StageStatus.values.firstWhere(
              (st) => st.name == s.status, orElse: () => StageStatus.pending),
        )).toList(),
      );
      _cacheService(entity);
      return entity;
    } catch (_) {
      return _loadCachedService();
    }
  }

  // ======== Caching helpers ========

  static const _profileKey = 'cached_profile';
  static const _vehiclesKey = 'cached_vehicles';
  static const _bookingsKey = 'cached_bookings';
  static const _notifsKey = 'cached_notifications';
  static const _serviceKey = 'cached_service';

  Box<dynamic> get _box => Hive.box<dynamic>('customer_cache');

  void _cacheProfile(CustomerEntity e) => _box.put(_profileKey, {'name': e.name, 'firstName': e.firstName, 'avatarInitials': e.avatarInitials, 'memberId': e.memberId});
  CustomerEntity _loadCachedProfile() {
    final d = _box.get(_profileKey) as Map?;
    if (d == null) return const CustomerEntity(name: 'Customer', firstName: 'Customer', avatarInitials: 'C', memberId: '');
    return CustomerEntity(name: d['name'] ?? '', firstName: d['firstName'] ?? '', avatarInitials: d['avatarInitials'] ?? '', memberId: d['memberId'] ?? '');
  }

  void _cacheVehicles(List<CustomerVehicleEntity> list) => _box.put(_vehiclesKey, list.map((v) => v.toJson()).toList());
  List<CustomerVehicleEntity> _loadCachedVehicles() {
    final list = _box.get(_vehiclesKey) as List?;
    if (list == null) return [];
    return list.map((m) => CustomerVehicleEntity.fromJson(Map<String, dynamic>.from(m as Map))).toList();
  }

  void _cacheBookings(List<CustomerBookingEntity> list) => _box.put(_bookingsKey, list.map((b) => b.toJson()).toList());
  List<CustomerBookingEntity> _loadCachedBookings() {
    final list = _box.get(_bookingsKey) as List?;
    if (list == null) return [];
    return list.map((m) => CustomerBookingEntity.fromJson(Map<String, dynamic>.from(m as Map))).toList();
  }

  void _cacheNotifications(List<CustomerNotificationEntity> list) => _box.put(_notifsKey, list.map((n) => n.toJson()).toList());
  List<CustomerNotificationEntity> _loadCachedNotifications() {
    final list = _box.get(_notifsKey) as List?;
    if (list == null) return [];
    return list.map((m) => CustomerNotificationEntity.fromJson(Map<String, dynamic>.from(m as Map))).toList();
  }

  void _cacheService(CustomerServiceEntity e) => _box.put(_serviceKey, e.toJson());
  CustomerServiceEntity _loadCachedService() {
    final d = _box.get(_serviceKey) as Map?;
    if (d == null) return CustomerServiceEntity(jobCardId: '', plateNumber: '', vehicleName: '', service: '', started: '', estCompletion: '', progressPercent: 0, currentStage: '', technicianName: '', stages: []);
    return CustomerServiceEntity.fromJson(Map<String, dynamic>.from(d));
  }
}
