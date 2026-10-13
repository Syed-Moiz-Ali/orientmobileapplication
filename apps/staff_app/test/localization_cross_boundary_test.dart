import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

void _noop() {}

void main() {
  testWidgets('staff app + shared_core + shared_auth render Arabic together',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            StaffLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            SharedAuthLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient),
          home: Builder(
            builder: (context) {
              final t = StaffLocalizations.of(context)!;
              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // App layer copy.
                      Text(t.loginAppName),
                      // shared_core layer copy.
                      EmptyState.error(message: 'تعذّر التحميل', onRetry: _noop),
                      // shared_auth layer copy.
                      const SecurityBadge(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('تطبيق أورينت — الموظفون'), findsOneWidget);
    expect(find.text('حدث خطأ ما'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.textContaining('أورينت'), findsWidgets);
    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('staff app copy renders English by default', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            StaffLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            SharedAuthLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient),
          home: Builder(
            builder: (context) {
              final t = StaffLocalizations.of(context)!;
              return Scaffold(body: Text(t.loginAppName));
            },
          ),
        ),
      ),
    );
    expect(find.text('Orient Staff App'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.ltr,
    );
  });
}
