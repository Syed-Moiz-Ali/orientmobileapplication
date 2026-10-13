import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

const _delegates = [
  SharedAuthLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _host({required Widget home, Locale locale = const Locale('ar')}) {
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: _delegates,
      theme: AppTheme.light(BrandConfig.orient),
      home: home,
    ),
  );
}

void main() {
  testWidgets('LoginView renders Arabic copy and mirrors in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        home: LoginView(
          onLoginSuccess: () {},
          onForgotPassword: () {},
          allowRegistration: true,
          appName: 'تطبيق أورينت — الموظفون',
          appPurpose: 'تأكيد الحجوزات واستلام المركبات.',
          intendedUsers: 'للمستشارين والفنيين والمشرفين',
        ),
      ),
    );

    expect(find.text('مرحباً بعودتك'), findsOneWidget);
    expect(find.text('البريد الإلكتروني أو رقم الجوال'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
    expect(find.text('عميل جديد؟ أنشئ حساباً'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(LoginView))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('LoginView registration copy localizes', (tester) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(home: LoginView(onLoginSuccess: () {}, allowRegistration: true)),
    );
    await tester.ensureVisible(find.text('عميل جديد؟ أنشئ حساباً'));
    await tester.tap(find.text('عميل جديد؟ أنشئ حساباً'));
    await tester.pumpAndSettle();

    expect(find.text('أنشئ حسابك'), findsOneWidget);
    expect(find.text('الاسم الكامل'), findsOneWidget);
    expect(find.text('إنشاء الحساب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ForgotPasswordView renders Arabic recovery copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        home: ForgotPasswordView(
          onBackToLogin: () {},
          appName: 'تطبيق أورينت — العملاء',
          appPurpose: 'احجز الخدمة وتابع مركبتك.',
          intendedUsers: 'لمالكي المركبات',
        ),
      ),
    );

    expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
    expect(find.text('إرسال رمز الاستعادة'), findsOneWidget);
    expect(find.text('تأكيد الحساب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('auth copy switches live when the locale provider flips', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(localeProvider),
            supportedLocales: AppLocales.supported,
            localizationsDelegates: _delegates,
            theme: AppTheme.light(BrandConfig.orient),
            home: const Scaffold(body: SecurityBadge()),
          ),
        ),
      ),
    );

    expect(
      find.text(
        'By signing in, you agree to the Terms of Service and Privacy Policy.',
      ),
      findsOneWidget,
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SecurityBadge)),
    );
    await container.read(localeProvider.notifier).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();

    expect(
      find.text('بتسجيل الدخول، فإنك توافق على شروط الخدمة وسياسة الخصوصية.'),
      findsOneWidget,
    );
  });
}
