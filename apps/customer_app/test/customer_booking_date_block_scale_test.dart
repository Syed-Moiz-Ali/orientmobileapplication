// Presentation-only guard for the booking row date block.
//
// Defect (gating U5): `_DateBlock` used a fixed 60px width + `maxLines: 1`
// ellipsis, cutting schedule time to `9:00 …` at 1.3x (AM cut; 1.0x/320px
// full). Time is PRIMARY schedule text — it must render whole.
//
// Fix under test: the block widens with the text scaler and the time may wrap
// once at the token boundary (`9:00` / `AM`). Same date/time data, same
// predicates/routes — presentation only.
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_item.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

const _booking = CustomerBookingEntity(
  id: 'b2',
  service: 'Brake pads',
  vehicleName: 'Honda Civic',
  plateNumber: 'XYZ 5678',
  date: '10 Jun 2026',
  time: '09:00',
  status: BookingStatus.inProgress,
  jobCardId: 'JC-7',
  bookingRef: 'BK-1002',
);

Future<void> _pumpItem(
  WidgetTester tester, {
  double scale = 1.0,
  bool dark = false,
  Locale locale = const Locale('en'),
  double width = 360,
  double height = 800,
}) async {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        CustomerLocalizations.delegate,
        SharedCoreLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(BrandConfig.orient, locale: locale),
      darkTheme: AppTheme.dark(BrandConfig.orient, locale: locale),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: CustomerBookingItem(
          booking: _booking,
          formatAmount: (amount) => '${amount.toStringAsFixed(0)} AED',
          onOpen: () {},
          onTrackService: () {},
          onReviewApproval: (_) {},
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  group('date block scale-aware time (U5)', () {
    testWidgets('1.3x/360: full "9:00 AM" renders whole, no overflow',
        (tester) async {
      await _pumpItem(tester, scale: 1.3);
      expect(tester.takeException(), isNull);
      expect(find.text('9:00 AM'), findsOneWidget);
      // Regression pin: single-line ellipsis was the defect.
      final time = tester.widget<Text>(find.text('9:00 AM'));
      expect(time.maxLines, 2);
      expect(time.overflow, TextOverflow.ellipsis);
    });

    testWidgets('1.0x/320: time stays intact, no overflow', (tester) async {
      await _pumpItem(tester, width: 320, height: 568);
      expect(tester.takeException(), isNull);
      expect(find.text('9:00 AM'), findsOneWidget);
    });

    testWidgets('ar + dark: time intact, no overflow', (tester) async {
      await _pumpItem(
        tester,
        dark: true,
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('9:00 AM'), findsOneWidget);
    });

    testWidgets('1.3x/320: time intact, no overflow', (tester) async {
      await _pumpItem(tester, scale: 1.3, width: 320, height: 568);
      expect(tester.takeException(), isNull);
      expect(find.text('9:00 AM'), findsOneWidget);
    });
  });
}
