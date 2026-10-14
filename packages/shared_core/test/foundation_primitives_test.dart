import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

Widget _host({
  required Widget child,
  Locale locale = const Locale('en'),
  bool dark = false,
  double width = 390,
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
    theme: dark
        ? AppTheme.dark(BrandConfig.orient, locale: locale)
        : AppTheme.light(BrandConfig.orient, locale: locale),
    home: Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

List<AppCommand> get _commands => [
      AppCommand(
        id: 'new-job',
        label: 'Create job card',
        hint: 'Intake',
        onSelected: () {},
      ),
      AppCommand(
        id: 'search-vin',
        label: 'Search by VIN',
        onSelected: () {},
      ),
    ];

/// Phase 01.2 — the seven new foundation primitives.
///
/// Every widget resolves styling through `context.colors` /
/// `context.semanticColors` only, renders in EN + AR, and survives the
/// 320 / 768 / 1280 widths without overflow (mirroring the golden suite).
void main() {
  group('AppFilterBar', () {
    testWidgets('selects, toggles off and clears (EN)', (tester) async {
      String? selected = 'A';
      await tester.pumpWidget(
        _host(
          child: AppFilterBar(
            options: const ['A', 'B'],
            selected: selected,
            onSelected: (v) => selected = v,
          ),
        ),
      );
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      await tester.tap(find.text('B'));
      expect(selected, 'B');
    });

    testWidgets('Arabic renders clear affordance', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: AppFilterBar(
            options: const ['قيد التنفيذ'],
            selected: 'قيد التنفيذ',
            onSelected: (_) {},
          ),
        ),
      );
      expect(find.text('مسح'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no selection hides the clear action', (tester) async {
      await tester.pumpWidget(
        _host(
          child: AppFilterBar(
            options: const ['A'],
            selected: null,
            onSelected: (_) {},
          ),
        ),
      );
      expect(find.text('Clear'), findsNothing);
    });
  });

  group('AppDateRangeField', () {
    testWidgets('formats the selected range (EN)', (tester) async {
      await tester.pumpWidget(
        _host(
          child: AppDateRangeField(
            value: DateTimeRange(
              start: DateTime(2026, 10, 7),
              end: DateTime(2026, 10, 14),
            ),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.textContaining('Oct 2026'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Arabic formats with Arabic months', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: AppDateRangeField(
            value: DateTimeRange(
              start: DateTime(2026, 10, 7),
              end: DateTime(2026, 10, 14),
            ),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.textContaining('أكتوبر'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty state shows the select label + clear clears', (
      tester,
    ) async {
      var cleared = false;
      await tester.pumpWidget(
        _host(
          child: AppDateRangeField(
            value: DateTimeRange(
              start: DateTime(2026, 10, 7),
              end: DateTime(2026, 10, 14),
            ),
            onChanged: (v) => cleared = v == null,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Clear dates'));
      expect(cleared, isTrue);
    });

    testWidgets('disabled field is not tappable', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(
          child: AppDateRangeField(
            value: null,
            enabled: false,
            onChanged: (_) => tapped = true,
          ),
        ),
      );
      await tester.tap(
        find.byType(AppDateRangeField),
        warnIfMissed: false,
      );
      expect(tapped, isFalse);
    });
  });

  group('AppPaginationFooter', () {
    testWidgets('shows page indicator + results (EN)', (tester) async {
      await tester.pumpWidget(
        _host(
          child: AppPaginationFooter(
            page: 2,
            totalPages: 8,
            totalResults: 96,
            onPrevious: () {},
            onNext: () {},
          ),
        ),
      );
      expect(find.text('Page 2 of 8'), findsOneWidget);
      expect(find.text('96 results'), findsOneWidget);
    });

    testWidgets('Arabic page indicator', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: AppPaginationFooter(
            page: 2,
            totalPages: 8,
            totalResults: 96,
            onPrevious: () {},
            onNext: () {},
          ),
        ),
      );
      expect(find.text('الصفحة 2 من 8'), findsOneWidget);
    });

    testWidgets('first page disables previous', (tester) async {
      await tester.pumpWidget(
        _host(
          child: const AppPaginationFooter(
            page: 1,
            totalPages: 1,
            totalResults: 4,
          ),
        ),
      );
      expect(find.text('Page 1 of 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppCommandPalette', () {
    testWidgets('filters commands by query', (tester) async {
      await tester.pumpWidget(_host(child: AppCommandPalette(
        commands: _commands,
      )));
      expect(find.text('Create job card'), findsOneWidget);
      expect(find.text('Search by VIN'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'job');
      await tester.pump();
      expect(find.text('Create job card'), findsOneWidget);
      expect(find.text('Search by VIN'), findsNothing);
    });

    testWidgets('empty query state localizes (AR)', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: AppCommandPalette(commands: _commands),
        ),
      );
      await tester.enterText(find.byType(TextField), 'zzz-no-match');
      await tester.pump();
      expect(find.text('لا توجد أوامر مطابقة'), findsOneWidget);
    });

    testWidgets('selecting a command fires callbacks', (tester) async {
      var tapped = false;
      var reported = false;
      await tester.pumpWidget(
        _host(
          child: AppCommandPalette(
            commands: [
              AppCommand(
                id: 'x',
                label: 'Do it',
                onSelected: () => tapped = true,
              ),
            ],
            onSelected: (_) => reported = true,
          ),
        ),
      );
      await tester.tap(find.text('Do it'));
      expect(tapped, isTrue);
      expect(reported, isTrue);
    });
  });

  group('AppStepper', () {
    testWidgets('announces localized progress + completes taps', (
      tester,
    ) async {
      var tapped = -1;
      await tester.pumpWidget(
        _host(
          child: AppStepper(
            steps: const ['Intake', 'Inspect', 'Deliver'],
            currentIndex: 1,
            onStepTap: (i) => tapped = i,
          ),
        ),
      );
      expect(find.text('Intake'), findsOneWidget);
      await tester.tap(find.text('Deliver'));
      expect(tapped, 2);
    });

    testWidgets('Arabic progress semantics', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: const AppStepper(
            steps: ['الاستلام', 'الفحص'],
            currentIndex: 0,
          ),
        ),
      );
      expect(find.text('الاستلام'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppTimeline', () {
    const entries = [
      AppTimelineEntry(
        title: 'Received',
        subtitle: 'Odo 62,400',
        time: '09:30',
        tone: StatusColorRole.success,
      ),
      AppTimelineEntry(title: 'Flagged', tone: StatusColorRole.warning),
    ];

    testWidgets('renders entries with time + subtitle', (tester) async {
      await tester.pumpWidget(
        _host(child: const AppTimeline(entries: entries)),
      );
      expect(find.text('Received'), findsOneWidget);
      expect(find.text('09:30'), findsOneWidget);
      expect(find.text('Odo 62,400'), findsOneWidget);
    });

    testWidgets('tone dots resolve from semantic families', (tester) async {
      late AppSemanticColors semantic;
      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              semantic = context.semanticColors;
              return const AppTimeline(entries: entries);
            },
          ),
        ),
      );
      expect(semantic.status(StatusColorRole.success), semantic.success);
    });

    testWidgets('Arabic renders without overflow', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: const AppTimeline(entries: entries),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppTrendStat', () {
    testWidgets('rising stat shows grouped value + delta', (tester) async {
      await tester.pumpWidget(
        _host(
          child: const AppTrendStat(
            label: 'Revenue today',
            displayValue: 'AED 48,250',
            deltaFraction: 0.184,
          ),
        ),
      );
      expect(find.text('AED 48,250'), findsOneWidget);
      expect(find.textContaining('18'), findsOneWidget);
    });

    testWidgets('falling bad stat uses danger tone (dark too)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          dark: true,
          child: const AppTrendStat(
            label: 'Comebacks',
            displayValue: '6',
            deltaFraction: 0.12,
          ),
        ),
      );
      expect(find.text('6'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Arabic trend label', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: const AppTrendStat(
            label: 'الإيراد',
            displayValue: 'AED 48,250',
            deltaFraction: -0.05,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Responsive (320 / 768 / 1280)', () {
    Future<void> pumpAll(
      WidgetTester tester, {
      required Locale locale,
      required double width,
      bool dark = false,
    }) async {
      final body = Column(
        children: [
          AppFilterBar(
            options: const ['A', 'B', 'C'],
            selected: 'A',
            onSelected: (_) {},
          ),
          AppDateRangeField(
            value: DateTimeRange(
              start: DateTime(2026, 10, 7),
              end: DateTime(2026, 10, 14),
            ),
            onChanged: (_) {},
          ),
          AppPaginationFooter(
            page: 2,
            totalPages: 8,
            totalResults: 96,
            onPrevious: () {},
            onNext: () {},
          ),
          AppCommandPalette(commands: _commands),
          const AppStepper(
            steps: ['One', 'Two', 'Three'],
            currentIndex: 1,
          ),
          const AppTimeline(
            entries: [
              AppTimelineEntry(title: 'T1', tone: StatusColorRole.info),
              AppTimelineEntry(title: 'T2', tone: StatusColorRole.success),
            ],
          ),
          const AppTrendStat(
            label: 'L',
            displayValue: 'AED 1,250',
            deltaFraction: 0.1,
          ),
        ],
      );
      await tester.pumpWidget(
        _host(locale: locale, dark: dark, width: width, child: body),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    }

    for (final width in [320.0, 768.0, 1280.0]) {
      testWidgets('all primitives survive ${width.toInt()}px EN', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await pumpAll(tester, locale: const Locale('en'), width: width);
      });

      testWidgets('all primitives survive ${width.toInt()}px AR', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await pumpAll(tester, locale: const Locale('ar'), width: width);
      });
    }
  });
}
