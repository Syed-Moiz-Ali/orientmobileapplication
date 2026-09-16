import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:flutter/material.dart';

/// How much attention a notification category deserves.
enum NotificationTone { attention, positive, neutral }

/// Presentation and destination rules for customer notifications.
///
/// Pure and side-effect free, so the inbox's two riskiest decisions — what a
/// row looks like and where (if anywhere) it leads — are directly unit
/// testable without a widget tree.
class CustomerNotificationPresentation {
  CustomerNotificationPresentation._();

  /// Icon for a category. [NotifType.general] is deliberately neutral.
  static IconData icon(NotifType type) => switch (type) {
    NotifType.bookingReceived => Icons.event_available_rounded,
    NotifType.bookingAssigned => Icons.calendar_month_rounded,
    NotifType.approvalNeeded => Icons.fact_check_rounded,
    NotifType.completionApproved => Icons.check_circle_rounded,
    NotifType.invoiceReady => Icons.receipt_long_rounded,
    NotifType.paymentReceived => Icons.payments_rounded,
    NotifType.estimateApproved => Icons.thumb_up_alt_rounded,
    NotifType.estimateRejected => Icons.thumb_down_alt_rounded,
    NotifType.breakdownAssigned => Icons.car_crash_rounded,
    NotifType.general => Icons.notifications_rounded,
  };

  /// Short category name, shown in the row so the category is readable text
  /// rather than only a colour or an icon.
  static String label(NotifType type) => switch (type) {
    NotifType.bookingReceived || NotifType.bookingAssigned => 'Booking',
    NotifType.approvalNeeded => 'Estimate',
    NotifType.completionApproved => 'Service',
    NotifType.invoiceReady => 'Invoice',
    NotifType.paymentReceived => 'Payment',
    NotifType.estimateApproved || NotifType.estimateRejected => 'Estimate',
    NotifType.breakdownAssigned => 'Breakdown',
    NotifType.general => 'Update',
  };

  static NotificationTone tone(NotifType type) => switch (type) {
    NotifType.approvalNeeded => NotificationTone.attention,
    NotifType.completionApproved ||
    NotifType.estimateApproved ||
    NotifType.paymentReceived => NotificationTone.positive,
    NotifType.bookingReceived ||
    NotifType.bookingAssigned ||
    NotifType.invoiceReady ||
    NotifType.estimateRejected ||
    NotifType.breakdownAssigned ||
    NotifType.general => NotificationTone.neutral,
  };

  /// Theme-aware tone colour: no hardcoded palette, so dark mode is correct.
  static Color toneColor(ColorScheme colors, NotifType type) =>
      switch (tone(type)) {
        NotificationTone.attention => colors.primary,
        NotificationTone.positive => colors.tertiary,
        NotificationTone.neutral => colors.onSurfaceVariant,
      };

  /// The canonical destination this category genuinely leads to, or null.
  ///
  /// A notification carries no booking, job card, estimate or invoice
  /// identifier — the backend stores none — so only destinations that are
  /// meaningful *without* one are returned:
  ///
  /// * booking events  -> the customer's own bookings list
  /// * estimate/billing -> the approvals & billing page, which is where pending
  ///   estimates and settled invoices live
  ///
  /// Everything else (a decision the customer just made themselves, a
  /// breakdown dispatch with no customer-facing tracking surface, an unknown
  /// type) has nothing safe to open, so its row stays non-navigational rather
  /// than guessing at a destination.
  static String? destination(NotifType type) => switch (type) {
    NotifType.bookingReceived ||
    NotifType.bookingAssigned ||
    NotifType.completionApproved => AppRoutes.bookingsLocation,
    NotifType.approvalNeeded ||
    NotifType.invoiceReady ||
    NotifType.paymentReceived => AppRoutes.approvalsLocation(),
    NotifType.estimateApproved ||
    NotifType.estimateRejected ||
    NotifType.breakdownAssigned ||
    NotifType.general => null,
  };

  /// True when a row for this category opens something.
  static bool isActionable(NotifType type) => destination(type) != null;
}
