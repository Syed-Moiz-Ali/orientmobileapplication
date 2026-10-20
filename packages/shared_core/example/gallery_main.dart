// Debug entry point for the design-system gallery (phase 1, 1a+).
//
// Run on a device/emulator with:
//   cd packages/shared_core && flutter run -t example/gallery_main.dart -d <device-id>
// (Find <device-id> via `flutter devices`.)
// No app code is touched: this file lives in shared_core only.
import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_core/src/gallery/design_system_gallery_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(BrandConfig.orient),
      darkTheme: AppTheme.dark(BrandConfig.orient),
      home: const DesignSystemGalleryScreen(),
    ),
  );
}
