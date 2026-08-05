import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';

class HeaderBanner extends ConsumerWidget {
  const HeaderBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dashboardUiProvider.notifier);
    final kpis = notifier.kpis;

    // Derive banner pills from real KPI data when available.
    String activeLabel = '0 Active';
    String newLabel = '0 New';
    if (kpis.isNotEmpty) {
      final active = kpis.firstWhere(
        (k) => k.label.toLowerCase().contains('open') ||
            k.label.toLowerCase().contains('active'),
        orElse: () => kpis.first,
      );
      final fresh = kpis.firstWhere(
        (k) => k.label.toLowerCase().contains('new') ||
            k.label.toLowerCase().contains('today'),
        orElse: () => active,
      );
      activeLabel = '${active.value} Active';
      newLabel = '${fresh.value} New';
    }

    return GradientBanner(
      title: 'Owner Dashboard',
      pills: [
        GradientBannerPill(
          icon: Icons.work_outline_rounded,
          label: activeLabel,
          accent: AppColors.amber400,
        ),
        GradientBannerPill(
          icon: Icons.check_circle_outline_rounded,
          label: newLabel,
          accent: AppColors.cyan,
        ),
      ],
      icon: Icons.business_center_rounded,
    );
  }
}
