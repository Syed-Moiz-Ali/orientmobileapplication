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
import 'package:staff_app/features/advisor/inspection_pages/data/models/inspection_view_model.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_assign_tasks_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_provider.dart';
import 'package:staff_app/features/advisor/presentation/pages/repair_order_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/repair_estimate_math.dart';
import 'package:staff_app/features/advisor/presentation/widgets/repair_estimate_share_sheet.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 09 — repair estimates studio visual references (EN/AR, mobile +
/// desktop, light + dark spots). Regenerated only for the screens
/// intentionally redesigned in Phase 09 and visually reviewed before
/// re-baselining.
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Bounded settle: fixed 30x100ms pumps instead of pumpAndSettle, so golden
/// renders can never stick on indeterminate progress animations.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

InspectionState _studioSeed() => const InspectionState(
  serviceLines: [
    ServiceLineItem(name: 'Brake pads replacement', qty: 1, rate: 180),
    ServiceLineItem(name: 'Wheel alignment', qty: 1, rate: 150),
  ],
  partLines: [
    PartLineItem(name: 'Brake pad set', qty: 2, rate: 220),
    PartLineItem(name: 'Oil filter', qty: 1, rate: 45),
  ],
  referenceNumber: 'LPO-2026-001',
  customerRequests: 'Brake noise when stopping',
  garageRecommendations: 'Replace pads and resurface discs',
  tag: 'VIP',
  jobCardId: 'JC-1042',
);

class _SeededInspection extends InspectionNotifier {
  final InspectionState seed;
  _SeededInspection(this.seed);

  @override
  InspectionState build() => seed;
}

const _fakeTechs = [
  AdvisorTechnicianResponse(id: 1, name: 'Ahmed Khan', empId: 'EMP001'),
  AdvisorTechnicianResponse(id: 2, name: 'Ravi Menon', empId: 'EMP002'),
  AdvisorTechnicianResponse(id: 3, name: 'Sara Iqbal', empId: 'EMP003'),
];

RepairInvoiceData _shareSeed() => const RepairInvoiceData(
  workshopName: 'Orient Auto Garage',
  workshopIcon: Icons.build_outlined,
  workshopMeta: 'Dubai · Al Quoz',
  customerName: 'Khalid Mansour',
  customerPhone: '+971501234567',
  vehicleLine: 'Toyota Camry',
  plate: 'DUBAI A 2500',
  preparedOn: '15/10/2026',
  groups: [
    RepairInvoiceGroup(
      title: 'Mandatory Safety Repairs',
      lines: [
        RepairInvoiceLine(
          name: 'Brake pads replacement',
          detail: '1 × AED 180',
          amount: 180,
        ),
        RepairInvoiceLine(
          name: 'Brake pad set',
          detail: '2 × AED 220',
          amount: 440,
        ),
      ],
    ),
    RepairInvoiceGroup(
      title: 'Optional Enhancements',
      lines: [
        RepairInvoiceLine(
          name: 'Wheel alignment',
          detail: '1 × AED 150',
          amount: 150,
        ),
      ],
    ),
  ],
  partsTotal: 485,
  servicesTotal: 330,
);

void main() {
  setUpAll(_loadFonts);

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('studio 390 $label', (tester) async {
      await _pumpStudio(tester, _studioSeed(), const Size(390, 844), locale,
          dark: false);
      await expectLater(
        find.byType(RepairOrderView),
        matchesGoldenFile('goldens/repair_studio_390_$label.png'),
      );
    });

    testWidgets('dispatch 390 $label', (tester) async {
      await _pumpDispatch(tester, const Size(390, 844), locale, dark: false);
      await expectLater(
        find.byType(AdvisorAssignTasksView),
        matchesGoldenFile('goldens/repair_dispatch_390_$label.png'),
      );
    });
  }

  testWidgets('studio 1280 en desktop', (tester) async {
    await _pumpStudio(
        tester, _studioSeed(), const Size(1280, 800), const Locale('en'),
        dark: false);
    await expectLater(
      find.byType(RepairOrderView),
      matchesGoldenFile('goldens/repair_studio_1280_en.png'),
    );
  });

  testWidgets('dispatch 1280 en desktop', (tester) async {
    await _pumpDispatch(
        tester, const Size(1280, 800), const Locale('en'),
        dark: false);
    await expectLater(
      find.byType(AdvisorAssignTasksView),
      matchesGoldenFile('goldens/repair_dispatch_1280_en.png'),
    );
  });

  testWidgets('share sheet 390 en', (tester) async {
    await _pumpShare(tester, const Size(390, 844), const Locale('en'));
    await expectLater(
      find.byType(RepairEstimateShareSheet),
      matchesGoldenFile('goldens/repair_share_390_en.png'),
    );
  });

  testWidgets('studio 390 en dark spot', (tester) async {
    await _pumpStudio(tester, _studioSeed(), const Size(390, 844),
        const Locale('en'),
        dark: true);
    await expectLater(
      find.byType(RepairOrderView),
      matchesGoldenFile('goldens/repair_studio_390_dark.png'),
    );
  });

  testWidgets('dispatch 390 en dark spot', (tester) async {
    await _pumpDispatch(tester, const Size(390, 844), const Locale('en'),
        dark: true);
    await expectLater(
      find.byType(AdvisorAssignTasksView),
      matchesGoldenFile('goldens/repair_dispatch_390_dark.png'),
    );
  });

  testWidgets('studio search no-match 390 en', (tester) async {
    await _pumpStudio(tester, _studioSeed(), const Size(390, 844),
        const Locale('en'),
        dark: false);
    final t =
        await StaffLocalizations.delegate.load(const Locale('en'));
    await tester.enterText(find.byType(AppSearchField), 'zzz-no-such-part');
    await _settle(tester);
    expect(find.text(t.advisorStudioNoMatch), findsOneWidget);
    await expectLater(
      find.byType(RepairOrderView),
      matchesGoldenFile('goldens/repair_studio_nomatch_390_en.png'),
    );
  });

  testWidgets('studio totals match provider math 390 en', (tester) async {
    // Guard against invented totals: the dock total must equal the seeded
    // provider base plus 5% VAT, formatted through MoneyAed.
    const parts = 440.0 + 45.0;
    const labor = 180.0 + 150.0;
    const vat = (parts + labor) * kUaeVatRate;
    const total = parts + labor + vat;
    await _pumpStudio(tester, _studioSeed(), const Size(390, 844),
        const Locale('en'),
        dark: false);
    expect(find.text('AED 485'), findsOneWidget);
    expect(find.text('AED 330'), findsOneWidget);
    expect(find.text('AED 40.75'), findsOneWidget);
    expect(find.text('AED 855.75'), findsOneWidget);
    expect(total, closeTo(855.75, 0.0001));
  });
}

Future<void> _pumpStudio(
  WidgetTester tester,
  InspectionState seed,
  Size size,
  Locale locale, {
  required bool dark,
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
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: RepairOrderView(onBack: () {}),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _pumpDispatch(
  WidgetTester tester,
  Size size,
  Locale locale, {
  required bool dark,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorLocalDataSourceProvider.overrideWithValue(_FakeLocal()),
        advisorRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
        advisorTechniciansProvider.overrideWith((ref) async => _fakeTechs),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: const AdvisorAssignTasksView(jobCardRef: 'JC-1042'),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _pumpShare(
  WidgetTester tester,
  Size size,
  Locale locale,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: _delegates,
      theme: AppTheme.light(BrandConfig.orient, locale: locale),
      home: Scaffold(
        body: SingleChildScrollView(
          child: RepairEstimateShareSheet(
            data: _shareSeed(),
            onShareWhatsApp: () {},
            onCopyLink: () {},
          ),
        ),
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
  Future<Map<String, dynamic>? > getInspection(String id) async => null;

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
  Future<List<WorkItemResponse>> getWorkItems(String jobCardRef) async =>
      const [
        WorkItemResponse(
          id: 1,
          description: 'Replace brake pads',
          estimatedHours: 1.5,
        ),
        WorkItemResponse(
          id: 2,
          description: 'Wheel alignment check',
          estimatedHours: 0.5,
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
