import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';

class QuickJobAccessSection extends ConsumerWidget {
  const QuickJobAccessSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.s16,
              vertical: AppDimensions.s12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.r18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppDimensions.r2),
                  ),
                ),
                SizedBox(width: AppDimensions.s10),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.r8),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.accent,
                    size: 15,
                  ),
                ),
                SizedBox(width: AppDimensions.s10),
                Text(
                  'Quick Job Access',
                  style: AppTextStyles.rajdhaniLabel(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.s16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: notifier.jobCardController,
                        onChanged: (_) => notifier.clearQuickJobError(),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
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
                          contentPadding: EdgeInsets.symmetric(
                            vertical: AppDimensions.s12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.r12),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.r12),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.r12),
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
                      onTap: () => notifier.searchJobCard(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.s20,
                          vertical: AppDimensions.s14,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.navy, AppColors.accent],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.r12),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
