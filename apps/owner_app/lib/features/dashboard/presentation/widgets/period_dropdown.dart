import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/data/datasources/dashboard_mock_datasource.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';

class PeriodDropdown extends ConsumerWidget {
  const PeriodDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);
    return AppDropdownButton(
      value: state.period,
      items: DashboardMockDataSource.periods,
      onChanged: (v) => notifier.setPeriod(v),
    );
  }
}
