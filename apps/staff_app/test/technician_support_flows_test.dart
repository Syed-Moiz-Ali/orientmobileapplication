import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/data/datasources/technician_remote_datasource.dart';
import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/escalation_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/parts_request_sheet.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Localizations for the localized console (EN default in these tests).
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

void main() {
  setUpAll(_loadFonts);

  const parts = PartsRequestSheet(
    jobCardRef: 'JO-1024',
    technicianEmpId: 'EMP-001',
    vehicleLabel: 'Toyota Camry',
    plateNumber: 'A 12345',
  );
  const escalation = EscalationSheet(
    jobCardRef: 'JO-1024',
    technicianEmpId: 'EMP-001',
    vehicleLabel: 'Toyota Camry',
    plateNumber: 'A 12345',
  );

  group('Parts request', () {
    testWidgets('carries the correct job context', (tester) async {
      await _pump(tester, parts);
      expect(find.text('JO-1024'), findsOneWidget);
      expect(find.text('Toyota Camry \u00b7 A 12345'), findsOneWidget);
    });

    testWidgets('requires a part name', (tester) async {
      final remote = _FakeRemote();
      await _pump(tester, parts, remote: remote);

      await tester.tap(find.text('Send request · 1'));
      await tester.pumpAndSettle();

      expect(find.text('Enter the part you need'), findsOneWidget);
      expect(remote.parts, isEmpty);
    });

    testWidgets('submits the exact established payload once', (tester) async {
      final remote = _FakeRemote();
      await _pump(tester, parts, remote: remote);

      await tester.enterText(
        find.byType(TextField).first,
        'Front brake pad set',
      );
      await tester.tap(find.text('Send request · 1'));
      await tester.pumpAndSettle();

      expect(remote.parts, hasLength(1));
      expect(remote.parts.single.keys.toSet(), {
        'jobCardRef',
        'technicianEmpId',
        'partName',
        'partNumber',
        'quantity',
        'urgency',
        'notes',
      });
      expect(remote.parts.single['jobCardRef'], 'JO-1024');
      expect(remote.parts.single['technicianEmpId'], 'EMP-001');
      expect(remote.parts.single['partName'], 'Front brake pad set');
      expect(remote.parts.single['quantity'], 1);
    });

    testWidgets('blocks a duplicate submit and shows Sending', (tester) async {
      final remote = _FakeRemote()..gate = Completer<void>();
      await _pump(tester, parts, remote: remote);

      await tester.enterText(find.byType(TextField).first, 'Oil filter');
      final send = find.text('Send request · 1');
      await tester.tap(send);
      await tester.pump();
      expect(find.text('Sending\u2026'), findsOneWidget);
      await tester.tap(find.text('Sending\u2026'), warnIfMissed: false);
      await tester.pump();

      remote.gate!.complete();
      await tester.pumpAndSettle();
      expect(remote.parts, hasLength(1));
    });

    testWidgets('a server failure keeps the form and shows an inline error', (
      tester,
    ) async {
      final remote = _FakeRemote(fail: true);
      await _pump(tester, parts, remote: remote);

      await tester.enterText(find.byType(TextField).first, 'Alternator');
      await tester.tap(find.text('Send request · 1'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining("We couldn't send the request"),
        findsOneWidget,
      );
      // Input is preserved for a retry.
      expect(find.text('Alternator'), findsOneWidget);
      expect(find.text('Send request · 1'), findsOneWidget);
    });

    testWidgets('never shows inventory or stock content', (tester) async {
      await _pump(tester, parts);
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => (t.data ?? '').toLowerCase())
          .join(' ');
      for (final forbidden in const [
        'in stock',
        'out of stock',
        'available',
        'warehouse',
        'ordered',
        'approved',
        'sku',
      ]) {
        expect(texts.contains(forbidden), isFalse, reason: forbidden);
      }
    });

    testWidgets('primary action is at least 48px', (tester) async {
      await _pump(tester, parts);
      expect(
        tester
            .getSize(
              find.ancestor(
                of: find.text('Send request · 1'),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w is FilledButton ||
                      w is OutlinedButton ||
                      w is ElevatedButton,
                ),
              ),
            )
            .height,
        greaterThanOrEqualTo(AppDimensions.touchTarget),
      );
    });

    for (final width in const [320.0, 360.0, 390.0, 430.0]) {
      testWidgets('no overflow at ${width.toInt()}px', (tester) async {
        await _pump(tester, parts, size: Size(width, 844));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('survives 1.6x text', (tester) async {
      await _pump(tester, parts, textScaler: const TextScaler.linear(1.6));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark mode', (tester) async {
      await _pump(tester, parts, theme: AppTheme.dark(BrandConfig.orient));
      expect(tester.takeException(), isNull);
    });
  });

  group('Escalation', () {
    testWidgets('carries the correct job context', (tester) async {
      await _pump(tester, escalation);
      expect(find.text('JO-1024'), findsOneWidget);
      expect(find.text('Toyota Camry \u00b7 A 12345'), findsOneWidget);
    });

    testWidgets('requires an issue description', (tester) async {
      final remote = _FakeRemote();
      await _pump(tester, escalation, remote: remote);

      await tester.tap(find.text('Escalate issue'));
      await tester.pumpAndSettle();

      expect(find.text('Describe the issue'), findsOneWidget);
      expect(remote.escalations, isEmpty);
    });

    testWidgets('submits the exact established payload once', (tester) async {
      final remote = _FakeRemote();
      await _pump(tester, escalation, remote: remote);

      await tester.enterText(
        find.byType(TextField).first,
        'Found a cracked suspension mount that needs supervisor review.',
      );
      await tester.tap(find.text('Escalate issue'));
      await tester.pumpAndSettle();

      expect(remote.escalations, hasLength(1));
      expect(remote.escalations.single.keys.toSet(), {
        'jobCardRef',
        'technicianEmpId',
        'issueType',
        'description',
      });
      expect(remote.escalations.single['jobCardRef'], 'JO-1024');
      expect(remote.escalations.single['issueType'], 'Unexpected Damage');
    });

    testWidgets('blocks a duplicate submit', (tester) async {
      final remote = _FakeRemote()..gate = Completer<void>();
      await _pump(tester, escalation, remote: remote);

      await tester.enterText(
        find.byType(TextField).first,
        'The lift is not locking on the front arms.',
      );
      final send = find.text('Escalate issue');
      await tester.tap(send);
      await tester.pump();
      expect(find.text('Sending\u2026'), findsOneWidget);
      await tester.tap(find.text('Sending\u2026'), warnIfMissed: false);
      await tester.pump();

      remote.gate!.complete();
      await tester.pumpAndSettle();
      expect(remote.escalations, hasLength(1));
    });

    testWidgets('a server failure keeps the input and shows an inline error', (
      tester,
    ) async {
      final remote = _FakeRemote(fail: true);
      await _pump(tester, escalation, remote: remote);

      await tester.enterText(
        find.byType(TextField).first,
        'Suspension mount cracked and unsafe.',
      );
      await tester.tap(find.text('Escalate issue'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining("We couldn't send the escalation"),
        findsOneWidget,
      );
      expect(find.text('Suspension mount cracked and unsafe.'), findsOneWidget);
    });

    testWidgets('never claims severity, a recipient or a ticket', (
      tester,
    ) async {
      await _pump(tester, escalation);
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => (t.data ?? '').toLowerCase())
          .join(' ');
      for (final forbidden in const [
        'high priority',
        'critical',
        'supervisor notified',
        'ticket',
        'job paused',
        'emergency',
      ]) {
        expect(texts.contains(forbidden), isFalse, reason: forbidden);
      }
    });

    testWidgets('no false job-status transition is claimed', (tester) async {
      final remote = _FakeRemote();
      await _pump(tester, escalation, remote: remote);

      await tester.enterText(
        find.byType(TextField).first,
        'Need supervisor input on this repair.',
      );
      await tester.tap(find.text('Escalate issue'));
      await tester.pumpAndSettle();

      expect(find.textContaining('paused'), findsNothing);
      expect(find.textContaining('on hold'), findsNothing);
    });

    testWidgets('primary action is at least 48px', (tester) async {
      await _pump(tester, escalation);
      expect(
        tester
            .getSize(
              find.ancestor(
                of: find.text('Escalate issue'),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w is FilledButton ||
                      w is OutlinedButton ||
                      w is ElevatedButton,
                ),
              ),
            )
            .height,
        greaterThanOrEqualTo(AppDimensions.touchTarget),
      );
    });

    for (final width in const [320.0, 390.0, 430.0]) {
      testWidgets('no overflow at ${width.toInt()}px', (tester) async {
        await _pump(tester, escalation, size: Size(width, 844));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('survives 1.6x text', (tester) async {
      await _pump(tester, escalation, textScaler: const TextScaler.linear(1.6));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark mode', (tester) async {
      await _pump(tester, escalation, theme: AppTheme.dark(BrandConfig.orient));
      expect(tester.takeException(), isNull);
    });
  });

  group('Support flow references', () {
    testWidgets('parts request mobile', (tester) async {
      await _pump(tester, parts);
      await _golden(
        tester,
        PartsRequestSheet,
        'technician_parts_request_mobile',
      );
    });

    testWidgets('parts request error mobile', (tester) async {
      final remote = _FakeRemote(fail: true);
      await _pump(tester, parts, remote: remote);
      await tester.enterText(find.byType(TextField).first, 'Alternator');
      await tester.tap(find.text('Send request · 1'));
      await tester.pumpAndSettle();
      await _golden(
        tester,
        PartsRequestSheet,
        'technician_parts_request_error_mobile',
      );
    });

    testWidgets('parts request large text mobile', (tester) async {
      await _pump(tester, parts, textScaler: const TextScaler.linear(1.6));
      await _golden(
        tester,
        PartsRequestSheet,
        'technician_parts_request_large_text_mobile',
      );
    });

    testWidgets('parts request dark mobile', (tester) async {
      await _pump(tester, parts, theme: AppTheme.dark(BrandConfig.orient));
      await _golden(
        tester,
        PartsRequestSheet,
        'technician_parts_request_dark_mobile',
      );
    });

    testWidgets('escalation mobile', (tester) async {
      await _pump(tester, escalation);
      await _golden(tester, EscalationSheet, 'technician_escalation_mobile');
    });

    testWidgets('escalation error mobile', (tester) async {
      final remote = _FakeRemote(fail: true);
      await _pump(tester, escalation, remote: remote);
      await tester.enterText(
        find.byType(TextField).first,
        'Suspension mount cracked and unsafe.',
      );
      await tester.tap(find.text('Escalate issue'));
      await tester.pumpAndSettle();
      await _golden(
        tester,
        EscalationSheet,
        'technician_escalation_error_mobile',
      );
    });

    testWidgets('escalation large text mobile', (tester) async {
      await _pump(tester, escalation, textScaler: const TextScaler.linear(1.6));
      await _golden(
        tester,
        EscalationSheet,
        'technician_escalation_large_text_mobile',
      );
    });

    testWidgets('escalation dark mobile', (tester) async {
      await _pump(tester, escalation, theme: AppTheme.dark(BrandConfig.orient));
      await _golden(
        tester,
        EscalationSheet,
        'technician_escalation_dark_mobile',
      );
    });
  });
}

Future<void> _golden(WidgetTester tester, Type type, String name) =>
    expectLater(find.byType(type), matchesGoldenFile('goldens/$name.png'));

// ---------- Harness ----------

class _FakeRemote implements TechnicianRemoteDataSource {
  _FakeRemote({this.fail = false});

  final bool fail;
  Completer<void>? gate;
  final List<Map<String, dynamic>> parts = [];
  final List<Map<String, dynamic>> escalations = [];

  @override
  Future<void> requestPart(Map<String, dynamic> data) async {
    await _wait();
    if (fail) throw Exception('network');
    parts.add(data);
  }

  @override
  Future<void> escalateIssue(Map<String, dynamic> data) async {
    await _wait();
    if (fail) throw Exception('network');
    escalations.add(data);
  }

  Future<void> _wait() async {
    final g = gate;
    if (g != null) await g.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Future<void> _pump(
  WidgetTester tester,
  Widget sheet, {
  _FakeRemote? remote,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        technicianRemoteDataSourceProvider.overrideWithValue(
          remote ?? _FakeRemote(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('en'),
        supportedLocales: StaffLocalizations.supportedLocales,
        localizationsDelegates: _delegates,
        theme: theme ?? AppTheme.light(BrandConfig.orient),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => sheet,
                ),
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('OPEN'));
  await tester.pumpAndSettle();
}

Future<void> _loadFonts() async {
  final appFont = File(
    '..${Platform.pathSeparator}..${Platform.pathSeparator}packages'
    '${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets'
    '${Platform.pathSeparator}fonts${Platform.pathSeparator}plus_jakarta_sans'
    '${Platform.pathSeparator}PlusJakartaSans-Variable.ttf',
  );
  final appBytes = await appFont.readAsBytes();
  await (FontLoader(
    AppFontFamilies.app,
  )..addFont(Future.value(ByteData.sublistView(appBytes)))).load();

  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts'
    '${Platform.pathSeparator}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
}
