import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/providers/team_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/dashboard_body.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_activity_feed_tab.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 13 — owner cockpit visual references (EN/AR, 390 + 768 + 1280,
/// light + dark spots, real fonts). The owner app had no goldens before;
/// this is the first baseline, reviewed against the advisor house bar.
/// Regenerate with `--update-goldens` only after visual review.
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

const _kpis = [
  OwnerKpi(
    label: 'Active jobs',
    value: '24',
    icon: Icons.build_circle_outlined,
    state: KpiSemanticState.info,
    sub: '6 due today',
  ),
  OwnerKpi(
    label: 'Revenue',
    value: 'AED 84K',
    icon: Icons.payments_outlined,
    state: KpiSemanticState.success,
    sub: '+18.4% vs target',
  ),
  OwnerKpi(
    label: 'Gross margin',
    value: '44.2%',
    icon: Icons.trending_up_rounded,
    state: KpiSemanticState.success,
    sub: '+2.1% ahead',
  ),
  OwnerKpi(
    label: 'Floor occupancy',
    value: '88.5%',
    icon: Icons.warehouse_outlined,
    state: KpiSemanticState.info,
    sub: '14/16 bays active',
  ),
  OwnerKpi(
    label: 'Approvals',
    value: '7',
    icon: Icons.fact_check_outlined,
    state: KpiSemanticState.warning,
    sub: 'AED 18.4K due',
  ),
];

const _register = [
  JobCardRegisterItem(label: 'In progress', open: 12, completed: 4, total: 28),
  JobCardRegisterItem(
    label: 'Awaiting approval',
    open: 7,
    completed: 0,
    total: 9,
  ),
  JobCardRegisterItem(label: 'Quality check', open: 3, completed: 11, total: 14),
];

const _sales = [
  SalesTrendPoint('Jan', 42),
  SalesTrendPoint('Feb', 56),
  SalesTrendPoint('Mar', 61),
  SalesTrendPoint('Apr', 58),
  SalesTrendPoint('May', 72),
  SalesTrendPoint('Jun', 84),
];

const _profit = [
  SalesTrendPoint('Jan', 18),
  SalesTrendPoint('Feb', 24),
  SalesTrendPoint('Mar', 27),
  SalesTrendPoint('Apr', 25),
  SalesTrendPoint('May', 31),
  SalesTrendPoint('Jun', 38),
];

const _expenses = [
  SalesTrendPoint('Jan', 22),
  SalesTrendPoint('Feb', 26),
  SalesTrendPoint('Mar', 30),
  SalesTrendPoint('Apr', 29),
  SalesTrendPoint('May', 33),
  SalesTrendPoint('Jun', 36),
];

const _categories = [
  TopSalesCategory(
    title: 'Brake services',
    items: [
      TopSalesItem(sno: 1, description: 'Brake pad replacement', value: 'AED 12K'),
      TopSalesItem(sno: 2, description: 'Disc resurfacing', value: 'AED 4K'),
    ],
  ),
  TopSalesCategory(
    title: 'Scheduled maintenance',
    items: [
      TopSalesItem(sno: 1, description: '60,000 km major service', value: 'AED 21K'),
      TopSalesItem(sno: 2, description: 'Oil & filter change', value: 'AED 9K'),
    ],
  ),
];

class _FakeAuth extends AuthNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
        role: UserRole.owner,
        token: 'test_token',
        profile: null,
      );
}

class _SeededUi extends DashboardUiNotifier {
  final int tab;
  _SeededUi(this.tab);

  @override
  DashboardUiState build() => DashboardUiState(selectedIndex: tab);

  @override
  Future<void> refresh() async {}

  @override
  List<OwnerKpi> get kpis => _kpis;

  @override
  List<JobCardRegisterItem> get registerItems => _register;

  @override
  List<SalesTrendPoint> get salesTrend => _sales;

  @override
  List<SalesTrendPoint> get profitTrend => _profit;

  @override
  List<SalesTrendPoint> get expensesTrend => _expenses;

  @override
  List<TopSalesCategory> get topSalesCategories => _categories;
}

class _SeededTeam extends TeamNotifier {
  @override
  TeamState build() => const TeamState(
        isLoading: false,
        staff: [
          StaffMember(
            id: '1',
            empId: 'EMP-1',
            name: 'Sara Iqbal',
            role: 'Advisor',
            branch: 'Al Quoz',
            phone: '+971501234567',
            isActive: true,
          ),
          StaffMember(
            id: '2',
            empId: 'EMP-2',
            name: 'Ravi Menon',
            role: 'Technician',
            branch: 'Al Quoz',
            phone: '+971507654321',
            isActive: true,
          ),
        ],
      );
}

Future<void> _pumpTab(
  WidgetTester tester,
  int tab,
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
        dashboardUiProvider.overrideWith(() => _SeededUi(tab)),
        teamProvider.overrideWith(_SeededTeam.new),
        authNotifierProvider.overrideWith(_FakeAuth.new),
        ownerActivityFeedProvider.overrideWith((ref) async => [
              {
                'id': 'a1',
                'type': 'approval',
                'icon': 'fact_check',
                'color': '#D97706',
                'title': 'Job #9281 approved by customer',
                'description': 'Estimate LPO-1042 · AED 4,820',
                'timestamp': DateTime.now()
                    .subtract(const Duration(minutes: 5))
                    .toIso8601String(),
              },
              {
                'id': 'a2',
                'type': 'job',
                'icon': 'assignment',
                'color': '#1F6FEB',
                'title': 'Bay 4 QC passed',
                'description': 'JC-2091 · Toyota Land Cruiser',
                'timestamp': DateTime.now()
                    .subtract(const Duration(hours: 3))
                    .toIso8601String(),
              },
            ]),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: const DashboardBody(),
      ),
    ),
  );
  await _settle(tester);
}

void main() {
  setUpAll(_loadFonts);

  const tabs = <String>['cockpit', 'topsales', 'messages', 'activity'];
  for (var tab = 0; tab < tabs.length; tab++) {
    final name = tabs[tab];
    for (final (label, locale) in <(String, Locale)>[
      ('en', const Locale('en')),
      ('ar', const Locale('ar')),
    ]) {
      testWidgets('$name 390 $label', (tester) async {
        await _pumpTab(tester, tab, const Size(390, 844), locale, dark: false);
        await expectLater(
          find.byType(DashboardBody),
          matchesGoldenFile('goldens/owner13_${name}_390_$label.png'),
        );
      });
    }

    testWidgets('$name 768 en tablet', (tester) async {
      await _pumpTab(
        tester,
        tab,
        const Size(768, 1024),
        const Locale('en'),
        dark: false,
      );
      await expectLater(
        find.byType(DashboardBody),
        matchesGoldenFile('goldens/owner13_${name}_768_en.png'),
      );
    });

    testWidgets('$name 1280 en desktop', (tester) async {
      await _pumpTab(
        tester,
        tab,
        const Size(1280, 800),
        const Locale('en'),
        dark: false,
      );
      await expectLater(
        find.byType(DashboardBody),
        matchesGoldenFile('goldens/owner13_${name}_1280_en.png'),
      );
    });

    testWidgets('$name 390 en dark spot', (tester) async {
      await _pumpTab(
        tester,
        tab,
        const Size(390, 844),
        const Locale('en'),
        dark: true,
      );
      await expectLater(
        find.byType(DashboardBody),
        matchesGoldenFile('goldens/owner13_${name}_390_dark.png'),
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
