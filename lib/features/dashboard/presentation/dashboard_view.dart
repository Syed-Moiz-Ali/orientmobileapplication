import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/widgets/exit_confirmation_dialog.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/dashboard_body.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ExitConfirmationWrapper(
      child: DashboardBody(),
    );
  }
}
