import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/local/helpers/environment_config.dart';
import 'package:orientmobileapplication/core/network/dio_client.dart';
import 'package:orientmobileapplication/features/auth/data/datasources/auth_datasource.dart';
import 'package:orientmobileapplication/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:orientmobileapplication/features/auth/data/datasources/mock_auth_datasource.dart';
import 'package:orientmobileapplication/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/role_config.dart';
import 'package:orientmobileapplication/features/auth/domain/repositories/auth_repository.dart';
import 'package:orientmobileapplication/features/auth/domain/usecases/authenticate.dart';
import 'package:orientmobileapplication/features/auth/domain/usecases/get_role_configs.dart';

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  if (EnvironmentConfig.useMocks) {
    return MockAuthDatasource();
  }
  return AuthRemoteDatasource(ref.watch(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
});

final getRoleConfigsProvider = Provider<GetRoleConfigs>((ref) {
  return GetRoleConfigs(ref.watch(authRepositoryProvider));
});

final authenticateProvider = Provider<Authenticate>((ref) {
  return Authenticate(ref.watch(authRepositoryProvider));
});

final roleConfigsProvider = Provider<List<RoleConfig>>((ref) {
  return ref.watch(getRoleConfigsProvider).call();
});
