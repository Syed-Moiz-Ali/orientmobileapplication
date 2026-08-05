import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_empty_fallbacks.dart';
import 'package:customer_app/core/router/app_router.dart';

class CustomerBookingsTab extends ConsumerStatefulWidget {
  const CustomerBookingsTab({super.key});

  @override
  ConsumerState<CustomerBookingsTab> createState() => _CustomerBookingsTabState();
}

class _CustomerBookingsTabState extends ConsumerState<CustomerBookingsTab> {
  BookingStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(customerBookingsProvider).value ?? const <CustomerBookingEntity>[];

    final filtered = _filter == null
        ? bookings
        : bookings.where((b) => b.status == _filter).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(AppDimensions.s16, AppDimensions.s12, AppDimensions.s16, AppDimensions.s8),
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Bookings',
                style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                '${filtered.length} booking${filtered.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 13, color: AppColors.text3),
              ),
              const SizedBox(height: AppDimensions.s12),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('All', null),
                    _filterChip('Pending', BookingStatus.pending),
                    _filterChip('Confirmed', BookingStatus.confirmed),
                    _filterChip('Completed', BookingStatus.completed),
                    _filterChip('Cancelled', BookingStatus.cancelled),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: filtered.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppDimensions.s16),
                  child: Center(
                    child: EmptyBookingsCard(
                      onBookService: () => context.push(AppRoutes.customerBookService),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.s16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.s12),
                  itemBuilder: (_, i) => _BookingCard(booking: filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, BookingStatus? status) {
    final sel = _filter == status;
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.s8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: sel ? AppColors.accent : AppColors.bg,
            borderRadius: BorderRadius.circular(AppDimensions.r20),
            border: Border.all(
              color: sel ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: sel ? Colors.white : AppColors.text2,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final CustomerBookingEntity booking;
  const _BookingCard({required this.booking});

  (Color, Color) _statusColors(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:
        return (const Color(0xFFB2E0E5), AppColors.accent);
      case BookingStatus.completed:
        return (AppColors.successBg, AppColors.success);
      case BookingStatus.pending:
        return (AppColors.warningBg, AppColors.warning);
      case BookingStatus.cancelled:
        return (AppColors.dangerBg, AppColors.danger);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (bg, fg) = _statusColors(booking.status);
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.customerBookingDetail,
        extra: booking,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.r14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bg.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimensions.r12),
              ),
              child: Icon(Icons.build_circle_outlined, color: fg, size: 24),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment',
                    style: AppTextStyles.rajdhaniLabel(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppDimensions.s4),
                  Text(
                    '${booking.vehicleName}  \u00b7  ${booking.plateNumber}',
                    style: const TextStyle(fontSize: 12, color: AppColors.text3),
                  ),
            const SizedBox(height: 4),
            Text(
                    booking.date,
                    style: const TextStyle(fontSize: 11, color: AppColors.text4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.s10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppDimensions.r20),
              ),
              child: Text(
                booking.statusLabel,
                style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}