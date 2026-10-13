import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void _noop() {}

Widget _host({
  required Widget child,
  Locale locale = const Locale('en'),
  TextScaler scaler = TextScaler.noScaling,
  Size size = const Size(390, 900),
  bool disableAnimations = false,
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
      data: MediaQueryData(
        size: size,
        textScaler: scaler,
        disableAnimations: disableAnimations,
      ),
      child: Scaffold(body: child),
    ),
  );
}

/// Realistic workshop job-card fixtures (no placeholder text).
class _Job {
  final String plate;
  final String service;
  final String amount;
  const _Job(this.plate, this.service, this.amount);
}

const _jobs = <_Job>[
  _Job('A 12345', 'Brake pad replacement', 'AED 1,250'),
  _Job('B 98765', 'Major 60,000 km service', 'AED 3,480'),
  _Job('C 45678', 'Air-conditioning recharge', 'AED 690'),
];

void main() {
  group('AppSkeleton variants', () {
    testWidgets('renders every variant without exception', (tester) async {
      await tester.pumpWidget(
        _host(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                AppSkeleton.text(width: 160),
                AppSkeleton.textBlock(),
                AppSkeleton.card(),
                AppSkeleton.listRows(),
                AppSkeleton.grid(itemHeight: 90),
                AppSkeleton.chart(height: 160),
                AppSkeleton.table(rows: 4),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(AppSkeleton), findsNWidgets(7));
      expect(tester.takeException(), isNull);
    });

    testWidgets('composites own a single skeleton widget each', (tester) async {
      await tester.pumpWidget(
        _host(
          child: const Column(
            children: [
              AppSkeleton.listRows(rows: 5),
              AppSkeleton.table(rows: 6),
            ],
          ),
        ),
      );
      await tester.pump();
      // One controller each — composites are not made of nested AppSkeletons.
      expect(find.byType(AppSkeleton), findsNWidgets(2));
    });

    testWidgets('renders at 320 / 768 / 1280 without overflow', (tester) async {
      for (final size in const [
        Size(320, 720),
        Size(768, 900),
        Size(1280, 900),
      ]) {
        await tester.pumpWidget(
          _host(
            size: size,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSkeleton.textBlock(lines: 4),
                  SizedBox(height: 12),
                  AppSkeleton.listRows(),
                  SizedBox(height: 12),
                  AppSkeleton.table(columns: 3),
                  SizedBox(height: 12),
                  AppSkeleton.chart(),
                ],
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 120));
        expect(tester.takeException(), isNull, reason: 'at $size');
      }
    });

    testWidgets('static under reduced motion', (tester) async {
      await tester.pumpWidget(
        _host(
          disableAnimations: true,
          child: const AppSkeleton.listRows(rows: 3),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      expect(find.byType(AppSkeleton), findsOneWidget);
    });
  });

  group('EmptyState variants', () {
    testWidgets('no-match uses localized default title (EN/AR)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          child: const EmptyState.noMatch(message: 'Try a different filter'),
        ),
      );
      expect(find.text('No matches found'), findsOneWidget);

      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: const EmptyState.noMatch(message: 'جرّب بحثاً آخر'),
        ),
      );
      expect(find.text('لا توجد نتائج مطابقة'), findsOneWidget);
    });

    testWidgets('error variant still resolves localized copy', (tester) async {
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: EmptyState.error(message: '', onRetry: _noop),
        ),
      );
      expect(find.text('حدث خطأ ما'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });
  });

  group('ErrorView details', () {
    testWidgets('renders message, details and localized retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _host(
          child: ErrorView(
            message: 'Could not load job cards',
            details: 'The workshop service is temporarily unavailable.',
            onRetry: () => retried = true,
          ),
        ),
      );
      expect(find.text('Could not load job cards'), findsOneWidget);
      expect(
        find.text('The workshop service is temporarily unavailable.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });

  group('AppTable', () {
    Widget tableView({
      Locale locale = const Locale('en'),
      Size size = const Size(1000, 800),
    }) {
      return _host(
        locale: locale,
        size: size,
        child: AppTable<_Job>(
          columns: const [
            AppTableColumn(label: 'Plate', flex: 2),
            AppTableColumn(label: 'Service', flex: 3),
            AppTableColumn(label: 'Amount', numeric: true, sortable: true),
          ],
          items: _jobs,
          cells: (context, job) => [
            AppTableCell.text(context, job.plate),
            AppTableCell.text(context, job.service),
            AppTableCell.numeric(context, job.amount),
          ],
        ),
      );
    }

    testWidgets('renders a full table at expanded width', (tester) async {
      await tester.pumpWidget(tableView());
      expect(find.byType(AppTableHeader), findsOneWidget);
      expect(find.text('Plate'), findsOneWidget);
      expect(find.text('Brake pad replacement'), findsOneWidget);
      expect(find.text('AED 3,480'), findsOneWidget);
      expect(find.byType(AppTableRow), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('falls back to record rows below 600 px', (tester) async {
      await tester.pumpWidget(
        _host(
          child: AppTable<_Job>(
            columns: const [
              AppTableColumn(label: 'Plate', flex: 2),
              AppTableColumn(label: 'Service', flex: 3),
              AppTableColumn(label: 'Amount', numeric: true),
            ],
            items: _jobs,
            cells: (context, job) => [
              AppTableCell.text(context, job.plate),
              AppTableCell.text(context, job.service),
              AppTableCell.numeric(context, job.amount),
            ],
            compactBuilder: (context, job) => AppRecordRow(
              title: job.plate,
              subtitle: job.service,
              trailing: Text(job.amount),
            ),
          ),
        ),
      );
      expect(find.byType(AppRecordRow), findsNWidgets(3));
      expect(find.byType(AppTableHeader), findsNothing);
    });

    testWidgets('sortable header reports sort taps and row taps fire', (
      tester,
    ) async {
      var sortIndex = -1;
      var tapped = false;
      await tester.pumpWidget(
        _host(
          size: const Size(1000, 800),
          child: AppTable<_Job>(
            columns: const [
              AppTableColumn(label: 'Plate', flex: 2, sortable: true),
              AppTableColumn(label: 'Amount', numeric: true),
            ],
            items: _jobs,
            onSort: (i) => sortIndex = i,
            onRowTap: (_) => tapped = true,
            cells: (context, job) => [
              AppTableCell.text(context, job.plate),
              AppTableCell.numeric(context, job.amount),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Plate'));
      expect(sortIndex, 0);
      await tester.tap(find.text('A 12345'));
      expect(tapped, isTrue);
    });

    testWidgets('shows loading, empty and error states', (tester) async {
      await tester.pumpWidget(
        _host(
          size: const Size(1000, 800),
          child: AppTable<_Job>(
            columns: const [AppTableColumn(label: 'Plate')],
            items: const [],
            isLoading: true,
            cells: (context, job) => [AppTableCell.text(context, job.plate)],
          ),
        ),
      );
      expect(find.byType(AppSkeleton), findsOneWidget);

      await tester.pumpWidget(
        _host(
          size: const Size(1000, 800),
          child: AppTable<_Job>(
            columns: const [AppTableColumn(label: 'Plate')],
            items: const [],
            emptyMessage: 'No job cards yet',
            cells: (context, job) => [AppTableCell.text(context, job.plate)],
          ),
        ),
      );
      expect(find.text('No job cards yet'), findsOneWidget);

      var retried = false;
      await tester.pumpWidget(
        _host(
          size: const Size(1000, 800),
          child: AppTable<_Job>(
            columns: const [AppTableColumn(label: 'Plate')],
            items: const [],
            isError: true,
            errorMessage: 'Could not load job cards',
            onRetry: () => retried = true,
            cells: (context, job) => [AppTableCell.text(context, job.plate)],
          ),
        ),
      );
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('RTL mirrors header column order', (tester) async {
      await tester.pumpWidget(tableView(locale: const Locale('ar')));
      final plate = tester.getCenter(find.text('Plate'));
      final amount = tester.getCenter(find.text('Amount'));
      // In RTL the first column sits at the reading-start (right) edge.
      expect(plate.dx, greaterThan(amount.dx));
    });

    testWidgets('no overflow at 320 px / 1.6x (fallback)', (tester) async {
      await tester.pumpWidget(
        _host(
          size: const Size(320, 800),
          scaler: const TextScaler.linear(1.6),
          child: AppTable<_Job>(
            columns: const [
              AppTableColumn(label: 'Plate', flex: 2),
              AppTableColumn(label: 'Amount', numeric: true),
            ],
            items: _jobs,
            cells: (context, job) => [
              AppTableCell.text(context, job.plate),
              AppTableCell.numeric(context, job.amount),
            ],
            compactBuilder: (context, job) => AppRecordRow(
              title: job.plate,
              subtitle: job.service,
              trailing: Text(job.amount),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppListSurface recipe', () {
    Widget surface({
      bool loading = false,
      bool error = false,
      bool empty = false,
      bool noMatch = false,
      VoidCallback? onRetry,
      Future<void> Function()? onRefresh,
    }) {
      return _host(
        child: AppListSurface(
          isLoading: loading,
          isError: error,
          errorMessage: error ? 'Could not load job cards' : null,
          onRetry: onRetry,
          isEmpty: empty,
          isNoMatch: noMatch,
          emptyMessage: 'No job cards yet',
          noMatchMessage: 'No job cards match your search',
          onRefresh: onRefresh,
          child: ListView(
            children: const [Text('JOB-4091 Mercedes-Benz E300')],
          ),
        ),
      );
    }

    testWidgets('renders each of the four states', (tester) async {
      await tester.pumpWidget(surface(loading: true));
      expect(find.byType(AppSkeleton), findsOneWidget);

      await tester.pumpWidget(surface(empty: true));
      expect(find.text('No job cards yet'), findsOneWidget);

      await tester.pumpWidget(surface(noMatch: true));
      expect(find.text('No job cards match your search'), findsOneWidget);

      var retried = false;
      await tester.pumpWidget(
        surface(error: true, onRetry: () => retried = true),
      );
      expect(find.text('Could not load job cards'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);

      await tester.pumpWidget(surface());
      expect(find.text('JOB-4091 Mercedes-Benz E300'), findsOneWidget);
    });

    testWidgets('wraps in a RefreshIndicator when onRefresh is provided', (
      tester,
    ) async {
      await tester.pumpWidget(surface(onRefresh: () async {}));
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
