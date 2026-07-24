class ConflictException implements Exception {
  final String message;
  ConflictException([this.message = 'Conflict detected during sync']);
}

class SyncQueueFullException implements Exception {
  final String message;
  SyncQueueFullException([this.message = 'Sync queue is full']);
}
