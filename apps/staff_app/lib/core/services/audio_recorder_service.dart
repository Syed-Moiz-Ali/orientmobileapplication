import 'package:flutter/services.dart';

class AudioRecorderService {
  static const _channel = MethodChannel('com.orient.staff_app/audio');

  Future<bool> hasPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> startRecording(String path) async {
    try {
      final result = await _channel.invokeMethod<bool>('startRecording', {
        'path': path,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final result = await _channel.invokeMethod<String>('stopRecording');
      return result;
    } catch (_) {
      return null;
    }
  }
}
