// Fixtures mirror `TechnicianJobEntity` + `WorkTaskEntity`
// (apps/staff_app/.../technician/domain/entities/): jobCardNo, dateOfWork,
// startTime, vehicleBrand/Model, plateNumber, customer, status, tasks
// (TaskStatus: pending / inProgress / onHold / completed), notes.
import 'fixture_types.dart';

enum FixtureTaskStatus { pending, inProgress, onHold, completed }

extension FixtureTaskStatusX on FixtureTaskStatus {
  String get labelKey => switch (this) {
        FixtureTaskStatus.pending => 'tech.action.start',
        FixtureTaskStatus.inProgress => 'tech.stage.inProgress',
        FixtureTaskStatus.onHold => 'tech.action.hold',
        FixtureTaskStatus.completed => 'tech.stage.completed',
      };
}

class TechnicianTaskFixture {
  final int id;
  final String ref;
  final LocalizedText description;
  final FixtureTaskStatus status;
  final String? startTime;
  final String? endTime;

  const TechnicianTaskFixture({
    required this.id,
    required this.ref,
    required this.description,
    required this.status,
    this.startTime,
    this.endTime,
  });
}

class TechnicianJobFixture {
  final String jobCardNo;
  final LocalizedText dateOfWork;
  final String startTime;
  final String vehicleBrand;
  final String vehicleModel;
  final String plate;
  final LocalizedText customer;
  final String phone;
  final String vin;
  final LocalizedText odometer;
  final LocalizedText fuel;
  final LocalizedText promised;
  final List<TechnicianTaskFixture> tasks;

  const TechnicianJobFixture({
    required this.jobCardNo,
    required this.dateOfWork,
    required this.startTime,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.plate,
    required this.customer,
    required this.phone,
    required this.vin,
    required this.odometer,
    required this.fuel,
    required this.promised,
    required this.tasks,
  });

  String get vehicleLabel => '$vehicleBrand $vehicleModel';

  int get completedCount =>
      tasks.where((t) => t.status == FixtureTaskStatus.completed).length;
}

const TechnicianJobFixture technicianJobFixture = TechnicianJobFixture(
  jobCardNo: 'JC-2026-0417',
  dateOfWork: LocalizedText('Tue, 13 Oct 2026', 'الثلاثاء، 13 أكتوبر 2026'),
  startTime: '09:30',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Land Cruiser',
  plate: 'A 12345',
  customer: LocalizedText('Ahmed Al Mansoori', 'أحمد المنصوري'),
  phone: '+971 50 123 4567',
  vin: 'JTMHV05J204123456',
  odometer: LocalizedText('96,420 km', '96,420 كم'),
  fuel: LocalizedText('3/4 tank', '3/4 الخزان'),
  promised: LocalizedText('Today · 4:30 PM', 'اليوم · 4:30 م'),
  tasks: [
    TechnicianTaskFixture(
      id: 1,
      ref: 'WI-8841',
      description: LocalizedText(
        'Drain engine oil and replace the oil filter',
        'تصريف زيت المحرك واستبدال فلتر الزيت',
      ),
      status: FixtureTaskStatus.completed,
      startTime: '09:30',
      endTime: '10:05',
    ),
    TechnicianTaskFixture(
      id: 2,
      ref: 'WI-8842',
      description: LocalizedText(
        'Replace front brake pads and inspect discs',
        'استبدال فحمات الفرامل الأمامية وفحص الأقراص',
      ),
      status: FixtureTaskStatus.inProgress,
      startTime: '10:15',
    ),
    TechnicianTaskFixture(
      id: 3,
      ref: 'WI-8843',
      description: LocalizedText(
        'Wheel alignment – front axle',
        'ضبط اتجاه العجلات — المحور الأمامي',
      ),
      status: FixtureTaskStatus.pending,
    ),
    TechnicianTaskFixture(
      id: 4,
      ref: 'WI-8844',
      description: LocalizedText(
        'A/C system pressure test and recharge',
        'اختبار ضغط نظام التكييف وإعادة الشحن',
      ),
      status: FixtureTaskStatus.onHold,
    ),
    TechnicianTaskFixture(
      id: 5,
      ref: 'WI-8845',
      description: LocalizedText(
        'Road test and final quality check',
        'اختبار الطريق وفحص الجودة النهائي',
      ),
      status: FixtureTaskStatus.pending,
    ),
  ],
);

/// No-tasks variant for the empty state capture.
const TechnicianJobFixture technicianJobNoTasksFixture = TechnicianJobFixture(
  jobCardNo: 'JC-2026-0421',
  dateOfWork: LocalizedText('Tue, 13 Oct 2026', 'الثلاثاء، 13 أكتوبر 2026'),
  startTime: '08:00',
  vehicleBrand: 'Nissan',
  vehicleModel: 'Patrol',
  plate: 'D 88421',
  customer: LocalizedText('Mariam Al Zaabi', 'مريم الزعابي'),
  phone: '+971 55 764 2210',
  vin: 'JN1TBNY62U0004821',
  odometer: LocalizedText('54,180 km', '54,180 كم'),
  fuel: LocalizedText('Full tank', 'الخزان ممتلئ'),
  promised: LocalizedText('Today · 6:00 PM', 'اليوم · 6:00 م'),
  tasks: [],
);
