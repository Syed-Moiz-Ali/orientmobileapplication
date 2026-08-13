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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // ── 1. SUCCESS ICON + HEADLINE ─────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4), width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(child: Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 48)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Booking Requested!',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The workshop will confirm your bay slot shortly.\nTrack live updates anytime from Appointments.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ── 2. BOOKING SUMMARY CARD ────────────────────────────────
              Text(
                'Booking Summary',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Keep this reference for your records',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              AppCard(
                borderRadius: 24,
                elevation: 0,
                padding: EdgeInsets.zero,
                color: colorScheme.surface,
                borderColor: colorScheme.outlineVariant,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                child: Column(
                  children: [
                    if (bookingRef != null && bookingRef!.isNotEmpty) ...[
                      _InfoRow(
                        icon: Icons.tag_rounded,
                        label: 'Reference',
                        value: '#$bookingRef',
                        highlight: true,
                        colorScheme: colorScheme,
                      ),
                      Divider(height: 1, color: colorScheme.outlineVariant),
                    ],
                    _InfoRow(
                      icon: Icons.build_rounded,
                      label: 'Service Package',
                      value: service,
                      colorScheme: colorScheme,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Scheduled Date',
                      value: date,
                      colorScheme: colorScheme,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _InfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time Slot',
                      value: time.isNotEmpty ? time : 'TBC',
                      colorScheme: colorScheme,
                    ),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    _InfoRow(
                      icon: Icons.pending_actions_rounded,
                      label: 'Status',
                      value: 'Pending Intake',
                      statusColor: colorScheme.secondary,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── 3. WHAT HAPPENS NEXT CARD ──────────────────────────────
              AppCard(
                borderRadius: 24,
                elevation: 0,
                padding: const EdgeInsets.all(20),
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderColor: colorScheme.primary.withValues(alpha: 0.2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.info_outline_rounded, color: colorScheme.primary, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What happens next?',
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Our team will review your booking and send confirmation within 1–2 hours during working hours (Mon–Fri, 8am–6pm).',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ── 4. ACTION BUTTONS ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.customerDashboard, extra: {'tab': 2}),
                  icon: Icon(Icons.calendar_month_rounded, size: 20, color: colorScheme.onPrimary),
                  label: Text('View Appointments'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.customerDashboard),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ),
              const SizedBox(height: 48),
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
  final ColorScheme colorScheme;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.statusColor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
          ),
          if (statusColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor!.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                value,
                style: textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w900),
              ),
            )
          else
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 2,
                style: textTheme.titleSmall?.copyWith(
                  color: highlight ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: highlight ? FontWeight.w900 : FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
