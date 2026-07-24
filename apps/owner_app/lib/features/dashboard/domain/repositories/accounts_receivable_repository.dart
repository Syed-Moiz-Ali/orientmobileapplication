import 'package:owner_app/features/dashboard/domain/entities/accounts_receivable.dart';

abstract interface class AccountsReceivableRepository {
  Future<ARSummary> getSummary();
  Future<List<ARRecord>> getRecords();
}
