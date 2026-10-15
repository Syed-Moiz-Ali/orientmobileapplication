import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_local_datasource.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/vehicle_damage_map_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/hud_pin_bridge.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/vehicle_body_condition_panel.dart';
import 'package:staff_app/features/advisor/presentation/pages/choose_inspection_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_preview_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_provider.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_sheet_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/real_damage_canvas.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 08 — pin add/remove, grading, voice/photo states, offline queueing,
/// permission-denied paths and shell/responsive coverage for the staff
/// inspection HUD & evidence workspace.
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

VehicleDamageFinding _finding(
  String partId,
  String id, {
  double x = 0.5,
  double y = 0.5,
}) =>
    VehicleDamageFinding(
      partId: partId,
      id: id,
      damageType: VehicleDamageType.scratch,
      severity: VehicleDamageSeverity.minor,
      normalizedX: x,
      normalizedY: y,
    );

/// Bounded settle: NEVER use pumpAndSettle in this file. The sheet owns
/// infinite animations (skeleton shimmer while loading, indeterminate
/// map spinner, entrance tweens) that make pumpAndSettle loop its 6000
/// fake-frame budget and stick the runner for 10 minutes. Twenty fixed
/// 100ms pumps drain every asset future, entrance animation and route
/// transition in these flows — deterministically, hang-free.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Real-part seeds: pins ride real map part ids (front bumper grammar).
InspectionState _sheetSeed() => InspectionState(
  sections: const [
    InspectionSection(
      id: 'brakes',
      label: 'Brakes',
      items: ['Brake pads', 'Brake fluid', 'Brake discs'],
    ),
    InspectionSection(id: 'engine', label: 'Engine', items: ['Engine oil']),
  ],
  statuses: const {'brakes_0': ItemStatus.good},
  vehiclePartInspections: {
    'hood': VehiclePartInspection(
      partId: 'hood',
      findings: [
        VehicleDamageFinding(
          partId: 'hood',
          id: 'F1',
          damageType: VehicleDamageType.scratch,
          severity: VehicleDamageSeverity.minor,
          normalizedX: 0.5,
          normalizedY: 0.16,
        ),
      ],
    ),
    'front_left_fender': const VehiclePartInspection(
      partId: 'front_left_fender',
      findings: [
        VehicleDamageFinding(
          partId: 'front_left_fender',
          id: 'F2',
          damageType: VehicleDamageType.dent,
          severity: VehicleDamageSeverity.major,
          damageLocation: 'palm',
          note: 'Creased along the arch',
          photos: ['/tmp/fender.jpg'],
          normalizedX: 0.28,
          normalizedY: 0.2,
        ),
      ],
    ),
    'front_left_door': VehiclePartInspection(
      partId: 'front_left_door',
      findings: [_finding('front_left_door', 'F3', x: 0.27, y: 0.38)],
    ),
  },
);

InspectionState _previewSeed() => InspectionState(
  sections: const [
    InspectionSection(
      id: 'brakes',
      label: 'Brakes',
      items: ['Brake pads', 'Brake fluid'],
    ),
    InspectionSection(id: 'engine', label: 'Engine', items: ['Engine oil']),
  ],
  statuses: const {
    'brakes_0': ItemStatus.good,
    'brakes_1': ItemStatus.fair,
    'engine_0': ItemStatus.poor,
  },
  jobCardId: 'JC-1042',
);

InspectionState _legacySeed() => InspectionState(
  sections: const [
    InspectionSection(
      id: 'brakes',
      label: 'Brakes',
      items: ['Brake pads', 'Brake fluid'],
    ),
  ],
  statuses: const {'brakes_0': ItemStatus.poor},
  jobCardId: 'JC-1042',
  vehiclePartInspections: {
    'front_left_door': VehiclePartInspection(
      partId: 'front_left_door',
      findings: [_finding('front_left_door', 'L1')],
    ),
  },
);

class _SeededInspection extends InspectionNotifier {
  final InspectionState seed;
  _SeededInspection(this.seed);

  @override
  InspectionState build() => seed;
}

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('phase08');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('inspections');
  });

  group('responsive no-overflow matrix (320/390/768/1280/1440 + 1.3x)', () {
    for (final size in const [
      Size(320, 568),
      Size(390, 844),
      Size(768, 1024),
      Size(1280, 800),
      Size(1440, 900),
    ]) {
      testWidgets('picker renders clean at ${size.width}', (tester) async {
        await _pump(
          tester,
          ChooseInspectionView(
            onSelect: () {},
            onSkip: () {},
            onBack: () {},
          ),
          size: size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('damage tab renders clean at ${size.width}', (tester) async {
        await _pumpSheet(tester, _sheetSeed(), size: size);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('desktop keeps separate full-width tabs (never side-by-side)', (
      tester,
    ) async {
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await _pumpSheet(
        tester,
        _sheetSeed(),
        size: const Size(1280, 800),
      );
      // Damage tab first: map studio + Done marking, no Review CTA.
      expect(find.text(t.advisorHudDoneMarking), findsOneWidget);
      expect(find.text(t.advisorHudReview), findsNothing);
      // Switch to checkpoints: list room + Review CTA, no Done marking.
      await tester.tap(find.textContaining(t.advisorHudTabChecks));
      await _settle(tester);
      expect(find.text(t.advisorHudReview), findsOneWidget);
      expect(find.text(t.advisorHudDoneMarking), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selected pin survives tab switches (IndexedStack rooms)', (
      tester,
    ) async {
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await _pumpSheet(
        tester,
        _sheetSeed(),
        size: const Size(390, 844),
      );
      // First tap selects the pin; switch rooms and back; the second tap
      // on the same pin opens the edit sheet immediately — proving the
      // selection survived (an unselected pin would only select).
      await tester.tap(find.byKey(const ValueKey('damage-marker-F1')));
      await _settle(tester);
      await tester.tap(find.textContaining(t.advisorHudTabChecks));
      await _settle(tester);
      await tester.tap(find.textContaining(t.advisorHudTabDamage));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('damage-marker-F1')));
      await _settle(tester);
      expect(find.text(t.advisorDamageSaveChanges), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('map studio shows title, legend and zoom controls', (
      tester,
    ) async {
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await _pumpSheet(
        tester,
        _sheetSeed(),
        size: const Size(390, 844),
      );
      // Legend chips carry the three severity names (title is semantic).
      expect(find.text(t.advisorDamageMinor), findsWidgets);
      expect(find.text(t.advisorDamageModerate), findsWidgets);
      expect(find.text(t.advisorDamageSevere), findsWidgets);
      expect(find.byTooltip(t.advisorDamageZoomIn), findsOneWidget);
      expect(find.byTooltip(t.advisorDamageZoomOut), findsOneWidget);
      expect(find.byTooltip(t.advisorDamageResetView), findsOneWidget);
      await tester.tap(find.byTooltip(t.advisorDamageZoomIn));
      await _settle(tester);
      await tester.tap(find.byTooltip(t.advisorDamageResetView));
      await _settle(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Show list opens sheet on mobile, drawer on desktop', (
      tester,
    ) async {
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      // Mobile: bottom sheet with the managed rows.
      await _pumpSheet(
        tester,
        _sheetSeed(),
        size: const Size(390, 844),
      );
      await tester.tap(find.text(t.advisorHudShowPins));
      await _settle(tester);
      expect(find.byTooltip(t.advisorDamageEdit), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop drawer lists pins and Esc closes it', (
      tester,
    ) async {
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await _pumpSheet(
        tester,
        _sheetSeed(),
        size: const Size(1280, 800),
      );
      await tester.tap(find.text(t.advisorHudShowPins));
      await _settle(tester);
      expect(find.byTooltip(t.advisorDamageEdit), findsWidgets);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settle(tester);
      expect(find.byTooltip(t.advisorDamageEdit), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('arrow keys walk pins, Enter opens edit', (tester) async {
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await _pumpSheet(
        tester,
        _sheetSeed(),
        size: const Size(1280, 800),
      );
      // Tap selects F1 and focuses the canvas; arrow moves to F2.
      await tester.tap(find.byKey(const ValueKey('damage-marker-F1')));
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _settle(tester);
      expect(find.text(t.advisorDamageSaveChanges), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dossier footer is Convert-primary + Submit-secondary side-by-side', (
      tester,
    ) async {
      await _pumpPreview(
        tester,
        _previewSeed(),
        size: const Size(390, 844),
      );
      expect(find.byType(PrimaryButton), findsWidgets);
      expect(find.byType(SecondaryButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x text clean at 390', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
            advisorRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
          ],
          child: MediaQuery(
            data: MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: const Locale('en'),
              supportedLocales: AppLocales.supported,
              localizationsDelegates: _delegates,
              theme: AppTheme.light(
                BrandConfig.orient,
                locale: const Locale('en'),
              ),
              home: ChooseInspectionView(
                onSelect: () {},
                onSkip: () {},
                onBack: () {},
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('damage pin bridge (real parts)', () {
    test('kind defaults map to the documented severities', () {
      expect(
        defaultSeverityForKind(VehicleDamageType.scratch),
        VehicleDamageSeverity.minor,
      );
      expect(
        defaultSeverityForKind(VehicleDamageType.paintChip),
        VehicleDamageSeverity.minor,
      );
      expect(
        defaultSeverityForKind(VehicleDamageType.dent),
        VehicleDamageSeverity.moderate,
      );
      expect(
        defaultSeverityForKind(VehicleDamageType.crack),
        VehicleDamageSeverity.moderate,
      );
      expect(
        defaultSeverityForKind(VehicleDamageType.broken),
        VehicleDamageSeverity.major,
      );
    });

    test('part labels resolve with stale-id fallback', () async {
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(damagePartLabel(t, 'front_left_fender'), 'Front Left Fender');
      expect(damagePartLabel(t, 'rear_right_taillight'), 'Rear Right Tail Light');
      expect(damagePartLabel(t, 'hud_front'), 'hud front');
      expect(damagePartLabel(t, ''), isEmpty);
    });

    test('worst severity wins for zone tinting', () {
      expect(
        worstSeverity([
          _finding('hood', 'a'),
          const VehicleDamageFinding(
            partId: 'hood',
            id: 'b',
            damageType: VehicleDamageType.dent,
            severity: VehicleDamageSeverity.moderate,
            normalizedX: 0,
            normalizedY: 0,
          ),
        ]),
        VehicleDamageSeverity.moderate,
      );
      expect(
        worstSeverity([
          const VehicleDamageFinding(
            partId: 'hood',
            id: 'c',
            damageType: VehicleDamageType.broken,
            severity: VehicleDamageSeverity.major,
            normalizedX: 0,
            normalizedY: 0,
          ),
        ]),
        VehicleDamageSeverity.major,
      );
      expect(worstSeverity(const []), isNull);
    });

    test('pin payload byte-shape is frozen', () {
      final finding = VehicleDamageFinding(
        partId: 'front_left_fender',
        id: 'VDF-1',
        damageType: VehicleDamageType.dent,
        severity: VehicleDamageSeverity.moderate,
        damageLocation: 'palm',
        note: 'Creased',
        photos: const ['/tmp/a.jpg'],
        normalizedX: 0.28,
        normalizedY: 0.2,
      );
      final json = finding.toJson();
      expect(
        json.keys.toSet(),
        {
          'id',
          'partId',
          'damageType',
          'severity',
          'damageLocation',
          'note',
          'photos',
          'recommendedAction',
          'position',
        },
      );
      expect(
        (json['position'] as Map).keys.toSet(),
        {'x', 'y'},
      );
      // Round-trips through the persisted parts shape unchanged.
      final restored = VehicleDamageFinding.fromJson(
        Map<String, dynamic>.from(
          json.map((k, v) => MapEntry(k.toString(), v)),
        ),
      );
      expect(restored.partId, 'front_left_fender');
      expect(restored.damageLocation, 'palm');
      expect(restored.photos, ['/tmp/a.jpg']);
    });
  });

  group('inspection grading + pins (notifier)', () {
    ProviderContainer containerWith(InspectionState seed) => ProviderContainer(
      overrides: [
        inspectionProvider.overrideWith(() => _SeededInspection(seed)),
        advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
        syncQueueProvider.overrideWithValue(_FakeQueue()),
        syncEngineProvider.overrideWithValue(_FakeEngine()),
      ],
    );

    test('setStatus toggles the grade off on repeat', () {
      final container = containerWith(_sheetSeed());
      final notifier = container.read(inspectionProvider.notifier);
      notifier.setStatus('brakes_1', ItemStatus.poor);
      expect(
        container.read(inspectionProvider).statuses['brakes_1'],
        ItemStatus.poor,
      );
      notifier.setStatus('brakes_1', ItemStatus.poor);
      expect(
        container.read(inspectionProvider).statuses.containsKey('brakes_1'),
        isFalse,
      );
    });

    test('damage pin add/update/remove round-trips on real parts', () {
      final container = containerWith(_sheetSeed());
      final notifier = container.read(inspectionProvider.notifier);
      const finding = VehicleDamageFinding(
        partId: 'hood',
        id: 'VDF-9',
        damageType: VehicleDamageType.dent,
        severity: VehicleDamageSeverity.moderate,
        damageLocation: 'coin',
        note: 'Small ding',
        photos: ['/tmp/hood.jpg'],
        normalizedX: 0.5,
        normalizedY: 0.16,
      );
      notifier.addVehicleDamageFinding(finding);
      final added = container
          .read(inspectionProvider)
          .vehiclePartInspections['hood']!
          .findings;
      expect(added.length, 2);
      // Photos mirror into the media index under the damage key.
      expect(
        container
            .read(inspectionProvider)
            .media['vehicle-damage:VDF-9']
            ?.photoPaths,
        ['/tmp/hood.jpg'],
      );
      notifier.updateVehicleDamageFinding(
        const VehicleDamageFinding(
          partId: 'hood',
          id: 'VDF-9',
          damageType: VehicleDamageType.dent,
          severity: VehicleDamageSeverity.major,
          damageLocation: 'coin',
          photos: ['/tmp/hood.jpg'],
          normalizedX: 0.5,
          normalizedY: 0.16,
        ),
      );
      expect(
        container
            .read(inspectionProvider)
            .vehiclePartInspections['hood']!
            .findings
            .firstWhere((f) => f.id == 'VDF-9')
            .severity,
        VehicleDamageSeverity.major,
      );
      notifier.removeVehicleDamageFinding('hood', 'VDF-9');
      expect(
        container
            .read(inspectionProvider)
            .vehiclePartInspections['hood']!
            .findings
            .length,
        1,
      );
      expect(
        container
            .read(inspectionProvider)
            .media
            .containsKey('vehicle-damage:VDF-9'),
        isFalse,
      );
    });

    test('photo removal drops only the indexed photo', () {
      final container = containerWith(_sheetSeed());
      final notifier = container.read(inspectionProvider.notifier);
      notifier.addPhoto('brakes_0', '/tmp/a.jpg');
      notifier.addPhoto('brakes_0', '/tmp/b.jpg');
      notifier.removePhoto('brakes_0', 0);
      expect(
        container.read(inspectionProvider).media['brakes_0']?.photoPaths,
        ['/tmp/b.jpg'],
      );
    });

    test('submit without a job card fails closed', () async {
      final container = containerWith(_sheetSeed());
      final result = await container
          .read(inspectionProvider.notifier)
          .submitInspection();
      expect(result, isA<Failure>());
    });

    test('submit without ratings fails closed', () async {
      final container = containerWith(
        const InspectionState(jobCardId: 'JC-1'),
      );
      final result = await container
          .read(inspectionProvider.notifier)
          .submitInspection();
      expect(result, isA<Failure>());
    });
  });

  group('package picker', () {
    testWidgets('renders three tiers, focus areas and one primary CTA', (
      tester,
    ) async {
      await _pump(tester, _choose());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.text(t.advisorPackageQuick), findsOneWidget);
      // The selected tier name repeats in the footer summary.
      expect(find.text(t.advisorPackageFull), findsWidgets);
      expect(find.text(t.advisorPackageSafety), findsOneWidget);
      // Progressive disclosure: only the selected tier shows focus areas.
      expect(find.text(t.advisorFocusBrakes), findsOneWidget);
      // Chrome budget: slim header + thin progress + ONE sort row.
      // ("Recommended" doubles as the sort pill and the tier badge.)
      expect(find.text(t.advisorPackageSortRecommended), findsWidgets);
      expect(find.text(t.advisorPackageSortQuickest), findsOneWidget);
      expect(find.text(t.advisorPackageSortThorough), findsOneWidget);
      expect(find.text(t.advisorPackageStart), findsOneWidget);
      expect(find.byType(WorkspaceAppBar), findsOneWidget);
      expect(find.byType(OfflineStatusPill), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('unselected tiers hide details until tapped', (tester) async {
      await _pump(tester, _choose());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.text(t.advisorPackageQuickDesc), findsNothing);
      await tester.tap(find.text(t.advisorPackageQuick));
      await _settle(tester);
      expect(find.text(t.advisorPackageQuickDesc), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sort row reorders tiers for compare', (tester) async {
      await _pump(tester, _choose());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      // Recommended order: comprehensive first, quick above safety.
      var quickY = tester.getTopLeft(find.text(t.advisorPackageQuick)).dy;
      var safetyY = tester.getTopLeft(find.text(t.advisorPackageSafety)).dy;
      expect(quickY, lessThan(safetyY));
      await tester.ensureVisible(find.text(t.advisorPackageSortQuickest));
      await _settle(tester);
      await tester.tap(find.text(t.advisorPackageSortQuickest));
      await _settle(tester);
      quickY = tester.getTopLeft(find.text(t.advisorPackageQuick)).dy;
      safetyY = tester.getTopLeft(find.text(t.advisorPackageSafety)).dy;
      expect(quickY, lessThan(safetyY));
      await tester.ensureVisible(find.text(t.advisorPackageSortThorough));
      await _settle(tester);
      await tester.tap(find.text(t.advisorPackageSortThorough));
      await _settle(tester);
      // Most thorough: safety (35) rises above quick (20).
      quickY = tester.getTopLeft(find.text(t.advisorPackageQuick)).dy;
      safetyY = tester.getTopLeft(find.text(t.advisorPackageSafety)).dy;
      expect(safetyY, lessThan(quickY));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tiers own the viewport at 390px', (tester) async {
      await _pump(tester, _choose());
      final pageHeight = tester.getSize(find.byType(AppResponsivePage)).height;
      expect(pageHeight / 844, greaterThanOrEqualTo(0.50));
      expect(tester.takeException(), isNull);
    });

    testWidgets('selection moves the Selected badge', (tester) async {
      await _pump(tester, _choose());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.text(t.advisorPackageSelected), findsOneWidget);
      await tester.tap(find.text(t.advisorPackageSafety));
      await _settle(tester);
      expect(find.text(t.advisorPackageSelected), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('start navigates to the inspection sheet', (tester) async {
      var sheetSeen = false;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => _choose()),
          GoRoute(
            path: '/inspection-sheet',
            builder: (_, _) {
              sheetSeen = true;
              return const Scaffold(body: Text('sheet-stub'));
            },
          ),
        ],
      );
      await _pumpRouter(tester, router);
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(t.advisorPackageStart));
      await _settle(tester);
      expect(sheetSeen, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('real damage map', () {
    testWidgets('damage tab shows the real car, pins and shell', (
      tester,
    ) async {
      final container = await _pumpSheet(tester, _sheetSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.byType(WorkspaceAppBar), findsOneWidget);
      expect(find.byType(OfflineStatusPill), findsOneWidget);
      expect(find.byType(RealDamageCanvas), findsOneWidget);
      expect(find.textContaining(t.advisorHudPinsTitle), findsOneWidget);
      expect(
        container.read(inspectionProvider).vehiclePartInspections.length,
        3,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Show list opens the managed pins sheet', (tester) async {
      await _pumpSheet(tester, _sheetSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      // Collapsed by default: pins bar only, no delete targets on canvas.
      expect(find.text(t.advisorHudShowPins), findsOneWidget);
      expect(find.byTooltip(t.advisorHudDeletePin), findsNothing);
      await tester.tap(find.text(t.advisorHudShowPins));
      await _settle(tester);
      expect(find.byTooltip(t.advisorHudDeletePin), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('damage canvas owns the viewport at 390px', (tester) async {
      await _pumpSheet(tester, _sheetSeed(), size: const Size(390, 844));
      final canvasHeight = tester.getSize(find.byType(RealDamageCanvas)).height;
      expect(canvasHeight / 844, greaterThanOrEqualTo(0.50));
      expect(tester.takeException(), isNull);
    });

    testWidgets('done marking advances to the checkpoints tab', (
      tester,
    ) async {
      await _pumpSheet(tester, _sheetSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.text(t.advisorHudDoneMarking), findsOneWidget);
      expect(find.text(t.advisorHudRingPass), findsNothing);
      await tester.tap(find.text(t.advisorHudDoneMarking));
      await _settle(tester);
      expect(find.text(t.advisorHudRingPass), findsWidgets);
      expect(find.text(t.advisorHudReview), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pin delete confirms inline then removes', (tester) async {
      final container = await _pumpSheet(tester, _sheetSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(t.advisorHudShowPins));
      await _settle(tester);
      final deletes = find.byTooltip(t.advisorHudDeletePin);
      expect(deletes, findsNWidgets(3));
      await tester.ensureVisible(deletes.first);
      await _settle(tester);
      await tester.tap(deletes.first);
      await _settle(tester);
      // Inline confirmation appears; nothing removed yet.
      expect(find.text(t.advisorDamageDeleteTitle), findsOneWidget);
      expect(
        container
            .read(inspectionProvider)
            .vehiclePartInspections
            .values
            .expand((p) => p.findings)
            .length,
        3,
      );
      await tester.ensureVisible(find.text(t.advisorDamageDelete));
      await _settle(tester);
      await tester.tap(find.text(t.advisorDamageDelete));
      await _settle(tester);
      expect(find.byTooltip(t.advisorHudDeletePin), findsNWidgets(2));
      expect(
        container
            .read(inspectionProvider)
            .vehiclePartInspections
            .values
            .expand((p) => p.findings)
            .length,
        2,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('pin edit opens the prefilled sheet and saves', (
      tester,
    ) async {
      final container = await _pumpSheet(tester, _sheetSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(t.advisorHudShowPins));
      await _settle(tester);
      final edits = find.byTooltip(t.advisorDamageEdit);
      expect(edits, findsNWidgets(3));
      await tester.ensureVisible(edits.first);
      await _settle(tester);
      await tester.tap(edits.first);
      await _settle(tester);
      // The sheet is titled by the tapped part (first pin: hood), not by
      // a generic edit caption.
      expect(find.text(damagePartLabel(t, 'hood')), findsWidgets);
      // The first pin (hood scratch) arrives prefilled: the kind row
      // is present in the sheet (pin-list rows behind it share labels).
      expect(find.text(t.advisorDamageKindScratch), findsWidgets);
      // The sticky confirm CTA is always hittable (scrolls into view).
      await tester.ensureVisible(find.text(t.advisorDamageSaveChanges));
      await _settle(tester);
      await tester.tap(find.text(t.advisorDamageSaveChanges));
      await _settle(tester);
      expect(find.text(t.advisorDamageSaveChanges), findsNothing);
      expect(
        container
            .read(inspectionProvider)
            .vehiclePartInspections
            .values
            .expand((p) => p.findings)
            .length,
        3,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('map error shows the retry card, never blank', (
      tester,
    ) async {
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      // Explicit definition futures win over the ambient loader cache,
      // so this error branch is hermetic regardless of suite order
      // (no global cache mutation, no cross-test leakage).
      final pending = Completer<VehicleMapDefinition>();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('en'),
            supportedLocales: AppLocales.supported,
            localizationsDelegates: _delegates,
            theme: AppTheme.light(BrandConfig.orient),
            home: Scaffold(
              body: SizedBox(
                height: 600,
                child: RealDamageCanvas(
                  inspections: const {},
                  definitionFuture: pending.future,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text(t.advisorDamageMapLoading), findsOneWidget);
      pending.completeError('missing asset');
      await _settle(tester);
      expect(find.text(t.advisorDamageMapError), findsOneWidget);
      // The retry action exists and is enabled (never a dead error card).
      // Reload-success is covered deterministically at the unit level
      // (`reload re-reads the asset after a failure`): tapping through a
      // real asset reload inside a widget suite is load-timing flaky and
      // leaks an in-flight loader future into the next test's settle.
      final sc = await SharedCoreLocalizations.delegate.load(
        const Locale('en'),
      );
      expect(find.text(sc.commonRetry), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('part tap opens the detail sheet; minor confirms a pin', (
      tester,
    ) async {
      final container = await _pumpSheet(
        tester,
        InspectionState(
          sections: _sheetSeed().sections,
          vehiclePartInspections: const {},
        ),
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      final definition = await VehicleMapLoader.load();
      await _tapPart(tester, definition, 'hood');
      await _settle(tester);
      expect(find.text(t.advisorPartHood), findsWidgets);
      await tester.tap(find.text(t.advisorDamageKindScratch));
      await _settle(tester);
      await tester.ensureVisible(find.text(t.advisorDamageAddPin));
      await _settle(tester);
      await tester.tap(find.text(t.advisorDamageAddPin));
      await _settle(tester);
      final hood = container
          .read(inspectionProvider)
          .vehiclePartInspections['hood'];
      expect(hood?.findings.length, 1);
      expect(
        hood?.findings.single.severity,
        VehicleDamageSeverity.minor,
      );
      // The sticky confirm CTA closes the sheet; the pins bar reflects it.
      expect(find.text(t.advisorDamageAddPin), findsNothing);
      expect(find.text(t.advisorHudShowPins), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('moderate damage cannot pin without a photo', (tester) async {
      final container = await _pumpSheet(
        tester,
        InspectionState(
          sections: _sheetSeed().sections,
          vehiclePartInspections: const {},
        ),
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      final definition = await VehicleMapLoader.load();
      await _tapPart(tester, definition, 'front_left_fender');
      await _settle(tester);
      // Dent auto-maps to Moderate, which requires a photo.
      await tester.tap(find.text(t.advisorDamageKindDent));
      await _settle(tester);
      await tester.ensureVisible(find.text(t.advisorDamageAddPin));
      await _settle(tester);
      await tester.tap(find.text(t.advisorDamageAddPin));
      await _settle(tester);
      expect(find.text(t.advisorDamagePhotoRequired), findsOneWidget);
      expect(
        container
            .read(inspectionProvider)
            .vehiclePartInspections
            .values
            .expand((p) => p.findings)
            .length,
        0,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('all 25 parts open the detail sheet', (tester) async {
      await _pumpSheet(
        tester,
        InspectionState(
          sections: _sheetSeed().sections,
          vehiclePartInspections: const {},
        ),
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      final definition = await VehicleMapLoader.load();
      expect(definition.parts, hasLength(25));
      for (final part in definition.parts) {
        await _tapPart(tester, definition, part.id);
        await _settle(tester);
        expect(
          find.text(damagePartLabel(t, part.id)),
          findsWidgets,
          reason: 'detail sheet for ${part.id}',
        );
        await tester.tap(find.byIcon(Icons.close_rounded).first);
        await _settle(tester);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL keeps pin geometry un-mirrored', (tester) async {
      Offset? enCenter;
      await _pumpSheet(tester, _sheetSeed(), locale: const Locale('en'));
      enCenter = tester.getCenter(find.byKey(const ValueKey('damage-marker-F1')));
      await _pumpSheet(tester, _sheetSeed(), locale: const Locale('ar'));
      final arCenter = tester.getCenter(
        find.byKey(const ValueKey('damage-marker-F1')),
      );
      expect(arCenter.dx, moreOrLessEquals(enCenter.dx, epsilon: 1));
      expect(arCenter.dy, moreOrLessEquals(enCenter.dy, epsilon: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('checkpoint rings grade and search filters', (tester) async {
      final container = await _pumpSheet(tester, _sheetSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.textContaining(t.advisorHudTabChecks));
      await _settle(tester);
      // Compressed cards build two-up: grade the second card directly.
      expect(find.text(t.advisorHudRingPass), findsWidgets);
      expect(find.text(t.advisorHudRingCaution), findsWidgets);
      expect(find.text(t.advisorHudRingFail), findsWidgets);
      await tester.tap(find.text(t.advisorHudRingFail).at(1));
      await _settle(tester);
      expect(
        container.read(inspectionProvider).statuses['brakes_1'],
        ItemStatus.poor,
      );
      // Search is icon-expandable now.
      await tester.tap(find.byIcon(Icons.search_rounded));
      await _settle(tester);
      expect(find.byType(AppSearchField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'zzz-no-match');
      await _settle(tester);
      expect(find.text(t.advisorHudNoMatch), findsOneWidget);
      // Clear restores the list.
      await tester.tap(find.text(t.advisorHudClear));
      await _settle(tester);
      expect(find.text(t.advisorHudNoMatch), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('denied microphone shows the settings path', (tester) async {
      await _pumpSheet(tester, _sheetSeed(), denyPermissions: true);
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.textContaining(t.advisorHudTabChecks));
      await _settle(tester);
      final dockHeaders = find.text(t.advisorHudDockTitle);
      await tester.ensureVisible(dockHeaders.first);
      await _settle(tester);
      await tester.tap(dockHeaders.first);
      await _settle(tester);
      final mic = find.byIcon(Icons.mic_rounded);
      await tester.ensureVisible(mic);
      await _settle(tester);
      await tester.tap(mic);
      await _settle(tester);
      expect(find.text(t.advisorHudMicDenied), findsOneWidget);
      expect(find.text(t.advisorHudOpenSettings), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('queued offline count is announced once', (tester) async {
      await _pumpSheet(tester, _sheetSeed(), pendingSync: 2);
      // The header pill is the single queued-state announcement: no banner
      // and no duplicate footer chip.
      expect(find.byType(OfflineStatusPill), findsOneWidget);
      expect(find.byType(OfflineBanner), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('checkpoints own the viewport at 390px', (tester) async {
      for (final locale in const [Locale('en'), Locale('ar')]) {
        await _pumpSheet(tester, _sheetSeed(), locale: locale, size: const Size(390, 844));
        final t = await StaffLocalizations.delegate.load(locale);
        await tester.tap(find.textContaining(t.advisorHudTabChecks));
        await _settle(tester);
        final listHeight = tester.getSize(find.byType(CustomScrollView)).height;
        expect(listHeight / 844, greaterThanOrEqualTo(0.55));
        // At least three compressed cards visible without scrolling.
        expect(find.text(t.advisorHudRingPass).evaluate().length,
            greaterThanOrEqualTo(3));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('completed section collapses with re-expand', (tester) async {
      final container = await _pumpSheet(tester, _sheetSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.textContaining(t.advisorHudTabChecks));
      await _settle(tester);
      await tester.tap(find.text(t.advisorHudMarkAllPass));
      await _settle(tester);
      expect(
        container.read(inspectionProvider).statuses.length,
        greaterThanOrEqualTo(2),
      );
      // Collapsed summary bar appears; cards are gone.
      expect(find.text('Brake pads'), findsNothing);
      await tester.tap(find.byIcon(Icons.check_circle_rounded));
      await _settle(tester);
      expect(find.text('Brake pads'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('review dock opens the notify sheet', (tester) async {
      var previewed = false;
      await _pumpSheet(
        tester,
        _sheetSeed(),
        onPreview: () => previewed = true,
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      // Damage tab first: Done marking advances to the grading tab.
      await tester.tap(find.text(t.advisorHudDoneMarking));
      await _settle(tester);
      await tester.tap(find.text(t.advisorHudReview));
      await _settle(tester);
      // Notify toggle lives in the sheet now.
      expect(find.text(t.advisorHudNotifyOwner), findsOneWidget);
      await tester.tap(find.text(t.advisorHudContinue));
      await _settle(tester);
      expect(previewed, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet, small, dark and AR render without overflow', (
      tester,
    ) async {
      for (final size in const [Size(768, 1024), Size(320, 568)]) {
        await _pumpSheet(tester, _sheetSeed(), size: size);
        expect(tester.takeException(), isNull);
      }
      await _pumpSheet(
        tester,
        _sheetSeed(),
        size: const Size(390, 844),
        textScaler: const TextScaler.linear(1.3),
      );
      expect(tester.takeException(), isNull);
      await _pumpSheet(tester, _sheetSeed(), dark: true);
      expect(tester.takeException(), isNull);
      await _pumpSheet(
        tester,
        _sheetSeed(),
        locale: const Locale('ar'),
        size: const Size(768, 1024),
      );
      final ar = await StaffLocalizations.delegate.load(const Locale('ar'));
      expect(find.textContaining(ar.advisorHudTabDamage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('health report preview', () {
    testWidgets('score, groups, breadcrumbs and convert action', (
      tester,
    ) async {
      await _pumpPreview(tester, _previewSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.byType(WorkspaceAppBar), findsOneWidget);
      expect(find.byType(AppBreadcrumbs), findsOneWidget);
      expect(find.text(t.advisorHealthScore(53)), findsWidgets);
      expect(find.textContaining(t.advisorHealthMandatory), findsOneWidget);
      expect(find.textContaining(t.advisorHealthRecommended), findsOneWidget);
      expect(find.textContaining(t.advisorHealthGoodGroup), findsOneWidget);
      expect(find.text(t.advisorHealthConvert), findsOneWidget);
      expect(find.text(t.advisorHealthSubmit), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mandatory expanded, good collapsed by default', (
      tester,
    ) async {
      await _pumpPreview(tester, _previewSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      // Mandatory (poor) ships expanded; Good ships collapsed.
      expect(find.text('Engine oil'), findsOneWidget);
      expect(find.text('Brake pads'), findsNothing);
      final goodHeader = find.textContaining(t.advisorHealthGoodGroup);
      await tester.ensureVisible(goodHeader);
      await _settle(tester);
      await tester.tap(goodHeader);
      await _settle(tester);
      expect(find.text('Brake pads'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('score strip and share row stay anchored', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });
      await _pumpPreview(tester, _previewSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.text(t.advisorHealthShare), findsOneWidget);
      expect(find.text(t.advisorHealthExport), findsOneWidget);
      await tester.tap(find.text(t.advisorHealthShare));
      await _settle(tester);
      expect(find.text(t.advisorHealthCopied), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('legacy body section stays collapsed', (tester) async {
      await _pumpPreview(tester, _legacySeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      // Exact header row (the recap line carries an attachments suffix).
      final header = find.text('${t.advisorBodyConditionHint} · 1');
      expect(header, findsOneWidget);
      expect(find.byType(VehicleBodyConditionPanel), findsNothing);
      await tester.ensureVisible(header);
      await _settle(tester);
      await tester.tap(header);
      await _settle(tester);
      expect(find.byType(VehicleBodyConditionPanel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty report blocks submission', (tester) async {
      await _pumpPreview(tester, const InspectionState());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      // App-bar subtitle and the empty dossier share the copy.
      expect(find.text(t.advisorHealthEmpty), findsWidgets);
      final submits = tester.widgetList<PrimaryButton>(
        find.widgetWithText(PrimaryButton, t.advisorHealthSubmit),
      );
      expect(submits.single.onPressed, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('convert navigates to the estimate flow', (tester) async {
      var estimateSeen = false;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => InspectionPreviewView(onBack: () {}),
          ),
          GoRoute(
            path: '/repair-order',
            builder: (_, _) {
              estimateSeen = true;
              return const Scaffold(body: Text('estimate-stub'));
            },
          ),
        ],
      );
      await _pumpRouter(
        tester,
        router,
        overrides: [
          inspectionProvider.overrideWith(
            () => _SeededInspection(_previewSeed()),
          ),
          advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
          advisorRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
        ],
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(t.advisorHealthConvert));
      await _settle(tester);
      expect(estimateSeen, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('submit asks for confirmation then navigates', (tester) async {
      var detailSeen = false;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => InspectionPreviewView(onBack: () {}),
          ),
          GoRoute(
            path: '/advisor/job-detail',
            builder: (_, _) {
              detailSeen = true;
              return const Scaffold(body: Text('detail-stub'));
            },
          ),
        ],
      );
      await _pumpRouter(
        tester,
        router,
        overrides: [
          inspectionProvider.overrideWith(
            () => _SeededInspection(_previewSeed()),
          ),
          advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
          advisorRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
        ],
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(t.advisorHealthSubmit));
      await _settle(tester);
      expect(find.text(t.advisorHealthSubmitTitle), findsOneWidget);
      await tester.tap(find.text(t.advisorHealthReviewAgain));
      await _settle(tester);
      expect(find.text(t.advisorHealthSubmitTitle), findsNothing);
      await tester.tap(find.text(t.advisorHealthSubmit));
      await _settle(tester);
      await tester.tap(find.text(t.advisorHealthSubmit).last);
      await _settle(tester);
      expect(detailSeen, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('offline submit queues and returns', (tester) async {
      var backedOut = false;
      final queue = _FakeQueue();
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => InspectionPreviewView(
              onBack: () => backedOut = true,
            ),
          ),
        ],
      );
      await _pumpRouter(
        tester,
        router,
        overrides: [
          inspectionProvider.overrideWith(
            () => _SeededInspection(_previewSeed()),
          ),
          advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
          advisorRemoteDataSourceProvider.overrideWithValue(
            _ThrowingRemote(),
          ),
          syncQueueProvider.overrideWithValue(queue),
          syncEngineProvider.overrideWithValue(_FakeEngine()),
        ],
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(t.advisorHealthSubmit));
      await _settle(tester);
      await tester.tap(find.text(t.advisorHealthSubmit).last);
      await _settle(tester);
      expect(backedOut, isTrue);
      expect(
        queue.ops.where((op) => op.entityType == 'inspection'),
        isNotEmpty,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

// ─── HARNESS ─────────────────────────────────────────────────────────────────

Widget _choose() => ChooseInspectionView(
  onSelect: () {},
  onSkip: () {},
  onBack: () {},
);

/// Display-space tap point for a map part: bounds center when it hit-tests
/// clean, otherwise a grid-searched interior point (small parts like mirrors
/// sit inside larger neighbours' bounds).
Offset _partDisplayPoint(
  WidgetTester tester,
  VehicleMapDefinition definition,
  String partId,
) {
  final part = definition.partById(partId)!;
  Offset mapPointFor(Offset map) {
    final origin = tester.getTopLeft(find.byType(RealDamageCanvas));
    final size = tester.getSize(find.byType(RealDamageCanvas));
    final scale = (size.width / 1254) < (size.height / 1254)
        ? size.width / 1254
        : size.height / 1254;
    final left = (size.width - 1254 * scale) / 2;
    final top = (size.height - 1254 * scale) / 2;
    return origin + Offset(left + map.dx * scale, top + map.dy * scale);
  }

  final bounds = part.path.getBounds();
  if (definition.hitTest(bounds.center)?.id == partId) {
    return mapPointFor(bounds.center);
  }
  for (var r = 0; r < 24; r++) {
    for (var c = 0; c < 24; c++) {
      final candidate = Offset(
        bounds.left + bounds.width * (c + 0.5) / 24,
        bounds.top + bounds.height * (r + 0.5) / 24,
      );
      if (definition.hitTest(candidate)?.id == partId) {
        return mapPointFor(candidate);
      }
    }
  }
  return mapPointFor(bounds.center);
}

Future<void> _tapPart(
  WidgetTester tester,
  VehicleMapDefinition definition,
  String partId,
) async {
  await tester.tapAt(_partDisplayPoint(tester, definition, partId));
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  bool dark = false,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
        advisorRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
        ...overrides,
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: child,
      ),
    ),
  );
  await _settle(tester);
}

Future<ProviderContainer> _pumpSheet(
  WidgetTester tester,
  InspectionState seed, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  bool dark = false,
  int pendingSync = 0,
  bool denyPermissions = false,
  VoidCallback? onPreview,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  // Pre-warm the 25-zone definition OUTSIDE the settle loop: the canvas
  // then renders synchronously from cache and no loader future can stall
  // pumpAndSettle (loading/error branches own a dedicated hermetic test).
  await VehicleMapLoader.load();
  if (denyPermissions) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async {
            final args = call.arguments;
            if (args is Map) {
              return <int, int>{for (final key in args.keys) (key as int): 0};
            }
            return <int, int>{};
          },
        );
  }
  addTearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          null,
        );
  });
  ProviderContainer? container;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inspectionProvider.overrideWith(() => _SeededInspection(seed)),
        advisorPendingSyncCountProvider.overrideWith(
          (ref) => Stream<int>.value(pendingSync),
        ),
        advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
        advisorRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        builder: (context, inner) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: inner!,
        ),
        home: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return InspectionSheetView(
              callbacks: InspectionCallbacks(
                onBack: () {},
                onSaveDraft: () {},
                onPreview: onPreview ?? () {},
              ),
            );
          },
        ),
      ),
    ),
  );
  await _settle(tester);
  return container!;
}

Future<void> _pumpPreview(
  WidgetTester tester,
  InspectionState seed, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inspectionProvider.overrideWith(() => _SeededInspection(seed)),
        advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
        advisorRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: InspectionPreviewView(onBack: () {}),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _pumpRouter(
  WidgetTester tester,
  GoRouter router, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
        advisorRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
        syncQueueProvider.overrideWithValue(_FakeQueue()),
        syncEngineProvider.overrideWithValue(_FakeEngine()),
        ...overrides,
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        routerConfig: router,
      ),
    ),
  );
  await _settle(tester);
}

class _FakeLocal implements AdvisorLocalDataSource {
  Map<String, dynamic>? draft;
  final savedInspections = <String, Map<String, dynamic>>{};

  @override
  Future<void> saveDraft(Map<String, dynamic> data) async {
    draft = data;
  }

  @override
  Map<String, dynamic>? getDraft() => draft;

  @override
  Future<Map<String, dynamic>?> getDraftAsync() async => draft;

  @override
  Future<void> deleteDraft() async {
    draft = null;
  }

  @override
  Future<void> saveInspection(String id, Map<String, dynamic> data) async {
    savedInspections[id] = data;
  }

  @override
  Future<Map<String, dynamic>?> getInspection(String id) async =>
      savedInspections[id];

  @override
  Future<void> save(String id, Map<String, dynamic> data) async {
    savedInspections[id] = data;
  }

  @override
  Future<Map<String, dynamic>?> get(String id) async => savedInspections[id];

  @override
  Future<List<Map<String, dynamic>>> getAll() async =>
      savedInspections.values.toList();

  @override
  Future<void> delete(String id) async {
    savedInspections.remove(id);
  }

  @override
  Future<void> clear() async {
    savedInspections.clear();
  }
}

class _FakeRemote implements AdvisorRemoteDataSource {
  @override
  Future<InspectionResponse> createInspection(Map<String, dynamic> data) async =>
      const InspectionResponse(id: 'INS-1');

  @override
  Future<JobCardDetailResponse> getJobCard(String id) async =>
      const JobCardDetailResponse(id: 'JC-1042', status: 'inspected');

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ThrowingRemote implements AdvisorRemoteDataSource {
  @override
  Future<InspectionResponse> createInspection(Map<String, dynamic> data) async {
    throw Exception('offline');
  }

  @override
  Future<JobCardDetailResponse> getJobCard(String id) async {
    throw Exception('offline');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeQueue implements SyncQueue {
  final ops = <SyncOperation>[];

  @override
  Future<void> enqueue(SyncOperation operation) async {
    ops.add(operation);
  }

  @override
  List<SyncOperation> peekAll() => List.of(ops);

  @override
  SyncOperation? getById(String id) {
    for (final op in ops) {
      if (op.id == id) return op;
    }
    return null;
  }

  @override
  Future<void> remove(String id) async {
    ops.removeWhere((op) => op.id == id);
  }

  @override
  Future<void> updateRetry(SyncOperation operation) async {
    remove(operation.id);
    ops.add(operation);
  }

  @override
  int get length => ops.length;

  @override
  Future<void> clear() async {
    ops.clear();
  }
}

class _FakeEngine implements SyncEngine {
  var synced = false;

  @override
  Future<void> syncAll() async {
    synced = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
