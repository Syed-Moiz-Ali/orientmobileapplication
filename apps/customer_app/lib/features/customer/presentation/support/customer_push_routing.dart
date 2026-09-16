import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_notification_presentation.dart';

/// Where a tapped push should land, decided with no side effects.
class CustomerPushRoute {
  /// The category the payload resolved to. Unknown payloads become
  /// [NotifType.general].
  final NotifType type;

  /// A canonical `AppRoutes` location — never a hand-written path.
  final String location;

  /// True when the category had no destination of its own and the inbox is
  /// being used as the safe fallback.
  final bool isFallback;

  const CustomerPushRoute({
    required this.type,
    required this.location,
    required this.isFallback,
  });
}

/// Resolves an FCM `type` payload into a destination the customer app can open.
///
/// Push cannot identify a record: the backend's FCM data map carries only
/// `type`, and booking / invoice / breakdown detail routes need a full entity.
/// So this reuses the inbox's own product decisions — the same canonical parser
/// and the same category destinations — and falls back to the Notifications
/// inbox for anything without a destination of its own, including unknown
/// future categories. It never parses the title or body and never guesses an
/// identifier.
CustomerPushRoute resolveCustomerPushRoute(String? rawType) {
  final type = NotifType.fromWire(rawType);
  final destination = CustomerNotificationPresentation.destination(type);
  return CustomerPushRoute(
    type: type,
    location: destination ?? AppRoutes.customerNotifications,
    isFallback: destination == null,
  );
}
