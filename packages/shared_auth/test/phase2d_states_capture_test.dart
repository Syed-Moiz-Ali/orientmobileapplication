// Phase-2d AFTER captures: error/busy states + small + tablet
// (capture-only, no app code).
//
// States (customer light, en, 1.0, 360x800 unless noted): login password
// field error, form error with retryable offline snackbar, busy CTA;
// login code invalid-code inline error; register empty-submit field error;
// forgot identifier field error + offline snackbar; forgot reset field
// errors + expired-code inline error; plus one RTL/1.3 field-error variant
// and one dark busy variant.
// Small (320x568): login password idle for all five app/theme combos +
// customer RTL + customer 1.3. Tablet portrait (768x1024): customer login
// password idle LTR + RTL.
//
// Tagged baseline: excluded from `melos run test` (see melos.yaml).
// Generate: flutter test --tags baseline --update-goldens
//             test/phase2d_states_capture_test.dart   (from packages/shared_auth)
// Compare:  flutter test --tags baseline test/phase2d_states_capture_test.dart
@Tags(['baseline'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'phase2d_capture_helpers.dart';
import 'test_helpers.dart';

const _en = Locale('en');
const _ar = Locale('ar');

/// Valid password-identifier credentials (email path).
Future<void> _enterPasswordCreds(WidgetTester tester) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), 'user@example.com');
  await tester.enterText(fields.at(1), 'secret123');
  await tester.pump();
}

void main() {
  setUpAll(loadCaptureFonts);

  group('login password states 360x800', () {
    testWidgets('customer login password field-error light 1.0 en 360x800',
        (tester) async {
      const locale = _en;
      final t = bundleFor(locale);
      await pumpCaptureLogin(tester, app: captureCustomer);
      final cta = find.text(t.loginActionContinue);
      await reveal(tester, cta);
      await tester.tap(cta);
      await tester.pump();
      await captureAfter(
        tester,
        afterName(
          app: 'customer',
          screen: 'login_password',
          state: 'field_error',
          dark: false,
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
    });

    testWidgets('customer login password field-error light 1.3 ar 360x800',
        (tester) async {
      const locale = _ar;
      final t = bundleFor(locale);
      await pumpCaptureLogin(
        tester,
        app: captureCustomer,
        locale: locale,
        textScale: 1.3,
      );
      final cta = find.text(t.loginActionContinue);
      await reveal(tester, cta);
      await tester.tap(cta);
      await tester.pump();
      await captureAfter(
        tester,
        afterName(
          app: 'customer',
          screen: 'login_password',
          state: 'field_error',
          dark: false,
          textScale: 1.3,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
    });

    testWidgets('customer login password form-error light 1.0 en 360x800',
        (tester) async {
      const locale = _en;
      final t = bundleFor(locale);
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async => const Failure(
              NetworkException('socket failed host lookup'),
            );
      await pumpCaptureLogin(tester, app: captureCustomer, repo: repo);
      await _enterPasswordCreds(tester);
      final cta = find.text(t.loginActionContinue);
      await reveal(tester, cta);
      await tester.tap(cta);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // Let the retry snackbar finish its entrance before pixels.
      await tester.pump(const Duration(milliseconds: 500));
      await captureAfter(
        tester,
        afterName(
          app: 'customer',
          screen: 'login_password',
          state: 'form_error',
          dark: false,
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
    });

    testWidgets('customer login password busy light 1.0 en 360x800',
        (tester) async {
      const locale = _en;
      final t = bundleFor(locale);
      final gate = Completer<Result<AuthResult>>();
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) => gate.future;
      await pumpCaptureLogin(tester, app: captureCustomer, repo: repo);
      await _enterPasswordCreds(tester);
      final cta = find.text(t.loginActionContinue);
      await reveal(tester, cta);
      await tester.tap(cta);
      await tester.pump();
      await captureAfter(
        tester,
        afterName(
          app: 'customer',
          screen: 'login_password',
          state: 'busy',
          dark: false,
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
      gate.complete(
        const Success(AuthResult(role: UserRole.customer, token: 'tok')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('customer login password busy dark 1.0 en 360x800',
        (tester) async {
      const locale = _en;
      final t = bundleFor(locale);
      final gate = Completer<Result<AuthResult>>();
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) => gate.future;
      await pumpCaptureLogin(
        tester,
        app: captureCustomer,
        dark: true,
        repo: repo,
      );
      await _enterPasswordCreds(tester);
      final cta = find.text(t.loginActionContinue);
      await reveal(tester, cta);
      await tester.tap(cta);
      await tester.pump();
      await captureAfter(
        tester,
        afterName(
          app: 'customer',
          screen: 'login_password',
          state: 'busy',
          dark: true,
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
      gate.complete(
        const Success(AuthResult(role: UserRole.customer, token: 'tok')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  group('login code + register states 360x800', () {
    testWidgets('customer login code invalid-code light 1.0 en 360x800',
        (tester) async {
      const locale = _en;
      final t = bundleFor(locale);
      final repo = FakeAuthRepository()
        ..verifyOtpHandler = (_, __) async =>
            const Failure(ValidationException('that otp is invalid'));
      final container = await pumpCaptureLogin(
        tester,
        app: captureCustomer,
        repo: repo,
      );
      await switchToCodeMode(tester, locale);
      await sendLoginCode(tester, locale);
      container.read(loginProvider.notifier).setOtp('123456');
      await tester.pump();
      final cta = find.text(t.loginActionVerifyCode);
      await reveal(tester, cta);
      await tester.tap(cta);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.text(t.errorOtpInvalid));
      await tester.pump();
      await captureAfter(
        tester,
        afterName(
          app: 'customer',
          screen: 'login_code_postsend',
          state: 'code_error',
          dark: false,
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
    });

    testWidgets('customer register field-error light 1.0 en 360x800',
        (tester) async {
      const locale = _en;
      final t = bundleFor(locale);
      await pumpCaptureLogin(tester, app: captureCustomer);
      await openRegisterMode(tester, locale);
      final cta = find.text(t.loginActionCreateAccount);
      await reveal(tester, cta);
      await tester.tap(cta);
      await tester.pump();
      await captureAfter(
        tester,
        afterName(
          app: 'customer',
          screen: 'login_register',
          state: 'field_error',
          dark: false,
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
    });
  });

  group('forgot states 360x800', () {
    testWidgets('customer forgot identifier field-error light 1.0 en 360x800',
        (tester) async {
      const locale = _en;
      final t = bundleFor(locale);
      await pumpCaptureForgot(tester, app: captureCustomer);
      final cta = find.text(t.forgotActionSendRecoveryCode);
      await reveal(tester, cta);
      await tester.tap(cta);
      await tester.pump();
      await captureAfter(
        tester,
        afterName(
          app: 'customer',
          screen: 'forgot_identifier',
          state: 'field_error',
          dark: false,
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
    });

    testWidgets('customer forgot identifier form-error light 1.0 en 360x800',
        (tester) async {
      const locale = _en;
      final t = bundleFor(locale);
      final repo = FakeAuthRepository()
        ..forgotHandler = (_, __, ___) async => const Failure(
              NetworkException('socket failed host lookup'),
            );
      await pumpCaptureForgot(tester, app: captureCustomer, repo: repo);
      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      final cta = find.text(t.forgotActionSendRecoveryCode);
      await reveal(tester, cta);
      await tester.tap(cta);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // Let the retry snackbar finish its entrance before pixels.
      await tester.pump(const Duration(milliseconds: 500));
      await captureAfter(
        tester,
        afterName(
          app: 'customer',
          screen: 'forgot_identifier',
          state: 'form_error',
          dark: false,
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
    });

    testWidgets('customer forgot reset field-errors light 1.0 en 360x800',
        (tester) async {
      const locale = _en;
      final t = bundleFor(locale);
      await pumpCaptureForgot(tester, app: captureCustomer);
      await reachForgotReset(tester, locale);
      final cta = find.text(t.forgotActionUpdatePassword);
      await reveal(tester, cta);
      await tester.tap(cta);
      await tester.pump();
      await tester.ensureVisible(find.text(t.forgotActionUpdatePassword));
      await tester.pump();
      await captureAfter(
        tester,
        afterName(
          app: 'customer',
          screen: 'forgot_reset',
          state: 'field_error',
          dark: false,
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
      await drainForgotCooldown(tester);
    });

    testWidgets('customer forgot reset expired-code light 1.0 en 360x800',
        (tester) async {
      const locale = _en;
      final t = bundleFor(locale);
      final repo = FakeAuthRepository()
        ..resetHandler = (_, __, ___, ____, _____) async =>
            const Failure(ValidationException('recovery code expired'));
      await pumpCaptureForgot(tester, app: captureCustomer, repo: repo);
      await reachForgotReset(tester, locale);
      await tester.enterText(find.byType(EditableText).first, '123456');
      await tester.enterText(find.byType(TextField).first, 'newpass123');
      await tester.pump();
      final cta = find.text(t.forgotActionUpdatePassword);
      await reveal(tester, cta);
      await tester.tap(cta);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.text(t.errorOtpExpired));
      await tester.pump();
      await captureAfter(
        tester,
        afterName(
          app: 'customer',
          screen: 'forgot_reset',
          state: 'code_error',
          dark: false,
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
      await drainForgotCooldown(tester);
    });
  });

  group('small 320x568 login password idle', () {
    for (final entry in [
      (app: captureCustomer, dark: false, locale: _en, scale: 1.0),
      (app: captureStaff, dark: false, locale: _en, scale: 1.0),
      (app: captureOwner, dark: false, locale: _en, scale: 1.0),
      (app: captureCrm, dark: false, locale: _en, scale: 1.0),
      (app: captureCustomer, dark: true, locale: _en, scale: 1.0),
      (app: captureCustomer, dark: false, locale: _ar, scale: 1.0),
      (app: captureCustomer, dark: false, locale: _en, scale: 1.3),
    ]) {
      testWidgets(
        '${entry.app.id} login password idle ${entry.dark ? 'dark' : 'light'} ${entry.scale} ${entry.locale.languageCode} 320x568',
        (tester) async {
          await pumpCaptureLogin(
            tester,
            app: entry.app,
            dark: entry.dark,
            locale: entry.locale,
            textScale: entry.scale,
            physical: smallSize,
            dpr: smallDpr,
          );
          await captureAfter(
            tester,
            afterName(
              app: entry.app.id,
              screen: 'login_password',
              state: 'idle',
              dark: entry.dark,
              textScale: entry.scale,
              locale: entry.locale,
              w: 320,
              h: 568,
            ),
          );
        },
      );
    }
  });

  group('tablet portrait 768x1024 login password idle', () {
    for (final locale in [_en, _ar]) {
      testWidgets(
        'customer login password idle light 1.0 ${locale.languageCode} 768x1024',
        (tester) async {
          await pumpCaptureLogin(
            tester,
            app: captureCustomer,
            locale: locale,
            physical: tabletSize,
            dpr: tabletDpr,
          );
          await captureAfter(
            tester,
            afterName(
              app: 'customer',
              screen: 'login_password',
              state: 'idle',
              dark: false,
              textScale: 1.0,
              locale: locale,
              w: 768,
              h: 1024,
            ),
          );
        },
      );
    }
  });
}
