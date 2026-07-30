import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:staff_app/features/technician/data/datasources/technician_remote_datasource.dart';

final technicianRemoteDataSourceProvider = Provider<TechnicianRemoteDataSource>((ref) {
  return TechnicianRemoteDataSource(ref.read(apiClientProvider));
});
