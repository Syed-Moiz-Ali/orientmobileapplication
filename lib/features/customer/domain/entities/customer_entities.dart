import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_entities.freezed.dart';
part 'customer_entities.g.dart';

// ── Enums ──

enum BookingStatus { confirmed, completed, pending, cancelled }

enum StageStatus { done, inProgress, pending }

enum NotifType {
  carReady,
  bookingConfirmed,
  invoiceReady,
  approvalNeeded,
  workInProgress,
  reminder,
}

// ── Entities ──

@freezed
class CustomerEntity with _$CustomerEntity {
  const factory CustomerEntity({
    required String name,
    required String firstName,
    required String avatarInitials,
    required String memberId,
  }) = _CustomerEntity;

  factory CustomerEntity.fromJson(Map<String, dynamic> json) =>
      _$CustomerEntityFromJson(json);

  static const mock = CustomerEntity(
    name: 'Ahmed Hassan',
    firstName: 'Ahmed',
    avatarInitials: 'AH',
    memberId: 'CUST-001',
  );
}

@freezed
class CustomerVehicleEntity with _$CustomerVehicleEntity {
  const factory CustomerVehicleEntity({
    required String id,
    required String brand,
    required String model,
    required String plateNumber,
    required String vin,
    required String color,
    required int year,
    required String mileage,
    required String lastService,
    required String nextDue,
    required int healthScore,
  }) = _CustomerVehicleEntity;

  const CustomerVehicleEntity._();

  factory CustomerVehicleEntity.fromJson(Map<String, dynamic> json) =>
      _$CustomerVehicleEntityFromJson(json);

  String get displayName => '$brand $model';
  String get shortLabel => '$brand $model · $plateNumber';

  static const List<CustomerVehicleEntity> mock = [
    CustomerVehicleEntity(
      id: '1',
      brand: 'BMW',
      model: '3 Series',
      plateNumber: 'AB19 XYZ',
      vin: 'WBA8E9G58GNT44078',
      color: 'Alpine White',
      year: 2019,
      mileage: '41,200 km',
      lastService: '10 Nov 2025',
      nextDue: '10 May 2026',
      healthScore: 82,
    ),
    CustomerVehicleEntity(
      id: '2',
      brand: 'Ford',
      model: 'Focus',
      plateNumber: 'FO21 CUS',
      vin: '1FADP3F29EL381234',
      color: 'Ocean Blue',
      year: 2021,
      mileage: '28,500 km',
      lastService: '22 Sep 2025',
      nextDue: '22 Mar 2026',
      healthScore: 64,
    ),
  ];
}

@freezed
class CustomerBookingEntity with _$CustomerBookingEntity {
  const factory CustomerBookingEntity({
    required String service,
    required String vehicleName,
    required String plateNumber,
    required String date,
    required String time,
    required BookingStatus status,
  }) = _CustomerBookingEntity;

  const CustomerBookingEntity._();

  factory CustomerBookingEntity.fromJson(Map<String, dynamic> json) =>
      _$CustomerBookingEntityFromJson(json);

  String get statusLabel {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  static const List<CustomerBookingEntity> mock = [
    CustomerBookingEntity(
      service: 'Oil Change & Filter',
      vehicleName: 'BMW 3 Series',
      plateNumber: 'AB19 XYZ',
      date: '5 Apr 2026',
      time: '10:00 AM',
      status: BookingStatus.confirmed,
    ),
    CustomerBookingEntity(
      service: 'Brake Inspection',
      vehicleName: 'Ford Focus',
      plateNumber: 'FO21 CUS',
      date: '20 Mar 2026',
      time: '2:00 PM',
      status: BookingStatus.completed,
    ),
  ];
}

@freezed
class ServiceStageEntity with _$ServiceStageEntity {
  const factory ServiceStageEntity({
    required String name,
    String? time,
    required StageStatus status,
  }) = _ServiceStageEntity;

  factory ServiceStageEntity.fromJson(Map<String, dynamic> json) =>
      _$ServiceStageEntityFromJson(json);
}

@freezed
class CustomerServiceEntity with _$CustomerServiceEntity {
  const factory CustomerServiceEntity({
    required String jobCardId,
    required String plateNumber,
    required String vehicleName,
    required String service,
    required String started,
    required String estCompletion,
    required int progressPercent,
    required String currentStage,
    required String technicianName,
    required List<ServiceStageEntity> stages,
  }) = _CustomerServiceEntity;

  factory CustomerServiceEntity.fromJson(Map<String, dynamic> json) =>
      _$CustomerServiceEntityFromJson(json);

  static const mock = CustomerServiceEntity(
    jobCardId: 'JC-2026-1245',
    plateNumber: 'AB19 XYZ',
    vehicleName: 'BMW 3 Series',
    service: 'Full Inspection',
    started: '09:00 AM',
    estCompletion: '12:30 PM',
    progressPercent: 65,
    currentStage: 'Service Work',
    technicianName: 'Khalid A.',
    stages: [
      ServiceStageEntity(
        name: 'Vehicle Received',
        time: '09:00 AM',
        status: StageStatus.done,
      ),
      ServiceStageEntity(
        name: 'Initial Inspection',
        time: '09:20 AM',
        status: StageStatus.done,
      ),
      ServiceStageEntity(
        name: 'Parts Preparation',
        time: '09:45 AM',
        status: StageStatus.done,
      ),
      ServiceStageEntity(
        name: 'Service Work',
        time: '10:15 AM',
        status: StageStatus.inProgress,
      ),
      ServiceStageEntity(name: 'Quality Check', status: StageStatus.pending),
      ServiceStageEntity(name: 'Wash & Cleaning', status: StageStatus.pending),
      ServiceStageEntity(
        name: 'Ready for Delivery',
        status: StageStatus.pending,
      ),
    ],
  );
}

@freezed
class CustomerNotificationEntity with _$CustomerNotificationEntity {
  const factory CustomerNotificationEntity({
    required String id,
    required String title,
    required String body,
    required String time,
    required NotifType type,
    @Default(false) bool isRead,
  }) = _CustomerNotificationEntity;

  factory CustomerNotificationEntity.fromJson(Map<String, dynamic> json) =>
      _$CustomerNotificationEntityFromJson(json);

  static List<CustomerNotificationEntity> get mock => [
        const CustomerNotificationEntity(
          id: 'n1',
          type: NotifType.carReady,
          title: 'Your car is ready!',
          body: 'BMW 3 Series has completed its Full Inspection.',
          time: '26 Mar · 16:30',
          isRead: false,
        ),
        const CustomerNotificationEntity(
          id: 'n2',
          type: NotifType.bookingConfirmed,
          title: 'Booking confirmed',
          body: 'Full Inspection on 25 Mar 2026 at 09:00 confirmed.',
          time: '24 Mar · 14:00',
          isRead: false,
        ),
        const CustomerNotificationEntity(
          id: 'n3',
          type: NotifType.invoiceReady,
          title: 'Invoice ready',
          body: 'Invoice INV-2026-0003 for £380.00 is now available.',
          time: '26 Mar · 19:00',
          isRead: true,
        ),
        const CustomerNotificationEntity(
          id: 'n4',
          type: NotifType.approvalNeeded,
          title: 'Approval needed',
          body: 'Worn brake pads & low coolant found.',
          time: '26 Mar · 10:34',
          isRead: true,
        ),
      ];
}

@freezed
class ServiceTypeEntity with _$ServiceTypeEntity {
  const factory ServiceTypeEntity({
    required String id,
    required String name,
    required String price,
    required String duration,
  }) = _ServiceTypeEntity;

  factory ServiceTypeEntity.fromJson(Map<String, dynamic> json) =>
      _$ServiceTypeEntityFromJson(json);

  static const List<ServiceTypeEntity> list = [
    ServiceTypeEntity(
      id: '1',
      name: 'Oil Change',
      price: 'From £65',
      duration: '~1 hr',
    ),
    ServiceTypeEntity(
      id: '2',
      name: 'Tyre Rotation',
      price: 'From £55',
      duration: '~45 min',
    ),
    ServiceTypeEntity(
      id: '3',
      name: 'Full Inspection',
      price: 'From £120',
      duration: '~2 hrs',
    ),
    ServiceTypeEntity(
      id: '4',
      name: 'General Repair',
      price: 'POA',
      duration: 'Varies',
    ),
    ServiceTypeEntity(
      id: '5',
      name: 'MOT Test',
      price: 'From £54.85',
      duration: '~1 hr',
    ),
    ServiceTypeEntity(
      id: '6',
      name: 'Full Service',
      price: 'From £280',
      duration: '~3 hrs',
    ),
  ];
}

const List<String> kTimeSlots = [
  '08:00',
  '09:00',
  '10:00',
  '11:00',
  '12:00',
  '13:00',
  '14:00',
  '15:00',
  '16:00',
];
