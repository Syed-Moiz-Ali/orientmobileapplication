import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/supervisor/presentation/widgets/supervisor_scaffold.dart';

class SupervisorDashboardView extends ConsumerWidget {
  const SupervisorDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SupervisorScaffold();
  }
}
