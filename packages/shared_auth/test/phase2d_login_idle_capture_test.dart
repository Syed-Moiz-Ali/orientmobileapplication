// Phase-2d AFTER captures: login idle matrix (capture-only, no app code).
//
// Covers every login idle screen x (customer light+dark, staff/owner/CRM
// light) x (LTR en, RTL ar) x (text scale 1.0, 1.3) on phone 360x800:
// password mode, code mode pre-send, code mode post-send (otpSent + in-flow
// success banner + 30s resend cooldown), register mode (customer only — the only
// router with allowRegistration: true).
//
// Tagged baseline: excluded from `melos run test` (see melos.yaml).
// Generate: flutter test --tags baseline --update-goldens
//             test/phase2d_login_idle_capture_test.dart   (from packages/shared_auth)
// Compare:  flutter test --tags baseline test/phase2d_login_idle_capture_test.dart
@Tags(['baseline'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phase2d_capture_helpers.dart';

const _en = Locale('en');
const _ar = Locale('ar');

void main() {
  setUpAll(loadCaptureFonts);

  group('login password idle 360x800', () {
    for (final app in [captureCustomer, captureStaff, captureOwner, captureCrm]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            '${app.id} login password idle light $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureLogin(
                tester,
                app: app,
                locale: locale,
                textScale: scale,
              );
              await captureAfter(
                tester,
                afterName(
                  app: app.id,
                  screen: 'login_password',
                  state: 'idle',
                  dark: false,
                  textScale: scale,
                  locale: locale,
                  w: 360,
                  h: 800,
                ),
              );
            },
          );
        }
      }
    }
    for (final locale in [_en, _ar]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          'customer login password idle dark $scale ${locale.languageCode} 360x800',
          (tester) async {
            await pumpCaptureLogin(
              tester,
              app: captureCustomer,
              dark: true,
              locale: locale,
              textScale: scale,
            );
            await captureAfter(
              tester,
              afterName(
                app: 'customer',
                screen: 'login_password',
                state: 'idle',
                dark: true,
                textScale: scale,
                locale: locale,
                w: 360,
                h: 800,
              ),
            );
          },
        );
      }
    }
  });

  group('login code pre-send idle 360x800', () {
    for (final app in [captureCustomer, captureStaff, captureOwner, captureCrm]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            '${app.id} login code presend idle light $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureLogin(
                tester,
                app: app,
                locale: locale,
                textScale: scale,
              );
              await switchToCodeMode(tester, locale);
              await captureAfter(
                tester,
                afterName(
                  app: app.id,
                  screen: 'login_code_presend',
                  state: 'idle',
                  dark: false,
                  textScale: scale,
                  locale: locale,
                  w: 360,
                  h: 800,
                ),
              );
            },
          );
        }
      }
    }
    for (final locale in [_en, _ar]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          'customer login code presend idle dark $scale ${locale.languageCode} 360x800',
          (tester) async {
            await pumpCaptureLogin(
              tester,
              app: captureCustomer,
              dark: true,
              locale: locale,
              textScale: scale,
            );
            await switchToCodeMode(tester, locale);
            await captureAfter(
              tester,
              afterName(
                app: 'customer',
                screen: 'login_code_presend',
                state: 'idle',
                dark: true,
                textScale: scale,
                locale: locale,
                w: 360,
                h: 800,
              ),
            );
          },
        );
      }
    }
  });

  group('login code post-send (otp sent + cooldown) 360x800', () {
    for (final dark in [false, true]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            'customer login code postsend otp-sent ${dark ? 'dark' : 'light'} $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureLogin(
                tester,
                app: captureCustomer,
                dark: dark,
                locale: locale,
                textScale: scale,
              );
              await switchToCodeMode(tester, locale);
              await sendLoginCode(tester, locale);
              await captureAfter(
                tester,
                afterName(
                  app: 'customer',
                  screen: 'login_code_postsend',
                  state: 'otp_sent',
                  dark: dark,
                  textScale: scale,
                  locale: locale,
                  w: 360,
                  h: 800,
                ),
              );
            },
          );
        }
      }
    }
    for (final app in [captureStaff, captureOwner, captureCrm]) {
      for (final locale in [_en, _ar]) {
        testWidgets(
          '${app.id} login code postsend otp-sent light 1.0 ${locale.languageCode} 360x800',
          (tester) async {
            await pumpCaptureLogin(tester, app: app, locale: locale);
            await switchToCodeMode(tester, locale);
            await sendLoginCode(tester, locale);
            await captureAfter(
              tester,
              afterName(
                app: app.id,
                screen: 'login_code_postsend',
                state: 'otp_sent',
                dark: false,
                textScale: 1.0,
                locale: locale,
                w: 360,
                h: 800,
              ),
            );
          },
        );
      }
    }
  });

  group('register mode idle 360x800 (customer only)', () {
    for (final dark in [false, true]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            'customer register idle ${dark ? 'dark' : 'light'} $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureLogin(
                tester,
                app: captureCustomer,
                dark: dark,
                locale: locale,
                textScale: scale,
              );
              await openRegisterMode(tester, locale);
              await captureAfter(
                tester,
                afterName(
                  app: 'customer',
                  screen: 'login_register',
                  state: 'idle',
                  dark: dark,
                  textScale: scale,
                  locale: locale,
                  w: 360,
                  h: 800,
                ),
              );
            },
          );
        }
      }
    }
  });
}
