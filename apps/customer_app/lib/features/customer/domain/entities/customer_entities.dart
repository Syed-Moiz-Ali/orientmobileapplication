import 'package:shared_core/shared_core.dart';

enum BookingStatus {
  confirmed,
  completed,
  pending,
  cancelled,
  approvalRequired,
  vehicleReceived,
  approved,
  workAssigned,
  inProgress,
  delivered,
}

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

  Map<String, dynamic> toJson() => {
    'name': name,
    'firstName': firstName,
    'avatarInitials': avatarInitials,
    'memberId': memberId,
  };
  factory CustomerEntity.fromJson(Map<String, dynamic> j) => CustomerEntity(
    name: j['name'] as String? ?? '',
    firstName: j['firstName'] as String? ?? '',
    avatarInitials: j['avatarInitials'] as String? ?? '',
    memberId: j['memberId'] as String? ?? '',
  );
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'brand': brand,
    'model': model,
    'plateNumber': plateNumber,
    'vin': vin,
    'color': color,
    'year': year,
    'mileage': mileage,
    'lastService': lastService,
    'nextDue': nextDue,
    'healthScore': healthScore,
  };
  factory CustomerVehicleEntity.fromJson(Map<String, dynamic> j) =>
      CustomerVehicleEntity(
        id: j['id'] as String? ?? '',
        brand: j['brand'] as String? ?? '',
        model: j['model'] as String? ?? '',
        plateNumber: j['plateNumber'] as String? ?? '',
        vin: j['vin'] as String? ?? '',
        color: j['color'] as String? ?? '',
        year: j['year'] as int? ?? 0,
        mileage: j['mileage'] as String? ?? '',
        lastService: j['lastService'] as String? ?? '',
        nextDue: j['nextDue'] as String? ?? '',
        healthScore: j['healthScore'] as int? ?? -1,
      );
}

class CustomerBookingEntity {
  final String id;
  final String service;
  final String vehicleName;
  final String plateNumber;
  final String date;
  final String time;
  final BookingStatus status;
  final String jobCardId;

  /// Public, prefixed booking reference (BK-â€¦) â€” the customer-facing
  /// identifier, preferred over internal job-card references.
  final String bookingRef;
  final String jobCardRef;
  final String jobCardStatus;
  final String estimateId;
  final double estimateAmount;

  const CustomerBookingEntity({
    this.id = '',
    required this.service,
    required this.vehicleName,
    required this.plateNumber,
    required this.date,
    required this.time,
    required this.status,
    this.jobCardId = '',
    this.bookingRef = '',
    this.jobCardRef = '',
    this.jobCardStatus = '',
    this.estimateId = '',
    this.estimateAmount = 0,
  });

  String get statusLabel {
    // FE-FIX (pre-deployment, P2-8): one canonical vocabulary across apps.
    return AppStatusLabels.booking(status.name);
  }

  static BookingStatus parseStatus({
    required String bookingStatus,
    String jobCardStatus = '',
    bool approvalRequired = false,
  }) {
    if (approvalRequired) return BookingStatus.approvalRequired;
    final raw = (jobCardStatus.isNotEmpty ? jobCardStatus : bookingStatus)
        .trim()
        .replaceAll('_', '')
        .toLowerCase();
    return switch (raw) {
      'confirmed' => BookingStatus.confirmed,
      'completed' || 'qualitycheckpassed' => BookingStatus.completed,
      'cancelled' || 'canceled' => BookingStatus.cancelled,
      'waitingcustomerapproval' => BookingStatus.approvalRequired,
      'vehiclereceived' => BookingStatus.vehicleReceived,
      'inspected' || 'approved' => BookingStatus.approved,
      'workassigned' => BookingStatus.workAssigned,
      'inprogress' || 'inservice' || 'qualitycheck' => BookingStatus.inProgress,
      'delivered' => BookingStatus.delivered,
      _ => BookingStatus.pending,
    };
  }

  // FIX (audit P0): UK-flavoured mock bookings removed â€” data comes from the API.

  Map<String, dynamic> toJson() => {
    'id': id,
    'service': service,
    'vehicleName': vehicleName,
    'plateNumber': plateNumber,
    'date': date,
    'time': time,
    'status': status.name,
    'jobCardId': jobCardId,
    'bookingRef': bookingRef,
    'jobCardRef': jobCardRef,
    'jobCardStatus': jobCardStatus,
    'estimateId': estimateId,
    'estimateAmount': estimateAmount,
  };
  factory CustomerBookingEntity.fromJson(Map<String, dynamic> j) =>
      CustomerBookingEntity(
        id: (j['id'] ?? '').toString(),
        service: j['service'] as String? ?? '',
        vehicleName: j['vehicleName'] as String? ?? '',
        plateNumber: j['plateNumber'] as String? ?? '',
        date: j['date'] as String? ?? '',
        time: j['time'] as String? ?? '',
        status: CustomerBookingEntity.parseStatus(
          bookingStatus: (j['status'] ?? '').toString(),
          jobCardStatus: (j['jobCardStatus'] ?? '').toString(),
          approvalRequired: j['approvalRequired'] as bool? ?? false,
        ),
        jobCardId: (j['jobCardId'] ?? '').toString(),
        bookingRef: (j['bookingRef'] ?? '').toString(),
        jobCardRef: (j['jobCardRef'] ?? '').toString(),
        jobCardStatus: (j['jobCardStatus'] ?? '').toString(),
        estimateId: (j['estimateId'] ?? '').toString(),
        estimateAmount: (j['estimateAmount'] as num?)?.toDouble() ?? 0,
      );
}

class ServiceStageEntity {
  final String name;
  final String? time;
  final StageStatus status;

  const ServiceStageEntity({
    required this.name,
    this.time,
    required this.status,
  });
  Map<String, dynamic> toJson() => {
    'name': name,
    'time': time,
    'status': status.name,
  };
  factory ServiceStageEntity.fromJson(Map<String, dynamic> j) =>
      ServiceStageEntity(
        name: j['name'] as String? ?? '',
        time: j['time'] as String?,
        status: StageStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => StageStatus.pending,
        ),
      );
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
  Map<String, dynamic> toJson() => {
    'jobCardId': jobCardId,
    'plateNumber': plateNumber,
    'vehicleName': vehicleName,
    'service': service,
    'started': started,
    'estCompletion': estCompletion,
    'progressPercent': progressPercent,
    'currentStage': currentStage,
    'technicianName': technicianName,
    'stages': stages.map((s) => s.toJson()).toList(),
  };
  factory CustomerServiceEntity.fromJson(Map<String, dynamic> j) =>
      CustomerServiceEntity(
        jobCardId: j['jobCardId'] as String? ?? '',
        plateNumber: j['plateNumber'] as String? ?? '',
        vehicleName: j['vehicleName'] as String? ?? '',
        service: j['service'] as String? ?? '',
        started: j['started'] as String? ?? '',
        estCompletion: j['estCompletion'] as String? ?? '',
        progressPercent: j['progressPercent'] as int? ?? 0,
        currentStage: j['currentStage'] as String? ?? '',
        technicianName: j['technicianName'] as String? ?? '',
        stages:
            (j['stages'] as List?)
                ?.map(
                  (s) => ServiceStageEntity.fromJson(
                    Map<String, dynamic>.from(s as Map),
                  ),
                )
                .toList() ??
            [],
      );
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

  // FIX (audit P0): UK-flavoured mock notifications (incl. a Â£ invoice)
  // removed â€” notifications come from the API.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'time': time,
    'type': type.name,
    'isRead': isRead,
  };
  factory CustomerNotificationEntity.fromJson(Map<String, dynamic> j) =>
      CustomerNotificationEntity(
        id: j['id'] as String? ?? '',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        time: j['time'] as String? ?? '',
        isRead: j['isRead'] as bool? ?? false,
        type: NotifType.values.firstWhere(
          (e) => e.name == j['type'],
          orElse: () => NotifType.carReady,
        ),
      );
}
