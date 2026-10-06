import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_customer_view.dart';

/// The intake screen must lay out cleanly across device widths without any
/// RenderFlex overflow or clipped controls.
void main() {
  const widths = <String, Size>{
    'narrow phone': Size(320, 640),
    'normal phone': Size(390, 844),
    'large phone / tablet': Size(768, 1024),
  };

  widths.forEach((label, size) {
    testWidgets('Vehicle & Customer Intake has no overflow on $label', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Vehicle & Customer Job Card'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);
      expect(find.text('Customer Details'), findsOneWidget);
      expect(find.text('Vehicle Details'), findsOneWidget);
      // The country-code prefix must be visible without focusing the field.
      expect(find.textContaining('971'), findsWidgets);
    });
  });

  testWidgets('Intake tolerates 1.3x text scaling without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness(textScaler: const TextScaler.linear(1.3)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('expanded vehicle fields and priority selector are valid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('MORE').last,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('MORE').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Add document').first,
      300,
      scrollable: find.byType(Scrollable).first,
    );

    // Regression: OutlinedButton.icon owns its label flex layout; the label
    // must not contain another Expanded/Flexible ParentDataWidget.
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Normal / Low priority'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Normal / Low priority'));
    await tester.pumpAndSettle();
    expect(find.text('Medium priority'), findsOneWidget);
    expect(find.text('High priority'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('field hints and dropdown content use the global app font', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final customerNameTexts = tester.widgetList<Text>(
      find.text('Customer Name'),
    );
    expect(customerNameTexts, isNotEmpty);
    expect(
      customerNameTexts.every(
        (text) => text.style?.fontFamily == AppFontFamilies.app,
      ),
      isTrue,
    );

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>).first,
    );
    expect(dropdown.style?.fontFamily, AppFontFamilies.app);

    final themed = Theme.of(tester.element(find.byType(VehicleCustomerView)));
    expect(themed.textTheme.bodyMedium?.fontFamily, AppFontFamilies.app);
    expect(themed.popupMenuTheme.textStyle?.fontFamily, AppFontFamilies.app);
  });
}

Widget _harness({TextScaler textScaler = TextScaler.noScaling}) =>
    ProviderScope(
      overrides: [
        advisorRemoteDataSourceProvider.overrideWithValue(_FakeAdvisorRemote()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
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
