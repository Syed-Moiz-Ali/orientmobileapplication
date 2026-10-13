import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_dashboard_page.dart';
import 'package:shared_core/shared_core.dart';

/// TEMPORARY Phase 01 evidence capture harness — state matrix (owner).
void main() {
  setUpAll(_loadFonts);

  testWidgets('capture owner_dashboard_390_loading', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardUiProvider.overrideWith(_LoadingNotifier.new),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient),
          home: const Scaffold(body: OwnerDashboardPage()),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(OwnerDashboardPage),
      matchesGoldenFile(
        '../../../phases/reports/PHASE_01/screens/'
        'owner_dashboard_390_loading.png',
      ),
    );
  });

  testWidgets('capture owner_dashboard_390_error', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardUiProvider.overrideWith(_ErrorNotifier.new),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient),
          home: const Scaffold(body: OwnerDashboardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(OwnerDashboardPage),
      matchesGoldenFile(
        '../../../phases/reports/PHASE_01/screens/'
        'owner_dashboard_390_error.png',
      ),
    );
  });
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

class _LoadingNotifier extends DashboardUiNotifier {
  @override
  DashboardUiState build() => const DashboardUiState(isLoading: true);

  @override
  Future<void> refresh() async {}
}

class _ErrorNotifier extends DashboardUiNotifier {
  @override
  DashboardUiState build() => const DashboardUiState(
    errorMessage: 'Dashboard data could not be loaded. Pull to retry.',
  );

  @override
  Future<void> refresh() async {}

  @override
  List<OwnerKpi> get kpis => const [];

  @override
  List<JobCardRegisterItem> get registerItems => const [];

  @override
  List<SalesTrendPoint> get salesTrend => const [];

  @override
  List<SalesTrendPoint> get profitTrend => const [];

  @override
  List<SalesTrendPoint> get expensesTrend => const [];
}
