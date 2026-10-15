import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

/// Phase 07.1 migration tests — customer_app.
///
/// Proves the bespoke bars/skeletons/headers are gone (source scan) and the
/// value-object adoptions are byte-identical to the code they replace.
/// Render evidence for the ten rewired screens comes from the existing suite,
/// which passes identically to baseline (see REPORT_PHASE_07_1.md §7).
void main() {
  group('Phase 07.1 source scan (no deleted primitives remain)', () {
    test('deleted bars, skeletons, headers and cards have zero references',
        () {
      const deleted = [
        'CustomerBookingsSkeleton',
        'CustomerHomeSkeleton',
        'CustomerStatusSkeleton',
        'CustomerEmptyStateCard',
        'EmptyVehiclesCard',
        'EmptyBookingsCard',
        'EmptyInvoicesCard',
        'CustomerBookingProgress',
        '_StepHeading',
        '_BookingsSectionHeader',
        '_DetailSkeleton',
        '_StepSkeleton',
        '_ProfileSkeleton',
        '_VehiclesSkeleton',
        '_NotificationsSkeleton',
      ];
      final offenders = <String>[];
      final dir = Directory('lib');
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = _stripComments(entity.readAsStringSync());
        for (final name in deleted) {
          if (RegExp('\\b$name\\b').hasMatch(source)) {
            offenders.add('${entity.path} :: $name');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'Deleted Phase 07.1 duplicates still referenced:\n'
            '${offenders.join('\n')}',
      );
    });

    test('no bespoke skeleton engine or bars remain in lib/', () {
      final offenders = <String>[];
      final patterns = {
        'CustomerSkeleton(': 'bespoke shimmer engine',
        'CustomerSkeletonBox': 'bespoke shimmer box',
        'AppTopBar(': 'deprecated bar',
        'CustomerTopBar': 'deprecated bar',
        'GradientBanner': 'deprecated banner',
      };
      final dir = Directory('lib');
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = _stripComments(entity.readAsStringSync());
        patterns.forEach((pattern, what) {
          if (source.contains(pattern)) {
            offenders.add('${entity.path} :: $what ($pattern)');
          }
        });
      }
      expect(
        offenders,
        isEmpty,
        reason: 'Bespoke engine/bar usage remains:\n${offenders.join('\n')}',
      );
    });
  });

  group('Value-object adoption equivalence', () {
    test('Vin().format() is byte-identical to trim().toUpperCase()', () {
      const samples = [
        'wdbjf65j1yb040901',
        '  WDBJF65J1YB040901  ',
        '',
        'short',
        'WDBJF65J1YB0409I1',
      ];
      for (final raw in samples) {
        expect(
          Vin(raw).format(),
          raw.trim().toUpperCase(),
          reason: 'VIN normalization diverged for "$raw"',
        );
      }
    });

    test('Vin validation accepts only 17-char ISO 3779', () {
      expect(Vin.tryParse('WDBJF65J1YB040901')?.format(),
          'WDBJF65J1YB040901');
      expect(Vin.tryParse('short'), isNull);
      expect(Vin.tryParse('WDBJF65J1YB0409I1'), isNull);
      expect(Vin.tryParse('WDBJF65J1YB0409O1'), isNull);
      expect(Vin.tryParse('WDBJF65J1YB0409Q1'), isNull);
    });

    test('PhoneNumber.normalizeLoose matches the old tel: munging', () {
      // Old: replaceAll(RegExp(r'[^\d+]'), ''); new form prefixes '+'.
      expect(
        '+${PhoneNumber.normalizeLoose('+971501234567')}',
        '+971501234567',
      );
      expect(
        '+${PhoneNumber.normalizeLoose('050 123 4567')}',
        '+971501234567',
      );
      // Local format previously produced a broken tel: link; the value
      // object repairs it to full E.164 (documented behavior fix).
      expect(
        PhoneNumber.tryParse('0501234567')?.e164,
        '+971501234567',
      );
    });

    test('identifiers stay LTR', () {
      expect(Vin.isLtr, isTrue);
      expect(PhoneNumber.isLtr, isTrue);
      expect(PlateNumber.isLtr, isTrue);
    });
  });
}

String _stripComments(String source) {
  final withoutBlocks = source.replaceAll(
    RegExp(r'/\*.*?\*/', dotAll: true),
    '',
  );
  return withoutBlocks
      .split('\n')
      .map((line) {
        final index = line.indexOf('//');
        return index < 0 ? line : line.substring(0, index);
      })
      .join('\n');
}
