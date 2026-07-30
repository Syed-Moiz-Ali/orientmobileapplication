import 'package:dio/dio.dart';
import 'package:shared_core/src/constants/api_constants.dart';
import 'package:shared_core/src/models/sync_models.dart';

class MediaClient {
  final Dio _dio;
  MediaClient(this._dio);

  Future<MediaUploadResponse> uploadMedia(
    String recordId, String filePath, {String itemId = '', String type = 'photo'}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
        'itemId': itemId,
        'type': type,
      });
      final response = await _dio.post(
        ApiEndpoints.uploadMedia(recordId),
        data: formData,
      );
      final data = response.data as Map<String, dynamic>?;
      return MediaUploadResponse(url: data?['url'] as String? ?? '');
    } catch (e) {
      return const MediaUploadResponse();
    }
  }
}
