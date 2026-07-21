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

  static const mock = CustomerEntity(
    name: 'Ahmed Hassan',
    firstName: 'Ahmed',
    avatarInitials: 'AH',
    memberId: 'CUST-001',
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

enum BookingStatus { confirmed, completed, pending, cancelled }

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

enum StageStatus { done, inProgress, pending }

class ServiceStageEntity {
  final String name;
  final String? time;
  final StageStatus status;

  const ServiceStageEntity({
    required this.name,
    this.time,
    required this.status,
  });
}

class CustomerServiceEntity {
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

enum NotifType {
  carReady,
  bookingConfirmed,
  invoiceReady,
  approvalNeeded,
  workInProgress,
  reminder,
}

class CustomerNotificationEntity {
  final String id;
  final String title;
  final String body;
  final String time;
  final NotifType type;
  bool isRead;

  CustomerNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  static List<CustomerNotificationEntity> get mock => [
    CustomerNotificationEntity(
      id: 'n1',
      type: NotifType.carReady,
      title: 'Your car is ready!',
      body: 'BMW 3 Series has completed its Full Inspection.',
      time: '26 Mar · 16:30',
      isRead: false,
    ),
    CustomerNotificationEntity(
      id: 'n2',
      type: NotifType.bookingConfirmed,
      title: 'Booking confirmed',
      body: 'Full Inspection on 25 Mar 2026 at 09:00 confirmed.',
      time: '24 Mar · 14:00',
      isRead: false,
    ),
    CustomerNotificationEntity(
      id: 'n3',
      type: NotifType.invoiceReady,
      title: 'Invoice ready',
      body: 'Invoice INV-2026-0003 for £380.00 is now available.',
      time: '26 Mar · 19:00',
      isRead: true,
    ),
    CustomerNotificationEntity(
      id: 'n4',
      type: NotifType.approvalNeeded,
      title: 'Approval needed',
      body: 'Worn brake pads & low coolant found.',
      time: '26 Mar · 10:34',
      isRead: true,
    ),
  ];
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
