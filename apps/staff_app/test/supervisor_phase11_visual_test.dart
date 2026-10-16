import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/qc_checklist_sheet.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_assign_sheet.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_dashboard_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_queue_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_reports_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_review_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_scaffold.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_schedule_tab.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 11 — supervisor floor-command visual references (EN/AR, mobile +
/// tablet + desktop, light + dark spots), captured with real fonts.
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(_loadFonts);
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (_) async => null,
        );
  });

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('supervisor shell 390 $label', (tester) async {
      await _pump(
        tester,
        const SupervisorScaffold(),
        const Size(390, 844),
        locale,
        dark: false,
      );
      await expectLater(
        find.byType(SupervisorScaffold),
        matchesGoldenFile('goldens/supervisor_shell_390_$label.png'),
      );
    });
  }

  testWidgets('supervisor shell 768 en', (tester) async {
    await _pump(
      tester,
      const SupervisorScaffold(),
      const Size(768, 1024),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorScaffold),
      matchesGoldenFile('goldens/supervisor_shell_768_en.png'),
    );
  });

  testWidgets('supervisor shell 1280 en', (tester) async {
    await _pump(
      tester,
      const SupervisorScaffold(),
      const Size(1280, 900),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorScaffold),
      matchesGoldenFile('goldens/supervisor_shell_1280_en.png'),
    );
  });

  testWidgets('supervisor shell 390 dark spot', (tester) async {
    await _pump(
      tester,
      const SupervisorScaffold(),
      const Size(390, 844),
      const Locale('en'),
      dark: true,
    );
    await expectLater(
      find.byType(SupervisorScaffold),
      matchesGoldenFile('goldens/supervisor_shell_390_dark.png'),
    );
  });

  testWidgets('supervisor queue 390 en', (tester) async {
    await _pump(
      tester,
      SupervisorQueueTab(onOpenReview: () {}),
      const Size(390, 844),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorQueueTab),
      matchesGoldenFile('goldens/supervisor_queue_390_en.png'),
    );
  });

  testWidgets('supervisor review 390 en', (tester) async {
    await _pump(
      tester,
      const SupervisorReviewTab(),
      const Size(390, 844),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorReviewTab),
      matchesGoldenFile('goldens/supervisor_review_390_en.png'),
    );
  });

  testWidgets('supervisor reports 390 en', (tester) async {
    await _pump(
      tester,
      const SupervisorReportsTab(),
      const Size(390, 844),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorReportsTab),
      matchesGoldenFile('goldens/supervisor_reports_390_en.png'),
    );
  });

  testWidgets('supervisor assign sheet 390 en', (tester) async {
    await _pump(
      tester,
      const Pad(child: SupervisorAssignSheet()),
      const Size(390, 844),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorAssignSheet),
      matchesGoldenFile('goldens/supervisor_assign_390_en.png'),
    );
  });

  testWidgets('supervisor qc sheet 390 en', (tester) async {
    await _pump(
      tester,
      const Pad(
        child: QcChecklistSheet(
          jobCardId: 1042,
          jobCardRef: 'JC-2026-1042',
          customerName: 'Rashid Al Nuaimi',
          vehicleInfo: '2024 Toyota Land Cruiser',
          workItems: [
            'Inspect front brake pads',
            'Torque wheel lug nuts to spec',
          ],
        ),
      ),
      const Size(390, 844),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(QcChecklistSheet),
      matchesGoldenFile('goldens/supervisor_qc_390_en.png'),
    );
  });

  testWidgets('supervisor qc sheet 390 ar', (tester) async {
    await _pump(
      tester,
      const Pad(
        child: QcChecklistSheet(
          jobCardId: 1042,
          jobCardRef: 'JC-2026-1042',
          customerName: 'Rashid Al Nuaimi',
          vehicleInfo: '2024 Toyota Land Cruiser',
          workItems: [
            'Inspect front brake pads',
            'Torque wheel lug nuts to spec',
          ],
        ),
      ),
      const Size(390, 844),
      const Locale('ar'),
      dark: false,
    );
    await expectLater(
      find.byType(QcChecklistSheet),
      matchesGoldenFile('goldens/supervisor_qc_390_ar.png'),
    );
  });

  // ── Floor board (the signature surface) ──────────────────────────────
  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('supervisor floor 390 $label', (tester) async {
      await _pump(
        tester,
        SupervisorDashboardTab(
          onOpenAssign: () {},
          onOpenQueue: () {},
          onOpenReview: () {},
        ),
        const Size(390, 844),
        locale,
        dark: false,
      );
      await expectLater(
        find.byType(SupervisorDashboardTab),
        matchesGoldenFile('goldens/supervisor_floor_390_$label.png'),
      );
    });
  }

  testWidgets('supervisor floor 1280 en', (tester) async {
    await _pump(
      tester,
      SupervisorDashboardTab(
        onOpenAssign: () {},
        onOpenQueue: () {},
        onOpenReview: () {},
      ),
      const Size(1280, 900),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorDashboardTab),
      matchesGoldenFile('goldens/supervisor_floor_1280_en.png'),
    );
  });

  testWidgets('supervisor floor 390 dark spot', (tester) async {
    await _pump(
      tester,
      SupervisorDashboardTab(
        onOpenAssign: () {},
        onOpenQueue: () {},
        onOpenReview: () {},
      ),
      const Size(390, 844),
      const Locale('en'),
      dark: true,
    );
    await expectLater(
      find.byType(SupervisorDashboardTab),
      matchesGoldenFile('goldens/supervisor_floor_390_dark.png'),
    );
  });

  // ── Schedule matrix ────────────────────────────────────────────────
  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('supervisor schedule 390 $label', (tester) async {
      await _pump(
        tester,
        SupervisorScheduleTab(onOpenQueue: () {}),
        const Size(390, 844),
        locale,
        dark: false,
      );
      await expectLater(
        find.byType(SupervisorScheduleTab),
        matchesGoldenFile('goldens/supervisor_schedule_390_$label.png'),
      );
    });
  }

  // ── Second axis per surface: 1280 EN + 390 AR + 390 dark ──────────
  testWidgets('supervisor queue 1280 en', (tester) async {
    await _pump(
      tester,
      SupervisorQueueTab(onOpenReview: () {}),
      const Size(1280, 900),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorQueueTab),
      matchesGoldenFile('goldens/supervisor_queue_1280_en.png'),
    );
  });

  testWidgets('supervisor queue 390 ar', (tester) async {
    await _pump(
      tester,
      SupervisorQueueTab(onOpenReview: () {}),
      const Size(390, 844),
      const Locale('ar'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorQueueTab),
      matchesGoldenFile('goldens/supervisor_queue_390_ar.png'),
    );
  });

  testWidgets('supervisor queue 390 dark spot', (tester) async {
    await _pump(
      tester,
      SupervisorQueueTab(onOpenReview: () {}),
      const Size(390, 844),
      const Locale('en'),
      dark: true,
    );
    await expectLater(
      find.byType(SupervisorQueueTab),
      matchesGoldenFile('goldens/supervisor_queue_390_dark.png'),
    );
  });

  testWidgets('supervisor review 1280 en', (tester) async {
    await _pump(
      tester,
      const SupervisorReviewTab(),
      const Size(1280, 900),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorReviewTab),
      matchesGoldenFile('goldens/supervisor_review_1280_en.png'),
    );
  });

  testWidgets('supervisor review 390 dark spot', (tester) async {
    await _pump(
      tester,
      const SupervisorReviewTab(),
      const Size(390, 844),
      const Locale('en'),
      dark: true,
    );
    await expectLater(
      find.byType(SupervisorReviewTab),
      matchesGoldenFile('goldens/supervisor_review_390_dark.png'),
    );
  });

  testWidgets('supervisor reports 1280 en', (tester) async {
    await _pump(
      tester,
      const SupervisorReportsTab(),
      const Size(1280, 900),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorReportsTab),
      matchesGoldenFile('goldens/supervisor_reports_1280_en.png'),
    );
  });

  testWidgets('supervisor assign sheet 390 ar', (tester) async {
    await _pump(
      tester,
      const Pad(child: SupervisorAssignSheet()),
      const Size(390, 844),
      const Locale('ar'),
      dark: false,
    );
    await expectLater(
      find.byType(SupervisorAssignSheet),
      matchesGoldenFile('goldens/supervisor_assign_390_ar.png'),
    );
  });
}

class Pad extends StatelessWidget {
  final Widget child;
  const Pad({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppDimensions.s16),
    child: child,
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child,
  Size size,
  Locale locale, {
  required bool dark,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supervisorDashboardProvider.overrideWith(_VisualNotifier.new),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: StaffLocalizations.supportedLocales,
        localizationsDelegates: _delegates,
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: Scaffold(body: child),
      ),
    ),
  );
  await _settle(tester);
}

class _VisualNotifier extends SupervisorDashboardNotifier {
  @override
  SupervisorDashboardState build() {
    return SupervisorDashboardState(
      isDashboardLoading: false,
      isQueueLoading: false,
      isReviewLoading: false,
      assignmentRows: [
        const WorkAssignmentEntity(id: 1, description: 'Brake service'),
      ],
    );
  }

  @override
  List<String> get technicians => const ['Alex Morgan', 'Sam Rivera'];

  @override
  List<String> get departments => const ['Mechanical', 'Diagnostics'];

  @override
  List<AssignableStaffResponse> get advisors => const [
    AssignableStaffResponse(id: 101, name: 'Zaid Khan', role: 'Advisor'),
    AssignableStaffResponse(id: 102, name: 'Maya Chen', role: 'Advisor'),
  ];

  @override
  List<BookingQueueResponse> get bookings => const [
    BookingQueueResponse(
      id: 1,
      customerName: 'Fatima Al Mansoori',
      vehicleName: 'Lexus LX 600',
      plateNumber: 'DXB B 1042',
      bookingDate: '2026-09-18 10:00 AM',
      serviceType: 'Engine Oil & Filter Service',
      status: 'pending',
    ),
    BookingQueueResponse(
      id: 2,
      customerName: 'Sultan Al Qasimi',
      vehicleName: 'Toyota Land Cruiser',
      plateNumber: 'SHJ K 889',
      bookingDate: '2026-09-18 11:30 AM',
      serviceType: 'Insurance body repair',
      status: 'confirmed',
    ),
  ];

  @override
  List<BreakdownQueueResponse> get breakdowns => const [
    BreakdownQueueResponse(
      id: 1,
      customerName: 'Omar Farooq',
      vehicleName: 'Nissan Patrol',
      vehiclePlate: 'DXB Z 772',
      issue: 'Engine overheating on highway',
      location: 'Sheikh Zayed Rd, Exit 42',
      status: 'pending',
    ),
  ];

  @override
  List<AssignedJobEntity> get jobs => const [
    AssignedJobEntity(
      jobCard: 'JC-2026-1042',
      customer: 'Rashid Al Nuaimi',
      vehicle: 'Toyota Land Cruiser',
      status: 'In Progress',
      dateAssigned: '17 Sep',
      done: 2,
      total: 3,
    ),
    AssignedJobEntity(
      jobCard: 'JC-2026-1048',
      customer: 'Sara Al Humaidan',
      vehicle: 'Lexus RX 350',
      status: 'Waiting for parts',
      dateAssigned: '17 Sep',
      done: 1,
      total: 4,
    ),
  ];

  @override
  List<AwaitingCompletionResponse> get awaitingCompletions => const [
    AwaitingCompletionResponse(
      jobCardId: 1042,
      jobCardRef: 'JC-2026-1042',
      customerName: 'Rashid Al Nuaimi',
      vehicleInfo: '2024 Toyota Land Cruiser',
      technician: 'Alex Morgan',
      done: 2,
      total: 2,
      items: [
        WorkItemDetail(id: 1, description: 'Inspect front brake pads'),
        WorkItemDetail(id: 2, description: 'Torque wheel lug nuts to spec'),
      ],
    ),
  ];

  @override
  List<AdvisorJobEntity> get advisorJobData => const [
    AdvisorJobEntity(name: 'Zaid Khan', count: 3),
    AdvisorJobEntity(name: 'Maya Chen', count: 2),
  ];

  @override
  List<JobTypeEntity> get jobTypes => const [
    JobTypeEntity(label: 'Periodic Maintenance', count: 8, color: Colors.blue),
    JobTypeEntity(label: 'Brakes & Suspension', count: 5, color: Colors.amber),
  ];

  @override
  List<RevenueMetricEntity> get revenueMetrics => const [
    RevenueMetricEntity(
      icon: Icons.receipt_rounded,
      amount: 'AED 12,450',
      label: 'Completed Work Orders',
      change: 'Today',
    ),
  ];

  @override
  int get totalAssigned => 16;

  @override
  int get inProgressCount => 10;

  @override
  int get completedCount => 6;

  @override
  List<StaffNotificationResponse> get notifications => const [];

  @override
  int get unreadNotifications => 0;
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
