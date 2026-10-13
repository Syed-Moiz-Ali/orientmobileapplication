// Interaction verification: the six screens must be genuinely usable, not
// static pictures. Covers row drill-ins, search/filter, task state morphing,
// form validation + sticky save, auth method switching + OTP, and the map →
// finding-sheet flow.
import 'package:design_prototype/widgets/proto_vehicle_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'prototype_test_utils.dart';

void main() {
  group('D1 owner dashboard', () {
    testWidgets('register row opens the drill-in dialog', (tester) async {
      await pumpScreen(tester, ProtoScreen.ownerDashboard,
          variant: 'populated', size: const Size(1280, 800));
      await tester.tap(find.textContaining('Waiting Parts').first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('job cards'), findsWidgets);
      await tester.tap(find.text('Close'));
      await tester.pump(const Duration(milliseconds: 300));
      await disposeTree(tester);
    });

    testWidgets('period control changes the hero period chip', (tester) async {
      await pumpScreen(tester, ProtoScreen.ownerDashboard,
          variant: 'populated', size: const Size(1280, 800));
      // Top bar period button shows the current value; open and choose.
      await tester.tap(find.text('This Week').first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('This Month').last);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('This Month'), findsWidgets);
      await disposeTree(tester);
    });

    testWidgets('quick action opens the job cards prototype', (tester) async {
      await pumpScreen(tester, ProtoScreen.ownerDashboard,
          variant: 'populated', size: const Size(1280, 800));
      final tile = find.text('Job Cards').first;
      await tester.tap(tile);
      // Dashboard is standalone in the test (no shell callback wired) — the
      // tap must at least not crash and keep the dashboard alive.
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      await disposeTree(tester);
    });
  });

  group('D2 job cards listing', () {
    testWidgets('search filters the register by vehicle', (tester) async {
      await pumpScreen(tester, ProtoScreen.jobCards,
          variant: 'populated', size: const Size(768, 1024));
      expect(find.text('8 of 8 cards'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Nissan');
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('1 of 8 cards'), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets('filter chip filters by status', (tester) async {
      await pumpScreen(tester, ProtoScreen.jobCards,
          variant: 'populated', size: const Size(768, 1024));
      await tester.tap(find.text('Waiting Parts').first);
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('2 of 8 cards'), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets('row opens the detail sheet with actions', (tester) async {
      await pumpScreen(tester, ProtoScreen.jobCards,
          variant: 'populated', size: const Size(768, 1024));
      await tester.tap(find.text('Ahmed Al Mansoori').first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Job card'), findsOneWidget);
      expect(find.text('Mark as complete'), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets('no-match state offers a reset', (tester) async {
      await pumpScreen(tester, ProtoScreen.jobCards,
          variant: 'noMatch', size: const Size(390, 844));
      expect(find.textContaining('Nothing matches'), findsOneWidget);
      await tester.tap(find.text('Clear search & filter'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('8 of 8 cards'), findsOneWidget);
      await disposeTree(tester);
    });
  });

  group('D3 technician job detail', () {
    testWidgets('task state morphs pending → in progress → completed',
        (tester) async {
      await pumpScreen(tester, ProtoScreen.technicianJob,
          variant: 'active', size: const Size(768, 1024));

      // Fixture starts with 1 of 5 tasks completed.
      expect(find.text('CURRENT TASK'), findsOneWidget);
      expect(find.text('1 of 5 tasks completed'), findsOneWidget);

      await tester.tap(find.text('Complete task'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('2 of 5 tasks completed'), findsOneWidget);

      await tester.tap(find.text('Start next task'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Wheel alignment – front axle'), findsWidgets);
      await disposeTree(tester);
    });

    testWidgets('hold morphs the running task', (tester) async {
      await pumpScreen(tester, ProtoScreen.technicianJob,
          variant: 'active', size: const Size(768, 1024));
      await tester.tap(find.text('Hold').first);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Resume'), findsWidgets);
      await disposeTree(tester);
    });

    testWidgets('complete repair is gated by a confirmation and lands in QC',
        (tester) async {
      await pumpScreen(tester, ProtoScreen.technicianJob,
          variant: 'active', size: const Size(768, 1024));
      await tester.ensureVisible(find.text('Complete repair').first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Complete repair').first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Complete repair?'), findsOneWidget);
      await tester.tap(find.text('Complete repair').last);
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.textContaining('supervisor QC review'), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets('request part opens the support sheet', (tester) async {
      await pumpScreen(tester, ProtoScreen.technicianJob,
          variant: 'active', size: const Size(768, 1024));
      await tester.ensureVisible(find.text('Request part').first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Request part').first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Part name'), findsOneWidget);
      await tester.tap(find.text('Send request'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('will sync'), findsWidgets);
      await disposeTree(tester);
    });
  });

  group('D4 add vehicle form', () {
    testWidgets('validation shows inline required errors', (tester) async {
      await pumpScreen(tester, ProtoScreen.addVehicle,
          variant: 'pristine', size: const Size(390, 844));
      await tester.tap(find.text('Save vehicle'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Enter the registration plate'), findsOneWidget);
      expect(find.text('Enter the make of the vehicle'), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets('valid save runs the busy state and confirms', (tester) async {
      await pumpScreen(tester, ProtoScreen.addVehicle,
          variant: 'pristine', size: const Size(390, 844));
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'A 99999');
      await tester.enterText(fields.at(1), 'Nissan');
      await tester.enterText(fields.at(2), 'Patrol Safari');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Save vehicle'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Saving…'), findsWidgets);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.textContaining('Vehicle saved'), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets('Arabic validation copy renders in RTL', (tester) async {
      await pumpScreen(tester, ProtoScreen.addVehicle,
          variant: 'pristine',
          size: const Size(390, 844),
          locale: const Locale('ar'));
      await tester.tap(find.text('حفظ المركبة'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('أدخل رقم اللوحة'), findsOneWidget);
      await disposeTree(tester);
    });
  });

  group('D5 login', () {
    testWidgets('invalid credentials show the error notice', (tester) async {
      await pumpScreen(tester, ProtoScreen.login,
          variant: 'invalid', size: const Size(390, 844));
      expect(
        find.text('Those credentials did not match. Check them and try again.'),
        findsOneWidget,
      );
      await disposeTree(tester);
    });

    testWidgets('one-time-code flow sends and verifies a code', (tester) async {
      await pumpScreen(tester, ProtoScreen.login,
          variant: 'default', size: const Size(768, 1024));
      await tester.tap(find.text('One-time code'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Security code'), findsOneWidget);
      await tester.tap(find.text('Send code'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.textContaining('Code sent to'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '528914');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Verify code'));
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull);
      await disposeTree(tester);
    });

    testWidgets('password mode submits into the loading CTA', (tester) async {
      await pumpScreen(tester, ProtoScreen.login,
          variant: 'default', size: const Size(768, 1024));
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 300));
      // Spinner replaces the label while the mutation runs.
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      await tester.pump(const Duration(milliseconds: 1200));
      await disposeTree(tester);
    });
  });

  group('D6 inspection', () {
    testWidgets('checkpoint rating toggles and updates progress',
        (tester) async {
      await pumpScreen(tester, ProtoScreen.inspection,
          variant: 'partial', size: const Size(768, 1024));
      // Subtitle + workflow progress label both carry this copy.
      expect(find.textContaining('11 of 26 checkpoints evaluated'), findsWidgets);
      // Body map is the default section; switch to the first checkpoint list.
      await tester.tap(find.textContaining('Interior / Exterior').first);
      await tester.pump(const Duration(milliseconds: 300));
      final good = find.text('Good').first;
      await tester.ensureVisible(good);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(good);
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.textContaining('10 of 26 checkpoints evaluated'), findsWidgets);
      await disposeTree(tester);
    });

    testWidgets('section rail switches the checkpoint list', (tester) async {
      await pumpScreen(tester, ProtoScreen.inspection,
          variant: 'partial', size: const Size(768, 1024));
      await tester.tap(find.textContaining('Under Vehicle').first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Shock Absorbers / Suspension'), findsWidgets);
      await disposeTree(tester);
    });

    testWidgets('tapping the vehicle map opens the finding sheet',
        (tester) async {
      await pumpScreen(tester, ProtoScreen.inspection,
          variant: 'partial', size: const Size(1280, 800));
      final found = await pumpUntilFound(tester, find.byType(ProtoVehicleMap), maxFrames: 80);
      expect(found, isTrue);

      final map = find.byType(ProtoVehicleMap).first;
      final topLeft = tester.getTopLeft(map);
      final size = tester.getSize(map);

      // Try a few known physical areas of the sedan until the sheet opens.
      var opened = false;
      for (final fraction in const [Offset(0.5, 0.06), Offset(0.5, 0.5), Offset(0.5, 0.95), Offset(0.15, 0.5)]) {
        await tester.tapAt(topLeft + Offset(size.width * fraction.dx, size.height * fraction.dy));
        await tester.pump(const Duration(milliseconds: 400));
        if (find.text('Damage finding').evaluate().isNotEmpty) {
          opened = true;
          break;
        }
      }
      expect(opened, isTrue, reason: 'no map part accepted the tap');
      expect(find.text('Save finding'), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets('review footer opens the preview summary dialog',
        (tester) async {
      await pumpScreen(tester, ProtoScreen.inspection,
          variant: 'partial', size: const Size(768, 1024));
      await tester.tap(find.text('Review inspection'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Inspection ready for preview'), findsOneWidget);
      await disposeTree(tester);
    });
  });
}
