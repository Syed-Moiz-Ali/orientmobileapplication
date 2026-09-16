import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';

/// Loading placeholder that mirrors the final Bookings structure — header,
/// counted section headings and the grouped compact rows — so the first paint
/// does not jump when the real records arrive.
class CustomerBookingsSkeleton extends StatelessWidget {
  const CustomerBookingsSkeleton({super.key});

  /// Roughly one compact booking row, so the placeholder sections read as the
  /// same list the customer is about to get.
  static const double _rowHeight = 94;

  @override
  Widget build(BuildContext context) {
    return CustomerSkeleton(
      builder: (context, block) {
        return AppResponsivePage(
          maxContentWidth: 1080,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomerSkeletonBox(width: 130, height: 26, color: block),
              const SizedBox(height: AppDimensions.s10),
              CustomerSkeletonBox(width: 200, height: 12, color: block),
              const SizedBox(height: AppDimensions.s20),
              AppSplitView(
                primaryFlex: context.adaptive.isMedium ? 1 : 3,
                secondaryFlex: context.adaptive.isMedium ? 1 : 2,
                spacing: AppDimensions.s24,
                primary: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomerSkeletonBox(width: 150, height: 18, color: block),
                    const SizedBox(height: AppDimensions.s10),
                    CustomerSkeletonBox(
                      height: _rowHeight * 3,
                      color: block,
                      radius: AppDimensions.radiusCard,
                    ),
                  ],
                ),
                secondary: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomerSkeletonBox(width: 80, height: 18, color: block),
                    const SizedBox(height: AppDimensions.s10),
                    CustomerSkeletonBox(
                      height: _rowHeight * 2,
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
