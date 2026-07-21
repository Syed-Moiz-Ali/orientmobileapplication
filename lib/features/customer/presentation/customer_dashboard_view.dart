import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/widgets/exit_confirmation_dialog.dart';
import 'package:orientmobileapplication/features/customer/presentation/widgets/customer_scaffold.dart';

class CustomerDashboardView extends ConsumerStatefulWidget {
  const CustomerDashboardView({super.key});

  @override
  ConsumerState<CustomerDashboardView> createState() => _CustomerDashboardViewState();
}

class _CustomerDashboardViewState extends ConsumerState<CustomerDashboardView> {
  @override
  Widget build(BuildContext context) {
    return const ExitConfirmationWrapper(
      child: CustomerScaffold(),
    );
  }
}
