import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/providers/dashboard_ui_providers.dart';

class PeriodDropdown extends ConsumerWidget {
  const PeriodDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.r20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.period,
          dropdownColor: AppColors.navy,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 16,
          ),
          isDense: true,
          onChanged: (v) => notifier.setPeriod(v ?? state.period),
          items: DashboardUiState.periods
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(
                    p,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
