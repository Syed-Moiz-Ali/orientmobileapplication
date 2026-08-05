import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/core/router/app_router.dart';

class CustomerBookingSuccessView extends StatefulWidget {
  final String? bookingRef;
  final String service;
  final String date;
  final String time;

  const CustomerBookingSuccessView({
    super.key,
    this.bookingRef,
    required this.service,
    required this.date,
    required this.time,
  });

  @override
  State<CustomerBookingSuccessView> createState() => _CustomerBookingSuccessViewState();
}

class _CustomerBookingSuccessViewState extends State<CustomerBookingSuccessView> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s32),
              const Text(
                'Booking Received!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.s12),
              const Text(
                'Your appointment request has been received. We\'ll confirm it shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.text3,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimensions.s32),
              AppCard(
                color: AppColors.surface,
                borderColor: AppColors.border,
                child: Column(
                  children: [
                    if (widget.bookingRef != null) ...[
                      _SumRow(icon: Icons.tag, label: 'Reference', value: widget.bookingRef!),
                      const Divider(height: 16, color: AppColors.border),
                    ],
                    _SumRow(icon: Icons.build_rounded, label: 'Service', value: widget.service),
                    const Divider(height: 16, color: AppColors.border),
                    _SumRow(icon: Icons.calendar_month_rounded, label: 'Date', value: widget.date),
                    const Divider(height: 16, color: AppColors.border),
                    _SumRow(icon: Icons.access_time_rounded, label: 'Time', value: widget.time),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.s40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to bookings tab (index 1) via router or pop to root and update state
                    context.go(AppRoutes.customerDashboard, extra: {'tab': 1});
                  },
                  child: const Text('Track Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: AppDimensions.s16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                  ),
                  onPressed: () {
                    context.go(AppRoutes.customerDashboard);
                  },
                  child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SumRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SumRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: AppColors.text3),
      const SizedBox(width: AppDimensions.s10),
      Text(label, style: const TextStyle(fontSize: 14, color: AppColors.text3)),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}
