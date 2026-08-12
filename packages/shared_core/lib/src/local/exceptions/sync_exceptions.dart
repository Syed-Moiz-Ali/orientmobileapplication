class ConflictException implements Exception {
  final String message;
  ConflictException([this.message = 'Conflict detected during sync']);
}

class SyncQueueFullException implements Exception {
  final String message;
  SyncQueueFullException([this.message = 'Sync queue is full']);
}

class MissingSyncHandlerException implements Exception {
  final String entityType;
  final String message;

  MissingSyncHandlerException(this.entityType)
      : message = 'No SyncHandler registered for entity type: $entityType';

  @override
  String toString() => message;
}
