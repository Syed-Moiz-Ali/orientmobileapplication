import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/technician_dashboard_view.dart';
import 'package:staff_app/features/technician/presentation/widgets/job_detail_sheet.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 10 — console shell visual references (EN/AR, mobile + tablet, light
/// + dark spots). Regenerated only for the surfaces intentionally redesigned
/// in Phase 10 and visually reviewed before re-baselining.
///
/// Determinism: golden fixtures never render a ticking stopwatch (running
/// tasks arrive without a recorded start; the paused readout is static by
/// construction), so captures are wall-clock independent.
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Bounded settle: running views own a live 1s stopwatch tick, so
/// pumpAndSettle would wait on its timer forever.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

const _runningJob = TechnicianJobEntity(
  jobCardNo: 'JO-1024',
  dateOfWork: '24 Aug',
  startTime: '09:30 AM',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Camry',
  plateNumber: 'A 12345',
  customerName: 'Ahmed Al Mansoori',
  status: TechJobStatus.inProgress,
  tasks: [
    WorkTaskEntity(
      id: 1,
      ref: 'task-1',
      description: 'Replace front brake pads',
      status: TaskStatus.inProgress,
    ),
    WorkTaskEntity(
      id: 2,
      ref: 'task-2',
      description: 'Road test',
      status: TaskStatus.pending,
    ),
  ],
);

const _heldJob = TechnicianJobEntity(
  jobCardNo: 'JO-1052',
  dateOfWork: '24 Aug',
  startTime: '13:00 PM',
  vehicleBrand: 'Ford',
  vehicleModel: 'Explorer',
  plateNumber: 'C 24680',
  status: TechJobStatus.delayed,
  tasks: [
    WorkTaskEntity(
      id: 5,
      ref: 'task-5',
      description: 'Replace alternator',
      status: TaskStatus.onHold,
      startTime: '13:20',
    ),
  ],
);

void main() {
  setUpAll(_loadFonts);
  // Auth session restore hits secure storage; unit tests have no plugin.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (_) async => null,
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          null,
        );
  });

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('console dashboard 390 $label', (tester) async {
      await _pumpDashboard(
        tester,
        const [_runningJob],
        const Size(390, 844),
        locale,
        dark: false,
      );
      await expectLater(
        find.byType(TechnicianDashboardView),
        matchesGoldenFile('goldens/technician_console_390_$label.png'),
      );
    });

    testWidgets('console banner held 390 $label', (tester) async {
      await _pumpDashboard(
        tester,
        const [_heldJob],
        const Size(390, 844),
        locale,
        dark: false,
      );
      await expectLater(
        find.byType(TechnicianDashboardView),
        matchesGoldenFile('goldens/technician_console_held_390_$label.png'),
      );
    });
  }

  testWidgets('console dashboard 768 en tablet', (tester) async {
    await _pumpDashboard(
      tester,
      const [_runningJob],
      const Size(768, 1024),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(TechnicianDashboardView),
      matchesGoldenFile('goldens/technician_console_768_en.png'),
    );
  });

  testWidgets('console dashboard 390 en dark spot', (tester) async {
    await _pumpDashboard(
      tester,
      const [_runningJob],
      const Size(390, 844),
      const Locale('en'),
      dark: true,
    );
    await expectLater(
      find.byType(TechnicianDashboardView),
      matchesGoldenFile('goldens/technician_console_390_dark.png'),
    );
  });

  testWidgets('console detail held 390 en', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    final fake = _FakeTechnicianNotifier(const [_heldJob]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [technicianDashboardProvider.overrideWith(() => fake)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('en'),
          supportedLocales: StaffLocalizations.supportedLocales,
          localizationsDelegates: _delegates,
          theme: AppTheme.light(BrandConfig.orient),
          home: const TechnicianJobDetailView(job: _heldJob),
        ),
      ),
    );
    await _settle(tester);
    await expectLater(
      find.byType(TechnicianJobDetailView),
      matchesGoldenFile('goldens/technician_console_detail_held_390_en.png'),
    );
  });
}

class _FakeTechnicianNotifier extends TechnicianNotifier {
  _FakeTechnicianNotifier(this._jobs);

  final List<TechnicianJobEntity> _jobs;

  @override
  TechnicianState build() => const TechnicianState(
    attendanceSummary: AttendanceSummaryEntity(),
    assignedJobs: [],
  );

  @override
  List<TechnicianJobEntity> get allJobs => _jobs;

  @override
  List<TechnicianJobEntity> get filteredJobs => _jobs;

  @override
  int get totalJobs => _jobs.length;

  @override
  int get inProgressJobs =>
      _jobs.where((j) => j.status == TechJobStatus.inProgress).length;

  @override
  int get completedJobs => 0;

  @override
  int get delayedJobs =>
      _jobs.where((j) => j.status == TechJobStatus.delayed).length;

  @override
  List<({TechnicianJobEntity job, WorkTaskEntity task})> get allTasks => [
    for (final job in _jobs)
      for (final task in job.tasks) (job: job, task: task),
  ];

  @override
  Future<void> refresh() async {}
}

Future<void> _pumpDashboard(
  WidgetTester tester,
  List<TechnicianJobEntity> jobs,
  Size size,
  Locale locale, {
  required bool dark,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final fake = _FakeTechnicianNotifier(jobs);
  fake.profile = const TechnicianProfileEntity(
    name: 'Ahmed',
    empId: 'EMP-001',
    role: 'Technician',
    branch: 'Al Quoz',
    shift: 'Morning',
    avatarInitials: 'A',
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [technicianDashboardProvider.overrideWith(() => fake)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: StaffLocalizations.supportedLocales,
        localizationsDelegates: _delegates,
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: TechnicianDashboardView(
          fixedRefreshAt: DateTime(2026, 6, 24, 10, 42),
        ),
      ),
    ),
  );
  await _settle(tester);
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
