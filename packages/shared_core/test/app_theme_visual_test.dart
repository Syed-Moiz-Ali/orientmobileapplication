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
  });

  testWidgets('theme foundation visual reference', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        home: const _ThemeFoundationShowcase(),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/theme_foundation_mobile.png'),
    );
  });
}

class _ThemeFoundationShowcase extends StatelessWidget {
  const _ThemeFoundationShowcase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Orient Workshop')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.s20),
        children: [
          Text('Design foundation', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppDimensions.s8),
          Text(
            'Calm, precise tools for every workshop role.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.s24),
          Wrap(
            spacing: AppDimensions.s8,
            runSpacing: AppDimensions.s8,
            children: [
              _Swatch('Primary', colors.primary),
              _Swatch('Success', AppColors.success),
              _Swatch('Warning', AppColors.warning),
              _Swatch('Error', colors.error),
            ],
          ),
          const SizedBox(height: AppDimensions.s24),
          Text('Job card', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppDimensions.s10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MH 12 AB 4582', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppDimensions.s4),
                  Text(
                    'Brake inspection · Ready for approval',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.s20),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Search customer or vehicle',
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          FilledButton(onPressed: _noop, child: const Text('Create job card')),
          const SizedBox(height: AppDimensions.s10),
          OutlinedButton(
            onPressed: _noop,
            child: const Text('View workshop queue'),
          ),
        ],
      ),
    );
  }

  static void _noop() {}
}

class _Swatch extends StatelessWidget {
  final String label;
  final Color color;

  const _Swatch(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            ),
          ),
          const SizedBox(height: AppDimensions.s6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
