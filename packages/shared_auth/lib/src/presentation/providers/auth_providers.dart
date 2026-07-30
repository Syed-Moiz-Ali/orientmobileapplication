import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/data/datasources/auth_datasource.dart';
import 'package:shared_auth/src/data/datasources/auth_remote_datasource.dart';
import 'package:shared_auth/src/data/repositories/auth_repository_impl.dart';
import 'package:shared_auth/src/domain/entities/role_config.dart';
import 'package:shared_auth/src/domain/repositories/auth_repository.dart';
import 'package:shared_auth/src/domain/usecases/authenticate.dart';
import 'package:shared_auth/src/domain/usecases/get_role_configs.dart';
import 'package:shared_auth/src/network/dio_client_provider.dart';

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  return AuthRemoteDatasource(ref.read(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
});

final getRoleConfigsProvider = Provider<GetRoleConfigs>((ref) {
  return GetRoleConfigs(ref.watch(authRepositoryProvider));
});

final sendOtpProvider = Provider<SendOtp>((ref) => SendOtp(ref.watch(authRepositoryProvider)));
final verifyOtpProvider = Provider<VerifyOtp>((ref) => VerifyOtp(ref.watch(authRepositoryProvider)));
final sendEmailOtpProvider = Provider<SendEmailOtp>((ref) => SendEmailOtp(ref.watch(authRepositoryProvider)));
final verifyEmailOtpProvider = Provider<VerifyEmailOtp>((ref) => VerifyEmailOtp(ref.watch(authRepositoryProvider)));
final registerUserProvider = Provider<RegisterUser>((ref) => RegisterUser(ref.watch(authRepositoryProvider)));
final loginWithPasswordProvider = Provider<LoginWithPassword>((ref) => LoginWithPassword(ref.watch(authRepositoryProvider)));
final forgotPasswordProvider = Provider<ForgotPassword>((ref) => ForgotPassword(ref.watch(authRepositoryProvider)));
final resetPasswordProvider = Provider<ResetPassword>((ref) => ResetPassword(ref.watch(authRepositoryProvider)));

final roleConfigsProvider = Provider<List<RoleConfig>>((ref) {
  return ref.watch(getRoleConfigsProvider).call();
});
