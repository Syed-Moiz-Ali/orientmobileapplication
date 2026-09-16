import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// The Customer workspace's permanent primary destinations, in navigation
/// order.
///
/// This is the single source of truth for the bottom navigation, the workspace
/// page order and the dashboard's `?tab=` deep link values, so no other file
/// needs to know a destination's numeric index.
///
/// Two customer tasks are deliberately **not** here, because neither represents
/// a persistent destination:
///
/// * **Service Status** only makes sense while a vehicle is in the workshop.
/// * **Approvals** only exists while the workshop is waiting for a decision on a
///   sent estimate (`/customers/approvals/pending` returns pending decisions
///   only — the backend exposes no approval history), and a customer realistically
///   has one such decision at a time. Home, Bookings and Booking Details already
///   surface those decisions with an exact deep link, so Approvals lives on its
///   own contextual route instead of occupying a permanent slot.
enum CustomerDestination {
  home(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  bookings(
    label: 'Bookings',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month_rounded,
  ),
  vehicles(
    label: 'Vehicles',
    icon: Icons.directions_car_outlined,
    selectedIcon: Icons.directions_car_rounded,
  ),
  profile(
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
  );

  const CustomerDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  AppNavItem get navItem =>
      AppNavItem(label: label, icon: icon, selectedIcon: selectedIcon);

  /// Navigation destinations, in order.
  static final List<AppNavItem> navItems = List<AppNavItem>.unmodifiable(
    CustomerDestination.values.map((destination) => destination.navItem),
  );

  /// Reserved `?tab=` value for the pre-migration Status destination.
  static const String statusTabValue = 'status';

  /// Reserved `?tab=` value for the pre-migration Approvals destination.
  static const String approvalsTabValue = 'approvals';

  /// Numeric `?tab=` values used before Status and Approvals became contextual:
  /// 0 Home, 1 Status, 2 Bookings, 3 Approvals, 4 Vehicles, 5 Profile.
  ///
  /// They are still resolved with their *original* meaning so a bookmarked or
  /// shared link can never silently open a different destination after the
  /// destinations were reordered.
  static const Map<String, String> _legacyTabValues = {
    '0': 'home',
    '1': statusTabValue,
    '2': 'bookings',
    '3': approvalsTabValue,
    '4': 'vehicles',
    '5': 'profile',
  };

  /// Resolves a dashboard `?tab=` value to a destination name, migrating the
  /// legacy numeric values. The contextual [statusTabValue] and
  /// [approvalsTabValue] are returned as-is so callers can route them to their
  /// own pages.
  static String resolveTabValue(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.isEmpty) return home.name;
    final migrated = _legacyTabValues[value] ?? value;
    if (migrated == statusTabValue || migrated == approvalsTabValue) {
      return migrated;
    }
    for (final destination in CustomerDestination.values) {
      if (destination.name == migrated) return destination.name;
    }
    return home.name;
  }

  /// The destination requested by a `?tab=` value, or null when the value asks
  /// for one of the contextual pages (Status, Approvals).
  static CustomerDestination? fromTabValue(String? raw) {
    final value = resolveTabValue(raw);
    if (value == statusTabValue || value == approvalsTabValue) return null;
    return CustomerDestination.values.byName(value);
  }

  /// True when a `?tab=` value refers to the pre-migration Status destination.
  static bool isStatusTabValue(String? raw) =>
      resolveTabValue(raw) == statusTabValue;

  /// True when a `?tab=` value refers to the pre-migration Approvals
  /// destination, which is now the contextual Approvals page.
  static bool isApprovalsTabValue(String? raw) =>
      resolveTabValue(raw) == approvalsTabValue;
}
