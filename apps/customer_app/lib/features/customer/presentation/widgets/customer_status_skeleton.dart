import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';

/// Loading placeholder that mirrors the final Status structure (heading,
/// tracking panel, details) so the first paint does not jump.
class CustomerStatusSkeleton extends StatelessWidget {
  const CustomerStatusSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomerSkeleton(
      builder: (context, block) {
        final wide = !context.adaptive.isCompact;
        return AppResponsivePage(
          maxContentWidth: 1080,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomerSkeletonBox(width: 150, height: 24, color: block),
              const SizedBox(height: AppDimensions.s10),
              CustomerSkeletonBox(width: 230, height: 12, color: block),
              const SizedBox(height: AppDimensions.s20),
              AppSplitView(
                primaryFlex: context.adaptive.isMedium ? 1 : 3,
                secondaryFlex: context.adaptive.isMedium ? 1 : 2,
                spacing: AppDimensions.s24,
                primary: CustomerSkeletonBox(
                  height: 210,
                  color: block,
                  radius: AppDimensions.radiusCard,
                ),
                secondary: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomerSkeletonBox(width: 130, height: 18, color: block),
                    const SizedBox(height: AppDimensions.s12),
                    CustomerSkeletonBox(
                      height: wide ? 150 : 190,
                      color: block,
                      radius: AppDimensions.radiusCard,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
