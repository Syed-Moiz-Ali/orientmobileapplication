import 'package:orientmobileapplication/core/local/sync/sync_handler.dart';
import 'package:orientmobileapplication/core/local/sync/sync_operation.dart';

class MockSyncHandler extends SyncHandler {
  @override
  final String entityType;

  final Duration delay;

  MockSyncHandler(this.entityType, {this.delay = const Duration(milliseconds: 500)});

  @override
  Future<bool> execute(SyncOperation operation) async {
    await Future.delayed(delay);
    return true;
  }
}
