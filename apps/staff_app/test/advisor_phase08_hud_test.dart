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

VehicleDamageFinding _finding(String partId, String id) =>
    VehicleDamageFinding(
      partId: partId,
      id: id,
      damageType: VehicleDamageType.scratch,
      severity: VehicleDamageSeverity.minor,
      normalizedX: 0.5,
      normalizedY: 0.5,
    );

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
    'hud_front': VehiclePartInspection(
      partId: 'hud_front',
      findings: [_finding('hud_front', 'F1')],
    ),
    'hud_rear': VehiclePartInspection(
      partId: 'hud_rear',
      findings: [
        const VehicleDamageFinding(
          partId: 'hud_rear',
          id: 'F2',
          damageType: VehicleDamageType.dent,
          severity: VehicleDamageSeverity.major,
          normalizedX: 0.5,
          normalizedY: 0.9,
        ),
      ],
    ),
    'front_left_door': VehiclePartInspection(
      partId: 'front_left_door',
      findings: [_finding('front_left_door', 'F3')],
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

  group('hud pin bridge', () {
    test('zone part ids round-trip every zone', () {
      for (final zone in VehicleZone.values) {
        expect(hudZoneForPart(hudPartId(zone)), zone);
      }
    });

    test('non-hud and unknown parts resolve to null', () {
      expect(hudZoneForPart('front_left_door'), isNull);
      expect(hudZoneForPart('hud_nope'), isNull);
      expect(hudZoneForPart(''), isNull);
    });

    test('kind mapping follows amber/crimson/blue', () {
      expect(
        hudKindForFindings([
          _finding('hud_front', 'a'),
        ]),
        DamageKind.scratch,
      );
      expect(
        hudKindForFindings([
          const VehicleDamageFinding(
            partId: 'hud_front',
            id: 'b',
            damageType: VehicleDamageType.dent,
            severity: VehicleDamageSeverity.major,
            normalizedX: 0,
            normalizedY: 0,
          ),
        ]),
        DamageKind.dent,
      );
      expect(
        hudKindForFindings([
          const VehicleDamageFinding(
            partId: 'hud_front',
            id: 'c',
            damageType: VehicleDamageType.crack,
            severity: VehicleDamageSeverity.moderate,
            normalizedX: 0,
            normalizedY: 0,
          ),
        ]),
        DamageKind.glass,
      );
    });

    test('finding factory stores zone part, severity and clamped coords', () {
      final finding = hudFindingForKind(
        DamageKind.glass,
        VehicleZone.sideLeft,
      );
      expect(finding.partId, 'hud_sideLeft');
      expect(finding.damageType, VehicleDamageType.crack);
      expect(finding.severity, VehicleDamageSeverity.moderate);
      expect(finding.normalizedX, inInclusiveRange(0, 1));
      expect(finding.normalizedY, inInclusiveRange(0, 1));
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

    test('damage pin add/remove round-trips', () {
      final container = containerWith(_sheetSeed());
      final notifier = container.read(inspectionProvider.notifier);
      final before =
          container
              .read(inspectionProvider)
              .vehiclePartInspections['hud_front']
              ?.findings
              .length ??
          0;
      notifier.addVehicleDamageFinding(
        hudFindingForKind(DamageKind.dent, VehicleZone.front),
      );
      final added = container
          .read(inspectionProvider)
          .vehiclePartInspections['hud_front']!
          .findings;
      expect(added.length, before + 1);
      notifier.removeVehicleDamageFinding('hud_front', added.last.id);
      expect(
        container
            .read(inspectionProvider)
            .vehiclePartInspections['hud_front']!
            .findings
            .length,
        before,
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
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.advisorPackageSortQuickest));
      await tester.pumpAndSettle();
      quickY = tester.getTopLeft(find.text(t.advisorPackageQuick)).dy;
      safetyY = tester.getTopLeft(find.text(t.advisorPackageSafety)).dy;
      expect(quickY, lessThan(safetyY));
      await tester.ensureVisible(find.text(t.advisorPackageSortThorough));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.advisorPackageSortThorough));
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
      expect(sheetSeen, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('spatial HUD sheet', () {
    testWidgets('damage tab shows canvas, pins and shell', (tester) async {
      final container = await _pumpSheet(tester, _sheetSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.byType(WorkspaceAppBar), findsOneWidget);
      expect(find.byType(OfflineStatusPill), findsOneWidget);
      expect(find.byType(SpatialDamageHud), findsOneWidget);
      expect(find.textContaining(t.advisorHudPinsTitle), findsOneWidget);
      expect(
        container.read(inspectionProvider).vehiclePartInspections.length,
        3,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('pins strip collapses until expanded', (tester) async {
      await _pumpSheet(tester, _sheetSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      // Collapsed by default: summary bar only, no delete targets.
      expect(find.text(t.advisorHudShowPins), findsOneWidget);
      expect(find.byTooltip(t.advisorHudDeletePin), findsNothing);
      await tester.tap(find.text(t.advisorHudShowPins));
      await tester.pumpAndSettle();
      expect(find.byTooltip(t.advisorHudDeletePin), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('damage canvas owns the viewport at 390px', (tester) async {
      await _pumpSheet(tester, _sheetSeed(), size: const Size(390, 844));
      final canvasHeight = tester.getSize(find.byType(SpatialDamageHud)).height;
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
      await tester.pumpAndSettle();
      expect(find.text(t.advisorHudRingPass), findsWidgets);
      expect(find.text(t.advisorHudReview), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pin delete removes the finding', (tester) async {
      final container = await _pumpSheet(tester, _sheetSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(t.advisorHudShowPins));
      await tester.pumpAndSettle();
      final deletes = find.byTooltip(t.advisorHudDeletePin);
      expect(deletes, findsNWidgets(3));
      await tester.ensureVisible(deletes.first);
      await tester.pumpAndSettle();
      await tester.tap(deletes.first);
      await tester.pumpAndSettle();
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

    testWidgets('zone tap opens the kind sheet and drops a pin', (
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
      final origin = tester.getTopLeft(
        find.descendant(
          of: find.byType(SpatialDamageHud),
          matching: find.byType(CustomPaint),
        ),
      );
      final size = tester.getSize(
        find.descendant(
          of: find.byType(SpatialDamageHud),
          matching: find.byType(CustomPaint),
        ),
      );
      // Rear anchor: Alignment(0, 0.86) -> fractions (0.5, 0.93).
      await tester.tapAt(origin + Offset(size.width * 0.5, size.height * 0.93));
      await tester.pumpAndSettle();
      expect(find.textContaining(t.advisorHudKindTitle), findsOneWidget);
      await tester.tap(find.text(t.advisorHudKindMinor));
      await tester.pumpAndSettle();
      expect(
        container
            .read(inspectionProvider)
            .vehiclePartInspections['hud_rear']
            ?.findings
            .length,
        1,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('checkpoint rings grade and search filters', (tester) async {
      final container = await _pumpSheet(tester, _sheetSeed());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.textContaining(t.advisorHudTabChecks));
      await tester.pumpAndSettle();
      // Compressed cards build two-up: grade the second card directly.
      expect(find.text(t.advisorHudRingPass), findsWidgets);
      expect(find.text(t.advisorHudRingCaution), findsWidgets);
      expect(find.text(t.advisorHudRingFail), findsWidgets);
      await tester.tap(find.text(t.advisorHudRingFail).at(1));
      await tester.pumpAndSettle();
      expect(
        container.read(inspectionProvider).statuses['brakes_1'],
        ItemStatus.poor,
      );
      // Search is icon-expandable now.
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(AppSearchField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'zzz-no-match');
      await tester.pumpAndSettle();
      expect(find.text(t.advisorHudNoMatch), findsOneWidget);
      // Clear restores the list.
      await tester.tap(find.text(t.advisorHudClear));
      await tester.pumpAndSettle();
      expect(find.text(t.advisorHudNoMatch), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('denied microphone shows the settings path', (tester) async {
      await _pumpSheet(tester, _sheetSeed(), denyPermissions: true);
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.textContaining(t.advisorHudTabChecks));
      await tester.pumpAndSettle();
      final dockHeaders = find.text(t.advisorHudDockTitle);
      await tester.ensureVisible(dockHeaders.first);
      await tester.pumpAndSettle();
      await tester.tap(dockHeaders.first);
      await tester.pumpAndSettle();
      final mic = find.byIcon(Icons.mic_rounded);
      await tester.ensureVisible(mic);
      await tester.pumpAndSettle();
      await tester.tap(mic);
      await tester.pumpAndSettle();
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
        await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.advisorHudMarkAllPass));
      await tester.pumpAndSettle();
      expect(
        container.read(inspectionProvider).statuses.length,
        greaterThanOrEqualTo(2),
      );
      // Collapsed summary bar appears; cards are gone.
      expect(find.text('Brake pads'), findsNothing);
      await tester.tap(find.byIcon(Icons.check_circle_rounded));
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.advisorHudReview));
      await tester.pumpAndSettle();
      // Notify toggle lives in the sheet now.
      expect(find.text(t.advisorHudNotifyOwner), findsOneWidget);
      await tester.tap(find.text(t.advisorHudContinue));
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
      await tester.tap(goodHeader);
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
      await tester.tap(header);
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
      expect(find.text(t.advisorHealthSubmitTitle), findsOneWidget);
      await tester.tap(find.text(t.advisorHealthReviewAgain));
      await tester.pumpAndSettle();
      expect(find.text(t.advisorHealthSubmitTitle), findsNothing);
      await tester.tap(find.text(t.advisorHealthSubmit));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.advisorHealthSubmit).last);
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.advisorHealthSubmit).last);
      await tester.pumpAndSettle();
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
  await tester.pumpAndSettle();
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
  await tester.pumpAndSettle();
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
  await tester.pumpAndSettle();
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
  await tester.pumpAndSettle();
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
