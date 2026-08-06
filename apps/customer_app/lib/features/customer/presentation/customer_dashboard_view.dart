import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_scaffold.dart';

class CustomerDashboardView extends ConsumerWidget {
  final int initialTab;
  const CustomerDashboardView({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX (audit): honour the requested tab (e.g. 'Track Booking' → Status).
    return CustomerScaffold(initialTab: initialTab);
  }
}
