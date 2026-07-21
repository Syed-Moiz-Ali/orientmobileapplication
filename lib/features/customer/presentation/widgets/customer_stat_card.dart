import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/features/customer/providers/customer_providers.dart';

class CustomerStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bg;

  const CustomerStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r14)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.orbitronKpiNumber(color: color)),
          const SizedBox(height: 5),
          Text(
            label,
            style: AppTextStyles.rajdhaniBodySmall(color: AppColors.text3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CustomerStatGrid extends StatelessWidget {
  final CustomerDashboardState state;

  const CustomerStatGrid({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final chips = [
      CustomerStatCard(
        value: '${state.servicesThisYear}',
        label: 'Services\nthis year',
        color: AppColors.accent,
        bg: AppColors.cyanLight,
      ),
      CustomerStatCard(
        value: '${state.vehicles.length}',
        label: 'Vehicles\nregistered',
        color: AppColors.info,
        bg: AppColors.infoBg,
      ),
      CustomerStatCard(
        value: '${state.unpaidInvoices}',
        label: 'Unpaid\ninvoice',
        color: AppColors.warning,
        bg: AppColors.warningBg,
      ),
    ];

    return Row(
      children: chips.asMap().entries.map((e) {
        final chip = e.value;
        final isLast = e.key == chips.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: chip,
          ),
        );
      }).toList(),
    );
  }
}
