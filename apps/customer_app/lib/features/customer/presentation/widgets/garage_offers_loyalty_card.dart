import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class GarageOffersLoyaltyCard extends StatelessWidget {
  final VoidCallback? onClaimOffer;

  const GarageOffersLoyaltyCard({super.key, this.onClaimOffer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.r24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(
                label: 'GARAGE REWARDS',
                icon: Icons.stars_rounded,
                bg: const Color(0xFFD97706).withValues(alpha: 0.15),
                fg: const Color(0xFFD97706),
              ),
              const Spacer(),
              Text(
                '450 Points',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Text(
            'Summer AC & Battery Health Check',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.s6),
          Text(
            'Complimentary 15-point inspection with any full service this month.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
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
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  'CODE: ORIENT2026',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                    fontFamily: AppFontFamilies.mono,
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
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                ),
                child: const Text('Claim Offer', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
