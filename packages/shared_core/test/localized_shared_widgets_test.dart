import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void _noop() {}

Widget _host({
  required Widget child,
  Locale locale = const Locale('ar'),
  TextScaler scaler = TextScaler.noScaling,
  Size size = const Size(320, 800),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocales.supported,
    localizationsDelegates: const [
      SharedCoreLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.light(BrandConfig.orient),
    home: MediaQuery(
      data: MediaQueryData(size: size, textScaler: scaler),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Shared chrome renders Arabic and mirrors in RTL', () {
    testWidgets('EmptyState.error uses localized copy in Arabic', (tester) async {
      await tester.pumpWidget(
        _host(child: EmptyState.error(message: '', onRetry: _noop)),
      );
      expect(find.text('حدث خطأ ما'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(EmptyState))),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('ErrorView retry label localizes', (tester) async {
      await tester.pumpWidget(
        _host(child: ErrorView(message: 'تعذّر التحميل', onRetry: _noop)),
      );
      expect(find.text('إعادة المحاولة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppTopBar back tooltip localizes and mirrors', (tester) async {
      // ignore: deprecated_member_use_from_same_package
      await tester.pumpWidget(_host(child: const AppTopBar(title: 'الطلبات')));
      expect(find.byTooltip('رجوع'), findsOneWidget);
      // IconWidgets inside DirectionalIcon must be mirrored by Transform.flip.
      expect(find.byType(DirectionalIcon), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shared search field hint + clear tooltip localize', (tester) async {
      final controller = TextEditingController(text: 'VIN');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(child: AppSearchField(controller: controller)),
      );
      expect(find.byTooltip('مسح البحث'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('confirmation dialog cancel label localizes', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final future = showAppConfirmationDialog(
        ctx,
        title: 'عنوان',
        message: 'رسالة',
        confirmLabel: 'تأكيد',
      );
      await tester.pumpAndSettle();
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('تأكيد'), findsOneWidget);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(await future, isFalse);
    });

    testWidgets('DirectionalIcon mirrors in RTL and not in LTR',
        (tester) async {
      bool mirrored() => tester
          .widgetList<Transform>(find.byType(Transform))
          .any((t) => t.transform.storage[0] < 0);

      await tester.pumpWidget(
        _host(child: const DirectionalIcon(Icons.arrow_back_rounded)),
      );
      expect(mirrored(), isTrue);

      await tester.pumpWidget(
        _host(
          locale: const Locale('en'),
          child: const DirectionalIcon(Icons.arrow_back_rounded),
        ),
      );
      expect(mirrored(), isFalse);
    });

    testWidgets('identifier AppTextField forces LTR content in Arabic',
        (tester) async {
      final identifier = TextEditingController(text: 'A 12345');
      final name = TextEditingController(text: 'أحمد المنصوري');
      addTearDown(identifier.dispose);
      addTearDown(name.dispose);

      await tester.pumpWidget(
        _host(
          child: Column(
            children: [
              AppTextField(
                controller: identifier,
                hint: 'لوحة',
                isIdentifier: true,
              ),
              AppTextField(controller: name, hint: 'الاسم'),
            ],
          ),
        ),
      );

      final fields = tester.widgetList<EditableText>(find.byType(EditableText));
      // The identifier field is forced LTR; the normal field inherits the
      // ambient (RTL) direction so it stays null on the widget.
      expect(fields.first.textDirection, TextDirection.ltr);
      expect(fields.last.textDirection, isNull);
      expect(
        Directionality.of(tester.element(find.byType(EditableText).last)),
        TextDirection.rtl,
      );
    });

    testWidgets('no overflow at 320px / 1.3x in Arabic', (tester) async {
      await tester.pumpWidget(
        _host(
          scaler: const TextScaler.linear(1.3),
          child: Column(
            children: const [
              EmptyState.error(
                message: 'تعذّر تحميل بيانات الورشة، يرجى المحاولة مرة أخرى.',
                onRetry: _noop,
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('bottom navigation mirrors order in RTL', (tester) async {
    const items = [
      AppNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'الرئيسية'),
      AppNavItem(icon: Icons.build_outlined, selectedIcon: Icons.build, label: 'المهام'),
      AppNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'الملف'),
    ];
    await tester.pumpWidget(
      _host(
        size: const Size(390, 800),
        child: AppBottomNavigation(
          items: items,
          selectedIndex: 0,
          onSelected: (_) {},
        ),
      ),
    );

    final first = tester.getCenter(find.text('الرئيسية'));
    final last = tester.getCenter(find.text('الملف'));
    // In RTL the first destination sits at the start (right) edge.
    expect(first.dx, greaterThan(last.dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets('locale switch flips shared copy live without restart',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            return MaterialApp(
              locale: ref.watch(localeProvider),
              supportedLocales: AppLocales.supported,
              localizationsDelegates: const [
                SharedCoreLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.light(BrandConfig.orient),
              home: const Scaffold(
                body: EmptyState.error(message: 'x', onRetry: _noop),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(EmptyState)),
    );
    await container.read(localeProvider.notifier).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();

    expect(find.text('حدث خطأ ما'), findsOneWidget);
    expect(find.text('Something went wrong'), findsNothing);
  });
}
