import 'package:shared_core/src/local/sync/sync_operation.dart';

abstract class SyncHandler {
  String get entityType;
  Future<bool> execute(SyncOperation operation);
}
