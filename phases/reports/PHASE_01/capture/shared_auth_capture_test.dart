import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// TEMPORARY Phase 01 evidence capture harness (auth).
/// Run from `packages/shared_auth`; PNGs land in
/// `phases/reports/PHASE_01/screens/`.
void main() {
  setUpAll(_loadFonts);
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (_) async => null,
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          null,
        );
  });

  final cases = <String, _Case>{
    'login_390_light': _Case(const Size(390, 844), 1.0),
    'login_1440_light': _Case(const Size(1440, 900), 1.0),
    'login_320_light': _Case(const Size(320, 640), 1.0),
    'login_390_scale13': _Case(const Size(390, 844), 1.3),
    'login_390_dark': _Case(const Size(390, 844), 1.0, dark: true),
  };

  cases.forEach((name, c) {
    testWidgets('capture $name', (tester) async {
      tester.view.physicalSize = c.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: c.dark
                ? AppTheme.dark(BrandConfig.orient)
                : AppTheme.light(BrandConfig.orient),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(c.scale)),
              child: child!,
            ),
            home: LoginView(
              onLoginSuccess: () {},
              onForgotPassword: () {},
              allowRegistration: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LoginView),
        matchesGoldenFile(
          '../../../phases/reports/PHASE_01/screens/$name.png',
        ),
      );
    });
  });
}

class _Case {
  final Size size;
  final double scale;
  final bool dark;
  const _Case(this.size, this.scale, {this.dark = false});
}

Future<void> _loadFonts() async {
  final appFont = File(
    '..${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets'
    '${Platform.pathSeparator}fonts${Platform.pathSeparator}plus_jakarta_sans'
    '${Platform.pathSeparator}PlusJakartaSans-Variable.ttf',
  );
  final appBytes = await appFont.readAsBytes();
  await (FontLoader(
    AppFontFamilies.app,
  )..addFont(Future.value(ByteData.sublistView(appBytes)))).load();

  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts'
    '${Platform.pathSeparator}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
}
