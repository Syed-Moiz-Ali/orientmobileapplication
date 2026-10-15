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
    'hud_front': const VehiclePartInspection(
      partId: 'hud_front',
      findings: [
        VehicleDamageFinding(
          partId: 'hud_front',
          id: 'F1',
          damageType: VehicleDamageType.scratch,
          severity: VehicleDamageSeverity.minor,
          normalizedX: 0.5,
          normalizedY: 0.07,
        ),
      ],
    ),
    'hud_sideLeft': const VehiclePartInspection(
      partId: 'hud_sideLeft',
      findings: [
        VehicleDamageFinding(
          partId: 'hud_sideLeft',
          id: 'F2',
          damageType: VehicleDamageType.dent,
          severity: VehicleDamageSeverity.major,
          normalizedX: 0.05,
          normalizedY: 0.5,
        ),
      ],
    ),
    'hud_rear': const VehiclePartInspection(
      partId: 'hud_rear',
      findings: [
        VehicleDamageFinding(
          partId: 'hud_rear',
          id: 'F3',
          damageType: VehicleDamageType.crack,
          severity: VehicleDamageSeverity.moderate,
          normalizedX: 0.5,
          normalizedY: 0.93,
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
    'hud_front': const VehiclePartInspection(
      partId: 'hud_front',
      findings: [
        VehicleDamageFinding(
          partId: 'hud_front',
          id: 'F1',
          damageType: VehicleDamageType.scratch,
          severity: VehicleDamageSeverity.minor,
          normalizedX: 0.5,
          normalizedY: 0.07,
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

  testWidgets('hud checkpoints 390 en', (tester) async {
    final t = await StaffLocalizations.delegate.load(const Locale('en'));
    await _pumpSheet(
      tester,
      _goldenSheetSeed(),
      const Size(390, 844),
      const Locale('en'),
    );
    await tester.tap(find.textContaining(t.advisorHudTabChecks));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
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
  await tester.pumpAndSettle();
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
  await tester.pumpAndSettle();
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
  await tester.pumpAndSettle();
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
