import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

bool localFileExists(String path) => path.isNotEmpty && File(path).existsSync();

Future<void> deleteLocalFile(String path) async {
  final f = File(path);
  if (f.existsSync()) {
    await f.delete();
  }
}

Future<String> persistMediaFile(String source, String dest) async {
  await File(source).copy(dest);
  return dest;
}

/// Persists raw bytes (e.g. a signature PNG) and returns the file path.
/// Returns an empty string when persistence is unavailable.
Future<String> saveSignatureFile(Uint8List bytes, String name) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

Widget localImage(String path, {BoxFit fit = BoxFit.cover}) {
  return Image.file(
    File(path),
    fit: fit,
    errorBuilder: (_, __, ___) => const Icon(
      Icons.broken_image,
      color: Color(0xFF94A3B8),
      size: 20,
    ),
  );
}

VideoPlayerController createVideoController(String path) =>
    VideoPlayerController.file(File(path));
