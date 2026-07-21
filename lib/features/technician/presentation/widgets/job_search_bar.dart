import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/features/technician/providers/technician_providers.dart';

class JobSearchBar extends ConsumerWidget {
  final VoidCallback? onJobFound;

  const JobSearchBar({super.key, this.onJobFound});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: notifier.jobCardController,
            onChanged: (_) => notifier.clearQuickJobError(),
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter Job Card Number...',
              hintStyle: AppTextStyles.rajdhaniBody(
                color: AppColors.text3,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.text3,
                size: 18,
              ),
              filled: true,
              fillColor: AppColors.bg,
              contentPadding: EdgeInsets.symmetric(vertical: AppDimensions.s12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r12),
                borderSide: BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
              errorText: state.quickJobError.isNotEmpty
                  ? state.quickJobError
                  : null,
            ),
          ),
        ),
        SizedBox(width: AppDimensions.s10),
        GestureDetector(
          onTap: () {
            notifier.searchJobCard();
            if (state.selectedJob != null) {
              onJobFound?.call();
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.s20,
              vertical: AppDimensions.s14,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.navy, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.r12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Go',
              style: AppTextStyles.rajdhaniBody(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
