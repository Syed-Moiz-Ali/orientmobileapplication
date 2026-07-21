import 'package:orientmobileapplication/features/auth/domain/entities/role_config.dart';
import 'package:orientmobileapplication/features/auth/domain/repositories/auth_repository.dart';

class GetRoleConfigs {
  final AuthRepository _repository;

  GetRoleConfigs(this._repository);

  List<RoleConfig> call() => _repository.getRoleConfigs();
}
