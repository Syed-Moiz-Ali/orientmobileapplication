import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class GarageInfoCard extends StatelessWidget {
  final VoidCallback? onCall;
  final VoidCallback? onMap;

  const GarageInfoCard({super.key, this.onCall, this.onMap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(AppDimensions.s18),
      color: AppColors.surface,
      borderColor: AppColors.border,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: const Icon(Icons.garage_rounded, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Orient Auto Workshop',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mon - Sat: 8:00 AM - 7:00 PM • Open Now',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                  border: Border.all(color: AppColors.successBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'OPEN NOW',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.success,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Bay 3, Unit 4 Industrial Estate, Main Highway',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),

          // Amenities Pills Bar
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

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      onCall ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Calling Workshop Hotline: +1 800 555-AUTO'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: const Text('Call Workshop'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primaryBorder),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.rPill)),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: ElevatedButton.icon(
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
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.rPill)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppDimensions.rPill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.text3),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.text3, fontSize: 10, fontWeight: FontWeight.w600),
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s14),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dangerBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '24/7 Roadside Assistance',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: AppColors.danger),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stranded or car won\'t start? Request emergency breakdown tow',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.text3, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.rPill)),
            ),
            child: Text('Get Help', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
