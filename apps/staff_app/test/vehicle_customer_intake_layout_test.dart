import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_customer_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/vehicle_customer_provider.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// The express intake wizard must lay out cleanly across device widths in
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
          expect(find.text(t.advisorIntakeWizardContactTitle), findsWidgets);
          // In Arabic the deck header and the card title share one
          // translation, so the count differs by locale.
          expect(find.text(t.advisorIntakeSectionCustomer), findsWidgets);
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

  testWidgets('wizard gates each deck with localized errors', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final t = await StaffLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Empty contact deck: advancing is blocked with field errors.
    await tester.tap(find.text(t.advisorIntakeWizardNext));
    await tester.pumpAndSettle();
    expect(find.text(t.advisorIntakeErrCustomerName), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Let the blocked snackbar dismiss (and flush its exit animation) so
    // it never covers the action bar.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Valid contact advances to the vehicle deck.
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), 'Layla Haddad');
    await tester.enterText(fields.at(2), '501234567');
    await tester.pump();
    await tester.tap(find.text(t.advisorIntakeWizardNext));
    await tester.pumpAndSettle();
    expect(find.text(t.advisorIntakeSectionVehicle), findsWidgets);

    // Empty vehicle deck: plate/brand/model errors surface inline.
    await tester.tap(find.text(t.advisorIntakeWizardNext));
    await tester.pumpAndSettle();
    expect(find.text(t.advisorIntakeErrPlate), findsOneWidget);
    expect(find.text(t.advisorIntakeErrMake), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed decks reach capture, sign-off and create', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final t = await StaffLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(VehicleCustomerView)),
    );
    container
        .read(vehicleCustomerFormProvider.notifier)
        .setCustomerName('Layla Haddad');
    container.read(vehicleCustomerFormProvider.notifier).setPhone('501234567');
    container
        .read(vehicleCustomerFormProvider.notifier)
        .setPlateNumber('12345');
    container.read(vehicleCustomerFormProvider.notifier).setMake('Nissan');
    container.read(vehicleCustomerFormProvider.notifier).setModel('Patrol');
    await tester.pump();

    await tester.tap(find.text(t.advisorIntakeWizardNext));
    await tester.pumpAndSettle();
    expect(find.text(t.advisorIntakeSectionVehicle), findsWidgets);

    await tester.tap(find.text(t.advisorIntakeWizardNext));
    await tester.pumpAndSettle();
    expect(find.text(t.advisorIntakeSectionMedia), findsOneWidget);
    expect(
      find.text(t.advisorIntakeAddLabel(t.advisorIntakePhotos)),
      findsOneWidget,
    );

    await tester.tap(find.text(t.advisorIntakeWizardNext));
    await tester.pumpAndSettle();
    expect(find.text(t.advisorIntakeSectionJob), findsWidgets);
    expect(find.text(t.advisorIntakeAddDescription), findsOneWidget);
    expect(find.text(t.advisorIntakeActionCreate), findsOneWidget);
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
