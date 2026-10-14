import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

Widget _host({
  required Widget child,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        SharedAuthLocalizations.delegate,
        SharedCoreLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(BrandConfig.orient, locale: locale),
      home: Scaffold(body: child),
    ),
  );
}

/// Phase 01.2 — shared_auth hardening: RoleConfig token migration, AuthGuard,
/// session-expired notice (EN/AR) and the password-strength slot.
void main() {
  group('RoleConfig hex migration', () {
    test('no bespoke Color(0x…) literals remain in role_config.dart', () {
      final raw =
          File('lib/src/domain/entities/role_config.dart').readAsStringSync();
      // Strip doc/block comments so prose never trips the literal scan.
      final code = raw
          .split('\n')
          .where((line) => !line.trimLeft().startsWith('///'))
          .join('\n')
          .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
      expect(
        code.contains('Color(0x'),
        isFalse,
        reason: 'RoleConfig must use AppColors authorities, not raw hex',
      );
    });

    test('every role button stays on the single #215FE6 primary', () {
      for (final config in RoleConfig.configs) {
        expect(
          config.buttonColor,
          AppColors.primary,
          reason: '${config.role} button must be the locked primary',
        );
      }
    });

    test('every role icon mark uses a frozen token', () {
      final allowed = [
        AppColors.primary,
        AppColors.surfaceStrong,
        AppColors.success,
        AppColors.purpleAccent,
        AppColors.info,
      ];
      for (final config in RoleConfig.configs) {
        expect(
          allowed.contains(config.iconBackgroundColor),
          isTrue,
          reason: '${config.role} icon mark is not a frozen token',
        );
      }
    });

    test('all six roles are configured', () {
      expect(RoleConfig.configs.length, UserRole.values.length);
    });
  });

  group('AuthGuard', () {
    testWidgets('loading state renders the loading view', (tester) async {
      await tester.pumpWidget(_host(child: const AuthGuard(
        child: Text('SECRET'),
      )));
      // AuthNotifier boots to AuthLoading before restoring the session.
      expect(find.byType(AuthLoadingView), findsOneWidget);
      expect(find.text('SECRET'), findsNothing);
    });

    testWidgets('unauthenticated renders the expired notice', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Force the session to unauthenticated.
      container.read(authNotifierProvider.notifier).state =
          const AuthUnauthenticated();
      await tester.pumpWidget(
        _host(
          overrides: [
            authNotifierProvider.overrideWith(
              () => _StaticAuth(const AuthUnauthenticated()),
            ),
          ],
          child: const AuthGuard(child: Text('SECRET')),
        ),
      );
      await tester.pump();
      expect(find.text('SECRET'), findsNothing);
      expect(
        find.text('Your session has expired. Sign in again to continue.'),
        findsOneWidget,
      );
    });

    testWidgets('authenticated role passes; denied role fails closed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          overrides: [
            authNotifierProvider.overrideWith(
              () => _StaticAuth(
                const AuthAuthenticated(
                  role: UserRole.technician,
                  token: 't',
                ),
              ),
            ),
          ],
          child: const AuthGuard(
            allowedRoles: [UserRole.technician],
            child: Text('TECH-SECRET'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('TECH-SECRET'), findsOneWidget);

      await tester.pumpWidget(
        _host(
          overrides: [
            authNotifierProvider.overrideWith(
              () => _StaticAuth(
                const AuthAuthenticated(
                  role: UserRole.technician,
                  token: 't',
                ),
              ),
            ),
          ],
          child: const AuthGuard(
            allowedRoles: [UserRole.owner],
            child: Text('OWNER-SECRET'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('OWNER-SECRET'), findsNothing);
    });

    testWidgets('session-expired Arabic copy', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          overrides: [
            authNotifierProvider.overrideWith(
              () => _StaticAuth(const AuthUnauthenticated()),
            ),
          ],
          child: const AuthGuard(child: Text('SECRET')),
        ),
      );
      await tester.pump();
      expect(
        find.text('انتهت جلستك. سجّل الدخول مجدداً للمتابعة.'),
        findsOneWidget,
      );
    });

    testWidgets('expanded expired view shows title + action', (tester) async {
      var signedIn = false;
      await tester.pumpWidget(
        _host(
          child: AuthSessionExpiredView(
            onSignIn: () => signedIn = true,
          ),
        ),
      );
      expect(find.text('Session expired'), findsOneWidget);
      await tester.tap(find.text('Sign in again'));
      expect(signedIn, isTrue);
    });
  });

  group('Password strength slot', () {
    test('scoring climbs with complexity', () {
      expect(passwordStrengthScore(''), 0);
      expect(passwordStrengthScore('abc'), 0);
      expect(passwordStrengthScore('abcdef'), 1);
      expect(passwordStrengthScore('Abcdef1'), lessThanOrEqualTo(3));
      expect(passwordStrengthScore('Abcdef12!'), 4);
      expect(passwordStrengthScore('Aa1!Aa1!Aa1!'), 4);
    });

    testWidgets('meter renders localized level + slot in the field', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(
          child: AuthTextField(
            controller: controller,
            label: 'Password',
            hint: 'Enter',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            belowField: const AuthPasswordStrength(password: 'Abcdef12!'),
          ),
        ),
      );
      expect(find.text('Strong'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('weak Arabic meter', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: const AuthPasswordStrength(password: 'abc'),
        ),
      );
      expect(find.text('ضعيفة'), findsOneWidget);
    });
  });
}

class _StaticAuth extends AuthNotifier {
  final AuthState fixed;
  _StaticAuth(this.fixed);

  @override
  AuthState build() => fixed;
}
