/// FE-FIX (pre-deployment connectivity pass, P2-8): one canonical vocabulary
/// for status strings across all five apps. Screens used to mix raw backend
/// values ("in_service", "inProgress") with display text ("In Service",
/// "In Progress") — a customer could see three different labels for the same
/// state depending on which app they were looking at.
abstract final class AppStatusLabels {
  // ---- Booking / service job status (backend enum values) ----
  static String booking(String? status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'vehicle_received':
        return 'Vehicle Received';
      case 'in_service':
        return 'In Service';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status ?? '';
    }
  }

  // ---- Breakdown status ----
  static String breakdown(String? status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'inProgress':
      case 'dispatched':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status ?? '';
    }
  }

  // ---- Invoice status ----
  static String invoice(String? status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'partial':
        return 'Partially Paid';
      case 'overdue':
        return 'Overdue';
      case 'unpaid':
        return 'Unpaid';
      default:
        return status ?? '';
    }
  }

  /// The canonical label for any of the raw forms a screen may hold:
  /// "in_service", "inProgress", "In Progress" all map to one string.
  static String normalizeJob(String? raw) {
    final v = (raw ?? '').toLowerCase();
    switch (v) {
      case 'pending':
      case 'awaiting':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'vehicle_received':
        return 'Vehicle Received';
      case 'in_service':
      case 'inprogress':
      case 'in progress':
      case 'working':
        return 'In Service';
      case 'waiting_parts':
      case 'waiting parts':
        return 'Waiting Parts';
      case 'completed':
      case 'done':
        return 'Completed';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      case 'rejected':
      case 'sent_back':
        return 'Sent Back';
      default:
        return raw ?? '';
    }
  }
}
