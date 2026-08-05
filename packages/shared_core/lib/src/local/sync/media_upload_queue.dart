import 'package:hive/hive.dart';

/// A single pending media upload that could not be sent while offline.
class PendingMediaUpload {
  final String id;
  final String recordId;
  final String filePath;
  final String itemId;
  final String type;
  final int timestamp;

  const PendingMediaUpload({
    required this.id,
    required this.recordId,
    required this.filePath,
    this.itemId = '',
    this.type = 'photo',
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'recordId': recordId,
    'filePath': filePath,
    'itemId': itemId,
    'type': type,
    'timestamp': timestamp,
  };

  factory PendingMediaUpload.fromJson(Map<String, dynamic> json) =>
      PendingMediaUpload(
        id: json['id'] as String,
        recordId: json['recordId'] as String,
        filePath: json['filePath'] as String,
        itemId: json['itemId'] as String? ?? '',
        type: json['type'] as String? ?? 'photo',
        timestamp: json['timestamp'] as int? ?? 0,
      );
}

/// Persists media uploads that could not be delivered while offline.
/// Retried whenever connectivity returns (see [retryPending]).
class MediaUploadQueue {
  final Box _box;

  MediaUploadQueue(Box box) : _box = box;

  List<PendingMediaUpload> get pending => _box.values
      .whereType<Map>()
      .map((m) => Map<String, dynamic>.from(m))
      .map(PendingMediaUpload.fromJson)
      .toList();

  int get length => _box.length;

  bool get isEmpty => _box.isEmpty;

  Future<void> enqueue(PendingMediaUpload upload) =>
      _box.put(upload.id, upload.toJson());

  Future<void> remove(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();

  /// Tries to flush queued uploads with the given [uploader].
  /// Returns true when every queued upload was delivered.
  Future<bool> retryPending(
    Future<void> Function(PendingMediaUpload upload) uploader,
  ) async {
    final queued = List<PendingMediaUpload>.from(pending);
    var allDelivered = true;
    for (final upload in queued) {
      try {
        await uploader(upload);
        await remove(upload.id);
      } catch (_) {
        allDelivered = false;
      }
    }
    return allDelivered;
  }
}
