export 'package:shared_auth/l10n/gen/shared_auth_localizations.dart';

export 'src/localization/shared_auth_l10n.dart';

export 'src/domain/entities/user_role.dart';
export 'src/domain/entities/auth_result.dart';
export 'src/domain/entities/role_config.dart';
export 'src/domain/repositories/auth_repository.dart';
export 'src/domain/usecases/authenticate.dart';
export 'src/domain/usecases/get_role_configs.dart';

export 'src/data/datasources/auth_datasource.dart';
export 'src/data/datasources/auth_remote_datasource.dart';
export 'src/data/repositories/auth_repository_impl.dart';

export 'src/network/auth_interceptor.dart';
export 'src/network/dio_client_provider.dart';

export 'src/presentation/providers/auth_state.dart';
export 'src/presentation/providers/auth_providers.dart';
export 'src/presentation/providers/login_provider.dart';
export 'src/presentation/pages/login_view.dart';
export 'src/presentation/pages/forgot_password_view.dart';
export 'src/presentation/widgets/auth_button.dart';
export 'src/presentation/widgets/auth_field.dart';
export 'src/presentation/widgets/auth_guard.dart';
export 'src/presentation/widgets/auth_error_mapper.dart';
export 'src/presentation/widgets/auth_notice.dart';
export 'src/presentation/widgets/auth_password_strength.dart';
export 'src/presentation/widgets/phone_country.dart';
export 'src/presentation/widgets/security_badge.dart';
export 'src/presentation/widgets/auth_loading_view.dart';
export 'src/presentation/widgets/auth_surface.dart';
export 'src/presentation/widgets/authenticated_push_notification_scope.dart';
