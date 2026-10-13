import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void _noop() {}

Widget _host({
  required Widget child,
  Locale locale = const Locale('en'),
  TextScaler scaler = TextScaler.noScaling,
  Size size = const Size(390, 844),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocales.supported,
    localizationsDelegates: const [
      SharedCoreLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.light(BrandConfig.orient),
    home: MediaQuery(
      data: MediaQueryData(size: size, textScaler: scaler),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AppQuantityStepper', () {
    testWidgets('increments, decrements and clamps to min/max', (tester) async {
      var value = 1.0;
      await tester.pumpWidget(
        _host(
          child: StatefulBuilder(
            builder: (context, setState) => AppQuantityStepper(
              value: value,
              max: 3,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(value, 2);

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(value, 1);

      // Clamp at max.
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(value, 3);
    });

    testWidgets('disabled controls do not change the value', (tester) async {
      var changed = false;
      await tester.pumpWidget(
        _host(
          child: AppQuantityStepper(
            value: 2,
            onChanged: (_) => changed = true,
            enabled: false,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(changed, isFalse);
    });

    testWidgets('loading state shows a spinner instead of the value', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          child: AppQuantityStepper(
            value: 2,
            onChanged: (_) {},
            isLoading: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('RTL mirrors the control order and localizes tooltips', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: AppQuantityStepper(value: 2, onChanged: (_) {}),
        ),
      );
      expect(find.byTooltip('زيادة'), findsOneWidget);
      expect(find.byTooltip('إنقاص'), findsOneWidget);

      final decrement = tester.getCenter(find.byIcon(Icons.remove_rounded));
      final increment = tester.getCenter(find.byIcon(Icons.add_rounded));
      // In RTL the decrement control sits on the reading-start (right) edge.
      expect(decrement.dx, greaterThan(increment.dx));
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at 320 px / 1.6x in Arabic', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          scaler: const TextScaler.linear(1.6),
          size: const Size(320, 720),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: AppQuantityStepper(value: 128, onChanged: (_) {}),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('showAppSelectionSheet', () {
    testWidgets('searches a long list and returns a value', (tester) async {
      final options = [
        for (var i = 0; i < 12; i++)
          AppSelectionOption<int>(value: i, label: 'Technician $i'),
      ];
      late BuildContext ctx;

      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final future = showAppSelectionSheet<int>(
        context: ctx,
        options: options,
        title: 'Select technician',
      );
      await tester.pumpAndSettle();

      // Searchable because >8 options.
      await tester.enterText(find.byType(TextField), 'Technician 11');
      await tester.pumpAndSettle();
      // The query text lives in the field; the matching row is the only list
      // entry. Assert the non-matching row is filtered out, then select.
      expect(find.text('Technician 3'), findsNothing);

      await tester.tap(find.text('Technician 11').last);
      await tester.pumpAndSettle();
      expect(await future, 11);
    });

    testWidgets('shows a localized empty-results state', (tester) async {
      final options = [
        for (var i = 0; i < 10; i++)
          AppSelectionOption<int>(value: i, label: 'Option $i'),
      ];
      late BuildContext ctx;
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      showAppSelectionSheet<int>(context: ctx, options: options);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'غير موجود');
      await tester.pumpAndSettle();
      expect(find.text('لا توجد نتائج مطابقة'), findsOneWidget);
    });

    testWidgets('uses a bounded dialog at >=600 px instead of a bottom sheet', (
      tester,
    ) async {
      final options = [
        for (var i = 0; i < 3; i++)
          AppSelectionOption<int>(value: i, label: 'Option $i'),
      ];
      late BuildContext ctx;
      await tester.pumpWidget(
        _host(
          size: const Size(800, 1000),
          child: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      showAppSelectionSheet<int>(context: ctx, options: options);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });
  });

  group('AppSelectField', () {
    testWidgets('opens the sheet and reports the selection', (tester) async {
      final options = [
        const AppSelectionOption<int>(value: 1, label: 'Petrol'),
        const AppSelectionOption<int>(value: 2, label: 'Diesel'),
        const AppSelectionOption<int>(value: 3, label: 'Hybrid'),
      ];
      var value = 1;
      await tester.pumpWidget(
        _host(
          child: StatefulBuilder(
            builder: (context, setState) => AppSelectField<int>(
              options: options,
              value: value,
              hint: 'Choose fuel',
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );

      expect(find.text('Petrol'), findsOneWidget);
      await tester.tap(find.text('Petrol'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Diesel').last);
      await tester.pumpAndSettle();
      expect(value, 2);
      expect(find.text('Diesel'), findsOneWidget);
    });
  });

  group('showAppSnackBar', () {
    testWidgets('shows the message and fires the action', (tester) async {
      var undone = false;
      late BuildContext ctx;
      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      showAppSnackBar(
        ctx,
        message: 'Job card archived',
        actionLabel: 'Undo',
        onAction: () => undone = true,
        tone: AppSnackBarTone.success,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Job card archived'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(undone, isTrue);
    });
  });

  group('PendingSyncChip', () {
    const states = [
      PendingSyncChip(state: SyncChipState.notSent),
      PendingSyncChip(state: SyncChipState.queued),
      PendingSyncChip(state: SyncChipState.failed),
      PendingSyncChip(state: SyncChipState.synced),
    ];

    testWidgets('renders EN labels per state', (tester) async {
      await tester.pumpWidget(_host(child: const Column(children: states)));
      expect(find.text('Not sent yet'), findsOneWidget);
      expect(find.text('Queued'), findsOneWidget);
      expect(find.text('Sync failed'), findsOneWidget);
      expect(find.text('Synced'), findsOneWidget);
    });

    testWidgets('renders AR labels per state', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: const Column(children: states),
        ),
      );
      expect(find.text('لم يُرسل بعد'), findsOneWidget);
      expect(find.text('في قائمة الانتظار'), findsOneWidget);
      expect(find.text('فشلت المزامنة'), findsOneWidget);
      expect(find.text('تمت المزامنة'), findsOneWidget);
    });
  });

  group('Form primitives', () {
    testWidgets('AppFormField marks optional and required fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          child: Column(
            children: const [
              AppFormField(
                label: 'Note',
                isOptional: true,
                child: SizedBox(height: 48),
              ),
              AppFormField(
                label: 'Plate',
                isRequired: true,
                child: SizedBox(height: 48),
              ),
            ],
          ),
        ),
      );
      expect(find.text('Optional'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('AppMediaUploadShell shows failed state with retry', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        _host(
          child: AppMediaUploadShell(
            onTap: _noop,
            hasError: true,
            errorLabel: 'Upload failed',
            onRetry: () => retried = true,
          ),
        ),
      );
      expect(find.text('Upload failed'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });

  group('AppActionBar', () {
    testWidgets('loading state announces and absorbs interaction', (
      tester,
    ) async {
      var pressed = false;
      await tester.pumpWidget(
        _host(
          child: AppActionBar(
            isLoading: true,
            primary: FilledButton(
              onPressed: () => pressed = true,
              child: const Text('Save'),
            ),
          ),
        ),
      );
      expect(find.text('Loading'), findsOneWidget);
      await tester.tap(find.text('Save'), warnIfMissed: false);
      expect(pressed, isFalse);
    });
  });

  group('KPI and progress refinements', () {
    testWidgets('wide KPI with flat trend renders', (tester) async {
      await tester.pumpWidget(
        _host(
          child: const AppKpiCard.wide(
            label: 'Open job cards',
            value: '24',
            trend: KpiTrend(label: '0%', isPositive: true, isFlat: true),
            supportingText: 'vs last week',
          ),
        ),
      );
      expect(find.text('OPEN JOB CARDS'), findsOneWidget);
      expect(find.byIcon(Icons.trending_flat_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('indeterminate linear progress renders', (tester) async {
      await tester.pumpWidget(
        _host(child: const AppLinearProgress(value: null)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });

  group('Accessibility semantics', () {
    testWidgets('tappable AppRecordRow is a semantic button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          child: AppRecordRow(title: 'MH 12 AB 4582', onTap: _noop),
        ),
      );
      expect(
        tester.getSemantics(find.byType(AppRecordRow)),
        containsSemantics(isButton: true),
      );
      handle.dispose();
    });

    testWidgets('AppInfoPanel renders in dark theme without exception', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(BrandConfig.orient),
          home: const Scaffold(
            body: Column(
              children: [
                AppInfoPanel.success(title: 'Synced', message: 'All good'),
                AppInfoPanel.navy(title: 'Cloud', message: 'Telemetry'),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('all 03A primitives render at 320 px / 1.6x in Arabic', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        locale: const Locale('ar'),
        scaler: const TextScaler.linear(1.6),
        size: const Size(320, 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppQuantityStepper(value: 12, onChanged: (_) {}),
              const SizedBox(height: 8),
              AppSelectField<int>(
                options: const [
                  AppSelectionOption<int>(value: 1, label: 'بنزين'),
                  AppSelectionOption<int>(value: 2, label: 'ديزل'),
                ],
                value: 1,
                hint: 'اختر الوقود',
                onChanged: (_) {},
              ),
              const SizedBox(height: 8),
              const PendingSyncChip(state: SyncChipState.queued),
              const SizedBox(height: 8),
              const AppKpiCard.wide(
                label: 'المهام المفتوحة',
                value: '24',
                trend: KpiTrend(label: '+2', isPositive: true),
              ),
              const SizedBox(height: 8),
              const AppLinearProgress(value: 0.5, label: 'التقدم'),
              const SizedBox(height: 8),
              const AppRecordRow(
                title: 'سيارة تويوتا كامري',
                subtitle: 'استبدال فحمات الفرامل',
                metadata: PendingSyncChip(state: SyncChipState.notSent),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
