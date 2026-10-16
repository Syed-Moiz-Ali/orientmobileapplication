import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';

/// Phase 11 — floor-board derivation (bay mutation) unit coverage.
///
/// The board is derived purely from frozen provider data, so it is verified
/// here without a backend: record placement order, state mapping, technician
/// initials (only when real) and idle fill.
void main() {
  group('buildSupervisorBays', () {
    final awaiting = [
      const AwaitingCompletionResponse(
        jobCardId: 1,
        jobCardRef: 'JC-1',
        customerName: 'A',
        vehicleInfo: 'Car A',
        technician: 'Alex Morgan',
        done: 2,
        total: 2,
      ),
    ];
    final jobs = [
      const AssignedJobEntity(
        jobCard: 'JC-2',
        customer: 'B',
        vehicle: 'Car B',
        status: 'In Progress',
        dateAssigned: '17 Sep',
        done: 1,
        total: 3,
      ),
      const AssignedJobEntity(
        jobCard: 'JC-3',
        customer: 'C',
        vehicle: 'Car C',
        status: 'Waiting for parts',
        dateAssigned: '17 Sep',
        done: 0,
        total: 2,
      ),
    ];
    final bookings = [
      const BookingQueueResponse(
        id: 9,
        bookingRef: 'BK-9',
        customerName: 'D',
        vehicleName: 'Car D',
        plateNumber: 'DXB A 1',
        serviceType: 'Oil',
        bookingDate: '2026-09-18 10:00 AM',
      ),
    ];

    test('always returns 16 bays', () {
      final bays = buildSupervisorBays(
        awaiting: awaiting,
        jobs: jobs,
        bookings: bookings,
      );
      expect(bays.length, kSupervisorBayCount);
      expect(bays.first.number, 1);
      expect(bays.last.number, 16);
    });

    test('places QC, then parts-delay, then occupied jobs, then bookings', () {
      final bays = buildSupervisorBays(
        awaiting: awaiting,
        jobs: jobs,
        bookings: bookings,
      );
      expect(bays[0].state, SupervisorBayState.qc);
      expect(bays[0].ref, 'JC-1');
      expect(bays[1].state, SupervisorBayState.occupied);
      expect(bays[1].ref, 'JC-2');
      expect(bays[2].state, SupervisorBayState.partsDelay);
      expect(bays[2].ref, 'JC-3');
      expect(bays[3].state, SupervisorBayState.occupied);
      expect(bays[3].ref, 'BK-9');
    });

    test('technician initials render only when the record carries one', () {
      final bays = buildSupervisorBays(
        awaiting: awaiting,
        jobs: jobs,
        bookings: bookings,
      );
      expect(bays[0].techInitials, 'AM'); // real QC technician
      expect(bays[1].techInitials, ''); // no technician on assigned jobs
      expect(bays[2].techInitials, '');
    });

    test('remaining bays are idle with no job', () {
      final bays = buildSupervisorBays(
        awaiting: awaiting,
        jobs: jobs,
        bookings: bookings,
      );
      for (var i = 4; i < bays.length; i++) {
        expect(bays[i].state, SupervisorBayState.idle);
        expect(bays[i].isIdle, isTrue);
        expect(bays[i].hasJob, isFalse);
      }
    });

    test('overflows beyond 16 bays safely (no crash, capped at 16)', () {
      final many = [
        for (var i = 0; i < 40; i++)
          AssignedJobEntity(
            jobCard: 'JC-$i',
            customer: 'C$i',
            vehicle: 'V$i',
            status: 'In Progress',
            dateAssigned: '',
            done: 0,
            total: 0,
          ),
      ];
      final bays = buildSupervisorBays(
        awaiting: const [],
        jobs: many,
        bookings: const [],
      );
      expect(bays.length, 16);
      expect(bays.every((b) => b.hasJob), isTrue);
    });
  });

  group('helpers', () {
    test('bayCode is LTR zero-padded', () {
      expect(bayCode(1), 'B-01');
      expect(bayCode(16), 'B-16');
    });

    test('initialsOf takes up to two words', () {
      expect(initialsOf('Alex Morgan'), 'AM');
      expect(initialsOf('Sam'), 'S');
      expect(initialsOf('  '), '');
    });

    test('status kind maps frozen strings', () {
      expect(supervisorStatusKind('Completed'), SupervisorStatusKind.success);
      expect(supervisorStatusKind('In Progress'), SupervisorStatusKind.inProgress);
      expect(supervisorStatusKind('Waiting for parts'), SupervisorStatusKind.warning);
      expect(supervisorStatusKind('Cancelled'), SupervisorStatusKind.danger);
      expect(supervisorStatusKind('New'), SupervisorStatusKind.neutral);
    });
  });

  group('queue priority derivation', () {
    final now = DateTime(2026, 9, 18, 12);

    test('vip / insurance / promised-today / normal', () {
      expect(
        bookingPriority(
          const BookingQueueResponse(notes: 'VIP customer'),
          now: now,
        ),
        SupervisorQueuePriority.vip,
      );
      expect(
        bookingPriority(
          const BookingQueueResponse(serviceType: 'Insurance repair'),
          now: now,
        ),
        SupervisorQueuePriority.insurance,
      );
      expect(
        bookingPriority(
          const BookingQueueResponse(bookingDate: '2026-09-18 10:00 AM'),
          now: now,
        ),
        SupervisorQueuePriority.promisedToday,
      );
      expect(
        bookingPriority(
          const BookingQueueResponse(bookingDate: '2026-09-20 10:00 AM'),
          now: now,
        ),
        SupervisorQueuePriority.normal,
      );
    });

    test('bookingIsToday uses dateKey when present', () {
      expect(
        bookingIsToday(
          const BookingQueueResponse(dateKey: '2026-09-18'),
          now: now,
        ),
        isTrue,
      );
      expect(
        bookingIsToday(
          const BookingQueueResponse(dateKey: '2026-09-19'),
          now: now,
        ),
        isFalse,
      );
    });

    test('priority rank orders vip first, normal last', () {
      expect(
        queuePriorityRank(SupervisorQueuePriority.vip) <
            queuePriorityRank(SupervisorQueuePriority.normal),
        isTrue,
      );
    });
  });
}
