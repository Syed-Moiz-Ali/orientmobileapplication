import 'package:orientmobileapplication/core/local/sync/sync_operation.dart';

abstract class SyncHandler {
  String get entityType;
  Future<bool> execute(SyncOperation operation);
}
