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

  // FIX (audit P0): UK-flavoured mock bookings removed — data comes from the API.

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

  // FIX (audit P0): empty-state mock removed; real service state comes from
  // the /customers/services/active API.
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

  // FIX (audit P0): UK-flavoured mock notifications (incl. a £ invoice)
  // removed — notifications come from the API.
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

  // FIX (audit P0): the hardcoded GBP ("From £65") service catalogue is
  // removed — services and prices must come from the /services/types API so
  // the workshop controls pricing and currency.
  static const List<ServiceTypeEntity> list = [];
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
