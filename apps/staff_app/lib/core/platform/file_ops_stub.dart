import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

bool localFileExists(String path) => false;

Future<void> deleteLocalFile(String path) async {}

Future<String> persistMediaFile(String source, String dest) async => source;

Future<String> saveSignatureFile(Uint8List bytes, String name) async => '';

Widget localImage(String path, {BoxFit fit = BoxFit.cover}) {
  return const SizedBox.shrink();
}

VideoPlayerController createVideoController(String path) =>
    throw UnsupportedError('Video playback is not supported on web');
