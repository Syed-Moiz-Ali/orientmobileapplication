import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';

class TechnicianLocalDatasource {
  final Box<dynamic> _box;

  TechnicianLocalDatasource(this._box);

  Future<void> saveAttendance({
    required String status,
    required String punchIn,
    required String punchOut,
    required String breakTime,
    required String workHours,
  }) async {
    final payload = {
      'status': status,
      'punchIn': punchIn,
      'punchOut': punchOut,
      'breakTime': breakTime,
      'workHours': workHours,
    };
    await _box.put('attendance', payload);
  }

  Map<String, dynamic>? loadAttendance() {
    final att = _box.get('attendance');
    if (att != null) {
      return Map<String, dynamic>.from(att);
    }
    return null;
  }

  Future<void> saveJob(TechnicianJobEntity job) async {
    final payload = {
      'jobCardNo': job.jobCardNo,
      'dateOfWork': job.dateOfWork,
      'startTime': job.startTime,
      'vehicleBrand': job.vehicleBrand,
      'vehicleModel': job.vehicleModel,
      'plateNumber': job.plateNumber,
      'status': job.status.name,
      'notes': job.notes,
      'tasks': job.tasks
          .map((t) => {
                'id': t.id,
                'description': t.description,
                'status': t.status.name,
                'startTime': t.startTime,
                'endTime': t.endTime,
              })
          .toList(),
    };
    final local = GenericLocalDataSource(_box);
    await local.save(job.jobCardNo, payload);
  }

  List<TechnicianJobEntity> loadJobs() {
    final savedJobs = _box.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .where((v) => v['jobCardNo'] != null)
        .map((v) => TechnicianJobEntity.fromJson(v))
        .toList();
    return savedJobs;
  }

  Future<void> saveAssignedJobStatus(String id, String status) async {
    final payload = {'id': id, 'status': status};
    await _box.put('assigned_$id', payload);
  }
}
