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

class CustomerEntity {
  final String name;
  final String firstName;
  final String avatarInitials;
  final String memberId;

  const CustomerEntity({
    required this.name,
    required this.firstName,
    required this.avatarInitials,
    required this.memberId,
  });

  static const mock = CustomerEntity(name: 'Ahmed Hassan', firstName: 'Ahmed', avatarInitials: 'AH', memberId: 'CUST-001');
  Map<String, dynamic> toJson() => {'name': name, 'firstName': firstName, 'avatarInitials': avatarInitials, 'memberId': memberId};
  factory CustomerEntity.fromJson(Map<String, dynamic> j) => CustomerEntity(
    name: j['name'] as String? ?? '', firstName: j['firstName'] as String? ?? '',
    avatarInitials: j['avatarInitials'] as String? ?? '', memberId: j['memberId'] as String? ?? '');
}

class CustomerVehicleEntity {
  final String id;
  final String brand;
  final String model;
  final String plateNumber;
  final String vin;
  final String color;
  final int year;
  final String mileage;
  final String lastService;
  final String nextDue;
  final int healthScore;

  const CustomerVehicleEntity({
    required this.id,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.vin,
    required this.color,
    required this.year,
    required this.mileage,
    required this.lastService,
    required this.nextDue,
    required this.healthScore,
  });

  String get displayName => '$brand $model';
  String get shortLabel => '$brand $model \u00b7 $plateNumber';

  static const List<CustomerVehicleEntity> mock = [];
  Map<String, dynamic> toJson() => {'id': id, 'brand': brand, 'model': model, 'plateNumber': plateNumber, 'vin': vin, 'color': color, 'year': year, 'mileage': mileage, 'lastService': lastService, 'nextDue': nextDue, 'healthScore': healthScore};
  factory CustomerVehicleEntity.fromJson(Map<String, dynamic> j) => CustomerVehicleEntity(
    id: j['id'] as String? ?? '', brand: j['brand'] as String? ?? '', model: j['model'] as String? ?? '',
    plateNumber: j['plateNumber'] as String? ?? '', vin: j['vin'] as String? ?? '', color: j['color'] as String? ?? '',
    year: j['year'] as int? ?? 0, mileage: j['mileage'] as String? ?? '',
    lastService: j['lastService'] as String? ?? '', nextDue: j['nextDue'] as String? ?? '',
    healthScore: j['healthScore'] as int? ?? 0);
}

class CustomerBookingEntity {
  final String service;
  final String vehicleName;
  final String plateNumber;
  final String date;
  final String time;
  final BookingStatus status;

  const CustomerBookingEntity({
    required this.service,
    required this.vehicleName,
    required this.plateNumber,
    required this.date,
    required this.time,
    required this.status,
  });

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
    CustomerBookingEntity(service: 'Oil Change & Filter', vehicleName: 'BMW 3 Series', plateNumber: 'AB19 XYZ', date: '5 Apr 2026', time: '10:00 AM', status: BookingStatus.confirmed),
    CustomerBookingEntity(service: 'Brake Inspection', vehicleName: 'Ford Focus', plateNumber: 'FO21 CUS', date: '20 Mar 2026', time: '2:00 PM', status: BookingStatus.completed),
  ];
  Map<String, dynamic> toJson() => {'service': service, 'vehicleName': vehicleName, 'plateNumber': plateNumber, 'date': date, 'time': time, 'status': status.name};
  factory CustomerBookingEntity.fromJson(Map<String, dynamic> j) => CustomerBookingEntity(
    service: j['service'] as String? ?? '', vehicleName: j['vehicleName'] as String? ?? '',
    plateNumber: j['plateNumber'] as String? ?? '', date: j['date'] as String? ?? '',
    time: j['time'] as String? ?? '',
    status: BookingStatus.values.firstWhere((e) => e.name == j['status'], orElse: () => BookingStatus.pending));
}

class ServiceStageEntity {
  final String name;
  final String? time;
  final StageStatus status;

  const ServiceStageEntity({required this.name, this.time, required this.status});
  Map<String, dynamic> toJson() => {'name': name, 'time': time, 'status': status.name};
  factory ServiceStageEntity.fromJson(Map<String, dynamic> j) => ServiceStageEntity(
    name: j['name'] as String? ?? '', time: j['time'] as String?,
    status: StageStatus.values.firstWhere((e) => e.name == j['status'], orElse: () => StageStatus.pending));
}

class CustomerServiceEntity {
  final bool hasActiveJob;
  final String jobCardId;
  final String plateNumber;
  final String vehicleName;
  final String service;
  final String started;
  final String estCompletion;
  final int progressPercent;
  final String currentStage;
  final String technicianName;
  final List<ServiceStageEntity> stages;

  const CustomerServiceEntity({
    this.hasActiveJob = false,
    required this.jobCardId,
    required this.plateNumber,
    required this.vehicleName,
    required this.service,
    required this.started,
    required this.estCompletion,
    required this.progressPercent,
    required this.currentStage,
    required this.technicianName,
    required this.stages,
  });

  static const mock = CustomerServiceEntity(
    hasActiveJob: false,
    jobCardId: '',
    plateNumber: '',
    vehicleName: '',
    service: '',
    started: '',
    estCompletion: '',
    progressPercent: 0,
    currentStage: '',
    technicianName: '',
    stages: [],
  );
  Map<String, dynamic> toJson() => {'jobCardId': jobCardId, 'plateNumber': plateNumber, 'vehicleName': vehicleName, 'service': service, 'started': started, 'estCompletion': estCompletion, 'progressPercent': progressPercent, 'currentStage': currentStage, 'technicianName': technicianName, 'stages': stages.map((s) => s.toJson()).toList()};
  factory CustomerServiceEntity.fromJson(Map<String, dynamic> j) => CustomerServiceEntity(
    jobCardId: j['jobCardId'] as String? ?? '', plateNumber: j['plateNumber'] as String? ?? '',
    vehicleName: j['vehicleName'] as String? ?? '', service: j['service'] as String? ?? '',
    started: j['started'] as String? ?? '', estCompletion: j['estCompletion'] as String? ?? '',
    progressPercent: j['progressPercent'] as int? ?? 0, currentStage: j['currentStage'] as String? ?? '',
    technicianName: j['technicianName'] as String? ?? '',
    stages: (j['stages'] as List?)?.map((s) => ServiceStageEntity.fromJson(Map<String, dynamic>.from(s as Map))).toList() ?? []);
}

class CustomerNotificationEntity {
  final String id;
  final String title;
  final String body;
  final String time;
  final NotifType type;
  final bool isRead;

  const CustomerNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  CustomerNotificationEntity copyWith({bool? isRead}) {
    return CustomerNotificationEntity(
      id: id,
      title: title,
      body: body,
      time: time,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }

  static List<CustomerNotificationEntity> get mock => [
    const CustomerNotificationEntity(
      id: 'n1',
      type: NotifType.carReady,
      title: 'Your car is ready!',
      body: 'BMW 3 Series has completed its Full Inspection.',
      time: '26 Mar \u00b7 16:30',
    ),
    const CustomerNotificationEntity(
      id: 'n2',
      type: NotifType.bookingConfirmed,
      title: 'Booking confirmed',
      body: 'Full Inspection on 25 Mar 2026 at 09:00 confirmed.',
      time: '24 Mar \u00b7 14:00',
    ),
    const CustomerNotificationEntity(
      id: 'n3',
      type: NotifType.invoiceReady,
      title: 'Invoice ready',
      body: 'Invoice INV-2026-0003 for \u00a3380.00 is now available.',
      time: '26 Mar \u00b7 19:00',
      isRead: true,
    ),
    const CustomerNotificationEntity(
      id: 'n4',
      type: NotifType.approvalNeeded,
      title: 'Approval needed',
      body: 'Worn brake pads & low coolant found.',
      time: '26 Mar \u00b7 10:34',
      isRead: true,
    ),
  ];
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'body': body, 'time': time, 'type': type.name, 'isRead': isRead};
  factory CustomerNotificationEntity.fromJson(Map<String, dynamic> j) => CustomerNotificationEntity(
    id: j['id'] as String? ?? '', title: j['title'] as String? ?? '', body: j['body'] as String? ?? '',
    time: j['time'] as String? ?? '', isRead: j['isRead'] as bool? ?? false,
    type: NotifType.values.firstWhere((e) => e.name == j['type'], orElse: () => NotifType.carReady));
}

class ServiceTypeEntity {
  final String id;
  final String name;
  final String price;
  final String duration;

  const ServiceTypeEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });

  static const List<ServiceTypeEntity> list = [
    ServiceTypeEntity(
      id: '1',
      name: 'Oil Change',
      price: 'From \u00a365',
      duration: '~1 hr',
    ),
    ServiceTypeEntity(
      id: '2',
      name: 'Tyre Rotation',
      price: 'From \u00a355',
      duration: '~45 min',
    ),
    ServiceTypeEntity(
      id: '3',
      name: 'Full Inspection',
      price: 'From \u00a3120',
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
      price: 'From \u00a354.85',
      duration: '~1 hr',
    ),
    ServiceTypeEntity(
      id: '6',
      name: 'Full Service',
      price: 'From \u00a3280',
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
