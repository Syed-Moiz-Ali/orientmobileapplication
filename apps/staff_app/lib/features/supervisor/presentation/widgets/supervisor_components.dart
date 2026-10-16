import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';

/// Shared presentation vocabulary for the supervisor workspace (Phase 11).
///
/// Everything here is presentation-only: it maps the frozen provider data
/// (bookings / breakdowns / assigned jobs / awaiting completions / roster)
/// into the visual state the floor board and rows need. No API shape, no
/// provider state and no payload is read or written — the bay board is a
/// deterministic derivation, so it is unit-testable without a backend.

// ─── BAY MODEL ───────────────────────────────────────────────────────────────

/// Physical state of a workshop bay for the floor board.
///
/// Mirrors the four states the supervisor console must surface: an active
/// repair, an idle bay, a repair held for parts and a bay sitting in QC.
enum SupervisorBayState { occupied, partsDelay, qc, idle }

/// One bay tile's derived presentation data.
@immutable
class SupervisorBay {
  /// 1-based bay number (rendered as a Latin, LTR `B-01` identifier).
  final int number;
  final SupervisorBayState state;

  /// Job card / booking identifier when the bay is in use (`''` when idle).
  final String ref;

  /// Primary tile line — vehicle identity or service type.
  final String title;

  /// Secondary tile line — customer or plate.
  final String subtitle;

  /// Technician initials — only when a real technician is known for the job.
  final String techInitials;

  /// Real, non-fabricated meta (date assigned / booking date / task progress).
  final String meta;

  /// Provider id used when the tile forwards a dispatch action.
  final int sourceId;

  const SupervisorBay({
    required this.number,
    required this.state,
    this.ref = '',
    this.title = '',
    this.subtitle = '',
    this.techInitials = '',
    this.meta = '',
    this.sourceId = 0,
  });

  bool get isIdle => state == SupervisorBayState.idle;
  bool get hasJob => state != SupervisorBayState.idle;
}

/// Number of physical bays in the workshop floor.
const int kSupervisorBayCount = 16;

/// Derives the 16-bay board from the frozen provider data, deterministically.
///
/// Order of priority for occupancy (only real records are placed):
/// 1. repairs awaiting QC (`awaitingCompletions`) → [SupervisorBayState.qc];
/// 2. assigned jobs whose status is held for parts / approval →
///    [SupervisorBayState.partsDelay];
/// 3. remaining assigned jobs → [SupervisorBayState.occupied];
/// 4. queued bookings → [SupervisorBayState.occupied].
///
/// Bays beyond the placed records stay [SupervisorBayState.idle]. Technician
/// initials render only when the record carries a technician (QC records do);
/// nothing is invented to fill the tile.
List<SupervisorBay> buildSupervisorBays({
  required List<AwaitingCompletionResponse> awaiting,
  required List<AssignedJobEntity> jobs,
  required List<BookingQueueResponse> bookings,
  List<AssignedJobEntity> extraJobs = const [],
  int bayCount = kSupervisorBayCount,
}) {
  final allJobs = <AssignedJobEntity>[...jobs, ...extraJobs];
  final entries = <SupervisorBay>[];
  var number = 1;

  bool heldForParts(AssignedJobEntity job) {
    final s = job.status.toLowerCase();
    return s.contains('part') ||
        s.contains('waiting') ||
        s.contains('hold') ||
        s.contains('approval');
  }

  for (final a in awaiting) {
    entries.add(
      SupervisorBay(
        number: number++,
        state: SupervisorBayState.qc,
        ref: a.jobCardRef.isNotEmpty ? a.jobCardRef : '${a.jobCardId}',
        title: a.vehicleInfo.isNotEmpty ? a.vehicleInfo : a.customerName,
        subtitle: a.customerName,
        techInitials: initialsOf(a.technician),
        meta: a.total > 0 ? '${a.done}/${a.total}' : a.updatedAt,
        sourceId: a.jobCardId,
      ),
    );
  }

  for (final j in allJobs) {
    entries.add(
      SupervisorBay(
        number: number++,
        state: heldForParts(j)
            ? SupervisorBayState.partsDelay
            : SupervisorBayState.occupied,
        ref: j.jobCard,
        title: j.vehicle.isNotEmpty ? j.vehicle : j.customer,
        subtitle: j.customer,
        meta: j.total > 0 ? '${j.done}/${j.total}' : j.dateAssigned,
      ),
    );
  }

  for (final b in bookings) {
    entries.add(
      SupervisorBay(
        number: number++,
        state: SupervisorBayState.occupied,
        ref: b.bookingRef.isNotEmpty
            ? b.bookingRef
            : (b.plateNumber.isNotEmpty ? b.plateNumber : b.serviceType),
        title: b.vehicleName.isNotEmpty ? b.vehicleName : b.serviceType,
        subtitle: b.plateNumber.isNotEmpty ? b.plateNumber : b.customerName,
        meta: _shortTime(b.bookingDate),
        sourceId: b.id,
      ),
    );
  }

  final bays = <SupervisorBay>[];
  for (var i = 0; i < bayCount; i++) {
    bays.add(
      i < entries.length
          ? entries[i]
          : SupervisorBay(number: i + 1, state: SupervisorBayState.idle),
    );
  }
  return bays;
}

/// First initials of up to two name words (`Alex Morgan` → `AM`).
String initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}

/// Latin, LTR tabular bay identifier (`1` → `B-01`).
String bayCode(int number) => 'B-${number.toString().padLeft(2, '0')}';

/// Keeps a booking's tile meta short (time only) so it never overflows the
/// narrow bay tile.
String _shortTime(String bookingDate) {
  final parts = bookingDate.trim().split(RegExp(r'\s+'));
  if (parts.length > 1) return parts.sublist(1).join(' ');
  return bookingDate.trim();
}

// ─── STATUS MAPPING ──────────────────────────────────────────────────────────

/// Classification of a raw (frozen) job status string into the five semantic
/// families. One place owns the rule so pills and rails never drift.
enum SupervisorStatusKind { success, inProgress, warning, danger, neutral }

SupervisorStatusKind supervisorStatusKind(String status) {
  final s = status.toLowerCase();
  if (s.contains('complete') || s.contains('done') || s.contains('deliver')) {
    return SupervisorStatusKind.success;
  }
  if (s.contains('progress') || s.contains('assigned')) {
    return SupervisorStatusKind.inProgress;
  }
  if (s.contains('part') ||
      s.contains('wait') ||
      s.contains('hold') ||
      s.contains('approval')) {
    return SupervisorStatusKind.warning;
  }
  if (s.contains('cancel') || s.contains('reject') || s.contains('fail')) {
    return SupervisorStatusKind.danger;
  }
  return SupervisorStatusKind.neutral;
}

/// Maps a raw (frozen) job status string to a shared [StatusPill].
StatusPill supervisorStatusPill(String status) => switch (
  supervisorStatusKind(status)
) {
  SupervisorStatusKind.success => StatusPill.success(status),
  SupervisorStatusKind.inProgress => StatusPill.inProgress(status),
  SupervisorStatusKind.warning => StatusPill.warning(status),
  SupervisorStatusKind.danger => StatusPill.danger(status),
  SupervisorStatusKind.neutral => StatusPill.neutral(status),
};

/// Resolves a raw job status string to its semantic status family (for rails,
/// dots and progress fills).
AppStatusColors supervisorStatusTone(BuildContext context, String status) {
  final sc = context.semanticColors;
  return switch (supervisorStatusKind(status)) {
    SupervisorStatusKind.success => sc.success,
    SupervisorStatusKind.inProgress => sc.info,
    SupervisorStatusKind.warning => sc.warning,
    SupervisorStatusKind.danger => sc.danger,
    SupervisorStatusKind.neutral => sc.neutral,
  };
}

/// Priority bucket for an incoming booking, derived from real record text.
enum SupervisorQueuePriority { vip, promisedToday, insurance, normal }

bool _contains(String haystack, String needle) =>
    haystack.toLowerCase().contains(needle);

/// Derives the priority bucket for a booking without inventing fields:
/// explicit `vip`, an insurance service line, or a booking promised today.
SupervisorQueuePriority bookingPriority(
  BookingQueueResponse booking, {
  DateTime? now,
}) {
  final text = '${booking.serviceType} ${booking.notes} ${booking.status}';
  if (_contains(text, 'vip')) return SupervisorQueuePriority.vip;
  if (_contains(text, 'insurance') || _contains(text, 'insur')) {
    return SupervisorQueuePriority.insurance;
  }
  if (bookingIsToday(booking, now: now)) {
    return SupervisorQueuePriority.promisedToday;
  }
  return SupervisorQueuePriority.normal;
}

/// True when a booking is promised for today (used by the priority bucket and
/// the schedule's today highlight).
bool bookingIsToday(BookingQueueResponse booking, {DateTime? now}) =>
    _isToday(booking.bookingDate, booking.dateKey, now: now);

bool _isToday(String bookingDate, String dateKey, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final candidate = dateKey.isNotEmpty
      ? dateKey
      : bookingDate.split(' ').first;
  final parsed = DateTime.tryParse(candidate);
  if (parsed == null) return false;
  return parsed.year == today.year &&
      parsed.month == today.month &&
      parsed.day == today.day;
}

/// Sort rank: lower ranks surface first (VIP → promised today → insurance →
/// normal). Stable within a rank so the server order is preserved.
int queuePriorityRank(SupervisorQueuePriority p) => switch (p) {
  SupervisorQueuePriority.vip => 0,
  SupervisorQueuePriority.promisedToday => 1,
  SupervisorQueuePriority.insurance => 2,
  SupervisorQueuePriority.normal => 3,
};

// ─── FEEDBACK ────────────────────────────────────────────────────────────────

/// Floating confirmation snackbar matching the advisor home grammar (tinted
/// plate + leading glyph + bold ink). Colour defaults to the primary fill;
/// pass a semantic family base for success / warning confirmations.
void showSupervisorToast(
  BuildContext context,
  String message, {
  IconData? icon,
  Color? color,
}) {
  final colors = Theme.of(context).colorScheme;
  final ink = context.semanticColors.onPrimary;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: ink, size: AppDimensions.iconSm),
            const SizedBox(width: AppDimensions.s8),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      backgroundColor: color ?? colors.primary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Bounded latin/mono styling helper for identifiers (plates, refs, times):
/// the caller wraps the text in `Directionality(LTR)`.
TextStyle supervisorMono(BuildContext context, {Color? color}) =>
    AppTextStyles.mono(color: color ?? context.colors.onSurface);

/// Resolves a bay state to its semantic status family (never a raw palette).
/// Occupied → active (success), parts delay → warning, QC → info, idle →
/// neutral. This is the single mapping the board, legend and detail pane share.
AppStatusColors supervisorBayTone(BuildContext context, SupervisorBayState s) {
  final sc = context.semanticColors;
  return switch (s) {
    SupervisorBayState.occupied => sc.operationalActive,
    SupervisorBayState.partsDelay => sc.warning,
    SupervisorBayState.qc => sc.info,
    SupervisorBayState.idle => sc.operationalIdle,
  };
}
