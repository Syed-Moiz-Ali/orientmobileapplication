// Phase-2d AFTER captures: forgot-password + splash idle matrix
// (capture-only, no app code).
//
// Covers every recovery idle screen x (customer light+dark, staff/owner/CRM
// light) x (LTR en, RTL ar) x (text scale 1.0, 1.3) on phone 360x800:
// Covers every recovery idle screen x (customer light+dark, staff/owner/CRM
// light) x (LTR en, RTL ar) x (text scale 1.0, 1.3) on phone 360x800:
// identifier stage, reset stage post-send (in-flow code-sent banner + 30s
// resend cooldown), done stage (warm success + single CTA), plus the branded
// navy splash (light/dark x en/ar x 1.0/1.3).
//
// Every test that reaches the reset stage drains the 30s resend loop AFTER
// the golden (cleanup only — same as the 2b suite). The done transition only
// retires the loop's generation; the in-flight tick must still elapse.
//
// Tagged baseline: excluded from `melos run test` (see melos.yaml).
// Generate: flutter test --tags baseline --update-goldens
//             test/phase2d_recovery_capture_test.dart   (from packages/shared_auth)
// Compare:  flutter test --tags baseline test/phase2d_recovery_capture_test.dart
@Tags(['baseline'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phase2d_capture_helpers.dart';
import 'test_helpers.dart';

const _en = Locale('en');
const _ar = Locale('ar');

void main() {
  setUpAll(loadCaptureFonts);

  group('forgot identifier idle 360x800', () {
    for (final app in [captureCustomer, captureStaff, captureOwner, captureCrm]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            '${app.id} forgot identifier idle light $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureForgot(
                tester,
                app: app,
                locale: locale,
                textScale: scale,
              );
              await captureAfter(
                tester,
                afterName(
                  app: app.id,
                  screen: 'forgot_identifier',
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
          'customer forgot identifier idle dark $scale ${locale.languageCode} 360x800',
          (tester) async {
            await pumpCaptureForgot(
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
                screen: 'forgot_identifier',
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

  group('forgot reset post-send (code sent + cooldown) 360x800', () {
    for (final dark in [false, true]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            'customer forgot reset otp-sent ${dark ? 'dark' : 'light'} $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureForgot(
                tester,
                app: captureCustomer,
                dark: dark,
                locale: locale,
                textScale: scale,
              );
              await reachForgotReset(tester, locale);
              await captureAfter(
                tester,
                afterName(
                  app: 'customer',
                  screen: 'forgot_reset',
                  state: 'otp_sent',
                  dark: dark,
                  textScale: scale,
                  locale: locale,
                  w: 360,
                  h: 800,
                ),
              );
              await drainForgotCooldown(tester);
            },
          );
        }
      }
    }
    for (final app in [captureStaff, captureOwner, captureCrm]) {
      for (final locale in [_en, _ar]) {
        testWidgets(
          '${app.id} forgot reset otp-sent light 1.0 ${locale.languageCode} 360x800',
          (tester) async {
            await pumpCaptureForgot(tester, app: app, locale: locale);
            await reachForgotReset(tester, locale);
            await captureAfter(
              tester,
              afterName(
                app: app.id,
                screen: 'forgot_reset',
                state: 'otp_sent',
                dark: false,
                textScale: 1.0,
                locale: locale,
                w: 360,
                h: 800,
              ),
            );
            await drainForgotCooldown(tester);
          },
        );
      }
    }
  });

  group('forgot done success 360x800', () {
    for (final dark in [false, true]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            'customer forgot done success ${dark ? 'dark' : 'light'} $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureForgot(
                tester,
                app: captureCustomer,
                dark: dark,
                locale: locale,
                textScale: scale,
              );
              await reachForgotDone(tester, locale);
              await captureAfter(
                tester,
                afterName(
                  app: 'customer',
                  screen: 'forgot_done',
                  state: 'success',
                  dark: dark,
                  textScale: scale,
                  locale: locale,
                  w: 360,
                  h: 800,
                ),
              );
              // The send-step cooldown tick is still in flight (the done
              // transition only retires its generation); drain it so no fake
              // timer is pending at teardown — cleanup only, after the
              // golden. Same as the 2b suite.
              await drainForgotCooldown(tester);
            },
          );
        }
      }
    }
    for (final app in [captureStaff, captureOwner, captureCrm]) {
      for (final locale in [_en, _ar]) {
        testWidgets(
          '${app.id} forgot done success light 1.0 ${locale.languageCode} 360x800',
          (tester) async {
            await pumpCaptureForgot(tester, app: app, locale: locale);
            await reachForgotDone(tester, locale);
            await captureAfter(
              tester,
              afterName(
                app: app.id,
                screen: 'forgot_done',
                state: 'success',
                dark: false,
                textScale: 1.0,
                locale: locale,
                w: 360,
                h: 800,
              ),
            );
            // Send-step cooldown tick still in flight; drain after the
            // golden (cleanup only, same as the 2b suite).
            await drainForgotCooldown(tester);
          },
        );
      }
    }
  });

  group('loading splash idle 360x800', () {
    for (final dark in [false, true]) {
      for (final locale in [_en, _ar]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            'splash idle ${dark ? 'dark' : 'light'} $scale ${locale.languageCode} 360x800',
            (tester) async {
              await pumpCaptureSplash(
                tester,
                dark: dark,
                locale: locale,
                textScale: scale,
              );
              await captureAfter(
                tester,
                afterName(
                  app: 'splash',
                  screen: 'loading',
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
