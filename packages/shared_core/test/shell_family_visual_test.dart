import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader(AppFontFamilies.app)
      ..addFont(
        rootBundle.load(
          'assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
        ),
      );
    await loader.load();

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
  });

  testWidgets('role shells share one compact navigation language', (
    tester,
  ) async {
    await _expectShellFamilyGolden(
      tester,
      viewport: const Size(1600, 844),
      shellMediaSize: const Size(390, 844),
      fileName: 'goldens/shell_family_mobile.png',
    );
  });

  testWidgets('role shells share one rail navigation language', (tester) async {
    await _expectShellFamilyGolden(
      tester,
      viewport: const Size(1920, 900),
      shellMediaSize: const Size(1024, 900),
      fileName: 'goldens/shell_family_desktop.png',
    );
  });
}

Future<void> _expectShellFamilyGolden(
  WidgetTester tester, {
  required Size viewport,
  required Size shellMediaSize,
  required String fileName,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = viewport;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(BrandConfig.orient),
      home: _ShellFamilyShowcase(shellMediaSize: shellMediaSize),
    ),
  );
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(_ShellFamilyShowcase),
    matchesGoldenFile(fileName),
  );
}

class _ShellFamilyShowcase extends StatelessWidget {
  final Size shellMediaSize;

  const _ShellFamilyShowcase({required this.shellMediaSize});

  static const _roles = [
    ('Customer', ['Home', 'Status', 'Bookings', 'Vehicles', 'Profile']),
    ('Staff', ['Today', 'Jobs', 'Reports', 'Profile']),
    ('Owner', ['Overview', 'Operations', 'Finance', 'Profile']),
    ('CRM', ['Dashboard', 'Leads', 'Pipeline', 'Messages']),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final role in _roles)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.s6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusPanel,
                    ),
                    child: MediaQuery(
                      data: MediaQueryData(size: shellMediaSize),
                      child: _RoleShell(role: role.$1, labels: role.$2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleShell extends StatelessWidget {
  final String role;
  final List<String> labels;

  const _RoleShell({required this.role, required this.labels});

  @override
  Widget build(BuildContext context) {
    final items = [
      for (var index = 0; index < labels.length; index++)
        AppNavItem(
          selectedIcon: _icons[index].$1,
          icon: _icons[index].$2,
          label: labels[index],
        ),
    ];
    final useRail = context.adaptive.useNavigationRail;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role),
            Text(
              'Orient Workshop',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: const [
          NotificationBell(),
          SizedBox(width: AppDimensions.s8),
        ],
      ),
      body: AppAdaptiveNavigationFrame(
        items: items,
        selectedIndex: 0,
        onSelected: (_) {},
        child: AppResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                eyebrow: '$role workspace',
                title: labels.first,
                subtitle: 'Priority work and recent activity in one calm view.',
              ),
              const SizedBox(height: AppDimensions.s20),
              const AppRecordRow(
                title: 'Action required',
                subtitle: 'One workshop item needs review',
                metadata: StatusPill(label: 'Open', showDot: true),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: useRail
          ? null
          : AppBottomNavigation(
              items: items,
              selectedIndex: 0,
              onSelected: (_) {},
            ),
    );
  }
}

const _icons = [
  (Icons.home_rounded, Icons.home_outlined),
  (Icons.work_rounded, Icons.work_outline_rounded),
  (Icons.insights_rounded, Icons.insights_outlined),
  (Icons.person_rounded, Icons.person_outline_rounded),
  (Icons.directions_car_rounded, Icons.directions_car_outlined),
];
