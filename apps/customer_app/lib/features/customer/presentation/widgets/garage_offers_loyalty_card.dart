import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class GarageOffersLoyaltyCard extends StatelessWidget {
  final VoidCallback? onClaimOffer;

  const GarageOffersLoyaltyCard({super.key, this.onClaimOffer});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s18),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 14,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: AppDimensions.s4),
                    Text(
                      'GARAGE REWARDS',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '450 Points',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Text(
            'Summer AC & Battery Health Check',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.s6),
          Text(
            'Complimentary 15-point inspection with any full service this month.',
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFBFDBFE),
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          Wrap(
            spacing: AppDimensions.s10,
            runSpacing: AppDimensions.s10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppDimensions.r8),
                ),
                child: Text(
                  'CODE: ORIENT2026',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              FilledButton(
                onPressed:
                    onClaimOffer ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Voucher ORIENT2026 applied to next booking!',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                child: const Text('Claim Offer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
