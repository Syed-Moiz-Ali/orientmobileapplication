import 'package:dio/dio.dart';
import 'package:shared_core/src/constants/api_constants.dart';
import 'package:shared_core/src/models/sync_models.dart';

class MediaUploadException implements Exception {
  final String message;
  final Object? cause;
  const MediaUploadException(this.message, {this.cause});
  @override
  String toString() => 'MediaUploadException: $message';
}

class MediaClient {
  final Dio _dio;
  MediaClient(this._dio);

  /// Uploads a local media file. Throws [MediaUploadException] on failure so
  /// callers can decide to queue the upload for later retry.
  Future<MediaUploadResponse> uploadMedia(
    String recordId, String filePath, {String itemId = '', String type = 'photo'}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filePath.split(RegExp(r'[/\\]')).last),
      'itemId': itemId,
      'type': type,
    });
    try {
      final response = await _dio.post(
        ApiEndpoints.mediaUploadFor(recordId),
        data: formData,
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['url'] is String) {
        return MediaUploadResponse(url: data['url'] as String);
      }
      if (data is Map && data.containsKey('data')) {
        final inner = data['data'];
        if (inner is Map && inner['url'] is String) {
          return MediaUploadResponse(url: inner['url'] as String);
        }
      }
      return const MediaUploadResponse();
    } on DioException catch (e) {
      throw MediaUploadException(
        'Upload failed for $filePath: ${e.message}',
        cause: e,
      );
    }
  }
}
