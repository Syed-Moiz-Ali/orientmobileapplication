import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_booking_relations.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_detail_service.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_detail_summary.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_detail_vehicle.dart';

/// The complete detailed representation of ONE booking: what it is, where it
/// stands, and what the customer can legitimately do with it.
///
/// It is a summary of the booking, not a second tracker â€” the stage-by-stage
/// service journey lives in the contextual Service Status page it links to.
/// Everything shown comes from real booking/active-service/approval state.
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
    final colors = theme.colorScheme;

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
      if (trackable || approvalPending) ...[
        const SizedBox(height: AppDimensions.s16),
        CustomerBookingDetailService(
          booking: booking,
          liveService: liveService,
          approvalPending: approvalPending,
          approvalMessage: _approvalMessage(booking, approval, dash),
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'Booking Details'),
            Divider(height: 1, color: colors.outlineVariant),
            Expanded(
              child: AppResponsivePage(
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
            ),
          ],
        ),
      ),
    );
  }

  String _approvalMessage(
    CustomerBookingEntity booking,
    CustomerApprovalSummaryResponse? approval,
    CustomerDashboardState dash,
  ) {
    final amount = CustomerBookingRelations.estimateAmount(booking, approval);
    if (amount == null) return 'Approval needed before work continues';
    return 'Estimate ${dash.formatAmount(amount)} awaiting approval';
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
    final booking = _currentBooking;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Cancel booking?',
      message: _cancelMessage(booking),
      confirmLabel: 'Cancel booking',
      cancelLabel: 'Keep booking',
      icon: Icons.cancel_outlined,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _cancelBooking(booking);
  }

  String _cancelMessage(CustomerBookingEntity booking) {
    final service = booking.service.trim();
    final schedule = CustomerBookingsPresentation.scheduleLabel(
      booking.date,
      booking.time,
    );
    final subject = service.isEmpty ? 'this appointment' : service;
    if (schedule.isEmpty) {
      return 'This will cancel your appointment for $subject. '
          'This cannot be undone.';
    }
    return 'This will cancel your appointment for $subject on $schedule. '
        'This cannot be undone.';
  }

  Future<void> _cancelBooking(CustomerBookingEntity booking) async {
    if (_cancelling || !mounted) return;

    final bookingId = int.tryParse(booking.id.trim()) ?? 0;
    if (bookingId <= 0) {
      // A booking without a usable id cannot be cancelled; report it the same
      // way as a failed request rather than sending a bogus id to the API.
      _showMessage(
        "We couldn't cancel this booking. Please try again.",
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
      _showMessage('Booking cancelled.');
    } else {
      _showMessage(
        "We couldn't cancel this booking. Please try again.",
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
            : SnackBarAction(label: 'Retry', onPressed: onRetry),
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
          label: Text(cancelling ? 'Cancelling\u2026' : 'Cancel booking'),
          style: TextButton.styleFrom(
            foregroundColor: colors.error,
            disabledForegroundColor: colors.onSurfaceVariant,
          ),
        ),
        if (cancelling) ...[
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: Text(
              'Cancelling your booking\u2026',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
