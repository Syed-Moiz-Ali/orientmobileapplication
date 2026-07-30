import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';

final advisorRemoteDataSourceProvider = Provider<AdvisorRemoteDataSource>((ref) {
  return AdvisorRemoteDataSource(ref.read(apiClientProvider));
});
