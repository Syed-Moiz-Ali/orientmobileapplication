import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01 (H3) — real-context layout smoke test.
///
/// Pumps the real `LoginView` at default and 1.3x text scale on compact and
/// desktop widths after the global text-scale lock removal. Asserts: builds
/// without exceptions, no RenderFlex overflow, and token typography resolves
/// through the shared theme. Locales: EN only this phase (AR-RTL is a Phase 02
/// gate).
void main() {
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

  for (final scale in <double>[1.0, 1.3]) {
    testWidgets('LoginView lays out at ${scale}x on a compact phone', (
      tester,
    ) async {
      await _pumpLogin(tester, size: const Size(390, 844), scale: scale);

      expect(tester.takeException(), isNull);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Continue'), findsWidgets);

      // Token typography resolves through the shared theme.
      final context = tester.element(find.byType(LoginView));
      expect(
        Theme.of(context).textTheme.bodyMedium?.fontFamily,
        AppFontFamilies.app,
      );
    });

    testWidgets('LoginView lays out at ${scale}x on desktop', (tester) async {
      await _pumpLogin(tester, size: const Size(1440, 900), scale: scale);

      expect(tester.takeException(), isNull);
      expect(find.text('Welcome back'), findsOneWidget);
    });
  }

  testWidgets('LoginView survives 320 px at 1.3x without overflow', (
    tester,
  ) async {
    await _pumpLogin(tester, size: const Size(320, 640), scale: 1.3);

    expect(tester.takeException(), isNull);
    expect(find.text('Continue'), findsWidgets);
  });

  testWidgets('CTA label follows the AA on-primary ink in both themes', (
    tester,
  ) async {
    // Phase 01.1 accessibility amendment: the shared auth primary button must
    // follow the same on-primary ink as the rest of the design system.
    await _pumpLogin(tester, size: const Size(390, 844), scale: 1.0);
    expect(_ctaLabelColor(tester), AppColors.textInverse);

    await _pumpLogin(
      tester,
      size: const Size(390, 844),
      scale: 1.0,
      dark: true,
    );
    expect(_ctaLabelColor(tester), AppDarkColors.onPrimary);
  });
}

Color _ctaLabelColor(WidgetTester tester) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text('Continue'));
  return paragraph.text.style!.color!;
}

Future<void> _pumpLogin(
  WidgetTester tester, {
  required Size size,
  required double scale,
  bool dark = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark
            ? AppTheme.dark(BrandConfig.orient)
            : AppTheme.light(BrandConfig.orient),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
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
}
