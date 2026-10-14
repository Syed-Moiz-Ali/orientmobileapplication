import 'dart:io';
import 'package:flutter/services.dart';

bool _fontsLoaded = false;

/// Loads real Latin & Arabic fonts plus MaterialIcons into the Flutter test engine
/// so golden screenshot images render actual readable typography and icons instead
/// of Flutter's default "Ahem" square/tofu wireframe boxes.
Future<void> loadShowcaseFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;

  // 1. Plus Jakarta Sans (Variable) from packages/shared_core
  final jakartaFile = File('../../packages/shared_core/assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf');
  if (jakartaFile.existsSync()) {
    final bytes = jakartaFile.readAsBytesSync();
    final fontLoader = FontLoader('PlusJakartaSans')
      ..addFont(Future.value(bytes.buffer.asByteData()));
    await fontLoader.load();

    // Also register as default Roboto / sans-serif alias so un-named TextStyles use it
    final robotoLoader = FontLoader('Roboto')
      ..addFont(Future.value(bytes.buffer.asByteData()));
    await robotoLoader.load();

    final sansLoader = FontLoader('sans-serif')
      ..addFont(Future.value(bytes.buffer.asByteData()));
    await sansLoader.load();
  }

  // 2. IBM Plex Sans Arabic for Arabic RTL testing
  final arabicFiles = [
    'IBMPlexSansArabic-Regular.ttf',
    'IBMPlexSansArabic-Medium.ttf',
    'IBMPlexSansArabic-SemiBold.ttf',
    'IBMPlexSansArabic-Bold.ttf',
  ];
  final arabicLoader = FontLoader('IBMPlexSansArabic');
  for (final filename in arabicFiles) {
    final file = File('../../packages/shared_core/assets/fonts/ibm_plex_sans_arabic/$filename');
    if (file.existsSync()) {
      arabicLoader.addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    }
  }
  await arabicLoader.load();

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
