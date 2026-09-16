import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';

/// Loading placeholder that mirrors the final Home composition (header,
/// service summary, quick actions, garage) so the first paint does not jump.
class CustomerHomeSkeleton extends StatelessWidget {
  const CustomerHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomerSkeleton(
      builder: (context, block) {
        return AppResponsivePage(
          maxContentWidth: 1080,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomerSkeletonBox(
                          width: 96,
                          height: 12,
                          color: block,
                        ),
                        const SizedBox(height: AppDimensions.s8),
                        CustomerSkeletonBox(
                          width: 150,
                          height: 26,
                          color: block,
                        ),
                      ],
                    ),
                  ),
                  CustomerSkeletonBox(
                    width: 42,
                    height: 42,
                    radius: AppDimensions.radiusPill,
                    color: block,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s20),
              AppSplitView(
                primaryFlex: context.adaptive.isMedium ? 1 : 3,
                secondaryFlex: context.adaptive.isMedium ? 1 : 2,
                spacing: AppDimensions.s24,
                primary: CustomerSkeletonBox(
                  height: 190,
                  color: block,
                  radius: AppDimensions.radiusCard,
                ),
                secondary: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < 3; i++) ...[
                            if (i > 0) const SizedBox(width: AppDimensions.s10),
                            Expanded(
                              child: CustomerSkeletonBox(
                                height: 92,
                                color: block,
                                radius: AppDimensions.radiusCard,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s24),
                    CustomerSkeletonBox(width: 120, height: 18, color: block),
                    const SizedBox(height: AppDimensions.s12),
                    CustomerSkeletonBox(
                      height: 128,
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
