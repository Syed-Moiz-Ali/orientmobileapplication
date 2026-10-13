// Fixtures mirror `JobCard` (apps/owner_app/.../domain/entities/job_card.dart):
// id, customerName, vehicle, plateNumber, services, technician,
// estCompletion, amount, status. 8 records with mixed states including a long
// Arabic name; EN pass shows plausible transliterations of the same records.
import 'fixture_types.dart';

enum FixtureJobStatus { inProgress, waitingParts, qualityCheck, completed, pendingApproval, delivered }

extension FixtureJobStatusX on FixtureJobStatus {
  String get labelKey => switch (this) {
        FixtureJobStatus.inProgress => 'jobs.status.inProgress',
        FixtureJobStatus.waitingParts => 'jobs.status.waitingParts',
        FixtureJobStatus.qualityCheck => 'jobs.status.qc',
        FixtureJobStatus.completed => 'jobs.status.completed',
        FixtureJobStatus.pendingApproval => 'jobs.status.pendingApproval',
        FixtureJobStatus.delivered => 'jobs.status.delivered',
      };

  /// One of: neutral, primary, success, warning, danger, info
  String get tone => switch (this) {
        FixtureJobStatus.inProgress => 'primary',
        FixtureJobStatus.waitingParts => 'warning',
        FixtureJobStatus.qualityCheck => 'info',
        FixtureJobStatus.completed => 'success',
        FixtureJobStatus.pendingApproval => 'warning',
        FixtureJobStatus.delivered => 'success',
      };
}

class JobCardFixture {
  final String id;
  final LocalizedText customer;
  final String vehicle;
  final String plate;
  final List<LocalizedText> services;
  final LocalizedText technician;
  final LocalizedText promised;
  final double amount;
  final FixtureJobStatus status;

  const JobCardFixture({
    required this.id,
    required this.customer,
    required this.vehicle,
    required this.plate,
    required this.services,
    required this.technician,
    required this.promised,
    required this.amount,
    required this.status,
  });

  String get vehicleDisplay => '$vehicle · $plate';
}

const List<JobCardFixture> jobCardFixtures = [
  JobCardFixture(
    id: 'JC-2026-0417',
    customer: LocalizedText('Ahmed Al Mansoori', 'أحمد المنصوري'),
    vehicle: 'Toyota Land Cruiser',
    plate: 'A 12345',
    services: [LocalizedText('Oil change', 'تغيير الزيت'), LocalizedText('Brake pads', 'فحمات الفرامل')],
    technician: LocalizedText('Rashid Khan', 'راشد خان'),
    promised: LocalizedText('Today · 4:30 PM', 'اليوم · 4:30 م'),
    amount: 1842.50,
    status: FixtureJobStatus.inProgress,
  ),
  JobCardFixture(
    id: 'JC-2026-0416',
    customer: LocalizedText('Mariam Al Zaabi', 'مريم الزعابي'),
    vehicle: 'Nissan Patrol Platinum',
    plate: 'D 88421',
    services: [LocalizedText('A/C overhaul', 'عمرة المكيف'), LocalizedText('Cabin filter', 'فلتر المقصورة')],
    technician: LocalizedText('Sunil Perera', 'سونيل بيريرا'),
    promised: LocalizedText('Today · 6:00 PM', 'اليوم · 6:00 م'),
    amount: 3480,
    status: FixtureJobStatus.waitingParts,
  ),
  JobCardFixture(
    id: 'JC-2026-0415',
    customer: LocalizedText('Seif bin Rashid', 'سيف بن راشد'),
    vehicle: 'Mercedes-Benz G 63',
    plate: 'AA 55219',
    services: [LocalizedText('Full service', 'صيانة شاملة'), LocalizedText('Wheel alignment', 'ضبط الاتجاه')],
    technician: LocalizedText('Rashid Khan', 'راشد خان'),
    promised: LocalizedText('Today · 2:00 PM', 'اليوم · 2:00 م'),
    amount: 5920.75,
    status: FixtureJobStatus.qualityCheck,
  ),
  JobCardFixture(
    id: 'JC-2026-0414',
    customer: LocalizedText('Fatima Al Hashimi', 'فاطمة الهاشمي'),
    vehicle: 'Lexus LX 570',
    plate: 'K 30212',
    services: [LocalizedText('Brake discs', 'أقراص الفرامل'), LocalizedText('Brake fluid', 'زيت الفرامل')],
    technician: LocalizedText('Imran Ali', 'عمران علي'),
    promised: LocalizedText('Tomorrow · 11:00 AM', 'غداً · 11:00 ص'),
    amount: 2310,
    status: FixtureJobStatus.inProgress,
  ),
  JobCardFixture(
    id: 'JC-2026-0413',
    customer: LocalizedText('Omar Al Falasi', 'عمر الفلاسي'),
    vehicle: 'Range Rover Sport',
    plate: 'J 77410',
    services: [LocalizedText('Suspension check', 'فحص نظام التعليق'), LocalizedText('Alignment', 'ضبط الاتجاه')],
    technician: LocalizedText('Sunil Perera', 'سونيل بيريرا'),
    promised: LocalizedText('Thu · 9:30 AM', 'الخميس · 9:30 ص'),
    amount: 7450,
    status: FixtureJobStatus.waitingParts,
  ),
  JobCardFixture(
    id: 'JC-2026-0412',
    customer: LocalizedText('Sara Ibrahim', 'سارة إبراهيم'),
    vehicle: 'Honda Accord',
    plate: 'M 55873',
    services: [LocalizedText('Periodic maintenance', 'صيانة دورية')],
    technician: LocalizedText('Imran Ali', 'عمران علي'),
    promised: LocalizedText('Today · 12:00 PM', 'اليوم · 12:00 م'),
    amount: 890,
    status: FixtureJobStatus.completed,
  ),
  JobCardFixture(
    id: 'JC-2026-0411',
    customer: LocalizedText(
      'Mohammed Abdulrahman Al Blooshi',
      'محمد عبدالرحمن البلوشي',
    ),
    vehicle: 'Ford F-150 Raptor',
    plate: 'R 66294',
    services: [LocalizedText('Transmission service', 'صيانة ناقل الحركة')],
    technician: LocalizedText('Vishwa Kumar', 'فيشوا كومار'),
    promised: LocalizedText('Sun · 10:00 AM', 'الأحد · 10:00 ص'),
    amount: 12450,
    status: FixtureJobStatus.pendingApproval,
  ),
  JobCardFixture(
    id: 'JC-2026-0410',
    customer: LocalizedText('Layla Al Marzouqi', 'ليلى المرزوقي'),
    vehicle: 'BMW X5',
    plate: 'S 10983',
    services: [LocalizedText('Tyre replacement', 'استبدال الإطارات'), LocalizedText('Wheel balance', 'توازن العجلات')],
    technician: LocalizedText('Vishwa Kumar', 'فيشوا كومار'),
    promised: LocalizedText('Delivered · yesterday', 'تم التسليم · أمس'),
    amount: 4120,
    status: FixtureJobStatus.delivered,
  ),
];
