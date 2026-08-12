import 'package:customer_app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

class CustomerBookingSuccessView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.s32),

              // ── SUCCESS ICON + HEADLINE ────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.success,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s20),
                    Text(
                      'Booking Submitted!',
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The workshop will confirm your slot shortly.\nTrack it anytime from My Bookings.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.text3,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.s32),

              // ── BOOKING SUMMARY CARD ───────────────────────────────────
              Text(
                'Booking Summary',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Keep this for your records',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.text3,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppDimensions.s10),
              AppCard(
                borderRadius: 24,
                padding: EdgeInsets.zero,
                color: AppColors.surface,
                borderColor: AppColors.border,
                child: Column(
                  children: [
                    if (bookingRef != null && bookingRef!.isNotEmpty) ...[
                      _InfoRow(
                        icon: Icons.tag_rounded,
                        label: 'Reference',
                        value: '#$bookingRef',
                        highlight: true,
                      ),
                      const Divider(height: 1, color: AppColors.line),
                    ],
                    _InfoRow(
                      icon: Icons.build_rounded,
                      label: 'Service',
                      value: service,
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: date,
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    _InfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: time.isNotEmpty ? time : 'TBC',
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    _InfoRow(
                      icon: Icons.pending_actions_rounded,
                      label: 'Status',
                      value: 'Pending Confirmation',
                      statusColor: AppColors.warning,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.s20),

              // ── WHAT HAPPENS NEXT CARD ─────────────────────────────────
              AppCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(AppDimensions.s16),
                color: AppColors.primaryBg,
                borderColor: AppColors.primaryBorder,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What happens next?',
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Our service team will review your booking and send a confirmation within 1–2 hours during working hours (Mon–Fri, 8am–6pm).',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.primary.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.s32),

              // ── ACTION BUTTONS ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.go(AppRoutes.customerDashboard, extra: {'tab': 2}),
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text('View My Bookings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.rPill),
                    ),
                    textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.customerDashboard),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.rPill),
                    ),
                    textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Back to Home'),
                ),
              ),
              const SizedBox(height: AppDimensions.s32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final Color? statusColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s16,
        vertical: AppDimensions.s14,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.text3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (statusColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor!.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.rPill),
              ),
              child: Text(
                value,
                style: textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          else
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 2,
                style: textTheme.bodyMedium?.copyWith(
                  color: highlight ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: highlight ? FontWeight.w900 : FontWeight.w700,
                  fontFamily:
                      highlight ? AppFontFamilies.mono : null,
                  letterSpacing: highlight ? 0.5 : 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
