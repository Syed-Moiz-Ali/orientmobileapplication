import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:crm_app/features/crm_dashboard/data/datasources/crm_remote_datasource.dart';

final crmRemoteDataSourceProvider = Provider<CrmRemoteDataSource>((ref) {
  return CrmRemoteDataSource(ref.read(apiClientProvider));
});
