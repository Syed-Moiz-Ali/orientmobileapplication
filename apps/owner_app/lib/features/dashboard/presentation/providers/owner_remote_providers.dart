import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_datasource.dart';

final ownerRemoteDataSourceProvider = Provider<OwnerRemoteDataSource>((ref) {
  return OwnerRemoteDataSource(ref.read(apiClientProvider));
});
