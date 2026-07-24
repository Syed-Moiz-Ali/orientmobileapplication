import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_scaffold.dart';

class CustomerDashboardView extends ConsumerWidget {
  const CustomerDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CustomerScaffold();
  }
}
