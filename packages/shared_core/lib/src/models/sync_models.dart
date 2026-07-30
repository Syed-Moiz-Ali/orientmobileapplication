class SyncResponse {
  final String id;
  final String synced;
  const SyncResponse({this.id = '', this.synced = 'false'});
  factory SyncResponse.fromJson(Map<String, dynamic> j) => SyncResponse(
    id: (j['id'] ?? '').toString(), synced: j['synced'] as String? ?? 'false');
}

class MediaUploadResponse {
  final String url;
  const MediaUploadResponse({this.url = ''});
  factory MediaUploadResponse.fromJson(Map<String, dynamic> j) => MediaUploadResponse(
    url: j['url'] as String? ?? '');
}
