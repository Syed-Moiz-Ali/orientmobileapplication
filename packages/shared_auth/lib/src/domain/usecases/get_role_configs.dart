import 'package:shared_auth/src/domain/entities/role_config.dart';
import 'package:shared_auth/src/domain/repositories/auth_repository.dart';

class GetRoleConfigs {
  final AuthRepository _repository;

  GetRoleConfigs(this._repository);

  List<RoleConfig> call() => _repository.getRoleConfigs();
}
