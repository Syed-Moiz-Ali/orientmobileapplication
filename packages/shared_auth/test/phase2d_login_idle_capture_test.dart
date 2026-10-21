// Phase-2d AFTER captures: login step idle matrix (capture-only, no app code).
//
// Covers every login step idle x (customer light+dark, staff/owner/CRM
// light) x (LTR en, RTL ar) x (text scale 1.0, 1.3) on phone 360x800:
// step 1 ("Log in or sign up"), step 2 password ("Welcome back", reached via
// Continue with ZERO API calls), step 2 code-confirm ("Confirm your number"
// post-send with the in-flow sent banner + 30s resend link), register R1/R2/R3
// (customer only — the only router with allowRegistration: true).
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

  group('login step1 idle 360x800', () {
    for (final app in [captureCustomer, captureStaff, captureOwner, captureCrm]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            '${app.id} login step1 idle light $scale ${locale.languageCode} 360x800',
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
                  screen: 'login_step1',
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
          'customer login step1 idle dark $scale ${locale.languageCode} 360x800',
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
                screen: 'login_step1',
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

  group('login step2 password idle 360x800', () {
    for (final app in [captureCustomer, captureStaff, captureOwner, captureCrm]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            '${app.id} login step2 idle light $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureLogin(
                tester,
                app: app,
                locale: locale,
                textScale: scale,
              );
              await reachStep2Password(tester, locale);
              await captureAfter(
                tester,
                afterName(
                  app: app.id,
                  screen: 'login_step2',
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
          'customer login step2 idle dark $scale ${locale.languageCode} 360x800',
          (tester) async {
            await pumpCaptureLogin(
              tester,
              app: captureCustomer,
              dark: true,
              locale: locale,
              textScale: scale,
            );
            await reachStep2Password(tester, locale);
            await captureAfter(
              tester,
              afterName(
                app: 'customer',
                screen: 'login_step2',
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

  group('login code-confirm post-send (otp sent + cooldown) 360x800', () {
    for (final dark in [false, true]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            'customer login code otp-sent ${dark ? 'dark' : 'light'} $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureLogin(
                tester,
                app: captureCustomer,
                dark: dark,
                locale: locale,
                textScale: scale,
              );
              await reachCodeStep(tester, locale);
              await captureAfter(
                tester,
                afterName(
                  app: 'customer',
                  screen: 'login_code',
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
          '${app.id} login code otp-sent light 1.0 ${locale.languageCode} 360x800',
          (tester) async {
            await pumpCaptureLogin(tester, app: app, locale: locale);
            await reachCodeStep(tester, locale);
            await captureAfter(
              tester,
              afterName(
                app: app.id,
                screen: 'login_code',
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

  group('register R1 idle 360x800 (customer only)', () {
    for (final dark in [false, true]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            'customer register R1 idle ${dark ? 'dark' : 'light'} $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureLogin(
                tester,
                app: captureCustomer,
                dark: dark,
                locale: locale,
                textScale: scale,
              );
              await openCaptureRegister(tester, locale);
              await captureAfter(
                tester,
                afterName(
                  app: 'customer',
                  screen: 'login_r1',
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

  group('register R2 idle 360x800 (customer only)', () {
    for (final dark in [false, true]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            'customer register R2 idle ${dark ? 'dark' : 'light'} $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureLogin(
                tester,
                app: captureCustomer,
                dark: dark,
                locale: locale,
                textScale: scale,
              );
              await openCaptureRegister(tester, locale);
              await continueCaptureRegisterName(tester, locale);
              await captureAfter(
                tester,
                afterName(
                  app: 'customer',
                  screen: 'login_r2',
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

  group('register R3 idle 360x800 (customer only)', () {
    for (final dark in [false, true]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            'customer register R3 idle ${dark ? 'dark' : 'light'} $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureLogin(
                tester,
                app: captureCustomer,
                dark: dark,
                locale: locale,
                textScale: scale,
              );
              await reachCaptureRegisterR3(tester, locale);
              await captureAfter(
                tester,
                afterName(
                  app: 'customer',
                  screen: 'login_r3',
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
