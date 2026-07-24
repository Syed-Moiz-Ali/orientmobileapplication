import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';

abstract class TechnicianRepository {
  TechnicianProfileEntity getProfile();
  AttendanceSummaryEntity getAttendanceSummary();
  List<AssignedJobEntity> getAssignedJobs();
  TechnicianStatsEntity getProductivity();
  List<TechnicianJobEntity> getJobs();

  Future<void> saveAttendance({
    required String status,
    required String punchIn,
    required String punchOut,
    required String breakTime,
    required String workHours,
  });
  Future<void> saveJob(TechnicianJobEntity job);
  Future<void> saveAssignedJobStatus(String id, String status);
}
