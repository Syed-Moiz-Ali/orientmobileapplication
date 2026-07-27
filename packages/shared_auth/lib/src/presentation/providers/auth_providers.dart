import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/data/datasources/auth_datasource.dart';
import 'package:shared_auth/src/data/datasources/auth_remote_datasource.dart';
import 'package:shared_auth/src/data/datasources/mock_auth_datasource.dart';
import 'package:shared_auth/src/data/repositories/auth_repository_impl.dart';
import 'package:shared_auth/src/domain/entities/role_config.dart';
import 'package:shared_auth/src/domain/repositories/auth_repository.dart';
import 'package:shared_auth/src/domain/usecases/authenticate.dart';
import 'package:shared_auth/src/domain/usecases/get_role_configs.dart';
import 'package:shared_auth/src/network/dio_client_provider.dart';
import 'package:shared_core/src/local/helpers/environment_config.dart';
import 'package:shared_models/src/user_role.dart';

final mockAuthDefaultRoleProvider = Provider<UserRole?>((ref) => null);

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  if (EnvironmentConfig.useMocks) {
    final roleOverride = ref.read(mockAuthDefaultRoleProvider);
    return MockAuthDatasource(defaultRole: roleOverride);
  }
  return AuthRemoteDatasource(ref.read(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
});

final getRoleConfigsProvider = Provider<GetRoleConfigs>((ref) {
  return GetRoleConfigs(ref.watch(authRepositoryProvider));
});

final sendOtpProvider = Provider<SendOtp>((ref) {
  return SendOtp(ref.watch(authRepositoryProvider));
});

final verifyOtpProvider = Provider<VerifyOtp>((ref) {
  return VerifyOtp(ref.watch(authRepositoryProvider));
});

final roleConfigsProvider = Provider<List<RoleConfig>>((ref) {
  return ref.watch(getRoleConfigsProvider).call();
});
