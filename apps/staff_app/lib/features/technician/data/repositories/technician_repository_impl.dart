import 'package:hive/hive.dart';
import 'package:staff_app/features/technician/data/datasources/technician_local_datasource.dart';
import 'package:staff_app/features/technician/data/datasources/technician_mock_datasource.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/domain/repositories/technician_repository.dart';

class TechnicianRepositoryImpl implements TechnicianRepository {
  final TechnicianLocalDatasource _local;
  final TechnicianMockDatasource _mock;

  TechnicianRepositoryImpl()
      : _local = TechnicianLocalDatasource(Hive.box<dynamic>('technician_jobs')),
        _mock = TechnicianMockDatasource();

  @override
  TechnicianProfileEntity getProfile() => _mock.profile;

  @override
  AttendanceSummaryEntity getAttendanceSummary() => _mock.attendanceSummary;

  @override
  List<AssignedJobEntity> getAssignedJobs() => _mock.assignedJobs;

  @override
  TechnicianStatsEntity getProductivity() => _mock.productivity;

  @override
  List<TechnicianJobEntity> getJobs() {
    final saved = _local.loadJobs();
    if (saved.isNotEmpty) return saved;
    return _mock.jobs;
  }

  @override
  Future<void> saveAttendance({
    required String status,
    required String punchIn,
    required String punchOut,
    required String breakTime,
    required String workHours,
  }) async {
    await _local.saveAttendance(
      status: status,
      punchIn: punchIn,
      punchOut: punchOut,
      breakTime: breakTime,
      workHours: workHours,
    );
  }

  @override
  Future<void> saveJob(TechnicianJobEntity job) async {
    await _local.saveJob(job);
  }

  @override
  Future<void> saveAssignedJobStatus(String id, String status) async {
    await _local.saveAssignedJobStatus(id, status);
  }
}
