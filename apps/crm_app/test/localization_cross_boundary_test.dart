import 'package:crm_app/l10n/gen/crm_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

void _noop() {}

void main() {
  testWidgets('crm app + shared_core + shared_auth render Arabic together',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            CrmLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            SharedAuthLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient),
          home: Builder(
            builder: (context) {
              final t = CrmLocalizations.of(context)!;
              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(t.loginAppName),
                      EmptyState.error(message: 'تعذّر التحميل', onRetry: _noop),
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

    expect(find.text('تطبيق أورينت — إدارة العملاء'), findsOneWidget);
    expect(find.text('حدث خطأ ما'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });
}
