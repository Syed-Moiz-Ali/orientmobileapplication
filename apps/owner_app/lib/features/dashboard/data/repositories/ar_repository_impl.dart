import 'package:owner_app/features/dashboard/data/datasources/mock_ar_datasource.dart';
import 'package:owner_app/features/dashboard/domain/entities/accounts_receivable.dart';
import 'package:owner_app/features/dashboard/domain/repositories/accounts_receivable_repository.dart';

class ARRepositoryImpl implements AccountsReceivableRepository {
  final ARDatasource _datasource;

  ARRepositoryImpl(this._datasource);

  @override
  Future<ARSummary> getSummary() => _datasource.getSummary();

  @override
  Future<List<ARRecord>> getRecords() => _datasource.getRecords();
}
