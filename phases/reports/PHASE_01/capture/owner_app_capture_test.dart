import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_dashboard_page.dart';
import 'package:shared_core/shared_core.dart';

/// TEMPORARY Phase 01 evidence capture harness (owner dashboard).
/// Run from `apps/owner_app`; PNGs land in `phases/reports/PHASE_01/screens/`.
void main() {
  setUpAll(_loadFonts);

  final cases = <String, _Case>{
    'owner_dashboard_390_light': _Case(const Size(390, 844), 1.0),
    'owner_dashboard_768_light': _Case(const Size(768, 1024), 1.0),
    'owner_dashboard_1280_light': _Case(const Size(1280, 800), 1.0),
    'owner_dashboard_320_light': _Case(const Size(320, 640), 1.0),
    'owner_dashboard_390_scale13': _Case(const Size(390, 844), 1.3),
    'owner_dashboard_390_dark': _Case(const Size(390, 844), 1.0, dark: true),
  };

  cases.forEach((name, c) {
    testWidgets('capture $name', (tester) async {
      tester.view.physicalSize = c.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardUiProvider.overrideWith(_FakeDashboardUiNotifier.new),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: c.dark
                ? AppTheme.dark(BrandConfig.orient)
                : AppTheme.light(BrandConfig.orient),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(c.scale)),
              child: child!,
            ),
            home: const Scaffold(body: OwnerDashboardPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(OwnerDashboardPage),
        matchesGoldenFile(
          '../../../phases/reports/PHASE_01/screens/$name.png',
        ),
      );
    });
  });
}

class _Case {
  final Size size;
  final double scale;
  final bool dark;
  const _Case(this.size, this.scale, {this.dark = false});
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

class _FakeDashboardUiNotifier extends DashboardUiNotifier {
  @override
  DashboardUiState build() => const DashboardUiState();

  @override
  Future<void> refresh() async {}

  @override
  List<OwnerKpi> get kpis => const [
    OwnerKpi(
      label: 'Active jobs',
      value: '24',
      icon: Icons.build_circle_outlined,
      color: Color(0xFF167C80),
      sub: '6 due today',
    ),
    OwnerKpi(
      label: 'Revenue',
      value: 'AED 84K',
      icon: Icons.payments_outlined,
      color: Color(0xFF1A8754),
      sub: 'This month',
    ),
    OwnerKpi(
      label: 'Receivables',
      value: 'AED 19K',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFB7791F),
      sub: '8 outstanding',
    ),
    OwnerKpi(
      label: 'Approvals',
      value: '7',
      icon: Icons.fact_check_outlined,
      color: Color(0xFF6746B8),
      sub: 'Needs attention',
    ),
  ];

  @override
  List<JobCardRegisterItem> get registerItems => const [
    JobCardRegisterItem(
      label: 'In progress',
      open: 12,
      completed: 4,
      total: 28,
    ),
    JobCardRegisterItem(
      label: 'Awaiting approval',
      open: 7,
      completed: 0,
      total: 9,
    ),
  ];

  @override
  List<SalesTrendPoint> get salesTrend => const [
    SalesTrendPoint('Jan', 42),
    SalesTrendPoint('Feb', 56),
    SalesTrendPoint('Mar', 61),
  ];

  @override
  List<SalesTrendPoint> get profitTrend => const [
    SalesTrendPoint('Jan', 18),
    SalesTrendPoint('Feb', 24),
    SalesTrendPoint('Mar', 27),
  ];

  @override
  List<SalesTrendPoint> get expensesTrend => const [
    SalesTrendPoint('Jan', 22),
    SalesTrendPoint('Feb', 26),
    SalesTrendPoint('Mar', 30),
  ];
}
