import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_booking_relations.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_detail_service.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_detail_summary.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_detail_vehicle.dart';

/// The complete detailed representation of ONE booking: its workshop pass,
/// what it is, where it stands, and what the customer can legitimately do
/// with it.
///
/// It is a summary of the booking, not a second tracker — the stage-by-stage
/// service journey lives in the contextual Service Status page it links to.
/// Everything shown comes from real booking/active-service/approval state.
/// The add-to-calendar action opens the calendar the device already has via
/// a link (no new dependency); without a parseable appointment it says so.
class CustomerBookingDetailView extends ConsumerStatefulWidget {
  final CustomerBookingEntity booking;

  const CustomerBookingDetailView({super.key, required this.booking});

  @override
  ConsumerState<CustomerBookingDetailView> createState() =>
      _CustomerBookingDetailViewState();
}

class _CustomerBookingDetailViewState
    extends ConsumerState<CustomerBookingDetailView> {
  bool _cancelling = false;

  /// The booking the screen is showing, resolved from live provider state so
  /// the screen reflects changes (for example a cancellation) without losing
  /// the booking passed in through the route.
  CustomerBookingEntity get _currentBooking {
    final bookings =
        ref.read(customerBookingsProvider).valueOrNull ??
        const <CustomerBookingEntity>[];
    return _resolve(bookings) ?? widget.booking;
  }

  CustomerBookingEntity? _resolve(List<CustomerBookingEntity> bookings) {
    final requested = widget.booking;
    final id = requested.id.trim();
    if (id.isNotEmpty) {
      for (final booking in bookings) {
        if (booking.id.trim() == id) return booking;
      }
      return null;
    }
    final reference = CustomerBookingsPresentation.referenceOf(requested);
    if (reference.isEmpty) return null;
    for (final booking in bookings) {
      if (CustomerBookingsPresentation.referenceOf(booking) == reference) {
        return booking;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.cx;

    final bookings =
        ref.watch(customerBookingsProvider).valueOrNull ??
        const <CustomerBookingEntity>[];
    final booking = _resolve(bookings) ?? widget.booking;
    final dash = ref.watch(customerDashboardProvider);
    final approvals =
        ref.watch(customerApprovalsProvider).valueOrNull ??
        const <CustomerApprovalSummaryResponse>[];

    // Related records are only used when they can be matched reliably.
    final vehicle = CustomerBookingRelations.vehicleFor(booking, dash.vehicles);
    final approval = CustomerBookingRelations.approvalFor(booking, approvals);
    final liveService = _liveServiceFor(booking, dash.activeService);
    final trackable = liveService != null;
    final approvalPending = CustomerBookingRelations.needsApproval(
      booking,
      approval,
    );
    final estimateId = booking.estimateId.trim();

    // Existing client-side rule: only a booking that has not reached the
    // workshop can be cancelled from the app.
    final cancellable =
        booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed;

    final primary = <Widget>[
      CustomerBookingDetailSummary(booking: booking),
      const SizedBox(height: AppDimensions.s16),
      OutlinedButton.icon(
        onPressed: () => _addToCalendar(booking),
        icon: const Icon(Icons.calendar_month_outlined, size: 18),
        label: Text(t.bkdAddCalendar),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppDimensions.touchTarget),
        ),
      ),
      if (trackable || approvalPending) ...[
        const SizedBox(height: AppDimensions.s16),
        CustomerBookingDetailService(
          booking: booking,
          liveService: liveService,
          approvalPending: approvalPending,
          approvalMessage: _approvalMessage(context, booking, approval, dash),
          onReviewEstimate: () =>
              context.go(AppRoutes.approvalsLocation(estimateId: estimateId)),
          onTrackService: () => context.push(AppRoutes.customerServiceStatus),
        ),
      ],
    ];

    final secondary = <Widget>[
      if (CustomerBookingDetailVehicle.hasDetails(vehicle)) ...[
        CustomerBookingDetailVehicle(booking: booking, vehicle: vehicle!),
        const SizedBox(height: AppDimensions.s16),
      ],
      if (cancellable)
        _CancelBookingAction(
          cancelling: _cancelling,
          onPressed: _confirmCancel,
        ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Phase 07.1: bespoke AppTopBar migrated to the shared workspace bar
      // (same title + back behavior; divider now drawn by the bar itself).
      appBar: WorkspaceAppBar(title: t.bkdTitle, showBack: true),
      body: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        // Records share the wider canvas as two coherent columns; a
        // single narrow phone column would waste desktop space.
        maxContentWidth: 1040,
        child: AppSplitView(
          primaryFlex: 3,
          secondaryFlex: 2,
          spacing: AppDimensions.s24,
          primary: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: primary,
          ),
          secondary: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: secondary,
          ),
        ),
      ),
    );
  }

  String _approvalMessage(
    BuildContext context,
    CustomerBookingEntity booking,
    CustomerApprovalSummaryResponse? approval,
    CustomerDashboardState dash,
  ) {
    final amount = CustomerBookingRelations.estimateAmount(booking, approval);
    // Same estimate line the bookings tab shows: one product voice.
    if (amount == null) return context.cx.bkdApprovalTitle;
    return context.cx.bkApprovalEst(dash.formatAmount(amount));
  }

  /// Opens the device calendar with the real appointment filled in. The
  /// calendar holds the event for one hour as a scheduling block; the
  /// booking itself carries no duration, so none is claimed.
  Future<void> _addToCalendar(CustomerBookingEntity booking) async {
    final start = CustomerBookingsPresentation.parseDateTime(
      booking.date,
      booking.time,
    );
    if (start == null) {
      _showMessage(context.cx.bkdCalendarFail);
      return;
    }
    String stamp(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}'
        '${d.month.toString().padLeft(2, '0')}'
        '${d.day.toString().padLeft(2, '0')}'
        'T'
        '${d.hour.toString().padLeft(2, '0')}'
        '${d.minute.toString().padLeft(2, '0')}'
        '00';
    final service = booking.service.trim();
    final reference = CustomerBookingsPresentation.referenceOf(booking);
    final details = [
      if (reference.isNotEmpty) reference,
      if (booking.plateNumber.trim().isNotEmpty) booking.plateNumber.trim(),
    ].join(' · ');
    final uri = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeComponent(service.isEmpty ? 'Service appointment' : service)}'
      '&dates=${stamp(start)}/${stamp(start.add(const Duration(hours: 1)))}'
      '&details=${Uri.encodeComponent(details)}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) _showMessage(context.cx.bkdCalendarFail);
  }

  /// The active workshop job, but only when it canonically belongs to this
  /// booking — otherwise the screen would describe another vehicle's service.
  CustomerServiceEntity? _liveServiceFor(
    CustomerBookingEntity booking,
    CustomerServiceEntity? activeService,
  ) {
    if (!CustomerServiceTracking.isLiveService(activeService)) return null;
    final service = activeService!;
    final owner = CustomerServiceTracking.bookingForJobCard([
      booking,
    ], service.jobCardId);
    return owner == null ? null : service;
  }

  Future<void> _confirmCancel() async {
    final t = context.cx;
    final booking = _currentBooking;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: t.bkdCancelTitle,
      message: _cancelMessage(booking),
      confirmLabel: t.bkdCancelCta,
      cancelLabel: t.bkdKeepCta,
      icon: Icons.cancel_outlined,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _cancelBooking(booking);
  }

  String _cancelMessage(CustomerBookingEntity booking) {
    final t = context.cx;
    final service = booking.service.trim();
    final schedule = CustomerBookingsPresentation.scheduleLabel(
      booking.date,
      booking.time,
    );
    final subject = service.isEmpty ? t.bkdServiceLabel : service;
    if (schedule.isEmpty) {
      return '$subject. ${t.bkdCancelBody}';
    }
    return '$subject · $schedule. ${t.bkdCancelBody}';
  }

  Future<void> _cancelBooking(CustomerBookingEntity booking) async {
    if (_cancelling || !mounted) return;

    final bookingId = int.tryParse(booking.id.trim()) ?? 0;
    if (bookingId <= 0) {
      // A booking without a usable id cannot be cancelled; report it the same
      // way as a failed request rather than sending a bogus id to the API.
      _showMessage(
        context.cx.bkdCancelFail,
        onRetry: () => _cancelBooking(booking),
      );
      return;
    }

    setState(() => _cancelling = true);

    var cancelled = false;
    try {
      cancelled = await ref
          .read(customerRemoteDataSourceProvider)
          .cancelBooking(bookingId);
    } catch (_) {
      // Never let a transport failure leave the screen stuck in a loading
      // state; the customer gets a friendly, retryable message instead.
      cancelled = false;
    }

    if (!mounted) return;
    setState(() => _cancelling = false);

    if (cancelled) {
      ref.invalidate(customerBookingsProvider);
      _showMessage(context.cx.bkdCancelled);
    } else {
      _showMessage(
        context.cx.bkdCancelFail,
        onRetry: () => _cancelBooking(booking),
      );
    }
  }

  void _showMessage(String message, {VoidCallback? onRetry}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: onRetry == null
            ? null
            : SnackBarAction(
                label: context.cx.bkdRetry,
                onPressed: onRetry,
              ),
      ),
    );
  }
}

/// Tertiary, restrained destructive action with an explicit in-flight state so
/// the request can never be submitted twice.
class _CancelBookingAction extends StatelessWidget {
  final bool cancelling;
  final VoidCallback onPressed;

  const _CancelBookingAction({
    required this.cancelling,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = context.cx;

    return Row(
      children: [
        TextButton.icon(
          onPressed: cancelling ? null : onPressed,
          icon: cancelling
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.error),
                  ),
                )
              : const Icon(Icons.cancel_outlined, size: 18),
          label: Text(cancelling ? t.bkdCancelling : t.bkdCancelCta),
          style: TextButton.styleFrom(
            foregroundColor: colors.error,
            disabledForegroundColor: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
