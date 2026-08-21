import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class GarageInfoCard extends StatelessWidget {
  final VoidCallback? onCall;
  final VoidCallback? onMap;

  const GarageInfoCard({super.key, this.onCall, this.onMap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      borderRadius: AppDimensions.r24,
      padding: const EdgeInsets.all(AppDimensions.s18),
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.garage_rounded, color: colorScheme.primary, size: 26),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orient Auto Workshop',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mon - Sat: 8:00 AM - 7:00 PM • Open Now',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: 'OPEN NOW',
                showDot: true,
                bg: const Color(0xFF10B981).withValues(alpha: 0.12),
                fg: const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Bay 3, Unit 4 Industrial Area, Dubai, UAE',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              _AmenityPill(icon: Icons.wifi_rounded, label: 'Free Wi-Fi'),
              const SizedBox(width: 6),
              _AmenityPill(icon: Icons.local_cafe_rounded, label: 'Lounge'),
              const SizedBox(width: 6),
              _AmenityPill(icon: Icons.ev_station_rounded, label: 'EV Charging'),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      onCall ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Calling Workshop Hotline: +971 4 800-AUTO'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: const Text('Call Workshop', style: TextStyle(fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r16)),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      onMap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening Google Maps navigation...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: const Text('Directions', style: TextStyle(fontWeight: FontWeight.w800)),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmenityPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.rPill),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 24/7 Breakdown Hotline Banner
class EmergencyBreakdownBanner extends StatelessWidget {
  final VoidCallback onTap;
  const EmergencyBreakdownBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.r24),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '24/7 Roadside Assistance',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stranded or vehicle won\'t start? Request emergency recovery',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.rPill)),
            ),
            child: const Text('Get Help', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
