import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_customer_view.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// The redesigned intake screen must lay out cleanly across device widths in
/// both locales with no RenderFlex overflow or clipped controls.
void main() {
  const widths = <String, Size>{
    '320': Size(320, 640),
    '360': Size(360, 780),
    '390': Size(390, 844),
    '430': Size(430, 932),
    '768': Size(768, 1024),
    '1280': Size(1280, 800),
  };

  for (final locale in <Locale>[const Locale('en'), const Locale('ar')]) {
    final tag = locale.languageCode;
    for (final entry in widths.entries) {
      testWidgets(
        'intake has no overflow at ${entry.key}px ($tag)',
        (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          final t = await StaffLocalizations.delegate.load(locale);
          await tester.pumpWidget(_harness(locale: locale));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text(t.advisorIntakeTitle), findsWidgets);
          expect(find.text(t.advisorIntakeSectionCustomer), findsOneWidget);
          expect(find.text(t.advisorIntakeSectionVehicle), findsOneWidget);
          // Required-field country prefix is visible without focusing.
          expect(find.textContaining('971'), findsWidgets);
        },
      );
    }
  }

  testWidgets('intake tolerates 1.3x text scaling without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _harness(textScaler: const TextScaler.linear(1.3)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('optional sections expand to reveal their content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final t = await StaffLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(t.advisorIntakeSectionMedia),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(t.advisorIntakeSectionMedia));
    await tester.pumpAndSettle();
    expect(find.text(t.advisorIntakeAddLabel(t.advisorIntakePhotos)), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text(t.advisorIntakeSectionJob),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(t.advisorIntakeSectionJob));
    await tester.pumpAndSettle();
    expect(find.text(t.advisorIntakeAddDescription), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing required fields surface localized errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final t = await StaffLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.advisorIntakeActionCreate));
    await tester.pumpAndSettle();

    expect(find.text(t.advisorIntakeErrCustomerName), findsOneWidget);
    expect(find.text(t.advisorIntakeErrPlate), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide layouts render the live summary panel', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final t = await StaffLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text(t.advisorIntakeSummaryTitle), findsOneWidget);
    expect(find.text(t.advisorIntakeSummaryCustomer), findsWidgets);
    expect(find.text(t.advisorIntakeSummaryVehicle), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('intake fields use the global app font', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final themed = Theme.of(tester.element(find.byType(VehicleCustomerView)));
    expect(themed.textTheme.bodyMedium?.fontFamily, AppFontFamilies.app);
    expect(themed.textTheme.bodyLarge?.fontFamily, AppFontFamilies.app);
  });
}

Widget _harness({
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
}) => ProviderScope(
  overrides: [
    advisorRemoteDataSourceProvider.overrideWithValue(_FakeAdvisorRemote()),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    supportedLocales: AppLocales.supported,
    localizationsDelegates: const [
      StaffLocalizations.delegate,
      SharedCoreLocalizations.delegate,
      SharedAuthLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.light(BrandConfig.orient, locale: locale),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: const VehicleCustomerView(),
  ),
);

class _FakeAdvisorRemote implements AdvisorRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
