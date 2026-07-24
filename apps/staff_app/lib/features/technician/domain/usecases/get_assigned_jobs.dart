import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/domain/repositories/technician_repository.dart';

class GetAssignedJobs {
  final TechnicianRepository _repository;

  GetAssignedJobs(this._repository);

  List<AssignedJobEntity> call() {
    return _repository.getAssignedJobs();
  }
}
