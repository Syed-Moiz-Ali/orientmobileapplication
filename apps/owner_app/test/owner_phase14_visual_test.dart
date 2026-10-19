import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/pages/job_status_view.dart';
import 'package:owner_app/features/dashboard/presentation/pages/pending_approvals_view.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/presentation/pages/job_card_detail_view.dart';
import 'package:owner_app/features/job_cards/presentation/pages/job_cards_list_view.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 14 — jobs & approvals visual references (EN/AR, 390 + 768 + 1280,
/// light + dark spots, real fonts), reviewed against the Phase 13 cockpit
/// sibling. Seeds are deterministic workshop fixtures. Regenerate with
/// `--update-goldens` only after visual review.
const _delegates = <LocalizationsDelegate<dynamic>>[
  OwnerLocalizations.delegate,
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

const _jobs = [
  JobCard(
    id: 'JC-1042',
    customerName: 'Ahmed Raza',
    vehicle: 'Toyota Camry',
    plateNumber: 'A 12345',
    services: ['Oil change', 'Brake pads', 'Wheel alignment'],
    technician: 'Sam',
    estCompletion: 'Today 5 PM',
    amount: 1250,
    status: JobCardStatus.inProgress,
  ),
  JobCard(
    id: 'JC-1049',
    customerName: 'Sara Nasser',
    vehicle: 'Nissan Patrol',
    plateNumber: 'B 67890',
    services: ['AC recharge'],
    technician: 'Alex',
    estCompletion: 'Tomorrow',
    amount: 2480.5,
    status: JobCardStatus.waitingParts,
  ),
  JobCard(
    id: 'JC-1057',
    customerName: 'Omar Farooq',
    vehicle: 'Honda Accord',
    plateNumber: 'C 11223',
    services: ['60,000 km major service'],
    technician: 'Ravi',
    estCompletion: 'Friday',
    amount: 3690,
    status: JobCardStatus.qualityCheck,
  ),
  JobCard(
    id: 'JC-1063',
    customerName: 'Layla Hassan',
    vehicle: 'Kia Sportage',
    plateNumber: 'D 44556',
    services: ['Transmission flush'],
    technician: 'Omar',
    estCompletion: 'Delivered',
    amount: 5210.75,
    status: JobCardStatus.delivered,
  ),
];

class _SeededJobs extends JobCardsNotifier {
  @override
  JobCardsState build() => const JobCardsState(
        isLoading: false,
        all: _jobs,
        filtered: _jobs,
      );

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh() async {}
}

class _SeededStatus extends JobStatusNotifier {
  @override
  JobStatusState build() => JobStatusState(
        isLoading: false,
        items: const [
          JobStatus(
            jobCardId: 'JC-2001',
            customerName: 'Layla Hassan',
            vehicleInfo: 'Kia Sportage',
            assignedTo: 'Omar',
            createdDate: '2026-10-10',
            dueDate: '2026-10-19',
            stage: JobStage.wip,
            estimatedAmount: 2300,
          ),
          JobStatus(
            jobCardId: 'JC-2002',
            customerName: 'Yusuf Ali',
            vehicleInfo: 'Ford Explorer',
            assignedTo: 'Sara',
            createdDate: '2026-10-11',
            dueDate: '2026-10-20',
            stage: JobStage.waitingParts,
            estimatedAmount: 4100,
          ),
          JobStatus(
            jobCardId: 'JC-2003',
            customerName: 'Noor Ahmed',
            vehicleInfo: 'Hyundai Tucson',
            assignedTo: 'Ravi',
            createdDate: '2026-10-09',
            dueDate: '2026-10-18',
            stage: JobStage.completed,
            estimatedAmount: 1875.5,
          ),
        ],
      );
}

class _SeededApprovals extends PendingApprovalsNotifier {
  @override
  PendingApprovalsState build() => const PendingApprovalsState(
        isLoading: false,
        categories: [
          ApprovalCategory(
            title: 'Discounts above 15%',
            subtitle: 'Advisor discount requests',
            count: 3,
            iconBg: Color(0xFFFEF3C7),
            icon: Icons.percent_rounded,
          ),
          ApprovalCategory(
            title: 'Goodwill repairs',
            subtitle: 'Warranty gestures',
            count: 1,
            iconBg: Color(0xFFD1FAE5),
            icon: Icons.volunteer_activism_rounded,
          ),
          ApprovalCategory(
            title: 'Parts credit overrides',
            subtitle: 'Supplier credit notes',
            count: 0,
            iconBg: Color(0xFFE0E7FF),
            icon: Icons.receipt_long_rounded,
          ),
        ],
      );
}

List<Override> _overrides({JobCard? selected}) => [
      jobCardsProvider.overrideWith(_SeededJobs.new),
      jobStatusProvider.overrideWith(_SeededStatus.new),
      pendingApprovalsProvider.overrideWith(_SeededApprovals.new),
      if (selected != null)
        selectedJobCardProvider.overrideWith((ref) => selected),
    ];

Future<void> _pump(
  WidgetTester tester,
  Widget child,
  Size size,
  Locale locale, {
  required bool dark,
  JobCard? selected,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(selected: selected),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
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

void main() {
  setUpAll(_loadFonts);

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('register 390 $label', (tester) async {
      await _pump(
        tester,
        const JobCardsListView(),
        const Size(390, 844),
        locale,
        dark: false,
      );
      expect(find.text('Ahmed Raza'), findsOneWidget);
      await expectLater(
        find.byType(JobCardsListView),
        matchesGoldenFile('goldens/owner14_register_390_$label.png'),
      );
    });

    testWidgets('detail 390 $label', (tester) async {
      await _pump(
        tester,
        const JobCardDetailView(),
        const Size(390, 844),
        locale,
        dark: false,
        selected: _jobs[0],
      );
      expect(find.text('Ahmed Raza'), findsWidgets);
      await expectLater(
        find.byType(JobCardDetailView),
        matchesGoldenFile('goldens/owner14_detail_390_$label.png'),
      );
    });

    testWidgets('status 390 $label', (tester) async {
      await _pump(
        tester,
        const JobStatusView(),
        const Size(390, 844),
        locale,
        dark: false,
      );
      expect(find.text('Layla Hassan'), findsOneWidget);
      await expectLater(
        find.byType(JobStatusView),
        matchesGoldenFile('goldens/owner14_status_390_$label.png'),
      );
    });

    testWidgets('approvals 390 $label', (tester) async {
      await _pump(
        tester,
        const PendingApprovalsView(),
        const Size(390, 844),
        locale,
        dark: false,
      );
      expect(find.text('Discounts above 15%'), findsOneWidget);
      await expectLater(
        find.byType(PendingApprovalsView),
        matchesGoldenFile('goldens/owner14_approvals_390_$label.png'),
      );
    });
  }

  for (final (name, view, selected) in <(String, Widget, JobCard?)>[
    ('register', const JobCardsListView(), null),
    ('detail', const JobCardDetailView(), _jobs[0]),
    ('status', const JobStatusView(), null),
    ('approvals', const PendingApprovalsView(), null),
  ]) {
    testWidgets('$name 768 en tablet', (tester) async {
      await _pump(
        tester,
        view,
        const Size(768, 1024),
        const Locale('en'),
        dark: false,
        selected: selected,
      );
      await expectLater(
        find.byType(view.runtimeType),
        matchesGoldenFile('goldens/owner14_${name}_768_en.png'),
      );
    });

    testWidgets('$name 1280 en desktop', (tester) async {
      await _pump(
        tester,
        view,
        const Size(1280, 800),
        const Locale('en'),
        dark: false,
        selected: selected,
      );
      await expectLater(
        find.byType(view.runtimeType),
        matchesGoldenFile('goldens/owner14_${name}_1280_en.png'),
      );
    });

    testWidgets('$name 390 en dark spot', (tester) async {
      await _pump(
        tester,
        view,
        const Size(390, 844),
        const Locale('en'),
        dark: true,
        selected: selected,
      );
      await expectLater(
        find.byType(view.runtimeType),
        matchesGoldenFile('goldens/owner14_${name}_390_dark.png'),
      );
    });
  }
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
