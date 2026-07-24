import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

const Color _cyanLight = AppColors.cyanLight;
const Color _cyanMid = Color(0xFFB2E0E5);

class CustomerBookServiceTab extends ConsumerWidget {
  const CustomerBookServiceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);

    if (state.bookingSubmitted) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 64,
            ),
            SizedBox(height: AppDimensions.s16),
            Text(
              'Booking Submitted!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppDimensions.s8),
            Text(
              'We\'ll confirm your appointment shortly.',
              style: TextStyle(fontSize: 14, color: AppColors.text3),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s16,
        AppDimensions.s12,
        AppDimensions.s16,
        AppDimensions.s32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book a Service',
            style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            'Fill in the details below',
            style: const TextStyle(fontSize: 13, color: AppColors.text3),
          ),
          const SizedBox(height: AppDimensions.s18),
          const Text(
            'Select Vehicle',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
          ...state.vehicles.map((v) {
            final isSel = state.selectedVehicle == v.id;
            return GestureDetector(
              onTap: () => notifier.setSelectedVehicle(v.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: AppDimensions.s8),
                padding: const EdgeInsets.all(AppDimensions.s14),
                decoration: BoxDecoration(
                  color: isSel ? _cyanLight : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                  border: Border.all(
                    color: isSel ? AppColors.accent : AppColors.border,
                    width: isSel ? 1.5 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSel ? _cyanMid : _cyanLight,
                        borderRadius: BorderRadius.circular(AppDimensions.r10),
                      ),
                      child: Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSel
                                  ? AppColors.accent
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s4),
                          Text(
                            '${v.plateNumber}  \u00b7  ${v.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSel)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppDimensions.s18),
          const Text(
            'Service Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
          ...notifier.serviceTypes.map((s) {
            final isSel = state.selectedServiceType == s;
            return GestureDetector(
              onTap: () => notifier.setSelectedServiceType(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: AppDimensions.s8),
                padding: const EdgeInsets.all(AppDimensions.s14),
                decoration: BoxDecoration(
                  color: isSel ? _cyanLight : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                  border: Border.all(
                    color: isSel ? AppColors.accent : AppColors.border,
                    width: isSel ? 1.5 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSel ? _cyanMid : _cyanLight,
                        borderRadius: BorderRadius.circular(AppDimensions.r10),
                      ),
                      child: Icon(
                        Icons.build_outlined,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSel
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSel)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppDimensions.s18),
          const Text(
            'Preferred Date',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    state.bookingDate ??
                    DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                notifier.setBookingDate(date);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s14,
                vertical: AppDimensions.s14,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.r12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Text(
                    state.bookingDate != null
                        ? '${state.bookingDate!.day}/${state.bookingDate!.month}/${state.bookingDate!.year}'
                        : 'Tap to select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: state.bookingDate != null
                          ? AppColors.textPrimary
                          : AppColors.text3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.s24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await notifier.submitBooking();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.s16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                ),
              ),
              child: const Text(
                'Submit Booking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
