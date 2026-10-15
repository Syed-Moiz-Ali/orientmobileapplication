import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_local_datasource.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/vehicle_damage_map_model.dart';
import 'package:staff_app/features/advisor/presentation/pages/choose_inspection_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_preview_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_provider.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_sheet_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 08 — inspection HUD visual references (EN/AR, mobile/tablet).
/// Regenerated only for the screens intentionally redesigned in Phase 08 and
/// visually reviewed before re-baselining.
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Bounded settle (same rationale as the hud suite): fixed 30x100ms
/// pumps instead of pumpAndSettle, so golden renders can never stick
/// on the sheet's infinite shimmer/spinner animations.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

InspectionState _goldenSheetSeed() => InspectionState(
  sections: const [
    InspectionSection(
      id: 'brakes',
      label: 'Brakes',
      items: ['Brake pads', 'Brake fluid', 'Brake discs'],
    ),
    InspectionSection(
      id: 'engine',
      label: 'Engine',
      items: ['Engine oil', 'Drive belts'],
    ),
    InspectionSection(
      id: 'suspension',
      label: 'Suspension',
      items: ['Shock absorbers', 'Bushings'],
    ),
  ],
  statuses: const {
    'brakes_0': ItemStatus.good,
    'brakes_1': ItemStatus.fair,
    'engine_0': ItemStatus.good,
  },
  vehiclePartInspections: {
    'hood': const VehiclePartInspection(
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
    'front_left_door': const VehiclePartInspection(
      partId: 'front_left_door',
      findings: [
        VehicleDamageFinding(
          partId: 'front_left_door',
          id: 'F2',
          damageType: VehicleDamageType.dent,
          severity: VehicleDamageSeverity.major,
          damageLocation: 'palm',
          photos: ['/tmp/door.jpg'],
          normalizedX: 0.27,
          normalizedY: 0.38,
        ),
      ],
    ),
    'rear_windshield': const VehiclePartInspection(
      partId: 'rear_windshield',
      findings: [
        VehicleDamageFinding(
          partId: 'rear_windshield',
          id: 'F3',
          damageType: VehicleDamageType.crack,
          severity: VehicleDamageSeverity.moderate,
          photos: ['/tmp/glass.jpg'],
          normalizedX: 0.5,
          normalizedY: 0.71,
        ),
      ],
    ),
  },
);

InspectionState _goldenPreviewSeed() => InspectionState(
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
  vehiclePartInspections: {
    'hood': const VehiclePartInspection(
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
  },
);

class _SeededInspection extends InspectionNotifier {
  final InspectionState seed;
  _SeededInspection(this.seed);

  @override
  InspectionState build() => seed;
}

void main() {
  setUpAll(_loadFonts);

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('package picker 390 $label', (tester) async {
      await _pump(
        tester,
        ChooseInspectionView(onSelect: () {}, onSkip: () {}, onBack: () {}),
        const Size(390, 844),
        locale,
      );
      await expectLater(
        find.byType(ChooseInspectionView),
        matchesGoldenFile('goldens/inspection_package_390_$label.png'),
      );
    });

    testWidgets('hud damage canvas 390 $label', (tester) async {
      await _pumpSheet(
        tester,
        _goldenSheetSeed(),
        const Size(390, 844),
        locale,
      );
      await expectLater(
        find.byType(InspectionSheetView),
        matchesGoldenFile('goldens/inspection_hud_390_$label.png'),
      );
    });

    testWidgets('health report 390 $label', (tester) async {
      await _pumpPreview(
        tester,
        _goldenPreviewSeed(),
        const Size(390, 844),
        locale,
      );
      await expectLater(
        find.byType(InspectionPreviewView),
        matchesGoldenFile('goldens/inspection_health_390_$label.png'),
      );
    });
  }

  testWidgets('hud damage canvas 768 en', (tester) async {
    final t = await StaffLocalizations.delegate.load(const Locale('en'));
    await _pumpSheet(
      tester,
      _goldenSheetSeed(),
      const Size(768, 1024),
      const Locale('en'),
    );
    expect(find.textContaining(t.advisorHudPinsTitle), findsOneWidget);
    await expectLater(
      find.byType(InspectionSheetView),
      matchesGoldenFile('goldens/inspection_hud_768_en.png'),
    );
  });

  testWidgets('damage map with all 25 parts pinned 390 en', (tester) async {
    final definition = await VehicleMapLoader.load();
    final severities = VehicleDamageSeverity.values;
    final types = [
      VehicleDamageType.scratch,
      VehicleDamageType.dent,
      VehicleDamageType.crack,
    ];
    final inspections = <String, VehiclePartInspection>{};
    for (var i = 0; i < definition.parts.length; i++) {
      final part = definition.parts[i];
      final center = part.path.getBounds().center;
      inspections[part.id] = VehiclePartInspection(
        partId: part.id,
        findings: [
          VehicleDamageFinding(
            partId: part.id,
            id: 'ALL-$i',
            damageType: types[i % types.length],
            severity: severities[i % severities.length],
            normalizedX: (center.dx / 1254).clamp(0.0, 1.0),
            normalizedY: (center.dy / 1254).clamp(0.0, 1.0),
          ),
        ],
      );
    }
    await _pumpSheet(
      tester,
      InspectionState(
        sections: _goldenSheetSeed().sections,
        statuses: _goldenSheetSeed().statuses,
        vehiclePartInspections: inspections,
      ),
      const Size(390, 844),
      const Locale('en'),
    );
    await expectLater(
      find.byType(InspectionSheetView),
      matchesGoldenFile('goldens/inspection_damage_allpins_390_en.png'),
    );
  });

  testWidgets('hud checkpoints 390 en', (tester) async {
    final t = await StaffLocalizations.delegate.load(const Locale('en'));
    await _pumpSheet(
      tester,
      _goldenSheetSeed(),
      const Size(390, 844),
      const Locale('en'),
    );
    await tester.tap(find.textContaining(t.advisorHudTabChecks));
    await _settle(tester);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await _settle(tester);
    await expectLater(
      find.byType(InspectionSheetView),
      matchesGoldenFile('goldens/inspection_checks_390_en.png'),
    );
  });

  testWidgets('package picker 768 en', (tester) async {
    await _pump(
      tester,
      ChooseInspectionView(onSelect: () {}, onSkip: () {}, onBack: () {}),
      const Size(768, 1024),
      const Locale('en'),
    );
    await expectLater(
      find.byType(ChooseInspectionView),
      matchesGoldenFile('goldens/inspection_package_768_en.png'),
    );
  });

  testWidgets('health report 768 en', (tester) async {
    await _pumpPreview(
      tester,
      _goldenPreviewSeed(),
      const Size(768, 1024),
      const Locale('en'),
    );
    await expectLater(
      find.byType(InspectionPreviewView),
      matchesGoldenFile('goldens/inspection_health_768_en.png'),
    );
  });

  testWidgets('package picker 1280 en desktop panoramic', (tester) async {
    await _pump(
      tester,
      ChooseInspectionView(onSelect: () {}, onSkip: () {}, onBack: () {}),
      const Size(1280, 800),
      const Locale('en'),
    );
    await expectLater(
      find.byType(ChooseInspectionView),
      matchesGoldenFile('goldens/inspection_package_1280_en.png'),
    );
  });

  testWidgets('hud desktop side-by-side 1280 en', (tester) async {
    await _pumpSheet(
      tester,
      _goldenSheetSeed(),
      const Size(1280, 800),
      const Locale('en'),
    );
    await expectLater(
      find.byType(InspectionSheetView),
      matchesGoldenFile('goldens/inspection_hud_1280_en.png'),
    );
  });

  testWidgets('health report two-col 1280 en', (tester) async {
    await _pumpPreview(
      tester,
      _goldenPreviewSeed(),
      const Size(1280, 800),
      const Locale('en'),
    );
    await expectLater(
      find.byType(InspectionPreviewView),
      matchesGoldenFile('goldens/inspection_health_1280_en.png'),
    );
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child,
  Size size,
  Locale locale,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
        advisorRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: child,
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _pumpSheet(
  WidgetTester tester,
  InspectionState seed,
  Size size,
  Locale locale,
) async {
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
        home: InspectionSheetView(
          callbacks: InspectionCallbacks(
            onBack: () {},
            onSaveDraft: () {},
            onPreview: () {},
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _pumpPreview(
  WidgetTester tester,
  InspectionState seed,
  Size size,
  Locale locale,
) async {
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

class _FakeLocal implements AdvisorLocalDataSource {
  @override
  Future<void> saveDraft(Map<String, dynamic> data) async {}

  @override
  Map<String, dynamic>? getDraft() => null;

  @override
  Future<Map<String, dynamic>?> getDraftAsync() async => null;

  @override
  Future<void> deleteDraft() async {}

  @override
  Future<void> saveInspection(String id, Map<String, dynamic> data) async {}

  @override
  Future<Map<String, dynamic>?> getInspection(String id) async => null;

  @override
  Future<void> save(String id, Map<String, dynamic> data) async {}

  @override
  Future<Map<String, dynamic>?> get(String id) async => null;

  @override
  Future<List<Map<String, dynamic>>> getAll() async => const [];

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> clear() async {}
}

class _FakeRemote implements AdvisorRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<void> _loadFonts() async {
  Future<void> load(String family, String relative) async {
    final bytes = await File(relative).readAsBytes();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }

  final sep = Platform.pathSeparator;
  await load(
    AppFontFamilies.app,
    '..$sep..${sep}packages${sep}shared_core${sep}assets${sep}fonts'
    '${sep}plus_jakarta_sans${sep}PlusJakartaSans-Variable.ttf',
  );
  for (final weight in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    await load(
      AppFontFamilies.arabic,
      '..$sep..${sep}packages${sep}shared_core${sep}assets${sep}fonts'
      '${sep}ibm_plex_sans_arabic${sep}IBMPlexSansArabic-$weight.ttf',
    );
  }

  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${sep}cache${sep}artifacts${sep}material_fonts'
    '${sep}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
}
