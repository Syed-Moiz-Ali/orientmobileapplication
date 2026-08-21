import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppDimensions.r20,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
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
    final colorScheme = Theme.of(context).colorScheme;

    final chips = <Widget>[
      CustomerStatCard(
        value: '${state.servicesThisYear}',
        label: 'Services\nThis Year',
        color: colorScheme.primary,
        bg: colorScheme.primary.withValues(alpha: 0.1),
      ),
      CustomerStatCard(
        value: '${state.vehicles.length}',
        label: 'Vehicles\nRegistered',
        color: const Color(0xFF3B82F6),
        bg: const Color(0xFF3B82F6).withValues(alpha: 0.1),
      ),
      CustomerStatCard(
        value: '${state.unpaidInvoices}',
        label: 'Unpaid\nInvoices',
        color: const Color(0xFFD97706),
        bg: const Color(0xFFD97706).withValues(alpha: 0.1),
      ),
    ];

    return AppAdaptiveGrid(
      minChildWidth: 140,
      childAspectRatio: 1.3,
      children: chips,
    );
  }
}
