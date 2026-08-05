import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:staff_app/features/supervisor/data/datasources/supervisor_remote_datasource.dart';

final supervisorRemoteDataSourceProvider = Provider<SupervisorRemoteDataSource>(
  (ref) {
    return SupervisorRemoteDataSource(ref.read(apiClientProvider));
  },
);
