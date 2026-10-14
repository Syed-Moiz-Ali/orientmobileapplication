import 'dart:io';
import 'package:flutter/services.dart';

bool _fontsLoaded = false;

/// Loads real Latin & Arabic fonts plus MaterialIcons into the Flutter test engine
/// so golden screenshot images render actual readable typography and icons instead
/// of Flutter's default "Ahem" wireframe square boxes.
Future<void> loadThemeFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;

  // 1. Plus Jakarta Sans (Variable)
  final jakartaPaths = [
    'assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
    '../../packages/shared_core/assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
  ];
  for (final path in jakartaPaths) {
    final file = File(path);
    if (file.existsSync()) {
      final bytes = file.readAsBytesSync();
      final fontLoader = FontLoader('packages/shared_core/Plus Jakarta Sans')
        ..addFont(Future.value(bytes.buffer.asByteData()));
      await fontLoader.load();

      final plainLoader = FontLoader('Plus Jakarta Sans')
        ..addFont(Future.value(bytes.buffer.asByteData()));
      await plainLoader.load();

      final robotoLoader = FontLoader('Roboto')
        ..addFont(Future.value(bytes.buffer.asByteData()));
      await robotoLoader.load();

      final sansLoader = FontLoader('sans-serif')
        ..addFont(Future.value(bytes.buffer.asByteData()));
      await sansLoader.load();
      break;
    }
  }

  // 2. IBM Plex Sans Arabic for Arabic RTL testing
  final arabicFiles = [
    'IBMPlexSansArabic-Regular.ttf',
    'IBMPlexSansArabic-Medium.ttf',
    'IBMPlexSansArabic-SemiBold.ttf',
    'IBMPlexSansArabic-Bold.ttf',
  ];
  final prefixPaths = [
    'assets/fonts/ibm_plex_sans_arabic/',
    '../../packages/shared_core/assets/fonts/ibm_plex_sans_arabic/',
  ];

  for (final prefix in prefixPaths) {
    if (Directory(prefix).existsSync()) {
      final arabicPackageLoader = FontLoader('packages/shared_core/IBM Plex Sans Arabic');
      final arabicPlainLoader = FontLoader('IBM Plex Sans Arabic');
      for (final filename in arabicFiles) {
        final file = File('$prefix$filename');
        if (file.existsSync()) {
          final data = file.readAsBytesSync().buffer.asByteData();
          arabicPackageLoader.addFont(Future.value(data));
          arabicPlainLoader.addFont(Future.value(data));
        }
      }
      await arabicPackageLoader.load();
      await arabicPlainLoader.load();
      break;
    }
  }

  // 3. MaterialIcons from Flutter SDK artifacts
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final iconFont = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (iconFont.existsSync()) {
      final icons = FontLoader('MaterialIcons')
        ..addFont(Future.value(iconFont.readAsBytesSync().buffer.asByteData()));
      await icons.load();
    }
  }
}
