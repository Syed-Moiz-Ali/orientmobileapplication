import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void _noop() {}

void main() {
  setUpAll(() async {
    final loader = FontLoader(AppFontFamilies.app)
      ..addFont(
        rootBundle.load(
          'assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
        ),
      );
    await loader.load();
  });

  testWidgets('shared component mobile visual reference', (tester) async {
    await _expectGolden(
      tester,
      size: const Size(390, 844),
      fileName: 'goldens/shared_components_mobile.png',
    );
  });

  testWidgets('shared component tablet visual reference', (tester) async {
    await _expectGolden(
      tester,
      size: const Size(800, 900),
      fileName: 'goldens/shared_components_tablet.png',
    );
  });

  testWidgets('shared component desktop visual reference', (tester) async {
    await _expectGolden(
      tester,
      size: const Size(1440, 900),
      fileName: 'goldens/shared_components_desktop.png',
    );
  });
}

Future<void> _expectGolden(
  WidgetTester tester, {
  required Size size,
  required String fileName,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(BrandConfig.orient),
      home: const _ComponentShowcase(),
    ),
  );
  await tester.pumpAndSettle();

  await expectLater(find.byType(Scaffold), matchesGoldenFile(fileName));
}

class _ComponentShowcase extends StatefulWidget {
  const _ComponentShowcase();

  @override
  State<_ComponentShowcase> createState() => _ComponentShowcaseState();
}

class _ComponentShowcaseState extends State<_ComponentShowcase> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppResponsivePage(
        maxContentWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppPageHeader(
              eyebrow: 'Workshop queue',
              title: 'Jobs needing attention',
              subtitle:
                  'Prioritized by delay, approval status, and delivery time.',
            ),
            const SizedBox(height: AppDimensions.s24),
            const AppRecordRow(
              title: 'MH 12 AB 4582',
              subtitle: 'Brake inspection · Customer approval pending',
              metadata: StatusPill(
                label: 'Needs action',
                fg: AppColors.warning,
                bg: AppColors.warningBg,
                showDot: true,
              ),
            ),
            const SizedBox(height: AppDimensions.s12),
            AppTextField(
              controller: _noteController,
              label: 'Internal note',
              hint: 'Add context for the next shift',
              helperText: 'Visible to workshop staff only',
            ),
            const SizedBox(height: AppDimensions.s20),
            AppActionBar(
              primary: FilledButton(
                onPressed: _noop,
                child: const Text('Review approval'),
              ),
              secondary: const [
                OutlinedButton(
                  onPressed: _noop,
                  child: const Text('Open job card'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
