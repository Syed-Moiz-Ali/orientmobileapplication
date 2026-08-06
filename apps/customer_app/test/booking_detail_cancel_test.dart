import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_detail_view.dart';

void main() {
  const booking = CustomerBookingEntity(
    id: '42',
    service: 'Full Service',
    vehicleName: 'Toyota Camry',
    plateNumber: 'ABC-123',
    date: '10 Aug 2026',
    time: '10:00 AM',
    status: BookingStatus.pending,
  );

  Widget wrap() => const ProviderScope(
        child: MaterialApp(home: CustomerBookingDetailView(booking: booking)),
      );

  testWidgets('pending booking shows a Cancel Booking action',
      (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Booking Details'), findsOneWidget);
    final cancelBtn = find.text('Cancel Booking');
    expect(cancelBtn, findsOneWidget);

    // Tapping opens a confirmation dialog — no network call without confirm.
    await tester.ensureVisible(cancelBtn);
    await tester.pumpAndSettle();
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();
    expect(find.text('Cancel this booking?'), findsOneWidget);
    expect(find.text('Keep Booking'), findsOneWidget);
  });

  testWidgets('cancelled booking hides the cancel action', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CustomerBookingDetailView(
            booking: CustomerBookingEntity(
              id: '43',
              service: 'Oil Change',
              vehicleName: 'Honda Civic',
              plateNumber: 'DEF-456',
              date: '11 Aug 2026',
              time: '11:00 AM',
              status: BookingStatus.cancelled,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Cancelled'), findsWidgets);
    expect(find.text('Cancel Booking'), findsNothing);
  });
}
