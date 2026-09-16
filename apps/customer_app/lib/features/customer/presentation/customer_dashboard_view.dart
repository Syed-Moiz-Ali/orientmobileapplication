import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_scaffold.dart';

class CustomerDashboardView extends ConsumerWidget {
  final CustomerDestination initialDestination;

  const CustomerDashboardView({
    super.key,
    this.initialDestination = CustomerDestination.home,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX (audit): honour the requested destination (e.g. 'Track Booking').
    return CustomerScaffold(initialDestination: initialDestination);
  }
}
